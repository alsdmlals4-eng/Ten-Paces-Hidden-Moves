# Phase 2 Combat Canon Reconciliation — Unified Implementation Contract

```yaml
contract_id: TEN-IMP-20260828-PHASE2-COMBAT-CANON-RECONCILIATION-01
status: IMPLEMENTED_MERGED_PR_261_POSTMERGE_MAIN_READBACK
work_mode: BUILD
approval_source: "user explicit: 승인"
implementation_issue: 258
authored_against:
  main: 2b47ec7521b974a26b89256ac44611b80b61a59c
  planning_branch_head: c94c978babc67e41cf44ff923a68260fd673d8f3
current_task_pr: 256
implementation_agent: Codex via completed CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF
implementation_pr: 261
implementation_merge_commit: 6baf817b5f86baa3fe7df193832bd4f7bc4b2abf
runtime_mutation_in_this_contract: IMPLEMENTED_IN_MERGED_PR_261
runtime_evidence: AUTOMATED_GODOT_MAIN_PASS_20260828
windows_visible_evidence: NOT_RUN
human_player_evidence: NOT_RUN
accessibility_user_evidence: NOT_RUN
android_actual_device_evidence: NOT_RUN
postmerge_status_owner: docs/planning-data/current_user_planning_status.json
historical_specification_boundary: "Sections 1–8 preserve the approved implementation contract; mutable completion and evidence state is owned by the post-merge status documents and execution report."
```

> **Post-merge closeout (2026-08-29):** PR #261 implemented this contract and merged it into project `main` at `6baf817b5f86baa3fe7df193832bd4f7bc4b2abf`. The contract remains the frozen scope/specification record; it is no longer a live handoff. Automated Godot evidence exists, but Windows-visible play, Human Player Experience, accessibility-user, Android-device, and release-performance evidence remain unrun.

## 1. Goal and player-visible promise

This contract reconciles the approved combat canon with the first-five-duel runtime. The player must be able to read a public opening distance of `2`, spend a current `3수 = 3슬롯` plan, make a meaningful one-slot versus two-slot `[전조] → [실행]` trade-off, press **`행동계획 실행`**, then watch the already-committed plan resolve without altering it.

A loss must remain a learning loop rather than an economy loop:

```text
loss → actual Review cause(s) → Failure Result → one same-seed pre-battle retry
     → win: normal result/reward/Route once
     → second loss: no reward/Route, return to Main
```

The target feeling is: “I can identify what my own three slots failed to account for, revise them once, and see the consequence.” It is not “the UI revealed the answer” or “a second currency system softened a loss.”

## 2. Binding authority and conflict resolution

| Subject | Current owner / binding | Implementation disposition |
| --- | --- | --- |
| Public opening distance | `TEN-DEC-20260828-OPENING-DISTANCE-RUNTIME-MAPPING-01` | Adopt `player_tile: 4`, `enemy_tile: 6` on the existing ten-cell logical board. The sole player-facing value is `거리 2`; coordinates are implementation-only. |
| Three-slot plan and two-slot action | `AGENTS.md`, `docs/02_COMBAT_RULES.md`, `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01` | Preserve. A two-slot action occupies two consecutive current-bundle slots and appears as one linked action with `[전조]` then `[실행]`. |
| CTA and transition | `TEN-DEC-20260828-ACTION-PLAN-EXECUTION-CTA-01` | Replace player-facing “잠금” wording with **`행동계획 실행`**. Execution starts only after a valid current-bundle plan; inputs are unavailable while presentation resolves. Internal state names may remain technical. |
| Basic action count and values | `docs/02_COMBAT_RULES.md` + `TEN-DEC-20260804-EXISTING-ACTIONS-REPRICE-01` + `TEN-DEC-20260802-BASIC-PALM-DAMAGE-GROWTH-01` | Reconcile runtime’s legacy eight cards to the current ten. The reprice overlay wins for heavy attack’s `기력1·내력2`; older `내력1` data is superseded. |
| Damage stats | `docs/02_COMBAT_RULES_DERIVED_STATS_AND_RESCUE_AMENDMENT.md` | Add the canonical five-stat state at the slice baseline `외공/근골/신법/내공/심안 = 4`. Do not add legacy `attack_power` to new damage. Its current HUD field is compatibility/history only and must not double-scale damage. |
| Observation | `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01` and its structured contract | One player-only slot gains one stored point. A point reveals one already-locked enemy action **type**, front-to-back, including all types of a compound action. No exact technique/name, target, direction, damage, AI weight, player-plan read, or recommended counter. |
| Defeat/retry | `TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01` | Implement one free same-seed retry from pre-battle state. A first loss never commits reward/Route/history progress; a retry win commits once; a second loss ends the run without reward/Route. |

