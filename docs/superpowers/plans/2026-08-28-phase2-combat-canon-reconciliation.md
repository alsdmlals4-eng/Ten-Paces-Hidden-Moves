# Phase 2 Combat Canon Reconciliation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans task-by-task only after the user approves `TEN-IMP-20260828-PHASE2-COMBAT-CANON-RECONCILIATION-01` and a `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF` has been issued. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the first-five-duel runtime match the approved public start distance, ten basic actions, action-plan execution journey, observation fairness, and one free same-seed defeat retry—without opening economy, persistence, or asset-production scope.

**Architecture:** Structured data owns action/range/formula/coordinate values. The combat engine owns all legality, damage, observation, and resolution state; the AI reads only public state; action UI expresses engine preview and execution state. `VerticalSliceRunState` owns retry snapshots and the exactly-once result/Route boundary. The shell renders those state outputs without recalculating them.

**Tech Stack:** Godot 4 GDScript, JSON data, Godot regression scripts, Python unittest/static contracts, GitHub Actions.

**Spec:** `docs/implementation/2026-08-28_PHASE2_COMBAT_CANON_RECONCILIATION_IMPLEMENTATION_CONTRACT.md`, `TEN-DEC-20260828-OPENING-DISTANCE-RUNTIME-MAPPING-01`, `TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01`, `docs/02_COMBAT_RULES.md`, `docs/planning-data/approved_20260804_existing_action_reprice_contract.json`, `docs/planning-data/approved_20260805_observation_answer_leak_guardrails_contract.json`.

## Global Constraints

- `3수 = 3슬롯`; a two-slot action consumes both slots as one `[전조] → [실행]` action.
- The player-facing CTA is `행동계획 실행`; this commits into combat resolution/presentation and is not called a plan lock.
- Use `player_tile 4`, `enemy_tile 6` for public start `거리 2`.
- No paid retries, permanent currency, save/profile, new assets, or generated images.
- AI cannot read uncommitted player plans/UI intent and cannot use `관찰`.
- Existing open/draft PRs remain read-only. Implement only in the post-approval Codex task branch.

### Task 1: Establish failing contract tests and reconcile data

**Files:**
- Modify: `data/cards/basic_cards.json`, `data/combat/combat_board_poc.json`, `data/combat/combat_hud_preview.json`, `data/combat/combat_resolution_preview.json`, `data/combat/combat_progress_preview.json`
- Modify: `tests/check_action_selection_contract.py`, `tests/check_card_component_contract.py`, `tests/check_combat_board_contract.py`, `tests/check_canonical_combat_docs.py`
- Modify/Create: focused basic-card, damage-formula, and CTA contract regressions

- [ ] Write focused assertions requiring ten cards, `4/6`, structured range/formula fields, five-stat baseline, heavy internal2, palm/observe semantics, +1/+1 meditation, and `행동계획 실행` text.
- [ ] Run those checks and record RED against the legacy eight-card/4-7/attack_power state.
- [ ] Add the exact data fields and retain only compatibility-safe legacy fields; use current atlas regions for observe/palm instead of new art.
- [ ] Run JSON parsing, focused checks, and `git diff --check`; commit this cohesive data/test unit.

### Task 2: Make common resolution and public AI honor the canon

**Files:**
- Modify: `src/combat/combat_resolution_engine.gd`, `src/run/vertical_slice_metrics_combat_resolution_engine.gd`, `src/combat/combat_ai_planner.gd`
- Modify: `tests/verify_combat_resolution_engine.gd`, `tests/verify_combat_ai_planner.gd`, relevant integration tests

- [ ] Add failing tests for stat4 quick/heavy/palm damage, range boundaries, no attack_power double scale, two-slot preparation/execution, and public-only AI input.
- [ ] Add normalized five stats, structured min/max range, and generic formula evaluation after legality/range/order/interruption gates.
- [ ] Add palm candidate conditions; exclude observe from enemy candidates; preserve deterministic seed trace and existing martial/ultimate behavior.
- [ ] Run focused Godot tests and existing martial/action regressions; commit the engine/AI unit.

### Task 3: Implement observation as a paid, fair information action

**Files:**
- Modify: `src/combat/combat_resolution_engine.gd`, relevant action/intent runtime owner and `src/ui/opponent_hypothesis_panel.gd` only if it is the actual reveal consumer
- Modify/Create: observation GDScript tests and contract checks

