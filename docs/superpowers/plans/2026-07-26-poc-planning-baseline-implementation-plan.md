# PoC Planning Baseline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 최신 승인 기획을 편집 가능한 PoC 데이터와 책임 원본으로 통합하되 런타임을 변경하지 않는다.

**Architecture:** 중앙 JSON은 수치·콘텐츠를 소유하고 Markdown 책임 원본은 경험·규칙·경계·검증을 설명한다. 현재 main 런타임은 `IMPLEMENTED_LEGACY`로 분리한다. 캠페인 구조는 결투 데이터의 `stage_id`와 지도 데이터의 구간별 중간 노드 계약으로 나눈다.

**Tech Stack:** Markdown, JSON, Python unittest, GitHub branch/PR, 기존 Python/Godot 검증 파이프라인.

## Global Constraints

- `PLANNING_IN_PROGRESS` 유지.
- `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot` 변경 금지.
- 사람·Godot·Windows 미실행 검증은 `NOT_RUN` 또는 `UNVERIFIED`.
- 0.05=1틱, 목표 20/50/80틱, 허용오차 ±5틱.
- PoC 플레이 범위는 주요 비무 1~5다.
- 주요 비무 사이 중간 노드는 각각 2~3개다.
- 주요 비무 5 승리 뒤 첫 절초를 사용할 수 있다.
- 스테이지 분할은 튜토리얼 1 / 스테이지1 2~5 / 스테이지2 6~8 / 스테이지3 9~10이다.
- 히든 천하제일인 전투는 스테이지3 이후 후속 추가이며 본편 종료 필수가 아니다.

---

### Task 1: 구형 계약 감사

**Files:** Create `docs/decisions/2026-07-26_LEGACY_CANONICAL_AUDIT.md`

- [x] 활성 문서·데이터의 구형 수치를 검색한다.
- [x] 고유 구현 정보와 구형 현재형 서술을 분리한다.
- [x] 런타임 비변경·롤백 경계를 기록한다.

### Task 2: 편집 가능한 PoC 데이터

**Files:** Create `docs/planning-data/*.json`, `docs/planning-data/README.md`

- [x] 중앙 틱 예산을 작성한다.
- [x] 6개 무공의 성장·기술·예산을 작성한다.
- [x] 공개 상태 적 문법과 주요 비무 10개를 작성한다.
- [x] 지도·성과·보상·의료 공급을 작성한다.
- [x] 모든 기술을 ±5틱 안으로 검산한다.

### Task 3: 전투 checkpoint

**Files:** Modify `docs/02_COMBAT_RULES.md`

- [x] 순차 연격 합·중단·강건·잔여타를 통합한다.
- [x] 효과 scope/trigger와 행동당 합 기세를 통합한다.
- [x] 구형 런타임 차이를 표로 격리한다.

### Task 4: 콘텐츠·성장·지도

**Files:** Modify `docs/03_CONTENT_CATALOG.md`, `docs/06_STARTING_FACTION_MASTERY_DATA.md`

- [x] PoC와 확장 가설의 수량을 구분한다.
- [x] 시작 무공·의료·주요 비무·지도 데이터를 연결한다.

### Task 5: PoC·로드맵

**Files:** Modify `docs/04_ROADMAP.md`, `docs/05_COMBAT_POC_SPEC.md`

- [x] 기존 3전+2선택 노드 PoC를 기록했다.
- [x] 성공·실패·중단·T1 게이트를 명시한다.

### Task 6: UI·아키텍처·연출·QA

**Files:** Modify `docs/07_COMBAT_UI_SPEC.md`, `docs/08_TEST_CHECKLIST.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`, `docs/10_COMBAT_PRESENTATION_PLAN.md`

- [x] 새 타격 이벤트·로그·복기 계약을 명시한다.
- [x] 실제 구현 경로와 데이터 변환 경계를 보존한다.
- [x] 자동·Godot·Windows·사람 증거를 분리한다.

### Task 7: 검수와 인수

**Files:** Modify Active Context, Documentation Map, Handoff; create review records.

- [x] 벤치마킹·1·2차 기획 검수·5회 적대적 검토를 기록한다.
- [x] sanity model의 증거 경계를 기록한다.
- [x] JSON·문서 정적 검증을 실행한다.
- [x] branch diff를 확인하고 draft PR #45를 연다.

### Task 8: 5전 PoC와 3스테이지 캠페인 구조

**Files:**
- Modify: `tests/test_poc_planning_data.py`
- Modify: `tools/check_poc_planning_data.py`
- Modify: `docs/planning-data/poc_enemy_duels.json`
- Modify: `docs/planning-data/poc_map_rewards.json`
- Modify: `docs/03_CONTENT_CATALOG.md`
- Modify: `docs/04_ROADMAP.md`
- Modify: `docs/05_COMBAT_POC_SPEC.md`
- Modify: `docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `[기획서]/00_프로젝트_허브/HANDOFF.md`

**Interfaces:**
- Consumes: `major_duels[].id`, `major_duels[].order`, `poc_runtime_subset`, `poc_slice.major_duels`.
- Produces: `major_duels[].stage_id`, `stage_contract`, `campaign_structure`, `intermediate_nodes_per_gap`, `target_visited_nodes`, `first_ultimate_available_after_duel_id`.

- [x] **Step 1: Write failing stage and node tests**
  - PoC subset must equal major duels 1~5.
  - Stage mapping must equal tutorial 1, stage1 2~5, stage2 6~8, stage3 9~10.
  - Every gap must allow 2~3 intermediate nodes.
  - PoC total visited range must equal 13~17.
  - Duel 5 must unlock first ultimate after victory.
  - Hidden battle must be `FUTURE_HIDDEN` after stage3 and optional for the main ending.

- [x] **Step 2: Run PR validation and verify RED**
  - PR Validation run #740에서 `Validate PoC planning data`가 기존 3전 데이터 때문에 의도대로 실패했다.

- [x] **Step 3: Update editable planning data**
  - `poc_runtime_subset`과 `poc_slice.major_duels`를 첫 다섯 안정 ID로 갱신했다.
  - 주요 비무 1~5를 `POC_PRIMARY`, 6~10을 `POC_EXPANSION`으로 분리했다.
  - 스테이지 ID·캠페인 메타데이터·네 구간 노드 범위를 추가했다.
  - 중간 노드 합계 8/10/12와 총 방문 노드 13/15/17을 기록했다.
  - 주요 비무 5 첫 절초 해금과 히든 천하제일인 메타데이터를 추가했다.

- [x] **Step 4: Update validator**
  - 정확한 PoC subset·스테이지 순서·노드 범위·파생 합계·절초 해금·히든 선택 범위를 검사한다.
  - 기존 예산·효과·ID·보상·의료 검사를 유지한다.

- [x] **Step 5: Run tests and verify GREEN**
  - PR Validation run #750에서 planning·운영체계·freshness·전투 영향 지도·기존 계약 검사가 모두 통과했다.

- [x] **Step 6: Synchronize responsible documents**
  - 활성 정본의 `1~3`, `3전`, `2회 성장`, `총 5노드` 현재 PoC 서술을 1~5·13~17노드 계약으로 교체했다.
  - 스테이지 1 절초 해금과 스테이지 2·3·히든 비구현 경계를 기록했다.

- [x] **Step 7: Update PR trace**
  - PR #45 본문과 승인 추적 기록을 최신 PoC 구조와 검증 증거로 갱신한다.
