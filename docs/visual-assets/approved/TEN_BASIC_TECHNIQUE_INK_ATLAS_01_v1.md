# TEN_BASIC_TECHNIQUE_INK_ATLAS_01 v1

## Asset identity

- **Status:** `USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_MACHINE_RUNTIME_VERIFIED_20260830`
- **User final lock:** explicit `확정` on 2026-08-30.
- **Canonical source asset:** `docs/visual-assets/approved/TEN_BASIC_TECHNIQUE_INK_ATLAS_01_v1.png`
- **Runtime asset:** `res://assets/ui/cards/basic_technique_ink_atlas_01_v1.png`
- **Generator output id:** `exec-f2059649-fecd-4456-9557-fc0dbafd6667`
- **SHA-256:** `a047a81c92d51cfa3c0b0d81ac2edf53b9a15e262420753a08bc2ed473ed7998`
- **Dimensions:** `1536 × 1024` opaque PNG (`Format24bppRgb`)
- **Runtime consumers:** `data/cards/basic_cards.json`, `BasicActionPanel`, card-detail consumers, and `CombatActionRevealOverlay`.

The canonical and runtime atlas files are byte-identical to the reviewed final-locked source. The former SVG atlas stays tracked for rollback/history but no basic-card definition points to it.

## Atlas mapping

The separators were measured from the actual raster rather than assumed from an even division. The card data and `assets/ui/cards/card_asset_manifest.json` use these exact art-safe regions:

| Card id | Technique | Region `[x, y, width, height]` |
| --- | --- | --- |
| `basic_move` | 이동 | `[0, 0, 303, 509]` |
| `basic_footwork` | 보법 | `[309, 0, 301, 509]` |
| `basic_guard` | 막기 | `[616, 0, 303, 509]` |
| `basic_evade` | 회피 | `[925, 0, 300, 509]` |
| `basic_quick_attack` | 속공 | `[1231, 0, 305, 509]` |
| `basic_heavy_attack` | 강공 | `[0, 515, 303, 509]` |
| `basic_observe` | 관찰 | `[309, 515, 301, 509]` |
| `basic_meditate` | 명상 | `[616, 515, 303, 509]` |
| `basic_stance` | 준비 | `[925, 515, 300, 509]` |
| `basic_palm` | 장풍 | `[1231, 515, 305, 509]` |

The compact 5×2 planning dock deliberately uses `STRETCH_KEEP_ASPECT_COVERED` so the action pose remains visually legible in a horizontal slot. The larger one-action reveal panels use the same image data alongside native Korean text, action-slot count, range, category, and authoritative outcome. No gameplay text, cost, range, or result is baked into this atlas.

## Scoped brief and rights boundary

The single atlas is an original warm-hanji Korean wuxia technique set, not a copied UI sheet: five columns by two rows representing movement, footwork, guard, evasion, quick attack, heavy attack, observation, meditation, stance, and palm strike. It contains no text, UI, logo, watermark, or third-party character identity.

The user reference informed only high-level ink-paper mood and card readability. The official [OpenAI Terms of Use](https://openai.com/policies/terms-of-use/) effective 2026-01-01 are retained as conditional provenance evidence, not a legal-release PASS. Human card readability, accessibility-user review, Android actual-device quality, and store/release clearance remain `NOT_RUN`.
