#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

DECISION_ID = "TEN_MANUAL_PRODUCT_VALIDATION_GATE"
GODOT_VERSION = "4.7.1"
PLATFORM = "windows-x86_64"
MASTERY_LEVELS = [3, 5, 7, 9, 10]
REQUIRED_SCENARIO_COUNT = 50
FORCED_NOT_RUN = [
    "windows_local_render",
    "gamepad_physical",
    "accessibility_user",
    "release_performance",
    "human_step14",
]
ALLOWED_PRODUCT_GATE = ["PARTIAL_AUTOMATED_COMPLETE", "FAIL", "BLOCKED"]
ARTIFACT_REQUIRED_FIELDS = [
    "name",
    "workflow_run_id",
    "build_utc",
    "preset",
    "repository",
    "pr",
    "head_sha",
]
SHA_RE = re.compile(r"^[0-9a-f]{40}$")


def _manual_ids(manifest: dict[str, Any]) -> list[str]:
    manual_files = manifest.get("manual_files")
    if not isinstance(manual_files, dict):
        return []
    return list(manual_files.keys())


def build_contract_from_manifest(manifest: dict[str, Any]) -> dict[str, Any]:
    scenario_matrix = [
        {
            "scenario_id": f"{manual_id}-star-{mastery}",
            "manual_id": manual_id,
            "mastery": mastery,
        }
        for manual_id in _manual_ids(manifest)
        for mastery in MASTERY_LEVELS
    ]
    return {
        "schema_version": 1,
        "decision_id": DECISION_ID,
        "design_spec": "docs/superpowers/specs/2026-08-06-ten-manual-product-validation-gate-design.md",
        "source_manifest": "data/cards/martial_manual_cards.json",
        "validated_product_baseline": "8832d0f54062ce999a5a9c5238f704854f96a0b1",
        "godot_version": GODOT_VERSION,
        "platform": PLATFORM,
        "export_preset": "Windows Desktop Product Validation",
        "viewports": [[1280, 800], [1440, 900], [1920, 1080]],
        "mastery_levels": MASTERY_LEVELS.copy(),
        "required_scenario_count": REQUIRED_SCENARIO_COUNT,
        "allowed_product_gate": ALLOWED_PRODUCT_GATE.copy(),
        "forced_not_run": FORCED_NOT_RUN.copy(),
        "artifact_required_fields": ARTIFACT_REQUIRED_FIELDS.copy(),
        "performance_environment_keys": ["runner", "godot_version"],
        "scenario_matrix": scenario_matrix,
    }


def validate_contract_document(
    contract: dict[str, Any], manifest: dict[str, Any]
) -> list[str]:
    errors: list[str] = []
    manual_ids = _manual_ids(manifest)
    if len(manual_ids) != 10 or len(set(manual_ids)) != 10:
        errors.append("manifest.manual_count must be exactly 10 unique manuals")

    exact_fields = {
        "decision_id": DECISION_ID,
        "godot_version": GODOT_VERSION,
        "platform": PLATFORM,
        "mastery_levels": MASTERY_LEVELS,
        "required_scenario_count": REQUIRED_SCENARIO_COUNT,
        "allowed_product_gate": ALLOWED_PRODUCT_GATE,
        "forced_not_run": FORCED_NOT_RUN,
        "artifact_required_fields": ARTIFACT_REQUIRED_FIELDS,
    }
    for key, expected in exact_fields.items():
        if contract.get(key) != expected:
            errors.append(f"contract.{key} must equal {expected!r}")

    scenario_matrix = contract.get("scenario_matrix")
    if not isinstance(scenario_matrix, list):
        errors.append("contract.scenario_count: scenario_matrix must be a list")
        return errors
    if len(scenario_matrix) != REQUIRED_SCENARIO_COUNT:
        errors.append(
            f"contract.scenario_count must be {REQUIRED_SCENARIO_COUNT}, got {len(scenario_matrix)}"
        )

    expected_pairs = {
        (manual_id, mastery)
        for manual_id in manual_ids
        for mastery in MASTERY_LEVELS
    }
    actual_pairs: set[tuple[str, int]] = set()
    scenario_ids: set[str] = set()
    for index, row in enumerate(scenario_matrix):
        if not isinstance(row, dict):
            errors.append(f"scenario_matrix[{index}] must be an object")
            continue
        manual_id = row.get("manual_id")
        mastery = row.get("mastery")
        scenario_id = row.get("scenario_id")
        if not isinstance(manual_id, str) or not isinstance(mastery, int):
            errors.append(f"scenario_matrix[{index}] manual_id/mastery invalid")
            continue
        actual_pairs.add((manual_id, mastery))
        expected_id = f"{manual_id}-star-{mastery}"
        if scenario_id != expected_id:
            errors.append(
                f"scenario_matrix[{index}].scenario_id must be {expected_id!r}"
            )
        if isinstance(scenario_id, str):
            if scenario_id in scenario_ids:
                errors.append(f"scenario_matrix duplicate scenario_id {scenario_id}")
            scenario_ids.add(scenario_id)

    if actual_pairs != expected_pairs:
        missing = sorted(expected_pairs - actual_pairs)
        extra = sorted(actual_pairs - expected_pairs)
        errors.append(f"contract.scenario_count pair mismatch missing={missing} extra={extra}")
    return errors


