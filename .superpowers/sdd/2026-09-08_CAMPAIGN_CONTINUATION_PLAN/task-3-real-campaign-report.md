# Task 3 — Actual Sequential Campaign Probe Report

## Current result

The corrected sequential probe is now `CAMPAIGN_COMPLETED / PUBLIC_POLICY / RESOURCE_HANDOFF_VERIFIED` at the bounded headless machine-runtime layer.

The retained policy completed all ten real resolver duels with no retry, no arbitrary health or outcome injection, no opponent nerf, and no hidden enemy-action read. The probe directly applies production-equivalent RunState resource handoff and ultimate momentum reservation; it does not exercise the UI placement controller. It carried the real `VerticalSliceRunState` health/stamina/internal snapshot into every duel after `make_initial_state()` and asserted exact equality before the first resolver. It also loaded every currently unlocked manual technique into the candidate set, considered all three base ultimates only when exact own momentum and public legality allowed them, actually resolved both seven-star techniques unlocked by this route, and resolved a base ultimate in every duel.

The earlier invalid full-campaign claim remains withdrawn. The corrected legacy policy's eight-duel failure and both later nine-duel policy failures are retained below; the final PASS does not erase them.

## 작업 전 문제

Commit `f011c704b2144201ac2e9bc0330342dda31d2f1e` corrected a serious probe defect: `make_initial_state()` reset current resources to maximum, so the old apparent ten-duel completion did not exercise sequential persistence. Once the probe copied and asserted the exact RunState resources after initialization, the legacy attack policy lost Duel 9 and its single legal retry.

That corrected policy also ignored all manual techniques unlocked at mastery 7 and all base ultimates. The follow-up scope was therefore not a balance or production change. It was a one-file test-policy correction: find a deterministic, player-legitimate policy using only own resources/stats, public distance, unlocked current-manual techniques, exact own momentum, and public route/reward choices.

## Authority, scope, and feasibility

- Worktree: `C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves/.worktrees/ten-duel-campaign-20260908`
- Probe correction base: `f011c704b2144201ac2e9bc0330342dda31d2f1e`
- Final commit: `79408303` (`test(run): complete campaign with public policy`)
- Work Mode: `BUILD` then `REVIEW`.
- Skill routes: project `ten-paces-verification` in `regression`, `runtime-validation`, and `evidence-report` modes; Base `running-adversarial-review-and-refinement`; Superpowers systematic debugging, TDD, and verification-before-completion.
- Owned mutation: `tests/probe_sequential_ten_duel_campaign.gd` and this ignored execution report only.
- Production, state, controller, UI, art, live editor, processes, imports, and UIDs were not edited by this task.
- Operating-contract fallback: `python tools/check_project_operating_system.py` returned `project operating system: PASS` before route execution. The project router's historically missing named PowerShell validator was not invented.
- CURRENT_SOURCE_RELEVANCE_CHECK: `NOT_APPLICABLE`. This task tests exact local resolver/policy semantics; current local card JSON, resolver code, RunState, and executable results are authoritative. External game examples could not establish whether this exact deterministic probe completes and would add no valid evidence.
- PREWORK_BENCHMARK_REVERSE_ENGINEERING_GATE: `NOT_APPLICABLE`. No new product system, UX, content, balance, or player-facing meaning was designed; only an already authorized one-file regression probe policy was corrected.
- Feasibility: `FEASIBLE`. The installed Godot 4.7.1 console executes the real local resolver and deterministic bound AI without production mutation.

## 조사·비교 결과

The corrected legacy output and card definitions exposed four useful facts.

1. The campaign is not proven unreachable: the obsolete policy simply never selected stronger unlocked techniques or ultimates.
2. All three base ultimates can be evaluated from public own momentum and legal range/cost state; no opponent plan is needed.
3. A permanent large mastery-7 score bonus is too aggressive. Repeatedly selecting the same newly unlocked card altered resource trajectories and produced a real Duel 10 double loss.
4. A bounded “try each unlocked advanced technique once, then return to ordinary efficiency scoring” rule keeps the policy player-legitimate and prevents repeated novelty preference from dominating the campaign.

