from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CURRENT_CONTRACT = ROOT / "docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"


class BaseV9AdoptionTests(unittest.TestCase):
    def test_compatibility_adapter_preserves_release_pin_and_v2_boundary(self) -> None:
        data = json.loads((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_text(encoding="utf-8"))
        health = json.loads((ROOT / "docs/PROJECT_OPERATING_HEALTH.json").read_text(encoding="utf-8"))
        release = data["base_release"]
        self.assertEqual("9.4.4", release["version"])
        self.assertEqual("210ec78292fa12ed7563ba743b322dd36103ae4a", release["release_commit"])
        self.assertEqual("bb61e68dc3028421b60c11b87ba2abd297ee6f78", release["release_evidence_commit"])
        self.assertEqual("5adc196c0185951f50e49ab5e51586eff8d60886", release["finalization_commit"])
        self.assertEqual(2, data["schema_version"])
        self.assertEqual("ten-paces-hidden-moves", data["project"]["project_id"])
        self.assertNotIn("current_operating_contract", data)
        current = CURRENT_CONTRACT.read_text(encoding="utf-8")
        self.assertIn("contract_version: '4.8'", current)
        self.assertIn("TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01", current)
        intake = data["shared_overrides"]["managing-project-intake-and-work-contract"]
        planning = intake["planning_first_governance"]
        first_prompt = intake["first_prompt_governance"]
        reuse_first = intake["reuse_first_governance"]
        self.assertEqual(10, planning["max_approved_decisions_per_batch"])
        self.assertEqual("GRILL_ME_REQUIRED", planning["planning_conflict_state"])
        self.assertEqual("NOT_RUN", planning["actual_project_batch_execution"])
        self.assertEqual("AWAITING_USER_CONFIRMATION", first_prompt["unconfirmed_state"])
        self.assertEqual("NOT_RUN", first_prompt["actual_project_instruction_execution"])
        self.assertEqual(
            ["REUSE_FIRST_PREFLIGHT_REQUIRED", "REUSE_LEARNING_HANDOFF_REQUIRED"],
            reuse_first["required_gates"],
        )
        self.assertEqual("NOT_RUN", reuse_first["actual_project_execution"])
        self.assertEqual("GOOGLE_SHEETS_LEGACY_MIGRATION_SOURCE", data["gdd_sheet"]["role"])
        self.assertEqual("MIGRATION_COMPATIBILITY_SURFACE", data["gdd_sheet"]["workspace_status"])
        self.assertEqual("STALE", data["gdd_sheet"]["sync_status"])
        self.assertFalse(data["gdd_sheet"]["current_authority"])
        self.assertEqual("OM-L0", health["operating_maturity"])
        self.assertEqual("PE-0", health["product_evidence_maturity"])
        self.assertEqual("NOT_RUN", health["critical_gates"]["runtime"])

    def test_v9_compatibility_view_is_generated(self) -> None:
        data = json.loads((ROOT / "skills/BASE_V9_ADAPTER.json").read_text(encoding="utf-8"))
        self.assertEqual("GENERATED_COMPATIBILITY_VIEW", data["artifact_role"])
        self.assertTrue(data["generated"])

    def test_adoption_contract_and_gates_exist_as_history(self) -> None:
        audit = (ROOT / "docs/BASE_V9_ADOPTION_AUDIT.md").read_text(encoding="utf-8")
        workflow = (ROOT / ".github/workflows/validate-base-v9-adoption.yml").read_text(encoding="utf-8")
        for token in ("OPERATING_SYSTEM_ONLY", "V6_V8_MIGRATION", "RUNTIME_IMPLEMENTATION_NOT_TOUCHED", "NOT_RUN"):
            self.assertIn(token, audit)
        self.assertIn("ci-gate", workflow)
        self.assertIn("adversarial-gate", workflow)


if __name__ == "__main__":
    unittest.main()