### Exact basic-card runtime values

`data/cards/basic_cards.json` becomes the runtime source for the following ten current actions. Reuse only existing card atlas regions for the two added cards; this is an explicit temporary presentation reuse, not new asset production.

| Runtime ID | Display | Slots / cost | Range / effect | Runtime rule |
| --- | --- | --- | --- | --- |
| `basic_move` | 이동 | 1 / none | 1 | Existing directional move. |
| `basic_footwork` | 보법 | 1 / 내력1 | 1–2 | Existing directional move choice. |
| `basic_guard` | 막기 | 1 / 기력1 | self | Existing response, with current approved stat handling retained where implemented. |
| `basic_evade` | 회피 | 1 / 기력1 | self | Existing response. |
| `basic_quick_attack` | 속공 | 1 / 기력1 | 1 | `floor(3 + 외공 × 0.50)`. |
| `basic_heavy_attack` | 강공 | 2 / 기력1·내력2 | 1–2 | `[전조] → [실행]`; `floor(7 + 외공 × 1.00)`. |
| `basic_observe` | 관찰 | 1 / none | self | Player-only: gain one observation point; no enemy AI candidate. |
| `basic_meditate` | 명상 | 1 / none | self | Fixed `기력 +1`, `내력 +1`; update legacy preview restoration values to match. |
| `basic_stance` | 준비 | 1 / none | self | Existing next non-move enhancement; do not rename it into an extra action type. |
| `basic_palm` | 장풍 | 2 / 내력1 | 1–3 | `[전조] → [실행]`; `floor(3 + 내공 × 0.75)`; no knockback. |

For attack cards, use structured fields equivalent to `range: {min, max}` and `damage_formula: {base, stat_key, coefficient}`. Displayed Korean formula text is derived from those fields; the engine, AI, preview, logs, and tests must use the structured fields. This avoids parsing `"1~3"` as an integer and avoids hidden duplicate formula ownership.

## 3. In scope

1. Reconcile current combat data/fallbacks, combat state, resolution, public AI input, action planning UI, progress CTA, review/result flow, tests, and canonical docs for the bindings above.
2. Add no new raster image, sprite, audio asset, external reference, store/release work, profile persistence, or currency.
3. Keep existing ten-manual and ultimate consumers working with the revised common stat/damage path; do not alter an approved martial effect identity merely to simplify this task.
4. Give Failure Result a structured functional UI reusing the current Review/Ink UI grammar. It is not a new full-screen art asset or a Human usability pass.

## 4. Explicit exclusions

- Paid `1/2/3` retries, permanent currency, wallet, profile save/load, payment recovery, and a loss Route.
- New visual-direction candidates, generated/runtime art, audio batch, localization expansion, Android layout redesign, or release work.
- Enemy pre-reveal, enemy post-reveal replanning, AI access to uncommitted player plans or UI intent, tactical “correct answer” recommendations.
- Changing `3 + 3 + 4`, deck/hand/draw exclusions, or assigning martial manuals directly to action slots.
- Reward-grade formula invention; existing unresolved grading remains unresolved.

## 5. Required implementation map

