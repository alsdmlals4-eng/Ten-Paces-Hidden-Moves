# Native campaign verification execution report

## Scope and authority

- Base SHA at implementation entry: `1581e20c`; protected gameplay source from merged PR #325, `12fe75ca795c9af640a58eff975e2a6cbe02888d`.
- Work Mode: BUILD (test only) / REVIEW. Skill: `ten-paces-hidden-moves-workflow-router` and project `ten-paces-verification`; modes `regression`, `runtime-validation`, `evidence-report`.
- Plan and current-source relevance/benchmark reuse/feasibility: `docs/operations/2026-09-08_NATIVE_CAMPAIGN_FLOW_VERIFICATION_PLAN.md`. No new gameplay dimension or visual asset.
- Independently read AGENTS, project contract, Base adoption owner, Active Context, registry, local verification skill, task brief, production shell/bridge/dock and existing policy probe. Controller owns live remote reconstruction and integration; this implementation task made no remote mutation.
- Project operating validator and pinned Base approved operating-contract validator both PASS before import. Base checkout: `C:/Users/user/Documents/GitHub/Ninza/omenward/.worktrees/_base-validator-19355-blueprint`, pin `19355b7ef065a21d0f2b685c7d9be64a4a3970f8`.

## Problem, comparison and selected structure

The earlier sequential probe exercised the actual resolver but constructed rewards, advanced run state and mirrored resource handoff in test code. Its result did not prove that a player could complete the campaign through production UI consumers.

The new probe inherits only public selection/scoring helpers from that script and overrides `run_probe`. It starts the real shell using the visible title button, selects four starter manuals, confirms the zero-selection bimu receipt, chooses actual actions and movement intents, locks/executes each plan, continues real review, claims earned rewards and selects routes. Every activation checks visible/enabled/focus prerequisites, dispatches pressed/released `InputEventAction` through `Input.parse_input_event`, witnesses exactly one production button `pressed` signal, and checks the corresponding state transition. There are no direct resolver, run advancement, resource application, outcome injection or reward construction calls in this probe.

The inherited policy receives a deep copy of combat state because its ultimate reservation helper changes the supplied player momentum. The live production state is never changed by policy evaluation. Production auto-placement assigns all actual anchors; expected anchor values in the test are assertions only.

Two alternatives were rejected: calling `pressed.emit`/consumer methods would bypass native event delivery, and duplicating the full policy would create another maintenance owner. `Input.action_press` was rejected by the plan's official input-source review because it does not prove GUI event propagation.

## Failure and correction evidence

1. Helper RED: a temporary permissive activation stub returned success for a disabled button and incremented progress. Godot exited 1 with `disabled control must be rejected` and `rejected activation must not count as progress`. The guarded event helper then exited 0 for this negative test. Final version also observes zero disabled-button signals.
2. The frontal layout hides fast/reduced-motion controls (`visible=false`, focus mode 0). The initial attempt to toggle fast replay correctly failed. The probe preserves ordinary production animation defaults; it does not expose hidden controls or write animation flags.
3. An initial harness assertion expected `planning` after review. Actual production continuation sets `next_bundle_ready`. The assertion now checks that documented runtime state plus hidden review.
4. First full native attempt stopped after 7 real wins, 7 rewards, 28 route choices and 326 native activations, at 114856 ms. Duel 8 turn 6 selected an ultimate before a trailing meditation; the subsequent basic-source tab was disabled. Both seven-star techniques and base ultimates had already resolved. The source-lock is intentional: `combat_board_preview_auto.gd::_dock_interaction_state` returns `ultimate_reserved`, and `ActionSelectionDock.LOCKED_STATES` locks source switching. This is not a production defect and was not bypassed.
5. The test policy now places the same chosen action multiset with the ultimate last. This changes action sequence and expected anchors, so outcomes are measured again rather than assumed equivalent. It preserves native source locking and production reservation. No actual timing anchor is assigned by the test. The full adjusted run passed.

## Actual result and reproducible commands

Executable: `C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe`, observed `4.7.1.stable.official.a13da4feb`.

Run from the exact project worktree:

```powershell
& 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --editor --import --quit
& 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script tests/probe_native_ten_duel_campaign.gd --log-file .godot/native-campaign.log
& 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script tests/verify_combat_keyboard_accessibility.gd
& 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script tests/verify_combat_action_selection_integration.gd
```

