# 십보강호 제품 문서 지도

> 최상위 운영·스킬·게이트 지도는 [`[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`](../%5B기획서%5D/00_%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8_%ED%97%88%EB%B8%8C/DOCUMENTATION_MAP.md)가 책임진다. 이 문서는 `docs` 제품 본책의 읽기 순서와 책임 경계를 정의한다.

## 1. 최초 진입

```text
../START_HERE.md
→ ../AGENTS.md
→ ../[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ 00_TAG_STATUS_REGISTRY.md
→ 01_GAME_DESIGN.md
→ 질문별 책임 원본
→ 실제 data/scenes/src/tests/PR
```

- `docs/[백업]/`과 과거 Decision Ledger는 역사 자료이며 기본 수정 대상이 아니다.
- 활성 문서가 최신 Decision과 충돌하면 최신 사용자 승인 Decision이 우선한다.
- planning JSON은 정적 계약이며 런타임이 직접 읽지 않는다.

## 2. 제품 문서 읽기 순서

1. [태그·상태 등록부](00_TAG_STATUS_REGISTRY.md) — 제품 태그, 전투 키워드, 권위·범위·구현·검증 상태.
2. [게임 기획서](01_GAME_DESIGN.md) — 정체성, 핵심 루프, 데모·정식 회차·후속 콘텐츠.
3. [전투 규칙](02_COMBAT_RULES.md) — 10칸·3/3/4·관찰·합·방어·회피·중단·결착.
4. [콘텐츠 카탈로그](03_CONTENT_CATALOG.md) — POC_PRIMARY·후반·천하제일인·챔피언 배틀·HOLD.
5. [제품 로드맵](04_ROADMAP.md) — 완료 기준선, App Flow Shell, T1·온라인·모바일 Gate.
6. [전투 PoC 명세](05_COMBAT_POC_SPEC.md) — 첫 데모 목적·범위·성공·실패 기준.
7. [무공·성장 데이터](06_STARTING_FACTION_MASTERY_DATA.md) — 1~10성, 기술·절초, 스테이터스 성장.
8. [전투 UI 명세](07_COMBAT_UI_SPEC.md) — HUD·행동 선택·입력·접근성.
9. [테스트 체크리스트](08_TEST_CHECKLIST.md) — 정적·자동·Godot·Windows·접근성·사람 증거.
10. [시스템 아키텍처](09_COMBAT_SYSTEM_ARCHITECTURE.md) — 도메인 상태·이벤트·저장·AI 경계.
11. [전투 연출](10_COMBAT_PRESENTATION_PLAN.md) — 구조화 사건 재생·VFX·SFX·폴백.
12. [Base 채택 기록](11_BASE_ADOPTION_AND_LEARNING_LOG.md) — Base 구체화·제안·검증 경계.

## 3. 작업별 최소 읽기

| 작업 | 최소 문서·스킬 |
|---|---|
| 현재 방향·인수 | Active Context, 00, 01, 04, 이 문서 |
| 전투 규칙·밸런스 | 00, 01, 02, 05, 08, 09, `ten-paces-game-design` |
| 무공·성장 | 00, 02, 03, 05, 06, 08 |
| 콘텐츠·경로 | 00, 01, 03, 04, 05, planning JSON |
| UI·접근성 | 00, 02, 07, 08, 09, 10, 실제 Scene |
| App Flow 구현 | Active Context, 04, 05, 08, 09, 상황 화면 Decision, 실제 파일 |
| 천하제일인·챔피언 | 00, 01, 03, 04, 최신 2개 Champion Decision |
| 검수 | 00, 08, 관련 본책, 실제 실행·렌더·CI |
| Base 업데이트 | BASE_RULES_VERSION, 11, Adapter, 최신 Base 원본 |

## 4. 책임 경계

