# Adversarial Review BUILD Remediation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the verified adversarial findings and UDR-01/02/03 decisions into an executable, single-source planning contract without changing Godot runtime paths.

**Architecture:** Keep `docs/planning-data/` as non-runtime source data, but normalize card execution, budget ledgers, AI plans, map generation, rewards, and run-state transitions into machine-checkable schemas. Extend `tools/check_poc_planning_data.py` as the sole static validator and use mutation tests to prove each previously reproduced false pass is rejected. Root entrypoints and canonical documents are synchronized after data contracts pass.

**Tech Stack:** Python 3.12, JSON, Markdown, `unittest`, GitHub Actions.

## Global Constraints

- Product runtime paths `data/`, `src/`, `scenes/`, `assets/`, `addons/`, and `project.godot` must remain unchanged.
- Work Mode returns to `REVIEW` after the minimal BUILD correction.
- PoC scope remains major duels 1–5 with 2–3 intermediate nodes in each of four gaps.
- Basic ultimates remain available from PoC start; manual ultimates unlock at mastery 10.
- Retry restores the pre-battle `RunState`, consumes permanent currency at 1/2/3 for retries in the same battle, and resets the counter on a different battle.
- `[필중]` is stack-based; one stack is consumed only when an effective hit reaches evade resolution and bypasses an available evade.
- Major-duel reward options are free training 6, designated training 5 plus free training 3, or a faction manual at mastery 3.
- A focused route must be able to reach 38 training points before major duel 5.
- `BLOCKED_UNVERIFIED` items remain explicitly unverified.

---

### Task 1: Add RED mutation coverage for every verified false pass and user decision

**Files:**
- Modify: `tests/test_poc_planning_data.py`

**Interfaces:**
- Consumes: `validator.run(root: Path) -> None` and planning JSON files.
- Produces: mutation tests for CE-01 through CE-08, canonical formatting, retry, sure-hit, rewards, AI templates, and growth reachability.

- [ ] **Step 1: Add a `mutated_root()` test helper** that copies `docs/planning-data` into a temporary root.
- [ ] **Step 2: Add one test per false pass** and assert `PlanningDataError` for invalid patch fields/ticks, condition vocabulary, medical drift, AI vocabulary, reward values, 38-point reachability, dimension ranges, and empty node catalog.
- [ ] **Step 3: Add direct contract tests** for `poc_run_state_contract.json`, stacked sure-hit policy, reward option values, and canonical pretty printing.
- [ ] **Step 4: Run `python -m unittest tests.test_poc_planning_data -v`.**

Expected: new tests fail because the current validator and data do not implement these contracts.

### Task 2: Normalize planning data contracts

**Files:**
- Create: `docs/planning-data/poc_run_state_contract.json`
- Modify: `docs/planning-data/poc_balance_budget.json`
- Modify: `docs/planning-data/poc_martial_arts.json`
- Modify: `docs/planning-data/poc_enemy_duels.json`
- Modify: `docs/planning-data/poc_map_rewards.json`
- Modify: `docs/planning-data/poc_sanity_model.json`
- Modify: `docs/planning-data/README.md`

**Interfaces:**
- Produces: normalized execution fields, tick ledgers, patch rules, AI bundle templates, reward option IDs, node IDs, performance formulas, medical cross-references, and RunState transitions.

- [ ] **Step 1: Add effect and condition vocabularies** plus the stacked sure-hit consumption contract to the central budget file.
- [ ] **Step 2: Add `budget.ledger[]` entries** with `source_table`, `price_id`, `quantity`, and `derived_ticks` to every technique and ultimate.
- [ ] **Step 3: Add normalized card execution fields**: `category`, `resolution_phase`, `targeting_mode`, `attack.raw_powers`, `attack.range`, and `movement`.
- [ ] **Step 4: Add patch contract metadata** and ensure every 5/9-star patch has a valid derived tick delta within the 5-tick allowance plus 1-tick tolerance.
- [ ] **Step 5: Replace duel-owned training amounts and free-text context rewards** with a central `major_duel_standard_v1` option-set reference and a faction manual ID.
- [ ] **Step 6: Add executable AI profile fields**: numeric weights, condition modifiers, one-to-three-action bundle templates, targeting policy, fallback action, and score window.
- [ ] **Step 7: Add stable node catalog and four gap constraints** whose guaranteed focus supply totals 6 and target high-efficiency supply totals 14.
- [ ] **Step 8: Add performance dimension formulas** with 0–100 clamp and explicit input events.
- [ ] **Step 9: Add acquisition and duplicate conversion rules** for manuals at mastery 3.
- [ ] **Step 10: Pretty-print every planning JSON** with two-space indentation and a trailing newline.

