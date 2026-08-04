#!/usr/bin/env python3
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
PARENT_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_combat_pricing_interruption_recovery_contract.json"
OVERLAY_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_resource_saturation_internal_recovery_contract.json"
DECISION_PATH = ROOT / "docs" / "decisions" / "2026-08-04_RESOURCE_SATURATION_INTERNAL_RECOVERY_DECISION.md"
PARENT_DECISION_PATH = ROOT / "docs" / "decisions" / "2026-08-04_COMBAT_PRICING_INTERRUPTION_RECOVERY_DECISION.md"
COMBAT_AMENDMENT_PATH = ROOT / "docs" / "02_COMBAT_RULES_RESOURCE_RECOVERY_AMENDMENT.md"
ROADMAP_AMENDMENT_PATH = ROOT / "docs" / "04_ROADMAP_RESOURCE_RISK_AMENDMENT.md"
LIFECYCLE_PATH = ROOT / "docs" / "CANON_LIFECYCLE_REGISTRY.md"
ACTIVE_CONTEXT_PATH = ROOT / "[기획서]" / "00_프로젝트_허브" / "ACTIVE_CONTEXT.md"

EXPECTED_TRANSITIONS = [
    "BUNDLE_1_TO_2",
    "BUNDLE_2_TO_3",
    "BUNDLE_3_TO_NEXT_ROUND_BUNDLE_1",
]
EXPECTED_RECOVERY = {"stamina": 1, "internal": 0, "ultimate_momentum": 1}
REQUIRED_ZERO_INTERNAL_ACTIONS = {
    "FREE_BASIC_ACTION",
    "MOVE",
    "PREPARE",
    "MEDITATE",
    "CLEAR_HEART_BREATH",
    "NO_INTERNAL_COST_ACTION",
}


class ResourceSaturationContractError(ValueError):
    pass


def _require(condition: bool, message: str) -> None:
    if not condition:
        raise ResourceSaturationContractError(message)


def effective_bundle_transition_recovery(parent: dict, overlay: dict) -> dict[str, int]:
    effective = dict(parent["bundle_transition_recovery"])
    effective.update(overlay["effective_bundle_transition_recovery"])
    return {key: effective[key] for key in ("stamina", "internal", "ultimate_momentum")}


def validate(parent: dict, overlay: dict) -> None:
    _require(parent.get("decision_id") == "TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01", "wrong parent decision")
    _require(overlay.get("decision_id") == "TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01", "wrong overlay decision")
    _require(overlay.get("authority_status") == "CURRENT_APPROVED_PLANNING", "wrong authority status")
    _require(overlay.get("risk_status") == "MITIGATED_PENDING_HUMAN_MEASUREMENT", "wrong risk status")
    _require(overlay.get("superseded_parent_fields") == ["bundle_transition_recovery.internal"], "wrong superseded field")

    amendment = parent.get("partial_amendment", {})
    _require(amendment.get("decision_id") == overlay.get("decision_id"), "parent amendment decision drift")
    _require(amendment.get("superseded_fields") == ["bundle_transition_recovery.internal"], "parent amendment field drift")

    parent_recovery = parent.get("bundle_transition_recovery", {})
    _require(parent_recovery.get("transitions") == EXPECTED_TRANSITIONS, "parent transition list drift")
    _require(parent_recovery.get("first_bundle_start") is False, "first bundle start recovery drift")
    _require(parent_recovery.get("stamina") == 1 and parent_recovery.get("ultimate_momentum") == 1, "parent non-internal recovery drift")
    _require(parent_recovery.get("caps_apply") is True and parent_recovery.get("before_enemy_plan_lock") is True, "parent recovery ordering drift")
    _require("[대체됨]" in parent_recovery.get("internal_lifecycle", ""), "parent internal lifecycle marker missing")

    effective = overlay.get("effective_bundle_transition_recovery", {})
    _require(effective.get("internal") == 0, "internal auto recovery must be zero")
    _require(effective.get("stamina") == 1 and effective.get("ultimate_momentum") == 1, "effective non-internal recovery drift")
    _require(effective.get("caps_apply") is True and effective.get("before_enemy_plan_lock") is True, "effective recovery ordering drift")
    _require(effective_bundle_transition_recovery(parent, overlay) == EXPECTED_RECOVERY, "effective recovery mismatch")
    _require(overlay.get("round_start_recovery", {}).get("internal") == 0, "round-start internal recovery is forbidden")

    prepared = parent.get("prepare", {}).get("prepared_meditation_gain", {})
    _require(prepared.get("internal") == 1, "prepared meditation internal recovery must remain 1")
    paths = set(overlay.get("explicit_internal_recovery_paths", []))
    _require("PREPARED_MEDITATION" in paths, "prepared meditation path missing")
    _require("CLEAR_HEART_BREATH" in paths, "clear heart recovery path missing")
    _require("APPROVED_CONDITIONAL_INTERNAL_RECOVERY" in paths, "conditional internal recovery path missing")

    legal = set(overlay.get("softlock_guard", {}).get("legal_at_internal_zero", []))
    _require(REQUIRED_ZERO_INTERNAL_ACTIONS.issubset(legal), "soft-lock fallback actions missing")
    _require(overlay.get("softlock_guard", {}).get("internal_zero_must_not_prevent_legal_bundle") is True, "soft-lock guard disabled")

    measurement = overlay.get("measurement_contract", {})
    _require(
        measurement.get("primary_metrics")
        == [
            "internal_zero_bundle_rate",
            "internal_constraint_plan_change_rate",
            "high_internal_action_consecutive_rate",
        ],
        "primary measurement contract incomplete",
    )
    _require({"RECOVERY_TAX_RISK", "RESOURCE_STARVATION_RISK"}.issubset(set(measurement.get("guardrails", []))), "measurement guardrails incomplete")
    _require(measurement.get("thresholds") == "DEFER_UNTIL_FIRST_HUMAN_MEASUREMENT_BATCH", "measurement threshold gate drift")

    boundary = overlay.get("validation_boundary", {})
    _require(boundary.get("human_validation") == "NOT_RUN", "human validation must remain NOT_RUN")
    for key in ("balance_validation", "godot_validation", "windows_validation", "accessibility_validation", "performance_validation"):
        _require(boundary.get(key) == "NOT_RUN", f"{key} must remain NOT_RUN")

    runtime = overlay.get("runtime_boundary", {})
    _require(all(value is False for value in runtime.values()), "runtime boundary changed")


