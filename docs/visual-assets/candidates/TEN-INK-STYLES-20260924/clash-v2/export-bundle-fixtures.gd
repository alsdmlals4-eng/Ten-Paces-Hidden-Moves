extends SceneTree
## Three consecutive fixed plans through the unchanged product resolver.
const ENGINE = preload("res://src/combat/combat_resolution_engine.gd")
const DEST = "res://docs/visual-assets/candidates/TEN-INK-STYLES-20260924/clash-v2/bundle-fixtures.json"

func _initialize() -> void:
    var engine = ENGINE.new()
    var hud: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json"))
    hud.enemy.stats.external = 2
    var state: Dictionary = engine.make_initial_state(hud, 4, 6)
    state["ai_enabled"] = false
    var plans := [
        [["basic_heavy_attack", 1], ["basic_meditate", 3]],
        [["basic_move", 4], ["basic_quick_attack", 5], ["basic_guard", 6]],
        [["basic_heavy_attack", 7], ["basic_quick_attack", 9], ["basic_meditate", 10]]
    ]
    var enemy_plans := [
        [["basic_heavy_attack", 1], ["basic_meditate", 3]],
        [["basic_observe", 4], ["basic_quick_attack", 5], ["basic_quick_attack", 6]],
        [["basic_heavy_attack", 7], ["basic_quick_attack", 9], ["basic_meditate", 10]]
    ]
    var bundles: Array = []
    for index in range(3):
        var placements: Array = []
        var enemy_plan: Array = []
        for entry in plans[index]:
            var definition: Dictionary = engine.get_actor_card_definition(entry[0], "player")
            assert(not definition.is_empty(), entry[0])
            placements.append({"card_id": entry[0], "definition": definition, "anchor_index": entry[1], "span": int(definition.action_slots), "target_ready": true, "direction": 1, "target_tile": 5 if entry[0] == "basic_move" else state.enemy.tile, "origin_tile": state.player.tile})
        for entry in enemy_plans[index]:
            assert(not engine.get_actor_card_definition(entry[0], "enemy").is_empty(), entry[0])
            enemy_plan.append({"card_id": entry[0], "timing": entry[1], "direction": -1})
        engine.rules["enemy_bundles"] = {str(index + 1): enemy_plan}
        engine.clear_locked_enemy_bundle()
        var before := state.duplicate(true)
        var context := {"round_number": 1, "bundle_index": index + 1, "timing_sequence": [3, 3, 4]}
        var result: Dictionary = engine.resolve_bundle(placements, context, state)
        bundles.append({"id": "bundle_" + str(index + 1), "input": {"before": before, "context": context, "placements": placements, "enemy_plan": enemy_plan}, "result": result})
        state = result.state.duplicate(true)
    var sources: Array = []
    for source in ["src/combat/combat_resolution_engine.gd", "src/combat/combat_ai_planner.gd", "data/cards/basic_cards.json", "data/cards/ultimate_cards.json", "data/combat/combat_resolution_preview.json", "data/combat/combat_hud_preview.json"]:
        sources.append({"path": source, "sha256": FileAccess.get_sha256("res://" + source)})
    var report := {"schema_version": 1, "evidence_kind": "ACTUAL_PRODUCT_RESOLVER_THREE_CONSECUTIVE_FIXED_BUNDLES_NOT_GAME_CAPTURE", "engine_version": Engine.get_version_info().string, "sources": sources, "bundles": bundles}
    var file := FileAccess.open(DEST, FileAccess.WRITE)
    assert(file != null)
    file.store_string(JSON.stringify(report, "  ") + "\n")
    file.close()
    print("INK_BUNDLE_FIXTURES_OK ", bundles.size(), " 3/3/4")
    quit(0)
