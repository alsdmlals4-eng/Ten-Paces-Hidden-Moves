# 절초·강건·밀착 전투 계약을 엔진 수준에서 검증한다.
extends SceneTree

const HUD_PATH := "res://data/combat/combat_hud_preview.json"
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hud := _load_json(HUD_PATH)
    _verify_ultimate_damage_and_momentum(hud)
    _verify_interruption_and_fortitude(hud)
    _verify_momentum_sources(hud)
    _verify_engagement_and_movement(hud)
    _verify_timing_snapshots(hud)
    _finish()

func _verify_ultimate_damage_and_momentum(hud: Dictionary) -> void:
    var cases := [
        ["ultimate_ten_paces_wave", 4, 5, 20, 1],
        ["ultimate_cleave_peak", 4, 6, 10, 1],
        ["ultimate_void_sword_qi", 4, 7, 0, 1]
    ]
    for case_value in cases:
        var case: Array = case_value
        var engine := CombatResolutionEngine.new()
        engine.rules["enemy_bundles"] = {}
        var state := engine.make_initial_state(hud, int(case[1]), int(case[2]))
        var player: Dictionary = (state.get("player", {}) as Dictionary).duplicate(true)
        player["momentum"] = [0, 5]
        state["player"] = player
        var definition: Dictionary = (engine.cards_by_id.get(str(case[0]), {}) as Dictionary).duplicate(true)
        var result := engine.resolve_bundle([_placement(definition, 1, 1)], _context(1), state)
        var enemy: Dictionary = (result.get("state", {}) as Dictionary).get("enemy", {})
        var enemy_health: Array = enemy.get("health", [0, 0])
        if int(enemy_health[0]) != int(case[3]):
            failures.append("Ultimate %s expected enemy health %d, got %d." % [str(case[0]), int(case[3]), int(enemy_health[0])])
        var result_player: Dictionary = (result.get("state", {}) as Dictionary).get("player", {})
        var momentum: Array = result_player.get("momentum", [0, 0])
        if int(momentum[0]) != int(case[4]):
            failures.append("Ultimate %s must receive the automatic completed-bundle momentum. expected=%d actual=%d" % [str(case[0]), int(case[4]), int(momentum[0])])
        var events: Array = result.get("presentation_events", [])
        if events.is_empty() or str((events[events.size() - 1] as Dictionary).get("type", "")) != "bundle_state":
            failures.append("Ultimate resolution must expose one authoritative presentation event stream.")

func _verify_interruption_and_fortitude(hud: Dictionary) -> void:
    var engine := CombatResolutionEngine.new()
    engine.rules["enemy_bundles"] = {"1": [
        {"timing": 1, "card_id": "basic_quick_attack", "direction": -1},
        {"timing": 2, "card_id": "basic_move", "target_tile": 5, "direction": -1},
        {"timing": 3, "card_id": "basic_quick_attack", "direction": -1}
    ]}
    var state := engine.make_initial_state(hud, 4, 5)
    var stance: Dictionary = engine.cards_by_id.get("basic_stance", {})
    var heavy: Dictionary = engine.cards_by_id.get("basic_heavy_attack", {})
    var result := engine.resolve_bundle([_placement(stance, 1), _placement(heavy, 2)], _context(1), state)
    if not _has_outcome(result.get("resolved_actions", []), "basic_stance", "interrupted"):
        failures.append("Damage must interrupt an unresolved utility action only at that same timing.")
    if _has_outcome(result.get("resolved_actions", []), "basic_heavy_attack", "interrupted"):
        failures.append("Damage at timing 1 must not interrupt an action scheduled for timing 3.")
    if not _has_outcome(result.get("resolved_actions", []), "basic_heavy_attack", "clash_win"):
        failures.append("The surviving timing-3 heavy attack must resolve as a clash against the timing-3 quick attack.")
    var result_state: Dictionary = result.get("state", {})
    var player: Dictionary = result_state.get("player", {})
    var enemy: Dictionary = result_state.get("enemy", {})
    if int((player.get("health", [0, 0]) as Array)[0]) != 24 or int((enemy.get("health", [0, 0]) as Array)[0]) != 28:
        failures.append("The example sequence must deal only timing-1 hit damage to A and timing-3 clash difference to B.")

    var lethal_engine := CombatResolutionEngine.new()
    var lethal: Dictionary = (lethal_engine.cards_by_id.get("basic_quick_attack", {}) as Dictionary).duplicate(true)
    lethal["id"] = "lethal_quick"
    lethal["damage"] = "30"
    lethal_engine.cards_by_id["lethal_quick"] = lethal
    lethal_engine.rules["enemy_bundles"] = {"1": [{"timing": 1, "card_id": "lethal_quick", "direction": -1}]}
    var quick: Dictionary = lethal_engine.cards_by_id.get("basic_quick_attack", {})
    var lethal_result := lethal_engine.resolve_bundle([_placement(stance, 1), _placement(quick, 3)], _context(1), lethal_engine.make_initial_state(hud, 4, 5))
    if not _has_outcome(lethal_result.get("resolved_actions", []), "basic_quick_attack", "interrupted"):
        failures.append("Combat incapacity must still cancel later actions after defeat.")

