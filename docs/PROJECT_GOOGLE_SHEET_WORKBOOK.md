# 십보강호 프로젝트 Google Sheets Workbook — Migration Compatibility

```yaml
project: Ten-Paces-Hidden-Moves
sheet_status: MIGRATION_ONLY_UNTIL_REMOVAL
spreadsheet_url: https://docs.google.com/spreadsheets/d/1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0/edit
spreadsheet_id: 1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0
workbook_role: LEGACY_MIGRATION_COMPATIBILITY_SOURCE
sheet_edit_policy: NO_NEW_CANON_INPUT
current_authority: false
last_verified_legacy_structure_at: 2026-07-29
```

이 workbook은 과거 사용자-facing GDD 작업면이었지만, 현재 신규 기획·승인·상태 관리의 기본 작업공간이 아니다.

현재 authority는 다음과 같다.

```text
latest user decision
→ exact Project Notion for human-facing planning / Flow / Visual / editable overview
→ GitHub repository + actual runtime for structured canon / implementation / tests / runtime truth
→ this legacy Google Sheet only when unique unmigrated material must be reconciled
```

Sheet의 수정 시각이 더 최신이라는 이유만으로 current Project Notion, 승인 Decision, repository runtime truth를 덮어쓰지 않는다.

## Migration locator로 보존하는 과거 탭

다음 이름은 **기존 자료를 찾기 위한 locator**다. current 권위를 뜻하지 않는다.

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

## Migration 처리 규칙

legacy material은 한 번만 다음으로 분류한다.

```text
UNIQUE
→ 올바른 Notion human-facing owner 또는 repository structured/runtime owner로 이동
→ provenance 보존
→ destination readback
→ MIGRATED_READBACK_VERIFIED

DUPLICATE
→ current owner와 중복임을 확인
→ active input에서 제외

OBSOLETE
→ 대체된 역사 자료로 분류
→ active input에서 제외
```

`UNIQUE` 여부를 검증하지 않은 자료를 일괄 복사하지 않는다. Sheet-only 변경은 `PROPOSED_SHEET_CHANGE`에 해당하는 과거 compatibility signal일 수 있지만 자동 승인/정본 승격 권한은 없다.

## 사람용/구현 owner 매핑

| 질문 | 현재 destination |
|---|---|
| 프로젝트 전체 그림·Flow·세계관·핵심 시스템 설명 | exact Project Notion |
| Visual·Reference·Asset human-facing 관리 | exact Project Notion의 해당 Project relation/view |
| Decision·Markdown·planning JSON | GitHub repository |
| game data·code·Scene·Resource·tests·runtime evidence | GitHub repository / actual runtime |
| 과거 Sheet에만 남은 고유 자료 | 위 owner로 migration 후 readback |

## 제거 조건

Sheet를 자동 삭제하지 않는다. 다음을 모두 만족할 때 별도 removal 판단이 가능하다.

1. 고유 자료가 `UNIQUE / DUPLICATE / OBSOLETE`로 분류됐다.
2. 모든 `UNIQUE` 자료의 destination이 명확하다.
3. migration destination readback이 성공했다.
4. active consumer/reference가 0이다.
5. 필요한 최소 provenance가 다른 current/historical owner에 보존됐다.

그 전까지 workbook은 `MIGRATION_ONLY_UNTIL_REMOVAL`로 읽기 가능한 compatibility source로 남는다.
