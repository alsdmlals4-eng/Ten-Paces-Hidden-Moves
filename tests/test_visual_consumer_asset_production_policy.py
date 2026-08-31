from __future__ import annotations

import json
from hashlib import sha256
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VISUAL = ROOT / "docs" / "planning-data" / "current_visual_production_handoff_20260826.json"
PLANNING = ROOT / "docs" / "planning-data" / "current_user_planning_status.json"
GATE = ROOT / "docs" / "19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md"
DECISION_ID = "TEN-DEC-20260827-WARM-DUSK-TEN-STEP-VISUAL-DIRECTION-01"
WARM_DUSK_DECISION = ROOT / "docs" / "decisions" / "2026-08-27_WARM_DUSK_TEN_STEP_VISUAL_DIRECTION_DECISION.md"
WARM_DUSK_PLANNING_ANCHOR_DECISION = ROOT / "docs" / "decisions" / "2026-08-28_WARM_DUSK_V2_PLANNING_ANCHOR_DECISION.md"
CORE_SCENE_BOARD_DECISION = ROOT / "docs" / "decisions" / "2026-08-28_CORE_SCENE_VISUAL_BOARD_FINAL_LOCK_CADENCE_DECISION.md"
CORE_SCENE_BOARD_ARTIFACT = ROOT / "docs" / "visual-assets" / "planning" / "PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2.png"
WARM_DUSK_CANDIDATE = ROOT / "docs" / "visual-assets" / "candidates" / "WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID.png"
WARM_DUSK_RECORD = ROOT / "docs" / "visual-assets" / "candidates" / "WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID.md"
SCREEN_AUDIT_OWNER = ROOT / "docs" / "17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md"
SCREEN_VISUAL_INVENTORY = ROOT / "docs" / "planning-data" / "current_screen_visual_coverage_inventory_20260828.json"
MARTIAL_MANUAL_PRESENTATION_DECISION = ROOT / "docs" / "decisions" / "2026-08-30_MARTIAL_MANUAL_TEXT_FIRST_PRESENTATION_DECISION.md"
ACTION_CARD_ILLUSTRATION_EXTENSION_DECISION = ROOT / "docs" / "decisions" / "2026-08-31_ACTION_CARD_ILLUSTRATION_EXTENSION_DECISION.md"
MARTIAL_ULTIMATE_ATLAS_CANDIDATE = ROOT / "docs" / "visual-assets" / "candidates" / "MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png"
MARTIAL_ULTIMATE_ATLAS_RECORD = ROOT / "docs" / "visual-assets" / "candidates" / "MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.md"
MARTIAL_MANUAL_DATA = ROOT / "data" / "cards" / "martial_manuals"


