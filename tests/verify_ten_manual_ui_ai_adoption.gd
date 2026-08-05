extends SceneTree

const DOCK_SCENE := "res://scenes/ui/action_selection/action_selection_dock.tscn"
const PREPARE_ENGINE_SCRIPT := preload("res://src/combat/combat_resolution_engine_prepare.gd")
const HUD_PATH := "res://data/combat/combat_hud_preview.json"

const HUA := "mount_hua_plum_blossom_sword"
const TANG := "sichuan_tang_hidden_weapons"
const HUA_STAR3 := "mount_hua_plum_blossom_sword_star3"
const HUA_STAR7 := "mount_hua_plum_blossom_sword_star7"
const TANG_STAR7 := "sichuan_tang_hidden_weapons_star7"
const TANG_STAR10 := "sichuan_tang_hidden_weapons_star10"

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    _verify_ui_registry_adoption()
    _verify_ai_enemy_loadout_boundary()
    _verify_bundle_executes_martial_pipeline()
    print("TEN_MANUAL_UI_AI_ADOPTION_VERIFY_OK")
    quit(0)

func _verify_ui_registry_adoption() -> void:
    var packed := load(DOCK_SCENE) as PackedScene
    assert(packed != null)
    var dock = packed.instantiate()
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
    assert(panel_snapshot.get("manual_ids", []) == [HUA, TANG])
    assert(int(panel_snapshot.get("manual_count", 0)) == 2)

    var hua_manual := _find_by_key(dock.martial_panel.manuals, "manual_id", HUA)
    assert(not hua_manual.is_empty())
    assert(str(hua_manual.get("faction", "")) == "화산파")
    assert(str(hua_manual.get("primary_stat", "")) == "신법")
    assert(str(hua_manual.get("secondary_stat", "")) == "외공")
    var hua_star3 := _find_by_key(hua_manual.get("techniques", []), "id", HUA_STAR3)
    var hua_star7 := _find_by_key(hua_manual.get("techniques", []), "id", HUA_STAR7)
    assert(not bool(hua_star3.get("locked", true)))
    assert("낙매유향" in hua_star3.get("applied_overlays", []))
    assert(bool(hua_star7.get("locked", false)))
    assert(int(hua_star7.get("unlock_mastery", 0)) == 7)

    var tang_ultimate := dock.ultimate_panel.get_action(TANG_STAR10)
    assert(not tang_ultimate.is_empty())
    assert(str(tang_ultimate.get("source", "")) == "martial_manual")
    assert(str(tang_ultimate.get("source_kind", "")) == "ultimate")
    assert(not bool(tang_ultimate.get("locked", true)))
    assert(not dock.ultimate_panel.get_action("ultimate_void_sword_qi").is_empty())

    dock.queue_free()
    await process_frame

func _verify_ai_enemy_loadout_boundary() -> void:
    var engine = PREPARE_ENGINE_SCRIPT.new()
    engine.configure_martial_loadouts(
        [HUA],
        {HUA: 5},
        [TANG],
        {TANG: 7}
    )
    var enemy_ids: PackedStringArray = engine.get_enemy_martial_card_ids()
    assert(TANG_STAR7 in enemy_ids)
    assert(HUA_STAR3 not in enemy_ids)

    var hud := _load_json(HUD_PATH)
    var state: Dictionary = engine.make_initial_state(hud, 4, 8)
    state["ai_enabled"] = true
    state["ai_decision_seed"] = 0
    var actions := engine.ai_planner.build_bundle_actions(state, 1, engine.get_enemy_ai_cards_by_id())
    var trace: Dictionary = engine.ai_planner.get_last_trace()
    assert(not actions.is_empty())
    assert(TANG_STAR7 in trace.get("candidate_ids", []))
    for candidate_id in trace.get("candidate_ids", []):
        var text := str(candidate_id)
        if text.ends_with("_star3") or text.ends_with("_star7") or text.ends_with("_star10"):
            assert(text in enemy_ids)

func _verify_bundle_executes_martial_pipeline() -> void:
    var engine = PREPARE_ENGINE_SCRIPT.new()
    engine.configure_martial_loadouts(
        [TANG],
        {TANG: 10},
        [],
        {}
    )
    var hud := _load_json(HUD_PATH)
    var state: Dictionary = engine.make_initial_state(hud, 4, 7)
    state["ai_enabled"] = false
    var before_health := int(((state.get("enemy", {}) as Dictionary).get("health", [30, 30]) as Array)[0])
    var definition: Dictionary = (engine.cards_by_id.get(TANG_STAR10, {}) as Dictionary).duplicate(true)
    assert(not definition.is_empty())
    var result := engine.resolve_bundle([
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
    assert(after_health < before_health)
    var found_completed := false
    for value in result.get("resolved_actions", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var record: Dictionary = value
        if str(record.get("card_id", "")) == TANG_STAR10 and str(record.get("outcome", "")) == "martial_completed":
            found_completed = true
    assert(found_completed)

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