def load_canon_documents() -> dict[str, str]:
    paths = {
        "decision": DECISION_PATH,
        "parent_decision": PARENT_DECISION_PATH,
        "combat_amendment": COMBAT_AMENDMENT_PATH,
        "roadmap_amendment": ROADMAP_AMENDMENT_PATH,
        "lifecycle": LIFECYCLE_PATH,
        "active_context": ACTIVE_CONTEXT_PATH,
    }
    return {name: path.read_text(encoding="utf-8") for name, path in paths.items()}


def validate_canon_documents(documents: dict[str, str]) -> None:
    decision = documents.get("decision", "")
    _require("- 승인일: 2026-08-04" in decision, "decision approval date drift")
    _require("internal_gain: 0" in decision, "decision effective internal recovery drift")
    _require("MITIGATED_PENDING_HUMAN_MEASUREMENT" in decision, "decision risk state drift")

    parent_decision = documents.get("parent_decision", "")
    _require("CURRENT_APPROVED_PLANNING_AMENDED" in parent_decision, "parent decision amendment state missing")
    _require("internal_gain: 0" in parent_decision, "parent decision effective internal recovery drift")
    _require("[대체됨]" in parent_decision and "bundle_transition_recovery.internal: 1" in parent_decision, "parent decision superseded field marker missing")

    combat = documents.get("combat_amendment", "")
    _require("- 상태: `[현행]`" in combat, "combat amendment current marker missing")
    _require("internal_gain: 0" in combat, "combat amendment effective internal recovery drift")
    _require("CANON_CONFLICT" in combat, "combat amendment conflict rule missing")

    roadmap = documents.get("roadmap_amendment", "")
    _require("RESOURCE_SATURATION_RISK`: `MITIGATED_PENDING_HUMAN_MEASUREMENT" in roadmap, "roadmap resource risk state drift")
    _require("CONDITION_CALIBRATION_RISK" in roadmap, "roadmap next risk missing")

    lifecycle = documents.get("lifecycle", "")
    _require("docs/02_COMBAT_RULES_RESOURCE_RECOVERY_AMENDMENT.md" in lifecycle, "lifecycle combat amendment missing")
    _require("docs/04_ROADMAP_RESOURCE_RISK_AMENDMENT.md" in lifecycle, "lifecycle roadmap amendment missing")
    superseded_token = "bundle_transition_recovery.internal=1` | `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`"
    _require(superseded_token in lifecycle, "superseded field authority marker missing")
    _require("#88 | `bbed0fd4d278ca0e0d52f4e6d9083aafa1997318`" in lifecycle, "merged PR88 lineage missing")

    active = documents.get("active_context", "")
    _require("active_planning_pr: 89" in active, "active PR89 pointer missing")
    _require("next_planning_decision: CONDITION_CALIBRATION_RISK" in active, "next risk pointer stale")
    _require("기력1·내력0·절초기세1" in active, "active recovery triple missing")
    _require("human_validation: NOT_RUN" in active and "balance_validation: NOT_RUN" in active, "active validation boundary drift")


def main() -> int:
    try:
        parent = json.loads(PARENT_PATH.read_text(encoding="utf-8"))
        overlay = json.loads(OVERLAY_PATH.read_text(encoding="utf-8"))
        validate(parent, overlay)
        validate_canon_documents(load_canon_documents())
    except (OSError, json.JSONDecodeError, ResourceSaturationContractError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("PASS: resource saturation internal recovery contract and canon surfaces are valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
