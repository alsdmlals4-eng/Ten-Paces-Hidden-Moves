from __future__ import annotations

import json
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADAPTER_PATH = ROOT / "skills/PROJECT_BASE_ADAPTER.json"
SKILL_ID = "orchestrating-deepseek-worktrees"
CURRENT_VERSION = "9.4.3"
CURRENT_PAYLOAD = "7dd1a4f80388bc5faca767ff74a3eb32dc9d0ac8"
CURRENT_EVIDENCE = "da33a350d61b8adc52df97fccc7001708a933370"
CURRENT_FINALIZATION = "0b7c94f38d959efc0fc9442274c60b2e268a3c97"
REGISTRY = "693a0dff3f054ecdd653079909e044211473838e73dd9aff07734d1ce5694c59"


def load_adapter() -> dict:
    return json.loads(ADAPTER_PATH.read_text(encoding="utf-8"))


def active_base_routes(adapter: dict) -> set[str]:
    return {
        route["skill_id"]
        for route in adapter["routing"]["base_routes"]
        if route.get("status") == "ACTIVE"
    }


class BaseSharedExternalAIAdapterTests(unittest.TestCase):
    def test_preserves_current_released_base_identity(self) -> None:
        adapter = load_adapter()
        release = adapter["base_release"]
        self.assertEqual(CURRENT_VERSION, release["version"])
        self.assertEqual(CURRENT_PAYLOAD, release["release_commit"])
        self.assertEqual(CURRENT_EVIDENCE, release["release_evidence_commit"])
        self.assertEqual(CURRENT_FINALIZATION, release["finalization_commit"])
        self.assertEqual(REGISTRY, adapter["skill_registry"]["base"]["sha256"])

    def test_routes_external_ai_worktree_skill_without_copying_body(self) -> None:
        adapter = load_adapter()
        self.assertIn(SKILL_ID, active_base_routes(adapter))
        self.assertFalse((ROOT / "skills/orchestrating-deepseek-worktrees/SKILL.md").exists())

    def test_binds_project_isolation_and_v941_validator_boundary(self) -> None:
        override = load_adapter()["shared_overrides"][SKILL_ID]
        self.assertEqual(".worktrees/", override["worktree_parent"])
        self.assertEqual("ai/deepseek-", override["task_branch_prefix"])
        self.assertEqual("drafts/external-ai/", override["draft_root"])
        self.assertEqual(["drafts/external-ai/**"], override["allowed_write_roots"])
        self.assertEqual("skills/PROJECT_BASE_ADAPTER.json#/protected_paths", override["protected_paths_source"])
        self.assertEqual("REVIEW_PENDING", override["result_state"])
        self.assertEqual("LOCAL_REVIEW_REQUIRED_BEFORE_CANON", override["integration_policy"])
        self.assertEqual("ADOPTED_FROM_BASE_V9_4_1", override["base_validator_adoption"])
        self.assertEqual("tools/check_external_ai_worktree_contract.py", override["base_validator_path"])
        self.assertEqual("base-v9.4.1.lock.json", override["base_release_lock"])
        self.assertEqual("NOT_RUN", override["actual_external_ai_worktree_execution"])

    def test_worktree_parent_is_ignored_by_git(self) -> None:
        result = subprocess.run(["git", "check-ignore", "-q", ".worktrees/"], cwd=ROOT, check=False)
        self.assertEqual(0, result.returncode)

    def test_project_validation_discovers_adapter_test(self) -> None:
        self.assertIn("python tests/test_base_shared_external_ai_adapter.py", load_adapter()["validators"])


if __name__ == "__main__":
    unittest.main()
