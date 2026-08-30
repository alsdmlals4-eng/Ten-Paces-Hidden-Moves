# First-Five Deterministic Balance Instrumentation Design

~~~yaml
status: USER_APPROVED_WRITTEN_SPEC_REVIEW_PENDING
decision: TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
baseline_main: 75168849691e3965e7d665dcb1af97485756e6cf
work_mode: PLAN
skill_modes:
  - ten-paces-game-design / balance-review
  - ten-paces-verification / contract-check
user_direction: "권장안대로 진행해; godot에 기획안들 전부 다 구현될 때까지 멈추지마"
approval_receipt: "2026-08-30 KST, user approved the proposed engine-direct single-duel instrumentation v1."
runtime_mutation_in_this_spec: NONE
human_playtest: NOT_RUN_DEFERRED_BY_USER_FOR_CURRENT_STAGE
~~~

## 1. Purpose and player value

The already-implemented opponent runtime binding makes the first five duels materially different: each candidate now owns one reusable profile, an ordered basic-action focus, and a derived five-stat total. The unresolved question is no longer whether those fields reach the real combat engine. It is whether their provisional profile weights and total-stat seeds create a defensible distribution of difficulty.

This package creates reproducible measurement before any numerical tuning. It does not tell a player which card to use, expose a hidden opponent plan, or declare the game balanced. Its player value is indirect but essential: future tuning decisions can cite real resolver outcomes instead of candidate prose, a Python rule copy, or intuition.

~~~
locked candidate + actual current engine
→ fixed public player policy and legal player loadout
→ 3 / 3 / 4 bundle resolution
→ public terminal/result events
→ deterministic per-duel record
→ coverage and aggregate report
→ separate balance decision or human playtest
~~~

## 2. Decision and scope

### Adopted approach

Use an engine-direct, non-shipping, deterministic single-duel instrumentation harness. A headless Godot SceneTree runner must construct the existing catalog, runtime binding, martial registry, and VerticalSliceMetricsCombatResolutionEngine; it must then resolve the real 3/3/4 combat bundles. It must not duplicate combat, AI, martial-card, range, clash, guard, evade, interruption, or metric formulas in Python or a parallel GDScript ruleset.

### Included

- all 15 current first-five-duel candidates;
- every legal four-of-six starter-manual selection produced by the current starter catalog (15 loadouts);
- three bounded, public-state-only player policies;
- five explicit AI decision seeds: [0, 1, 17, 101, 1009];
- one initial resource/route context: opening_no_route;
- real candidate binding, card availability, AI planner, public resolution history, and battle metrics;
- a maximum of 12 full rounds, with an explicit measurement-only timeout terminal state;
- a versioned JSON scenario matrix and deterministic JSON report;
- focused contract, determinism, information-boundary, coverage, and adjacent resolver regressions.

The initial matrix has exactly:

~~~
15 candidates × 15 legal starter loadouts × 3 public policies × 5 AI seeds
= 3,375 single-duel scenarios
~~~

### Excluded

- changing combat formulas, candidate data, profile weights, stat totals, starter data, or route values;
- changing current run_seed semantics or saving a new AI seed;
- player UI, combat presentation, assets, audio, localization, Android layout, save/profile persistence, telemetry upload, or external analytics;
- campaign-wide reward/route automation, five-duel auto-play, and retry-economy evaluation;
- automatic balance PASS/FAIL thresholds, automatic tuning, or a Human Player Experience claim.

The 12-round cap is an instrumentation safety limit only. A timeout is a measurement result, not a new game draw rule.

## 3. Alternatives considered

| Alternative | Disposition | Benefit | Rejection or adoption reason |
| --- | --- | --- | --- |
| A. Real engine, deterministic, single-duel headless harness | ADOPT | Measures current candidate binding and resolver behavior without a duplicate rules model. | Smallest reliable evidence package; keeps UI/save/runtime behavior untouched. |
| B. Full five-duel campaign simulator with reward, route, growth, retry, and opponent-selection policies | DEFER | Would eventually measure run-level difficulty and route effects. | The policy itself would become a new game-design authority and could obscure the immediate candidate/profile question. |
| C. Python Monte Carlo reimplementation | REJECT | Fast aggregation and familiar data tooling. | A second combat model could drift from the actual resolver and create false balance evidence. |

## 4. Architecture and ownership

