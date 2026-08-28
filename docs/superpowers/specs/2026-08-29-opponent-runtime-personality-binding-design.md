# First-Five Opponent Runtime Personality Binding Design

```yaml
status: DRAFT_FOR_USER_REVIEW
issue: 267
decision: TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01
baseline_main: c1fb43d92956e2bf7d104f59039728713a8e74af
work_mode: PLAN
skill_modes:
  - ten-paces-game-design / poc-contract
  - combat-implementation-handoff / implementation-contract
  - ten-paces-verification / contract-check
user_direction: "좋아 권장안대로 진행하자"
human_playtest: NOT_RUN_DEFERRED_BY_USER_FOR_CURRENT_STAGE
runtime_mutation_in_this_spec: NONE
```

## 1. Goal

Bind the already-authored first-five-duel candidate data to the actual combat runtime so a locked candidate controls three things before combat begins:

1. a reusable AI archetype that scores only public state;
2. its ordered `basic_action_focus_ids`; and
3. a deterministic allocation of `final_stat_total_seed` across the existing five stats.

The implementation must preserve the shared resolver and the player-facing rhythm:

```text
3 slots → resolve → 3 slots → resolve → 4 slots → resolve
```

A two-slot action remains one connected `[전조] → [실행]` action occupying two real slots. After **`행동계획 실행`**, neither side's locked current bundle is replanned.

## 2. Why this is needed

`data/run/vertical_slice_opponents.json` already gives 15 candidates a signature manual, mastery seed, basic-action focus, behavior focus, and final-stat total. The current shell sends only the manual, mastery, ID, and presentation identity to `VerticalSliceCombatBridge`; the bridge then initializes the same default enemy HUD stats and global rival tendency for every candidate.

This makes the player-visible briefing partly untrue in play. The candidate's martial card is real, but its stated habit and strength profile are not yet a runtime input. The desired experience is:

```text
public rumor / Route clue
→ player makes a falsifiable 3/3/4 plan hypothesis
→ locked opponent expresses a broad, non-deterministic tendency
→ public combat result demonstrates or breaks the hypothesis
→ Review explains actual events, never a hidden AI weight or next correct answer
```

## 3. Non-negotiable constraints

- AI input may contain its own candidate binding, the existing legal enemy cards, deterministic seed, and already resolved public combat state only.
- AI input may not contain player placements for the uncommitted current bundle, target/direction choices, hover/pointer/focus state, UI intent, observation answer data, or a recommended counter.
- The engine owns legality, action slots, cost, target, range, damage, clash, defense, interruption, stat allocation application, and public-history append. UI only displays engine output.
- Candidate behavior is data-driven. There are no per-candidate resolver subclasses, scripted turn exceptions, enemy-only manuals, enemy-only techniques, or separate AI rules.
- The first-five result/retry/Route ownership, public opening distance `2`, shared player/AI martial-card pool, and current basic-card definitions remain intact.
- This scope does not add art, audio, economy, save/profile persistence, new route nodes, Android layout work, market/release work, or a Human Player Experience PASS claim.

## 4. Data ownership

| Owner | Responsibility | Change |
| --- | --- | --- |
| `data/run/vertical_slice_opponents.json` | Candidate identity, current briefing copy, manual/mastery, focus order, total-stat seed, selected runtime archetype ID. | Add exactly `runtime_archetype_id` to every candidate; retain current descriptive fields. |
| `data/run/vertical_slice_opponent_archetypes.json` | Five reusable behavioral and stat-allocation definitions. | New runtime data owner. |
| `src/run/vertical_slice_opponent_runtime_binding.gd` | Parse/validate archetype data and turn one candidate into a safe runtime binding. | New domain adapter; no UI ownership. |
| `src/run/vertical_slice_combat_bridge.gd` | Receive the binding and attach it to the per-combat engine/state. | Extend loadout configuration. |
| `src/run/vertical_slice_metrics_combat_resolution_engine.gd` | Preserve the binding across initial-state construction/retry and configure the per-engine AI. | Add bounded binding configuration. |
| `src/combat/combat_ai_planner.gd` | Score and schedule legal enemy actions using an optional per-instance binding. | Preserve the default profile for non-Vertical-Slice consumers. |
| `src/combat/combat_resolution_engine.gd` | Append bounded resolved public history after a bundle resolves. | No UI data and no pending plan data. |

`behavior_focus` stays a content/briefing statement. `runtime_archetype_id`, focus IDs, and profile fields are the executable contract. Internal IDs and weights are never shown in Briefing, HUD, Review, log text, or accessibility copy.

## 5. Reusable archetypes

