from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE_SHA = "7072b9e2742a60d7548fd39df3328ad76a8dbad1"
BRANCH = "agent/bca-visual-sheet-v8-adoption"
TABS = [
    "00_프로젝트_허브", "01_작업순서", "02_현재_확정결정", "03_근거_라이브러리", "04_누락_충돌_감사",
    "10_제품방향", "11_세계관", "12_핵심루프", "13_주요인물", "14_조연_세력_관계",
    "20_코어경험_데모목표", "30_데모범위_품질기준_제작기반", "40_핵심시스템_메인콘텐츠", "41_성장_경제",
    "50_메인콘텐츠", "60_UX_UI_접근성", "70_아트_오디오_에셋", "71_이미지기획_생성목록",
    "72_이미지검수_승인로그", "80_데모_버티컬슬라이스_플레이테스트", "90_본제작_출시_사업",
    "98_Base_반영후보", "99_변경이력",
]


def append_once(path: str, marker: str, block: str) -> None:
    target = ROOT / path
    text = target.read_text(encoding="utf-8")
    if marker not in text:
        target.write_text(text.rstrip() + "\n\n" + block.strip() + "\n", encoding="utf-8")


def write(path: str, content: str) -> None:
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content.rstrip() + "\n", encoding="utf-8")


def update_agents() -> None:
    path = ROOT / "AGENTS.md"
    text = path.read_text(encoding="utf-8")
    old = "3. `VERTICAL_SLICE_MASTER_REFERENCE_v6.md`와 축약 실행문."
    new = "3. `alsdmlals4-eng/Base@" + BASE_SHA + "`의 `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v8.md`."
    if old in text:
        text = text.replace(old, new, 1)
    block = f"""
## 12. BCA Sheet·GPT 이미지 생성·검수

- Base 기준: `alsdmlals4-eng/Base@{BASE_SHA}`.
- 통합 실행문: `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v8.md`.
- 프로젝트 Google Sheets 상태: `NOT_CONFIGURED`. 정확한 URL·권한을 확인하기 전에는 새 Sheet를 추정 생성하지 않는다.
- 의미 구조는 `docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md`가 세계관·핵심루프·주요인물·조연·세력·관계·핵심시스템·메인콘텐츠와 이미지 tab을 프로젝트 정본에 연결한다.
- GPT 이미지는 `planning-visualization`과 `final-visual-candidate`로 생성할 수 있지만 자동 최종 자산이 아니다.
- 전장 10칸, 3수→3수→4수, 숨은 수 판독, 카드·거리·합 가독성을 실제 화면 기준으로 `visual-qa-and-approval` 검수한다.
- 승인 뒤에만 Decision·정본·GitHub·Sheet·Asset Ledger·실제 적용 상태를 동기화한다.
- 각 단계 종료 시 `repository-wide-audit`로 v6/v7 활성 참조, stale 목업, untouched 소비자와 승인 누락을 다시 공격한다.
"""
    if "## 12. BCA Sheet·GPT 이미지 생성·검수" not in text:
        text = text.rstrip() + "\n\n" + block.strip() + "\n"
    path.write_text(text, encoding="utf-8")


def update_base_version() -> None:
    path = ROOT / "docs/BASE_RULES_VERSION.md"
    text = path.read_text(encoding="utf-8")
    text = text.replace("41a20584dd2ee51d917e5c9d7cab6838e1ceba7e", BASE_SHA)
    text = text.replace("코어 동기화 날짜: `2026-07-23`", "코어 동기화 날짜: `2026-07-28`")
    block = f"""
## 9. BCA v8 채택

- 채택 Base: `alsdmlals4-eng/Base@{BASE_SHA}`.
- 활성 통합 실행문: `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v8.md`.
- 프로젝트 Sheet: `NOT_CONFIGURED`; `docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md`의 tab·열 계약만 설치.
- GPT 기획 시각화·최종 후보·검수: `docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md`.
- v6 결정 원장은 십보강호 고유 승인 이력으로 유지하지만 v6 공용 Prompt는 활성 실행 권한이 없다.
"""
    if "## 9. BCA v8 채택" not in text:
        text = text.rstrip() + "\n\n" + block.strip() + "\n"
    path.write_text(text, encoding="utf-8")


