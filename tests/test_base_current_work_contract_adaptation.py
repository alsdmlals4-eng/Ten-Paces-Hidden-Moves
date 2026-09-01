from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RECEIPT = ROOT / "docs/operations/2026-09-01_BASE_CURRENT_ADAPTER_WORK_CONTRACT_RECEIPT.json"
AUDIT = ROOT / "[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md"
BASE_RULES = ROOT / "docs/BASE_RULES_VERSION.md"
README = ROOT / "README.md"
OBSERVED_BASE_MAIN = "19355b7ef065a21d0f2b685c7d9be64a4a3970f8"


class BaseCurrentWorkContractAdaptationTests(unittest.TestCase):
    def test_receipt_preserves_exact_source_and_bounded_reuse(self) -> None:
        receipt = json.loads(RECEIPT.read_text(encoding="utf-8"))
        self.assertEqual("L1", receipt["work_level"])
        self.assertEqual(OBSERVED_BASE_MAIN, receipt["source_identity"]["base_current_main_observed"])
        benchmark = receipt["benchmark_preflight_receipt"]
        self.assertEqual("REUSED_EVIDENCE", benchmark["state"])
        self.assertGreaterEqual(len(benchmark["entries"]), 3)
        self.assertEqual({"ADOPT", "ADAPT"}, {entry["disposition"] for entry in benchmark["entries"]})

    def test_hygiene_keeps_unrelated_work_and_limits_removal(self) -> None:
        receipt = json.loads(RECEIPT.read_text(encoding="utf-8"))
        inventory = receipt["context_configuration_hygiene"]["inventory"]
        obsolete = [item for item in inventory if item["classification"] == "OBSOLETE_CANDIDATE"]
        self.assertEqual(1, len(obsolete))
        self.assertTrue(obsolete[0]["removal_proposed"])
        self.assertTrue(obsolete[0]["references_and_consumers_zero_before_removal"])
        self.assertTrue(obsolete[0]["git_recoverable_removal_and_readback"])
        self.assertTrue(any(item["classification"] == "UNKNOWN_UNVERIFIED" for item in inventory))

    def test_current_documents_keep_repository_first_and_conditional_boundaries(self) -> None:
        rules = BASE_RULES.read_text(encoding="utf-8")
        audit = AUDIT.read_text(encoding="utf-8")
        readme = README.read_text(encoding="utf-8")
        for token in (
            "PROJECT_START_CANON_CHECKLIST_REQUIRED",
            "REUSE_FIRST_PREFLIGHT_REQUIRED",
            "LEGACY_CONTEXT_CONFIGURATION_HYGIENE_REQUIRED",
            "TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01",
            "conditional Blueprint/wireframe",
        ):
            self.assertIn(token, rules)
        self.assertIn(OBSERVED_BASE_MAIN, audit)
        self.assertIn("ADOPT / ADAPT / REJECT", audit)
        self.assertNotIn("NOTION_DEFAULT_PROJECT_WORKSPACE", readme)


if __name__ == "__main__":
    unittest.main()
