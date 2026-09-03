# 2026-09-03 · Modular Duel UI and Presentation Execution Report

## Execution receipt

| field | record |
| --- | --- |
| current project main read | `origin/main` `0afdef427257ae5f8bcc2f37b7c46e13bc00b44b`; it is an ancestor of this task worktree `f99d723aa85f5524b51235d54801df921cb1eba9` |
| task route | PR [#321](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/pull/321), `codex/human-blueprint-additive-recovery-20260902`; only the task-owned PR was mutable, #199 and #200 remained read-only and do not overlap the changed product paths |
| Work Mode | `BUILD → REVIEW` |
| selected skills / modes | `combat-implementation-handoff / implementation-contract, build, runtime-handoff`; `combat-ux-and-accessibility / ui-contract, runtime-review`; `ten-paces-verification / contract-check, runtime-validation, regression, evidence-report` |
| approved scope | four final-locked UI frames; current 3/3/4 bundle only; safe type-only observation; preparation-versus-reveal surfaces; attack, evade, block, hit, ultimate, and shared-anchor clash presentation only |
| protected contract | `check_approved_project_operating_contract.py` passed after the explicit current task approval record added the actual `action_selection_dock.gd` consumer path; no ruleset/admin bypass, main push, force push, or unrelated deletion was used |

## Current-authority and Base readback

The responsibility order was applied as `AGENTS.md → current project main → current Decisions and Active Context → actual code/scenes/data/assets/tests → open PR overlap → adopted Base profile → current Base reuse handoff`.

The project remains pinned to the adopted Base release `v9.4.4` (`210ec782…`, finalization `5adc196c…`). Current Base remote `main` was freshly read at `850204b3e5de81a4045111b4a050c46c5a292b59`. Its new `CURRENT_PROJECT_WORK_HANDOFF` was **ADAPT**ed only for current-authority order, reuse-first boundaries, and evidence handoff. It does not silently replace the project pin and no Base runtime module was installed.

`TEN_PACES_COMBAT_MOTION_CATALOG_20260903.md` is classified as a research draft: it proposes a larger motion-state/clip system but declares no current canon, asset, or runtime approval. The exact current product consumer uses the approved presentation-only methods on `CombatCharacterPlaceholder`; expanding to a 22–30 motion clip system would exceed this Decision. It is therefore **DEFERRED**, not partially auto-adopted.

The existing 12-game and frontal-duel 10-case benchmark packets were reused only after a fresh same-dimension check: this package changes information hierarchy and presentational readability, not combat economy, hidden plan rules, save data, deck/hand/draw, or AI inputs.

## Problem → adopted structure

The previous screen had a valid three-surface composition but did not give status, current actions, technique details, and observation each a reusable image-backed shell. The prior free-floating observation label also made the protected information boundary hard to audit. The action reveal still resembled a lower-card choice instead of a single resolved action.

The adopted structure is intentionally thin:

- Four locked transparent PNGs are canonical sources under `docs/visual-assets/approved/TEN-MODULAR-DUEL-UI-20260903/` and byte-identical runtime textures under `assets/ui/duel/`.
- `CombatantStatusPanel`, `ActionTimingSlot`, `ActionDetailPanel`, and `ObservationRevealPanel` own only dynamic public text and frames. The board remains the composition owner and the resolver remains the result owner.
- Player resources render `current/max`; enemy numeric resources remain hidden. Momentum remains five segments. Observation sanitizes to allowed action types and cannot display skill name, target, damage, direction, cost, private plan, or AI state.
- Preparation shows the lower planning surface. Action resolution hides the complete lower surface and uses compact top/middle callouts for the present current action only.
- Combat motions modify only visual transforms. They return to the same foot anchor; a clash computes one shared horizontal anchor and returns both actors to their starting ground line.

## Implementation and use

```text
Preparation
  top: player/enemy status frames, public distance and round
  middle: distant frontal duel on one ground line
  lower: current 3/3/4 bundle, basic/martial/ultimate cards, detail and type-only observation

Plan locked / one action resolves
  top + middle only
  → one current action callout
  → attack / evade / block / hit / ultimate / clash presentation
  → no lower cards, detail, future action, or editable plan
```

The canonical state was also corrected: `current_user_planning_status.json` and `ACTIVE_CONTEXT.md` now point to `TEN-DEC-20260903-MODULAR-DUEL-UI-AND-PRESENTATION-MOTION-01`, while the operational roadmap now names `REPOSITORY_HUMAN_FACING_CANON` instead of retired Notion-as-current wording.

## Verification evidence

| claim | evidence and result |
| --- | --- |
| approved protected-path route | current operating-contract validator: `PASS` |
| Godot import/parse | Godot `4.7.1` headless editor scan: exit `0`; class/texture import succeeded. Engine shutdown emitted `45 ObjectDB` and `22 resources still in use` warnings, retained as diagnostics rather than hidden. |
| UI asset, public-information, action-fact regression | `verify_modular_duel_ui_presentation`, `verify_phase2_observation`, `verify_action_card_source_unification`: `PASS` |
| screen/reveal regression | `verify_combat_action_reveal`, `verify_frontal_duel_screen_partition`, `verify_frontal_duel_plan_lock`, `verify_vertical_slice_shell`: `PASS` |
| grounded motion regression | `verify_combat_character_art`: `PASS`; it protects shared foot-line return, common clash anchor, and presentation-only state isolation |
| adjacent presentation regression | `verify_combat_sfx_presentation`: `PASS`; its shutdown reported `6 ObjectDB` instances, recorded separately from the pass result |
| canonical current-state correction | the current-state contract was first made to fail against the stale 2026-09-01 state, then corrected through `current_user_planning_status.json`, `ACTIVE_CONTEXT.md`, and the matching regression assertions |
| combat contract and asset-consumer closure | `tests/check_combat_board_contract.py`: `PASS`; it first rejected the new manifest entries, then now requires all four source/runtime byte hashes, alpha status, and active consumer registration |
| full Python regression | `python -m unittest discover -s tests -p 'test_*.py' -v`: `455` tests, `OK` |
| exact-head remote CI correction | Initial remote head `b60e8be6` exposed a stale static expectation in `tests/check_action_selection_contract.py`: it required a stage-only slot label after the approved UI began rendering `[전조/실행] + 기술명`. The direct check was reproduced locally as `FAIL`, the contract was corrected to require the named planned action, and `action selection contract: PASS`, the 455-test suite, board contract, protected-contract validator, and diff check all passed locally. Correction head `cb32f7dc` is pushed to PR #321; its remote non-Full-validation workflows are successful, while the two Linux Godot jobs in `Full Validation` remain `IN_PROGRESS` at this receipt's readback. |
| current preparation runtime capture | `TEN-RVC-20260903-001`: a fresh `1280×800` client-area PNG (`SHA-256 31e653d5f57b02b423e38f37c0b290f55d283371e8610f568548c2ad262c1365`) was captured from the exact task Godot process after verifying its project path and scene, then registered through the project capture validator. The manifest records the direct scene route, all concrete consumers, `0` capture diagnostics, and the dirty task-worktree source delta. It proves this preparation composition as `MACHINE_RUNTIME_CAPTURE`; it is not an exact-committed-head claim or Human/device/accessibility/release evidence. |

## Five adversarial review loops

1. **Lineage and rights:** checked source/runtime paths, SHA-256, dimensions, transparent corners, true alpha, final-lock phrase, and concrete runtime consumers. No rejected candidate or locked v2 actor byte is replaced.
2. **Information boundary:** attacked observation with prohibited private values and enemy numeric values. The panel sanitizes type literals only; the regression snapshot requires player numeric visibility and enemy numeric invisibility.
3. **Surface and future-information boundary:** attacked reveal state for remaining lower cards, detail, observation, combat log, and future actions. The resolution surface hides the complete lower planning shell and the overlay declares no selection cards/future actions.
4. **Presentation isolation:** attacked ground drift, unequal clash center, overlap persistence, and reduced-motion behavior. Motions use transforms only, preserve foot anchors, and do not write resolver/AI/save/plan state.
5. **Authority, test, and hygiene boundary:** compared current main, task PR, active docs, actual consumers, adopted Base pin, and current Base handoff. The stale current-state owner was corrected and tested. Temporary capture output remains outside Git under `build/runtime-capture-source/`; removal was authorized but blocked by the execution safety policy, so it is not staged or represented as project evidence.

## Reuse-learning handoff

```yaml
selected_modules:
  - existing CombatBoardPreview composition and resolver event surface
  - existing CombatCharacterPlaceholder locked-v2 texture route
  - existing 2026-08-30 and 2026-09-01 benchmark evidence
reuse_mode: REUSE_EXISTING_PROJECT_IMPLEMENTATION + ADAPT_WITH_THIN_PROJECT_ADAPTER
project_paths_changed:
  - assets/ui/duel/
  - src/ui/
  - src/combat/
  - scenes/ui/
  - docs/ and tests/ current responsibility owners
verification_evidence: focused Godot verifier batch, Godot import, current-state RED-to-GREEN contract, full Python regression (455 tests), and TEN-RVC-20260903-001 preparation runtime capture
evidence_ceiling: MACHINE_RUNTIME_CAPTURE for the 1280x800 preparation screen; locked-action reveal/motion visual capture, human/player, Android, accessibility-user, release performance, and release rights remain unverified
rollback: remove only this task's runtime UI textures and their consumers together from the task branch; preserve the approved canonical source PNGs and all locked pre-existing actors
project_only_lessons: an observation frame must own sanitization and a reveal overlay must be bounded by the actual duel-stage rect, not the whole viewport
base_promotion_candidates: NONE; one project-specific Godot UI composition is not cross-project evidence
```

## Unverified and next safe work

The current result is `PARTIAL`: implementation and local automated checks are complete, and repository-controlled `MACHINE_RUNTIME_CAPTURE` now covers preparation, hover detail, plan lock, and a current-action reveal.  The exact-head Full Validation Linux Godot jobs were still `IN_PROGRESS` at the earlier recorded readback.  This is not a claim that player readability, physical input, accessibility-user behavior, Android, release performance, or asset release rights has passed.

That previously pending locked-action reveal capture is now recorded in the later 2026-09-03 plan-lock correction addendum.  Human/player comparison remains separately deferred.

## 2026-09-03 reference-layout correction addendum

### Problem → correction

The supplied comparison showed that the prior live preparation surface still made the detail text collapse into the locked portrait frame's right medallion.  It also made the intended right-side information geometry difficult to compare with the approved 5×2 planning reference.  The correction deliberately did **not** replace a locked combatant, background, or frame PNG.

- The preparation board keeps the verified `20% top / 40% duel / 40% planning` split, current three-slot bundle, compact lock immediately after the bundle, distant grounded characters, and separate lower planning surface.
- The reusable `ActionDetailPanel` now has a `250 px` allocated right column.  Its locked outer detail frame remains visible, while an inner parchment contract surface gives cost, effect, and range a single text-safe width instead of writing through the ornamental medallion.
- The idle detail panel stays hidden until a real card is hovered or pinned.  Hovering `이동 1수` visibly exposes `소모: 기력 0 · 내력 0 · 1수`, `효과: 이동 1`, and `사거리: 1`; rich metadata remains model-owned below the compact first viewport.
- The generated compact-frame candidate was inspected before adoption.  Although its lanes had useful geometry, its delivered file was `1168×1347` `Format24bppRgb` with a checkerboard baked into the exterior rather than true alpha.  It was not copied into the repository, manifest, or Godot runtime and is **not** a canonical asset or a user-final-lock request.

### TDD, runtime, and comparison evidence

1. Added the full-width compact-detail regression to `verify_frontal_duel_screen_partition.gd`.  It first failed with `Compact technique detail needs one full-width readable text lane...`; after the `250 px` column and inner parchment contract implementation it passed.
2. Focused Godot 4.7.1 headless results: `verify_frontal_duel_screen_partition`, `verify_action_detail_panel`, `verify_frontal_duel_plan_lock`, `verify_phase2_observation`, `verify_combat_character_art`, and `verify_combat_action_reveal`: all `PASS`.
3. The Godot 4.7.1 headless editor scan exited `0` and parsed/imported the changed scene.  Its shutdown emitted `45 ObjectDB` instance and `22 resource` leak warnings, retained as warnings rather than a zero-warning claim.  A clean HERA direct-scene runtime itself recorded `0` diagnostics errors and warnings.  `TEN-RVC-20260903-003` registers the idle `1280×800` reference-layout preparation state (`SHA-256 cb448c76c874c7988fb2633c8b9029121cf4467b3a8d767d11fc4cbe481d8a4e`).  `TEN-RVC-20260903-004` registers the distinct hover-detail state (`SHA-256 d2868c6d9689a748b7acb81414148e88d7d2ab47ec4ec1881375248ba5823543`).
4. The supplied target and the same-width `1280×800` runtime were placed into a temporary comparison-only review image before acceptance.  The review verified the intended three-surface hierarchy, centered distance/round, wide paired status frames, compact plan/lock grouping, 5×2 grid, distant grounded duel, and right-side detail/observation columns.  The temporary comparison is not a product asset or repository evidence.
5. `check_combat_board_contract.py`, `test_frontal_duel_action_flow_blueprint_contract.py` (`6` checks), `test_observation_answer_leak_guardrails_contract.py` (`14` checks), JSON parsing, and the protected-contract validator all passed after the exact consumer-path approval list was reconciled.

### Five adversarial review loops for this correction

1. **Reference geometry:** compared the supplied composition and the actual runtime at a common width.  Rejected the earlier near-half-screen planning layout; retained the current 20/40/40 partition and current-bundle-only row.
2. **Text-safe compact detail:** forced the text-width regression to RED, then required at least `200 px` of body lane with an inner inset before GREEN.  This catches both a too-small host and content written onto frame ornamentation.
3. **Information and interaction boundary:** re-ran plan-lock and observation regressions.  The lock remains beside the three visible slots; observation remains visible as a structural lower column but only receives safe revealed action types; enemy numbers/private plan data remain absent.
4. **Grounding and reveal boundary:** re-ran character-art and action-reveal checks.  Presentation transforms still return to their same foot anchors, clash remains shared-anchor only, and the lower planning surface remains hidden during resolution.
5. **Asset and hygiene boundary:** checked the compact-frame candidate's actual pixel format before any asset routing, rejected it from production, and preserved locked art bytes.  A stale untracked intermediate capture cannot be removed in this execution environment because the direct deletion operation is policy-rejected; it remains explicitly registered rather than leaving a dangling manifest pointer.  No broad cleanup, forced reset, or unrelated generated-import staging was performed.

### Evidence ceiling and next safe work

`TEN-RVC-20260903-003` and `TEN-RVC-20260903-004` are `MACHINE_RUNTIME_CAPTURE` only.  They do not establish Human/player visual approval, physical input quality, accessibility-user usability, Android device behavior, release performance, or shipping rights.  The next safe in-scope continuation remains a visual capture of the plan-locked action-reveal/motion sequence; the user explicitly deferred player comparison.

## 2026-09-03 plan-lock duel-surface correction addendum

### Problem → adopted structure

The first visible lock-state review exposed an important composition defect: hiding only the lower planning widgets produced a black unused lower band.  That contradicted the user's instruction that a locked plan should leave the top status plus the combat screen, not a blank page.  The corrected two-step flow preserves the existing rule boundary—first lock does not resolve, second execution resolves exactly once—while moving the second compact CTA into the combat stage.

- At lock, the lower planning surface, timing slots, source tabs/cards, detail, and observation panel are hidden together.
- The translucent duel stage, final-locked courtyard background, and banner extend through the released lower screen area.  The distant player and enemy are re-anchored to that enlarged courtyard floor without logical tile visibility or resolver mutation.
- `3수 실행` is a compact centered CTA inside the expanded duel stage.  After it is pressed, only the current player/enemy action callouts are revealed; future slots and all planning UI remain hidden.

### TDD and runtime evidence

1. The plan-lock verifier first failed because both the duel stage and background stopped above the hidden planning band.  It now requires the lower planning surface to be hidden, the CTA to be enclosed by `DuelStageSurface`, and both stage/background to reach the viewport bottom; `FRONTAL_DUEL_PLAN_LOCK_VERIFY_OK` is the GREEN result.
2. `TEN-RVC-20260903-005` is the fresh `1280×800` plan-locked expanded-duel capture (`SHA-256 3215cbdddc8acc2a59080b113682525781b3e651210f0613eca92ed91672f889`).
3. `TEN-RVC-20260903-006` is the fresh `1280×800` current-action reveal capture (`SHA-256 7ed650b7893078be070208cefadfe4f22f5f7af788d0871d1bb4960b07794380`).  It was produced by direct Godot scene launch, synthetic placement of three legal basic actions, explicit lock, then explicit execution—no hidden plan, state injection, or asset substitution.
4. The six focused Godot verifiers and the protected operating-contract validator were run again after this correction: all passed.  HERA diagnostics were `0` errors and `0` warnings for both capture runs.

### Five adversarial review loops for the lock-state correction

1. **Blank-space attack:** hid the lower controls in a live run and found the black lower band.  The test now fails unless the duel stage and background reach the released viewport bottom.
2. **Interaction attack:** preserved the existing two-step lock/execute contract, then checked that the only post-lock CTA is reparent-free, centered in the duel stage, and remains directly operable.
3. **Information attack:** confirmed that timing, cards, hover detail, observation, and input switching are all hidden/locked before reveal; only public status, distance, and the execution CTA remain.
4. **Ground and asset attack:** re-expanded only the existing final-locked background/banner layout and recalculated actor foot anchors.  No battle raster byte, renderer rule, logical board visibility, resolver, AI, or save data changed.
5. **Resolution attack:** drove a legal three-action bundle through lock and execution, re-ran the reveal/grounding regressions, inspected HERA diagnostics, and registered separate fresh captures for lock and current action.

### Evidence ceiling

The plan-locked and action-reveal images prove the machine runtime composition and public presentation state only.  They are not human readability approval, physical play evidence, Android evidence, accessibility-user evidence, release performance proof, or permission to alter the locked art assets.

## 2026-09-03 current-state contract repair

The full local regression deliberately caught three stale expectations that still described the earlier `TEN-RVC-20260903-001` preparation-only state after the newer hover, lock, and single-action-reveal captures were registered.  The current-state regression now requires the aligned repository owners to name `001/003/004/005/006`, retain `HUMAN_DEFERRED`, and identify the native 2D presentation Decision as latest.  This corrects the contract consumer rather than reverting accurate evidence owners.

The first remote PR run then exposed a separate legacy source-text assertion in `tests/check_action_selection_contract.py`: it still required every individual timing slot to display the selected technique name.  The active runtime and its focused linked-block verifier instead intentionally place the name on the single linked action block, while each slot shows only `전조` or `실행` and keeps the full name in accessibility context.  The contract now guards that current split explicitly.  Local evidence after the repair: the action-selection contract check passed; the related 28 Python regressions passed; the complete Python suite passed `455/455`; and the focused six Godot 4.7.1 verifiers plus the protected operating-contract validator passed.  The subsequent exact-PR-head remote checks remain a separate CI readback.

The next exact-head CI readback found two historic keyboard regressions still expecting playback, reduced-motion, and sound controls to appear in the preparation traversal.  That contradicted both the reference-layout implementation and the current partition verifier, which intentionally remove those controls from the preparation surface.  The repaired focus contracts now require the visible sequence to wrap from the compact plan lock back to the source tabs, and require all four retired presentation controls to be hidden with `FOCUS_NONE`.  The focus-order, keyboard-accessibility, assistive-label, focus-visual, layout-accessibility, and action-selection-integration Godot verifiers were rerun locally and all passed.  No combat rule, action-selection behavior, AI, save schema, or image byte changed in this repair.
