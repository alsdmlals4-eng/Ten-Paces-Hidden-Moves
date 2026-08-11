from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
JSON_PATH = ROOT / "docs/planning-data/planning_completion_inventory_20260811.json"
MD_PATH = ROOT / "docs/reviews/2026-08-11_PLANNING_COMPLETION_INVENTORY.md"
FINAL_REVIEW_JSON = ROOT / "docs/planning-data/final_planning_adversarial_review_20260811.json"
FINAL_REVIEW_MD = ROOT / "docs/reviews/2026-08-11_FINAL_PLANNING_ADVERSARIAL_REVIEW.md"

REQUIRED_DOMAINS = {
    "project_product_direction_core_promise",
    "core_loop_win_loss_failure",
    "world_characters_factions_vertical_slice",
    "combat_rules_timing_distance_actions",
    "observation_information_fairness",
    "combat_resources_clash_interruption",
    "martial_manuals_techniques_content",
    "growth_economy_rewards",
    "vertical_slice_content_scope",
    "app_flow_route_node_briefing_result_retry",
    "ux_ui_card_detail_plan",
    "accessibility_and_input",
    "windows_android_platform_adapter",
    "save_resume_commit_idempotency",
    "art_audio_visual_requirements",
    "testing_evidence_acceptance",
    "implementation_legacy_delta",
    "governance_canon_sheet_sync",
}

ALLOWED_COMPLETION = {
    "RESOLVED",
    "P0",
    "P1",
    "P2",
    "DEFERRED_NON_BLOCKING",
    "EVIDENCE_PENDING_NON_PLANNING",
}

REQUIRED_DOMAIN_FIELDS = {
    "domain_id",
    "authority",
    "decision_ids",
    "sheet_rows",
    "implementation_state",
    "open_conflicts",
    "evidence_class",
    "completion_status",
}


class PlanningCompletionInventoryTests(unittest.TestCase):
    def setUp(self) -> None:
        self.assertTrue(JSON_PATH.is_file(), f"missing inventory JSON: {JSON_PATH}")
        self.assertTrue(MD_PATH.is_file(), f"missing inventory report: {MD_PATH}")
        self.data = json.loads(JSON_PATH.read_text(encoding="utf-8"))
        self.report = MD_PATH.read_text(encoding="utf-8")

    def test_top_level_snapshot_and_safety_boundaries(self) -> None:
        self.assertEqual(self.data["schema_version"], "1.0")
        self.assertTrue(self.data["project_main_sha"])
        self.assertTrue(self.data["base_remote_main_sha"])
        self.assertIsInstance(self.data["project_open_prs"], list)
        self.assertIsInstance(self.data["base_open_prs"], list)
        self.assertFalse(self.data["product_implementation_authorized"])
        self.assertFalse(self.data["image_generation_allowed"])
        self.assertFalse(self.data["planning_completion_candidate"])

    def test_required_domains_are_complete_and_traceable(self) -> None:
        rows = self.data["domains"]
        by_id = {row["domain_id"]: row for row in rows}
        self.assertEqual(len(by_id), len(rows), "duplicate domain_id")
        self.assertEqual(set(by_id), REQUIRED_DOMAINS)

        for domain_id, row in by_id.items():
            self.assertTrue(REQUIRED_DOMAIN_FIELDS.issubset(row), domain_id)
            self.assertTrue(row["authority"], f"blank authority: {domain_id}")
            self.assertTrue(row["sheet_rows"], f"blank sheet_rows: {domain_id}")
            self.assertTrue(row["implementation_state"], f"blank implementation_state: {domain_id}")
            self.assertTrue(row["evidence_class"], f"blank evidence_class: {domain_id}")
            self.assertIn(row["completion_status"], ALLOWED_COMPLETION, domain_id)
            self.assertIsInstance(row["decision_ids"], list, domain_id)
            self.assertIsInstance(row["open_conflicts"], list, domain_id)

    def test_severity_summary_matches_domain_rows(self) -> None:
        expected = {status: 0 for status in ALLOWED_COMPLETION}
        for row in self.data["domains"]:
            expected[row["completion_status"]] += 1
        self.assertEqual(self.data["severity_summary"], expected)
        self.assertGreater(expected["P1"] + expected["P0"], 0, "inventory must not hide observed blockers")

    def test_benchmarking_is_project_fit_only(self) -> None:
        research = self.data["research_summary"]
        for key in ("borrow", "do_not_borrow", "project_fit"):
            self.assertTrue(research[key], f"empty research field: {key}")
        self.assertIn("벤치마킹·현업 조사", self.report)
        self.assertIn("가져오는 요소", self.report)
        self.assertIn("가져오지 않는 요소", self.report)
        self.assertIn("십보강호 적용", self.report)

    def test_report_exposes_blockers_and_evidence_boundary(self) -> None:
        for marker in (
            "P0/P1",
            "EVIDENCE_PENDING_NON_PLANNING",
            "IMPLEMENTED_LEGACY",
            "이미지 생성 금지",
            "product_implementation_authorized: false",
            "DEFERRED_NON_BLOCKING",
        ):
            self.assertIn(marker, self.report)

    def test_user_planning_complete_requires_phase_b_review_artifacts(self) -> None:
        self.assertTrue(FINAL_REVIEW_JSON.is_file(), f"missing Phase B JSON: {FINAL_REVIEW_JSON}")
        self.assertTrue(FINAL_REVIEW_MD.is_file(), f"missing Phase B report: {FINAL_REVIEW_MD}")
        final = json.loads(FINAL_REVIEW_JSON.read_text(encoding="utf-8"))
        self.assertTrue(final["user_planning_complete_declared"])
        self.assertEqual("FINAL_PLANNING_REVIEW", final["phase"])
        self.assertFalse(final["product_implementation_authorized"])
        self.assertFalse(final["image_generation_allowed"])


if __name__ == "__main__":
    unittest.main()
