import copy
import importlib.util
import json
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
VALIDATOR_PATH = ROOT / "tools" / "check_resource_saturation_internal_recovery_contract.py"
PARENT_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_combat_pricing_interruption_recovery_contract.json"
OVERLAY_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_resource_saturation_internal_recovery_contract.json"

EXPECTED_EFFECTIVE_RECOVERY = {
    "stamina": 1,
    "internal": 0,
    "ultimate_momentum": 1,
}


def load_validator():
    spec = importlib.util.spec_from_file_location("resource_saturation_validator", VALIDATOR_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("resource saturation validator module cannot be loaded")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ResourceSaturationInternalRecoveryContractTests(unittest.TestCase):
    def load_parent(self):
        return json.loads(PARENT_PATH.read_text(encoding="utf-8"))

    def load_overlay(self):
        return json.loads(OVERLAY_PATH.read_text(encoding="utf-8"))

    def test_effective_bundle_transition_recovery_is_stamina1_internal0_momentum1(self):
        validator = load_validator()
        parent = self.load_parent()
        overlay = self.load_overlay()
        validator.validate(parent, overlay)
        self.assertEqual(
            EXPECTED_EFFECTIVE_RECOVERY,
            validator.effective_bundle_transition_recovery(parent, overlay),
        )

    def test_validator_rejects_internal_auto_recovery_drift(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_overlay())
        broken["effective_bundle_transition_recovery"]["internal"] = 1
        with self.assertRaisesRegex(validator.ResourceSaturationContractError, "internal auto recovery"):
            validator.validate(self.load_parent(), broken)

    def test_validator_rejects_separate_round_start_internal_recovery(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_overlay())
        broken["round_start_recovery"]["internal"] = 1
        with self.assertRaisesRegex(validator.ResourceSaturationContractError, "round-start internal"):
            validator.validate(self.load_parent(), broken)

    def test_validator_rejects_prepared_meditation_internal_removal(self):
        validator = load_validator()
        broken_parent = copy.deepcopy(self.load_parent())
        broken_parent["prepare"]["prepared_meditation_gain"]["internal"] = 0
        with self.assertRaisesRegex(validator.ResourceSaturationContractError, "prepared meditation"):
            validator.validate(broken_parent, self.load_overlay())

    def test_validator_rejects_parent_transition_list_drift(self):
        validator = load_validator()
        broken_parent = copy.deepcopy(self.load_parent())
        broken_parent["bundle_transition_recovery"]["transitions"].pop()
        with self.assertRaisesRegex(validator.ResourceSaturationContractError, "transition list"):
            validator.validate(broken_parent, self.load_overlay())

    def test_validator_rejects_false_human_validation_claim(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_overlay())
        broken["validation_boundary"]["human_validation"] = "PASS"
        with self.assertRaisesRegex(validator.ResourceSaturationContractError, "human validation"):
            validator.validate(self.load_parent(), broken)

    def test_validator_rejects_missing_internal_zero_softlock_fallbacks(self):
        validator = load_validator()
        broken = copy.deepcopy(self.load_overlay())
        broken["softlock_guard"]["legal_at_internal_zero"] = []
        with self.assertRaisesRegex(validator.ResourceSaturationContractError, "soft-lock"):
            validator.validate(self.load_parent(), broken)

    def test_canon_documents_are_synchronized(self):
        validator = load_validator()
        validator.validate_canon_documents(validator.load_canon_documents())

    def test_validator_rejects_stale_live_pr_pointer(self):
        validator = load_validator()
        broken = copy.deepcopy(validator.load_canon_documents())
        broken["active_context"] = broken["active_context"].replace(
            "active_project_pr: GITHUB_PR_METADATA_REFETCH_REQUIRED",
            "active_project_pr: 89",
        )
        with self.assertRaisesRegex(validator.ResourceSaturationContractError, "live PR"):
            validator.validate_canon_documents(broken)

    def test_validator_rejects_missing_field_level_superseded_marker(self):
        validator = load_validator()
        broken = copy.deepcopy(validator.load_canon_documents())
        broken["lifecycle"] = broken["lifecycle"].replace(
            "bundle_transition_recovery.internal=1` | `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`",
            "bundle_transition_recovery.internal=1` | `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01`",
        )
        with self.assertRaisesRegex(validator.ResourceSaturationContractError, "superseded field"):
            validator.validate_canon_documents(broken)


if __name__ == "__main__":
    unittest.main()
