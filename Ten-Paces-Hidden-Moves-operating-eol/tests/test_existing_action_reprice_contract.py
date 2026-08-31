import copy
import importlib.util
import json
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
VALIDATOR_PATH = ROOT / "tools" / "check_existing_action_reprice_contract.py"
CONTRACT_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_existing_action_reprice_contract.json"

EXPECTED_ADJUSTMENTS = {
    "quick_attack": (1, 1, 0, 25, 24, 1),
    "heavy_attack": (2, 1, 2, 70, 68, 2),
    "basic_palm": (2, 0, 1, 60, 57, 3),
    "flowing_cloud_triple": (2, 1, 1, 58, 61, -3),
    "vajra_guard": (1, 1, 1, 30, 31, -1),
    "cloud_hand_return": (1, 2, 1, 42, 40, 2),
    "pursuing_wind_thrust": (1, 1, 3, 50, 45, 5),
    "clear_heart_breath": (1, 0, 0, 23, 24, -1),
    "iron_step_drift": (1, 3, 2, 48, 46, 2),
    "falling_petal_chasing_sword": (2, 2, 1, 70, 65, 5),
    "rebounding_vajra_fist": (2, 1, 1, 66, 65, 1),
    "four_ounces_move_thousand_pounds": (2, 1, 1, 68, 66, 2),
    "chained_road_lock": (2, 1, 3, 79, 75, 4),
    "returning_qi_meridian": (2, 1, 0, 60, 61, -1),
    "ten_paces_position_reversal": (3, 1, 1, 93, 96, -3),
}


def load_validator():
    spec = importlib.util.spec_from_file_location("existing_action_reprice_validator", VALIDATOR_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("validator module cannot be loaded")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ExistingActionRepriceContractTests(unittest.TestCase):
    def test_contract_covers_exactly_fifteen_approved_actions_with_expected_adjustments(self):
        validator = load_validator()
        data = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
        validator.validate(data)
        actual = {
            action["action_id"]: (
                action["effective_action_slots"],
                action["effective_costs"]["stamina"],
                action["effective_costs"]["internal"],
                action["effect_cost_ticks"],
                action["available_budget_ticks"],
                action["variance_ticks"],
            )
            for action in data["actions"]
        }
        self.assertEqual(EXPECTED_ADJUSTMENTS, actual)

    def test_validator_rejects_one_tick_of_unapproved_drift(self):
        validator = load_validator()
        data = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
        broken = copy.deepcopy(data)
        broken["actions"][0]["effect_cost_ticks"] += 1
        with self.assertRaisesRegex(validator.RepriceContractError, "effect cost"):
            validator.validate(broken)


if __name__ == "__main__":
    unittest.main()