### Task 3: Implement validator support and make RED tests GREEN

**Files:**
- Modify: `tools/check_poc_planning_data.py`
- Modify: `tests/test_poc_planning_data.py`

**Interfaces:**
- Produces: `validate_run_state`, ledger recalculation, patch application validation, reward/growth checks, AI template validation, map/node checks, grade formula checks, and cross-file medical validation.

- [ ] **Step 1: Add the run-state file to `FILES` and canonical JSON formatting validation.**
- [ ] **Step 2: Recalculate every budget ledger item** from the central price/condition tables and reject stale `derived_ticks`, components, calculated totals, and variances.
- [ ] **Step 3: Validate normalized card execution fields** and ensure legacy `damage/hits/range/move_range` values match the normalized contract.
- [ ] **Step 4: Apply each patch to a copied technique** and reject unknown fields, stale deltas, and deltas above 6 ticks.
- [ ] **Step 5: Validate all effect, condition, AI phase, and AI template vocabularies.**
- [ ] **Step 6: Validate reward option values 6 < 8 < 10**, duel references, duplicate conversion, and both 38-point paths.
- [ ] **Step 7: Validate gap/node IDs, numeric rewards, guaranteed 6, target 14, and deterministic seed policy.**
- [ ] **Step 8: Validate performance dimension weights/formulas and medical source deltas across files.**
- [ ] **Step 9: Validate paid retry 1/2/3 and stacked sure-hit persistence/consumption.**
- [ ] **Step 10: Run the unit suite and standalone validator until all tests pass.**

### Task 4: Synchronize canonical documents and entrypoints

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `START_HERE.md`
- Modify: `docs/02_COMBAT_RULES.md`
- Modify: `docs/03_CONTENT_CATALOG.md`
- Modify: `docs/04_ROADMAP.md`
- Modify: `docs/05_COMBAT_POC_SPEC.md`
- Modify: `docs/06_STARTING_FACTION_MASTERY_DATA.md`
- Modify: `docs/07_COMBAT_UI_SPEC.md`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Modify: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- Modify: `docs/10_COMBAT_PRESENTATION_PLAN.md`
- Modify: `docs/decisions/2026-07-26_FULL_ADVERSARIAL_REVIEW_LOOP.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- Modify: `[기획서]/00_프로젝트_허브/HANDOFF.md`
- Modify: `.github/reference-freshness.json`

**Interfaces:**
- Consumes: validated planning contracts.
- Produces: one current description of combat, growth, retry, rewards, AI, and remaining unverified evidence.

- [ ] **Step 1: Remove stale phase, 2–4 node, same-tick halving, and old fortitude language from root entrypoints.**
- [ ] **Step 2: Document RunState/CombatState, paid retry, and permanent-profile transaction boundaries.**
- [ ] **Step 3: Document stacked sure-hit and normalized card/AI contracts.**
- [ ] **Step 4: Document the three reward options and the two valid 38-point focus routes.**
- [ ] **Step 5: Mark all 14 TRPs implemented and all three UDRs approved; retain nine BUV findings as unverified.**
- [ ] **Step 6: Add freshness requirements that reject reintroduction of obsolete phrases.**

### Task 5: Return to REVIEW and verify regressions

**Files:**
- Restore: `.github/workflows/documentation-governance.yml` without the temporary artifact-upload step.
- Modify: PR #45 body and review trace.

**Interfaces:**
- Produces: final REVIEW evidence and no runtime changes.

- [ ] **Step 1: Run local unit tests and validator from a clean current-source copy.**
- [ ] **Step 2: Confirm changed paths exclude all protected runtime paths.**
- [ ] **Step 3: Synchronize the single non-conflicting main commit before final judgment.**
- [ ] **Step 4: Run PR Validation and inspect every step.**
- [ ] **Step 5: Re-run CE-01 through CE-08 and normal/boundary regressions.**
- [ ] **Step 6: Record `PASS_WITH_FOLLOWUP` if static/reference/regression pass while Godot, Windows, accessibility, performance, and human play remain unverified.**
