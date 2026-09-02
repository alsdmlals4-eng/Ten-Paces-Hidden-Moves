# FRONTAL_COURTYARD_MODULAR_ART_PACK_20260902_v2

```yaml
asset_pack_id: FRONTAL_COURTYARD_MODULAR_ART_PACK_20260902_v2
status: USER_FINAL_LOCKED__CANON_REGISTERED__IMPLEMENTED_PENDING_MACHINE_RUNTIME_VERIFICATION
generation_mode: USER_FEEDBACK_SCOPED_SINGLE_IMAGEGEN_REVISION_PER_CHARACTER
predecessor: FRONTAL_COURTYARD_MODULAR_ART_PACK_20260902_v1
user_feedback_applied:
  - character modules must read as wuxia plus animation, not photoreal concept art
  - background, banner, and each combatant must remain separately generated layers
  - sword must remain body-proportional and terminate by the forward-foot zone
reference_role:
  user_image_1: broad style anchor only: low-key charcoal silhouette, wind-swept robe masses, readable martial-arts animation value grouping
  excluded: user character, pixels, pose, and screenshot composition are never copied
style_lock:
  medium: hand-painted Korean wuxia animation key art; confident charcoal brush outline; flat-to-gently-celled shadows; sparse dry-brush and ink specks over a hanji-paper material
  composition: frontal shared-ground duel; environment first; low left-right combatant scale
  prohibited: photoreal skin/material treatment, glossy 3D, extended sword/beam/trail, floating feet, baked ground, background rectangle, UI, text, logo, watermark
modules:
  - id: FRONTAL_COURTYARD_BACKGROUND_02
    reuse_from: FRONTAL_COURTYARD_MODULAR_ART_PACK_20260902_v1
    output: docs/visual-assets/candidates/FRONTAL_COURTYARD_BACKGROUND_02_20260902_v1.png
    state: USER_FINAL_LOCKED__CANON_REGISTERED__IMPLEMENTED_PENDING_MACHINE_RUNTIME_VERIFICATION
    intended_runtime_consumers:
      - src/combat/battle_background.gd
      - src/ui/main_title_screen.gd
  - id: FRONTAL_COURTYARD_BANNER_OVERLAY_01
    reuse_from: FRONTAL_COURTYARD_MODULAR_ART_PACK_20260902_v1
    output: docs/visual-assets/candidates/FRONTAL_COURTYARD_BANNER_OVERLAY_01_20260902_v1.png
    state: USER_FINAL_LOCKED__CANON_REGISTERED__IMPLEMENTED_PENDING_MACHINE_RUNTIME_VERIFICATION
    intended_runtime_consumers:
      - proposed BattleBackground foreground overlay in combat board
      - proposed main-title foreground overlay
  - id: WANDERER_COMBAT_BATTLER_02
    output: docs/visual-assets/candidates/WANDERER_COMBAT_BATTLER_02_20260902_v2.png
    source: C:/Users/user/.codex/generated_images/01a04af4-16f3-7153-96fc-823b2094d386/exec-4695661f-7c4a-46a2-afaa-113372e4504c.png
    dimensions: 1024x1536
    sha256: 383fd9a62de43d1b9c5c6c38f1ad9d537d8f088c08e4f25e23e974b87dc08864
    alpha: verified__transparent_pixels_922489__partially_transparent_pixels_650375__opaque_pixels_0
    alpha_bounds_at_threshold_16: 56,120-984,1412
    foot_safe_bottom_margin_px: 123
    state: USER_FINAL_LOCKED__CANON_REGISTERED__IMPLEMENTED_PENDING_MACHINE_RUNTIME_VERIFICATION
    predecessor: WANDERER_COMBAT_BATTLER_02_20260902_v1
    intended_runtime_consumers:
      - src/combat/combat_character_placeholder.gd PLAYER_ART_PATH successor
      - src/ui/main_title_screen.gd PLAYER_PATH successor
  - id: MASKED_SWORDSMAN_COMBAT_BATTLER_02
    output: docs/visual-assets/candidates/MASKED_SWORDSMAN_COMBAT_BATTLER_02_20260902_v2.png
    source: C:/Users/user/.codex/generated_images/01a04af4-16f3-7153-96fc-823b2094d386/exec-3eae95cf-fa7d-44f4-b326-8a2e839d7fbe.png
    dimensions: 1024x1536
    sha256: 0841505d275ca970d7d085d7ab206788276517d2290a63960d829e657dfbe17f
    alpha: verified__transparent_pixels_970318__partially_transparent_pixels_602546__opaque_pixels_0
    alpha_bounds_at_threshold_16: 88,124-1000,1428
    foot_safe_bottom_margin_px: 107
    state: USER_FINAL_LOCKED__CANON_REGISTERED__IMPLEMENTED_PENDING_MACHINE_RUNTIME_VERIFICATION
    predecessor: MASKED_SWORDSMAN_COMBAT_BATTLER_02_20260902_v1
    intended_runtime_consumers:
      - src/combat/combat_character_placeholder.gd ENEMY_ART_PATH successor
      - src/ui/main_title_screen.gd ENEMY_PATH successor
approval_boundary: User final lock is explicit for all four modules: revised player/enemy in “방금 2 이미지는 승인”, then background/banner in “배경,깃발도 방금 만든거 2개 승인” (2026-09-02). Canon registration and runtime implementation are now scoped to this exact pack. Machine runtime verification, Human/UX verification, Android-device verification, and release-rights clearance remain separate.
```

## Review focus

1. Both full bodies use one horizontal foot baseline with no baked ground or dark halo, so the runtime can supply the one shared contact shadow and align them to the courtyard floor.
2. Both swords are a single low, physical blade next to the front boot; neither becomes a horizontal attack line, long beam, or VFX trail.
3. The player remains left-facing-right and the masked opponent right-facing-left. The background and banner are still independent layers; no image contains another module.
4. The exact pack is final-locked and replaces only the generic background/player/enemy consumers. The Godot machine/runtime capture is still pending and must be recorded separately; no Human, Android, accessibility-user, or release claim is made.
