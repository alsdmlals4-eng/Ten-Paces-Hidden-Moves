# 2026-09-02 · Modular Frontal Duel Art Pack Execution Report

## Execution receipt

| field | record |
|---|---|
| baseline source commit | `847ede9085781f9c38c8d8c1c4b6624de974b965` |
| Work Mode | `BUILD → REVIEW` |
| Skill / Skill Mode | `ten-paces-hidden-moves-workflow-router / image asset and Godot implementation route`; `imagegen / scoped generation`; `systematic-debugging / capture-path diagnosis` |
| benchmark gate | `REUSED_EVIDENCE`: `docs/reviews/2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md`; this package changes no combat mechanics, deck/hand rule, save schema, or core UX meaning |
| final locks | player/enemy: “방금 2 이미지는 승인”; background/banner: “배경,깃발도 방금 만든거 2개 승인” |
| canonical status | all four modules `USER_FINAL_LOCKED → CANON_REGISTERED → IMPLEMENTED → MACHINE_RUNTIME_VERIFIED_20260902` |

## Work before problem → adopted structure

The previous generic background and battlers remained individually usable but did not form the newly requested painted wuxia-animation family, and the banner had no reusable runtime consumer. The new current route separates the environment-only background, transparent banner overlay, player, and generic enemy into independently versioned files. `DuelForegroundBanner` mirrors one banner asset for both sides, ignores input, and is consumed by both combat and the title surface. It owns no game state, text, targeting, or combat rule.

The old `background_01`, `player_battler_v1`, and `enemy_battler_v1` remain manifest-marked superseded assets, so the change does not destroy prior approved evidence or a recovery path. Dogyeom’s `slot1_dogyeom` route remains unchanged.

## Implementation and expected effect

- `BattleBackground`, `CombatCharacterPlaceholder`, and `MainTitleScreen` now consume v2 modular art.
- `CombatBoardPreview` exposes `DuelForegroundBanner` in its layout snapshot, while the banner stays behind characters and UI.
- Shared foot-anchor and contact-shadow logic is preserved; the new transparent character images carry no baked floor.
- Main and combat both use the same reusable foreground component instead of two screen-specific banner copies.

## Verification evidence

| evidence | result |
|---|---|
| TDD RED | missing `DuelForegroundBanner` preload failed exactly before implementation |
| focused automated tests | `check_combat_board_contract.py`, 11 focused Python unit tests, and four focused Godot verifiers passed |
| Godot import | Godot `4.7.1` editor import parsed the new class and four runtime textures |
| combat capture | [`TEN-RVC-20260902-001.png`](../evidence/runtime-captures/TEN-RVC-20260902-001.png) — 1280×800 actual-window initial combat state, errors `0`, warnings `0` |
| main capture | [`TEN-RVC-20260902-002.png`](../evidence/runtime-captures/TEN-RVC-20260902-002.png) — 1280×800 actual-window main-title component state, errors `0`, warnings `0` |

The capture images prove the exact recorded machine rendering only. Human usability, player approval after viewing the integrated game, Android device, accessibility-user, release performance, and release-rights clearance remain `NOT_RUN`.

## Five adversarial review loops

1. **Asset lineage:** hashes, candidate/approved/runtime destinations, approval phrases, and consumers match. No prior approved bytes were overwritten.
2. **Composition:** combat capture shows both new full-body assets facing each other with a shared floor and short low swords; the title capture shows each layer separately readable.
3. **Reusable behavior:** verifier proves the left/right pair reuses one texture, mirrors only the right side, and cannot intercept input.
4. **Rule isolation:** the diff changes visual paths/structure only; 10-tile distance, 3/3/4 bundle rule, AI information boundary, cards, and Dogyeom-specific route remain unchanged.
5. **Evidence hygiene:** registrar records fresh source paths, run IDs, exact commit, hashes, dimensions, consumers, and zero diagnostics. One failed headless/dummy-renderer capture is unregistered external temporary output, never repository evidence; its text harness and receipts were removed. The remaining PNGs are outside the repository under the OS temporary directory and do not enter the project tree.

## Unverified / next safe work

No Blueprint pages were created or revised in this image-first package. The next safe visual work is Human review at native PC size, then motion-state captures (attack, clash, ultimate) only if the current approved art remains accepted in context.
