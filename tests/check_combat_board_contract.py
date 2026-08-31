from __future__ import annotations

import json
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEXT_SUFFIXES = {".gd", ".tscn", ".py", ".ps1", ".cmd", ".md", ".json", ".yml", ".yaml", ".godot"}
EXPECTED_PLAYER_TILE = 4
EXPECTED_ENEMY_TILE = 6
EXPECTED_CARD_IDS = [
    "basic_move",
    "basic_footwork",
    "basic_guard",
    "basic_evade",
    "basic_quick_attack",
    "basic_heavy_attack",
    "basic_observe",
    "basic_meditate",
    "basic_stance",
    "basic_palm",
]


def load_json(relative: str) -> dict:
    return json.loads((ROOT / relative).read_text(encoding="utf-8"))


def res_file(value: str) -> Path:
    assert value.startswith("res://")
    return ROOT / value.removeprefix("res://")


def find_conflict_markers(text: str) -> list[tuple[int, str]]:
    markers: list[tuple[int, str]] = []
    in_conflict = False
    for line_number, line in enumerate(text.splitlines(), start=1):
        if line.startswith("<<<<<<<"):
            markers.append((line_number, line))
            in_conflict = True
        elif line.startswith("=======") and in_conflict:
            markers.append((line_number, line))
        elif line.startswith(">>>>>>>"):
            markers.append((line_number, line))
            in_conflict = False
    return markers


