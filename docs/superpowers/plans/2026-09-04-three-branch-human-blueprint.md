# 강호행로 3갈래·4회 선택 및 Human Blueprint Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 새 3갈래·4회 선택 정본과 일관된 9화면 atlas 후보를 하나의 현재 사람용 Blueprint PDF로 생산한다.

**Architecture:** Markdown Decision/GDD/structured state가 규칙을 소유하고, 새 ReportLab builder가 그 내용을 사람용 PDF로 파생한다. 이미지 후보는 documentation-only consumer를 가지며, runtime asset promotion은 후속 Godot package로 분리한다.

**Tech Stack:** Python 3, ReportLab, Pillow, pypdf, Poppler, project-local document validators.

**Spec:** `docs/superpowers/specs/2026-09-04-three-branch-human-blueprint-design.md`

## Global Constraints

- 사용자 최신 지시의 `3갈래 / 4회 선택 / 단일 행동 실행 / 별도 Review 화면 없음`을 보존한다.
- 10칸 전장, 시작 거리 2, 3/3/4, 숨은 계획, deck/hand/draw 금지를 바꾸지 않는다.
- existing final-locked runtime assets와 `data/`, `src/`, `scenes/`, `assets/`, `project.godot`는 수정하지 않는다.
- 최종 PDF는 `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260904.pdf` 한 개이고, 20260902 PDF는 historical derived output으로 보존한다.

---

### Task 1: Route and screen-contract canon

**Files:**
- Create: `docs/reviews/2026-09-04_THREE_BRANCH_FOUR_CHOICE_ROUTE_BENCHMARK.md`
- Create: `docs/decisions/2026-09-04_THREE_BRANCH_FOUR_CHOICE_JIANGHU_AND_HUMAN_BLUEPRINT_DECISION.md`
- Modify: `docs/01_GAME_DESIGN.md`, `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`, `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`, `docs/07_COMBAT_UI_SPEC.md`, `docs/UX_UI_SYSTEM.md`, `docs/10_COMBAT_PRESENTATION_PLAN.md`

- [x] Write the 10-case current route benchmark with direct, adjacent and negative/mixed cases.
- [x] Record the exact user-approved route and execution contracts in a successor Decision.
- [x] Replace only active two-node/standalone-review/two-step-CTA statements with successor wording; retain older decisions as historical evidence.
- [x] Run `rg -n "route_two_nodes_per_gap_preserved|Combat Review Overlay|행동계획 잠금" docs` and classify remaining historical results rather than deleting them.

### Task 2: Candidate provenance and regression first

**Files:**
- Create: `docs/visual-assets/candidates/TEN-HUMAN-BLUEPRINT-20260904/TEN_PACES_3X3_SCREEN_ATLAS_20260904_v1.png`
- Create: `docs/visual-assets/candidates/TEN-HUMAN-BLUEPRINT-20260904/TEN_PACES_3X3_SCREEN_ATLAS_20260904_v1.md`
- Create: `tests/test_human_blueprint_20260904_contract.py`

- [x] Write the failing test asserting the new PDF path, the candidate atlas, exact route/CTA text, and a minimum 20-page PDF.
- [x] Run `python -m unittest tests.test_human_blueprint_20260904_contract -v` and confirm failure because the new output/owners/builder do not exist.
- [x] Copy the selected whole-scene candidate without overwriting an existing source, then record the SHA-256, dimensions, documentation consumer, and shipping-right boundary.

### Task 3: Build the new dated current PDF

**Files:**
- Create: `tools/build_human_game_blueprint_20260904_pdf.py`
- Create: `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260904.pdf`

- [x] Implement a deterministic 24-page landscape PDF with project intro, atlas, two system sections, Flow Maps, wireframes, asset split plan, PM matrix, and risks.
- [x] Fail fast for a missing or mismatched atlas candidate.
- [x] Immediately before the first authoring command run the PDF marker exactly once with `--operation-kind create --expected-output-count 1 --output-format pdf`.
- [x] Run the builder, then rerun `python -m unittest tests.test_human_blueprint_20260904_contract -v` to verify GREEN.

### Task 4: Promote only the derived-document ownership

**Files:**
- Modify: `docs/design/PROJECT_AI_PRODUCTION_SPEC.md`
- Modify: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- Modify: `[기획서]/DESIGN_DOCUMENT_REGISTRY.json`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/planning-data/current_user_planning_status.json`
- Create: `docs/operations/2026-09-04_THREE_BRANCH_HUMAN_BLUEPRINT_EXECUTION_REPORT.md`
- Create: `docs/operations/2026-09-04_THREE_BRANCH_HUMAN_BLUEPRINT_WORK_CONTRACT_RECEIPT.json`

- [x] Point the only human-master role to the new dated PDF.
- [x] Retain the 20260902 file as a historical derived publication with an explicit stale-screen-rule warning.
- [x] Record exact legacy runtime consumers and all evidence ceilings in receipt/report.

### Task 5: Render, review and validate

**Files:**
- Modify: final PDF only if visual review finds a defect.

- [x] Run pypdf page/text structural checks.
- [x] Render every page to `tmp/pdf-render-human-blueprint-20260904-final/` using Poppler; inspect every rendered page for clipping, unreadable Korean glyphs, bad crop, broken page number, stale 2-node language, and empty PM cells.
- [x] Run focused tests, `git diff --check`, the project documentation/reference freshness validator, and the route search audit.
- [x] Record five actual full-scope adversarial loops and distinct `PASS`/`NOT_RUN` evidence in the execution report.
