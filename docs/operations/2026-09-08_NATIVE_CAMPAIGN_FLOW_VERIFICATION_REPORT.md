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
