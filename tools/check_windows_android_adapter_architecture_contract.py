#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONTRACT = ROOT / "docs/planning-data/approved_20260806_windows_android_adapter_architecture_contract.json"
CURRENT_STATE = ROOT / "docs/planning-data/current_operating_state.json"
DECISION = ROOT / "docs/decisions/2026-08-06_WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_DECISION.md"
PARENT_DECISION = ROOT / "docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md"
ACTIVE_CONTEXT = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
ROADMAP = ROOT / "docs/04_ROADMAP.md"
PROJECT_SETTINGS = ROOT / "project.godot"
EXPORT_PRESETS = ROOT / "export_presets.cfg"

DECISION_ID = "TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01"
PARENT_ID = "TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01"

REQUIRED_ADAPTERS = {
    "INPUT",
    "RESPONSIVE_UI",
    "APP_LIFECYCLE",
    "PLATFORM_SERVICES",
    "QUALITY_EXPORT",
}

REQUIRED_COMMANDS = {
    "NAVIGATE_LEFT",
    "NAVIGATE_RIGHT",
    "NAVIGATE_UP",
    "NAVIGATE_DOWN",
    "CONFIRM",
    "CANCEL_BACK",
    "TAB_PREVIOUS",
    "TAB_NEXT",
    "COMBAT_SELECT",
    "COMBAT_REMOVE",
    "COMBAT_COMMIT",
    "COMBAT_INSPECT",
    "REVIEW_PREVIOUS",
    "REVIEW_NEXT",
    "PAUSE_MENU",
}

SHARED_CORE_KEYS = {
    "combat_rules",
    "ai",
    "content_ids",
    "numeric_balance",
    "save_schema",
    "deterministic_resolution",
}

EXPECTED_BACK_PRIORITY = [
    "CLOSE_TOP_OVERLAY",
    "CANCEL_REVERSIBLE_STEP",
    "OPEN_PAUSE_CONFIRM",
    "REQUEST_EXIT",
]

EXPECTED_CHECKPOINTS = [
    "BUNDLE_COMMITTED",
    "BUNDLE_RESOLVED",
    "ROUTE_NODE_CHOSEN",
    "RESULT_ENTERED",
]

REQUIRED_CURRENT_STATE_KEYS = {
    "schema_version",
    "authority",
    "source_decision",
    "active_planning_work_mode",
    "active_planning_pr",
    "active_planning_parent_pr",
    "active_approval_count",
    "active_decision_state",
    "next_package",
    "next_planning_decision",
}

