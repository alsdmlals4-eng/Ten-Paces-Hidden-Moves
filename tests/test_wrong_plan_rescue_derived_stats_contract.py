import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "docs/planning-data/approved_20260805_wrong_plan_rescue_derived_stats_contract.json"
CHECKER = ROOT / "tools/check_wrong_plan_rescue_derived_stats_contract.py"


class WrongPlanRescueDerivedStatsContractTest(unittest.TestCase):
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

    def test_approved_contract_passes(self):
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_reference_values_are_30_5_4(self):
        data = self.load_contract()
        self.assertEqual(
            data["reference_outputs"],
            {"max_health": 30, "max_stamina": 5, "max_internal": 4},
        )

    def test_rejects_continuous_range_scaling(self):
        self.assert_mutation_rejected(
            lambda data: data["forbidden_continuous_structural_scaling"].remove("ATTACK_RANGE"),
            "ATTACK_RANGE",
        )

    def test_rejects_current_resource_fill_on_max_growth(self):
        self.assert_mutation_rejected(
            lambda data: data["max_change_policy"].update(
                {"fill_current_on_max_increase": True}
            ),
            "fill_current",
        )

    def test_rejects_legacy_attack_power_double_scaling(self):
        self.assert_mutation_rejected(
            lambda data: data["legacy_attack_power"].update(
                {"may_add_to_stat_scaled_actions": True}
            ),
            "DOUBLE_SCALING_CONFLICT",
        )

    def test_outcome_reversal_and_major_rescue_are_exclusive(self):
        data = self.load_contract()
        policy = data["rescue_classification"]
        self.assertTrue(policy["outcome_reversal_precedes_major_rescue"])
        self.assertFalse(policy["allow_double_count"])

    def test_normalization_preserves_missing_and_spent_amounts(self):
        data = self.load_contract()
        normalization = data["counterfactual_normalization"]
        self.assertEqual(
            normalization["health"],
            "clamp(reference_max_health - missing_health, 0, reference_max_health)",
        )
        self.assertEqual(
            normalization["stamina"],
            "clamp(reference_max_stamina - spent_stamina, 0, reference_max_stamina)",
        )
        self.assertEqual(
            normalization["internal"],
            "clamp(reference_max_internal - spent_internal, 0, reference_max_internal)",
        )

    def test_rejects_passive_global_damage_reduction(self):
        self.assert_mutation_rejected(
            lambda data: data["derived_stats"]["constitution"].update(
                {"passive_global_damage_reduction": True}
            ),
            "PASSIVE_DEFENSE_RESCUE_CONFLICT",
        )

    def test_rejects_hidden_plan_access_from_insight(self):
        self.assert_mutation_rejected(
            lambda data: data["derived_stats"]["insight"].update(
                {"hidden_plan_access": True}
            ),
            "HIDDEN_PLAN_ACCESS",
        )

    def test_rejects_automatic_correct_counter_from_insight(self):
        self.assert_mutation_rejected(
            lambda data: data["derived_stats"]["insight"].update(
                {"automatic_correct_counter": True}
            ),
            "AUTOMATIC_CORRECT_COUNTER",
        )

    def test_rejects_counterfactual_rng_drift(self):
        self.assert_mutation_rejected(
            lambda data: data["counterfactual_contract"].update(
                {"same_rng_seed_and_consumption_order": False}
            ),
            "COUNTERFACTUAL_REPLAY_CONFLICT",
        )

    def test_rejects_missing_wrong_plan_reason_code(self):
        self.assert_mutation_rejected(
            lambda data: data["wrong_plan_reason_codes"].remove("MISSING_DEFENSE_RESPONSE"),
            "MISSING_DEFENSE_RESPONSE",
        )

    def test_rejects_truncated_uncapped_sanity_points(self):
        self.assert_mutation_rejected(
            lambda data: data["sanity_stat_points"].remove(20),
            "UNCAPPED_SANITY_BAND_CONFLICT",
        )

    def test_rejects_stat_adjustment_before_success_gates(self):
        self.assert_mutation_rejected(
            lambda data: data.update(
                {
                    "resolution_order": [
                        "LEGALITY",
                        "STAT_NUMERIC_ADJUSTMENT",
                        "DISTANCE_ORDER_MOVEMENT_INTERRUPTION",
                        "SUCCESS_GATES",
                        "COUNTERFACTUAL_REPLAY",
                        "RESCUE_CLASSIFICATION",
                    ]
                }
            ),
            "resolution order",
        )


if __name__ == "__main__":
    unittest.main()
