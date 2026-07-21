# Combat POC Milestones

## Implemented

- STEP 0 — Card UI foundation
- STEP 1 — Ten-tile battlefield
- STEP 2 — Character scale and tile placement
- STEP 3 — Ink-wash battle background
- STEP 4 — Top combat HUD
- STEP 5 — 3 / 3 / 4 action timing groups
- STEP 6 — Seven basic-action cards
- STEP 7 — Card detail and collapsible combat log
- STEP 8 — Progress button
- STEP 9 — Card-to-timing placement, confirmed in Windows F5
- STEP 10 — Deterministic bundle resolution and state advancement, awaiting Windows F5 review

## STEP 10 contract

- Combat starts at round 1, bundle 1, timing 1.
- A completed bundle resolves in the order response, quick attack, move, and general action.
- The preview enemy uses a fixed action plan loaded from data; AI remains a later step.
- Resolution updates health, stamina, internal energy, momentum, and battlefield tile positions.
- After each bundle, the next bundle becomes editable; after timing 10, the next round begins at timing 1.
- Same-phase attacks apply damage simultaneously.
- Damage interruption, focus, and fortitude remain disabled until STEP 11.

## Next

- STEP 11 — Damage interruption, focus, and fortitude
- STEP 12 — Simple combat AI
- STEP 13 — Combat end and restart
- STEP 14 — POC playtest
