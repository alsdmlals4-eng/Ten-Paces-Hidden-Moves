# MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01 v1

## Canonical asset identity

- **Status:** `USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_RUNTIME_VERIFIED`.
- **User final lock:** `삽화 확정` (2026-08-31).
- **Approved asset:** `MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png`.
- **SHA-256:** `227a0492399d287fec073d7bccb36dc84eae1dd0c6d11247302e24ca87c3750e`.
- **Dimensions:** `1536 × 1024` PNG.
- **Generator:** OpenAI built-in image generation.
- **Generation output ID:** `exec-42629f32-87fa-457f-a6a5-5454b002c500`.

## Purpose and ownership

This text-free 4×2 semantic atlas supplies the top illustration area of the shared `ActionChoiceCard` for martial techniques and ultimates. The cells cover sword, saber, palm/internal force, spear/staff, meditation, guard, footwork, and a restrained gold ultimate. Names, costs, unlock state, range, effects, keyboard focus, and accessibility text remain UI/data binding; the illustration never becomes the sole rule carrier.

The user-provided combat references informed only the warm hanji-and-ink direction and card-scale readability. The asset contains no copied reference pixels, UI, text, composition, character likeness, logo, watermark, or franchise identity. Release rights remain conditional: the user remains responsible for input rights and final use, and output similarity is not guaranteed unique.

## Source, destinations, and consumer

- **Candidate provenance:** `docs/visual-assets/candidates/MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png`.
- **Approved canonical PNG:** this directory’s `MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png`.
- **Runtime PNG:** `res://assets/ui/cards/martial_ultimate_card_illustration_atlas_01_v1.png`.
- **Asset manifest:** `martial_ultimate_card_illustration_atlas_01_v1` in `assets/ASSET_MANIFEST.json`.
- **Runtime route:** `ActionViewModelAdapter` source-kind semantic mapping → `ActionChoiceCard` → `MartialActionPanel` and `UltimateActionPanel`.

All three PNG destinations are exact byte-equivalent to the final-locked candidate. The layout is one renderer and one semantic atlas, rather than panel-specific art surfaces, so martial and ultimate cards retain the same card hierarchy as basic actions.

## Verification boundary

Focused Godot parser/import, action-card source-unification, martial-panel, and ultimate-panel checks verify the implemented route. Visible Windows Godot runtime observation verifies that the concrete panels create illustration regions through the shared card renderer. This does not establish a human readability, accessibility-user, Android-device, release-performance, or release-rights PASS.
