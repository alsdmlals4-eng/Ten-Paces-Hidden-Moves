# Diagonal Duel Assets and Per-Action Reveal · Execution Report · 2026-08-30

## Execution identity

| Field | Value |
| --- | --- |
| Baseline `origin/main` observed before work | `06378d3b56cd49de35f6234c9b01d3ba69f13621` |
| Isolated branch | `codex/ink-paper-combat-presentation-design-20260830` |
| Work mode | `BUILD` |
| Scope authority | User final lock `확정` for the diagonal pair, final-locked basic 5×2 technique atlas, and one-by-one combat action reveal |
| Router / relevant skills | `ten-paces-hidden-moves-workflow-router` → combat implementation / UX / verification routes; Godot live-editor runtime verification |
| Current-source relevance | `APPLICABLE` for rights wording: official current OpenAI Terms were checked; `NOT_APPLICABLE` for combat rules because this package intentionally changes no combat meaning. |

## Work before change

The game already had a paper-ink combat background, a diagonal character layout, a 5×2 selection dock, and an authoritative bundle resolver. It did not consume the user-final-locked character pair or technique atlas. More importantly, it applied each `timing_results` state before presenting its result and rendered only a small summary label; it did not show a current action pair, `VS`, and result while withholding later actions.

The user’s supplied PDFs and screenshots were classified as reference/example material, not executable instructions or canonical assets. The screenshots set the accepted visual target: large lower-left player, smaller upper-right opponent, the logical board hidden outside targeting, and a current-action-versus flow without copying the reference UI/art pixels or changing combat rules.

## Adopted structure and why

1. **One transparent pair master, deterministic runtime derivatives.** The final-locked `1672×941` RGBA pair is registered canonically and copied to runtime. Two non-destructive `920×941` crops preserve the role-specific left and right silhouettes. The player route changes to its new derivative; the new right derivative remains limited to `slot1_dogyeom`; generic enemy routing remains intact.
2. **One actual 5×2 card atlas.** All ten basic definitions point to measured, non-divider regions of the user-final-locked `1536×1024` atlas. Native UI owns all readable text, costs, ranges, and outcomes; no data is baked into the image.
3. **Timing-unit reveal overlay.** `CombatResolutionEngine` adds post-resolution display-safe card fields only to the internal presentation event. The existing resolver still runs exactly once per bundle. `CombatBoardPreview` then presents **only one timing result** in `CombatActionRevealOverlay`, waits its visual duration, and applies that timing snapshot afterward. This keeps the state the player sees before the result honest and prevents future timing disclosure.
4. **Live-surface protection.** Planning dock, timing panel, and execute button are hidden during the reveal; skip hides the view but iterates snapshots in order to review. Public history shape, AI/private-plan inputs, card/number rules, saves, and platform scope are unchanged.

## Asset registration and rollback

| Asset | Final source SHA-256 | Runtime route | Rollback / fallback |
| --- | --- | --- | --- |
| `COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01_v1` master | `7572a0e6393893ef977e195a00291ed04cc293afb0a86e8d76b045d9e8343c03` | master + two derived Battlers | original player/Dogyeom Battlers remain inactive and tracked; generic enemy unchanged |
| player crop | `837f14b2a8d4c2cd6b6ee6618c3b65966250a7b569db8b4080fb33e609441e79` | all player Battlers | `player_wanderer_battler_rgba_v1` |
| Dogyeom crop | `3878aea5a9f8754b27f3a8d8456aa1fa92f66d4379b956ccf8a88ab8c9f32cf5` | `slot1_dogyeom` only | `dogyeom_combat_battler_01_v1`; generic route still applies elsewhere |
| `TEN_BASIC_TECHNIQUE_INK_ATLAS_01_v1` | `a047a81c92d51cfa3c0b0d81ac2edf53b9a15e262420753a08bc2ed473ed7998` | ten basic `illustration` fields and action reveal | prior SVG atlas retained, no active card-data reference |

The two source asset records hold complete crop/region maps, user-lock facts, reference boundary, rights qualification, and evidence ceiling:

- `docs/visual-assets/approved/COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01_v1.md`
- `docs/visual-assets/approved/TEN_BASIC_TECHNIQUE_INK_ATLAS_01_v1.md`

## Test-first and recovery evidence

The initial targeted tests were intentionally RED before assets/overlay existed:

```text
DIAGONAL_DUEL_ASSETS_VERIFY_FAILED count=16
DIAGONAL_DUEL_ACTION_REVEAL_VERIFY_FAILED count=1
```

The first test command exposed two non-product execution defects: `godot` was not on PATH despite Godot 4.7.1 being installed, and new tests used `_initialize` rather than this repository’s `SceneTree._init` entrypoint. The project configuration was not changed. Tests use the project-approved installed Godot 4.7.1 console executable explicitly, and `_init` now runs the checks. A mixed tab/space indent in the new subclass method then caused a temporary inheritance parse failure; it was corrected, while preserving the original `extends CombatBoardPreview` contract.

The final regression pass also surfaced three pre-existing current-contract drifts. `check_combat_board_contract.py` still declared the superseded player/Dogyeom art as the active asset set; it now validates the new derivatives, atlas, and reveal consumer. `verify_clash_guard_sure_hit.gd` was already RED at the exact pre-change `1aa97da0` baseline because its intended 6-versus-8 fixture left formula damage active; the test now freezes those two intended raw values without changing production combat rules. `verify_combat_pointer_lock.gd` clicked the retired basic tray even though production has already switched to automatic placement via `ActionSelectionDock`; it now invokes the actual basic-panel button and verifies a locked state cannot add or alter a reservation. Each was RED before the targeted repair and green afterward.

