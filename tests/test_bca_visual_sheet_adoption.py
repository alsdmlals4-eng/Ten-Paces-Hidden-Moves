
from __future__ import annotations
import json
import unittest
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
BASE_SHA = "7072b9e2742a60d7548fd39df3328ad76a8dbad1"

class BCAAdoptionTests(unittest.TestCase):
    def test_entrypoints_and_base_pin(self):
        for path in ("README.md", "AGENTS.md", "docs/BASE_RULES_VERSION.md"):
            text = (ROOT / path).read_text(encoding="utf-8")
            self.assertIn(BASE_SHA, text, path)
        self.assertIn("VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v8.md", (ROOT / "AGENTS.md").read_text(encoding="utf-8"))

    def test_sheet_and_visual_contracts(self):
        sheet = (ROOT / "docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md").read_text(encoding="utf-8")
        visual = (ROOT / "docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md").read_text(encoding="utf-8")
        for token in ("11_세계관", "12_핵심루프", "13_주요인물", "14_조연_세력_관계", "40_핵심시스템_메인콘텐츠", "71_이미지기획_생성목록", "72_이미지검수_승인로그", "NOT_CONFIGURED"):
            self.assertIn(token, sheet)
        for token in ("planning-visualization", "final-visual-candidate", "visual-qa-and-approval", "APPROVED_CANDIDATE", "PROJECT_ASSET_APPROVED", "자동 최종 자산"):
            self.assertIn(token, visual)

    def test_registry_and_ux_skill(self):
        registry = json.loads((ROOT / "[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json").read_text(encoding="utf-8"))
        self.assertEqual(registry["base_integration"]["commit"], BASE_SHA)
        self.assertEqual(registry["bca_visual_sheet"]["sheet_status"], "NOT_CONFIGURED")
        ux = (ROOT / "skills/ux-ui-accessibility/combat-ux-and-accessibility/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("`planning-mockup-review`", ux)
        self.assertIn("`visual-qa-and-approval`", ux)

if __name__ == "__main__": unittest.main()
