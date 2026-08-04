import copy
import importlib.util
import json
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
VALIDATOR_PATH = ROOT / "tools" / "check_technique1_conditional_star5_contract.py"
CONTRACT_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_technique1_conditional_rework_star5_contract.json"

EXPECTED = {
    "flowing_cloud_triple": (58, 61, -3, 12, 11, -1),
    "vajra_guard": (31, 31, 0, 6, 5, -1),
    "cloud_hand_return": (38, 40, -2, 8, 7, -1),
    "pursuing_wind_thrust": (50, 45, 5, 9, 9, 0),
    "clear_heart_breath": (22, 24, -2, 5, 5, 0),
    "iron_step_drift": (48, 46, 2, 9, 8, -1),
}


def load_validator():
    spec = importlib.util.spec_from_file_location("technique1_conditional_star5_validator", VALIDATOR_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("validator module cannot be loaded")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class Technique1ConditionalStar5ContractTests(unittest.TestCase):
    def load_contract(self):
        return json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))

    def test_contract_has_exact_six_approved_techniques_and_budget_values(self):
        validator = load_validator()
        data = self.load_contract()
        validator.validate(data)
        actual = {
            technique_id: (
                technique["base_design"]["effect_cost_ticks"],
                technique["available_budget_ticks"],
                technique["base_design"]["variance_ticks"],
                technique["star5_patch"]["budget_ticks"],
                technique["star5_patch"]["priced_ticks"],
                technique["star5_patch"]["variance_ticks"],
            )
            for technique_id, technique in data["techniques"].items()
        }
        self.assertEqual(EXPECTED, actual)

    def test_validator_rejects_partial_reward_on_condition_failure(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["condition_rules"]["partial_reward_on_failure"] = True
        with self.assertRaisesRegex(validator.Technique1ContractError, "partial reward"):
            validator.validate(broken)

    def test_validator_rejects_per_hit_damage_calculation(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["multi_hit_contract"]["calculate_total_damage_once"] = False
        with self.assertRaisesRegex(validator.Technique1ContractError, "total damage"):
            validator.validate(broken)

    def test_validator_rejects_self_created_prerequisite_credit(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["condition_rules"]["self_created_prerequisite_credit_allowed"] = True
        with self.assertRaisesRegex(validator.Technique1ContractError, "self-created prerequisite"):
            validator.validate(broken)

    def test_validator_rejects_unapproved_star5_budget_drift(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["techniques"]["flowing_cloud_triple"]["star5_patch"]["budget_ticks"] += 1
        with self.assertRaisesRegex(validator.Technique1ContractError, "20% patch budget"):
            validator.validate(broken)

    def test_flowing_cloud_total_damage_is_split_40_30_remainder(self):
        validator = load_validator()
        self.assertEqual((5, 4, 5), validator.split_three_hit_damage(14))
        self.assertEqual((6, 5, 6), validator.split_three_hit_damage(17))
        self.assertEqual(14, sum(validator.split_three_hit_damage(14)))
        self.assertEqual(17, sum(validator.split_three_hit_damage(17)))


if __name__ == "__main__":
    unittest.main()
