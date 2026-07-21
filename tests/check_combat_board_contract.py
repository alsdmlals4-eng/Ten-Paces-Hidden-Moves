from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "data/combat/combat_board_poc.json"
HUD_DATA = ROOT / "data/combat/combat_hud_preview.json"
ACTION_TIMING_DATA = ROOT / "data/combat/combat_action_timing_preview.json"
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

    assert contract["schema_version"] >= 5
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
    assert top_hud["momentum_segments"] == 6
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
    assert hud_data["momentum_segments"] == 6
    assert len(hud_data["player"]["momentum"]) == 2
    assert len(hud_data["enemy"]["momentum"]) == 2
    assert hud_data["player"]["momentum"][1] == 6
    assert hud_data["enemy"]["momentum"][1] == 6
    assert hud_data["round"]["bundle_total"] == 3
    assert hud_data["round"]["resolution_order"] == "대응 → 속공 → 이동 → 일반 공격"

    action_timing = contract["action_timing"]
    assert action_timing["step"] == 5
    assert action_timing["approval_status"] == "USER_APPROVED_LAYOUT"
    assert action_timing["layout_role"] == "bottom_upper"
    assert action_timing["timing_sequence"] == [3, 3, 4]
    assert action_timing["total_timings"] == 10
    assert action_timing["current_bundle"] == 2
    assert action_timing["current_timing"] == 5
    assert action_timing["progress_scope"] == "round"
    assert action_timing["cards_inserted"] is False
    assert action_timing["interactions_enabled"] is False
    assert res_file(action_timing["scene"]).exists()
    assert res_file(action_timing["data"]).exists()

    timing_data = json.loads(ACTION_TIMING_DATA.read_text(encoding="utf-8"))
    assert timing_data["timing_sequence"] == [3, 3, 4]
    assert sum(timing_data["timing_sequence"]) == 10
    assert timing_data["total_timings"] == 10
    assert timing_data["current_bundle"] == 2
    assert timing_data["current_timing"] == 5

    tray = contract["basic_card_tray"]
    assert tray["step"] == 6
    assert tray["approval_status"] == "IMPLEMENTED_FOR_REVIEW"
    assert tray["layout_role"] == "bottom_lower"
    assert tray["card_count"] == 7
    assert tray["card_ids"] == EXPECTED_CARD_IDS
    assert tray["compact_variant"] is True
    assert tray["uses_shared_card_data_and_atlases"] is True
    assert tray["interactions_enabled"] is False
    assert tray["action_timing_above"] is True
    assert res_file(tray["scene"]).exists()
    assert res_file(tray["item_scene"]).exists()
    assert res_file(tray["data"]).exists()

    basic_cards = json.loads(BASIC_CARDS_DATA.read_text(encoding="utf-8"))
    assert basic_cards["schema_version"] == 1
    assert [card["id"] for card in basic_cards["cards"]] == EXPECTED_CARD_IDS
    assert len(basic_cards["cards"]) == 7
    assert basic_cards["forbidden_fields"] == ["action_point_cost", "guard_reduction"]
    for card in basic_cards["cards"]:
        assert card["source"] == "basic"
        assert card["source_label"] == "기초"
        assert set(("range_text", "category", "category_label", "illustration", "action_slots", "stamina_cost", "internal_cost")) <= set(card)
        assert "action_point_cost" not in card
        assert "guard_reduction" not in card

    scope = set(contract["presentation_scope"])
    assert {"battle_background", "top_hud", "action_timing", "basic_card_tray"} <= scope

    excluded = set(contract["excluded_until_later_steps"])
    assert "cards" not in excluded
    assert "skill_catalog" not in excluded
    assert {"card_detail_panel", "combat_log_panel", "progress_button", "action_placement_interaction"} <= excluded

    required_files = [
        "assets/backgrounds/step3_mountain_fortress.svg",
        "data/cards/basic_cards.json",
        "data/combat/combat_hud_preview.json",
        "data/combat/combat_action_timing_preview.json",
        "scenes/combat/battle_background.tscn",
        "scenes/combat/combat_board_tile.tscn",
        "scenes/combat/combat_character_placeholder.tscn",
        "scenes/combat/combat_board_preview.tscn",
        "scenes/ui/action_timing_panel.tscn",
        "scenes/ui/action_timing_slot.tscn",
        "scenes/ui/basic_card_tray.tscn",
        "scenes/ui/basic_card_tray_item.tscn",
        "scenes/ui/combatant_status_panel.tscn",
        "scenes/ui/momentum_gauge.tscn",
        "scenes/ui/round_hud_panel.tscn",
        "scenes/ui/top_combat_hud.tscn",
        "src/combat/battle_background.gd",
        "src/combat/combat_board_tile.gd",
        "src/combat/combat_character_placeholder.gd",
        "src/combat/combat_board_preview.gd",
        "src/ui/action_timing_panel.gd",
        "src/ui/action_timing_slot.gd",
        "src/ui/basic_card_tray.gd",
        "src/ui/basic_card_tray_item.gd",
        "src/ui/combatant_status_panel.gd",
        "src/ui/momentum_gauge.gd",
        "src/ui/round_hud_panel.gd",
        "src/ui/top_combat_hud.gd",
        "tests/verify_combat_board.gd",
    ]
    for relative in required_files:
        assert (ROOT / relative).exists(), relative

    background_asset = (ROOT / "assets/backgrounds/step3_mountain_fortress.svg").read_text(encoding="utf-8")
    assert "data:image/" not in background_asset
    assert "<image" not in background_asset
    assert "<path" in background_asset

    controller = (ROOT / "src/combat/combat_board_preview.gd").read_text(encoding="utf-8")
    assert 'const BASIC_CARD_TRAY_SCENE := preload("res://scenes/ui/basic_card_tray.tscn")' in controller
    assert 'basic_card_tray = BASIC_CARD_TRAY_SCENE.instantiate() as BasicCardTray' in controller
    assert controller.index("add_child(_character_layer)") < controller.index("add_child(action_timing_panel)")
    assert controller.index("add_child(action_timing_panel)") < controller.index("add_child(basic_card_tray)")
    assert controller.index("add_child(basic_card_tray)") < controller.index("add_child(top_hud)")
    assert '"basic_card_tray_ready": is_instance_valid(basic_card_tray)' in controller
    assert '"lower_status_panels": false' in controller
    assert '"lower_skill_panel": true' in controller

    timing_panel_script = (ROOT / "src/ui/action_timing_panel.gd").read_text(encoding="utf-8")
    assert 'set_meta("timing_sequence", "3|3|4")' in timing_panel_script
    assert 'set_meta("progress_scope", "round")' in timing_panel_script
    assert '"라운드 진행 %d / %d수"' in timing_panel_script
    assert 'set_meta("interactions_enabled", false)' in timing_panel_script

    tray_script = (ROOT / "src/ui/basic_card_tray.gd").read_text(encoding="utf-8")
    assert 'DATA_PATH := "res://data/cards/basic_cards.json"' in tray_script
    assert 'CARD_SCENE := preload("res://scenes/ui/basic_card_tray_item.tscn")' in tray_script
    assert 'set_meta("card_count", cards.size())' in tray_script
    assert 'set_meta("compact_variant", true)' in tray_script
    assert 'set_meta("interactions_enabled", false)' in tray_script

    tray_item_script = (ROOT / "src/ui/basic_card_tray_item.gd").read_text(encoding="utf-8")
    assert '"슬롯 %d  ·  기력 %d  ·  내력 %d"' in tray_item_script
    assert 'set_meta("interactions_enabled", false)' in tray_item_script
    for category in ("move", "attack", "response", "recovery", "strengthen"):
        assert f'"{category}"' in tray_item_script

    verifier = (ROOT / "tests/verify_combat_board.gd").read_text(encoding="utf-8")
    assert "EXPECTED_TIMING_SEQUENCE := [3, 3, 4]" in verifier
    assert "EXPECTED_CARD_IDS" in verifier
    assert '"basic_card_tray_ready"' in verifier

    print("combat board STEP 1-6 contract: PASS")


if __name__ == "__main__":
    main()