def assert_no_conflict_markers() -> None:
    failures: list[str] = []
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in TEXT_SUFFIXES:
            continue
        if ".git" in path.parts or ".godot" in path.parts:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for line_number, line in find_conflict_markers(text):
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

    assert contract["basic_action_cards"]["card_count"] == 10
    assert contract["basic_action_cards"]["card_ids"] == EXPECTED_CARD_IDS
    assert contract["basic_action_cards"]["stance_response_combo_enabled"] is True
    assert contract["basic_action_cards"]["card_surface"] == "shared_action_card_grid"
    assert contract["basic_action_cards"]["illustration_policy"] == "basic_atlas_only"
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
    assert by_id["basic_heavy_attack"]["range"] == {"min": 1, "max": 2}
    assert by_id["basic_heavy_attack"]["internal_cost"] == 2
    assert by_id["basic_observe"]["player_only"] is True
    assert by_id["basic_palm"]["range"] == {"min": 1, "max": 3}
    assert "50%" in by_id["basic_guard"]["effect_text"]
    assert "완전히 회피" in by_id["basic_evade"]["effect_text"]
    assert "다음" in by_id["basic_stance"]["effect_text"]

    targeting = contract["action_targeting"]
    assert targeting["patch"] == "10.7"
    assert targeting["surface"] == "semantic_intent_cards"
    assert targeting["move_mode"] == "semantic_intent_cards"
    assert targeting["move_range_source"] == "card.move_range"
    assert targeting["basic_move_range"] == 1
    assert targeting["footwork_move_range"] == 2
    assert targeting["footwork_distance_choice"] == [1, 2]
    assert targeting["move_intents"] == ["approach", "retreat"]
    assert targeting["attack_mode"] == "semantic_aim_cards"
    assert targeting["attack_intents"] == ["aim_opponent", "predict_away"]
    assert targeting["heavy_attack_range"] == 2
    assert targeting["heavy_attack_hits_distances"] == [1, 2]
    assert targeting["attack_range_tiles_are_clickable"] is False
    assert targeting["logical_board_visible_during_selection"] is False
    assert targeting["tile_states"] == ["hidden"]
    assert targeting["shape_and_text_fallback"] is True
    assert targeting["unresolved_target_blocks_progress"] is True
    assert targeting["resolution_uses_semantic_intent"] is True

    response = contract["response_rules"]
    assert response["patch"] == "10.6"
    assert response["guard_same_timing"] == "subtract_guard_then_halve_damage"
    assert response["guard_same_bundle"] == "reduce_by_guard_block"
    assert response["guard_comparison"] == "ordered_compound_reduction"
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
    assert {asset["id"] for asset in active_assets} == {
        "frontal_courtyard_duel_background_01_v1",
        "player_wanderer_ink_v1",
        "enemy_masked_ink_v1",
        "dogyeom_status_portrait_01_v1",
        "player_wanderer_battler_rgba_v1",
        "enemy_masked_battler_rgba_v1",
        "dogyeom_combat_battler_01_v1",
        "basic_technique_ink_atlas_01_v1",
        "martial_ultimate_card_illustration_atlas_01_v1",
        "ten_paces_hidden_moves_title_logo_01_v1",
        "attack_clash_ink_gold_atlas_01_v1",
        "ultimate_ink_gold_sprite_sheet_rgba",
    }
    for asset in active_assets:
        assert res_file(asset["path"]).exists(), asset["path"]
        assert asset.get("prompt") or asset.get("source_png_sha256"), asset["id"]
        assert asset.get("license", asset_manifest.get("license", ""))
    battle_background = next(asset for asset in active_assets if asset["id"] == "frontal_courtyard_duel_background_01_v1")
    assert battle_background["source_asset"] == "docs/visual-assets/approved/FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1.png"
    assert battle_background["runtime_consumer"] == "src/combat/battle_background.gd"
    assert battle_background["replaces_active_asset"] == "ink_mist_valley_duel_01_v1"
    canonical_source = ROOT / battle_background["source_asset"]
    assert canonical_source.exists()
    assert hashlib.sha256(canonical_source.read_bytes()).hexdigest() == battle_background["source_png_sha256"]
    assert hashlib.sha256(res_file(battle_background["path"]).read_bytes()).hexdigest() == battle_background["source_png_sha256"]
    assert all(asset["id"] not in {"twilight_ink_duel_v1", "ink_mist_valley_duel_01_v1"} for asset in asset_manifest["assets"])
    semantic_atlas = next(asset for asset in active_assets if asset["id"] == "martial_ultimate_card_illustration_atlas_01_v1")
    assert semantic_atlas["source_asset"] == "docs/visual-assets/approved/MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png"
    assert "ActionViewModelAdapter" in semantic_atlas["runtime_consumer"]
    semantic_atlas_source = ROOT / semantic_atlas["source_asset"]
    assert semantic_atlas_source.exists()
    assert hashlib.sha256(semantic_atlas_source.read_bytes()).hexdigest() == semantic_atlas["source_png_sha256"]
    assert hashlib.sha256(res_file(semantic_atlas["path"]).read_bytes()).hexdigest() == semantic_atlas["source_png_sha256"]
    ultimate_vfx = next(asset for asset in active_assets if asset["id"] == "ultimate_ink_gold_sprite_sheet_rgba")
    assert ultimate_vfx["transparency_audit"]["has_alpha"] is True
    assert ultimate_vfx["transparency_audit"]["status"] == "APPROVED_ACTIVE"
    title_logo = next(asset for asset in active_assets if asset["id"] == "ten_paces_hidden_moves_title_logo_01_v1")
    assert title_logo["source_asset"] == "docs/visual-assets/approved/TEN_PACES_HIDDEN_MOVES_TITLE_LOGO_01_v1.png"
    assert title_logo["runtime_consumer"] == "MainTitleScreen in src/ui/main_title_screen.gd"
    assert title_logo["transparency_audit"]["alpha_extrema"] == [0, 255]
    title_logo_source = ROOT / title_logo["source_asset"]
    assert title_logo_source.exists()
    assert hashlib.sha256(title_logo_source.read_bytes()).hexdigest() == title_logo["source_png_sha256"]
    assert hashlib.sha256(res_file(title_logo["path"]).read_bytes()).hexdigest() == title_logo["source_png_sha256"]
    attack_clash_vfx = next(asset for asset in active_assets if asset["id"] == "attack_clash_ink_gold_atlas_01_v1")
    assert attack_clash_vfx["source_asset"] == "docs/visual-assets/approved/ATTACK_CLASH_INK_GOLD_ATLAS_01_v1.png"
    assert "CombatBoardPreview._show_feedback_vfx" in attack_clash_vfx["runtime_consumer"]
    assert attack_clash_vfx["source_alpha_audit"]["status"] == "OPAQUE_SOURCE_RUNTIME_MATTE_REQUIRED"
    assert "ShaderMaterial" in attack_clash_vfx["runtime_matte"]
    attack_clash_source = ROOT / attack_clash_vfx["source_asset"]
    assert attack_clash_source.exists()
    assert hashlib.sha256(attack_clash_source.read_bytes()).hexdigest() == attack_clash_vfx["source_png_sha256"]
    assert hashlib.sha256(res_file(attack_clash_vfx["path"]).read_bytes()).hexdigest() == attack_clash_vfx["source_png_sha256"]
    for asset_id in ("player_wanderer_battler_rgba_v1", "dogyeom_combat_battler_01_v1", "enemy_masked_battler_rgba_v1"):
        character_art = next(asset for asset in active_assets if asset["id"] == asset_id)
        audit = character_art["transparency_audit"]
        assert character_art.get("source_asset") or character_art.get("source_png_sha256")
        assert audit["has_alpha"] is True
        assert audit["alpha_extrema"] == [0, 255]
        assert audit["corner_alpha"] == [0, 0, 0, 0]
        assert audit["status"] == "APPROVED_ACTIVE"
    assert ultimate["requires_exact_momentum"] is True
    assert ultimate["reservation_consumes_momentum_immediately"] is True
    assert ultimate["reservation_cancellation_refund_before_progress"] is True
    assert ultimate["reservation_refund_after_progress"] is False
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
    assert "필중" in next(card for card in ultimate_cards["cards"] if card["id"] == "ultimate_void_sword_qi")["tags"]

    resolution_contract = contract["resolution_engine"]
    assert resolution_contract["resolution_order"] == ["response", "quick_attack", "move", "general"]
    assert resolution_contract["same_phase_attacks"] == "simultaneous_damage"
    assert resolution_contract["uses_semantic_move_intent"] is True
    assert resolution_contract["uses_semantic_aim_intent"] is True
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

    assert resolution["schema_version"] >= 7
    assert resolution["targeting_patch"] == "10.5"
    assert resolution["tile_count"] == 10
    assert resolution["movement_range_source"] == "card.move_range"
    assert resolution["combat_start_resources"] == "maximum_minus_start_penalties"
    assert resolution["guard_same_timing_damage_multiplier"] == 0.5
    assert resolution["guard_bundle_mode"] == "fixed_block"
    assert resolution["guard_resolution_order"] == ["subtract_guard_block", "halve_if_same_timing"]
    assert resolution["clash_same_timing_attacks"] is True
    assert resolution["clash_damage_uses_defense"] is True
    assert resolution["evade_same_timing_full"] is True
    assert resolution["stance_response_bundle_extension"] is True
    assert resolution["stance_response_defense_multiplier"] == 1.5
    assert resolution["placement_resource_preview"] is True
    assert resolution["semantic_player_move_intent"] is True
    assert resolution["semantic_player_aim_intent"] is True
    assert resolution["damage_interrupts_current_timing_actions"] is True
    assert resolution["bundle_momentum_gain"] == 1
    assert resolution["guard_success_momentum_gain"] == 1
    assert resolution["evade_success_momentum_gain"] == 1
    assert resolution["clash_win_momentum_gain"] == 1
    assert resolution["fortitude_quick_phase_one_slot_only"] is True
    assert resolution["same_tile_engagement"] is True
    assert resolution["same_tile_max_combatants"] == 2
    assert resolution["enemy_plan_source"] == "public_state_ai"
    assert resolution["enemy_bundles"] == {}
    assert contract["ultimate_skills"]["selection_trigger"] == "action_source_tab"
    assert contract["ultimate_skills"]["list_visible_during_planning"] is True

    scope = set(contract["presentation_scope"])
    assert {"basic_action_cards", "action_targeting", "action_placement", "response_rules", "resolution_engine", "distance_readout"} <= scope
    excluded = set(contract["excluded_until_later_steps"])
    assert "combat_ai" not in excluded and "combat_end_restart" not in excluded

    required_files = [
        "assets/backgrounds/frontal_courtyard_duel_background_01_v1.png",
        "assets/characters/player_wanderer_battler_rgba_v1.png",
        "assets/characters/dogyeom_combat_battler_01_v1.png",
        "assets/characters/enemy_masked_battler_rgba_v1.png",
        "assets/ui/cards/basic_technique_ink_atlas_01_v1.png",
        "assets/reference/step_02_character_scale_and_tile_placement.svg",
        "scenes/combat/combat_board_preview.tscn",
        "scenes/combat/combat_board_tile.tscn",
        "scenes/ui/action_timing_panel.tscn",
        "scenes/ui/action_timing_slot.tscn",
        "src/combat/combat_board_preview.gd",
        "src/combat/combat_board_tile.gd",
        "src/combat/combat_resolution_engine.gd",
        "src/combat/combat_ai_planner.gd",
        "src/ui/combat_action_reveal_overlay.gd",
        "src/ui/action_timing_panel.gd",
        "src/ui/action_timing_slot.gd",
        "src/ui/basic_card_tray.gd",
        "tests/verify_combat_board.gd",
        "tests/verify_response_rules.gd",
        "tests/verify_clash_guard_sure_hit.gd",
        "tests/verify_step12_13_restart_ai.gd",
        "tests/verify_ultimate_interrupt_engagement.gd",
        "tests/verify_ultimate_ui.gd",
        "tests/verify_combat_character_art.gd",
        "tests/verify_combat_focus_visuals.gd",
        "tests/verify_combat_focus_order.gd",
        "tests/verify_combat_assistive_labels.gd",
        "tests/verify_combat_pointer_lock.gd",
        "tests/verify_combat_presentation_controls.gd",
        "tests/verify_frontal_duel_assets.gd",
        "tests/verify_combat_action_reveal.gd",
        "tests/verify_combat_keyboard_accessibility.gd",
        "tests/verify_combat_layout_accessibility.gd",
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
    character_script = (ROOT / "src/combat/combat_character_placeholder.gd").read_text(encoding="utf-8")
    action_reveal_script = (ROOT / "src/ui/combat_action_reveal_overlay.gd").read_text(encoding="utf-8")
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
        "var _enemy_tile := 6",
        'contract.get("player_start_tile", 4)',
        'contract.get("enemy_start_tile", 6)',
        "UltimateMenu",
        "_refund_ultimate_reservation",
        "presentation_state",
        "CombatActionRevealOverlay",
        "_present_timing_duel",
        "action_reveal_snapshot",
    ))
    assert all(token in character_script for token in (
        "player_wanderer_battler_rgba_v1.png",
        "dogyeom_combat_battler_01_v1.png",
        "enemy_masked_battler_rgba_v1.png",
        "get_render_texture",
        "character_art_path",
    ))
    assert "_apply_keyboard_focus_ring" in controller
    assert "keyboard_focus_ring" in controller
    assert "_wait_for_presentation_delay" in controller
    assert "_configure_keyboard_focus_order" in controller
    assert "_configure_accessibility_semantics" in controller
    assert all(token in action_reveal_script for token in ("show_timing", "future_action_visible", "_actor_events", "VS"))
    assert all(token in verifier for token in ("TARGETING_10_5", "_on_product_intent_selected", "miss_direction", "basic_footwork", "EXPECTED_PLAYER_TILE := 4", "EXPECTED_ENEMY_TILE := 6"))
    assert all(token in response_verifier for token in ("Same-timing guard", "Stance+guard", "Stance+evade", "preview_player_plan", "invalid_anchors"))
    assert "res://tests/verify_response_rules.gd" in powershell
    assert "res://tests/verify_combat_pointer_lock.gd" in powershell
    assert "res://tests/verify_combat_presentation_controls.gd" in powershell
    assert "res://tests/verify_combat_focus_order.gd" in powershell
    assert "res://tests/verify_combat_assistive_labels.gd" in powershell
    assert "OpponentHypothesisPanel" not in controller
    assert "SkipPresentationButton" not in controller
    assert "플레이어 4번 / 상대 7번" in reference_svg  # historical visual reference; not runtime authority
    assert "플레이어 · 4번 칸" in reference_svg
    assert "상대 · 7번 칸" in reference_svg
    assert "플레이어 3번 / 상대 8번" not in reference_svg

    print("combat board STEP 1-10.6 contract with current start tiles 4 and 6: PASS")


if __name__ == "__main__":
    main()
