# Deterministic Balance Instrumentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** Build a validation-only Godot harness that measures every approved first-five candidate/loadout/public-policy/AI-seed single duel through the actual combat resolver and emits one deterministic, privacy-safe report.

**Architecture:** A versioned JSON matrix declares validation inputs. VerticalSliceBalancePublicPolicy turns public state and legal player cards into placements. VerticalSliceBalanceInstrumentation creates a fresh candidate-bound metrics engine for every scenario and normalizes real resolver outcomes. A SceneTree runner writes the ordered report, while Python validates report behavior only and never combat rules.

**Tech Stack:** Godot 4.7.1 GDScript / SceneTree, existing VerticalSliceMetricsCombatResolutionEngine, Python 3 JSON checker.

**Spec:** docs/superpowers/specs/2026-08-30-balance-instrumentation-design.md

## Global Constraints

- Preserve the 10-tile board, public opening distance 2 (player_tile=4, enemy_tile=6), and [3, 3, 4] resolver sequence.
- Read candidates from VerticalSliceOpponentCatalog and every legal four-of-six starter selection from VerticalSliceStarterManualCatalog; do not duplicate either source list.
- Call actual VerticalSliceMetricsCombatResolutionEngine.resolve_bundle; never reimplement combat, AI, martial, range, defense, clash, interruption, or metric formulas.
- Policy may read only public state, player legal cards, selected player loadout, public history, and explicit ai_decision_seed.
- Do not serialize weights, planner trace, locked enemy actions, pending placements, previews, observation answer, pointer/focus, or recommendations.
- Use a new engine/planner/state per scenario. Emit sorted rows and fixed key order. Any invalid scenario fails the complete run.
- This is validation-only: do not change player-facing scenes, save, combat values, assets, audio, Android, telemetry, or automatic balance tuning.
- Automated/headless evidence does not prove Windows-visible, Human/player, Android, accessibility, release, or balance PASS.

---

## File Structure

| File | Responsibility |
| --- | --- |
| data/validation/vertical_slice_balance_instrumentation_matrix.json | Versioned public inputs and expected dimensions. |
| src/validation/vertical_slice_balance_public_policy.gd | Deterministic public-only placement policy. |
| src/validation/vertical_slice_balance_instrumentation.gd | Matrix expansion, fresh-engine execution, normalized report. |
| tests/verify_vertical_slice_balance_instrumentation.gd | Actual Godot coverage, isolation, privacy, and determinism behavior. |
| tests/run_vertical_slice_balance_instrumentation.gd | SceneTree full-run entry point and JSON writer. |
| tests/check_vertical_slice_balance_report.py | Output schema/coverage/privacy/byte comparison, with no combat calculation. |
| docs/operations/2026-08-30_BALANCE_INSTRUMENTATION_IMPLEMENTATION_EXECUTION_REPORT.md | Executed evidence only, after actual result collection. |

## Task 1: Matrix contract and RED behavior proof

**Files:**

- Create: data/validation/vertical_slice_balance_instrumentation_matrix.json
- Create: tests/verify_vertical_slice_balance_instrumentation.gd
- Create: tests/check_vertical_slice_balance_report.py

**Interfaces:**

- Consumes: VerticalSliceOpponentCatalog.get_all_candidates(), VerticalSliceStarterManualCatalog.get_options().
- Produces: VerticalSliceBalanceInstrumentation.build_matrix_contract() -> Dictionary and build_scenarios() -> Array.

The matrix file must contain exactly this public validation configuration:

~~~json
{
  "schema_version": 1,
  "contract_id": "TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01",
  "route_context_id": "opening_no_route",
  "player_tile": 4,
  "enemy_tile": 6,
  "timing_sequence": [3, 3, 4],
  "maximum_rounds": 12,
  "ai_decision_seeds": [0, 1, 17, 101, 1009],
  "player_policy_ids": [
    "public_approach_pressure",
    "public_guarded_exchange",
    "public_recovery_range"
  ],
  "expected_candidate_count": 15,
  "expected_starter_loadout_count": 15,
  "expected_scenario_count": 3375
}
~~~

- [ ] **Step 1: Write the failing Godot test before production scripts**

Create the verifier with a preload of the not-yet-created instrumentation script and these real boundary assertions:

~~~gdscript
var instrumentation = InstrumentationScript.new()
var contract: Dictionary = instrumentation.build_matrix_contract()
_expect(bool(contract.get("valid", false)), "Current matrix must validate.")
_expect_eq(int(contract.get("candidate_count", -1)), 15, "All current candidates must be covered.")
_expect_eq(int(contract.get("starter_loadout_count", -1)), 15, "Every legal current 4-of-6 selection must be covered.")
_expect_eq(int(contract.get("scenario_count", -1)), 3375, "The current matrix must contain 3,375 duels.")
_expect_eq(instrumentation.build_scenarios().size(), 3375, "Every scenario must materialize.")
~~~

Add a same-scenario-twice assertion for exact normalized row equality, an invalid-candidate assertion for fail-closed behavior, a second-candidate isolation assertion, and a sentinel-state assertion. Copied state values in debug_hidden_player_plan, pointer_focus, uncommitted_target_preview, and observation_answer cannot affect placements or appear recursively in a row.

- [ ] **Step 2: Run RED**

Run:

~~~powershell
& $godot --headless --path . --script tests/verify_vertical_slice_balance_instrumentation.gd
~~~

Expected: nonzero load/parse failure because res://src/validation/vertical_slice_balance_instrumentation.gd does not exist. The failure is expected to name the missing feature.

- [ ] **Step 3: Write the failing report checker**

Create a command-line Python checker that accepts report_a and optional report_b. It reads raw UTF-8 bytes first; two inputs must be byte-identical. Then assert:

~~~python
assert report["schema_version"] == 1
assert report["contract_id"] == "TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01"
assert report["scenario_count_expected"] == 3375
assert report["scenario_count_completed"] == 3375
assert len(report["rows"]) == 3375
assert [row["scenario_id"] for row in report["rows"]] == sorted(row["scenario_id"] for row in report["rows"])
assert len({row["scenario_id"] for row in report["rows"]}) == 3375
~~~

The recursive privacy check rejects keys/tokens ai_profile, weight, trace, locked_enemy, pending, preview, pointer, focus, and observation.

- [ ] **Step 4: Run Python RED**

~~~powershell
python tests/check_vertical_slice_balance_report.py .\missing-report.json
~~~

Expected: nonzero failure that names the missing file.

- [ ] **Step 5: Commit the RED task**

~~~powershell
git add -- data/validation/vertical_slice_balance_instrumentation_matrix.json tests/verify_vertical_slice_balance_instrumentation.gd tests/check_vertical_slice_balance_report.py
git commit -m "test: specify balance instrumentation contract"
~~~

## Task 2: Public-only player policy

**Files:**

- Create: src/validation/vertical_slice_balance_public_policy.gd
- Modify: tests/verify_vertical_slice_balance_instrumentation.gd

**Interfaces:**

- Consumes: policy_id: String, state: Dictionary, cards_by_id: Dictionary, player_martial_card_ids: PackedStringArray, bundle_index: int, timing_sequence: Array.
- Produces: build_placements(...) -> Array[Dictionary]; each placement has card_id, deep-copied definition, anchor_index, span, targeting_mode, target_ready, target_tile, direction, origin_tile.

- [ ] **Step 1: Extend the test for legal policies**

Assert exactly:

~~~gdscript
_expect_eq(PolicyScript.get_policy_ids(), [
    "public_approach_pressure",
    "public_guarded_exchange",
    "public_recovery_range"
], "Only approved public policies may run.")
~~~

At distance 2, build each policy with real engine cards, call engine.preview_player_plan(state, placements), and assert valid == true. Assert all anchors/spans lie inside bundle 1 [1,3], bundle 2 [4,6], or bundle 3 [7,10].

- [ ] **Step 2: Run RED**

Run the Task 1 Godot command. Expected: nonzero because the policy class is absent.

- [ ] **Step 3: Implement the smallest policy**

Create class_name VerticalSliceBalancePublicPolicy extending RefCounted with:

~~~gdscript
static func get_policy_ids() -> Array[String]
static func build_placements(
    policy_id: String,
    state: Dictionary,
    cards_by_id: Dictionary,
    player_martial_card_ids: PackedStringArray,
    bundle_index: int,
    timing_sequence: Array
) -> Array[Dictionary]
~~~

Whitelist public state before policy selection. Reject unknown IDs. Approach policy closes distance via basic_move/legal basic_footwork before selecting a reachable player martial attack or basic_heavy_attack/basic_quick_attack. Guarded policy selects legal basic_guard or basic_evade. Recovery policy chooses basic_meditate only when its own public stamina/internal is below maximum, otherwise a legal range action. Build placement dictionaries from actual card definitions only.

- [ ] **Step 4: Run GREEN and adjacent boundary regression**

~~~powershell
& $godot --headless --path . --script tests/verify_vertical_slice_balance_instrumentation.gd
& $godot --headless --path . --script tests/verify_ai_rival_tendency.gd
~~~