Every profile contains the existing general score keys plus movement, history, sequence, and stat rules. The data file has `schema_version: 1`, `stat_order: [external, constitution, agility, internal_power, insight]`, and exactly these five IDs:

| ID | Publicly readable tendency | `max_actions_per_bundle` | Movement policy | Public-history policy | Stat weights in canonical order |
| --- | --- | ---: | --- | --- | --- |
| `initiative_exchange` | Close distance and test the player with early initiative, but still protects itself when hurt. | 1 | `approach` | `none` | `[5, 4, 5, 3, 3]` |
| `stabilize_then_pressure` | Values defense/resource stability first; converts a stable opening into heavier pressure. | 1 | `approach` | `none` | `[4, 6, 3, 4, 3]` |
| `range_control` | Moves toward a preferred public distance; retreats when too close and approaches when too far. | 1 | `preferred_distance: 3` | `none` | `[3, 3, 6, 5, 3]` |
| `public_history_counter` | Uses only repeated actions already resolved in earlier bundles to lean toward defense/evasion/counter pressure. | 1 | `hold_or_approach` | `last_two_player_resolved_cards` | `[3, 3, 4, 4, 6]` |
| `sequence_pressure` | Reserves up to two non-overlapping legal actions in the current bundle, retaining a conservative legal follow-up when the first plan has a high slot cost. | 2 | `approach` | `own_planned_cards_only` | `[5, 3, 4, 5, 3]` |

The exact score weights in `vertical_slice_opponent_archetypes.json` are:

| ID | approach | quick_pressure | heavy_prepare | response_low_health | recover_low_resource | ultimate_ready |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `initiative_exchange` | 1.0 | 1.5 | 0.4 | 1.0 | 0.6 | 1.0 |
| `stabilize_then_pressure` | 0.4 | 0.5 | 1.2 | 2.0 | 1.8 | 1.2 |
| `range_control` | 0.8 | 0.4 | 1.0 | 1.0 | 1.0 | 1.0 |
| `public_history_counter` | 0.4 | 0.6 | 0.5 | 1.7 | 1.2 | 1.0 |
| `sequence_pressure` | 1.0 | 1.1 | 1.0 | 0.6 | 0.8 | 1.4 |

## 6. Candidate mapping

The following is the complete mapping. `basic_action_focus_ids` remains the candidate-specific variation inside a shared archetype; its first, second, and third legal IDs receive additive score bonuses `+1.20`, `+0.60`, and `+0.30` respectively. A focus ID that is illegal because of slots, cost, range, or player-only restriction receives no candidate at all.

| Candidate | Runtime archetype | Reason |
| --- | --- | --- |
| `slot1_yeongyo` | `initiative_exchange` | Direct opening pressure with defensive counterexample. |
| `slot1_dogyeom` | `stabilize_then_pressure` | Attack then stabilize; pressure only when behind. |
| `slot1_chaeryeong` | `initiative_exchange` | Meets entry and breaks excessive waiting. |
| `slot2_mukjin` | `stabilize_then_pressure` | Defense/resource before heavy telegraph. |
| `slot2_seokmu` | `stabilize_then_pressure` | Endures long telegraph before shorter pressure. |
| `slot2_danso` | `stabilize_then_pressure` | Preserves defense resources, then becomes aggressive. |
| `slot3_seolha` | `range_control` | Maintains a signature distance with a close-range counterexample. |
| `slot3_uram` | `range_control` | Uses spear-tip distance but may trade after entry. |
| `slot3_biyeon` | `range_control` | Leaves attack range, then can reverse-enter against pursuit. |
| `slot4_cheongheo` | `public_history_counter` | Adapts only to resolved player repetition. |
| `slot4_damwol` | `public_history_counter` | Counters as second mover, pressures excessive waiting. |
| `slot4_jinryeo` | `public_history_counter` | Reuses visible bait patterns with a legal immediate-action counterexample. |
| `slot5_jeogu` | `sequence_pressure` | Links pressure and becomes conservative after an expensive first plan. |
| `slot5_pungmok` | `sequence_pressure` | Mixes rhythm pressure with safer singleton behavior. |
| `slot5_rajin` | `sequence_pressure` | Links movement and action, then uses a safe legal follow-up when blocked. |

## 7. Deterministic stat allocation

`final_stat_total_seed` is a total, not a hidden formula. The runtime binding derives `enemy.stats` with this exact algorithm:

1. Read the selected archetype's five integer weights; every table above sums to `20`.
2. For each canonical stat, calculate `floor(total_seed * weight / 20)`.
3. Allocate the remaining points one at a time to the largest fractional remainder.
4. Break equal remainders in canonical order: `external`, `constitution`, `agility`, `internal_power`, `insight`.
5. Reject a binding if any result is below `1`, any weight is non-positive, its weight sum is not `20`, or the final stat sum differs from `final_stat_total_seed`.

