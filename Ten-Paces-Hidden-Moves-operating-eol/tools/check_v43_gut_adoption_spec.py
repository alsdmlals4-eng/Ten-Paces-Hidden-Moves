#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
V43_DECISION_ID = "TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01"
GUT_DECISION_ID = "TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01"
EXPECTED_GUT_TAG_COMMIT = "aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605"
EXISTING_INSTALL_COMMIT = "6e471b62a6236749312f31264428a46b97c8387a"


class ContractError(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ContractError(message)


def load(relative: str) -> dict:
    path = ROOT / relative
    require(path.is_file(), f"V43_GUT_SPEC_BLOCKED_UNVERIFIED: missing {relative}")
    value = json.loads(path.read_text(encoding="utf-8"))
    require(isinstance(value, dict), f"V43_GUT_SPEC_BLOCKED_UNVERIFIED: invalid {relative}")
    return value


def main() -> None:
    binding = load("docs/planning-data/approved_20260806_integrated_work_contract_v4_3_binding.json")
    spec = load("docs/planning-data/approved_20260806_gut_9_7_1_adoption_spec.json")

    require(binding.get("decision_id") == V43_DECISION_ID, "V43_BINDING_CANON_CONFLICT: Decision ID")
    require(binding.get("contract_version") == "4.3", "V43_BINDING_CANON_CONFLICT: version")
    require(
        binding.get("review_model") == "GPT_ROLE_SEPARATED_PLUS_USER_DECISION_AUTHORITY",
        "V43_BINDING_CANON_CONFLICT: review model",
    )
    require(
        binding.get("external_independent_reviewer") == "NOT_PLANNED_SOLO_DEVELOPMENT",
        "V43_BINDING_CANON_CONFLICT: external reviewer state",
    )
    require(
        binding.get("merge_authority") == "CURRENT_CONVERSATION_RECOMMENDED_MERGES_AUTO_APPROVED",
        "V43_BINDING_CANON_CONFLICT: merge authority",
    )
    require(
        binding.get("project_repository") == "alsdmlals4-eng/Ten-Paces-Hidden-Moves",
        "V43_BINDING_CANON_CONFLICT: repository",
    )
    require(
        binding.get("project_local_path") == "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves",
        "V43_BINDING_CANON_CONFLICT: project path",
    )
    require(
        binding.get("godot_project_path") == "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves",
        "V43_BINDING_CANON_CONFLICT: Godot path",
    )
    require(binding.get("entry_state_reconciliation_required") is True, "V43_BINDING_CANON_CONFLICT: entry gate")
    require(binding.get("test_first_every_task") is True, "V43_BINDING_CANON_CONFLICT: test-first")

    require(spec.get("decision_id") == GUT_DECISION_ID, "GUT_ADOPTION_SPEC_CANON_CONFLICT: Decision ID")
    require(spec.get("version") == "9.7.1", "GUT_ADOPTION_SPEC_CANON_CONFLICT: version")
    require(spec.get("source_branch_or_release") == "v9.7.1", "GUT_ADOPTION_SPEC_CANON_CONFLICT: release tag")
    require(spec.get("source_ref") == "refs/tags/v9.7.1", "GUT_ADOPTION_SPEC_CANON_CONFLICT: source ref")
    require(spec.get("pinned_source_commit") == EXPECTED_GUT_TAG_COMMIT, "GUT_ADOPTION_SPEC_CANON_CONFLICT: pinned commit")
    require(spec.get("stage") == "ADOPTION_SPEC_DRAFT_PR", "GUT_ADOPTION_SPEC_CANON_CONFLICT: stage")
    require(
        spec.get("adoption_spec_branch") == "chore/gut-9.7.1-adoption-spec",
        "GUT_ADOPTION_SPEC_CANON_CONFLICT: branch",
    )
    require(
        spec.get("formal_installation") == "BLOCKED_UNTIL_SPEC_MERGED_AND_EXISTING_INSTALL_RECONCILED",
        "BLOCKED_BY_GUT_ADOPTION_SPEC_AND_RECONCILIATION",
    )
    require(spec.get("production_files_may_be_modified") is False, "GUT_ADOPTION_SPEC_SCOPE_VIOLATION")
    require(
        spec.get("higodot_authority") == "SINGLE_GODOT_SCENE_NODE_RESOURCE_PROJECT_SETTINGS_AUTHOR",
        "HIGODOT_GUT_ROLE_NON_OVERLAP_GATE: HiGodot authority",
    )
    require(spec.get("gut_authority") == "FORMAL_TEST_EXECUTION_AND_ASSERTION", "HIGODOT_GUT_ROLE_NON_OVERLAP_GATE: GUT authority")
    require(spec.get("gut_production_mutation") == "FORBIDDEN", "HIGODOT_GUT_ROLE_NON_OVERLAP_GATE: production mutation")
    require(spec.get("production_hash_before_after_required") is True, "GUT_ADOPTION_SPEC_CANON_CONFLICT: production hash")
    require(spec.get("higodot_authoring_manifest_required_for_godot_mutations") is True, "GUT_ADOPTION_SPEC_CANON_CONFLICT: authoring manifest")

    for key in (
        "source_provenance",
        "license_verification",
        "godot_compatibility",
        "existing_installation",
        "consumer_path",
        "ci_plan",
        "removal_and_rollback",
        "role_non_overlap",
        "claim_ceiling",
    ):
        require(isinstance(spec.get(key), dict), f"GUT_ADOPTION_SPEC_BLOCKED_UNVERIFIED: missing {key}")

    provenance = spec["source_provenance"]
    require(provenance.get("release_tag") == "v9.7.1", "GUT_ADOPTION_SPEC_CANON_CONFLICT: provenance tag")
    require(provenance.get("tag_commit") == EXPECTED_GUT_TAG_COMMIT, "GUT_ADOPTION_SPEC_CANON_CONFLICT: provenance commit")
    require(provenance.get("plugin_manifest_path") == "addons/gut/plugin.cfg", "GUT_ADOPTION_SPEC_CANON_CONFLICT: plugin manifest path")
    require(provenance.get("plugin_manifest_version") == "9.7.1", "GUT_ADOPTION_SPEC_CANON_CONFLICT: plugin manifest version")
    require(provenance.get("verification_state") == "VERIFIED_AT_ADOPTION_SPEC", "GUT_ADOPTION_SPEC_BLOCKED_UNVERIFIED: source provenance")

    license_info = spec["license_verification"]
    require(license_info.get("expected") == "MIT", "GUT_ADOPTION_SPEC_CANON_CONFLICT: license")
    require(license_info.get("path") == "addons/gut/LICENSE.md", "GUT_ADOPTION_SPEC_CANON_CONFLICT: license path")
    require(license_info.get("verified_at_ref") == "v9.7.1", "GUT_ADOPTION_SPEC_CANON_CONFLICT: license ref")
    require(
        license_info.get("state") == "VERIFIED_AT_ADOPTION_SPEC_RECHECK_AT_INSTALL",
        "GUT_ADOPTION_SPEC_BLOCKED_UNVERIFIED: license verification",
    )

    compatibility = spec["godot_compatibility"]
    require(compatibility.get("required") == "4.7.x", "GUT_ADOPTION_SPEC_CANON_CONFLICT: Godot compatibility")
    require(compatibility.get("upstream_branch_family") == "godot_4_7", "GUT_ADOPTION_SPEC_CANON_CONFLICT: compatibility branch family")

    existing = spec["existing_installation"]
    require(existing.get("detected_on_main") is True, "GUT_EXISTING_INSTALL_CONFLICT: main presence missing")
    require(existing.get("introduction_commit") == EXISTING_INSTALL_COMMIT, "GUT_EXISTING_INSTALL_CONFLICT: introduction commit")
    require(existing.get("state") == "PREEXISTING_OUT_OF_SEQUENCE_INSTALLATION", "GUT_EXISTING_INSTALL_CONFLICT: state")
    require(existing.get("modified_by_adoption_spec_pr") is False, "GUT_ADOPTION_SPEC_SCOPE_VIOLATION: existing addon modified")
    require(existing.get("authority") == "NOT_GRANTED_BY_FILE_PRESENCE", "GUT_EXISTING_INSTALL_OVERCLAIM: file presence")
    require(existing.get("tree_match_to_verified_tag") == "NOT_YET_VERIFIED", "GUT_EXISTING_INSTALL_OVERCLAIM: tree match")
    require(
        existing.get("required_remediation") == "POST_SPEC_MERGE_RECONCILIATION_AND_VALIDATION_PR",
        "GUT_EXISTING_INSTALL_CONFLICT: remediation",
    )

    require(spec["ci_plan"].get("existing_addon_tree_match_assertion") is True, "GUT_ADOPTION_SPEC_CANON_CONFLICT: tree match assertion")
    require(spec["ci_plan"].get("production_hash_unchanged_assertion") is True, "GUT_ADOPTION_SPEC_CANON_CONFLICT: CI hash assertion")
    require(
        spec["claim_ceiling"].get("formal_installation") == "EXISTING_FILES_PRESENT_AUTHORITY_NOT_GRANTED",
        "GUT_ADOPTION_SPEC_OVERCLAIM: installation authority",
    )
    require(spec["claim_ceiling"].get("android") == "NOT_RUN", "GUT_ADOPTION_SPEC_OVERCLAIM: Android")
    require(spec.get("visual_audio_disposition") == "NO_NEW_VISUAL_OR_AUDIO_ASSET_REQUIRED", "GUT_ADOPTION_SPEC_CANON_CONFLICT: visual/audio")

    v43_decision = (ROOT / "docs/decisions/2026-08-06_INTEGRATED_WORK_CONTRACT_V4_3_BINDING_DECISION.md").read_text(encoding="utf-8")
    gut_decision = (ROOT / "docs/decisions/2026-08-06_GUT_9_7_1_ADOPTION_SPEC_DECISION.md").read_text(encoding="utf-8")
    for marker in (V43_DECISION_ID, "GPT_ROLE_SEPARATED_PLUS_USER_DECISION_AUTHORITY", "CURRENT_CONVERSATION_RECOMMENDED_MERGES_AUTO_APPROVED"):
        require(marker in v43_decision, f"V43_BINDING_BLOCKED_UNVERIFIED: missing marker {marker}")
    for marker in (
        GUT_DECISION_ID,
        "GUT_ADOPTION_SPEC_DRAFT_PR_GATE",
        "BLOCKED_UNTIL_SPEC_MERGED_AND_EXISTING_INSTALL_RECONCILED",
        "PREEXISTING_OUT_OF_SEQUENCE_INSTALLATION",
        "HIGODOT_GUT_ROLE_NON_OVERLAP_GATE",
        EXPECTED_GUT_TAG_COMMIT,
        EXISTING_INSTALL_COMMIT,
    ):
        require(marker in gut_decision, f"GUT_ADOPTION_SPEC_BLOCKED_UNVERIFIED: missing marker {marker}")

    print("v4.3 binding and verified GUT 9.7.1 reconciliation spec: PASS")


if __name__ == "__main__":
    main()
