from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ACTIVE = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
ROADMAP = ROOT / "docs/04_ROADMAP.md"
README = ROOT / "README.md"
START_HERE = ROOT / "START_HERE.md"
CURRENT_STATE = ROOT / "docs/planning-data/current_operating_state.json"
PLATFORM = ROOT / "docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md"
PRODUCT_MERGE = "a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90"
EVIDENCE_HEAD = "0a8bf577b936ddac5cb7130a0cc58e519ea6eff6"
PLATFORM_DECISION = "TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01"
ADAPTER_DECISION = "TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01"
CURRENT_WORK_CONTRACT = "TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01"
MUTABLE_KEYS = (
    "active_planning_work_mode",
    "active_planning_pr",
    "active_planning_parent_pr",
    "active_approval_count",
    "active_decision_state",
    "next_package",
    "next_planning_decision",
)


class ProductPostMergeAndPlatformCanonTests(unittest.TestCase):
    def test_active_context_preserves_product_merge_under_later_planning(self) -> None:
        text = ACTIVE.read_text(encoding="utf-8")
        product_authority = (
            f"product_implementation_merge_commit: {PRODUCT_MERGE}",
            "merged_product_pr: 92",
            "runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92",
            "product_gate: PARTIAL_AUTOMATED_COMPLETE",
            f"evidence_source_head: {EVIDENCE_HEAD}",
        )
        for token in product_authority:
            self.assertIn(token, text)

        current = json.loads(CURRENT_STATE.read_text(encoding="utf-8"))
        for key in MUTABLE_KEYS:
            self.assertIn(f"{key}: {current[key]}", text)
        self.assertIn(f"platform_adapter_decision: {ADAPTER_DECISION}", text)

        forbidden = (
            "DRAFT_PR92_TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_10_OF_10",
            "PR #92는 PR #91 위에 쌓인 Draft",
        )
        for token in forbidden:
            self.assertNotIn(token, text)

    def test_roadmap_preserves_final_product_evidence_without_mutable_checkpoint(self) -> None:
        text = ROADMAP.read_text(encoding="utf-8")
        required = (
            f"product_implementation_merge_commit: {PRODUCT_MERGE}",
            "merged_product_pr: 92",
            f"증거: `{EVIDENCE_HEAD}` / workflow `31074079068` / artifact `8956790279`",
            "current_state_owner: ACTIVE_CONTEXT_PLUS_CURRENT_JSON",
            "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE",
            "MIGRATION_ONLY_UNTIL_REMOVAL",
        )
        for token in required:
            self.assertIn(token, text)
        for key in MUTABLE_KEYS:
            self.assertIsNone(
                re.search(rf"(?m)^{re.escape(key)}:\s*", text),
                f"roadmap duplicates mutable operating state: {key}",
            )
        for stale in (
            "7494f50c48573168542781e007eeab6af11dda7d",
            "31068098197",
            "8954602789",
        ):
            self.assertNotIn(stale, text)

    def test_windows_android_dual_target_is_current_platform_authority(self) -> None:
        decision = PLATFORM.read_text(encoding="utf-8")
        active = ACTIVE.read_text(encoding="utf-8")
        roadmap = ROADMAP.read_text(encoding="utf-8")
        readme = README.read_text(encoding="utf-8")
        required_decision = (
            PLATFORM_DECISION,
            "status: APPROVED_PLANNING",
            "design_targets: [WINDOWS, ANDROID]",
            "logic_and_data_core: SINGLE_SHARED_CORE",
            "separated_adapters: [INPUT, RESPONSIVE_UI, APP_LIFECYCLE, PLATFORM_SERVICES, QUALITY_EXPORT]",
            "android_runtime_evidence: NOT_RUN",
            "same_day_release_required: false",
        )
        for token in required_decision:
            self.assertIn(token, decision)

        for token in (
            f"platform_decision: {PLATFORM_DECISION}",
            f"platform_adapter_decision: {ADAPTER_DECISION}",
            "design_platforms: WINDOWS_ANDROID",
            "platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS",
        ):
            self.assertIn(token, active)
            self.assertIn(token, roadmap)
        self.assertIn("android_validation: NOT_RUN", active)
        self.assertIsNone(re.search(r"(?m)^android_validation:\s*", roadmap))
        self.assertIn("실제 Android", roadmap)
        self.assertIn("NOT_RUN / UNVERIFIED", roadmap)
        for text in (active, roadmap):
            self.assertNotIn("future_platform: MOBILE_CONSIDERATION_ONLY", text)

        self.assertIn("[플랫폼 범위 Decision](docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md)", readme)
        self.assertIn("Windows·Android 기본 설계", readme)
        self.assertIn("단일 공유 코어·플랫폼 Adapter", readme)
        self.assertIn("현재 정확한 검증 상태는 Active Context에서 읽습니다", readme)
        self.assertNotIn("Android 실제 기기 검증: `NOT_RUN`", readme)
        for stale in (
            "PC 우선, 모바일 고려만",
            "현재 기획·구현·검증·배포 기준은 `PC`입니다.",
            "모바일은 PC 버티컬 슬라이스와 전투 코어 검증 뒤 재평가할 미래 후보",
        ):
            self.assertNotIn(stale, readme)

    def test_root_start_here_is_stable_router_not_mutable_state_snapshot(self) -> None:
        text = START_HERE.read_text(encoding="utf-8")
        authority = text.split("## 안정 authority", 1)[1].split("## DOMAIN SPLIT", 1)[0]

        self.assertIn("current_state_owner: ACTIVE_CONTEXT", authority)
        self.assertIn("current_pr_authority: GITHUB_PR_METADATA", authority)
        self.assertIn("current_human_workspace: REPOSITORY_HUMAN_FACING_CANON", authority)
        self.assertIn("current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME", authority)
        self.assertIn("google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL", authority)
        self.assertIn(f"current_work_contract: {CURRENT_WORK_CONTRACT}", authority)
        self.assertIn("design_platforms: WINDOWS_ANDROID", authority)
        self.assertIn("platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS", authority)

        for mutable_key in (
            "runtime_integration_pr:",
            "planning_work_mode:",
            "runtime_implementation:",
            "latest_combat_planning_runtime:",
            "next_package:",
            "human_validation:",
            "current_sheet_authority:",
        ):
            self.assertNotIn(mutable_key, authority)

        self.assertIn("시작 공개 거리 2", text)
        self.assertIn("`거리 N`", text)
        self.assertIn("실제 current Work Mode와 다음 작업은 `ACTIVE_CONTEXT.md`", text)
        self.assertNotIn("필요한 이미지·애니메이션·HX 생성·검수·승인", text)
        self.assertNotIn("VERTICAL_SLICE_APP_FLOW_SHELL Codex 구현 인계", text)


if __name__ == "__main__":
    unittest.main()
