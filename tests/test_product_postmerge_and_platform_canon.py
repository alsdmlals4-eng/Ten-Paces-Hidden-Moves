from __future__ import annotations

import json
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
        for key in (
            "active_planning_work_mode",
            "active_planning_pr",
            "active_planning_parent_pr",
            "active_approval_count",
            "active_decision_state",
            "next_package",
            "next_planning_decision",
        ):
            self.assertIn(f"{key}: {current[key]}", text)
        self.assertIn(f"platform_adapter_decision: {ADAPTER_DECISION}", text)

        forbidden = (
            "DRAFT_PR92_TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_10_OF_10",
            "PR #92는 PR #91 위에 쌓인 Draft",
        )
        for token in forbidden:
            self.assertNotIn(token, text)

    def test_roadmap_preserves_final_product_evidence_and_tracks_new_batch(self) -> None:
        text = ROADMAP.read_text(encoding="utf-8")
        required = (
            f"product_implementation_merge_commit: {PRODUCT_MERGE}",
            "merged_product_pr: 92",
            f"증거: `{EVIDENCE_HEAD}` / workflow `31074079068` / artifact `8956790279`",
        )
        for token in required:
            self.assertIn(token, text)
        current = json.loads(CURRENT_STATE.read_text(encoding="utf-8"))
        for key in (
            "active_planning_work_mode",
            "active_planning_pr",
            "active_planning_parent_pr",
            "active_approval_count",
            "active_decision_state",
            "next_package",
            "next_planning_decision",
        ):
            self.assertIn(f"{key}: {current[key]}", text)
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
        for text in (active, roadmap):
            self.assertIn(f"platform_decision: {PLATFORM_DECISION}", text)
            self.assertIn(f"platform_adapter_decision: {ADAPTER_DECISION}", text)
            self.assertIn("design_platforms: WINDOWS_ANDROID", text)
            self.assertIn("platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS", text)
            self.assertIn("android_validation: NOT_RUN", text)
            self.assertNotIn("future_platform: MOBILE_CONSIDERATION_ONLY", text)

        self.assertIn("[플랫폼 범위 Decision](docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md)", readme)
        self.assertIn("Windows·Android 기본 설계", readme)
        self.assertIn("단일 공유 코어·플랫폼 Adapter", readme)
        self.assertIn("Android 실제 기기 검증: `NOT_RUN`", readme)
        for stale in (
            "PC 우선, 모바일 고려만",
            "현재 기획·구현·검증·배포 기준은 `PC`입니다.",
            "모바일은 PC 버티컬 슬라이스와 전투 코어 검증 뒤 재평가할 미래 후보",
        ):
            self.assertNotIn(stale, readme)

    def test_root_start_here_is_stable_router_not_mutable_state_snapshot(self) -> None:
        text = START_HERE.read_text(encoding="utf-8")
        current = text.split("## 현재 기준", 1)[1].split("## 현재 책임 원본", 1)[0]
        owners = text.split("## 현재 책임 원본", 1)[1].split("## 프로젝트 코어", 1)[0]
        work = text.split("## 현재 작업", 1)[1].split("## Work Mode", 1)[0]

        self.assertIn("current_state_owner: ACTIVE_CONTEXT", current)
        self.assertIn("current_pr_authority: GITHUB_PR_METADATA", current)
        self.assertIn("product_build_requires_user_planning_complete: true", current)
        self.assertIn("design_platforms: WINDOWS_ANDROID", current)
        self.assertIn("platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS", current)

        for mutable_key in (
            "runtime_integration_pr:",
            "planning_work_mode:",
            "runtime_implementation:",
            "latest_combat_planning_runtime:",
            "next_package:",
            "human_validation:",
        ):
            self.assertNotIn(mutable_key, current)

        self.assertIn(
            "docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md",
            owners,
        )
        self.assertNotIn("docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md", owners)
        self.assertNotIn("최근 병합 성장 체크포인트", owners)
        self.assertNotIn("구현 종료:", owners)

        self.assertIn("시작 공개 거리 2", text)
        self.assertIn("`거리 N`", text)
        self.assertIn("사용자 명시 `기획 완료`", work)
        self.assertIn("ACTIVE_CONTEXT의 current next action", work)
        self.assertNotIn("필요한 이미지·애니메이션·HX 생성·검수·승인", work)
        self.assertNotIn("VERTICAL_SLICE_APP_FLOW_SHELL Codex 구현 인계", work)


if __name__ == "__main__":
    unittest.main()
