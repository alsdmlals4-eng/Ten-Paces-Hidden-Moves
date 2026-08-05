#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import pathlib
import sys
from typing import Any

ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_CONTRACT = ROOT / "docs/planning-data/approved_20260805_star7_star9_mastery_bonus_contract.json"
SOURCE_CONTRACT = ROOT / "docs/planning-data/approved_20260804_existing_action_reprice_contract.json"

EXPECTED_IDS = {
    "falling_petal_chasing_sword",
    "rebounding_vajra_fist",
    "four_ounces_move_thousand_pounds",
    "chained_road_lock",
    "returning_qi_meridian",
    "ten_paces_position_reversal",
}


class MasteryContractError(ValueError):
    pass


def require(condition: bool, code: str, detail: str) -> None:
    if not condition:
        raise MasteryContractError(f"{code}: {detail}")


def load_json(path: pathlib.Path, missing_code: str) -> dict[str, Any]:
    require(path.is_file(), missing_code, str(path))
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise MasteryContractError(f"{missing_code}_JSON_INVALID: {exc}") from exc
    require(isinstance(data, dict), missing_code, "root must be object")
    return data


def validate_metadata(data: dict[str, Any]) -> None:
    require(data.get("schema_version") == 1, "MASTERY_METADATA_CONFLICT", "schema_version")
    require(
        data.get("decision_id") == "TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01",
        "MASTERY_METADATA_CONFLICT",
        "decision_id",
    )
    require(
        data.get("authority_status") == "CURRENT_APPROVED_PLANNING_GOVERNANCE",
        "MASTERY_METADATA_CONFLICT",
        "authority_status",
    )
    require(data.get("implementation_authority") == "PLANNING_ONLY", "MASTERY_SCOPE_CONFLICT", "implementation_authority")
    require(data.get("active_approval_count") == "10/10", "MASTERY_METADATA_CONFLICT", "active_approval_count")
    require(
        data.get("next_planning_decision") == "SIX_STAR7_MASTERY_BONUS_ALLOCATIONS",
        "MASTERY_METADATA_CONFLICT",
        "next_planning_decision",
    )


def effective_source_budgets(source: dict[str, Any]) -> dict[str, int]:
    rows = source.get("actions", [])
    require(isinstance(rows, list), "MASTERY_SOURCE_CONFLICT", "actions must be list")
    result: dict[str, int] = {}
    for row in rows:
        if isinstance(row, dict) and row.get("category") == "technique_2":
            action_id = row.get("action_id")
            budget = row.get("available_budget_ticks")
            require(isinstance(action_id, str), "MASTERY_SOURCE_CONFLICT", "technique_2 action_id")
            require(isinstance(budget, int), "MASTERY_SOURCE_CONFLICT", f"{action_id} budget")
            result[action_id] = budget
    require(set(result) == EXPECTED_IDS, "MASTERY_SOURCE_CONFLICT", "effective Technique2 ID coverage")
    return result


def validate_source(data: dict[str, Any], source: dict[str, Any]) -> dict[str, int]:
    declared = data.get("budget_source", {})
    require(
        declared.get("contract") == "approved_20260804_existing_action_reprice_contract.json",
        "MASTERY_SOURCE_CONFLICT",
        "source contract",
    )
    require(declared.get("field") == "actions[].available_budget_ticks", "MASTERY_SOURCE_CONFLICT", "source field")
    require(declared.get("category") == "technique_2", "MASTERY_SOURCE_CONFLICT", "source category")
    return effective_source_budgets(source)


