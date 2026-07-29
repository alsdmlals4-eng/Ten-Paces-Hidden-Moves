# 십보강호 프로젝트 Google Sheets Workbook

```yaml
project: Ten-Paces-Hidden-Moves
sheet_status: PROJECT_SHEET_CONFIGURED
spreadsheet_url: https://docs.google.com/spreadsheets/d/1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0/edit
spreadsheet_id: 1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0
workbook_role: USER_FACING_GDD_WORKSPACE
sheet_edit_policy: PROPOSED_SHEET_CHANGE
base_commit: c987647d01ad2baa028a16e03d85ddfc1572a727
last_verified_at: 2026-07-29
```

Google Sheets는 사용자가 전체 흐름을 확인·수정하고 AI가 GitHub 정본·실제 구현과 함께 읽는 GDD 작업면이다. Sheet 단독 값으로 승인·구현·검증 완료를 확정하지 않는다.

## 검증된 탭
- `00_프로젝트_허브`
- `01_작업순서`
- `02_현재_확정결정`
- `03_근거_라이브러리`
- `04_누락_충돌_감사`
- `05_GDD_요약`
- `10_제품방향`
- `11_세계관`
- `12_핵심루프`
- `13_주요인물`
- `14_조연_세력_관계`
- `15_조작_게임규칙`
- `20_코어경험_데모목표`
- `30_데모범위_품질기준_제작기반`
- `40_핵심시스템_메인콘텐츠`
- `41_성장_경제`
- `50_메인콘텐츠`
- `60_UX_UI_접근성`
- `70_아트_오디오_에셋`
- `71_이미지기획_생성목록`
- `72_이미지검수_승인로그`
- `80_데모_버티컬슬라이스_플레이테스트`
- `90_본제작_출시_사업`
- `98_Base_반영후보`
- `99_변경이력`

## 프로젝트 책임 매핑

| 의미 구조 | 프로젝트 책임 원본 |
|---|---|
| 세계관·세력·무공 | v6 결정 원장과 등록된 기획 문서 |
| 핵심루프 | `docs/00_GAME_PILLARS.md`, 전투·진행 책임 원본 |
| 주요인물·조연 | 캐릭터·결투·세력 책임 원본 |
| 핵심시스템·메인콘텐츠 | 전장 10칸, 3/3/4 계획, 카드·거리·합, 주요 비무 |
| 이미지 계획·검수 | `docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md` |

GitHub에 없는 사용자 수정은 자동 덮어쓰지 않고 `PROPOSED_SHEET_CHANGE`로 비교·승인한 뒤 양쪽을 재조회한다.
