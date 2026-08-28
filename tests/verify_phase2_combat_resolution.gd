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
