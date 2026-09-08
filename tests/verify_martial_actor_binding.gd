extends SceneTree

const ENGINE = preload("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd")
const MANUAL := "shaolin_arhat_vajra_art"
var failures: Array[String] = []

func _initialize() -> void:
    var engine = ENGINE.new()
    for pair in [[3, 7], [5, 3], [7, 9], [9, 7]]:
        engine.configure_martial_loadouts([MANUAL], {MANUAL: pair[0]}, [MANUAL], {MANUAL: pair[1]})
        var state := _state(engine)
        for actor in ["player", "enemy"]:
            var mastery: int = pair[0] if actor == "player" else pair[1]
            var result: Dictionary = engine.resolve_martial_card(MANUAL + "_star3", state, actor, {"full_absorb": true})
            _assert(result.state[actor].internal[0] == (1 if mastery >= 5 else 0), "%s%d must use own star5 recovery with peer%d" % [actor, mastery, pair[1] if actor == "player" else pair[0]])
            if engine.has_method("get_actor_card_definition"):
                for raw in engine.martial_registry.build_unlocked_cards(MANUAL, mastery):
                    var definition: Dictionary = engine.call("get_actor_card_definition", raw.id, actor)
                    _assert(definition.effect_steps == raw.effect_steps and definition.mastery == mastery, "Own registry overlays " + actor + str(mastery))
    _assert(engine.has_method("get_actor_card_definition") and engine.has_method("get_actor_cards_by_id"), "Actor owned-copy lookup APIs exist")
    if engine.has_method("get_actor_card_definition") and engine.has_method("get_actor_cards_by_id"):
        _verify_boundaries(engine)
    _verify_old_identity_preserved()
    for failure in failures: push_error(failure)
    print("MARTIAL_ACTOR_BINDING: %s (%d failures)" % ["PASS" if failures.is_empty() else "FAIL", failures.size()])
    quit(0 if failures.is_empty() else 1)