Final native summary: `complete=true`, 10 terminal successes (all ten observed enemy HP 0 with positive player HP), 10 earned rewards, 36 actual route choices, 387 successful native activations, 142230 ms, `ordinary_defaults`, no failures, exit 0. The shell's production seed is `20260820`; no test seed is injected. This differs from the standalone sequential probe's seed `20260908`.

Resolved public player action IDs include `shaolin_arhat_vajra_art_star7`, `yang_family_spear_star7`, `ultimate_void_sword_qi`, `ultimate_cleave_peak`, `mount_hua_plum_blossom_sword_star3`, `basic_guard`, `basic_heavy_attack`, `basic_move`, `basic_palm`, `basic_meditate`. The probe asserts exact production bridge-to-shell resources at every terminal result and shell-to-next-bridge resources before each duel.

Adjacent results: `COMBAT_KEYBOARD_ACCESSIBILITY_VERIFY_OK`, `verify_combat_action_selection_integration: PASS`, both exit 0. Final native run contains no `SCRIPT ERROR`, resource error or ObjectDB leak warning. Earlier aborted native runs emitted a two-object exit leak warning; the fresh editor import emitted 45-object/22-resource teardown diagnostics. These are not relabeled as clean import evidence. The completed native run is separately clean.

Bounds: 270 bundles per duel, 30 seconds per review wait, 900 seconds global campaign wall limit. Existing product CI includes the new probe only after local PASS; remote CI and independent controller review are pending at this implementation handoff. No new service or paid tool is introduced.

## Reuse, risks and evidence ceiling

The recurring lesson is that native UI policy must respect public atomic reservation ordering and actual continuation states; a resolver-only script cannot validate those boundaries. The negative helper guard and complete native probe retain the regression in the existing CI owner. Generated import/UID output is excluded from the commit; no protected product file is intentionally changed.

This is generated native-input headless runtime evidence. It is not Windows visible observation, physical keyboard/mouse/gamepad evidence, Android device evidence, Human/fun/balance/accessibility-user acceptance, asset rights acceptance or release PASS. Only the production technical seed and one public action/route policy were exercised. Independent review, exact-head remote CI and postmerge readback belong to the controller's subsequent closeout.

## Independent review correction round 1

Review base: `ff8388da56341f73631ffb85f57972d418291189`. The reviewer confirmed the earlier actual win trace, but identified five ways the test could overclaim future results. They were test defects, not newly demonstrated game defects. `receiving-code-review` was used to compare each finding to the actual shell/RunState consumers before editing only the probe and reports.

- Terminal success now requires actual player/enemy HP to prove a win or contract-legal draw, matching `last_combat_result.terminal`, HP, outcome, duel ID and the newly retained history row. The summary distinguishes wins and draws. A forged terminal receipt with both actors alive is rejected; contradictory history/wrong duel fixtures fail, and consistent win/draw fixtures pass.
- The activation witness remains connected throughout press/release and settling frames, then disconnects. An isolated fixture deliberately emits an additional `pressed` signal: `observed=2` must return false without incrementing activations. The fixture's one-shot callback merely generates that duplicate; the actual witness is not one-shot. No synthetic signal is sent to production controls.
- Each route's pending receipt and newly appended history must have the chosen `id` and `route_type`, plus the expected `J<duel>-<step>` node ID. Fixtures reject a different chosen route and a stale node.
- Review stall errors include duel, bundle, shell screen, presentation state and last input label. These diagnostics contain no hidden enemy plan.
- Helper PASS markers are conditional on successful assertions; guard failures stop before the campaign.

Focused RED command, then identical GREEN command:

```powershell
& 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script tests/probe_native_ten_duel_campaign.gd -- --guards-only
```

RED exited 1 with duplicate accepted, duplicate progress counted, and forged terminal HP accepted. The old one-shot witness and a temporary receipt-only terminal predicate represented those missing guards. GREEN exited 0, observed and rejected two signals, and printed `NATIVE_HELPER_GUARDS PASS`. These are isolated negative fixtures, not fabricated campaign results.