def validate_evidence_document(
    evidence: dict[str, Any],
    contract: dict[str, Any],
    *,
    expected_sha: str | None,
) -> list[str]:
    errors: list[str] = []
    if evidence.get("decision_id") != DECISION_ID:
        errors.append("evidence.decision_id mismatch")
    if evidence.get("godot_version") != contract.get("godot_version"):
        errors.append("evidence.godot_version mismatch")
    if evidence.get("platform") != contract.get("platform"):
        errors.append("evidence.platform mismatch")

    head_sha = evidence.get("head_sha")
    if not isinstance(head_sha, str) or not SHA_RE.fullmatch(head_sha):
        errors.append("evidence.head_sha must be a lowercase 40-character SHA")
    if expected_sha is not None and head_sha != expected_sha:
        errors.append(
            f"evidence.head_sha must match expected head_sha {expected_sha}, got {head_sha}"
        )

    expected_count = contract.get("required_scenario_count")
    if evidence.get("scenario_count") != expected_count:
        errors.append("evidence.scenario_count mismatch")
    if evidence.get("scenario_passed") != expected_count:
        errors.append("evidence.scenario_passed must equal scenario_count")
    if evidence.get("scenario_failed") != 0:
        errors.append("evidence.scenario_failed must be 0")

    automated_pass_fields = [
        "windows_export",
        "windows_ci_runtime",
        "keyboard_synthetic",
        "mouse_synthetic",
        "resolution_matrix",
        "accessibility_automated",
    ]
    for field in automated_pass_fields:
        if evidence.get(field) != "PASS":
            errors.append(f"evidence.{field} must be PASS")
    if evidence.get("performance_baseline") != "CAPTURED":
        errors.append("evidence.performance_baseline must be CAPTURED")

    for field in contract.get("forced_not_run", []):
        if evidence.get(field) != "NOT_RUN":
            errors.append(f"evidence.{field} must remain NOT_RUN")

    participant_count = evidence.get("participant_count")
    if not isinstance(participant_count, int) or participant_count < 0:
        errors.append("evidence.participant_count must be a non-negative integer")
    if participant_count == 0 and evidence.get("human_step14") != "NOT_RUN":
        errors.append("evidence.human_step14 cannot pass with participant_count 0")

    if evidence.get("product_gate") not in contract.get("allowed_product_gate", []):
        errors.append("evidence.product_gate is not an allowed state")
    if evidence.get("product_gate") == "PARTIAL_AUTOMATED_COMPLETE":
        if any(evidence.get(field) != "PASS" for field in automated_pass_fields):
            errors.append("evidence.product_gate partial completion requires automated PASS")
        if evidence.get("performance_baseline") != "CAPTURED":
            errors.append("evidence.product_gate partial completion requires baseline")

    artifact = evidence.get("artifact")
    if not isinstance(artifact, dict):
        errors.append("evidence.artifact must be an object")
    else:
        for field in contract.get("artifact_required_fields", []):
            if artifact.get(field) in (None, ""):
                errors.append(f"evidence.artifact.{field} is required")
        if artifact.get("head_sha") != head_sha:
            errors.append("evidence.artifact.head_sha must match evidence.head_sha")
        if artifact.get("preset") != contract.get("export_preset"):
            errors.append("evidence.artifact.preset mismatch")

    environment = evidence.get("performance_environment")
    if not isinstance(environment, dict):
        errors.append("evidence.performance_environment must be an object")
    else:
        for field in contract.get("performance_environment_keys", []):
            if environment.get(field) in (None, ""):
                errors.append(f"evidence.performance_environment.{field} is required")
        if environment.get("godot_version") != contract.get("godot_version"):
            errors.append("evidence.performance_environment.godot_version mismatch")

    baseline = evidence.get("comparison_baseline")
    if baseline is not None:
        if not isinstance(baseline, dict):
            errors.append("evidence.comparison_baseline must be an object")
        elif (
            baseline.get("runner") != environment.get("runner")
            or baseline.get("godot_version") != environment.get("godot_version")
        ):
            errors.append("evidence.performance baseline environment is not comparable")
    return errors


def _load_json(path: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"{path} must contain a JSON object")
    return data


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--expected-sha")
    parser.add_argument("--evidence", type=Path)
    args = parser.parse_args(argv)

    root = args.root.resolve()
    manifest_path = root / "data/cards/martial_manual_cards.json"
    contract_path = (
        root
        / "docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json"
    )
    try:
        manifest = _load_json(manifest_path)
        contract = _load_json(contract_path)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"TEN_MANUAL_PRODUCT_GATE_CONTRACT_ERROR: {exc}", file=sys.stderr)
        return 1

    errors = validate_contract_document(contract, manifest)
    if args.evidence is not None:
        evidence_path = args.evidence
        if not evidence_path.is_absolute():
            evidence_path = root / evidence_path
        try:
            evidence = _load_json(evidence_path)
        except (OSError, ValueError, json.JSONDecodeError) as exc:
            errors.append(f"evidence load failed: {exc}")
        else:
            errors.extend(
                validate_evidence_document(
                    evidence,
                    contract,
                    expected_sha=args.expected_sha,
                )
            )

    if errors:
        for error in errors:
            print(f"TEN_MANUAL_PRODUCT_GATE_ERROR: {error}", file=sys.stderr)
        return 1
    print("TEN_MANUAL_PRODUCT_GATE_CONTRACT_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
