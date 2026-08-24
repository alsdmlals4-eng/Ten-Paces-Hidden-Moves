> # 십보강호: 숨은 수의 비무
## Ten Paces: Hidden Moves

상대의 공개 단서와 해결 이력을 읽어 가설을 세우고, 여러 수의 계획으로 의도를 무너뜨리는 **1대1 무협 전술 로그라이트**입니다.

> 보이지 않는 상대의 수를 읽고, 준비한 계획으로 꺾는다.

## 시작

- [작업 시작](START_HERE.md)
- [현재 상태]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)
- [문서 지도]([기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md)
- [현행 통합 작업계약](docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md)
- [게임 기획](docs/01_GAME_DESIGN.md)
- [전투 규칙](docs/02_COMBAT_RULES.md)
- [콘텐츠 카탈로그](docs/03_CONTENT_CATALOG.md)
- [로드맵](docs/04_ROADMAP.md)
- [테스트 체크리스트](docs/08_TEST_CHECKLIST.md)

## 현재 상태 읽는 법

활성 PR·exact SHA·현재 Work Mode·제품 단계·다음 package/Decision·device/Human evidence는 README에 복제하지 않습니다.

```text
ACTIVE_CONTEXT.md
+ current planning JSON
+ GitHub live metadata
+ exact Project Notion
→ current state
```

사람용 Project Home·Flow·Visual·핵심 표는 `NOTION_DEFAULT_PROJECT_WORKSPACE`, Markdown/JSON·코드·Scene·Resource·Test·runtime evidence는 repository가 소유합니다. Google Sheets는 `MIGRATION_ONLY_UNTIL_REMOVAL` compatibility source입니다.

## 프로젝트 코어와 핵심 재미

```text
공개 상태·해결 이력 읽기
→ 가능한 행동 가설 세우기
→ 여러 가능성을 견디는 3/3/4 비공개 계획
→ 거리·현재 순번 합·대응·중단으로 해결
→ 결정적 원인을 복기
→ 다음 계획과 경로 선택 변경
```

- 1대1 10칸 일자형 전장입니다.
- 현재 런타임의 역사 구현 계보에는 **플레이어 4번·상대 7번** 시작이 존재하지만, 플레이어-facing 설계의 기준은 시작 공개 거리 2이며 정확한 current binding은 전투 정본과 실제 runtime을 함께 읽습니다.
- 거리 0은 `[밀착]`입니다.
- 한 라운드는 `3수 → 3수 → 4수`, 각 묶음 뒤 해결하며 총 10수입니다.
- `[합]`, 순차 연격, 방어도, 회피, 중단, 강건을 사용합니다.
- AI는 플레이어의 미확정 계획을 읽지 않습니다.
- 덱·손패·드로우·장착 기술 제한을 사용하지 않습니다.
- 무공서가 아니라 현재 해금 기술을 수에 배치합니다.
- 성장은 원시 수치로 판단을 대체하지 않고 더 다양한 파훼 수단을 제공합니다.

## 플랫폼 범위

- Windows와 Android를 기본 설계 대상으로 유지합니다.
- 전투 규칙·AI·콘텐츠·ID·수치·저장 Schema는 단일 공유 코어를 사용합니다.
- 플랫폼 차이는 입력, 반응형 UI·안전영역, 앱 생명주기·뒤로가기, 플랫폼 서비스, 품질·성능·export Adapter에 한정합니다.
- Android 실제 설치·실행·터치·뒤로가기·safe-area·pause/resume·저장·성능은 실제 evidence 전에는 완료로 주장하지 않습니다.

## Vertical Slice

첫 5전 Vertical Slice의 현재 구현/검증 상태는 [Active Context]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)가 단독 책임집니다. README는 mutable 완료 상태를 고정하지 않습니다.

사람이 이해할 전체 흐름과 Visual/UX는 Notion Project Home에서 보고, 구현 사실은 repository/runtime evidence에서 검증합니다.

## 역사·호환 기준

- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 계보입니다.
- PR #45와 v6 Decision 원장은 재설계·승인 이력입니다.
- PR #65는 ActionSelectionDock/화면 구조 구현 이력입니다.
- PR #92는 초기 10권 무공 런타임·UI/AI·자동 제품 검증 이력입니다.
- 과거 Base 기준 `c987647d01ad2baa028a16e03d85ddfc1572a727`은 `HISTORICAL_COMPATIBILITY_BASELINE`입니다.
- 과거 Base v9.4.3 pin은 프로젝트 채택/회귀 증거이며 current Base remote truth가 아닙니다.
- `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`은 역사 계약이고 현행 project operating contract는 v4.8 r2입니다.

정적 검사·Actions 성공은 Windows 실제 Godot, 실물 게임패드, Android 실제 기기, 접근성 보조기술, 성능, 실제 플레이 재미를 증명하지 않습니다. 실행하지 않은 항목은 `NOT_RUN`입니다.
