#!/usr/bin/env python3
import json
import math
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_technique1_conditional_rework_star5_contract.json"
REPRICE_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_existing_action_reprice_contract.json"

EXPECTED_IDS = {
    "flowing_cloud_triple",
    "vajra_guard",
    "cloud_hand_return",
    "pursuing_wind_thrust",
    "clear_heart_breath",
    "iron_step_drift",
}

EXPECTED_EFFECTIVE = {
    "flowing_cloud_triple": (2, 1, 1, 61),
    "vajra_guard": (1, 1, 1, 31),
    "cloud_hand_return": (1, 2, 1, 40),
    "pursuing_wind_thrust": (1, 1, 3, 45),
    "clear_heart_breath": (1, 0, 0, 24),
    "iron_step_drift": (1, 3, 2, 46),
}

EXPECTED_BUDGETS = {
    "flowing_cloud_triple": (58, -3, 12, 11, -1),
    "vajra_guard": (31, 0, 6, 5, -1),
    "cloud_hand_return": (38, -2, 8, 7, -1),
    "pursuing_wind_thrust": (50, 5, 9, 9, 0),
    "clear_heart_breath": (22, -2, 5, 5, 0),
    "iron_step_drift": (48, 2, 9, 8, -1),
}

EXPECTED_COEFFICIENTS = {
    "easy": 0.85,
    "moderate": 0.70,
    "hard": 0.55,
    "very_hard": 0.40,
    "extreme": 0.25,
}


class Technique1ContractError(ValueError):
    pass


def _require(condition: bool, message: str) -> None:
    if not condition:
        raise Technique1ContractError(message)


def round_half_up(value: float) -> int:
    return int(math.floor(value + 0.5))


def split_three_hit_damage(total_damage: int) -> tuple[int, int, int]:
    _require(isinstance(total_damage, int) and total_damage >= 0, "total damage must be a non-negative integer")
    hit1 = math.floor(total_damage * 0.40)
    hit2 = math.floor(total_damage * 0.30)
    hit3 = total_damage - hit1 - hit2
    return hit1, hit2, hit3


def _validate_components(components: list[dict], context: str) -> int:
    total = 0
    for component in components:
        raw = component.get("raw_ticks")
        coefficient = component.get("coefficient")
        priced = component.get("priced_ticks")
        _require(isinstance(raw, int) and raw >= 0, f"{context}: invalid raw ticks")
        _require(isinstance(coefficient, (int, float)) and 0 < coefficient <= 1, f"{context}: invalid coefficient")
        expected = round_half_up(raw * float(coefficient))
        _require(priced == expected, f"{context}: priced ticks must be rounded once after bundle discount")
        if float(coefficient) < 1:
            _require(component.get("all_or_nothing") is True, f"{context}: conditional bundle must be all-or-nothing")
            _require(bool(component.get("condition")), f"{context}: conditional bundle must declare condition")
        total += priced
    return total


def _load_reprice_contract() -> dict:
    return json.loads(REPRICE_PATH.read_text(encoding="utf-8"))


def _validate_repricing_authority(reprice_data: dict) -> None:
    _require(
        reprice_data.get("decision_id") == "TEN-DEC-20260804-EXISTING-ACTIONS-REPRICE-01",
        "repricing authority decision id drift",
    )
    actions = reprice_data.get("actions", [])
    action_map = {item.get("action_id"): item for item in actions}
    _require(EXPECTED_IDS.issubset(action_map), "repricing authority is missing Technique1 actions")
    for technique_id, (slots, stamina, internal, available) in EXPECTED_EFFECTIVE.items():
        action = action_map[technique_id]
        costs = action.get("effective_costs", {})
        _require(action.get("effective_action_slots") == slots, f"{technique_id}: repricing authority slot drift")
        _require(costs.get("stamina", 0) == stamina, f"{technique_id}: repricing authority stamina drift")
        _require(costs.get("internal", 0) == internal, f"{technique_id}: repricing authority internal drift")
        _require(action.get("available_budget_ticks") == available, f"{technique_id}: repricing authority budget drift")


