from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    target = ROOT / path
    assert target.is_file(), f"missing action-selection contract file: {path}"
    return target.read_text(encoding="utf-8")


def main() -> None:
    dock = read("src/ui/action_selection/action_selection_dock.gd")
    for token in (
        'const SOURCES := ["basic", "martial", "ultimate"]',
        'set_meta("manual_is_not_directly_placeable", true)',
        'set_meta("virtual_combo_enabled", false)',
        'MARTIAL_PANEL_SCENE',
        'ULTIMATE_PANEL_SCENE',
        'DETAIL_PANEL_SCENE',
    ):
        assert token in dock, f"ActionSelectionDock contract missing {token}"

    adapter = read("src/ui/action_selection/action_view_model_adapter.gd")
    for runtime_path in (
        "res://data/cards/basic_cards.json",
        "res://data/cards/ultimate_cards.json",
        "res://data/combat/action_selection_poc.json",
        "res://data/combat/mastery_ultimate_poc.json",
    ):
        assert runtime_path in adapter
    assert "docs/planning-data" not in adapter
    assert 'normalized["source_kind"] = source_kind' in adapter
    assert 'normalized["source"] = source_kind' in adapter

    martial = read("src/ui/action_selection/martial_action_panel.gd")
    assert "func select_manual(manual_id: String) -> bool:" in martial
    assert "func activate_technique(technique_id: String) -> bool:" in martial
    assert 'technique_selected.emit(technique.duplicate(true))' in martial
    assert "technique_selected.emit(manual" not in martial

    timing = read("src/ui/action_timing_panel.gd")
    assert "const TIMING_SEQUENCE := [3, 3, 4]" in timing
    timing_auto = read("src/ui/action_timing_panel_auto.gd")
    for token in (
        "get_linked_block_snapshots",
        "can_move_placement",
        "move_placement",
        "linked_block_move_requested",
    ):
        assert token in timing_auto

    slot = read("src/ui/action_timing_slot.gd")
    assert 'return "전조" if _assignment_stage() == "preparation" else "실행"' in slot
    assert '_placeholder_label.text = "[%s]" % stage_label' in slot
    assert '%s [준비]' not in slot

    block = read("src/ui/action_selection/linked_action_block.gd")
    assert 'stages.append("실행" if index == span - 1 else "전조")' in block
    assert "block_move_requested" in block
    assert "block_remove_requested" in block

    controller = read("src/ui/action_selection/action_placement_controller.gd")
    for token in (
        'timing_panel.call("find_earliest_open_anchor", span)',
        "select_and_place",
        "move_placement",
        "reserve_ultimate.call",
        "refund_ultimate.call",
    ):
        assert token in controller

    combat = read("src/combat/combat_board_preview_auto.gd")
    for token in (
        "ACTION_SELECTION_DOCK_SCENE",
        "_on_product_action_selected",
        "action_placement_controller.select_and_place",
        'set_meta("product_action_selection_enabled", true)',
        'set_meta("virtual_combo_enabled", false)',
        "_hide_legacy_action_ui",
    ):
        assert token in combat
    assert "docs/planning-data" not in combat

    basic_catalog = json.loads(read("data/cards/basic_cards.json"))
    assert len(basic_catalog["cards"]) == 8
    ultimate_catalog = json.loads(read("data/cards/ultimate_cards.json"))
    assert {card["id"] for card in ultimate_catalog["cards"]} == {
        "ultimate_ten_paces_wave",
        "ultimate_cleave_peak",
        "ultimate_void_sword_qi",
    }

    impact = json.loads(read(".github/canonical-combat-impact-map.json"))
    feature = impact["features"]["action_selection_dock"]
    assert feature["timing_sequence"] == [3, 3, 4]
    assert feature["manual_direct_placement"] is False
    assert feature["virtual_prepare_response_combo"] is False
    for path in feature["runtime_consumers"] + feature["test_consumers"]:
        assert (ROOT / path).exists(), path

    for source in (ROOT / "src").rglob("*.gd"):
        assert "docs/planning-data" not in source.read_text(encoding="utf-8"), source

    print("action selection contract: PASS")


if __name__ == "__main__":
    main()
