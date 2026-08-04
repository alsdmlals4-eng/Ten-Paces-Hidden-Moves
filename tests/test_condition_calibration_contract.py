import copy
import importlib.util
import json
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
VALIDATOR_PATH = ROOT / "tools" / "check_condition_calibration_contract.py"
PARENT_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_technique1_conditional_rework_star5_contract.json"
CALIBRATION_PATH = ROOT / "docs" / "planning-data" / "approved_20260805_condition_calibration_contract.json"
EXPECTED_BOUNDARIES = {0.00: "extreme", 0.15: "very_hard", 0.30: "hard", 0.50: "moderate", 0.70: "easy", 0.85: "quasi_certain", 1.00: "quasi_certain"}


def load_validator():
    spec = importlib.util.spec_from_file_location("condition_calibration_validator", VALIDATOR_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("condition calibration validator module cannot be loaded")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ConditionCalibrationContractTests(unittest.TestCase):
    def load_parent(self):
        return json.loads(PARENT_PATH.read_text(encoding="utf-8"))

    def load_calibration(self):
        return json.loads(CALIBRATION_PATH.read_text(encoding="utf-8"))

    def test_current_contract_passes_and_boundaries_are_deterministic(self):
        validator = load_validator()
        validator.validate(self.load_parent(), self.load_calibration())
        for rate, expected in EXPECTED_BOUNDARIES.items():
            self.assertEqual(expected, validator.difficulty_for_success_rate(rate, self.load_calibration()))

    def test_out_of_range_success_rates_are_rejected(self):
        validator = load_validator()
        for rate in (-0.001, 1.001):
            with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "success rate"):
                validator.difficulty_for_success_rate(rate, self.load_calibration())

    def test_quasi_certain_band_cannot_receive_discount(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_calibration())
        broken["difficulty_bands"]["quasi_certain"]["coefficient"] = 0.95
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "quasi-certain"):
            validator.validate(self.load_parent(), broken)

    def test_band_gap_or_overlap_is_rejected(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_calibration())
        broken["difficulty_bands"]["hard"]["max_exclusive"] = 0.49
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "band coverage"):
            validator.validate(self.load_parent(), broken)

    def test_parent_coefficient_drift_is_rejected(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_parent())
        broken["condition_coefficients"]["hard"] = 0.50
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "parent coefficient"):
            validator.validate(broken, self.load_calibration())

    def test_publicly_impossible_attempt_cannot_enter_price_denominator(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_calibration())
        broken["valid_attempt_contract"]["publicly_impossible_in_calibration_denominator"] = True
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "publicly impossible"):
            validator.validate(self.load_parent(), broken)

    def test_hidden_counterplay_failure_must_remain_valid_failure(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_calibration())
        broken["valid_attempt_contract"]["hidden_opponent_counterplay_failure_is_valid_failure"] = False
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "hidden counterplay"):
            validator.validate(self.load_parent(), broken)

    def test_automatic_repricing_is_rejected(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_calibration())
        broken["reclassification_contract"]["automatic_repricing"] = True
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "automatic repricing"):
            validator.validate(self.load_parent(), broken)

    def test_warning_and_reclassification_samples_cannot_be_reduced(self):
        validator = load_validator()
        warning = copy.deepcopy(self.load_calibration())
        warning["warning_gate"]["min_valid_attempts"] = 10
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "warning gate"):
            validator.validate(self.load_parent(), warning)
        reclass = copy.deepcopy(self.load_calibration())
        reclass["reclassification_gate"]["min_valid_attempts"] = 50
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "reclassification gate"):
            validator.validate(self.load_parent(), reclass)

    def test_failure_taxonomy_and_shared_trigger_deduplication_are_required(self):
        validator = load_validator()
        taxonomy = copy.deepcopy(self.load_calibration())
        taxonomy["failure_taxonomy"] = []
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "failure taxonomy"):
            validator.validate(self.load_parent(), taxonomy)
        counting = copy.deepcopy(self.load_calibration())
        counting["shared_trigger_counting"]["one_success_event_per_condition_group"] = False
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "shared trigger"):
            validator.validate(self.load_parent(), counting)

    def test_current_technique_declarations_cannot_change(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_calibration())
        broken["current_condition_groups"]["vajra_guard_full_absorb"]["declared_difficulty"] = "moderate"
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "current condition declaration"):
            validator.validate(self.load_parent(), broken)

    def test_false_human_validation_claim_is_rejected(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_calibration())
        broken["validation_boundary"]["human_validation"] = "PASS"
        with self.assertRaisesRegex(validator.ConditionCalibrationContractError, "human validation"):
            validator.validate(self.load_parent(), broken)


if __name__ == "__main__":
    unittest.main()
