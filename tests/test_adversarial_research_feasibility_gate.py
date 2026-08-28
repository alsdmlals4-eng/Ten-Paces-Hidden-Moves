from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
AGENTS_PATH = ROOT / "AGENTS.md"
CONTRACT_PATH = ROOT / "docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"
DECISION_PATH = ROOT / "docs/decisions/2026-08-28_ADVERSARIAL_RESEARCH_FEASIBILITY_GATE_DECISION.md"
PLANNING_PATH = ROOT / "docs/planning-data/current_user_planning_status.json"

DECISION_ID = "TEN-DEC-20260828-ADVERSARIAL-RESEARCH-FEASIBILITY-GATE-01"


class AdversarialResearchFeasibilityGateTests(unittest.TestCase):
    def test_current_operating_contract_requires_the_new_gate(self) -> None:
        text = CONTRACT_PATH.read_text(encoding="utf-8")
        self.assertIn("external_research_policy: REQUIRED_EVERY_TASK_CURRENT_SOURCE_RELEVANCE_CHECK", text)
        self.assertIn("implementation_feasibility_policy: REQUIRED_BEFORE_MATERIAL_MUTATION", text)
        self.assertIn(
            "adversarial_review_policy: EVERY_TASK_BASE_LOOP_PLUS_MINIMUM_FIVE_FULL_SCOPE_LOOPS_FOR_MATERIAL_CHANGE",
            text,
        )
        self.assertIn(DECISION_ID, text)

    def test_agents_routes_current_work_through_research_and_adversarial_evidence(self) -> None:
        text = AGENTS_PATH.read_text(encoding="utf-8")
        self.assertIn(DECISION_ID, text)
        self.assertIn("CURRENT_SOURCE_RELEVANCE_CHECK", text)
        self.assertIn("EVERY_TASK_BASE_LOOP", text)
        self.assertIn("FEASIBLE / PARTIAL / BLOCKED_UNVERIFIED", text)

    def test_decision_records_evidence_boundaries_and_no_fake_research_escape(self) -> None:
        text = DECISION_PATH.read_text(encoding="utf-8")
        self.assertIn(DECISION_ID, text)
        self.assertIn("research_question", text)
        self.assertIn("NOT_APPLICABLE", text)
        self.assertIn("not invent external evidence", text)
        self.assertIn("Godot Command line tutorial", text)
        self.assertIn("GitHub-hosted runners reference", text)
        self.assertIn("Game Accessibility Guidelines", text)

    def test_current_planning_state_exposes_the_active_gate(self) -> None:
        payload = json.loads(PLANNING_PATH.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, payload["current_adversarial_research_feasibility_gate"])
        self.assertEqual(
            "REQUIRED_EVERY_TASK_WITH_EVIDENCE_SCALED_RECORD",
            payload["adversarial_research_feasibility_gate_status"],
        )


if __name__ == "__main__":
    unittest.main()
