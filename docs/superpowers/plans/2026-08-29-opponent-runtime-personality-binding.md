# Opponent Runtime Personality Binding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans task-by-task only after the user-approved `TEN-IMP-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01` and its `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF` are present on current `main`. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every locked first-five opponent's approved archetype, ordered basic-action preference, and seeded five-stat total affect only that combat's actual public-state AI and enemy state.

**Architecture:** A validated JSON archetype owner and `VerticalSliceOpponentRuntimeBinding` adapter turn one catalog candidate into an immutable per-combat binding. The Vertical Slice bridge applies that binding to one metrics engine, while the shared resolver owns public resolved-history and the existing `CombatAiPlanner` scores/schedules only legal enemy actions from public state. The default global rival profile remains unchanged whenever no per-combat binding exists.

**Tech Stack:** Godot 4.7, GDScript, JSON, headless GDScript verification, Python static contracts, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-08-29-opponent-runtime-personality-binding-design.md`, `docs/implementation/2026-08-29_OPPONENT_RUNTIME_PERSONALITY_BINDING_IMPLEMENTATION_CONTRACT.md`, `TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01`.

## Global Constraints

- Preserve the 10-cell board, public opening distance `2`, `3수 = 3슬롯`, and `3 → 해결 → 3 → 해결 → 4 → 해결`.
- A two-slot action occupies exactly two adjacent real slots as one `[전조] → [실행]` action; no action crosses its current bundle boundary.
- **`행동계획 실행`** starts resolution/presentation. Neither side replans a locked bundle after execution begins.
- AI may read only its binding, legal enemy cards, deterministic seed, and resolved public combat state. It may not read uncommitted player placements, hidden target/direction, pointer/hover/focus, UI intent, observation answers, or a recommended counter.
- Candidate-specific behavior belongs in JSON archetypes plus ordered focus IDs. Do not add candidate-specific resolver/AI subclasses, enemy-only manuals/techniques, new resources, art/audio, economy, persistence, Route nodes, or platform work.
- Every new GDScript file begins with one Korean line comment describing its role. Use `Dictionary.duplicate(true)` at the binding, bridge, engine, and state boundaries; nested data must not leak between combats.
- Human Player Experience, Windows-visible, accessibility-user, Android-device, and release-performance evidence are not part of automated PASS. Human remains `NOT_RUN` for this stage.

---

### Task 1: Validate candidate-to-archetype data before any combat mutation

**Files:**
- Create: `data/run/vertical_slice_opponent_archetypes.json`
- Modify: `data/run/vertical_slice_opponents.json`
- Create: `src/run/vertical_slice_opponent_runtime_binding.gd`
- Create: `tests/verify_vertical_slice_opponent_runtime_binding.gd`
- Create: `tests/check_vertical_slice_opponent_runtime_binding_contract.py`
- Modify: `src/run/vertical_slice_opponent_catalog.gd`, `tests/verify_vertical_slice_opponent_catalog.gd`

**Interfaces:**
- Consumes: one catalog candidate with `candidate_id`, `runtime_archetype_id`, `basic_action_focus_ids`, and `final_stat_total_seed`.
- Produces:

```gdscript
# 첫 5전 후보 데이터를 검증된 전투별 런타임 binding으로 변환한다.
class_name VerticalSliceOpponentRuntimeBinding
extends RefCounted