- [ ] Start with failing tests for one point per observe, locked-bundle-only spending, front-to-back action-type reveal, compound display, and prohibited payload absence.
- [ ] Add explicit state/event payloads; do not place AI plan generation or reveal logic in UI.
- [ ] Render accessible reveal history/status from the engine payload and preserve the existing no-hidden-plan boundary.
- [ ] Run the existing observation guardrail validator plus focused runtime tests; commit this unit.

### Task 4: Reconcile plan UI and execution transition

**Files:**
- Modify: `src/ui/action_selection/action_view_model_adapter.gd`, `src/ui/action_selection/basic_action_panel.gd`, `src/ui/action_selection/action_placement_controller.gd`, `src/ui/action_selection/action_selection_dock.gd`, `src/ui/basic_card_tray.gd`, `src/ui/combat_progress_button.gd`, `src/combat/combat_board_preview.gd`
- Modify: action selection and accessibility tests

- [ ] Write failures for linked two-slot visual/accessibility semantics, ten basic actions, no stale player-facing lock wording, and disabled inputs through resolution/review.
- [ ] Render the data-owned fields; keep placement ownership in the controller and combat calculations in the engine.
- [ ] Change progress labels, captions, metadata, and accessibility descriptions to `행동계획 실행` meaning while retaining compatible internal technical states.
- [ ] Run action selection, card component, combat board, accessibility metadata and reduced-motion regressions; commit this unit.

### Task 5: Build first-five defeat/retry domain state before shell UI

**Files:**
- Modify: `src/run/vertical_slice_run_state.gd`, `src/run/vertical_slice_progression_state.gd`, `src/run/vertical_slice_combat_bridge.gd`
- Create: `tests/verify_vertical_slice_failure_retry.gd`
- Modify: existing Vertical Slice state/review/result tests and workflow

- [ ] Add failing tests for first-loss no-commit, snapshot restore, same seed/opponent, one retry, retry-win exactly-once commit, and second-loss terminal behavior.
- [ ] Add strict no-partial-mutation progression snapshot restoration and `SCREEN_FAILURE_RETRY` state transitions.
- [ ] Emit one-to-three actual review causes; if fewer are substantiated, return fewer rather than synthetic advice.
- [ ] Run the new failure test with all existing run-state/review/result/route/completion tests and update the workflow; commit this unit.

### Task 6: Render the failure result and retry attempt safely

**Files:**
- Modify: `src/run/vertical_slice_shell.gd`, `src/run/vertical_slice_shell_result_auto.gd`, `src/run/vertical_slice_shell_route_auto.gd`, `src/run/vertical_slice_shell_completion_auto.gd`
- Modify: `scenes/run/vertical_slice_shell.tscn` only if necessary for node wiring
- Modify: shell/UI runtime tests

- [ ] Start with failure tests for first loss controls, exhausted controls, no loss reward/Route options, and new combat-bridge attempt identity.
- [ ] Render actual causes, restoration scope, `0/1`, retry/end-run actions; instantiate a fresh combat bridge for retry rather than calling a developer restart.
- [ ] Ensure no stale combat node, signal, logs, result reward buttons, or route controls survive title return.
- [ ] Run all Vertical Slice Godot tests plus keyboard/pointer/gamepad focus checks; commit this unit.

### Task 7: Reconcile documentation and exact-head verification

**Files:**
- Modify only affected entries in `docs/02_COMBAT_RULES.md`, `docs/07_COMBAT_UI_SPEC.md`, `docs/08_TEST_CHECKLIST.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`, `docs/10_COMBAT_PRESENTATION_PLAN.md`, `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`, `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`, `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`, structured planning state, and operation report.

- [ ] Classify old active-looking values (`4/7`, distance3, eight basic cards, attack_power formula, heavy internal1, retry not applicable) as superseded/legacy exactly where still active-looking.
- [ ] Run canonical/reference freshness, all focused Python checks, all affected Godot tests, JSON/GDScript syntax, and baseline diff review.
- [ ] Run Godot parse/headless; record Windows visible, Human, accessibility user, Android device, and release performance independently.
- [ ] Create/update the one task PR, obtain review, read exact HEAD checks, then merge only when all required remote checks are green. Post-merge read main and then update/read back Notion Home and UI Flow Map.

## Self-review

- The plan maps every approved rule to data → state → engine/AI → UI → test → evidence.
- It preserves the user’s two-slot and execution wording corrections without using them as a reason to invent economy, art, or save features.
- A first loss cannot masquerade as completed content; generated assets and Human/player validation remain explicitly outside automated evidence.