Expected: both exit 0.

- [ ] **Step 5: Commit**

~~~powershell
git add -- src/validation/vertical_slice_balance_public_policy.gd tests/verify_vertical_slice_balance_instrumentation.gd
git commit -m "feat: add public balance instrumentation policies"
~~~

## Task 3: Fresh-engine executor and result rows

**Files:**

- Create: src/validation/vertical_slice_balance_instrumentation.gd
- Modify: tests/verify_vertical_slice_balance_instrumentation.gd

**Interfaces:**

- Produces: build_matrix_contract() -> Dictionary, build_scenarios() -> Array, build_policy_placements_for_state(...) -> Array, run_scenario(scenario: Dictionary) -> Dictionary, run_all() -> Dictionary, serialize_report(report: Dictionary) -> String, run_and_write(output_path: String) -> Dictionary.

- [ ] **Step 1: Add actual-result RED assertions**

For a valid scenario row, assert route_context_id == "opening_no_route", outcome in ["win", "loss", "draw", "timeout"], nonnegative bundles_resolved, and exactly the existing five battle metrics. The malformed candidate scenario returns valid == false without partial rows. These tests fail if the executor copies rules, skips binding, reuses state, leaks private data, or claims partial success.

- [ ] **Step 2: Run RED**

Run the Task 1 Godot command. Expected: nonzero because executor methods are absent.

- [ ] **Step 3: Implement the actual-engine executor**

Implement this exact sequence:

1. Load/validate matrix JSON, current opponent catalog, runtime binding, and starter catalog.
2. Sort current candidate IDs and construct lexicographically sorted legal four-manual combinations from actual starter options.
3. For every scenario, create a fresh VerticalSliceMetricsCombatResolutionEngine, bind the candidate, configure player mastery-three manuals and candidate signature manual/star, then make state from combat_hud_preview.json at 4/6.
4. Set only ai_enabled=true and scenario ai_decision_seed.
5. For rounds 1 through 12 and bundles 1 through 3, obtain policy placements and invoke actual resolve_bundle(placements, {round_number, bundle_index, timing_sequence}, state).
6. Stop for health terminal state or normalize a measurement-only timeout after round 12.
7. Normalize public IDs, candidate archetype/stat total, final health, player resource loss, existing metrics, and fixed resolver cause counts. Do not retain an engine, state, binding, or trace after the row.
8. Sort rows by scenario_id; any invalid scenario yields a whole-run error, never a success report. Serialize with JSON.stringify(report, "  ") plus a trailing newline.

- [ ] **Step 4: Run GREEN and resolver regressions**

~~~powershell
& $godot --headless --path . --script tests/verify_vertical_slice_balance_instrumentation.gd
& $godot --headless --path . --script tests/verify_vertical_slice_opponent_runtime_binding.gd
& $godot --headless --path . --script tests/verify_phase2_combat_resolution.gd
~~~

Expected: every command exits 0.

- [ ] **Step 5: Commit**

~~~powershell
git add -- src/validation/vertical_slice_balance_instrumentation.gd tests/verify_vertical_slice_balance_instrumentation.gd
git commit -m "feat: execute deterministic balance scenarios"
~~~

## Task 4: Full runner and byte-identical report evidence

**Files:**

- Create: tests/run_vertical_slice_balance_instrumentation.gd
- Modify: tests/verify_vertical_slice_balance_instrumentation.gd
- Modify: tests/check_vertical_slice_balance_report.py

**Interfaces:**

- Produces: VerticalSliceBalanceInstrumentation.run_and_write(output_path: String) -> Dictionary. The SceneTree runner delegates to it and exits 0 only for 3,375 completed valid rows.

- [ ] **Step 1: Add RED runner assertions**

The verifier creates two instrumentation instances, calls run_and_write twice with temporary output paths, reads raw bytes, and expects equality. It invokes the Python checker with both paths through OS.execute. Before the executor owns this method the verifier fails; before the SceneTree runner exists the runner command fails.

- [ ] **Step 2: Run RED**

~~~powershell
& $godot --headless --path . --script tests/run_vertical_slice_balance_instrumentation.gd -- --output .\balance-report-red.json
~~~

Expected: nonzero because the runner script is absent.

- [ ] **Step 3: Implement runner and output checker**

The SceneTree runner parses only OS.get_cmdline_user_args() for --output, otherwise uses an untracked user:// path; it makes parent directories, calls run_all(), writes exactly one report only after valid completion, prints VERTICAL_SLICE_BALANCE_INSTRUMENTATION_OK scenarios=3375, and exits 0. It prints errors and exits 1 on any invalid/writing failure. The Python checker validates source coverage, fixed row keys, sorted unique IDs, nonnegative metrics/cause counts, forbidden recursive tokens, and byte equality for two reports; it calculates no combat outcome.

