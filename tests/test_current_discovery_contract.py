from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

from tests.test_issue54_human_device_validation_packet import Issue54HumanDeviceValidationPacketTests


ROOT = Path(__file__).resolve().parents[1]
FULL_SHA = re.compile(r"^[0-9a-f]{40}$")
USES = re.compile(r"^\s*(?:-\s*)?uses:\s*([^\s#]+)", re.MULTILINE)
CURRENT_ACTION_PINS = {
    "actions/checkout": "3d3c42e5aac5ba805825da76410c181273ba90b1",  # Base current / v7.0.1
    "actions/setup-python": "5fda3b95a4ea91299a34e894583c3862153e4b97",  # Base current / v7.0.0
    "actions/upload-artifact": "043fb46d1a93c77aae656e7c1c64a875d1fc6a0a",  # Base current / v7.0.1
    "chickensoft-games/setup-godot": "f166999204a4f2722c6fe042fbaa3b3ea0d9c789",  # upstream v2.4.1
}
TEMPORARY_PIN_EXCEPTIONS: dict[str, dict[str, str]] = {}
CURRENT_WORK_CONTRACT = "TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01"
CURRENT_VISUAL_PRODUCTION_DECISION = "TEN-DEC-20260827-WARM-DUSK-TEN-STEP-VISUAL-DIRECTION-01"


def is_reconciled_action_pin_allowed(workflow_path: str, action: str, ref: str) -> bool:
    del workflow_path
    expected = CURRENT_ACTION_PINS.get(action)
    if expected is None:
        return bool(FULL_SHA.fullmatch(ref))
    return ref == expected


