# 2026-08-29 Post-merge Canon and Runtime Reality Review

```yaml
baseline_project_main: 1de4ce0d1d9572056870a24d35d148472e0cb332
baseline_base_main: af870522d15abf391a0b13553de690514ac8579a
work_mode: REVIEW
skill_modes:
  - combat-implementation-handoff / implementation-contract
  - ten-paces-verification / contract-check
user_direction: "사람플레이 검수는 안해도 되니까 작업진행해"
human_playtest: NOT_RUN_DEFERRED_BY_USER_FOR_CURRENT_STAGE
product_mutation_in_this_review: NONE
result: PARTIAL
```

## Fresh-read scope

- Project `origin/main` at `1de4ce0d1d9572056870a24d35d148472e0cb332`; current completed master GDD PR #265, merged Phase 2 PR #261, and open draft PRs #199/#200 were read.
- Current Base completed `main` was `af870522d15abf391a0b13553de690514ac8579a` (PR #770). Its two-artifact profile is not auto-adopted because the project’s current repository-only contract already owns this task and Base changes require separate adoption review.
- Repository current owners, Phase 2 contract/plan/execution report, combat data, run data, AI/resolution/route/shell sources, tests, and current GitHub Issues were read. Notion was not read or written: it is migration/history input only under the current project decision.

## Corrected stale state

| finding | disposition | destination |
|---|---|---|
| Phase 2 contract still said handoff issued and `runtime_evidence: NOT_RUN`. | Corrected to the frozen specification’s implemented PR #261 post-merge state while retaining evidence ceilings. | `docs/implementation/2026-08-28_PHASE2_COMBAT_CANON_RECONCILIATION_IMPLEMENTATION_CONTRACT.md` |
| Phase 2 execution report still said branch validation pending. | Added post-merge closeout and repository-only delivery correction. | `docs/operations/2026-08-28_ISSUE258_PHASE2_COMBAT_CANON_EXECUTION_REPORT.md` |
| User-directed state still routed the project to human play before any other technical review. | Recorded the explicit deferral without converting Human evidence into PASS. | `current_user_planning_status.json`, `ACTIVE_CONTEXT.md` |
| Issue #258 and superseded duplicate visual Issue #236 remained open despite their merged successor work. | Closed; GitHub readback confirms the closeout comments and leaves only deferred Issues #54/#64 open. | GitHub Issues #258 and #236 |

## Runtime reality finding — opponent identity is only partially playable

`data/run/vertical_slice_opponents.json` gives every candidate a `signature_manual_id`, `signature_star_seed`, `basic_action_focus_ids`, `behavior_focus`, and `final_stat_total_seed`.

Actual consumers prove a smaller runtime surface:

- `vertical_slice_shell.gd` sends only the signature manual and star seed into `configure_vertical_slice_loadouts`.
- `signature_star_seed` also informs route/public technique text.
- `behavior_focus`, `basic_action_focus_ids`, and `final_stat_total_seed` are consumed by data/catalog/briefing tests only, not by runtime combat planning, combatant stats, or result balancing.
- `combat_ai_planner.gd` instead selects the single active global profile in `data/combat/combat_rival_tendency_poc.json` from public state. It does not receive a candidate profile identifier.

**Effect on player promise:** briefing can describe fifteen distinct habits, but the live opponent does not yet enact those habits or stat totals. This preserves the public-information/no-cheating boundary, but it leaves Duel 2–5’s intended archetype escalation `PARTIAL`, not balance-validated.

## Balance disposition

No candidate balance simulation was run or claimed. A simulation now would exercise a global AI and common combat-state values, not the candidate behavior/stat seeds the GDD asks players to read. That would be misleading evidence.

The next contract must first bind the already-approved candidate intent to runtime through a data-owned profile identifier and explicit stat allocation, while preserving:

- public-state-only AI; never pending player plan, hidden placement, or UI intent;
- one shared resolver, card definitions, review and retry boundaries;
- `3 → resolve → 3 → resolve → 4 → resolve`, including two-slot `[전조] → [실행]` occupancy;
- no deck/hand/draw system and no per-opponent bespoke resolver;
- deterministic seed replay so post-binding balance instrumentation can report opponent, player archetype, route choice, seed, win/loss, rounds, HP/resource loss, clash/range/interruption causes, and profile coverage.

## Current implementation feasibility

`CombatAiPlanner` is already data-driven at the profile/weight boundary and the resolver is separated from UI presentation. Adding a candidate-selected profile at that boundary, plus a deterministic scenario harness, is technically feasible without putting rule calculations into the UI. This is an implementation feasibility inference from the current source, not implementation evidence. The local Godot executable was not discoverable on this host, so no new local Godot runtime claim is made.

Official Godot documentation confirms that `--headless` is appropriate for scripted/CI validation, and GUT’s project states that 9.x targets Godot 4.x. These support the planned instrumentation method but do not replace player observation. [Godot command-line documentation](https://docs.godotengine.org/en/latest/tutorials/editor/command_line_tutorial.html) [GUT project](https://github.com/bitwes/Gut)

## Five adversarial full-scope loops

1. **Completion overclaim:** checked Phase 2 source, execution report, PR #261, and mutable state. Found stale handoff wording; corrected it without upgrading Human/device evidence.
2. **Data-to-runtime drift:** traced each opponent behavior/stat field to source consumers. Found three candidate fields without runtime consumers; recorded `PARTIAL` rather than inventing balance results.
3. **Fairness regression:** traced AI inputs. The candidate binding proposal must remain at the profile selection boundary; no player pending-plan/UI input may enter the snapshot.
4. **False validation:** distinguished historical CI success from a new local run. The absent local Godot binary blocks a fresh local runtime assertion; the review reports this as `NOT_RUN`.
5. **Scope creep:** rejected new content, visual asset, Android, save, economy, and bespoke-AI work. The only proposed next product scope is binding existing approved opponent data and then measuring it.

## Incident / Solution / Lesson

**Incident:** merged implementation status persisted as an issued/pending handoff in two project records, while their GitHub Issue stayed open.

**Solution:** corrected the repository records to a post-merge historical-contract role, kept evidence ceilings intact, and closed the stale Issues after readback.

**Lesson:** an implementation contract and its execution report require an explicit post-merge state transition; otherwise later planning can be routed by a stale “next human test” marker instead of the remaining runtime gap.

**Base promotion:** `NO_BASE_PROMOTION`. The stale fields and opponent data ownership are specific to this project’s Phase 2/first-five-duel records. Base already owns generic post-merge/readback discipline.

## Required user decision before a new product handoff

The material decision is not whether to bypass human evidence; it is whether the existing fifteen-candidate behavior/stats should become real opponent runtime behavior in the first-five-duel slice. This review leaves that scope unapproved and provides the current evidence needed for the next single Grill Me question.
