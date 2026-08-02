from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ACTIVE_CONTEXT = ROOT / "[기획서]" / "00_프로젝트_허브" / "ACTIVE_CONTEXT.md"


class CanonicalReferenceRegressionTests(unittest.TestCase):
    def test_active_context_references_combat_rules(self) -> None:
        text = ACTIVE_CONTEXT.read_text(encoding="utf-8")
        self.assertIn(
            "docs/02_COMBAT_RULES.md",
            text,
            "ACTIVE_CONTEXT.md must reference the canonical combat rules document",
        )


if __name__ == "__main__":
    unittest.main()
