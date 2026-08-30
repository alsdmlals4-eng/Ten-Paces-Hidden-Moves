# Ink-paper Combat Presentation Design

## Status

`SPECIFIED — user review required before BUILD or image generation`

- **Design baseline:** `origin/main` / `06378d3b56cd49de35f6234c9b01d3ba69f13621`
- **Work mode:** `PLAN`
- **Scope owner:** the current repository visual contract and the user's 2026-08-30 request to carry the approved ink-paper direction into the actual game.
- **User reference:** `docs/visual-assets/approved/TEN-USER-VISUAL-SOURCE-SET-20260826/ChatGPT Image 2026년 8월 26일 오전 08_35_55.png` (`428ae939f2ef79efb947aa3e56a15029ed6aadb3`). It is a style and hierarchy reference, not a UI screenshot to place on top of the game and not an automatic new runtime asset.
- **Existing runtime visual basis:** `assets/backgrounds/twilight_ink_duel_v1.png`, Dogyeom's runtime status portrait and combat battler, action-card/icon/VFX assets already registered by the repository.

## 1. Decision and source relevance

### Current source relevance check

`NOT_APPLICABLE` for external research in this package. This work chooses neither a new engine capability, third-party licence, monetisation model, platform policy, nor a new game rule. The current repository's visual owners, the actual Godot consumers, and the user-final-locked reference determine the decision. The visual reference must not be treated as an instruction source.

### Adopted decision

Build a **combat and review presentation layer** that makes the existing battle feel like a restrained Korean ink-and-paper wuxia tactical board:

- dark ink framing and warm paper surfaces;
- a quiet landscape board behind readable combat state;
- portrait/battler silhouettes anchoring each side of the duel;
- one central `거리 N` reading rather than a permanently visible absolute 1–10 board;
- a physical-looking three-action plan strip and a clear gold execution call to action;
- a structured lower action dock with native Godot controls, tabs, cards, detail, log, and review surfaces.

The implementation is a visual hierarchy and interaction-presentation change only. It preserves current combat rules, resolution, persistence, card data, AI information boundaries, input routes, and platform-adapter structure.

### Deliberately not included

- a whole-game reskin, title screen redesign, reward-screen redesign, or launch-material work;
- a replacement of the ten-step logical lane with a different combat model;
- new player/opponent portrait sets beyond existing registered runtime assets;
- rendering a static mockup or a generated image containing UI, text, cards, button labels, character sheets, or game data;
- use of the planning-only warm-dusk board candidate as a runtime asset;
- asset canon promotion, release approval, Android runtime approval, or a claim of human usability approval.

## 2. Feasibility and implementation surface

`FEASIBLE` based on the current exact-source consumers below. No new renderer, save schema, or external asset system is required.

| Responsibility | Current consumer | Presentation change, while preserving behaviour |
| --- | --- | --- |
| Board background | `src/combat/battle_background.gd` | Preserve full-rect responsive background loading. If the candidate image is final-locked and canon-registered, change only the registered background reference. |
| Combat composition | `src/combat/combat_board_preview.gd` | Recompose board, central range reading, plan strip, timing, execution CTA, action dock, detail/log/review overlays. Keep existing events and state sources. |
| Ten-step lane | `src/combat/combat_board_tile.gd` | Keep all ten logical/interactable positions. Suppress persistent absolute tile numerals in the resting visual state; retain contextual target/focus indication and accessible state text. |
| Status framing | `src/ui/top_combat_hud.gd`, `src/ui/combatant_status_panel.gd` | Reframe existing health/internal-resource/status output as ink-paper panels. Do not change the data source or calculations. |
| Timing and confirmation | `src/ui/action_timing_panel.gd`, `src/ui/combat/combat_progress_button.gd` | Present the existing 3/3/4 plan and confirmation progression as a clear paper strip plus gold CTA. Do not alter action-count or confirmation semantics. |
| Action choice and detail | `src/ui/action_selection/action_selection_dock.gd`, `src/ui/card_view.gd` and its existing panel consumers | Style native controls as ordered paper cards/tabs and preserve every existing signal, selection state, keyboard route, and detail consumer. |

