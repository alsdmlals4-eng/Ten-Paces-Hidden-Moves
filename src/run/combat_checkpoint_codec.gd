class_name CombatCheckpointCodec
extends RefCounted

# Explicit domain DTO. Packed timing indices become arrays; no object serialization.
static func portable(value):
    match typeof(value):
        TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_ARRAY:
            var items: Array = []
            for item in value: items.append(portable(item))
            return items
        TYPE_DICTIONARY:
            var result := {}
            for key in value: result[key] = portable(value[key])
            return result
        TYPE_FLOAT:
            return int(value) if is_finite(value) and value == floor(value) else value
    return value

static func integer(value, minimum: int = 0, maximum: int = 9007199254740991) -> bool:
    return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) and float(value) == floor(float(value)) and value >= minimum and value <= maximum

static func _keys(value, required: Array, optional: Array = []) -> bool:
    if typeof(value) != TYPE_DICTIONARY: return false
    for key in required:
        if not value.has(key): return false
    for key in value:
        if key not in required and key not in optional: return false
    return true

func validate(dto: Dictionary, expected_binding: Dictionary = {}) -> Dictionary:
    var bad := {"ok": false, "status": "CORRUPT", "error": "Malformed combat checkpoint"}
    if not load("res://src/run/run_checkpoint_codec.gd").json_safe(dto, 0, [0]): return bad
    dto = portable(dto)
    if not _keys(dto, ["phase", "duel_index", "attempt_id", "state", "context", "enemy_lock", "binding", "player_plan", "state_before", "reservation_anchors", "review_summary"]): return bad
    if dto.phase not in ["PLANNING", "BUNDLE_COMMITTED", "BUNDLE_RESOLVED"] or not integer(dto.duel_index, 1, 10) or not integer(dto.attempt_id, 0, 1): return bad
    for field in ["state", "context", "enemy_lock", "binding", "state_before", "review_summary"]:
        if typeof(dto[field]) != TYPE_DICTIONARY: return bad
    for field in ["player_plan", "reservation_anchors"]:
        if typeof(dto[field]) != TYPE_ARRAY: return bad
    if not expected_binding.is_empty() and portable(dto.binding) != portable(expected_binding): return bad
    bad.error = "Combat binding mismatch"
    var engine = _engine(dto.binding)
    if engine == null: return bad
    if dto.binding.has("resolved_encounter") and dto.binding.resolved_encounter.stage != dto.duel_index: return bad
    bad.error = "Combat state or timing context malformed"
    if not _state(dto.state) or not _context(dto.context, dto.state): return bad
    if dto.binding.has("resolved_encounter") and not _variable_enemy_state(dto.state.enemy, dto.binding.resolved_encounter, dto.binding.bimu_receipt): return bad
    bad.error = "Enemy lock malformed"
    if not _lock(dto.enemy_lock, dto.state, engine, dto.phase == "PLANNING"): return bad
    if dto.state.enemy.get("candidate_id", "") != dto.binding.enemy_candidate_id: return bad
    if dto.phase == "PLANNING":
        if not dto.player_plan.is_empty() or not dto.state_before.is_empty() or not dto.reservation_anchors.is_empty() or not dto.review_summary.is_empty(): return bad
        if dto.state.enemy.health[0] <= 0: return bad
        # Existing draw/resource carry can enter a fresh duel at player HP 0.
        # Only that initial boundary is allowed; envelope and bridge check carry.
        if dto.state.player.health[0] == 0:
            if dto.state.round_number != 1 or dto.state.bundle_index != 1 or not dto.state.get("public_resolution_history", []).is_empty(): return bad
            for value in dto.state.battle_metrics.values():
                if value != 0: return bad
    else:
        bad.error = "Committed source state malformed"
        if not _state(dto.state_before) or not _context(dto.context, dto.state_before): return bad
        if dto.binding.has("resolved_encounter") and not _variable_enemy_state(dto.state_before.enemy, dto.binding.resolved_encounter, dto.binding.bimu_receipt): return bad
        if dto.phase == "BUNDLE_COMMITTED" and portable(dto.state) != portable(dto.state_before): return bad
        bad.error = "Committed plan malformed"
        if not _plan(dto.player_plan, dto.context, engine): return bad
        if not engine.preview_player_plan(dto.state_before, dto.player_plan).get("valid", false): return bad
        var expected_reservations: Array = []
        for row in dto.player_plan:
            if row.definition.get("source") == "ultimate" or row.definition.get("source_kind") == "ultimate": expected_reservations.append(int(row.anchor_index))
        if portable(dto.reservation_anchors) != expected_reservations: return bad
        if not expected_reservations.is_empty() and dto.state_before.player.momentum[0] != 0: return bad
        if dto.phase == "BUNDLE_COMMITTED" and not dto.review_summary.is_empty(): return bad
        if dto.phase == "BUNDLE_RESOLVED" and not _summary(dto.review_summary): return bad
    return {"ok": true, "status": "VALID"}

