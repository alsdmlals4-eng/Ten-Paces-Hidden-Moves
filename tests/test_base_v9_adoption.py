from __future__ import annotations
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

class BaseV9AdoptionTests(unittest.TestCase):
    def test_base_v9_adapter_and_planning_boundary(self) -> None:
        data = json.loads((ROOT / "skills/BASE_V9_ADAPTER.json").read_text(encoding="utf-8"))
        self.assertEqual(data["base"]["release_commit"], "585a53a25be1b04c543196f5901551deb49c7691")
        self.assertFalse(data["base"]["copy_common_skill_bodies"])
        self.assertEqual(data["sheet"]["sync_status"], "SHEET_GITHUB_CONFLICT")
        self.assertEqual(data["maturity"]["level"], 2)
        self.assertEqual(data["scope"], "PLANNING_ONLY")
    def test_adoption_contract_and_gates_exist(self) -> None:
        audit = (ROOT / "docs/BASE_V9_ADOPTION_AUDIT.md").read_text(encoding="utf-8")
        workflow = (ROOT / ".github/workflows/validate-base-v9-adoption.yml").read_text(encoding="utf-8")
        for token in ("OPERATING_SYSTEM_ONLY", "V6_V8_MIGRATION", "RUNTIME_IMPLEMENTATION_NOT_TOUCHED", "NOT_RUN"):
            self.assertIn(token, audit)
        self.assertIn("ci-gate", workflow)
        self.assertIn("adversarial-gate", workflow)

if __name__ == "__main__":
    unittest.main()
