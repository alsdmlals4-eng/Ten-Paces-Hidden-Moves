# Frontal Duel Presentation and Illustrated Card Policy

## Status and authority

`SPECIFIED_FOR_USER_APPROVED_BUILD` under `TEN-DEC-20260831-FRONTAL-DUEL-PRESENTATION-AND-ILLUSTRATED-CARD-POLICY-01`. The user final-locked the reviewed `FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1` candidate on 2026-08-31. The implementation baseline is the current isolated worktree branch, whose upstream comparison baseline remains `origin/main` `0b2ab3fe64a8325b52b743c8d9da03cb23646b3f`.

## Experience contract

The player reads a wide stone courtyard first, then two combatants facing each other on the same visual floor. The eye moves inward to `거리 N`, down to the 3/3/4 plan strip, then to a consistent card dock. The board still represents ten logical positions, but no persistent floor grid competes with the duel scene. Removing the hypothesis selector removes a low-value precommitment surface; it does not disclose enemy plans or remove observation/review information. Removing the visible immediate-complete button keeps sequential action reveal meaningful while fast replay and reduced motion preserve time-control alternatives.

## Component boundaries

| Owner | Change | Preserved responsibility |
| --- | --- | --- |
| `BattleBackground` | Load only the promoted courtyard raster and annotate its frontal-grounded role. | Full-rect responsive texture behaviour; no combat meaning. |
| `CombatBoardPreviewAuto` | Use same-baseline, comparable-scale left/right anchors. | Logical tiles, actions, timing, resolution, and central range state. |
| `CombatBoardPreview` | Stop constructing, laying out, focusing, or resetting the hypothesis/visible-skip controls. | Presentation state, sequential reveal, review, audio/motion options, public observation, action selection. |
| `CombatCharacterPlaceholder` | Route the player to the already approved inward-facing full-body battler. | Candidate-specific enemy routing, art metadata, motion, and foot anchors. |
| `ActionChoiceCard` plus panels | Remain the universal card surface. | Native text, disabled state, accessibility labels, selection signals, and action data ownership. |

## Image policy

The final-locked background is promoted now. The existing basic atlas stays active. The user-approved goal is full card illustration coverage, but non-basic card art has no final-locked image yet. The next visual unit is one original, text-free supplemental 4×2 category atlas for martial, ultimate, and intent cards: footwork, sword attack, guard/response, observation, meditation/recovery, strengthening stance, ultimate energy, and aim intent. It may be generated as one `GENERATED_CANDIDATE`, inspected, and only then receive its own user final lock and exact action-source mapping. Until that gate, the runtime must not claim it has all-card illustration coverage.

## Failure handling

- If the promoted image fails to load, Godot emits the existing `BattleBackground` load error rather than substituting a generated mockup.
- If the front layout has insufficient vertical room, the layout clamps to the existing HUD/timing bounds without moving the plan/dock into the battlefield.
- If focus order contains a deleted node, the focused regression fails rather than skipping to a null control.
- If a non-basic illustration spec is missing or invalid, the future card-art package falls back to native labels and reports incomplete coverage; it does not render an unrelated basic illustration under a false technique identity.

## Evidence ceiling

Automated and visible Windows Godot readback can prove the asset route, layout, controls, input route, and nonfatal runtime state. They cannot prove player comprehension, accessibility-user use, Android behaviour, release performance, legal release clearance, or human visual acceptance beyond the user's explicit asset final lock.
