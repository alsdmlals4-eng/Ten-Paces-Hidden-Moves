#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
V43_DECISION_ID = "TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01"
GUT_DECISION_ID = "TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01"


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
    require(spec.get("source_branch_or_release") == "godot_4_7", "GUT_ADOPTION_SPEC_CANON_CONFLICT: source branch")
    require(spec.get("stage") == "ADOPTION_SPEC_DRAFT_PR", "GUT_ADOPTION_SPEC_CANON_CONFLICT: stage")
    require(
        spec.get("adoption_spec_branch") == "chore/gut-9.7.1-adoption-spec",
        "GUT_ADOPTION_SPEC_CANON_CONFLICT: branch",
    )
    require(
        spec.get("formal_installation") == "BLOCKED_UNTIL_SPEC_MERGED_TO_MAIN",
        "BLOCKED_BY_GUT_ADOPTION_SPEC",
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
        "consumer_path",
        "ci_plan",
        "removal_and_rollback",
        "role_non_overlap",
        "claim_ceiling",
    ):
        require(isinstance(spec.get(key), dict), f"GUT_ADOPTION_SPEC_BLOCKED_UNVERIFIED: missing {key}")

    require(spec["license_verification"].get("expected") == "MIT", "GUT_ADOPTION_SPEC_CANON_CONFLICT: license")
    require(spec["godot_compatibility"].get("required") == "4.7.x", "GUT_ADOPTION_SPEC_CANON_CONFLICT: Godot compatibility")
    require(spec["ci_plan"].get("production_hash_unchanged_assertion") is True, "GUT_ADOPTION_SPEC_CANON_CONFLICT: CI hash assertion")
    require(spec["claim_ceiling"].get("formal_installation") == "NOT_STARTED", "GUT_ADOPTION_SPEC_OVERCLAIM: installation")
    require(spec["claim_ceiling"].get("android") == "NOT_RUN", "GUT_ADOPTION_SPEC_OVERCLAIM: Android")
    require(spec.get("visual_audio_disposition") == "NO_NEW_VISUAL_OR_AUDIO_ASSET_REQUIRED", "GUT_ADOPTION_SPEC_CANON_CONFLICT: visual/audio")

    v43_decision = (ROOT / "docs/decisions/2026-08-06_INTEGRATED_WORK_CONTRACT_V4_3_BINDING_DECISION.md").read_text(encoding="utf-8")
    gut_decision = (ROOT / "docs/decisions/2026-08-06_GUT_9_7_1_ADOPTION_SPEC_DECISION.md").read_text(encoding="utf-8")
    for marker in (V43_DECISION_ID, "GPT_ROLE_SEPARATED_PLUS_USER_DECISION_AUTHORITY", "CURRENT_CONVERSATION_RECOMMENDED_MERGES_AUTO_APPROVED"):
        require(marker in v43_decision, f"V43_BINDING_BLOCKED_UNVERIFIED: missing marker {marker}")
    for marker in (GUT_DECISION_ID, "GUT_ADOPTION_SPEC_DRAFT_PR_GATE", "BLOCKED_UNTIL_SPEC_MERGED_TO_MAIN", "HIGODOT_GUT_ROLE_NON_OVERLAP_GATE"):
        require(marker in gut_decision, f"GUT_ADOPTION_SPEC_BLOCKED_UNVERIFIED: missing marker {marker}")

    print("v4.3 binding and GUT 9.7.1 adoption spec: PASS")


if __name__ == "__main__":
    main()
