from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKFLOWS = ROOT / ".github" / "workflows"


class CiPolicyTests(unittest.TestCase):
    def read(self, name: str) -> str:
        return (WORKFLOWS / name).read_text(encoding="utf-8")

    def test_all_ci_workflows_cancel_superseded_runs(self) -> None:
        for name in (
            "documentation-governance.yml",
            "card-component-contract.yml",
            "full-validation-matrix.yml",
        ):
            text = self.read(name)
            self.assertIn("group: ci-${{ github.workflow }}-${{ github.ref }}", text)
            self.assertIn("cancel-in-progress: true", text)
            self.assertIn("vars.CI_ENABLED == 'true'", text)

    def test_pull_request_validation_routes_by_scope(self) -> None:
        text = self.read("documentation-governance.yml")
        self.assertIn("pull_request:", text)
        self.assertIn("tools/classify_ci_scope.py", text)
        self.assertIn("tools/run_ci_suite.py docs", text)
        self.assertIn("tools/run_ci_suite.py code", text)
        self.assertIn("tools/run_godot_ci.py", text)

    def test_card_contract_is_manual_only(self) -> None:
        text = self.read("card-component-contract.yml")
        trigger = text.split("concurrency:", 1)[0]
        self.assertIn("workflow_dispatch:", trigger)
        self.assertNotIn("pull_request:", trigger)
        self.assertNotIn("push:", trigger)

    def test_full_matrix_is_main_and_nightly_only(self) -> None:
        text = self.read("full-validation-matrix.yml")
        self.assertIn("branches: [main]", text)
        self.assertIn("schedule:", text)
        self.assertIn("ubuntu-latest", text)
        self.assertIn("windows-latest", text)
        self.assertIn('["3.11", "3.12", "3.13"]', text)
        self.assertIn("matrix.python-version == '3.12'", text)


if __name__ == "__main__":
    unittest.main()