| Layer | Planned owner | Responsibility | Boundary |
| --- | --- | --- | --- |
| Scenario configuration | data/validation/vertical_slice_balance_instrumentation_matrix.json | Versioned seed vector, route context, policy IDs, round cap, expected scenario count. | Data is validation-only and never loaded by gameplay scenes. |
| Policy selection | src/validation/vertical_slice_balance_public_policy.gd | Map current public state and the player's legal cards to placements. | Cannot read enemy locked actions, planner trace, profile weights, pending player plans, target previews, or UI state. |
| Duel executor | src/validation/vertical_slice_balance_instrumentation.gd | Build current catalog/binding/engine, execute a single scenario, normalize the public result. | Uses the actual engine; owns no combat formula. |
| Headless entry point | tests/run_vertical_slice_balance_instrumentation.gd | Read the matrix, execute ordered scenarios, write one deterministic report, return nonzero on any failed scenario. | Never enters the game scene tree or writes tracked game data. |
| Automated proof | tests/verify_vertical_slice_balance_instrumentation.gd and a focused Python contract check | Validate configuration, deterministic output, coverage, data privacy, and failure behavior. | Does not assert a desirable win-rate number. |
| CI artifact plumbing | Existing test/CI conventions, only if an existing no-cost artifact route supports it | Preserve report as build evidence. | No new paid service, remote telemetry, or player data collection. |

No new gameplay data, source, scene, asset, addon, or project-setting consumer is permitted. The planned validation files are development-only and may call the current runtime engine but may not be reachable from a player-facing scene.

## 5. Scenario matrix and public player policies

The runner must obtain candidate order from the current VerticalSliceOpponentCatalog and starter selections from VerticalSliceStarterManualCatalog. It must sort IDs and construct each selection deterministically; neither list is duplicated by hand in the test.

Each policy may receive only:

- round number, bundle index, current public tiles/distance;
- the player's current health, stamina, internal power, and momentum;
- the player's legal current card definitions and own selected starter loadout;
- already-resolved public history.

Each policy must be deterministic and must validate its proposed placements through the actual engine's existing legality boundary.

| Policy ID | Intent | Permitted behavior |
| --- | --- | --- |
| public_approach_pressure | Test normal approach and attack pressure. | Close distance when out of range; prefer a legal attack or player martial card once it can resolve. |
| public_guarded_exchange | Test defense-first exchanges. | Prefer a legal guard/evade when public resources and distance support it; otherwise use a legal short-range response. |
| public_recovery_range | Test resource recovery and midrange decisions. | Recover when its own public resources are low; otherwise prefer legal distance control, palm, or martial options. |

Policies may not inspect any AI candidate list, enemy chosen card, AI trace, runtime profile object, uncommitted player placement, or UI-only field. A policy may be simplistic; it is an instrument input, never the correct player strategy.

## 6. Resolution and termination protocol

For every ordered scenario the executor must:

1. load the current HUD, catalog, runtime binding, current legal player loadout, and the candidate's signature manual/mastery;
2. create one fresh VerticalSliceMetricsCombatResolutionEngine;
3. apply only the validated candidate runtime binding and current legal martial loadouts;
4. create the initial combat state at current public opening distance 2 (player_tile=4, enemy_tile=6);
5. set the explicit ai_decision_seed for this measurement scenario without changing normal gameplay seed policy;
6. for rounds 1..12, resolve bundle indices 1..3 using the existing [3, 3, 4] timing sequence and the selected public policy;
7. stop at an actual player/enemy terminal state, or record timeout after the round cap;
8. emit one normalized result row, or fail the full run when engine setup, a policy proposal, or result normalization is invalid.

The executor must start a fresh engine per scenario. It must neither reuse an enemy planner/binding across candidates nor persist a state mutation between scenarios. It must use the resolver-produced public_resolution_history only after each real bundle has resolved.

## 7. Report schema and information boundary

The report is an internal, local/CI artifact. The headless entry point accepts an explicit output path after Godot's user-argument separator; otherwise it may write a temporary user:// report. Tracked report JSON is not a new source of gameplay truth.

~~~json
{
  "schema_version": 1,
  "contract_id": "TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01",
  "scenario_count_expected": 3375,
  "scenario_count_completed": 3375,
  "rows": [
    {
      "scenario_id": "candidate|loadout|policy|seed",
      "candidate_id": "slot1_dogyeom",
      "archetype_id": "stabilize_then_pressure",
      "enemy_stat_total": 20,
      "starter_loadout_id": "sorted-current-four-of-six-id",
      "player_policy_id": "public_approach_pressure",
      "route_context_id": "opening_no_route",
      "ai_decision_seed": 0,
      "outcome": "win|loss|draw|timeout",
      "rounds_elapsed": 0,
      "bundles_resolved": 0,
      "player_final_health": 0,
      "enemy_final_health": 0,
      "player_resource_loss": {"health": 0, "stamina": 0, "internal": 0},
      "battle_metrics": {},
      "cause_counts": {}
    }
  ],
  "coverage": {},
  "aggregates": {}
}
~~~

battle_metrics is the existing five-key metric object. cause_counts is derived only from completed resolver action outcomes and contains fixed keys for clash, range_miss, guard, evade, interrupted, and resource_insufficient.

The report must not include profile weight values, candidate score tables, AI planner trace, locked enemy actions, pending player placements, target/direction preview, observation answer, UI pointer/focus state, or any recommended player counter. The test suite must inject sentinel private fields into combat state and prove the policy/result public record remain unchanged.

The writer must use a fixed row order and fixed key order so an identical code/data/matrix input produces byte-identical output. A deterministic report is an acceptance requirement, not a claim that different game versions must have equal results.