The first full rerun after the previous handoff's import cleanup could not load `atlas_blue_ink_courtyard_v1.png`; it emitted SCRIPT ERROR and was stopped with exit 1. Regenerating import metadata using the documented headless editor import fixed readiness. Import again exited 0 with the existing 45-object/22-resource editor teardown diagnostics. Regenerated import/UID files remain unstaged and preserved for controller verification; do not rerun a fresh/restored worktree without import.

The corrected full run used the documented command with log `.godot/native-campaign-review1-final.log`: exit 0, `complete=true`, **10 wins / 0 draws**, 10 rewards, 36 routes, 387 activations, 141588 ms. Every new HP/result/history/route identity assertion passed, as did both-direction resource checks and required techniques/ultimates. No SCRIPT ERROR occurred. A two-object exit teardown warning did occur; it is not relabeled as a clean run. A diagnostic verbose repeat is recorded separately below when available.

Adjacent current checks: `python tools/validate_ten_manual_product_gate.py --root .` → `TEN_MANUAL_PRODUCT_GATE_CONTRACT_OK`; `python -m unittest tests.test_ten_manual_product_gate -q` → 8 tests OK; project operating router PASS. Existing keyboard/action-selection runtime results above remain prior adjacent evidence, not newly rerun results. The CI step and product consumers were not edited in this correction round.

## Five full-scope refinement passes for the retained package

Each pass considers current authority and protected scope, the inherited public policy and real input path, negative assertions, terminal/route/resource consumers, existing CI and untouched tests, runtime evidence, cost and the Human/device evidence ceiling. The rows record actual findings or clean checks; no finding is invented to fill the count.

| Pass | Full-scope result and evidence | Refinement / exit |
|---|---|---|
| 1 — authority and design-to-test boundary | Fresh project/router/contract validation and shell/dock/policy reads showed why resolver-only evidence did not cover UI flow. Existing CI and adjacent consumers remained the integration owner; no product or new service was needed. | Inherit the public policy with a deep state copy; test native controls; disabled-button RED/GREEN establishes the first guard. |
| 2 — first complete native attempt | Production UI, resources, public actions, reward/route transitions and existing protected policy were checked against the actual attempt. Hidden settings, continuation naming and atomic reservation ordering differed from initial harness assumptions. Cost remained bounded and no Human claim followed from runtime. | Keep ordinary animation, assert `next_bundle_ready`, place the same selected actions with ultimate last. The 114856 ms failed attempt is retained, and the adjusted 142230 ms full run passed. |
| 3 — independent adversarial review | The controller's independent reviewer checked the retained test, production consumers, actual trace and evidence ceiling. It found missing HP/result/history proof, duplicate-event blindness, weak route identity, incomplete stall diagnostics and unconditional helper PASS. No actual campaign result was fabricated by the earlier run. | Reopen the test package; all five findings are addressed in this correction round. |
| 4 — counterexamples and current consumers | Re-read actual RunState history/result/route schema, the complete changed probe, source-lock implementation and untouched product CI. Negative duplicate and forged-terminal fixtures failed before correction and passed after it; valid draw semantics remain. Restored-worktree import readiness failed separately and was regenerated. | Persistent witness and terminal/route identity predicates retained; no production mutation. Contract and eight adjacent unittest checks pass. |
| 5 — full rerun and retained diff | Re-inspected the full diff/public boundary/CI, exercised the whole native campaign again, and checked every new assertion at production transitions. The 141588 ms result is 10 actual wins, 36 identified routes and exact handoffs with no SCRIPT ERROR. A verbose repeat completed the same assertions in 141240 ms without an exit warning. | Local retained-test review exit is clean with the intermittent teardown observation explicitly limited below. Remote CI and independent re-review remain controller closeout gates. |

Verbose diagnostic repeat command:

```powershell
& 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --verbose --script tests/probe_native_ten_duel_campaign.gd --log-file .godot/native-campaign-review1-verbose.log
```

Result: exit 0, 141240 ms, 10 wins/0 draws, 10 rewards, 36 routes, 387 activations, all guards passed. This repeat has no SCRIPT ERROR, resource error or ObjectDB warning. Because the two-object teardown warning did not recur with verbose output, its object types and cause were not identified. No cleanup delay, warning suppression or product modification was added to obtain the clean repeat. The earlier warning remains an intermittent observation, not a demonstrated fixed bug or a failed campaign assertion. A future recurrence should capture verbose object identities before assigning a production cause.
