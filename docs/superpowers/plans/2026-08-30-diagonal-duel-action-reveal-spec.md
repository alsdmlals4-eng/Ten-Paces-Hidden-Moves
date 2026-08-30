# Diagonal Duel Characters and Per-Action Reveal Specification

> Status: `USER_CONFIRMED_2026-08-30`
>
> Decision input: the user final-locked the reviewed transparent two-character
> master and confirmed the per-action reveal structure. The supplied screenshots
> are reference-only: image 1 supplies visual hierarchy and image 2 supplies
> reveal cadence only. Neither image supplies rules, text, UI pixels, or a
> shipping asset.

## Goal

Make the live first duel read as an ink-and-hanji confrontation: a larger
> player battler occupies the lower-left foreground, a smaller Dogyeom battler
> occupies the upper-right background, and every resolved timing reveals only
> that timing's two public actions before their visual clash and state update.

## Invariants

- Preserve the one-versus-one ten-cell logical lane, public `거리 N`, opening
  distance 2, and the `[3, 3, 4]` bundle sequence.
- Preserve the resolver, AI information boundary, card IDs/values, save format,
  opponent identity, and existing status portrait routing.
- The resolver remains the sole source of outcome, state, cost, distance,
  damage, interruption, reward, and AI decision. Presentation never calculates
  those values and never changes a result.
- A future timing's enemy action must not be visible before that timing begins.
- Fast replay, skip, and reduced motion may shorten or suppress motion, but
  must retain event order and produce the same authoritative result.
- The current player, Dogyeom, and generic-enemy fallback are separate routing
  cases. This package replaces player and `slot1_dogyeom` battlers only; it
  keeps the generic enemy fallback and Dogyeom's approved status portrait.

## Approved Asset Contract

### Character master

`COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01_v1`

| Field | Value |
| --- | --- |
| Candidate source | `C:/Users/user/.codex/generated_images/01a04af4-16f3-7153-96fc-823b2094d386/exec-4e154749-1c4b-46a5-89b9-1afcb0f57651.png` |
| Candidate SHA-256 | `7572A0E6393893EF977E195A00291ED04CC293AFB0A86E8D76B045D9E8343C03` |
| Candidate dimensions | `1672x941`, transparent RGBA |
| Canonical master | `docs/visual-assets/approved/COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01_v1.png` |
| Runtime master | `assets/characters/combat_diagonal_duel_character_pair_01_v1.png` |
| Derived player | `assets/characters/player_diagonal_duel_battler_01_v1.png`, crop `[0,0,920,941]` |
| Derived Dogyeom | `assets/characters/dogyeom_diagonal_duel_battler_01_v1.png`, crop `[752,0,920,941]` |
| Existing consumer | `CombatCharacterPlaceholder` through its player and `slot1_dogyeom` role routes |
| Source-reference handling | reference composition/mood only; no source pixels, UI, text, or identifiable character were copied |

The two crops are deterministic derivatives of the approved master. They exist
only to keep the current `Texture2D` routing, foot-anchor calculation, and
motion implementation stable. The older player/Dogyeom assets remain tracked
as rollback inputs and are never deleted by this package.

### Basic technique atlas

`TEN-BASIC-TECHNIQUE-INK-ATLAS-01_v1`

The user previously final-locked the reviewed 5-by-2 candidate. This package
promotes the exact reviewed master to
`docs/visual-assets/approved/TEN_BASIC_TECHNIQUE_INK_ATLAS_01_v1.png` and
`assets/ui/cards/basic_technique_ink_atlas_01_v1.png`, then maps its ten cells
in semantic card-ID order:

```text
basic_move, basic_footwork, basic_guard, basic_evade, basic_quick_attack
basic_heavy_attack, basic_observe, basic_meditate, basic_stance, basic_palm
```

No rules, prices, names, text, numbers, or UI are encoded in the raster image.
Card labels and factual values remain native Godot labels.

## Presentation Architecture

```text
CombatResolutionEngine.resolve_bundle (one authoritative call)
→ ordered timing_results (response, then each actual timing)
→ CombatBoardPreview current-state-before-timing
→ CombatActionRevealOverlay shows current timing only
→ existing visual motion/SFX and outcome copy
→ CombatBoardPreview applies that timing's authoritative state snapshot
→ next timing or review
```

`CombatResolutionEngine._resolved_record()` gains post-resolution display
fields copied from the already-resolved action definition: source/category
labels, range, costs, slots, and illustration reference. Its bounded public
history remains restricted to the existing six public fields. The additional
display fields are not AI inputs, plan-preview data, or future-action data.

`CombatActionRevealOverlay` is a presentation-only Control. For one response
or timing it creates up to one player and one enemy action card, displays the
round/bundle/timing header and `대결`, then replaces the cards with the
existing authoritative outcome summary. A side with no action receives an
explicit `행동 없음` presentation cell; it never borrows a card from a future
timing. Multiple same-side events are displayed as a compact ordered list in
that side's current-timing cell.

During a timing reveal, the action dock, timing strip, and progress control are
hidden but retain state. They return only after the existing review confirmation
opens the next bundle. This keeps the player-facing focus on the duel without
discarding the plan or bypassing review.

## Required Behavior

1. `CombatBoardPreview` calls `resolve_bundle` exactly once per committed
   bundle, then locks inputs as it does today.
2. For each `timing_results` entry, the board keeps its current combat state,
   presents only that entry's events, and applies that entry's authoritative
   state after the reveal finishes or is skipped.
3. The action overlay's heading is a native localized label such as
   `제 1 라운드 · 1묶음 · 2수`; the image never supplies that text.
4. Attacks use the existing character lunge; non-attacks retain an event-typed
   visual cue without inventing a different combat outcome.
5. `skip`, `fast replay`, and `reduced motion` retain the previous input and
   accessibility semantics. Skip hides overlays promptly but still walks every
   ordered timing snapshot before review.
6. The overlay is keyboard/mouse inert, exposes accessible state text, and
   never relies on color, animation, or audio alone for the result.

## Acceptance Evidence

- A failing Godot regression proves the previous text-only presentation does
  not construct a per-timing duel overlay or retain pre-timing state during
  the reveal.
- Passing regressions prove character routes, crops, atlas regions, one
  resolver invocation, ordered `[3,3,4]` playback, no next-timing action leak,
  state application after each reveal, and skip/reduced-motion equivalence.
- Static readback proves canonical/runtime bytes, SHA-256, manifest records,
  data references, and legacy rollback assets.
- Exact-worktree Godot runtime evidence covers the start flow to `slot1_dogyeom`
  combat, a complete first bundle, the timing overlay, visible diagonal
  characters, and diagnostics.

## Evidence Ceiling

This package can reach `MACHINE_VERIFIED` and local Windows
`RUNTIME_VERIFIED`. It cannot by itself establish independent human usability,
accessibility-user, Android-device, release-performance, store, or legal
release approval; those remain `NOT_RUN` unless separately evidenced.
