from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class BaseV9AdoptionTests(unittest.TestCase):
    def test_current_adapter_preserves_planning_boundary(self) -> None:
        data = json.loads((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_text(encoding="utf-8"))
        health = json.loads((ROOT / "docs/PROJECT_OPERATING_HEALTH.json").read_text(encoding="utf-8"))
        release = data["base_release"]
        self.assertEqual("9.4.3", release["version"])
        self.assertEqual("7dd1a4f80388bc5faca767ff74a3eb32dc9d0ac8", release["release_commit"])
        self.assertEqual("da33a350d61b8adc52df97fccc7001708a933370", release["release_evidence_commit"])
        self.assertEqual("0b7c94f38d959efc0fc9442274c60b2e268a3c97", release["finalization_commit"])
        intake = data["shared_overrides"]["managing-project-intake-and-work-contract"]
        planning = intake["planning_first_governance"]
        first_prompt = intake["first_prompt_governance"]
        self.assertEqual(10, planning["max_approved_decisions_per_batch"])
        self.assertEqual("GRILL_ME_REQUIRED", planning["planning_conflict_state"])
        self.assertEqual("NOT_RUN", planning["actual_project_batch_execution"])
        self.assertEqual("AWAITING_USER_CONFIRMATION", first_prompt["unconfirmed_state"])
        self.assertEqual("NOT_RUN", first_prompt["actual_project_instruction_execution"])
        self.assertEqual("BLOCKED", data["gdd_sheet"]["sync_status"])
        self.assertEqual("OM-L0", health["operating_maturity"])
        self.assertEqual("PE-0", health["product_evidence_maturity"])
        self.assertEqual("NOT_RUN", health["critical_gates"]["runtime"])

    def test_v9_compatibility_view_is_generated(self) -> None:
        data = json.loads((ROOT / "skills/BASE_V9_ADAPTER.json").read_text(encoding="utf-8"))
        self.assertEqual("GENERATED_COMPATIBILITY_VIEW", data["artifact_role"])
        self.assertTrue(data["generated"])

    def test_adoption_contract_and_gates_exist(self) -> None:
        audit = (ROOT / "docs/BASE_V9_ADOPTION_AUDIT.md").read_text(encoding="utf-8")
        workflow = (ROOT / ".github/workflows/validate-base-v9-adoption.yml").read_text(encoding="utf-8")
        for token in ("OPERATING_SYSTEM_ONLY", "V6_V8_MIGRATION", "RUNTIME_IMPLEMENTATION_NOT_TOUCHED", "NOT_RUN"):
            self.assertIn(token, audit)
        self.assertIn("ci-gate", workflow)
        self.assertIn("adversarial-gate", workflow)


if __name__ == "__main__":
    unittest.main()
