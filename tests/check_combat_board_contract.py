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

    assert contract["schema_version"] >= 9
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
    assert timing["timing_sequence"] == [3, 3, 4]
    assert timing["total_timings"] == 10
    assert timing["current_bundle"] == 1
    assert timing["current_timing"] == 1
    assert timing["actionable_indices"] == [1, 2, 3]
    assert timing["advances_after_resolution"] is True
    assert timing_data["schema_version"] == 2
    assert timing_data["current_bundle"] == 1
    assert timing_data["current_timing"] == 1
    assert sum(timing_data["timing_sequence"]) == 10

    progress = contract["progress_button"]
    assert progress["step"] == 8
    assert progress["placement_gate_step"] == 9
    assert progress["runtime_step"] == 10
    assert progress["default_enabled"] is False
    assert progress["enable_condition"] == "current_bundle_complete"
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
    assert tray["information_interaction_step"] == 7
    assert tray["placement_step"] == 9
    assert tray["card_count"] == 7
    assert tray["card_ids"] == EXPECTED_CARD_IDS
    assert tray["action_placement_enabled"] is True
    assert [card["id"] for card in card_data["cards"]] == EXPECTED_CARD_IDS
    assert card_data["forbidden_fields"] == ["action_point_cost", "guard_reduction"]
    assert next(card for card in card_data["cards"] if card["id"] == "basic_heavy_attack")["action_slots"] == 2

    placement = contract["action_placement"]
    assert placement["step"] == 9
    assert placement["approval_status"] == "USER_APPROVED_INTERACTION"
    assert placement["editable_scope"] == "current_bundle_slots"
    assert placement["current_bundle"] == 1
    assert placement["actionable_indices"] == [1, 2, 3]
    assert placement["state_advancement_enabled"] is True

    resolution = contract["resolution_engine"]
    assert resolution["step"] == 10
    assert resolution["approval_status"] == "IMPLEMENTED_FOR_REVIEW"
    assert resolution["resolution_order"] == ["response", "quick_attack", "move", "general"]
    assert resolution["resolution_order_label"] == "대응 → 속공 → 이동 → 일반 공격"
    assert resolution["same_phase_attacks"] == "simultaneous_damage"
    assert resolution["updates_health_stamina_internal_momentum"] is True
    assert resolution["updates_board_position"] is True
    assert resolution["advances_bundle_and_round"] is True
    assert resolution["fixed_enemy_preview_plan"] is True
    assert resolution["interruption_enabled"] is False
    assert res_file(resolution["script"]).exists()
    assert res_file(resolution["data"]).exists()

    assert resolution_data["schema_version"] == 1
    assert resolution_data["step"] == 10
    assert resolution_data["resolution_order"] == ["response", "quick_attack", "move", "general"]
    assert resolution_data["guard_block"] == 4
    assert set(resolution_data["enemy_bundles"]) == {"1", "2", "3"}
    assert [entry["timing"] for entry in resolution_data["enemy_bundles"]["1"]] == [1, 2, 3]

    combat_log = contract["combat_log"]
    assert combat_log["resolution_output"] is True
    assert len(log_data["entries"]) == 4
    assert "대응 → 속공 → 이동 → 일반 공격" in log_data["entries"][-1]["text"]

    scope = set(contract["presentation_scope"])
    assert {"action_placement", "resolution_engine", "action_timing", "progress_button", "top_hud", "combat_log"} <= scope
    excluded = set(contract["excluded_until_later_steps"])
    assert "resolution_engine" not in excluded
    assert {"interruption_focus_fortitude", "combat_ai", "combat_end_restart"} <= excluded

    required_files = [
        "data/combat/combat_resolution_preview.json",
        "src/combat/combat_resolution_engine.gd",
        "src/combat/combat_board_preview.gd",
        "src/ui/action_timing_panel.gd",
        "src/ui/combat_progress_button.gd",
        "src/ui/top_combat_hud.gd",
        "tests/verify_combat_board.gd",
    ]
    for relative in required_files:
        assert (ROOT / relative).exists(), relative

    engine_script = (ROOT / "src/combat/combat_resolution_engine.gd").read_text(encoding="utf-8")
    assert "class_name CombatResolutionEngine" in engine_script
    assert "func resolve_bundle(" in engine_script
    assert 'rules.get("resolution_order_label"' in engine_script
    assert "func _execute_response(" in engine_script
    assert "func _execute_attack_phase(" in engine_script
    assert "func _execute_move_phase(" in engine_script
    assert "func _execute_utility(" in engine_script
    assert '"interruption_enabled"' not in engine_script

    timing_script = (ROOT / "src/ui/action_timing_panel.gd").read_text(encoding="utf-8")
    assert "func get_resolution_placements() -> Array" in timing_script
    assert "func get_runtime_context() -> Dictionary" in timing_script
    assert "func advance_after_resolution() -> Dictionary" in timing_script
    assert '"state_advancement_enabled": true' in timing_script

    progress_script = (ROOT / "src/ui/combat_progress_button.gd").read_text(encoding="utf-8")
    assert "func set_runtime_context(value: Dictionary)" in progress_script
    assert "func mark_resolution_applied()" in progress_script
    assert 'progress_data.get("request_mode", "resolve_bundle")' in progress_script

    hud_script = (ROOT / "src/ui/top_combat_hud.gd").read_text(encoding="utf-8")
    assert "func apply_combat_state(state: Dictionary" in hud_script

    controller = (ROOT / "src/combat/combat_board_preview.gd").read_text(encoding="utf-8")
    assert "resolution_engine = CombatResolutionEngine.new()" in controller
    assert "resolution_engine.resolve_bundle(" in controller
    assert "action_timing_panel.advance_after_resolution()" in controller
    assert "top_hud.apply_combat_state(" in controller
    assert '"state_advancement_enabled": true' in controller
    assert '"interruption_enabled": false' in controller

    verifier = (ROOT / "tests/verify_combat_board.gd").read_text(encoding="utf-8")
    assert "STEP10" in verifier
    assert "request_progress()" in verifier
    assert "current_bundle" in verifier

    print("combat board STEP 1-10 contract: PASS")


if __name__ == "__main__":
    main()
