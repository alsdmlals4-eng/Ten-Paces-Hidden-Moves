from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "postmerge-canon-lifecycle-validation.yml"
LITERAL_ACTIVE_CONTEXT_FILTER = (
    r"      - '\[기획서\]/00_프로젝트_허브/ACTIVE_CONTEXT.md'"
)
UNESCAPED_ACTIVE_CONTEXT_FILTER = (
    "      - '[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md'"
)


class WorkflowLiteralPathFilterTests(unittest.TestCase):
    def test_postmerge_workflow_escapes_literal_brackets_in_path_filter(self) -> None:
        text = WORKFLOW.read_text(encoding="utf-8")

        self.assertIn(LITERAL_ACTIVE_CONTEXT_FILTER, text)
        self.assertNotIn(UNESCAPED_ACTIVE_CONTEXT_FILTER, text)


if __name__ == "__main__":
    unittest.main()
