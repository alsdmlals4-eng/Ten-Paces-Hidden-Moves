from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
R2_DECISION_ID = "TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01"
CURRENT_DECISION_ID = "TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01"
PREVIOUS_DECISION_ID = "TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01"
SOURCE_SHA256 = "6f0541048e084746f6777223521361d0339dbfb2e223c70947f694f1c050f508"
CANONICAL = ROOT / "docs" / "PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"
DECISION = ROOT / "docs" / "decisions" / "2026-08-24_INTEGRATED_WORK_CONTRACT_V4_8_R2_BINDING_DECISION.md"
CONTRACT = ROOT / "docs" / "planning-data" / "approved_20260824_integrated_work_contract_v4_8_r2_binding.json"


class IntegratedWorkContractV48R2Tests(unittest.TestCase):
    def test_v48r2_is_preserved_as_historical_evidence(self) -> None:
        self.assertTrue(DECISION.is_file())
        self.assertTrue(CONTRACT.is_file())
        decision_text = DECISION.read_text(encoding="utf-8")
        self.assertIn(R2_DECISION_ID, decision_text)
        self.assertIn("SUPERSEDED_HISTORICAL_EVIDENCE", decision_text)
        self.assertIn(CURRENT_DECISION_ID, decision_text)

        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(R2_DECISION_ID, payload["decision_id"])
        self.assertEqual(PREVIOUS_DECISION_ID, payload["supersedes_decision_id"])
        self.assertEqual("4.8", payload["contract_version"])
        self.assertEqual("2026-08-24-r2", payload["revision"])
        self.assertEqual(SOURCE_SHA256, payload["source_uploaded_sha256"])
        self.assertEqual("NOTION_HUMAN_FACING_CANON", payload["authority"]["human_workspace"])
        self.assertEqual("REPOSITORY_STRUCTURED_CANON_AND_RUNTIME_TRUTH", payload["authority"]["repository"])
        self.assertEqual("MIGRATION_ONLY_UNTIL_REMOVAL", payload["authority"]["google_sheets"])

    def test_current_adapter_no_longer_claims_r2_is_current(self) -> None:
        text = CANONICAL.read_text(encoding="utf-8")
        self.assertIn(f"current_binding_decision: {CURRENT_DECISION_ID}", text)
        self.assertIn("revision: '2026-08-26-r5.4-superset-final'", text)
        self.assertIn(f"decision: {R2_DECISION_ID}", text)
        self.assertIn("status: SUPERSEDED_HISTORICAL_EVIDENCE", text)
        self.assertNotIn(f"current_binding_decision: {R2_DECISION_ID}", text)

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