func is_valid() -> bool
func get_load_errors() -> PackedStringArray
func build(candidate: Dictionary) -> Dictionary
# valid, candidate_id, archetype_id, ai_profile, basic_action_focus_ids,
# stats, final_stat_total_seed only
```

- The archetype owner uses `schema_version: 1`, canonical `stat_order`, positive integer stat weights totaling `20`, and exactly the five IDs in the approved spec. Candidate mappings are all 15 exact IDs from the approved mapping table; no default or guessed archetype is allowed.

- [ ] **Step 1: Write the failing data/binding regressions**

```gdscript
var binding := BindingScript.new()
_expect_true(binding.is_valid(), "Archetype data must load before a candidate can bind.")
var dogyeom: Dictionary = catalog.get_candidate("slot1_dogyeom")
var result: Dictionary = binding.build(dogyeom)
_expect_true(bool(result.get("valid", false)), "Dogyeom must produce a valid runtime binding.")
_expect_eq(str(result.get("archetype_id", "")), "stabilize_then_pressure", "Dogyeom must use the approved reusable archetype.")
_expect_eq(result.get("stats", {}), {"external": 4, "constitution": 6, "agility": 3, "internal_power": 4, "insight": 3}, "A total-20 stabilize profile must allocate its exact five stats.")
_expect_false(bool(binding.build({"candidate_id": "bad"}).get("valid", true)), "Missing archetype, focus, and total data must fail closed.")
```

Add Python assertions for five unique profile IDs, stat-weight sums of `20`, three valid focus IDs per candidate, 15 valid mappings, and an exact candidate stat sum equal to its existing seed.

- [ ] **Step 2: Run the new checks and observe RED**

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_opponent_runtime_binding.gd`

Run: `python tests/check_vertical_slice_opponent_runtime_binding_contract.py`

Expected: FAIL because the archetype file, `runtime_archetype_id`, and binding class do not exist on the pre-task state.

- [ ] **Step 3: Add the data owner and minimal validated adapter**

Create JSON profiles with the approved score weights, movement/history policy, action cap, and exact stat vectors. Add one `runtime_archetype_id` per existing candidate and replace the prior note that exact distributions are absent. The adapter must:

```gdscript
var allocated := _allocate_stats(total_seed, stat_weights)
if allocated.is_empty() or _sum_stats(allocated) != total_seed:
    return {"valid": false}
return {
    "valid": true,
    "candidate_id": candidate_id,
    "archetype_id": archetype_id,
    "ai_profile": profile.duplicate(true),
    "basic_action_focus_ids": focus_ids.duplicate(),
    "stats": allocated.duplicate(true),
    "final_stat_total_seed": total_seed
}
```

Allocate floors of `total * weight / 20`, then remainders by largest fractional part and the canonical stat order. Reject invalid JSON root/type, missing/duplicate profile IDs, non-positive/non-20 weights, invalid focus IDs, unknown archetypes, totals below one per derived stat, or a mismatched sum. Catalog validation must reject any candidate without a valid `runtime_archetype_id`.

- [ ] **Step 4: Run focused GREEN and catalog regression**

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_opponent_runtime_binding.gd`

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_opponent_catalog.gd`

Run: `python tests/check_vertical_slice_opponent_runtime_binding_contract.py`

Expected: PASS; all 15 bindings are valid and every derived stat sum matches the existing seed.

- [ ] **Step 5: Commit the self-contained data/binding unit**

```bash
git add data/run/vertical_slice_opponent_archetypes.json data/run/vertical_slice_opponents.json src/run/vertical_slice_opponent_runtime_binding.gd src/run/vertical_slice_opponent_catalog.gd tests/verify_vertical_slice_opponent_runtime_binding.gd tests/check_vertical_slice_opponent_runtime_binding_contract.py tests/verify_vertical_slice_opponent_catalog.gd
git commit -m "feat: bind opponent data to reusable archetypes"
```

### Task 2: Carry one validated binding through shell, bridge, engine, and retry-safe state

**Files:**
- Modify: `src/run/vertical_slice_shell.gd`, `src/run/vertical_slice_combat_bridge.gd`, `src/run/vertical_slice_metrics_combat_resolution_engine.gd`
- Modify: `tests/verify_vertical_slice_setup_briefing.gd`, `tests/verify_vertical_slice_opponent_runtime_binding.gd`

**Interfaces:**
- Consumes: a `valid` binding returned by Task 1 before bridge configuration.
- Produces:

