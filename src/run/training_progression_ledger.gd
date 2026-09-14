extends RefCounted
## Validates temporal accounting; never applies imported effects to a live run.
const CODEC = preload("res://src/run/run_checkpoint_codec.gd")

static func validate(owner, snapshot: Dictionary, catalog) -> bool:
    var events: Array = snapshot.progression_events
    if events.size() > 1024: return false
    var audit = owner.get_script().new()
    if not audit.configure_opponents(catalog, snapshot.run_seed): return false
    if not snapshot.player_manual_loadout.is_empty():
        if not audit.start_new_run() or not audit.confirm_setup_loadout(snapshot.player_manual_loadout, snapshot.player_mastery_by_manual): return false
    var routes: Array = snapshot.route_history.duplicate(true)
    if not snapshot.pending_jianghu.is_empty(): routes.append(snapshot.pending_jianghu)
    var reward_count := 0
    var route_count := 0
    for index in range(events.size()):
        var event = events[index]
        if typeof(event) != TYPE_DICTIONARY or not CODEC.integer(event.get("sequence"), index + 1, index + 1): return false
        match event.get("kind"):
            "reward":
                if event.size() != 3 or not CODEC.integer(event.get("index"), reward_count, reward_count): return false
                if reward_count >= snapshot.reward_history.size() or route_count != reward_count * 4: return false
                var receipt: Dictionary = snapshot.reward_history[reward_count].duplicate(true)
                if not owner._valid_reward(receipt, audit.get_owned_player_manuals(), catalog.get_candidate(receipt.opponent_candidate_id)): return false
                receipt.erase("duel_index")
                receipt.erase("opponent_candidate_id")
                if audit._progression.apply_reward_receipt(receipt).is_empty(): return false
                reward_count += 1
            "route":
                if event.size() != 3 or not CODEC.integer(event.get("index"), route_count, route_count): return false
                if route_count >= routes.size() or reward_count != route_count / 4 + 1: return false
                audit._current_screen = "JIANGHU"
                audit.completed_duels = reward_count
                audit.duel_index = reward_count
                audit.jianghu_step = route_count % 4
                audit._next_opponent_id = catalog.select_campaign_candidate_id(reward_count + 1)
                audit._pending_jianghu.clear()
                if not audit.select_jianghu_node(routes[route_count].id, audit.jianghu_step): return false
                route_count += 1
            "training":
                if event.size() != 8 or typeof(event.get("allocations")) != TYPE_DICTIONARY: return false
                if not CODEC.integer(event.get("route_count"), route_count, route_count): return false
                if event.get("screen") == "BRIEFING":
                    if reward_count >= 10 or route_count != reward_count * 4 or not CODEC.integer(event.get("duel_index"), reward_count + 1, reward_count + 1): return false
                elif event.get("screen") == "JIANGHU":
                    if reward_count < 1 or reward_count >= 10 or not CODEC.integer(event.get("duel_index"), reward_count, reward_count): return false
                else: return false
                var preview: Dictionary = audit._progression.preview_training(event.allocations)
                if not preview.ok: return false
                if not CODEC.integer(event.get("pool_before"), preview.pool_before, preview.pool_before) or not CODEC.integer(event.get("pool_after"), preview.pool_after, preview.pool_after): return false
                if not audit._progression.commit_training(event.allocations): return false
            _: return false
    if reward_count != snapshot.reward_history.size() or route_count != routes.size(): return false
    var expected: Dictionary = audit.get_progression_snapshot()
    for key in ["owned_manual_ids", "mastery_by_manual", "training_by_manual", "free_training_pool", "pending_duplicate_transfers"]:
        if expected[key] != snapshot.progression[key]: return false
    return true
