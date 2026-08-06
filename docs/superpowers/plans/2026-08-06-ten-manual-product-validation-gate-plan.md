# Ten-Manual Product Validation Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build reproducible automated product evidence for the ten martial manuals without overstating local Windows, accessibility-user, release-performance, or human-playtest results.

**Architecture:** Keep the existing ten-manual registry, UI, AI, and combat pipeline unchanged as the product-under-test. Add a data-driven 50-scenario Godot validator, a Windows export/runtime evidence runner, a strict Python evidence validator, and one workflow that preserves every evidence axis separately. Existing product-validation files are reviewed and extended rather than duplicated.

**Tech Stack:** Godot 4.7.1/GDScript, Python 3.11+, PowerShell 7, GitHub Actions, JSON evidence contracts.

## Global Constraints

- PC is the current target platform; mobile remains consideration-only.
- Godot version is exactly `4.7.1` for this gate.
- Scenario matrix is exactly 10 manuals × mastery `3,5,7,9,10` = 50 scenarios.
- Maximum automated gate status is `PARTIAL_AUTOMATED_COMPLETE` while local Windows render, physical gamepad, accessibility-user, release-performance, and STEP 14 remain `NOT_RUN`.
- The gate must not alter final damage/cost values, loadout economy, enemy difficulty curves, or balance conclusions.
- Existing basic actions, generic ultimates, public-state AI boundaries, `[준비]`, and auto-placement must remain regression-protected.
- Every generated evidence payload must carry the exact checked-out Git SHA.

---

### Task 1: Inventory and RED Contract

**Files:**
- Create: `docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json`
- Create: `tools/validate_ten_manual_product_gate.py`
- Create: `tests/test_validate_ten_manual_product_gate.py`

**Interfaces:**
- Consumes: `data/cards/martial_manual_cards.json`, ten manual runtime files, approved UI/AI/runtime Decisions.
- Produces: `validate_contract(contract, evidence) -> list[str]` and CLI exit code `0` only when all evidence-state constraints pass.

- [ ] Write failing tests for missing contract, 49 scenarios, duplicate mastery, wrong SHA, participant count 0 with human PASS, Windows CI masquerading as local render PASS, and cross-environment performance comparison.
- [ ] Run the new unit test and verify failure because the contract and validator do not yet satisfy the API.
- [ ] Implement the smallest validator and approved contract that satisfy the tests.
- [ ] Run unit tests and direct CLI validation.
- [ ] Commit `test: define ten-manual product gate evidence contract`.

### Task 2: 50-Scenario Godot Product Validator

**Files:**
- Review/modify: `src/validation/ten_manual_product_scenario_validator.gd`
- Review/modify: `src/validation/ten_manual_product_validation_bootstrap.gd`
- Create: `tests/verify_ten_manual_product_gate.gd`

**Interfaces:**
- Consumes: `MartialManualRegistry`, ActionSelectionDock, TenManualCombatResolutionEngine.
- Produces: `build_runtime_contract() -> Dictionary`, `run(contract) -> Dictionary` with `scenario_count=50`, per-scenario UI/unlock/overlay/execution results, timing, and failures.

- [ ] Write a failing Godot verifier requiring exactly 50 scenarios and all five mastery milestones for every manifest manual.
- [ ] Verify RED through a dedicated workflow step.
- [ ] Implement or repair the data-driven scenario validator; do not hardcode display names as the source roster.
- [ ] Verify Star3 unlock, Star5 single overlay on technique1, Star7 unlock, Star9 single overlay on technique2, Star10 ultimate coexistence and execution.
- [ ] Add representative semantic checks for all ten manuals and stable `quit(1)` on any failure.
- [ ] Run Godot import, focused verifier, UI/AI adoption regression, and runtime-foundation regression.
- [ ] Commit `test: validate fifty ten-manual product scenarios`.

### Task 3: Resolution, Input, and Accessibility Automation

**Files:**
- Create: `tests/verify_ten_manual_product_viewports.gd`
- Create: `tests/verify_ten_manual_product_input.gd`
- Modify only if required: UI accessibility metadata or focus-neighbor files touched by a failing test.

**Interfaces:**
- Consumes: product combat scene and ActionSelectionDock.
- Produces: JSON-compatible results for viewport `1280x800`, `1440x900`, `1920x1080`, keyboard/mouse synthetic paths, InputMap presence, clipping/focus failures.

