from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class TenPacesV91OperatingContractTests(unittest.TestCase):
    def test_only_project_specific_skills_remain_local(self) -> None:
        adapter = json.loads((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_text(encoding="utf-8"))
        self.assertEqual(
            {route["route_id"] for route in adapter["routing"]["project_routes"]},
            {"combat-implementation-handoff", "combat-ux-and-accessibility", "ten-paces-game-design", "ten-paces-verification"},
        )
        self.assertIn("running-adversarial-review-and-refinement", {route["route_id"] for route in adapter["routing"]["base_routes"]})

    def test_generated_router_is_contract_only(self) -> None:
        router = (ROOT / ".agents/skills/ten-paces-hidden-moves-workflow-router/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("PROJECT_BASE_ADAPTER.json", router)
        self.assertIn("PROJECT_SKILL_SNAPSHOT.json", router)
        self.assertNotIn("Base shared Skill body", router.split("this router contains no copied ")[0])


if __name__ == "__main__":
    unittest.main()
