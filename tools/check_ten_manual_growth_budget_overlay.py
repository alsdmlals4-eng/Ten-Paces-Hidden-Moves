#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONTRACT = ROOT / "docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json"
SOURCE_CONTRACT = ROOT / "docs/planning-data/approved_20260804_existing_action_reprice_contract.json"

EXPECTED_DECISION = "TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01"
EXPECTED_ALIASES = {
    "falling_petal_chasing_sword": "mount_hua_plum_blossom_sword",
    "rebounding_vajra_fist": "shaolin_arhat_vajra_art",
    "four_ounces_move_thousand_pounds": "wudang_taiji_sword",
    "chained_road_lock": "yang_family_spear",
    "returning_qi_meridian": "mount_hua_purple_mist_art",
    "ten_paces_position_reversal": "xiaoyao_lingbo_footwork",
}
NEW_STAR7 = {
    "beggars_dragon_subduing_palm",
    "sichuan_tang_hidden_weapons",
    "hebei_peng_five_tigers_saber",
    "nangong_boundless_sky_sword",
}
ALL_MANUALS = set(EXPECTED_ALIASES.values()) | NEW_STAR7
EXPECTED_PRICING = {
    "movement_ticks_per_tile": 15,
    "range_ticks_per_tile_beyond_one": 15,
    "stamina_allowance_ticks_per_point": 4,
    "internal_allowance_ticks_per_point": 7,
    "slot_budget_ticks": {"1": 20, "2": 50, "3": 80},
    "automatic_tolerance_ticks": 5,
    "max_stamina": 5,
    "max_internal": 4,
}


