# 십보강호 문서 지도

## 기본 읽기

`AGENTS.md → ACTIVE_CONTEXT.md → 이 문서 → 질문별 책임 원본 → 실제 파일·테스트·PR·Issue`.

## 질문별 책임 원본

| 질문 | 책임 원본 |
|---|---|
| 프로젝트 코어·루프 | `docs/01_GAME_DESIGN.md` |
| 전투 판정·연격·필중·예산·재도전 | `docs/02_COMBAT_RULES.md` |
| 콘텐츠·적·주요 비무·지도·보상 | `docs/03_CONTENT_CATALOG.md`와 `docs/planning-data/` |
| 제품 순서 | `docs/04_ROADMAP.md` |
| PoC·T1 | `docs/05_COMBAT_POC_SPEC.md` |
| 무공·성장·의료 | `docs/06_STARTING_FACTION_MASTERY_DATA.md` |
| UI·접근성 | `docs/07_COMBAT_UI_SPEC.md` |
| QA | `docs/08_TEST_CHECKLIST.md` |
| RunState·CombatState·adapter | `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` |
| 연출 | `docs/10_COMBAT_PRESENTATION_PLAN.md` |
| 현재 상태 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` |
| Skill 라우팅 | `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json` |
| 통합 PoC 기준선 | `docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md` |
| REVIEW 발견·교정 | `docs/decisions/2026-07-26_REVIEW_FINDINGS_AND_CORRECTIONS.md` |
| 전체 적대적 검토 | `docs/decisions/2026-07-26_FULL_ADVERSARIAL_REVIEW_LOOP.md` |
| 승인안 BUILD 교정 | `docs/decisions/2026-07-26_ADVERSARIAL_REVIEW_BUILD_REMEDIATION.md` |
| 수치 sanity | `docs/decisions/2026-07-26_POC_BALANCE_SANITY_REPORT.md` |
| 세션 인수 | `[기획서]/00_프로젝트_허브/HANDOFF.md` |

## planning 데이터

- `poc_balance_budget.json`: 가격표·effect·patch·필중 스택.
- `poc_martial_arts.json`: 무공·card·ledger·습득·중복.
- `poc_enemy_duels.json`: 주요 비무·보상 option 참조·AI template.
- `poc_map_rewards.json`: 노드·보상·등급·38포인트 경로.
- `poc_run_state_contract.json`: 회차/전투 상태와 유료 재도전.
- `poc_sanity_model.json`: 분석 전용 가설.

## 실제 구현 경로

`data/`, `src/`, `scenes/`, `assets/`, `addons/`, `tests/`, `tools/`, `project.godot`.

## 경계

PoC planning JSON은 source-only 지원 데이터이며 런타임 권한이 없다. 구현·자동·Godot·Windows·사람 검증 상태를 독립 기록한다. 결정·검수 기록은 변경 이유와 대체 관계를 보존하고, 현재 판정은 질문별 책임 원본이 소유한다.