Three concrete approaches were compared:

| Approach | Result | Decision |
|---|---|---|
| Keep corrected legacy guarded pressure | 8 completed; Duel 9 and retry lost | REJECTED: ignores unlocked growth and ultimates |
| Permanently add a large bonus to every mastery-7 attack | 9 completed; Duel 10 and retry lost | REJECTED: repeated novelty preference damages the run |
| Prioritize an unlocked seven-star card only until it has appeared in public player resolution history | 10 completed, 0 retries | ADOPTED: bounded, deterministic, public, and evidence-producing |

A fourth diagnostic variant skipped `basic_guard` when stamina was 2 and Yang seven-star was unlocked. It was also rejected: Yang seven-star still did not become legal/selected in the relevant placement, Duel 9's first attempt regressed to a loss, and Duel 10 still lost its retry with enemy HP 2.

## 채택한 구조와 이유

The retained probe now:

1. Configures the actual player manuals and current mastery before every duel.
2. Captures `engine.get_player_martial_card_ids()` in every terminal attempt as the public available-technique evidence.
3. Preserves the post-initialization RunState resource application and exact equality assertion before every first resolver.
4. Builds actions only from the player's current stamina/internal/momentum, public player/enemy tiles and distance, the current bundle's open action slots, and public card definitions.
5. Considers every current manual attack returned by the engine, all three base ultimates, and the basic attacks.
6. Requires exact full own momentum before an ultimate is legal, then applies the same reservation represented by the real UI flow.
7. Records player card IDs only from `public_resolution_history`.
8. Gives an as-yet-unseen mastery-7 card a one-time public novelty priority. After it actually resolves, the card returns to the normal damage/slot/resource score.
9. Uses a normal `basic_guard` policy on the first attempt and the existing legitimate stance+evade response combo on the one permitted retry. The retained final run did not need that retry.
10. Uses predetermined legitimate focused rewards: Shaolin for Duels 1–4, Yang for Duels 5–8, and Mount Hua for Duels 9–10. Jianghu choices are selected only from the currently offered public options.

The policy never reads the locked enemy bundle, enemy pending placements, hidden action IDs, unrevealed intent, or future outcome. The only enemy field used by action placement is the public tile, to derive public distance and direction.

## RED and rejected-attempt evidence

All commands used the same installed executable:

```powershell
& 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s res://tests/probe_sequential_ten_duel_campaign.gd
```

### Resource-handoff RED retained from the prior correction

Before the post-init resource application was added, the new exact equality assertion exited 1 before Duel 2's first resolver:

```text
SEQUENTIAL_CAMPAIGN_FAIL: duel 2 policy 0 initial engine resources must exactly match RunState before the first resolver
```

### Corrected legacy policy — 8/10, exit 1

- Duels 1–8: wins.
- Duel 9 first attempt: loss in 3 bundles, enemy HP 7.
- Duel 9 legal retry: loss in 5 bundles, enemy HP 2.
- Summary: `complete=false`, `completed_duels=8`, `attempt_count=10`, `duel_history_count=8`, `reward_history_count=8`, `route_choice_count=32`.
- Exact resource-handoff assertions passed on all 10 resolver entries.

### First public candidate/ultimate policy without actual seven-star use — 10/10, exit 0 but not retained

- Ten wins, no retry.
- A base ultimate resolved once per duel.
- Summary: `complete=true`, `completed_duels=10`, `attempt_count=10`, `duel_history_count=10`, `reward_history_count=10`, `route_choice_count=36`.
- Final resources: HP `8/30`, stamina `1/5`, internal `2/4`.
- Rejected after adversarial review because seven-star cards were loaded and considered but never actually selected; the evidence did not close the reported policy gap.

### Permanent mastery-7 priority — 9/10, exit 1

- Duels 1–9: wins; Shaolin seven-star resolved in Duels 5, 6, and 8.
- Duel 10 first attempt: loss in 2 bundles, enemy HP 13.
- Duel 10 legal retry: loss in 3 bundles, enemy HP 13.
- Summary: `complete=false`, `completed_duels=9`, `attempt_count=11`, `duel_history_count=9`, `reward_history_count=9`, `route_choice_count=36`.
- No resource-handoff assertion failed.

