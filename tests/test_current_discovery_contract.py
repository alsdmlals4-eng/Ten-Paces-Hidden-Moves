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
CURRENT_WORK_CONTRACT = "TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01"
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
        self.assertIn("NOTION_DEFAULT_PROJECT_WORKSPACE", text)
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
        self.assertIn("NOTION_HUMAN_FACING_CANON", owner_section)
        self.assertIn("REPOSITORY_RUNTIME_TRUTH", owner_section)
        self.assertNotIn("최근 병합 체크포인트", owner_section)
        self.assertNotIn("PR #80", owner_section)

        self.assertIn("current_state_owner: ACTIVE_CONTEXT", current_section)
        self.assertIn("current_pr_authority: GITHUB_PR_METADATA", current_section)
        self.assertIn("current_notion_authority: EXACT_PROJECT_NOTION", current_section)
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
        self.assertIn("exact Project Notion", next_section)
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
            "current_truth_source: GITHUB_MAIN_PLUS_EXACT_PROJECT_NOTION_LIVE_READ",
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
        self.assertIn("future_product_mutation_authorized: false", current_section)
        self.assertIn("human_validation: NOT_RUN", current_section)
        self.assertIn("android_validation: NOT_RUN", current_section)
        self.assertIn("next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION", current_section)
        self.assertIn("next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", current_section)
        self.assertIn(
            "user_directed_planning_status: PHASE_1_CANONICAL_REVIEW_COMPLETE_UNIFIED_IMPLEMENTATION_CONTRACT_DRAFT_READY",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_latest_decision: TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_failure_retry: ONE_FREE_SAME_SEED_RETRY_PER_DUEL_THEN_END_RUN_USER_APPROVED_IMPLEMENTATION_REQUIRED",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_pending_material_decision: NONE_DECISIONS_RESOLVED_FINAL_USER_APPROVAL_OF_SINGLE_CONSOLIDATED_IMPLEMENTATION_CONTRACT",
            current_section,
        )
        self.assertIn(
            "user_directed_planning_unified_implementation_contract: TEN-IMP-20260828-PHASE2-COMBAT-CANON-RECONCILIATION-01",
            current_section,
        )
        self.assertIn("planning_execution_surface: GPT_WORK", current_section)
        self.assertIn("planning_work_handoff: docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md", current_section)
        self.assertIn("planning_visual_next: NONE_BOARD_R2_USER_FINAL_LOCKED_NO_AUTOMATIC_NEXT", current_section)
        self.assertIn(
            "planning_visual_generation: SCOPED_SINGLE_RESULT_FINAL_USER_LOCK_R2_COMPLETE",
            current_section,
        )
        self.assertIn(
            "planning_visual_review: PROJECT_CORE_SCENE_VISUAL_BOARD_R2_USER_FINAL_LOCKED_PLANNING_ONLY_DOGYEOM_RUNTIME_ASSETS_PRESERVED",
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
            "product_implementation_authorized: false",
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
        self.assertIn("future_product_mutation_authorized: false", current_risk)
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

    def test_current_user_planning_status_records_the_single_contract_draft_before_handoff(self) -> None:
        status_path = ROOT / "docs/planning-data/current_user_planning_status.json"
        status = json.loads(status_path.read_text(encoding="utf-8"))

        self.assertEqual(
            "PHASE_1_CANONICAL_REVIEW_COMPLETE_UNIFIED_IMPLEMENTATION_CONTRACT_DRAFT_READY",
            status["user_directed_planning_status"],
        )
        self.assertEqual(
            "PHASE_1_REMAINING_PLANNING_REVIEW_THEN_SINGLE_IMPLEMENTATION_CONTRACT",
            status["next_phase"],
        )
        self.assertFalse(status["product_implementation_authorized"])
        self.assertEqual(
            "TEN-IMP-20260828-PHASE2-COMBAT-CANON-RECONCILIATION-01",
            status["unified_implementation_contract_id"],
        )
        self.assertEqual(
            "DRAFT_FINAL_USER_APPROVAL_AND_CODEX_HANDOFF_REQUIRED",
            status["unified_implementation_contract_status"],
        )
        self.assertIn("CORE_RULE_AND_RUNTIME_DRIFT_REVIEW", status["current_work_order"])
        self.assertIn("GRILL_ME_ONE_MATERIAL_DECISION_AT_A_TIME", status["current_work_order"])
        self.assertIn("SINGLE_CONSOLIDATED_IMPLEMENTATION_CONTRACT_AFTER_USER_DECISIONS", status["current_work_order"])
        self.assertEqual(
            "TEN-DEC-20260828-OPENING-DISTANCE-RUNTIME-MAPPING-01",
            status["current_opening_distance_runtime_mapping_decision"],
        )
        self.assertEqual(2, status["canonical_public_opening_distance"])
        self.assertEqual(
            "USER_APPROVED_IMPLEMENTATION_BINDING_REQUIRED",
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
        self.assertEqual([], status["pending_material_decisions"])
        self.assertIn(
            "TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01",
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
