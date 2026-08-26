from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CURRENT_DECISION_ID = "TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01"
R2_DECISION_ID = "TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01"
SOURCE_SHA256 = "fdf238c202cfac6d3a824aae49b8ac525fba023e31bba7df6ece64a2790365a0"
BASE_OBSERVED = "edb3b3376603c9f6b00d64af3126304f8c9946bf"
CANONICAL = ROOT / "docs" / "PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"
DECISION = ROOT / "docs" / "decisions" / "2026-08-26_INTEGRATED_WORK_CONTRACT_V4_8_R5_4_BINDING_DECISION.md"
CONTRACT = ROOT / "docs" / "planning-data" / "approved_20260826_integrated_work_contract_v4_8_r5_4_binding.json"
VISUAL = ROOT / "docs" / "planning-data" / "current_visual_production_handoff_20260826.json"
PLANNING = ROOT / "docs" / "planning-data" / "current_user_planning_status.json"
VERIFY_SKILL = ROOT / "skills" / "qa" / "ten-paces-verification" / "SKILL.md"


class IntegratedWorkContractV48R54Tests(unittest.TestCase):
    def test_r54_is_current_project_operating_contract(self) -> None:
        text = CANONICAL.read_text(encoding="utf-8")
        for marker in (
            "contract_version: '4.8'",
            "revision: '2026-08-26-r5.4-superset-final'",
            f"current_binding_decision: {CURRENT_DECISION_ID}",
            f"source_uploaded_sha256: {SOURCE_SHA256}",
            f"base_snapshot_observed_at_binding: {BASE_OBSERVED}",
            "adapter_policy: THIN_ADAPTER_DO_NOT_DUPLICATE_BASE_CANON",
            "fresh_read_bootstrap_policy: PROJECT_GITHUB_NOTION_ONLY_RECONSTRUCTION_REQUIRED",
            "local_codex_policy: RETIRED_NOT_USED",
            "codex_execution_policy: INDEPENDENT_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF_ONLY",
            "powershell_policy: LOCAL_GODOT_OR_VALIDATION_ONLY_NOT_CODEX_LAUNCHER",
            "visual_generation_policy: TEXT_BRIEF_THEN_EXPLICIT_USER_APPROVAL_THEN_EXACTLY_ONE_RESULT",
            "minimum_localization_targets: [ko, en, ja, zh-*]",
            "responsive_target_profiles: [pc_standard, pc_wide_or_ultrawide, mobile_landscape]",
        ):
            self.assertIn(marker, text)
        self.assertNotIn(f"current_binding_decision: {R2_DECISION_ID}", text)

    def test_binding_record_preserves_evidence_ceiling_and_history(self) -> None:
        self.assertTrue(DECISION.is_file())
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(CURRENT_DECISION_ID, payload["decision_id"])
        self.assertEqual(R2_DECISION_ID, payload["supersedes_decision_id"])
        self.assertEqual(SOURCE_SHA256, payload["source_uploaded_sha256"])
        self.assertEqual(BASE_OBSERVED, payload["base_observed_main"])
        self.assertFalse(payload["fresh_read"]["past_conversation_required"])
        self.assertEqual("MIGRATION_ONLY_UNTIL_REMOVAL", payload["authority"]["google_sheets"])
        self.assertEqual("NOT_RUN", payload["evidence_ceiling"]["windows_visible_human"])
        self.assertEqual("NOT_RUN", payload["evidence_ceiling"]["player_experience"])

    def test_current_cold_start_routes_to_r54(self) -> None:
        for relative in (
            "AGENTS.md",
            "START_HERE.md",
            "[기획서]/00_프로젝트_허브/START_HERE.md",
            "docs/BASE_RULES_VERSION.md",
        ):
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn(CURRENT_DECISION_ID, text, relative)
            self.assertIn("MIGRATION_ONLY_UNTIL_REMOVAL", text, relative)
        self.assertIn("current_work_contract: " + CURRENT_DECISION_ID, (ROOT / "START_HERE.md").read_text(encoding="utf-8"))

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

    def test_current_visual_production_is_exactly_one(self) -> None:
        visual = json.loads(VISUAL.read_text(encoding="utf-8"))
        planning = json.loads(PLANNING.read_text(encoding="utf-8"))
        self.assertEqual(1, visual["image_production_cadence"]["max_results_per_explicit_approval"])
        self.assertTrue(visual["image_production_cadence"]["automatic_next_result_forbidden"])
        self.assertEqual("OPPONENT_CHARACTER_MASTER_01", visual["next_result"]["id"])
        self.assertEqual("WAITING_EXPLICIT_USER_GENERATION_APPROVAL", visual["next_result"]["generation_status"])
        self.assertEqual(["OPPONENT_CHARACTER_MASTER_01"], planning["next_visual_batch"])
        self.assertEqual("READY_FOR_EXPLICIT_SINGLE_IMAGE", planning["next_image_generation"])
        self.assertEqual("docs/planning-data/current_visual_production_handoff_20260826.json", planning["visual_reference_state"])


if __name__ == "__main__":
    unittest.main()
