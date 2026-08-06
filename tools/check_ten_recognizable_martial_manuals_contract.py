#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONTRACT = ROOT / "docs/planning-data/approved_20260806_ten_recognizable_martial_manuals_contract.json"

EXPECTED_DECISION = "TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01"
EXPECTED_MANUALS = {
    "mount_hua_plum_blossom_sword": ("화산파", "매화검결", "신법", "외공", "이십사수매화검법"),
    "shaolin_arhat_vajra_art": ("소림사", "나한금강공", "외공", "내공", "여래신장"),
    "wudang_taiji_sword": ("무당파", "태극검결", "심안", "내공", "태극혜검"),
    "yang_family_spear": ("양가", "양가창결", "외공", "신법", "회마창"),
    "mount_hua_purple_mist_art": ("화산파", "자하심법", "내공", "근골", "자하신공"),
    "xiaoyao_lingbo_footwork": ("소요파", "소요보결", "신법", "심안", "능파미보"),
    "beggars_dragon_subduing_palm": ("개방", "강룡장결", "내공", "근골", "항룡십팔장"),
    "sichuan_tang_hidden_weapons": ("사천당문", "천기암기록", "심안", "신법", "만천화우"),
    "hebei_peng_five_tigers_saber": ("하북팽가", "팽가도결", "근골", "외공", "오호단문도"),
    "nangong_boundless_sky_sword": ("남궁세가", "창궁무애검법", "내공", "심안", "제왕검형"),
}

EXPECTED_ORDERS = {
    "mount_hua_plum_blossom_sword": [
        "APPROACH_1",
        "INDEPENDENT_STRIKE_1",
        "INDEPENDENT_STRIKE_2",
        "INDEPENDENT_STRIKE_3",
        "REQUIRE_AT_LEAST_2_ACTUAL_HP_HITS",
        "CHASE_1",
        "RECHECK_RANGE",
        "FINISHING_SWORD",
        "LOCK_FINAL_POSITION",
    ],
    "shaolin_arhat_vajra_art": [
        "GAIN_DEFENSE_AND_TENACITY_BEFORE_PRELUDE",
        "START_THIS_ACTION_DEFENSE_LOSS_RECORD",
        "RECORD_ACTUAL_DEFENSE_LOSS",
        "RECHECK_CLOSE_RANGE",
        "EXTERNAL_PALM_STRIKE",
        "ADD_CAPPED_RECORDED_IMPACT_DAMAGE",
        "END_RECORD",
    ],
    "wudang_taiji_sword": [
        "PREPARE_TAIJI_SWORD_STATE",
        "CONTACT_INCOMING_ATTACK",
        "SPECIAL_INSIGHT_CLASH",
        "ON_WIN_REDIRECT_ATTACK",
        "COUNTERATTACK",
        "STABILIZE_INTERNAL_AND_DEFENSE",
    ],
    "yang_family_spear": [
        "FIRST_THRUST",
        "RESOLVE_RESULT",
        "RETREAT_2",
        "RECHECK_RANGE",
        "RETURNING_HORSE_THRUST",
        "RESOLVE_RESULT",
    ],
    "mount_hua_purple_mist_art": [
        "CONSUME_ONCE_PER_BATTLE_USE_AT_FIRST_PRELUDE",
        "SNAPSHOT_START_RESOURCES",
        "RECOVER_INTERNAL",
        "RECOVER_STAMINA",
        "STABILIZE_TENACITY_AND_DEFENSE",
        "IF_START_LOW_RESOURCE_RECOVER_LIMITED_HP",
        "ON_SUCCESSFUL_COMPLETION_GAIN_ULTIMATE_MOMENTUM_1",
    ],
    "xiaoyao_lingbo_footwork": [
        "GRANT_EVADE",
        "ON_EVADE_SUCCESS_COUNTER_FROM_PRE_MOVE_POSITION",
        "RESOLVE_COUNTER",
        "MOVE_OPPOSITE_ATTACKER_UP_TO_3",
        "GAIN_PREPARATION",
    ],
    "beggars_dragon_subduing_palm": [
        "APPROACH_1",
        "INTERNAL_FORCE_CLASH",
        "ON_WIN_BREAK_DEFENSE",
        "DEAL_HP_DAMAGE",
        "PUSH_2",
    ],
    "sichuan_tang_hidden_weapons": [
        "RECHECK_RANGE",
        "PROJECTILE_1",
        "PROJECTILE_2",
        "PROJECTILE_3",
        "PROJECTILE_4",
        "END_ACTION",
    ],
    "hebei_peng_five_tigers_saber": [
        "BREAKING_SABER_1",
        "RESOLVE_DEFENSE",
        "BREAKING_SABER_2",
        "RESOLVE_DEFENSE",
        "REQUIRE_TARGET_DEFENSE_ZERO",
        "FINISHING_SABER",
    ],
    "nangong_boundless_sky_sword": [
        "FORM_EMPEROR_SWORD_PRELUDE",
        "RECHECK_RANGE",
        "SPECIAL_INTERNAL_SWORD_CLASH",
        "ON_WIN_BREAK_DEFENSE",
        "SINGLE_FINISHING_SWORD",
    ],
}