At total `20`, the weights are the exact result. At higher slot totals the same profile grows without a candidate-specific numerical script. Health, stamina, internal resource, momentum, manual star, and card effects keep their current owners; this contract changes only the existing `stats` dictionary.

## 8. Public history and action scheduling

### Public history

After a bundle resolves, `CombatResolutionEngine` appends up to six newest records to `combat_state.public_resolution_history`. Each record contains only:

```yaml
round_number:
bundle_index:
actor: player | enemy
card_id:
category:
outcome:
```

The record is added only after resolution. The current player placement dictionary, targets/directions of an uncommitted bundle, UI metadata, hidden AI weights, and observation answer data are excluded. `public_history_counter` receives only the two newest **player** records from this history. It never reads the uncommitted current bundle.

### Movement

`CombatAiPlanner` converts the selected public movement policy to a target tile through one shared method:

- `approach`: move toward the player as the current planner does.
- `preferred_distance: 3`: move away if public distance is below `3`; move toward if it is above `3`; otherwise movement is not score-boosted.
- `hold_or_approach`: favor a legal defensive candidate at preferred distance; otherwise approach.

No profile chooses an out-of-board tile, crosses a movement-step limit, or bypasses the resolver's occupancy rules.

### Bundle scheduling

The planner keeps its existing legal-candidate filter and seeded selection. It adds a generic scheduler:

1. Start at the current bundle's first timing and remaining real slots `3`, `3`, or `4`.
2. Choose one legal action with the selected archetype and focus bonuses.
3. Reserve its exact `action_slots`; a two-slot action reserves adjacent `[전조] → [실행]` slots and its action timing is its execution slot.
4. For profiles with `max_actions_per_bundle: 2`, choose at most one more legal non-duplicate action with the remaining slots. It may not overlap or cross the bundle boundary.
5. Do not simulate player intent or future results while scheduling. Actions can still fail, clash, or be interrupted at resolution; that is the playable uncertainty.

The default non-Vertical-Slice rival retains `max_actions_per_bundle: 1`, its current global profile, and its current approach behavior.

## 9. Runtime interface contract

`VerticalSliceOpponentRuntimeBinding` is the only adapter that converts a candidate to runtime data:

```gdscript
func build(candidate: Dictionary) -> Dictionary
# valid: bool
# candidate_id: String
# archetype_id: String
# ai_profile: Dictionary
# basic_action_focus_ids: Array[String]
# stats: Dictionary
# final_stat_total_seed: int
```

`VerticalSliceCombatBridge.configure_vertical_slice_loadouts(...)` gains one required `enemy_runtime_binding: Dictionary` argument before optional presentation identity. It rejects an invalid binding before mutating `resolution_engine` or `combat_state`.

`VerticalSliceMetricsCombatResolutionEngine` gains:

```gdscript
func configure_enemy_runtime_binding(binding: Dictionary) -> bool
```

It stores a deep copy, configures only its own `ai_planner`, and applies `binding.stats` plus `candidate_id` during every `make_initial_state`. This preserves a same-seed retry without a separate state path.

`CombatAiPlanner` gains:

```gdscript
func set_runtime_binding(archetype_id: String, ai_profile: Dictionary, basic_action_focus_ids: Array[String]) -> bool
func clear_runtime_binding() -> void
```

Its trace adds `runtime_archetype_id`, `basic_action_focus_ids`, and the bounded public-history count. It does not serialize hidden weight values to player-facing consumers.

## 10. Implementation surface

| Layer | Create | Modify |
| --- | --- | --- |
| Runtime data | `data/run/vertical_slice_opponent_archetypes.json` | `data/run/vertical_slice_opponents.json` |
| Binding domain | `src/run/vertical_slice_opponent_runtime_binding.gd` | `src/run/vertical_slice_opponent_catalog.gd` |
| Combat/runtime | none | `src/run/vertical_slice_shell.gd`, `src/run/vertical_slice_combat_bridge.gd`, `src/run/vertical_slice_metrics_combat_resolution_engine.gd`, `src/combat/combat_ai_planner.gd`, `src/combat/combat_resolution_engine.gd`, `src/combat/combat_resolution_engine_ten_manuals.gd` only if its enemy-action override requires the new scheduler interface |
| Automated evidence | `tests/verify_vertical_slice_opponent_runtime_binding.gd`, `tests/check_vertical_slice_opponent_runtime_binding_contract.py` | `tests/verify_vertical_slice_opponent_catalog.gd`, `tests/verify_vertical_slice_setup_briefing.gd`, `tests/verify_ai_rival_tendency.gd`, relevant workflow script lists |
| Canon/status | none until implementation evidence exists | `docs/02_COMBAT_RULES.md`, `docs/08_TEST_CHECKLIST.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`, `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`, `ACTIVE_CONTEXT.md`, `docs/planning-data/current_user_planning_status.json` |

