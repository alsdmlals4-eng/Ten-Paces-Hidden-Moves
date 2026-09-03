# Human Blueprint Additive Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish a 46-page current human Master GDD that preserves the prior 36-page blueprint in full and adds the approved frontal-duel visual and wireframe layer.

**Architecture:** A new PDF assembler owns the current human-master publication. It creates one current cover, reuses the exact 36-page baseline as preserved source pages, builds the nine functional visual pages from the existing frontal-duel generator into a temporary PDF, and interleaves those pages beside the relevant master sections. Source ownership records point to the assembled PDF; the short focused PDF ceases to be a competing publication.

**Tech Stack:** Python 3, ReportLab, pypdf, Pillow, Poppler rendering, Python unittest, Git/GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-09-02-human-blueprint-additive-recovery-design.md`

## Revision 2 · 2026-09-03 incremental expansion

**Scope refinement:** retain all initial 46-page recovery obligations and
extend the addendum to 52 pages. `FM` means **Flow Map**. The PDF must now
carry project goals, systems, case statuses, stepwise Flow Maps, distinct
preparation/combat wireframes, and an image-production board. It must show
the source lineage `whole scene → separated candidate modules → composed
Godot runtime` without falsely treating a superseded exploratory image as a
canon asset.

**Actual evidence inputs:**

| Input | State | PDF role |
|---|---|---|
| `FRONTAL_COURTYARD_DUEL_SEQUENCE_BOARD_20260902_v2` | `SUPERSEDED_GENERATED_EXPLORATION` | whole-scene visual/provenance predecessor only |
| `FRONTAL_COURTYARD_DUEL_BACKGROUND_02_v1`, banner, two battlers | `USER_FINAL_LOCKED → CANON_REGISTERED → IMPLEMENTED → MACHINE_RUNTIME_VERIFIED` | separated-module board |
| `TEN-RVC-20260903-003…006` | `MACHINE_RUNTIME_CAPTURE` | preparation, hover-detail, plan-lock, and current-action runtime evidence |

**Out of scope:** no new raster generation, no user-final-lock inference, no
asset promotion, no runtime/game-rule mutation, and no deletion of the
preserved 36-page source. The existing untracked Godot `.import` files remain
outside this task and are not cleanup targets.

### Revision Task A: add a rendered output regression before implementation

**Files:**

- Modify: `tests/test_human_game_blueprint_profile.py`

- [x] Add a rendered-PDF test that fails when the current publication has fewer
  than 52 pages or lacks the requested goal/system, Flow Map, preparation and
  combat wireframes, image pipeline, and case-status headings.
- [x] Run only that test first; it failed at 46 pages before implementation.

### Revision Task B: expand the additive source without breaking baseline order

**Files:**

- Modify: `tools/build_frontal_duel_visual_blueprint_pdf.py`
- Modify: `tools/build_human_game_blueprint_pdf.py`

- [ ] Make the focused builder provide 16 pages: one non-current cover plus 15
  reusable insertion pages.
- [ ] Preserve each of the original 36 pages in exact source order, and
  interleave all 15 additions by their existing subject boundary.
- [ ] Use only declared/repository-read visual inputs and label every evidence
  ceiling in the rendered page where it matters.

### Revision Task C: derive one coherent planning surface

**Files:**

- Modify: `docs/design/PROJECT_AI_PRODUCTION_SPEC.md`
- Modify: `docs/DOCUMENTATION_MAP.md`
- Modify: `docs/operations/2026-09-02_FRONTAL_DUEL_BLUEPRINT_PDF_PUBLICATION_REPORT.md`
- Create: `docs/operations/2026-09-03_HUMAN_BLUEPRINT_INCREMENTAL_REVISION_WORK_CONTRACT_RECEIPT.json`
- Create: `docs/operations/2026-09-03_HUMAN_BLUEPRINT_INCREMENTAL_REVISION_EXECUTION_REPORT.md`

- [ ] Keep master-role ownership singular: Markdown remains canonical and this
  PDF remains the one current human-facing derived publication.
- [ ] Declare the 52-page preservation/page-order contract and the image
  pipeline provenance so a later reader cannot confuse candidates, canon
  modules, and runtime captures.
- [ ] Log current state → request reason → expected effect for every listed
  system/case, with `NOT_RUN` left intact where evidence is absent.

### Revision Task D: render, inspect, and publish safely

- [ ] Invoke the PDF creation marker exactly once before the first authoring
  command, then create the one active output atomically.
- [ ] Render every page with Poppler; inspect cover, all 15 insertion pages,
  insertion boundaries, and final page at full resolution.
- [ ] Run PDF readback, focused tests, canonical-reference freshness, project
  operating validator, relevant Python/Godot regressions, and five adversarial
  review loops before commit/push/PR exact-head readback.

## Global Constraints

- Preserve the 1v1 ten-step, public-distance, 3/3/4, public-only AI, and no-deck core without changing code/data/scenes/assets.
- Use only existing approved visual assets and existing machine runtime captures.
- Keep the 36-page baseline PDF intact; never delete it.
- Mark unrun human, Android, accessibility, release, exact lock/reveal, and impact runtime evidence as unverified.
- Publish only from an isolated `codex/` branch and never force-push or write directly to `main`.

---

### Task 1: Lock the no-regression publication contract

**Files:**
- Modify: `tests/test_human_game_blueprint_profile.py`
- Modify: `tests/test_frontal_duel_action_flow_blueprint_contract.py`

**Interfaces:**
- Consumes: `exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260829.pdf` and the current visual source generator.
- Produces: a testable `HUMAN_MASTER_GDD_PDF` path, page-count floor, preserved-baseline order, and wireframe-token contract.

- [ ] **Step 1: Write the failing tests**

```python
def test_current_human_master_is_additive_and_preserves_all_36_baseline_pages(self):
    self.assertTrue(CURRENT_PDF.is_file())
    self.assertGreaterEqual(len(PdfReader(str(CURRENT_PDF)).pages), 46)
    self.assertEqual(
        [page.extract_text() for page in current.pages[1:37]],
        [page.extract_text() for page in baseline.pages],
    )