| Layer | Required paths / owner | Contracted change |
| --- | --- | --- |
| Canon/data | `data/cards/basic_cards.json`, `data/combat/combat_board_poc.json`, `data/combat/combat_hud_preview.json`, `data/combat/combat_resolution_preview.json` | Ten basic cards, structured ranges/formulas, starting coordinate `4/6`, baseline five stats, 3/3/4 preservation, `행동계획 실행` wording/metadata, and meditation values. Preserve legacy `attack_power` only if an untouched compatibility consumer needs it; prohibit it from new formula calculation. |
| Resolution/state | `src/combat/combat_resolution_engine.gd`, `src/run/vertical_slice_metrics_combat_resolution_engine.gd` | Normalize actor stats, resolve range by structured min/max, calculate basic damage only after legality/range/order/interruption success gates, generate preparation records for all two-slot actions, process observation points/reveals, and keep results as domain data. |
| AI | `src/combat/combat_ai_planner.gd` | Use only public combat snapshot, including public distance `2`; add eligible palm selection at range 1–3 with two slots and internal 1; never choose player-only observation; no player plan/UI access. |
| Planning/UI | `src/ui/action_selection/action_view_model_adapter.gd`, `src/ui/action_selection/basic_action_panel.gd`, `src/ui/action_selection/action_placement_controller.gd`, `src/ui/action_selection/action_selection_dock.gd`, `src/ui/basic_card_tray.gd`, `src/ui/combat_progress_button.gd`, `src/combat/combat_board_preview.gd` | Show exactly ten current actions with true cost/range/formula text, linked `[전조] → [실행]` occupancy, accessible state description, and an execution CTA. UI reads preview/engine state and must not calculate damage/reward/retry rules. |
| Review/retry domain | `src/run/vertical_slice_run_state.gd`, `src/run/vertical_slice_progression_state.gd`, `src/run/vertical_slice_combat_bridge.gd` | Add `SCREEN_FAILURE_RETRY`, attempt identity, validated pre-battle snapshot/restore, exact retry count, loss review payload (one to three actual causes), and success-only commit boundary. `VerticalSliceProgressionState` owns strict snapshot restore; invalid snapshot causes no state mutation. |
| Shell | `src/run/vertical_slice_shell.gd`, `src/run/vertical_slice_shell_result_auto.gd`, `src/run/vertical_slice_shell_route_auto.gd`, `src/run/vertical_slice_shell_completion_auto.gd`, `scenes/run/vertical_slice_shell.tscn` only if node wiring is needed | Recreate the combat bridge on a retry attempt rather than using a developer restart. Hide reward/Route controls on loss. First loss offers retry and voluntary end-run; exhausted retry offers title return only. Preserve keyboard, pointer, gamepad focus and Korean accessibility descriptions. |
| Docs/status | `docs/02_COMBAT_RULES.md`, `docs/07_COMBAT_UI_SPEC.md`, `docs/08_TEST_CHECKLIST.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`, `docs/10_COMBAT_PRESENTATION_PLAN.md`, `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`, `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`, `ACTIVE_CONTEXT.md`, planning JSON, operation report | Change only the affected current statements. Classify old 4/7, distance3, 8-card, `attack_power`, heavy-internal1 and retry-not-applicable statements as historical/superseded rather than deleting evidence. |

## 6. State and event contract

### Combat execution

```text
planning (valid current 3-slot bundle)
→ player selects 행동계획 실행
→ `committed` internal presentation state
→ resolve/presentation animation
→ terminal Review
```

- The internal identifier `committed` may remain to preserve presentation compatibility, but no user-facing string, accessibility description, log heading, or API label calls the action “행동계획 잠금.”
- The current `ActionPlacementController` is the one owner of contiguous placement. It must reject a two-slot placement that crosses the current bundle boundary and expose one linked action, not two card actions.
- `CombatResolutionEngine` owns cost, range, formula, legality, preparation, execution, observation effects, and logs. UI may show its preview/output only.

### Observation payload

```yaml
observation_points:
  owner: combat_state.player
  gain: basic_observe resolves successfully, +1
  spend: explicit player request after enemy bundle is locked
  order: locked enemy actions, front_to_back
  visible_payload: action_type_labels only
  excluded_payload:
    - technique_id_or_name
    - target_tile
    - direction
    - damage
    - ai_weight
    - uncommitted_player_plan
    - recommended_counter
```

The interaction must make the cost and resulting one-type reveal observable in logs/accessibility text. It does not make observation an enemy action or a free inspect button.

### First-five defeat/retry state

```text
BRIEFING → COMBAT
  capture PRE_BATTLE_RUN_STATE once for this duel
COMBAT loss → REVIEW → FAILURE_RETRY(retry_count 0, remaining 1)
  retry → restore snapshot → COMBAT(attempt_id + 1, same seed/opponent)
  end run → MAIN
retry loss → REVIEW → FAILURE_RETRY(retry_count 1, remaining 0)
  only end run → MAIN
COMBAT win → REVIEW → RESULT → existing reward/Route flow
```

`PRE_BATTLE_RUN_STATE` includes only the state necessary to reproduce the same duel: run seed, duel index, current/next opponent IDs, player progression snapshot/resources, route state/history as of pre-battle, pending result state, and attempt identity. It does **not** become profile persistence.

Commit invariants:

- First loss stores an ephemeral failure receipt for display but does not change `completed_duels`, `_duel_history`, `_reward_history`, Route state, pending reward, or persistent progression.
- Retry restoration clears the failed combat view and terminal result; retains same duel/opponent/seed; restores pre-battle resources and progression exactly.
- A retry win produces exactly one duel-history row, one result reward application, and normal Route progression.
- A second loss shows actual causes and exhausted `0/1` status, but no retry/reward/Route CTA; ending clears transient run state and returns to Main.
- `review_causes` is an ordered array of one to three actual resolution events. If the current builder can substantiate only one event, it returns exactly one—not invented filler—and records this restriction in the result payload.

