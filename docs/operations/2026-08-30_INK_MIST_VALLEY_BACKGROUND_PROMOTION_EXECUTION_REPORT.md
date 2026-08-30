# INK_MIST_VALLEY_DUEL_01 · Canon Promotion and Runtime Integration · 2026-08-30

## Execution identity

| Field | Value |
| --- | --- |
| Baseline `origin/main` | `06378d3b56cd49de35f6234c9b01d3ba69f13621` |
| Isolated branch | `codex/ink-paper-combat-presentation-design-20260830` |
| Prior presentation commit | `62ab761a076b92db26c7be5d769672daf14ebfd6` |
| Work mode | `BUILD` |
| Router / skill | `ten-paces-hidden-moves-workflow-router` → `ten-paces-verification` |
| Current-source relevance | `APPLICABLE`: the current OpenAI Terms of Use were checked because provenance/right-to-use language is a release-sensitive, time-varying fact. |
| Scope | One already-generated landscape background, its provenance registration, the actual `BattleBackground` consumer, focused regression coverage, and machine/runtime evidence. |

## Work before the promotion

The approved visual presentation package had already changed the live Godot combat composition while deliberately leaving the new landscape at `GENERATED_CANDIDATE`. The candidate was never treated as canon simply because it rendered successfully. The prior report, `2026-08-30_INK_PAPER_COMBAT_PRESENTATION_EXECUTION_REPORT.md`, preserves that pre-lock state.

The user then supplied the required explicit final lock: `확정하자` (2026-08-30). This is the authorization boundary for the bounded promotion below, not approval for unrelated images, a broader reskin, combat-rule changes, release, or a new art queue.

## Candidate provenance and canonicalization

- Generator: OpenAI built-in image generation
- Output id: `exec-ab1363be-f939-480e-9cd5-1e506e167e89`
- Reviewed candidate SHA-256: `3203af421a7ecafd14cd8bb0be0db08dc282f4e9463a372ef593185f3f6cc538`
- Dimensions: `1672 × 941`
- Canonical source destination: `docs/visual-assets/approved/INK_MIST_VALLEY_DUEL_01_v1.png`
- Runtime destination: `assets/backgrounds/ink_mist_valley_duel_01_v1.png`
- Readback: both destination bytes match the reviewed candidate SHA-256.
- Consumer: `src/combat/battle_background.gd`.
- Replacement policy: `twilight_ink_duel_v1.png` remains tracked with `active: false` and `superseded_by: ink_mist_valley_duel_01_v1` for rollback.

The generator brief was limited to an empty landscape. No person, weapon, text, UI, logo, watermark, reference pixels, or user-supplied character identity was included. The official [OpenAI Terms of Use](https://openai.com/policies/terms-of-use/) (effective 2026-01-01) are recorded as conditional provenance evidence: they assign Output rights as between the user and OpenAI to the extent permitted by law, while making the user responsible for input rights/lawful use and noting that Output may not be unique. Therefore this record is not a legal-release PASS.

## Test-first change

Before changing the consumer, the focused Godot board test was updated to expect the final-locked asset and snapshot. It failed as intended because the file/path was not yet in the runtime contract:

```text
STEP 3 battle background asset was not found
Combat board snapshot must expose the approved ink-mist background asset
```

Only after that RED result were the canonical/runtime copies registered, `BattleBackground` switched to the new runtime path, the board snapshot path aligned, and the static contract extended to verify the source/runtime byte identity and inactive rollback asset.

## Adversarial review loops

1. **Authority and scope:** checked the new PNG is an explicit final-locked, one-consumer asset and the warm-dusk planning anchor remains planning-only. No planning image was promoted.
2. **Asset integrity and rollback:** checked canonical and runtime files share the reviewed SHA-256; manifest has exactly one active combat background and preserves the former file as inactive rollback.
3. **Runtime consumer and UI separation:** checked only `BattleBackground`/combat preview path metadata changed. Live Godot controls, Korean labels, card data, distance logic, AI boundaries, and save schema remain code/data-owned.
4. **Readability and interaction:** actual `new run → manual selection → Dogyeom → combat` readback shows the warm hanji/misty valley behind the two combatants and ten logical tiles, while `거리 2`, 3/3/4 timing, cards, and controls remain native legible Godot UI. This does not substitute human accessibility or usability evidence.
5. **Repository/delivery hygiene:** checked the isolated diff, documents, current handoff status, focused tests, ignored/generated Godot import-cache noise, and exact baseline. No cache/import mutation is staged; no direct-main or unrelated PR action occurs.

`CLEAN_REVIEW_EXIT`: all five loops completed; `MUST_FIX_REMAINING: 0`. The initial stale test-command filename was diagnosed as an execution-list mismatch before it could be treated as a product defect; the current repository test names were used and the plan was corrected.

## Verification evidence

| Layer | Command / observation | Status |
| --- | --- | --- |
| Project operating contract | `python tools/check_project_operating_system.py` | `PASS` before mutation |
| Focused static contract | `python tests/check_combat_board_contract.py` | `PASS` |
| Godot board contract | `verify_combat_board.gd` | `PASS` |
| Ink-paper presentation contract | `verify_ink_paper_combat_presentation.gd` | `PASS` |
| Relevant Godot regressions | 13 checks: board/layout/keyboard/focus/character/assistive-label/action-dock/basic/martial/ultimate/detail/integration/presentation | `PASS` |
| Full Python test discovery | `python -m unittest discover -s tests -p "test_*.py"` | `PASS` — 421 tests |
| Actual Godot machine runtime | exact isolated-worktree `new run → four manuals → Dogyeom → combat`; 1280×800 current-frame screenshot, `BattleBackground` node texture/readback, and game log | `PASS` — no game errors; 12 pre-existing editor warnings only |
| Windows human usability / player approval | separate human observation | `NOT_RUN` |
| Accessibility-user / Android device / release performance | separate environments and evidence | `NOT_RUN` |

`verify_combat_focus_visuals.gd` is intentionally not counted in this asset-promotion PASS set: it is a pre-existing baseline failure that was reproduced against detached `origin/main` before this promotion and is unrelated to the untouched final-background consumer. Its broader keyboard-focus correction remains a separately scoped accessibility task.

## Current conclusion

At this report revision the asset is `USER_FINAL_LOCKED · CANON_REGISTERED · IMPLEMENTED · MACHINE_RUNTIME_VERIFIED`. The runtime `BattleBackground` node reported `res://assets/backgrounds/ink_mist_valley_duel_01_v1.png`, `1672×941`, `user_final_locked_ai_generated_project_raster_png`, and `below_board_and_characters`; its current screenshot was not stale. The remaining evidence ceiling is human usability/player approval, accessibility-user review, Android actual device, and release/performance/store clearance — all `NOT_RUN`.
