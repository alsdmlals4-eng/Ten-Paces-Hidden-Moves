from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ADAPTER = ROOT / "skills/PROJECT_BASE_ADAPTER.json"
PAYLOAD = "210ec78292fa12ed7563ba743b322dd36103ae4a"
EVIDENCE = "bb61e68dc3028421b60c11b87ba2abd297ee6f78"
FINALIZATION = "5adc196c0185951f50e49ab5e51586eff8d60886"
REGISTRY = "08f882d0c77339e8f7ff187c35b79501e0a2958ab1ff1c7aaa1c0ef8dbee45d6"
SKILL = "managing-project-intake-and-work-contract"


def load() -> dict:
    return json.loads(ADAPTER.read_text(encoding="utf-8"))


def active_routes(data: dict) -> set[str]:
    return {
        route["skill_id"]
        for route in data["routing"]["base_routes"]
        if route.get("status") == "ACTIVE"
    }


class BaseV944ReuseFirstAdoptionTests(unittest.TestCase):
    def test_release_identity_is_reproducible(self) -> None:
        data = load()
        release = data["base_release"]
        self.assertEqual("9.4.4", release["version"])
        self.assertEqual(PAYLOAD, release["release_commit"])
        self.assertEqual(EVIDENCE, release["release_evidence_commit"])
        self.assertEqual(FINALIZATION, release["finalization_commit"])
        self.assertEqual(REGISTRY, data["skill_registry"]["base"]["sha256"])

    def test_adapter_only_intake_route_remains_active(self) -> None:
        self.assertIn(SKILL, active_routes(load()))
        self.assertFalse((ROOT / "skills" / SKILL / "SKILL.md").exists())

    def test_reuse_first_gate_is_explicit_and_fail_closed(self) -> None:
        intake = load()["shared_overrides"][SKILL]
        reuse = intake["reuse_first_governance"]
        self.assertEqual("skills/managing-project-intake-and-work-contract/SKILL.md", reuse["base_contract_source"])
        self.assertEqual(
            "docs/knowledge/game-development/reuse/adoption/PROJECT_WORK_REUSE_HANDOFF.json",
            reuse["handoff_source"],
        )
        self.assertEqual(
            ["REUSE_FIRST_PREFLIGHT_REQUIRED", "REUSE_LEARNING_HANDOFF_REQUIRED"],
            reuse["required_gates"],
        )
        self.assertEqual("base-v9.4.4.lock.json", reuse["base_release_lock"])
        self.assertEqual(FINALIZATION, reuse["base_release_finalization_commit"])
        self.assertEqual("NOT_RUN", reuse["actual_project_execution"])

    def test_project_specific_current_work_adaptation_is_bounded(self) -> None:
        current = load()["shared_overrides"][SKILL]["current_work_contract_governance"]
        self.assertEqual("PROJECT_REPOSITORY_OWNED_EXACT_BASE_VALIDATED", current["receipt_policy"])
        self.assertEqual("REPOSITORY_PRIMARY_CANON_NO_NEW_NOTION_WRITE_BY_DEFAULT", current["workspace_authority_override"])
        self.assertEqual(
            "ONLY_WHEN_CONNECTED_PLAYER_FACING_SYSTEM_CHANGE_REQUIRES_IT",
            current["conditional_blueprint_policy"],
        )
        self.assertIn("PROJECT_START_CANON_CHECKLIST_REQUIRED", current["required_startup_gates"])
        self.assertIn("LEGACY_CONTEXT_CONFIGURATION_HYGIENE_REQUIRED", current["required_startup_gates"])


if __name__ == "__main__":
    unittest.main()