```gdscript
func configure_vertical_slice_loadouts(
    player_loadout,
    player_mastery_by_manual: Dictionary,
    enemy_loadout,
    enemy_mastery_by_manual: Dictionary,
    enemy_candidate_id: String,
    enemy_runtime_binding: Dictionary,
    enemy_identity: Dictionary = {}
) -> bool

func configure_enemy_runtime_binding(binding: Dictionary) -> bool
```

- [ ] **Step 1: Write bridge isolation failures**

```gdscript
_expect_false(bridge.configure_vertical_slice_loadouts(player_ids, player_mastery, enemy_ids, enemy_mastery, "slot1_dogyeom", {"valid": false}), "Invalid binding must fail before bridge state mutates.")
_expect_true(bridge.configure_vertical_slice_loadouts(player_ids, player_mastery, enemy_ids, enemy_mastery, "slot1_dogyeom", dogyeom_binding), "Valid binding must configure the combat engine.")
var snapshot: Dictionary = bridge.get_vertical_slice_loadout_snapshot()
_expect_eq(str(snapshot.get("enemy_runtime_binding", {}).get("archetype_id", "")), "stabilize_then_pressure", "Bridge snapshot must retain the per-combat archetype ID.")
_expect_eq(bridge.combat_state.get("enemy", {}).get("stats", {}), dogyeom_binding.get("stats", {}), "Initial enemy state must use the derived candidate stats.")
```

Extend the setup/briefing test to assert that a shell-created bridge snapshot has the locked candidate ID, archetype ID, and derived stats, but that player-facing Briefing text still exposes neither internal profile IDs nor focus IDs.

- [ ] **Step 2: Run bridge/setup checks and observe RED**

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_setup_briefing.gd`

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_opponent_runtime_binding.gd`

Expected: FAIL because the shell passes no runtime binding and `make_initial_state` still uses the default enemy HUD stats.

- [ ] **Step 3: Apply binding at the single combat boundary**

The shell constructs a binding from `run_state.get_current_opponent()` and passes it in the new required argument. The bridge validates the binding before it sets `_ten_manual_loadout_data` or replaces `resolution_engine`; it deep-copies the binding into its loadout snapshot only for internal test/readback. `VerticalSliceMetricsCombatResolutionEngine` deep-copies a valid binding, calls `ai_planner.set_runtime_binding(...)`, and in every `make_initial_state` applies only `binding.stats` plus the candidate ID to `enemy`.

Do not put stats or profile scoring in HUD, Scene, or shell UI. A newly instantiated bridge on an existing same-seed retry must rebuild the same binding from the same locked candidate, while a later combat cannot retain a previous engine's binding.

