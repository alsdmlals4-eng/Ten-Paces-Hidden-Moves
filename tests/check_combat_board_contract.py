from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "data/combat/combat_board_poc.json"
HUD_DATA = ROOT / "data/combat/combat_hud_preview.json"
ACTION_TIMING_DATA = ROOT / "data/combat/combat_action_timing_preview.json"
COMBAT_LOG_DATA = ROOT / "data/combat/combat_log_preview.json"
BASIC_CARDS_DATA = ROOT / "data/cards/basic_cards.json"
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

    assert contract["schema_version"] >= 6
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
    assert background["style"] == "ink_wash_mountain_fortress"
    assert background["contrast_role"] == "below_board_and_characters"
    assert res_file(background["asset"]).exists()
    assert res_file(background["scene"]).exists()

    top_hud = contract["top_hud"]
    assert top_hud["step"] == 4
    assert top_hud["approval_status"] == "USER_APPROVED_LAYOUT"
    assert top_hud["momentum_segments"] == 5
    assert top_hud["layout"] == [
        "player_status",
        "player_momentum",
        "round_bundle",
        "enemy_momentum",
        "enemy_status",
    ]
    assert top_hud["resource_fields"] == ["health", "stamina", "internal"]
    assert top_hud["lower_status_panels"] is False
    assert res_file(top_hud["scene"]).exists()
    assert res_file(top_hud["data"]).exists()

    hud_data = json.loads(HUD_DATA.read_text(encoding="utf-8"))
    assert hud_data["momentum_segments"] == 5
    assert hud_data["player"]["momentum"] == [4, 5]
    assert hud_data["enemy"]["momentum"] == [3, 5]
    assert hud_data["round"]["round_number"] == 1
    assert hud_data["round"]["resolution_order"] == "대응 → 속공 → 이동 → 일반 공격"

    action_timing = contract["action_timing"]
    assert action_timing["step"] == 5
    assert action_timing["approval_status"] == "USER_APPROVED_LAYOUT"
    assert action_timing["layout_role"] == "bottom_upper"
    assert action_timing["round_number"] == 1
    assert action_timing["timing_sequence"] == [3, 3, 4]
    assert action_timing["total_timings"] == 10
    assert action_timing["current_bundle"] == 2
    assert action_timing["current_timing"] == 5
    assert action_timing["progress_label_format"] == "라운드 {round}"
    assert action_timing["cards_inserted"] is False
    assert action_timing["interactions_enabled"] is False

    timing_data = json.loads(ACTION_TIMING_DATA.read_text(encoding="utf-8"))
    assert timing_data["round_number"] == hud_data["round"]["round_number"] == 1
    assert timing_data["timing_sequence"] == [3, 3, 4]
    assert sum(timing_data["timing_sequence"]) == 10

    tray = contract["basic_card_tray"]
    assert tray["step"] == 6
    assert tray["information_interaction_step"] == 7
    assert tray["approval_status"] == "USER_APPROVED_LAYOUT"
    assert tray["layout_role"] == "bottom_lower"
    assert tray["card_count"] == 7
    assert tray["card_ids"] == EXPECTED_CARD_IDS
    assert tray["compact_variant"] is True
    assert tray["uses_shared_card_data_and_atlases"] is True
    assert tray["information_interactions_enabled"] is True
    assert tray["action_placement_enabled"] is False
    assert tray["action_timing_above"] is True

    basic_cards = json.loads(BASIC_CARDS_DATA.read_text(encoding="utf-8"))
    assert [card["id"] for card in basic_cards["cards"]] == EXPECTED_CARD_IDS
    assert len(basic_cards["cards"]) == 7
    assert basic_cards["forbidden_fields"] == ["action_point_cost", "guard_reduction"]
    for card in basic_cards["cards"]:
        assert card["source"] == "basic"
        assert card["source_label"] == "기초"
        assert set(("target", "damage", "condition", "effect_text", "tags", "action_slots", "stamina_cost", "internal_cost")) <= set(card)
        assert "action_point_cost" not in card
        assert "guard_reduction" not in card

    detail = contract["card_detail_overlay"]
    assert detail["step"] == 7
    assert detail["approval_status"] == "IMPLEMENTED_FOR_REVIEW"
    assert detail["layout_role"] == "left_overlay"
    assert detail["hover_preview"] is True
    assert detail["click_pin"] is True
    assert detail["same_card_or_blank_click_close"] is True
    assert detail["action_placement_enabled"] is False
    assert res_file(detail["scene"]).exists()

    combat_log = contract["combat_log"]
    assert combat_log["step"] == 7
    assert combat_log["approval_status"] == "IMPLEMENTED_FOR_REVIEW"
    assert combat_log["layout_role"] == "right_overlay"
    assert combat_log["collapsible"] is True
    assert combat_log["default_collapsed"] is True
    assert combat_log["sample_entry_count"] == 4
    assert combat_log["output_interface"] is True
    assert res_file(combat_log["scene"]).exists()
    assert res_file(combat_log["data"]).exists()

    log_data = json.loads(COMBAT_LOG_DATA.read_text(encoding="utf-8"))
    assert log_data["schema_version"] == 1
    assert log_data["step"] == 7
    assert log_data["default_collapsed"] is True
    assert len(log_data["entries"]) == 4
    assert log_data["entries"][0]["text"] == "[1라운드 2묶음]"
    assert "대응 → 속공 → 이동 → 일반 공격" in log_data["entries"][-1]["text"]

    scope = set(contract["presentation_scope"])
    assert {"battle_background", "top_hud", "action_timing", "basic_card_tray", "card_detail_overlay", "combat_log"} <= scope
    excluded = set(contract["excluded_until_later_steps"])
    assert "card_detail_panel" not in excluded
    assert "combat_log_panel" not in excluded
    assert {"progress_button", "action_placement_interaction"} <= excluded

    required_files = [
        "assets/backgrounds/step3_mountain_fortress.svg",
        "data/cards/basic_cards.json",
        "data/combat/combat_hud_preview.json",
        "data/combat/combat_action_timing_preview.json",
        "data/combat/combat_log_preview.json",
        "scenes/combat/battle_background.tscn",
        "scenes/combat/combat_board_tile.tscn",
        "scenes/combat/combat_character_placeholder.tscn",
        "scenes/combat/combat_board_preview.tscn",
        "scenes/ui/action_timing_panel.tscn",
        "scenes/ui/action_timing_slot.tscn",
        "scenes/ui/basic_card_tray.tscn",
        "scenes/ui/basic_card_tray_item.tscn",
        "scenes/ui/card_detail_panel.tscn",
        "scenes/ui/combat_log_panel.tscn",
        "scenes/ui/combatant_status_panel.tscn",
        "scenes/ui/momentum_gauge.tscn",
        "scenes/ui/round_hud_panel.tscn",
        "scenes/ui/top_combat_hud.tscn",
        "src/combat/battle_background.gd",
        "src/combat/combat_board_preview.gd",
        "src/ui/action_timing_panel.gd",
        "src/ui/basic_card_tray.gd",
        "src/ui/basic_card_tray_item.gd",
        "src/ui/card_detail_panel.gd",
        "src/ui/combat_log_panel.gd",
        "tests/verify_combat_board.gd",
    ]
    for relative in required_files:
        assert (ROOT / relative).exists(), relative

    background_asset = (ROOT / "assets/backgrounds/step3_mountain_fortress.svg").read_text(encoding="utf-8")
    assert "data:image/" not in background_asset
    assert "<image" not in background_asset
    assert "<path" in background_asset

    controller = (ROOT / "src/combat/combat_board_preview.gd").read_text(encoding="utf-8")
    assert 'CARD_DETAIL_SCENE := preload("res://scenes/ui/card_detail_panel.tscn")' in controller
    assert 'COMBAT_LOG_SCENE := preload("res://scenes/ui/combat_log_panel.tscn")' in controller
    assert 'basic_card_tray.card_hovered.connect(_on_card_hovered)' in controller
    assert 'basic_card_tray.card_clicked.connect(_on_card_clicked)' in controller
    assert 'card_detail_panel.show_definition(definition, true)' in controller
    assert 'combat_log_panel.layout_requested.connect(_layout_board)' in controller
    assert '"card_detail_ready": is_instance_valid(card_detail_panel)' in controller
    assert '"combat_log_ready": is_instance_valid(combat_log_panel)' in controller
    assert '"action_placement_enabled": false' in controller

    timing_script = (ROOT / "src/ui/action_timing_panel.gd").read_text(encoding="utf-8")
    assert '_progress_label.text = "라운드 %d"' in timing_script
    assert "(%d/%d수)" not in timing_script

    tray_script = (ROOT / "src/ui/basic_card_tray.gd").read_text(encoding="utf-8")
    assert 'signal card_hovered(definition)' in tray_script
    assert 'signal card_clicked(definition)' in tray_script
    assert 'set_meta("information_interactions_enabled", true)' in tray_script
    assert 'set_meta("action_placement_enabled", false)' in tray_script

    tray_item_script = (ROOT / "src/ui/basic_card_tray_item.gd").read_text(encoding="utf-8")
    assert 'signal detail_hovered(definition)' in tray_item_script
    assert 'signal detail_clicked(definition)' in tray_item_script
    assert 'mouse_filter = Control.MOUSE_FILTER_STOP' in tray_item_script
    assert 'set_meta("information_interactions_enabled", true)' in tray_item_script
    assert 'set_meta("action_placement_enabled", false)' in tray_item_script

    detail_script = (ROOT / "src/ui/card_detail_panel.gd").read_text(encoding="utf-8")
    assert 'func show_definition(value: Dictionary, value_pinned: bool = false)' in detail_script
    assert 'func clear_definition()' in detail_script
    assert '"hover_preview": true' in detail_script
    assert '"click_pin": true' in detail_script
    assert '"blank_click_close": true' in detail_script

    log_script = (ROOT / "src/ui/combat_log_panel.gd").read_text(encoding="utf-8")
    assert 'func toggle_collapsed()' in log_script
    assert 'func append_entry(text: String, kind: String = "system")' in log_script
    assert 'func clear_entries()' in log_script
    assert '"output_interface": true' in log_script

    verifier = (ROOT / "tests/verify_combat_board.gd").read_text(encoding="utf-8")
    assert "EXPECTED_MOMENTUM_SEGMENTS := 5" in verifier
    assert '"card_detail_ready"' in verifier
    assert '"combat_log_ready"' in verifier
    assert "STEP7" in verifier

    print("combat board STEP 1-7 contract: PASS")


if __name__ == "__main__":
    main()
