# FRONTAL_COURTYARD_DUEL_BACKGROUND_01 v1

## Final lock and approved destination

- **Lifecycle:** `USER_FINAL_LOCKED → CANON_REGISTERED → IMPLEMENTED → MACHINE_RUNTIME_VERIFIED_20260831`.
- **User final lock:** explicit `최종확정` on 2026-08-31.
- **Canonical source:** `docs/visual-assets/approved/FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1.png`.
- **Runtime asset:** `res://assets/backgrounds/frontal_courtyard_duel_background_01_v1.png`.
- **Runtime consumer:** `src/combat/battle_background.gd` (`BattleBackground`).
- **SHA-256:** `27778369c3896d7d6237990ec70620c54ad0d636f660c9aa80322b0632262d06` for the reviewed candidate, canonical source, and runtime asset.
- **Dimensions:** `1672 × 941` PNG.
- **Generator output:** `exec-e3ab08d2-ac38-48de-81b4-de02580ecafc`.

## Scope and provenance

This is an original environment-only warm sunset stone courtyard. It gives independent left and right combatant sprites one visible, shared horizontal ground plane while retaining quiet central distance-HUD space. It has no people, weapons, silhouette, UI, text, numerals, logo, watermark, or baked game state.

The user-supplied visual references informed only functional requirements: warm ink-and-hanji material, frontal left/right staging, a grounded stone floor, and readable HUD regions. No reference pixels, character likeness, UI layout, text, or identifiable third-party composition were placed in the generated asset.

The Godot 4.7.1 visible runtime readback passed with the logical tile layer and foot-anchor guide hidden, both combatants on the same `y=267` ground baseline, the live centre label at `거리 2`, and zero runtime diagnostic errors or warnings. The previous inactive background binaries are intentionally absent from the current tree under the user-approved cleanup rule. Their historical approval/provenance records remain in Git history; this does not create a release-rights, human-UX, accessibility-user, Android-device, or release-performance PASS.
