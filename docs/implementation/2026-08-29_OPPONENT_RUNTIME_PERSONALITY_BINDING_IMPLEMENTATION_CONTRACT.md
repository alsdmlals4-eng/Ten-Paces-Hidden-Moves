# First-Five Opponent Runtime Personality Binding — Implementation Contract

```yaml
contract_id: TEN-IMP-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01
status: USER_APPROVED_READY_FOR_CODEX_GODOT_HANDOFF
work_mode: BUILD
approval_source: "user explicit: 승인"
implementation_issue: 267
planning_pr: 268
design_decision: TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01
design_spec: docs/superpowers/specs/2026-08-29-opponent-runtime-personality-binding-design.md
implementation_plan: docs/superpowers/plans/2026-08-29-opponent-runtime-personality-binding.md
runtime_mutation_in_this_contract: AUTHORIZED_ON_FRESH_ISOLATED_ISSUE267_BRANCH_ONLY
automated_evidence: NOT_RUN
godot_runtime_evidence: NOT_RUN
windows_visible_evidence: NOT_RUN
human_player_evidence: NOT_RUN_DEFERRED_BY_USER_FOR_CURRENT_STAGE
accessibility_user_evidence: NOT_RUN
android_actual_device_evidence: NOT_RUN
release_performance_evidence: NOT_RUN
```

## 1. Goal and player-visible promise

The locked opponent must make the Briefing's readable habit materially observable without becoming an answer key:

```text
public rumor / Route clue
→ player places a falsifiable 3/3/4 hypothesis
→ 행동계획 실행
→ the locked enemy's archetype, focus order, and seeded stats operate from public state
→ distance / 합 / defense / interruption / sequence result becomes visible in combat and Review
→ player revises the next hypothesis or one same-seed retry
```

The player is not promised a deterministic counter. They are promised a broad tendency with a public counterexample: success or failure is explained by resolved public state, not a hidden AI read of the current player plan.

## 2. Binding authority and protected invariants

| Subject | Owner | Implementation disposition |
| --- | --- | --- |
| Candidate identity, manual, mastery, focus order, total seed | `data/run/vertical_slice_opponents.json` | Retain all existing values; add one valid `runtime_archetype_id` per candidate. |
| Archetype scores, movement, history, sequence cap, stat weights | New `data/run/vertical_slice_opponent_archetypes.json` | Five data-owned reusable profiles; no candidate-specific GDScript branch. |
| Candidate-to-runtime conversion | New `VerticalSliceOpponentRuntimeBinding` | Validate before bridge/engine mutation; deep-copy output. |
| Enemy stats and planner instance | Metrics resolution engine | Apply to one engine instance only; retry rebuild receives the same locked binding. |
| Legal action, costs, slots, resolution, history | `CombatResolutionEngine` | Preserve one shared resolver; add only bounded resolved public-history projection. |
| Planning/AI | `CombatAiPlanner` | Optional per-instance binding takes precedence; unbound consumers retain global default profile. |
| Player-facing behavior | `AGENTS.md`, `docs/02_COMBAT_RULES.md` | Preserve public distance2, 3/3/4, two-slot `[전조] → [실행]`, and **`행동계획 실행`** semantics. |

Non-negotiable exclusions: decks/hands/draw/equip caps, enemy-only manuals/techniques, candidate-specific code, economy, profile/save persistence, route changes, image/audio work, Android redesign, release/store work, balance PASS, and Human Player Experience PASS.

## 3. Exact runtime data contract

`data/run/vertical_slice_opponent_archetypes.json` must contain:

```json
{
  "schema_version": 1,
  "stat_order": ["external", "constitution", "agility", "internal_power", "insight"],
  "stat_weight_total": 20,
  "profiles": []
}
```

Every profile contains `id`, `score_weights`, `max_actions_per_bundle`, `movement_policy`, `history_policy`, and integer `stat_weights`. All profile IDs and values are fixed here:

| ID | Max actions | Movement/history | Score weights `approach / quick / heavy / low-health / recover / ultimate` | Stat weights `외공 / 근골 / 신법 / 내공 / 심안` |
| --- | ---: | --- | --- | --- |
| `initiative_exchange` | 1 | approach / none | `1.0 / 1.5 / 0.4 / 1.0 / 0.6 / 1.0` | `5 / 4 / 5 / 3 / 3` |
| `stabilize_then_pressure` | 1 | approach / none | `0.4 / 0.5 / 1.2 / 2.0 / 1.8 / 1.2` | `4 / 6 / 3 / 4 / 3` |
| `range_control` | 1 | preferred public distance 3 / none | `0.8 / 0.4 / 1.0 / 1.0 / 1.0 / 1.0` | `3 / 3 / 6 / 5 / 3` |
| `public_history_counter` | 1 | hold-or-approach / two newest resolved player cards | `0.4 / 0.6 / 0.5 / 1.7 / 1.2 / 1.0` | `3 / 3 / 4 / 4 / 6` |
| `sequence_pressure` | 2 | approach / own planned cards only | `1.0 / 1.1 / 1.0 / 0.6 / 0.8 / 1.4` | `5 / 3 / 4 / 5 / 3` |

All 15 candidate assignments are fixed:

| Duel slot | Candidates | Archetype |
| --- | --- | --- |
| 1 | `slot1_yeongyo`, `slot1_chaeryeong` | `initiative_exchange` |
| 1 | `slot1_dogyeom` | `stabilize_then_pressure` |
| 2 | `slot2_mukjin`, `slot2_seokmu`, `slot2_danso` | `stabilize_then_pressure` |
| 3 | `slot3_seolha`, `slot3_uram`, `slot3_biyeon` | `range_control` |
| 4 | `slot4_cheongheo`, `slot4_damwol`, `slot4_jinryeo` | `public_history_counter` |
| 5 | `slot5_jeogu`, `slot5_pungmok`, `slot5_rajin` | `sequence_pressure` |