NOT_RUN_VALIDATIONS = {
    "windows_local_render",
    "physical_gamepad",
    "android_export",
    "android_install_launch",
    "android_touch",
    "android_back_safe_area",
    "android_pause_resume_restore",
    "android_performance",
    "accessibility_user",
    "release_performance",
}


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def validate_contract(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    if data.get("schema_version") != 1:
        errors.append("SCHEMA_CONFLICT")
    if data.get("decision_id") != DECISION_ID:
        errors.append("DECISION_AUTHORITY_CONFLICT")
    if data.get("parent_decision") != PARENT_ID:
        errors.append("PARENT_AUTHORITY_CONFLICT")
    if data.get("authority_status") != "CURRENT_APPROVED_PLANNING":
        errors.append("AUTHORITY_STATE_CONFLICT")
    if data.get("implementation_authority") != "PLANNING_CONTRACT_ONLY":
        errors.append("IMPLEMENTATION_SCOPE_CONFLICT")
    if "current_operating_state" in data:
        errors.append("MUTABLE_STATE_IN_IMMUTABLE_DECISION_CONFLICT")
    if set(data.get("platforms", [])) != {"WINDOWS", "ANDROID"}:
        errors.append("PLATFORM_SCOPE_CONFLICT")
    if set(data.get("adapter_layers", [])) != REQUIRED_ADAPTERS:
        errors.append("ADAPTER_LAYER_CONFLICT")

    batch = data.get("approval_batch", {})
    if batch.get("active_approval_count") != "1/10":
        errors.append("APPROVAL_BATCH_CONFLICT")
    if batch.get("maximum_decision_count") != 10:
        errors.append("APPROVAL_BATCH_CONFLICT")

    core = data.get("core_policy", {})
    if core.get("authority") != "SINGLE_SHARED_CORE":
        errors.append("SHARED_CORE_CONFLICT authority")
    for key in sorted(SHARED_CORE_KEYS):
        if core.get(key) != "SHARED":
            errors.append(f"SHARED_CORE_CONFLICT {key}")
    for key in (
        "platform_specific_game_rules_allowed",
        "platform_specific_balance_allowed",
        "platform_specific_save_meaning_allowed",
    ):
        if core.get(key) is not False:
            errors.append(f"SHARED_CORE_CONFLICT {key}")

    input_contract = data.get("input_contract", {})
    if set(input_contract.get("logical_commands", [])) != REQUIRED_COMMANDS:
        errors.append("INPUT_COMMAND_CONFLICT")
    if input_contract.get("consumer_boundary") != "LOGICAL_COMMANDS_OR_INPUTMAP_ONLY":
        errors.append("INPUT_BOUNDARY_CONFLICT")
    if input_contract.get("hover_only_action_allowed") is not False:
        errors.append("TOUCH_EQUIVALENCE_CONFLICT hover")
    if input_contract.get("touch_reorder_requires_button_alternative") is not True:
        errors.append("TOUCH_EQUIVALENCE_CONFLICT reorder")
    if input_contract.get("drag_required_for_core_action") is not False:
        errors.append("TOUCH_EQUIVALENCE_CONFLICT drag")
    if input_contract.get("focus_navigation_required") is not True:
        errors.append("ACCESSIBILITY_NAVIGATION_CONFLICT")
    if input_contract.get("existing_raw_leaf_input_status") != "MIGRATION_REQUIRED_NOT_PRODUCT_FAILURE":
        errors.append("CURRENT_CODE_AUDIT_CONFLICT raw input")

    ui = data.get("responsive_ui_contract", {})
    if ui.get("semantic_equivalence") != "REQUIRED":
        errors.append("RESPONSIVE_SEMANTICS_CONFLICT")
    if ui.get("pixel_identical_layout_required") is not False:
        errors.append("RESPONSIVE_LAYOUT_CONFLICT")
    if ui.get("minimum_touch_target_dp") != 48:
        errors.append("ACCESSIBILITY_TARGET_CONFLICT")
    if ui.get("touch_target_unit") != "ANDROID_DP_NOT_RAW_PIXELS":
        errors.append("ACCESSIBILITY_UNIT_CONFLICT")
    if ui.get("breakpoint_measure") != "AVAILABLE_SAFE_AREA_UI_LOGICAL_WIDTH_NOT_FRAMEBUFFER_PIXELS":
        errors.append("RESPONSIVE_MEASURE_CONFLICT")
    if ui.get("breakpoints_logical_px") != {
        "compact_max": 899,
        "standard_max": 1439,
        "wide_min": 1440,
    }:
        errors.append("RESPONSIVE_BREAKPOINT_CONFLICT")
    if ui.get("compact_layout") != "STACKED_OR_BOTTOM_SHEET":
        errors.append("RESPONSIVE_LAYOUT_CONFLICT compact")
    if ui.get("text_scaling_must_not_hide_actions") is not True:
        errors.append("ACCESSIBILITY_TEXT_CONFLICT")
    if ui.get("color_only_state_allowed") is not False:
        errors.append("ACCESSIBILITY_COLOR_CONFLICT")
    if ui.get("hover_only_information_allowed") is not False:
        errors.append("TOUCH_EQUIVALENCE_CONFLICT information")

    window = data.get("android_window_contract", {})
    if window.get("safe_area_api") != "DisplayServer.get_display_safe_area":
        errors.append("ANDROID_SAFE_AREA_CONFLICT")
    if window.get("cutout_api") != "DisplayServer.get_display_cutouts":
        errors.append("ANDROID_CUTOUT_CONFLICT")
    if window.get("safe_area_coordinate_conversion") != "DISPLAY_SPACE_TO_VIEWPORT_CONTROL_SPACE_REQUIRED":
        errors.append("ANDROID_SAFE_AREA_COORDINATE_CONFLICT")
    if window.get("back_event") != "WINDOW_EVENT_GO_BACK_REQUEST":
        errors.append("ANDROID_BACK_CONFLICT")
    if window.get("back_priority") != EXPECTED_BACK_PRIORITY:
        errors.append("ANDROID_BACK_CONFLICT priority")
    if window.get("orientation_policy") != "LANDSCAPE_PRIMARY_PORTRAIT_NOT_SUPPORTED_IN_T1":
        errors.append("ANDROID_ORIENTATION_CONFLICT")
    if window.get("core_interaction_may_overlap_system_bars") is not False:
        errors.append("ANDROID_SAFE_AREA_CONFLICT interaction")

    lifecycle = data.get("lifecycle_contract", {})
    expected_lifecycle = {
        "on_focus_lost": "PAUSE_PRESENTATION_AND_BLOCK_NEW_COMMIT",
        "on_pause": "QUEUE_IDEMPOTENT_CHECKPOINT",
        "on_stop_or_suspend": "FLUSH_CHECKPOINT_IF_DIRTY",
        "on_resume": "RESTORE_UI_THEN_ACCEPT_INPUT",
        "mid_resolution_restore_policy": "RESTORE_LAST_COMPLETED_DETERMINISTIC_BOUNDARY",
    }
    for key, expected in expected_lifecycle.items():
        if lifecycle.get(key) != expected:
            errors.append(f"APP_LIFECYCLE_CONFLICT {key}")
    if lifecycle.get("save_only_on_pause_allowed") is not False:
        errors.append("APP_LIFECYCLE_CONFLICT pause-only-save")
    if lifecycle.get("checkpoint_boundaries") != EXPECTED_CHECKPOINTS:
        errors.append("CHECKPOINT_BOUNDARY_CONFLICT")
    if lifecycle.get("resume_requires_duplicate_effect_guard") is not True:
        errors.append("RESUME_IDEMPOTENCY_CONFLICT")
    if lifecycle.get("background_simulation_allowed") is not False:
        errors.append("BACKGROUND_SIMULATION_CONFLICT")

    save = data.get("save_contract", {})
    if save.get("path_root") != "user://":
        errors.append("SAVE_PATH_CONFLICT")
    if save.get("schema_authority") != "SHARED_CROSS_PLATFORM":
        errors.append("SAVE_SCHEMA_CONFLICT")
    if save.get("write_policy") != "TEMP_WRITE_VALIDATE_ATOMIC_REPLACE":
        errors.append("SAVE_ATOMICITY_CONFLICT")
    if save.get("minimum_backups") != 1:
        errors.append("SAVE_BACKUP_CONFLICT")
    if save.get("schema_version_required") is not True:
        errors.append("SAVE_SCHEMA_CONFLICT version")
    if save.get("migration_tests_required") is not True:
        errors.append("SAVE_MIGRATION_CONFLICT")
    if save.get("platform_specific_gameplay_fields_allowed") is not False:
        errors.append("SAVE_SCHEMA_CONFLICT platform field")
    required_envelope = {
        "schema_version",
        "save_id",
        "written_at_utc",
        "app_version",
        "run_state",
        "integrity_hash",
    }
    if set(save.get("required_envelope_fields", [])) != required_envelope:
        errors.append("SAVE_ENVELOPE_CONFLICT")
    if save.get("integrity_hash_scope") != "CORRUPTION_DETECTION_NOT_SECURITY_BOUNDARY":
        errors.append("SAVE_INTEGRITY_SCOPE_CONFLICT")

    services = data.get("platform_services_contract", {})
    if services.get("service_boundary") != "OPTIONAL_ADAPTERS_MUST_NOT_CHANGE_OFFLINE_GAME_RULES":
        errors.append("PLATFORM_SERVICE_BOUNDARY_CONFLICT")
    for key in ("store_sdk", "cloud_save", "achievements", "billing", "ads", "push_notifications"):
        if services.get(key) != "DEFERRED":
            errors.append(f"PLATFORM_SERVICE_SCOPE_CONFLICT {key}")

    quality = data.get("quality_export_contract", {})
    if quality.get("shared_renderer_baseline") != "GL_COMPATIBILITY":
        errors.append("RENDERER_BASELINE_CONFLICT")
    if quality.get("android_package_artifact") != "AAB_RELEASE":
        errors.append("ANDROID_EXPORT_CONFLICT package")
    if quality.get("android_local_validation_artifact") != "APK_DEBUG_OR_RELEASE":
        errors.append("ANDROID_EXPORT_CONFLICT local artifact")
    if quality.get("android_architectures") != ["ARM64"]:
        errors.append("ANDROID_EXPORT_CONFLICT architecture")
    if quality.get("release_signing_secret_policy") != "ENVIRONMENT_OR_SECRET_STORE_ONLY":
        errors.append("SIGNING_SECRET_CONFLICT")
    if quality.get("keystore_in_repository_allowed") is not False:
        errors.append("SIGNING_SECRET_CONFLICT repository")
    if quality.get("android_export_status") != "NOT_RUN":
        errors.append("EVIDENCE_OVERCLAIM_CONFLICT android export")
    if quality.get("android_export_preset_status") != "NOT_CREATED":
        errors.append("CURRENT_CODE_AUDIT_CONFLICT android preset")
    if quality.get("windows_export_status") != "PASS_EXISTING_EVIDENCE":
        errors.append("WINDOWS_EVIDENCE_CONFLICT")

    matrix = data.get("validation_matrix", {})
    if matrix.get("windows_ci_export_runtime") != "PASS_EXISTING_EVIDENCE":
        errors.append("WINDOWS_EVIDENCE_CONFLICT matrix")
    for key in sorted(NOT_RUN_VALIDATIONS):
        if matrix.get(key) != "NOT_RUN":
            errors.append(f"EVIDENCE_OVERCLAIM_CONFLICT {key}")
    if matrix.get("implementation_authority") != "PLANNING_CONTRACT_ONLY":
        errors.append("IMPLEMENTATION_SCOPE_CONFLICT matrix")

    if data.get("next_gate") != "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE":
        errors.append("NEXT_GATE_CONFLICT")

    return errors


def validate_current_operating_state() -> list[str]:
    errors: list[str] = []
    try:
        state = load_json(CURRENT_STATE)
    except (OSError, json.JSONDecodeError) as exc:
        return [f"CURRENT_OPERATING_STATE_CONFLICT cannot load: {exc}"]
    if set(state) != REQUIRED_CURRENT_STATE_KEYS:
        errors.append("CURRENT_OPERATING_STATE_SCHEMA_CONFLICT")
    if state.get("schema_version") != 1:
        errors.append("CURRENT_OPERATING_STATE_SCHEMA_CONFLICT version")
    if state.get("authority") != "CURRENT_OPERATING_STATE":
        errors.append("CURRENT_OPERATING_STATE_AUTHORITY_CONFLICT")
    if not isinstance(state.get("source_decision"), str) or not state.get("source_decision"):
        errors.append("CURRENT_OPERATING_STATE_AUTHORITY_CONFLICT source")
    return errors



def validate_canonical_files() -> list[str]:
    errors: list[str] = []
    for path, tokens in {
        DECISION: [DECISION_ID, PARENT_ID, "PLANNING_CONTRACT_ONLY", "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE"],
        PARENT_DECISION: [PARENT_ID, "WINDOWS", "ANDROID", "SINGLE_SHARED_CORE"],
        ACTIVE_CONTEXT: [DECISION_ID],
        ROADMAP: [DECISION_ID],
    }.items():
        try:
            text = read_text(path)
        except OSError as exc:
            errors.append(f"CANONICAL_FILE_MISSING {path}: {exc}")
            continue
        for token in tokens:
            if token not in text:
                errors.append(f"CANONICAL_DISCOVERY_CONFLICT {path}: {token}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=Path, default=DEFAULT_CONTRACT)
    args = parser.parse_args()
    try:
        data = load_json(args.contract)
    except (OSError, json.JSONDecodeError) as exc:
        print(f"CONTRACT_LOAD_CONFLICT {exc}")
        return 1

    errors = validate_contract(data)
    errors.extend(validate_current_operating_state())
    errors.extend(validate_canonical_files())
    if errors:
        for error in errors:
            print(error)
        return 1
    print("WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT_PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
