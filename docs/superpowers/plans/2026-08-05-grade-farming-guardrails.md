# Battle Grade Farming Guardrails Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a planning-only, deterministic anti-farming aggregation contract that preserves raw combat events while limiting repeat, multi-hit, late-round, and ineffective-ultimate grade credit.

**Architecture:** Keep the existing five raw battle-grade metrics and combat resolution untouched. Add a separate eligible-credit layer keyed by canonical enemy action identity and action instance, validate it with a JSON contract and Python checker, then advance the active planning batch to 9/10 and synchronize GitHub canon and Google Sheets.

**Tech Stack:** Markdown and JSON planning canon, Python 3.12 `unittest`, deterministic Python contract checker, GitHub Actions, Google Sheets GDD workspace.

## Global Constraints

- Work Mode remains `PLAN`; product code, Godot scenes, HTML PoC, and runtime data must not change.
- Decision ID is `TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01`.
- Raw dodge, clash, health-loss, round, and ultimate-use events remain complete and unattenuated.
- Repeat multipliers are exactly `[1.0, 0.5, 0.0]` by canonical enemy action source ID.
- One enemy attack action instance contributes at most `1.0` combined clash+dodge credit.
- Multiple qualifying events within one action instance split its credit pool equally.
- Clash and dodge credit caps are each `3.0`; normalized inputs are `min(total, 3.0) / 3.0`.
- Encounter `grade_target_rounds` controls the scoring window; PoC fallback is `3`.
- Positive clash, dodge, and ultimate credit stops after the scoring window; raw logs, health loss, and round count continue.
- Only the first effective ultimate use within the scoring window receives grade credit.
- Grade cannot affect economy before the human-validation gate and a new Decision.
- Active approval count becomes `9/10`; next planning decision becomes `STAR9_PUBLIC_READ_BRANCH_TEMPLATE`.
- Every change follows RED → GREEN → REFACTOR → exact-head verification.

---

### Task 1: RED grade-farming contract tests

**Files:**
- Create: `tests/test_grade_farming_guardrails_contract.py`
- Create: `.github/workflows/grade-farming-guardrails-validation.yml`

**Interfaces:**
- Consumes: current five-metric grade Decision, stable action identity Decision, historical repeat attenuation candidate, and the approved design spec.
- Produces: failing tests for the absent approved contract and checker.

- [ ] Create a `unittest` module that requires the approved contract and checker paths.
- [ ] Require raw-log preservation, exact repeat multipliers, per-instance combined-credit cap, equal pool splitting, metric caps, scoring-window cutoff, ultimate limit, economy gate, measurement diagnostics, `9/10`, and next `STAR9_PUBLIC_READ_BRANCH_TEMPLATE`.
- [ ] Add mutation tests with stable error codes: `RAW_EVENT_PRESERVATION_CONFLICT`, `REPEAT_ATTENUATION_CONFLICT`, `ACTION_INSTANCE_CREDIT_CONFLICT`, `EVENT_POOL_SPLIT_CONFLICT`, `GRADE_METRIC_CAP_CONFLICT`, `GRADE_SCORING_WINDOW_CONFLICT`, `ULTIMATE_GRADE_CREDIT_CONFLICT`, `GRADE_ECONOMY_GATE_CONFLICT`, and `GRADE_MEASUREMENT_CONFLICT`.
- [ ] Add a dedicated pull-request workflow that runs the new test module and checker.
- [ ] Push RED and confirm the workflow fails because the contract and checker do not exist.

### Task 2: GREEN approved contract and deterministic checker

**Files:**
- Create: `docs/planning-data/approved_20260805_grade_farming_guardrails_contract.json`
- Create: `tools/check_grade_farming_guardrails_contract.py`
- Create: `docs/decisions/2026-08-05_GRADE_FARMING_GUARDRAILS_DECISION.md`
- Create: `docs/02_COMBAT_RULES_GRADE_FARMING_GUARDRAILS_AMENDMENT.md`

**Interfaces:**
- Consumes: the RED tests and `docs/superpowers/specs/2026-08-05-grade-farming-guardrails-design.md`.
- Produces: an approved planning contract and deterministic validation surface.