func _verify_momentum_sources(hud: Dictionary) -> void:
    var normal_hit_engine := CombatResolutionEngine.new()
    normal_hit_engine.rules["enemy_bundles"] = {}
    var quick: Dictionary = normal_hit_engine.cards_by_id.get("basic_quick_attack", {})
    var normal_hit_result := normal_hit_engine.resolve_bundle([_placement(quick, 1)], _context(1), normal_hit_engine.make_initial_state(hud, 4, 5))
    if _momentum_of(normal_hit_result, "player") != 1:
        failures.append("A normal hit must not add momentum beyond the completed-bundle gain.")

    var guard_engine := CombatResolutionEngine.new()
    guard_engine.rules["enemy_bundles"] = {"1": [{"timing": 2, "card_id": "basic_quick_attack", "direction": -1}]}
    var guard: Dictionary = guard_engine.cards_by_id.get("basic_guard", {})
    var guard_result := guard_engine.resolve_bundle([_placement(guard, 1)], _context(1), guard_engine.make_initial_state(hud, 4, 5))
    if _momentum_of(guard_result, "player") != 2:
        failures.append("A successful guard must add one momentum in addition to the completed-bundle gain.")

    var evade_engine := CombatResolutionEngine.new()
    evade_engine.rules["enemy_bundles"] = {"1": [{"timing": 1, "card_id": "basic_quick_attack", "direction": -1}]}
    var evade: Dictionary = evade_engine.cards_by_id.get("basic_evade", {})
    var evade_result := evade_engine.resolve_bundle([_placement(evade, 1)], _context(1), evade_engine.make_initial_state(hud, 4, 5))
    if _momentum_of(evade_result, "player") != 2:
        failures.append("A successful evade must add one momentum in addition to the completed-bundle gain.")

    var clash_engine := CombatResolutionEngine.new()
    clash_engine.rules["enemy_bundles"] = {"1": [{"timing": 2, "card_id": "basic_quick_attack", "direction": -1}]}
    var heavy: Dictionary = clash_engine.cards_by_id.get("basic_heavy_attack", {})
    var clash_result := clash_engine.resolve_bundle([_placement(heavy, 1)], _context(1), clash_engine.make_initial_state(hud, 4, 5))
    if _momentum_of(clash_result, "player") != 2:
        failures.append("A clash winner must add one momentum in addition to the completed-bundle gain.")

func _momentum_of(result: Dictionary, actor_key: String) -> int:
    var actor: Dictionary = (result.get("state", {}) as Dictionary).get(actor_key, {})
    var momentum: Array = actor.get("momentum", [0, 5])
    return int(momentum[0]) if not momentum.is_empty() else 0

