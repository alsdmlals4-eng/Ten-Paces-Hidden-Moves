from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GATES = ROOT / "[기획서]" / "00_프로젝트_허브" / "DEVELOPMENT_GATES.md"


class DevelopmentGatesStableContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.text = GATES.read_text(encoding="utf-8")

    def test_current_state_is_routed_to_live_authorities_not_snapshot_here(self) -> None:
        section = self.text.split("## 2. 현재 게이트", 1)[1].split("## 3. G0", 1)[0]
        self.assertIn("current_state_owner: ACTIVE_CONTEXT", section)
        self.assertIn("current_pr_authority: GITHUB_PR_METADATA", section)
        self.assertIn("current_human_workspace: EXACT_PROJECT_NOTION", section)
        self.assertIn("current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME", section)
        self.assertIn("google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL", section)
        self.assertIn("gate_document_semantics: CONDITIONS_ONLY", section)
        self.assertNotIn("current_sheet_authority", section)
        for mutable in (
            "product_stage:",
            "runtime_work_mode:",
            "runtime_integration_pr:",
            "planning_work_mode:",
            "runtime_implementation:",
            "next_package:",
            "human_validation:",
            "t1_greenlight:",
        ):
            self.assertNotIn(mutable, section, mutable)

    def test_planning_and_review_completion_do_not_require_generated_images(self) -> None:
        visual = self.text.split("## 8. G5", 1)[1].split("## 9. G6", 1)[0]
        self.assertIn("PLANNING_COMPLETE does not require generated images", visual)
        self.assertIn("REVIEW_COMPLETE does not require generated images", visual)
        self.assertIn("image_generation_requires_explicit_user_request: true", visual)
        self.assertIn("APPROVED_ASSET_OR_NO_NEW_ASSET_REQUIRED", visual)
        self.assertNotIn("현재 판정:", visual)

    def test_future_build_gate_requires_current_scope_and_explicit_user_approval(self) -> None:
        build = self.text.split("## 9. G6", 1)[1].split("## 10. G7", 1)[0]
        self.assertIn("Phase I–VI", build)
        self.assertIn("current user request", build)
        self.assertIn("사용자 명시 Build 승인", build)
        self.assertIn("RED→GREEN", build)
        self.assertNotIn("VERTICAL_SLICE_APP_FLOW_SHELL", build)
        self.assertNotIn("현재 판정:", build)

    def test_sheet_is_only_migration_compatibility(self) -> None:
        self.assertIn("MIGRATION_ONLY_UNTIL_REMOVAL", self.text)
        self.assertNotIn("current_sheet_authority: GOOGLE_SHEET_00_02_04_99", self.text)
        self.assertNotIn("GitHub/Sheet readback", self.text)
        self.assertIn("Notion", self.text)


if __name__ == "__main__":
    unittest.main()