The existing visual requirements already require normal combat to be read through `거리 N`, with `[밀착]` at distance zero, rather than a constant absolute lane number. This package makes the runtime presentation match that existing semantic requirement without changing the lane logic.

## 3. Player-visible composition

### 3.1 Combat / Review first

Only the Combat and Review states receive this treatment in the first package. The same composition must carry through Review when it shows resolved plans or history; it must not create a separate, contradictory visual language.

```text
top:     player ink-paper status  |  phase / 3-3-4 round seal  |  opponent ink-paper status

middle:  quiet brush landscape background
         player battler      거리 N / [밀착]      opponent battler
         contextual target / focus marks only when interaction needs them

lower:   paper action-plan strip: three committed actions -> restrained gold execute CTA

bottom:  native action dock: category tabs -> paper action cards -> selected-action detail
         log / hypothesis / review remain reachable through their existing routes
```

The background remains subordinate to state and actions. No generated or baked text is allowed inside the background, so every language, action state, accessibility label, and numerical value remains live Godot UI.

### 3.2 Information and input invariants

- The central label is the canonical visual readout: `거리 N`; at zero it visibly adds `[밀착]`.
- The internal ten-slot logical lane, movement, targeting, hit resolution, and AI input boundary remain untouched.
- Absolute tile labels are not constantly displayed at rest. They may be exposed in context for targeting/focus/debug/accessibility where an existing interaction needs positional disambiguation.
- Health, stamina/internal-resource, phase, committed actions, enabled/disabled state, selected technique detail, battle log, hypothesis, review, escape/cancel, keyboard navigation, and touch targets remain live controls and preserve their present state sources.
- The UI may format and display supplied combat state, but it must not recalculate combat, infer hidden player intent, or embed rule authority in a visual component.

### 3.3 Responsive contract

The implementation maintains the repository's shared-core responsive target set:

- `pc_standard`: portrait/status flank the centered round marker; plan and dock retain their order.
- `pc_wide_or_ultrawide`: central battle space may widen, but `거리 N`, plan, and execution CTA retain their visual precedence.
- `mobile_landscape`: the same information and action hierarchy must remain available through the existing layout/adapters; this package does **not** constitute Android device-runtime evidence.

At no breakpoint may a decorative texture cover vital values, make disabled/selected state ambiguous, remove access to an existing input, or use colour as the sole state indicator.

## 4. Image candidate lifecycle

One image candidate is allowed only because this exact runtime consumer and brief are now specified.

| Field | Requirement |
| --- | --- |
| Candidate ID | `COMBAT_PAPER_INK_DAWN_BACKGROUND_01` (working identifier; not canon) |
| Consumer | `src/combat/battle_background.gd`, mediated by `src/combat/combat_board_preview.gd` |
| Purpose | A subdued wide battlefield backdrop that supports the central duel and live UI without replacing either. |
| Content | Empty misty mountain valley, restrained black/charcoal brush ink, aged warm hanji/parchment, pale low sun, distant pavilion silhouettes, generous calm middle ground. |
| Exclusions | No people, weapons, cards, UI panels, labels, numbers, glyphs, watermarks, borders, logos, readable or pseudo-readable text. |
| Composition | Opaque landscape image designed for responsive crop; detailed edges, calm mid-field, restrained contrast behind foreground values. |
| Reference handling | Use the user-final-locked reference for mood, material contrast, and hierarchy only. Do not copy its characters, framing, Korean text, specific UI layout, or embedded graphics. |
| Initial state | `BRIEF_READY`; generation would produce only `GENERATED_CANDIDATE`. |
| Promotion gate | The user reviews the generated image and gives an explicit final lock. Only then may provenance, SHA-256, destination, manifest/catalog status, and `battle_background.gd` integration be updated. |