The first, second, and third legal `basic_action_focus_ids` add respectively `+1.20`, `+0.60`, and `+0.30` to the eligible candidate score. A focus never makes an illegal card legal.

For `final_stat_total_seed`, calculate `floor(total * weight / 20)` per canonical stat; distribute remaining points by largest fractional remainder; break equal remainders in canonical stat order. Reject non-positive weights, weights not totaling 20, any result below one, invalid profile/focus, or a final sum different from the seed.

## 4. Required implementation map

| Layer | Required files | Required result |
| --- | --- | --- |
| Data and adapter | New archetype JSON and binding GDScript; candidate JSON; opponent catalog | Validated 15→5 mapping and deterministic stats before runtime mutation. |
| Shell and bridge | `vertical_slice_shell.gd`, `vertical_slice_combat_bridge.gd`, metrics engine | Pass exactly one valid binding to one fresh combat engine and snapshot it only for tests. |
| Shared resolver | `combat_resolution_engine.gd` | Append max six resolved execution-only public records after bundle completion. |
| Planner | `combat_ai_planner.gd` | Profile precedence, public-only history, focus bonus, retreat/approach, max-two non-overlapping schedule. |
| Tests | New binding verifier/static contract; existing catalog, setup, AI, resolution, workflow tests | RED before behavior changes and evidence for data, isolation, fairness, slots, history, and default regression. |
| Current canon | combat rules/test/architecture/route docs, Active Context, planning status, operation report | Record actual implementation/evidence only after exact-head validation. |

No Scene, Resource, asset, or project setting change is authorized. If an actual consumer cannot receive the binding through this map, stop implementation and report `CONTRACT_DIVERGENCE_REVIEW_REQUIRED`.

## 5. State, fairness, and scheduling contract

`VerticalSliceOpponentRuntimeBinding.build(candidate)` returns only:

```yaml
valid:
candidate_id:
archetype_id:
ai_profile:
basic_action_focus_ids:
stats:
final_stat_total_seed:
```

The bridge configuration is:

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
```

`VerticalSliceMetricsCombatResolutionEngine.configure_enemy_runtime_binding(binding)` validates/deep-copies before `make_initial_state`, then configures only its own `ai_planner`. A rejected binding must leave the existing bridge and engine state unchanged. A later combat starts with no previous binding.

After a completed bundle, resolver state owns at most six oldest-to-newest records with exactly `round_number`, `bundle_index`, `actor`, `card_id`, `category`, and `outcome`. `[전조]` preparation records, uncommitted plans, targets/directions, UI metadata, profile weights, and observation-answer data are excluded. Only `public_history_counter` reads the newest two player records in the next bundle.

The planner must preserve the current unbound global default. A bound planner can choose only legal cards supplied by the existing enemy-card pool. It returns actions anchored within the current 3/3/4 bundle. A two-slot action reserves both real slots; a sequence profile may add one non-duplicate legal action only if remaining slots permit it. It cannot predict resolution, replan a lock, or read player UI/private data. Trace can include archetype ID, public-history count, first selected ID, and scheduled public card IDs, but never focus lists, weights, private data, or UI intent.

## 6. Acceptance criteria

1. Five valid data profiles and 15 valid candidate mappings load; every stat allocation is deterministic and sums to the original seed.
2. Invalid binding data fails before bridge/engine mutation; two combat engines cannot leak candidate binding/state into one another.
3. Enemy initial stats and AI profile come from the locked candidate; default Combat Preview keeps its existing global profile without a binding.
4. AI action/trace is unchanged when only uncommitted player plans, target/direction, pointer/hover/focus, or observation-answer keys change.
5. Range control retreats below public distance 3 and approaches above it through shared legal movement; no off-board/crossing shortcut exists.
6. Counter behavior receives only post-resolution public records; sequence scheduling uses at most two non-overlapping actions and honors the actual 3/3/4 slots.
7. Existing manual-pool, candidate selection, Briefing secrecy, retry, route, action-selection, resolution, and default rival tests remain green.
8. Automated/Godot evidence is recorded separately from unrun Windows-visible, Human, accessibility, Android-device, and release-performance evidence.

## 7. Required validation order

```text
failing focused test
→ minimal code/data for one task
→ focused GDScript verifier
→ affected existing GDScript regressions
→ Python static/canonical/reference checks
→ exact-head Godot parse/headless workflow
→ changed-file baseline review
→ evidence report
```

The implementation executor must record exact commands, exit status, affected test counts, commit SHA, and failure output. A failing command stops progression to the next task until its root cause is identified and the smallest in-scope fix is tested. Windows-visible, Human, accessibility-user, Android-device, and release-performance checks remain `NOT_RUN` unless actually performed.

## 8. Delivery boundary

- This contract is the one approved scope for GitHub Issue #267.
- The executor works on a new isolated `codex/` Issue #267 branch after fresh-reading merged `main`; it does not take over PRs #199/#200 or this planning PR.
- No direct main push, force push, blind reset/clean/rebase, or bypass is allowed.
- One implementation PR carries product changes and exact-head evidence. Planning PR #268 only records the approved contract/plan/handoff.
- The implementation report records any Incident / Solution / Lesson and evaluates Base promotion. The expected disposition is `NO_BASE_PROMOTION` unless a new generic lesson is evidenced.
- Notion and Sheets are not delivery targets; the repository is the current canonical workspace.
