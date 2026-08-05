#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONTRACT = ROOT / "docs/planning-data/approved_20260805_observation_answer_leak_guardrails_contract.json"
PARENT_DECISION = ROOT / "docs/decisions/2026-08-02_OBSERVATION_STATS_MASTERY_DECISION.md"
COMBAT_RULES = ROOT / "docs/02_COMBAT_RULES.md"
DECISION = ROOT / "docs/decisions/2026-08-05_OBSERVATION_ANSWER_LEAK_GUARDRAILS_DECISION.md"
AMENDMENT = ROOT / "docs/02_COMBAT_RULES_OBSERVATION_GUARDRAILS_AMENDMENT.md"
ACTIVE_CONTEXT = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"

STABLE_ENTRYPOINTS = [
    ROOT / "AGENTS.md",
    ROOT / "README.md",
    ROOT / "START_HERE.md",
    ROOT / "docs/BASE_RULES_VERSION.md",
    ROOT / "[기획서]/00_프로젝트_허브/START_HERE.md",
]

REQUIRED_FORBIDDEN = {
    "AI_WEIGHT",
    "AI_PREFERENCE_SCORE",
    "EXACT_TECHNIQUE_NAME",
    "EXACT_MARTIAL_MANUAL_NAME",
    "EXACT_COST",
    "EXACT_DIRECTION",
    "EXACT_DISTANCE",
    "EXACT_DAMAGE",
    "EXACT_RANGE",
    "EXACT_TARGET",
    "RECOMMENDED_CORRECT_COUNTER",
}

REQUIRED_METRICS = {
    "observation_use_rate",
    "observation_points_spent_per_bundle",
    "full_bundle_reveal_rate",
    "exact_technique_inference_rate",
    "observation_assisted_correct_counter_rate",
    "non_observation_correct_counter_rate",
    "observation_assisted_grade_uplift",
    "non_observation_win_rate",
}

EXPECTED_ORDER = [
    "BUNDLE_END_STATE_AND_RECOVERY",
    "ENEMY_PLAN_CURRENT_BUNDLE",
    "ENEMY_BUNDLE_LOCK",
    "OBSERVATION_POINT_SPEND_FRONT_TO_BACK",
    "ACTION_TYPE_REVEAL",
    "PLAYER_PLAN_AND_COMMIT",
    "BUNDLE_RESOLUTION",
]

