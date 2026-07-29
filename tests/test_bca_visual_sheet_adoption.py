from __future__ import annotations
import json, unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
BASE_SHA="c987647d01ad2baa028a16e03d85ddfc1572a727"
SHEET_ID="1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0"
class BCAAdoptionTests(unittest.TestCase):
    def test_base_and_sheet_contract(self):
        for path in ("README.md","AGENTS.md","docs/BASE_RULES_VERSION.md"):
            self.assertIn(BASE_SHA,(ROOT/path).read_text(encoding="utf-8"),path)
        sheet=(ROOT/"docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md").read_text(encoding="utf-8")
        for token in ("PROJECT_SHEET_CONFIGURED",SHEET_ID,"USER_FACING_GDD_WORKSPACE","PROPOSED_SHEET_CHANGE","05_GDD_요약","15_조작_게임규칙"):
            self.assertIn(token,sheet)
    def test_registry(self):
        r=json.loads((ROOT/"[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json").read_text(encoding="utf-8"))
        self.assertEqual(r["base_integration"]["commit"],BASE_SHA)
        self.assertEqual(r["base_integration"]["project_sheet_status"],"PROJECT_SHEET_CONFIGURED")
        self.assertEqual(r["bca_visual_sheet"]["spreadsheet_id"],SHEET_ID)
        self.assertIn("05_GDD_요약",r["bca_visual_sheet"]["required_tabs"])
        self.assertIn("15_조작_게임규칙",r["bca_visual_sheet"]["required_tabs"])
if __name__=="__main__": unittest.main()
