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
| durable screen captures | `NOT_REGISTERED`: preparation was observed in the exact Windows game during this task, but no repository PNG was registered. A fresh isolated worktree run then found two same-title 4.7.1 game windows; automation correctly refused to guess a target, and the newly started empty run was closed without touching the user-active run. No artificial or stale capture is claimed. |

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
verification_evidence: focused Godot verifier batch, Godot import, current-state RED-to-GREEN contract, full Python regression (455 tests) passed
evidence_ceiling: MACHINE_VERIFIED; Windows preparation observed without a durable repository capture; locked-action visible flow, human/player, Android, accessibility-user, release performance, and release rights remain unverified
rollback: remove only this task's runtime UI textures and their consumers together from the task branch; preserve the approved canonical source PNGs and all locked pre-existing actors
project_only_lessons: an observation frame must own sanitization and a reveal overlay must be bounded by the actual duel-stage rect, not the whole viewport
base_promotion_candidates: NONE; one project-specific Godot UI composition is not cross-project evidence
```

## Unverified and next safe work

The current result is `PARTIAL`: implementation and automated checks are complete, but no durable current repository capture exists and the locked-action Windows sequence was not continued after active user input was detected. This is not a failure of the core rules or a claim that player readability, physical input, accessibility-user behavior, Android, release performance, or asset release rights has passed.

The next safe continuation is a fresh exact-worktree Windows capture run when the active user interaction has ended: capture one preparation frame and one locked-action reveal/motion frame, hash/register them in the existing runtime-capture manifest, then conduct the separately deferred human/player comparison.