## 7. Test-first acceptance contract

Codex must add or amend tests before behavior changes and observe each focused regression fail for the missing behavior.

1. **Basic-action data and view model**: assert the exact ten IDs, heavy `internal_cost: 2`, palm slots/range/formula/no-knockback, observation player-only/one point, meditation +1/+1, four-column panel’s ten-card rendering, and existing atlas-only presentation reuse.
2. **Resolution**: assert `4/6 → 거리2`, `0 → 밀착`, range 1–2/1–3 boundaries, stat4 expected damage (`속공5`, `강공11`, `장풍6`), no double scaling from `attack_power`, preparation then execution for heavy/palm, interruption/range failure before stat damage, and resource insufficiency.
3. **AI fairness**: assert public snapshot excludes plan/UI fields; at range 1–3 with two slots/internal1 palm may be selected; observation is never selected; same seed and public state reproduce the candidate/trace.
4. **Observation**: assert one successful observe adds one point; only a locked enemy bundle can consume it; outputs action types in front-to-back order; compound types are preserved; prohibited hidden values are absent; enemy plan does not change after reveal.
5. **CTA/UX**: assert player-facing CTA/accessibility text says `행동계획 실행`; no player-facing `잠금` wording; action input becomes unavailable from execution start through presentation/review; current plan cannot mutate after execution begins.
6. **Retry state**: add `tests/verify_vertical_slice_failure_retry.gd` and update the Vertical Slice workflow. Assert first loss→Review→Failure Result, same seed/opponent/pre-battle resources, exactly one retry, no loss reward/Route/history/duel completion, retry win commits once, second loss has no retry/reward/Route, and end-run returns Main with no stale combat node/signal/log accumulation.
7. **Regression**: preserve current action-selection, card component, combat board, ten-manual, review/result, route/completion and planning-discovery checks. Update historical values only where they claim active runtime truth.
8. **Runtime/UX evidence**: execute Godot parse/headless first; then Windows visible mouse/keyboard/gamepad walkthrough, reduced motion and long Korean text; Android actual device and human/accessibility/playtest remain separately reported. No unrun layer becomes PASS.

## 8. Manual validation scripts

### Windows visible critical path

1. Start a new run, choose four manuals, reach Duel 1, and verify opening label `거리 2` with positions equivalent to 4/6.
2. In a three-slot bundle, place one `장풍` or `강공`; confirm it occupies two adjacent slots as `[전조] → [실행]`; reject a cross-boundary placement.
3. Place a valid plan, activate **행동계획 실행**, and confirm inputs disable while the resolution animation/log advances.
4. Use `관찰`; confirm it costs one slot and reveals only the first eligible locked enemy action type, never exact technique/target/direction/damage or a counter hint.
5. Lose once, inspect actual causes and `0/1`, retry, and verify same opponent/seed/pre-battle resource condition. Win and verify one reward/Route only.
6. Lose twice in a fresh duel and verify there is no reward/Route/retry control; use title return; start a new run and verify no stale review/combat state.

### Evidence ceiling after implementation

```yaml
automated_static_and_godot: REQUIRED
windows_visible: REQUIRED_FOR_CLAIM
human_player_experience: REQUIRED_FOR_FUN_CLAIM
accessibility_user: NOT_RUN_UNTIL_EXECUTED
android_actual_device: NOT_RUN_UNTIL_EXECUTED
release_performance: NOT_RUN_UNTIL_EXECUTED
```

## 9. Git/Notion delivery boundary

1. GitHub Issue `#258` was the implementation owner. Its scoped handoff produced PR `#261`; the Issue is closed after this post-merge readback.
2. Codex performed the isolated implementation and the post-merge execution report records actual divergences and the automated evidence.
3. Existing PRs #199/#200 remain read-only. No direct main push, force push, reset/clean/rebase, or ruleset bypass was used.
4. The current workspace is repository-only under `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`; Notion is migration/history input and has no current delivery/readback obligation. Mutable completion/evidence lives in the repository owners named above.
5. Implementation-time material divergences are retained as Project Incident / Solution / Lesson in the execution report. Its Base disposition remains `NO_BASE_PROMOTION`.

## 10. Approval and handoff boundary

The user explicitly approved this exact contract. GitHub Issue `#258` was the implementation owner, and its isolated `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF` completed in merged PR `#261`. Automated Godot/runtime evidence is recorded; this does not claim Windows-visible usability, Human Player Experience, accessibility-user, Android-device, or release evidence. A future product mutation must receive a new scoped contract and fresh-read current GitHub/repository owners and actual runtime; Notion is historical migration input only.
