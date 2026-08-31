#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import pathlib
import sys
from typing import Any

ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_CONTRACT = ROOT / "docs/planning-data/approved_20260805_grade_farming_guardrails_contract.json"


class GradeContractError(ValueError):
    pass


def require(condition: bool, code: str, detail: str) -> None:
    if not condition:
        raise GradeContractError(f"{code}: {detail}")


def load_contract(path: pathlib.Path) -> dict[str, Any]:
    require(path.is_file(), "GRADE_CONTRACT_MISSING", str(path))
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise GradeContractError(f"GRADE_CONTRACT_JSON_INVALID: {exc}") from exc
    require(isinstance(data, dict), "GRADE_CONTRACT_SHAPE_INVALID", "root must be object")
    return data


def validate_metadata(data: dict[str, Any]) -> None:
    require(data.get("schema_version") == 1, "GRADE_METADATA_CONFLICT", "schema_version")
    require(
        data.get("decision_id") == "TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01",
        "GRADE_METADATA_CONFLICT",
        "decision_id",
    )
    require(
        data.get("authority_status") == "CURRENT_APPROVED_PLANNING_GOVERNANCE",
        "GRADE_METADATA_CONFLICT",
        "authority_status",
    )
    require(
        data.get("risk_status") == "MITIGATED_PENDING_HUMAN_MEASUREMENT",
        "GRADE_METADATA_CONFLICT",
        "risk_status",
    )
    require(data.get("implementation_authority") == "PLANNING_ONLY", "GRADE_SCOPE_CONFLICT", "implementation_authority")
    require(data.get("active_approval_count") == "9/10", "GRADE_METADATA_CONFLICT", "active_approval_count")
    require(
        data.get("next_planning_decision") == "STAR9_PUBLIC_READ_BRANCH_TEMPLATE",
        "GRADE_METADATA_CONFLICT",
        "next_planning_decision",
    )


def validate_raw_events(data: dict[str, Any]) -> None:
    raw = data.get("raw_event_contract", {})
    for key in [
        "successful_dodges_record_all",
        "clash_wins_record_all",
        "health_loss_records_all",
        "rounds_elapsed_records_all",
        "ultimate_uses_record_all",
    ]:
        require(raw.get(key) is True, "RAW_EVENT_PRESERVATION_CONFLICT", key)
    for key in [
        "combat_resolution_attenuated",
        "replay_log_attenuated",
        "ultimate_momentum_attenuated",
        "online_season_rating_changed",
    ]:
        require(raw.get(key) is False, "RAW_EVENT_PRESERVATION_CONFLICT", key)


def validate_defensive_credit(data: dict[str, Any]) -> None:
    credit = data.get("defensive_credit_contract", {})
    require(credit.get("identity_basis") == "CANONICAL_SOURCE_ID", "REPEAT_ATTENUATION_CONFLICT", "identity_basis")
    require(credit.get("canonical_source_id_formula") == "source_type:source_id", "REPEAT_ATTENUATION_CONFLICT", "canonical_source_id_formula")
    require(credit.get("action_instance_field") == "enemy_action_instance_id", "ACTION_INSTANCE_CREDIT_CONFLICT", "action_instance_field")
    require(set(credit.get("qualifying_events", [])) == {"CLASH_WIN", "DODGE_SUCCESS"}, "ACTION_INSTANCE_CREDIT_CONFLICT", "qualifying_events")
    require(credit.get("repeat_multipliers") == [1.0, 0.5, 0.0], "REPEAT_ATTENUATION_CONFLICT", "repeat_multipliers")
    require(credit.get("action_instance_combined_credit_cap") == 1.0, "ACTION_INSTANCE_CREDIT_CONFLICT", "combined cap")
    require(
        credit.get("multi_event_pool_distribution") == "EQUAL_SPLIT_ACROSS_QUALIFYING_EVENTS",
        "EVENT_POOL_SPLIT_CONFLICT",
        "pool distribution",
    )
    require(
        credit.get("event_credit_formula") == "repeat_multiplier/qualifying_event_count_in_action_instance",
        "EVENT_POOL_SPLIT_CONFLICT",
        "event credit formula",
    )
    for key in [
        "hit_index_creates_new_identity",
        "temporary_modifier_creates_new_identity",
        "display_name_creates_new_identity",
    ]:
        require(credit.get(key) is False, "REPEAT_ATTENUATION_CONFLICT", key)


def validate_metric_caps(data: dict[str, Any]) -> None:
    caps = data.get("metric_cap_contract", {})
    require(caps.get("clash_credit_cap") == 3.0, "GRADE_METRIC_CAP_CONFLICT", "clash cap")
    require(caps.get("dodge_credit_cap") == 3.0, "GRADE_METRIC_CAP_CONFLICT", "dodge cap")
    require(
        caps.get("normalized_clash_input") == "min(total_clash_credit,3.0)/3.0",
        "GRADE_METRIC_CAP_CONFLICT",
        "clash normalization",
    )
    require(
        caps.get("normalized_dodge_input") == "min(total_dodge_credit,3.0)/3.0",
        "GRADE_METRIC_CAP_CONFLICT",
        "dodge normalization",
    )
    require(
        caps.get("final_metric_weights_status") == "UNRESOLVED_FUTURE_DECISION",
        "GRADE_SCOPE_CONFLICT",
        "weights cannot be silently approved",
    )
    require(
        caps.get("grade_thresholds_status") == "UNRESOLVED_FUTURE_DECISION",
        "GRADE_SCOPE_CONFLICT",
        "thresholds cannot be silently approved",
    )


