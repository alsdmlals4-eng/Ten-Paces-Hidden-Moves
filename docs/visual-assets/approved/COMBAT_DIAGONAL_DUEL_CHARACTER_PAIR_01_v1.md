# COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01 v1

## Asset identity

- **Status:** `USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_MACHINE_RUNTIME_VERIFIED_20260830`
- **User final lock:** explicit `확정` on 2026-08-30.
- **Canonical source asset:** `docs/visual-assets/approved/COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01_v1.png`
- **Runtime master:** `res://assets/characters/combat_diagonal_duel_character_pair_01_v1.png`
- **Runtime derivatives:** `res://assets/characters/player_diagonal_duel_battler_01_v1.png` and `res://assets/characters/dogyeom_diagonal_duel_battler_01_v1.png`
- **Generator output id:** `exec-4e154749-1c4b-46a5-89b9-1afcb0f57651`
- **Source SHA-256:** `7572a0e6393893ef977e195a00291ed04cc293afb0a86e8d76b045d9e8343c03`
- **Dimensions:** `1672 × 941` transparent PNG (`Format32bppArgb`)

The canonical and runtime-master PNGs are byte-identical to the reviewed final-locked source. Both corners and sampled outside pixels are transparent; the original RGB checkerboard candidate was not registered or consumed.

## Consumer and deterministic derivative contract

`CombatCharacterPlaceholder` remains the sole battler-art consumer. It uses the following derived, true-RGBA crops without changing tile, combat, AI, plan, save, or status-panel rules.

| Runtime derivative | Crop from master | SHA-256 | Consumer |
| --- | --- | --- | --- |
| `player_diagonal_duel_battler_01_v1.png` | `[0, 0, 920, 941]` | `837f14b2a8d4c2cd6b6ee6618c3b65966250a7b569db8b4080fb33e609441e79` | player `PLAYER_ART_PATH` |
| `dogyeom_diagonal_duel_battler_01_v1.png` | `[752, 0, 920, 941]` | `3878aea5a9f8754b27f3a8d8456aa1fa92f66d4379b956ccf8a88ab8c9f32cf5` | enemy `DOGYEOM_ART_PATH`, only when `candidate_id == "slot1_dogyeom"` |

The left derivative preserves the foreground player’s right-facing cloak and sword silhouette. The overlapping right crop preserves the smaller inward-facing opponent and the end of the shared central sword line. The existing generic enemy battler remains the route for every non-Dogyeom or missing candidate ID. The prior player and Dogyeom battlers remain tracked as inactive rollback assets; no prior file was overwritten or deleted.

## Scoped brief and reference boundary

The one generated pair is an original Korean wuxia duel: large cloaked player at lower left, smaller masked swordsman at upper right, both facing into a quiet confrontation, with warm hanji paper and charcoal ink rendering on transparent background. It excludes text, UI, logos, watermark, new combat information, and third-party character likeness.

The user-provided screenshots informed only the general left/right scale hierarchy, inward-facing diagonal staging, and ink-paper mood. No supplied pixels, UI skin, labels, or character expression were included in the runtime image. Position, distance, health, labels, cards, and effects remain Godot/data-owned overlays.

## Rights and evidence ceiling

This asset is recorded as `CONDITIONAL_RELEASE_RIGHTS`, not a release clearance. The official [OpenAI Terms of Use](https://openai.com/policies/terms-of-use/) effective 2026-01-01 assign OpenAI’s rights in Output to the user as between the user and OpenAI, to the extent permitted by applicable law. They also keep responsibility for input rights and lawful final use with the user and warn that Output may not be unique.

Machine/runtime verification confirms loading, transparent crop integrity, foot-anchor preservation, the generic-enemy fallback, the `slot1_dogyeom` route, and visible current-frame rendering in Godot 4.7.1. It does **not** establish human usability, accessibility-user review, Android device quality, store approval, or legal release clearance; those remain `NOT_RUN`.
