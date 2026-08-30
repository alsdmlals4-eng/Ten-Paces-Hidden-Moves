# INK_MIST_VALLEY_DUEL_01 v1

## Asset identity

- **Status:** `USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_MACHINE_RUNTIME_VERIFIED_2026-08-30`
- **User final lock:** explicit `확정하자` on 2026-08-30.
- **Canonical source asset:** `docs/visual-assets/approved/INK_MIST_VALLEY_DUEL_01_v1.png`
- **Runtime asset:** `res://assets/backgrounds/ink_mist_valley_duel_01_v1.png`
- **Runtime consumer:** `src/combat/battle_background.gd` (`BattleBackground`)
- **SHA-256:** `3203af421a7ecafd14cd8bb0be0db08dc282f4e9463a372ef593185f3f6cc538`
- **Dimensions:** `1672 × 941` PNG
- **Generation service:** OpenAI built-in image generation
- **Generation output id:** `exec-ab1363be-f939-480e-9cd5-1e506e167e89`

The canonical source and runtime PNGs were copied only after the generated candidate was inspected. Readback confirms both repository files equal the SHA-256 above.

## Scoped brief and reference handling

The one scoped asset is a wide, opaque Korean wuxia duel backdrop: aged warm hanji paper, misty ink mountains, charcoal-black pines at the far left and right, a low sun, a small distant pavilion, and a calm open centre for the two combatants and the ten-step board.

It excludes people, weapons, cards, UI panels, labels, readable or pseudo-readable text, numerals, glyphs, logos, borders, and watermarks. The user-supplied combat image informed only high-level warm ink-paper mood, world/UI hierarchy, and low-contrast gameplay-safe composition. No reference pixels, characters, UI, text, or identifiable expression were included in this generated image.

## Runtime and rollback contract

`BattleBackground` consumes the runtime path above while preserving its full-rect, responsive, below-board-and-characters behaviour. `twilight_ink_duel_v1.png` remains tracked as a non-active rollback source in `assets/ASSET_MANIFEST.json`; it was neither deleted nor silently overwritten.

This promotion changes presentation only. It does not change ten-step combat logic, card data, AI/private-plan boundaries, save compatibility, platform targets, or UI-owned text/data.

## Rights and release evidence ceiling

The provenance record states the relevant current official OpenAI policy rather than declaring a universal copyright or shipping clearance. The [OpenAI Terms of Use](https://openai.com/policies/terms-of-use/) effective 2026-01-01 say that, as between the user and OpenAI and to the extent permitted by applicable law, OpenAI assigns its rights in Output to the user; they also place input-rights and lawful-use responsibility on the user and warn that output may not be unique.

Accordingly this asset is recorded as `CONDITIONAL_RELEASE_RIGHTS`, with its generation output id, prompt scope, source hash, and reference handling retained for review. It is not by itself evidence of legal release approval, store approval, third-party clearance beyond the documented prompt inputs, or human/device quality.

## Verification status

| Evidence | Status |
| --- | --- |
| User final lock | `PASS_20260830` |
| Canonical/runtime byte readback | `PASS_20260830` |
| Deterministic static and Godot contract tests | `PASS_20260830` — focused static contract, 13 relevant Godot checks, and full Python discovery (421 tests) |
| Actual Godot combat-screen runtime readback | `PASS_20260830` — Godot 4.7.1 isolated worktree, `새 비무행 → 4권 선택 → 도겸 → 전투`, current screenshot/node/log readback |
| Human usability/player approval | `NOT_RUN` |
| Accessibility-user review | `NOT_RUN` |
| Android actual device | `NOT_RUN` |
| Release/performance/store clearance | `NOT_RUN` |

The completed machine/runtime evidence and exact commands belong in `docs/operations/2026-08-30_INK_MIST_VALLEY_BACKGROUND_PROMOTION_EXECUTION_REPORT.md`.