def validate_scoring_window(data: dict[str, Any]) -> None:
    window = data.get("scoring_window_contract", {})
    require(window.get("encounter_field") == "grade_target_rounds", "GRADE_SCORING_WINDOW_CONFLICT", "encounter field")
    require(window.get("minimum_authored_value") == 1, "GRADE_SCORING_WINDOW_CONFLICT", "minimum authored value")
    require(window.get("default_grade_target_rounds") == 3, "GRADE_SCORING_WINDOW_CONFLICT", "default rounds")
    require(
        set(window.get("positive_credit_types", []))
        == {"CLASH_CREDIT", "DODGE_CREDIT", "EFFECTIVE_ULTIMATE_CREDIT"},
        "GRADE_SCORING_WINDOW_CONFLICT",
        "positive credit types",
    )
    require(window.get("positive_credit_after_window") is False, "GRADE_SCORING_WINDOW_CONFLICT", "positive credit after window")
    require(window.get("raw_events_continue_after_window") is True, "GRADE_SCORING_WINDOW_CONFLICT", "raw events after window")
    require(window.get("health_loss_continues_after_window") is True, "GRADE_SCORING_WINDOW_CONFLICT", "health loss after window")
    require(window.get("round_count_continues_after_window") is True, "GRADE_SCORING_WINDOW_CONFLICT", "round count after window")


def validate_ultimate(data: dict[str, Any]) -> None:
    ultimate = data.get("ultimate_credit_contract", {})
    require(ultimate.get("raw_uses_record_all") is True, "ULTIMATE_GRADE_CREDIT_CONFLICT", "raw uses")
    require(ultimate.get("maximum_effective_ultimate_grade_credit") == 1, "ULTIMATE_GRADE_CREDIT_CONFLICT", "maximum credit")
    require(ultimate.get("must_resolve_within_scoring_window") is True, "ULTIMATE_GRADE_CREDIT_CONFLICT", "scoring window")
    require(ultimate.get("must_resolve_legally") is True, "ULTIMATE_GRADE_CREDIT_CONFLICT", "legal resolution")
    require(ultimate.get("cost_or_reservation_alone_qualifies") is False, "ULTIMATE_GRADE_CREDIT_CONFLICT", "cost-only qualification")
    require(
        set(ultimate.get("qualifying_non_cost_results", []))
        == {
            "HEALTH_DAMAGE",
            "HEALING",
            "FORCED_MOVEMENT",
            "STATUS_APPLIED",
            "ATTACK_INTERRUPTED",
            "BENEFICIAL_RESOURCE_CHANGE",
        },
        "ULTIMATE_GRADE_CREDIT_CONFLICT",
        "qualifying result set",
    )


def validate_economy_gate(data: dict[str, Any]) -> None:
    gate = data.get("economy_gate", {})
    for key in [
        "grade_affects_run_currency",
        "grade_affects_training",
        "grade_affects_drops",
        "grade_affects_permanent_currency",
        "grade_affects_retry_refund",
    ]:
        require(gate.get(key) is False, "GRADE_ECONOMY_GATE_CONFLICT", key)
    require(gate.get("new_decision_required_for_reward_link") is True, "GRADE_ECONOMY_GATE_CONFLICT", "new Decision gate")
    require(gate.get("human_validation_required_before_reward_link") is True, "GRADE_ECONOMY_GATE_CONFLICT", "human gate")


def validate_measurement(data: dict[str, Any]) -> None:
    gate = data.get("human_validation_gate", {})
    require(gate.get("minimum_completed_victories") == 30, "GRADE_MEASUREMENT_CONFLICT", "minimum victories")
    require(gate.get("minimum_distinct_encounters") == 5, "GRADE_MEASUREMENT_CONFLICT", "minimum encounters")
    require(gate.get("maximum_single_encounter_sample_share") == 0.4, "GRADE_MEASUREMENT_CONFLICT", "sample concentration")
    required = {
        "raw_to_effective_defensive_credit_ratio",
        "same_source_repeat_response_share",
        "post_window_positive_raw_event_share",
        "full_scoring_window_completion_rate",
        "observation_assisted_effective_credit_uplift",
        "average_rounds_elapsed",
        "p90_rounds_elapsed",
        "effective_ultimate_use_rate",
    }
    require(required.issubset(set(gate.get("required_diagnostics", []))), "GRADE_MEASUREMENT_CONFLICT", "required diagnostics")
    require(gate.get("automatic_tuning_allowed") is False, "GRADE_MEASUREMENT_CONFLICT", "automatic tuning")
    require(gate.get("new_grillme_decision_required_for_tuning") is True, "GRADE_MEASUREMENT_CONFLICT", "new GrillMe gate")


def validate_scope(data: dict[str, Any]) -> None:
    scope = data.get("scope_boundary", {})
    for key in [
        "product_code_changed",
        "godot_scene_changed",
        "html_poc_changed",
        "runtime_data_changed",
        "combat_resolution_changed",
        "observation_behavior_changed",
    ]:
        require(scope.get(key) is False, "GRADE_SCOPE_CONFLICT", key)
    for key in [
        "runtime_validation",
        "godot_validation",
        "windows_validation",
        "accessibility_validation",
        "performance_validation",
        "human_validation",
        "balance_validation",
    ]:
        require(scope.get(key) == "NOT_RUN", "GRADE_SCOPE_CONFLICT", key)


def validate(data: dict[str, Any]) -> None:
    validate_metadata(data)
    validate_raw_events(data)
    validate_defensive_credit(data)
    validate_metric_caps(data)
    validate_scoring_window(data)
    validate_ultimate(data)
    validate_economy_gate(data)
    validate_measurement(data)
    validate_scope(data)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=pathlib.Path, default=DEFAULT_CONTRACT)
    args = parser.parse_args()
    try:
        data = load_contract(args.contract)
        validate(data)
    except (OSError, GradeContractError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("GRADE_FARMING_GUARDRAILS_CONTRACT_PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
