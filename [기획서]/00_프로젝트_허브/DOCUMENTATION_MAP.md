# 십보강호 문서 지도

## 기본 읽기

```text
AGENTS.md
→ skills/PROJECT_BASE_ADAPTER.json
→ skills/PROJECT_SKILL_SNAPSHOT.json
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
→ 질문별 책임 원본
→ 실제 코드·데이터·테스트·PR·Issue
```

- Base 적용 기준: `docs/BASE_RULES_VERSION.md`.
- 활성 실행 계약: Base v9.3의 `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v9.md`.
- 프로젝트 고유 Skill Registry: `skills/SKILL_REGISTRY.json`.
- `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`은 compatibility/history 참조다.

## 질문별 책임 원본

| 질문 | 현재 책임 원본 | 과거·보조 자료 |
|---|---|---|
| 현재 단계·권한·보류·다음 작업 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` | PR #45 본문·과거 Active Context |
| Base release·Skill route·보호 경로·Sheet 상태 | `skills/PROJECT_BASE_ADAPTER.json` | `skills/PROJECT_SKILL_SNAPSHOT.json`·Legacy adapters |
| 전체 사용자 결정·대체·폐기·보류 | `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md` | 2026-07-25/26 기준선·결정 기록 |
| 프로젝트 코어·플레이어 약속 | v6 원장 `CORE-*` | `docs/01_GAME_DESIGN.md`·과거 코어 결정 기록 |
| 전투·슬롯·합·연격·방어도·태그 | v6 원장 `COMBAT/BOARD/SLOT/COST/STACK/AUTO/TAG/DEF-*` | `docs/02_COMBAT_RULES.md`·현행 PoC 코드 |
| 적 의도 단서·가설·복기 | `docs/decisions/2026-07-29_ENEMY_INTENT_EVIDENCE_PACK_PILOT.md` | 실제 사람 플레이테스트; `PLANNING_INPUT / NOT_CANON` |
| 강호행·경로·콘텐츠 범위 | v6 원장 `RUN-*` | `docs/03_CONTENT_CATALOG.md`·`docs/planning-data/` source-only |
| 무공서·성급·수련·랭크·절초 | v6 원장 `MARTIAL/GLOBAL/ROSTER/POOL/BAN/OFFER/TRAIN/RANK/ULT-*` | `docs/06_STARTING_FACTION_MASTERY_DATA.md` |
| UI·접근성 | `docs/07_COMBAT_UI_SPEC.md` | 실제 씬·사람 검증 |
| 구현 사실 | 실제 `data/`, `src/`, `scenes/`, `tests/` | 문서의 구현 주장 |
| 10전·천하제일인 이후 챔피언 배틀 후보 | GitHub Issue #64 | 승인 후 제품 정본·Sheet에 전파; 현재 `PLANNING_ONLY` |

`docs/01`, `02`, `03`, `06`은 현행 구현·과거 기획 설명을 보존한다. 최신 v6 설계와 충돌할 때 결정 원장이 우선하며, 새 제품 결정은 승인 후 해당 책임 원본에 전파한다.

## 운영체계 이관 경계

- Issue #63은 Base v9.3 Adapter·Snapshot·Router·활성 진입 문서만 이관한다.
- `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`은 보호한다.
- v8·v9.1 자료는 삭제하지 않고 `SUPERSEDED_COMPATIBILITY / HISTORY_ONLY`로 보존한다.
- Sheet는 이관 PR 병합 후 새 `main` SHA를 재조회하기 전까지 쓰지 않는다.

## 중복 방지

- `2026-07-26_POC_PLANNING_BASELINE.md`와 `2026-07-26_REVIEW_COMPLETE_AND_BUILD_ENTRY.md`는 역사 포인터이며 최신 규칙을 소유하지 않는다.
- 과거 적대적 검토·벤치마크·sanity 문서는 변경 당시의 증거를 보존한다.
- `docs/planning-data/*.json`은 source-only 분석 자료이며 런타임 입력이 아니다.
- 같은 질문에 여러 활성 정본을 두지 않는다.

## 상태 분리

- 제품 단계: `CONCEPT_APPROVAL`.
- Work Mode: `PLAN`.
- 실행 프로필: `PLANNING_ONLY_PROFILE`.
- Base 운영 계약: `v9.3.0 / Vertical Slice v9`.
- 사람 검증: `NOT_RUN`.
- 절초 16종 개별 설계: `DEFERRED / [보류]`.
- 런타임 구현: `PROHIBITED_UNTIL_NEW_APPROVAL`.
- 서버·모바일 구현: `DEFERRED / SEPARATE_GATE`.