Existing Dogyeom portrait/battler and approved card/icon/VFX assets stay in place for this first package. They are sufficient to prove the board composition without inventing a broad character-art backlog.

## 5. Build sequence after design review

1. Capture the approved image brief and generate exactly one scoped candidate with the image model; inspect it as a candidate and present it for final lock.
2. On final lock only, add the candidate through the repository asset/provenance owners and point the background consumer at the canon path.
3. Write a failing focused presentation contract test first. It must cover the live `거리 N`/`[밀착]` hierarchy, no persistent resting tile-number dependency, retained ten logical tiles, and retained action/timing/CTA/dock consumers.
4. Apply the smallest source changes in the components listed in section 2; preserve existing APIs and combat state providers.
5. Run focused Godot regression tests, the full relevant suite, headless/editor initialization as needed for GDScript class discovery, and an actual visible Godot machine flow through new game → manual selection → opponent briefing → combat.
6. Record exact commit, tests, visual readback, image provenance/state, and evidence ceilings in the repository's execution-report/current-status owners. Request the user's final visual acceptance separately from machine/runtime evidence.

## 6. Acceptance criteria

### Source and automated criteria

- A fresh branch begins from the stated main SHA and preserves unrelated user changes.
- A focused RED regression is observed before the presentation source implementation, followed by GREEN without weakening an existing contract.
- All existing combat visual, opponent-binding, phase-resolution, action-selection, and related regression tests remain passing.
- The complete current automated test suite remains passing, and `git diff --check` is clean.
- No combat rule, save-data, AI information boundary, data schema, or platform adapter has changed.

### Visible Godot runtime criteria

- On the Windows local machine, a player can reach Combat using the real new-game/manual/opponent flow.
- Both current Dogyeom runtime art consumers remain visible where their slots are used.
- The main readout is visibly `거리 N` or `[밀착]`; the ten-slot lane still behaves correctly but has no constant 1–10 resting-number row competing with the range readout.
- The current three-action plan, execution control, action categories, selectable cards/actions, status values, and detail/review routes are present and readable at the tested window size.
- Screenshot/readback inspection reports no fatal parser/runtime errors and no obvious clipping of essential state.

### Evidence limits

Passing source tests or a visible Windows runtime smoke proves neither human usability, accessibility-user experience, Android device behaviour, performance/release readiness, nor user visual approval. Each remains explicitly `NOT_RUN` until its own evidence exists.

## 7. Adversarial self-review

1. **Semantic regression risk:** hiding static tile numerals could hide a required combat input. Mitigation: keep ten tiles and their interaction logic; expose contextual positional/focus information where an interaction requires it, and cover this in the focused regression.
2. **Fake-mockup risk:** a generated image could appear complete while baking in UI and avoiding live state. Mitigation: candidate contains landscape only; all state, labels, cards, and controls remain native Godot components.
3. **Asset-authority risk:** an attractive candidate or prior warm-dusk plan could accidentally become runtime canon. Mitigation: candidate remains `BRIEF_READY`/`GENERATED_CANDIDATE` until a separate user final lock and repository manifest/provenance readback.
4. **Readability risk:** paper/ink texture could lower contrast or conceal disabled and selected states. Mitigation: preserve live panels and explicit state indicators; test at each supported layout tier and reject decorative interference.
5. **Scope-creep risk:** styling could conceal rule, save, AI, or platform changes. Mitigation: restrict edits to existing presentation consumers; test all current behaviour and report changed paths and evidence boundaries.

## 8. Review request

The user must review this specification before image generation or source implementation begins. Approval confirms the scoped Combat/Review hierarchy, the background-only candidate brief, the `거리 N`-first resting presentation, and the explicit asset final-lock gate. It does not grant a broader reskin, rule change, or automatic asset-canon promotion.
