# Existing Approved Actions Reprice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the approved unified 15-tick movement/range price to all 15 previously approved basic attacks and martial techniques while preserving each action's approved effect identity.

**Architecture:** Preserve historical source contracts unchanged, and add one authoritative repricing overlay that owns the effective cost and slot values for product implementation. A standalone validator and regression tests enforce complete coverage, exact calculations, affordability, and ±5-tick variance.

**Tech Stack:** JSON planning contracts, Python 3.12 validation, unittest, Markdown canonical decisions.

## Global Constraints

- Reprice exactly 15 approved actions: 3 basic attacks, 6 technique-1 actions, and 6 technique-2 actions.
- Use movement cost `tiles * 15` and range cost `max(0, max_range - 1) * 15`.
- Preserve approved damage, movement, range, tags, conditions, and role identity.
- Resource allowance is independent of slot count: stamina +4 ticks each, internal +7 ticks each.
- Every adjusted action must remain within ±5 ticks.
- 10-star martial ultimates remain excluded because their effects are not approved.
- HTML PoC and Godot runtime remain unchanged.

---

### Task 1: Repricing contract and RED validation

**Files:**
- Create: `docs/planning-data/approved_20260804_existing_action_reprice_contract.json`
- Create: `tools/check_existing_action_reprice_contract.py`
- Create: `tests/test_existing_action_reprice_contract.py`

- [ ] Add a failing test requiring all 15 action IDs and exact approved adjustments.
- [ ] Run the test before the contract exists and confirm failure.
- [ ] Add the contract and minimal validator.
- [ ] Run targeted tests and confirm pass.

### Task 2: Canonical decision and implementation boundary

**Files:**
- Create: `docs/decisions/2026-08-04_EXISTING_APPROVED_ACTIONS_REPRICE_DECISION.md`
- Create: `docs/superpowers/specs/2026-08-04-existing-approved-actions-reprice-design.md`

- [ ] Record exact old/new costs and slots, calculations, rationale, and exclusions.
- [ ] State that the overlay supersedes historical costs for implementation but preserves historical evidence.
- [ ] Record human balance and runtime validation as NOT_RUN.

### Task 3: CI integration and authority references

**Files:**
- Create: `.github/workflows/approved-action-reprice-validation.yml`
- Create: `docs/decisions/2026-08-04_EXISTING_APPROVED_ACTIONS_REPRICE_DECISION.md`

- [ ] Add the repricing validator to pull-request validation.
- [ ] Make the new decision and overlay the implementation authority for effective costs and slots.
- [ ] Run all relevant validation.

### Task 4: GitHub and Sheet synchronization

- [ ] Commit changes on PR #86 branch.
- [ ] Verify branch compare and all validation workflows.
- [ ] Update Google Sheet with the same Decision ID and exact head.
- [ ] Read back GitHub and Sheet state.
