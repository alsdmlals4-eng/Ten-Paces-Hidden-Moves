from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CURRENT_DECISION_ID = "TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01"
PREVIOUS_DECISION_ID = "TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01"
SOURCE_SHA256 = "6f0541048e084746f6777223521361d0339dbfb2e223c70947f694f1c050f508"
CANONICAL = ROOT / "docs" / "PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"
DECISION = ROOT / "docs" / "decisions" / "2026-08-24_INTEGRATED_WORK_CONTRACT_V4_8_R2_BINDING_DECISION.md"
CONTRACT = ROOT / "docs" / "planning-data" / "approved_20260824_integrated_work_contract_v4_8_r2_binding.json"


class IntegratedWorkContractV48R2Tests(unittest.TestCase):
    def test_v48r2_is_current_project_operating_contract(self) -> None:
        text = CANONICAL.read_text(encoding="utf-8")
        for marker in (
            "contract_version: '4.8'",
            "revision: '2026-08-24-r2'",
            f"current_binding_decision: {CURRENT_DECISION_ID}",
            f"source_uploaded_sha256: {SOURCE_SHA256}",
            "adapter_policy: THIN_ADAPTER_DO_NOT_DUPLICATE_BASE_CANON",
            "human_workspace: NOTION_DEFAULT_PROJECT_WORKSPACE",
            "runtime_structured_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME",
            "google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL",
            "open_pr_policy: OPEN_PR_READ_ONLY_BY_DEFAULT",
        ):
            self.assertIn(marker, text)
        self.assertNotIn("current_sheet_authority: GOOGLE_SHEET_00_02_04_99", text)
        self.assertNotIn("workbook_role: USER_FACING_GDD_WORKSPACE", text)

    def test_v48_binding_supersedes_v45_without_deleting_history(self) -> None:
        self.assertTrue(DECISION.is_file())
        self.assertTrue(CONTRACT.is_file())
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(CURRENT_DECISION_ID, payload["decision_id"])
        self.assertEqual(PREVIOUS_DECISION_ID, payload["supersedes_decision_id"])
        self.assertEqual("4.8", payload["contract_version"])
        self.assertEqual("2026-08-24-r2", payload["revision"])
        self.assertEqual(SOURCE_SHA256, payload["source_uploaded_sha256"])
        self.assertEqual("NOTION_HUMAN_FACING_CANON", payload["authority"]["human_workspace"])
        self.assertEqual("REPOSITORY_STRUCTURED_CANON_AND_RUNTIME_TRUTH", payload["authority"]["repository"])
        self.assertEqual("MIGRATION_ONLY_UNTIL_REMOVAL", payload["authority"]["google_sheets"])
        historical = ROOT / "docs" / "decisions" / "2026-08-11_INTEGRATED_WORK_CONTRACT_V4_5_R2_BINDING_DECISION.md"
        self.assertTrue(historical.is_file())
        self.assertIn(PREVIOUS_DECISION_ID, historical.read_text(encoding="utf-8"))

    def test_default_cold_start_routes_to_notion_and_repository_not_sheet(self) -> None:
        for relative in (
            "AGENTS.md",
            "START_HERE.md",
            "[기획서]/00_프로젝트_허브/START_HERE.md",
            "[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md",
        ):
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn("ACTIVE_CONTEXT.md", text, relative)
            self.assertNotIn("current_sheet_authority: GOOGLE_SHEET_00_02_04_99", text, relative)
            self.assertNotIn("GitHub `main`·열린 PR과 Google Sheet", text, relative)
        self.assertIn("NOTION_DEFAULT_PROJECT_WORKSPACE", (ROOT / "START_HERE.md").read_text(encoding="utf-8"))
        self.assertIn("MIGRATION_ONLY_UNTIL_REMOVAL", (ROOT / "docs" / "PROJECT_GOOGLE_SHEET_WORKBOOK.md").read_text(encoding="utf-8"))

    def test_stable_routers_do_not_duplicate_mutable_state(self) -> None:
        mutable_tokens = (
            "product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING",
            "runtime_integration_pr: 65",
            "next_package: VERTICAL_SLICE_APP_FLOW_SHELL",
            "current_sheet_authority: GOOGLE_SHEET_00_02_04_99",
        )
        for relative in (
            "START_HERE.md",
            "README.md",
            "[기획서]/00_프로젝트_허브/START_HERE.md",
        ):
            text = (ROOT / relative).read_text(encoding="utf-8")
            for token in mutable_tokens:
                self.assertNotIn(token, text, f"{relative} duplicates mutable state: {token}")


if __name__ == "__main__":
    unittest.main()
