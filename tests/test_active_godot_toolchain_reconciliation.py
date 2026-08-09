from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DECISION_ID = "TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01"
DECISION = ROOT / "docs/decisions/2026-08-09_GODOT_AI313_GUT971_HERA100_ACTIVE_TOOLCHAIN.md"
CONTRACT = ROOT / "docs/planning-data/active_godot_toolchain_20260809.json"
HERA_RECORD = ROOT / "docs/planning-data/HERA_ADOPTION_RECORD.json"
ENTRY_GATE = ROOT / "docs/planning-data/current_entry_gate_20260808.json"
ACTIVE_APPROVAL = ROOT / "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"
ARCHIVED_APPROVAL = ROOT / "docs/operations/2026-08-09_ACTIVE_TOOLCHAIN_PROTECTED_CHANGE_APPROVAL_RECORD.md"


def plugin_version(relative: str) -> str:
    text = (ROOT / relative).read_text(encoding="utf-8")
    match = re.search(r'^version="([^"]+)"$', text, flags=re.MULTILINE)
    if match is None:
        raise AssertionError(f"{relative} is missing plugin version")
    return match.group(1)


class ActiveGodotToolchainReconciliationTests(unittest.TestCase):
    def test_active_tool_versions_and_project_state_are_preserved(self) -> None:
        self.assertEqual("3.1.3", plugin_version("addons/godot_ai/plugin.cfg"))
        self.assertEqual("9.7.1", plugin_version("addons/gut/plugin.cfg"))
        self.assertEqual("1.0.0", plugin_version("addons/hera_agent_godot/plugin.cfg"))
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        for token in (
            'TenManualProductValidationBootstrap="*res://src/validation/ten_manual_product_validation_bootstrap.gd"',
            'HeraGameInspector="*uid://c4ug7a211oav8"',
            '_mcp_game_helper="*res://addons/godot_ai/runtime/game_helper.gd"',
        ):
            self.assertIn(token, project)
        self.assertIn(
            'enabled=PackedStringArray("res://addons/godot_ai/plugin.cfg", "res://addons/gut/plugin.cfg", "res://addons/hera_agent_godot/plugin.cfg")',
            project,
        )

    def test_decision_and_contract_define_authority_and_correct_local_claim_ceiling(self) -> None:
        decision = DECISION.read_text(encoding="utf-8")
        for token in (
            DECISION_ID,
            "3.1.3",
            "9.7.1",
            "1.0.0",
            "SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY",
            "DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY",
            "LIVE_QA_AND_OBSERVABILITY_ONLY",
            "HERA_CLI_ADDON_PAIR_UNVERIFIED",
            "HISTORICAL_PASS_GODOT_4_7_REVALIDATION_REQUIRED",
            "SUPERSEDED_DO_NOT_EXECUTE",
        ):
            self.assertIn(token, decision)

        contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, contract["decision_id"])
        self.assertEqual("4.7.1", contract["godot"]["local_acceptance_target"])
        self.assertEqual("3.1.3", contract["godot_ai"]["version"])
        self.assertEqual("SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY", contract["godot_ai"]["role"])
        self.assertEqual("9.7.1", contract["gut"]["version"])
        self.assertEqual("DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY", contract["gut"]["role"])
        self.assertEqual(
            "HISTORICAL_PASS_GODOT_4_7_REVALIDATION_REQUIRED",
            contract["gut"]["local_clean_checkout"],
        )
        self.assertEqual("1.0.0", contract["hera"]["version"])
        self.assertEqual("LIVE_QA_AND_OBSERVABILITY_ONLY", contract["hera"]["role"])
        self.assertEqual("FORBIDDEN", contract["hera"]["persistent_mutation"])
        self.assertEqual("HERA_CLI_ADDON_PAIR_UNVERIFIED", contract["remaining_gates"]["hera_cli_pair"])
        self.assertEqual("NOT_RUN", contract["remaining_gates"]["hera_status"])
        self.assertEqual("NOT_RUN", contract["remaining_gates"]["hera_smoke_skip_game"])
        self.assertEqual(
            "BLOCKED_REQUIRES_EXACT_GODOT_4_7_1_RERUN",
            contract["remaining_gates"]["local_gut_clean_checkout"],
        )
        self.assertEqual(
            "NOT_RUN_EXACT_GODOT_4_7_1_RERUN_REQUIRED",
            contract["remaining_gates"]["godot_import_parse"],
        )
        self.assertEqual(
            "BLOCKED_GODOT_4_7_1_RERUN_HERA_CLI_UNRESOLVED",
            contract["remaining_gates"]["local_windows"],
        )

        local = contract["local_clean_collector_console"]
        self.assertEqual("USER_LOCAL_FILE_READBACK", local["evidence_level"])
        self.assertEqual("4.7.stable.official.5b4e0cb0f", local["actual_godot_version"])
        self.assertEqual("WARNING_ONLY_NATIVE_STDERR_FALSE_FAIL", local["import_parse_diagnosis"])
        self.assertFalse(local["post_run_worktree_clean"])
        self.assertEqual("PASS_HISTORICAL_WRONG_GODOT_VERSION", local["gut_status"])
        self.assertEqual("PR127_MERGED_RERUN_NOT_RUN", local["collector_hardening"])

    def test_hera_record_separates_enabled_plugin_from_unverified_live_qa(self) -> None:
        record = json.loads(HERA_RECORD.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, record["decision_id"])
        self.assertTrue(record["enabled_in_project_godot"])
        self.assertEqual("PLUGIN_ENABLED_L0_OBSERVED_CLI_PAIR_UNVERIFIED", record["adoption_status"])
        self.assertIsNone(record["exact_local_cli_version"])
        for required in (
            "VERIFY_WINDOWS_AMD64_CLI_ARTIFACT_SHA256",
            "HERA_VERSION_EXACT_V1_0_0",
            "FULL_EDITOR_RESTART",
            "HERA_STATUS_TARGET_PROJECT",
            "HERA_SMOKE_SKIP_GAME",
            "TRACKED_SOURCE_POST_HERA_DELTA_NONE",
        ):
            self.assertIn(required, record["required_before_active"])

    def test_entry_gate_requires_exact_471_rerun_without_opening_product_gate(self) -> None:
        gate = json.loads(ENTRY_GATE.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, gate["decision_id"])
        self.assertTrue(gate["hera_plugin_currently_enabled"])
        self.assertEqual("HERA_CLI_ADDON_PAIR_UNVERIFIED", gate["hera_cli_pair"])
        self.assertEqual("NOT_RUN", gate["hera_status"])
        self.assertEqual("NOT_RUN", gate["hera_smoke_skip_game"])
        self.assertEqual("BLOCKED_REQUIRES_EXACT_GODOT_4_7_1_RERUN", gate["local_gut_clean_checkout"])
        self.assertEqual("NOT_RUN_EXACT_GODOT_4_7_1_RERUN_REQUIRED", gate["godot_import_parse"])
        self.assertEqual(
            "BLOCKED_GODOT_4_7_1_RERUN_HERA_CLI_UNRESOLVED",
            gate["local_windows_checkout"],
        )
        self.assertIn(
            "RUN_HARDENED_COLLECTOR_ON_FRESH_CLEAN_CHECKOUT_WITH_EXACT_GODOT_4_7_1",
            gate["allowed_next_actions"],
        )
        self.assertFalse(gate["product_implementation_authorized"])

    def test_one_time_protected_approval_is_archived_after_merge(self) -> None:
        self.assertFalse(ACTIVE_APPROVAL.exists())
        self.assertTrue(ARCHIVED_APPROVAL.is_file())
        contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
        approval = contract["protected_approval"]
        self.assertEqual("HISTORICAL_MERGED", approval["status"])
        self.assertFalse(approval["active_manifest_present"])


if __name__ == "__main__":
    unittest.main()
