from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ACTIVE = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
ROADMAP = ROOT / "docs/04_ROADMAP.md"
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

        current_planning = (
            "active_planning_pr: NONE",
            "active_planning_parent_pr: NONE",
            "active_planning_work_mode: REVIEW",
            "active_approval_count: 1/10",
            "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED",
            f"platform_adapter_decision: {ADAPTER_DECISION}",
            "next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE",
        )
        for token in current_planning:
            self.assertIn(token, text)

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
            "active_planning_pr: NONE",
            "active_approval_count: 1/10",
            "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED",
            "next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION",
            "next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE",
        )
        for token in required:
            self.assertIn(token, text)
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


if __name__ == "__main__":
    unittest.main()
