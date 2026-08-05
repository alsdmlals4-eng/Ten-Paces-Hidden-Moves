#!/usr/bin/env python3
from __future__ import annotations

import json
import pathlib
import re
import sys
from typing import Any

ROOT = pathlib.Path(__file__).resolve().parents[1]
ACTIVE_PATH = pathlib.Path("[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md")
ROADMAP_PATH = pathlib.Path("docs/04_ROADMAP.md")
MASTERY_PATH = pathlib.Path("docs/06_STARTING_FACTION_MASTERY_DATA.md")
REGISTRY_PATH = pathlib.Path("docs/CANON_LIFECYCLE_REGISTRY.md")
RANGE_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md")
OLD_TECHNIQUE_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md")
OLD_TECHNIQUE_CONTRACT_PATH = pathlib.Path("docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json")
AUDIT_CONTRACT_PATH = pathlib.Path("docs/planning-data/approved_20260804_postmerge_canon_adversarial_audit_contract.json")

EXPECTED_RISKS = {
    "RESOURCE_SATURATION_RISK",
    "CONDITION_CALIBRATION_RISK",
    "WRONG_PLAN_RESCUE_RISK",
    "OBSERVATION_ANSWER_LEAK_RISK",
    "GRADE_FARMING_RISK",
    "RUNTIME_AUTHORITY_GAP",
}
OPERATING_KEYS = (
    "active_planning_pr",
    "active_planning_parent_pr",
    "active_approval_count",
    "active_decision_state",
    "next_planning_decision",
)
MERGED_OR_HELD_PR_IDS = {84, 85, 86, 87, 88, 90}


