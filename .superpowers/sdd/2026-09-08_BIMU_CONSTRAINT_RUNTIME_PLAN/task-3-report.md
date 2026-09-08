# Task 3 implementation report

## Scope, authority and evidence ceiling

- Baseline: `d8ac2c7d` on `codex/bimu-constraint-runtime-20260908`.
- Work Mode: BUILD. Skills: project `combat-ux-and-accessibility` / ui-contract and runtime-review; `ten-paces-verification` / regression, runtime-validation and evidence-report. The implementer prompt and task-3 brief were read before changes.
- Fresh local owners read: AGENTS, Base version entry, integrated work contract, Active Context, project skill registry/adapter/snapshot, UX owner, approved runtime plan, actual constraint JSON/model, RunState, actual completion -> route -> result -> base shell chain, bridge, native card/dock/setters and neighboring tests.
- CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE from the controller's same-package runtime plan. It records the same selection/composition/disclosure/duration benchmark dimensions and official Hades, God of War Burdens, Godot optimization refresh. This implementation imports no benchmark rules, reward formulas or new design dimensions. It implements the approved nine-option catalog. No new visual assets needed.
- FEASIBLE: existing RunState/model own selection and frozen receipts; actual combat engine owns lock reasons; existing native Containers and cards own presentation. No UI rule recomputation.
- `python tools/check_project_operating_system.py --root .`: `project operating system: PASS`, exit 0. The controller confirmed this as the project's actual validator; the generic router's guessed `tools/validate_operating_contract.ps1` locator is absent and was not invented.
- MACHINE_VERIFIED and headless layout/input evidence only. Windows visible/Hera captures are the controller's next step. Android, physical gamepad, accessibility users, Human UX and release performance: NOT_RUN.

## Implemented

1. Actual native shell briefing has a public-opponent/own-mastery column and a scrollable nine-option constraint column. Title and confirmation remain outside option scrolling. The existing route-shell appended intel remains visible in the public-info scroll, including through repeated actual-root render calls.
2. Constraint names, effects, costs and target binding fields come from the model catalog; a read-only deep-copy `get_selection_policy()` accessor supplies the catalog's Korean count/budget format. RunState validates and submits every change atomically. Invalid attempts preserve the accepted selection and display the model's reason.
3. Owned-player-manual, current enemy public signature manual and catalog-approved stat target selectors bind exact selection fields. Summary includes selected deltas and target names, never hidden enemy base values. Zero confirmation says `제약 없이 비무 시작`; nonzero says `선택한 제약으로 비무 시작`.
4. Bridge builds presentation context from its actual `resolution_engine.get_action_lock_reason(card_id)` and current receipt. Native manual/ultimate cards show the actual Korean seal reason, disable normal activation, and preserve base ultimate availability. Dock rejects stale/injected locked IDs before emitting placement. Task 2's original bridge commit guard remains intact and its forged-slot regression passed.
5. Preparation has a compact `이번 비무` active-condition summary beside source tabs, with target names and disclosed-effect tooltip. Sealed-card third summary line displays the reason; existing card geometry and approved atlas assets are reused.
6. Equal manual data, ultimate mastery/loadout, momentum and reservations return before rebuilding. Equality guards preserve original initialization, including momentum configured before `_ready`. Changed mastery, receipt, momentum and reservations still refresh.
7. A real headless 1280x800 briefing-to-combat transition exposed legacy BasicCardTray exit signals during construction before `card_detail_panel` existed. Two bounded readiness checks protect the existing hover/unhover callbacks without changing initialized behavior.

## TDD evidence

Command for focused RED/GREEN:

```powershell
& 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script tests/verify_bimu_constraint_ui.gd
```

Initial test development hit an untyped empty-array test argument; that fixture was corrected before recording the behavioral RED. Actual behavioral RED before product changes:

```text
BIMU_UI_IDENTICAL_UPDATES=10 CHANGED_MANUAL_LISTS=10
ERROR: native briefing constraint panel missing
ERROR: identical manual list identity preserved
ERROR: identical techniques identity preserved
ERROR: identical ultimate identity preserved
```

The errors were expected: the shell had no native constraint controls and equal setters rebuilt native nodes. After first implementation, the focused assertions passed but transition produced:

```text
SCRIPT ERROR: Invalid call. Nonexistent function 'clear_definition' in base 'Nil'.
at: VerticalSliceCombatBridge._on_card_unhovered (res://src/combat/combat_board_preview.gd:680)
```

This is the observed failing reproduction for the additional bounded readiness guard. Final focused GREEN after the guard and self-review refinements:

```text
BIMU_UI_IDENTICAL_UPDATES=10 CHANGED_MANUAL_LISTS=0
BIMU_CONSTRAINT_UI_OK
```

Exit 0, no script errors/warnings. Godot identifies itself as `4.7.1.stable.official.a13da4feb`.

The rebuild measurement is ten identical manual-context updates, comparing actual first manual-button instance IDs after each setter call: 10 changed lists before, 0 after. The same regression checks technique and ultimate node identities, actual focus after a frame, a nonzero horizontal scroll offset, changed mastery/receipt/momentum/reservations, equal nonempty reservations, and default/pre-ready initialization. This is a node-rebuild reduction measurement, not an FPS or release-performance claim.

## Regression commands and results

From the stated worktree:

```powershell
$cases = @('verify_bimu_constraint_model', 'verify_bimu_constraint_runtime', 'verify_bimu_constraint_ui', 'verify_vertical_slice_setup_briefing', 'verify_vertical_slice_combat_bridge', 'verify_vertical_slice_shell', 'verify_vertical_slice_route_state', 'verify_vertical_slice_failure_retry', 'verify_martial_action_panel', 'verify_ultimate_action_panel', 'verify_action_card_summary', 'verify_atlas_presentation_successor', 'verify_frontal_duel_screen_partition', 'verify_action_selection_dock')
foreach ($case in $cases) {
    & 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script "tests/$case.gd"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
```

All 14 completed, overall exit 0, with their expected PASS/OK sentinels and no script errors. Constraint model reported `BIMU_CONSTRAINT_MODEL_OK cases=45`; runtime reported `BIMU_CONSTRAINT_RUNTIME_OK`. The atlas suite also prints its unrelated sound cache timing; this report makes no new sound or FPS claim. After final self-review additions, the focused UI test was rerun and remained clean exit 0.

Headless UI coverage at both 1280x720 and 1280x800: actual inherited shell, zero CTA, first/last focus, automatic last-row scroll, actual `ui_accept` input toggling the last option, title/CTA/option bounds, counter policy, target eligibility, third-choice rejection, atomic accepted selection, appended route intel, own mastery/public wording, active-summary/source-tab separation, manual sealing, injected dock ID rejection, changed receipt/mastery unlocking ordinary cards, sealed mastery ultimate with engine reason, base ultimate still enabled at 5 momentum.

## Self-review and files

Review checked the actual diff against untouched route/result/completion consumers, actual UI initialization/input boundaries, catalog/receipt ownership, lifecycle regressions and evidence limits. Fixed issues found during implementation/self-review: initial typed-array test fixture; pre-ready equal momentum must still populate actions; native hover/unhover may precede detail-panel construction; preparation summary needed compact names/targets to fit beside tabs; manual snapshot must count constraint locks; policy denominator must be catalog-derived. No new gameplay decisions or assets.

Owned files:

- `src/ui/bimu_constraint_panel.gd` (new focused briefing view)
- `src/run/vertical_slice_shell.gd`
- `src/run/vertical_slice_combat_bridge.gd` (presentation context only)
- `src/run/bimu_constraint_model.gd` (read-only policy getter only)
- `src/ui/action_selection/action_selection_dock.gd`
- `src/ui/action_selection/martial_action_panel.gd`
- `src/ui/action_selection/ultimate_action_panel.gd`
- `src/ui/action_selection/action_choice_card.gd`
- `src/combat/combat_board_preview.gd` (two readiness guards)
- `tests/verify_bimu_constraint_ui.gd`
- this report.

Existing imports, generated UIDs, captures, artifacts and controller-owned docs were preserved and excluded from the owned commit. No branch switch/push/editor manipulation.

## Controller visible-QA locators and scenarios

- Actual scene: `res://scenes/run/vertical_slice_shell.tscn`.
- Root method: `get_bimu_constraint_panel()` returns the live panel.
- Panel: `ContentPanel/.../BimuBriefingBody/BimuConstraintPanel`; public text sibling is `PublicOpponentBriefing`.
- Controls: `panel.option_buttons[constraint_id]`, `panel.target_selectors[constraint_id]`, `panel.options_scroll`, `panel.summary_label`, `panel.reason_label`.
- Each scroll row is named its `CST_*` ID, with `SelectConstraint` and (when relevant) `ConstraintTarget` children.
- Preparation: `root._combat_view.action_selection_dock.constraint_summary`; native martial/ultimate panels remain `dock.martial_panel` and `dock.ultimate_panel`.

