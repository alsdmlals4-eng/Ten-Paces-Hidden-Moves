from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FULL_SHA = re.compile(r"^[0-9a-f]{40}$")
USES = re.compile(r"^\s*(?:-\s*)?uses:\s*([^\s#]+)", re.MULTILINE)
CURRENT_ACTION_PINS = {
    "actions/checkout": "3d3c42e5aac5ba805825da76410c181273ba90b1",  # Base current / v7.0.1
    "actions/setup-python": "5fda3b95a4ea91299a34e894583c3862153e4b97",  # Base current / v7.0.0
    "actions/upload-artifact": "043fb46d1a93c77aae656e7c1c64a875d1fc6a0a",  # Base current / v7.0.1
    "chickensoft-games/setup-godot": "f166999204a4f2722c6fe042fbaa3b3ea0d9c789",  # upstream v2.4.1
}
TEMPORARY_PIN_EXCEPTIONS = {
    # The Live-Editor adoption contract intentionally rejects broad diffs. Its workflow
    # is migrated in a dedicated follow-up PR so that its four-file boundary remains
    # meaningful during this fleet-wide supply-chain patch. These refs are immutable;
    # the exception is only for Base-current freshness and must be removed after that PR.
    ".github/workflows/validate-godot-live-editor-pilot.yml": {
        "actions/checkout": "11bd71901bbe5b1630ceea73d27597364c9af683",
        "actions/setup-python": "a26af69be951a213d495a4c3e4e4022e16d87065",
    }
}


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

    def test_temporary_pin_exception_self_retires_when_current_pin_arrives(self) -> None:
        workflow_path = ".github/workflows/validate-godot-live-editor-pilot.yml"
        for action, current_ref in CURRENT_ACTION_PINS.items():
            if action not in TEMPORARY_PIN_EXCEPTIONS[workflow_path]:
                continue
            self.assertTrue(
                is_reconciled_action_pin_allowed(workflow_path, action, current_ref),
                f"{action} must be allowed to leave its temporary exception without changing this contract first",
            )

    def test_active_workflows_use_immutable_reconciled_action_pins(self) -> None:
        violations: list[str] = []
        seen_actions: set[str] = set()
        seen_exceptions: set[tuple[str, str]] = set()
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

                if action in CURRENT_ACTION_PINS:
                    expected = CURRENT_ACTION_PINS[action]
                    exception = TEMPORARY_PIN_EXCEPTIONS.get(workflow_path, {}).get(action)
                    if ref == exception:
                        seen_exceptions.add((workflow_path, action))
                    elif ref != expected:
                        violations.append(
                            f"{workflow_path}: {action} pin {ref} != reconciled current {expected}"
                        )

        self.assertEqual(set(CURRENT_ACTION_PINS), seen_actions)
        expected_exceptions = {
            (workflow_path, action)
            for workflow_path, actions in TEMPORARY_PIN_EXCEPTIONS.items()
            for action in actions
        }
        self.assertEqual(expected_exceptions, seen_exceptions)
        self.assertFalse(
            violations,
            "Mutable/stale remote action refs found:\n" + "\n".join(violations),
        )


if __name__ == "__main__":
    unittest.main()
