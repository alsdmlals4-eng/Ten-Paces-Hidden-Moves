# ATTACK_CLASH_INK_GOLD_ATLAS_01 v1

## Final lock and approved destination

- **Lifecycle:** `USER_FINAL_LOCKED → CANON_REGISTERED → IMPLEMENTED → MACHINE_VERIFIED_20260831`.
- **User final lock:** explicit `모두 확정` on 2026-08-31.
- **Canonical source:** `docs/visual-assets/approved/ATTACK_CLASH_INK_GOLD_ATLAS_01_v1.png`.
- **Runtime asset:** `res://assets/vfx/attack_clash_ink_gold_atlas_rgba_v1.png`.
- **Runtime consumer:** `CombatBoardPreview._show_feedback_vfx`; upper atlas band for `attack`, lower atlas band for `clash`.
- **SHA-256:** `0859c714728608744b3f016e03c02f7b0e18d86b0b0ced191a2d5ec25ce2553f` for candidate, canonical source, and runtime asset.
- **Dimensions:** `1774 × 887` PNG.
- **Generator output:** `exec-a87618fa-38d4-40a5-abf7-7643951e419b`.

The final-locked bytes remain opaque at source, so `CombatBoardPreview` applies a neutral-light `ShaderMaterial` matte at runtime to prevent a white checker rectangle from hiding the duel. Focused Godot verification covers asset discovery, atlas selection for both bands, and the presence of that protective matte. This is machine evidence only; human visual quality, Android-device rendering, accessibility-user review, and release readiness remain unverified.