Capture at 1280x720 and 1280x800: (a) no-selection briefing with top options and explicit zero CTA; (b) choose `문파 단절` with an owned target plus `내공 수련` with a stat target, scroll to the last option and confirm selected deltas/target names; (c) attempt a third choice and verify readable reason; (d) begin combat, choose 무공, inspect the sealed target's disabled card/reason and active summary; (e) fixture with mastery 10 and momentum 5 plus 절초 봉인, confirm sealed manual ultimate and available base ultimate; (f) later briefing with route-acquired intel. Keyboard: focus public text scroll, first/last option, target dropdown, primary CTA; activate with keyboard and verify scroll/focus.

Visible font/readability, pointer/keyboard observation, subsequent full-scope review loops, repository-wide tests, exact-head CI and protected merge remain controller work. No Human/UX/Android/release PASS is implied.

## Review fix round 1 — native contrast, integer counters, focused-row visibility

Baseline `370e01c9`. Controller review found a near-black unchecked icon, JSON-derived denominators rendered as `2.0/3.0`, and the final selected row/target clipped when the summary grew. The implementer inspected `docs/runtime-captures/TEN-BIMU-CONSTRAINTS-20260908/briefing-selected-1280x800.png` and confirmed the last-row clipping and decimal labels. The controller also supplied `briefing-zero-1280x800.png` as unchecked-state evidence.

Changes are confined to `src/ui/bimu_constraint_panel.gd`, `tests/verify_bimu_constraint_ui.gd`, and this report. Replaced the theme-dependent CheckBox icon with a native toggle Button carrying explicit `[미선택]` / `[선택]` Korean text. Existing native StyleBoxFlat surfaces provide dark unchecked, paper selected and a three-pixel blue focus border. No raster/vector asset was produced. Font contrast is tested at >=4.5:1 in normal/selected states; unchecked boundary and focus boundary are tested at >=3:1, including focus against both normal and selected fills. These are style-parameter calculations, not Human/accessibility acceptance.

Policy values are converted to integers at the presentation boundary; the regression compares the complete first line exactly (`선택 0/2 · 제약 점수 0/3` and `선택 2/2 · 제약 점수 2/3`). After footer updates and viewport resize, one coalesced deferred callback waits for Container layout and reveals the entire focused option row, including its target selector. It does not move focus or change unrelated scroll positions.

TDD command (same executable/path as above):

```powershell
& 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script tests/verify_bimu_constraint_ui.gd
```

An initial test helper was inserted mid-function, producing parse errors; that test-authoring mistake was corrected before the behavioral RED. Behavioral RED then reproduced all three review findings at exit 1:

```text
ERROR: catalog policy exact integer counter
ERROR: unchecked state has explicit text cue
ERROR: native option has explicit normal selected focus styles
ERROR: selected exact integer counter 720
ERROR: selected state has explicit text cue
ERROR: selected final row and target fully visible after footer grows 720
ERROR: selected exact integer counter 800
ERROR: selected final row and target fully visible after footer grows 800
```

GREEN after the implementation and stronger focus-contrast check: exit 0, `BIMU_UI_IDENTICAL_UPDATES=10 CHANGED_MANUAL_LISTS=0`, `BIMU_CONSTRAINT_UI_OK`, no script errors. The new scenario first selects a manual seal, focuses the final unchecked stat option with its short footer, emits the real toggle signal, waits for the expanded summary layout, then checks the full button and target rectangles are enclosed by the scroll viewport at 720/800. CTA bounds remain protected.

Adjacent regression command:

```powershell
$cases = @('verify_bimu_constraint_ui', 'verify_vertical_slice_setup_briefing', 'verify_vertical_slice_shell', 'verify_action_selection_dock')
foreach ($case in $cases) {
    & 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script "tests/$case.gd"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
```

All four passed, overall exit 0, no script errors. Native locators are unchanged. Controller performs updated visible captures; no editor was manipulated by this subtask. Captured visual acceptance remains pending until that readback.
