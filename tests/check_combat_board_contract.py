from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEXT_SUFFIXES = {".gd", ".tscn", ".py", ".ps1", ".cmd", ".md", ".json", ".yml", ".yaml", ".godot"}
CONFLICT_MARKERS = ("<<<<<<<", "=======", ">>>>>>>")
EXPECTED_PLAYER_TILE = 4
EXPECTED_ENEMY_TILE = 7
EXPECTED_CARD_IDS = [
    "basic_move",
    "basic_footwork",
    "basic_guard",
    "basic_evade",
    "basic_quick_attack",
    "basic_heavy_attack",
    "basic_meditate",
    "basic_stance",
]


def load_json(relative: str) -> dict:
    return json.loads((ROOT / relative).read_text(encoding="utf-8"))


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
        for line_number, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1):
            if line.startswith(CONFLICT_MARKERS):
                failures.append(f"{path.relative_to(ROOT)}:{line_number}:{line}")
    assert not failures, "Committed VCS conflict markers found:\n" + "\n".join(failures)


def main() -> None:
    assert_no_conflict_markers()

    contract = load_json("data/combat/combat_board_poc.json")
    hud = load_json("data/combat/combat_hud_preview.json")
    timing = load_json("data/combat/combat_action_timing_preview.json")
    progress = load_json("data/combat/combat_progress_preview.json")
    resolution = load_json("data/combat/combat_resolution_preview.json")
    cards = load_json("data/cards/basic_cards.json")
    ultimate_cards = load_json("data/cards/ultimate_cards.json")
    asset_manifest = load_json("assets/ASSET_MANIFEST.json")

    assert contract["schema_version"] >= 13
    assert contract["tile_count"] == 10
    assert contract["player_start_tile"] == EXPECTED_PLAYER_TILE
    assert contract["enemy_start_tile"] == EXPECTED_ENEMY_TILE
    assert contract["camera_mode"] == "fixed_wide"
    assert contract["top_hud"]["momentum_segments"] == 5
    assert contract["top_hud"]["combat_start_resources"] == "maximum_minus_start_penalties"
    assert contract["top_hud"]["placement_resource_preview"] is True
    assert hud["momentum_segments"] == 5
    assert hud["round"]["round_number"] == 1
    assert hud["round"]["bundle_index"] == 1
    for side in ("player", "enemy"):
        for resource in ("health", "stamina", "internal"):
            current, maximum = hud[side][resource]
            assert current == maximum
            assert hud[side]["start_penalties"][resource] == 0
        assert hud[side]["health"] == [30, 30]
        assert hud[side]["attack_power"] == 8

    action_timing = contract["action_timing"]
    assert action_timing["timing_sequence"] == [3, 3, 4]
    assert action_timing["total_timings"] == 10
    assert action_timing["current_bundle"] == 1
    assert action_timing["current_timing"] == 1
    assert action_timing["actionable_indices"] == [1, 2, 3]
    assert action_timing["targeting_enabled"] is True
    assert action_timing["resource_preview_enabled"] is True
    assert timing["timing_sequence"] == [3, 3, 4]
    assert timing["current_bundle"] == 1
    assert timing["current_timing"] == 1

    progress_contract = contract["progress_button"]
    assert progress_contract["enable_condition"] == "current_bundle_complete_targets_and_resources_ready"
    assert progress_contract["request_mode"] == "resolve_bundle"
    assert progress_contract["advances_state"] is True
    assert progress["default_enabled"] is False
    assert progress["enable_condition"] == "current_bundle_complete_targets_and_resources_ready"
    assert progress["resource_plan_required"] is True
    assert progress["request_mode"] == "resolve_bundle"
    assert progress["advances_state"] is True

    assert contract["basic_card_tray"]["card_count"] == 8
    assert contract["basic_card_tray"]["card_ids"] == EXPECTED_CARD_IDS
    assert contract["basic_card_tray"]["stance_response_combo_enabled"] is True
    assert [card["id"] for card in cards["cards"]] == EXPECTED_CARD_IDS
    assert cards["forbidden_fields"] == ["action_point_cost", "guard_reduction"]
    by_id = {card["id"]: card for card in cards["cards"]}
    for card in cards["cards"]:
        assert card["source"] == "basic"
        assert int(card["action_slots"]) in (1, 2)
        assert "action_point_cost" not in card
        assert "guard_reduction" not in card
    assert by_id["basic_move"]["move_range"] == 1
    assert by_id["basic_footwork"]["move_range"] == 2
    assert by_id["basic_footwork"]["internal_cost"] == 1
    assert by_id["basic_heavy_attack"]["range_text"] == "2"
    assert by_id["basic_heavy_attack"]["internal_cost"] == 1
    assert "50%" in by_id["basic_guard"]["effect_text"]
    assert "완전히 회피" in by_id["basic_evade"]["effect_text"]
    assert "대응" in by_id["basic_stance"]["effect_text"]

    targeting = contract["action_targeting"]
    assert targeting["patch"] == "10.5"
    assert targeting["move_mode"] == "select_destination_board_tile"
    assert targeting["move_range_source"] == "card.move_range"
    assert targeting["basic_move_range"] == 1
    assert targeting["footwork_move_range"] == 2
    assert targeting["footwork_distance_choice"] == [1, 2]
    assert targeting["attack_mode"] == "select_left_or_right_direction"
    assert targeting["heavy_attack_range"] == 2
    assert targeting["heavy_attack_hits_distances"] == [1, 2]
    assert targeting["tile_states"] == ["default", "movable", "attackable", "selected", "disabled"]
    assert targeting["shape_and_text_fallback"] is True
    assert targeting["unresolved_target_blocks_progress"] is True
    assert targeting["resolution_uses_explicit_target"] is True

    response = contract["response_rules"]
    assert response["patch"] == "10.6"
    assert response["guard_same_timing"] == "halve_damage"
    assert response["guard_same_bundle"] == "reduce_by_guard_block"
    assert response["guard_comparison"] == "use_larger_reduction"
    assert response["guard_block"] == 4
    assert response["evade_same_timing"] == "full_evade"
    assert response["stance_response_combo"] == "same_slot"
    assert response["stance_response_scope"] == "current_bundle"
    assert response["stance_guard_multiplier"] == 1.5
    assert response["stance_evade_scope"] == "full_bundle_evade"

    placement = contract["action_placement"]
    assert placement["placement_updates_resources_immediately"] is True
    assert placement["recovery_updates_resources_immediately"] is True
    assert placement["insufficient_resources_block_progress"] is True
    assert placement["progress_requires_resources_ready"] is True

    engagement = contract["engagement"]
    assert engagement["same_tile_allowed"] is True
    assert engagement["max_combatants_per_tile"] == 2
    assert engagement["distance"] == 0
    assert engagement["range_one_or_more_automatic"] is True
    assert engagement["swap_and_pass_forbidden"] is True

    ultimate = contract["ultimate_skills"]
    assert ultimate["activation_momentum"] == 5
    assert res_file(ultimate["asset_manifest"]).exists()
    active_assets = [asset for asset in asset_manifest["assets"] if asset["active"]]
    assert len(active_assets) == 1
    assert active_assets[0]["id"] == "ultimate_ink_gold_sprite_sheet_rgba"
    assert active_assets[0]["transparency_audit"]["has_alpha"] is True
    assert active_assets[0]["transparency_audit"]["status"] == "APPROVED_ACTIVE"
    assert ultimate["requires_exact_momentum"] is True
    assert ultimate["reservation_consumes_momentum_immediately"] is True
    assert ultimate["reservation_refund"] is False
    assert ultimate["damage_formula"] == "base_damage + floor(attack_power * coefficient)"
    assert [card["id"] for card in ultimate_cards["cards"]] == ultimate["skills"]
    expected_ultimate_damage = {
        "ultimate_ten_paces_wave": (1, "quick_attack", "8", 0.25),
        "ultimate_cleave_peak": (2, "general", "14", 0.75),
        "ultimate_void_sword_qi": (3, "general", "22", 1.5),
    }
    for card in ultimate_cards["cards"]:
        span, phase, damage, coefficient = expected_ultimate_damage[card["id"]]
        assert card["source"] == "ultimate"
        assert card["action_slots"] == span
        assert card["resolution_phase"] == phase
        assert card["damage"] == damage
        assert card["attack_power_coefficient"] == coefficient
        assert card["stamina_cost"] == 0 and card["internal_cost"] == 0

    resolution_contract = contract["resolution_engine"]
    assert resolution_contract["resolution_order"] == ["response", "quick_attack", "move", "general"]
    assert resolution_contract["same_phase_attacks"] == "simultaneous_damage"
    assert resolution_contract["uses_explicit_move_target"] is True
    assert resolution_contract["uses_explicit_attack_direction"] is True
    assert resolution_contract["uses_card_specific_move_range"] is True
    assert resolution_contract["uses_guard_bundle_profiles"] is True
    assert resolution_contract["uses_stance_response_combo"] is True
    assert resolution_contract["placement_resource_preview"] is True
    assert resolution_contract["combat_start_resources"] == "maximum_minus_start_penalties"
    assert resolution_contract["interruption_enabled"] is True
    assert resolution_contract["fortitude_enabled"] is True
    assert resolution_contract["presentation_events"] is True
    assert res_file(resolution_contract["script"]).exists()
    assert res_file(resolution_contract["data"]).exists()

    assert resolution["schema_version"] >= 4
    assert resolution["targeting_patch"] == "10.5"
    assert resolution["tile_count"] == 10
    assert resolution["movement_range_source"] == "card.move_range"
    assert resolution["combat_start_resources"] == "maximum_minus_start_penalties"
    assert resolution["guard_same_timing_damage_multiplier"] == 0.5
    assert resolution["guard_bundle_mode"] == "fixed_block"
    assert resolution["guard_uses_higher_reduction"] is True
    assert resolution["evade_same_timing_full"] is True
    assert resolution["stance_response_bundle_extension"] is True
    assert resolution["stance_response_defense_multiplier"] == 1.5
    assert resolution["placement_resource_preview"] is True
    assert resolution["explicit_player_move_target"] is True
    assert resolution["explicit_player_attack_direction"] is True
    assert resolution["damage_interrupts_future_actions"] is True
    assert resolution["fortitude_quick_phase_one_slot_only"] is True
    assert resolution["same_tile_engagement"] is True
    assert resolution["same_tile_max_combatants"] == 2
    assert set(resolution["enemy_bundles"]) == {"1", "2", "3"}
    for bundle in resolution["enemy_bundles"].values():
        for action in bundle:
            assert action["targeting_mode"] in {"none", "move_tile", "attack_direction"}
            assert int(action["direction"]) in {-1, 0, 1}

    scope = set(contract["presentation_scope"])
    assert {"action_targeting", "action_placement", "response_rules", "resolution_engine"} <= scope
    excluded = set(contract["excluded_until_later_steps"])
    assert {"combat_ai", "combat_end_restart"} <= excluded
    assert "interruption_focus_fortitude" not in excluded

    required_files = [
        "assets/backgrounds/step3_mountain_fortress.svg",
        "assets/reference/step_02_character_scale_and_tile_placement.svg",
        "scenes/combat/combat_board_preview.tscn",
        "scenes/combat/combat_board_tile.tscn",
        "scenes/ui/action_timing_panel.tscn",
        "scenes/ui/action_timing_slot.tscn",
        "src/combat/combat_board_preview.gd",
        "src/combat/combat_board_tile.gd",
        "src/combat/combat_resolution_engine.gd",
        "src/ui/action_timing_panel.gd",
        "src/ui/action_timing_slot.gd",
        "src/ui/basic_card_tray.gd",
        "tests/verify_combat_board.gd",
        "tests/verify_response_rules.gd",
        "tests/verify_ultimate_interrupt_engagement.gd",
        "tests/verify_ultimate_ui.gd",
        "tests/verify_combat_performance_headless.gd",
        "data/cards/ultimate_cards.json",
    ]
    for relative in required_files:
        assert (ROOT / relative).exists(), relative

    tile_script = (ROOT / "src/combat/combat_board_tile.gd").read_text(encoding="utf-8")
    timing_script = (ROOT / "src/ui/action_timing_panel.gd").read_text(encoding="utf-8")
    slot_script = (ROOT / "src/ui/action_timing_slot.gd").read_text(encoding="utf-8")
    tray_script = (ROOT / "src/ui/basic_card_tray.gd").read_text(encoding="utf-8")
    engine_script = (ROOT / "src/combat/combat_resolution_engine.gd").read_text(encoding="utf-8")
    controller = (ROOT / "src/combat/combat_board_preview.gd").read_text(encoding="utf-8")
    verifier = (ROOT / "tests/verify_combat_board.gd").read_text(encoding="utf-8")
    response_verifier = (ROOT / "tests/verify_response_rules.gd").read_text(encoding="utf-8")
    powershell = (ROOT / "tools/verify_and_commit_combat_foundation.ps1").read_text(encoding="utf-8")
    reference_svg = (ROOT / "assets/reference/step_02_character_scale_and_tile_placement.svg").read_text(encoding="utf-8")

    assert all(token in tile_script for token in ("signal tile_clicked", "set_interaction_state", "movable", "attackable"))
    assert all(token in timing_script for token in ("set_placement_target", "get_pending_target_anchor", "are_current_bundle_targets_ready", "are_current_bundle_resources_ready", "preview_player_plan", "projected_combat_state"))
    assert all(token in slot_script for token in ("set_target_info", "set_resource_info", "resource_ready", "자원 부족"))
    assert all(token in tray_script for token in ("build_stance_response_combo", "stance_response_combo", "combo_parts", "태세+"))
    assert all(token in engine_script for token in ("miss_direction", "target_tile", "selected_direction", "requested_tile", "move_range", "start_penalties", "_prepare_combatant_start", "preview_player_plan", "_prepare_bundle_defenses", "guard_timings", "evade_bundle", "stance_response_defense_multiplier", "ULTIMATES_PATH", "_apply_interruption_after_damage", "_build_presentation_events"))
    assert all(token in controller for token in (
        "_begin_targeting_for_anchor",
        "_on_board_tile_clicked",
        "set_placement_target",
        "targeting_enabled",
        "move_range",
        "var _player_tile := 4",
        "var _enemy_tile := 7",
        'contract.get("player_start_tile", 4)',
        'contract.get("enemy_start_tile", 7)',
        "UltimateMenu",
        "presentation_state",
    ))
    assert all(token in verifier for token in ("TARGETING_10_5", "_on_board_tile_clicked", "miss_direction", "basic_footwork", "EXPECTED_PLAYER_TILE := 4", "EXPECTED_ENEMY_TILE := 7"))
    assert all(token in response_verifier for token in ("Same-timing guard", "Stance+guard", "Stance+evade", "preview_player_plan", "invalid_anchors"))
    assert "res://tests/verify_response_rules.gd" in powershell
    assert "플레이어 4번 / 상대 7번" in reference_svg
    assert "플레이어 · 4번 칸" in reference_svg
    assert "상대 · 7번 칸" in reference_svg
    assert "플레이어 3번 / 상대 8번" not in reference_svg

    print("combat board STEP 1-10.6 contract with start tiles 4 and 7: PASS")


if __name__ == "__main__":
    main()
