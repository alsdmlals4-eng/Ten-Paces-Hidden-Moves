# Phase 2 기초 행동의 구조화 사거리와 오능력치 피해 공식을 검증한다.
extends SceneTree

const HUD_PATH := "res://data/combat/combat_hud_preview.json"
const CombatResolutionEngineScript := preload("res://src/combat/combat_resolution_engine.gd")

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hud := _load_json(HUD_PATH)
    _expect_damage(hud, "basic_quick_attack", 5, 5)
    _expect_damage_with_legacy_attack_power(hud, "basic_quick_attack", 5, 999, 5)
    _expect_damage(hud, "basic_heavy_attack", 6, 11)
    _expect_damage(hud, "basic_palm", 7, 6)
    _expect_range_miss(hud, "basic_heavy_attack", 7)
    _expect_meditate_preview_matches_resolution(hud)
    _expect_resolved_public_history(hud)
    if failures.is_empty():
        print("PHASE2_COMBAT_RESOLUTION_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _expect_damage(hud: Dictionary, card_id: String, enemy_tile: int, expected_damage: int) -> void:
    var engine := CombatResolutionEngineScript.new()
    engine.rules["enemy_bundles"] = {}
    var definition: Dictionary = (engine.cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)
    var state := engine.make_initial_state(hud, 4, enemy_tile)
    var result := engine.resolve_bundle([_placement(definition)], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
    var enemy: Dictionary = (result.get("state", {}) as Dictionary).get("enemy", {})
    var health: Array = enemy.get("health", [0, 0])
    var actual_damage := 30 - int(health[0])
    if actual_damage != expected_damage:
        failures.append("%s must deal %d at stat 4; actual=%d" % [card_id, expected_damage, actual_damage])

func _expect_range_miss(hud: Dictionary, card_id: String, enemy_tile: int) -> void:
    var engine := CombatResolutionEngineScript.new()
    engine.rules["enemy_bundles"] = {}
    var definition: Dictionary = (engine.cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)
    var state := engine.make_initial_state(hud, 4, enemy_tile)
    var result := engine.resolve_bundle([_placement(definition)], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
    var enemy: Dictionary = (result.get("state", {}) as Dictionary).get("enemy", {})
    var health: Array = enemy.get("health", [0, 0])
    if int(health[0]) != 30:
        failures.append("%s must not deal damage beyond its structured maximum range." % card_id)

func _expect_damage_with_legacy_attack_power(hud: Dictionary, card_id: String, enemy_tile: int, attack_power: int, expected_damage: int) -> void:
    var altered_hud := hud.duplicate(true)
    var player: Dictionary = (altered_hud.get("player", {}) as Dictionary).duplicate(true)
    player["attack_power"] = attack_power
    altered_hud["player"] = player
    _expect_damage(altered_hud, card_id, enemy_tile, expected_damage)

func _expect_meditate_preview_matches_resolution(hud: Dictionary) -> void:
    var engine := CombatResolutionEngineScript.new()
    engine.rules["enemy_bundles"] = {}
    engine.rules["meditate_stamina_restore"] = 2
    var definition: Dictionary = (engine.cards_by_id.get("basic_meditate", {}) as Dictionary).duplicate(true)
    var state := engine.make_initial_state(hud, 4, 6)
    var player: Dictionary = (state.get("player", {}) as Dictionary).duplicate(true)
    player["stamina"] = [0, int((player.get("stamina", [0, 0]) as Array)[1])]
    player["internal"] = [0, int((player.get("internal", [0, 0]) as Array)[1])]
    state["player"] = player
    var preview := engine.preview_player_plan(state, [_placement(definition)])
    var resolved := engine.resolve_bundle([_placement(definition)], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
    var preview_player: Dictionary = (preview.get("state", {}) as Dictionary).get("player", {})
    var resolved_player: Dictionary = (resolved.get("state", {}) as Dictionary).get("player", {})
    var preview_stamina := int((preview_player.get("stamina", [0, 0]) as Array)[0])
    var preview_internal := int((preview_player.get("internal", [0, 0]) as Array)[0])
    var resolved_stamina := int((resolved_player.get("stamina", [0, 0]) as Array)[0])
    var resolved_internal := int((resolved_player.get("internal", [0, 0]) as Array)[0])
    if preview_stamina != 1 or preview_internal != 1:
        failures.append("Meditation preview must restore stamina and internal by +1/+1; actual=%d/%d" % [preview_stamina, preview_internal])
    if resolved_stamina != 1 or resolved_internal != 1:
        failures.append("Meditation resolution must restore stamina and internal by +1/+1; actual=%d/%d" % [resolved_stamina, resolved_internal])
    if preview_stamina != resolved_stamina or preview_internal != resolved_internal:
        failures.append("Meditation preview and resolution must match; preview=%d/%d resolved=%d/%d" % [preview_stamina, preview_internal, resolved_stamina, resolved_internal])


func _expect_resolved_public_history(hud: Dictionary) -> void:
    var engine := CombatResolutionEngineScript.new()
    engine.rules["enemy_bundles"] = {}
    var state := engine.make_initial_state(hud, 4, 6)
    if state.has("public_resolution_history"):
        failures.append("No future or locked-bundle history may exist at combat start.")

    var heavy: Dictionary = (engine.cards_by_id.get("basic_heavy_attack", {}) as Dictionary).duplicate(true)
    var first := engine.resolve_bundle([_placement(heavy)], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
    state = first.get("state", {})
    var first_history: Array = state.get("public_resolution_history", [])
    if first_history.size() != 1:
        failures.append("A two-slot action must append exactly one execution-stage public record; actual=%d" % first_history.size())
    elif typeof(first_history[0]) == TYPE_DICTIONARY:
        var first_record: Dictionary = first_history[0]
        _expect_public_history_shape(first_record)
        if str(first_record.get("card_id", "")) != "basic_heavy_attack" or str(first_record.get("category", "")) != "attack":
            failures.append("Resolved public history must preserve only the execution card and category.")
        if first_record.has("target_tile") or first_record.has("direction") or first_record.has("action_stage"):
            failures.append("Resolved public history must exclude targeting, direction, and preparation metadata.")

    var meditate: Dictionary = (engine.cards_by_id.get("basic_meditate", {}) as Dictionary).duplicate(true)
    for round_number in range(2, 8):
        var result := engine.resolve_bundle([_placement(meditate)], {"round_number": round_number, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
        state = result.get("state", {})
    var history: Array = state.get("public_resolution_history", [])
    if history.size() != 6:
        failures.append("Resolved public history must retain at most six newest records; actual=%d" % history.size())
    elif typeof(history[0]) == TYPE_DICTIONARY and typeof(history[history.size() - 1]) == TYPE_DICTIONARY:
        var oldest: Dictionary = history[0]
        var newest: Dictionary = history[history.size() - 1]
        if int(oldest.get("round_number", 0)) != 2 or int(newest.get("round_number", 0)) != 7:
            failures.append("Resolved public history must trim only the oldest records.")
        for record_value in history:
            if typeof(record_value) == TYPE_DICTIONARY:
                _expect_public_history_shape(record_value as Dictionary)


func _expect_public_history_shape(record: Dictionary) -> void:
    var keys: Array[String] = []
    for key_value in record.keys():
        keys.append(str(key_value))
    keys.sort()
    var expected := ["round_number", "bundle_index", "actor", "card_id", "category", "outcome"]
    expected.sort()
    if keys != expected:
        failures.append("Resolved public history must expose exactly the approved six public fields.")

func _placement(definition: Dictionary) -> Dictionary:
    return {
        "card_id": str(definition.get("id", "")),
        "definition": definition,
        "anchor_index": 1,
        "span": int(definition.get("action_slots", 1)),
        "targeting_mode": "attack_direction",
        "target_ready": true,
        "direction": 1,
        "origin_tile": 4
    }

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
