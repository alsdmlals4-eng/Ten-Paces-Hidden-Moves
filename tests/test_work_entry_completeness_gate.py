from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DECISION_ID = "TEN-DEC-20260806-WORK-ENTRY-COMPLETENESS-GATE-01"
DECISION = ROOT / "docs/decisions/2026-08-06_WORK_ENTRY_COMPLETENESS_GATE_DECISION.md"
CONTRACT = ROOT / "docs/planning-data/approved_20260806_work_entry_completeness_gate.json"
SHEET_SNAPSHOT = ROOT / "docs/planning-data/sheet_work_entry_gate_snapshot_20260806.json"
STATE = ROOT / "docs/planning-data/current_operating_state.json"
ACTIVE_CONTEXT = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
VALIDATOR = ROOT / "tools/check_work_entry_completeness_gate.py"
WORKFLOW = ROOT / ".github/workflows/documentation-governance.yml"


class WorkEntryCompletenessGateTests(unittest.TestCase):
    def test_gate_contract_is_fail_closed(self) -> None:
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(payload["decision_id"], DECISION_ID)
        self.assertEqual(payload["mode"], "FAIL_CLOSED")
        self.assertTrue(payload["blocking_gate"])
        self.assertFalse(payload["checklist_only"])
        self.assertEqual(payload["product_implementation"]["entry_state"], "BLOCKED")
        self.assertEqual(
            payload["governance_tooling"]["visual_disposition"],
            "NO_NEW_VISUAL_ASSET_REQUIRED",
        )

    def test_required_authority_surfaces_are_mandatory(self) -> None:
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        required = set(payload["required_readbacks"])
        self.assertEqual(
            required,
            {
                "GITHUB_DECISION_LEDGER",
                "SHEET_02_CURRENT_DECISIONS",
                "SHEET_04_UNRESOLVED_AUDIT",
                "SHEET_71_IMAGE_PLAN",
                "SHEET_72_IMAGE_REVIEW",
                "CURRENT_OPERATING_STATE",
            },
        )
        self.assertEqual(payload["missing_readback_result"], "WORK_ENTRY_BLOCKED_UNVERIFIED")
        self.assertEqual(payload["source_conflict_result"], "WORK_ENTRY_BLOCKED_CANON_CONFLICT")

    def test_sheet_snapshot_reverses_false_ready_claims(self) -> None:
        snapshot = json.loads(SHEET_SNAPSHOT.read_text(encoding="utf-8"))
        self.assertEqual(snapshot["sheet_read_at"], "2026-08-06T22:20:00+09:00")
        self.assertEqual(snapshot["decision_ledger"]["latest_synced_main"], "5f4add5d98721413681cf92c01bb810f16677703")
        self.assertEqual(snapshot["unresolved"]["blocking_finding"], "P0_RUNTIME_AUTHORITY_GAP")
        self.assertEqual(snapshot["visual_review"]["approval_state"], "IN_REVIEW")
        self.assertEqual(snapshot["visual_review"]["runtime_validation"], "NOT_RUN")
        self.assertEqual(snapshot["product_implementation_entry"], "BLOCKED")
        self.assertNotIn(snapshot["product_implementation_entry"], {"READY", "AWAITING_IMPLEMENTATION"})

    def test_operating_state_remains_adapter_owned_while_gate_blocks_entry(self) -> None:
        state = json.loads(STATE.read_text(encoding="utf-8"))
        self.assertEqual(state["authority"], "CURRENT_OPERATING_STATE")
        self.assertEqual(state["source_decision"], "TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01")
        self.assertEqual(state["active_planning_pr"], "NONE")
        self.assertEqual(state["next_package"], "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION")
        self.assertNotIn("next_package_state", state)
        self.assertNotIn("work_entry_completeness_gate", state)

        gate = json.loads(CONTRACT.read_text(encoding="utf-8"))["product_implementation"]
        self.assertEqual(gate["entry_state"], "BLOCKED")
        self.assertEqual(gate["reason"], "PLANNING_REVIEW_VISUAL_AND_AUTHORITY_GATES_OPEN")

    def test_active_context_does_not_claim_unqualified_readiness(self) -> None:
        text = ACTIVE_CONTEXT.read_text(encoding="utf-8")
        self.assertIn(DECISION_ID, text)
        self.assertIn("active_tooling_pr: 104", text)
        self.assertIn("product_implementation_entry: BLOCKED", text)
        self.assertIn("NO_NEW_VISUAL_ASSET_REQUIRED", text)
        self.assertNotIn("next_package_state: READY", text)
        self.assertNotIn("next_package_state: AWAITING_IMPLEMENTATION", text)

    def test_gate_has_executable_validator_and_ci_entry(self) -> None:
        validator_text = VALIDATOR.read_text(encoding="utf-8")
        self.assertIn("WORK_ENTRY_BLOCKED_UNVERIFIED", validator_text)
        self.assertIn("WORK_ENTRY_BLOCKED_CANON_CONFLICT", validator_text)
        self.assertIn("PLANNING_REVIEW_VISUAL_AND_AUTHORITY_GATES_OPEN", validator_text)

        workflow_text = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("gut-adoption-exact-head", workflow_text)
        self.assertIn("tests.test_work_entry_completeness_gate", workflow_text)
        self.assertIn("python tools/check_work_entry_completeness_gate.py", workflow_text)
        self.assertIn("mkdir -p build/test-results", workflow_text)

    def test_decision_explicitly_forbids_checklist_bypass(self) -> None:
        text = DECISION.read_text(encoding="utf-8")
        for marker in (
            DECISION_ID,
            "MANDATORY_BLOCKING_GATE",
            "CHECKLIST_ONLY_FORBIDDEN",
            "FALSE_READY_REVERSAL",
            "GITHUB_SHEET_READBACK_REQUIRED",
            "PRODUCT_IMPLEMENTATION_BLOCKED",
        ):
            self.assertIn(marker, text)


if __name__ == "__main__":
    unittest.main()
