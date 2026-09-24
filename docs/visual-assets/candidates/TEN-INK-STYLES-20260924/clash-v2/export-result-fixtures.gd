extends SceneTree
## Fixed inputs through the unchanged product resolver. This does not capture game UI.
const ENGINE = preload("res://src/combat/combat_resolution_engine.gd")
const DEST = "res://docs/visual-assets/candidates/TEN-INK-STYLES-20260924/clash-v2/result-fixtures.json"

func _initialize() -> void:
    var cases: Array = []
    cases.append(make_case("clash_win", "basic_heavy_attack", 2, 6))
    cases.append(make_case("clash_loss", "basic_heavy_attack", 8, 6))
    cases.append(make_case("clash_draw", "basic_heavy_attack", 4, 6))
    cases.append(make_case("evade", "basic_evade", 4, 6))
    cases.append(make_case("guard", "basic_guard", 4, 6))
    cases.append(make_case("miss_range", "basic_heavy_attack", 2, 7))
    var sources: Array = []
    for source in ["src/combat/combat_resolution_engine.gd", "src/combat/combat_ai_planner.gd", "data/cards/basic_cards.json", "data/cards/ultimate_cards.json", "data/combat/combat_resolution_preview.json", "data/combat/combat_hud_preview.json"]:
        sources.append({"path": source, "sha256": FileAccess.get_sha256("res://" + source)})
    var report := {"schema_version": 1, "evidence_kind": "ACTUAL_PRODUCT_RESOLVER_WITH_FIXED_INPUTS_NOT_GAME_CAPTURE", "engine_version": Engine.get_version_info().string, "sources": sources, "cases": cases}
    var file := FileAccess.open(DEST, FileAccess.WRITE)
    assert(file != null)
    file.store_string(JSON.stringify(report, "  ") + "\n")
    file.close()
    print("INK_RESULT_FIXTURES_OK ", cases.size())
    quit(0)

func make_case(id: String, enemy_card: String, enemy_external: int, enemy_tile: int) -> Dictionary:
    var engine = ENGINE.new()
    var hud: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json"))
    hud.enemy.stats.external = enemy_external
    # Only the fixture plan is fixed. Card definitions, costs and combat rules are unchanged.
    var enemy_definition: Dictionary = engine.get_actor_card_definition(enemy_card, "enemy")
    var enemy_anchor := 3 - int(enemy_definition.action_slots)
    engine.rules["enemy_bundles"] = {"1": [{"card_id": enemy_card, "timing": enemy_anchor, "direction": -1}]}
    var before: Dictionary = engine.make_initial_state(hud, 4, enemy_tile)
    before["ai_enabled"] = false
    var definition: Dictionary = engine.get_actor_card_definition("basic_heavy_attack", "player")
    var placement := {"card_id": definition.id, "definition": definition, "anchor_index": 1, "span": int(definition.action_slots), "target_ready": true, "direction": 1, "target_tile": enemy_tile, "origin_tile": 4}
    var context := {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}
    var result: Dictionary = engine.resolve_bundle([placement], context, before)
    return {"id": id, "input": {"before": before, "context": context, "enemy_plan": engine.rules.enemy_bundles}, "result": result}
