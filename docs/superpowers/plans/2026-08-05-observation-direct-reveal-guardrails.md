# Observation Direct Reveal Guardrails Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve the approved direct observation reveal model while recording its opportunity cost, anti-cheat boundaries, answer-leak measurement contract, and current planning state consistently across GitHub and Google Sheets.

**Architecture:** Keep the existing gameplay behavior unchanged: one Observation action converts one action slot into one observation point, and stored points reveal the enemy's locked bundle from the first slot forward using the existing action-type categories. Add a planning-only contract and deterministic validator, then remove stale mutable PR/count/next-decision copies from entry documents so `ACTIVE_CONTEXT.md` remains the sole repository source for mutable planning state.

**Tech Stack:** Markdown and JSON planning canon, Python 3.12 `unittest` validator tests, GitHub Actions, Google Sheets GDD workspace.

## Global Constraints

- Work Mode remains `PLAN`; product code, Godot scenes, HTML PoC, and runtime data must not change.
- Decision ID: `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`.
- Existing observation behavior is retained: direct front-to-back action-type reveal, compound action-type display, unlimited stored observation, and cross-bundle carryover.
- Enemy plan must be locked before observation reveal and must not be replaced after reveal.
- Observation must never expose AI weights, exact target/direction/distance/damage, or a recommended correct counter.
- Risk status is `ACCEPTED_PENDING_HUMAN_MEASUREMENT`; no automatic observation nerf or repricing is allowed.
- Active approval count becomes `8/10`; next planning decision becomes `GRADE_FARMING_RISK`.
- Every change follows RED → GREEN → REFACTOR → exact-head verification.

---

### Task 1: RED contract and entrypoint consistency tests

**Files:**
- Create: `tests/test_observation_answer_leak_guardrails_contract.py`
- Create: `.github/workflows/observation-answer-leak-guardrails-validation.yml`

**Interfaces:**
- Consumes: current PR #92 branch files and the future contract/checker paths.
- Produces: failing tests for missing contract/checker and stale mutable planning state in active entrypoints.

- [ ] Write tests that require the approved contract, direct reveal behavior, one-slot observation opportunity cost, front-to-back spending, enemy pre-lock, prohibited hidden outputs, no automatic nerf, measurement fields, `8/10`, and `GRADE_FARMING_RISK`.
- [ ] Add a dedicated workflow that runs only the new test module and checker.
- [ ] Commit and confirm the workflow fails because the contract/checker are absent and stale entrypoints still advertise PR #82 / 2-of-10.

### Task 2: GREEN approved observation contract and validator

**Files:**
- Create: `docs/planning-data/approved_20260805_observation_answer_leak_guardrails_contract.json`
- Create: `tools/check_observation_answer_leak_guardrails_contract.py`
- Create: `docs/decisions/2026-08-05_OBSERVATION_ANSWER_LEAK_GUARDRAILS_DECISION.md`
- Create: `docs/02_COMBAT_RULES_OBSERVATION_GUARDRAILS_AMENDMENT.md`

**Interfaces:**
- Consumes: `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`, current combat rules, and PR #92 active context.
- Produces: deterministic planning contract and checker with stable diagnostic codes.

- [ ] Encode the unchanged direct reveal model and opportunity-cost rationale.
- [ ] Encode `locked_before_reveal`, `no_post_reveal_replan`, `no_player_uncommitted_plan_read`, exact forbidden outputs, and measurement-only handling.
- [ ] Require metrics: observation use rate, observation points spent, full-bundle reveal rate, exact-technique inference rate, observation-assisted correct-counter rate, grade uplift, and non-observation win rate.
- [ ] Set manual review defaults: at least 30 valid observed bundles before interpretation; warning only at exact-technique inference above 70%, correct-counter uplift above 20 percentage points, or full-bundle reveal above 50%; never auto-nerf.
- [ ] Run the focused tests until GREEN.

### Task 3: REFACTOR mutable planning state ownership

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `START_HERE.md`
- Modify: `docs/01_GAME_DESIGN.md`
- Modify: `docs/BASE_RULES_VERSION.md`
- Modify: `[기획서]/00_프로젝트_허브/START_HERE.md`
- Modify: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- Modify: `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/04_ROADMAP.md`
- Modify: `docs/CANON_LIFECYCLE_REGISTRY.md`

**Interfaces:**
- Consumes: the new Decision and approved contract.
- Produces: one mutable-state authority (`ACTIVE_CONTEXT.md`) and stable entrypoints that link to it instead of copying active PR/head/count/next-decision values.

- [ ] Update `ACTIVE_CONTEXT.md` to PR #92, `8/10`, `APPROVED_DRAFT_OBSERVATION_ANSWER_LEAK_GUARDRAILS`, and next `GRADE_FARMING_RISK`.
- [ ] Update Roadmap and lifecycle registry with the new Decision and risk state.
- [ ] Remove stale PR #82 / 2-of-10 current-state claims from all active entrypoints.
- [ ] Keep stable core, platform, runtime boundary, and historical lineage facts intact.
- [ ] Run focused tests and existing lifecycle tests.

### Task 4: Workflow and PR metadata integration

**Files:**
- Modify: `.github/workflows/documentation-governance.yml`
- Modify: PR #92 title and body.

**Interfaces:**
- Consumes: the new checker and tests.
- Produces: permanent exact-head regression coverage and an accurate PR summary.

- [ ] Add the new test/checker to the main PR Validation workflow.
- [ ] Update PR #92 body with both approved Decisions, `8/10`, accepted measurement risk, entrypoint freshness repair, and unchanged product/runtime boundary.
- [ ] Verify all PR workflows at the latest exact head.

### Task 5: Google Sheets same-ID synchronization

**Files:**
- Update ranges in `00_프로젝트_허브`, `01_작업순서`, `02_현재_확정결정`, `04_누락_충돌_감사`, `12_핵심루프`, `15_조작_게임규칙`, `40_핵심시스템_메인콘텐츠`, `41_성장_경제`, and `99_변경이력`.

**Interfaces:**
- Consumes: final PR #92 exact head and Decision ID.
- Produces: `SHEET_SYNCED_STACKED_DRAFT` rows with the same Decision ID and exact head.

- [ ] Record unchanged direct observation reveal and accepted measurement risk.
- [ ] Record entrypoint canon conflict and its TDD repair.
- [ ] Normalize the new `99_변경이력` row to the existing eight-column schema.
- [ ] Read back all written ranges and compare Decision ID, PR, exact head, state, and next risk.

### Task 6: Adversarial regression and closeout

**Files:**
- No new product files.

**Interfaces:**
- Consumes: final GitHub and Sheets state.
- Produces: exact-head decision report.

- [ ] Attack for accidental observation weakening, hidden AI replanning, exact counter recommendation, stale PR #82 claims, Sheet column drift, and product/runtime scope leakage.
- [ ] Validate each critique and fix only MUST_FIX findings.
- [ ] Re-run focused, lifecycle, PR, Full, Base, Technique1, Derived Stats, and Observation workflows.
- [ ] Confirm draft/open/mergeable status, stacked parent #91, review threads 0, and human/Godot/Windows/balance/accessibility/performance `NOT_RUN`.
