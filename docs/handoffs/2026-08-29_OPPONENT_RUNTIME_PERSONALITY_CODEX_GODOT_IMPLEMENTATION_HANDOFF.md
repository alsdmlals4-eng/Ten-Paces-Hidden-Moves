# CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF — Issue #267

```yaml
handoff_id: TEN-HANDOFF-20260829-OPPONENT-RUNTIME-PERSONALITY-01
status: USER_APPROVED_READY_AFTER_PLANNING_PR268_MAIN_READBACK
issue: 267
contract: TEN-IMP-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01
plan: docs/superpowers/plans/2026-08-29-opponent-runtime-personality-binding.md
work_mode: BUILD
execution_environment: Codex isolated issue branch
product_mutation_authority: ISSUE267_SCOPE_ONLY
human_playtest: NOT_RUN_DEFERRED_BY_USER_FOR_CURRENT_STAGE
```

## Required fresh-read before any implementation

1. Fetch Project GitHub `main`, Issue #267, and all open/draft PR metadata. Treat PRs #199 and #200 as read-only.
2. Confirm this handoff, its implementation contract, its plan, `ACTIVE_CONTEXT.md`, planning status JSON, `docs/02_COMBAT_RULES.md`, `docs/08_TEST_CHECKLIST.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`, and `data/run/vertical_slice_opponents.json` are on current `main`.
3. Read actual `vertical_slice_shell`, bridge, metrics engine, opponent catalog, resolver, ten-manual resolver, AI planner, and the existing candidate/setup/AI/resolution verifiers before deciding exact edits.
4. Create an isolated `codex/issue-267-opponent-runtime-personality-binding` branch from that fresh `main`. Do not work in the planning PR #268 branch.
5. If any fresh current owner conflicts with this contract, stop and return `CONTRACT_DIVERGENCE_REVIEW_REQUIRED` with file/line evidence. Do not silently reinterpret the plan.

## Codex goal

`/goal Implement GitHub Issue #267 exactly as specified.`

Implement the approved reusable five-archetype binding for the first-five opponent catalog. Candidate identity, current manuals/mastery, shared resolver, public opening distance2, 3/3/4 slot rhythm, two-slot `[전조] → [실행]`, `행동계획 실행`, public-state-only AI, shared player/AI martial-card pool, and the existing same-seed retry boundary are protected. Build only the data adapter, per-combat binding, bounded resolved public history, legal retreat/approach behavior, ordered focus bonus, and maximum-two-action slot scheduler described by the contract and plan.

Do not add enemy-only skills, a deck/hand/draw layer, candidate-specific code branches, new economy/persistence/Route/features, generated assets, Scene work, UI redesign, Android work, or claims about Human/player/device/release evidence.

## Required implementation contract

- Begin each code unit with its failing focused regression and capture the failure before the minimal fix.
- Add `data/run/vertical_slice_opponent_archetypes.json` and `VerticalSliceOpponentRuntimeBinding`; add `runtime_archetype_id` to exactly the existing 15 candidates.
- Bind data through shell → bridge → `VerticalSliceMetricsCombatResolutionEngine` → its planner; invalid binding must not mutate combat state.
- Stat allocation must be deterministic, canonical-order tie-broken, and exactly equal each candidate's existing total seed.
- Resolver public history is post-resolution, execution-only, max six, and contains only the six approved public fields.
- Planner binding is optional/per-instance. Unbound default rival behavior remains regression-tested; bound AI reads no uncommitted player placement, target/direction, pointer/hover/focus/UI intent, or observation answer.
- Range control uses the shared legal move target path. Sequence pressure schedules zero, one, or two non-overlapping legal actions without crossing the active 3/3/4 bundle. A two-slot action consumes two real adjacent slots.
- Internal focus lists/weights do not enter player-facing text or AI trace. Prove focus effects through controlled scoring assertions instead.

## Required verification and completion report

Run the exact focused and adjacent checks from the implementation plan, then project operating-system, canonical-reference, skill-integrity, Python discovery/governance, Godot headless/parse, and baseline-diff checks on the final implementation head. Report:

```yaml
baseline_branch:
baseline_sha:
work_branch:
issue:
approved_scope:
changed_files:
untouched_consumers:
red_green_evidence:
static_evidence:
godot_runtime_evidence:
windows_visible_evidence: NOT_RUN unless actually executed
human_player_evidence: NOT_RUN_DEFERRED_BY_USER_FOR_CURRENT_STAGE
accessibility_user_evidence: NOT_RUN unless actually executed
android_actual_device_evidence: NOT_RUN unless actually executed
release_performance_evidence: NOT_RUN unless actually executed
counterexamples:
remaining_risks:
incident_solution_lesson:
base_promotion_disposition:
result:
```

Create one implementation PR for Issue #267, read its exact-head remote checks, do not merge it without the applicable review/check policy, and post-merge fresh-read `main` before reporting any completed runtime evidence.
