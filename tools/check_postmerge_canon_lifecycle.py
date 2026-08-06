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

STALE_ACTIVE_TOKENS = {
    "APPROVED_PENDING_MERGE",
    "ACTIVE_DRAFT_7_OF_10_PR87",
    "PR #87 남은 GrillMe 승인",
    "PR #87은 PR #86",
}
MERGED_OR_HELD_PR_IDS = {84, 85, 86, 87, 88}
OPERATING_KEYS = (
    "active_planning_pr",
    "active_planning_parent_pr",
    "active_approval_count",
    "active_decision_state",
    "next_planning_decision",
)


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
    text = read_text(root, relative)
    try:
        data = json.loads(text)
    except json.JSONDecodeError as exc:
        raise CanonLifecycleError(f"invalid JSON in {relative.as_posix()}: {exc}") from exc
    require(isinstance(data, dict), f"{relative.as_posix()} must contain a JSON object")
    return data


def yaml_scalar(text: str, key: str) -> str:
    matches = re.findall(rf"(?m)^{re.escape(key)}:\s*([^\s#]+)\s*(?:#.*)?$", text)
    require(len(matches) == 1, f"operating checkpoint key must appear exactly once: {key}")
    return matches[0]


def parse_pr_id(value: str, field: str, *, allow_none: bool) -> int | None:
    if value == "NONE":
        require(allow_none, f"{field} cannot be NONE")
        return None
    require(value.isdigit(), f"{field} must be a PR number or NONE")
    return int(value)


def validate_operating_state(active: str, roadmap: str) -> None:
    for token in STALE_ACTIVE_TOKENS:
        require(token not in active, f"active planning PR state is stale: {token}")
        require(token not in roadmap, f"roadmap active planning PR state is stale: {token}")

    active_state = {key: yaml_scalar(active, key) for key in OPERATING_KEYS}
    roadmap_state = {key: yaml_scalar(roadmap, key) for key in OPERATING_KEYS}
    require(active_state == roadmap_state, "operating checkpoint mismatch between active context and roadmap")

    active_pr = parse_pr_id(active_state["active_planning_pr"], "active planning PR", allow_none=True)
    parent_pr = parse_pr_id(active_state["active_planning_parent_pr"], "active planning parent PR", allow_none=True)
    decision_state = active_state["active_decision_state"]
    next_decision = active_state["next_planning_decision"]

    if active_pr is None:
        require(parent_pr is None, "merged checkpoint cannot have an active planning parent PR")
        require(decision_state == "MERGED_CANON_CHECKPOINT", "merged checkpoint decision state differs")
    else:
        require(active_pr not in MERGED_OR_HELD_PR_IDS, "active planning PR points to merged or held historical PR")
        require(parent_pr != active_pr, "active planning PR cannot be its own parent")
        if parent_pr is not None:
            require(parent_pr not in MERGED_OR_HELD_PR_IDS, "active planning parent PR points to merged or held historical PR")
            require(parent_pr < active_pr, "stacked planning parent PR must precede active PR")
        require(
            decision_state.startswith("APPROVED_DRAFT_") or decision_state.startswith("ACTIVE_DRAFT_"),
            "active planning checkpoint requires a draft decision state",
        )

    require(active_state["active_approval_count"] == "7/10", "active approval count differs")
    require(bool(next_decision) and next_decision != "NONE", "next planning decision is missing")

    for token in [
        "runtime_work_mode: REVIEW",
        "runtime_integration_pr: 65",
        "runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65",
        "automated_validation: PASS",
        "human_validation: NOT_RUN",
        "2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md",
    ]:
        require(token in active, f"active context missing operating token: {token}")

    for token in [
        "프로젝트 코어 확정",
        "STEP 14",
        "T1 — 최소 세로 슬라이스",
        "KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST",
    ]:
        require(token in roadmap, f"roadmap missing operating token: {token}")


def validate_superseded_authority(
    range_decision: str,
    old_technique_decision: str,
    old_technique_contract: dict[str, Any],
) -> None:
    require("# [대체됨]" in range_decision, "range Decision lifecycle label [대체됨] missing")
    require("상태: `SUPERSEDED`" in range_decision, "range Decision lifecycle status must be SUPERSEDED")
    require("TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01" in range_decision, "range Decision replacement authority missing")

    require("# [대체됨]" in old_technique_decision, "Technique1 Decision lifecycle label [대체됨] missing")
    require("상태: `SUPERSEDED`" in old_technique_decision, "Technique1 Decision must be SUPERSEDED")
    require("TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01" in old_technique_decision, "Technique1 replacement authority missing")

    require(
        old_technique_contract.get("authority_status") == "SUPERSEDED_HISTORICAL_EVIDENCE",
        "superseded Technique1 contract cannot claim current authority",
    )
    require(
        old_technique_contract.get("implementation_authority") == "HISTORICAL_PLANNING_EVIDENCE_ONLY",
        "superseded Technique1 contract implementation authority differs",
    )
    require(old_technique_contract.get("lifecycle_label_ko") == "[대체됨]", "superseded Technique1 contract Korean lifecycle label missing")
    require(
        old_technique_contract.get("superseded_by") == "TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01",
        "superseded Technique1 contract replacement differs",
    )
    forbidden = set(old_technique_contract.get("forbidden_use", []))
    require("CURRENT_RUNTIME_DATA_GENERATION" in forbidden, "superseded Technique1 contract runtime-use ban missing")


def validate_registry(registry: str) -> None:
    for token in [
        "[현행]",
        "[대체됨]",
        "[보류]",
        "[폐기]",
        "PR #85 HTML Technique1 PoC",
        "닫힘·병합 금지·제품 권위 없음",
        "81765e35c179b7a57eaa527a307080b63c32f0b8",
        "731e6431e76ebc76841f9253e87cd1e7a693ebb2",
        "0ba841ff2e62b2f716466356dd9e7ffcf587d150",
        "STAR9_PUBLIC_READ_BRANCH_TEMPLATE",
    ]:
        require(token in registry, f"canon lifecycle registry missing token: {token}")


