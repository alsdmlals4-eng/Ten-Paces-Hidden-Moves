# 십보강호 문서 지도

## 기본 읽기

```text
AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
→ docs/decisions/2026-07-31_COMBAT_ROUTE_AND_CHAMPION_DECISION.md
→ docs/decisions/2026-07-31_PROCEDURAL_DUEL_POOL_AND_ROUTE_DECISION.md
→ 질문별 책임 원본
→ 실제 코드·데이터·테스트·PR
```

- Base 적용 기준: `docs/BASE_RULES_VERSION.md`.
- Skill Registry: `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`.

## 질문별 책임 원본

| 질문 | 현재 책임 원본 | 과거·보조 자료 |
|---|---|---|
| 현재 단계·권한·보류·다음 작업 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` | PR #45 본문·과거 Active Context |
| 전체 사용자 결정·대체·폐기·보류 | `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md` + 최신 날짜별 승인 결정 | 2026-07-25/26 기준선·결정 기록 |
| 2026-07-31 전투·노드 수·전체 회차·천하제일인 결정 | `docs/decisions/2026-07-31_COMBAT_ROUTE_AND_CHAMPION_DECISION.md` | `approved_20260731_combat_route_contract.json` |
| 절차형 주요 비무 후보 3명·경로 생성·선정 규칙 | `docs/decisions/2026-07-31_PROCEDURAL_DUEL_POOL_AND_ROUTE_DECISION.md` | `approved_20260731_procedural_duel_pool_route_contract.json` |
| 절차형 비무·경로 설계 명세 | `docs/superpowers/specs/2026-07-31-procedural-duel-pool-route-design.md` | 슬롯 1·2 후보와 생성 안전장치 |
| 상황별 필수 화면 4종·P0 플레이 상태·Godot Scene/Node/State 구현 명세 | `docs/superpowers/specs/2026-07-31-situation-screen-implementation-spec.md` | `draft_20260731_situation_screen_contract.json`; `DESIGN_DRAFT_USER_REVIEW_PENDING` |
| 주요 비무 1·2전 고정형 상세 초안 | `docs/planning/2026-07-31_DUEL_01_02_ROUTE_PACKAGE_DRAFT.md` | 후보 원형·고정 경로 역사 자료; 최신 절차형 결정이 우선 |
| PR #45 통합 판정·중복 제거 | `docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md` | PR #45 changed files·과거 검수 보고서 |
| 프로젝트 코어·플레이어 약속 | `docs/01_GAME_DESIGN.md` | v6 원장 `CORE-*`·과거 코어 결정 기록 |
| 전투·능력치 비례·슬롯·합·연격·방어도·중단 | `docs/02_COMBAT_RULES.md` | v6 원장·현행 PoC 코드 |
| 적 의도 단서·가설·해결 후 인과 Pilot | `docs/decisions/2026-07-29_ENEMY_INTENT_EVIDENCE_PACK_PILOT.md` | v6 원장·실제 사람 플레이테스트; `PLANNING_INPUT / NOT_CANON` |
| 적 의도 단서 사람 검증 Artifact | `docs/superpowers/plans/2026-07-29-enemy-intent-human-validation-artifact.md` | 기존 A2/A3 PoC·가설/복기 UI; `HUMAN_VALIDATION_INPUT / NOT_CANON` |
| 합성 테스터 적용 Skill·작업 구조 | `docs/research/2026-07-29_SYNTHETIC_TESTER_STRUCTURE_ANALYSIS.md` | Registry·Active Context·프로젝트 Skill; `T6_AI_INFERENCE / NOT_CANON` |
| 적 의도 단서 합성 위험 검토 | `docs/research/2026-07-29_ENEMY_INTENT_SYNTHETIC_TESTER_REPORT.md` | 사람 검증 패킷·Evidence Pack; `AI_SIMULATION_COMPLETED / HUMAN_NOT_RUN` |
| 강호행로·데모 8노드·전체 18노드·콘텐츠 범위 | `docs/03_CONTENT_CATALOG.md` + 2026-07-31 결정 | 과거 `poc_map_rewards.json` 범위 가설 |
| PoC 5전·4구간·노드 8개 검증 | `docs/05_COMBAT_POC_SPEC.md` | planning JSON·현행 T0 |
| 무공서·성급·수련·랭크·절초 공통 계약 | v6 원장 `MARTIAL/GLOBAL/ROSTER/POOL/BAN/OFFER/TRAIN/RANK/ULT-*` | `docs/06_STARTING_FACTION_MASTERY_DATA.md`·과거 PoC 무공 JSON |
| UI·접근성 | `docs/07_COMBAT_UI_SPEC.md` + `docs/UX_UI_SYSTEM.md` | 실제 씬·사람 검증 |
| 구현 사실 | 실제 `data/`, `src/`, `scenes/`, `tests/`, `project.godot` | 문서의 구현 주장 |

`docs/01`, `02`, `03`, `05`는 2026-07-31 승인 전투 결정에 맞춰 갱신했다. 고정형 연교→묵진 패키지는 후보 원형으로 유지하되, 상대·노드·연결을 고정한 표현은 최신 절차형 결정이 대체한다. 상황별 화면 명세는 사용자 검토용 설계 초안이며 승인 결정·구현 권한을 갖지 않는다. 충돌할 때는 가장 최근 날짜의 승인 결정 문서가 우선한다.

## PR #45 중복 방지

- `2026-07-26_POC_PLANNING_BASELINE.md`와 `2026-07-26_REVIEW_COMPLETE_AND_BUILD_ENTRY.md`는 역사 포인터이며 최신 규칙을 소유하지 않는다.
- 과거 적대적 검토·벤치마크·sanity 문서는 변경 당시의 증거를 보존한다.
- 과거 `docs/planning-data/*.json`은 source-only 분석 자료이며 런타임 입력이 아니다.
- `docs/planning-data/approved_20260731_combat_route_contract.json`은 전투·회차 승인 기획의 구조화 포인터다.
- `docs/planning-data/approved_20260731_procedural_duel_pool_route_contract.json`은 절차형 상대·경로 승인 기획의 구조화 포인터다.
- `docs/planning-data/draft_20260731_duel_01_02_route_package.json`은 고정형 후보 원형 자료이며 런타임 입력 권한이 없다.
- `docs/planning-data/draft_20260731_situation_screen_contract.json`은 상황별 화면 구현 명세의 구조화된 검토 입력이며 런타임 입력 권한이 없다.
- 2026-07-26 구현 계획은 새 BUILD 승인 전 실행하지 않는다.
- 같은 질문에 여러 활성 정본을 두지 않는다.

## 상태 분리

- 제품 단계: `CONCEPT_APPROVAL`
- Work Mode: `PLAN`
- 실행 프로필: `PLANNING_ONLY_PROFILE`
- 합성 검토: `AI_SIMULATION_COMPLETED / T6_AI_INFERENCE`
- 절차형 비무 후보·경로 구조: `APPROVED_PLANNING`
- 상황별 화면 구현 명세: `DESIGN_DRAFT_USER_REVIEW_PENDING`
- 슬롯 1·2 정확 수치·전용 무공: `PLANNED / BALANCE_PENDING`
- 사람 검증: `NOT_RUN`
- 후속 적대적 검토: `HOLD / [보류]`
- 절초 16종 개별 설계: `DEFERRED / [보류]`
- 주요 비무 6~10·천하제일인 구현: `HOLD`
- 런타임 구현: `PROHIBITED_UNTIL_NEW_APPROVAL`