func _verify_boundaries(engine) -> void:
    var enemy_manual := "nangong_emperor_sword"
    # Pick a real different manual from registry, independent of caller source tags.
    for id in engine.martial_registry.get_manual_ids():
        if id != MANUAL: enemy_manual = id; break
    _assert(engine.call("configure_martial_loadouts", [MANUAL], {MANUAL: 3}, [enemy_manual], {enemy_manual: 7}) == true, "Fresh configure returns true")
    var state := _state(engine)
    _assert(engine.call("get_actor_card_definition", enemy_manual + "_star3", "player").is_empty(), "Foreign martial ID unavailable")
    _assert(engine.call("get_actor_cards_by_id", "unknown").is_empty(), "Unknown actor has no map")
    _assert(engine.call("get_actor_card_definition", MANUAL + "_star3", "unknown").is_empty(), "Unknown actor has no definition")
    _assert(engine.call("get_actor_card_definition", "unknown_card", "player").is_empty(), "Missing definition is unavailable")
    _assert(not engine.resolve_martial_card(MANUAL + "_star3", state, "enemy").completed, "Direct foreign actor call fails")
    var own: Dictionary = engine.call("get_actor_cards_by_id", "player")
    var saved := own.duplicate(true)
    var enemy_saved: Dictionary = engine.call("get_actor_cards_by_id", "enemy")
    own[MANUAL + "_star3"].effect_steps.clear()
    own.basic_guard.stamina_cost = 999
    var card: Dictionary = engine.call("get_actor_card_definition", MANUAL + "_star3", "player")
    card.effect_steps.clear()
    _assert(engine.call("get_actor_cards_by_id", "player") == saved, "Returned maps and nested definitions are owned copies")
    _assert(engine.call("get_actor_cards_by_id", "enemy") == enemy_saved, "Player copy mutation cannot affect other actor")
    var foreign: Dictionary = engine.call("get_actor_card_definition", enemy_manual + "_star3", "enemy")
    foreign.source = "basic"
    var mismatch: Dictionary = saved[MANUAL + "_star3"].duplicate(true)
    mismatch.id = "basic_guard"
    for bad in [{"card_id": enemy_manual + "_star3", "definition": foreign, "anchor_index": 2}, {"card_id": MANUAL + "_star3", "definition": mismatch, "anchor_index": 2}, {"card_id": MANUAL + "_star3", "definition": {"id": "", "source": "basic"}, "anchor_index": 2}]:
        for locked in [false, true]:
            engine.clear_locked_enemy_bundle()
            if locked: engine.lock_enemy_bundle(state, 1)
            var lock_before: Dictionary = engine.export_enemy_lock()
            var before := state.duplicate(true)
            var plan := [{"card_id": "basic_guard", "anchor_index": 1}, bad]
            var preview: Dictionary = engine.preview_player_plan(state, plan)
            var result: Dictionary = engine.resolve_bundle(plan, {}, state)
            _assert(not preview.valid and preview.get("failure_reason") == "MARTIAL_ACTOR_DEFINITION_MISMATCH", "Whole preview rejects actor mismatch")
            _assert(result.get("rejected", false) and not result.get("valid", true) and result.get("failure_reason") == "MARTIAL_ACTOR_DEFINITION_MISMATCH", "Whole resolve rejects actor mismatch")
            _assert(state == before and preview.state == before and result.state == before, "Rejected whole plan keeps resources, effects and metrics unchanged")
            _assert(engine.export_enemy_lock() == lock_before and result.get("resolved_actions", []).is_empty(), "Rejected whole plan preserves revealed or absent lock")
    var lock_before: Dictionary = engine.export_enemy_lock()
    var maps_before: Dictionary = engine.call("get_actor_cards_by_id", "player")
    _assert(engine.call("configure_martial_loadouts", [MANUAL], {MANUAL: 7}, [enemy_manual], {enemy_manual: 7}) == false, "Changed binding under lock rejected")
    _assert(engine.call("get_actor_cards_by_id", "player") == maps_before and engine.export_enemy_lock() == lock_before, "Rejected configure preserves maps and lock")
    _assert(engine.call("configure_martial_loadouts", [MANUAL], {MANUAL: 3}, [enemy_manual], {enemy_manual: 7}) == true, "Identical binding under lock accepted")
    _assert(engine.export_enemy_lock() == lock_before, "Identical configure cannot reroll lock")
    engine.clear_locked_enemy_bundle()
    _assert(engine.call("configure_martial_loadout", [enemy_manual], {enemy_manual: 3}) == true, "Single actor configure succeeds unlocked")
    _assert(not engine.cards_by_id.has(MANUAL + "_star3") and engine.get_enemy_martial_card_ids().is_empty(), "Reconfigure clears stale union and enemy entries")
    _assert(engine.cards_by_id.has("basic_guard") and engine.cards_by_id.has("ultimate_void_sword_qi"), "Reconfigure preserves basic and generic ultimate")
    engine.configure_martial_loadouts([MANUAL], {MANUAL: 5}, [MANUAL], {MANUAL: 3})
    var canonical: Dictionary = engine.call("get_actor_card_definition", MANUAL + "_star3", "player")
    var spoof := canonical.duplicate(true)
    spoof.source = "basic"
    spoof.category = "move"
    spoof.stamina_cost = 999
    var plan := [{"card_id": canonical.id, "definition": spoof, "anchor_index": 1, "span": 3, "direction": -1, "intent": "keep", "target_tile": 6}]
    var actions: Array = engine._build_player_actions(plan)
    var attempts: Array = engine._placement_attempts(plan, "player")
    _assert(actions.size() == 1 and actions[0].definition == canonical and actions[0].span == canonical.action_slots, "Supplied martial definition and span canonicalized before costs")
    _assert(attempts.size() == 1 and attempts[0].definition == canonical and attempts[0].execution_timing == canonical.action_slots, "Preparation uses same actor canonical definition and span")
    _assert(actions[0].direction == -1 and actions[0].target_tile == 6, "Canonicalization preserves placement targeting")
    _assert(engine.cards_by_id[canonical.id] == canonical, "Discovery union keeps player precedence")
    engine.configure_martial_loadouts([MANUAL], {MANUAL: 7}, [MANUAL], {MANUAL: 3})
    engine.configure_bimu_constraints([{"constraint_id": "CST_TECH_MULTI_SLOT_SEAL"}], [MANUAL], [MANUAL])
    var mixed := [{"card_id": MANUAL + "_star7", "definition": {"id": "basic_guard"}, "anchor_index": 1}]
    _assert(engine.preview_player_plan(state, mixed).get("failure_reason") == "MARTIAL_ACTOR_DEFINITION_MISMATCH" and engine.resolve_bundle(mixed, {}, state).get("failure_reason") == "MARTIAL_ACTOR_DEFINITION_MISMATCH", "Actor identity preflight precedes constraint consumer")

func _state(engine) -> Dictionary:
    var actor := {"health": [30, 30], "stamina": [5, 5], "internal": [4, 4], "momentum": [0, 5]}
    var state: Dictionary = engine.make_initial_state({"player": actor, "enemy": actor}, 4, 6)
    state.player.internal[0] = 0
    state.enemy.internal[0] = 0
    return state

func _assert(value: bool, message: String) -> void:
    if not value: failures.append(message)

func _verify_old_identity_preserved() -> void:
    var bytes := FileAccess.get_file_as_bytes("res://tests/fixtures/pre_publication_save_v1_actor_shared.json")
    var directory := OS.get_cache_dir().path_join("ten-paces-actor-old-" + str(Time.get_ticks_usec()))
    _assert(DirAccess.make_dir_recursive_absolute(directory) == OK, "Create isolated old identity directory")
    var path := directory.path_join("primary.json")
    var file := FileAccess.open(path, FileAccess.WRITE)
    file.store_buffer(bytes)
    file.close()
    for iteration in range(2):
        var store = preload("res://src/run/run_save_store.gd").new(directory)
        var loaded: Dictionary = store.load_checkpoint()
        _assert(not loaded.ok and loaded.status == "INCOMPATIBLE", "Old semantic identity remains incompatible on open " + str(iteration))
        _assert(FileAccess.get_file_as_bytes(path) == bytes, "Old QA file bytes preserved on repeated open")
    if failures.is_empty():
        DirAccess.remove_absolute(path)
        DirAccess.remove_absolute(directory)
