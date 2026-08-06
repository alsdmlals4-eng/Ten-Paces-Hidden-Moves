import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CURRENT_STATE = ROOT / "docs/planning-data/current_operating_state.json"
ACTIVE = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
ROADMAP = ROOT / "docs/04_ROADMAP.md"
HUB_ROADMAP = ROOT / "[기획서]/00_프로젝트_허브/ROADMAP.md"

ARCHITECTURE_DECISION = "TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01"
ARCHITECTURE_MERGE = "023385d372d127044d48afcb50e6f232ab9ffaa1"


def yaml_scalar(text: str, key: str) -> str:
    values = re.findall(rf"(?m)^{re.escape(key)}:\s*([^\s#]+)", text)
    if len(values) != 1:
        raise AssertionError(f"expected one YAML scalar for {key}, found {len(values)}")
    return values[0]


class WindowsAndroidAdapterPostMergeCloseoutTest(unittest.TestCase):
    def test_current_operating_state_no_longer_treats_pr102_as_active(self):
        state = json.loads(CURRENT_STATE.read_text(encoding="utf-8"))
        self.assertNotEqual(state["active_planning_pr"], "102")
        self.assertNotEqual(state["active_decision_state"], "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED")

    def test_active_context_records_architecture_merge(self):
        text = ACTIVE.read_text(encoding="utf-8")
        self.assertEqual(yaml_scalar(text, "merged_planning_checkpoint"), ARCHITECTURE_MERGE)
        self.assertNotEqual(yaml_scalar(text, "active_planning_pr"), "102")
        self.assertNotEqual(yaml_scalar(text, "active_decision_state"), "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED")
        self.assertEqual(yaml_scalar(text, "platform_adapter_merge_commit"), ARCHITECTURE_MERGE)
        self.assertEqual(yaml_scalar(text, "merged_platform_adapter_pr"), "102")
        self.assertIn("merged_pr_lineage: 84,86,87,88,89,91,92,100,101,102", text)

    def test_roadmaps_record_merge_and_next_gate(self):
        for path in [ROADMAP, HUB_ROADMAP]:
            text = path.read_text(encoding="utf-8")
            self.assertNotEqual(yaml_scalar(text, "active_planning_pr"), "102")
            self.assertNotEqual(yaml_scalar(text, "active_decision_state"), "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED")
            self.assertEqual(yaml_scalar(text, "platform_adapter_merge_commit"), ARCHITECTURE_MERGE)
            self.assertEqual(yaml_scalar(text, "merged_platform_adapter_pr"), "102")
            self.assertEqual(yaml_scalar(text, "next_planning_decision"), "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE")
            self.assertIn("PR #102", text)

    def test_product_authority_remains_separate(self):
        text = ACTIVE.read_text(encoding="utf-8")
        self.assertIn("product_implementation_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90", text)
        self.assertIn("merged_product_pr: 92", text)
        self.assertIn("evidence_source_head: 0a8bf577b936ddac5cb7130a0cc58e519ea6eff6", text)
        self.assertIn("product_gate: PARTIAL_AUTOMATED_COMPLETE", text)


if __name__ == "__main__":
    unittest.main()
