from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github/workflows/validate-project-base-adapter.yml"
APPROVAL = ROOT / "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"
BASE_GATE_COMMIT = "4ec410e611152294f3f2685570fca6019c7abcfa"
PROTECTED_BASE = "4b5967dee99592de4a09a611068344994e1ee026"


class ApprovedProtectedChangeAdoptionTests(unittest.TestCase):
    def test_approval_manifest_exactly_authorizes_project_godot(self) -> None:
        document = json.loads(APPROVAL.read_text(encoding="utf-8"))
        self.assertEqual("PROJECT_PROTECTED_CHANGE_APPROVAL", document["artifact_role"])
        self.assertEqual("APPROVED", document["status"])
        self.assertEqual(PROTECTED_BASE, document["protected_base_commit"])
        self.assertEqual(["project.godot"], document["approved_paths"])
        self.assertEqual(
            [
                "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",
                "TEN_MANUAL_UI_AI_ADOPTION_GATE",
                "TEN_MANUAL_PRODUCT_VALIDATION_GATE",
            ],
            document["decision_ids"],
        )
        self.assertEqual("GITHUB_PR_LABEL_APPROVED_PROTECTED_CHANGE", document["approval_source"])

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
