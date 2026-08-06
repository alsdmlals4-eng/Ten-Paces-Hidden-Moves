from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
V43_DECISION_ID = "TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01"
GUT_DECISION_ID = "TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01"
EXPECTED_GUT_TAG_COMMIT = "aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605"
EXISTING_INSTALL_COMMIT = "6e471b62a6236749312f31264428a46b97c8387a"
V43_DECISION = ROOT / "docs/decisions/2026-08-06_INTEGRATED_WORK_CONTRACT_V4_3_BINDING_DECISION.md"
V43_CONTRACT = ROOT / "docs/planning-data/approved_20260806_integrated_work_contract_v4_3_binding.json"
GUT_DECISION = ROOT / "docs/decisions/2026-08-06_GUT_9_7_1_ADOPTION_SPEC_DECISION.md"
GUT_SPEC = ROOT / "docs/planning-data/approved_20260806_gut_9_7_1_adoption_spec.json"
VALIDATOR = ROOT / "tools/check_v43_gut_adoption_spec.py"


class V43GutAdoptionSpecGateTests(unittest.TestCase):
    def load_json(self, path: Path) -> dict:
        return json.loads(path.read_text(encoding="utf-8"))

    def test_v43_is_bound_as_the_active_integrated_contract(self) -> None:
        payload = self.load_json(V43_CONTRACT)
        self.assertEqual(payload["decision_id"], V43_DECISION_ID)
        self.assertEqual(payload["contract_name"], "PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION")
        self.assertEqual(payload["contract_version"], "4.3")
        self.assertEqual(payload["status"], "ACTIVE_INTEGRATED_AUDIT_IMPLEMENTATION_DELIVERY_CONTRACT")
        self.assertEqual(payload["review_model"], "GPT_ROLE_SEPARATED_PLUS_USER_DECISION_AUTHORITY")
        self.assertEqual(payload["external_independent_reviewer"], "NOT_PLANNED_SOLO_DEVELOPMENT")
        self.assertEqual(payload["merge_authority"], "CURRENT_CONVERSATION_RECOMMENDED_MERGES_AUTO_APPROVED")

    def test_project_binding_uses_actual_ten_paces_paths_not_template_defaults(self) -> None:
        payload = self.load_json(V43_CONTRACT)
        self.assertEqual(payload["project_repository"], "alsdmlals4-eng/Ten-Paces-Hidden-Moves")
        self.assertEqual(payload["project_local_path"], "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves")
        self.assertEqual(payload["godot_project_path"], "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves")
        self.assertEqual(payload["project_google_sheet_id"], "1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0")

    def test_gut_spec_precedes_formal_authority_even_when_files_preexist(self) -> None:
        payload = self.load_json(GUT_SPEC)
        self.assertEqual(payload["decision_id"], GUT_DECISION_ID)
        self.assertEqual(payload["version"], "9.7.1")
        self.assertEqual(payload["source_branch_or_release"], "v9.7.1")
        self.assertEqual(payload["source_ref"], "refs/tags/v9.7.1")
        self.assertEqual(payload["adoption_spec_branch"], "chore/gut-9.7.1-adoption-spec")
        self.assertEqual(payload["stage"], "ADOPTION_SPEC_DRAFT_PR")
        self.assertEqual(
            payload["formal_installation"],
            "BLOCKED_UNTIL_SPEC_MERGED_AND_EXISTING_INSTALL_RECONCILED",
        )
        self.assertFalse(payload["production_files_may_be_modified"])

    def test_preexisting_out_of_sequence_install_is_explicitly_reconciled(self) -> None:
        payload = self.load_json(GUT_SPEC)
        existing = payload["existing_installation"]
        self.assertTrue(existing["detected_on_main"])
        self.assertEqual(existing["introduction_commit"], EXISTING_INSTALL_COMMIT)
        self.assertEqual(existing["state"], "PREEXISTING_OUT_OF_SEQUENCE_INSTALLATION")
        self.assertFalse(existing["modified_by_adoption_spec_pr"])
        self.assertEqual(existing["authority"], "NOT_GRANTED_BY_FILE_PRESENCE")
        self.assertEqual(
            existing["required_remediation"],
            "POST_SPEC_MERGE_RECONCILIATION_AND_VALIDATION_PR",
        )
        self.assertEqual(
            payload["claim_ceiling"]["formal_installation"],
            "EXISTING_FILES_PRESENT_AUTHORITY_NOT_GRANTED",
        )

    def test_gut_source_provenance_is_verified_against_the_release_tag(self) -> None:
        payload = self.load_json(GUT_SPEC)
        provenance = payload["source_provenance"]
        self.assertEqual(payload["pinned_source_commit"], EXPECTED_GUT_TAG_COMMIT)
        self.assertEqual(provenance["release_tag"], "v9.7.1")
        self.assertEqual(provenance["tag_commit"], EXPECTED_GUT_TAG_COMMIT)
        self.assertEqual(provenance["plugin_manifest_path"], "addons/gut/plugin.cfg")
        self.assertEqual(provenance["plugin_manifest_version"], "9.7.1")
        self.assertEqual(provenance["verification_state"], "VERIFIED_AT_ADOPTION_SPEC")
        license_info = payload["license_verification"]
        self.assertEqual(license_info["path"], "addons/gut/LICENSE.md")
        self.assertEqual(license_info["verified_at_ref"], "v9.7.1")
        self.assertEqual(license_info["state"], "VERIFIED_AT_ADOPTION_SPEC_RECHECK_AT_INSTALL")

    def test_higodot_and_gut_roles_do_not_overlap(self) -> None:
        payload = self.load_json(GUT_SPEC)
        self.assertEqual(
            payload["higodot_authority"],
            "SINGLE_GODOT_SCENE_NODE_RESOURCE_PROJECT_SETTINGS_AUTHOR",
        )
        self.assertEqual(payload["gut_authority"], "FORMAL_TEST_EXECUTION_AND_ASSERTION")
        self.assertEqual(payload["gut_production_mutation"], "FORBIDDEN")
        self.assertTrue(payload["production_hash_before_after_required"])
        self.assertTrue(payload["higodot_authoring_manifest_required_for_godot_mutations"])

    def test_spec_covers_source_license_compatibility_consumption_ci_and_removal(self) -> None:
        payload = self.load_json(GUT_SPEC)
        for key in (
            "source_provenance",
            "license_verification",
            "godot_compatibility",
            "existing_installation",
            "consumer_path",
            "ci_plan",
            "removal_and_rollback",
            "claim_ceiling",
        ):
            self.assertIn(key, payload)
        self.assertEqual(payload["license_verification"]["expected"], "MIT")
        self.assertEqual(payload["godot_compatibility"]["required"], "4.7.x")
        self.assertEqual(payload["godot_compatibility"]["upstream_branch_family"], "godot_4_7")
        self.assertEqual(payload["claim_ceiling"]["local_higodot"], "NOT_RUN")
        self.assertEqual(payload["claim_ceiling"]["android"], "NOT_RUN")

    def test_decisions_and_validator_contain_required_markers(self) -> None:
        v43_text = V43_DECISION.read_text(encoding="utf-8")
        gut_text = GUT_DECISION.read_text(encoding="utf-8")
        validator_text = VALIDATOR.read_text(encoding="utf-8")
        for marker in (
            V43_DECISION_ID,
            "GPT_ROLE_SEPARATED_PLUS_USER_DECISION_AUTHORITY",
            "CURRENT_CONVERSATION_RECOMMENDED_MERGES_AUTO_APPROVED",
        ):
            self.assertIn(marker, v43_text)
        for marker in (
            GUT_DECISION_ID,
            "GUT_ADOPTION_SPEC_DRAFT_PR_GATE",
            "BLOCKED_UNTIL_SPEC_MERGED_AND_EXISTING_INSTALL_RECONCILED",
            "PREEXISTING_OUT_OF_SEQUENCE_INSTALLATION",
            "HIGODOT_GUT_ROLE_NON_OVERLAP_GATE",
            EXPECTED_GUT_TAG_COMMIT,
            EXISTING_INSTALL_COMMIT,
        ):
            self.assertIn(marker, gut_text)
        self.assertIn(V43_DECISION_ID, validator_text)
        self.assertIn(GUT_DECISION_ID, validator_text)
        self.assertIn(EXPECTED_GUT_TAG_COMMIT, validator_text)
        self.assertIn(EXISTING_INSTALL_COMMIT, validator_text)


if __name__ == "__main__":
    unittest.main()
