from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github/workflows/validate-project-base-adapter.yml"
BASE_GATE_COMMIT = "2828a74f60c1ed09546171040f4178c8848ea686"


class ApprovedProtectedChangeWorkflowTests(unittest.TestCase):
    def test_workflow_pins_current_completed_base_gate_and_fails_closed(self) -> None:
        workflow = WORKFLOW.read_text(encoding="utf-8")
        required = (
            f"ref: {BASE_GATE_COMMIT}",
            "check_approved_project_operating_contract.py",
            "PROJECT_PROTECTED_CHANGE_APPROVAL.json",
            "approved-protected-change",
            "--external-approval \"$EXTERNAL_APPROVAL\"",
            "check_one_time_protected_change_lifecycle.py",
            "--base-sha \"$PR_BASE_SHA\"",
            "labeled",
            "unlabeled",
        )
        for token in required:
            self.assertIn(token, workflow)
        self.assertNotIn("ref: 4ec410e611152294f3f2685570fca6019c7abcfa", workflow)
        self.assertNotIn("ref: bfdc9e44d4a6920dc085eaa3f9d19d31b1acd2a1", workflow)


if __name__ == "__main__":
    unittest.main()