MUTABLE_STATE_TOKENS = [
    "active_planning_pr:",
    "active_planning_head:",
    "active_approval_count:",
    "next_planning_decision:",
]


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def validate_contract(contract: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    if contract.get("decision_id") != "TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01":
        errors.append("PARENT_AUTHORITY_CONFLICT decision_id")
    if contract.get("parent_authority") != "TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01":
        errors.append("PARENT_AUTHORITY_CONFLICT observation parent")
    if contract.get("design_conclusion") != "RETAIN_EXISTING_DIRECT_REVEAL":
        errors.append("DIRECT_REVEAL_RETENTION_CONFLICT design conclusion")
    if contract.get("risk_state") != "ACCEPTED_PENDING_HUMAN_MEASUREMENT":
        errors.append("OBSERVATION_RISK_STATE_CONFLICT")
    if contract.get("implementation_authority") != "PLANNING_ONLY":
        errors.append("PRODUCT_SCOPE_CONFLICT implementation authority")

    cost = contract.get("observation_cost_contract", {})
    if cost.get("action_slots_spent") != 1:
        errors.append("OBSERVATION_COST_CONFLICT action slot")
    if cost.get("observation_points_gained") != 1:
        errors.append("OBSERVATION_COST_CONFLICT point gain")
    if cost.get("points_spent_per_revealed_slot") != 1:
        errors.append("OBSERVATION_COST_CONFLICT point spend")
    if cost.get("stamina_or_internal_cost_added") is not False:
        errors.append("OBSERVATION_COST_CONFLICT new stamina/internal cost")

    reveal = contract.get("observation_reveal_contract", {})
    if reveal.get("payload") != "ACTUAL_ACTION_TYPES":
        errors.append("DIRECT_REVEAL_RETENTION_CONFLICT payload")
    if reveal.get("spend_order") != "FRONT_TO_BACK":
        errors.append("DIRECT_REVEAL_RETENTION_CONFLICT spend order")
    if reveal.get("bundle_scope") != "CURRENT_LOCKED_ENEMY_BUNDLE":
        errors.append("OBSERVATION_FAIRNESS_CONFLICT bundle scope")
    for key in (
        "compound_action_types_all_displayed",
        "unlimited_storage",
        "cross_bundle_carryover",
        "reveal_after_enemy_lock",
        "direct_reveal_may_logically_identify_one_technique",
        "recommended_counter_is_never_generated",
    ):
        if reveal.get(key) is not True:
            errors.append(f"DIRECT_REVEAL_RETENTION_CONFLICT {key}")
    if reveal.get("future_bundle_pre_generation") is not False:
        errors.append("OBSERVATION_FAIRNESS_CONFLICT future bundle pre-generation")

    fairness = contract.get("fairness_contract", {})
    if fairness.get("enemy_bundle_locked_before_reveal") is not True:
        errors.append("OBSERVATION_FAIRNESS_CONFLICT enemy pre-lock")
    if fairness.get("enemy_may_replan_after_reveal") is not False:
        errors.append("OBSERVATION_FAIRNESS_CONFLICT enemy post-reveal replan")
    if fairness.get("enemy_may_read_uncommitted_player_plan") is not False:
        errors.append("OBSERVATION_FAIRNESS_CONFLICT player plan read")
    if fairness.get("reveal_uses_actual_locked_action_types") is not True:
        errors.append("OBSERVATION_FAIRNESS_CONFLICT actual action types")
    if fairness.get("player_commits_after_reveal") is not True:
        errors.append("OBSERVATION_FAIRNESS_CONFLICT commit order")

    forbidden = set(contract.get("forbidden_outputs", []))
    for missing in sorted(REQUIRED_FORBIDDEN - forbidden):
        code = "ANSWER_AUTOMATION_CONFLICT" if missing == "RECOMMENDED_CORRECT_COUNTER" else "HIDDEN_INFORMATION_CONFLICT"
        errors.append(f"{code} missing {missing}")

    risk = contract.get("risk_policy", {})
    if risk.get("preserve_current_design") is not True:
        errors.append("DIRECT_REVEAL_RETENTION_CONFLICT preserve_current_design")
    if risk.get("automatic_nerf") is not False:
        errors.append("AUTOMATIC_OBSERVATION_CHANGE_CONFLICT automatic_nerf")
    if risk.get("automatic_reprice") is not False:
        errors.append("AUTOMATIC_OBSERVATION_CHANGE_CONFLICT automatic_reprice")
    if risk.get("automatic_category_blurring") is not False:
        errors.append("AUTOMATIC_OBSERVATION_CHANGE_CONFLICT automatic_category_blurring")
    if risk.get("planning_change_requires_new_user_decision") is not True:
        errors.append("USER_DECISION_GATE_CONFLICT")
    if risk.get("measurement_does_not_change_runtime_by_itself") is not True:
        errors.append("AUTOMATIC_OBSERVATION_CHANGE_CONFLICT measurement mutation")

    metrics = set(contract.get("measurement_metrics", []))
    for missing in sorted(REQUIRED_METRICS - metrics):
        errors.append(f"OBSERVATION_MEASUREMENT_CONFLICT missing {missing}")

    protocol = contract.get("measurement_protocol", {})
    if protocol.get("minimum_valid_observed_bundles") != 30:
        errors.append("OBSERVATION_MEASUREMENT_CONFLICT minimum sample")
    if protocol.get("warning_thresholds_are_recommended_defaults") is not True:
        errors.append("OBSERVATION_MEASUREMENT_CONFLICT threshold authority")
    if protocol.get("exact_technique_inference_rate_warning_above") != 0.7:
        errors.append("OBSERVATION_MEASUREMENT_CONFLICT inference threshold")
    if protocol.get("correct_counter_uplift_percentage_points_warning_above") != 20:
        errors.append("OBSERVATION_MEASUREMENT_CONFLICT counter threshold")
    if protocol.get("full_bundle_reveal_rate_warning_above") != 0.5:
        errors.append("OBSERVATION_MEASUREMENT_CONFLICT full reveal threshold")
    if protocol.get("warnings_trigger_manual_review_only") is not True:
        errors.append("AUTOMATIC_OBSERVATION_CHANGE_CONFLICT warning action")
    if protocol.get("human_play_and_balance_validation") != "NOT_RUN":
        errors.append("EVIDENCE_OVERCLAIM_CONFLICT human validation")

    if contract.get("resolution_order") != EXPECTED_ORDER:
        errors.append("OBSERVATION_FAIRNESS_CONFLICT resolution order")

    batch = contract.get("approval_batch", {})
    if batch.get("active_planning_pr") != 92:
        errors.append("ACTIVE_PLANNING_STATE_CONFLICT pr")
    if batch.get("approved_decision_count") != 8:
        errors.append("ACTIVE_PLANNING_STATE_CONFLICT approval count")
    if batch.get("maximum_decision_count") != 10:
        errors.append("ACTIVE_PLANNING_STATE_CONFLICT maximum count")
    if batch.get("next_planning_decision") != "GRADE_FARMING_RISK":
        errors.append("ACTIVE_PLANNING_STATE_CONFLICT next decision")

    boundary = contract.get("product_boundary", {})
    for key in ("product_code_changed", "godot_changed", "html_poc_changed", "runtime_data_changed"):
        if boundary.get(key) is not False:
            errors.append(f"PRODUCT_SCOPE_CONFLICT {key}")
    for key in ("human_validation", "balance_validation", "accessibility_validation", "performance_validation"):
        if boundary.get(key) != "NOT_RUN":
            errors.append(f"EVIDENCE_OVERCLAIM_CONFLICT {key}")

    return errors


def validate_parent_authority() -> list[str]:
    errors: list[str] = []
    try:
        parent = read_text(PARENT_DECISION)
        combat = read_text(COMBAT_RULES)
    except OSError as exc:
        return [f"PARENT_AUTHORITY_CONFLICT cannot load parent: {exc}"]

    parent_required = [
        "앞 수부터 행동 종류를 공개",
        "공개량과 저장량에 상한은 없다",
        "남은 양을 다음 묶음으로 이월",
        "공개된 뒤에는 해당 묶음의 적 계획을 다른 행동으로 교체할 수 없다",
    ]
    combat_required = [
        "고정 관찰량 1 획득",
        "저장·획득 상한은 없다",
        "묶음·라운드 경계를 넘어 이월",
        "기술명·무공서명·정확한 비용·방향·거리·피해·사거리·대상·AI 가중치는 공개하지 않는다",
    ]
    for token in parent_required:
        if token not in parent:
            errors.append(f"PARENT_AUTHORITY_CONFLICT parent token: {token}")
    for token in combat_required:
        if token not in combat:
            errors.append(f"PARENT_AUTHORITY_CONFLICT combat token: {token}")
    return errors


def validate_canonical_files() -> list[str]:
    errors: list[str] = []
    for path in (DECISION, AMENDMENT):
        try:
            text = read_text(path)
        except OSError as exc:
            errors.append(f"CANONICAL_FILE_MISSING {path}: {exc}")
            continue
        if "TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01" not in text:
            errors.append(f"CANONICAL_DECISION_ID_MISSING {path}")

    try:
        active = read_text(ACTIVE_CONTEXT)
    except OSError as exc:
        errors.append(f"ACTIVE_PLANNING_STATE_CONFLICT cannot load Active Context: {exc}")
        return errors
    for token in (
        "active_planning_pr: 92",
        "active_approval_count: 8/10",
        "active_decision_state: APPROVED_DRAFT_OBSERVATION_ANSWER_LEAK_GUARDRAILS",
        "next_planning_decision: GRADE_FARMING_RISK",
        "TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01",
    ):
        if token not in active:
            errors.append(f"ACTIVE_PLANNING_STATE_CONFLICT missing {token}")

    for path in STABLE_ENTRYPOINTS:
        try:
            text = read_text(path)
        except OSError as exc:
            errors.append(f"CANONICAL_ENTRYPOINT_MISSING {path}: {exc}")
            continue
        if "ACTIVE_CONTEXT.md" not in text:
            errors.append(f"ACTIVE_CONTEXT_DISCOVERY_CONFLICT {path}")
        for token in MUTABLE_STATE_TOKENS:
            if token in text:
                errors.append(f"DUPLICATED_MUTABLE_STATE_CONFLICT {path}: {token}")

    targeted = {
        ROOT / "docs/01_GAME_DESIGN.md": "ACTIVE_DRAFT_PR82_APPROVED_PENDING_MERGE_2_OF_10",
        ROOT / "[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md": "현재 활성 승인 배치 | PR #82",
        ROOT / "[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md": "PASS_AT_PR82_HEAD",
    }
    for path, token in targeted.items():
        try:
            text = read_text(path)
        except OSError as exc:
            errors.append(f"CANONICAL_ENTRYPOINT_MISSING {path}: {exc}")
            continue
        if token in text:
            errors.append(f"STALE_ACTIVE_PLANNING_REFERENCE {path}: {token}")
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
    errors.extend(validate_parent_authority())
    errors.extend(validate_canonical_files())
    if errors:
        for error in errors:
            print(error)
        return 1
    print("OBSERVATION_ANSWER_LEAK_GUARDRAILS_CONTRACT_PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