func _engine(binding: Dictionary):
    if not _keys(binding, ["player_loadout", "player_mastery_by_manual", "enemy_candidate_id", "enemy_loadout", "enemy_mastery_by_manual", "enemy_runtime_binding", "effective_enemy_mastery_by_manual", "bimu_receipt"], ["resolved_encounter"]): return null
    for field in ["player_loadout", "enemy_loadout"]:
        if typeof(binding[field]) != TYPE_ARRAY: return null
    for field in ["player_mastery_by_manual", "enemy_mastery_by_manual", "enemy_runtime_binding", "effective_enemy_mastery_by_manual", "bimu_receipt"]:
        if typeof(binding[field]) != TYPE_DICTIONARY: return null
    if binding.player_loadout.size() != 4 or typeof(binding.enemy_candidate_id) != TYPE_STRING: return null
    var opponent: Dictionary
    if binding.has("resolved_encounter"):
        var provider = load("res://src/run/variable_opponent_roster.gd").new()
        if not provider.validate_encounter(binding.resolved_encounter): return null
        opponent = provider.get_encounter_candidate(binding.resolved_encounter)
        var expected_loadout: Array = []
        var expected_mastery := {}
        for manual in binding.resolved_encounter.manuals:
            expected_loadout.append(manual.id)
            expected_mastery[manual.id] = manual.mastery
        if binding.enemy_candidate_id != opponent.candidate_id or binding.enemy_loadout != expected_loadout or binding.enemy_mastery_by_manual != expected_mastery: return null
    else:
        var catalog = load("res://src/run/vertical_slice_opponent_catalog.gd").new()
        opponent = catalog.get_candidate(binding.enemy_candidate_id)
        if opponent.is_empty() or binding.enemy_loadout != [opponent.signature_manual_id]: return null
        if binding.enemy_mastery_by_manual != {opponent.signature_manual_id: int(opponent.signature_star_seed)}: return null
    var adapter = load("res://src/run/vertical_slice_opponent_runtime_binding.gd").new()
    var runtime: Dictionary = adapter.build(opponent)
    if binding.has("resolved_encounter"):
        runtime["stats"] = binding.resolved_encounter.stats.duplicate(true)
        runtime["final_stat_total_seed"] = 0
        for value in runtime.stats.values(): runtime.final_stat_total_seed += int(value)
    if portable(runtime) != portable(binding.enemy_runtime_binding): return null
    var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
    engine.variable_opponent_rules = binding.has("resolved_encounter")
    for field in ["player_mastery_by_manual", "enemy_mastery_by_manual"]:
        for id in binding[field]:
            if typeof(id) != TYPE_STRING or engine.martial_registry.get_manual(id).is_empty() or not integer(binding[field][id], 1, 10): return null
    for id in binding.player_loadout:
        if typeof(id) != TYPE_STRING or not binding.player_mastery_by_manual.has(id): return null
    for id in binding.enemy_loadout:
        if typeof(id) != TYPE_STRING or not binding.enemy_mastery_by_manual.has(id): return null
    if typeof(binding.bimu_receipt.get("selections")) != TYPE_ARRAY: return null
    if not engine.configure_bimu_constraints(binding.bimu_receipt.selections, binding.player_loadout, binding.enemy_loadout): return null
    if not engine.configure_enemy_runtime_binding(binding.enemy_runtime_binding): return null
    if portable(engine.get_bimu_enemy_mastery(binding.enemy_mastery_by_manual)) != portable(binding.effective_enemy_mastery_by_manual): return null
    if not engine.configure_martial_loadouts(binding.player_loadout, binding.player_mastery_by_manual, binding.enemy_loadout, binding.effective_enemy_mastery_by_manual): return null
    return engine

