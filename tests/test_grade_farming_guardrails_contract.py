import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "docs/planning-data/approved_20260805_grade_farming_guardrails_contract.json"
CHECKER = ROOT / "tools/check_grade_farming_guardrails_contract.py"


class GradeFarmingGuardrailsContractTest(unittest.TestCase):
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
        self.assertTrue(CONTRACT.is_file(), "approved grade-farming contract is missing")
        self.assertTrue(CHECKER.is_file(), "grade-farming contract checker is missing")

    def test_approved_contract_passes(self):
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("GRADE_FARMING_GUARDRAILS_CONTRACT_PASS", result.stdout)

    def test_raw_grade_events_are_preserved(self):
        raw = self.load_contract()["raw_event_contract"]
        self.assertTrue(raw["successful_dodges_record_all"])
        self.assertTrue(raw["clash_wins_record_all"])
        self.assertTrue(raw["health_loss_records_all"])
        self.assertTrue(raw["rounds_elapsed_records_all"])
        self.assertTrue(raw["ultimate_uses_record_all"])
        self.assertFalse(raw["combat_resolution_attenuated"])
        self.assertFalse(raw["replay_log_attenuated"])

    def test_repeat_and_action_instance_credit_contract(self):
        credit = self.load_contract()["defensive_credit_contract"]
        self.assertEqual(credit["identity_basis"], "CANONICAL_SOURCE_ID")
        self.assertEqual(credit["repeat_multipliers"], [1.0, 0.5, 0.0])
        self.assertEqual(credit["action_instance_combined_credit_cap"], 1.0)
        self.assertEqual(
            credit["multi_event_pool_distribution"],
            "EQUAL_SPLIT_ACROSS_QUALIFYING_EVENTS",
        )
        self.assertFalse(credit["hit_index_creates_new_identity"])

    def test_grade_metric_caps_are_fixed_poc_defaults(self):
        caps = self.load_contract()["metric_cap_contract"]
        self.assertEqual(caps["clash_credit_cap"], 3.0)
        self.assertEqual(caps["dodge_credit_cap"], 3.0)
        self.assertEqual(
            caps["normalized_clash_input"],
            "min(total_clash_credit,3.0)/3.0",
        )
        self.assertEqual(
            caps["normalized_dodge_input"],
            "min(total_dodge_credit,3.0)/3.0",
        )

    def test_scoring_window_stops_only_positive_credit(self):
        window = self.load_contract()["scoring_window_contract"]
        self.assertEqual(window["encounter_field"], "grade_target_rounds")
        self.assertEqual(window["default_grade_target_rounds"], 3)
        self.assertFalse(window["positive_credit_after_window"])
        self.assertTrue(window["raw_events_continue_after_window"])
        self.assertTrue(window["health_loss_continues_after_window"])
        self.assertTrue(window["round_count_continues_after_window"])

    def test_only_first_effective_ultimate_receives_credit(self):
        ultimate = self.load_contract()["ultimate_credit_contract"]
        self.assertEqual(ultimate["maximum_effective_ultimate_grade_credit"], 1)
        self.assertTrue(ultimate["must_resolve_within_scoring_window"])
        self.assertFalse(ultimate["cost_or_reservation_alone_qualifies"])
        self.assertEqual(
            set(ultimate["qualifying_non_cost_results"]),
            {
                "HEALTH_DAMAGE",
                "HEALING",
                "FORCED_MOVEMENT",
                "STATUS_APPLIED",
                "ATTACK_INTERRUPTED",
                "BENEFICIAL_RESOURCE_CHANGE",
            },
        )

    def test_grade_economy_link_is_blocked_before_human_gate(self):
        gate = self.load_contract()["economy_gate"]
        self.assertFalse(gate["grade_affects_run_currency"])
        self.assertFalse(gate["grade_affects_training"])
        self.assertFalse(gate["grade_affects_drops"])
        self.assertFalse(gate["grade_affects_permanent_currency"])
        self.assertTrue(gate["new_decision_required_for_reward_link"])

    def test_measurement_gate_is_complete(self):
        measurement = self.load_contract()["human_validation_gate"]
        self.assertEqual(measurement["minimum_completed_victories"], 30)
        self.assertEqual(measurement["minimum_distinct_encounters"], 5)
        self.assertEqual(measurement["maximum_single_encounter_sample_share"], 0.40)
        required = {
            "raw_to_effective_defensive_credit_ratio",
            "same_source_repeat_response_share",
            "post_window_positive_raw_event_share",
            "full_scoring_window_completion_rate",
            "observation_assisted_effective_credit_uplift",
            "average_rounds_elapsed",
            "p90_rounds_elapsed",
            "effective_ultimate_use_rate",
        }
        self.assertTrue(required.issubset(set(measurement["required_diagnostics"])))
        self.assertFalse(measurement["automatic_tuning_allowed"])

    def test_rejects_raw_event_attenuation(self):
        self.assert_mutation_rejected(
            lambda data: data["raw_event_contract"].update(
                {"clash_wins_record_all": False}
            ),
            "RAW_EVENT_PRESERVATION_CONFLICT",
        )

    def test_rejects_repeat_multiplier_drift(self):
        self.assert_mutation_rejected(
            lambda data: data["defensive_credit_contract"].update(
                {"repeat_multipliers": [1.0, 0.25, 0.0]}
            ),
            "REPEAT_ATTENUATION_CONFLICT",
        )

    def test_rejects_action_instance_credit_above_one(self):
        self.assert_mutation_rejected(
            lambda data: data["defensive_credit_contract"].update(
                {"action_instance_combined_credit_cap": 2.0}
            ),
            "ACTION_INSTANCE_CREDIT_CONFLICT",
        )

    def test_rejects_non_equal_multi_event_pool_distribution(self):
        self.assert_mutation_rejected(
            lambda data: data["defensive_credit_contract"].update(
                {"multi_event_pool_distribution": "EACH_EVENT_FULL_CREDIT"}
            ),
            "EVENT_POOL_SPLIT_CONFLICT",
        )

    def test_rejects_grade_metric_cap_drift(self):
        self.assert_mutation_rejected(
            lambda data: data["metric_cap_contract"].update(
                {"clash_credit_cap": 5.0}
            ),
            "GRADE_METRIC_CAP_CONFLICT",
        )

    def test_rejects_positive_credit_after_scoring_window(self):
        self.assert_mutation_rejected(
            lambda data: data["scoring_window_contract"].update(
                {"positive_credit_after_window": True}
            ),
            "GRADE_SCORING_WINDOW_CONFLICT",
        )

    def test_rejects_multiple_ultimate_grade_credits(self):
        self.assert_mutation_rejected(
            lambda data: data["ultimate_credit_contract"].update(
                {"maximum_effective_ultimate_grade_credit": 2}
            ),
            "ULTIMATE_GRADE_CREDIT_CONFLICT",
        )

    def test_rejects_premature_grade_economy_link(self):
        self.assert_mutation_rejected(
            lambda data: data["economy_gate"].update(
                {"grade_affects_run_currency": True}
            ),
            "GRADE_ECONOMY_GATE_CONFLICT",
        )

    def test_rejects_missing_measurement_diagnostic(self):
        self.assert_mutation_rejected(
            lambda data: data["human_validation_gate"]["required_diagnostics"].remove(
                "same_source_repeat_response_share"
            ),
            "GRADE_MEASUREMENT_CONFLICT",
        )

    def test_active_context_moves_to_nine_of_ten_and_star9_template(self):
        active = (
            ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
        ).read_text(encoding="utf-8")
        self.assertIn("active_planning_pr: 92", active)
        self.assertIn("active_approval_count: 9/10", active)
        self.assertIn(
            "active_decision_state: APPROVED_DRAFT_GRADE_FARMING_GUARDRAILS",
            active,
        )
        self.assertIn(
            "next_planning_decision: STAR9_PUBLIC_READ_BRANCH_TEMPLATE",
            active,
        )
        self.assertIn("TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01", active)


if __name__ == "__main__":
    unittest.main()