func _verify_engagement_and_movement(hud: Dictionary) -> void:
    var engine := CombatResolutionEngine.new()
    engine.rules["enemy_bundles"] = {}
    var state := engine.make_initial_state(hud, 5, 5)
    var quick: Dictionary = engine.cards_by_id.get("basic_quick_attack", {})
    var engaged_result := engine.resolve_bundle([_placement(quick, 1, 1)], _context(1), state)
    var enemy: Dictionary = (engaged_result.get("state", {}) as Dictionary).get("enemy", {})
    if int((enemy.get("health", [0, 0]) as Array)[0]) != 24:
        failures.append("Engaged fighters on one tile must be valid range-one attack targets regardless of direction.")

    var move: Dictionary = engine.cards_by_id.get("basic_move", {})
    state = engine.make_initial_state(hud, 4, 5)
    var enter_result := engine.resolve_bundle([_placement(move, 1, 1, 5)], _context(1), state)
    var entered_player: Dictionary = (enter_result.get("state", {}) as Dictionary).get("player", {})
    if int(entered_player.get("tile", 0)) != 5:
        failures.append("A fighter must be able to enter a stationary opponent tile and engage.")

    var shared_engine := CombatResolutionEngine.new()
    shared_engine.rules["enemy_bundles"] = {"1": [{"timing": 1, "card_id": "basic_move", "target_tile": 5, "direction": -1}]}
    var shared_result := shared_engine.resolve_bundle([_placement(move, 1, 1, 5)], _context(1), shared_engine.make_initial_state(hud, 4, 6))
    var shared_state: Dictionary = shared_result.get("state", {})
    if int((shared_state.get("player", {}) as Dictionary).get("tile", 0)) != 5 or int((shared_state.get("enemy", {}) as Dictionary).get("tile", 0)) != 5:
        failures.append("Both fighters selecting one empty tile must engage on that tile.")

    var swap_engine := CombatResolutionEngine.new()
    swap_engine.rules["enemy_bundles"] = {"1": [{"timing": 1, "card_id": "basic_move", "target_tile": 4, "direction": -1}]}
    var swap_result := swap_engine.resolve_bundle([_placement(move, 1, 1, 5)], _context(1), swap_engine.make_initial_state(hud, 4, 5))
    var swap_state: Dictionary = swap_result.get("state", {})
    if int((swap_state.get("player", {}) as Dictionary).get("tile", 0)) != 4 or int((swap_state.get("enemy", {}) as Dictionary).get("tile", 0)) != 5:
        failures.append("Direct position swapping must remain invalid.")

func _verify_timing_snapshots(hud: Dictionary) -> void:
    var engine := CombatResolutionEngine.new()
    engine.rules["enemy_bundles"] = {"1": [{"timing": 1, "card_id": "basic_move", "target_tile": 6, "direction": -1}]}
    var move: Dictionary = engine.cards_by_id.get("basic_move", {})
    var meditate: Dictionary = engine.cards_by_id.get("basic_meditate", {})
    var quick: Dictionary = engine.cards_by_id.get("basic_quick_attack", {})
    var result := engine.resolve_bundle([
        _placement(move, 1, 1, 5),
        _placement(meditate, 2),
        _placement(quick, 3, 1, 6)
    ], _context(1), engine.make_initial_state(hud, 4, 7))
    var timing_results: Array = result.get("timing_results", [])
    if timing_results.size() != 3:
        failures.append("A full 3-slot bundle must return one authoritative playback snapshot per timing.")
        return
    for index in range(timing_results.size()):
        var timing_result: Dictionary = timing_results[index]
        if int(timing_result.get("timing", 0)) != index + 1:
            failures.append("Playback snapshots must be ordered by actual timing, not only by bundle completion.")
    var first_state: Dictionary = (timing_results[0] as Dictionary).get("state", {})
    var first_player: Dictionary = first_state.get("player", {})
    var first_enemy: Dictionary = first_state.get("enemy", {})
    if int(first_player.get("tile", 0)) != 5 or int(first_enemy.get("tile", 0)) != 6:
        failures.append("Timing 1 playback must expose only the moves resolved at timing 1.")
    var second_state: Dictionary = (timing_results[1] as Dictionary).get("state", {})
    var second_player: Dictionary = second_state.get("player", {})
    var second_stamina: Array = second_player.get("stamina", [])
    if second_stamina.size() < 2 or int(second_stamina[0]) != 5:
        failures.append("Timing 2 playback must expose meditation before timing 3 is resolved.")

func _placement(definition: Dictionary, anchor: int, direction: int = 1, target_tile: int = 0) -> Dictionary:
    var span := maxi(1, int(definition.get("action_slots", 1)))
    return {"card_id": str(definition.get("id", "")), "definition": definition.duplicate(true), "anchor_index": anchor, "span": span, "target_ready": true, "direction": direction, "target_tile": target_tile}

func _context(bundle_index: int) -> Dictionary:
    return {"round_number": 1, "bundle_index": bundle_index, "timing_sequence": [3, 3, 4]}

func _has_outcome(actions: Array, card_id: String, outcome: String) -> bool:
    for value in actions:
        if typeof(value) == TYPE_DICTIONARY and str(value.get("card_id", "")) == card_id and str(value.get("outcome", "")) == outcome:
            return true
    return false

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _finish() -> void:
    if failures.is_empty():
        print("ULTIMATE_INTERRUPT_ENGAGEMENT_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("ULTIMATE_INTERRUPT_ENGAGEMENT_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
