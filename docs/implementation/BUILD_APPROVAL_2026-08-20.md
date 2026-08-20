# First Five-Duel Vertical Slice · Phase I/II/III Build Approval

- Gate: `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`
- Planning Complete: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`
- Visual/UX: `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`
- Approved on: `2026-08-20 KST`
- Approval source: user instruction `이미지 생성 외 작업을 진행하자`
- Authority level: `SCOPED_PC_FIRST_VERTICAL_SLICE_PHASE_I_II_III`

## Approved scope

This build may implement the first bounded runtime phases of `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`:

1. a RunState/flow controller for `Main → Setup → Intro → Briefing → Combat → Review → Result → Route → next Briefing → Completion`;
2. exactly five duel visits and exactly eight inter-duel Route visits;
3. Review and Result as separate states;
4. no Route after Duel 5;
5. a shell/bridge around the existing CombatBoardPreview without rewriting combat resolution rules;
6. automated headless verification for the new flow;
7. structured text/frames and existing approved assets while final visual reference remains pending;
8. the approved fifteen-opponent first-slice catalog and reversible runtime selection/lock binding;
9. the approved current-name six-manual starter selection, four-manual RunState persistence, public Briefing data binding, and runtime combat-loadout handoff described below.

### Phase I bridge extension · PR #178 scope

The same user-approved Phase I authority covers the bounded terminal bridge increment:

- subclass the existing ten-manual CombatBoardPreview only to surface terminal Review events to the run shell;
- preserve the resolved terminal combat state while Combat Review is shown;
- route terminal Review confirmation to the separate RunState `RESULT` instead of restarting the POC combat;
- instantiate a fresh existing-combat-derived view only when the next duel actually enters `COMBAT`;
- carry only terminal outcome/health/review-summary data across the bridge;
- do not alter combat resolution formulas, AI decision information, manual effects, balance, hidden-plan rules, or the default project main scene.

### Phase II opponent catalog / Route lock extension · PR #179 scope

The same user instruction explicitly authorizes the next data-binding layer without reopening protected combat rules:

- encode exactly `5 duel slots × 3 candidates = 15` working candidates from the approved planning canon;
- reference current runtime `manual_id`, unlocked manual-card IDs, and basic-action IDs rather than inventing duplicate combat content;
- preserve slot difficulty seeds `20/22/24/26/28` and mastery seeds `3/7/7/7/9`, with `slot3_biyeon` capped at mastery `4` and Tang star3 only so enemy `[관찰]` authority is never introduced;
- keep exact permanent-stat distributions and exact AI numeric weights absent/deferred;
- mark the temporary deterministic candidate selector as `REVERSIBLE_SELECTION_BINDING`, not final save/RNG canon;
- bind the validated opponent catalog into the technical Vertical Slice shell with a fixed technical seed used only for deterministic CI/runtime scaffolding;
- lock Duel 1 before its Briefing;
- keep the next opponent unavailable through unresolved Result presentation, then lock it exactly once when Result is confirmed and the run enters the first Route node;
- preserve the same locked candidate through Growth/Recovery and Information/Preparation Route nodes;
- promote that locked candidate to the next Briefing without Route reroll;
- treat candidate IDs as stable internal identifiers with no whitespace; working names/appearance/faction/personality remain reversible content detail.

The fixed technical seed is not a final player-facing randomization or save/retry policy. A later save-state/data-binding phase may replace it while preserving deterministic reproduction and the no-reroll Route contract.

### Phase III Setup / Briefing / runtime loadout extension · PR #180 scope

The same scoped PC-first implementation authority covers the next approved handoff-plan slice:

- map the historical starter-six concept to the six **current** player-facing manuals: `매화검결 / 나한금강공 / 태극검결 / 양가창결 / 자하심법 / 소요보결`;
- obtain faction/name/stat/star3 technique metadata from the current `MartialManualRegistry`, not duplicated legacy display strings;
- require exactly four unique starter manuals before the Setup CTA can advance;
- start each selected starter manual at mastery `3` and persist the four IDs/mastery map in RunState;
- reject a fifth simultaneous selection and avoid deck/hand/draw vocabulary in player-facing Setup copy;
- render Briefing from the already-locked opponent's approved public fields: working name, martial identity, current signature-manual display name, readable habit, ambiguity/counterexample, and public briefing hook;
- explicitly preserve `현재 계획`, AI numeric weights, internal candidate IDs/behavior keys, and selector seed as hidden/non-player-facing information;
- rebind the existing ten-manual combat bridge at duel entry so the player uses the selected four manuals and the enemy uses only the locked candidate's approved signature manual/mastery seed instead of the legacy fixed PoC loadout;
- keep the inherited combat resolution engine, formulas, hidden-information boundaries, basic actions, and manual effects unchanged;
- mark Setup/Briefing presentation as structured functional UI only, not final visual or Human evidence.

This Phase III approval is recorded in the same runtime-changing PR so Base v9 BUILD governance can verify scope from the local diff.

## Protected invariants

- logical 10-cell battlefield;
- `3 → 3 → 4` combat bundles;
- hidden current plans;
- public-state-only enemy AI;
- distance / clash / response / interruption / review;
- player-only `[관찰]` authority;
- existing ten martial manuals;
- cards remain an action catalogue, not deck/hand/draw gameplay;
- Combat Review overlay / Duel Result separate Scene / Route separate Scene boundary;
- exactly two Route nodes between Duels 1-4;
- next-opponent information changes knowledge only and may not reroll the locked candidate.

## Explicitly not authorized by this build

- changing combat formulas, hidden-information access, manual effects, or combat balance formulas;
- adding an eleventh manual or enemy-only combat rule;
- committing exact AI numeric weights or exact permanent-stat distributions as final balance;
- making the temporary deterministic candidate selector the final save/RNG policy;
- implementing Route rewards/recovery/info choice effects beyond the already-approved state boundary;
- Windows/Android Adapter implementation;
- Android physical-device completion;
- Human fun/readability PASS;
- release readiness claims;
- new image generation or promotion of the current generated concept to product asset.

## Evidence ceiling

- RunState headless verification: required;
- shell integration headless verification: required;
- terminal Combat Review → Result bridge headless verification: required;
- 15-candidate catalog/runtime-ID legality verification: required;
- candidate-ID hygiene verification: required;
- shell catalog binding + Result→Route lock/no-reroll verification: required;
- six-current-starter / exact-four Setup / Briefing public-info / combat runtime-loadout binding verification: required;
- existing PR / Full / Product Gate validation: required for runtime/data changes;
- Windows visible local usability: `NOT_RUN`;
- Android physical device: `BLOCKED_UNVERIFIED`;
- Human validation: `NOT_RUN`;
- final visual approval: `USER_REFERENCE_PENDING`.
