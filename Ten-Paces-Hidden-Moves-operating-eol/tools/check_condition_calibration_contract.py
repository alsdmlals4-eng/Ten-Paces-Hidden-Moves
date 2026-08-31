#!/usr/bin/env python3
from __future__ import annotations

import json
import pathlib
import sys
from typing import Any

ROOT = pathlib.Path(__file__).resolve().parents[1]
PARENT_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_technique1_conditional_rework_star5_contract.json"
CALIBRATION_PATH = ROOT / "docs" / "planning-data" / "approved_20260805_condition_calibration_contract.json"

BAND_ORDER = ["extreme", "very_hard", "hard", "moderate", "easy", "quasi_certain"]
EXPECTED_PARENT_COEFFICIENTS = {"easy": 0.85, "moderate": 0.70, "hard": 0.55, "very_hard": 0.40, "extreme": 0.25}
EXPECTED_BANDS = {
    "extreme": (0.00, 0.15, 0.25),
    "very_hard": (0.15, 0.30, 0.40),
    "hard": (0.30, 0.50, 0.55),
    "moderate": (0.50, 0.70, 0.70),
    "easy": (0.70, 0.85, 0.85),
    "quasi_certain": (0.85, 1.00, 1.00),
}
EXPECTED_FAILURE_TAXONOMY = [
    "PUBLIC_STATE_MISMATCH", "PREDICTION_MISS", "POSITION_FAILURE", "INTERRUPTED",
    "EVADED_OR_MISSED", "NO_HEALTH_DAMAGE", "PARTIAL_CHAIN_FAILURE", "SUCCESS",
]
EXPECTED_GROUPS = {
    "flowing_cloud_hit2": ("flowing_cloud_triple", "HIT1_REAL_HEALTH_DAMAGE", "moderate"),
    "flowing_cloud_hit3": ("flowing_cloud_triple", "HIT1_AND_HIT2_REAL_HEALTH_DAMAGE", "very_hard"),
    "flowing_cloud_retreat": ("flowing_cloud_triple", "ALL_THREE_HITS_REAL_HEALTH_DAMAGE", "extreme"),
    "vajra_guard_full_absorb": ("vajra_guard", "REAL_ATTACK_FULLY_ABSORBED_BEFORE_NEXT_OWN_ACTION", "hard"),
    "cloud_hand_return_evade": ("cloud_hand_return", "SUCCESSFULLY_EVADE_REAL_EFFECTIVE_ATTACK", "hard"),
    "pursuing_wind_spear_tip": ("pursuing_wind_thrust", "FULL_ADVANCE_AND_EXACT_RANGE_2_AND_REAL_HEALTH_DAMAGE", "very_hard"),
    "clear_heart_low_resource": ("clear_heart_breath", "PRE_ACTION_STAMINA_PLUS_INTERNAL_LE_1", "very_hard"),
    "iron_step_complete_escape": ("iron_step_drift", "SUCCESSFULLY_EVADE_REAL_ATTACK_AND_COMPLETE_SECOND_RETREAT_TILE", "hard"),
}
REQUIRED_STAR9_FIELDS = {
    "declared_difficulty", "coefficient", "public_trigger", "valid_attempt_definition", "success_event",
    "failure_points", "opponent_counterplay", "all_or_nothing_scope", "high_ceiling", "low_floor",
    "measurement_metrics", "reclassification_gate",
}


class ConditionCalibrationContractError(ValueError):
    pass


def _require(condition: bool, message: str) -> None:
    if not condition:
        raise ConditionCalibrationContractError(message)


def _same_number(actual: Any, expected: float) -> bool:
    return isinstance(actual, (int, float)) and not isinstance(actual, bool) and abs(float(actual) - expected) < 1e-9


