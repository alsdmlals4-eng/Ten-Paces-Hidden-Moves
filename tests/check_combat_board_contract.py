from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "data/combat/combat_board_poc.json"
HUD_DATA = ROOT / "data/combat/combat_hud_preview.json"
TIMING_DATA = ROOT / "data/combat/combat_action_timing_preview.json"
PROGRESS_DATA = ROOT / "data/combat/combat_progress_preview.json"
RESOLUTION_DATA = ROOT / "data/combat/combat_resolution_preview.json"
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
    resolution_data = json.loads(RESOLUTION_DATA.read_text(encoding="utf-8"))
    log_data = json.loads(LOG_DATA.read_text(encoding="utf-8"))
    card_data = json.loads(CARD_DATA.read_text(encoding="utf-8"))

    assert contract["schema_version"] >= 10
    assert contract["tile_count"] == 10
    assert contract["player_start_tile"] == 3
    assert contract["enemy_start_tile"] == 8
    assert contract["camera_mode"] == "fixed_wide"
    assert 1.4 <= contract["character_height_to_tile_width"] <= 1.6
    assert 0.0 < contract["foot_anchor_y_ratio"] < 1.0

    background = contract["battle_background"]
    assert background["step"] == 3
    assert background["approval_status"] == "USER_APPROVED"
    assert res_file(background["asset"]).exists()
    assert res_file(background["scene"]).exists()

    hud = contract["top_hud"]
    assert hud["step"] == 4
    assert hud["runtime_step"] == 10
    assert hud["momentum_segments"] == 5
    assert hud["runtime_updates"] is True
    assert hud["lower_status_panels"] is False
    assert hud_data["momentum_segments"] == 5
    assert hud_data["round"]["round_number"] == 1
    assert hud_data["round"]["bundle_index"] == 1

    timing = contract["action_timing"]
    assert timing["step"] == 5
    assert timing["placement_step"] == 9
    assert timing["runtime_step"] == 10
    assert timing["targeting_patch"] == "10.5"
    assert timing["timing_sequence"] == [3, 3, 4]
    assert timing["total_timings"] == 10
    assert timing["current_bundle"] == 1
    assert timing["current_timing"] == 1
    assert timing["actionable_indices"] == [1, 2, 3]
    assert timing["targeting_enabled"] is True
    assert timing["advances_after_resolution"] is True
    assert timing_data["schema_version"] == 2
    assert timing_data["current_bundle"] == 1
    assert timing_data["current_timing"] == 1
    assert sum(timing_data["timing_sequence"]) == 10

    progress = contract["progress_button"]
    assert progress["step"] == 8
    assert progress["placement_gate_step"] == 9
    assert progress["runtime_step"] == 10
    assert progress["targeting_patch"] == "10.5"
    assert progress["default_enabled"] is False
    assert progress["enable_condition"] == "current_bundle_complete_and_targets_ready"
    assert progress["request_mode"] == "resolve_bundle"
    assert progress["advances_state"] is True
    assert progress["action_placement_required"] is True
    assert progress_data["schema_version"] == 3
    assert progress_data["bundle_index"] == 1
    assert progress_data["current_timing"] == 1
    assert progress_data["request_mode"] == "resolve_bundle"
    assert progress_data["advances_state"] is True

    tray = contract["basic_card_tray"]
    assert tray["step"] == 6
    assert tray["placement_step"] == 9
    assert tray["card_count"] == 7
    assert tray["card_ids"] == EXPECTED_CARD_IDS
    assert tray["action_placement_enabled"] is True
    assert [card["id"] for card in card_data["cards"]] == EXPECTED_CARD_IDS
    assert card_data["forbidden_fields"] == ["action_point_cost", "guard_reduction"]
    assert next(card for card in card_data["cards"] if card["id"] == "basic_heavy_attack")["action_slots"] == 2

    placement = contract["action_placement"]
    assert placement["step"] == 9
    assert placement["targeting_patch"] == "10.5"
    assert placement["interaction"] == "select_card_then_click_slot_then_choose_target"
    assert placement["editable_scope"] == "current_bundle_slots"
    assert placement["actionable_indices"] == [1, 2, 3]
    assert placement["progress_requires_complete_bundle"] is True
    assert placement["progress_requires_targets_ready"] is True
    assert placement["state_advancement_enabled"] is True

    targeting = contract["action_targeting"]
    assert targeting["patch"] == "10.5"
    assert targeting["approval_status"] == "IMPLEMENTED_FOR_REVIEW"
    assert targeting["move_mode"] == "select_destination_board_tile"
    assert targeting["move_steps"] == 1
    assert targeting["attack_mode"] == "select_left_or_right_direction"
    assert targeting["attack_range_tiles_are_clickable"] is True
    assert targeting["tile_states"] == ["default", "movable", "attackable", "selected", "disabled"]
    assert targeting["shape_and_text_fallback"] is True
    assert targeting["slot_target_summary"] is True
    assert targeting["unresolved_target_blocks_progress"] is True
    assert targeting["resolution_uses_explicit_target"] is True

    resolution = contract["resolution_engine"]
    assert resolution["step"] == 10
    assert resolution["targeting_patch"] == "10.5"
    assert resolution["resolution_order"] == ["response", "quick_attack", "move", "general"]
    assert resolution["same_phase_attacks"] == "simultaneous_damage"
    assert resolution["uses_explicit_move_target"] is True
    assert resolution["uses_explicit_attack_direction"] is True
    assert resolution["advances_bundle_and_round"] is True
    assert resolution["fixed_enemy_preview_plan"] is True
    assert resolution["interruption_enabled"] is False
    assert res_file(resolution["script"]).exists()
    assert res_file(resolution["data"]).exists()

    assert resolution_data["schema_version"] == 2
    assert resolution_data["targeting_patch"] == "10.5"
    assert resolution_data["tile_count"] == 10
    assert resolution_data["explicit_player_move_target"] is True
    assert resolution_data["explicit_player_attack_direction"] is True
    assert resolution_data["resolution_order"] == ["response", "quick_attack", "move", "general"]
    assert set(resolution_data["enemy_bundles"]) == {"1", "2", "3"}
    for bundle in resolution_data["enemy_bundles"].values():
        for action in bundle:
            assert "targeting_mode" in action
            assert "direction" in action

    combat_log = contract["combat_log"]
    assert combat_log["resolution_output"] is True
    assert combat_log["targeting_output"] is True
    assert len(log_data["entries"]) == 4
    assert "대응 → 속공 → 이동 → 일반 공격" in log_data["entries"][-1]["text"]

    scope = set(contract["presentation_scope"])
    assert {"action_placement", "action_targeting", "resolution_engine", "action_timing", "progress_button", "top_hud", "combat_log"} <= scope
    excluded = set(contract["excluded_until_later_steps"])
    assert "resolution_engine" not in excluded
    assert {"interruption_focus_fortitude", "combat_ai", "combat_end_restart"} <= excluded

    required_files = [
        "data/combat/combat_resolution_preview.json",
        "src/combat/combat_resolution_engine.gd",
        "src/combat/combat_board_preview.gd",
        "src/combat/combat_board_tile.gd",
        "src/ui/action_timing_panel.gd",
        "src/ui/action_timing_slot.gd",
        "src/ui/combat_progress_button.gd",
        "src/ui/top_combat_hud.gd",
        "tests/verify_combat_board.gd",
    ]
    for relative in required_files:
        assert (ROOT / relative).exists(), relative

    tile_script = (ROOT / "src/combat/combat_board_tile.gd").read_text(encoding="utf-8")
    assert "signal tile_clicked(tile_index: int)" in tile_script
    assert "func set_interaction_state(value: String)" in tile_script
    assert 'interaction_state in ["movable", "attackable", "selected"]' in tile_script
    assert 'draw_string(ThemeDB.fallback_font' in tile_script

    timing_script = (ROOT / "src/ui/action_timing_panel.gd").read_text(encoding="utf-8")
    assert "func set_placement_target(anchor_index: int, target_data: Dictionary) -> bool" in timing_script
    assert "func get_pending_target_anchor() -> int" in timing_script
    assert "func are_current_bundle_targets_ready() -> bool" in timing_script
    assert "return are_current_bundle_targets_ready()" in timing_script
    assert '"targeting_mode": targeting_mode' in timing_script
    assert '"target_ready": targeting_mode == "none"' in timing_script

    slot_script = (ROOT / "src/ui/action_timing_slot.gd").read_text(encoding="utf-8")
    assert "func set_target_info(value_text: String, value_ready: bool, value_mode: String)" in slot_script
    assert '"대상 선택"' in slot_script

    engine_script = (ROOT / "src/combat/combat_resolution_engine.gd").read_text(encoding="utf-8")
    assert "func resolve_bundle(" in engine_script
    assert 'selected_direction != relative_direction' in engine_script
    assert 'requested_tile := int(action.get("target_tile", 0))' in engine_script
    assert '"direction": int(action.get("direction", 0))' in engine_script
    assert '"target_tile": int(action.get("target_tile", 0))' in engine_script

    controller = (ROOT / "src/combat/combat_board_preview.gd").read_text(encoding="utf-8")
    assert "tile.tile_clicked.connect(_on_board_tile_clicked)" in controller
    assert "func _begin_targeting_for_anchor(anchor_index: int) -> bool" in controller
    assert "func _on_board_tile_clicked(tile_index: int) -> void" in controller
    assert 'get_tile(target_index).set_interaction_state("movable")' in controller
    assert 'get_tile(target_index).set_interaction_state("attackable")' in controller
    assert "action_timing_panel.set_placement_target(_targeting_anchor, target_data)" in controller
    assert '"targeting_enabled": true' in controller
    assert '"interruption_enabled": false' in controller

    verifier = (ROOT / "tests/verify_combat_board.gd").read_text(encoding="utf-8")
    assert "TARGETING_10_5" in verifier
    assert "set_placement_target" in verifier
    assert "miss_direction" in verifier

    print("combat board STEP 1-10 plus TARGETING 10.5 contract: PASS")


if __name__ == "__main__":
    main()
