import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "docs/planning-data/approved_20260805_observation_answer_leak_guardrails_contract.json"
CHECKER = ROOT / "tools/check_observation_answer_leak_guardrails_contract.py"

STABLE_ENTRYPOINTS = [
    ROOT / "AGENTS.md",
    ROOT / "README.md",
    ROOT / "START_HERE.md",
    ROOT / "docs/BASE_RULES_VERSION.md",
    ROOT / "[기획서]/00_프로젝트_허브/START_HERE.md",
]


class ObservationAnswerLeakGuardrailsContractTest(unittest.TestCase):
    def run_checker(self, contract_path: Path = CONTRACT) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(CHECKER), "--contract", str(contract_path)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def load_contract(self) -> dict:
        return json.loads(CONTRACT.read_text(encoding="utf-8"))

    def mutate(self, edit) -> Path:
        data = self.load_contract()
        edit(data)
        temp = tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8")
        json.dump(data, temp, ensure_ascii=False, indent=2)
        temp.write("\n")
        temp.close()
        return Path(temp.name)

    def assert_mutation_rejected(self, edit, expected: str):
        mutated = self.mutate(edit)
        result = self.run_checker(mutated)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(expected, result.stdout + result.stderr)

    def test_contract_and_checker_exist(self):
        self.assertTrue(CONTRACT.is_file(), "approved observation contract is missing")
        self.assertTrue(CHECKER.is_file(), "observation contract checker is missing")

    def test_approved_contract_passes(self):
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("OBSERVATION_ANSWER_LEAK_GUARDRAILS_CONTRACT_PASS", result.stdout)

    def test_direct_front_to_back_reveal_is_preserved(self):
        data = self.load_contract()
        reveal = data["observation_reveal_contract"]
        self.assertEqual(reveal["payload"], "ACTUAL_ACTION_TYPES")
        self.assertEqual(reveal["spend_order"], "FRONT_TO_BACK")
        self.assertTrue(reveal["compound_action_types_all_displayed"])
        self.assertTrue(reveal["unlimited_storage"])
        self.assertTrue(reveal["cross_bundle_carryover"])

    def test_observation_has_explicit_slot_and_point_cost(self):
        data = self.load_contract()
        cost = data["observation_cost_contract"]
        self.assertEqual(cost["action_slots_spent"], 1)
        self.assertEqual(cost["observation_points_gained"], 1)
        self.assertEqual(cost["points_spent_per_revealed_slot"], 1)
        self.assertFalse(cost["stamina_or_internal_cost_added"])

    def test_enemy_plan_is_locked_before_reveal(self):
        data = self.load_contract()
        fairness = data["fairness_contract"]
        self.assertTrue(fairness["enemy_bundle_locked_before_reveal"])
        self.assertFalse(fairness["enemy_may_replan_after_reveal"])
        self.assertFalse(fairness["enemy_may_read_uncommitted_player_plan"])

    def test_rejects_weakening_direct_reveal(self):
        self.assert_mutation_rejected(
            lambda data: data["observation_reveal_contract"].update(
                {"payload": "TACTICAL_CLUE"}
            ),
            "DIRECT_REVEAL_RETENTION_CONFLICT",
        )

    def test_rejects_post_reveal_enemy_replanning(self):
        self.assert_mutation_rejected(
            lambda data: data["fairness_contract"].update(
                {"enemy_may_replan_after_reveal": True}
            ),
            "OBSERVATION_FAIRNESS_CONFLICT",
        )

    def test_rejects_exact_counter_recommendation(self):
        self.assert_mutation_rejected(
            lambda data: data["forbidden_outputs"].remove("RECOMMENDED_CORRECT_COUNTER"),
            "ANSWER_AUTOMATION_CONFLICT",
        )

    def test_rejects_automatic_nerf(self):
        self.assert_mutation_rejected(
            lambda data: data["risk_policy"].update({"automatic_nerf": True}),
            "AUTOMATIC_OBSERVATION_CHANGE_CONFLICT",
        )

    def test_requires_measurement_bundle(self):
        self.assert_mutation_rejected(
            lambda data: data["measurement_metrics"].remove("full_bundle_reveal_rate"),
            "OBSERVATION_MEASUREMENT_CONFLICT",
        )

    def test_mutable_state_is_owned_by_active_context(self):
        for path in STABLE_ENTRYPOINTS:
            text = path.read_text(encoding="utf-8")
            self.assertNotIn("active_planning_pr:", text, str(path))
            self.assertNotIn("active_planning_head:", text, str(path))
            self.assertNotIn("active_approval_count:", text, str(path))
            self.assertNotIn("next_planning_decision:", text, str(path))
            self.assertIn("ACTIVE_CONTEXT.md", text, str(path))

    def test_known_pr82_current_state_tokens_are_removed(self):
        game_design = (ROOT / "docs/01_GAME_DESIGN.md").read_text(encoding="utf-8")
        documentation_map = (
            ROOT / "[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md"
        ).read_text(encoding="utf-8")
        gates = (
            ROOT / "[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md"
        ).read_text(encoding="utf-8")
        self.assertNotIn("ACTIVE_DRAFT_PR82_APPROVED_PENDING_MERGE_2_OF_10", game_design)
        self.assertNotIn("현재 활성 승인 배치 | PR #82", documentation_map)
        self.assertNotIn("PASS_AT_PR82_HEAD", gates)

    def test_active_context_moves_to_eight_of_ten_and_grade_risk(self):
        active = (
            ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
        ).read_text(encoding="utf-8")
        self.assertIn("active_planning_pr: 92", active)
        self.assertIn("active_approval_count: 8/10", active)
        self.assertIn(
            "active_decision_state: APPROVED_DRAFT_OBSERVATION_ANSWER_LEAK_GUARDRAILS",
            active,
        )
        self.assertIn("next_planning_decision: GRADE_FARMING_RISK", active)
        self.assertIn("TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01", active)


if __name__ == "__main__":
    unittest.main()