def update_registry() -> None:
    path = ROOT / "[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    base = data["base_integration"]
    base["commit"] = BASE_SHA
    base["integrated_execution_prompt"] = "templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v8.md"
    base["project_sheet_status"] = "NOT_CONFIGURED"
    base["project_sheet_contract"] = "docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md"
    base["image_workflow"] = "docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md"
    data["bca_visual_sheet"] = {
        "status": "ADOPTED",
        "sheet_status": "NOT_CONFIGURED",
        "required_tabs": TABS,
        "image_modes": ["planning-visualization", "final-visual-candidate", "visual-qa-and-approval"],
        "adversarial_mode": "repository-wide-audit",
    }
    by_id = {item["skill_id"]: item for item in data["project_local_skills"]}
    for tag in ("worldbuilding", "core-loop", "main-characters", "supporting-characters", "core-systems", "main-content", "planning-visualization", "final-visual-candidate"):
        if tag not in by_id["ten-paces-game-design"]["trigger_tags"]:
            by_id["ten-paces-game-design"]["trigger_tags"].append(tag)
    if "visual-brief" not in by_id["ten-paces-game-design"]["modes"]:
        by_id["ten-paces-game-design"]["modes"].append("visual-brief")
    for tag in ("image-mockup", "visual-qa", "image-approval"):
        if tag not in by_id["combat-ux-and-accessibility"]["trigger_tags"]:
            by_id["combat-ux-and-accessibility"]["trigger_tags"].append(tag)
    for mode in ("planning-mockup-review", "visual-qa-and-approval"):
        if mode not in by_id["combat-ux-and-accessibility"]["modes"]:
            by_id["combat-ux-and-accessibility"]["modes"].append(mode)
    for tag in ("sheet-structure", "stale-prompt", "image-approval-ledger", "bca-adoption"):
        if tag not in by_id["ten-paces-verification"]["trigger_tags"]:
            by_id["ten-paces-verification"]["trigger_tags"].append(tag)
    if "bca-adoption-audit" not in by_id["ten-paces-verification"]["modes"]:
        by_id["ten-paces-verification"]["modes"].append("bca-adoption-audit")
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def update_ux_skill() -> None:
    path = ROOT / "skills/ux-ui-accessibility/combat-ux-and-accessibility/SKILL.md"
    text = path.read_text(encoding="utf-8")
    if "`planning-mockup-review`" not in text:
        text = text.replace(
            "- `accessibility-review`: 정보·입력·탐색·시간·난이도·모션·음향 장벽과 대체 경로.",
            "- `accessibility-review`: 정보·입력·탐색·시간·난이도·모션·음향 장벽과 대체 경로.\n- `planning-mockup-review`: GPT가 만든 전장·카드·HUD 기획 목업의 정보 위계와 코어 일치 검수.\n- `visual-qa-and-approval`: 최종 후보의 실제 화면·구현 가능성·오류·권리·승인 상태 검수.",
            1,
        )
    if "생성 목업은 자동 최종 자산이 아니다" not in text:
        text = text.replace(
            "- 승인 이미지 임의 교체.",
            "- 승인 이미지 임의 교체.\n- 생성 목업은 자동 최종 자산이 아니다. `APPROVED_CANDIDATE`와 `PROJECT_ASSET_APPROVED`를 혼동하지 않는다.",
            1,
        )
    path.write_text(text, encoding="utf-8")