ALLOWED_PROVENANCE = {
    "HISTORICAL_OR_ESTABLISHED",
    "WUXIA_CONVENTIONAL",
    "PROJECT_ORIGINAL",
    "INSPIRED_HYBRID",
}
REQUIRED_STAGES = {"star3", "star5", "star7", "star9", "star10"}


def load_contract(path: Path) -> dict[str, Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        print("TEN_MANUAL_CONTRACT_MISSING", file=sys.stderr)
        raise
    except json.JSONDecodeError as exc:
        print(f"TEN_MANUAL_CONTRACT_JSON_INVALID: {exc}", file=sys.stderr)
        raise


def validate_metadata(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if (
        data.get("schema_version") != 1
        or data.get("decision_id") != EXPECTED_DECISION
        or data.get("authority_status") != "CURRENT_APPROVED_PLANNING_GOVERNANCE"
        or data.get("implementation_authority") != "PLANNING_ONLY"
        or data.get("approval_batch") != "9/10"
    ):
        errors.append("MANUAL_METADATA_CONFLICT")
    if (
        data.get("stat_assignment_policy") != "FACTION_MARTIAL_ACTION_FIT_ONLY"
        or data.get("stat_quota_rules_enabled") is not False
        or "primary_stat_distribution" in data
        or "secondary_stat_distribution" in data
    ):
        errors.append("STAT_QUOTA_POLICY_CONFLICT")
    growth = data.get("growth_policy", {})
    if set(growth.get("required_stages", [])) != REQUIRED_STAGES:
        errors.append("GROWTH_STAGE_CONFLICT")
    if not growth.get("star7_bonus_is_integrated_budget", False):
        errors.append("STAR7_BUDGET_SCOPE_CONFLICT")
    if not growth.get("value_superior_role_nonreplacement_required", False):
        errors.append("ROLE_REPLACEMENT_CONFLICT")
    return errors


def validate_roster(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    manuals = data.get("manuals")
    if not isinstance(manuals, dict) or set(manuals) != set(EXPECTED_MANUALS):
        return ["MANUAL_ROSTER_CONFLICT"]
    for manual_id, expected in EXPECTED_MANUALS.items():
        manual = manuals.get(manual_id, {})
        actual = (
            manual.get("faction"),
            manual.get("manual_name"),
            manual.get("primary_stat"),
            manual.get("secondary_stat"),
            manual.get("growth", {}).get("star10", {}).get("name"),
        )
        if actual[:2] != expected[:2] or actual[4] != expected[4]:
            errors.append("FACTION_SIGNATURE_CONFLICT")
        if actual[2:4] != expected[2:4]:
            errors.append("STAT_AUTHORITY_CONFLICT")
    return errors


def validate_stat_fit(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for manual in data.get("manuals", {}).values():
        rationale = manual.get("stat_fit_rationale")
        if not isinstance(rationale, str) or not rationale.strip():
            errors.append("STAT_FIT_RATIONALE_CONFLICT")
    shaolin = data.get("manuals", {}).get("shaolin_arhat_vajra_art", {})
    beggars = data.get("manuals", {}).get("beggars_dragon_subduing_palm", {})
    if (shaolin.get("primary_stat"), shaolin.get("secondary_stat")) != ("외공", "내공"):
        errors.append("STAT_AUTHORITY_CONFLICT")
    if (beggars.get("primary_stat"), beggars.get("secondary_stat")) != ("내공", "근골"):
        errors.append("STAT_AUTHORITY_CONFLICT")
    return errors


def validate_growth(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for manual_id, manual in data.get("manuals", {}).items():
        growth = manual.get("growth")
        if not isinstance(growth, dict) or set(growth) != REQUIRED_STAGES:
            errors.append("GROWTH_STAGE_CONFLICT")
            continue
        star5 = growth.get("star5", {})
        if star5.get("modifies") != "star3" or not star5.get("effect"):
            errors.append("STAR5_ROLE_CONFLICT")
        star9 = growth.get("star9", {})
        if (
            star9.get("modifies") != "star7"
            or star9.get("effect_count") != 1
            or star9.get("branching_allowed") is not False
            or star9.get("additional_input_allowed") is not False
            or star9.get("additional_resource_cost_allowed") is not False
        ):
            errors.append("STAR9_SINGLE_EFFECT_CONFLICT")
        if not growth.get("star10", {}).get("name") or not growth.get("star10", {}).get("effect"):
            errors.append("ULTIMATE_IDENTITY_CONFLICT")
        if growth.get("star3", {}).get("role") == growth.get("star7", {}).get("role"):
            errors.append("ROLE_REPLACEMENT_CONFLICT")
        if manual.get("resolution_order") != EXPECTED_ORDERS.get(manual_id):
            errors.append("RESOLUTION_ORDER_CONFLICT")
        provenance = manual.get("provenance", {})
        if (
            provenance.get("classification") not in ALLOWED_PROVENANCE
            or not provenance.get("traditions")
            or not provenance.get("recognition_basis")
        ):
            errors.append("PROVENANCE_CONFLICT")
        if not manual.get("counterplay") or not manual.get("forbidden_roles"):
            errors.append("ROLE_REPLACEMENT_CONFLICT")
    return errors


def validate_special_rules(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    rules = data.get("special_rules", {})
    zixia = rules.get("zixia_divine_art", {})
    if (
        zixia.get("uses_per_battle") != 1
        or zixia.get("consume_timing") != "FIRST_PRELUDE_EXECUTION"
        or zixia.get("refund_on_interrupt") is not False
        or zixia.get("recharge_allowed") is not False
        or zixia.get("ultimate_momentum_gain") != 1
        or zixia.get("ultimate_momentum_timing") != "ON_SUCCESSFUL_COMPLETION"
        or zixia.get("respect_resource_caps") is not True
    ):
        errors.append("ZIXIA_ONCE_PER_BATTLE_CONFLICT")
    vajra = rules.get("vajra_tenacity", {})
    if (
        vajra.get("grant_timing") != "BEFORE_ATTACK_OR_PRELUDE"
        or vajra.get("uses_existing_rule_only") is not True
        or vajra.get("absolute_interrupt_immunity") is not False
        or vajra.get("grants_invulnerability") is not False
        or vajra.get("prevents_defeat") is not False
    ):
        errors.append("VAJRA_TENACITY_CONFLICT")
    force = rules.get("emitted_force_scaling", {})
    if (
        force.get("default_primary_stat") != "내공"
        or "항룡십팔장" not in force.get("approved_internal_examples", [])
        or "여래신장" not in force.get("approved_close_range_external_exceptions", [])
        or force.get("automatic_hit_allowed") is not False
        or force.get("automatic_clash_win_allowed") is not False
    ):
        errors.append("PALM_FORCE_STAT_CONFLICT")
    return errors


def validate_scope(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    scope = data.get("scope_boundary", {})
    for key in ("product_code_changed", "godot_scene_changed", "html_poc_changed", "runtime_data_changed"):
        if scope.get(key) is not False:
            errors.append("TEN_MANUAL_SCOPE_CONFLICT")
            break
    for key in (
        "runtime_validation",
        "godot_validation",
        "windows_validation",
        "accessibility_validation",
        "performance_validation",
        "human_validation",
        "balance_validation",
    ):
        if scope.get(key) != "NOT_RUN":
            errors.append("TEN_MANUAL_SCOPE_CONFLICT")
            break
    return errors


def validate(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for validator in (
        validate_metadata,
        validate_roster,
        validate_stat_fit,
        validate_growth,
        validate_special_rules,
        validate_scope,
    ):
        errors.extend(validator(data))
    return list(dict.fromkeys(errors))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Validate the ten recognizable martial manuals planning contract.")
    parser.add_argument("--contract", type=Path, default=DEFAULT_CONTRACT)
    args = parser.parse_args(argv)
    try:
        data = load_contract(args.contract)
    except (OSError, json.JSONDecodeError):
        return 1
    errors = validate(data)
    if errors:
        for error in errors:
            print(error)
        return 1
    print("TEN_RECOGNIZABLE_MARTIAL_MANUALS_CONTRACT_PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