class CanonLifecycleError(ValueError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise CanonLifecycleError(message)


def read_text(root: pathlib.Path, relative: pathlib.Path) -> str:
    path = root / relative
    require(path.is_file(), f"missing canon lifecycle file: {relative.as_posix()}")
    return path.read_text(encoding="utf-8")


def read_json(root: pathlib.Path, relative: pathlib.Path) -> dict[str, Any]:
    try:
        value = json.loads(read_text(root, relative))
    except json.JSONDecodeError as exc:
        raise CanonLifecycleError(f"invalid JSON in {relative.as_posix()}: {exc}") from exc
    require(isinstance(value, dict), f"{relative.as_posix()} must contain a JSON object")
    return value


def yaml_scalar(text: str, key: str) -> str:
    matches = re.findall(rf"(?m)^{re.escape(key)}:\s*([^\s#]+)\s*(?:#.*)?$", text)
    require(len(matches) == 1, f"operating checkpoint key must appear exactly once: {key}")
    return matches[0]


def parse_pr_id(value: str, field: str, allow_none: bool) -> int | None:
    if value == "NONE":
        require(allow_none, f"{field} cannot be NONE")
        return None
    require(value.isdigit(), f"{field} must be a PR number or NONE")
    return int(value)


def validate_operating_state(active: str, roadmap: str) -> None:
    active_state = {key: yaml_scalar(active, key) for key in OPERATING_KEYS}
    roadmap_state = {key: yaml_scalar(roadmap, key) for key in OPERATING_KEYS}
    require(active_state == roadmap_state, "operating checkpoint mismatch between active context and roadmap")

    active_pr = parse_pr_id(active_state["active_planning_pr"], "active planning PR", True)
    parent_pr = parse_pr_id(active_state["active_planning_parent_pr"], "active planning parent PR", True)
    require(active_pr == 92, "active planning PR differs from current Draft PR #92")
    require(active_pr not in MERGED_OR_HELD_PR_IDS, "active planning PR points to merged or held historical PR")
    require(parent_pr == 91, "active planning parent PR differs")
    require(parent_pr not in MERGED_OR_HELD_PR_IDS, "active planning parent PR points to merged or held historical PR")
    require(parent_pr < active_pr, "stacked planning parent PR must precede active PR")
    require(active_state["active_approval_count"] == "9/10", "active approval count differs")
    require(
        active_state["active_decision_state"] == "APPROVED_DRAFT_TEN_RECOGNIZABLE_MARTIAL_MANUALS",
        "active planning decision state differs",
    )
    require(
        active_state["next_planning_decision"] == "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",
        "next planning decision differs",
    )

    for token in [
        "runtime_work_mode: REVIEW",
        "runtime_integration_pr: 65",
        "runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65",
        "human_validation: NOT_RUN",
        "TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01",
        "DRAFT_PR92_TEN_RECOGNIZABLE_MARTIAL_MANUALS_9_OF_10",
    ]:
        require(token in active, f"active context missing operating token: {token}")
    for token in [
        "프로젝트 코어 확정",
        "STEP 14",
        "T1 — 최소 세로 슬라이스",
        "KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST",
        "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",
        "NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT",
    ]:
        require(token in roadmap, f"roadmap missing operating token: {token}")


def validate_superseded_authority(range_decision: str, old_decision: str, old_contract: dict[str, Any]) -> None:
    require("# [대체됨]" in range_decision, "range Decision lifecycle label [대체됨] missing")
    require("상태: `SUPERSEDED`" in range_decision, "range Decision lifecycle status must be SUPERSEDED")
    require("TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01" in range_decision, "range Decision replacement authority missing")
    require("# [대체됨]" in old_decision, "Technique1 Decision lifecycle label [대체됨] missing")
    require("상태: `SUPERSEDED`" in old_decision, "Technique1 Decision must be SUPERSEDED")
    require(
        old_contract.get("authority_status") == "SUPERSEDED_HISTORICAL_EVIDENCE",
        "superseded Technique1 contract cannot claim current authority",
    )
    require(
        old_contract.get("implementation_authority") == "HISTORICAL_PLANNING_EVIDENCE_ONLY",
        "superseded Technique1 contract implementation authority differs",
    )
    require(old_contract.get("lifecycle_label_ko") == "[대체됨]", "superseded Technique1 contract Korean lifecycle label missing")
    require(
        old_contract.get("superseded_by") == "TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01",
        "superseded Technique1 contract replacement differs",
    )


def validate_registry(registry: str) -> None:
    for token in [
        "[현행]", "[대체됨]", "[보류]", "[폐기]",
        "PR #85 HTML Technique1 PoC",
        "닫힘·병합 금지·제품 권위 없음",
        "81765e35c179b7a57eaa527a307080b63c32f0b8",
        "731e6431e76ebc76841f9253e87cd1e7a693ebb2",
        "0ba841ff2e62b2f716466356dd9e7ffcf587d150",
        "TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01",
        "approved_20260806_ten_recognizable_martial_manuals_contract.json",
        "approved_20260806_ten_manual_growth_budget_overlay_contract.json",
        "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",
        "9성 공개 정보 자동 분기 가설",
    ]:
        require(token in registry, f"canon lifecycle registry missing token: {token}")


def validate_mastery(mastery: str) -> None:
    for token in [
        "T1 이후 가설 원본",
        "active_batch: 9/10",
        "action_slots",
        "sure_hit",
        "프로젝트 코어가 사용자 승인",
        "approved_20260804_existing_action_reprice_contract.json",
        "approved_20260804_technique1_conditional_rework_star5_contract.json",
        "approved_20260805_grade_farming_guardrails_contract.json",
        "approved_20260805_star7_star9_mastery_bonus_contract.json",
        "9성 | 기술2 단일 완성 보너스",
        "현재 T0에는 세력 선택",
        "공용 절초 3종",
        "approved_20260806_ten_recognizable_martial_manuals_contract.json",
        "approved_20260806_ten_manual_growth_budget_overlay_contract.json",
        "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",
    ]:
        require(token in mastery, f"growth authority missing token: {token}")
    require("active_batch: 10/10" not in mastery, "growth authority still claims superseded active batch 10/10")
    require("9성 | 기술2 공개 정보 자동 분기" not in mastery, "growth authority still claims automatic branch")
    require(
        "approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`은 `[대체됨]`" in mastery,
        "growth authority must mark old Technique1 contract as superseded",
    )


def validate_historical_audit(data: dict[str, Any]) -> None:
    require(data.get("decision_id") == "TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01", "post-merge audit decision id differs")
    risks = data.get("adversarial_risks", {})
    require(set(risks) == EXPECTED_RISKS, "adversarial risk coverage differs")
    held = data.get("held_artifacts")
    require(isinstance(held, list) and len(held) == 1, "held artifact coverage differs")
    html_pr = held[0]
    require(html_pr.get("surface") == "GITHUB_PR" and html_pr.get("id") == 85, "held HTML PR identity differs")
    require(html_pr.get("merge_allowed") is False, "held HTML PR cannot be mergeable authority")
    require(html_pr.get("current_product_authority") is False, "held HTML PR cannot be product authority")
    order = data.get("next_planning_order")
    require(isinstance(order, list) and bool(order), "next planning order missing")
    require(order[0] == "STAR9_PUBLIC_READ_BRANCH_TEMPLATE", "9-star template must precede individual branches in historical audit")
    require("SIX_INDIVIDUAL_STAR9_AUTOMATIC_BRANCHES" in order, "individual 9-star branch stage missing in historical audit")


def validate(root: pathlib.Path = ROOT) -> None:
    active = read_text(root, ACTIVE_PATH)
    roadmap = read_text(root, ROADMAP_PATH)
    mastery = read_text(root, MASTERY_PATH)
    registry = read_text(root, REGISTRY_PATH)
    range_decision = read_text(root, RANGE_DECISION_PATH)
    old_decision = read_text(root, OLD_TECHNIQUE_DECISION_PATH)
    old_contract = read_json(root, OLD_TECHNIQUE_CONTRACT_PATH)
    audit = read_json(root, AUDIT_CONTRACT_PATH)
    validate_operating_state(active, roadmap)
    validate_superseded_authority(range_decision, old_decision, old_contract)
    validate_registry(registry)
    validate_mastery(mastery)
    validate_historical_audit(audit)


def main() -> int:
    try:
        validate(ROOT)
    except (OSError, CanonLifecycleError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("PASS: post-merge canon lifecycle and current mastery checkpoint are valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