- [ ] Write failing tests for off-screen critical controls, zero-size click targets, broken focus traversal, empty essential labels, color-only lock/failure indicators, and inability to complete keyboard/mouse placement flow.
- [ ] Run and capture RED.
- [ ] Apply only targeted UI/focus fixes needed by the tests.
- [ ] Run viewport, keyboard, mouse, existing accessibility, and action-selection regressions.
- [ ] Commit `test: add ten-manual product viewport and input validation`.

### Task 4: Windows Export and Runtime Evidence

**Files:**
- Review/modify: `export_presets.cfg`
- Create: `scripts/windows/run_ten_manual_product_validation.ps1`
- Create: `.github/workflows/validate-ten-manual-product-gate.yml`

**Interfaces:**
- Consumes: Godot 4.7.1 Windows export templates, bootstrap environment variables.
- Produces: Windows `.exe`/`.pck`, `product_scenarios.json`, `product_validation_evidence.json`, logs, timing, peak working set, artifact size.

- [ ] Add a workflow RED that fails while evidence runner/artifact metadata is incomplete.
- [ ] Install Godot 4.7.1 and matching export templates; export preset `Windows Desktop Product Validation`.
- [ ] PowerShell runner launches the exported process with `TEN_MANUAL_PRODUCT_VALIDATION=1`, enforces timeout, records exit code, elapsed time, peak working set, file sizes, and exact SHA.
- [ ] Generate evidence with separate fields for `windows_ci_runtime`, `windows_local_render`, `accessibility_user`, `release_performance`, and `human_step14`.
- [ ] Run Python validator before artifact upload.
- [ ] Upload executable, PCK, scenario report, evidence JSON, and logs even on validation failure when possible.
- [ ] Commit `ci: add ten-manual Windows product validation`.

### Task 5: Canon and STEP 14 Evidence Boundaries

**Files:**
- Create: `docs/decisions/2026-08-06_TEN_MANUAL_PRODUCT_VALIDATION_GATE.md`
- Create: `docs/evidence/TEN_MANUAL_PRODUCT_VALIDATION_EVIDENCE.md`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Modify: `docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md`
- Modify: `docs/research/STEP14_REPEAT_POC_RESULTS_TEMPLATE.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `[기획서]/00_프로젝트_허브/ROADMAP.md`
- Modify: `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`

**Interfaces:**
- Consumes: exact-head workflow evidence.
- Produces: `PRODUCT_VALIDATION_AUTOMATED / PARTIAL_AUTOMATED_COMPLETE` only after Windows export/runtime and all automated checks pass; preserves human/local/release axes as `NOT_RUN`.

- [ ] Add lifecycle regression tests that reject `PASS`, `T1_GREENLIGHT`, `MVP_COMPLETE`, local Windows PASS, or human PASS without corresponding evidence.
- [ ] Update canon and STEP 14 protocol to `REACTIVATED_BY_USER`, participant count 0, locked implementation SHA, and `human_step14: NOT_RUN`.
- [ ] Record exact evidence and remaining gates without claiming physical-device or human completion.
- [ ] Run governance, reference-freshness, product-gate validator, PR Validation, and Full Validation.
- [ ] Commit `docs: record partial automated product validation evidence`.

### Task 6: Exact-Head Verification and Sheet Sync

**Files:**
- Update PR #92 body/title.
- Google Sheet tabs: `00`, `01`, `02`, `03_무공서_무학`, `04`, `12`, `15`, `30`, `40`, `41`, `99`.

**Interfaces:**
- Consumes: final exact head and completed workflow evidence.
- Produces: identical Decision ID and exact SHA in GitHub canon, PR, and Sheets.

- [ ] Confirm every required workflow on the final exact head is completed successfully.
- [ ] Download/read the product-validation artifact and verify its embedded SHA and evidence axes.
- [ ] Confirm review submissions and unresolved threads are zero or contain no P0/P1.
- [ ] Sync Sheets only after exact-head validation; preserve `03_무공서_무학` content and append product-validation status rather than replacing martial design data.
- [ ] Read back every written Sheet range.
- [ ] Keep PR #92 Draft, open, unmerged, and stacked on PR #91.
- [ ] Commit no further code after Sheet exact SHA is recorded; if head moves, repeat exact-head verification and Sheet sync.

## Plan Self-Review

- Spec coverage: Windows export/runtime, 50 scenarios, resolution/input/accessibility automation, performance baseline, evidence validation, STEP 14 boundaries, canon, PR, and Sheet sync are each assigned.
- Placeholder scan: no `TBD`, `TODO`, or unspecified implementation step remains.
- Type consistency: evidence uses one JSON contract and one exact SHA across Godot, PowerShell, Python, docs, PR, and Sheets.
