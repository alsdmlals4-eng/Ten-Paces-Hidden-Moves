from __future__ import annotations
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

class BaseV9AdoptionTests(unittest.TestCase):
    def test_v9_1_canonical_adapter_preserves_planning_boundary(self) -> None:
        data = json.loads((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_text(encoding="utf-8"))
        health = json.loads((ROOT / "docs/PROJECT_OPERATING_HEALTH.json").read_text(encoding="utf-8"))
        self.assertEqual(data["base_release"]["version"], "9.1.0")
        self.assertEqual(data["gdd_sheet"]["sync_status"], "BLOCKED")
        self.assertEqual(health["operating_maturity"], "OM-L0")
        self.assertEqual(health["product_evidence_maturity"], "PE-0")
        self.assertEqual(health["critical_gates"]["runtime"], "NOT_RUN")

    def test_v9_compatibility_view_is_generated(self) -> None:
        data = json.loads((ROOT / "skills/BASE_V9_ADAPTER.json").read_text(encoding="utf-8"))
        self.assertEqual(data["artifact_role"], "GENERATED_COMPATIBILITY_VIEW")
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