Every new GDScript file starts with a one-line Korean role comment. No Scene, Resource, asset, or project setting change is expected unless the implementer finds a concrete existing consumer that cannot receive the binding through the listed bridge; that discovery must stop the build for contract review.

## 11. Acceptance and failure tests

1. **Data validity:** exactly five archetypes; all required keys; positive weights summing to `20`; all 15 candidates map to one valid archetype; every existing focus ID resolves to a current basic card.
2. **Stats:** every candidate's five stats sum exactly to its seed; allocation is deterministic; invalid total/weights/profile fails before bridge mutation.
3. **Bridge isolation:** a candidate's engine state has its candidate ID and derived stats; the bridge snapshot records the archetype ID for tests; a second combat with another candidate does not retain the first binding.
4. **AI fairness:** same candidate/public state/seed produces identical actions and trace; mutating uncommitted-player-plan/UI-only keys changes neither; `basic_observe` remains absent; only legal enemy cards are candidates.
5. **Archetype expression:** test focused public situations for approach, low-resource stabilization, retreat/approach at preferred distance, two resolved player-card repetition, and sequence scheduling. Each test checks legal slots/target tile and trace identity, not a player-facing exact answer.
6. **Slot integrity:** any scheduled two-slot action uses two adjacent real slots, no scheduled action overlaps or crosses `3/3/4` bundle boundaries, and sequence profiles schedule no more than two actions.
7. **Public history:** no record exists before a bundle resolves; it is bounded to six; next-bundle counter logic reads only resolved player records.
8. **Regression:** existing default rival tendency, ten-manual enemy card availability, candidate/manual selection, setup briefing secrecy, retry, route, action-selection, resolution, and product-gate tests remain green.
9. **Evidence boundary:** automated/headless evidence is required for implementation claims. Windows visible, accessibility-user, Android device, release performance, and Human Player Experience retain their independent statuses; Human is `NOT_RUN` in this stage.

## 12. Risks and adversarial disposition

| Risk | Countermeasure | Disposition |
| --- | --- | --- |
| Candidate copy claims a behavior current code cannot express. | Add common retreat/approach, resolved-history, and bundle scheduler boundaries; do not leave `behavior_focus` as proof by itself. | `MUST_FIX_IN_IMPLEMENTATION` |
| A profile reads a player plan before enemy lock. | Construct snapshot from state and resolver-produced history only; regression mutates private keys to prove invariance. | `MUST_FIX_IN_IMPLEMENTATION` |
| Fifteen special cases create maintenance debt. | Use five JSON archetypes and ordered focus IDs; prohibit candidate-specific code branches. | `PROTECT` |
| Stat total changes health/resources or redefines the player build. | Apply only to enemy `stats`; retain resource owners and existing player state. | `PROTECT` |
| Sequence scheduling secretly predicts outcomes. | Choose legal slots from the public lock-time state without simulation; actual resolution remains authoritative. | `PROTECT` |
| Automated scenarios are misreported as balance/fun validation. | Treat them as binding/determinism evidence only; a later balance-instrumentation contract and Human evidence stay separate. | `DEFER` |

## 13. Feasibility research

Godot's JSON API converts parsed objects to `Dictionary` values and exposes type checks, matching the repository's existing JSON loader pattern. Its static parse helper returns `null` on failure, so the new binding loader must validate both parse shape and required fields before runtime mutation. [Godot JSON documentation](https://docs.godotengine.org/en/stable/classes/class_json.html)

Godot supports headless execution with `--script`, which fits the repository's existing GDScript verification pattern for deterministic binding tests. This supports automated contract evidence only; it does not replace visible Windows or human-play evidence. [Godot command-line documentation](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)

## 14. Review request

This is the full design contract for the user-approved A direction. It intentionally makes the hidden implementation gaps explicit: current single-action AI cannot honestly enact Slot 5 sequence habits, current approach-only movement cannot enact Slot 3 range habits, and current state lacks resolved-history input for Slot 4. The proposed common boundaries address those gaps without inventing candidate-specific rules.

After the user approves this document, the next artifact is a task-by-task implementation plan and a single Codex/Godot implementation handoff for Issue #267. No product implementation starts from this draft.
