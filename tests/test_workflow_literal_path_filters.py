from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW_ROOT = ROOT / ".github" / "workflows"
UNESCAPED_LITERAL_PATH_FILTER = re.compile(
    r"^\s*-\s+[\"']?\[기획서\]/"
)
EXPECTED_LITERAL_FILTERS = {
    "postmerge-canon-lifecycle-validation.yml": (
        r"\[기획서\]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
    ),
    "condition-calibration-validation.yml": (
        r"\[기획서\]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
    ),
    "resource-saturation-internal-recovery-validation.yml": (
        r"\[기획서\]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
    ),
    "validate-bca-visual-sheet-adoption.yml": (
        r"\[기획서\]/00_프로젝트_허브/SKILL_REGISTRY.json"
    ),
}


class WorkflowLiteralPathFilterTests(unittest.TestCase):
    def test_no_workflow_list_item_uses_unescaped_literal_brackets(self) -> None:
        offenders: list[str] = []
        for workflow in sorted(WORKFLOW_ROOT.glob("*.y*ml")):
            for line_number, line in enumerate(
                workflow.read_text(encoding="utf-8").splitlines(), start=1
            ):
                if UNESCAPED_LITERAL_PATH_FILTER.match(line):
                    offenders.append(f"{workflow.name}:{line_number}:{line.strip()}")

        self.assertEqual([], offenders, "unescaped literal path filters: " + "; ".join(offenders))

    def test_known_literal_directory_filters_remain_escaped(self) -> None:
        for workflow_name, expected_filter in EXPECTED_LITERAL_FILTERS.items():
            with self.subTest(workflow=workflow_name):
                text = (WORKFLOW_ROOT / workflow_name).read_text(encoding="utf-8")
                self.assertIn(expected_filter, text)


if __name__ == "__main__":
    unittest.main()