def load_json(path: Path) -> dict[str, Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        print(f"MISSING_FILE: {path}", file=sys.stderr)
        raise
    except json.JSONDecodeError as exc:
        print(f"INVALID_JSON: {path}: {exc}", file=sys.stderr)
        raise


def calculate_distance_ticks(row: dict[str, Any], pricing: dict[str, Any]) -> int:
    return (
        int(row["movement_tiles"]) * int(pricing["movement_ticks_per_tile"])
        + max(0, int(row["max_range"]) - 1) * int(pricing["range_ticks_per_tile_beyond_one"])
    )


def calculate_available_budget(row: dict[str, Any], pricing: dict[str, Any]) -> int:
    slots = int(row["action_slots"])
    return (
        int(pricing["slot_budget_ticks"][str(slots)])
        + int(row["stamina_cost"]) * int(pricing["stamina_allowance_ticks_per_point"])
        + int(row["internal_cost"]) * int(pricing["internal_allowance_ticks_per_point"])
        + int(row["condition_allowance_ticks"])
        + int(row["other_resource_allowance_ticks"])
    )


def validate_metadata(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if (
        data.get("schema_version") != 1
        or data.get("decision_id") != EXPECTED_DECISION
        or data.get("authority_status") != "CURRENT_APPROVED_PLANNING_GOVERNANCE"
        or data.get("implementation_authority") != "PLANNING_ONLY"
        or data.get("semantic_contract") != "approved_20260806_ten_recognizable_martial_manuals_contract.json"
        or data.get("budget_source") != "approved_20260804_existing_action_reprice_contract.json"
    ):
        errors.append("TEN_MANUAL_BUDGET_METADATA_CONFLICT")
    if data.get("pricing") != EXPECTED_PRICING:
        errors.append("TEN_MANUAL_PRICING_CONFLICT")
    aliases = data.get("legacy_star7_aliases")
    if aliases != EXPECTED_ALIASES:
        errors.append("TEN_MANUAL_LEGACY_ALIAS_CONFLICT")
    if set(data.get("new_star7_manual_ids", [])) != NEW_STAR7:
        errors.append("TEN_MANUAL_NEW_PROFILE_COVERAGE_CONFLICT")
    return errors


def validate_legacy_aliases(data: dict[str, Any], source: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    rows = data.get("star7_profiles", {})
    source_rows = {row.get("action_id"): row for row in source.get("actions", [])}
    for source_id, manual_id in EXPECTED_ALIASES.items():
        row = rows.get(manual_id, {})
        source_row = source_rows.get(source_id)
        if not source_row:
            errors.append("TEN_MANUAL_LEGACY_SOURCE_CONFLICT")
            continue
        source_budget = source_row.get("available_budget_ticks")
        expected_final = int(source_budget) + 10
        expected_bonus = 10 + math.floor(expected_final * 0.20)
        if row.get("source_type") != "LEGACY_ALIAS" or row.get("source_action_id") != source_id:
            errors.append("TEN_MANUAL_LEGACY_ALIAS_CONFLICT")
        if row.get("effective_existing_budget_ticks") != source_budget:
            errors.append("TEN_MANUAL_LEGACY_SOURCE_CONFLICT")
        if (
            row.get("star7_final_budget_ticks") != expected_final
            or row.get("star9_bonus_ticks") != expected_bonus
            or row.get("star9_total_budget_ticks") != expected_final + expected_bonus
        ):
            errors.append("TEN_MANUAL_STAR7_FORMULA_CONFLICT")
    return errors


def validate_numeric_profile(row: dict[str, Any], pricing: dict[str, Any], *, require_star9: bool) -> list[str]:
    errors: list[str] = []
    required = [
        "action_slots",
        "stamina_cost",
        "internal_cost",
        "movement_tiles",
        "max_range",
        "base_effect_ticks_excluding_distance",
        "distance_effect_ticks",
        "condition_allowance_ticks",
        "other_resource_allowance_ticks",
        "effect_cost_ticks",
        "available_budget_ticks",
        "variance_ticks",
    ]
    if any(not isinstance(row.get(key), int) or isinstance(row.get(key), bool) for key in required):
        return ["TEN_MANUAL_BUDGET_PROFILE_SHAPE_CONFLICT"]
    slots = row["action_slots"]
    if str(slots) not in pricing["slot_budget_ticks"]:
        errors.append("TEN_MANUAL_BUDGET_PROFILE_SHAPE_CONFLICT")
    if not 0 <= row["stamina_cost"] <= pricing["max_stamina"]:
        errors.append("TEN_MANUAL_BUDGET_PROFILE_SHAPE_CONFLICT")
    if not 0 <= row["internal_cost"] <= pricing["max_internal"]:
        errors.append("TEN_MANUAL_BUDGET_PROFILE_SHAPE_CONFLICT")
    expected_distance = calculate_distance_ticks(row, pricing)
    expected_effect = row["base_effect_ticks_excluding_distance"] + expected_distance
    expected_available = calculate_available_budget(row, pricing)
    expected_variance = expected_effect - expected_available
    if (
        row["distance_effect_ticks"] != expected_distance
        or row["effect_cost_ticks"] != expected_effect
        or row["available_budget_ticks"] != expected_available
        or row["variance_ticks"] != expected_variance
    ):
        errors.append("TEN_MANUAL_BUDGET_FORMULA_CONFLICT")
    if abs(row["variance_ticks"]) > pricing["automatic_tolerance_ticks"]:
        errors.append("TEN_MANUAL_VARIANCE_CONFLICT")
    if row.get("variance_status") != "WITHIN_TOLERANCE":
        errors.append("TEN_MANUAL_VARIANCE_CONFLICT")
    if require_star9:
        final = row.get("star7_final_budget_ticks")
        bonus = row.get("star9_bonus_ticks")
        total = row.get("star9_total_budget_ticks")
        if final != expected_available:
            errors.append("TEN_MANUAL_STAR7_FORMULA_CONFLICT")
        expected_bonus = 10 + math.floor(expected_available * 0.20)
        if bonus != expected_bonus or total != expected_available + expected_bonus:
            errors.append("TEN_MANUAL_STAR7_FORMULA_CONFLICT")
    return errors


def validate_new_profiles(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    pricing = data.get("pricing", {})
    rows = data.get("star7_profiles", {})
    if set(rows) != ALL_MANUALS:
        errors.append("TEN_MANUAL_STAR7_COVERAGE_CONFLICT")
        return errors
    for manual_id in NEW_STAR7:
        row = rows.get(manual_id, {})
        if row.get("source_type") != "NEW_APPROVED_PROFILE":
            errors.append("TEN_MANUAL_NEW_PROFILE_COVERAGE_CONFLICT")
        errors.extend(validate_numeric_profile(row, pricing, require_star9=True))
    return errors


def validate_ultimates(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    pricing = data.get("pricing", {})
    rows = data.get("ultimate_profiles", {})
    if set(rows) != ALL_MANUALS:
        return ["TEN_MANUAL_ULTIMATE_COVERAGE_CONFLICT"]
    for row in rows.values():
        errors.extend(validate_numeric_profile(row, pricing, require_star9=False))
    return errors


def validate_scope(data: dict[str, Any]) -> list[str]:
    scope = data.get("scope_boundary", {})
    if (
        scope.get("product_code_changed") is not False
        or scope.get("godot_scene_changed") is not False
        or scope.get("html_poc_changed") is not False
        or scope.get("runtime_data_changed") is not False
        or scope.get("human_balance_validation") != "NOT_RUN"
    ):
        return ["TEN_MANUAL_BUDGET_SCOPE_CONFLICT"]
    return []


def validate(data: dict[str, Any], source: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    errors.extend(validate_metadata(data))
    errors.extend(validate_legacy_aliases(data, source))
    errors.extend(validate_new_profiles(data))
    errors.extend(validate_ultimates(data))
    errors.extend(validate_scope(data))
    return list(dict.fromkeys(errors))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Validate ten-manual growth budget overlay.")
    parser.add_argument("--contract", type=Path, default=DEFAULT_CONTRACT)
    args = parser.parse_args(argv)
    try:
        data = load_json(args.contract)
        source = load_json(SOURCE_CONTRACT)
    except (OSError, json.JSONDecodeError):
        return 1
    errors = validate(data, source)
    if errors:
        for error in errors:
            print(error)
        return 1
    print("TEN_MANUAL_GROWTH_BUDGET_OVERLAY_PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
