# PR #7 Canonical·Skill·Structure Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** PR #7 `agent/t0-combat-poc-board@147a031c75e96bff170d7f99016beb9e85b12066`와 Issue #13의 STEP 12~14 승인 계약을 유일한 최신 기준으로 삼아, Codex 구현 파일을 보존하면서 활성 문서·Skill·Registry·검사를 Base `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`와 정렬한다.

**Architecture:** 전투 구현·데이터·씬·자산은 수정하지 않고 exact PR #7 HEAD에서 분기한 정합화 브랜치에서 문서와 Governance만 변경한다. 현행 계약은 `docs/02_COMBAT_RULES.md`, 현재 범위는 `docs/05_COMBAT_POC_SPEC.md`, 현재 증거는 `docs/08_TEST_CHECKLIST.md`, 현재 상태는 허브 `ACTIVE_CONTEXT.md`가 각각 단일 책임을 가진다. 날짜별 보정 절과 구형 진행 상태를 제거하고, JSON 실제 계약에서 활성 문서·Skill의 최신성을 검사한다.

**Tech Stack:** GitHub Contents API, Markdown, JSON Schema draft 2020-12, Python 3 unittest/checker, GitHub Actions, Godot 4.7 프로젝트의 기존 정적·런타임 테스트.

## Global Constraints

- 기준 브랜치와 SHA는 `agent/t0-combat-poc-board@147a031c75e96bff170d7f99016beb9e85b12066`다.
- STEP 14는 기계적 5시나리오 증거까지 `PASS/PARTIAL`, 사람 이해·보조기기·주관적 음향/모션·외부 플레이는 `NOT_RUN`이다.
- `data/`, `src/`, `scenes/`, `assets/`, `project.godot`, Godot addon과 제품 테스트 구현은 이번 정합화에서 변경하지 않는다.
- force push, reset, rebase, PR #7 HEAD 덮어쓰기를 금지한다.
- Base 기준은 `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`다.
- 로컬 Skill은 프로젝트 고유 4개를 유지하며 Base 공유 Skill을 복제하지 않는다.
- 백업·보류·과거 Plan·Git 이력의 당시 표현은 활성 기본 참조가 아니다.
- 검증하지 않은 런타임·접근성·성능·사용자 플레이를 완료로 표시하지 않는다.

---

### Task 1: Freeze baseline and preservation evidence