```

- [ ] **Step 2: Run the focused test to verify RED**

Run: `python -m unittest tests.test_human_game_blueprint_profile.HumanGameBlueprintProfileContract.test_current_human_master_is_additive_and_preserves_all_36_baseline_pages -v`

Expected: failure because the new current human-master PDF does not exist.

- [ ] **Step 3: Add the focused visual-token regression**

```python
for token in (
    "플레이어 흐름 맵 · 3/3/4",
    "계획 편집 · 구조 와이어프레임",
    "한 수 공개 · 구조 와이어프레임",
    "통합 카드 · 삽화와 사실 정보",
):
    self.assertIn(token, current_text)
```

- [ ] **Step 4: Run the visual-token test to verify RED**

Run: `python -m unittest tests.test_frontal_duel_action_flow_blueprint_contract -v`

Expected: failure because the new master does not yet contain the additive visual pages.

### Task 2: Build the additive human-master PDF assembler

**Files:**
- Create: `tools/build_human_game_blueprint_pdf.py`
- Modify: `tools/build_frontal_duel_visual_blueprint_pdf.py`

**Interfaces:**
- Consumes: `build(output: Path) -> None`, the preserved 36-page baseline PDF, existing approved visual asset paths, and existing machine runtime-capture paths.
- Produces: `build(output: Path) -> None` for the 46-page current master output.

- [ ] **Step 1: Write the failing generator contract test**

```python
subprocess.run(
    [sys.executable, "tools/build_human_game_blueprint_pdf.py", "--output", str(output)],
    check=True,
)
self.assertEqual(len(PdfReader(str(output)).pages), 46)
```

- [ ] **Step 2: Run it to verify RED**

Run: `python -m unittest tests.test_human_game_blueprint_profile -v`

Expected: failure because `tools/build_human_game_blueprint_pdf.py` does not exist.

- [ ] **Step 3: Implement the minimal assembler**

```python
def build(output: Path) -> None:
    with TemporaryDirectory() as directory:
        addendum_path = Path(directory) / "addendum.pdf"
        build_addendum(addendum_path)
        writer = PdfWriter()
        writer.add_page(build_current_cover())
        append_interleaved_pages(writer, baseline_reader, addendum_reader)
        write_atomically(writer, output)
