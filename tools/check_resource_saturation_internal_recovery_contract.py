#!/usr/bin/env python3
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
PARENT_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_combat_pricing_interruption_recovery_contract.json"
OVERLAY_PATH = ROOT / "docs" / "planning-data" / "approved_20260804_resource_saturation_internal_recovery_contract.json"

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

    parent_recovery = parent.get("bundle_transition_recovery", {})
    _require(parent_recovery.get("transitions") == EXPECTED_TRANSITIONS, "parent transition list drift")
    _require(parent_recovery.get("first_bundle_start") is False, "first bundle start recovery drift")
    _require(parent_recovery.get("stamina") == 1 and parent_recovery.get("ultimate_momentum") == 1, "parent non-internal recovery drift")
    _require(parent_recovery.get("caps_apply") is True and parent_recovery.get("before_enemy_plan_lock") is True, "parent recovery ordering drift")

    effective = overlay.get("effective_bundle_transition_recovery", {})
    _require(effective.get("internal") == 0, "internal auto recovery must be zero")
    _require(effective.get("stamina") == 1 and effective.get("ultimate_momentum") == 1, "effective non-internal recovery drift")
    _require(effective.get("caps_apply") is True and effective.get("before_enemy_plan_lock") is True, "effective recovery ordering drift")
    _require(effective_bundle_transition_recovery(parent, overlay) == EXPECTED_RECOVERY, "effective recovery mismatch")
    _require(overlay.get("round_start_recovery", {}).get("internal") == 0, "round-start internal recovery is forbidden")

    prepared = parent.get("prepare", {}).get("prepared_meditation_gain", {})
    _require(prepared.get("internal") == 1, "prepared meditation internal recovery must remain 1")
    _require("PREPARED_MEDITATION" in overlay.get("explicit_internal_recovery_paths", []), "prepared meditation path missing")

    legal = set(overlay.get("softlock_guard", {}).get("legal_at_internal_zero", []))
    _require(REQUIRED_ZERO_INTERNAL_ACTIONS.issubset(legal), "soft-lock fallback actions missing")
    _require(overlay.get("softlock_guard", {}).get("internal_zero_must_not_prevent_legal_bundle") is True, "soft-lock guard disabled")

    measurement = overlay.get("measurement_contract", {})
    _require(len(measurement.get("primary_metrics", [])) == 3, "primary measurement contract incomplete")
    _require({"RECOVERY_TAX_RISK", "RESOURCE_STARVATION_RISK"}.issubset(set(measurement.get("guardrails", []))), "measurement guardrails incomplete")

    boundary = overlay.get("validation_boundary", {})
    _require(boundary.get("human_validation") == "NOT_RUN", "human validation must remain NOT_RUN")
    for key in ("balance_validation", "godot_validation", "windows_validation", "accessibility_validation", "performance_validation"):
        _require(boundary.get(key) == "NOT_RUN", f"{key} must remain NOT_RUN")

    runtime = overlay.get("runtime_boundary", {})
    _require(all(value is False for value in runtime.values()), "runtime boundary changed")


def main() -> int:
    try:
        parent = json.loads(PARENT_PATH.read_text(encoding="utf-8"))
        overlay = json.loads(OVERLAY_PATH.read_text(encoding="utf-8"))
        validate(parent, overlay)
    except (OSError, json.JSONDecodeError, ResourceSaturationContractError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("PASS: resource saturation internal recovery contract is valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