func _context(context: Dictionary, state: Dictionary) -> bool:
    if not _keys(context, ["round_number", "bundle_index", "current_timing", "total_timings", "timing_sequence"]): return false
    if not integer(context.round_number, 1) or not integer(context.bundle_index, 1, 3): return false
    if context.round_number != state.round_number or context.bundle_index != state.bundle_index: return false
    return context.timing_sequence == [3, 3, 4] and context.total_timings == 10 and integer(context.current_timing, 1, 10) and context.current_timing == [1, 4, 7][int(context.bundle_index) - 1]

func _state(state: Dictionary) -> bool:
    if not _keys(state, ["round_number", "bundle_index", "player", "enemy", "ai_decision_seed", "ai_enabled", "battle_metrics"], ["public_resolution_history"]): return false
    if not integer(state.round_number, 1) or not integer(state.bundle_index, 1, 3) or not integer(state.ai_decision_seed, -9007199254740991) or typeof(state.ai_enabled) != TYPE_BOOL: return false
    if not _actor(state.player) or not _actor(state.enemy): return false
    if not _keys(state.battle_metrics, ["successful_dodges", "clash_wins", "player_health_lost", "rounds_elapsed", "ultimate_uses"]): return false
    for value in state.battle_metrics.values():
        if not integer(value): return false
    if typeof(state.get("public_resolution_history", [])) != TYPE_ARRAY: return false
    for row in state.get("public_resolution_history", []):
        if not _keys(row, ["round_number", "bundle_index", "actor", "card_id", "category", "outcome"]): return false
        if not integer(row.round_number, 1) or not integer(row.bundle_index, 1, 3): return false
        if row.actor not in ["player", "enemy"] or typeof(row.card_id) != TYPE_STRING or typeof(row.category) != TYPE_STRING or typeof(row.outcome) != TYPE_STRING: return false
    return true

func _actor(actor) -> bool:
    if not _keys(actor, ["name", "epithet", "health", "stamina", "internal", "momentum", "attack_power", "stats", "start_penalties", "statuses", "tile", "next_attack_bonus", "fortitude_next_attack", "prepare_active"], ["candidate_id", "observation_points", "observation_reveal_index", "observation_reveals", "status_counts", "battle_uses", "defense"]): return false
    for key in ["name", "epithet"]:
        if typeof(actor[key]) != TYPE_STRING: return false
    for key in ["health", "stamina", "internal", "momentum"]:
        var pair = actor[key]
        if typeof(pair) != TYPE_ARRAY or pair.size() != 2 or not integer(pair[1], 1) or not integer(pair[0], 0, int(pair[1])): return false
    if actor.momentum[1] != 5 or not integer(actor.tile, 1, 10): return false
    for key in ["attack_power", "next_attack_bonus", "observation_points", "observation_reveal_index", "defense"]:
        if actor.has(key) and not integer(actor[key]): return false
    for key in ["fortitude_next_attack", "prepare_active"]:
        if typeof(actor[key]) != TYPE_BOOL: return false
    if not _keys(actor.stats, ["external", "constitution", "agility", "internal_power", "insight"]): return false
    for value in actor.stats.values():
        if not integer(value, 1): return false
    if not _keys(actor.start_penalties, ["health", "stamina", "internal"]): return false
    for value in actor.start_penalties.values():
        if not integer(value): return false
    if typeof(actor.statuses) != TYPE_ARRAY: return false
    for status in actor.statuses:
        if not _keys(status, ["label", "kind"]): return false
        if typeof(status.label) != TYPE_STRING or typeof(status.kind) != TYPE_STRING: return false
    for key in ["status_counts", "battle_uses"]:
        if actor.has(key):
            if typeof(actor[key]) != TYPE_DICTIONARY: return false
            for id in actor[key]:
                if typeof(id) != TYPE_STRING: return false
                if key == "battle_uses":
                    if typeof(actor[key][id]) != TYPE_BOOL: return false
                elif not integer(actor[key][id]): return false
    if typeof(actor.get("observation_reveals", [])) != TYPE_ARRAY: return false
    for entry in actor.get("observation_reveals", []):
        if typeof(entry) != TYPE_ARRAY: return false
        for label in entry:
            if typeof(label) != TYPE_STRING: return false
    return true

