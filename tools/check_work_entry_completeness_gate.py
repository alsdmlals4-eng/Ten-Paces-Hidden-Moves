#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DECISION_ID = "TEN-DEC-20260806-WORK-ENTRY-COMPLETENESS-GATE-01"
SOLO_DECISION_ID = "TEN-DEC-20260806-SOLO-MAINTAINER-REVIEW-EXCEPTION-01"


class GateError(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise GateError(message)


def load_json(relative: str) -> dict:
    path = ROOT / relative
    require(path.is_file(), f"WORK_ENTRY_BLOCKED_UNVERIFIED: missing {relative}")
    value = json.loads(path.read_text(encoding="utf-8"))
    require(isinstance(value, dict), f"WORK_ENTRY_BLOCKED_UNVERIFIED: invalid {relative}")
    return value


def main() -> None:
    contract = load_json("docs/planning-data/approved_20260806_work_entry_completeness_gate.json")
    solo = load_json("docs/planning-data/approved_20260806_solo_maintainer_review_exception.json")
    snapshot = load_json("docs/planning-data/sheet_work_entry_gate_snapshot_20260806.json")
    state = load_json("docs/planning-data/current_operating_state.json")

    decision_path = ROOT / "docs/decisions/2026-08-06_WORK_ENTRY_COMPLETENESS_GATE_DECISION.md"
    solo_decision_path = ROOT / "docs/decisions/2026-08-06_SOLO_MAINTAINER_REVIEW_EXCEPTION_DECISION.md"
    active_path = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
    require(decision_path.is_file(), "WORK_ENTRY_BLOCKED_UNVERIFIED: Decision missing")
    require(solo_decision_path.is_file(), "WORK_ENTRY_BLOCKED_UNVERIFIED: solo-maintainer Decision missing")
    require(active_path.is_file(), "WORK_ENTRY_BLOCKED_UNVERIFIED: Active Context missing")

    require(contract.get("decision_id") == DECISION_ID, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: Decision ID mismatch")
    require(contract.get("mode") == "FAIL_CLOSED", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: gate must fail closed")
    require(contract.get("blocking_gate") is True, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: blocking gate disabled")
    require(contract.get("checklist_only") is False, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: checklist-only bypass enabled")

    required = contract.get("required_readbacks")
    require(isinstance(required, list) and len(required) == 6, "WORK_ENTRY_BLOCKED_UNVERIFIED: mandatory readbacks incomplete")

    product_gate = contract.get("product_implementation", {})
    require(product_gate.get("entry_state") == "BLOCKED", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: product entry must be blocked")
    require(
        product_gate.get("reason") == "PLANNING_REVIEW_VISUAL_AND_AUTHORITY_GATES_OPEN",
        "PLANNING_REVIEW_VISUAL_AND_AUTHORITY_GATES_OPEN",
    )

    require(solo.get("decision_id") == SOLO_DECISION_ID, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: solo Decision ID mismatch")
    require(solo.get("repository") == "alsdmlals4-eng/Ten-Paces-Hidden-Moves", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: solo exception repository differs")
    require(solo.get("scope") == "PROJECT_WIDE_WHILE_SOLO_MAINTAINED", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: solo exception scope differs")
    require(solo.get("independent_review") == "WAIVED_WHILE_ACTIVATION_CONDITION_TRUE", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: solo review waiver differs")
    require(solo.get("review_record") == "SOLO_MAINTAINER_REVIEW_ATTESTATION", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: fake independent review record")

    activation = solo.get("activation_condition", {})
    require(activation.get("sole_maintainer_required") is True, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: sole-maintainer condition missing")
    require(activation.get("independent_reviewer_candidates_required") == 0, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: reviewer candidate condition differs")
    require(activation.get("collaborator_and_reviewer_readback_required_per_pr") is True, "WORK_ENTRY_BLOCKED_UNVERIFIED: collaborator readback missing")

    controls = solo.get("required_controls", {})
    for key in (
        "fresh_base_github_sheet_readback",
        "exact_head_required",
        "all_required_checks_pass",
        "tdd_evidence_required",
        "adversarial_diff_review_required",
        "unresolved_threads_zero",
        "open_p0_p1_zero",
        "github_sheet_same_decision_id",
        "explicit_user_merge_authorization_per_pr",
        "head_change_invalidates_attestation",
    ):
        require(controls.get(key) is True, f"WORK_ENTRY_BLOCKED_CANON_CONFLICT: required solo control disabled: {key}")
    require(controls.get("automatic_merge_allowed") is False, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: automatic merge cannot be enabled")

    waivers = solo.get("waivers", {})
    for key in (
        "tests",
        "exact_head_validation",
        "adversarial_review",
        "runtime_or_human_evidence",
        "security_or_permission_safety",
        "branch_protection_change_approval",
        "product_entry_gate",
        "postmerge_main_and_sheet_sync",
    ):
        require(waivers.get(key) is False, f"WORK_ENTRY_BLOCKED_CANON_CONFLICT: forbidden waiver enabled: {key}")

    suspension = solo.get("suspension", {})
    require(suspension.get("on_additional_reviewer_or_maintainer") is True, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: collaborator suspension missing")
    require(suspension.get("result") == "MERGE_BLOCKED_UNTIL_REVALIDATED", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: suspension result differs")
    require(solo.get("product_implementation_effect") == "NONE", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: solo exception cannot release product implementation")
    require(solo.get("current_product_entry") == "BLOCKED_BY_WORK_ENTRY_COMPLETENESS_GATE", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: product entry state differs")

    solo_decision = solo_decision_path.read_text(encoding="utf-8")
    for marker in (
        SOLO_DECISION_ID,
        "PROJECT_WIDE_WHILE_SOLO_MAINTAINED",
        "SOLO_MAINTAINER_REVIEW_ATTESTATION",
        "NO_FAKE_INDEPENDENT_APPROVE",
        "EXPLICIT_USER_MERGE_AUTHORIZATION_PER_PR",
        "PRODUCT_ENTRY_GATE_NOT_WAIVED",
    ):
        require(marker in solo_decision, f"WORK_ENTRY_BLOCKED_UNVERIFIED: solo Decision marker missing: {marker}")

    require(snapshot.get("product_implementation_entry") == "BLOCKED", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: false READY state")
    require(snapshot.get("unresolved", {}).get("blocking_finding") == "P0_RUNTIME_AUTHORITY_GAP", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: unresolved list differs")
    require(snapshot.get("visual_review", {}).get("approval_state") == "IN_REVIEW", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: image review state differs")
    require(snapshot.get("visual_review", {}).get("runtime_validation") == "NOT_RUN", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: image runtime state differs")

    require(state.get("authority") == "CURRENT_OPERATING_STATE", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: current state authority differs")
    require(
        state.get("source_decision") == "TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01",
        "WORK_ENTRY_BLOCKED_CANON_CONFLICT: current state source differs",
    )
    require(state.get("active_planning_pr") == "NONE", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: unexpected active planning PR")
    require(
        state.get("next_package") == "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION",
        "WORK_ENTRY_BLOCKED_CANON_CONFLICT: next package differs",
    )
    require("next_package_state" not in state, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: gate state duplicated into adapter state")
    require("work_entry_completeness_gate" not in state, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: gate contract duplicated into adapter state")

    active = active_path.read_text(encoding="utf-8")
    require(DECISION_ID in active, "WORK_ENTRY_BLOCKED_UNVERIFIED: Active Context gate missing")
    require("active_tooling_pr: 104" in active, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: tooling PR differs")
    require("product_implementation_entry: BLOCKED" in active, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: Active Context false READY")
    require("NO_NEW_VISUAL_ASSET_REQUIRED" in active, "WORK_ENTRY_BLOCKED_UNVERIFIED: tooling visual disposition missing")
    require("next_package_state: READY" not in active, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: false READY remains")
    require("next_package_state: AWAITING_IMPLEMENTATION" not in active, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: false AWAITING remains")

    print("work entry completeness gate: PASS (solo review exception bounded; product implementation remains blocked)")


if __name__ == "__main__":
    main()
