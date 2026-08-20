# First Five-Duel Vertical Slice · Phase I/II/III/IV/V/VI Build Approval

- Gate: `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`
- Planning Complete: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`
- Visual/UX: `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`
- Approved on: `2026-08-20 KST`
- Approval source: user instruction `이미지 생성 외 작업을 진행하자` followed by continued implementation approval `진행해`
- Authority level: `SCOPED_PC_FIRST_VERTICAL_SLICE_PHASE_I_II_III_IV_V_VI`

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
9. the approved current-name six-manual starter selection, four-manual RunState persistence, public Briefing data binding, and runtime combat-loadout handoff;
10. neutral causal Review wording, raw five-metric Result evidence, a grade-formula-pending Result state, and one-of-three Duel reward receipt selection;
11. Phase V run progression ownership for reward application, inter-duel resources, Growth/Recovery Route choices, Info/Preparation clues, Route history, and next-duel resource restoration;
12. Phase VI retained five-Duel public history plus a read-only structured Completion summary of outcomes/opponents, Review causes, growth, rewards, Route choices, and the approved brief recurring-peer ending beat.

### Phase I bridge extension · PR #178 scope

- subclass the existing ten-manual CombatBoardPreview only to surface terminal Review events to the run shell;
- preserve resolved terminal combat state while Combat Review is shown;
- route terminal Review confirmation to separate RunState `RESULT` instead of restarting Vertical Slice combat;
- instantiate a fresh existing-combat-derived view only when the next duel actually enters `COMBAT`;
- do not alter combat resolution formulas, AI decision information, manual effects, balance, hidden-plan rules, or the default project main scene.

### Phase II opponent catalog / Route lock extension · PR #179 scope

- encode exactly `5 duel slots × 3 candidates = 15` working candidates from approved planning canon;
- reference current runtime `manual_id`, manual-card IDs, and basic-action IDs rather than duplicate combat content;
- preserve slot difficulty seeds `20/22/24/26/28` and mastery seeds `3/7/7/7/9`, with `slot3_biyeon` capped at mastery `4` and Tang star3 only so enemy `[관찰]` authority is never introduced;
- keep exact permanent-stat distributions and exact AI numeric weights absent/deferred;
- mark the temporary deterministic candidate selector as `REVERSIBLE_SELECTION_BINDING`, not final save/RNG canon;
- lock Duel 1 before Briefing and lock the next opponent exactly once when a confirmed Result leaves for Route;
- preserve the same locked candidate through both Route nodes and promote it to the next Briefing without reroll.

### Phase III Setup / Briefing / runtime loadout extension · PR #180 scope

- map the historical starter-six concept to the six current manuals: `매화검결 / 나한금강공 / 태극검결 / 양가창결 / 자하심법 / 소요보결`;
- obtain faction/name/stat/star3 technique metadata from current `MartialManualRegistry`;
- require exactly four unique starter manuals, all at mastery `3`, before Setup may advance;
- reject a fifth simultaneous selection and avoid deck/hand/draw vocabulary;
- render only approved public Briefing fields while keeping `현재 계획`, AI numeric weights, internal candidate/behavior keys, and selector seed hidden;
- rebind the existing ten-manual combat bridge to the selected four player manuals and locked opponent signature manual/mastery;
- preserve inherited combat formulas, hidden-information boundaries, basic actions, and manual effects.

### Phase IV Review / Result extension · PR #181 scope

The same PC-first authority covers the next bounded handoff-plan slice:

- keep Combat Review as a read-only combat overlay and retain `CAUSE → FAILURE → CONSEQUENCE` evidence already derived from resolved combat;
- replace prescriptive `다음 묶음에서는 ...` guidance with a neutral `검토 관점` that points to the causal relationship to inspect without selecting the player's next move;
- preserve legacy non-Vertical-Slice terminal restart behavior, while the Vertical Slice terminal Review labels its CTA `결과 확인` and transitions to separate Result;
- track only the five already-approved raw Battle Grade metrics: `successful_dodges`, `clash_wins`, `player_health_lost`, `rounds_elapsed`, `ultimate_uses`;
- collect those metrics in an isolated Vertical Slice resolution-engine wrapper after normal combat resolution, without changing combat formulas or outcomes;
- carry those raw metrics in the terminal Result payload;
- render Result with `grade_status = FORMULA_PENDING` and `final_grade = ""` while S/A/B/C weights, normalization and thresholds remain TBD;
- do not revive legacy `S85/A70/B55/C0` thresholds or invent replacement grade math;
- expose exactly three approved Duel reward types as receipts: `자유 수련 +6`, `집중 수련 지정 무공 +5 + 자유 +3`, `문파 전수 상대 시그니처 무공 3성`;
- require a valid reward receipt before Result can leave for Route or Completion;
- require focused-training target to be one of the player's current manuals;
- record exactly one confirmed reward receipt per Duel in RunState history;
- lock the next opponent only after a valid reward exists and the confirmed Result actually leaves for Growth/Recovery Route, preserving the existing no-reroll contract;
- mark Result UI as structured functional UI only, not final visual or Human evidence.

### Phase V Route / run progression extension · PR #182 scope

The same PC-first authority covers the first complete inter-duel progression loop:

- introduce a dedicated progression state owned by RunState for current owned manuals, mastery, per-manual accumulated training, unallocated free-training pool, persistent player resources, and unresolved duplicate faction-transfer receipts;
- use the approved mastery costs from 3★ upward: `4★=2 / 5★=3 / 6★=4 / 7★=5 / 8★=6 / 9★=8 / 10★=10`, recalculating mastery from total accumulated training rather than discarding residual points;
- apply a confirmed Result receipt exactly once as Result leaves for Route: free-training receipts increase the free pool; focused-training receipts apply `+5` to the chosen owned manual and `+3` to the free pool; non-duplicate faction transfers add the opponent signature manual at 3★;
- do not invent a value conversion when a faction-transfer manual is already owned: record that receipt as `PENDING_DUPLICATE_POLICY` until a separate canon decision exists;
- persist terminal player `health / stamina / internal` current/max pairs from Combat into RunState and inject those pairs into the newly instantiated next-duel combat bridge;
- expose exactly three logical Growth/Recovery choices per R1/R3/R5/R7 node: recovery, focused training, free training;
- use reversible Route seeds `R1/R3 focus +1 / free +3`, `R5/R7 focus +2 / free +4`;
- recovery applies `25% max HP + stamina 1 + internal 1`, capped at each maximum; integer HP recovery uses the explicitly reversible temporary policy `REVERSIBLE_NEAREST_INTEGER` until balance validation revisits it;
- require one Growth/Recovery choice before transition to the paired Info/Preparation node;
- expose exactly three public-info categories per R2/R4/R6/R8 for the already-locked next opponent;
- require exactly one Info/Preparation choice, record it against that candidate, and append the resulting public clue to the next Briefing;
- keep internal behavior keys, AI numeric weights, selector seed, current hidden plan, and answer-card information out of Route intel;
- keep the locked next opponent invariant through both Route nodes and promote that exact candidate to Briefing without reroll;
- record exactly one Route-history receipt for each of the eight Route visits;
- keep the Route shell as `STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL`.

### Phase VI Completion Summary extension · PR #183 scope

The same PC-first authority covers only the final first-slice completion review:

- retain exactly five completed Duel history rows with Duel number, actual opponent identity, outcome, resolved Review cause summary, and only the five already-approved raw Battle Grade metrics;
- keep Completion history player-visible and read-only; do not retain current hidden plans, AI numeric weights, selector seed, internal behavior keys, or answer-card information for summary display;
- build a structured Completion snapshot from five Duel rows, five confirmed reward receipts, eight Route receipts, and the existing progression snapshot;
- summarize only the top `2–3` observed Review cause codes with actual occurrence counts;
- show only `1–2` most-grown manuals from actual accumulated training/mastery state;
- include the approved brief recurring-peer closing beat without turning it into a diagnosis or tutorial answer;
- expose the snapshot through the existing run shell using `STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL` status;
- do not alter combat formulas, opponent selection, Route values, reward values, mastery costs, AI information authority, or final-grade math.

## Protected invariants

- logical 10-cell battlefield;
- `3 → 3 → 4` combat bundles;
- hidden current plans;
- public-state-only enemy AI;
- distance / clash / response / interruption / review;
- player-only `[관찰]` authority;
- existing ten martial manuals;
- cards remain an action catalogue, not deck/hand/draw gameplay;
- Combat Review overlay / Duel Result separate Scene-state / Route separate Scene-state boundary;
- exactly two Route nodes between Duels 1-4;
- next-opponent information changes knowledge only and may not reroll the locked candidate.

## Explicitly not authorized by this build

- changing combat formulas, hidden-information access, manual effects, or combat balance formulas;
- adding an eleventh manual or enemy-only combat rule;
- committing exact AI numeric weights or exact permanent-stat distributions as final balance;
- making the temporary deterministic candidate selector the final save/RNG policy;
- defining S/A/B/C Battle Grade weights, normalization, thresholds, or any final grade formula;
- inventing duplicate `문파 전수` conversion/refund value before a separate planning decision;
- spending the free-training pool automatically or inventing an unapproved free-point allocation UX;
- treating the reversible 25% HP integer rounding policy as final balance canon;
- labeling the player as an attack/defense/personality type from Completion history;
- recommending a correct build, next-run answer, or deterministic counter from Completion history;
- Windows/Android Adapter implementation;
- Android physical-device completion;
- Human fun/readability PASS;
- release readiness claims;
- new image generation or promotion of any supplied/generated example image to approved product asset.

## Evidence ceiling

- RunState headless verification: required;
- shell integration headless verification: required;
- terminal Combat Review → Result bridge headless verification: required;
- 15-candidate catalog/runtime-ID legality verification: required;
- candidate-ID hygiene verification: required;
- shell catalog binding + Result→Route lock/no-reroll verification: required;
- six-current-starter / exact-four Setup / Briefing public-info / combat runtime-loadout binding verification: required;
- neutral Review / raw five-metric / formula-pending Result / reward-receipt gating verification: required;
- persistent resource / progression / R1-R8 Route choice / Route intel / next-Combat restoration verification: required;
- five-Duel retained history / Completion snapshot / Completion shell binding verification: required;
- existing PR / Full / Product Gate validation: required for runtime changes;
- Windows visible local usability: `NOT_RUN`;
- Android physical device: `BLOCKED_UNVERIFIED`;
- Human validation: `NOT_RUN`;
- final visual approval: `USER_REFERENCE_EXAMPLES_RECEIVED_NOT_APPROVED`.

## Provisional visual-reference intake note

Reference scope is limited to the Ten Paces martial-arts example screens explicitly supplied for this project. Any unrelated images supplied in chat are out of scope and must not be recorded, compared, or promoted as Ten Paces reference material.

The in-scope examples are **reference examples only, not approval**. Shared tendencies that may inform later visual work without constraining Phase VI logic are:

- ink-wash / aged-paper visual language;
- dark charcoal-black surfaces with restrained gold framing and highlights;
- character portraits integrated into tactical information panels;
- card/action-driven combat planning UI;
- strong hierarchy between battlefield, current bundle/timeline, resources, and detail panels;
- result/training and pre-duel preparation screens that reuse the same frame language.

The in-scope examples contain both non-pixel ink illustration and pixel-like/hybrid combat rendering. Therefore renderer treatment, character render style, exact palette, typography, density, and final layout remain `NOT_APPROVED` and must not be inferred as final canon.