- [ ] **Step 4: Run focused GREEN and bridge regressions**

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_setup_briefing.gd`

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_opponent_runtime_binding.gd`

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_opponent_catalog.gd`

Expected: PASS; valid candidates bind their own stats and archetype, invalid input changes no bridge state, and Briefing remains secrecy-safe.

- [ ] **Step 5: Commit the integration boundary**

```bash
git add src/run/vertical_slice_shell.gd src/run/vertical_slice_combat_bridge.gd src/run/vertical_slice_metrics_combat_resolution_engine.gd tests/verify_vertical_slice_setup_briefing.gd tests/verify_vertical_slice_opponent_runtime_binding.gd
git commit -m "feat: apply opponent binding per combat"
```

### Task 3: Store only resolved public history in the shared resolver

**Files:**
- Modify: `src/combat/combat_resolution_engine.gd`
- Modify: `tests/verify_phase2_combat_resolution.gd`, `tests/verify_vertical_slice_opponent_runtime_binding.gd`

**Interfaces:**
- Consumes: `resolved_actions` after the current bundle has completed.
- Produces: `combat_state.public_resolution_history`, ordered oldest to newest, maximum six records. Each record has exactly `round_number`, `bundle_index`, `actor`, `card_id`, `category`, and `outcome`.

- [ ] **Step 1: Write the failing public-history regressions**

```gdscript
var initial := engine.make_initial_state(hud_data, 4, 6)
_expect_false(initial.has("public_resolution_history"), "No future or locked-bundle history may exist at combat start.")
var resolved := engine.resolve_bundle(player_placements, {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, initial)
var history: Array = resolved.get("state", {}).get("public_resolution_history", [])
_expect_true(history.size() >= 1, "A completed bundle must append resolved execution records.")
_expect_false((history[0] as Dictionary).has("target_tile"), "Public history must exclude target intent.")
_expect_false((history[0] as Dictionary).has("direction"), "Public history must exclude direction intent.")
```

Resolve enough legal single-action bundles to require trimming, then assert `history.size() == 6`, the newest record is retained, and a two-slot action adds only its execution record—not its `[전조]` preparation record.

- [ ] **Step 2: Run the resolution verifier and observe RED**

Run: `godot --headless --path . --script res://tests/verify_phase2_combat_resolution.gd`

Expected: FAIL because initial state has no bounded public-history owner and resolved records do not include the approved public category field.

- [ ] **Step 3: Append a minimal post-resolution public projection**

Add `category` to `_resolved_record`. Immediately after the bundle's normal resolution completes, append only records whose `action_stage == "execution"`; project the six approved fields into a new dictionary, discard all other action fields, and remove oldest entries while the array exceeds six. Never append during lock, planning, preview, preparation, or observation reveal.

```gdscript
func _append_public_resolution_history(state: Dictionary, resolved_actions: Array, round_number: int, bundle_index: int) -> void:
    var history: Array = (state.get("public_resolution_history", []) as Array).duplicate(true)
    for action_value in resolved_actions:
        var action: Dictionary = action_value
        if str(action.get("action_stage", "execution")) != "execution":
            continue
        history.append({"round_number": round_number, "bundle_index": bundle_index, "actor": str(action.get("actor", "")), "card_id": str(action.get("card_id", "")), "category": str(action.get("category", "")), "outcome": str(action.get("outcome", ""))})
    while history.size() > 6:
        history.pop_front()
    state["public_resolution_history"] = history
```

- [ ] **Step 4: Run focused GREEN and martial/resolution regressions**

Run: `godot --headless --path . --script res://tests/verify_phase2_combat_resolution.gd`

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_opponent_runtime_binding.gd`

Run: the existing ten-manual resolution verifier named by the current workflow.

Expected: PASS; history exists only after resolution, contains no pre-commit/UI/target fields, and leaves the existing resolver's outcome ownership intact.

- [ ] **Step 5: Commit the resolver-owned public history unit**

```bash
git add src/combat/combat_resolution_engine.gd tests/verify_phase2_combat_resolution.gd tests/verify_vertical_slice_opponent_runtime_binding.gd
git commit -m "feat: record bounded public resolution history"
```

### Task 4: Make the optional per-combat planner binding express five archetypes without cheating

**Files:**
- Modify: `src/combat/combat_ai_planner.gd`
- Modify: `tests/verify_ai_rival_tendency.gd`, `tests/verify_vertical_slice_opponent_runtime_binding.gd`

**Interfaces:**

```gdscript
func set_runtime_binding(archetype_id: String, ai_profile: Dictionary, basic_action_focus_ids: Array[String]) -> bool
func clear_runtime_binding() -> void
func build_bundle_actions(state: Dictionary, bundle_index: int, cards_by_id: Dictionary) -> Array
```

- A bound planner trace contains `runtime_archetype_id`, public-history count, first `selected_card_id`, and `scheduled_card_ids`; it contains no focus list, profile weights, player placement, UI, target-preview, or observation-answer field. An unbound planner keeps the current global tendency profile and single-action policy.

- [ ] **Step 1: Write failing fairness, movement, focus, and slot-scheduling tests**

```gdscript
_expect_true(planner.set_runtime_binding("range_control", range_profile, []), "Range profile must validate.")
var retreat_actions := planner.build_bundle_actions(_public_state_at_distance(2), 1, cards_by_id)
_expect_eq(int((retreat_actions[0] as Dictionary).get("target_tile", 0)), 7, "At public distance 2, range control must retreat from enemy tile 6 to 7 toward preferred distance 3.")

planner.set_runtime_binding("initiative_exchange", initiative_profile, ["basic_guard"])
planner.build_bundle_actions(_low_health_public_state(), 1, cards_by_id)
_expect_eq(float(planner.get_last_trace().get("candidate_scores", {}).get("basic_guard", 0.0)), 9.6, "First focus adds 1.20 to the public low-health guard score.")
_expect_false(_contains_forbidden_trace_data(planner.get_last_trace()), "AI trace must not expose focus or UI-only keys.")

planner.set_runtime_binding("sequence_pressure", sequence_profile, ["basic_quick_attack", "basic_guard"])
var sequence := planner.build_bundle_actions(_low_health_distance_one_state(), 1, cards_by_id)
_expect_true(sequence.size() <= 2, "Sequence profile may schedule at most two actions.")
_expect_no_overlap_or_bundle_cross(sequence, 1, [3, 3, 4])
```

Mutate `debug_hidden_player_plan`, `pointer_focus`, uncommitted target/direction, and observation keys between otherwise identical states; actions and trace must remain identical. Add a state with two resolved player records and assert `public_history_counter` uses only those public records. Keep existing default-profile tests for ultimates, meditation, `basic_palm`, and no `basic_observe`.

- [ ] **Step 2: Run the planner regressions and observe RED**

Run: `godot --headless --path . --script res://tests/verify_ai_rival_tendency.gd`

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_opponent_runtime_binding.gd`

Expected: FAIL because the planner has no binding setters, always approaches, has no resolved history, and returns only one action.

- [ ] **Step 3: Add optional profile precedence, legal score bonuses, movement, and scheduler**

When a valid binding is set, `_active_profile()` returns its deep-copied data; otherwise it returns the untouched current `combat_rival_tendency_poc.json` active profile. Build a snapshot from existing scalar public fields plus at most two newest player records projected from `public_resolution_history`. Add `+1.20`, `+0.60`, `+0.30` only to legal candidates matching first/second/third focus IDs.

For movement, calculate a desired direction from public distance: approach toward player, preferred-distance retreat/approach around `3`, and hold-or-approach without a hidden target. Clamp it through the current 1..10 board and existing movement range. For `max_actions_per_bundle: 2`, select the first legal action at the bundle start, subtract its actual `action_slots`, and select at most one non-duplicate legal action at the next available timing. Keep a two-slot action's `timing` at its preparation anchor so the resolver derives its execution slot. Never score a future simulated outcome or modify a locked bundle.

- [ ] **Step 4: Run focused GREEN and default-rival regression**

Run: `godot --headless --path . --script res://tests/verify_ai_rival_tendency.gd`

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_opponent_runtime_binding.gd`

Run: `godot --headless --path . --script res://tests/verify_vertical_slice_opponent_catalog.gd`

Expected: PASS; all archetypes consume only public state, range control can retreat, sequence scheduling never overlaps slots, and the unbound global rival retains existing behavior.

- [ ] **Step 5: Commit the planner unit**

```bash
git add src/combat/combat_ai_planner.gd tests/verify_ai_rival_tendency.gd tests/verify_vertical_slice_opponent_runtime_binding.gd
git commit -m "feat: express opponent archetypes in public AI"
```

### Task 5: Prove the end-to-end first-five binding and publish exact evidence boundaries

**Files:**
- Modify: current workflow/test script list that invokes the affected verifiers
- Modify: `docs/02_COMBAT_RULES.md`, `docs/08_TEST_CHECKLIST.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`, `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`, `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`, `docs/planning-data/current_user_planning_status.json`
- Create: `docs/operations/2026-08-29_ISSUE267_OPPONENT_RUNTIME_PERSONALITY_EXECUTION_REPORT.md`

**Interfaces:**
- Consumes: the Task 1 binding, Task 2 bridge state, Task 3 public history, and Task 4 planner trace.
- Produces: exact-head automated/Godot evidence and a status record that distinguishes implementation evidence from unrun human/device evidence.

- [ ] **Step 1: Write the integrated failure case before final documentation changes**

```gdscript
var first: Dictionary = _start_locked_candidate_combat("slot3_seolha")
_expect_eq(str(first.get("binding", {}).get("archetype_id", "")), "range_control", "Slot 3 candidate must reach its approved runtime archetype.")
_expect_eq(_sum_stats(first.get("combat_state", {}).get("enemy", {}).get("stats", {})), 24, "Slot 3 enemy stat sum must equal its seed.")
_expect_true(_trace_uses_only_public_history(first.get("trace", {})), "Integrated counter inputs must exclude current player plan and UI state.")
```

Add a second candidate combat after the first and assert no archetype/stats/action trace leaks across engines. Add a same-seed retry/rebuild assertion if the current retry verifier is available; otherwise add it to the new binding verifier without changing retry rules.

- [ ] **Step 2: Run the full affected suite and observe RED**

Run the new binding verifier plus current opponent catalog, setup briefing, AI tendency, combat resolution, action-selection, ten-manual, Vertical Slice route/retry, and Python discovery/operating-system checks.

Expected: FAIL until all prior tasks are present; no result may be reported as runtime evidence before this suite is green.

- [ ] **Step 3: Run final automated/Godot verification on the exact implementation head**

Run: `python tools/check_project_operating_system.py`

Run: `python tools/check_canonical_reference_freshness.py`

Run: `python tools/check_skill_package_integrity.py`

Run: `python -m unittest tests.test_current_discovery_contract tests.test_project_governance -v`

Run every affected Godot verifier named in the current workflow, then run the project parse/headless command used by that workflow. Record the exact commands, exit codes, commit SHA, and any environment blocker in the execution report.

- [ ] **Step 4: Update only verified current truth**

Move `opponent_behavior_runtime_binding` from handoff-issued to the exact automated result only after Task 3–5 evidence exists. Keep balance simulation blocked until its separate instrumentation contract, and retain `NOT_RUN` for Windows-visible, Human, accessibility-user, Android device, and release performance. Do not claim generated assets, Scene completion, or Player Experience PASS.

- [ ] **Step 5: Commit evidence/status and deliver the implementation PR**

```bash
git add docs/02_COMBAT_RULES.md docs/08_TEST_CHECKLIST.md docs/09_COMBAT_SYSTEM_ARCHITECTURE.md docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md '[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md' docs/planning-data/current_user_planning_status.json docs/operations/2026-08-29_ISSUE267_OPPONENT_RUNTIME_PERSONALITY_EXECUTION_REPORT.md
git commit -m "docs: record opponent binding evidence"
```

Push only the Issue #267 branch, create its one PR, read the exact-head checks, and merge only after required checks and review are green. Then fetch/read `origin/main`, compare the merge commit, and update the Issue/operation readback. Existing PRs #199 and #200 remain read-only throughout.

## Self-review

- Data validity and deterministic stat apportionment are Task 1.
- Bridge/engine lifetime and retry-safe isolation are Task 2.
- Resolved-only history is Task 3.
- Public-only scoring, focus bonuses, movement, and 3/3/4-safe scheduling are Task 4.
- Full first-five evidence, untouched default behavior, canonical state, and proof boundaries are Task 5.
- No task adds a deck, hand, draw restriction, player-plan-reading AI, candidate-specific code branch, economy, save feature, art/audio, or Human PASS.
- The plan contains no deferred implementation markers; an executor has the exact source files, interfaces, RED/GREEN criteria, and commit boundaries needed to implement it.