func _lock(lock: Dictionary, state: Dictionary, engine, allow_empty: bool) -> bool:
    if not _keys(lock, ["key", "actions"]) or typeof(lock.key) != TYPE_STRING or typeof(lock.actions) != TYPE_ARRAY: return false
    if lock.key.is_empty(): return allow_empty and lock.actions.is_empty()
    if lock.key != "%d:%d" % [state.round_number, state.bundle_index]: return false
    var used := {}
    var allowed_cards: Dictionary = engine.get_actor_cards_by_id("enemy")
    for action in lock.actions:
        if not _keys(action, ["actor", "anchor_index", "span", "execution_timing", "definition", "targeting_mode", "target_ready", "target_tile", "direction", "origin_tile", "ai_reason", "ai_seed", "action_types"]) or action.get("actor") != "enemy": return false
        if not _action(action, state.bundle_index, allowed_cards, used): return false
        if not integer(action.get("execution_timing"), 1, 10) or action.execution_timing != action.anchor_index + action.span - 1: return false
        if not integer(action.get("ai_seed"), -9007199254740991) or typeof(action.get("ai_reason")) != TYPE_STRING or typeof(action.get("action_types")) != TYPE_ARRAY: return false
        for label in action.action_types:
            if typeof(label) != TYPE_STRING: return false
    return true

func _plan(plan: Array, context: Dictionary, engine) -> bool:
    var used := {}
    var allowed_cards: Dictionary = engine.get_actor_cards_by_id("player")
    for row in plan:
        if not _keys(row, ["card_id", "card_name", "definition", "anchor_index", "span", "indices", "targeting_mode", "target_ready", "resource_ready", "target_tile", "direction", "origin_tile", "target_text"], ["intent"]): return false
        if not _action(row, context.bundle_index, allowed_cards, used): return false
        if typeof(row.card_name) != TYPE_STRING or typeof(row.target_text) != TYPE_STRING or typeof(row.resource_ready) != TYPE_BOOL or row.resource_ready != true: return false
        if row.has("intent") and typeof(row.intent) != TYPE_STRING: return false
        if row.get("card_id") != row.definition.id or typeof(row.get("indices")) != TYPE_ARRAY: return false
        var expected: Array = []
        for index in range(int(row.anchor_index), int(row.anchor_index + row.span)): expected.append(index)
        if row.indices != expected: return false
        if not engine.get_action_lock_reason(row.card_id).is_empty(): return false
    return used.size() == [3, 3, 4][int(context.bundle_index) - 1]

func _action(row: Dictionary, bundle, allowed_cards: Dictionary, used: Dictionary) -> bool:
    if typeof(row.get("definition")) != TYPE_DICTIONARY: return false
    var id = row.definition.get("id")
    if typeof(id) != TYPE_STRING or not allowed_cards.has(id) or portable(row.definition) != portable(allowed_cards[id]): return false
    if not integer(row.get("anchor_index"), 1, 10) or not integer(row.get("span"), 1, 4): return false
    if row.span != allowed_cards[id].get("action_slots", 1): return false
    var first: int = [1, 4, 7][int(bundle) - 1]
    var last: int = [3, 6, 10][int(bundle) - 1]
    for index in range(int(row.anchor_index), int(row.anchor_index + row.span)):
        if index < first or index > last or used.has(index): return false
        used[index] = true
    return row.get("target_ready") == true and typeof(row.get("target_ready")) == TYPE_BOOL and integer(row.get("target_tile"), 0, 10) and integer(row.get("origin_tile"), 0, 10) and integer(row.get("direction"), -1, 1) and row.get("targeting_mode") in ["none", "move_intent", "tile"]

func _summary(summary: Dictionary) -> bool:
    if not _keys(summary, ["opponent_actual", "cause_code", "cause_label", "decisive_timing", "distance_before", "distance_after", "review_focus", "review_dimension", "player_plan_count"]): return false
    for key in ["opponent_actual", "cause_code", "cause_label", "review_focus", "review_dimension"]:
        if typeof(summary.get(key)) != TYPE_STRING: return false
    for key in ["decisive_timing", "distance_before", "distance_after", "player_plan_count"]:
        if not integer(summary.get(key)): return false
    return true

func _variable_enemy_state(enemy: Dictionary, encounter: Dictionary, receipt: Dictionary) -> bool:
    var expected: Dictionary = load("res://src/run/bimu_constraint_model.gd").new().enemy_state_overlay({"stats": encounter.stats.duplicate(true)}, receipt)
    if portable(enemy.stats) != portable(expected.stats): return false
    for resource in ["health", "stamina", "internal"]:
        if enemy[resource][1] != encounter.resource_caps[resource]: return false
    if enemy.get("observation_points", 0) != 0 or enemy.get("observation_reveal_index", 0) != 0 or not enemy.get("observation_reveals", []).is_empty(): return false
    return true
