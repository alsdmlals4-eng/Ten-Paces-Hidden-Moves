# Post-Merge Canon Adversarial Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 병합된 7/10 기획을 main 정본 상태로 전환하고, 구형 권위 분류와 핵심 재미 위험을 자동 검증 가능한 계약으로 만든다.

**Architecture:** 활성 상태는 `ACTIVE_CONTEXT.md`와 `docs/04_ROADMAP.md`가 소비하고, 파일 생명주기는 `docs/CANON_LIFECYCLE_REGISTRY.md`가 단일 색인을 제공한다. JSON 감사 계약과 Python validator가 문서·계약의 상태 drift를 차단하며 Google Sheet는 같은 Decision ID와 main 병합 SHA를 기록한다.

**Tech Stack:** Markdown, JSON, Python 3.12 `unittest`, GitHub Actions, Google Sheets API

## Global Constraints

- 제품 코드·Scene·런타임 데이터 변경 금지.
- HTML PoC 재개·병합 금지.
- 사용자 승인 없는 전투 수치 변경 금지.
- 현행·대체됨·보류·폐기 상태를 기계 판독 가능하게 유지.
- 기존 PR·Full·Base·전용 계약 검증을 모두 유지.
- Godot·Windows·접근성·사람 검증은 실행하지 않았으면 `NOT_RUN`.

---

### Task 1: Canon lifecycle authority

**Files:**
- Create: `docs/decisions/2026-08-04_POSTMERGE_CANON_ADVERSARIAL_AUDIT_DECISION.md`
- Create: `docs/planning-data/approved_20260804_postmerge_canon_adversarial_audit_contract.json`
- Create: `docs/CANON_LIFECYCLE_REGISTRY.md`

**Interfaces:**
- Consumes: merge commits `81765e35`, `731e6431`, `0ba841ff`
- Produces: lifecycle labels and core-fun risk IDs consumed by validator and Sheet

- [ ] Record merged PR lineage and current authority files.
- [ ] Classify old range and Technique1 authority as `[대체됨]`.
- [ ] Classify HTML PR #85 as `[보류]` and forbid merge.
- [ ] Record six adversarial core-fun risks without changing mechanics.
- [ ] Set the next gate to `STAR9_PUBLIC_READ_BRANCH_TEMPLATE`.

### Task 2: Post-merge operating-state sync

**Files:**
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/04_ROADMAP.md`

**Interfaces:**
- Consumes: Task 1 Decision and registry
- Produces: current routing state for humans and governance tests

- [ ] Remove pending PR #84/#86/#87 state from current sections.
- [ ] Set `active_planning_pr: NONE` and `active_decision_state: MERGED_CANON_CHECKPOINT`.
- [ ] Preserve required runtime tokens `work_mode: REVIEW`, `integration_pr: 65`, `automated_validation: PASS`.
- [ ] Preserve runtime gap and Build prohibition.
- [ ] Put shared 9-star template before individual branch authoring.

### Task 3: Superseded authority labeling

**Files:**
- Modify: `docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md`
- Modify: `docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md`
- Modify: `docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`

**Interfaces:**
- Consumes: current combat pricing and Technique1 contracts
- Produces: unambiguous historical-only metadata

- [ ] Add visible `[대체됨]` banner to both Decisions.
- [ ] Change old Technique1 JSON authority to `SUPERSEDED_HISTORICAL_EVIDENCE`.
- [ ] Add `superseded_by` and Korean lifecycle label.
- [ ] Preserve historical formulas for migration and diff evidence.

### Task 4: Regression validator

**Files:**
- Create: `tools/check_postmerge_canon_lifecycle.py`
- Create: `tests/test_postmerge_canon_lifecycle.py`
- Create: `.github/workflows/postmerge-canon-lifecycle-validation.yml`

**Interfaces:**
- Consumes: Tasks 1–3 files
- Produces: `validate(root: Path) -> None`, CLI exit code, CI check

- [ ] Write mutation tests for stale PR state, old current authority, missing lifecycle label, and missing core-fun risk.
- [ ] Verify tests fail before the validator exists.
- [ ] Implement the minimal validator.
- [ ] Run seven lifecycle regression tests and direct CLI validation.
- [ ] Add dedicated pull-request workflow.

### Task 5: Growth authority pointer correction

**Files:**
- Modify: `docs/06_STARTING_FACTION_MASTERY_DATA.md`

**Interfaces:**
- Consumes: current Technique1 and repricing contracts
- Produces: correct 7/10 growth authority header without changing detailed formulas unnecessarily

- [ ] Replace the old Technique1 contract in the active-contract list.
- [ ] Set active batch to `7/10`.
- [ ] Move the old Technique1 Decision to historical/superseded lineage.
- [ ] Add conditional low-floor/high-ceiling and Star5 scope to current approval summary.

### Task 6: Sheet synchronization

**Files:**
- Google Sheet tabs: `00`, `01`, `02`, `04`, `12`, `15`, `40`, `41`, `99`

**Interfaces:**
- Consumes: final audit branch SHA and Decision ID
- Produces: same lifecycle and next-gate state in planning database

- [ ] Replace active draft status with merged checkpoint status.
- [ ] Add post-merge audit Decision and lifecycle audit row.
- [ ] Mark HTML PR #85 `[보류]` and old Technique1 authority `[대체됨]`.
- [ ] Record core-fun risks and required human metrics.
- [ ] Read back every edited range.

### Task 7: PR review and integration

**Files:**
- GitHub Draft PR against `main`

**Interfaces:**
- Consumes: all prior tasks
- Produces: reviewed canon-maintenance change set

- [ ] Run PR Validation, Full Validation, Base adoption, repricing, Technique1, and lifecycle workflows.
- [ ] Inspect changed files, review threads, comments, compare state, and exact head.
- [ ] Fix only evidenced failures.
- [ ] Merge with expected head SHA after all checks pass.
- [ ] Re-read main and Sheet after merge.