- [ ] **Step 4: Execute two full reports and verify GREEN**

~~~powershell
& $godot --headless --path . --script tests/run_vertical_slice_balance_instrumentation.gd -- --output .\balance-report-a.json
& $godot --headless --path . --script tests/run_vertical_slice_balance_instrumentation.gd -- --output .\balance-report-b.json
python tests/check_vertical_slice_balance_report.py .\balance-report-a.json .\balance-report-b.json
~~~

Expected: two Godot exits 0, Python exit 0, and byte-identical reports. Do not commit temporary reports.

- [ ] **Step 5: Commit**

~~~powershell
git add -- tests/run_vertical_slice_balance_instrumentation.gd tests/verify_vertical_slice_balance_instrumentation.gd tests/check_vertical_slice_balance_report.py
git commit -m "test: run deterministic balance instrumentation"
~~~

## Task 5: Evidence owners, adversarial review, and integration

**Files:**

- Modify: docs/decisions/2026-08-30_BALANCE_INSTRUMENTATION_CONTRACT_DECISION.md
- Modify: [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
- Modify: docs/planning-data/current_user_planning_status.json
- Create: docs/operations/2026-08-30_BALANCE_INSTRUMENTATION_IMPLEMENTATION_EXECUTION_REPORT.md
- Modify: tests/test_current_discovery_contract.py only if mutable owner values change.

**Interfaces:**

- Produces: executed-evidence status that separates full headless measurement from all unrun human/device/release evidence.

- [ ] **Step 1: Add a RED owner-state expectation**

Update current-discovery test to expect MACHINE_VERIFIED_HEADLESS_FULL_MATRIX only after actual reports are validated; run it first to observe the expected stale-status failure.

- [ ] **Step 2: Record executed facts only**

After full runs, write baseline SHA, exact commit, 3,375 completions, two byte-identical reports, commands, affected protected paths, no scene/save coupling, rollback, and unrun Windows-visible/Human/Android/accessibility/release gates. Do not state a balance threshold, fun, fairness, or player-understanding PASS.

- [ ] **Step 3: Run the final validation ladder**

~~~powershell
python tools/check_canonical_reference_freshness.py
python -m unittest tests.test_current_discovery_contract tests.test_human_game_blueprint_profile tests.test_pc_first_vertical_slice_implementation_gate tests.test_base_shared_skill_adapter -v
python tests/check_canonical_combat_docs.py
python tools/check_project_operating_system.py
& $godot --headless --editor --path . --quit
& $godot --headless --path . --script tests/verify_vertical_slice_balance_instrumentation.gd
& $godot --headless --path . --script tests/verify_vertical_slice_opponent_runtime_binding.gd
& $godot --headless --path . --script tests/verify_ai_rival_tendency.gd
git diff --check
~~~

Expected: every executed command exits 0. Device/human/release claims remain NOT_RUN unless actually executed.

- [ ] **Step 4: Complete five full-scope adversarial loops**

Review canon/diff; matrix source/coverage; actual resolver and AI privacy; untouched scenes/saves/assets; report evidence/cost/rollback. Correct real findings, re-run affected evidence, and record a clean exit for this package only.

- [ ] **Step 5: Commit evidence and prepare current-task PR**

~~~powershell
git add -- docs/decisions/2026-08-30_BALANCE_INSTRUMENTATION_CONTRACT_DECISION.md "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md" docs/planning-data/current_user_planning_status.json docs/operations/2026-08-30_BALANCE_INSTRUMENTATION_IMPLEMENTATION_EXECUTION_REPORT.md tests/test_current_discovery_contract.py
git commit -m "docs: record balance instrumentation evidence"
~~~

## Plan Self-Review

- **Spec coverage:** Tasks 1–4 implement matrix, three public policies, fresh actual resolver, 12-round timeout, privacy, determinism, coverage, and no player-facing coupling. Task 5 records evidence and integration.
- **No placeholders:** paths, interfaces, exact matrix content, failure conditions, commands, expected outputs, and report checks are explicit.
- **Type consistency:** instrumentation owns matrix/scenario/executor/report methods; public policy owns placements; SceneTree owns output/exit; Python validates output only.
- **Execution selection:** inline execution in this isolated worktree. The user asked to continue and this environment forbids creating subagents, so the required execution mode is superpowers:executing-plans.
