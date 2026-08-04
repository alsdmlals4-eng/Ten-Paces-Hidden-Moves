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
        mutated = self.mutate(
            lambda data: data["forbidden_continuous_structural_scaling"].remove("ATTACK_RANGE")
        )
        result = self.run_checker(mutated)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("ATTACK_RANGE", result.stdout + result.stderr)

    def test_rejects_current_resource_fill_on_max_growth(self):
        mutated = self.mutate(
            lambda data: data["max_change_policy"].update(
                {"fill_current_on_max_increase": True}
            )
        )
        result = self.run_checker(mutated)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("fill_current", result.stdout + result.stderr)

    def test_rejects_legacy_attack_power_double_scaling(self):
        mutated = self.mutate(
            lambda data: data["legacy_attack_power"].update(
                {"may_add_to_stat_scaled_actions": True}
            )
        )
        result = self.run_checker(mutated)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("DOUBLE_SCALING_CONFLICT", result.stdout + result.stderr)

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


if __name__ == "__main__":
    unittest.main()
