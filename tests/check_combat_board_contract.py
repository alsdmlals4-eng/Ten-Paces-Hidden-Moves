from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "data/combat/combat_board_poc.json"
HUD_DATA = ROOT / "data/combat/combat_hud_preview.json"
TIMING_DATA = ROOT / "data/combat/combat_action_timing_preview.json"
PROGRESS_DATA = ROOT / "data/combat/combat_progress_preview.json"
LOG_DATA = ROOT / "data/combat/combat_log_preview.json"
CARD_DATA = ROOT / "data/cards/basic_cards.json"
TEXT_SUFFIXES = {".gd", ".tscn", ".py", ".ps1", ".cmd", ".md", ".json", ".yml", ".yaml", ".godot"}
CONFLICT_MARKERS = ("<<<<<<<", "=======", ">>>>>>>")
EXPECTED_CARD_IDS = [
    "basic_move",
    "basic_guard",
    "basic_evade",
    "basic_quick_attack",
    "basic_heavy_attack",
    "basic_meditate",
    "basic_stance",
]


def res_file(value: str) -> Path:
    assert value.startswith("res://")
    return ROOT / value.removeprefix("res://")


def assert_no_conflict_markers() -> None:
    failures: list[str] = []
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in TEXT_SUFFIXES:
            continue
        if ".git" in path.parts or ".godot" in path.parts:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for line_number, line in enumerate(text.splitlines(), start=1):
            if line.startswith(CONFLICT_MARKERS):
                failures.append(f"{path.relative_to(ROOT)}:{line_number}:{line}")
    assert not failures, "Committed VCS conflict markers found:\n" + "\n".join(failures)