def create_docs() -> None:
    tabs = "\n".join(f"- `{tab}`" for tab in TABS)
    write("docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md", f"""
# 십보강호 프로젝트 Google Sheets Workbook

```yaml
project: Ten-Paces-Hidden-Moves
sheet_status: NOT_CONFIGURED
spreadsheet_url:
base_commit: {BASE_SHA}
```

정확한 기존 Sheet URL·ID·권한을 확인하지 못했으므로 신규 Sheet를 생성하지 않는다. 연결 시 기존 tab·수식·사용자 편집을 먼저 읽고 다음 tab을 작업 순서대로 설치·병합한다.

{tabs}

## 프로젝트 책임 매핑

| 의미 구조 | 프로젝트 책임 원본 |
|---|---|
| 세계관·세력·무공 | v6 결정 원장과 등록된 기획 문서 |
| 핵심루프 | `docs/00_GAME_PILLARS.md`, 전투·진행 책임 원본 |
| 주요인물·조연 | 캐릭터·결투·세력 책임 원본 |
| 핵심시스템·메인콘텐츠 | 전장 10칸, 3/3/4 계획, 카드·거리·합, 5개 앵커 결투 |
| 이미지 계획·검수 | `docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md` |

Sheet는 독립 정본이 아니라 Decision ID·GitHub 경로·상태를 연결한다.
""")
    write("docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md", f"""
# 십보강호 GPT 이미지 생성·검수 워크플로

- Base: `alsdmlals4-eng/Base@{BASE_SHA}`
- 공용 Mode: `planning-visualization`, `final-visual-candidate`, `visual-qa-and-approval`
- Sheet 상태: `NOT_CONFIGURED`

## 기획 중 우선 이미지

1. 10칸 일자형 전장과 거리·밀착 정보 목업.
2. `3수 → 3수 → 4수` 계획 슬롯과 실행 전/후 HUD.
3. 카드의 문파·무공 종류·사거리·비용·행동 슬롯·기력·내력 정보 위계.
4. 주요 문파·무공·심법의 실루엣과 색·상징 언어.
5. 숨은 수 단서·가설·파훼가 읽히는 결투 상황 비교.

## 기획 종료 우선 후보

1. 5개 앵커 결투 Demo 키아트와 Steam 캡슐 후보.
2. 실제 16:9 전투 HUD·카드·로그 고도화 목업.
3. 주요 인물·상대 무인 캐릭터 시트와 표정·포즈.
4. 무공서·절초·세력 카드의 반복 제작 가능한 시각 체계.

## 검수

`PLANNED → GENERATED_EXPLORATION → IN_REVIEW → REVISION_REQUIRED/REJECTED/APPROVED_CANDIDATE → PROJECT_ASSET_APPROVED → APPLIED_AND_RUNTIME_VERIFIED`를 사용한다.

전장·카드·HUD는 실제 화면 크기에서 거리, 선택, 대응, 합 결과가 읽혀야 한다. 손·무기·한글·배지·카드 정렬·원근 오류, 구현 비용, 특정 IP·작가 스타일 유사성, 원출처·라이선스를 검수한다. 생성 결과는 자동 최종 자산이 아니다.
""")
    write("docs/BCA_VISUAL_SHEET_ADOPTION_AUDIT.md", f"""
# BCA v8 적용 적대적 검토

```yaml
base_commit: {BASE_SHA}
project_sheet_status: NOT_CONFIGURED
product_paths_changed: false
final_status: CONFLICT_FIXED
```

## 공격 결과

- `MUST_FIX`: AGENTS의 공용 v6 Prompt 활성 우선순위 → Base v8로 교체.
- `MUST_FIX`: 세계관·핵심루프·인물·핵심시스템·이미지 tab 계약 부재 → adapter 설치.
- `MUST_FIX`: 기획 이미지와 최종 자산 상태 분리 부족 → 공용 lifecycle 설치.
- `ALLOWED_LEGACY`: v6 결정 원장과 PR #45는 십보강호 고유 승인·역사 근거로 유지.
- `BLOCKED_UNVERIFIED`: 실제 Google Sheet URL·권한과 실제 생성 이미지·런타임 검수.

제품 코드·데이터·씬·자산은 이 적용에서 변경하지 않는다.
""")


def create_test_and_workflow() -> None:
    write("tests/test_bca_visual_sheet_adoption.py", f'''
from __future__ import annotations
import json
import unittest
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
BASE_SHA = "{BASE_SHA}"

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
''')
    write(".github/workflows/validate-bca-visual-sheet-adoption.yml", '''
name: Validate BCA Visual Sheet Adoption
on:
  pull_request:
    branches: [main]
    paths:
      - "README.md"
      - "AGENTS.md"
      - "docs/BASE_RULES_VERSION.md"
      - "docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md"
      - "docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md"
      - "docs/BCA_VISUAL_SHEET_ADOPTION_AUDIT.md"
      - "[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json"
      - "skills/ux-ui-accessibility/combat-ux-and-accessibility/SKILL.md"
      - "tests/test_bca_visual_sheet_adoption.py"
      - ".github/workflows/validate-bca-visual-sheet-adoption.yml"
permissions:
  contents: read
concurrency:
  group: ten-paces-bca-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true
jobs:
  contract:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - name: Run contract and stale-reference audit
        shell: bash
        run: |
          python -m py_compile tests/test_bca_visual_sheet_adoption.py
          python -m unittest tests.test_bca_visual_sheet_adoption -v
          git grep -n -I -E 'VERTICAL_SLICE_EXECUTION_PROMPT_SHORT_v6|VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v7' -- README.md AGENTS.md docs '[기획서]/00_프로젝트_허브' skills || true
          git diff --check origin/main...HEAD
''')


def main() -> None:
    create_docs()
    create_test_and_workflow()
    update_agents()
    update_base_version()
    update_registry()
    update_ux_skill()
    append_once("README.md", "## BCA v8 기획·이미지·Sheet 운영", f"""
## BCA v8 기획·이미지·Sheet 운영

- Base 기준: `alsdmlals4-eng/Base@{BASE_SHA}`
- 통합 실행문: `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v8.md`
- 프로젝트 Sheet: `NOT_CONFIGURED`; 구조 계약은 `docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md`
- GPT 이미지·목업: `docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md`
- 적용 감사: `docs/BCA_VISUAL_SHEET_ADOPTION_AUDIT.md`
""")

if __name__ == "__main__": main()
