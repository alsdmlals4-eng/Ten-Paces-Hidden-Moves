# 십보강호 제품 문서 지도

> 최상위 운영·스킬·게이트 지도는 [`[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`](../%5B기획서%5D/00_프로젝트_허브/DOCUMENTATION_MAP.md)가 책임진다. 이 문서는 기존 `docs` 제품 본책의 상세 읽기 순서와 책임 경계를 유지한다.

## 최초 진입

```text
../START_HERE.md
→ ../AGENTS.md
→ ../[기획서]/00_프로젝트_허브/START_HERE.md
→ 허브 ACTIVE_CONTEXT·DEVELOPMENT_GATES
→ ../[기획서]/DESIGN_DOCUMENT_REGISTRY.json
→ 현재 제품 책임 원본
```

- 기존 `docs/[백업]/`은 과거 기록이며 기본 읽기·수정 대상에서 제외한다.
- `docs/[보류]/`는 사용자가 재개하기 전까지 구현 대상에서 제외한다.
- 기존 `docs/01~11`은 schema v3 Markdown 단일 책임 원본으로 Registry에 등록돼 있다.
- 제품 본책의 PDF·Manifest는 실제 생성·렌더·검수 전까지 `MIGRATION_PENDING`이다.

## 제품 문서 읽기 순서

1. [Base 규칙 적용 버전](BASE_RULES_VERSION.md) — 적용 Base 커밋과 프로젝트 구체화 경계.
2. [제품 활성 컨텍스트](ACTIVE_CONTEXT.md) — 승인 제품 방향·미확정·다음 제품 작업.
3. [게임 기획서](01_GAME_DESIGN.md) — 5전 데모, 10전 전체 구조, 플레이어 경험과 성장.
4. [전투 규칙](02_COMBAT_RULES.md) — 10타이밍, 2수 잠금, 합, 거리와 자원.
5. [전투 시스템 아키텍처](09_COMBAT_SYSTEM_ARCHITECTURE.md) — 공용 수정자, 상대 생성, 저장과 Godot 구현 경계.
6. [대회 세로 슬라이스 명세](05_COMBAT_POC_SPEC.md) — 구현 범위, 성과·행운·상대 성장과 완료 기준.
7. [전투·대회 연출 기획서](10_COMBAT_PRESENTATION_PLAN.md) — 상대 정보, 제약, 2수 공개·해상, 합, 성장, 데모 결말과 폴백.
8. [핵심무공·심법 데이터](06_STARTING_FACTION_MASTERY_DATA.md) — 1~10성, 절초·진의, 문파 기믹.
9. [콘텐츠 카탈로그](03_CONTENT_CATALOG.md) — 문파 전용·공용 무공 목록과 보류 경계.
10. [전투 UI·아트 명세](07_COMBAT_UI_SPEC.md) — 2수 선택 UI, 카드, HUD, 행운 결과와 무림식 상대 정보.
11. [테스트 체크리스트](08_TEST_CHECKLIST.md) — 합·AI 잠금·수련·행운·상대 생성·연출·5전·10전 검증.
12. [제품 로드맵](04_ROADMAP.md) — 데모 우선 단계, 남은 설계·구현·검증과 전체판 확장 기준.
13. [구현 Plan](../plans/2026-07-16-combat-poc-plan.md) — 실제 파일 감사 후의 Codex 구현 순서.
14. [기존 기획·인수인계 확장](skills/TEN_PACES_PLANNING_HANDOFF_EXTENSION.md) — v1.9.3 시점 프로젝트 적용 기록; 신규 작업은 Skill Registry 진입 스킬을 우선한다.
15. [Base 적용·학습 기록](11_BASE_ADOPTION_AND_LEARNING_LOG.md) — 채택·구체화·검증·Base 제안 경계.

## 작업별 최소 읽기

| 작업 | 최소 문서·스킬 |
|---|---|
| 현재 방향·인수 | 루트 START_HERE, AGENTS, 허브 Active Context·Handoff, 이 문서 |
| 전투 규칙·밸런스 | 01, 02, 05, 09, `ten-paces-game-design` |
| 절초 기세·상단 HUD | 제품 Active Context, 02, 04, 05, 06, 07, 08, 09, 10, `combat-ux-and-accessibility` |
| UI·카드·접근성 | 07, 10, 실제 화면·자산, UX 스킬 |
| 전투·대회 연출 | 10, 02, 07, 09, 실제 렌더 |
| 무공·문파 데이터 | 03, 06, 09, 게임 디자인 스킬 |
| 구현 | Gates, 02, 05, 09, 현재 Plan, 실제 파일·테스트, `combat-implementation-handoff` |
| 검수 | 08, 관련 본책, 실제 실행·렌더, `ten-paces-verification` |
| Base 업데이트 | BASE_RULES_VERSION, 11, 허브 Source Audit·Decision Log, 최신 Base 원본 |
| 문서 발행 | Design Registry, 생성기, Manifest, PDF 자동·사람 검수 |

