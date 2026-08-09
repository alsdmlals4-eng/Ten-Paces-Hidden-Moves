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

    def test_new_decision_and_contract_define_active_authority_split(self) -> None:
        self.assertTrue(DECISION.is_file(), "active-toolchain Decision must exist")
        self.assertTrue(CONTRACT.is_file(), "active-toolchain structured contract must exist")

        decision = DECISION.read_text(encoding="utf-8")
        for token in (
            DECISION_ID,
            "3.1.3",
            "9.7.1",
            "1.0.0",
            "SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY",
            "DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY",
            "LIVE_QA_AND_OBSERVABILITY_ONLY",
            "ten-paces-higodot-recovery@b62b",
            "HERA_CLI_ADDON_PAIR_UNVERIFIED",
            "PASS_USER_LOCAL_COMMAND_READBACK",
            "SUPERSEDED_DO_NOT_EXECUTE",
        ):
            self.assertIn(token, decision)

        contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, contract["decision_id"])
        self.assertEqual("3.1.3", contract["godot_ai"]["version"])
        self.assertEqual("SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY", contract["godot_ai"]["role"])
        self.assertEqual("9.7.1", contract["gut"]["version"])
        self.assertEqual("DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY", contract["gut"]["role"])
        self.assertEqual("PASS_USER_LOCAL_COMMAND_READBACK", contract["gut"]["local_clean_checkout"])
        self.assertEqual("1.0.0", contract["hera"]["version"])
        self.assertEqual("LIVE_QA_AND_OBSERVABILITY_ONLY", contract["hera"]["role"])
        self.assertEqual("FORBIDDEN", contract["hera"]["persistent_mutation"])
        self.assertEqual("ten-paces-higodot-recovery@b62b", contract["local_higodot_l0"]["session_id"])
        self.assertEqual("PASS_OBSERVED_EXISTING_STATE", contract["local_higodot_l0"]["state"])
        self.assertEqual("HERA_CLI_ADDON_PAIR_UNVERIFIED", contract["remaining_gates"]["hera_cli_pair"])
        self.assertEqual("NOT_RUN", contract["remaining_gates"]["hera_status"])
        self.assertEqual("NOT_RUN", contract["remaining_gates"]["hera_smoke_skip_game"])
        self.assertEqual(
            "PASS_USER_LOCAL_COMMAND_READBACK",
            contract["remaining_gates"]["local_gut_clean_checkout"],
        )
        self.assertEqual(
            "FAIL_USER_LOCAL_COMMAND_READBACK_ROOT_CAUSE_PENDING",
            contract["remaining_gates"]["godot_import_parse"],
        )
        self.assertEqual(
            "BLOCKED_GODOT_IMPORT_PARSE_FAIL_HERA_CLI_UNRESOLVED",
            contract["remaining_gates"]["local_windows"],
        )

        local = contract["local_clean_collector_console"]
        self.assertEqual("USER_LOCAL_COMMAND_READBACK", local["evidence_level"])
        self.assertEqual("f0d85bd81981e608a43979ed0e5dc7a8763bd15f", local["head"])
        self.assertEqual(local["head"], local["origin_main"])
        self.assertTrue(local["working_tree_clean"])
        self.assertEqual("LOCAL_SYNC_CURRENT", local["git_sync_status"])
        self.assertEqual("PASS", local["gut_status"])
        self.assertEqual("FAIL", local["godot_import_parse"])
        self.assertEqual("HERA_CLI_NOT_FOUND_OR_PATH_UNSET", local["hera_status"])
        self.assertEqual("NOT_AVAILABLE_STALE_UPLOAD_DETECTED", local["fresh_json_artifact"])

    def test_hera_record_separates_enabled_plugin_from_unverified_live_qa(self) -> None:
        record = json.loads(HERA_RECORD.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, record["decision_id"])
        self.assertTrue(record["enabled_in_project_godot"])
        self.assertEqual(
            "LOCAL_HIGODOT_L0_OBSERVED_EXISTING_ENABLED_STATE",
            record["enablement_evidence"],
        )
        self.assertEqual("ten-paces-higodot-recovery@b62b", record["enablement_session"])
        self.assertEqual("PLUGIN_ENABLED_L0_OBSERVED_CLI_PAIR_UNVERIFIED", record["adoption_status"])
        self.assertIsNone(record["exact_local_cli_version"])
        self.assertNotIn(
            "HIGODOT_L2_ENABLE_HERA_PLUGIN_IF_ADOPTION_CONTINUES",
            record["required_before_active"],
        )
        for required in (
            "VERIFY_WINDOWS_AMD64_CLI_ARTIFACT_SHA256",
            "HERA_VERSION_EXACT_V1_0_0",
            "FULL_EDITOR_RESTART",
            "HERA_STATUS_TARGET_PROJECT",
            "HERA_SMOKE_SKIP_GAME",
            "TRACKED_SOURCE_POST_HERA_DELTA_NONE",
        ):
            self.assertIn(required, record["required_before_active"])

    def test_entry_gate_reflects_enabled_state_without_opening_product_gate(self) -> None:
        gate = json.loads(ENTRY_GATE.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, gate["decision_id"])
        self.assertTrue(gate["hera_plugin_currently_enabled"])
        self.assertEqual("LOCAL_HIGODOT_L0_OBSERVED_EXISTING_ENABLED_STATE", gate["hera_plugin_enablement_evidence"])
        self.assertEqual("HERA_CLI_ADDON_PAIR_UNVERIFIED", gate["hera_cli_pair"])
        self.assertEqual("NOT_RUN", gate["hera_status"])
        self.assertEqual("NOT_RUN", gate["hera_smoke_skip_game"])
        self.assertEqual("PASS_USER_LOCAL_COMMAND_READBACK", gate["local_gut_clean_checkout"])
        self.assertEqual("FAIL_USER_LOCAL_COMMAND_READBACK_ROOT_CAUSE_PENDING", gate["godot_import_parse"])
        self.assertEqual(
            "BLOCKED_GODOT_IMPORT_PARSE_FAIL_HERA_CLI_UNRESOLVED",
            gate["local_windows_checkout"],
        )
        self.assertIn(
            "CAPTURE_FRESH_GODOT_VERSION_AND_IMPORT_PARSE_LOGS_FROM_CLEAN_COLLECTOR_RUN",
            gate["allowed_next_actions"],
        )
        self.assertNotIn(
            "HIGODOT_L2_ENABLE_HERA_PLUGIN_IF_ADOPTION_CONTINUES",
            gate["allowed_next_actions"],
        )
        self.assertFalse(gate["product_implementation_authorized"])

    def test_one_time_protected_approval_is_archived_after_merge(self) -> None:
        self.assertFalse(
            ACTIVE_APPROVAL.exists(),
            "merged one-time active-toolchain protected approval must not authorize later PRs",
        )
        self.assertTrue(ARCHIVED_APPROVAL.is_file(), "merged protected approval audit record must exist")
        record = ARCHIVED_APPROVAL.read_text(encoding="utf-8")
        for token in (
            "status: HISTORICAL_MERGED",
            "product_pr: 123",
            "product_head: 6029bf5e8f7801ba894552ad61dd0193684626a9",
            "product_merge_commit: 00a5502f1e40db77dce9495a57292b77bf4e3a5a",
            "protected_base_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90",
            "approved_paths: [project.godot]",
            f"decision_ids: [{DECISION_ID}]",
            "approval_source: USER_EXPLICIT_KEEP_GUT_HERA_AND_CONTINUOUS_WORK_2026-08-09",
            "external_approval: GITHUB_PR_LABEL_APPROVED_PROTECTED_CHANGE",
        ):
            self.assertIn(token, record)

        contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
        approval = contract["protected_approval"]
        self.assertEqual("HISTORICAL_MERGED", approval["status"])
        self.assertEqual(
            "docs/operations/2026-08-09_ACTIVE_TOOLCHAIN_PROTECTED_CHANGE_APPROVAL_RECORD.md",
            approval["historical_record"],
        )
        self.assertFalse(approval["active_manifest_present"])


if __name__ == "__main__":
    unittest.main()
