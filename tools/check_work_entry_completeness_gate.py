#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DECISION_ID = "TEN-DEC-20260806-WORK-ENTRY-COMPLETENESS-GATE-01"


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
    snapshot = load_json("docs/planning-data/sheet_work_entry_gate_snapshot_20260806.json")
    state = load_json("docs/planning-data/current_operating_state.json")

    decision_path = ROOT / "docs/decisions/2026-08-06_WORK_ENTRY_COMPLETENESS_GATE_DECISION.md"
    active_path = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
    require(decision_path.is_file(), "WORK_ENTRY_BLOCKED_UNVERIFIED: Decision missing")
    require(active_path.is_file(), "WORK_ENTRY_BLOCKED_UNVERIFIED: Active Context missing")

    require(contract.get("decision_id") == DECISION_ID, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: Decision ID mismatch")
    require(contract.get("mode") == "FAIL_CLOSED", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: gate must fail closed")
    require(contract.get("blocking_gate") is True, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: blocking gate disabled")
    require(contract.get("checklist_only") is False, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: checklist-only bypass enabled")

    required = contract.get("required_readbacks")
    require(isinstance(required, list) and len(required) == 6, "WORK_ENTRY_BLOCKED_UNVERIFIED: mandatory readbacks incomplete")

    require(snapshot.get("product_implementation_entry") == "BLOCKED", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: false READY state")
    require(snapshot.get("unresolved", {}).get("blocking_finding") == "P0_RUNTIME_AUTHORITY_GAP", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: unresolved list differs")
    require(snapshot.get("visual_review", {}).get("approval_state") == "IN_REVIEW", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: image review state differs")
    require(snapshot.get("visual_review", {}).get("runtime_validation") == "NOT_RUN", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: image runtime state differs")

    gate = state.get("work_entry_completeness_gate")
    require(isinstance(gate, dict), "WORK_ENTRY_BLOCKED_UNVERIFIED: current operating gate missing")
    require(gate.get("decision_id") == DECISION_ID, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: operating Decision differs")
    require(gate.get("product_implementation_entry") == "BLOCKED", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: product entry must be blocked")
    require(gate.get("reason") == "PLANNING_REVIEW_VISUAL_AND_AUTHORITY_GATES_OPEN", "PLANNING_REVIEW_VISUAL_AND_AUTHORITY_GATES_OPEN")
    require(state.get("next_package_state") == "BLOCKED_BY_WORK_ENTRY_COMPLETENESS_GATE", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: next package state differs")
    require(state.get("active_tooling_pr") == "104", "WORK_ENTRY_BLOCKED_CANON_CONFLICT: tooling PR differs")

    active = active_path.read_text(encoding="utf-8")
    require(DECISION_ID in active, "WORK_ENTRY_BLOCKED_UNVERIFIED: Active Context gate missing")
    require("product_implementation_entry: BLOCKED" in active, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: Active Context false READY")
    require("NO_NEW_VISUAL_ASSET_REQUIRED" in active, "WORK_ENTRY_BLOCKED_UNVERIFIED: tooling visual disposition missing")
    require("next_package_state: READY" not in active, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: false READY remains")
    require("next_package_state: AWAITING_IMPLEMENTATION" not in active, "WORK_ENTRY_BLOCKED_CANON_CONFLICT: false AWAITING remains")

    print("work entry completeness gate: PASS (product implementation remains blocked)")


if __name__ == "__main__":
    main()