def difficulty_for_success_rate(rate: float, calibration: dict[str, Any]) -> str:
    _require(isinstance(rate, (int, float)) and not isinstance(rate, bool), "success rate must be numeric")
    value = float(rate)
    _require(0.0 <= value <= 1.0, "success rate must be within 0..1")
    bands = calibration.get("difficulty_bands", {})
    for name in BAND_ORDER[:-1]:
        band = bands.get(name, {})
        if float(band.get("min_inclusive", -1.0)) <= value < float(band.get("max_exclusive", -1.0)):
            return name
    final = bands.get("quasi_certain", {})
    if float(final.get("min_inclusive", -1.0)) <= value <= float(final.get("max_inclusive", -1.0)):
        return "quasi_certain"
    raise ConditionCalibrationContractError("success rate is not covered by difficulty bands")


def _parent_components(parent: dict[str, Any]) -> set[tuple[str, str, str]]:
    found: set[tuple[str, str, str]] = set()
    for technique_id, technique in parent.get("techniques", {}).items():
        for section_name in ("base_design", "star5_patch"):
            for component in technique.get(section_name, {}).get("components", []):
                condition = component.get("condition")
                difficulty = component.get("difficulty")
                if condition and difficulty and difficulty != "none":
                    found.add((technique_id, condition, difficulty))
    return found


