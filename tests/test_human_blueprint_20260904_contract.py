from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

from pypdf import PdfReader


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260904.pdf"
BUILDER = ROOT / "tools/build_human_game_blueprint_20260904_pdf.py"
DECISION = ROOT / "docs/decisions/2026-09-04_THREE_BRANCH_FOUR_CHOICE_JIANGHU_AND_HUMAN_BLUEPRINT_DECISION.md"
CANDIDATE = ROOT / "docs/visual-assets/candidates/TEN-HUMAN-BLUEPRINT-20260904/TEN_PACES_3X3_SCREEN_ATLAS_20260904_v1.png"


class HumanBlueprint20260904Contract(unittest.TestCase):
    def test_current_blueprint_build_contains_new_route_and_execution_contract(self) -> None:
        self.assertTrue(BUILDER.is_file(), "new dated human-blueprint builder must exist")
        self.assertTrue(OUTPUT.is_file(), "new dated human-blueprint PDF must exist")
        self.assertTrue(CANDIDATE.is_file(), "whole-screen atlas candidate must be project-bound")

        spec = importlib.util.spec_from_file_location("human_blueprint_20260904", BUILDER)
        self.assertIsNotNone(spec)
        self.assertIsNotNone(spec.loader)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        self.assertEqual(module.DEFAULT_OUTPUT, OUTPUT)

        reader = PdfReader(str(OUTPUT))
        self.assertGreaterEqual(len(reader.pages), 20)
        extracted = "\n".join((page.extract_text() or "") for page in reader.pages)
        for required in (
            "십보강호: 숨은 수의 비무",
            "강호행로",
            "3갈래",
            "4회 선택",
            "행동 실행",
            "VS",
            "GENERATED_CANDIDATE",
            "RUNTIME_IMPLEMENTATION_NOT_STARTED",
        ):
            self.assertIn(required, extracted)

        decision_text = DECISION.read_text(encoding="utf-8")
        self.assertIn("후보 중 1개 선택 × 정확히 4단계", decision_text)
        self.assertIn("행동 실행", decision_text)
        self.assertIn("IMPLEMENTED_LEGACY_TWO_NODE_ROUTE", decision_text)


if __name__ == "__main__":
    unittest.main()
