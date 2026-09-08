# Inline combat results implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Current user already authorizes continuous implementation; do not ask another execution-choice question.

**Goal:** Apply the approved removal of standalone review overlays while retaining actual causal results, and correct the observed reveal text overlap.

**Architecture:** Keep the existing resolver, summary builder and run-state receipt ownership. Nonterminal presentation returns to next-bundle planning without a review-confirmation click; terminal presentation hands its real receipt to the existing result/failure screen exactly once. Current-action reveal and a compact inline result strip carry causal information without another scene or hidden-plan exposure.

**Tech Stack:** Godot 4.7.1, GDScript, existing shared UI and native-event test helpers, Python contract tests.

**Spec:** `docs/decisions/2026-09-04_THREE_BRANCH_FOUR_CHOICE_JIANGHU_AND_HUMAN_BLUEPRINT_DECISION.md` sections 1.2/1.3, screen-boundary-only supersession. The user's current continuous Blueprint implementation request is the execution scope.

## Global constraints

- Preserve `3수 → 해결 → 3수 → 해결 → 4수 → 해결`, AI public-only decisions and exact-once reward/resource handoff.
- No deck/hand/draw, numerical combat, scouting disclosure, reward formula, save schema, engine, audio or new asset changes.
- Preserve approved battler scale/grounding and existing visual assets. This package corrects composition, not art direction.
- Show only already-resolved causal information. Do not expose a later action from the same resolved bundle while an earlier timing is presented.
- Preserve skip/fast replay/reduced motion, keyboard activation, interruption and teardown safety. Physical/Human/Android/release evidence remains separate.
- Do not mutate other worktrees or take over unrelated PRs. This branch starts from PR329 closeout commit `45cec8ae`; reconcile its merge before publication.

## Evidence, research and feasibility

CURRENT_SOURCE_RELEVANCE_CHECK: reuse the fully reread September 1 ten-game frontal duel/reveal benchmark for the same presentation/replay dimension and unchanged core, together with the September 4 accepted screen-boundary decision. ADAPT readable causal feedback and quick re-entry, REJECT another modal confirmation or future-plan preview. This is not fresh player research. Fresh September 8 official checks: https://docs.godotengine.org/en/stable/classes/class_container.html (automatic child arrangement) and https://docs.godotengine.org/en/stable/classes/class_label.html (wrapping within bounded width). ADOPT layout based on actual Control minimum sizes; REJECT merely shrinking text or clipping meaningful effects. No new comparative game mechanism is introduced.

FEASIBLE: base `_show_review_panel` currently pauses in `review_ready`; `_on_review_continue_requested` owns the existing advance operation. Bridge overrides both, emits terminal ready then confirmed, and shell transitions through internal review to result. Retain this receipt sequence atomically without presenting a separate review screen. `CombatReviewSummaryBuilder.build_summary` already produces one actual cause (within approved 1–3). A new broad summary/scoring system is unnecessary.

Actual controller capture `docs/runtime-captures/single-execute-reveal-20260908.png` shows `RevealResult` crossing callout text. `_layout_cards` assigns a nominal 64–86px panel height even when VBox minimum size is larger; result position is based on the nominal height. Correct actual layout, not just the screenshot.

## Task 1: Inline causal results and uninterrupted presentation flow

**Files / responsibilities**
- Modify `src/combat/combat_board_preview.gd`: replace active review overlay boundary, reuse advance logic, inline causal result, standalone terminal restart handling and focus order.
- Modify `src/combat/combat_board_preview_auto.gd` only for the actual presentation-state consumer.
- Modify `src/run/vertical_slice_combat_bridge.gd` and `src/run/vertical_slice_shell.gd`: terminal receipt handoff and compatibility with internal run-state review stage, exactly once.
- Modify `src/run/vertical_slice_shell_result_auto.gd`: display existing actual summary cause in result text, without changing metrics/reward computation.
- Modify `src/ui/combat_action_reveal_overlay.gd`: non-overlapping bounded current-action comparison/result layout.
- Keep standalone legacy `combat_review_panel` resource available if its isolated tests still consume it; no active product overlay, no broad historical deletion.
- Create `tests/verify_inline_combat_results.gd`; migrate active review/terminal/reveal/native campaign fixtures to the approved flow, retaining their causal and terminal assertions.
- Add the focused regression to the actual Godot CI invocation list, with a Python binding guard if that is the current pattern.
- Update same-date BUILD record, fresh exact-path protected manifest, Active Context and `docs/operations/2026-09-08_INLINE_COMBAT_RESULTS_EXECUTION_REPORT.md`.

**Interfaces**
- Consume actual result summary from existing `_last_review_summary` / `CombatReviewSummaryBuilder.build_summary(result, plan, before)`; never calculate damage in UI.
- Define `_finish_bundle_presentation(terminal: bool) -> void` as the active completion hook replacing `_show_review_panel`; define `_advance_to_next_bundle() -> void` by extracting the existing advance body, not implementing another rule.
- Bridge overrides completion to emit its existing terminal receipt signals in a safe deferred, once-only order. Preserve internal RunState state names and existing receipt API; no save migration.
- Inline summary may use a Label owned by the base board and actual terminal `review_summary.cause_label` in result shell. Reuse immutable summary values, never future actor plans.

