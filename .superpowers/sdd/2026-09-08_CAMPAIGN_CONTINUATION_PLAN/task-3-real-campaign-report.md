# Task 3 — actual sequential campaign report

## Result

`PASS` at the bounded headless machine-runtime evidence layer. On exact base
`ac1024e8f801a9694d364aceb542cfd6bcf00e94`, Godot 4.7.1 ran one real
`VerticalSliceRunState` from setup through ten duels and completion. Every duel
used `VerticalSliceMetricsCombatResolutionEngine`, the candidate runtime binding,
the candidate signature manual, and the bound public-state AI. Terminal results
were sent to RunState only after the resolver reduced player or enemy HP to zero.

The probe used four legal starter manuals from
`VerticalSliceStarterManualCatalog.STARTER_MANUAL_IDS`: Hua-shan Plum Blossom
Sword, Shaolin Arhat Vajra Art, Wudang Taiji Sword, and Yang Family Spear. It
loaded the actual mastery-3 techniques and selected the real Yang spear and
Hua-shan plum-blossom techniques using only own resources/loadout and public
distance. It never read locked enemy actions or future plans.

## Actual attempts and outcomes

| Duel | Candidate | First public policy | Legal retry | Committed terminal resources |
|---:|---|---|---|---|
| 1 | `slot1_dogyeom` | win, 3 bundles, HP 14 | — | HP 14, stamina 0, internal 1 |
| 2 | `slot1_yeongyo` | win, 3 bundles, HP 13 | — | HP 13, stamina 0, internal 1 |
| 3 | `slot2_mukjin` | win, 5 bundles, HP 24 | — | HP 24, stamina 4, internal 0 |
| 4 | `slot2_danso` | win, 5 bundles, HP 24 | — | HP 24, stamina 4, internal 0 |
| 5 | `slot3_seolha` | win, 3 bundles, HP 23 | — | HP 23, stamina 2, internal 0 |
| 6 | `slot3_biyeon` | win, 3 bundles, HP 19 | — | HP 19, stamina 2, internal 0 |
| 7 | `slot4_cheongheo` | win, 3 bundles, HP 19 | — | HP 19, stamina 2, internal 0 |
| 8 | `slot4_jinryeo` | win, 3 bundles, HP 30 | — | HP 30, stamina 2, internal 0 |
| 9 | `slot5_pungmok` | loss, 3 bundles, enemy HP 7 | win, 3 bundles, HP 6 | HP 6, stamina 1, internal 2 |
| 10 | `slot5_rajin` | loss, 3 bundles, enemy HP 7 | win, 3 bundles, HP 1 | HP 1, stamina 1, internal 2 |

The two losses are retained as real failures. RunState's one permitted retry
restored each real pre-battle snapshot. The deterministic retry policy used a
legal heavy attack when public distance, remaining slots, stamina, and internal
energy allowed it; it did not change enemy stats or health.

## Resource, reward, and growth continuity

Each win committed its resolver-produced player resource pairs. Each Result
selected and committed a real focused-training reward (+5 target, +3 free),
rotating across the four owned manuals. Each Jianghu step then selected one of
the three actually offered choices, preferring recovery when available. The
final retained snapshot was:

- resources: HP `1/30`, stamina `1/5`, internal `2/4`;
- reward receipts: `10`;
- free training pool: `65`;
- mastery: Hua-shan `7`, Shaolin `7`, Wudang `6`, Yang spear `6`;
- focused training totals: `15`, `15`, `10`, `10` respectively;
- duplicate transfer receipts: `0`.

All 36 committed Jianghu choices, in exact node order:

```text
J1-1 training, J1-2 event, J1-3 rest, J1-4 rest
J2-1 event,    J2-2 rest,  J2-3 rest, J2-4 rest
J3-1 rest,     J3-2 rest,  J3-3 rest, J3-4 training
J4-1 rest,     J4-2 rest,  J4-3 training, J4-4 event
J5-1 rest,     J5-2 training, J5-3 event, J5-4 rest
J6-1 training, J6-2 event, J6-3 rest, J6-4 rest
J7-1 event,    J7-2 rest,  J7-3 rest, J7-4 rest
J8-1 rest,     J8-2 rest,  J8-3 rest, J8-4 training
J9-1 rest,     J9-2 rest,  J9-3 training, J9-4 event
```

These comprise real `training`, `event`, and `rest` effects offered by the
current four-step route model. No route exists after the tenth reward.

## Verification commands and evidence

Environment: exact executable
`C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe`,
headless, exact worktree project.

```text
python tools/check_project_operating_system.py
=> project operating system: PASS

Godot --headless --path . --script res://tests/probe_ten_duel_real_resolver.gd
=> exit 0; independent baseline: duels 1-8 win, duels 9-10 loss

Godot --headless --path . --script res://tests/probe_sequential_ten_duel_campaign.gd
=> exit 0
=> complete=true, completed_duels=10, attempt_count=12
=> duel_history_count=10, reward_history_count=10, route_choice_count=36
```

The final probe prints each attempt, each post-duel resource/progression state,
all 36 route receipts, and the final JSON summary. The independent baseline is
important counterevidence: the simple policy does not silently classify the
last two losses as completion.

## Concrete defect identified, not changed

`VerticalSliceRunState.confirm_setup_loadout()` checks count, uniqueness, and
mastery, but does not verify IDs against `VerticalSliceStarterManualCatalog` or
the martial registry. During probe development, four invented non-empty IDs at
mastery 3 were accepted by RunState and produced no player martial cards. The
final probe avoids this defect by sourcing the current legal starter IDs, but
the production validation gap remains. No production edit was made because this
task owns only the new probe and report.

## Adversarial review and evidence ceiling

Five bounded review passes checked: (1) exact authority and worktree isolation,
(2) terminal HP provenance and no injected outcome, (3) public-information-only
player policy and bound AI, (4) RunState resource/reward/route continuity and
real retry semantics, and (5) final counts, unintended file scope, and evidence
overclaiming. Clean exit: no additional probe-scope defect remained.

This is automated headless machine-runtime evidence. It is not a visible UI,
Human/player UX, balance acceptance, accessibility-user, Android device,
release-performance, rights, store, or release PASS. The deterministic probe is
one policy/run seed and does not establish broad balance quality or campaign
completion rates.