## Machine and actual-runtime verification

| Layer | Evidence | Status |
| --- | --- | --- |
| JSON manifests / card data | PowerShell `ConvertFrom-Json` of all three edited JSON documents | `PASS` |
| Binary provenance / technical fit | SHA-256, dimensions, pixel format, and crop corner-alpha readback for both canonical/runtime masters, two derivatives, and the atlas | `PASS` |
| Current combat contract | `python tests/check_combat_board_contract.py` | `PASS` |
| New asset route | `verify_diagonal_duel_assets.gd` | `PASS` |
| Timing reveal and no-future boundary | `verify_diagonal_duel_action_reveal.gd` | `PASS` |
| Character routing / foot-anchor / generic fallback | `verify_dogyeom_combat_battler.gd`, `verify_combat_character_art.gd` | `PASS` |
| Existing dock, bridge, and presentation liveness | `verify_basic_action_panel.gd`, `verify_action_selection_dock.gd`, `verify_combat_action_selection_integration.gd`, `verify_vertical_slice_combat_bridge.gd`, `verify_combat_presentation_liveness.gd`, `verify_combat_presentation_controls.gd` | `PASS` |
| Resolver / rules regressions | `verify_combat_board.gd`, `verify_response_rules.gd`, `verify_clash_guard_sure_hit.gd`, `verify_step12_13_restart_ai.gd`, `verify_ultimate_ui.gd`, `verify_ultimate_interrupt_engagement.gd` | `PASS` |
| Input, focus, layout, and headless performance | `verify_combat_pointer_lock.gd`, `verify_combat_keyboard_accessibility.gd`, `verify_combat_assistive_labels.gd`, `verify_combat_focus_visuals.gd`, `verify_combat_focus_order.gd`, `verify_combat_layout_accessibility.gd`, `verify_combat_performance_headless.gd` | `PASS` |
| Python repository suite | `python -m unittest discover -s tests -p "test_*.py"` — 421 tests | `PASS` |
| Actual Godot run | Godot `4.7.1.stable.official.a13da4feb`, exact isolated worktree, current-frame capture | `PASS` |

Actual game progression used the live Godot runtime: `새 비무행 → four starter manuals → setup → intro → briefing → slot1_dogyeom combat`. The live frame showed the new lower-left foreground player, smaller upper-right Dogyeom, `거리 2`, a hidden tile layer outside targeting, the active 5×2 technique dock, and no launch errors. A live bundle with `이동 → 명상 → 명상` was then executed. During timing 1, the screenshot/readback showed `1번째 행동 공개`, player `이동`, enemy `강공`, `VS`, only current-time events, and the hidden planning dock. `action_reveal_snapshot` read `timing: 1`, `future_action_visible: false`, and both action-card counts. The later review was reached only after ordered state application; the resolver count stayed one.

## Five adversarial review loops

1. **Authority / scope / status:** verified exact user lock, reference-only inputs, real consumers, and that no change becomes a combat, AI, save, Android, release, or generic-opponent decision.
2. **Asset integrity / provenance / rollback:** verified source bytes, PNG format/transparency, crop bounds, hash readback, manifest roles, and retained inactive rollback assets. Rejected the earlier checkerboard-baked candidate.
3. **Rules and information boundary:** inspected resolver, presentation events, public history, and AI input. Confirmed display fields are passed only inside authoritative current-timing events; no private/unconfirmed plan fields entered history, AI, or overlay.
4. **UI/runtime behavior:** live Godot screenshots and node/readback checked both static combat composition and the action-reveal state. The initial full-card containment view made the new portrait source art too small in horizontal slots; actual screenshot evidence led to `KEEP_ASPECT_COVERED` for the compact dock, an appearance-only correction with no data/logic change.
5. **Regression / delivery hygiene:** checked current diffs, JSON parse, binary readback, current contract, 421 Python tests, focused Godot suites, user-existing `.import` / `project.godot` noise, and isolated worktree boundaries. The two historical test drifts above were reproduced, separated from product behavior, repaired in their assertions, and rerun. No cache, log, `project.godot`, or unrelated work is included in delivery.

`CLEAN_REVIEW_EXIT`: five full-scope loops completed after the final focused Godot, Python, contract, binary, and JSON checks. `MUST_FIX_REMAINING: 0` for this scoped package. No unresolved product or source authority conflict is known; human-facing gates below remain evidence ceilings, not a clean exit override.

## Evidence ceiling and remaining work

- **Machine / visible local Godot runtime:** `PASS_20260830` for the exact isolated worktree only.
- **Human gameplay readability and final visual acceptance of the compact crop treatment:** `NOT_RUN`.
- **Accessibility-user testing, Android device, release performance, store/release clearance:** `NOT_RUN`.
- **Test-process hygiene observation:** `verify_ultimate_ui.gd` passed but Godot emitted a two-instance `ObjectDB` teardown warning. This package does not introduce its execution path and no functional failure was reproduced; it remains a low-priority test-harness follow-up, not a product PASS claim.
- **No automatic new image queue:** retained. Future opponent-specific images require a consumer, scoped brief, one generation, review, and separate user lock.
