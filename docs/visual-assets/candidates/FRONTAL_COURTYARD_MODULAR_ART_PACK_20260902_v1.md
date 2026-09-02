# FRONTAL_COURTYARD_MODULAR_ART_PACK_20260902_v1

```yaml
asset_pack_id: FRONTAL_COURTYARD_MODULAR_ART_PACK_20260902_v1
status: GENERATED_CANDIDATE__CHARACTER_MODULES_SUPERSEDED_BY_V2
generation_mode: FOUR_SINGLE_SCOPED_IMAGEGEN_CANDIDATES
reference_roles:
  user_image_1:
    owns: centered gate and sun, wide warm stone courtyard, symmetrical frontal perspective, gold sunset world mass
  user_image_2:
    owns: low left-right fighter scale, charcoal ink contour, dark amber dusk mood, environment-first composition
style_lock:
  medium: semi-realistic charcoal ink and sepia wash on worn hanji paper
  palette: amber-gold sky, muted stone brown, charcoal-black foreground, restrained antique gold only for decision/VFX accents
  camera: frontal, centred gate/sun, continuous shared ground, no diagonal staging
  prohibited: logical floor grid, numbered tiles, invented UI/text/logo, neon, glossy 3D, oversized energy, watermark
modules:
  - id: FRONTAL_COURTYARD_BACKGROUND_02
    output: docs/visual-assets/candidates/FRONTAL_COURTYARD_BACKGROUND_02_20260902_v1.png
    intended_runtime_consumers:
      - src/combat/battle_background.gd
      - src/ui/main_title_screen.gd
    existing_active_asset: res://assets/backgrounds/frontal_courtyard_duel_background_01_v1.png
    state: GENERATED_CANDIDATE__do_not_replace_active_asset
    source: C:/Users/user/.codex/generated_images/01a04af4-16f3-7153-96fc-823b2094d386/exec-3d7cc1b7-de1b-4322-82f4-288108f1d2a7.png
    dimensions: 1672x941
    sha256: 1f36bb1b853cf6008ca9d54bf71ebe1ce3916ce90db75a8caca1e62e5ad076fd
    alpha: none_expected_for_environment__verified_rgb
    requirements: environment only; no people, banners, weapons, UI, text, or action effects
  - id: FRONTAL_COURTYARD_BANNER_OVERLAY_01
    output: docs/visual-assets/candidates/FRONTAL_COURTYARD_BANNER_OVERLAY_01_20260902_v1.png
    intended_runtime_consumers:
      - proposed BattleBackground foreground overlay in combat board
      - proposed main-title foreground overlay
    state: GENERATED_CANDIDATE__no_current_runtime_consumer
    source: C:/Users/user/.codex/generated_images/01a04af4-16f3-7153-96fc-823b2094d386/exec-66e61807-3dea-4dad-9a65-1a419b7b3ec6.png
    dimensions: 1024x1536
    sha256: 56667318d441f7e74accfc08f7038500e5d3b313bc68a15387f9c3c62608d7e2
    alpha: verified__sampled_transparent_pixels_6144__sampled_opaque_pixels_0
    alpha_bounds_at_threshold_16: 340,8-684,1528
    requirements: transparent-background vertical tattered tournament banner and pole; no crest, text, or person; mirrorable
  - id: WANDERER_COMBAT_BATTLER_02
    output: docs/visual-assets/candidates/WANDERER_COMBAT_BATTLER_02_20260902_v1.png
    intended_runtime_consumers:
      - src/combat/combat_character_placeholder.gd PLAYER_ART_PATH successor
      - src/ui/main_title_screen.gd PLAYER_PATH successor
    existing_active_asset: res://assets/characters/player_wanderer_battler_rgba_v1.png
    state: SUPERSEDED_GENERATED_EXPLORATION__see_WANDERER_COMBAT_BATTLER_02_20260902_v2
    source: C:/Users/user/.codex/generated_images/01a04af4-16f3-7153-96fc-823b2094d386/exec-587f1e17-0be8-41ba-88ad-374a267a8a2b.png
    dimensions: 1024x1536
    sha256: 2882ef6d32fde77e33c5917e9acd0f9decc94a323e46ac786ecf21bcc2e09be3
    alpha: verified__sampled_transparent_pixels_6144__sampled_opaque_pixels_0
    alpha_bounds_at_threshold_16: 20,8-1000,1488
    requirements: transparent-background single full body, faces right, low ready stance, foot-anchor safe, natural low-held sword with no extended blade/energy line
  - id: MASKED_SWORDSMAN_COMBAT_BATTLER_02
    output: docs/visual-assets/candidates/MASKED_SWORDSMAN_COMBAT_BATTLER_02_20260902_v1.png
    intended_runtime_consumers:
      - src/combat/combat_character_placeholder.gd ENEMY_ART_PATH successor
      - src/ui/main_title_screen.gd ENEMY_PATH successor
    existing_active_asset: res://assets/characters/enemy_masked_battler_rgba_v1.png
    state: SUPERSEDED_GENERATED_EXPLORATION__see_MASKED_SWORDSMAN_COMBAT_BATTLER_02_20260902_v2
    source: C:/Users/user/.codex/generated_images/01a04af4-16f3-7153-96fc-823b2094d386/exec-d9c49f34-4e35-4782-a9e1-95bf93b02d6a.png
    dimensions: 1024x1536
    sha256: f0550aa7da71980c9e23e23895470bcf180f8f74b126653811ec5019957fccbe
    alpha: verified__sampled_transparent_pixels_6144__sampled_opaque_pixels_0
    alpha_bounds_at_threshold_16: 72,44-1004,1488
    requirements: transparent-background single full body, faces left, low ready stance, foot-anchor safe, natural low-held sword with no extended blade/energy line
evidence_boundary: All four files remain GENERATED_CANDIDATE after generation. They are not user-final-locked, canon-registered, runtime-integrated, machine-runtime-verified, human-UX-verified, Android-device-verified, or release-rights-cleared.
```

## Cross-module consistency tests

1. The background contains no characters or banners; it must remain reusable across combatants and states.
2. The banner contains no readable mark and can be mirrored without changing meaning.
3. Each combatant contains exactly one full body, a planted foot region, and one physically proportioned sword held low.
4. All modules use the same frontal warm-dusk ink-and-hanji grammar, but no baked shadow from one module assumes another module's position.
5. The three overlay modules were verified to contain sampled transparency and a bounded non-transparent silhouette. The environment intentionally remains opaque RGB.
6. The candidate pack is reviewed as a set before any active runtime asset is replaced.

## Supersession

The user found both v1 character modules too close to photoreal concept art and requested a more readable martial-arts animation treatment. The environment and banner remain valid reusable candidates; only the two character candidates are superseded by `FRONTAL_COURTYARD_MODULAR_ART_PACK_20260902_v2.md`. These source bytes stay retained as generated-review provenance and are not active runtime files.
