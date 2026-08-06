# Ten Manual Product Validation Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build reproducible automated product evidence for the ten-manual UI·AI runtime on Godot 4.7.1, including 50 mastery scenarios, Windows export/runtime evidence, resolution/input/accessibility checks, and strict separation of automated evidence from human or local-device validation.

**Architecture:** Keep the existing ten-manual runtime and UI·AI implementation unchanged unless a product scenario exposes a defect. Add a machine-readable gate contract, a Godot scenario verifier, a Python evidence validator with adversarial fixtures, and an isolated GitHub Actions workflow that produces a Windows artifact plus JSON evidence. Canonical documents consume the evidence states but never convert CI evidence into local Windows, physical input, accessibility-user, release-performance, or human-playtest PASS.

**Tech Stack:** Godot 4.7.1/GDScript, Python 3.11+, PowerShell 7, GitHub Actions, JSON, Markdown.

## Global Constraints

- Current platform authority is PC; mobile remains `MOBILE_CONSIDERATION_ONLY`.
- Product baseline is `8832d0f54062ce999a5a9c5238f704854f96a0b1`; implementation starts from approved spec head `f5756d10f3d1a04f1124530e347f5550244e66c1`.
- PR #92 remains Open, Draft, unmerged, and stacked on PR #91.
- Automated completion may reach only `PARTIAL_AUTOMATED_COMPLETE`.
- `windows_local_render`, `gamepad_physical`, `accessibility_user`, `release_performance`, and `human_step14` remain `NOT_RUN` without direct evidence.
- No final damage, cost, loadout economy, opponent difficulty curve, T1, MVP, merge, or Draft-release authority is created.
- Runtime tests must derive the ten-manual roster and display names from the registry/manifest rather than duplicate a second roster.
- Any product defect is fixed through RED→GREEN with existing basic-action, public-state AI, prepare, auto-placement, and action-selection regressions preserved.

---

### Task 1: Gate contract and evidence validator RED→GREEN

**Files:**
- Create: `docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json`
- Create: `tools/validate_ten_manual_product_gate.py`
- Create: `tests/test_ten_manual_product_gate.py`
- Create: `.github/workflows/validate-ten-manual-product-gate.yml`

**Interfaces:**
- Consumes: `data/cards/martial_manual_cards.json`, `docs/superpowers/specs/2026-08-06-ten-manual-product-validation-gate-design.md`, environment variable `GITHUB_SHA`.
- Produces: `validate_contract(root: Path, evidence_path: Path | None, expected_sha: str | None) -> list[str]`; exit code `0` only when no validation errors exist.

- [ ] **Step 1: Write failing validator tests**

```python
class ProductGateValidationTests(unittest.TestCase):
    def test_contract_requires_fifty_scenarios(self):
        contract = load_contract_fixture()
        contract["scenario_matrix"] = contract["scenario_matrix"][:-1]
        self.assertIn("scenario_count", validate_mutated_contract(contract))

    def test_zero_participants_cannot_claim_human_pass(self):
        evidence = valid_evidence_fixture()
        evidence["human_step14"] = "PASS"
        evidence["participant_count"] = 0
        self.assertIn("human_step14", validate_mutated_evidence(evidence))

    def test_ci_runtime_cannot_claim_local_windows_pass(self):
        evidence = valid_evidence_fixture()
        evidence["windows_local_render"] = "PASS"
        self.assertIn("windows_local_render", validate_mutated_evidence(evidence))
```

- [ ] **Step 2: Add the workflow with only the Python RED test**

Run in workflow:

```yaml
- run: python -m unittest tests.test_ten_manual_product_gate -v
- run: python tools/validate_ten_manual_product_gate.py --root . --expected-sha "${{ github.sha }}"
```

Expected: FAIL because the contract and validator do not exist.

- [ ] **Step 3: Implement the contract**

The contract must contain:

