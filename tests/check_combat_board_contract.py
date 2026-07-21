from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEXT_SUFFIXES = {".gd", ".tscn", ".py", ".ps1", ".cmd", ".md", ".json", ".yml", ".yaml", ".godot"}
CONFLICT_MARKERS = ("<<<<<<<", "=======", ">>>>>>>")
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

    assert contract["schema_version"] >= 11
    assert contract["tile_count"] == 10
    assert contract["player_start_tile"] == 3
    assert contract["enemy_start_tile"] == 8
    assert contract["camera_mode"] == "fixed_wide"
    assert contract["top_hud"]["momentum_segments"] == 5
    assert contract["top_hud"]["combat_start_resources"] == "maximum_minus_start_penalties"
    assert hud["momentum_segments"] == 5
    assert hud["round"]["round_number"] == 1
    assert hud["round"]["bundle_index"] == 1
    for side in ("player", "enemy"):
        for resource in ("health", "stamina", "internal"):
            current, maximum = hud[side][resource]
            assert current == maximum
            assert hud[side]["start_penalties"][resource] == 0

    action_timing = contract["action_timing"]
    assert action_timing["timing_sequence"] == [3, 3, 4]
    assert action_timing["total_timings"] == 10
    assert action_timing["current_bundle"] == 1
    assert action_timing["current_timing"] == 1
    assert action_timing["actionable_indices"] == [1, 2, 3]
    assert action_timing["targeting_enabled"] is True
    assert timing["timing_sequence"] == [3, 3, 4]
    assert timing["current_bundle"] == 1
    assert timing["current_timing"] == 1

    progress_contract = contract["progress_button"]
    assert progress_contract["enable_condition"] == "current_bundle_complete_and_targets_ready"
    assert progress_contract["request_mode"] == "resolve_bundle"
    assert progress_contract["advances_state"] is True
    assert progress["default_enabled"] is False
    assert progress["request_mode"] == "resolve_bundle"
    assert progress["advances_state"] is True

    assert contract["basic_card_tray"]["card_count"] == 8
    assert contract["basic_card_tray"]["card_ids"] == EXPECTED_CARD_IDS
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

    resolution_contract = contract["resolution_engine"]
    assert resolution_contract["resolution_order"] == ["response", "quick_attack", "move", "general"]
    assert resolution_contract["same_phase_attacks"] == "simultaneous_damage"
    assert resolution_contract["uses_explicit_move_target"] is True
    assert resolution_contract["uses_explicit_attack_direction"] is True
    assert resolution_contract["uses_card_specific_move_range"] is True
    assert resolution_contract["combat_start_resources"] == "maximum_minus_start_penalties"
    assert resolution_contract["interruption_enabled"] is False
    assert res_file(resolution_contract["script"]).exists()
    assert res_file(resolution_contract["data"]).exists()

    assert resolution["schema_version"] >= 3
    assert resolution["targeting_patch"] == "10.5"
    assert resolution["tile_count"] == 10
    assert resolution["movement_range_source"] == "card.move_range"
    assert resolution["combat_start_resources"] == "maximum_minus_start_penalties"
    assert resolution["explicit_player_move_target"] is True
    assert resolution["explicit_player_attack_direction"] is True
    assert set(resolution["enemy_bundles"]) == {"1", "2", "3"}
    for bundle in resolution["enemy_bundles"].values():
        for action in bundle:
            assert action["targeting_mode"] in {"none", "move_tile", "attack_direction"}
            assert int(action["direction"]) in {-1, 0, 1}

    scope = set(contract["presentation_scope"])
    assert {"action_targeting", "action_placement", "resolution_engine"} <= scope
    excluded = set(contract["excluded_until_later_steps"])
    assert {"interruption_focus_fortitude", "combat_ai", "combat_end_restart"} <= excluded

    required_files = [
        "assets/backgrounds/step3_mountain_fortress.svg",
        "scenes/combat/combat_board_preview.tscn",
        "scenes/combat/combat_board_tile.tscn",
        "scenes/ui/action_timing_panel.tscn",
        "scenes/ui/action_timing_slot.tscn",
        "src/combat/combat_board_preview.gd",
        "src/combat/combat_board_tile.gd",
        "src/combat/combat_resolution_engine.gd",
        "src/ui/action_timing_panel.gd",
        "src/ui/action_timing_slot.gd",
        "tests/verify_combat_board.gd",
    ]
    for relative in required_files:
        assert (ROOT / relative).exists(), relative

    tile_script = (ROOT / "src/combat/combat_board_tile.gd").read_text(encoding="utf-8")
    timing_script = (ROOT / "src/ui/action_timing_panel.gd").read_text(encoding="utf-8")
    slot_script = (ROOT / "src/ui/action_timing_slot.gd").read_text(encoding="utf-8")
    engine_script = (ROOT / "src/combat/combat_resolution_engine.gd").read_text(encoding="utf-8")
    controller = (ROOT / "src/combat/combat_board_preview.gd").read_text(encoding="utf-8")
    verifier = (ROOT / "tests/verify_combat_board.gd").read_text(encoding="utf-8")

    assert all(token in tile_script for token in ("signal tile_clicked", "set_interaction_state", "movable", "attackable"))
    assert all(token in timing_script for token in ("set_placement_target", "get_pending_target_anchor", "are_current_bundle_targets_ready", "target_ready"))
    assert all(token in slot_script for token in ("set_target_info", "target_ready", "대상 선택"))
    assert all(token in engine_script for token in ("miss_direction", "target_tile", "selected_direction", "requested_tile", "move_range", "start_penalties", "_prepare_combatant_start"))
    assert all(token in controller for token in ("_begin_targeting_for_anchor", "_on_board_tile_clicked", "set_placement_target", "targeting_enabled", "move_range"))
    assert all(token in verifier for token in ("TARGETING_10_5", "_on_board_tile_clicked", "miss_direction", "basic_footwork"))

    print("combat board STEP 1-10 plus TARGETING 10.5 rule extension contract: PASS")


if __name__ == "__main__":
    main()
