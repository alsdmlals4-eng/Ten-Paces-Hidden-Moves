# TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01

## Decision

Extend the shared action-card presentation so that **basic actions, martial-manual techniques, and ultimates** can all use the same compact, semantic card-illustration treatment. The existing `ActionChoiceCard` remains the sole card renderer; no second card layout, manual-specific illustration panel, or separate ultimate presentation is introduced.

## Authority and supersession

- **User direction:** card illustrations are to be included across all card surfaces.
- **Supersedes for the current direction:** the no-illustration choice in `TEN-DEC-20260830-MARTIAL-MANUAL-TEXT-FIRST-PRESENTATION-01`.
- **Does not yet authorize runtime promotion:** the newly generated atlas remains a candidate until a separate explicit final lock. Until then, martial and ultimate cards remain text/tag/numeric at runtime and basic-card rendering stays unchanged.

## Adopted structure

1. Keep one `ActionChoiceCard` renderer and one shared top illustration region.
2. Map each action to a semantic atlas region at the action-view-model boundary, rather than embedding different layouts in martial and ultimate panels.
3. Preserve names, costs, action count, unlock status, category, range, effect text, keyboard focus, tooltip, and assistive labels as text. Illustration is supplementary, never the only carrier of gameplay information.
4. Route the existing approved basic atlas only to basic actions. Prepare the new martial-and-ultimate atlas candidate solely as provenance/review material until final lock.
5. After final lock, copy exact bytes to the approved and runtime locations, register hash/provenance/consumer in the asset manifest, attach illustration specs to the current action data or adapter, and run UI/runtime verification before claiming implementation.

## Scope boundary

The candidate contains anonymous, text-free semantic technique vignettes only. It is not a mock-up, does not alter combat rules, does not expose hidden AI information, and does not replace the one-action-at-a-time reveal sequence. Candidate generation, byte readback, and machine visual inspection are not user UX approval, accessibility-user validation, Android-device validation, release approval, or an asset-rights guarantee.
