import copy
import importlib.util
import json
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
VALIDATOR_PATH = ROOT / "tools" / "check_work_governance_contract.py"
CONTRACT_PATH = ROOT / "docs" / "planning-data" / "approved_20260805_work_governance_contract.json"


def load_validator():
    spec = importlib.util.spec_from_file_location("work_governance_validator", VALIDATOR_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("work governance validator module cannot be loaded")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class WorkGovernanceContractTests(unittest.TestCase):
    def load_contract(self):
        return json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))

    def test_current_contract_passes(self):
        load_validator().validate(self.load_contract())

    def test_approval_batch_cannot_exceed_ten(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["approval_batch"]["maximum_approval_items"] = 11
        with self.assertRaisesRegex(validator.WorkGovernanceContractError, "approval batch"):
            validator.validate(broken)

    def test_all_early_checkpoint_triggers_are_required(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["checkpoint_policy"]["early_checkpoint_triggers"].remove("HIGH_RISK_CONFLICT")
        with self.assertRaisesRegex(validator.WorkGovernanceContractError, "checkpoint trigger"):
            validator.validate(broken)

    def test_tdd_cannot_be_optional(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["tdd_policy"]["required_for_every_task"] = False
        with self.assertRaisesRegex(validator.WorkGovernanceContractError, "TDD"):
            validator.validate(broken)

    def test_tdd_must_require_red_before_implementation(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["tdd_policy"]["required_sequence"] = ["GREEN", "REFACTOR"]
        with self.assertRaisesRegex(validator.WorkGovernanceContractError, "RED"):
            validator.validate(broken)

    def test_benchmarking_cannot_be_removed_from_material_work(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["benchmark_policy"]["required_for_material_questions_and_tasks"] = False
        with self.assertRaisesRegex(validator.WorkGovernanceContractError, "benchmark"):
            validator.validate(broken)

    def test_benchmark_recommendation_and_source_quality_are_required(self):
        validator = load_validator()
        broken_recommendation = copy.deepcopy(self.load_contract())
        broken_recommendation["benchmark_policy"]["recommendation_required"] = False
        with self.assertRaisesRegex(validator.WorkGovernanceContractError, "recommendation"):
            validator.validate(broken_recommendation)

        broken_source = copy.deepcopy(self.load_contract())
        broken_source["benchmark_policy"]["preferred_source_order"] = ["UNVERIFIED_SUMMARY"]
        with self.assertRaisesRegex(validator.WorkGovernanceContractError, "source order"):
            validator.validate(broken_source)

    def test_unavailable_comparable_must_be_disclosed_not_invented(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["benchmark_policy"]["when_no_reliable_comparable"] = "INVENT_REASONABLE_COMPARISON"
        with self.assertRaisesRegex(validator.WorkGovernanceContractError, "no reliable comparable"):
            validator.validate(broken)

    def test_non_executable_work_still_requires_a_failing_contract_check(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_contract())
        broken["tdd_policy"]["non_executable_work"] = "NO_TEST_REQUIRED"
        with self.assertRaisesRegex(validator.WorkGovernanceContractError, "non-executable"):
            validator.validate(broken)


if __name__ == "__main__":
    unittest.main()
