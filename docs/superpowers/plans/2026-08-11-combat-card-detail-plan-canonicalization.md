# Combat Card Detail Plan Canonicalization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Promote the user-approved combat card body/detail/planning-board information spec into the existing combat UI canon without changing Godot/runtime/product assets.

**Architecture:** Reuse `TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01` rather than create a competing Decision. Add one contract regression that first fails because the approved companion spec is not yet canon-linked, then minimally update the Decision, `docs/07_COMBAT_UI_SPEC.md`, and the approved spec status/reference. Keep image generation and product implementation blocked until their later gates.

**Tech Stack:** Markdown canon, Python contract tests, GitHub Actions remote CI, Google Sheet Decision ledger/readback.

## Global Constraints

- Product implementation authority remains `PLANNING_ONLY`.
- No Godot Scene/Resource/script/runtime mutation.
- No image generation in this task.
- Image order remains `기획완료 → 검수완료 → 이미지 생성`.
- Card body always shows: action name, source + action type, slot count, actual resource cost or `비용 없음`, core effect.
- `사거리` appears only for `[공격]` actions; non-attack actions omit the row entirely.
- Continuous numeric effects show the current calculated value on the card; exact formulas belong in detail view.
- Detail view must not be hover-only: Windows click/keyboard/gamepad focus and Android tap/back paths are required.
- Planning board preserves `3|3|4`, `[전조] → actual action type`, and explicit `행동계획 잠금`.
- `[관찰]` reveals only action types, never technique name/cost/damage/range/direction.
- `% 명중률`, `예상 명중률`, and `[기절]` remain forbidden.

---

### Task 1: Canon-link regression

**Files:**
- Create: `tests/test_combat_card_detail_plan_information_spec.py`
- Read: `docs/decisions/2026-08-11_COMBAT_UI_INFORMATION_HIERARCHY_DECISION.md`
- Read: `docs/07_COMBAT_UI_SPEC.md`
- Read: `docs/superpowers/specs/2026-08-11-combat-card-detail-plan-information-design.md`

**Interfaces:**
- Consumes: existing Decision ID `TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01`.
- Produces: a regression contract requiring the approved companion spec, card-current-value/detail-formula split, explicit cross-input detail access, and planning/image gates.

- [ ] **Step 1: Write the failing test**

Create a Python unittest that reads the three files and asserts:

```python
assert "APPROVED_SPEC" in spec
assert "docs/superpowers/specs/2026-08-11-combat-card-detail-plan-information-design.md" in decision
assert "card_body_numeric_display: CURRENT_CALCULATED_VALUE" in decision
assert "detail_formula_display: EXACT_FORMULA" in decision
assert "detail_open_windows: CLICK_KEYBOARD_GAMEPAD_FOCUS" in decision
assert "detail_open_android: TAP_BACK" in decision
assert "기획완료 → 검수완료 → 이미지 생성" in decision
assert "카드 본체는 현재 계산값을 우선" in ui_spec
assert "hover 전용" in ui_spec
```

- [ ] **Step 2: Run test to verify RED**

Run via the repository's normal Python contract test path (or the single test directly in CI). Expected: FAIL because the current Decision does not yet canon-link the companion spec and does not contain the new structured display/access keys.

- [ ] **Step 3: Record RED evidence in the PR description**

Record the exact failing assertions; do not treat unrelated failures as the intended RED.

### Task 2: Minimal canon promotion

**Files:**
- Modify: `docs/superpowers/specs/2026-08-11-combat-card-detail-plan-information-design.md`
- Modify: `docs/decisions/2026-08-11_COMBAT_UI_INFORMATION_HIERARCHY_DECISION.md`
- Modify: `docs/07_COMBAT_UI_SPEC.md`

**Interfaces:**
- Consumes: Task 1 regression contract.
- Produces: canon-linked approved companion spec under the same Decision ID.

- [ ] **Step 1: Mark the companion spec approved**

Change status from `USER_APPROVED_DIRECTION / WRITTEN_SPEC_FOR_REVIEW` to `APPROVED_SPEC / CANON_COMPANION` and state that it elaborates, not supersedes, the Decision.

- [ ] **Step 2: Add Decision companion-spec contract**

Add the exact companion path and structured keys:

```yaml
card_body_numeric_display: CURRENT_CALCULATED_VALUE
detail_formula_display: EXACT_FORMULA
detail_open_windows: CLICK_KEYBOARD_GAMEPAD_FOCUS
detail_open_android: TAP_BACK
image_generation_order: PLANNING_COMPLETE_THEN_REVIEW_COMPLETE_THEN_IMAGE_GENERATION
```

Preserve `PLANNING_ONLY`, `product_implementation_authorized: false`, `[공격]`-only range, observation type-only disclosure, `[기절]` and hit-probability prohibitions.

- [ ] **Step 3: Align UI spec wording**

Add concise normative wording that cards prioritize current calculated values while formulas live in detail; detail cannot rely on hover-only and must expose Windows and Android equivalent paths.

- [ ] **Step 4: Run Task 1 test to verify GREEN**

Expected: PASS.

### Task 3: Regression and adversarial review

**Files:**
- Test: `tests/test_combat_card_detail_plan_information_spec.py`
- Existing combat/UI/observation contract tests and PR Validation workflows.

**Interfaces:**
- Consumes: canon changes from Task 2.
- Produces: exact-head evidence that no existing combat/UI/observation contract regressed.

- [ ] **Step 1: Run focused tests**

Run the new regression plus existing combat UI/observation/current-entry contract checks.

- [ ] **Step 2: Run full PR validation**

Use the repository's canonical GitHub Actions workflows on the exact PR head; no local-success substitution for failing remote CI.

- [ ] **Step 3: Adversarial review**

Search changed/current canon for contradictions: formula on card body, range on non-attacks, hover-only detail, technique-name leakage from observation, `[기절]`, hit-rate percentages, image generation before planning/review completion, or accidental product implementation authority.

- [ ] **Step 4: Verify exact-head and review threads**

Require current head, required checks success, no unresolved review thread, and no P0/P1 finding.

### Task 4: Merge and Sheet synchronization

**Files/Surfaces:**
- GitHub Decision/UI/spec/test/plan files.
- Google Sheet Decision row for `TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01`.
- Project Hub/UX/change-history surfaces only as needed for current-state synchronization.

**Interfaces:**
- Consumes: approved scope and Task 3 exact-head evidence.
- Produces: merged-main canon and same-Decision-ID Sheet readback.

- [ ] **Step 1: Merge with exact-head protection**

Use the repository's approved squash path after all gates pass; do not request duplicate user approval.

- [ ] **Step 2: Read merged main**

Verify the companion spec status/path and Decision/UI wording from new `main`.

- [ ] **Step 3: Sync Google Sheet**

Update the same Decision ID to record the approved companion spec and merged main SHA. Preserve `PLANNING_ONLY` and the later `기획완료 → 검수완료 → 이미지 생성` sequence.

- [ ] **Step 4: Read back Sheet and open PR inventory**

Verify written values and re-audit all open/draft PRs.

## Self-review

- Spec coverage: card body, detail, planning board, observation, deterministic/no-hit-rate rules, Windows/Android access, and image/build gates are all mapped to Tasks 1–4.
- Placeholder scan: no TBD/TODO or unspecified implementation step remains.
- Responsibility boundary: this plan promotes planning canon only; product runtime/Godot/image work is explicitly excluded.
