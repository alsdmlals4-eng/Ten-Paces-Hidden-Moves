from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github/workflows/validate-project-base-adapter.yml"
ACTIVE_APPROVAL = ROOT / "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"
MERGED_RECORD = ROOT / "docs/operations/2026-08-06_PR92_PROTECTED_CHANGE_APPROVAL_RECORD.md"
BASE_GATE_COMMIT = "4ec410e611152294f3f2685570fca6019c7abcfa"


class ApprovedProtectedChangeAdoptionTests(unittest.TestCase):
    def test_merged_approval_is_archived_not_left_active(self) -> None:
        self.assertFalse(
            ACTIVE_APPROVAL.exists(),
            "merged one-time protected change approval must not authorize later PRs",
        )
        record = MERGED_RECORD.read_text(encoding="utf-8")
        required = (
            "status: HISTORICAL_MERGED",
            "product_pr: 92",
            "product_head: 3f4b2dd8b97480b39cb4301c33b2e27e0921cb37",
            "product_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90",
            "protected_base_commit: 4b5967dee99592de4a09a611068344994e1ee026",
            "approved_paths: [project.godot]",
            "approval_source: GITHUB_PR_LABEL_APPROVED_PROTECTED_CHANGE",
        )
        for token in required:
            self.assertIn(token, record)

    def test_adapter_workflow_pins_merged_base_gate_and_external_approval(self) -> None:
        workflow = WORKFLOW.read_text(encoding="utf-8")
        required = (
            f"ref: {BASE_GATE_COMMIT}",
            "check_approved_project_operating_contract.py",
            "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json",
            "approved-protected-change",
            "--external-approval \"$EXTERNAL_APPROVAL\"",
            "labeled",
            "unlabeled",
        )
        for token in required:
            self.assertIn(token, workflow)
        self.assertNotIn("ref: bfdc9e44d4a6920dc085eaa3f9d19d31b1acd2a1", workflow)


if __name__ == "__main__":
    unittest.main()
