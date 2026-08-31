# Frontal Duel Presentation and Illustrated Card Policy

## Status and authority

`IMPLEMENTED_MACHINE_VERIFIED_AWAITING_CORRECT_EDITOR_SCREEN_READBACK` under `TEN-DEC-20260831-FRONTAL-DUEL-PRESENTATION-AND-ILLUSTRATED-CARD-POLICY-01`. The user final-locked the reviewed `FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1` and `MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1` candidates on 2026-08-31. This package begins from isolated-branch head `969ad3e48d530196e86a2741d74e2737f527a9f3`; its upstream comparison baseline is `origin/main` `1509317d59d270087c5ff08b696e8ae9d8e7dfce`.

## Experience contract

The player reads a wide stone courtyard first, then two combatants facing each other on the same visual floor. The eye moves inward to `거리 N`, down to the 3/3/4 plan strip, then to a consistent card dock. The board still represents ten logical positions, but no persistent floor grid competes with the duel scene. Removing the hypothesis selector removes a low-value precommitment surface; it does not disclose enemy plans or remove observation/review information. Removing the visible immediate-complete button keeps sequential action reveal meaningful while fast replay and reduced motion preserve time-control alternatives.

## Component boundaries

| Owner | Change | Preserved responsibility |
| --- | --- | --- |
| `BattleBackground` | Load only the promoted courtyard raster and annotate its frontal-grounded role. | Full-rect responsive texture behaviour; no combat meaning. |
| `CombatBoardPreviewAuto` | Use same-baseline, comparable-scale left/right anchors and a dock that leaves a grounded duel field visible. | Logical tiles, actions, timing, resolution, and central range state. |
| `CombatBoardPreview` | Present one already-public event at a time, with normal attack, clash, and ultimate feedback above the reveal overlay. | Presentation state, sequential reveal, review, audio/motion options, public observation, action selection. |
| `CombatCharacterPlaceholder` | Keep both battlers on a fixed visual floor: no idle vertical bob, no idle foot cross marker, and only a flattened grounded shadow. | Candidate-specific enemy routing, art metadata, combat movement, and foot anchors. |
| `ActionChoiceCard` plus panels | Remain the universal illustrated card surface for basic, martial, and ultimate actions, with explicit range, Ki, inner-power, and effect facts. | Native text, disabled state, accessibility labels, selection signals, and action data ownership. |
| `MainTitleScreen` | Replace technical MAIN-shell copy with the player-facing title, promise, approved courtyard, and one existing start route. | Run-state ownership and the existing shell transition. |

## Image policy

The final-locked courtyard, basic-technique atlas, and supplemental martial/ultimate 4×2 category atlas are active. The latter maps sword, saber, palm/internal, spear/staff, meditation, guard, footwork, and ultimate semantics through `ActionViewModelAdapter` into the same `ActionChoiceCard` renderer; no panel gets a separate illustration system. A new transparent two-band normal-attack/clash VFX is currently `GENERATED_CANDIDATE` outside the repository. Until its own explicit final lock, source hash, manifest registration, and consumer readback complete, normal attack and clash use only the implemented public-event label/motion route. The existing final-locked ultimate RGBA VFX remains active.

## Failure handling

- If a runtime raster lacks its required Godot import metadata, asset loading fails loudly; a single Godot import recreates the required metadata before tests rerun. Required active imports are not cleanup targets.
- If the promoted image fails to load, Godot emits the existing `BattleBackground` load error rather than substituting a generated mockup.
- If the front layout has insufficient vertical room, the layout clamps to the existing HUD/timing bounds without moving the plan/dock into the battlefield.
- If focus order contains a deleted node, the focused regression fails rather than skipping to a null control.
- If a mapped illustration is missing or invalid, the common card retains semantic native facts and reports incomplete coverage; it does not render an unrelated basic illustration under a false technique identity.

## Evidence ceiling

Automated and visible Windows Godot readback can prove the asset route, layout, controls, input route, and nonfatal runtime state. They cannot prove player comprehension, accessibility-user use, Android behaviour, release performance, legal release clearance, or human visual acceptance beyond the user's explicit asset final lock.
