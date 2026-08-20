from __future__ import annotations

import json
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class CurrentDiscoveryContractTests(unittest.TestCase):
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
        self.assertIn(
            "planning_visual_next: AWAITING_EXPLICIT_ASSET_OR_IMPLEMENTATION_REQUEST",
            current_section,
        )
        self.assertIn(
            "planning_visual_authority: TEN-DEC-20260820-VISUAL-UX-SYSTEM-01",
            current_section,
        )
        self.assertIn(
            "planning_visual_review: TEN_IMG_001_CHAT_EXPLORATIONS_REVIEWED_NOT_AN_ASSET",
            current_section,
        )
        self.assertIn(
            "planning_visual_overlay: TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01",
            current_section,
        )
        self.assertIn("ci_supply_chain_followup: RESOLVED_ISSUE_140", current_section)
        self.assertIn("product_implementation_authorized: false", current_section)

        self.assertNotIn("planning_visual_next: TEN_IMG_001_GENERATE_EXPLORATION", current_section)
        self.assertNotIn("planning_visual_review: TEN_IMG_001_EXPLORATION_REVIEW", current_section)
        self.assertNotIn("ci_supply_chain_followup: ISSUE_140", current_section)

        self.assertIn("## 관측 증거 스냅샷", text)
        self.assertIn(
            "historical_project_main_at_handoff: 43841d3cc6667d821c10df75272b239f314f3df0",
            text,
        )

    def test_documentation_map_routes_current_state_without_mutable_snapshot(self) -> None:
        text = (ROOT / "DOCUMENTATION_MAP.md").read_text(encoding="utf-8")
        self.assertIn("ACTIVE_CONTEXT.md", text)
        self.assertNotIn("project_main_checkpoint", text)

    def test_root_start_here_uses_current_windows_android_platform_authority(self) -> None:
        text = (ROOT / "START_HERE.md").read_text(encoding="utf-8")
        self.assertIn("WINDOWS_ANDROID", text)
        self.assertIn("ACTIVE_CONTEXT.md", text)

    def test_combat_rules_use_current_basic_attack_reprice_authority(self) -> None:
        text = (ROOT / "docs" / "02_COMBAT_RULES.md").read_text(encoding="utf-8")
        self.assertIn("approved_20260811_basic_attack_reprice_contract.json", text)

    def test_combat_rules_use_current_bundle_transition_internal_recovery(self) -> None:
        text = (ROOT / "docs" / "02_COMBAT_RULES.md").read_text(encoding="utf-8")
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

    def test_active_workflows_use_immutable_reconciled_action_pins(self) -> None:
        workflow_dir = ROOT / ".github" / "workflows"
        workflows = list(workflow_dir.glob("*.yml")) + list(workflow_dir.glob("*.yaml"))
        self.assertTrue(workflows)
        for workflow in workflows:
            text = workflow.read_text(encoding="utf-8")
            self.assertNotIn("actions/checkout@v", text, workflow.as_posix())
            self.assertNotIn("actions/setup-python@v", text, workflow.as_posix())

    def test_no_temporary_pin_exceptions_remain_after_live_editor_migration(self) -> None:
        exception_path = ROOT / ".github" / "action-pin-exceptions.json"
        if not exception_path.exists():
            return
        data = json.loads(exception_path.read_text(encoding="utf-8"))
        exceptions = data.get("exceptions", [])
        self.assertEqual([], exceptions)


if __name__ == "__main__":
    unittest.main()