- [ ] Add behavioral RED for no standalone review and automatic next-bundle readiness using the existing real board and guard plan:

```gdscript
var board = preload("res://scenes/combat/combat_board_preview.tscn").instantiate()
root.add_child(board)
for frame in range(6):
    await process_frame
board._reduced_motion = true
for index in range(3):
    board.action_selection_dock.basic_panel.buttons[2].emit_signal("pressed")
    await process_frame
board.combat_progress_button.request_progress()
var deadline = Time.get_ticks_msec() + 15000
while str(board.get_meta("presentation_state", "")) != "next_bundle_ready" and Time.get_ticks_msec() < deadline:
    await process_frame
_expect(str(board.get_meta("presentation_state", "")) == "next_bundle_ready", "No modal review click is required")
_expect(int(board.get_meta("resolution_count", 0)) == 1, "One existing resolution only")
_expect(not is_instance_valid(board.combat_review_panel) or not board.combat_review_panel.visible, "No standalone product review overlay")
```

The focused inline and bridge regressions together must additionally inspect nonempty actual inline cause, bounded reveal card/result rects after minimum-size/layout frames at 1280×720, 1280×800 and 1920×1080, terminal once-only result handoff, unchanged resources, and no future timing exposure. The inline cause occupies a bounded horizontal lane beside timing/progress controls; it must not consume another vertical row, alter duel geometry, intersect actual timing slots/progress/source tabs/visible product cards, or push visible cards beyond the viewport. Both regressions must be wired to actual CI invocation lists. Use real resolved event fixtures already present in reveal/terminal tests; preserve their outcome checks. Fail with `_expect` and `quit(1)`, capture native exit explicitly. Tests may set focused fixtures; the full campaign may not inject terminal state or bypass UI.

- [ ] Run `Godot --headless --path . --script res://tests/verify_inline_combat_results.gd` after required editor import; record actual behavioral failure and nonzero native exit. Do not count a parse error as behavior RED.
- [ ] Extract the existing advancement code and replace the overlay pause. On nonterminal finish, retain inline cause and advance once. On terminal finish, preserve final state and emit one receipt before one completion handoff. Use existing queued/deferred scene ownership where needed to avoid freeing the board while its async method is executing. In standalone board mode show inline terminal information and existing restart control, never restart automatically.
- [ ] Refactor the reveal layout around actual minimum heights or containers: heading/phase above comparison, result strip below both callouts, all within presentation region. Keep readable font size and wrapping. Actual result strip must not duplicate/overlap central feedback and must clear/update at each timing. Protect compact 720 layout; do not claim this is device validation.
- [ ] In the same current-action comparison, consume existing event `raw_damage`, `stamina_cost`, `internal_cost` and actual outcome when present. For clash, existing `clash_opponent_raw_damage`/`clash_difference` are authoritative facts, not a new UI formula. Display the approved power-versus-power and actual damage/evade meaning without guessed zero values for missing/non-attack facts. Test a resolved clash fixture with raw powers 15/10 and actual damage 5, and an evade fixture with actual damage 0; these are output fixtures, not changed combat rules.
- [ ] Update active test consumers that explicitly click `ReviewContinueButton`; replace that expectation with observable next-ready/result state, not direct state injection. Keep summary builder isolated tests and legacy widget unit tests intact when still valid. Native campaign continues actual UI path with its next meaningful button and checks final receipts/resources/history.
- [ ] Run focused GREEN and related reveal, review-summary, terminal, pointer lock, keyboard, liveness, vertical-slice review/result, and ultimate tests. Connect the new regression to CI and test that binding. Run whole Python once and ordinary-default native ten-duel campaign once with explicit native exit. The required outcome remains 10 wins/10 rewards/36 routes; report actual activation count, do not force the old 343 count.
- [ ] Register exact protected paths against `30b854b657fa5f29904d05c77aad38c7b6e17072`, preserve adoption pin. Record commands, five meaningful full-scope review passes, remaining gaps and NOT_RUN gates. Commit only owned source/tests/docs; leave generated import/UID churn unstaged. No push/merge/subagents.

Controller performs independent task and whole-branch review, actual scene capture and comparison, exact-head CI, protected merge, postmerge readback and one-time approval closeout. Reward/scouting and remaining content are separate subsequent packages, not silently declared complete here.

## Plan self-review

Screen-boundary and overlap requirements map to this one cohesive task; numerical systems deliberately remain outside. Producer/consumer hooks are explicitly named, receipt signals preserve current shell API, and tests cover both normal continuation and terminal teardown. The earlier ten-game comparison is reused only for unchanged presentation feedback, not as new balance evidence. Wrong automatic-advance interpretation would require restoring a compact inline continuation control; the approved no-overlay instruction and continuous flow are the current basis.
