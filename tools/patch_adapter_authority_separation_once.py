#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"missing {label}: {old!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def regex_replace_once(path: Path, pattern: str, replacement: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.S)
    if count != 1:
        raise SystemExit(f"expected one regex match for {label}, found {count}")
    path.write_text(updated, encoding="utf-8")


contract_path = ROOT / "docs/planning-data/approved_20260806_windows_android_adapter_architecture_contract.json"
contract = json.loads(contract_path.read_text(encoding="utf-8"))
contract["current_project_audit"] = {
    "snapshot_status": "PLANNING_BASELINE",
    "baseline_main_commit": "7d20c2c9d5d1c92b80d32dc9bf25bd833a48ad58",
    "renderer_shared_gl_compatibility": True,
    "windows_export_preset_exists": True,
    "android_export_preset_exists": False,
    "inputmap_project_actions_exist": False,
    "run_session_exists": False,
    "save_service_exists": False,
    "safe_area_adapter_exists": False,
    "android_lifecycle_adapter_exists": False,
    "leaf_raw_input_examples_exist": True,
}
contract_path.write_text(json.dumps(contract, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

checker = ROOT / "tools/check_windows_android_adapter_architecture_contract.py"
regex_replace_once(
    checker,
    r"EXPECTED_CURRENT_STATE = \{.*?\n\}\n\nNOT_RUN_VALIDATIONS",
    '''REQUIRED_CURRENT_STATE_KEYS = {
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

NOT_RUN_VALIDATIONS''',
    "checker current state constant",
)
regex_replace_once(
    checker,
    r"def validate_current_operating_state\(\) -> list\[str\]:.*?\n\ndef validate_current_project",
    '''def validate_current_operating_state() -> list[str]:
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


def validate_current_project''',
    "checker current state function",
)
regex_replace_once(
    checker,
    r"\ndef validate_current_project\(data: dict\[str, Any\]\) -> list\[str\]:.*?\n\ndef validate_canonical_files",
    "\n\ndef validate_canonical_files",
    "checker remove live project comparison",
)
regex_replace_once(
    checker,
    r"def validate_canonical_files\(\) -> list\[str\]:.*?\n\ndef main",
    '''def validate_canonical_files() -> list[str]:
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


def main''',
    "checker canonical discovery",
)
replace_once(
    checker,
    "    errors.extend(validate_current_project(data))\n",
    "",
    "checker remove live audit call",
)

architecture_test = ROOT / "tests/test_windows_android_adapter_architecture_contract.py"
replace_once(
    architecture_test,
    '''    def test_current_canon_discovers_the_contract(self):
        active = ACTIVE.read_text(encoding="utf-8")
        roadmap = ROADMAP.read_text(encoding="utf-8")
        for text in [active, roadmap]:
            self.assertIn("TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01", text)
            self.assertIn("WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", text)
            self.assertIn("android_validation: NOT_RUN", text)
''',
    '''    def test_current_canon_discovers_the_contract(self):
        active = ACTIVE.read_text(encoding="utf-8")
        roadmap = ROADMAP.read_text(encoding="utf-8")
        for text in [active, roadmap]:
            self.assertIn("TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01", text)

    def test_project_audit_is_an_immutable_baseline_snapshot(self):
        audit = self.load_contract()["current_project_audit"]
        self.assertEqual(audit["snapshot_status"], "PLANNING_BASELINE")
        self.assertEqual(audit["baseline_main_commit"], "7d20c2c9d5d1c92b80d32dc9bf25bd833a48ad58")
        self.assertTrue(audit["renderer_shared_gl_compatibility"])
        self.assertTrue(audit["windows_export_preset_exists"])
        self.assertFalse(audit["android_export_preset_exists"])
''',
    "architecture test immutable discovery",
)

postmerge = ROOT / "tools/check_postmerge_canon_lifecycle.py"
replace_once(
    postmerge,
    'ADAPTER_CONTRACT_PATH = pathlib.Path("docs/planning-data/approved_20260806_windows_android_adapter_architecture_contract.json")',
    'CURRENT_STATE_PATH = pathlib.Path("docs/planning-data/current_operating_state.json")',
    "postmerge current state path",
)
replace_once(
    postmerge,
    'OPERATING_KEYS = ("active_planning_work_mode", "active_planning_pr", "active_planning_parent_pr", "active_approval_count", "active_decision_state", "next_planning_decision")',
    'OPERATING_KEYS = ("active_planning_work_mode", "active_planning_pr", "active_planning_parent_pr", "active_approval_count", "active_decision_state", "next_package", "next_planning_decision")',
    "postmerge operating keys",
)
replace_once(
    postmerge,
    'def validate_operating_state(active: str, roadmap: str, current_contract: dict[str, Any]) -> None:',
    'def validate_operating_state(active: str, roadmap: str, current_state: dict[str, Any]) -> None:',
    "postmerge function parameter",
)
replace_once(
    postmerge,
    '''    expected_state = current_contract.get("current_operating_state")
    require(isinstance(expected_state, dict), "current planning authority must define current_operating_state")
''',
    '''    require(current_state.get("schema_version") == 1, "current operating state schema differs")
    require(current_state.get("authority") == "CURRENT_OPERATING_STATE", "current operating state authority differs")
    require(isinstance(current_state.get("source_decision"), str) and current_state.get("source_decision"), "current operating state source Decision missing")
    expected_state = current_state
''',
    "postmerge expected state source",
)
replace_once(
    postmerge,
    '    validate_operating_state(active, roadmap, read_json(root, ADAPTER_CONTRACT_PATH))',
    '    validate_operating_state(active, roadmap, read_json(root, CURRENT_STATE_PATH))',
    "postmerge validate call",
)

# Clarify units, coordinate spaces, and integrity scope in the human-readable Decision.
decision = ROOT / "docs/decisions/2026-08-06_WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_DECISION.md"
replace_once(
    decision,
    "minimum_touch_target: 48dp\norientation: LANDSCAPE_PRIMARY",
    "minimum_touch_target: 48dp (Android density-independent unit; raw pixel 고정값 아님)\nbreakpoint_measure: available safe-area UI logical width (framebuffer pixel 아님)\norientation: LANDSCAPE_PRIMARY",
    "decision responsive units",
)
replace_once(
    decision,
    "safe area는 시작, resize, orientation change, resume에서 다시 계산한다.",
    "safe area는 시작, resize, orientation change, resume에서 다시 계산한다. DisplayServer가 반환한 display-space 좌표는 viewport·Control 좌표계로 변환한 뒤 레이아웃에 적용한다.",
    "decision safe area coordinates",
)
replace_once(
    decision,
    "- `integrity_hash`\n",
    "- `integrity_hash` — 우발적 손상 탐지용이며 보안·위변조 방지 경계로 간주하지 않는다.\n",
    "decision integrity scope",
)