```json
{
  "decision_id": "TEN_MANUAL_PRODUCT_VALIDATION_GATE",
  "godot_version": "4.7.1",
  "platform": "windows-x86_64",
  "viewports": [[1280, 800], [1440, 900], [1920, 1080]],
  "mastery_levels": [3, 5, 7, 9, 10],
  "required_scenario_count": 50,
  "allowed_product_gate": ["PARTIAL_AUTOMATED_COMPLETE", "FAIL", "BLOCKED"],
  "forced_not_run": ["windows_local_render", "gamepad_physical", "accessibility_user", "release_performance", "human_step14"]
}
```

Generate `scenario_matrix` from the exact ten manual IDs in `data/cards/martial_manual_cards.json`, five mastery levels each.

- [ ] **Step 4: Implement the validator**

Validate exact Decision, Godot version, 10 unique manuals, five exact mastery levels, 50 unique scenarios, allowed state vocabulary, evidence SHA equality, required artifact metadata, zero-participant human state, CI/local evidence separation, and performance-environment comparability.

- [ ] **Step 5: Run RED→GREEN verification**

```bash
python -m unittest tests.test_ten_manual_product_gate -v
python tools/validate_ten_manual_product_gate.py --root .
```

Expected: all tests PASS and validator prints `TEN_MANUAL_PRODUCT_GATE_CONTRACT_OK`.

- [ ] **Step 6: Commit**

```bash
git add docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json tools/validate_ten_manual_product_gate.py tests/test_ten_manual_product_gate.py .github/workflows/validate-ten-manual-product-gate.yml
git commit -m "test: define ten-manual product gate contract"
```

---

### Task 2: Fifty-scenario Godot product verifier RED→GREEN

**Files:**
- Create: `tests/verify_ten_manual_product_gate.gd`
- Modify only if a real defect is exposed: `src/ui/action_selection/action_view_model_adapter.gd`, `src/ui/action_selection/action_selection_dock.gd`, `src/combat/combat_resolution_engine_ten_manuals.gd`, or the current ten-manual registry/pipeline files.
- Modify: `.github/workflows/validate-ten-manual-product-gate.yml`

**Interfaces:**
- Consumes: `MartialManualRegistry`, `ActionViewModelAdapter`, `ActionSelectionDock`, `TenManualCombatResolutionEngine`, gate contract JSON.
- Produces: `artifacts/ten-manual-product-validation/product_scenarios.json` with 50 results and aggregate timings; process exits `1` for any failure.

- [ ] **Step 1: Write the failing GDScript verifier**

The script must use a `failures: Array[String]` accumulator and explicit `quit(1)`.

```gdscript
for manual_id in registry.manual_ids():
    for mastery in [3, 5, 7, 9, 10]:
        var cards := registry.cards_for_manual(manual_id, mastery)
        _expect_unlock_contract(manual_id, mastery, cards)
        _expect_ui_supply(manual_id, mastery)
        _expect_place_and_resolve(manual_id, mastery, cards)
_expect_total(50)
_finish()
```

Required assertions:
- 3★ technique1 available and executable.
- 5★ same technique1 card ID plus exactly one approved overlay.
- 7★ technique2 added without removing technique1.
- 9★ same technique2 card ID plus exactly one non-branching overlay.
- 10★ signature ultimate appears beside legacy ultimates and executes.
- player/enemy loadout separation and no private-plan AI input.
- representative semantics for all ten manuals.

- [ ] **Step 2: Run verifier to confirm RED**

```bash
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/verify_ten_manual_product_gate.gd
```

Expected: FAIL because evidence generation or one required product interface is missing.

- [ ] **Step 3: Implement only the missing product-test interfaces or fix exposed defects**

Do not add a second runtime. Prefer small test-facing read methods such as:

```gdscript
func get_current_martial_entries_for_validation() -> Array[Dictionary]:
    return _martial_entries.duplicate(true)
```

Any runtime behavior fix must preserve existing tests and receive its own assertion in the new verifier.

- [ ] **Step 4: Generate deterministic scenario evidence**

Write JSON with:

```json
{
  "scenario_count": 50,
  "passed": 50,
  "failed": 0,
  "manuals": 10,
  "mastery_levels": [3, 5, 7, 9, 10],
  "elapsed_ms": 0,
  "results": []
}
```

- [ ] **Step 5: Run GREEN and adjacent regressions**

```bash
godot --headless --path . --script res://tests/verify_ten_manual_product_gate.gd
godot --headless --path . --script res://tests/verify_ten_manual_ui_ai_adoption.gd
godot --headless --path . --script res://tests/verify_combat_board.gd
godot --headless --path . --script res://tests/verify_combat_action_selection_integration.gd
```

Expected: all exit `0`, no parser/runtime errors.

- [ ] **Step 6: Commit**

```bash
git add tests/verify_ten_manual_product_gate.gd .github/workflows/validate-ten-manual-product-gate.yml src
git commit -m "test: verify fifty ten-manual product scenarios"
```

---

### Task 3: Resolution, synthetic input, and accessibility evidence

**Files:**
- Create: `tests/verify_ten_manual_product_viewports.gd`
- Create: `tests/verify_ten_manual_product_input.gd`
- Modify: `.github/workflows/validate-ten-manual-product-gate.yml`

**Interfaces:**
- Produces: `artifacts/ten-manual-product-validation/ui_evidence.json` with viewport and input results.

- [ ] **Step 1: Write viewport RED tests**

Instantiate the product combat scene at `1280×800`, `1440×900`, and `1920×1080`. Assert non-zero clickable rects, visible martial/ultimate tabs, visible timeline/proceed control, and no full-rect escape from viewport.

- [ ] **Step 2: Write synthetic-input RED tests**

Use InputMap actions for keyboard navigation/accept/cancel/proceed and InputEventMouseButton for tab/manual/card placement/removal. Assert focus progression and resulting slot state rather than raw key codes.

- [ ] **Step 3: Add accessibility assertions**

Assert every critical button has text or accessible description, locked/selected/failure states have non-color text/icon information, and result/review cause text exists with animation/audio disabled.

- [ ] **Step 4: Run RED, implement minimal fixes, then GREEN**

```bash
godot --headless --path . --script res://tests/verify_ten_manual_product_viewports.gd
godot --headless --path . --script res://tests/verify_ten_manual_product_input.gd
```

- [ ] **Step 5: Commit**

```bash
git add tests/verify_ten_manual_product_viewports.gd tests/verify_ten_manual_product_input.gd .github/workflows/validate-ten-manual-product-gate.yml src scenes
git commit -m "test: add ten-manual viewport input accessibility evidence"
```

---

### Task 4: Windows export and CI runtime evidence

**Files:**
- Create: `export_presets.cfg`
- Create: `scripts/windows/run_ten_manual_product_validation.ps1`
- Modify: `.github/workflows/validate-ten-manual-product-gate.yml`

**Interfaces:**
- Produces: `build/windows/TenPacesHiddenMoves.exe`, `.pck`, logs, and `product_validation_evidence.json`.

- [ ] **Step 1: Add a Windows Desktop export preset**

Use preset name `Windows Desktop Product Validation`, runnable export, x86_64 architecture, and output `build/windows/TenPacesHiddenMoves.exe`. Do not add signing or store configuration.

- [ ] **Step 2: Write the PowerShell runner before enabling export GREEN**

The script must:
- require `-Executable`, `-HeadSha`, `-OutputDirectory`;
- start the process with deterministic validation arguments;
- enforce a 120-second timeout;
- capture exit code, elapsed time, peak working set, executable/PCK/artifact sizes;
- preserve stdout/stderr;
- write evidence with CI/local/human states separated;
- exit non-zero on launch failure, timeout, non-zero process, missing files, or mismatched SHA.

- [ ] **Step 3: Configure the Windows workflow job**

Use `windows-latest`, Godot 4.7.1 with export templates, Python 3.12, and `actions/upload-artifact@v4`. Export first, run the executable through PowerShell, validate evidence, then upload with `if: always()`.

- [ ] **Step 4: Run the workflow and verify Windows RED/GREEN**