def main() -> None:
    assert_no_conflict_markers()
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    hud_data = json.loads(HUD_DATA.read_text(encoding="utf-8"))
    timing_data = json.loads(TIMING_DATA.read_text(encoding="utf-8"))
    progress_data = json.loads(PROGRESS_DATA.read_text(encoding="utf-8"))
    log_data = json.loads(LOG_DATA.read_text(encoding="utf-8"))
    card_data = json.loads(CARD_DATA.read_text(encoding="utf-8"))

    assert contract["schema_version"] >= 8
    assert contract["tile_count"] == 10
    assert contract["player_start_tile"] == 3
    assert contract["enemy_start_tile"] == 8
    assert contract["camera_mode"] == "fixed_wide"
    assert 1.4 <= contract["character_height_to_tile_width"] <= 1.6
    assert 0.0 < contract["character_body_width_to_tile_width"] < 1.0
    assert 0.0 < contract["foot_anchor_y_ratio"] < 1.0

    background = contract["battle_background"]
    assert background["step"] == 3
    assert background["approval_status"] == "USER_APPROVED"
    assert background["contrast_role"] == "below_board_and_characters"
    assert res_file(background["asset"]).exists()
    assert res_file(background["scene"]).exists()

    hud = contract["top_hud"]
    assert hud["step"] == 4
    assert hud["momentum_segments"] == 5
    assert hud["layout"] == [
        "player_status",
        "player_momentum",
        "round_bundle",
        "enemy_momentum",
        "enemy_status",
    ]
    assert hud["lower_status_panels"] is False
    assert hud_data["momentum_segments"] == 5
    assert hud_data["player"]["momentum"] == [4, 5]
    assert hud_data["enemy"]["momentum"] == [3, 5]
    assert hud_data["round"]["round_number"] == 1

    timing = contract["action_timing"]
    assert timing["step"] == 5
    assert timing["placement_step"] == 9
    assert timing["timing_sequence"] == [3, 3, 4]
    assert timing["total_timings"] == 10
    assert timing["current_bundle"] == 2
    assert timing["current_timing"] == 5
    assert timing["progress_label_format"] == "라운드 {round}"
    assert timing["actionable_indices"] == [5, 6]
    assert timing["cards_inserted"] is True
    assert timing["interactions_enabled"] is True
    assert timing_data["round_number"] == 1
    assert timing_data["timing_sequence"] == [3, 3, 4]
    assert sum(timing_data["timing_sequence"]) == 10

    progress = contract["progress_button"]
    assert progress["step"] == 8
    assert progress["placement_gate_step"] == 9
    assert progress["default_enabled"] is False
    assert progress["enable_condition"] == "current_bundle_complete"
    assert progress["request_mode"] == "signal_only"
    assert progress["advances_state"] is False
    assert progress["action_placement_required"] is True
    assert res_file(progress["scene"]).exists()
    assert res_file(progress["data"]).exists()
    assert progress_data["schema_version"] == 2
    assert progress_data["placement_gate_step"] == 9
    assert progress_data["default_enabled"] is False
    assert progress_data["disabled_text"] == "행동 배치 필요"
    assert progress_data["action_placement_required"] is True

    tray = contract["basic_card_tray"]
    assert tray["step"] == 6
    assert tray["information_interaction_step"] == 7
    assert tray["placement_step"] == 9
    assert tray["card_count"] == 7
    assert tray["card_ids"] == EXPECTED_CARD_IDS
    assert tray["information_interactions_enabled"] is True
    assert tray["action_placement_enabled"] is True
    assert [card["id"] for card in card_data["cards"]] == EXPECTED_CARD_IDS
    assert card_data["forbidden_fields"] == ["action_point_cost", "guard_reduction"]
    for card in card_data["cards"]:
        assert card["source"] == "basic"
        assert card["source_label"] == "기초"
        assert int(card["action_slots"]) in (1, 2)
        assert {"target", "damage", "condition", "effect_text", "tags", "stamina_cost", "internal_cost"} <= set(card)
        assert "action_point_cost" not in card
        assert "guard_reduction" not in card

    detail = contract["card_detail_overlay"]
    assert detail["step"] == 7
    assert detail["approval_status"] == "USER_APPROVED_INTERACTION"
    assert detail["hover_preview"] is True
    assert detail["click_pin"] is True
    assert detail["action_placement_enabled"] is False

    combat_log = contract["combat_log"]
    assert combat_log["step"] == 7
    assert combat_log["approval_status"] == "USER_APPROVED_INTERACTION"
    assert combat_log["collapsible"] is True
    assert combat_log["default_collapsed"] is True
    assert combat_log["output_interface"] is True
    assert len(log_data["entries"]) == 4
    assert "대응 → 속공 → 이동 → 일반 공격" in log_data["entries"][-1]["text"]

    placement = contract["action_placement"]
    assert placement["step"] == 9
    assert placement["interaction"] == "select_card_then_click_slot"
    assert placement["editable_scope"] == "current_bundle_remaining_slots"
    assert placement["actionable_indices"] == [5, 6]
    assert placement["single_slot_supported"] is True
    assert placement["consecutive_multi_slot_supported"] is True
    assert placement["occupied_slot_click_removes_whole_card"] is True
    assert placement["progress_requires_complete_bundle"] is True
    assert placement["state_advancement_enabled"] is False

    scope = set(contract["presentation_scope"])
    assert {
        "battle_background",
        "top_hud",
        "action_timing",
        "progress_button",
        "basic_card_tray",
        "card_detail_overlay",
        "combat_log",
        "action_placement",
    } <= scope
    excluded = set(contract["excluded_until_later_steps"])
    assert "action_placement_interaction" not in excluded
    assert {"state_advancement_engine", "resolution_engine"} <= excluded

    required_files = [
        "assets/backgrounds/step3_mountain_fortress.svg",
        "data/cards/basic_cards.json",
        "data/combat/combat_hud_preview.json",
        "data/combat/combat_action_timing_preview.json",
        "data/combat/combat_progress_preview.json",
        "data/combat/combat_log_preview.json",
        "scenes/combat/combat_board_preview.tscn",
        "scenes/ui/action_timing_panel.tscn",
        "scenes/ui/action_timing_slot.tscn",
        "scenes/ui/combat_progress_button.tscn",
        "scenes/ui/basic_card_tray.tscn",
        "scenes/ui/basic_card_tray_item.tscn",
        "scenes/ui/card_detail_panel.tscn",
        "scenes/ui/combat_log_panel.tscn",
        "src/combat/combat_board_preview.gd",
        "src/ui/action_timing_panel.gd",
        "src/ui/action_timing_slot.gd",
        "src/ui/combat_progress_button.gd",
        "src/ui/basic_card_tray.gd",
        "src/ui/basic_card_tray_item.gd",
        "tests/verify_combat_board.gd",
    ]
    for relative in required_files:
        assert (ROOT / relative).exists(), relative

    controller = (ROOT / "src/combat/combat_board_preview.gd").read_text(encoding="utf-8")
    assert "action_timing_panel.slot_clicked.connect(_on_timing_slot_clicked)" in controller
    assert "action_timing_panel.placement_changed.connect(_on_placement_changed)" in controller
    assert "basic_card_tray.action_card_selected.connect(_on_action_card_selected)" in controller
    assert "action_timing_panel.place_card(_selected_action_definition, timing_index)" in controller
    assert "action_timing_panel.remove_at(timing_index)" in controller
    assert "combat_progress_button.set_progress_enabled(action_timing_panel.is_current_bundle_complete())" in controller
    assert '"action_placement_enabled": true' in controller
    assert '"state_advancement_enabled": false' in controller

    timing_script = (ROOT / "src/ui/action_timing_panel.gd").read_text(encoding="utf-8")
    assert "func place_card(definition: Dictionary, start_index: int) -> bool" in timing_script
    assert "func remove_at(timing_index: int) -> Dictionary" in timing_script
    assert "func is_current_bundle_complete() -> bool" in timing_script
    assert "get_current_bundle_indices()" in timing_script
    assert '"placement_step": 9' in timing_script

    slot_script = (ROOT / "src/ui/action_timing_slot.gd").read_text(encoding="utf-8")
    assert "signal slot_clicked(timing_index: int)" in slot_script
    assert "func set_assignment(" in slot_script
    assert "func clear_assignment()" in slot_script
    assert 'set_meta("card_content", true)' in slot_script

    tray_script = (ROOT / "src/ui/basic_card_tray.gd").read_text(encoding="utf-8")
    assert "signal action_card_selected(definition)" in tray_script
    assert "func set_selected_card(card_id: String)" in tray_script
    assert 'set_meta("action_placement_enabled", true)' in tray_script

    progress_script = (ROOT / "src/ui/combat_progress_button.gd").read_text(encoding="utf-8")
    assert "func set_progress_enabled(value: bool)" in progress_script
    assert 'progress_data.get("disabled_text", "행동 배치 필요")' in progress_script
    assert 'progress_data.get("action_placement_required", true)' in progress_script

    verifier = (ROOT / "tests/verify_combat_board.gd").read_text(encoding="utf-8")
    assert "STEP9" in verifier
    assert "place_card" in verifier
    assert "is_current_bundle_complete" in verifier

    print("combat board STEP 1-9 contract: PASS")


if __name__ == "__main__":
    main()
