# Current Phase I–VI Router Correction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconcile Ten Paces `ACTIVE_CONTEXT.md` with the already-merged first-five-duel Phase I–VI implementation while preserving evidence ceilings and future-mutation gates.

**Architecture:** Treat `ACTIVE_CONTEXT.md` as the mutable live-state router and keep exact PR/SHA history in the historical evidence section. Update the existing discovery regression first so the stale pre-implementation router fails, then make the smallest documentation correction that satisfies the current GitHub main + Notion truth without changing gameplay/runtime files.

**Tech Stack:** Markdown, Python `unittest`, GitHub Actions documentation-governance workflow.

**Spec:** GitHub Issue #187 — `[P0][AUTHORITY-DRIFT] Active Context를 Phase I–VI current implementation 상태로 동기화`.

## Global Constraints

- Preserve 10-cell battlefield, 3/3/4 combat, hidden-information, balance, AI-information, and platform rules unchanged.
- Preserve Windows-visible local Human usability, Android physical device, Human fun/readability/immersion, and final Visual/VFX/Audio as `NOT_RUN` until actual evidence exists.
- Distinguish the already-authorized-and-merged Phase I–VI implementation from authorization for any future new product mutation.
- Keep exact historical SHA/PR evidence outside the live current-state block.
- Re-read current GitHub main, open PRs, and exact Notion project state before completion claims.

---

### Task 1: Lock the current-state contract with RED→GREEN

**Files:**
- Modify: `tests/test_current_discovery_contract.py`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`

**Interfaces:**
- Consumes: `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`, merged PR #183 implementation evidence, current Notion TEN_PACES Home.
- Produces: an unambiguous live router that states Phase I–VI is implemented while future product mutation still requires a fresh gate.

- [ ] **Step 1: Write the failing regression expectation**

Update `test_active_context_separates_live_state_from_observed_snapshots` to require:

```python
self.assertIn("product_stage: FIRST_FIVE_DUEL_PHASE_I_VI_IMPLEMENTED", current_section)
self.assertIn("phase_i_vi_implementation: AUTHORIZED_AND_MERGED", current_section)
self.assertIn("future_product_mutation_authorized: false", current_section)
self.assertIn("human_validation: NOT_RUN", current_section)
self.assertIn("android_validation: NOT_RUN", current_section)
self.assertNotIn("product_implementation_authorized: false", current_section)
self.assertNotIn("product_stage: VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_COMPLETE_HANDOFF_READY", current_section)
```

- [ ] **Step 2: Run the focused test and confirm RED**

Run:

```bash
python -m unittest tests.test_current_discovery_contract.CurrentDiscoveryContractTests.test_active_context_separates_live_state_from_observed_snapshots -v
```

Expected: FAIL because the current `ACTIVE_CONTEXT.md` still exposes the pre-implementation handoff state.

- [ ] **Step 3: Apply the minimal router correction**

In the live `## 현재 기준` block:

```yaml
product_stage: FIRST_FIVE_DUEL_PHASE_I_VI_IMPLEMENTED
phase_i_vi_implementation: AUTHORIZED_AND_MERGED
future_product_mutation_authorized: false
human_validation: NOT_RUN
android_validation: NOT_RUN
```

Retain existing automated evidence and visual-generation gate, and rewrite the explanatory paragraph so Phase I–VI historical authorization is not confused with permission for a new mutation.

- [ ] **Step 4: Re-run focused and governance tests**

Run:

```bash
python -m unittest tests.test_current_discovery_contract -v
```

Expected: PASS. Then rely on exact-head GitHub Actions PR Validation for the repository-wide governance suite.

- [ ] **Step 5: Verify scope and evidence ceiling**

Confirm changed paths are limited to this plan, the discovery regression, and `ACTIVE_CONTEXT.md`; no product runtime/gameplay file changes. Re-read Notion TEN_PACES Home and GitHub current branch before opening the PR.
