# 십보강호 v4.8 Current Authority Migration Design

## 상태

```yaml
design_status: USER_APPROVED
approval_source: "user explicit: 권장안대로 진행해"
baseline_main: b35112592e608cd974411bafe07ef5e37ab866b2
scope: PROJECT_OPERATING_AUTHORITY_ONLY
runtime_mutation: FORBIDDEN
```

## 문제

십보강호의 실제 제품 상태와 Notion 사람용 정본은 첫 5전 Vertical Slice Phase I–VI 병합 상태를 반영하지만, 일부 GitHub cold-start/운영 계약은 과거 v4.5 r2 및 Google Sheets `USER_FACING_GDD_WORKSPACE` 시대의 current authority를 계속 강제한다. 해당 표현을 회귀 테스트도 보호하고 있어 단순 문서 수정은 재퇴행 위험이 있다.

## 목표

1. `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`를 프로젝트 전용 v4.8 r2 thin adapter current authority로 승격한다.
2. v4.5 r2 원문·Decision·JSON·normative parts는 역사/감사 증거로 보존한다.
3. 신규 기획/승인/사람용 전체 그림은 Notion, 구조화 정본/런타임 사실은 repository, Google Sheets는 `MIGRATION_ONLY_UNTIL_REMOVAL`로 정렬한다.
4. stable cold-start 문서에서 PR 번호·SHA·mutable stage/package를 current truth처럼 복제하지 않는다.
5. 기존 tests/config가 구형 authority를 다시 강제하지 못하게 RED→GREEN으로 교정한다.
6. `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`은 변경하지 않는다.

## 권장 구조

```text
latest user instruction
→ project AGENTS / security / engine rules
→ v4.8 project thin adapter
→ ACTIVE_CONTEXT + current planning JSON + GitHub live metadata + exact Project Notion
→ domain Decision / canonical owner
→ actual code/data/scene/test/runtime
→ adopted Base pin + latest Base owner when progressive-load is required
```

### Domain split

```text
Notion
→ human-facing Project Home / Flow / Visual / editable project overview

Repository
→ Markdown / JSON / game data / code / Scene / Resource / tests / runtime truth

Google Sheets
→ MIGRATION_ONLY_UNTIL_REMOVAL
→ unique unmigrated legacy material locator only
```

## v4.8 binding

새 current Decision:

`TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`

업로드된 v4.8 r2 source SHA-256:

`6f0541048e084746f6777223521361d0339dbfb2e223c70947f694f1c050f508`

프로젝트 canonical entrypoint는 Base 상세 playbook을 복제하지 않고 프로젝트 불변식·authority·delivery gate만 소유한다. 과거 v4.5 r2 body는 삭제하지 않는다.

## Current consumer 교정

Current/cold-start owner만 교정한다.

- `AGENTS.md`
- `START_HERE.md`
- `README.md`
- `docs/BASE_RULES_VERSION.md`
- `docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md`
- `[기획서]/00_프로젝트_허브/START_HERE.md`
- `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`
- `skills/PROJECT_BASE_ADAPTER.json`
- `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`
- current discovery/governance tests and freshness config

Historical Decision, review, planning inventory, old handoff snapshots are not bulk-rewritten merely because they contain superseded tokens.

## Runtime boundary

현재 `CombatAiPlanner`의 public-state-only 정보 경계, 10칸/3·3·4 전투 규칙, Phase I–VI 구현은 이 migration의 변경 대상이 아니다. 제품 동작 변경이 발견되면 별도 Decision으로 승격한다.

## Acceptance

- canonical integrated contract reports v4.8 r2 and new Decision ID.
- v4.5 r2 historical integrity remains discoverable.
- default cold-start no longer routes Google Sheets as current truth.
- legacy Sheet ID/tabs may remain only as migration locators.
- stable routers do not duplicate mutable PR/SHA/stage/next-package state.
- `skills/SKILL_REGISTRY.json` remains active project Skill authority; legacy registry is compatibility-only and not default-loaded.
- current authority tests fail before migration and pass after migration.
- current-task PR exact-head CI is green before merge.
- postmerge new `main` and Notion Home readback preserve runtime/product evidence ceilings.

## Rollback

Revert the migration PR. v4.5 r2 historical source remains intact, so no recovery depends on reconstructing deleted evidence.

## Incident note

작업 시작 중 branch 생성 전에 잘못된 probe write가 `main`에 1회 발생했다(`60f89d33a926100832999d291b24eda9a521fd43`). 즉시 probe 파일만 제거하는 보상 commit `b35112592e608cd974411bafe07ef5e37ab866b2`로 repository content를 원상복구했다. 원인은 `create_branch` action discovery 전에 `create_file`로 branch existence를 probe한 절차 오류다. 재발 방지: branch write 전 `GitHub.create_branch` schema를 먼저 discovery하고 exact branch ref를 확인한다.
