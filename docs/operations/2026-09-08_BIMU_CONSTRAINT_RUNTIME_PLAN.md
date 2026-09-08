# 비무 제약 런타임 구현 계획

Latest user implementation continuation is the execution authority; preserve the historical
2026-09-04 planning candidate, and introduce a separately scoped runtime adoption Decision.
Spec locator: codex/human-blueprint-r4-closure-20260907:
docs/planning-data/bimu_constraint_v0_candidate_catalog.json.
The controller read the full candidate, Decision and ten-case benchmark. Current research
reuses the exact selection/composition/disclosure/duration dimension; Hades Pact and God of
War Burdens official pages were fresh-read. ADAPT transparent optional challenge choices;
AVOID copied rewards, hidden scaling and altered core. Feasibility: current RunState,
metrics engine and native shell are concrete consumers; implementation still pending.

Official refresh 2026-09-08:
- https://www.supergiantgames.com/blog/rock-out-in-the-superstar-update/ — explicit optional Pact conditions; ADAPT choice clarity, REJECT importing bounty formula.
- https://blog.playstation.com/2023/04/05/god-of-war-ragnarok-new-game-plus-is-available-now/ — Burdens combination and HUD count; ADAPT active condition feedback, REJECT equipment/stat progression import.
- https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html — profile bottlenecks before optimization; ADOPT shared immutable catalog/preview data, do not claim FPS without measurement.
Limit: official feature descriptions establish mechanisms, not universal player preference
or evidence that these exact numbers are balanced for this game. Existing ten-case packet
supplies the wider comparison and negative cases; no new ten-case research claim here.

## Global Constraints

Nine specified constraints, 0–2 unique, cost <=3, max one enemy reinforcement.
Current duel only; frozen before combat; identical retry receipt; no reward link.
Manual-only seals: star10 / response / recovery / >=2 slots / one owned manual.
Base actions and base ultimates remain legal. No private-plan access, opening distance2
and 3/3/4 preserved. No save schema, random hidden scaling or new scout thresholds.
Original source assets and other worktrees preserved. No external asset needed.
No product completion claim until consumer and runtime verified.

## Task 1: Pure constraint catalog and model

Create data/run/bimu_constraints.json and src/run/bimu_constraint_model.gd, focused
tests/verify_bimu_constraint_model.gd. Read exact source catalog via git show first;
copy specified values, not historical status/consumer claims. Runtime JSON owns nine
options and policy; no runtime dependency on docs or candidate branch.

Model interface:
- get_options() deep copy
- validate_selection(selection: Array, player_manual_ids: Array, enemy_manual_ids: Array)
  returns {valid:bool, errors:Array, selections:Array, selection_point_spent:int,
  disclosed_effects:Array}. Selection items use constraint_id and only specified
  optional parameter field. Fail closed on non-dictionary elements, missing/extra
  fields, invalid types/IDs, duplicates, over count/cost/buffs, invalid ownership.
- action_lock_reason(definition:Dictionary, validated_receipt:Dictionary)->String:
  match manual actions only using actual registry definition fields. Look up actual
  definitions and tests so action_slots/category/unlock_star/manual identity accurate.
  Base action/ultimate cannot match. Return explicit Korean reason.
- enemy_mastery_overlay(masteries:Dictionary,receipt:Dictionary)->Dictionary copy +2 cap10.
- enemy_state_overlay(enemy:Dictionary,receipt:Dictionary)->Dictionary copy:
  momentum+1 capped, stamina/internal+1 current capped, selected stats+1.
  No base catalog mutation. Empty receipt identity.
Receipt validation cannot be bypassed by merely a supplied valid=true: downstream
binding will validate against actual actor-owned catalog. Keep model small and explicit.

TDD missing model RED then pure boundary/eachkind/duplicates/budget/onebuff/
parameter ownership/wrongtypes/extra keys/deepcopy/caps/base guards GREEN.
Use explicit quit(1) failures not raw assert hangs. No UI/RunState edits for Task1.
Report exact observed output and source differences; commit owned files only.

## Task 2: Bind run state and combat enforcement

Consume Task1 model. Add explicit pending selection and frozen receipt tied to duel ID.
Zero selection remains valid. Briefing confirmation freezes; retry restores same; new
duel/run resets. Validate before mutation and no new save schema.
Bridge validates real current identities, mastery overlay before registry configure,
stat/resource overlay after initial state and binding validation. Shared preview and
resolver lock path must reject forbidden real manual IDs even forged definition fields.
UI must not own recomputation. Preserve no-selection existing tests and 10-win probe.
Write RED first for retry/reset/invalid selection and forged placement enforcement.

## Task 3: Native briefing selection and preparation feedback

Use current shell consumer with 9 readable options, bound target choices, selection
count/cost/reason, current-duel text, explicit zero confirmation. Keep known/public
opponent copy and own mastery. Display selected effect deltas, not hidden base stats.
Preparation marks forbidden manual cards with reason and active constraint summary;
normal inputs cannot reserve/place forbidden cards. Keep existing input semantics.
Verify at720p/800p, keyboard, first/last options, no overlap; actual capture.
When wiring constraint state, avoid rebuilding unchanged native manual/ultimate lists:
current set_manuals resets horizontal scroll on every identical context and ultimate
context rebuilds repeatedly. Same-data updates must preserve node/focus/scroll identity;
changed receipt/mastery/resources still refresh correctly. Add an identity/count regression
and measure rebuild reduction, not an unmeasured FPS claim. This is bounded to touched
consumer setters, not a generic UI framework.

## Task 4: Integration and delivery

Run constraint model/state/bridge/UI tests, corrected sequential campaign, full Python,
existing product UI tests. Whole scope adversarial review and 5 meaningful loops.
Update Decision/ActiveContext/roadmap/runtime evidence, exact protected approval and CI.
Reconcile main, normal merge, postmerge readback. Human/Android/rights/release remain
separate unrun gates; no silent candidate final-lock promotion.
