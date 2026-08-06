#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"missing {label}: {old!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


product = ROOT / "tests/test_product_postmerge_and_platform_canon.py"
replace_once(product, "from __future__ import annotations\n\nimport unittest", "from __future__ import annotations\n\nimport json\nimport unittest", "product json import")
replace_once(
    product,
    'ROADMAP = ROOT / "docs/04_ROADMAP.md"\n',
    'ROADMAP = ROOT / "docs/04_ROADMAP.md"\nCURRENT_STATE = ROOT / "docs/planning-data/current_operating_state.json"\n',
    "product current state path",
)
replace_once(
    product,
    '''        current_planning = (
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
''',
    '''        current = json.loads(CURRENT_STATE.read_text(encoding="utf-8"))
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
''',
    "product active dynamic state",
)
replace_once(
    product,
    '''        required = (
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
''',
    '''        required = (
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
''',
    "product roadmap dynamic state",
)

project = ROOT / "tests/test_project_governance.py"
replace_once(
    project,
    '''        current_mutable_tokens = [
            "active_planning_pr: NONE",
            "active_approval_count: 1/10",
            "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED",
            "next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION",
            "next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE",
            "TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01",
        ]
''',
    '''        current_state = json.loads(
            (ROOT / "docs/planning-data/current_operating_state.json").read_text(encoding="utf-8")
        )
        current_mutable_tokens = [
            f"active_planning_pr: {current_state['active_planning_pr']}",
            f"active_approval_count: {current_state['active_approval_count']}",
            f"active_decision_state: {current_state['active_decision_state']}",
            f"next_package: {current_state['next_package']}",
            f"next_planning_decision: {current_state['next_planning_decision']}",
            current_state["source_decision"],
        ]
''',
    "governance dynamic state",
)

mastery = ROOT / "tests/test_star7_star9_mastery_bonus_contract.py"
replace_once(
    mastery,
    '''        for current in [active, roadmap]:
            self.assertIn("TEN_MANUAL_UI_AI_ADOPTION_GATE", current)
            self.assertIn("TEN_MANUAL_PRODUCT_VALIDATION_GATE", current)
            self.assertIn("merged_product_pr: 92", current)
            self.assertIn("product_implementation_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90", current)
            self.assertIn("active_approval_count: 1/10", current)
            self.assertIn("active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED", current)
            self.assertIn("next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", current)
''',
    '''        current_state = json.loads(
            (ROOT / "docs/planning-data/current_operating_state.json").read_text(encoding="utf-8")
        )
        for current in [active, roadmap]:
            self.assertIn("TEN_MANUAL_UI_AI_ADOPTION_GATE", current)
            self.assertIn("TEN_MANUAL_PRODUCT_VALIDATION_GATE", current)
            self.assertIn("merged_product_pr: 92", current)
            self.assertIn("product_implementation_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90", current)
            self.assertIn(f"active_approval_count: {current_state['active_approval_count']}", current)
            self.assertIn(f"active_decision_state: {current_state['active_decision_state']}", current)
            self.assertIn(f"next_planning_decision: {current_state['next_planning_decision']}", current)
''',
    "mastery dynamic state",
)

closeout = ROOT / "tests/test_windows_android_adapter_postmerge_closeout.py"
replace_once(
    closeout,
    '''    def test_current_operating_state_closes_pr102(self):
        state = json.loads(CURRENT_STATE.read_text(encoding="utf-8"))
        self.assertEqual(state["source_decision"], ARCHITECTURE_DECISION)
        self.assertEqual(state["active_planning_work_mode"], "REVIEW")
        self.assertEqual(state["active_planning_pr"], "NONE")
        self.assertEqual(state["active_planning_parent_pr"], "NONE")
        self.assertEqual(state["active_approval_count"], "1/10")
        self.assertEqual(state["active_decision_state"], "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED")
        self.assertEqual(state["next_package"], "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION")
        self.assertEqual(state["next_planning_decision"], "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE")
''',
    '''    def test_current_operating_state_no_longer_treats_pr102_as_active(self):
        state = json.loads(CURRENT_STATE.read_text(encoding="utf-8"))
        self.assertNotEqual(state["active_planning_pr"], "102")
        self.assertNotEqual(state["active_decision_state"], "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED")
''',
    "closeout durable current state",
)
replace_once(
    closeout,
    '''        self.assertEqual(yaml_scalar(text, "active_planning_pr"), "NONE")
        self.assertEqual(yaml_scalar(text, "active_decision_state"), "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED")
''',
    '''        self.assertNotEqual(yaml_scalar(text, "active_planning_pr"), "102")
        self.assertNotEqual(yaml_scalar(text, "active_decision_state"), "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED")
''',
    "closeout active durable state",
)
replace_once(
    closeout,
    '''            self.assertEqual(yaml_scalar(text, "active_planning_pr"), "NONE")
            self.assertEqual(yaml_scalar(text, "active_decision_state"), "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED")
''',
    '''            self.assertNotEqual(yaml_scalar(text, "active_planning_pr"), "102")
            self.assertNotEqual(yaml_scalar(text, "active_decision_state"), "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED")
''',
    "closeout roadmaps durable state",
)

for path in (product, project, mastery, closeout):
    text = path.read_text(encoding="utf-8")
    path.write_text("\n".join(line.rstrip() for line in text.splitlines()) + "\n", encoding="utf-8")
