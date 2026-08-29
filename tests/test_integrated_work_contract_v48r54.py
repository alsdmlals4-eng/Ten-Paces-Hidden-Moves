from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CURRENT_EXECUTION_DECISION_ID = "TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01"
PRODUCT_SAFETY_BASELINE_ID = "TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01"
CURRENT_VISUAL_PRODUCTION_DECISION_ID = "TEN-DEC-20260827-WARM-DUSK-TEN-STEP-VISUAL-DIRECTION-01"
R2_DECISION_ID = "TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01"
SOURCE_SHA256 = "fdf238c202cfac6d3a824aae49b8ac525fba023e31bba7df6ece64a2790365a0"
BASE_OBSERVED = "edb3b3376603c9f6b00d64af3126304f8c9946bf"
CANONICAL = ROOT / "docs" / "PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"
DECISION = ROOT / "docs" / "decisions" / "2026-08-26_INTEGRATED_WORK_CONTRACT_V4_8_R5_4_BINDING_DECISION.md"
CONTRACT = ROOT / "docs" / "planning-data" / "approved_20260826_integrated_work_contract_v4_8_r5_4_binding.json"
VISUAL = ROOT / "docs" / "planning-data" / "current_visual_production_handoff_20260826.json"
HISTORICAL_VISUAL = "docs/planning-data/current_visual_production_handoff_20260825.json"
PLANNING = ROOT / "docs" / "planning-data" / "current_user_planning_status.json"
VERIFY_SKILL = ROOT / "skills" / "qa" / "ten-paces-verification" / "SKILL.md"
PR_VALIDATION = ROOT / ".github" / "workflows" / "documentation-governance.yml"


