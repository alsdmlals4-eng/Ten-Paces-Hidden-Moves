from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OLD_BASE = "7072b9e2742a60d7548fd39df3328ad76a8dbad1"
BASE_SHA = "c987647d01ad2baa028a16e03d85ddfc1572a727"
SHEET_ID = "1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0"
SHEET_URL = f"https://docs.google.com/spreadsheets/d/{SHEET_ID}/edit"
TABS = [
    "00_프로젝트_허브", "01_작업순서", "02_현재_확정결정", "03_근거_라이브러리",
    "04_누락_충돌_감사", "05_GDD_요약", "10_제품방향", "11_세계관", "12_핵심루프",
    "13_주요인물", "14_조연_세력_관계", "15_조작_게임규칙", "20_코어경험_데모목표",
    "30_데모범위_품질기준_제작기반", "40_핵심시스템_메인콘텐츠", "41_성장_경제",
    "50_메인콘텐츠", "60_UX_UI_접근성", "70_아트_오디오_에셋", "71_이미지기획_생성목록",
    "72_이미지검수_승인로그", "80_데모_버티컬슬라이스_플레이테스트", "90_본제작_출시_사업",
    "98_Base_반영후보", "99_변경이력",
]


def update_text(path: str) -> None:
    file = ROOT / path
    if not file.exists():
        return
    text = file.read_text(encoding="utf-8")
    text = text.replace(OLD_BASE, BASE_SHA)
    text = text.replace("NOT_CONFIGURED", "PROJECT_SHEET_CONFIGURED")
    text = text.replace(
        "정확한 URL·권한을 확인하기 전에는 새 Sheet를 추정 생성하지 않는다.",
        "검증된 URL·ID·탭을 사용하고 사용자 Sheet 수정은 `PROPOSED_SHEET_CHANGE`로 보존한다.",
    )
    text = text.replace(
        "실제 Google Sheet URL·권한과 실제 생성 이미지·런타임 검수",
        "실제 생성 이미지·런타임·사용자 시각 검수",
    )
    file.write_text(text, encoding="utf-8")


for path in (
    "README.md", "AGENTS.md", "docs/BASE_RULES_VERSION.md",
    "docs/BCA_VISUAL_SHEET_ADOPTION_AUDIT.md",
    "docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md",
):
    update_text(path)

workbook = [
    "# 십보강호 프로젝트 Google Sheets Workbook", "", "```yaml",
    "project: Ten-Paces-Hidden-Moves", "sheet_status: PROJECT_SHEET_CONFIGURED",
    f"spreadsheet_url: {SHEET_URL}", f"spreadsheet_id: {SHEET_ID}",
    "workbook_role: USER_FACING_GDD_WORKSPACE", "sheet_edit_policy: PROPOSED_SHEET_CHANGE",
    f"base_commit: {BASE_SHA}", "last_verified_at: 2026-07-29", "```", "",
    "Google Sheets는 사용자가 전체 흐름을 확인·수정하고 AI가 GitHub 정본·실제 구현과 함께 읽는 GDD 작업면이다. Sheet 단독 값으로 승인·구현·검증 완료를 확정하지 않는다.", "",
    "## 검증된 탭",
]
workbook.extend(f"- `{tab}`" for tab in TABS)
workbook.extend([
    "", "## 프로젝트 책임 매핑", "",
    "| 의미 구조 | 프로젝트 책임 원본 |", "|---|---|",
    "| 세계관·세력·무공 | v6 결정 원장과 등록된 기획 문서 |",
    "| 핵심루프 | `docs/00_GAME_PILLARS.md`, 전투·진행 책임 원본 |",
    "| 주요인물·조연 | 캐릭터·결투·세력 책임 원본 |",
    "| 핵심시스템·메인콘텐츠 | 전장 10칸, 3/3/4 계획, 카드·거리·합, 주요 비무 |",
    "| 이미지 계획·검수 | `docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md` |", "",
    "GitHub에 없는 사용자 수정은 자동 덮어쓰지 않고 `PROPOSED_SHEET_CHANGE`로 비교·승인한 뒤 양쪽을 재조회한다.",
])
(ROOT / "docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md").write_text("\n".join(workbook) + "\n", encoding="utf-8")

registry_path = ROOT / "[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json"
registry = json.loads(registry_path.read_text(encoding="utf-8"))
base = registry["base_integration"]
base["commit"] = BASE_SHA
base["project_sheet_status"] = "PROJECT_SHEET_CONFIGURED"
base["project_sheet_url"] = SHEET_URL
base["project_sheet_id"] = SHEET_ID
base["project_sheet_role"] = "USER_FACING_GDD_WORKSPACE"
base["project_sheet_edit_policy"] = "PROPOSED_SHEET_CHANGE"
base["project_sheet_last_verified_at"] = "2026-07-29"
bca = registry["bca_visual_sheet"]
bca["sheet_status"] = "PROJECT_SHEET_CONFIGURED"
bca["spreadsheet_url"] = SHEET_URL
bca["spreadsheet_id"] = SHEET_ID
bca["workbook_role"] = "USER_FACING_GDD_WORKSPACE"
bca["sheet_edit_policy"] = "PROPOSED_SHEET_CHANGE"
bca["last_verified_at"] = "2026-07-29"
bca["required_tabs"] = TABS
registry_path.write_text(json.dumps(registry, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

test = f'''from __future__ import annotations
import json, unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
BASE_SHA="{BASE_SHA}"
SHEET_ID="{SHEET_ID}"
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
'''
(ROOT / "tests/test_bca_visual_sheet_adoption.py").write_text(test, encoding="utf-8")