- [ ] Encode the unchanged five raw metrics and planning-only boundary.
- [ ] Encode canonical source identity, action-instance identity, `[1.0, 0.5, 0.0]`, equal split, combined instance cap `1.0`, and per-metric cap `3.0`.
- [ ] Encode encounter target rounds with fallback `3` and positive-credit cutoff behavior.
- [ ] Encode first-effective-ultimate-only credit and non-cost effectiveness events.
- [ ] Encode the 30-victory, 5-encounter, 40%-maximum-sample human gate and required diagnostics.
- [ ] Encode no automatic tuning and no economy linkage before a new Decision.
- [ ] Implement checker diagnostics with the exact error codes required by RED tests.
- [ ] Run the focused tests until GREEN.

### Task 3: REFACTOR active canon and stale mutable assertions

**Files:**
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/01_GAME_DESIGN.md`
- Modify: `docs/04_ROADMAP.md`
- Modify: `docs/06_STARTING_FACTION_MASTERY_DATA.md`
- Modify: `docs/CANON_LIFECYCLE_REGISTRY.md`
- Modify: `tools/check_postmerge_canon_lifecycle.py`
- Modify: `tests/test_observation_answer_leak_guardrails_contract.py`
- Modify: `tests/test_postmerge_canon_lifecycle.py` only if its fixture asserts the previous approval count.

**Interfaces:**
- Consumes: the approved grade-farming Decision and contract.
- Produces: active planning state `9/10`, risk mitigation state, and next 9-star template decision without making older feature tests own mutable global state.

- [ ] Advance Active Context and Roadmap to `9/10`, `APPROVED_DRAFT_GRADE_FARMING_GUARDRAILS`, and `STAR9_PUBLIC_READ_BRANCH_TEMPLATE`.
- [ ] Record `GRADE_FARMING_RISK` as `MITIGATED_PENDING_HUMAN_MEASUREMENT`.
- [ ] Add the Decision and contract to lifecycle and game-design authority lists.
- [ ] Update lifecycle validator expected approval count to `9/10` and mastery active batch to `9/10`.
- [ ] Refactor observation-specific tests so they validate observation authority without freezing the global approval count or next Decision.
- [ ] Run grade, observation, lifecycle, governance, and focused contract tests.

### Task 4: Permanent workflow and PR integration

**Files:**
- Modify: `.github/workflows/documentation-governance.yml`
- Modify: PR #92 title and body.

**Interfaces:**
- Consumes: the grade checker and tests.
- Produces: permanent exact-head regression coverage and an accurate 9/10 PR summary.

- [ ] Add grade-farming test and checker commands to PR Validation.
- [ ] Update PR #92 title/body with all three current Decisions, the raw/effective separation, 9/10, next 9-star template, and unchanged product/runtime boundary.
- [ ] Verify dedicated and aggregate workflows at the latest exact head.

### Task 5: Google Sheets same-ID synchronization

**Files:**
- Update: `00_프로젝트_허브`, `01_작업순서`, `02_현재_확정결정`, `04_누락_충돌_감사`, `12_핵심루프`, `15_조작_게임규칙`, `40_핵심시스템_메인콘텐츠`, `41_성장_경제`, `99_변경이력`.

**Interfaces:**
- Consumes: final PR #92 exact head and `TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01`.
- Produces: same-ID Sheet rows aligned with GitHub canon.

- [ ] Record raw logs versus effective grade credit and exact anti-farming defaults.
- [ ] Record the economy-link prohibition and human-validation gate.
- [ ] Record 9/10 and next `STAR9_PUBLIC_READ_BRANCH_TEMPLATE` in the project hub.
- [ ] Append `99_변경이력` using the existing eight-column schema.
- [ ] Read back all nine tabs and compare Decision ID, PR head, state, next decision, and column alignment.

### Task 6: Adversarial verification and closeout

**Files:**
- No product/runtime files.

**Interfaces:**
- Consumes: final GitHub and Sheets state.
- Produces: exact-head evidence report.

- [ ] Attack for raw-log attenuation, multi-hit double credit, repeat identity bypass, post-window positive credit, ineffective ultimate credit, premature economy linkage, mutable-state test drift, Sheet column drift, and product/runtime scope leakage.
- [ ] Fix only validated MUST_FIX findings.
- [ ] Re-run dedicated Grade, Observation, Derived Stats, Technique1, Base, PR Validation, and Full Validation workflows.
- [ ] Confirm PR #92 remains draft/open/mergeable, stacked on PR #91, with review threads 0.
- [ ] Report Godot, Windows, accessibility, performance, human, and balance validation as `NOT_RUN`.
