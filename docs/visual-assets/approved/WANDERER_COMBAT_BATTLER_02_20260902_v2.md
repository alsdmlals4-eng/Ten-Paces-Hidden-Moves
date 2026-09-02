# WANDERER_COMBAT_BATTLER_02_20260902_v2

- **Asset ID:** `player_wanderer_battler_rgba_v2`
- **Lifecycle:** `USER_FINAL_LOCKED → CANON_REGISTERED → IMPLEMENTED → MACHINE_RUNTIME_VERIFIED_20260902`
- **Approved source:** `docs/visual-assets/candidates/WANDERER_COMBAT_BATTLER_02_20260902_v2.png`
- **Canonical source copy:** `docs/visual-assets/approved/WANDERER_COMBAT_BATTLER_02_20260902_v2.png`
- **Runtime destination:** `res://assets/characters/player_wanderer_battler_rgba_v2.png`
- **SHA-256:** `383fd9a62de43d1b9c5c6c38f1ad9d537d8f088c08e4f25e23e974b87dc08864`
- **Dimensions / alpha:** `1024×1536`, RGBA; alpha extrema `0..255`; transparent pixels `922489`; partially transparent pixels `650375`; corner alpha `0,0,0,0`; visual bounds `56,120–984,1412`; bottom safety margin `123 px`.
- **Runtime consumers:** `CombatCharacterPlaceholder.PLAYER_ART_PATH`; `MainTitleScreen.PLAYER_PATH`.

## User approval and visual boundary

The user explicitly approved this revised player in the 2026-09-02 message: “방금 2 이미지는 승인”. The approved role is a left-side character facing right, with a low, single body-proportional sword ending near the forward boot. The source has no baked floor; the shared runtime floor anchor and contact shadow remain code-owned.

`player_wanderer_battler_rgba_v1` remains a recoverable manifest entry marked `SUPERSEDED_BY_USER_FINAL_LOCK_20260902`; it is neither deleted nor consumed by the current generic player route.

## Provenance and rights boundary

Generated as an original project asset with OpenAI built-in image generation (`exec-4695661f-7c4a-46a2-afaa-113372e4504c`). User references informed broad animated-wuxia styling and gameplay readability only, not reference pixels, poses, identities, UI, or composition. `TEN-RVC-20260902-001` records the same shared floor baseline in actual Godot rendering at exact source commit `847ede9085781f9c38c8d8c1c4b6624de974b965`; `TEN-RVC-20260902-002` records the reusable title composition.
