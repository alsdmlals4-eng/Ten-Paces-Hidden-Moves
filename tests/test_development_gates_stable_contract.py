from __future__ import annotations

import json
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
        self.assertIn("current_sheet_authority: GOOGLE_SHEET_00_02_04_99", section)
        self.assertIn("gate_document_semantics: CONDITIONS_ONLY", section)
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
        self.assertIn("image_generation_gate: AFTER_REVIEW_COMPLETE", visual)
        self.assertIn("VISUAL_COMPLETE_OR_NO_NEW_ASSET_REQUIRED", visual)
        self.assertNotIn("현재 판정:", visual)

    def test_build_gate_uses_conditional_visual_state_and_explicit_user_approval(self) -> None:
        build = self.text.split("## 9. G6", 1)[1].split("## 10. G7", 1)[0]
        self.assertIn("PLANNING_COMPLETE", build)
        self.assertIn("REVIEW_COMPLETE", build)
        self.assertIn("VISUAL_COMPLETE_OR_NO_NEW_ASSET_REQUIRED", build)
        self.assertIn("사용자 명시 Build 승인", build)
        self.assertNotIn("G3·G4·G5 완료", build)
        self.assertNotIn("현재 판정:", build)

    def test_mutable_gate_verdicts_are_not_duplicated_in_stable_document(self) -> None:
        for token in (
            "현재 판정: `NOT_COMPLETE`",
            "현재 판정: `BLOCKED_BY_G3`",
            "현재 판정: `BLOCKED_BY_G4`",
            "현재 판정: `NOT_GRANTED`",
        ):
            self.assertNotIn(token, self.text)
        self.assertIn("historical_evidence_snapshot: TEN_MANUAL_AUTOMATED_PRODUCT_VALIDATION", self.text)

    def test_base_reuse_adoption_manifest_is_planning_only(self) -> None:
        manifest = json.loads((ROOT / "docs/base-reuse-adoption.json").read_text(encoding="utf-8"))
        self.assertEqual(
            {
                "schema_version": 1,
                "base_source_commit": "8553678f70e22f193a2336b591f677dcfa5a8965",
                "modules": {
                    "RM-TOOL-001": {"state": "planned"},
                    "RM-SYS-001": {"state": "not_applicable"},
                    "RM-SYS-003": {"state": "not_applicable"},
                    "RM-VIS-001": {"state": "planned"},
                    "RM-VIS-002": {"state": "planned"},
                },
            },
            manifest,
        )
        adapter = json.loads((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_text(encoding="utf-8"))
        self.assertEqual(
            ["data/", "src/", "scenes/", "assets/", "addons/", "project.godot"],
            adapter["protected_paths"],
        )


if __name__ == "__main__":
    unittest.main()
