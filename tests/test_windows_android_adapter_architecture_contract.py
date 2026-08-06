import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "docs/planning-data/approved_20260806_windows_android_adapter_architecture_contract.json"
DECISION = ROOT / "docs/decisions/2026-08-06_WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_DECISION.md"
CHECKER = ROOT / "tools/check_windows_android_adapter_architecture_contract.py"
ACTIVE = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
ROADMAP = ROOT / "docs/04_ROADMAP.md"

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

REQUIRED_ADAPTERS = {
    "INPUT",
    "RESPONSIVE_UI",
    "APP_LIFECYCLE",
    "PLATFORM_SERVICES",
    "QUALITY_EXPORT",
}


class WindowsAndroidAdapterArchitectureContractTest(unittest.TestCase):
    def run_checker(self, contract_path: Path = CONTRACT) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(CHECKER), "--contract", str(contract_path)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def load_contract(self) -> dict:
        self.assertTrue(CONTRACT.is_file(), "adapter architecture contract is missing")
        return json.loads(CONTRACT.read_text(encoding="utf-8"))

    def mutate(self, edit) -> Path:
        data = self.load_contract()
        edit(data)
        temp = tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8")
        json.dump(data, temp, ensure_ascii=False, indent=2)
        temp.write("\n")
        temp.close()
        return Path(temp.name)

    def assert_mutation_rejected(self, edit, expected: str) -> None:
        mutated = self.mutate(edit)
        result = self.run_checker(mutated)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(expected, result.stdout + result.stderr)

    def test_contract_artifacts_exist(self):
        self.assertTrue(CONTRACT.is_file())
        self.assertTrue(DECISION.is_file())
        self.assertTrue(CHECKER.is_file())

    def test_approved_contract_passes(self):
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT_PASS", result.stdout)

    def test_shared_core_and_adapter_set_are_fixed(self):
        data = self.load_contract()
        self.assertEqual(data["decision_id"], "TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01")
        self.assertEqual(data["parent_decision"], "TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01")
        self.assertEqual(set(data["platforms"]), {"WINDOWS", "ANDROID"})
        self.assertEqual(set(data["adapter_layers"]), REQUIRED_ADAPTERS)
        self.assertEqual(data["core_policy"]["authority"], "SINGLE_SHARED_CORE")
        for key in ["combat_rules", "ai", "content_ids", "numeric_balance", "save_schema", "deterministic_resolution"]:
            self.assertEqual(data["core_policy"][key], "SHARED")

    def test_input_commands_are_device_neutral(self):
        data = self.load_contract()
        self.assertEqual(set(data["input_contract"]["logical_commands"]), REQUIRED_COMMANDS)
        self.assertEqual(data["input_contract"]["consumer_boundary"], "LOGICAL_COMMANDS_OR_INPUTMAP_ONLY")
        self.assertFalse(data["input_contract"]["hover_only_action_allowed"])
        self.assertTrue(data["input_contract"]["touch_reorder_requires_button_alternative"])
        self.assertEqual(data["input_contract"]["existing_raw_leaf_input_status"], "MIGRATION_REQUIRED_NOT_PRODUCT_FAILURE")

    def test_responsive_ui_has_accessible_numeric_defaults(self):
        ui = self.load_contract()["responsive_ui_contract"]
        self.assertEqual(ui["semantic_equivalence"], "REQUIRED")
        self.assertEqual(ui["minimum_touch_target_dp"], 48)
        self.assertEqual(ui["breakpoints_logical_px"], {"compact_max": 899, "standard_max": 1439, "wide_min": 1440})
        self.assertEqual(ui["compact_layout"], "STACKED_OR_BOTTOM_SHEET")
        self.assertFalse(ui["pixel_identical_layout_required"])

    def test_safe_area_back_and_orientation_contract(self):
        mobile = self.load_contract()["android_window_contract"]
        self.assertEqual(mobile["safe_area_api"], "DisplayServer.get_display_safe_area")
        self.assertEqual(mobile["cutout_api"], "DisplayServer.get_display_cutouts")
        self.assertEqual(mobile["back_event"], "WINDOW_EVENT_GO_BACK_REQUEST")
        self.assertEqual(mobile["back_priority"], ["CLOSE_TOP_OVERLAY", "CANCEL_REVERSIBLE_STEP", "OPEN_PAUSE_CONFIRM", "REQUEST_EXIT"])
        self.assertEqual(mobile["orientation_policy"], "LANDSCAPE_PRIMARY_PORTRAIT_NOT_SUPPORTED_IN_T1")

    def test_lifecycle_and_save_recovery_are_explicit(self):
        lifecycle = self.load_contract()["lifecycle_contract"]
        self.assertEqual(lifecycle["on_focus_lost"], "PAUSE_PRESENTATION_AND_BLOCK_NEW_COMMIT")
        self.assertEqual(lifecycle["on_pause"], "QUEUE_IDEMPOTENT_CHECKPOINT")
        self.assertEqual(lifecycle["on_stop_or_suspend"], "FLUSH_CHECKPOINT_IF_DIRTY")
        self.assertEqual(lifecycle["on_resume"], "RESTORE_UI_THEN_ACCEPT_INPUT")
        self.assertFalse(lifecycle["save_only_on_pause_allowed"])
        self.assertEqual(lifecycle["checkpoint_boundaries"], ["BUNDLE_COMMITTED", "BUNDLE_RESOLVED", "ROUTE_NODE_CHOSEN", "RESULT_ENTERED"])

    def test_save_schema_is_shared_atomic_and_versioned(self):
        save = self.load_contract()["save_contract"]
        self.assertEqual(save["path_root"], "user://")
        self.assertEqual(save["schema_authority"], "SHARED_CROSS_PLATFORM")
        self.assertEqual(save["write_policy"], "TEMP_WRITE_VALIDATE_ATOMIC_REPLACE")
        self.assertEqual(save["minimum_backups"], 1)
        self.assertTrue(save["schema_version_required"])
        self.assertTrue(save["migration_tests_required"])
        self.assertFalse(save["platform_specific_gameplay_fields_allowed"])

    def test_renderer_and_export_boundary_are_conservative(self):
        quality = self.load_contract()["quality_export_contract"]
        self.assertEqual(quality["shared_renderer_baseline"], "GL_COMPATIBILITY")
        self.assertEqual(quality["android_package_artifact"], "AAB_RELEASE")
        self.assertEqual(quality["android_local_validation_artifact"], "APK_DEBUG_OR_RELEASE")
        self.assertEqual(quality["release_signing_secret_policy"], "ENVIRONMENT_OR_SECRET_STORE_ONLY")
        self.assertFalse(quality["keystore_in_repository_allowed"])
        self.assertEqual(quality["android_export_status"], "NOT_RUN")

    def test_validation_matrix_does_not_overclaim(self):
        matrix = self.load_contract()["validation_matrix"]
        self.assertEqual(matrix["windows_ci_export_runtime"], "PASS_EXISTING_EVIDENCE")
        for key in [
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
        ]:
            self.assertEqual(matrix[key], "NOT_RUN", key)
        self.assertEqual(matrix["implementation_authority"], "PLANNING_CONTRACT_ONLY")

    def test_rejects_platform_specific_game_rules(self):
        self.assert_mutation_rejected(
            lambda data: data["core_policy"].update({"numeric_balance": "PLATFORM_SPECIFIC"}),
            "SHARED_CORE_CONFLICT",
        )

    def test_rejects_smaller_touch_targets(self):
        self.assert_mutation_rejected(
            lambda data: data["responsive_ui_contract"].update({"minimum_touch_target_dp": 40}),
            "ACCESSIBILITY_TARGET_CONFLICT",
        )

    def test_current_canon_discovers_the_contract(self):
        active = ACTIVE.read_text(encoding="utf-8")
        roadmap = ROADMAP.read_text(encoding="utf-8")
        for text in [active, roadmap]:
            self.assertIn("TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01", text)
            self.assertIn("WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", text)
            self.assertIn("android_validation: NOT_RUN", text)
        self.assertIn("active_approval_count: 1/10", active)
        self.assertIn("next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", active)


if __name__ == "__main__":
    unittest.main()