class IntegratedWorkContractV48R54Tests(unittest.TestCase):
    def test_repository_only_execution_contract_keeps_r54_product_safety_baseline(self) -> None:
        text = CANONICAL.read_text(encoding="utf-8")
        for marker in (
            "contract_version: '4.8'",
            "revision: '2026-08-26-r5.4-superset-final'",
            f"current_binding_decision: {CURRENT_EXECUTION_DECISION_ID}",
            f"product_safety_baseline: {PRODUCT_SAFETY_BASELINE_ID}",
            f"source_uploaded_sha256: {SOURCE_SHA256}",
            f"base_snapshot_observed_at_binding: {BASE_OBSERVED}",
            "adapter_policy: THIN_ADAPTER_DO_NOT_DUPLICATE_BASE_CANON",
            "fresh_read_bootstrap_policy: PROJECT_GITHUB_REPOSITORY_OWNER_RECONSTRUCTION_REQUIRED",
            "local_codex_policy: RETIRED_NOT_USED",
            "codex_execution_policy: INDEPENDENT_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF_ONLY",
            "powershell_policy: LOCAL_GODOT_OR_VALIDATION_ONLY_NOT_CODEX_LAUNCHER",
            "visual_generation_policy: TEXT_BRIEF_THEN_SCOPED_SINGLE_GENERATION_THEN_USER_FINAL_LOCK",
            "minimum_localization_targets: [ko, en, ja, zh-*]",
            "responsive_target_profiles: [pc_standard, pc_wide_or_ultrawide, mobile_landscape]",
        ):
            self.assertIn(marker, text)
        self.assertNotIn(f"current_binding_decision: {PRODUCT_SAFETY_BASELINE_ID}", text)
        self.assertNotIn(f"current_binding_decision: {R2_DECISION_ID}", text)

    def test_r54_superset_invariants_are_preserved_without_copying_base_procedures(self) -> None:
        text = CANONICAL.read_text(encoding="utf-8")
        for marker in (
            "work_structure_flexibility_policy: FIX_ONLY_TRUE_INVARIANTS_KEEP_COUNTS_TOOLS_AND_MODES_DYNAMIC",
            "legacy_surface_retirement_policy: ABSORB_UNIQUE_VERIFY_DESTINATION_ZERO_ACTIVE_REFERENCES_THEN_SUPERSEDE_HOLD_ARCHIVE_OR_REMOVE",
            "approved_unit_closeout_policy: ADVERSARIAL_REVIEW_REPOSITORY_SYNC_PR_CHECK_MERGE_POSTMERGE_READBACK",
            "primary_work_goal: BEST_LONG_TERM_EFFICIENT_METHOD",
            "world_core_storyline_policy: REQUIRED_WHEN_PROJECT_HAS_WORLD_OR_NARRATIVE",
            "narrative_event_origin_policy: MESSAGE_OR_QUESTION_AND_CHARACTER_BEFORE_EVENT_PRESSURE",
            "entry_state_reconciliation_policy: REQUIRED_BEFORE_MATERIAL_MUTATION",
            "whole_project_audit_policy: REQUIRED_FOR_NEW_PROJECT_MAJOR_GATE_AND_RESTRUCTURE",
            "decision_checkpoint_policy: BOUNDED_DECISION_BATCH_AND_EARLY_CANON_SYNC",
            "decision_screen_comprehension_policy: REQUIRED_FOR_DECISION_BEARING_UI",
            "slice_delivery_policy: PLAYABLE_MEANINGFUL_SLICE_INCREMENTAL_DELIVERY",
            "slice_canonical_reflection_policy: AFTER_PLAY_VERIFICATION_REPOSITORY_STRUCTURED_AND_HUMAN_READBACK",
            "audio_visual_poc_policy: RUNTIME_FEEDBACK_ALIGNMENT_EVIDENCE_REQUIRED_WHEN_PLAYER_PROMISE_DEPENDS_ON_IT",
            "progress_measurement_policy: PLAYABLE_PROGRESS_NOT_DOCUMENT_VOLUME",
            "asset_provenance_policy: SOURCE_RIGHTS_VERSION_TECHNICAL_FIT_APPROVAL_RUNTIME_CONSUMER",
            "shared_audio_reference_policy: REUSE_FIRST_PROVENANCE_AND_PROJECT_OWNED_CONSUMPTION_COPY",
            "one_click_play_policy: RUNNABLE_BY_USER_WHEN_PLAYER_OR_HUMAN_VALIDATION_IS_REQUIRED",
            "ci_supply_chain_policy: CURRENT_REPOSITORY_REQUIRED_CHECKS_AND_IMMUTABLE_ACTION_PINNING_WHEN_APPLICABLE",
            "remote_ci_cost_policy: EXISTING_ZERO_INCREMENTAL_COST_ROUTE_FIRST",
            "skill_absorption_policy: PARTIAL_ABSORPTION_WITH_FUNCTION_LEVEL_VALIDITY_CLASSIFICATION",
            "skill_coverage_policy: CURRENT_REGISTRY_FULL_INVENTORY_TRIGGERED_PROGRESSIVE_LOAD_WITH_EXECUTION_RECEIPT",
            "unreviewed_floating_latest_policy: FORBIDDEN",
            "per_project_dedicated_port_policy: NOT_DEFAULT_EXCEPTION_ONLY",
            "local_godot_editor_policy: OPEN_OR_REUSE_EXACT_EDITOR_BEFORE_GODOT_AUTHORING_RUNTIME",
        ):
            self.assertIn(marker, text)
        for invariant in (
            "WHOLE_PROJECT_AUDIT_FIRST",
            "PLAYABLE_SLICE_BOUNDARY",
            "CANONICAL_REFLECTION_AFTER_PLAY",
            "AUDIO_VISUAL_POC_EVIDENCE",
            "DECISION_SCREEN_COMPREHENSION_GATE",
            "FUNCTION_LEVEL_VALIDITY_CLASSIFICATION",
            "ASSET_PROVENANCE_AND_GODOT_IMPORT_GATE",
            "RUNNABLE_BY_USER_ONE_CLICK_PROJECT_PLAY_GATE",
        ):
            self.assertIn(invariant, text)

    def test_binding_record_preserves_evidence_ceiling_and_history(self) -> None:
        self.assertTrue(DECISION.is_file())
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(PRODUCT_SAFETY_BASELINE_ID, payload["decision_id"])
        self.assertEqual(R2_DECISION_ID, payload["supersedes_decision_id"])
        self.assertEqual(SOURCE_SHA256, payload["source_uploaded_sha256"])
        self.assertEqual(BASE_OBSERVED, payload["base_observed_main"])
        self.assertFalse(payload["fresh_read"]["past_conversation_required"])
        self.assertEqual("MIGRATION_ONLY_UNTIL_REMOVAL", payload["authority"]["google_sheets"])
        self.assertEqual("NOT_RUN", payload["evidence_ceiling"]["windows_visible_human"])
        self.assertEqual("NOT_RUN", payload["evidence_ceiling"]["player_experience"])

    def test_current_cold_start_routes_to_repository_only_execution_contract(self) -> None:
        for relative in (
            "AGENTS.md",
            "START_HERE.md",
            "[기획서]/00_프로젝트_허브/START_HERE.md",
            "docs/BASE_RULES_VERSION.md",
        ):
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn(CURRENT_EXECUTION_DECISION_ID, text, relative)
            self.assertIn("MIGRATION_ONLY_UNTIL_REMOVAL", text, relative)
        root_start = (ROOT / "START_HERE.md").read_text(encoding="utf-8")
        self.assertIn("current_work_contract: " + CURRENT_EXECUTION_DECISION_ID, root_start)
        self.assertIn("docs/planning-data/current_visual_production_handoff_20260826.json", root_start)
        self.assertIn(HISTORICAL_VISUAL + "`은", root_start)
        current_visual_sentence = root_start.split("현재 승인 Visual과 다음 제작 대상은", 1)[1].split("## Work Mode", 1)[0]
        self.assertIn("repository Visual/asset owner", current_visual_sentence)
        self.assertNotIn("exact Project Notion", current_visual_sentence)

    def test_active_verification_skill_does_not_restore_retired_local_codex_route(self) -> None:
        text = VERIFY_SKILL.read_text(encoding="utf-8")
        self.assertIn("local-godot-validation-readiness", text)
        self.assertIn("CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF", text)
        self.assertIn("시작 공개 거리 2", text)
        self.assertIn("현재 기초 행동 정본은 10종", text)
        for stale_current_marker in (
            "local-executor-readiness",
            "DEDICATED_GODOT:",
            "HIGODOT_HTTP_8003:",
            "HIGODOT_WS_9503:",
            "전장 10칸·4/7·거리 3",
            "기초 행동 8종·절초 3종",
        ):
            self.assertNotIn(stale_current_marker, text)

    def test_retired_local_codex_launcher_is_not_an_active_ci_consumer(self) -> None:
        workflow = PR_VALIDATION.read_text(encoding="utf-8")
        self.assertNotIn("tests.test_local_executor_bootstrap_contract", workflow)
        self.assertNotIn('"tools/start_ten_paces_local_executor.ps1"', workflow)
        self.assertIn("tests.test_local_executor_handoff_contract", workflow)

    def test_current_visual_production_is_scoped_generation_then_final_lock(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        planning = json.loads(PLANNING.read_text(encoding="utf-8"))
        self.assertEqual(
            "SCOPED_BRIEF_THEN_SINGLE_GENERATION_PASS_THEN_FINAL_USER_LOCK",
            visual["image_production_cadence"]["current_policy"],
        )
        self.assertFalse(visual["image_production_cadence"]["pre_generation_user_approval_required"])
        self.assertEqual(1, visual["image_production_cadence"]["max_initial_candidates_per_scoped_task"])
        self.assertTrue(visual["image_production_cadence"]["final_user_lock_required"])
        self.assertTrue(visual["image_production_cadence"]["automatic_next_result_forbidden"])
        self.assertEqual(CURRENT_VISUAL_PRODUCTION_DECISION_ID, visual["current_visual_production_decision"])
        self.assertEqual("ACTUAL_GAME_CONSUMER_REQUIRED", visual["consumer_first_asset_policy"])
        master = visual["approved_results"]["OPPONENT_CHARACTER_MASTER_01"]
        self.assertEqual("USER_APPROVED_AND_IMPLEMENTED_2026_08_27", master["status"])
        self.assertEqual("PASS_20260826", master["historical_notion_delivery_evidence"])
        self.assertFalse(master["runtime_asset"])
        battler = visual["approved_results"]["DOGYEOM_COMBAT_BATTLER_01"]
        self.assertEqual("USER_APPROVED_2026_08_26", battler["status"])
        self.assertEqual("PASS_20260826", battler["historical_notion_delivery_evidence"])
        self.assertEqual("res://assets/characters/dogyeom_combat_battler_01_v1.png", battler["runtime_asset"])
        self.assertEqual("AUTOMATED_GODOT_PASS_20260827", battler["opponent_specific_routing"])
        portrait = visual["approved_results"]["DOGYEOM_STATUS_PORTRAIT_01"]
        self.assertEqual("USER_APPROVED_AND_IMPLEMENTED_2026_08_26", portrait["status"])
        self.assertEqual("res://assets/portraits/dogyeom_status_portrait_01_v1.png", portrait["runtime_asset"])
        self.assertEqual("AUTOMATED_GODOT_PASS_20260826", portrait["opponent_specific_routing"])
        self.assertEqual("PROJECT_CORE_SCENE_VISUAL_BOARD", visual["next_result"]["id"])
        self.assertEqual("USER_FINAL_LOCKED_PLANNING_ONLY", visual["next_result"]["generation_status"])
        self.assertEqual("USER_APPROVED_FINAL_LOCKED", visual["next_result"]["final_lock_status"])
        self.assertEqual([], planning["next_visual_batch"])
        self.assertEqual("NONE_CURRENT_BOARD_USER_FINAL_LOCKED_NO_AUTOMATIC_NEXT", planning["next_image_generation"])
        self.assertEqual(
            "REPOSITORY_ONLY_GPT_WORK",
            planning["next_execution_surface"],
        )
        self.assertEqual("docs/planning-data/current_visual_production_handoff_20260826.json", planning["visual_reference_state"])
        serialized_queue = json.dumps(visual.get("deferred_queue_after_result_review", []), ensure_ascii=False)
        self.assertNotIn("MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01", serialized_queue)


if __name__ == "__main__":
    unittest.main()
