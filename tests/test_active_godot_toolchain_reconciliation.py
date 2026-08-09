from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DECISION_ID = "TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01"
HERA_DECISION_ID = "TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01"
COLLECTOR_DECISION_ID = "TEN-DEC-20260809-LOCAL-GODOT-EVIDENCE-COLLECTOR-01"
DECISION = ROOT / "docs/decisions/2026-08-09_GODOT_AI313_GUT971_HERA100_ACTIVE_TOOLCHAIN.md"
HERA_DECISION = ROOT / "docs/decisions/2026-08-08_HERA_V1_LIVE_QA_RECONCILIATION_DECISION.md"
CONTRACT = ROOT / "docs/planning-data/active_godot_toolchain_20260809.json"
HERA_CONTRACT = ROOT / "docs/planning-data/approved_20260808_hera_v1_live_qa_reconciliation.json"
LOCAL_ACCEPTANCE = ROOT / "docs/planning-data/local_godot_471_gut_junit_acceptance_20260810.json"
HERA_ACCEPTANCE = ROOT / "docs/planning-data/local_hera_v1_live_qa_acceptance_20260810.json"
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
            "PASS_HERA_V1_0_0_EXACT_PAIR_LIVE_QA_SOURCE_DELTA_NONE",
            "PASS_USER_LOCAL_COMMAND_TRANSCRIPT",
            "local_gut_junit_471: PASS",
            "HERA_SOURCE_DELTA_NONE",
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
        self.assertEqual("PASS_EXACT_V1_0_0_USER_LOCAL_EVIDENCE", contract["remaining_gates"]["hera_cli_pair"])
        self.assertEqual("v1.0.0", contract["remaining_gates"]["exact_local_hera_cli_version"])
        self.assertEqual("PASS_EXACT_TARGET", contract["remaining_gates"]["hera_status"])
        self.assertEqual("PASS", contract["remaining_gates"]["hera_smoke_skip_game"])
        self.assertEqual("HERA_SOURCE_DELTA_NONE", contract["remaining_gates"]["hera_phase_source_delta"])
        self.assertEqual(
            "PASS_EXACT_GODOT_4_7_1_GUT_9_7_1_JUNIT_USER_LOCAL_COMMAND_TRANSCRIPT",
            contract["remaining_gates"]["local_gut_clean_checkout"],
        )
        self.assertEqual(
            "PASS_EXACT_GODOT_4_7_1_USER_LOCAL_COMMAND_TRANSCRIPT",
            contract["remaining_gates"]["godot_import_parse"],
        )
        self.assertEqual(
            "PARTIAL_PASS_GODOT_GUT_HERA_CORE_EXPORT_ANDROID_DEVICE_HUMAN_REMAIN",
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

        hera = contract["local_hera_v1_live_qa_acceptance"]
        self.assertEqual("USER_UPLOADED_RECOVERY_EVIDENCE_ZIP", hera["evidence_level"])
        self.assertEqual("v1.0.0", hera["cli_version"])
        self.assertEqual("1.0.0", hera["addon_version"])
        self.assertTrue(hera["localhost_only"])
        self.assertTrue(hera["token_auth_enforced"])
        self.assertEqual(0, hera["status_exit_code"])
        self.assertTrue(hera["status_exact_target"])
        self.assertEqual(0, hera["smoke_skip_game_exit_code"])
        self.assertTrue(hera["pre_content_clean"])
        self.assertTrue(hera["post_content_clean"])
        self.assertEqual("HERA_SOURCE_DELTA_NONE", hera["tracked_source_delta"])

    def test_local_acceptance_evidence_is_bounded_and_keeps_product_gate_closed(self) -> None:
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
        self.assertFalse(evidence["claim_ceiling"]["product_implementation_authorized_by_this_evidence"])

    def test_hera_original_decision_contract_and_evidence_are_promoted_together(self) -> None:
        decision = HERA_DECISION.read_text(encoding="utf-8")
        self.assertIn(HERA_DECISION_ID, decision)
        self.assertIn("LOCAL_LIVE_QA_ACCEPTED", decision)
        self.assertIn("PASS_HERA_V1_0_0_EXACT_PAIR_LIVE_QA_SOURCE_DELTA_NONE", decision)
        self.assertIn("HERA_SOURCE_DELTA_NONE", decision)

        contract = json.loads(HERA_CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(HERA_DECISION_ID, contract["decision_id"])
        state = contract["project_state"]
        self.assertTrue(state["enabled_in_project_godot"])
        self.assertEqual("v1.0.0", state["exact_local_cli_version"])
        self.assertEqual("PASS_EXACT_V1_0_0_USER_LOCAL_EVIDENCE", state["cli_addon_pair"])
        self.assertEqual("PASS_EXACT_TARGET", state["status_check"])
        self.assertEqual("PASS", state["smoke_skip_game"])
        self.assertEqual("PASS_ENFORCED_REDACTED", state["shared_token_configuration"])
        self.assertEqual("HERA_SOURCE_DELTA_NONE", state["source_delta_canary"])
        self.assertEqual("LOCAL_LIVE_QA_ACCEPTED", state["adoption_status"])

        evidence = json.loads(HERA_ACCEPTANCE.read_text(encoding="utf-8"))
        self.assertIn(HERA_DECISION_ID, evidence["decision_ids"])
        self.assertIn(DECISION_ID, evidence["decision_ids"])
        self.assertEqual("ce81eeba1af293061c17e4547fdd2364ec33f8c9", evidence["project"]["head"])
        self.assertEqual("v1.0.0", evidence["hera"]["cli_version"])
        self.assertEqual("1.0.0", evidence["hera"]["addon_version"])
        self.assertEqual(
            "9ae181741c2e8a3f57bbb2a2e4c61ac2c9c7c844fad21c88ae3890c55a5cc66b",
            evidence["hera"]["windows_archive_sha256"],
        )
        self.assertTrue(evidence["hera"]["localhost_only"])
        self.assertTrue(evidence["hera"]["token_auth_enforced"])
        self.assertEqual(0, evidence["hera"]["normal_status_exit"])
        self.assertTrue(evidence["hera"]["exact_target"])
        self.assertEqual(1, evidence["hera"]["wrong_token_exit"])
        self.assertEqual(0, evidence["hera"]["smoke_skip_game_exit"])
        self.assertEqual("HERA_SOURCE_DELTA_NONE", evidence["hera"]["tracked_source_delta"])
        self.assertEqual("PASS_HERA_V1_0_0_EXACT_PAIR_LIVE_QA_SOURCE_DELTA_NONE", evidence["verdict"])
        self.assertFalse(evidence["claim_ceiling"]["product_implementation_authorized_by_this_evidence"])

    def test_hera_record_is_live_qa_accepted_without_authoring_authority(self) -> None:
        record = json.loads(HERA_RECORD.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, record["decision_id"])
        self.assertTrue(record["enabled_in_project_godot"])
        self.assertEqual("LOCAL_LIVE_QA_ACCEPTED", record["adoption_status"])
        self.assertEqual("v1.0.0", record["exact_local_cli_version"])
        self.assertEqual("PASS_EXACT_V1_0_0_USER_LOCAL_EVIDENCE", record["cli_addon_pair"])
        self.assertEqual("PASS_EXACT_TARGET", record["status_check"])
        self.assertEqual("PASS", record["smoke_skip_game"])
        self.assertEqual("PASS_ENFORCED_REDACTED", record["shared_token_configuration"])
        self.assertEqual("HERA_SOURCE_DELTA_NONE", record["source_delta_canary"])
        self.assertEqual("FORBIDDEN", record["persistent_source_mutation"])
        self.assertEqual("LIVE_QA_AND_OBSERVABILITY_ONLY", record["role"])

    def test_entry_gate_closes_hera_without_opening_product_gate(self) -> None:
        gate = json.loads(ENTRY_GATE.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, gate["decision_id"])
        self.assertTrue(gate["hera_plugin_currently_enabled"])
        self.assertEqual("LOCAL_LIVE_QA_ACCEPTED", gate["hera_active_adoption"])
        self.assertEqual("PASS_EXACT_V1_0_0_USER_LOCAL_EVIDENCE", gate["hera_cli_pair"])
        self.assertEqual("PASS_EXACT_TARGET", gate["hera_status"])
        self.assertEqual("PASS", gate["hera_smoke_skip_game"])
        self.assertEqual("HERA_SOURCE_DELTA_NONE", gate["hera_phase_source_delta"])
        self.assertEqual(
            "PASS_EXACT_GODOT_4_7_1_GUT_9_7_1_JUNIT_USER_LOCAL_COMMAND_TRANSCRIPT",
            gate["local_gut_clean_checkout"],
        )
        self.assertEqual(
            "PASS_EXACT_GODOT_4_7_1_USER_LOCAL_COMMAND_TRANSCRIPT",
            gate["godot_import_parse"],
        )
        self.assertEqual(
            "PARTIAL_PASS_GODOT_GUT_HERA_CORE_EXPORT_ANDROID_DEVICE_HUMAN_REMAIN",
            gate["local_windows_checkout"],
        )
        self.assertNotIn(
            "VERIFY_LOCAL_HERA_WINDOWS_CLI_ARCHIVE_SHA256_AND_HERA_VERSION",
            gate["allowed_next_actions"],
        )
        self.assertNotIn(
            "RUN_HERA_STATUS_AND_SMOKE_SKIP_GAME_AND_REQUIRE_HERA_PHASE_DELTA_NONE",
            gate["allowed_next_actions"],
        )
        self.assertIn(
            "HIGODOT_L2_AUTHOR_APPROVED_GUT_TEST_PRODUCT_EXPORT_EXCLUSION",
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
