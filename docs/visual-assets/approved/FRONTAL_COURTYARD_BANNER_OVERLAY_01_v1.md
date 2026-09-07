# FRONTAL_COURTYARD_BANNER_OVERLAY_01_v1

- **Asset ID:** `frontal_courtyard_banner_overlay_01_v1`
- **Lifecycle:** `USER_FINAL_LOCKED → CANON_REGISTERED → IMPLEMENTED → MACHINE_RUNTIME_VERIFIED_20260902`
- **Approved source:** `docs/visual-assets/candidates/FRONTAL_COURTYARD_BANNER_OVERLAY_01_20260902_v1.png`
- **Canonical source copy:** `docs/visual-assets/approved/FRONTAL_COURTYARD_BANNER_OVERLAY_01_v1.png`
- **Runtime destination:** `res://assets/foregrounds/frontal_courtyard_banner_overlay_01_v1.png`
- **SHA-256:** `56667318d441f7e74accfc08f7038500e5d3b313bc68a15387f9c3c62608d7e2`
- **Dimensions / alpha:** `1024×1536`, RGBA; alpha bounds at threshold 16: `340,8–684,1528`; corner alpha: `0,0,0,0`.
- **Runtime component:** `DuelForegroundBanner` in `src/ui/duel_foreground_banner.gd`.
- **Current consumers:** `CombatBoardPreview` and `MainTitleScreen`; later frontal surfaces configure the same component instead of creating a screen-specific banner duplicate.

## User approval and visual boundary

The user explicitly approved this banner in the 2026-09-02 message: “배경,깃발도 방금 만든거 2개 승인”. It is a transparent foreground module only. `DuelForegroundBanner` mirrors this single project-owned texture for left/right framing, keeps it behind characters and controls, and ignores pointer input. It owns no combat state, camera logic, text, or UI.

## Provenance and rights boundary

Generated as an original project asset with OpenAI built-in image generation (`exec-66e61807-3dea-4dad-9a65-1a419b7b3ec6`). User references informed only functional separate-layer requirements and warm painted wuxia direction. Release rights remain conditional on the project’s asset-rights review; approval and runtime registration do not claim Human/UX, Android, or release PASS.

`TEN-RVC-20260902-001` proves the combat consumer and `TEN-RVC-20260902-002` proves the main-title consumer at exact source commit `847ede9085781f9c38c8d8c1c4b6624de974b965`. Both are machine-only visual records.