| 질문 | 책임 원본 |
|---|---|
| 태그·상태 이름 | `00_TAG_STATUS_REGISTRY.md` |
| 전체 경험·제품 범위 | `01_GAME_DESIGN.md` |
| 전투 판정·행동 종류 | `02_COMBAT_RULES.md` |
| 콘텐츠 목록·범위·HOLD | `03_CONTENT_CATALOG.md` |
| 구현·검증 순서 | `04_ROADMAP.md` |
| 데모 PoC 계약 | `05_COMBAT_POC_SPEC.md` |
| 무공·스테이터스·성장 | `06_STARTING_FACTION_MASTERY_DATA.md` |
| UI·카드·HUD | `07_COMBAT_UI_SPEC.md` |
| 관찰 가능한 완료 증거 | `08_TEST_CHECKLIST.md` |
| 도메인·데이터·저장·AI | `09_COMBAT_SYSTEM_ARCHITECTURE.md` |
| 연출·오디오·접근성 폴백 | `10_COMBAT_PRESENTATION_PLAN.md` |
| 현재 작업·위험 | 허브 `ACTIVE_CONTEXT.md` |

UI·연출 문서는 규칙을 재계산하지 않는다. 임시 목업 수치는 전투·성장 기준을 변경하지 않는다.

## 5. 최신 Decision 우선순위

현재 활성 계획에서 반드시 읽을 Decision:

- `2026-08-02_PLATFORM_SCOPE_DECISION.md`
- `2026-08-02_OBSERVATION_STATS_MASTERY_DECISION.md`
- `2026-08-02_FULL_RUN_CHAMPION_RANKED_DECISION.md`
- `2026-08-02_RANKED_OBSERVATION_CONVERSION_DECISION.md`

이들은 다음 구형 표현보다 우선한다.

- 범용 공격력·방어력 중심 신규 성장.
- 공개 성향·대표 위협·정답 파훼법 자동 공개.
- 소모되는 방어도.
- 미래 묶음 선잠금.
- 10성 진의 선택.
- 천하제일인 후보6명 고정·사전 예고·첫 후보 자동 배정.
- 챔피언 배틀 HOLD 또는 관찰 의존 효과 미결정.

## 6. 고정 제품 계약

- 1대1 10칸, 시작 4/7, 거리 0 `[밀착]`.
- `3수 → 3수 → 4수` 비공개 계획.
- 적 현재 묶음 계획 잠금→관찰 종류 공개→플레이어 계획.
- 외공·근골·신법·내공·심안.
- 순차 피해 단위 `[합]`, 비소모 방어도, 횟수형 회피, 중단·`[강건]`.
- 데모 주요 비무5슬롯×후보3명, 중간 노드8개.
- 정식 주요 비무10슬롯×후보3명, 중간 노드18개, 이후 천하제일인전.
- 챔피언 배틀은 `FUTURE_ONLINE`, 구현은 별도 승인 전 `BLOCKED_NOT_AUTHORIZED`.
- 현재 플랫폼은 PC, 모바일은 후속 고려.

## 7. 현재 다음 제품 작업

`VERTICAL_SLICE_APP_FLOW_SHELL` 구현 Packet 정밀화:

1. App Root·Scene·화면 상태.
2. `RunSession`·`SaveService`.
3. 시작 무공 6중4.
4. Route·Node·Briefing.
5. Combat 진입·복귀.
6. Result·Reward·Retry transaction.
7. 자동·Godot·Windows·접근성·성능·사람 검증.

## 8. 갱신 규칙

- 새 태그는 00 등록부에서 기존 의미와 충돌 여부를 먼저 확인한다.
- 규칙을 바꾸는 새 태그는 GrillMe 승인 Decision이 필요하다.
- 단순 명칭 정규화·구형 참조 제거는 유지보수로 처리한다.
- 책임 원본·경로가 바뀌면 Design Registry와 두 문서 지도를 함께 갱신한다.
- 활성 `v2`, `final`, `latest` 복제본을 만들지 않는다.
- 이전 내용은 Git 이력으로 보존한다.
- 체크리스트와 실제 테스트, CI와 런타임, 자동과 사람 검증을 분리한다.
