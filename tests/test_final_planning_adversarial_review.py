from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
JSON_PATH = ROOT / "docs/planning-data/final_planning_adversarial_review_20260811.json"
MD_PATH = ROOT / "docs/reviews/2026-08-11_FINAL_PLANNING_ADVERSARIAL_REVIEW.md"


class FinalPlanningAdversarialReviewTests(unittest.TestCase):
    def setUp(self) -> None:
        self.assertTrue(JSON_PATH.is_file(), f"missing final review JSON: {JSON_PATH}")
        self.assertTrue(MD_PATH.is_file(), f"missing final review report: {MD_PATH}")
        self.data = json.loads(JSON_PATH.read_text(encoding="utf-8"))
        self.report = MD_PATH.read_text(encoding="utf-8")

    def test_user_declaration_enters_phase_b_without_opening_build_or_images(self) -> None:
        self.assertEqual("FINAL_PLANNING_REVIEW", self.data["phase"])
        self.assertTrue(self.data["user_planning_complete_declared"])
        self.assertFalse(self.data["review_complete"])
        self.assertFalse(self.data["product_implementation_authorized"])
        self.assertFalse(self.data["image_generation_allowed"])
        self.assertIn("REVIEW_COMPLETE", self.data["image_generation_gate"])

    def test_fresh_authority_and_external_process_evidence_are_recorded(self) -> None:
        authority = self.data["fresh_authority"]
        self.assertEqual("b9a9db62f4fd860131561a11d2ddebf3d496f39a", authority["project_main_sha"])
        self.assertEqual("7ce96181d0a97930300fcc6d383dacc75ad08f6a", authority["base_main_sha"])
        self.assertEqual([], authority["project_open_prs_at_start"])
        self.assertEqual([], authority["base_open_prs_at_start"])
        self.assertTrue(authority["sheet_reread"])

        overlay = self.data["external_process_overlay"]
        for marker in (
            "superpowers/brainstorming",
            "superpowers/test-driven-development",
            "base/running-adversarial-review-and-refinement",
        ):
            self.assertIn(marker, overlay["actually_executed"])

    def test_review_keeps_findings_and_evidence_boundaries_explicit(self) -> None:
        self.assertIsInstance(self.data["findings"], list)
        self.assertGreater(len(self.data["findings"]), 0)
        for finding in self.data["findings"]:
            self.assertIn(finding["severity"], {"P0", "P1", "P2", "P3"})
            self.assertTrue(finding["id"])
            self.assertTrue(finding["status"])
        evidence = self.data["evidence_boundaries"]
        self.assertEqual("NOT_RUN", evidence["human_usability"])
        self.assertEqual("NOT_RUN", evidence["player_experience"])
        self.assertEqual("NOT_RUN", evidence["android_physical_device"])
        self.assertEqual("NOT_RUN", evidence["local_windows_visible"])

    def test_report_states_current_conflicts_and_no_false_completion(self) -> None:
        for marker in (
            "사용자 `기획완료` 선언",
            "Phase B",
            "Base current main",
            "Google Sheet",
            "적대적 검토",
            "이미지 생성은 아직 시작하지 않는다",
            "product_implementation_authorized: false",
            "HUMAN_USABILITY_EVIDENCE: NOT_RUN",
            "PLAYER_EXPERIENCE_EVIDENCE: NOT_RUN",
        ):
            self.assertIn(marker, self.report)


if __name__ == "__main__":
    unittest.main()
