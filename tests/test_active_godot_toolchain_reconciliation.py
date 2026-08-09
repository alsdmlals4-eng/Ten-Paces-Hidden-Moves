from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DECISION_ID = "TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01"
COLLECTOR_DECISION_ID = "TEN-DEC-20260809-LOCAL-GODOT-EVIDENCE-COLLECTOR-01"
DECISION = ROOT / "docs/decisions/2026-08-09_GODOT_AI313_GUT971_HERA100_ACTIVE_TOOLCHAIN.md"
CONTRACT = ROOT / "docs/planning-data/active_godot_toolchain_20260809.json"
LOCAL_ACCEPTANCE = ROOT / "docs/planning-data/local_godot_471_gut_junit_acceptance_20260810.json"
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

    def test_decision_and_contract_define_authority_and_promoted_local_claim_ceiling(self) -> None:
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
            "PASS_USER_LOCAL_COMMAND_TRANSCRIPT",
            "local_gut_junit_471: PASS",
            "SUPERSEDED_DO_NOT_EXECUTE",
        ):
            self.assertIn(token, decision)

        contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, contract["decision_id"])
        self.assertEqual("4.7.1", contract["godot"]["local_acceptance_target"])
        self.assertEqual("4.7.1.stable.official.a13da4feb", contract["godot"]["accepted_local_version"])
        self.assertEqual("PASS_USER_LOCAL_COMMAND_TRANSCRIPT", contract["godot"]["local_import_parse"])
        self.assertEqual("3.1.3", contract["godot_ai"]["version"])
        self.assertEqual("SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY", contract["godot_ai"]["role"])
        self.assertEqual("9.7.1", contract["gut"]["version"])
        self.assertEqual("DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY", contract["gut"]["role"])
        self.assertEqual(
            "PASS_EXACT_GODOT_4_7_1_GUT_9_7_1_JUNIT_USER_LOCAL_COMMAND_TRANSCRIPT",
            contract["gut"]["local_clean_checkout"],
        )
        self.assertEqual("PASS", contract["gut"]["local_test_execution"])
        self.assertEqual("PASS", contract["gut"]["local_junit"])
        self.assertEqual("1.0.0", contract["hera"]["version"])
        self.assertEqual("LIVE_QA_AND_OBSERVABILITY_ONLY", contract["hera"]["role"])
        self.assertEqual("FORBIDDEN", contract["hera"]["persistent_mutation"])
        self.assertEqual("HERA_CLI_ADDON_PAIR_UNVERIFIED", contract["remaining_gates"]["hera_cli_pair"])
        self.assertEqual("NOT_RUN", contract["remaining_gates"]["hera_status"])
        self.assertEqual("NOT_RUN", contract["remaining_gates"]["hera_smoke_skip_game"])
        self.assertEqual(
            "PASS_EXACT_GODOT_4_7_1_GUT_9_7_1_JUNIT_USER_LOCAL_COMMAND_TRANSCRIPT",
            contract["remaining_gates"]["local_gut_clean_checkout"],
        )
        self.assertEqual(
            "PASS_EXACT_GODOT_4_7_1_USER_LOCAL_COMMAND_TRANSCRIPT",
            contract["remaining_gates"]["godot_import_parse"],
        )
        self.assertEqual(
            "PARTIAL_PASS_GODOT_GUT_CORE_HERA_EXPORT_ANDROID_DEVICE_HUMAN_REMAIN",
            contract["remaining_gates"]["local_windows"],
        )

        local = contract["local_exact_471_gut_junit_acceptance"]
        self.assertEqual("USER_LOCAL_COMMAND_TRANSCRIPT", local["evidence_level"])
        self.assertEqual("4.7.1.stable.official.a13da4feb", local["actual_godot_version"])
        self.assertEqual("PASS", local["godot_import_parse"])
        self.assertEqual("PASS", local["gut_status"])
        self.assertEqual("PASS", local["gut_test_execution"])
        self.assertEqual("PASS", local["gut_junit"])
        self.assertTrue(local["canonical_gut_xml_exists"])
        self.assertTrue(local["evidence_gut_xml_exists"])
        self.assertTrue(local["post_run_content_clean"])
        self.assertFalse(local["post_run_porcelain_clean"])
        self.assertTrue(local["stat_only_status_possible"])

    def test_local_acceptance_evidence_is_bounded_and_keeps_hera_unverified(self) -> None:
        evidence = json.loads(LOCAL_ACCEPTANCE.read_text(encoding="utf-8"))
        self.assertEqual(COLLECTOR_DECISION_ID, evidence["decision_id"])
        self.assertIn(DECISION_ID, evidence["related_decision_ids"])
        self.assertEqual("1ecfb77eca6df0731c74f89ffe6d5dd16c6466d6", evidence["collector_main"])
        self.assertEqual("4.7.1.stable.official.a13da4feb", evidence["godot"]["version"])
        self.assertEqual("PASS", evidence["godot"]["import_parse"])
        self.assertEqual("9.7.1", evidence["gut"]["version"])
        self.assertEqual("PASS", evidence["gut"]["test_execution_status"])
        self.assertEqual("PASS", evidence["gut"]["junit_status"])
        self.assertTrue(evidence["gut"]["canonical_junit_exists"])
        self.assertTrue(evidence["gut"]["evidence_junit_exists"])
        self.assertTrue(evidence["final_git"]["working_tree_content_clean"])
        self.assertEqual("HERA_CLI_ADDON_PAIR_UNVERIFIED", evidence["hera"]["acceptance"])
        self.assertFalse(evidence["claim_ceiling"]["product_implementation_authorized_by_this_evidence"])

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

    def test_entry_gate_closes_exact_471_rerun_without_opening_product_gate(self) -> None:
        gate = json.loads(ENTRY_GATE.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, gate["decision_id"])
        self.assertTrue(gate["hera_plugin_currently_enabled"])
        self.assertEqual("HERA_CLI_ADDON_PAIR_UNVERIFIED", gate["hera_cli_pair"])
        self.assertEqual("NOT_RUN", gate["hera_status"])
        self.assertEqual("NOT_RUN", gate["hera_smoke_skip_game"])
        self.assertEqual(
            "PASS_EXACT_GODOT_4_7_1_GUT_9_7_1_JUNIT_USER_LOCAL_COMMAND_TRANSCRIPT",
            gate["local_gut_clean_checkout"],
        )
        self.assertEqual(
            "PASS_EXACT_GODOT_4_7_1_USER_LOCAL_COMMAND_TRANSCRIPT",
            gate["godot_import_parse"],
        )
        self.assertEqual(
            "PARTIAL_PASS_GODOT_GUT_CORE_HERA_EXPORT_ANDROID_DEVICE_HUMAN_REMAIN",
            gate["local_windows_checkout"],
        )
        self.assertNotIn(
            "RUN_HARDENED_COLLECTOR_ON_FRESH_CLEAN_CHECKOUT_WITH_EXACT_GODOT_4_7_1",
            gate["allowed_next_actions"],
        )
        self.assertIn(
            "VERIFY_LOCAL_HERA_WINDOWS_CLI_ARCHIVE_SHA256_AND_HERA_VERSION",
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
