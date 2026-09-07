# MASKED_SWORDSMAN_COMBAT_BATTLER_02_20260902_v2

- **Asset ID:** `enemy_masked_battler_rgba_v2`
- **Lifecycle:** `USER_FINAL_LOCKED → CANON_REGISTERED → IMPLEMENTED → MACHINE_RUNTIME_VERIFIED_20260902`
- **Approved source:** `docs/visual-assets/candidates/MASKED_SWORDSMAN_COMBAT_BATTLER_02_20260902_v2.png`
- **Canonical source copy:** `docs/visual-assets/approved/MASKED_SWORDSMAN_COMBAT_BATTLER_02_20260902_v2.png`
- **Runtime destination:** `res://assets/characters/enemy_masked_battler_rgba_v2.png`
- **SHA-256:** `0841505d275ca970d7d085d7ab206788276517d2290a63960d829e657dfbe17f`
- **Dimensions / alpha:** `1024×1536`, RGBA; alpha extrema `0..255`; transparent pixels `970318`; partially transparent pixels `602546`; corner alpha `0,0,0,0`; visual bounds `88,124–1000,1428`; bottom safety margin `107 px`.
- **Runtime consumers:** `CombatCharacterPlaceholder.ENEMY_ART_PATH`; `MainTitleScreen.ENEMY_PATH`.

## User approval and visual boundary

The user explicitly approved this revised opponent in the 2026-09-02 message: “방금 2 이미지는 승인”. The approved role is a right-side character facing left, with a grounded low stance, muted red lining, and a single short body-proportional sword ending near the forward boot. The source has no baked floor; runtime owns the shared floor anchor and contact shadow.

`enemy_masked_battler_rgba_v1` remains a recoverable manifest entry marked `SUPERSEDED_BY_USER_FINAL_LOCK_20260902`; it is neither deleted nor consumed by the current generic-enemy fallback.

## Provenance and rights boundary

Generated as an original project asset with OpenAI built-in image generation (`exec-3eae95cf-fa7d-44f4-b326-8a2e839d7fbe`). User references informed broad animated-wuxia styling and gameplay readability only, not reference pixels, poses, identities, UI, or composition. `TEN-RVC-20260902-001` records the same shared floor baseline in actual Godot rendering at exact source commit `847ede9085781f9c38c8d8c1c4b6624de974b965`; `TEN-RVC-20260902-002` records the reusable title composition.