class CurrentDiscoveryContractTests(unittest.TestCase):
    def test_root_start_here_uses_current_windows_android_platform_authority(self) -> None:
        text = (ROOT / "START_HERE.md").read_text(encoding="utf-8")

        self.assertIn("design_platforms: WINDOWS_ANDROID", text)
        self.assertIn("platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS", text)
        self.assertIn("현재 대상 플랫폼은 `Windows`와 `Android`다.", text)
        self.assertIn("REPOSITORY_HUMAN_FACING_CANON", text)
        self.assertIn("MIGRATION_ONLY_UNTIL_REMOVAL", text)
        self.assertIn(CURRENT_WORK_CONTRACT, text)

        stale_tokens = [
            "primary_platform: PC",
            "future_platform: MOBILE_CONSIDERATION_ONLY",
            "현재 주 플랫폼은 `PC`다.",
            "모바일은 `CONSIDERATION_ONLY`",
            "current_sheet_authority: GOOGLE_SHEET_00_02_04_99",
        ]
        for token in stale_tokens:
            self.assertNotIn(
                token,
                text,
                f"START_HERE.md still exposes stale authority: {token}",
            )

    def test_documentation_map_routes_current_state_without_mutable_snapshot(self) -> None:
        text = (
            ROOT / "[기획서]" / "00_프로젝트_허브" / "DOCUMENTATION_MAP.md"
        ).read_text(encoding="utf-8")
        owner_section = text.split("## 질문별 현재 책임 원본", 1)[1].split(
            "## 최신 활성 Decision", 1
        )[0]
        current_section = text.split("## 현재 상태", 1)[1].split(
            "## 구형·오해 표현 차단", 1
        )[0]
        next_section = text.split("## 현재 다음 작업", 1)[1]

        self.assertIn("현재 단계·권한·다음 작업", owner_section)
        self.assertIn("ACTIVE_CONTEXT.md", owner_section)
        self.assertIn(CURRENT_WORK_CONTRACT, owner_section)
        self.assertIn("전투 UI 정보 위계", owner_section)
        self.assertIn("2026-08-11_COMBAT_UI_INFORMATION_HIERARCHY_DECISION.md", owner_section)
        self.assertIn("REPOSITORY_HUMAN_FACING_CANON", owner_section)
        self.assertIn("REPOSITORY_RUNTIME_TRUTH", owner_section)
        self.assertNotIn("최근 병합 체크포인트", owner_section)
        self.assertNotIn("PR #80", owner_section)

        self.assertIn("current_state_owner: ACTIVE_CONTEXT", current_section)
        self.assertIn("current_pr_authority: GITHUB_PR_METADATA", current_section)
        self.assertIn("current_human_facing_authority: REPOSITORY_HUMAN_FACING_CANON", current_section)
        self.assertIn("current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME", current_section)
        self.assertIn("google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL", current_section)
        self.assertNotIn("current_sheet_authority", current_section)
        for mutable_key in (
            "product_stage:",
            "runtime_work_mode:",
            "planning_work_mode:",
            "runtime_implementation:",
            "latest_combat_planning_runtime:",
            "next_package:",
            "human_validation:",
        ):
            self.assertNotIn(mutable_key, current_section)

        self.assertNotIn("현재 핵심 권위에는 다음이 포함된다", text)
        self.assertIn("CANON_LIFECYCLE_REGISTRY.md", text)
        self.assertIn("current planning JSON", next_section)
        self.assertIn("repository human-facing/structured owners", next_section)
        self.assertNotIn("필요한 이미지·애니메이션·HX를 생성·검수", next_section)
        self.assertNotIn("VERTICAL_SLICE_APP_FLOW_SHELL` Codex 구현", next_section)

    def test_combat_rules_use_current_basic_attack_reprice_authority(self) -> None:
        text = (ROOT / "docs" / "02_COMBAT_RULES.md").read_text(encoding="utf-8")

        self.assertIn(
            "docs/decisions/2026-08-04_EXISTING_APPROVED_ACTIONS_REPRICE_DECISION.md",
            text,
        )
        self.assertIn("approved_20260804_existing_action_reprice_contract.json", text)
        self.assertIn(
            "| 강공 | 2 | 기력 1·내력 2 |",
            text,
            "Combat canon must expose the approved strong-attack effective cost.",
        )
        self.assertNotIn(
            "| 강공 | 2 | 기력 1·내력 1 |",
            text,
            "Combat canon still exposes the superseded pre-reprice strong-attack cost.",
        )
        self.assertIn(
            "속공25/24틱, 강공70/68틱, 장풍60/57틱",
            text,
            "Combat canon must expose the approved repriced basic-attack ledger.",
        )
        self.assertNotIn("속공21/20틱, 강공54/50틱, 장풍48/50틱", text)

        tag_registry = (ROOT / "docs" / "00_TAG_STATUS_REGISTRY.md").read_text(
            encoding="utf-8"
        )
        checklist = (ROOT / "docs" / "08_TEST_CHECKLIST.md").read_text(encoding="utf-8")
        self.assertIn("floor(3 + 내공 × 0.75)", tag_registry)
        self.assertNotIn("동일 조건의 속공보다 피해가 낮다", tag_registry)
        self.assertIn("동일 능력치에서 속공보다 반드시 낮아야 한다는 구형 제약은 없다", checklist)
        self.assertIn("강공 `floor(7 + 외공 × 1.00)`", checklist)

    def test_opening_distance_mapping_decision_has_one_public_distance_authority(self) -> None:
        decision_id = "TEN-DEC-20260828-OPENING-DISTANCE-RUNTIME-MAPPING-01"
        rule_text = (ROOT / "docs" / "02_COMBAT_RULES.md").read_text(encoding="utf-8")
        decision_text = (
            ROOT
            / "docs"
            / "decisions"
            / "2026-08-28_OPENING_DISTANCE_RUNTIME_MAPPING_DECISION.md"
        ).read_text(encoding="utf-8")
        lifecycle_text = (ROOT / "docs" / "CANON_LIFECYCLE_REGISTRY.md").read_text(
            encoding="utf-8"
        )

        self.assertIn(decision_id, rule_text)
        self.assertIn("공개 시작 거리는 `2`", decision_text)
        self.assertIn("두 번째 거리 규칙", decision_text)
        self.assertIn(decision_id, lifecycle_text)

    def test_combat_rules_use_current_bundle_transition_internal_recovery(self) -> None:
        text = (ROOT / "docs" / "02_COMBAT_RULES.md").read_text(encoding="utf-8")

        self.assertIn(
            "docs/decisions/2026-08-04_RESOURCE_SATURATION_INTERNAL_RECOVERY_DECISION.md",
            text,
        )
        self.assertIn("approved_20260804_resource_saturation_internal_recovery_contract.json", text)
        self.assertIn("생존한 양측 기력 +1·절초기세 +1(각 최대치 적용)", text)
        self.assertIn(
            "모든 묶음 전환은 생존한 양측에 기력 +1·절초기세 +1",
            text,
        )
        self.assertNotIn("생존한 양측 기력 +1·내력 +1·절초기세 +1", text)
        self.assertIn(
            "묶음 전환·라운드 시작에는 별도 내력 자동 회복이 없다.",
            text,
        )

    def test_active_context_separates_live_state_from_observed_snapshots(self) -> None:
        text = (
            ROOT / "[기획서]" / "00_프로젝트_허브" / "ACTIVE_CONTEXT.md"
        ).read_text(encoding="utf-8")
        current_section = text.split("## 현재 기준", 1)[1].split("## 관측 증거 스냅샷", 1)[0]

        self.assertIn(
            "current_truth_source: GITHUB_MAIN_PLUS_REPOSITORY_HUMAN_STRUCTURED_RUNTIME_OWNERS_LIVE_READ",
            current_section,
        )
        self.assertIn(f"current_work_contract: {CURRENT_WORK_CONTRACT}", current_section)
        self.assertIn("current_main_policy: ALWAYS_REFETCH_GITHUB_MAIN", current_section)
        self.assertIn("base_remote_main_policy: ALWAYS_REFETCH_CURRENT_MAIN", current_section)
        self.assertIn("active_project_pr: GITHUB_PR_METADATA_REFETCH_REQUIRED", current_section)
        self.assertNotIn("project_main_checkpoint:", current_section)
        self.assertNotIn("base_remote_main_observed:", current_section)

        self.assertIn("product_stage: FIRST_FIVE_DUEL_PHASE_I_VI_IMPLEMENTED", current_section)
        self.assertIn("phase_i_vi_implementation: AUTHORIZED_AND_MERGED", current_section)
        self.assertIn(
            "future_product_mutation_authorized: false_NEW_PRODUCT_MUTATION_REQUIRES_FRESH_APPROVED_CONTRACT",
            current_section,
        )
        self.assertIn("human_validation: NOT_RUN", current_section)
        self.assertIn("android_validation: NOT_RUN", current_section)
        self.assertIn("next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION", current_section)
        self.assertIn("next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", current_section)
        self.assertIn(
            "user_directed_planning_next_package: BALANCE_MEASUREMENT_REPRESENTATIVE_POLICY_COVERAGE_RESULT_REVIEW_SEPARATE_NUMERICAL_DECISION_IF_EVIDENCE_REQUIRES_CHANGE",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_next_decision: TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_status: INK_PAPER_DIAGONAL_DUEL_PRESENTATION_IMPLEMENTED_MERGED_MAIN_PR277_PROTECTED_APPROVAL_ARCHIVED_PR278_MACHINE_RUNTIME_VERIFIED_HUMAN_PLAYTEST_DEFERRED_PLUS_BALANCE_INSTRUMENTATION_IMPLEMENTED_MERGED_MAIN_PR280_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR281_POSTMERGE_READBACK_PLUS_BALANCE_MEASUREMENT_POLICY_COVERAGE_EXTENSION_IMPLEMENTED_MERGED_MAIN_PR289_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR290_POSTMERGE_READBACK_PLUS_BALANCE_MEASUREMENT_REPRESENTATIVE_POLICY_COVERAGE_IMPLEMENTED_MERGED_MAIN_PR292_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR293_POSTMERGE_READBACK",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_diagonal_duel_presentation_status: USER_FINAL_LOCKED_IMPLEMENTED_MERGED_MAIN_PR277_MACHINE_RUNTIME_AND_REMOTE_CI_VERIFIED",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_diagonal_duel_approval_archive: docs/operations/2026-08-30_PR277_PROTECTED_CHANGE_APPROVAL_RECORD.md",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_latest_decision: TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_failure_retry: ONE_FREE_SAME_SEED_RETRY_PER_DUEL_THEN_END_RUN_IMPLEMENTED_MERGED_MAIN_PR_261",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_pending_material_decision: NONE_REPRESENTATIVE_POLICY_COVERAGE_IS_VALIDATION_ONLY_NUMERICAL_DECISION_STILL_REQUIRES_SEPARATE_EVIDENCE",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_balance_instrumentation_decision: docs/decisions/2026-08-30_BALANCE_INSTRUMENTATION_CONTRACT_DECISION.md",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_balance_instrumentation_design_spec: docs/superpowers/specs/2026-08-30-balance-instrumentation-design.md",
            current_section,
        )
        self.assertIn("user_directed_planning_opponent_runtime_personality_issue: 267", current_section)
        self.assertIn(
            "user_directed_planning_opponent_runtime_personality_design_spec: docs/superpowers/specs/2026-08-29-opponent-runtime-personality-binding-design.md",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_opponent_runtime_personality_implementation_contract: docs/implementation/2026-08-29_OPPONENT_RUNTIME_PERSONALITY_BINDING_IMPLEMENTATION_CONTRACT.md",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_opponent_runtime_personality_implementation_plan: docs/superpowers/plans/2026-08-29-opponent-runtime-personality-binding.md",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_opponent_runtime_personality_handoff: docs/handoffs/2026-08-29_OPPONENT_RUNTIME_PERSONALITY_CODEX_GODOT_IMPLEMENTATION_HANDOFF.md",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_opponent_runtime_personality_status: IMPLEMENTED_MERGED_MAIN_PR273_POSTMERGE_READBACK",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_unified_implementation_contract: TEN-IMP-20260828-PHASE2-COMBAT-CANON-RECONCILIATION-01",
            current_section,
        )
        self.assertIn(
            "planning_execution_surface: REPOSITORY_ONLY_GPT_WORK",
            current_section,
        )
        self.assertIn("planning_work_handoff: docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md", current_section)
        self.assertIn("planning_visual_next: NONE_BOARD_R2_USER_FINAL_LOCKED_NO_AUTOMATIC_NEXT", current_section)
        self.assertIn(
            "planning_visual_generation: SCOPED_SINGLE_RESULT_FINAL_USER_LOCK_R2_COMPLETE",
            current_section,
        )
        self.assertIn(
            "planning_visual_review: PROJECT_CORE_SCENE_VISUAL_BOARD_R2_USER_FINAL_LOCKED_PLANNING_ONLY_PLUS_DIAGONAL_DUEL_PAIR_5X2_BASIC_ATLAS_AND_PER_TIMING_VS_REVEAL_IMPLEMENTED_PR277",
            current_section,
        )
        self.assertIn(
            f"planning_visual_production_decision: {CURRENT_VISUAL_PRODUCTION_DECISION}",
            current_section,
        )
        self.assertIn(
            "planning_visual_state: docs/planning-data/current_visual_production_handoff_20260826.json",
            current_section,
        )
        self.assertIn(
            "planning_visual_authority: TEN-DEC-20260820-VISUAL-UX-SYSTEM-01",
            current_section,
        )
        self.assertIn(
            "planning_visual_planning_anchor_decision: TEN-DEC-20260828-WARM-DUSK-V2-PLANNING-ANCHOR-01",
            current_section,
        )
        self.assertIn(
            "planning_visual_cadence_decision: TEN-DEC-20260828-CORE-SCENE-VISUAL-BOARD-FINAL-LOCK-CADENCE-01",
            current_section,
        )
        self.assertIn(
            "planning_visual_overlay: TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01",
            current_section,
        )
        self.assertIn("ci_supply_chain_followup: RESOLVED_ISSUE_140", current_section)

        for stale_live_token in (
            "user_directed_planning_next_package: AWAITING_EXPLICIT_ASSET_OR_IMPLEMENTATION_REQUEST",
            "user_directed_planning_status: PLANNING_COMPLETE_USER_APPROVED",
            "planning_visual_next: AWAITING_EXPLICIT_ASSET_OR_IMPLEMENTATION_REQUEST",
            "planning_visual_next: OPPONENT_CHARACTER_MASTER_01",
            "planning_visual_next: DOGYEOM_COMBAT_BATTLER_01",
            "planning_visual_review: TEN_IMG_001_CHAT_EXPLORATIONS_REVIEWED_NOT_AN_ASSET",
            "planning_visual_review: USER_APPROVED_REFERENCE_SET_20260825_NOT_RUNTIME_VISUAL_PASS",
            "planning_visual_review: USER_APPROVED_REFERENCE_SET_20260825_AND_OPPONENT_CHARACTER_MASTER_01_20260826_NOT_RUNTIME_VISUAL_PASS",
            "future_product_mutation_authorized: true_FOR_ISSUE_258_ONLY",
            "product_stage: VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_COMPLETE_HANDOFF_READY",
            "planning_visual_next: TEN_IMG_001_GENERATE_EXPLORATION",
            "planning_visual_review: TEN_IMG_001_EXPLORATION_REVIEW",
            "ci_supply_chain_followup: ISSUE_140",
        ):
            self.assertNotIn(stale_live_token, current_section)

        self.assertIn("## 관측 증거 스냅샷", text)
        self.assertIn(
            "historical_project_main_at_handoff: 43841d3cc6667d821c10df75272b239f314f3df0",
            text,
        )
        self.assertIn(
            "historical_base_main_at_handoff: 637dad32c773c56a27d44d847518580848dee493",
            text,
        )
        self.assertIn(
            "historical_pre_phase_i_vi_product_stage: VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_COMPLETE_HANDOFF_READY",
            text,
        )
        self.assertIn("historical_pre_phase_i_vi_product_implementation_authorized: false", text)

        self.assertNotIn("## 현재 Entry Gate", text)
        self.assertIn("## 역사 Entry Gate · 2026-08-08", text)
        self.assertIn("current_vertical_slice_implementation_gate_20260820.json", text)
        historical_entry = text.split("## 역사 Entry Gate · 2026-08-08", 1)[1].split(
            "## 역사 플랫폼 preflight 중단 상태 · 2026-08-10", 1
        )[0]
        self.assertIn("SUPERSEDED_FOR_PHASE_I_VI_IMPLEMENTATION", historical_entry)
        self.assertIn("product_implementation_authorized: false", historical_entry)

        current_risk = text.split("## 현재 위험·미검증", 1)[1].split(
            "## 상태 표현 규칙", 1
        )[0]
        self.assertIn("Phase I–VI", current_risk)
        self.assertIn("OPPONENT_CHARACTER_MASTER_01", current_risk)
        self.assertIn("DOGYEOM_COMBAT_BATTLER_01", current_risk)
        self.assertIn("DOGYEOM_STATUS_PORTRAIT_01", current_risk)
        self.assertIn("USER_APPROVED_2026_08_26", current_risk)
        self.assertIn("AUTOMATED_GODOT_PASS_20260826", current_risk)
        self.assertIn("runtime art integration", current_risk)
        self.assertIn("Issue #267", current_risk)
        self.assertIn("PR #273", current_risk)
        self.assertIn("PR #274", current_risk)
        self.assertIn("remote CI readback", current_risk)
        self.assertNotIn("PR CI/review/merge/readback을 기다린다", current_risk)
        self.assertNotIn("product_implementation_authorized: false", current_risk)
        self.assertIn("Issue #140", text)

        local_history = text.split(
            "## 역사 LOCAL_EXECUTOR_HANDOFF_CHECKPOINT — 2026-08-12 · CURRENT EXECUTION SUPERSEDED",
            1,
        )[1]
        self.assertIn("IN_CODEX_FRESH_READINESS: NOT_RUN", local_history)
        self.assertIn("FRESH_POWERSHELL_REPEAT_RUN: NOT_RUN", local_history)
        self.assertIn("CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF", local_history)
        self.assertIn("current readiness 선행조건이 아니다", local_history)

    def test_pc_first_vertical_slice_gate_is_discoverable(self) -> None:
        gate_path = ROOT / "docs/planning-data/current_vertical_slice_implementation_gate_20260820.json"
        gate = json.loads(gate_path.read_text(encoding="utf-8"))
        self.assertEqual("AUTHORIZED", gate["pc_first_vertical_slice_implementation"])
        self.assertEqual("BLOCKED_UNVERIFIED", gate["android_physical_device"])
        self.assertEqual("NOT_RUN", gate["human_validation"])
        self.assertFalse(gate["image_generation_authorized"])

    def test_current_user_planning_status_records_deferred_human_gate_and_runtime_gap(self) -> None:
        status_path = ROOT / "docs/planning-data/current_user_planning_status.json"
        status = json.loads(status_path.read_text(encoding="utf-8"))

        self.assertEqual(
            "INK_PAPER_DIAGONAL_DUEL_PRESENTATION_IMPLEMENTED_MERGED_MAIN_PR277_PROTECTED_APPROVAL_ARCHIVED_PR278_MACHINE_RUNTIME_VERIFIED_HUMAN_PLAYTEST_DEFERRED_PLUS_BALANCE_INSTRUMENTATION_IMPLEMENTED_MERGED_MAIN_PR280_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR281_POSTMERGE_READBACK_PLUS_BALANCE_MEASUREMENT_POLICY_COVERAGE_EXTENSION_IMPLEMENTED_MERGED_MAIN_PR289_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR290_POSTMERGE_READBACK_PLUS_BALANCE_MEASUREMENT_REPRESENTATIVE_POLICY_COVERAGE_IMPLEMENTED_MERGED_MAIN_PR292_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR293_POSTMERGE_READBACK",
            status["user_directed_planning_status"],
        )
        self.assertIn(
            "COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01",
            status["completed_scope"],
        )
        self.assertIn(
            "TEN_BASIC_TECHNIQUE_INK_ATLAS_01",
            status["completed_scope"],
        )
        self.assertEqual(
            "IMPLEMENTED_MERGED_MAIN_PR277_AUTOMATED_GODOT_VISIBLE_RUNTIME_AND_REMOTE_CI_VERIFIED_HUMAN_READABILITY_NOT_RUN",
            status["evidence_ceiling"]["ink_paper_diagonal_duel_presentation"],
        )
        self.assertEqual(
            "ACTIVE_MANIFEST_ARCHIVED_PR278_BASELINE_PROMOTED_MAIN_READBACK_PASS",
            status["evidence_ceiling"]["pr277_protected_approval_lifecycle"],
        )
        self.assertEqual(
            "BALANCE_MEASUREMENT_REPRESENTATIVE_POLICY_COVERAGE_RESULT_REVIEW_SEPARATE_NUMERICAL_DECISION_IF_EVIDENCE_REQUIRES_CHANGE",
            status["next_phase"],
        )
        self.assertEqual(
            "BALANCE_MEASUREMENT_REPRESENTATIVE_POLICY_COVERAGE_RESULT_REVIEW_SEPARATE_NUMERICAL_DECISION_IF_EVIDENCE_REQUIRES_CHANGE",
            status["next_product_execution_surface"],
        )
        self.assertEqual(
            "TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01",
            status["balance_instrumentation_decision"],
        )
        self.assertEqual(
            "docs/superpowers/specs/2026-08-30-balance-instrumentation-design.md",
            status["balance_instrumentation_design_spec"],
        )
        self.assertEqual(
            "IMPLEMENTED_MERGED_MAIN_PR280_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR281_POSTMERGE_READBACK",
            status["balance_instrumentation_status"],
        )
        self.assertEqual(
            "TEN-DEC-20260830-BALANCE-MEASUREMENT-POLICY-COVERAGE-EXTENSION-01",
            status["balance_measurement_policy_coverage_extension_decision"],
        )
        self.assertEqual(
            "IMPLEMENTED_MERGED_MAIN_PR289_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR290_POSTMERGE_READBACK_4500_SCENARIOS_TWO_BYTE_IDENTICAL_REPORTS",
            status["balance_measurement_policy_coverage_extension_status"],
        )
        self.assertEqual(
            "docs/operations/2026-08-30_BALANCE_MEASUREMENT_POLICY_COVERAGE_EXTENSION_IMPLEMENTATION_EXECUTION_REPORT.md",
            status["balance_measurement_policy_coverage_extension_execution_report"],
        )
        self.assertEqual(
            "docs/operations/2026-08-30_PR289_PROTECTED_CHANGE_APPROVAL_RECORD.md",
            status["balance_measurement_policy_coverage_extension_approval_archive"],
        )
        self.assertEqual(
            "docs/operations/2026-08-30_PR290_BALANCE_MEASUREMENT_POLICY_COVERAGE_POSTMERGE_READBACK.md",
            status["balance_measurement_policy_coverage_extension_postmerge_readback"],
        )
        self.assertTrue(status["product_implementation_authorized"])
        self.assertEqual(
            "TEN-IMP-20260828-PHASE2-COMBAT-CANON-RECONCILIATION-01",
            status["unified_implementation_contract_id"],
        )
        self.assertEqual(
            "IMPLEMENTED_MERGED_MAIN_PR_261",
            status["unified_implementation_contract_status"],
        )
        self.assertEqual(258, status["unified_implementation_contract_issue"])
        self.assertEqual(
            "CLOSED_POSTMERGE_READBACK_20260829",
            status["unified_implementation_issue_status"],
        )
        self.assertEqual(
            "ISSUE267_CODEX_GODOT_PRODUCT_IMPLEMENTATION_MERGED_MAIN_PR273_POSTMERGE_READBACK_HUMAN_EVIDENCE_DEFERRED_BY_USER_FOR_CURRENT_STAGE",
            status["implementation_handoff_status"],
        )
        self.assertIn("PHASE_2_MERGED_MAIN_PR_261", status["current_work_order"])
        self.assertEqual(
            "TEN-DEC-20260828-OPENING-DISTANCE-RUNTIME-MAPPING-01",
            status["current_opening_distance_runtime_mapping_decision"],
        )
        self.assertEqual(2, status["canonical_public_opening_distance"])
        self.assertEqual(
            "IMPLEMENTED_MERGED_MAIN_PR_261",
            status["opening_distance_runtime_mapping_status"],
        )
        self.assertEqual(
            "TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01",
            status["current_first_five_defeat_retry_scope_decision"],
        )
        self.assertEqual(
            "ONE_FREE_SAME_SEED_RETRY_PER_DUEL_THEN_END_RUN",
            status["first_five_defeat_retry_scope"],
        )
        self.assertEqual(
            [],
            status["pending_material_decisions"],
        )
        self.assertEqual(
            "TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01",
            status["opponent_runtime_personality_binding_decision"],
        )
        self.assertEqual(267, status["opponent_runtime_personality_binding_issue"])
        self.assertEqual(
            "docs/superpowers/specs/2026-08-29-opponent-runtime-personality-binding-design.md",
            status["opponent_runtime_personality_binding_design_spec"],
        )
        self.assertEqual(
            "docs/implementation/2026-08-29_OPPONENT_RUNTIME_PERSONALITY_BINDING_IMPLEMENTATION_CONTRACT.md",
            status["opponent_runtime_personality_binding_implementation_contract"],
        )
        self.assertEqual(
            "docs/superpowers/plans/2026-08-29-opponent-runtime-personality-binding.md",
            status["opponent_runtime_personality_binding_implementation_plan"],
        )
        self.assertEqual(
            "docs/handoffs/2026-08-29_OPPONENT_RUNTIME_PERSONALITY_CODEX_GODOT_IMPLEMENTATION_HANDOFF.md",
            status["opponent_runtime_personality_binding_handoff"],
        )
        self.assertEqual(
            "IMPLEMENTED_MERGED_MAIN_PR273_POSTMERGE_READBACK",
            status["opponent_runtime_personality_binding_status"],
        )
        self.assertEqual(
            "SCHEMA_3_REPRESENTATIVE_POLICY_COVERAGE_IMPLEMENTED_MERGED_MAIN_PR292_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR293_POSTMERGE_READBACK_HEADLESS_FULL_MATRIX_6750_ROWS_TWO_BYTE_IDENTICAL_REPORTS_WINDOWS_HUMAN_ANDROID_ACCESSIBILITY_RELEASE_NOT_RUN",
            status["evidence_ceiling"]["balance_simulation"],
        )
        self.assertEqual(
            "NOT_RUN_DEFERRED_BY_USER_FOR_CURRENT_STAGE",
            status["evidence_ceiling"]["human_fun_readability"],
        )
        self.assertEqual(
            "IMPLEMENTED_MERGED_MAIN_PR273_AUTOMATED_GODOT_REMOTE_CI_VERIFIED_15_TO_5_PROFILE_BINDING_DERIVED_STATS_PUBLIC_HISTORY_AND_PLANNER_ISOLATION_HUMAN_EVIDENCE_PENDING",
            status["evidence_ceiling"]["opponent_behavior_runtime_binding"],
        )
        self.assertIn(
            "TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01",
            status["resolved_material_decisions"],
        )
        self.assertIn(
            "TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01",
            status["resolved_material_decisions"],
        )
        self.assertIn(
            "TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01",
            status["resolved_material_decisions"],
        )
        self.assertIn(
            "TEN-DEC-20260830-BALANCE-MEASUREMENT-POLICY-COVERAGE-EXTENSION-01",
            status["resolved_material_decisions"],
        )
        self.assertEqual(
            "TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01",
            status["balance_measurement_representative_policy_coverage_decision"],
        )
        self.assertEqual(
            "IMPLEMENTED_MERGED_MAIN_PR292_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR293_POSTMERGE_READBACK_6750_SCENARIOS_TWO_BYTE_IDENTICAL_REPORTS_SCHEMA_3",
            status["balance_measurement_representative_policy_coverage_status"],
        )
        self.assertEqual(
            "A0669A0727C9608B6A240910CE529263C1982C510E4B3C376BD58D8AB5F66558",
            status["balance_measurement_representative_policy_coverage_report_sha256"],
        )
        self.assertEqual(
            "docs/operations/2026-08-30_PR292_PROTECTED_CHANGE_APPROVAL_RECORD.md",
            status["balance_measurement_representative_policy_coverage_approval_archive"],
        )
        self.assertEqual(
            "docs/operations/2026-08-30_PR293_REPRESENTATIVE_POLICY_COVERAGE_POSTMERGE_READBACK.md",
            status["balance_measurement_representative_policy_coverage_postmerge_readback"],
        )
        self.assertIn(
            "TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01",
            status["resolved_material_decisions"],
        )

    def test_first_five_defeat_retry_decision_keeps_paid_retry_out_of_scope(self) -> None:
        decision_id = "TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01"
        decision_text = (
            ROOT
            / "docs"
            / "decisions"
            / "2026-08-28_FIRST_FIVE_DEFEAT_RETRY_SCOPE_DECISION.md"
        ).read_text(encoding="utf-8")
        run_state_contract = json.loads(
            (ROOT / "docs" / "planning-data" / "poc_run_state_contract.json").read_text(
                encoding="utf-8"
            )
        )
        ui_text = (ROOT / "docs" / "07_COMBAT_UI_SPEC.md").read_text(encoding="utf-8")
        lifecycle_text = (ROOT / "docs" / "CANON_LIFECYCLE_REGISTRY.md").read_text(
            encoding="utf-8"
        )

        self.assertIn("1회 무료 동일-seed 재도전", decision_text)
        self.assertIn("영구재화", decision_text)
        self.assertIn(decision_id, lifecycle_text)
        self.assertIn("1회 무료 동일-seed 재도전", ui_text)
        self.assertEqual(
            "ONE_FREE_SAME_SEED_RETRY_PER_DUEL_THEN_END_RUN",
            run_state_contract["first_five_slice_defeat_retry"]["policy"],
        )
        self.assertEqual(
            "OUT_OF_SCOPE_FOR_FIRST_FIVE_SLICE",
            run_state_contract["defeat_retry"]["first_five_slice_status"],
        )

    def test_no_temporary_pin_exceptions_remain_after_live_editor_migration(self) -> None:
        self.assertFalse(
            TEMPORARY_PIN_EXCEPTIONS,
            "All active workflows now use reconciled current pins; temporary exceptions must be removed.",
        )

    def test_active_workflows_use_immutable_reconciled_action_pins(self) -> None:
        violations: list[str] = []
        seen_actions: set[str] = set()
        workflows = ROOT / ".github" / "workflows"

        for workflow in sorted(workflows.glob("*.y*ml")):
            workflow_path = workflow.relative_to(ROOT).as_posix()
            text = workflow.read_text(encoding="utf-8")
            for target in USES.findall(text):
                if target.startswith("./"):
                    continue
                if target.startswith("docker://"):
                    violations.append(
                        f"{workflow_path}: docker use requires explicit digest governance: {target}"
                    )
                    continue
                if "@" not in target:
                    violations.append(f"{workflow_path}: remote use has no ref: {target}")
                    continue

                action, ref = target.rsplit("@", 1)
                if action in CURRENT_ACTION_PINS:
                    seen_actions.add(action)

                if not FULL_SHA.fullmatch(ref):
                    violations.append(f"{workflow_path}: mutable remote ref {target}")
                    continue

                if not is_reconciled_action_pin_allowed(workflow_path, action, ref):
                    expected = CURRENT_ACTION_PINS.get(action, "full immutable SHA")
                    violations.append(
                        f"{workflow_path}: {action} pin {ref} != reconciled current {expected}"
                    )

        self.assertEqual(set(CURRENT_ACTION_PINS), seen_actions)
        self.assertFalse(
            violations,
            "Mutable/stale remote action refs found:\n" + "\n".join(violations),
        )


if __name__ == "__main__":
    unittest.main()
