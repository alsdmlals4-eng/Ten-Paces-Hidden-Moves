# Screen Asset Coverage Inventory Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a machine-checkable current visual inventory that distinguishes active runtime image needs from production references and future release work.

**Architecture:** A JSON record owns the exact Screen × Object × State × Variant mapping. A concise Markdown projection explains the outcome to humans, while a focused Python regression prevents future docs from turning a planned surface into an automatic image-generation task.

**Tech Stack:** JSON, Markdown, Python `unittest`, Godot source-path evidence.

**Spec:** `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md#16`, `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md`, GitHub Issue #243.

## Global Constraints

- Use `res://scenes/run/vertical_slice_shell.tscn` and real GDScript consumers as runtime truth.
- Do not create, promote, or route an image in this task.
- New images require canon review → text brief → explicit user approval → exactly one result → review.
- Existing Draft PRs #199 and #200 remain read-only.
- Report unrun Windows, Android, and human validation as `NOT_RUN`.

---

### Task 1: Add the consumer-first regression

**Files:**
- Modify: `tests/test_visual_consumer_asset_production_policy.py`
- Test: `tests/test_visual_consumer_asset_production_policy.py::VisualConsumerAssetProductionPolicyTests.test_current_screen_inventory_maps_actual_consumers_before_production`

**Interfaces:**
- Consumes: `docs/planning-data/current_screen_visual_coverage_inventory_20260828.json`
- Produces: regression assertions for policy, P0 gap count, current combat consumer, code-rendered Main, and deferred release state.

- [ ] **Step 1: Write the failing test**

```python
inventory = json.loads(SCREEN_VISUAL_INVENTORY.read_text(encoding="utf-8"))
assert inventory["current_p0_runtime_blocking_image_gaps"] == 0
assert inventory["automatic_image_generation_from_inventory_gaps"] is False
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m unittest tests.test_visual_consumer_asset_production_policy.VisualConsumerAssetProductionPolicyTests.test_current_screen_inventory_maps_actual_consumers_before_production -v`

Expected: `FileNotFoundError` because the structured inventory is not yet present.

- [ ] **Step 3: Add the minimal structured inventory**

Create `docs/planning-data/current_screen_visual_coverage_inventory_20260828.json` with all P0 screens, exact current consumer paths, state variants, status, destinations, and production blockers. Include future Pause/Failure/Codex/Release rows as `NOT_APPLICABLE_CURRENT_VERTICAL_SLICE` or `RELEASE_BLOCKED_UNVERIFIED`.

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m unittest tests.test_visual_consumer_asset_production_policy.VisualConsumerAssetProductionPolicyTests.test_current_screen_inventory_maps_actual_consumers_before_production -v`

Expected: `OK`.

- [ ] **Step 5: Commit**

```bash
git add tests/test_visual_consumer_asset_production_policy.py docs/planning-data/current_screen_visual_coverage_inventory_20260828.json
git commit -m "docs: add consumer-first screen visual inventory"
```

### Task 2: Publish the human-readable inventory and correct stale handoff state

**Files:**
- Create: `docs/20_SCREEN_VISUAL_COVERAGE_INVENTORY_20260828.md`
- Modify: `docs/planning-data/current_visual_production_handoff_20260826.json`
- Modify: `docs/planning-data/current_user_planning_status.json`
- Test: `tests/test_visual_consumer_asset_production_policy.py`

**Interfaces:**
- Consumes: Task 1 JSON and merged-main evidence for Issue #240.
- Produces: a human summary linked from current visual handoff state.

- [ ] **Step 1: Write the failing status assertion**

```python
assert inventory["superseded_handoff_correction"]["status"] == "ISSUE_240_MERGED_MAIN_D9AE822"
```

- [ ] **Step 2: Run the focused test**

Run: `python -m unittest tests.test_visual_consumer_asset_production_policy -v`

Expected: a failure until the handoff status and its new inventory owner agree.

- [ ] **Step 3: Make the minimal documentation correction**

Set the old bounded handoff status to `ISSUE_240_MERGED_MAIN_D9AE822`; make the inventory JSON the detail owner; set the planning handoff to `SCREEN_VISUAL_COVERAGE_INVENTORY_COMPLETE_AWAITING_CONCRETE_CONSUMER_ASSET` without changing runtime or art status.

- [ ] **Step 4: Run validation**

Run: `python -m unittest tests.test_visual_consumer_asset_production_policy -v; python -m json.tool docs/planning-data/current_screen_visual_coverage_inventory_20260828.json > $null; git diff --check`

Expected: all tests pass, JSON parses, and `git diff --check` has no output.

- [ ] **Step 5: Commit**

```bash
git add docs/20_SCREEN_VISUAL_COVERAGE_INVENTORY_20260828.md docs/planning-data/current_visual_production_handoff_20260826.json docs/planning-data/current_user_planning_status.json
git commit -m "docs: publish screen visual coverage audit"
```

### Task 3: Merge and project the verified result

**Files:**
- Read: GitHub PR checks and main readback
- Update after merge: Project Home and Visual Bible Notion pages

**Interfaces:**
- Consumes: merged current-task PR and the Task 2 record.
- Produces: GitHub main readback plus Project Notion projection, without attaching any candidate image.

- [ ] **Step 1: Open a current-task PR**

Run: `gh pr create --base main --head codex/screen-asset-coverage-20260828 --title "docs: inventory visual coverage by actual screen consumers" --body "Closes #243. Adds only a consumer-first coverage inventory, regression, and stale handoff correction; no image is generated, promoted, or routed."`

- [ ] **Step 2: Verify and review the PR**

Run the Task 2 validation, inspect `gh pr checks <number>`, and obtain an independent review. Resolve only task-scoped findings.

- [ ] **Step 3: Merge after checks are green**

Run: `gh pr merge <number> --squash --delete-branch`.

Expected: GitHub reports merged and current `main` contains the inventory commit.

- [ ] **Step 4: Read back main and Notion destinations**

Fetch the Project Home and Visual Bible before update, append a concise statement that P0 image gaps are zero and link Issue #243, then fetch both pages again. Do not attach or promote a candidate asset.

- [ ] **Step 5: Commit is not applicable**

The repository commit is already merged in Step 3; Notion readback is external evidence only.

## Self-Review

- Spec coverage: Task 1 covers actual Screen × Object × State × Variant data; Task 2 separates runtime, reference, and release status; Task 3 reads back both durable owners.
- Placeholder scan: no executable task contains a deferred implementation placeholder.
- Type consistency: the test reads the exact JSON fields produced in Task 1; Task 2 only updates documented status strings.