## 8. Aggregation and interpretation

The report aggregates only observed output:

- completed/failed coverage by candidate, archetype, stat-total, loadout, policy, route context, and seed;
- win/loss/draw/timeout counts and rates;
- mean final health, player health loss, elapsed rounds, and existing battle metrics;
- resolver cause totals and rates;
- unexpected failed/invalid scenarios.

The harness has no green balance threshold. A distribution is an input to the next decision:

- KEEP: observed distribution is acceptable after separate design review;
- CHANGE: a specific profile weight, stat total, recovery value, or card value needs a separately approved data decision;
- RETEST: expand the seed/loadout/policy matrix or correct an instrumentation defect;
- DEFER: campaign/route or Human Player Experience questions remain outside v1.

No conclusion about fun, fairness, accessibility, Android, release performance, or player understanding may be inferred from the report.

## 9. Acceptance criteria and failure tests

1. Matrix validity: the matrix has exactly one opening_no_route context, three known policy IDs, the five explicit seeds, a positive round cap, and the calculated scenario count 3375.
2. Current-source coverage: all 15 current candidates and all legal current four-of-six starter selections are covered. A missing/invalid candidate, manual, card, or runtime binding fails before a partial success claim.
3. Actual engine use: a focused verifier proves the executor constructs VerticalSliceMetricsCombatResolutionEngine, the catalog binding adapter, and the actual martial registry; no copied resolver formula is allowed.
4. Determinism: two executions with the same exact project content and matrix yield byte-identical reports and matching normalized per-scenario rows.
5. Isolation: every scenario starts with fresh engine/planner/state; changing a prior scenario cannot alter a later one.
6. Public-information boundary: injected pending-plan/UI/trace sentinel fields do not change a policy's placements or appear in an output row.
7. Outcome accounting: final health, existing battle metrics, and cause totals agree with the actual resolved state/actions. A timeout is recorded distinctly.
8. No gameplay coupling: default game startup and current battle paths do not import, instantiate, or require the instrumentation runner.
9. Regression: existing candidate-binding, resolver, AI-public-boundary, retry, route, starter-catalog, and product-gate focused tests remain green.
10. Evidence ceiling: automated/headless results are reported as MACHINE_VERIFIED only after execution. Windows-visible, Human/player, accessibility-user, Android-device, and release-performance evidence remain independently NOT_RUN unless actually executed.

## 10. Feasibility and external-source relevance

This is a material implementation decision, so current engine documentation was checked. Godot supports a standalone .gd script through --script; such scripts inherit SceneTree or MainLoop, and --headless is explicitly intended for script-oriented non-window execution. That matches this repository's existing headless GDScript verification pattern. [Godot command-line documentation](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)

Godot documents that a RandomNumberGenerator owns independent seed/state, but this project already uses the deterministic integer ai_decision_seed field in its planner. v1 therefore supplies that existing field explicitly rather than introducing a second RNG model or changing normal gameplay semantics. [Godot random-number generation documentation](https://docs.godotengine.org/en/4.7/tutorials/math/random_number_generation.html)

Feasibility verdict: FEASIBLE. The candidate adapter, metrics resolution engine, AI planner, martials registry, catalog, and headless test pattern already exist. The first build must still establish RED tests before the minimal runner implementation.

## 11. Risks, rollback, and follow-up

| Risk | Mitigation | Status |
| --- | --- | --- |
| The harness becomes a second combat implementation. | Delegate all resolution to the current metrics engine; test imports and outcome agreement. | MUST_PROTECT |
| Synthetic policies get mistaken for player behavior. | Name policies as instruments, record them in every row, and prohibit balance PASS thresholds. | MUST_PROTECT |
| Hidden AI/player data leaks into report. | Fixed public schema, sentinel regression, and no trace serialization. | MUST_PROTECT |
| A large matrix makes CI slow. | Start with 3,375 single-duel cases and measure elapsed time; optimize only after evidence. | OBSERVE |
| Route/campaign conclusions are inferred too early. | Use explicit opening_no_route; defer campaign automation to a later decision. | DEFER |
| Current run seed and AI decision seed are conflated. | Record only explicit ai_decision_seed; do not mutate run/save seed behavior. | MUST_PROTECT |

Rollback is deletion of validation-only files and CI artifact wiring from the isolated implementation branch. No player save, content, art, combat data, or shipping runtime migration is created by this package.

## 12. Implementation boundary after written-spec review

After the user reviews this committed specification, the next permitted artifact is a detailed implementation plan followed by one isolated Codex/Godot implementation handoff. The implementation package must begin from the then-current origin/main, repeat the project contract fresh-read, write RED contract tests first, and update the current status owners only with executed evidence.

The user's long-horizon request to implement the full GDD is retained as a continuing objective. It does not convert future core-rule, campaign, platform, economy, or release decisions into silent changes; each successor package is selected from current canonical owners and completed through the same implementation/evidence loop.
