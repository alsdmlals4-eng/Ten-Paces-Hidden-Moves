# Campaign continuation plan

## Global Constraints

User authorizes continuous implementation, recreation and runtime connection of images,
VFX, sound and motion without intermediate approval. Preserve originals. This changes
the candidate-lock wait for this bounded work, not rights/release or human QA claims.
Baseline 751f4ee0. Existing dirty files in this worktree are the preceding task's work.
Do not touch other worktrees. Do not stage generated import metadata. No force/direct main push.
Spec: docs/operations/2026-09-08_TEN_DUEL_CAMPAIGN_IMPLEMENTATION.md plus latest user direction.

### Task 1: Campaign regression closure

Own src/run/vertical_slice_run_state.gd, vertical_slice_opponent_catalog.gd,
vertical_slice_route_model.gd, vertical_slice_completion_model.gd and campaign/route tests.
Do not edit shell/UI/art files (controller owns them).
Review preceding uncommitted ten-duel implementation. Correct missing boundary checks,
retry/reset/idempotence, invalid combat outcome acceptance, ten distinct valid opponent
bindings, four successive three-choice nodes per interval, no post-final route.
Route effects must actually apply once. Preserve current combat and reward semantics;
no save schema expansion. Add meaningful RED tests before behavior fixes. Update obsolete
five-duel/two-node tests to new behavior rather than delete coverage. Avoid terminal hangs
on unexpected arrays. Run focused Godot tests and applicable Python contracts. Commit
only owned production/tests; include preceding changes to owned files in this commit.
Use installed Godot 4.7.1 console at C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe.
Report expected legacy failures separately from regressions. Do not spawn agents.

### Task 2: Atlas presentation integration

Controller owns shell/UI/background/audio/presentation and visual provenance.
Connect newly generated blue-ink courtyard to game; remove incompatible sepia foreground
where appropriate. Reuse and improve actor motion, hit/clash/evade/ultimate VFX and sound.
Replace placeholder UI surfaces with atlas-compatible paper/ink hierarchy; no baked numbers.
Test actual consumers and capture normal rendered viewport, preserve mute/reduced motion.
Continue with always-visible preparation costs/slots/main effect and range summaries.
Combat engine owns numerical previews; UI must not represent formula base as final power.
Preserve two-row grid and validate native labels at 720p/800p before capture.

### Task 3: Combined verification

Review state and presentation contracts together, run regressions, actual renderer captures,
attempt full campaign through real combat. Record evidence ceiling honestly. Reconcile
Active Context and Blueprint asset linkage. Required CI/review before authorized merge.
