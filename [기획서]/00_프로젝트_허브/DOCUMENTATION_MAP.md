# 십보강호 문서 지도

## 기본 읽기

```text
AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
→ 질문별 책임 원본
→ 실제 코드·데이터·테스트·PR
```

- Base 적용 기준: `docs/BASE_RULES_VERSION.md`.
- Skill Registry: `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`.

## 질문별 책임 원본

| 질문 | 현재 책임 원본 | 과거·보조 자료 |
|---|---|---|
| 현재 단계·권한·보류·다음 작업 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` | PR #45 본문·과거 Active Context |
| 전체 사용자 결정·대체·폐기·보류 | `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md` | 2026-07-25/26 기준선·결정 기록 |
| PR #45 통합 판정·중복 제거 | `docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md` | PR #45 changed files·과거 검수 보고서 |
| 프로젝트 코어·플레이어 약속 | v6 원장 `CORE-*` | `docs/01_GAME_DESIGN.md`·과거 코어 결정 기록 |
| 전투·슬롯·합·연격·방어도·태그 | v6 원장 `COMBAT/BOARD/SLOT/COST/STACK/AUTO/TAG/DEF-*` | `docs/02_COMBAT_RULES.md`·현행 PoC 코드 |
| 적 의도 단서·가설·해결 후 인과 Pilot | `docs/decisions/2026-07-29_ENEMY_INTENT_EVIDENCE_PACK_PILOT.md` | v6 원장·실제 사람 플레이테스트; `PLANNING_INPUT / NOT_CANON` |
| 적 의도 단서 사람 검증 Artifact | `docs/superpowers/plans/2026-07-29-enemy-intent-human-validation-artifact.md` | 기존 A2/A3 PoC·가설/복기 UI; `HUMAN_VALIDATION_INPUT / NOT_CANON` |
| 합성 테스터 적용 Skill·작업 구조 | `docs/research/2026-07-29_SYNTHETIC_TESTER_STRUCTURE_ANALYSIS.md` | Registry·Active Context·프로젝트 Skill; `T6_AI_INFERENCE / NOT_CANON` |
| 적 의도 단서 합성 위험 검토 | `docs/research/2026-07-29_ENEMY_INTENT_SYNTHETIC_TESTER_REPORT.md` | 사람 검증 패킷·Evidence Pack; `AI_SIMULATION_COMPLETED / HUMAN_NOT_RUN` |
| 강호행·경로·콘텐츠 범위 | v6 원장 `RUN-*` | `docs/03_CONTENT_CATALOG.md`·`docs/planning-data/` source-only |
| 무공서·성급·수련·랭크·절초 공통 계약 | v6 원장 `MARTIAL/GLOBAL/ROSTER/POOL/BAN/OFFER/TRAIN/RANK/ULT-*` | `docs/06_STARTING_FACTION_MASTERY_DATA.md`·과거 PoC 무공 JSON |
| UI·접근성 | `docs/07_COMBAT_UI_SPEC.md` | 실제 씬·사람 검증 |
| 구현 사실 | 실제 `data/`, `src/`, `scenes/`, `tests/` | 문서의 구현 주장 |

`docs/01`, `02`, `03`, `06`은 이번 통합 시점의 현행 구현·과거 기획 설명을 보존한다. 최신 v6 설계와 충돌할 때 결정 원장이 우선하며, 후속 통합 명세 작성 시 원장의 영향 책임 원본으로 갱신한다.

## PR #45 중복 방지

- `2026-07-26_POC_PLANNING_BASELINE.md`와 `2026-07-26_REVIEW_COMPLETE_AND_BUILD_ENTRY.md`는 역사 포인터이며 최신 규칙을 소유하지 않는다.
- 과거 적대적 검토·벤치마크·sanity 문서는 변경 당시의 증거를 보존한다.
- `docs/planning-data/*.json`은 source-only 분석 자료이며 런타임 입력이 아니다.
- 2026-07-26 구현 계획은 새 BUILD 승인 전 실행하지 않는다.
- 같은 질문에 여러 활성 정본을 두지 않는다.

## 상태 분리

- 제품 단계: `CONCEPT_APPROVAL`
- Work Mode: `PLAN`
- 실행 프로필: `PLANNING_ONLY_PROFILE`
- 합성 검토: `AI_SIMULATION_COMPLETED / T6_AI_INFERENCE`
- 사람 검증: `NOT_RUN`
- 후속 적대적 검토: `HOLD / [보류]`
- 절초 16종 개별 설계: `DEFERRED / [보류]`
- 런타임 구현: `PROHIBITED_UNTIL_NEW_APPROVAL`