## 제품 책임 경계

| 질문 | 책임 원본 |
|---|---|
| 전체 경험·범위 | `01_GAME_DESIGN.md` |
| 전투 판정 | `02_COMBAT_RULES.md` |
| 콘텐츠 목록·보류 | `03_CONTENT_CATALOG.md` |
| 제품 구현 순서 | `04_ROADMAP.md` |
| 데모·전체판 범위 | `05_COMBAT_POC_SPEC.md` |
| 무공·심법·성장 | `06_STARTING_FACTION_MASTERY_DATA.md` |
| UI·카드·HUD | `07_COMBAT_UI_SPEC.md` |
| 관찰 가능한 검증 | `08_TEST_CHECKLIST.md` |
| 도메인·데이터·저장 | `09_COMBAT_SYSTEM_ARCHITECTURE.md` |
| 시선·연출·접근성 폴백 | `10_COMBAT_PRESENTATION_PLAN.md` |
| Base 채택·교훈 | `11_BASE_ADOPTION_AND_LEARNING_LOG.md` |
| 현재 운영 상태·위험 | 허브 `ACTIVE_CONTEXT.md` |
| 문서·스킬·게이트 라우팅 | 허브 `DOCUMENTATION_MAP.md`·Registry |

UI와 연출 문서는 전문을 복사하지 않는다. 연출 시안의 임시 숫자는 전투·성장 기준을 변경하지 않는다.

## 절초 기세 책임 분리

- `02_COMBAT_RULES.md`: 획득·상한·소모·초기화 판정.
- `06_STARTING_FACTION_MASTERY_DATA.md`: 핵심무공 10성과 절초 해금.
- `07_COMBAT_UI_SPEC.md`: 상단 HUD 위치·정보·잠금·축적·발동 가능·예약·소모 상태.
- `09_COMBAT_SYSTEM_ARCHITECTURE.md`: 도메인 상태·구조화 이벤트·저장 경계.
- `10_COMBAT_PRESENTATION_PLAN.md`: 증가 이유 피드백·강조·VFX·오디오·접근성 폴백.
- `08_TEST_CHECKLIST.md`: 구현과 표현의 관찰 가능한 검증.

## 제품 고정 동기화 범위

- 전장 10칸, 라운드 행동 타이밍 10개, 전체 대회 10전.
- 데모 1~2전 내부전, 3~4전 예선, 5전 예선 결승.
- 8전 8강, 9전 준결승, 10전 결승.
- 행동 두 개 비공개 잠금·동시 공개·순차 해상.
- 유효한 쌍방 공격의 합 수치 비교와 차이 피해.
- 핵심무공 여러 개, 3·6·9성 기술, 10성 절초, 10성 최대 1개.
- 심법 최대 2개, 10성 진의, 10성 최대 1개.
- 수련 기본 5 + 등급 C1/B3/A5/S7 + 행운 0~3.
- 상대 A계열 60%·B계열 40%, 성장·표현 키 회차 생성 시 고정.
- 개발용 태그 대신 이명·풍문·전적·정탐.
- 프레젠테이션은 피해·보상·수련·저장을 결정하지 않음.
- 문파별 기믹 수행도 성과 평가는 `[보류]`.

## 현재 다음 제품 작업

1. 절초 해금·전투 발동의 이중 조건과 기세 규칙·HUD를 승인한다.
2. 승인 뒤 02, 05, 07, 08, 09, 10과 구현 Plan을 동기화한다.
3. 사용자 Windows 작업본에서 실제 Godot·데이터·테스트를 감사한다.
4. 나머지 성과 임계값·상대 출현표·문구 사전·수련 알고리즘·제약·자원 비용을 확정한다.

## 갱신 규칙

- 변경 후 허브 `DOCUMENT_UPDATE_MATRIX.md`를 확인한다.
- 책임 원본·경로가 바뀌면 Design Registry와 두 문서 지도를 갱신한다.
- 활성 `v2`, `final`, `latest`, 날짜별 복제본을 만들지 않는다.
- 이전 내용은 Git 이력으로 보존한다.
- Base 교훈은 자동 반영하지 않고 제안·사용자 승인·별도 구현 PR을 따른다.
- 체크리스트와 실제 테스트, Workflow와 Actions, PDF와 시각 검수를 구분한다.
