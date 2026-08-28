# 2026-08-29 Opponent Runtime Personality Binding Design Review

```yaml
baseline_project_main: c1fb43d92956e2bf7d104f59039728713a8e74af
fresh_base_main: 2e6fa14a93ffba177b22fd7ff21e2f654ea15bb0
work_mode: PLAN
skill_modes:
  - ten-paces-game-design / poc-contract
  - combat-implementation-handoff / implementation-contract
  - ten-paces-verification / contract-check
decision: TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01
issue: 267
product_mutation: NONE
result: USER_APPROVED_IMPLEMENTATION_PLAN_AND_HANDOFF_REQUIRED
human_playtest: NOT_RUN_DEFERRED_BY_USER_FOR_CURRENT_STAGE
```

## Fresh-read scope

- Project `origin/main` at `c1fb43d92956e2bf7d104f59039728713a8e74af`, open draft PRs #199 and #200, open deferred Issues #54 and #64, and newly created implementation Issue #267 were read. PRs #199/#200 remain read-only.
- Current Base `main` was `2e6fa14a93ffba177b22fd7ff21e2f654ea15bb0`. It was observed as reuse/process evidence only; the project repository-only contract remains current and no Base adoption was made.
- Current project owners, candidate data, opponent catalog, shell, bridge, metrics engine, combat engine, AI planner, setup/candidate/AI verification, GDD content, test checklist, and current mutable state were read.
- Notion and Google Sheets were not used as current authority. Notion is history/migration input and Sheets remain migration-only.

## Actual implementation findings

| Statement | Evidence | Classification |
| --- | --- | --- |
| Candidate signature manual and star are runtime-bound. | `vertical_slice_shell.gd` sends them to `configure_vertical_slice_loadouts`; bridge configures the enemy loadout. | `CURRENT_IMPLEMENTED` |
| Candidate basic-action focus, behavior focus, and final-stat total are not runtime-bound. | They occur in candidate data/catalog/briefing tests, but the bridge does not receive them and `make_initial_state` uses HUD defaults. | `CURRENT_PARTIAL` |
| AI is currently per-engine but uses one global active profile. | `CombatAiPlanner._active_profile()` reads `active_rival_id` from `combat_rival_tendency_poc.json`. | `CURRENT_PARTIAL` |
| Range candidates cannot currently retreat or hold a distance. | AI move target is always calculated toward the player in `_build_action`. | `IMPLEMENTATION_GAP` |
| Slot 5 sequence candidates cannot currently express a multi-action bundle. | `build_bundle_actions` returns one selected action even when the current bundle has three or four slots. | `IMPLEMENTATION_GAP` |
| Slot 4 public-history candidates cannot currently inspect resolved repetition. | AI snapshot has no resolver-maintained public action history. | `IMPLEMENTATION_GAP` |

## Corrected stale canon

- `docs/02_COMBAT_RULES.md` section 17 was labelled as a current main gap despite containing a pre-Phase-2 snapshot. It is now explicitly historical and its Phase-2 subsection is labelled `IMPLEMENTED_MERGED_PR_261`.
- `docs/03_CONTENT_CATALOG.md` now marks its 4/7-distance3 T0 entry as compatibility-only, not the first-five product runtime.
- `docs/08_TEST_CHECKLIST.md` now checks the current 4/6 internal start and public opening distance2 rather than stale 4/7.
- `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md` now points the unbound candidate behavior/stats to this current Decision and its contract-review status.

## Adversarial loops

1. **Flavor-only opponent test:** rejected a contract that merely passes `behavior_focus` through UI text. Every executable distinction must reach AI candidate scoring, movement/bundle scheduling, or enemy stats.
2. **Cheating AI test:** rejected any public-history shortcut that exposes uncommitted player data. History is appended after resolver completion only, and privacy mutation tests are mandatory.
3. **False range/sequence test:** rejected a five-profile label set without retreat movement or multi-action scheduling because it would not enact Slot 3/5 promises.
4. **Global leakage test:** rejected changing `active_rival_id` per candidate. The selected binding is per combat engine and must be cleared/isolated across combat instances.
5. **False balance/pass test:** rejected balance simulation before binding, and rejected the use of automated headless success as Human fun, Windows-visible, accessibility, Android, or performance evidence.
6. **Hidden-trace exposure test:** corrected the draft's proposal to include `basic_action_focus_ids` in the AI trace because the existing privacy regression treats `focus` fields as forbidden. Focus influence is tested by controlled scoring outcomes, while the trace carries only archetype identity, public-history count, and scheduled public card IDs.

## Feasibility and research

The repository already loads JSON to Godot Dictionaries and creates an independent `CombatAiPlanner` per resolver, so a validated data-owned binding at the bridge/engine boundary is feasible without a plugin or a UI rule owner. Official Godot documentation confirms JSON parse/type behavior and headless scripted execution, which supports the proposed deterministic regression route. It does not substitute for Human evidence. [Godot JSON documentation](https://docs.godotengine.org/en/stable/classes/class_json.html) [Godot command-line documentation](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)

## Incident / Solution / Lesson

**Incident:** Phase-2 implementation made several current product rules real, but active-looking GDD/checklist text still described the older 4/7, eight-action path as current. At the same time, the first-five candidate data presented personality/stat fields that did not reach combat.

**Solution:** separated historical T0 snapshots from the current first-five runtime binding, created Issue #267, and wrote a data-owned five-archetype contract that explicitly covers the missing retreat, public-history, and sequence boundaries.

**Lesson:** content descriptors become a player-facing promise only after their runtime consumer is verified. A candidate catalog test that validates IDs is insufficient when the field has no consumer.

**Base promotion:** `NO_BASE_PROMOTION`. The stale identifiers, 15-candidate content schema, and combat boundaries are project-specific; Base already owns the generic fresh-read, adversarial review, and post-merge discipline.

## Evidence ceiling and next action

The user approved the exact contract with `승인` on 2026-08-29 KST. No product files or assets changed and no new runtime, balance, Windows-visible, accessibility-user, Android-device, release-performance, or Human-play claim was made. The next action is the task-by-task implementation plan and one `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF` for Issue #267; only the Codex executor's isolated implementation and evidence can change runtime status.

## Approval-plan validation and residual suite boundary

- The approval-plan package passed the current discovery, adversarial-research, integrated-work, project-governance, canonical-combat, operating-system, reference-freshness, skill-integrity, JSON, plan-placeholder, and diff checks. The revised PC-first state regression also passed after its stale `next_phase` expectation was synchronized to the approved Issue #267 handoff.
- A full `python -m unittest discover -s tests -p 'test_*.py' -v` run executed 410 tests and remained non-green with nine failures and one error outside this change's diff: the Actions budget fallback test expects an older GitHub Actions state, the v4.5-r2 history checksum test no longer matches its preserved source, and the resource-saturation validator still requires a retired Project-Notion current-truth token. These files were untouched by this planning branch; their failures are `PREEXISTING_UNRELATED_FULL_SUITE_DEBT`, not evidence for Issue #267 implementation.
- The Issue #267 executor must run its focused/adjacent tests and exact required PR checks. It must not report a repository-wide all-green suite unless the above independent debt has separately been reconciled.
