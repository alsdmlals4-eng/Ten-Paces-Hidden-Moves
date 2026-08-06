extends SceneTree

const DOCK_SCENE := "res://scenes/ui/action_selection/action_selection_dock.tscn"
const PREPARE_ENGINE_SCRIPT := preload("res://src/combat/combat_resolution_engine_ten_manuals.gd")
const HUD_PATH := "res://data/combat/combat_hud_preview.json"

const HUA := "mount_hua_plum_blossom_sword"
const TANG := "sichuan_tang_hidden_weapons"
const HUA_STAR3 := "mount_hua_plum_blossom_sword_star3"
const HUA_STAR7 := "mount_hua_plum_blossom_sword_star7"
const TANG_STAR7 := "sichuan_tang_hidden_weapons_star7"
const TANG_STAR10 := "sichuan_tang_hidden_weapons_star10"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    await _verify_ui_registry_adoption()
    _verify_ai_enemy_loadout_boundary()
    _verify_bundle_executes_martial_pipeline()
    if failures.is_empty():
        print("TEN_MANUAL_UI_AI_ADOPTION_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _verify_ui_registry_adoption() -> void:
    var packed := load(DOCK_SCENE) as PackedScene
    _expect(packed != null, "ActionSelectionDock scene must load.")
    if packed == null:
        return
    var dock: ActionSelectionDock = packed.instantiate() as ActionSelectionDock
    root.add_child(dock)
    await process_frame

    dock.set_runtime_context({
        "martial_loadout": [HUA, TANG],
        "martial_mastery_by_manual": {HUA: 5, TANG: 10},
        "momentum": [5, 5],
        "momentum_maximum": 5,
        "ultimate_reservations": []
    })
    await process_frame

    var panel_snapshot: Dictionary = dock.martial_panel.get_panel_snapshot()
    _expect(panel_snapshot.get("manual_ids", []) == [HUA, TANG], "Martial tab must preserve explicit loadout order.")
    _expect(int(panel_snapshot.get("manual_count", 0)) == 2, "Martial tab must show exactly two loaded manuals in this fixture.")

    var hua_manual: Dictionary = _find_by_key(dock.martial_panel.manuals, "manual_id", HUA)
    _expect(not hua_manual.is_empty(), "Mount Hua manual must be supplied by the registry.")
    _expect(str(hua_manual.get("faction", "")) == "화산파", "Mount Hua faction metadata is missing.")
    _expect(str(hua_manual.get("primary_stat", "")) == "신법", "Mount Hua primary stat is missing.")
    _expect(str(hua_manual.get("secondary_stat", "")) == "외공", "Mount Hua secondary stat is missing.")
    var hua_star3: Dictionary = _find_by_key(hua_manual.get("techniques", []), "id", HUA_STAR3)
    var hua_star7: Dictionary = _find_by_key(hua_manual.get("techniques", []), "id", HUA_STAR7)
    _expect(not bool(hua_star3.get("locked", true)), "Star3 must be unlocked at mastery 5.")
    _expect("낙매유향" in hua_star3.get("applied_overlays", []), "Star5 overlay must be visible on the Star3 technique.")
    _expect(bool(hua_star7.get("locked", false)), "Star7 must remain locked at mastery 5.")
    _expect(int(hua_star7.get("unlock_mastery", 0)) == 7, "Star7 lock threshold must be visible.")

    var tang_ultimate: Dictionary = dock.ultimate_panel.get_action(TANG_STAR10)
    _expect(not tang_ultimate.is_empty(), "Tang Star10 ultimate must appear in the ultimate tab.")
    _expect(str(tang_ultimate.get("source", "")) == "martial_manual", "Martial ultimate source must remain martial_manual.")
    _expect(str(tang_ultimate.get("source_kind", "")) == "ultimate", "Martial Star10 card must be placeable as an ultimate.")
    _expect(not bool(tang_ultimate.get("locked", true)), "Tang Star10 must be unlocked at mastery10 and full momentum.")
    _expect(not dock.ultimate_panel.get_action("ultimate_void_sword_qi").is_empty(), "Generic ultimates must remain available.")

    dock.queue_free()
    await process_frame

func _verify_ai_enemy_loadout_boundary() -> void:
    var engine = PREPARE_ENGINE_SCRIPT.new()
    if not engine.has_method("configure_martial_loadouts"):
        failures.append("Ten-manual prepare engine must expose configure_martial_loadouts.")
        return
    engine.configure_martial_loadouts(
        [HUA],
        {HUA: 5},
        [TANG],
        {TANG: 7}
    )
    if not engine.has_method("get_enemy_martial_card_ids") or not engine.has_method("get_enemy_ai_cards_by_id"):
        failures.append("Ten-manual prepare engine must expose enemy martial-card boundary APIs.")
        return
    var enemy_ids: PackedStringArray = engine.get_enemy_martial_card_ids()
    _expect(TANG_STAR7 in enemy_ids, "Enemy Tang mastery7 card must be loaded.")
    _expect(HUA_STAR3 not in enemy_ids, "Player-only Mount Hua card must not leak into enemy loadout.")

    var hud: Dictionary = _load_json(HUD_PATH)
    var state: Dictionary = engine.make_initial_state(hud, 4, 8)
    state["ai_enabled"] = true
    state["ai_decision_seed"] = 0
    var actions: Array = engine.ai_planner.build_bundle_actions(state, 1, engine.get_enemy_ai_cards_by_id())
    var trace: Dictionary = engine.ai_planner.get_last_trace()
    _expect(not actions.is_empty(), "Enemy AI must return an action.")
    _expect(TANG_STAR7 in trace.get("candidate_ids", []), "Enemy Tang Star7 must enter the rational candidate pool at range4.")
    for candidate_id in trace.get("candidate_ids", []):
        var text := str(candidate_id)
        if text.ends_with("_star3") or text.ends_with("_star7") or text.ends_with("_star10"):
            _expect(text in enemy_ids, "AI candidate pool contains a martial card outside the enemy loadout: %s" % text)

func _verify_bundle_executes_martial_pipeline() -> void:
    var engine = PREPARE_ENGINE_SCRIPT.new()
    if not engine.has_method("configure_martial_loadouts"):
        failures.append("Bundle integration requires configure_martial_loadouts.")
        return
    engine.configure_martial_loadouts(
        [TANG],
        {TANG: 10},
        [],
        {}
    )
    var hud: Dictionary = _load_json(HUD_PATH)
    var state: Dictionary = engine.make_initial_state(hud, 4, 7)
    state["ai_enabled"] = false
    var before_health := int(((state.get("enemy", {}) as Dictionary).get("health", [30, 30]) as Array)[0])
    var definition: Dictionary = (engine.cards_by_id.get(TANG_STAR10, {}) as Dictionary).duplicate(true)
    _expect(not definition.is_empty(), "Player Tang Star10 definition must be loaded into the engine.")
    if definition.is_empty():
        return
    var result: Dictionary = engine.resolve_bundle([
        {
            "card_id": TANG_STAR10,
            "definition": definition,
            "anchor_index": 1,
            "span": int(definition.get("action_slots", 3)),
            "targeting_mode": "attack_direction",
            "target_ready": true,
            "direction": 1,
            "target_tile": 0,
            "origin_tile": 4
        }
    ], {
        "round_number": 1,
        "bundle_index": 1,
        "timing_sequence": [3, 3, 4]
    }, state)
    var after_state: Dictionary = result.get("state", {})
    var after_health := int((((after_state.get("enemy", {}) as Dictionary).get("health", [30, 30])) as Array)[0])
    _expect(after_health < before_health, "Martial effect pipeline must apply Tang Star10 damage inside resolve_bundle.")
    var found_completed := false
    for value in result.get("resolved_actions", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var record: Dictionary = value
        if str(record.get("card_id", "")) == TANG_STAR10 and str(record.get("outcome", "")) == "martial_completed":
            found_completed = true
    _expect(found_completed, "Resolved actions must record martial_completed for a completed martial program.")

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _find_by_key(values, key: String, expected: String) -> Dictionary:
    if typeof(values) != TYPE_ARRAY:
        return {}
    for value in values:
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get(key, "")) == expected:
            return (value as Dictionary).duplicate(true)
    return {}

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