def validate(parent: dict[str, Any], calibration: dict[str, Any]) -> None:
    _require(parent.get("decision_id") == "TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01", "wrong parent decision")
    _require(calibration.get("decision_id") == "TEN-DEC-20260805-CONDITION-CALIBRATION-01", "wrong calibration decision")
    _require(calibration.get("authority_status") == "CURRENT_APPROVED_PLANNING_GOVERNANCE", "wrong calibration authority")
    _require(calibration.get("risk_status") == "MITIGATED_PENDING_HUMAN_MEASUREMENT", "wrong calibration risk status")
    _require(calibration.get("parent_decision_id") == parent.get("decision_id"), "calibration parent decision mismatch")

    parent_coefficients = parent.get("condition_coefficients", {})
    _require(parent_coefficients == EXPECTED_PARENT_COEFFICIENTS, "parent coefficient drift")

    bands = calibration.get("difficulty_bands", {})
    _require(set(bands) == set(BAND_ORDER), "band coverage differs")
    previous_max = 0.0
    for index, name in enumerate(BAND_ORDER):
        band = bands[name]
        expected_min, expected_max, expected_coefficient = EXPECTED_BANDS[name]
        _require(_same_number(band.get("min_inclusive"), expected_min), "band coverage min differs")
        max_key = "max_inclusive" if name == "quasi_certain" else "max_exclusive"
        _require(_same_number(band.get(max_key), expected_max), "band coverage max differs")
        _require(_same_number(expected_min, previous_max), "band coverage has a gap or overlap")
        if name == "quasi_certain":
            _require(_same_number(band.get("coefficient"), 1.0), "quasi-certain condition cannot receive a discount")
        else:
            _require(_same_number(band.get("coefficient"), expected_coefficient), "difficulty coefficient differs")
            _require(_same_number(band.get("coefficient"), EXPECTED_PARENT_COEFFICIENTS[name]), "parent coefficient and calibration band differ")
        previous_max = expected_max
        if index < len(BAND_ORDER) - 1:
            _require("max_inclusive" not in band, "non-final band cannot include its upper boundary")
    _require(_same_number(previous_max, 1.0), "band coverage must end at 1")

    for boundary, expected in ((0.0, "extreme"), (0.15, "very_hard"), (0.30, "hard"), (0.50, "moderate"), (0.70, "easy"), (0.85, "quasi_certain"), (1.0, "quasi_certain")):
        _require(difficulty_for_success_rate(boundary, calibration) == expected, "difficulty boundary classification differs")

    measurement = calibration.get("measurement_contract", {})
    _require(measurement.get("pricing_reclassification_basis") == "valid_attempt_success_rate", "valid-attempt pricing basis missing")
    _require("legally_committed_uses" in measurement.get("overall_use_success_rate", ""), "overall-use denominator missing")
    _require("attempts_possible_from_public_state_at_commit" in measurement.get("valid_attempt_success_rate", ""), "valid-attempt denominator missing")

    valid_attempt = calibration.get("valid_attempt_contract", {})
    _require(valid_attempt.get("publicly_impossible_in_calibration_denominator") is False, "publicly impossible attempts cannot enter calibration denominator")
    _require(valid_attempt.get("publicly_impossible_retained_as_misuse_metric") is True, "publicly impossible attempt diagnostic missing")
    _require(valid_attempt.get("hidden_opponent_counterplay_failure_is_valid_failure") is True, "hidden counterplay failure must remain a valid failure")
    _require(valid_attempt.get("debug_forced_outcomes_excluded") is True, "debug forced outcomes must be excluded")
    _require(valid_attempt.get("abandoned_or_force_terminated_battles_excluded") is True, "unfinished battles must be excluded")

    _require(calibration.get("failure_taxonomy") == EXPECTED_FAILURE_TAXONOMY, "failure taxonomy differs")
    counting = calibration.get("shared_trigger_counting", {})
    _require(counting.get("one_success_event_per_condition_group") is True, "shared trigger must count one success event")
    _require(counting.get("parent_and_star5_patch_do_not_double_count") is True, "shared trigger parent and patch double counting is forbidden")

    warning = calibration.get("warning_gate", {})
    _require(warning.get("min_valid_attempts") == 30 and warning.get("min_distinct_battles") == 10 and warning.get("min_band_deviation_percentage_points") == 10, "warning gate differs")
    _require(warning.get("effect") == "CALIBRATION_WARNING_ONLY", "warning gate cannot reprice")

    reclassification = calibration.get("reclassification_gate", {})
    _require(reclassification.get("min_valid_attempts") == 100 and reclassification.get("min_distinct_battles") == 30 and reclassification.get("consecutive_batch_min_valid_attempts") == 50 and reclassification.get("consecutive_batch_min_distinct_battles") == 15, "reclassification gate differs")
    _require(set(reclassification.get("evidence_any_of", [])) == {"WILSON_95_CI_ENTIRELY_OUTSIDE_DECLARED_BAND", "TWO_CONSECUTIVE_SAME_DIRECTION_BATCHES"}, "reclassification evidence differs")

    policy = calibration.get("reclassification_contract", {})
    _require(policy.get("automatic_repricing") is False and policy.get("live_repricing") is False, "automatic repricing is forbidden")
    _require(policy.get("separate_decision_required") is True, "reclassification requires a separate decision")
    _require(policy.get("before_after_budget_table_required") is True, "reclassification budget comparison missing")
    _require(policy.get("current_values_change_without_approval") is False, "current values cannot change without approval")

    groups = calibration.get("current_condition_groups", {})
    _require(set(groups) == set(EXPECTED_GROUPS), "current condition group coverage differs")
    parent_components = _parent_components(parent)
    for group_id, expected in EXPECTED_GROUPS.items():
        group = groups[group_id]
        actual = (group.get("technique_id"), group.get("condition"), group.get("declared_difficulty"))
        _require(actual == expected, f"current condition declaration differs: {group_id}")
        _require(expected in parent_components, f"parent condition declaration missing: {group_id}")

    freeze = calibration.get("current_technique_freeze", {})
    _require(all(value is False for value in freeze.values()), "current technique values changed")
    _require(REQUIRED_STAR9_FIELDS.issubset(set(calibration.get("star9_required_fields", []))), "Star9 condition template fields missing")

    runtime = calibration.get("runtime_boundary", {})
    _require(runtime and all(value is False for value in runtime.values()), "runtime boundary changed")
    boundary = calibration.get("validation_boundary", {})
    _require(boundary.get("human_validation") == "NOT_RUN", "human validation must remain NOT_RUN")
    for key in ("balance_validation", "godot_validation", "windows_validation", "accessibility_validation", "performance_validation"):
        _require(boundary.get(key) == "NOT_RUN", f"{key} must remain NOT_RUN")


def main() -> int:
    try:
        parent = json.loads(PARENT_PATH.read_text(encoding="utf-8"))
        calibration = json.loads(CALIBRATION_PATH.read_text(encoding="utf-8"))
        validate(parent, calibration)
    except (OSError, json.JSONDecodeError, ConditionCalibrationContractError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("PASS: condition calibration contract is valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