def validate_policies(data: dict[str, Any]) -> None:
    role = data.get("role_policy", {})
    require(role.get("value_superior_role_nonreplacement_required") is True, "ROLE_NONREPLACEMENT_CONFLICT", "value/role principle")
    require(role.get("same_martial_identity_required") is True, "ROLE_NONREPLACEMENT_CONFLICT", "martial identity")
    require(role.get("technique1_role_duplication_allowed") is False, "ROLE_NONREPLACEMENT_CONFLICT", "Technique1 duplication")
    require(role.get("core_role_change_allowed") is False, "ROLE_NONREPLACEMENT_CONFLICT", "Technique2 role change")
    require(role.get("automatic_answer_or_rule_bypass_allowed") is False, "ROLE_NONREPLACEMENT_CONFLICT", "automatic answer")

    star7 = data.get("star7_policy", {})
    require(star7.get("fixed_mastery_bonus_ticks") == 10, "STAR7_BONUS_CONFLICT", "fixed bonus")
    require(star7.get("formula") == "effective_existing_budget_ticks + 10", "STAR7_BONUS_CONFLICT", "formula")
    require(
        star7.get("individual_bonus_allocation_status") == "PENDING_SEPARATE_GRILLME_DECISION",
        "MASTERY_ALLOCATION_SCOPE_CONFLICT",
        "Star7 individual allocation",
    )

    star9 = data.get("star9_policy", {})
    require(star9.get("fixed_mastery_bonus_ticks") == 10, "STAR9_FORMULA_CONFLICT", "fixed bonus")
    require(star9.get("percentage_of_star7_final_budget") == 0.2, "STAR9_FORMULA_CONFLICT", "percentage")
    require(star9.get("rounding") == "FLOOR_TO_INTEGER_TICKS", "STAR9_FORMULA_CONFLICT", "rounding")
    require(star9.get("bonus_formula") == "10 + floor(star7_final_budget_ticks * 0.20)", "STAR9_FORMULA_CONFLICT", "bonus formula")
    require(star9.get("total_formula") == "star7_final_budget_ticks + star9_bonus_ticks", "STAR9_FORMULA_CONFLICT", "total formula")
    require(star9.get("effect_count_per_technique") == 1, "STAR9_SIMPLICITY_CONFLICT", "effect count")
    for key in [
        "branching_allowed",
        "public_trigger_required",
        "additional_player_input_allowed",
        "additional_resource_cost_allowed",
        "multiple_bonus_effects_allowed",
    ]:
        require(star9.get(key) is False, "STAR9_SIMPLICITY_CONFLICT", key)
    require(star9.get("one_sentence_card_rule_required") is True, "STAR9_SIMPLICITY_CONFLICT", "one sentence card")
    require(
        star9.get("individual_effect_allocation_status") == "PENDING_SEPARATE_GRILLME_DECISION",
        "MASTERY_ALLOCATION_SCOPE_CONFLICT",
        "Star9 individual allocation",
    )


def validate_techniques(data: dict[str, Any], source_budgets: dict[str, int]) -> None:
    techniques = data.get("techniques", {})
    require(isinstance(techniques, dict), "MASTERY_SOURCE_CONFLICT", "techniques must be object")
    require(set(techniques) == EXPECTED_IDS, "MASTERY_SOURCE_CONFLICT", "contract Technique2 ID coverage")
    for technique_id, source_budget in source_budgets.items():
        item = techniques[technique_id]
        require(isinstance(item, dict), "MASTERY_SOURCE_CONFLICT", technique_id)
        require(item.get("effective_existing_budget_ticks") == source_budget, "MASTERY_SOURCE_CONFLICT", technique_id)
        star7_final = source_budget + 10
        require(item.get("star7_mastery_bonus_ticks") == 10, "STAR7_BONUS_CONFLICT", technique_id)
        require(item.get("star7_final_budget_ticks") == star7_final, "STAR7_BONUS_CONFLICT", technique_id)
        percentage = math.floor(star7_final * 0.20)
        star9_bonus = 10 + percentage
        require(item.get("star9_fixed_bonus_ticks") == 10, "STAR9_FORMULA_CONFLICT", technique_id)
        require(item.get("star9_percentage_bonus_ticks") == percentage, "STAR9_FORMULA_CONFLICT", technique_id)
        require(item.get("star9_bonus_ticks") == star9_bonus, "STAR9_FORMULA_CONFLICT", technique_id)
        require(item.get("star9_total_budget_ticks") == star7_final + star9_bonus, "STAR9_FORMULA_CONFLICT", technique_id)


def validate_scope(data: dict[str, Any]) -> None:
    scope = data.get("scope_boundary", {})
    for key in [
        "individual_star7_effects_approved",
        "individual_star9_effects_approved",
        "product_code_changed",
        "godot_scene_changed",
        "html_poc_changed",
        "runtime_data_changed",
    ]:
        require(scope.get(key) is False, "MASTERY_SCOPE_CONFLICT", key)
    for key in [
        "runtime_validation",
        "godot_validation",
        "windows_validation",
        "accessibility_validation",
        "performance_validation",
        "human_validation",
        "balance_validation",
    ]:
        require(scope.get(key) == "NOT_RUN", "MASTERY_SCOPE_CONFLICT", key)


def validate(data: dict[str, Any], source: dict[str, Any]) -> None:
    validate_metadata(data)
    source_budgets = validate_source(data, source)
    validate_policies(data)
    validate_techniques(data, source_budgets)
    validate_scope(data)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=pathlib.Path, default=DEFAULT_CONTRACT)
    parser.add_argument("--source", type=pathlib.Path, default=SOURCE_CONTRACT)
    args = parser.parse_args()
    try:
        contract = load_json(args.contract, "MASTERY_CONTRACT_MISSING")
        source = load_json(args.source, "MASTERY_SOURCE_CONFLICT")
        validate(contract, source)
    except (OSError, MasteryContractError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("STAR7_STAR9_MASTERY_BONUS_CONTRACT_PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