def validate(data: dict, reprice_data: dict | None = None) -> None:
    if reprice_data is None:
        reprice_data = _load_reprice_contract()
    _validate_repricing_authority(reprice_data)

    _require(data.get("decision_id") == "TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01", "wrong decision id")
    _require(data.get("authority_status") == "CURRENT_APPROVED_PLANNING", "wrong authority status")
    _require(data.get("condition_coefficients") == EXPECTED_COEFFICIENTS, "condition coefficients changed")
    _require(
        data.get("effective_cost_authority") == "docs/planning-data/approved_20260804_existing_action_reprice_contract.json",
        "Technique1 contract must name the repricing authority",
    )

    rules = data.get("condition_rules", {})
    _require(rules.get("conditional_bundle_all_or_nothing") is True, "conditional bundle must be all-or-nothing")
    _require(rules.get("partial_reward_on_failure") is False, "partial reward on condition failure is forbidden")
    _require(rules.get("carryover_on_failure") is False, "condition failure carryover is forbidden")
    _require(rules.get("substitution_on_failure") is False, "condition failure substitution is forbidden")
    _require(rules.get("conversion_on_failure") is False, "condition failure conversion is forbidden")
    _require(rules.get("self_created_prerequisite_credit_allowed") is False, "self-created prerequisite credit is forbidden")
    _require(rules.get("multiple_conditions_use_one_composite_coefficient") is True, "multiple conditions need one composite coefficient")
    _require(rules.get("round_once_after_bundle_discount") is True, "condition bundle must round once")

    star5 = data.get("star5_contract", {})
    _require(star5.get("free_bonus_ratio") == 0.20, "5-star free bonus ratio must be 20%")
    _require(star5.get("extra_slot_cost") == 0 and star5.get("extra_resource_cost") == 0, "5-star patch cannot add cost")

    multi = data.get("multi_hit_contract", {})
    _require(multi.get("calculate_total_damage_once") is True, "multi-hit must calculate total damage once")
    _require(multi.get("three_hit_distribution") == [0.40, 0.30, "remainder"], "multi-hit distribution changed")
    _require(multi.get("cancelled_damage_redistributed") is False, "cancelled damage cannot be redistributed")
    _require(multi.get("failed_hit_damage_carried_forward") is False, "failed hit damage cannot carry forward")
    _require(multi.get("stat_scaling_per_hit") is False and multi.get("rounding_per_hit_formula") is False, "per-hit scaling or rounding is forbidden")

    techniques = data.get("techniques", {})
    _require(set(techniques) == EXPECTED_IDS, "contract must contain exactly six canonical Technique1 IDs")

    for technique_id in sorted(EXPECTED_IDS):
        technique = techniques[technique_id]
        expected_slots, expected_stamina, expected_internal, expected_available = EXPECTED_EFFECTIVE[technique_id]
        _require(technique.get("effective_action_slots") == expected_slots, f"{technique_id}: effective slots drift")
        costs = technique.get("effective_costs", {})
        _require(costs.get("stamina", 0) == expected_stamina, f"{technique_id}: effective stamina cost drift")
        _require(costs.get("internal", 0) == expected_internal, f"{technique_id}: effective internal cost drift")
        _require(technique.get("available_budget_ticks") == expected_available, f"{technique_id}: available budget drift")

        base = technique.get("base_design", {})
        calculated_base = _validate_components(base.get("components", []), f"{technique_id} base")
        expected_base, expected_base_variance, expected_patch_budget, expected_patch, expected_patch_variance = EXPECTED_BUDGETS[technique_id]
        _require(calculated_base == expected_base == base.get("effect_cost_ticks"), f"{technique_id}: base effect cost drift")
        calculated_base_variance = calculated_base - expected_available
        _require(base.get("variance_ticks") == calculated_base_variance == expected_base_variance, f"{technique_id}: base variance drift")
        _require(abs(calculated_base_variance) <= 5, f"{technique_id}: base variance outside tolerance")

        patch = technique.get("star5_patch", {})
        calculated_patch_budget = round_half_up(expected_available * 0.20)
        _require(patch.get("budget_ticks") == calculated_patch_budget == expected_patch_budget, f"{technique_id}: 20% patch budget drift")
        calculated_patch = _validate_components(patch.get("components", []), f"{technique_id} 5-star patch")
        _require(calculated_patch == patch.get("priced_ticks") == expected_patch, f"{technique_id}: patch priced ticks drift")
        calculated_patch_variance = calculated_patch - calculated_patch_budget
        _require(patch.get("variance_ticks") == calculated_patch_variance == expected_patch_variance, f"{technique_id}: patch variance drift")
        _require(abs(calculated_patch_variance) <= 5, f"{technique_id}: patch variance outside tolerance")
        _require(patch.get("extra_slot_cost") == 0, f"{technique_id}: patch adds slot cost")
        _require(patch.get("extra_stamina_cost") == 0 and patch.get("extra_internal_cost") == 0, f"{technique_id}: patch adds resource cost")

    flowing = techniques["flowing_cloud_triple"]
    flow_multi = flowing.get("multi_hit", {})
    _require(flow_multi.get("calculate_once") is True, "Flowing Cloud must calculate total damage once")
    _require(flow_multi.get("reference_stat4_total_damage") == 14, "Flowing Cloud base total damage drift")
    _require(tuple(flow_multi.get("reference_stat4_hits", [])) == split_three_hit_damage(14) == (5, 4, 5), "Flowing Cloud base hit split drift")
    _require(flow_multi.get("cancelled_damage_redistributed") is False and flow_multi.get("failed_hit_damage_carried_forward") is False, "Flowing Cloud failed damage cannot move")
    flow_patch = flowing["star5_patch"]
    _require(flow_patch.get("total_damage_bonus") == 3, "Flowing Cloud 5-star total damage bonus drift")
    _require(flow_patch.get("reference_stat4_total_damage") == 17, "Flowing Cloud 5-star total damage drift")
    _require(tuple(flow_patch.get("reference_stat4_hits", [])) == split_three_hit_damage(17) == (6, 5, 6), "Flowing Cloud 5-star hit split drift")

    clear_condition = techniques["clear_heart_breath"]["base_design"]["components"][1]
    _require(clear_condition.get("condition_checked_before_own_gains") is True, "Clear Heart must snapshot resources before own gains")
    iron_condition = techniques["iron_step_drift"]["base_design"]["components"][2]
    _require(iron_condition.get("blocked_second_retreat_grants_momentum") is False, "Iron Step cannot grant momentum when second retreat fails")

    runtime = data.get("runtime_boundary", {})
    _require(runtime.get("html_poc_changed") is False, "HTML PoC must remain unchanged")
    _require(runtime.get("godot_runtime_changed") is False, "Godot runtime must remain unchanged")
    _require(runtime.get("runtime_game_data_changed") is False, "runtime game data must remain unchanged")


def main() -> int:
    try:
        data = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
        reprice_data = _load_reprice_contract()
        validate(data, reprice_data)
    except (OSError, json.JSONDecodeError, Technique1ContractError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("PASS: Technique1 conditional rework and 5-star contract is valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
