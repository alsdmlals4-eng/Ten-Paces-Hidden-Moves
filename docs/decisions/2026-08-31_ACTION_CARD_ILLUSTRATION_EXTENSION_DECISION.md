# TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01

## Decision

Extend the shared action-card presentation so that **basic actions, martial-manual techniques, and ultimates** can all use the same compact, semantic card-illustration treatment. The existing `ActionChoiceCard` remains the sole card renderer; no second card layout, manual-specific illustration panel, or separate ultimate presentation is introduced.

## Authority and supersession

- **User direction:** card illustrations are to be included across all card surfaces.
- **Supersedes for the current direction:** the no-illustration choice in `TEN-DEC-20260830-MARTIAL-MANUAL-TEXT-FIRST-PRESENTATION-01`.
- **Historical pre-lock constraint:** the atlas remained a candidate until the separate explicit final lock. That condition is now satisfied by `삽화 확정` (2026-08-31); the implementation outcome below is the current authority.

## Adopted structure

1. Keep one `ActionChoiceCard` renderer and one shared top illustration region.
2. Map each action to a semantic atlas region at the action-view-model boundary, rather than embedding different layouts in martial and ultimate panels.
3. Preserve names, costs, action count, unlock status, category, range, effect text, keyboard focus, tooltip, and assistive labels as text. Illustration is supplementary, never the only carrier of gameplay information.
4. Route the existing approved basic atlas only to basic actions. Prepare the new martial-and-ultimate atlas candidate solely as provenance/review material until final lock.
5. After final lock, copy exact bytes to the approved and runtime locations, register hash/provenance/consumer in the asset manifest, attach illustration specs to the current action data or adapter, and run UI/runtime verification before claiming implementation.

## Scope boundary

The candidate contains anonymous, text-free semantic technique vignettes only. It is not a mock-up, does not alter combat rules, does not expose hidden AI information, and does not replace the one-action-at-a-time reveal sequence. Candidate generation, byte readback, and machine visual inspection are not user UX approval, accessibility-user validation, Android-device validation, release approval, or an asset-rights guarantee.

## User final lock and implementation outcome

- **User final lock:** `삽화 확정` (2026-08-31) applies to the reviewed exact candidate `MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1`.
- **Canonical promotion:** the candidate is copied byte-for-byte to `docs/visual-assets/approved/MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png` and to `res://assets/ui/cards/martial_ultimate_card_illustration_atlas_01_v1.png`.
- **Runtime route:** `ActionViewModelAdapter` assigns semantic atlas regions to martial-manual actions and the dedicated ultimate region to every ultimate. `ActionChoiceCard` remains the one renderer, with the same text, cost, lock, focus, tooltip, and accessibility information.
- **Verification required and performed:** exact-byte SHA-256 readback, manifest/readback, focused Godot UI regressions, and a visible Godot runtime review are recorded by the successor execution report. Human UX, accessibility-user, Android-device, release performance, and release/rights clearance remain separate evidence gates.