### Low-stamina guard-skip diagnostic — 9/10, exit 1

- Duel 9 first attempt regressed to a loss in 5 bundles, enemy HP 20.
- Duel 9's one legal retry won in 4 bundles with player HP 22.
- Duel 10 first attempt lost in 5 bundles, enemy HP 14.
- Duel 10's one legal retry lost in 5 bundles, enemy HP 2.
- Summary: `complete=false`, `completed_duels=9`, `attempt_count=12`, `duel_history_count=9`, `reward_history_count=9`, `route_choice_count=36`.
- This variant was removed completely before the retained run.

## 실제 구현 및 GREEN result

The retained one-time public novelty policy completed the campaign with exit 0:

| Duel | Candidate | Outcome | Bundles | Player HP | Actual notable public cards |
|---:|---|---|---:|---:|---|
| 1 | `slot1_dogyeom` | win | 4 | 21 | `ultimate_void_sword_qi` |
| 2 | `slot1_yeongyo` | win | 5 | 17 | `ultimate_cleave_peak` |
| 3 | `slot2_mukjin` | win | 4 | 20 | `ultimate_void_sword_qi` |
| 4 | `slot2_danso` | win | 4 | 20 | `ultimate_void_sword_qi` |
| 5 | `slot3_seolha` | win | 5 | 9 | `shaolin_arhat_vajra_art_star7`, `ultimate_void_sword_qi` |
| 6 | `slot3_biyeon` | win | 5 | 11 | Mount Hua star 3, `ultimate_void_sword_qi` |
| 7 | `slot4_cheongheo` | win | 5 | 14 | `ultimate_void_sword_qi` |
| 8 | `slot4_jinryeo` | win | 6 | 19 | Yang star 7, Mount Hua star 3, `ultimate_void_sword_qi` |
| 9 | `slot5_pungmok` | win | 3 | 17 | `ultimate_void_sword_qi` |
| 10 | `slot5_rajin` | win | 3 | 9 | `ultimate_void_sword_qi` |

Final summary:

```text
complete=true
completed_duels=10
attempt_count=10
duel_history_count=10
reward_history_count=10
route_choice_count=36
ultimate_use_count=10
final resources=HP 9/30, stamina 1/5, internal 2/4
final mastery=Mount Hua 6, Shaolin 8, Wudang 3, Yang 8
```

The captured available-card arrays prove that Shaolin seven-star was loaded from Duel 4 onward and Yang seven-star from Duel 8 onward. Duel-wide public action sets prove Shaolin seven-star resolved in Duel 5 and Yang seven-star resolved in Duel 8. The shorter terminal `player_card_counts` view omitted the earlier Yang action, which is why the retained probe now emits the duel-wide set separately.

## 사용 예 및 기대효과

- If `make_initial_state()` again overwrites carried current resources without the test reapplying the exact RunState snapshot, the pre-resolver equality assertion fails immediately.
- If mastery growth stops exposing a seven-star card to the combat engine, the per-attempt `available_player_card_ids` evidence changes visibly.
- If the policy regresses to ignoring every unlocked seven-star technique, the explicit actual-resolution assertion fails.
- If own momentum no longer enables a legitimate base ultimate, the actual ultimate-use assertion fails.
- The probe demonstrates reachability under one deterministic public policy; it does not claim every policy, seed, player, or balance path will succeed.

## Verification evidence

