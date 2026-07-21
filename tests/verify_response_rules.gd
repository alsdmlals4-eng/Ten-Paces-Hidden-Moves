extends SceneTree

const HUD_PATH := "res://data/combat/combat_hud_preview.json"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hud := _load_json(HUD_PATH)
    if hud.is_empty():
        failures.append("Combat HUD data could not be loaded.")
        _finish()
        return

    _verify_guard_rules(hud)
    _verify_evade_rules(hud)
    _verify_stance_response_combos(hud)
    _verify_resource_preview(hud)
    _finish()

func _verify_guard_rules(hud: Dictionary) -> void:
    var same_timing_health := _resolve_defense_case(hud, "basic_guard", false, 1, 1)
    if same_timing_health != 14:
        failures.append("Same-timing guard must use 50% reduction when it is stronger than guard block. expected=14 actual=%d" % same_timing_health)

    var bundle_health := _resolve_defense_case(hud, "basic_guard", false, 1, 2)
    if bundle_health != 12:
        failures.append("Same-bundle guard must reduce damage 12 by guard block 4. expected=12 actual=%d" % bundle_health)

func _verify_evade_rules(hud: Dictionary) -> void:
    var same_timing_health := _resolve_defense_case(hud, "basic_evade", false, 1, 1)
    if same_timing_health != 20:
        failures.append("Same-timing evade must fully avoid damage. expected=20 actual=%d" % same_timing_health)

    var other_timing_health := _resolve_defense_case(hud, "basic_evade", false, 1, 2)
    if other_timing_health != 8:
        failures.append("Normal evade must not protect a different timing in the bundle. expected=8 actual=%d" % other_timing_health)

func _verify_stance_response_combos(hud: Dictionary) -> void:
    var guard_combo_health := _resolve_defense_case(hud, "basic_guard", true, 1, 2)
    if guard_combo_health != 14:
        failures.append("Stance+guard must extend to the bundle with defense 6. expected=14 actual=%d" % guard_combo_health)

    var evade_combo_health := _resolve_defense_case(hud, "basic_evade", true, 1, 2)
    if evade_combo_health != 20:
        failures.append("Stance+evade must fully evade attacks across the current bundle. expected=20 actual=%d" % evade_combo_health)

func _resolve_defense_case(hud: Dictionary, response_id: String, combo: bool, response_timing: int, attack_timing: int) -> int:
    var engine := CombatResolutionEngine.new()
    var attack_definition: Dictionary = (engine.cards_by_id.get("basic_quick_attack", {}) as Dictionary).duplicate(true)
    attack_definition["damage"] = "12"
    engine.cards_by_id["basic_quick_attack"] = attack_definition
    engine.rules["enemy_bundles"] = {
        "1": [
            {"timing": attack_timing, "card_id": "basic_quick_attack", "targeting_mode": "attack_direction", "direction": -1}
        ]
    }

    var response: Dictionary = (engine.cards_by_id.get(response_id, {}) as Dictionary).duplicate(true)
    if combo:
        var stance: Dictionary = engine.cards_by_id.get("basic_stance", {})
        response["id"] = "combo_stance_%s" % response_id
        response["base_card_id"] = response_id
        response["name"] = "태세+%s" % str(response.get("name", "대응"))
        response["stance_response_combo"] = true
        response["stamina_cost"] = int(response.get("stamina_cost", 0)) + int(stance.get("stamina_cost", 0))
        response["internal_cost"] = int(response.get("internal_cost", 0)) + int(stance.get("internal_cost", 0))

    var state := engine.make_initial_state(hud, 3, 4)
    var placement := _placement(response, response_timing)
    var result := engine.resolve_bundle([placement], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
    var player: Dictionary = (result.get("state", {}) as Dictionary).get("player", {})
    var health: Array = player.get("health", [0, 0])
    return int(health[0])

func _verify_resource_preview(hud: Dictionary) -> void:
    var engine := CombatResolutionEngine.new()
    var state := engine.make_initial_state(hud, 3, 8)
    var footwork: Dictionary = engine.cards_by_id.get("basic_footwork", {})
    var quick: Dictionary = engine.cards_by_id.get("basic_quick_attack", {})
    var meditate: Dictionary = engine.cards_by_id.get("basic_meditate", {})
    var placements := [
        _placement(footwork, 1),
        _placement(quick, 2),
        _placement(meditate, 3)
    ]
    var preview := engine.preview_player_plan(state, placements)
    if not bool(preview.get("valid", false)):
        failures.append("Footwork, quick attack, and meditation should be a valid resource plan.")
        return
    var player: Dictionary = (preview.get("state", {}) as Dictionary).get("player", {})
    var stamina: Array = player.get("stamina", [0, 0])
    var internal: Array = player.get("internal", [0, 0])
    if int(stamina[0]) != 5 or int(internal[0]) != 4:
        failures.append("Immediate resource preview must include costs and later meditation recovery. expected=5/5 and 4/4 actual=%d/%d" % [int(stamina[0]), int(internal[0])])

    var restricted_state := state.duplicate(true)
    var restricted_player: Dictionary = (restricted_state.get("player", {}) as Dictionary).duplicate(true)
    restricted_player["internal"] = [0, 4]
    restricted_state["player"] = restricted_player
    var invalid_preview := engine.preview_player_plan(restricted_state, [_placement(footwork, 1)])
    if bool(invalid_preview.get("valid", true)):
        failures.append("A footwork plan with zero internal energy must be marked invalid immediately.")
    var invalid_anchors: PackedInt32Array = invalid_preview.get("invalid_anchors", PackedInt32Array())
    if 1 not in invalid_anchors:
        failures.append("The unaffordable footwork timing must be reported as an invalid anchor.")

func _placement(definition: Dictionary, anchor: int) -> Dictionary:
    var span := maxi(1, int(definition.get("action_slots", 1)))
    return {
        "card_id": str(definition.get("id", "")),
        "card_name": str(definition.get("name", "")),
        "definition": definition.duplicate(true),
        "anchor_index": anchor,
        "span": span,
        "indices": PackedInt32Array([anchor]),
        "targeting_mode": "none",
        "target_ready": true,
        "target_tile": 0,
        "direction": 1,
        "origin_tile": 3
    }

func _load_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _finish() -> void:
    if failures.is_empty():
        print("RESPONSE_RULES_10_6_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("RESPONSE_RULES_10_6_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
