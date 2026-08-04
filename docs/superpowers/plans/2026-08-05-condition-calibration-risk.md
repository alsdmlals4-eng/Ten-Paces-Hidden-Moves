# Condition Calibration Risk Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add stable condition-difficulty calibration governance without changing current Technique1 effects or costs.

**Architecture:** Keep the Technique1 contract as the effect authority. Add a focused calibration contract and validator for success-rate bands, valid-attempt measurement, failure taxonomy, manual reclassification, and anti-gaming; enforce it in PR CI and canon surfaces.

**Tech Stack:** Markdown, JSON, Python 3.12 `unittest`, GitHub Actions, Google Sheets.

## Global Constraints

- Decision: `TEN-DEC-20260805-CONDITION-CALIBRATION-01`.
- Current six Technique1 values remain unchanged.
- `quasi_certain` is `[0.85,1.00]` coefficient `1.00`.
- Publicly impossible attempts are excluded from calibration denominator.
- Hidden opponent counterplay failures remain valid failures.
- No automatic repricing.
- Runtime and human validation remain `NOT_RUN`.

---

### Task 1: RED tests

**Files:**
- Create: `tests/test_condition_calibration_contract.py`
- Create: `.github/workflows/condition-calibration-validation.yml`

- [ ] Write failing tests for band boundaries, denominator rules, duplicate trigger counting, sample gates, declaration freeze, and validation boundaries.
- [ ] Run tests and confirm failure because approved contract and validator do not exist.
- [ ] Commit with `test: define condition calibration authority`.

### Task 2: GREEN contract and validator

**Files:**
- Create: `docs/planning-data/approved_20260805_condition_calibration_contract.json`
- Create: `tools/check_condition_calibration_contract.py`

- [ ] Define six bands, valid-attempt and overall-use formulas, eight final outcomes, warning/reclassification gates, anti-gaming, current condition groups, Star9 required fields, and runtime boundary.
- [ ] Implement `difficulty_for_success_rate()` and `validate()`.
- [ ] Run `python -m unittest tests.test_condition_calibration_contract -v`.
- [ ] Run `python tools/check_condition_calibration_contract.py`.
- [ ] Commit with `feat: approve condition calibration contract`.

### Task 3: Canon synchronization

**Files:**
- Create: `docs/decisions/2026-08-05_CONDITION_CALIBRATION_DECISION.md`
- Create: `docs/02_COMBAT_RULES_CONDITION_CALIBRATION_AMENDMENT.md`
- Modify: `docs/CANON_LIFECYCLE_REGISTRY.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/04_ROADMAP.md`
- Modify: `.github/workflows/documentation-governance.yml`

- [ ] Register the new Decision and contract as current governance without superseding the Technique1 effect authority.
- [ ] Require the new regression suite in PR Validation.
- [ ] Preserve product/runtime boundaries.

### Task 4: Review and evidence

- [ ] Verify exact-head PR, Full, Base, Technique1, lifecycle, condition, and work-governance checks.
- [ ] Confirm no unresolved review threads or product runtime changes.
- [ ] Synchronize Sheet tabs `00·01·02·04·12·15·40·41·99` with the same Decision IDs and exact SHA.
- [ ] Keep the PR Draft and stacked on PR #89.