Expected first RED: missing/invalid preset, runtime argument, or evidence. Implement the smallest fix, then require successful export, runtime exit `0`, validator success, and downloadable artifact.

- [ ] **Step 5: Commit**

```bash
git add export_presets.cfg scripts/windows/run_ten_manual_product_validation.ps1 .github/workflows/validate-ten-manual-product-gate.yml
git commit -m "ci: add Windows ten-manual product evidence"
```

---

### Task 5: Evidence report and STEP 14 reactivation

**Files:**
- Create: `docs/decisions/2026-08-06_TEN_MANUAL_PRODUCT_VALIDATION_GATE.md`
- Create: `docs/evidence/TEN_MANUAL_PRODUCT_VALIDATION_EVIDENCE.md`
- Modify: `docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md`
- Modify: `docs/research/STEP14_REPEAT_POC_RESULTS_TEMPLATE.md`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `[기획서]/00_프로젝트_허브/ROADMAP.md`
- Modify: `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`
- Modify: lifecycle/reference regression tests that intentionally enforce the prior Gate.

**Interfaces:**
- Consumes: exact successful head and Actions run/artifact IDs.
- Produces: current state `PRODUCT_VALIDATION_AUTOMATED / PARTIAL_AUTOMATED_COMPLETE` only when Windows and Ubuntu product evidence pass.

- [ ] **Step 1: Add failing canonical-state tests**

Require the new Decision, contract, evidence report, `REACTIVATED_BY_USER`, locked build SHA, participant count `0`, and all human/local axes `NOT_RUN`.

- [ ] **Step 2: Write canonical documents and evidence report**

Record exact run IDs and evidence values. Do not copy generated artifact JSON into repository authority; summarize and link its metadata.

- [ ] **Step 3: Update STEP 14 without fabricating results**

Protocol becomes ready/locked; results template remains five `NOT_RUN` participant rows and product gate remains partial.

- [ ] **Step 4: Run canonical and lifecycle tests**

```bash
python tools/check_canonical_reference_freshness.py --root . --config .github/reference-freshness.json
python tools/check_postmerge_canon_lifecycle.py --root .
python -m unittest tests.test_project_governance -v
python -m unittest tests.test_ten_manual_product_gate -v
```

- [ ] **Step 5: Commit**

```bash
git add docs '[기획서]' tools tests
git commit -m "docs: record automated ten-manual product evidence"
```

---

### Task 6: Final exact-head regression, PR, and Google Sheet sync

**Files:**
- Modify only if required by validation: `.github/workflows/full-validation.yml`, PR #92 metadata, Google Sheet rows.

**Interfaces:**
- Produces: one exact SHA shared by PR body and Sheets `00·01·02·03·04·12·15·30·40·41·99`.

- [ ] **Step 1: Run exact-head workflows**

Require PASS for the new product workflow, PR Validation, Full Validation, UI·AI adoption, runtime foundation, manuals, budget, 5/7/9 mastery, public-state AI, observation, grade, derived stats, and Base adoption.

- [ ] **Step 2: Inspect artifacts and review state**

Verify artifact files/metadata, no unresolved review threads, no submitted change-request review, Draft/open/unmerged state, and unchanged PR #91 base.

- [ ] **Step 3: Sync Google Sheet after final SHA is stable**

Update existing `03_무공서_무학` rows only for runtime evidence status/Decision/SHA. Add separate current Decision, audit, test-quality, growth/system, and eight-column change-history rows. Preserve prior UI·AI evidence history.

- [ ] **Step 4: Read back every written row**

Confirm Decision and full exact SHA appear together in every required tab.

- [ ] **Step 5: Update PR #92 body**

Report automatic evidence as partial only and retain `NOT_RUN` for local Windows, physical gamepad, accessibility user, release performance, human STEP 14, balance, T1, and MVP.

- [ ] **Step 6: Final verification report**

Use `verification-before-completion`; report exact SHA, workflow run IDs, artifact ID/name, Sheet readback, PR Draft/stack status, and remaining product gates.