def validate_mastery(mastery: str) -> None:
    for token in [
        "T1 이후 가설 원본",
        "active_batch: 7/10",
        "action_slots",
        "sure_hit",
        "프로젝트 코어가 사용자 승인",
        "approved_20260804_existing_action_reprice_contract.json",
        "approved_20260804_technique1_conditional_rework_star5_contract.json",
        "STAR9_PUBLIC_READ_BRANCH_TEMPLATE",
    ]:
        require(token in mastery, f"growth authority missing token: {token}")
    require("active_batch: 6/10" not in mastery, "growth authority still claims active batch 6/10")
    require(
        "approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`은 `[대체됨]`" in mastery,
        "growth authority must mark old Technique1 contract as superseded",
    )


def validate_audit_contract(data: dict[str, Any]) -> None:
    require(data.get("schema_version") == 1, "post-merge audit schema version differs")
    require(data.get("decision_id") == "TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01", "post-merge audit decision id differs")
    require(data.get("authority_status") == "CURRENT_APPROVED_PLANNING_GOVERNANCE", "post-merge audit authority differs")
    require(data.get("base_main_commit") == "0ba841ff2e62b2f716466356dd9e7ffcf587d150", "post-merge audit base main differs")

    lineage = data.get("merged_pr_lineage")
    require(isinstance(lineage, list) and len(lineage) == 3, "merged PR lineage coverage differs")
    actual_lineage = {(item.get("pr"), item.get("merge_commit"), item.get("status")) for item in lineage}
    expected_lineage = {
        (84, "81765e35c179b7a57eaa527a307080b63c32f0b8", "MERGED"),
        (86, "731e6431e76ebc76841f9253e87cd1e7a693ebb2", "MERGED"),
        (87, "0ba841ff2e62b2f716466356dd9e7ffcf587d150", "MERGED"),
    }
    require(actual_lineage == expected_lineage, "merged PR lineage differs")

    operating = data.get("operating_state", {})
    require(operating.get("active_planning_pr") == "NONE", "audit active planning PR differs")
    require(operating.get("active_decision_state") == "MERGED_CANON_CHECKPOINT", "audit merged checkpoint state differs")
    require(operating.get("next_planning_decision") == "STAR9_PUBLIC_READ_BRANCH_TEMPLATE", "audit next planning decision differs")

    risks = data.get("adversarial_risks", {})
    require(set(risks) == EXPECTED_RISKS, "adversarial risk coverage differs")
    for risk_id in EXPECTED_RISKS:
        risk = risks[risk_id]
        require(risk.get("mechanic_change_approved") is False, f"{risk_id}: audit cannot silently approve mechanic change")
        require(risk.get("severity") in {"P0", "P1"}, f"{risk_id}: severity missing")
        if risk_id not in {"GRADE_FARMING_RISK", "RUNTIME_AUTHORITY_GAP"}:
            metrics = risk.get("required_metrics")
            require(isinstance(metrics, list) and len(metrics) >= 4, f"{risk_id}: required metrics missing")

    held = data.get("held_artifacts")
    require(isinstance(held, list) and len(held) == 1, "held artifact coverage differs")
    html_pr = held[0]
    require(html_pr.get("surface") == "GITHUB_PR" and html_pr.get("id") == 85, "held HTML PR identity differs")
    require(html_pr.get("label") == "[보류]", "held HTML PR lifecycle label differs")
    require(html_pr.get("merge_allowed") is False, "held HTML PR cannot be mergeable authority")
    require(html_pr.get("current_product_authority") is False, "held HTML PR cannot be product authority")

    order = data.get("next_planning_order")
    require(isinstance(order, list) and bool(order), "next planning order missing")
    require(order[0] == "STAR9_PUBLIC_READ_BRANCH_TEMPLATE", "9-star template must precede individual branches")
    require("SIX_INDIVIDUAL_STAR9_AUTOMATIC_BRANCHES" in order, "individual 9-star branch stage missing")

    runtime = data.get("runtime_boundary", {})
    require(runtime.get("product_code_changed") is False, "post-merge audit cannot change product code")
    require(runtime.get("runtime_data_changed") is False, "post-merge audit cannot change runtime data")
    for key in [
        "runtime_validation",
        "godot_validation",
        "windows_validation",
        "accessibility_validation",
        "human_validation",
        "balance_validation",
    ]:
        require(runtime.get(key) == "NOT_RUN", f"post-merge audit boundary differs: {key}")


def validate(root: pathlib.Path = ROOT) -> None:
    active = read_text(root, ACTIVE_PATH)
    roadmap = read_text(root, ROADMAP_PATH)
    mastery = read_text(root, MASTERY_PATH)
    registry = read_text(root, REGISTRY_PATH)
    range_decision = read_text(root, RANGE_DECISION_PATH)
    old_technique_decision = read_text(root, OLD_TECHNIQUE_DECISION_PATH)
    old_technique_contract = read_json(root, OLD_TECHNIQUE_CONTRACT_PATH)
    audit_contract = read_json(root, AUDIT_CONTRACT_PATH)

    validate_operating_state(active, roadmap)
    validate_superseded_authority(range_decision, old_technique_decision, old_technique_contract)
    validate_registry(registry)
    validate_mastery(mastery)
    validate_audit_contract(audit_contract)


def main() -> int:
    try:
        validate(ROOT)
    except (OSError, CanonLifecycleError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("PASS: post-merge canon lifecycle and adversarial audit contract are valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