**Files:**
- Create: `plans/2026-07-23-pr7-canonical-skill-structure-refresh-plan.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `[기획서]/00_프로젝트_허브/HANDOFF.md`

**Interfaces:**
- Consumes: PR #7 HEAD SHA, Issue #13 approved rules, current workflow runs.
- Produces: exact baseline, protected path list, human-vs-automated verification boundary.

- [ ] Record the exact baseline and protected path prefixes.
- [ ] Confirm the refresh branch starts at the exact PR #7 HEAD.
- [ ] Compare baseline to refresh branch and require no product file differences before documentation edits.
- [ ] Record STEP 14 mechanical evidence separately from human observation.

### Task 2: Rewrite active product canon

**Files:**
- Modify: `docs/01_GAME_DESIGN.md`
- Modify: `docs/02_COMBAT_RULES.md`
- Modify: `docs/03_CONTENT_CATALOG.md`
- Modify: `docs/04_ROADMAP.md`
- Modify: `docs/05_COMBAT_POC_SPEC.md`
- Modify: `docs/06_STARTING_FACTION_MASTERY_DATA.md`
- Modify: `docs/07_COMBAT_UI_SPEC.md`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Modify: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- Modify: `docs/10_COMBAT_PRESENTATION_PLAN.md`
- Modify: `docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md`

**Interfaces:**
- Consumes: Issue #11 and #13 approved rules, actual data/code/test contracts at PR #7 HEAD.
- Produces: one current contract per question without appended superseding sections.

- [ ] Replace stale occupancy, movement, clash, defense, sure-hit, AI, interruption, ultimate, ending and restart statements.
- [ ] Remove date-appended override sections after integrating unique current facts into their owning sections.
- [ ] Preserve T1/T2/full-game hypotheses as hypotheses and keep them out of T0 completion.
- [ ] Keep STEP 14 human evidence `NOT_RUN`.

### Task 3: Optimize project Skills and Base routing

**Files:**
- Modify: `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`
- Modify: `skills/game-design/ten-paces-game-design/SKILL.md`
- Modify: `skills/ux-ui-accessibility/combat-ux-and-accessibility/SKILL.md`
- Modify: `skills/engineering/combat-implementation-handoff/SKILL.md`
- Modify: `skills/qa/ten-paces-verification/SKILL.md`
- Modify: `skills/LEGACY_SKILL_ALIASES.md`
- Modify: `schemas/skill-registry-v3.schema.json`

**Interfaces:**
- Consumes: Base `skills/SKILL_REGISTRY.json@41a20584...` and current four local responsibilities.
- Produces: current Base route map, compact local procedure routers, preserved legacy compatibility.

- [ ] Update Base commit and route all active Base Skill IDs without default loading.
- [ ] Keep exactly four local Skills.
- [ ] Remove Issue/STEP completion state from Skill bodies; route current state to Active Context and product canon.
- [ ] Retain procedure, modes, ownership, forbidden actions and completion criteria.
- [ ] Update schema/checkers so route count is derived from the Registry rather than hard-coded to 13.

### Task 4: Strengthen canonical freshness and governance tests

**Files:**
- Modify: `.github/reference-freshness.json`
- Modify: `.github/documentation-governance.json`
- Modify: `tools/check_canonical_reference_freshness.py`
- Modify: `tools/check_project_operating_system.py`
- Modify: `tools/check_skill_package_integrity.py`
- Modify: `tests/test_project_governance.py`
- Modify: `.gitignore`
- Delete when tracked: `tools/__pycache__/*.pyc`

**Interfaces:**
- Consumes: schema 16 board JSON, active document/Skill list, Base route map.
- Produces: stale-claim rejection, current-contract validation and no-cache policy.

- [ ] Make board schema expectation `16`.
- [ ] Reject active claims for one-fighter occupancy, no overlap, shared-target stop, health 20, highest-reduction guard, fixed enemy plan, unimplemented STEP 11-13, focus status and two-move combat.
- [ ] Validate Base commit and active Base routes from configuration rather than fixed literals in Python.
- [ ] Add negative tests proving each stale family fails.
- [ ] Ignore and remove Python cache artifacts.

### Task 5: Refresh entrypoints, Registry and project status

**Files:**
- Modify: `README.md`
- Modify: `START_HERE.md`
- Modify: `AGENTS.md`
- Modify: `[기획서]/DESIGN_DOCUMENT_REGISTRY.json`
- Modify: `[기획서]/00_프로젝트_허브/START_HERE.md`
- Modify: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- Modify: `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`
- Modify: `[기획서]/00_프로젝트_허브/ROADMAP.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `[기획서]/00_프로젝트_허브/HANDOFF.md`
- Modify: `[기획서]/00_프로젝트_허브/OPERATING_SYSTEM_HEALTH_REPORT.md`
- Modify: `docs/BASE_RULES_VERSION.md`

**Interfaces:**
- Consumes: Tasks 2-4 canonical ownership and verified states.
- Produces: cold-start path that selects PR #7/Issue #13 current state and STEP 14 human gate.

- [ ] Replace one-off Issue/P0 required section names with durable responsibility headings.
- [ ] State STEP 0-13 implementation and STEP 14 evidence split consistently.
- [ ] Point implementation work to PR #7 and planning work to the core-design sequence after integration.
- [ ] Record Base SHA and the new synchronization audit boundary.

### Task 6: Verify no Codex product work was lost

**Files:**
- Test only: all files changed between baseline and refresh branch.

**Interfaces:**
- Consumes: exact baseline and refresh branch HEAD.
- Produces: preservation report and allowed-change set.

- [ ] Compare `147a031c...` to refresh HEAD.
- [ ] Fail if changes appear under `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot` or product runtime test files.
- [ ] Inspect every changed filename and confirm it belongs to docs/Skills/Governance/plan/cache cleanup.
- [ ] Run Documentation Governance and Card Component Contract workflows.
- [ ] Record PASS/FAIL/NOT_RUN with workflow URLs and commit SHA.

### Task 7: Integrate through a stacked documentation PR

**Files:**
- GitHub PR metadata only.

**Interfaces:**
- Consumes: verified refresh branch.
- Produces: Draft PR targeting `agent/t0-combat-poc-board`, then refreshed PR #7 metadata and later main integration.

- [ ] Create a Draft PR from `agent/pr7-canonical-skill-refresh` to `agent/t0-combat-poc-board`.
- [ ] Include baseline SHA, protected paths, exact validation evidence and human STEP 14 `NOT_RUN` state.
- [ ] Do not merge until checks succeed and the head SHA remains unchanged.
- [ ] After stacked PR merge, refresh PR #7 title/body and retarget to `main` only after main/base ancestry is verified.
- [ ] Close superseded PRs only after their unique information is preserved or explicitly linked.
