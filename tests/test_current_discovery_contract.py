from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class CurrentDiscoveryContractTests(unittest.TestCase):
    def test_root_start_here_uses_current_windows_android_platform_authority(self) -> None:
        text = (ROOT / "START_HERE.md").read_text(encoding="utf-8")

        self.assertIn("design_platforms: WINDOWS_ANDROID", text)
        self.assertIn("platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS", text)
        self.assertIn("현재 대상 플랫폼은 `Windows`와 `Android`다.", text)

        stale_tokens = [
            "primary_platform: PC",
            "future_platform: MOBILE_CONSIDERATION_ONLY",
            "현재 주 플랫폼은 `PC`다.",
            "모바일은 `CONSIDERATION_ONLY`",
        ]
        for token in stale_tokens:
            self.assertNotIn(
                token,
                text,
                f"START_HERE.md still exposes stale platform authority: {token}",
            )

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

        self.assertIn("current_truth_source: GITHUB_MAIN_PLUS_SHEET_LIVE_READ", current_section)
        self.assertIn("current_main_policy: ALWAYS_REFETCH_GITHUB_MAIN", current_section)
        self.assertIn("base_remote_main_policy: ALWAYS_REFETCH_CURRENT_MAIN", current_section)
        self.assertNotIn("project_main_checkpoint:", current_section)
        self.assertNotIn("base_remote_main_observed:", current_section)

        self.assertIn("next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION", current_section)
        self.assertIn("next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", current_section)
        self.assertIn("planning_visual_next: TEN_IMG_001_GENERATE_EXPLORATION", current_section)
        self.assertIn("planning_visual_review: TEN_IMG_001_EXPLORATION_REVIEW", current_section)
        self.assertIn("product_implementation_authorized: false", current_section)

        self.assertIn("## 관측 증거 스냅샷", text)
        self.assertIn(
            "historical_project_main_at_handoff: 43841d3cc6667d821c10df75272b239f314f3df0",
            text,
        )
        self.assertIn(
            "historical_base_main_at_handoff: 637dad32c773c56a27d44d847518580848dee493",
            text,
        )
        self.assertIn("Issue #140", text)


if __name__ == "__main__":
    unittest.main()
