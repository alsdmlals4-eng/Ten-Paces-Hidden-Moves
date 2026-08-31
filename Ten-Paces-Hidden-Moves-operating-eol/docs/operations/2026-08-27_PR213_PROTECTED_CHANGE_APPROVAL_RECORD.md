# PR #213 Protected Change Approval Record

Status: `ARCHIVED_IMMUTABLE_RECORD`

This is the historical archive of the one-time protected-path approval consumed by PR #213. It is not an active approval and cannot authorize a later protected-path change.

## Consumed approval

- Pull request: [#213](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/pull/213)
- Merged main commit: `4e5af6f2740440bffcdf850e71f97589db9fbe7b`
- Superseded protected baseline: `b0e40d035629f87ca15874d7e34f8e9ac3aacca9`
- Approval source: `USER_EXPLICIT_APPROVED_VISUAL_ASSETS_AND_RECOMMENDED_CONTINUATION_2026-08-26`
- Approved scope: `DOGYEOM_COMBAT_BATTLER_01` runtime binding only

## Exact protected-path delta consumed

- `assets/ASSET_MANIFEST.json`
- `assets/characters/dogyeom_combat_battler_01_v1.png`
- `assets/characters/dogyeom_combat_battler_01_v1.png.import`
- `src/combat/combat_board_preview.gd`
- `src/combat/combat_character_placeholder.gd`

## Evidence boundary retained

PR #213's protected-change lifecycle, Base operating contract, focused routing tests, combat art test, and Vertical Slice bridge test passed before merge. The resulting `slot1_dogyeom` Battler is horizontally mirrored at draw time to retain enemy left-facing, while all other and missing candidate IDs use the existing generic fallback. Windows visible human review, Android actual-device validation, and fifteen-opponent identifiability remain `NOT_RUN`; this archive does not change those evidence states.
