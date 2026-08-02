from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ADAPTER_PATH = ROOT / "skills/PROJECT_BASE_ADAPTER.json"
PAYLOAD = "dd705d7f48a7919187bc0507610ba5fc5b43a658"
EVIDENCE = "0c6cdd128bf1f5782e96b3a6240c9585f8d1ef6d"
FINALIZATION = "ac9466edc2d93b59f274c9ac55ca719eba2809e3"
REGISTRY_SHA256 = "693a0dff3f054ecdd653079909e044211473838e73dd9aff07734d1ce5694c59"


def load_adapter() -> dict:
    return json.loads(ADAPTER_PATH.read_text(encoding="utf-8"))


class BaseV942PlanningFirstAdoptionTests(unittest.TestCase):
    def test_exact_released_identity(self) -> None:
        adapter = load_adapter()
        release = adapter["base_release"]
        self.assertEqual("9.4.2", release["version"])
        self.assertEqual(PAYLOAD, release["release_commit"])
        self.assertEqual(EVIDENCE, release["release_evidence_commit"])
        self.assertEqual(FINALIZATION, release["finalization_commit"])
        self.assertEqual(REGISTRY_SHA256, adapter["skill_registry"]["base"]["sha256"])

    def test_intake_route_adopts_planning_first_governance(self) -> None:
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
        self.assertEqual("base-v9.4.2.lock.json", policy["base_release_lock"])
        self.assertEqual(FINALIZATION, policy["base_release_finalization_commit"])
        self.assertEqual(10, policy["max_approved_decisions_per_batch"])
        self.assertEqual("RECOMMENDED_DEFAULT", policy["numeric_default_state"])
        self.assertEqual("GRILL_ME_REQUIRED", policy["planning_conflict_state"])
        self.assertEqual("APPROVED_PENDING_MERGE", policy["pre_merge_sheet_state"])
        self.assertEqual("SYNCED_TO_MAIN", policy["post_merge_sheet_state"])
        self.assertEqual("NOT_RUN", policy["actual_project_batch_execution"])

    def test_existing_external_ai_boundary_is_preserved(self) -> None:
        adapter = load_adapter()
        policy = adapter["shared_overrides"]["orchestrating-deepseek-worktrees"]
        self.assertEqual("ADOPTED_FROM_BASE_V9_4_1", policy["base_validator_adoption"])
        self.assertEqual("base-v9.4.1.lock.json", policy["base_release_lock"])
        self.assertEqual("NOT_RUN", policy["actual_external_ai_worktree_execution"])

    def test_project_canon_and_sheet_boundary_are_unchanged(self) -> None:
        adapter = load_adapter()
        self.assertEqual("SHEET_GITHUB_CONFLICT", adapter["gdd_sheet"]["declared_sync_status"])
        self.assertEqual("BLOCKED", adapter["gdd_sheet"]["sync_status"])
        self.assertEqual(
            ["data/", "src/", "scenes/", "assets/", "addons/", "project.godot"],
            adapter["protected_paths"],
        )


if __name__ == "__main__":
    unittest.main()
