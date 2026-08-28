from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADAPTER_PATH = ROOT / "skills/PROJECT_BASE_ADAPTER.json"
CURRENT_CONTRACT_PATH = ROOT / "docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"
CURRENT_PAYLOAD = "7dd1a4f80388bc5faca767ff74a3eb32dc9d0ac8"
CURRENT_EVIDENCE = "da33a350d61b8adc52df97fccc7001708a933370"
CURRENT_FINALIZATION = "0b7c94f38d959efc0fc9442274c60b2e268a3c97"
REGISTRY = "693a0dff3f054ecdd653079909e044211473838e73dd9aff07734d1ce5694c59"
CURRENT_EXECUTION_DECISION = "TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01"
PRODUCT_SAFETY_BASELINE = "TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01"


def load_adapter() -> dict:
    return json.loads(ADAPTER_PATH.read_text(encoding="utf-8"))


class PlanningFirstCompatibilityTests(unittest.TestCase):
    def test_historical_release_pin_remains_reproducible(self) -> None:
        adapter = load_adapter()
        release = adapter["base_release"]
        self.assertEqual("9.4.3", release["version"])
        self.assertEqual(CURRENT_PAYLOAD, release["release_commit"])
        self.assertEqual(CURRENT_EVIDENCE, release["release_evidence_commit"])
        self.assertEqual(CURRENT_FINALIZATION, release["finalization_commit"])
        self.assertEqual(REGISTRY, adapter["skill_registry"]["base"]["sha256"])

    def test_current_operating_contract_uses_repository_only_execution_decision(self) -> None:
        adapter = load_adapter()
        self.assertNotIn("current_operating_contract", adapter)
        text = CURRENT_CONTRACT_PATH.read_text(encoding="utf-8")
        self.assertIn("contract_version: '4.8'", text)
        self.assertIn(f"current_binding_decision: {CURRENT_EXECUTION_DECISION}", text)
        self.assertIn(f"product_safety_baseline: {PRODUCT_SAFETY_BASELINE}", text)
        self.assertIn("base_snapshot_policy: ALWAYS_REFETCH_CURRENT_COMPLETED_MAIN", text)

    def test_adapter_uses_current_v2_identity_and_migration_schema(self) -> None:
        adapter = load_adapter()
        self.assertEqual(2, adapter["schema_version"])
        self.assertEqual("ten-paces-hidden-moves", adapter["project"]["project_id"])
        sheet = adapter["gdd_sheet"]
        self.assertEqual("GOOGLE_SHEETS_LEGACY_MIGRATION_SOURCE", sheet["role"])
        self.assertEqual("MIGRATION_COMPATIBILITY_SURFACE", sheet["workspace_status"])
        self.assertEqual("STALE", sheet["sync_status"])
        self.assertEqual("NO_NEW_CANON_INPUT", sheet["write_policy"])
        self.assertFalse(sheet["current_authority"])

    def test_intake_route_preserves_planning_first_governance_without_sheet_authority(self) -> None:
        adapter = load_adapter()
        routes = {
            item["skill_id"]
            for item in adapter["routing"]["base_routes"]
            if item.get("status") == "ACTIVE"
        }
        self.assertIn("managing-project-intake-and-work-contract", routes)
        policy = adapter["shared_overrides"]["managing-project-intake-and-work-contract"]["planning_first_governance"]
        self.assertEqual("docs/PLANNING_FIRST_GRILL_ME_BATCH_POLICY.md", policy["base_contract_source"])
        self.assertEqual("templates/project-operations/GRILL_ME_BATCH_CHECKPOINT.md", policy["checkpoint_template"])
        self.assertEqual("base-v9.4.3.lock.json", policy["base_release_lock"])
        self.assertEqual(CURRENT_FINALIZATION, policy["base_release_finalization_commit"])
        self.assertEqual(10, policy["max_approved_decisions_per_batch"])
        self.assertEqual("RECOMMENDED_DEFAULT", policy["numeric_default_state"])
        self.assertEqual("GRILL_ME_REQUIRED", policy["planning_conflict_state"])
        self.assertEqual("REPOSITORY_ONLY", policy["decision_sync_surface"])
        self.assertEqual("APPROVED_PENDING_MERGE", policy["pre_merge_sync_state"])
        self.assertEqual("REPOSITORY_DESTINATION_READBACK_REQUIRED", policy["post_merge_sync_state"])
        self.assertEqual("MIGRATION_ONLY_UNTIL_REMOVAL", policy["legacy_sheet_state"])
        self.assertNotIn("pre_merge_sheet_state", policy)
        self.assertNotIn("post_merge_sheet_state", policy)
        self.assertEqual("NOT_RUN", policy["actual_project_batch_execution"])

    def test_existing_external_ai_boundary_is_preserved(self) -> None:
        policy = load_adapter()["shared_overrides"]["orchestrating-deepseek-worktrees"]
        self.assertEqual("ADOPTED_FROM_BASE_V9_4_1", policy["base_validator_adoption"])
        self.assertEqual("base-v9.4.1.lock.json", policy["base_release_lock"])
        self.assertEqual("NOT_RUN", policy["actual_external_ai_worktree_execution"])


if __name__ == "__main__":
    unittest.main()
