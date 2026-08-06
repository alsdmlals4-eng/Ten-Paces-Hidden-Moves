from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FALLBACK_DECISION_ID = "TEN-DEC-20260807-ACTIONS-BUDGET-MANUAL-VALIDATION-FALLBACK-01"
FALLBACK_CONTRACT = (
    ROOT
    / "docs/planning-data/approved_20260807_actions_budget_manual_validation_fallback.json"
)
FALLBACK_DECISION = (
    ROOT
    / "docs/decisions/2026-08-07_ACTIONS_BUDGET_MANUAL_VALIDATION_FALLBACK_DECISION.md"
)
RECONCILIATION_CONTRACT = (
    ROOT / "docs/planning-data/approved_20260807_gut_9_7_1_reconciliation.json"
)
RECONCILIATION_DECISION = (
    ROOT / "docs/decisions/2026-08-07_GUT_9_7_1_RECONCILIATION_VALIDATION_DECISION.md"
)


class ActionsBudgetManualValidationFallbackTests(unittest.TestCase):
    def test_fallback_is_bounded_and_does_not_claim_unrun_execution(self) -> None:
        payload = json.loads(FALLBACK_CONTRACT.read_text(encoding="utf-8"))

        self.assertEqual(payload["decision_id"], FALLBACK_DECISION_ID)
        self.assertEqual(payload["reason"], "GITHUB_ACTIONS_BUDGET_UNAVAILABLE")
        self.assertEqual(payload["scope"]["pr_number"], 107)
        self.assertEqual(
            payload["scope"]["allowed_claim"],
            "PARTIAL_VALIDATED_EXPORT_GATE_OPEN",
        )
        self.assertEqual(payload["scope"]["product_implementation_effect"], "NONE")

        requirements = payload["requirements"]
        for key in (
            "exact_head_required",
            "exact_changed_blob_reconstruction",
            "git_blob_sha_match_required",
            "static_contract_test_required",
            "runtime_closure_tree_sha_match_required",
            "prior_successful_godot_gut_evidence_required",
            "full_diff_review_required",
            "review_threads_zero_required",
            "required_checks_policy_readback_required",
            "head_change_invalidates",
            "workflows_preserved",
            "branch_and_ruleset_policy_unchanged",
        ):
            self.assertTrue(requirements[key], key)

        limitations = payload["limitations"]
        self.assertEqual(
            limitations["current_head_godot_execution"],
            "NOT_RUN_BUDGET_UNAVAILABLE",
        )
        self.assertEqual(
            limitations["current_head_gut_execution"],
            "NOT_RUN_BUDGET_UNAVAILABLE",
        )
        self.assertEqual(
            limitations["export_presets_equivalence"],
            "NOT_CLAIMED_DIFFERENT_BLOB",
        )
        self.assertEqual(
            limitations["export_exclusion"],
            "BLOCKED_PENDING_HIGODOT_L1",
        )

    def test_fallback_preserves_repository_policy_and_workflow_files(self) -> None:
        payload = json.loads(FALLBACK_CONTRACT.read_text(encoding="utf-8"))
        merge_policy = payload["merge_policy"]

        self.assertEqual(
            merge_policy["github_required_status_check_set"],
            "EMPTY_READBACK_REQUIRED",
        )
        self.assertEqual(
            merge_policy["actions_pending_or_unrun"],
            "NON_REQUIRED_NOT_TREATED_AS_PASS",
        )
        self.assertTrue(merge_policy["no_branch_or_ruleset_bypass"])
        self.assertTrue(merge_policy["per_head_evidence_required_before_merge"])
        self.assertFalse(merge_policy["disable_or_delete_workflows"])

    def test_reconciliation_authority_links_the_fallback_decision(self) -> None:
        payload = json.loads(RECONCILIATION_CONTRACT.read_text(encoding="utf-8"))
        validation = payload["exact_head_validation"]

        self.assertEqual(validation["fallback_decision_id"], FALLBACK_DECISION_ID)
        self.assertEqual(
            validation["github_actions"],
            "NOT_RUN_BUDGET_UNAVAILABLE",
        )
        self.assertEqual(
            validation["fallback_route"],
            "CONTENT_ADDRESSED_EXACT_HEAD_STATIC_PLUS_RUNTIME_CLOSURE_EQUIVALENCE",
        )
        self.assertEqual(
            validation["state"],
            "FALLBACK_ROUTE_AUTHORIZED_PER_HEAD_EVIDENCE_REQUIRED",
        )

        decision_text = FALLBACK_DECISION.read_text(encoding="utf-8")
        reconciliation_text = RECONCILIATION_DECISION.read_text(encoding="utf-8")
        for marker in (
            FALLBACK_DECISION_ID,
            "CONTENT_ADDRESSED_EXACT_HEAD_STATIC_PLUS_RUNTIME_CLOSURE_EQUIVALENCE",
            "NOT_RUN_BUDGET_UNAVAILABLE",
            "PARTIAL_VALIDATED_EXPORT_GATE_OPEN",
            "BLOCKED_PENDING_HIGODOT_L1",
        ):
            self.assertIn(marker, decision_text)
            self.assertIn(marker, reconciliation_text)


if __name__ == "__main__":
    unittest.main()
