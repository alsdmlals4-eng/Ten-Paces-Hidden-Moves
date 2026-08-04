#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONTRACT = ROOT / "docs/planning-data/approved_20260805_wrong_plan_rescue_derived_stats_contract.json"
UNCAPPED = ROOT / "docs/planning-data/approved_20260803_uncapped_core_stats_contract.json"
REFERENCE = ROOT / "docs/planning-data/approved_20260802_stat_reference_price_base4_contract.json"
BASIC_ATTACKS = ROOT / "docs/planning-data/approved_20260802_basic_attack_formulas_slot_budget_contract.json"

REQUIRED_STRUCTURAL = {
    "MOVE_DISTANCE",
    "ATTACK_RANGE",
    "ACTION_SLOTS",
    "HIT_COUNT",
    "EVADE_COUNT",
    "TARGETING_PERMISSION",
    "SURE_HIT",
    "HIDDEN_PLAN_ACCESS",
}


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def max_health(constitution: int) -> int:
    return 26 + constitution


def max_stamina(agility: int) -> int:
    return 4 + agility // 4


def max_internal(internal_power: int) -> int:
    return 3 + internal_power // 4


def normalize_pool(actual_max: int, actual_current: int, reference_max: int) -> int:
    spent = actual_max - actual_current
    return max(0, min(reference_max, reference_max - spent))


def classify_rescue(reference: dict[str, Any], actual: dict[str, Any]) -> str:
    bad_reference = reference.get("outcome") in {"FAILURE", "DEFEAT", "DEATH"}
    good_actual = actual.get("outcome") in {"SUCCESS", "VICTORY", "SURVIVAL"}
    if bad_reference and good_actual:
        return "OUTCOME_REVERSAL"

    reference_loss = max(0, int(reference.get("health_loss", 0)))
    actual_loss = max(0, int(actual.get("health_loss", 0)))
    loss_reduction = 0.0 if reference_loss == 0 else (reference_loss - actual_loss) / reference_loss
    severity_reduction = int(reference.get("severity", 0)) - int(actual.get("severity", 0))
    if loss_reduction >= 0.5 or severity_reduction >= 2:
        return "MAJOR_RESCUE"
    return "NO_RESCUE"


