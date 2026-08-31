# ATTACK_CLASH_INK_GOLD_ATLAS_01 v1

## Candidate identity

- **Status:** `USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_MACHINE_VERIFIED_20260831`.
- **User final lock:** explicit `모두 확정` on 2026-08-31.
- **Candidate asset:** `ATTACK_CLASH_INK_GOLD_ATLAS_01_v1.png`.
- **SHA-256:** `0859c714728608744b3f016e03c02f7b0e18d86b0b0ced191a2d5ec25ce2553f`.
- **Dimensions:** `1774 × 887` PNG, two horizontal bands.
- **Generator output:** `exec-a87618fa-38d4-40a5-abf7-7643951e419b`.
- **Runtime consumer:** `CombatBoardPreview._show_feedback_vfx`.

## Scoped purpose and rendering note

The upper band is the normal-attack line and the lower band is the clash impact. It is an original ink-and-restrained-gold effect with no gameplay text, card, or copied reference pixels. The user-provided visual direction informed only the need for sequential duel feedback, not any source artwork or interface composition.

The locked source has an RGBA channel but every source pixel is opaque (`alpha 255`), including the light checker backdrop. The source file is therefore retained unchanged and a neutral-light runtime matte removes only the bright, near-neutral backdrop in Godot. Gold, dark ink, and coloured detail remain intact. The matte is a renderer adjustment, not a modified or substituted image asset.
