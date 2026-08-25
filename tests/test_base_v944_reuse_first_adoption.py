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
    found: set[str] = set()
    for route in data["routing"]["base_routes"]:
        if isinstance(route, str):
            found.add(route)
        elif route.get("status") == "ACTIVE":
            found.add(route["skill_id"])
    return found


def intake(data: dict) -> dict:
    value = data.get("shared_overrides", {}).get(SKILL)
    if not isinstance(value, dict):
        raise AssertionError("missing intake shared override")
    return value


class BaseV944ReuseFirstAdoptionTests(unittest.TestCase):
    def test_release_identity(self) -> None:
        data = load()
        release = data["base_release"]
        self.assertEqual("9.4.4", release["version"])
        self.assertEqual(PAYLOAD, release["release_commit"])
        self.assertEqual(EVIDENCE, release["release_evidence_commit"])
        self.assertEqual(FINALIZATION, release["finalization_commit"])
        self.assertEqual(REGISTRY, data["skill_registry"]["base"]["sha256"])

    def test_intake_route_and_adapter_only_policy(self) -> None:
        self.assertIn(SKILL, active_routes(load()))
        self.assertFalse((ROOT / "skills" / SKILL / "SKILL.md").exists())

    def test_existing_first_prompt_and_planning_contracts_follow_v944_pin(self) -> None:
        value = intake(load())
        first_prompt = value["first_prompt_governance"]
        planning = value["planning_first_governance"]
        self.assertEqual(["route", "first-prompt", "contract", "clarify"], first_prompt["instruction_flow"])
        self.assertEqual("AWAITING_USER_CONFIRMATION", first_prompt["unconfirmed_state"])
        self.assertEqual("REUSE_EXACT_APPROVAL_REFERENCE", first_prompt["approval_reuse"])
        self.assertEqual("base-v9.4.4.lock.json", first_prompt["base_release_lock"])
        self.assertEqual(FINALIZATION, first_prompt["base_release_finalization_commit"])
        self.assertEqual("NOT_RUN", first_prompt["actual_project_instruction_execution"])
        self.assertEqual("base-v9.4.4.lock.json", planning["base_release_lock"])
        self.assertEqual(FINALIZATION, planning["base_release_finalization_commit"])

    def test_reuse_first_gate_is_explicit_and_fail_closed(self) -> None:
        reuse = intake(load())["reuse_first_governance"]
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

    def test_project_boundaries_remain_declared(self) -> None:
        self.assertTrue(load()["protected_paths"])


if __name__ == "__main__":
    unittest.main()