def validate_contract(contract: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    if contract.get("decision_id") != "TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01":
        errors.append("PARENT_AUTHORITY_CONFLICT decision_id")
    if contract.get("reference_stat") != 4:
        errors.append("PARENT_AUTHORITY_CONFLICT reference_stat must be 4")

    derived = contract.get("derived_stats", {})
    if derived.get("constitution", {}).get("max_health_formula") != "26 + constitution":
        errors.append("DERIVED_STAT_FORMULA_CONFLICT max_health")
    if derived.get("agility", {}).get("max_stamina_formula") != "4 + floor(agility / 4)":
        errors.append("DERIVED_STAT_FORMULA_CONFLICT max_stamina")
    if derived.get("internal_power", {}).get("max_internal_formula") != "3 + floor(internal_power / 4)":
        errors.append("DERIVED_STAT_FORMULA_CONFLICT max_internal")

    expected_reference = {"max_health": 30, "max_stamina": 5, "max_internal": 4}
    if contract.get("reference_outputs") != expected_reference:
        errors.append("DERIVED_STAT_FORMULA_CONFLICT reference_outputs")

    points = contract.get("sanity_stat_points", [])
    expected = {
        "max_health": [max_health(x) for x in points],
        "max_stamina": [max_stamina(x) for x in points],
        "max_internal": [max_internal(x) for x in points],
    }
    if contract.get("sanity_outputs") != expected:
        errors.append("DERIVED_STAT_FORMULA_CONFLICT sanity_outputs")

    present_structural = set(contract.get("forbidden_continuous_structural_scaling", []))
    for missing in sorted(REQUIRED_STRUCTURAL - present_structural):
        errors.append(f"STRUCTURAL_SCALING_CONFLICT missing {missing}")

    max_policy = contract.get("max_change_policy", {})
    if max_policy.get("fill_current_on_max_increase") is not False:
        errors.append("CURRENT_RESOURCE_FILL_CONFLICT fill_current_on_max_increase")
    if max_policy.get("preserve_missing_or_spent_amount") is not True:
        errors.append("COUNTERFACTUAL_NORMALIZATION_CONFLICT preserve_missing_or_spent_amount")
    if max_policy.get("threshold_step") != 4 or max_policy.get("thresholds_continue_uncapped") is not True:
        errors.append("DERIVED_STAT_FORMULA_CONFLICT uncapped threshold progression")

    expected_norm = {
        "health": "clamp(reference_max_health - missing_health, 0, reference_max_health)",
        "stamina": "clamp(reference_max_stamina - spent_stamina, 0, reference_max_stamina)",
        "internal": "clamp(reference_max_internal - spent_internal, 0, reference_max_internal)",
    }
    if contract.get("counterfactual_normalization") != expected_norm:
        errors.append("COUNTERFACTUAL_NORMALIZATION_CONFLICT formulas")

    rescue = contract.get("rescue_classification", {})
    if rescue.get("outcome_reversal_precedes_major_rescue") is not True:
        errors.append("RESCUE_CLASSIFICATION_CONFLICT precedence")
    if rescue.get("allow_double_count") is not False:
        errors.append("RESCUE_CLASSIFICATION_CONFLICT double_count")
    if rescue.get("major_health_loss_reduction_ratio") != 0.5:
        errors.append("RESCUE_CLASSIFICATION_CONFLICT health threshold")
    if rescue.get("major_severity_step_reduction") != 2:
        errors.append("RESCUE_CLASSIFICATION_CONFLICT severity threshold")
    if rescue.get("severity_scale") != [0, 1, 2, 3, 4]:
        errors.append("RESCUE_CLASSIFICATION_CONFLICT severity scale")

    legacy = contract.get("legacy_attack_power", {})
    if legacy.get("may_add_to_stat_scaled_actions") is not False:
        errors.append("DOUBLE_SCALING_CONFLICT legacy attack_power may not be added")
    if legacy.get("conflict_code") != "DOUBLE_SCALING_CONFLICT":
        errors.append("DOUBLE_SCALING_CONFLICT missing conflict code")

    order = contract.get("resolution_order", [])
    expected_order = [
        "LEGALITY",
        "DISTANCE_ORDER_MOVEMENT_INTERRUPTION",
        "SUCCESS_GATES",
        "STAT_NUMERIC_ADJUSTMENT",
        "COUNTERFACTUAL_REPLAY",
        "RESCUE_CLASSIFICATION",
    ]
    if order != expected_order:
        errors.append("STRUCTURAL_SCALING_CONFLICT resolution order")

    try:
        uncapped = load_json(UNCAPPED)
        reference = load_json(REFERENCE)
        basic = load_json(BASIC_ATTACKS)
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"PARENT_AUTHORITY_CONFLICT cannot load parent: {exc}")
        return errors

    if uncapped.get("cap_policy", {}).get("designed_hard_cap") is not None:
        errors.append("PARENT_AUTHORITY_CONFLICT core stats must remain uncapped")
    if uncapped.get("cap_policy", {}).get("clamp_at_legacy_15") is not False:
        errors.append("PARENT_AUTHORITY_CONFLICT legacy 15 clamp")
    if reference.get("balance_reference_stat") != 4:
        errors.append("PARENT_AUTHORITY_CONFLICT pricing reference stat")
    if basic.get("formulas", {}).get("quick_attack", {}).get("stat") != "external_power":
        errors.append("PARENT_AUTHORITY_CONFLICT quick attack stat")
    if basic.get("formulas", {}).get("basic_palm", {}).get("stat") != "internal_power":
        errors.append("PARENT_AUTHORITY_CONFLICT basic palm stat")

    if max_health(4) != 30 or max_stamina(4) != 5 or max_internal(4) != 4:
        errors.append("DERIVED_STAT_FORMULA_CONFLICT helper reference outputs")
    if normalize_pool(7, 5, 5) != 3:
        errors.append("COUNTERFACTUAL_NORMALIZATION_CONFLICT helper")
    if classify_rescue({"outcome": "DEFEAT", "health_loss": 8, "severity": 4}, {"outcome": "VICTORY", "health_loss": 1, "severity": 0}) != "OUTCOME_REVERSAL":
        errors.append("RESCUE_CLASSIFICATION_CONFLICT outcome reversal helper")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=Path, default=DEFAULT_CONTRACT)
    args = parser.parse_args()

    try:
        contract = load_json(args.contract)
    except (OSError, json.JSONDecodeError) as exc:
        print(f"PARENT_AUTHORITY_CONFLICT cannot load contract: {exc}")
        return 1

    errors = validate_contract(contract)
    if errors:
        for error in errors:
            print(error)
        return 1

    print("WRONG_PLAN_RESCUE_DERIVED_STATS_CONTRACT_PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