- Project operating-contract fallback: PASS.
- Retained focused Godot campaign probe: exit 0.
- Repeatability rerun: PASS; two consecutive retained-policy runs exited 0 with the same ten outcomes, Duel 10 HP `9/30`, 10 ultimate uses, both unlocked seven-star IDs, and the same final resources.
- Post-commit exact-HEAD run at `79408303`: exit 0, `complete=true`, 10 completed duels, 10 attempts, 10 rewards, 36 route choices, 10 ultimate uses, both seven-star IDs observed, final HP/stamina/internal `9/30`, `1/5`, `2/4`.
- Exact RunState resource handoff: PASS before the first resolver on all 10 retained attempts.
- Actual unlocked seven-star resolution: PASS, Shaolin seven-star in Duel 5 and Yang seven-star in Duel 8.
- Actual legal base ultimate resolution: PASS, 10 total.
- Ten distinct sequential terminal successes: PASS.
- Reward history: 10; route history: 36; no post-final route.
- Adjacent independent real-resolver probe: exit 0; its expected isolated-policy outcomes remained wins for Duels 1–8 and losses for Duels 9–10. This is not sequential completion evidence.
- Adjacent synthetic campaign-state verifier: exit 0 with `TEN_DUEL_CAMPAIGN_STATE_OK`; it remains explicitly labeled synthetic.
- Final project operating-contract fallback: PASS.
- `git diff --check -- tests/probe_sequential_ten_duel_campaign.gd`: PASS (line-ending conversion warning only; no whitespace error).
- Owned diff scope: exactly `tests/probe_sequential_ten_duel_campaign.gd`, 171 insertions and 25 deletions versus the corrected legacy policy.
- Windows visible, Human/player UX, accessibility user, Android actual device, release performance, remote CI, PR/merge, and post-merge main readback: `NOT_RUN`.

## Five full-scope adversarial review loops

1. **Failure provenance and alternatives:** retained the 8/10 corrected legacy failure, compared no-priority, permanent-priority, and low-stamina variants, and rejected variants whose apparent progress did not meet the actual advanced-technique evidence or campaign-completion requirement.
2. **Information boundary and legitimacy:** reviewed every policy state read. Own resources/momentum, public tiles/distance, public resolution history, public unlock IDs, public route offers, and predetermined reward choices are allowed; no locked enemy action data is read.
3. **Sequential-state integrity and retry ceiling:** confirmed the exact post-init RunState equality assertion remains before AI/resolver entry for every attempt. Only `retry_failed_duel()` can open a retry, and no code permits a second retry. The final run used zero retries.
4. **Coverage and false-positive resistance:** added terminal output for available manual card IDs, accumulated public card IDs and ultimate count, plus explicit assertions that an unlocked seven-star technique and a legal base ultimate actually resolved. This prevents a future 10-win result from silently restoring the original policy gap.
5. **Scope, consumers, and long-term fit:** limited the retained mutation to the standalone probe. No production balance, save schema, run state, UI/controller, catalog, route model, assets, or imports were changed. The policy remains a transparent diagnostic rather than a product AI or balance authority.

`BETTER_ALTERNATIVE_SEARCH`: a full planner/search agent could find more winning paths but would enlarge the test, risk hidden-state leakage, and obscure reproducibility. The once-per-publicly-observed advanced-card priority is smaller and sufficient. `LONG_TERM_PLAN_FIT_RECHECK`: retained because it strengthens campaign reachability evidence without changing game meaning or production behavior.

## 자동화·학습 반영

- The report now separates resource-handoff validity, policy reachability, actual advanced-card use, actual ultimate use, route/reward history, and evidence ceiling.
- Failed policy variants are recorded as reusable counterexamples rather than discarded from the narrative.
- No Base or memory update was authorized or performed.

## 미검증·남은 위험

- This is one deterministic headless run at the current local data/code revision. It proves existence of a reachable public-policy path, not global balance, seed coverage, or human playability.
- The final route unlocked two seven-star attacks and both actually resolved. It did not unlock any star-10 manual ultimate, so no claim is made about those cards in this run.
- The fixed route preference is legitimate but not globally optimal, and free-training accumulation is not automatically spent by this probe.
- Base ultimate reservation is mirrored in test-local policy state because the real UI normally reserves momentum before resolver entry. A future production reservation API change may require probe alignment.
- The policy records only player actions from `public_resolution_history`; it intentionally does not learn from enemy hidden plans, even on retry.
- Visible UI, Human/player UX, accessibility, Android device, performance, release, remote CI, merge, and post-merge readback remain `NOT_RUN`.