```

- [ ] **Step 4: Run focused tests to verify GREEN**

Run: `python -m unittest tests.test_human_game_blueprint_profile tests.test_frontal_duel_action_flow_blueprint_contract -v`

Expected: all focused tests pass.

### Task 3: Make the expanded PDF the sole current human-master publication

**Files:**
- Modify: `docs/design/PROJECT_AI_PRODUCTION_SPEC.md`
- Modify: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- Modify: `docs/operations/2026-09-02_FRONTAL_DUEL_BLUEPRINT_PDF_PUBLICATION_REPORT.md`
- Modify: `tests/test_human_game_blueprint_profile.py`
- Delete: `output/pdf/TEN_PACES_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT_2026-09-02.pdf`

**Interfaces:**
- Consumes: new master output identity and preserved baseline provenance.
- Produces: one current `HUMAN_MASTER_GDD_PDF` path; old 36-page source and short focused output have explicit retained/absorbed roles.

- [ ] **Step 1: Write the failing ownership assertions**

```python
self.assertIn("HUMAN_BLUEPRINT_ADDITIVE_20260902", self.spec)
self.assertNotIn("TEN_PACES_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT_2026-09-02.pdf | current", self.doc_map)
```

- [ ] **Step 2: Run to verify RED**

Run: `python -m unittest tests.test_human_game_blueprint_profile -v`

Expected: failure because the current human-master path still names the 20260829 publication.

- [ ] **Step 3: Update only the human-publication ownership and evidence boundary**

Keep the old 36-page source as `PRESERVED_BASELINE_SOURCE`; point the human-master role at the 46-page additive publication; record the former short output as `ABSORBED_DERIVED_OUTPUT`; do not rewrite unrelated current-state claims.

- [ ] **Step 4: Run focused ownership tests to verify GREEN**

Run: `python -m unittest tests.test_human_game_blueprint_profile -v`

Expected: all profile tests pass.

### Task 4: Render, audit, and publish the one full blueprint

**Files:**
- Create: `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf`
- Modify: `docs/operations/2026-09-02_FRONTAL_DUEL_BLUEPRINT_PDF_PUBLICATION_REPORT.md`

**Interfaces:**
- Consumes: the PDF assembler and active ownership records.
- Produces: current human-master PDF, source/page mapping evidence, rendered-page inspection record, and removal of the redundant focused output.

- [ ] **Step 1: Mark the PDF edit operation and build the output**

Run the PDF skill marker exactly once, then execute the assembler to the `exports/` path.

- [ ] **Step 2: Run structural PDF readback**

```python
reader = PdfReader(str(output))
assert len(reader.pages) == 46
assert baseline_pages == current_pages[1:37]
```

- [ ] **Step 3: Render all 46 pages and visually inspect the cover, every insertion boundary, all added wireframes, and the final register**

Use Poppler output only under `tmp/pdfs/`, then remove it after inspection.

- [ ] **Step 4: Run full documentation and regression validation**

Run: `python tools/check_project_operating_system.py`; `python tools/check_canonical_reference_freshness.py --root . --config .github/reference-freshness.json`; focused tests; full project test suite.

- [ ] **Step 5: Commit, push, open current-task PR, verify exact-head checks, merge normally, and read back `origin/main`**

Do not touch pre-existing PRs #199 or #200. Delete only this task's superseded short derived output and temporary PDF renders after their consumer replacement is verified.

## Plan self-review

- Spec coverage: old 36-page preservation, added images/wireframes, evidence boundary, single current master owner, cleanup, visual and automated validation are each assigned.
- Placeholder scan: no TBD/TODO steps; page order, paths, counts, tests, and output ownership are explicit.
- Interface consistency: the existing focused generator exports `build(output: Path)`; the new assembler consumes it and exports the same shape for its own CLI.