class VisualConsumerAssetProductionPolicyTests(unittest.TestCase):
    def test_current_visual_queue_is_consumer_first_not_explanatory_sheet_first(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        planning = json.loads(PLANNING.read_text(encoding="utf-8"))
        gate = GATE.read_text(encoding="utf-8")

        self.assertEqual(DECISION_ID, visual["current_visual_production_decision"])
        self.assertEqual("ACTUAL_GAME_CONSUMER_REQUIRED", visual["consumer_first_asset_policy"])
        self.assertEqual("USER_APPROVED_AND_IMPLEMENTED_2026_08_27", visual["approved_results"]["OPPONENT_CHARACTER_MASTER_01"]["status"])
        self.assertEqual(
            "PASS_20260826",
            visual["approved_results"]["OPPONENT_CHARACTER_MASTER_01"]["historical_notion_delivery_evidence"],
        )

        battler = visual["approved_results"]["DOGYEOM_COMBAT_BATTLER_01"]
        self.assertEqual("USER_APPROVED_2026_08_26", battler["status"])
        self.assertEqual("PASS_20260826", battler["historical_notion_delivery_evidence"])
        self.assertEqual("res://assets/characters/dogyeom_combat_battler_01_v1.png", battler["runtime_asset"])
        self.assertEqual("src/combat/combat_character_placeholder.gd", battler["consumer"])
        self.assertEqual("AUTOMATED_GODOT_PASS_20260827", battler["opponent_specific_routing"])

        portrait = visual["approved_results"]["DOGYEOM_STATUS_PORTRAIT_01"]
        self.assertEqual("USER_APPROVED_AND_IMPLEMENTED_2026_08_26", portrait["status"])
        self.assertEqual("src/ui/combatant_status_panel.gd", portrait["consumer"])
        self.assertEqual("res://assets/portraits/dogyeom_status_portrait_01_v1.png", portrait["runtime_asset"])
        self.assertEqual("AUTOMATED_GODOT_PASS_20260826", portrait["opponent_specific_routing"])
        self.assertEqual("PROJECT_CORE_SCENE_VISUAL_BOARD", visual["next_result"]["id"])
        self.assertEqual("USER_FINAL_LOCKED_PLANNING_ONLY", visual["next_result"]["generation_status"])
        self.assertEqual("USER_APPROVED_FINAL_LOCKED", visual["next_result"]["final_lock_status"])
        self.assertEqual("SCOPED_BRIEF_THEN_SINGLE_GENERATION_PASS_THEN_FINAL_USER_LOCK", visual["image_production_cadence"]["current_policy"])
        self.assertFalse(visual["image_production_cadence"]["pre_generation_user_approval_required"])
        self.assertTrue(visual["image_production_cadence"]["final_user_lock_required"])
        self.assertEqual(
            "PASS_20260828_VISUAL_BIBLE_ATTACHMENT_AND_FINAL_LOCK_READBACK",
            visual["historical_notion_delivery_evidence"]["project_core_scene_visual_board_delivery"],
        )
        self.assertEqual([], planning["next_visual_batch"])
        self.assertEqual(
            "REPOSITORY_ONLY_GPT_WORK",
            planning["next_execution_surface"],
        )

        serialized_queue = json.dumps(visual.get("deferred_queue_after_result_review", []), ensure_ascii=False)
        self.assertNotIn("MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01", serialized_queue)
        self.assertIn("실제 게임 소비처", gate)
        self.assertIn("DOGYEOM_COMBAT_BATTLER_01", gate)
        self.assertIn("DOGYEOM_STATUS_PORTRAIT_01", gate)
        self.assertIn("src/ui/combatant_status_panel.gd", gate)
        self.assertIn("CardView.illustration", gate)
        self.assertIn("GPT Work", gate)

    def test_warm_dusk_anchor_is_planning_only_with_local_provenance(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        self.assertTrue(WARM_DUSK_DECISION.is_file())
        self.assertTrue(WARM_DUSK_PLANNING_ANCHOR_DECISION.is_file())
        self.assertTrue(WARM_DUSK_CANDIDATE.is_file())
        self.assertTrue(WARM_DUSK_RECORD.is_file())
        self.assertEqual(
            "11281c8f6eb874b3ddd516b38c11cbba269eb6a2d547ce8c36f701c65fd84802",
            sha256(WARM_DUSK_CANDIDATE.read_bytes()).hexdigest(),
        )
        record = WARM_DUSK_RECORD.read_text(encoding="utf-8")
        decision = WARM_DUSK_DECISION.read_text(encoding="utf-8")
        self.assertIn("USER_APPROVED_PLANNING_ANCHOR_ONLY_NON_RUNTIME", record)
        self.assertIn("Notion delivery: `PASS_20260828_VISUAL_BIBLE_PLANNING_ANCHOR_ATTACHMENT_READBACK`", record)
        self.assertIn("Runtime: `NOT_RUN`", record)
        self.assertIn("`src/combat/combat_board_preview.gd`", record)
        self.assertIn("logical ten-space field is not rendered as floor cells", record)
        self.assertIn(DECISION_ID, decision)
        self.assertIn("TEN-DEC-20260828-WARM-DUSK-V2-PLANNING-ANCHOR-01", WARM_DUSK_PLANNING_ANCHOR_DECISION.read_text(encoding="utf-8"))
        self.assertEqual(
            "PROJECT_CORE_SCENE_VISUAL_BOARD",
            visual["next_result"]["id"],
        )
        self.assertTrue(CORE_SCENE_BOARD_DECISION.is_file())
        self.assertIn(
            "TEN-DEC-20260828-CORE-SCENE-VISUAL-BOARD-FINAL-LOCK-CADENCE-01",
            CORE_SCENE_BOARD_DECISION.read_text(encoding="utf-8"),
        )
        self.assertIn("PLANNING_ONLY", CORE_SCENE_BOARD_DECISION.read_text(encoding="utf-8"))
        self.assertIn("NOT_A_RUNTIME_ASSET", CORE_SCENE_BOARD_DECISION.read_text(encoding="utf-8"))
        self.assertIn("USER_FINAL_LOCKED_PLANNING_ONLY", CORE_SCENE_BOARD_DECISION.read_text(encoding="utf-8"))
        self.assertTrue(CORE_SCENE_BOARD_ARTIFACT.is_file())
        self.assertEqual(
            "24fdd3a827ea36ead0364ed35c2a03689c969b4a1444823fa2e5ad94ac93ea33",
            sha256(CORE_SCENE_BOARD_ARTIFACT.read_bytes()).hexdigest(),
        )

    def test_screen_first_audit_keeps_p0_coverage_separate_from_image_generation(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        audit = SCREEN_AUDIT_OWNER.read_text(encoding="utf-8")

        self.assertEqual(0, visual["screen_surface_asset_audit_20260827"]["p0_blocking_gap"])
        self.assertFalse(visual["screen_surface_asset_audit_20260827"]["automatic_image_generation_from_gaps"])
        self.assertEqual(
            "GODOT_UI_TEXT_LAYER_NO_NEW_IMAGE_FILE_REQUIRED",
            visual["screen_surface_asset_audit_20260827"]["noncombat_implementation_mode"],
        )
        for screen_id in [
            "SCREEN_MAIN",
            "SCREEN_SETUP",
            "SCREEN_INTRO",
            "SCREEN_BRIEFING",
            "SCREEN_COMBAT",
            "OVERLAY_REVIEW",
            "SCREEN_RESULT",
            "SCREEN_ROUTE_GROWTH",
            "SCREEN_ROUTE_INFO",
            "SCREEN_COMPLETION",
        ]:
            self.assertIn(screen_id, audit)
        self.assertIn("SCREEN_PAUSE_SETTINGS", audit)
        self.assertIn("NOT_APPLICABLE", audit)
        self.assertIn("CODEX_UI_COPY_CORRECTION_REQUIRED", audit)
        self.assertIn("WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID", audit)
        self.assertIn("VerticalSliceResultShell", audit)
        self.assertIn("VerticalSliceRouteShell", audit)
        self.assertIn("VerticalSliceCompletionShell", audit)
        self.assertNotIn("VerticalSliceShellResultAuto", audit)
        self.assertNotIn("VerticalSliceShellRouteAuto", audit)
        self.assertNotIn("VerticalSliceShellCompletionAuto", audit)
        self.assertIn("src/ui/action_selection/action_choice_card.gd", audit)
        self.assertIn("MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01", audit)
        self.assertIn("tests/verify_vertical_slice_shell.gd", audit)

    def test_current_screen_inventory_maps_actual_consumers_before_production(self) -> None:
        inventory = json.loads(SCREEN_VISUAL_INVENTORY.read_text(encoding="utf-8"))
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))

        self.assertEqual("ACTUAL_GAME_CONSUMER_FIRST", inventory["asset_production_policy"])
        self.assertFalse(inventory["automatic_image_generation_from_inventory_gaps"])
        self.assertEqual(0, inventory["current_p0_runtime_blocking_image_gaps"])
        self.assertEqual("ISSUE_240_MERGED_MAIN_D9AE822", inventory["superseded_handoff_correction"]["status"])
        self.assertEqual("ISSUE_240_MERGED_MAIN_D9AE822", visual["screen_surface_asset_audit_20260827"]["bounded_codex_handoff_status"])
        self.assertEqual(SCREEN_VISUAL_INVENTORY.relative_to(ROOT).as_posix(), visual["screen_surface_asset_audit_20260827"]["canonical_repository_owner"])

        p0_expectations = {
            "SCREEN_MAIN": ("src/run/vertical_slice_shell.gd:VerticalSliceShell._render_current_screen", "COVERED_BY_CODE_RENDERING"),
            "SCREEN_SETUP": ("src/run/vertical_slice_shell.gd:VerticalSliceShell._build_setup_options", "COVERED_BY_CODE_RENDERING"),
            "SCREEN_INTRO": ("src/run/vertical_slice_shell.gd:VerticalSliceShell._render_current_screen", "COVERED_BY_CODE_RENDERING"),
            "SCREEN_BRIEFING": ("src/run/vertical_slice_shell.gd:VerticalSliceShell._render_briefing", "COVERED_BY_CODE_RENDERING"),
            "SCREEN_COMBAT": ("src/combat/combat_board_preview.gd", "COVERED_BY_EXISTING_RUNTIME_ASSETS"),
            "OVERLAY_REVIEW": ("src/ui/combat_review_panel.gd via src/run/vertical_slice_combat_bridge.gd", "COVERED_BY_REUSE"),
            "SCREEN_RESULT": ("src/run/vertical_slice_shell_result_auto.gd:VerticalSliceResultShell", "COVERED_BY_CODE_RENDERING"),
            "SCREEN_ROUTE_GROWTH": ("src/run/vertical_slice_shell_route_auto.gd:VerticalSliceRouteShell", "COVERED_BY_CODE_RENDERING"),
            "SCREEN_ROUTE_INFO": ("src/run/vertical_slice_shell_route_auto.gd:VerticalSliceRouteShell", "COVERED_BY_CODE_RENDERING"),
            "SCREEN_COMPLETION": ("src/run/vertical_slice_shell_completion_auto.gd:VerticalSliceCompletionShell", "COVERED_BY_CODE_RENDERING"),
        }
        p0_rows = [row for row in inventory["screen_inventory"] if row["priority"] == "P0"]
        self.assertEqual(set(p0_expectations), {row["screen_id"] for row in p0_rows})
        self.assertEqual(len(p0_rows), len({row["screen_id"] for row in p0_rows}))
        for row in p0_rows:
            self.assertEqual(p0_expectations[row["screen_id"]], (row["actual_consumer"], row["status"]))

        combat = next(row for row in inventory["screen_inventory"] if row["screen_id"] == "SCREEN_COMBAT")
        self.assertEqual("src/combat/combat_board_preview.gd", combat["actual_consumer"])
        self.assertIn("COMBAT_BACKGROUND_01", combat["runtime_asset_families"])
        self.assertIn("CARD_ICON_ILLUSTRATION", combat["runtime_asset_families"])

        main = next(row for row in inventory["screen_inventory"] if row["screen_id"] == "SCREEN_MAIN")
        self.assertEqual("NO_RUNTIME_IMAGE_REQUIRED", main["image_requirement"])
        self.assertEqual("COVERED_BY_CODE_RENDERING", main["status"])

        release = next(row for row in inventory["screen_inventory"] if row["screen_id"] == "SCREEN_RELEASE_LOADING_ERROR")
        self.assertEqual("NOT_APPLICABLE_CURRENT_VERTICAL_SLICE", release["status"])
        self.assertEqual("RELEASE_BLOCKED_UNVERIFIED", release["release_evidence"])

        failure_retry = next(row for row in inventory["screen_inventory"] if row["screen_id"] == "SCREEN_FAILURE_RETRY")
        self.assertEqual("P0_IMPLEMENTATION_CONTRACT", failure_retry["priority"])
        self.assertEqual("APPROVED_P0_IMPLEMENTATION_REQUIRED", failure_retry["status"])
        self.assertEqual("NO_RUNTIME_IMAGE_REQUIRED", failure_retry["image_requirement"])
        self.assertIn("TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01", failure_retry["evidence"])
        self.assertIn("same-duel SCREEN_COMBAT", failure_retry["entry_exit"])

    def test_martial_and_ultimate_card_illustration_candidate_is_final_lock_gated(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        gate = GATE.read_text(encoding="utf-8")

        self.assertTrue(MARTIAL_MANUAL_PRESENTATION_DECISION.is_file())
        self.assertTrue(ACTION_CARD_ILLUSTRATION_EXTENSION_DECISION.is_file())
        self.assertTrue(MARTIAL_ULTIMATE_ATLAS_CANDIDATE.is_file())
        self.assertTrue(MARTIAL_ULTIMATE_ATLAS_RECORD.is_file())
        self.assertEqual(
            "TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01",
            visual["martial_manual_presentation"]["decision_id"],
        )
        self.assertEqual(
            "TEN-DEC-20260830-MARTIAL-MANUAL-TEXT-FIRST-PRESENTATION-01",
            visual["martial_manual_presentation"]["supersedes_decision_id"],
        )
        self.assertEqual(
            "SHARED_SEMANTIC_CARD_ILLUSTRATION_CANDIDATE_AWAITING_FINAL_LOCK",
            visual["martial_manual_presentation"]["policy"],
        )
        self.assertEqual(
            "GENERATED_CANDIDATE_AWAITING_USER_FINAL_LOCK",
            visual["martial_manual_presentation"]["asset_generation_status"],
        )
        self.assertEqual(
            "CANDIDATE_GENERATED_RUNTIME_UNCHANGED_AWAITING_USER_FINAL_LOCK",
            visual["martial_manual_presentation"]["implementation_status"],
        )
        self.assertEqual(
            "docs/visual-assets/candidates/MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png",
            visual["martial_manual_presentation"]["asset_candidate"]["path"],
        )
        self.assertEqual(
            "CANDIDATE_ONLY_NO_MARTIAL_OR_ULTIMATE_RUNTIME_ILLUSTRATION_UNTIL_SEPARATE_USER_FINAL_LOCK",
            visual["martial_manual_presentation"]["runtime_gate"],
        )
        self.assertIn("공용 삽화 후보 gate", gate)
        self.assertIn("TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01", gate)
        self.assertIn("GENERATED_CANDIDATE_AWAITING_USER_FINAL_LOCK", gate)
        decision = ACTION_CARD_ILLUSTRATION_EXTENSION_DECISION.read_text(encoding="utf-8")
        self.assertIn("ActionChoiceCard", decision)
        self.assertIn("separate explicit final lock", decision)
        record = MARTIAL_ULTIMATE_ATLAS_RECORD.read_text(encoding="utf-8")
        self.assertIn("GENERATED_CANDIDATE_AWAITING_USER_FINAL_LOCK", record)
        self.assertIn("not in `assets/`", record)
        for manual_path in sorted(MARTIAL_MANUAL_DATA.glob("*.json")):
            manual = json.loads(manual_path.read_text(encoding="utf-8"))
            for technique in manual["cards"].values():
                self.assertNotIn(
                    "illustration",
                    technique,
                    f"{manual_path.name}:{technique['id']} remains unmodified until the candidate is final-locked.",
                )

    def test_user_final_lock_routes_martial_and_ultimate_cards_through_the_semantic_atlas(self) -> None:
        """The final user lock supersedes the former text-only martial-card policy."""

        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        runtime_atlas = ROOT / "assets" / "ui" / "cards" / "martial_ultimate_card_illustration_atlas_01_v1.png"
        renderer = ROOT / "src" / "ui" / "action_selection" / "action_choice_card.gd"

        self.assertEqual(
            "SHARED_SEMANTIC_CARD_ILLUSTRATION_USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_RUNTIME_VERIFIED",
            visual["martial_manual_presentation"]["policy"],
        )
        self.assertTrue(runtime_atlas.is_file())
        self.assertTrue(renderer.is_file())
        self.assertIn("semantic_atlas", renderer.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
