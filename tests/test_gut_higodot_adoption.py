from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DECISION = ROOT / "docs/decisions/2026-08-06_GUT_9_7_1_TEST_FRAMEWORK_ADOPTION_DECISION.md"
CONTRACT = ROOT / "docs/planning-data/approved_20260806_gut_higodot_test_authority_contract.json"
HIGODOT_RECORD = ROOT / "docs/planning-data/HIGODOT_ADOPTION_RECORD.json"
GUT_CONFIG = ROOT / ".gutconfig.json"
GUT_TEST = ROOT / "tests/gut/test_martial_manual_registry.gd"
WORKFLOW = ROOT / ".github/workflows/validate-gut-higodot-adoption.yml"
PROJECT = ROOT / "project.godot"
EXPORT_PRESETS = ROOT / "export_presets.cfg"
START_HERE = ROOT / "START_HERE.md"


class GutHiGodotAdoptionTests(unittest.TestCase):
    def test_authority_contract_exists_and_separates_roles(self) -> None:
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(payload["decision_id"], "TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01")
        self.assertEqual(payload["gut"]["version"], "9.7.1")
        self.assertEqual(payload["gut"]["upstream_commit"], "aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605")
        self.assertEqual(payload["gut"]["adoption_state"], "TRIAL_APPROVED")
        self.assertEqual(payload["gut"]["owner_boundary"], "GDSCRIPT_TEST_EXECUTION_AND_JUNIT_ONLY")
        self.assertEqual(payload["higodot"]["version"], "3.1.2")
        self.assertEqual(payload["higodot"]["execution_authority"], "SOLE_GODOT_AUTHORING_AUTHORITY")
        self.assertEqual(payload["higodot"]["network_mode"], "LOOPBACK_ONLY")
        self.assertEqual(payload["higodot"]["runtime_helper"]["autoload"], "_mcp_game_helper")
        self.assertEqual(payload["higodot"]["runtime_helper"]["status"], "EXISTING_BASELINE_PRESENT")
        self.assertTrue(payload["higodot"]["runtime_helper"]["product_export_dependency"])
        self.assertEqual(
            payload["higodot"]["runtime_helper"]["removal_state"],
            "BLOCKED_PENDING_HIGODOT_L1_OR_L2_VALIDATION",
        )
        self.assertFalse(payload["production_readiness"])

    def test_decision_records_approval_and_non_overclaiming(self) -> None:
        text = DECISION.read_text(encoding="utf-8")
        for marker in (
            "TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01",
            "APPROVED_FOR_IMPLEMENTATION",
            "GUT 9.7.1",
            "HiGodot 3.1.2",
            "SOLE_GODOT_AUTHORING_AUTHORITY",
            "GDSCRIPT_TEST_EXECUTION_AND_JUNIT_ONLY",
            "EXISTING_BASELINE_PRESENT",
            "BLOCKED_PENDING_HIGODOT_L1_OR_L2_VALIDATION",
            "HUMAN_NOT_RUN",
            "ANDROID_NOT_RUN",
        ):
            self.assertIn(marker, text)

    def test_higodot_record_is_exact_and_fail_closed(self) -> None:
        payload = json.loads(HIGODOT_RECORD.read_text(encoding="utf-8"))
        self.assertEqual(payload["provider"], "hi-godot/godot-ai")
        self.assertEqual(payload["exact_release"], "v3.1.2")
        self.assertEqual(
            payload["release_asset_sha256"],
            "60915d780e112aa25b142a596548786a0fb558f795278b9337722532e5dfdb33",
        )
        self.assertEqual(payload["execution_authority"], "SOLE_GODOT_AUTHORING_AUTHORITY")
        self.assertEqual(payload["network_mode"], "LOOPBACK_ONLY")
        self.assertEqual(payload["deepseek_profile"]["mcp_registration"], "ABSENT_REQUIRED")
        self.assertEqual(payload["mcp_host_registration"], "UNVERIFIED")
        helper = payload["runtime_helper_boundary"]
        self.assertEqual(helper["autoload"], "_mcp_game_helper")
        self.assertEqual(helper["path"], "res://addons/godot_ai/runtime/game_helper.gd")
        self.assertEqual(helper["status"], "EXISTING_BASELINE_PRESENT")
        self.assertTrue(helper["included_by_current_product_export"])
        self.assertEqual(helper["removal_state"], "BLOCKED_PENDING_HIGODOT_L1_OR_L2_VALIDATION")
        self.assertFalse(payload["production_readiness"])

    def test_project_keeps_higodot_enabled_and_gut_cli_only(self) -> None:
        text = PROJECT.read_text(encoding="utf-8")
        match = re.search(r"enabled=PackedStringArray\(([^\n]+)\)", text)
        self.assertIsNotNone(match)
        enabled = match.group(1)
        self.assertIn('res://addons/godot_ai/plugin.cfg', enabled)
        self.assertNotIn('res://addons/gut/plugin.cfg', enabled)
        self.assertIn('_mcp_game_helper="*res://addons/godot_ai/runtime/game_helper.gd"', text)

    def test_gut_has_real_consumption_path_and_junit_output(self) -> None:
        config = json.loads(GUT_CONFIG.read_text(encoding="utf-8"))
        self.assertEqual(config["dirs"], ["res://tests/gut"])
        self.assertTrue(config["include_subdirs"])
        self.assertTrue(config["should_exit"])
        self.assertEqual(config["junit_xml_file"], "res://build/test-results/gut.xml")

        test_text = GUT_TEST.read_text(encoding="utf-8")
        self.assertIn("extends GutTest", test_text)
        self.assertIn("MartialManualRegistry", test_text)
        self.assertIn("test_registry_loads_exactly_ten_manuals", test_text)
        self.assertIn("test_mastery_unlock_boundaries", test_text)

    def test_workflow_runs_static_runtime_and_entry_gates(self) -> None:
        text = WORKFLOW.read_text(encoding="utf-8")
        for marker in (
            "tests.test_gut_higodot_adoption",
            "tests.test_conflict_marker_detection",
            "tests.test_work_entry_completeness_gate",
            "python tools/check_work_entry_completeness_gate.py",
            "chickensoft-games/setup-godot@v2",
            "version: 4.7.1",
            "mkdir -p build/test-results",
            "res://addons/gut/gut_cmdln.gd",
            "-gconfig=res://.gutconfig.json",
            "build/test-results/gut.xml",
            "actions/upload-artifact@v4",
        ):
            self.assertIn(marker, text)

    def test_product_export_excludes_gut_without_breaking_existing_higodot_autoload(self) -> None:
        text = EXPORT_PRESETS.read_text(encoding="utf-8")
        self.assertIn("addons/gut/**", text)
        self.assertIn("tests/gut/**", text)
        self.assertIn(".gutconfig.json", text)
        self.assertNotIn("addons/godot_ai/**", text)

    def test_start_here_uses_current_platform_authority(self) -> None:
        text = START_HERE.read_text(encoding="utf-8")
        self.assertIn("design_platforms: WINDOWS_ANDROID", text)
        self.assertIn("next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION", text)
        self.assertIn("next_package_state: BLOCKED_BY_WORK_ENTRY_COMPLETENESS_GATE", text)
        self.assertNotIn("future_platform: MOBILE_CONSIDERATION_ONLY", text)


if __name__ == "__main__":
    unittest.main()
