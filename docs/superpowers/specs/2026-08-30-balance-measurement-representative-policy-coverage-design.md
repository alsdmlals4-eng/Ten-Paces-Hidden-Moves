# Balance Measurement Representative-Policy Coverage Design

**Decision:** `TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01`
**Baseline:** `e1aad779fced8ac54da52e03686fe51abb7fb34d`
**Mode:** `BUILD` after red regression is observed
**Scope:** validation-only, resolver-backed, `opening_no_route`

## Target outcome

```text
15 current candidates
× 15 legal four-of-six starter loadouts
× 6 fixed public policies
× 5 fixed AI seeds
= 6,750 deterministic, resolver-derived report rows
```

The successor is not an auto-balancer and does not add a player-facing strategy system. It only makes the measurement set match the six archetypes already named by the review-ready contract.

## Public-policy contract

Every policy receives only the existing public projection:

```text
player tile, enemy tile, public distance/direction,
player public stamina/internal/momentum,
public resolution history, public card definitions,
active 3/3/4 bundle bounds, player martial IDs
```

It must not inspect locked enemy action, uncommitted player placement, planner trace/weights, target preview/pointer, observation answer, Scene/UI state, or save-only data.

| Policy | Deterministic public order | Intentional non-goal |
| --- | --- | --- |
| `public_distance_control` | reachable martial attack with greatest `range.max`, then reachable basic attack, then public move if distance > 0, then guard | retreat mechanics or exact opponent-intent counterplay |
| `public_mixed_exchange` | reachable ultimate at full momentum; recover when resources are below maximum and public history has a completed exchange; reachable martial/basic attack; public move; guard | a human/optimal policy, random sampling, hidden-state reaction |

Ties resolve by sorted card ID. A card must fit the current bundle and be affordable before it is selected. A terminal fallback returns `[]` only when there is no legal public action, preserving fail-closed behavior.

## Report contract

The schema 3 public row remains:

```text
scenario_id, candidate_id, starter_loadout_id, player_policy_id,
ai_decision_seed, route_context_id, outcome, bundles_resolved,
battle_metrics, policy_selection_counts
```

`policy_selection_counts` has exactly six non-negative aggregate integers:

```text
attack, move, guard, evade, recovery, ultimate
```

No per-card selection, target, opponent plan, AI trace, weight, preview, pointer, focus, or observation field may be emitted.

## RED → GREEN checks

1. Make the public-policy verifier expect six IDs, then observe the baseline fail.
2. Add focused public states that prove distance-control picks a farther-reaching public attack and mixed-exchange selects legal public recovery/ultimate fallback without private-state dependence.
3. Make instrumentation/report tests and Python checker expect schema 3, six aggregate keys, and 6,750 rows; observe baseline fail.
4. Implement the minimal validation-only policy/matrix/report updates until the focused Godot tests pass.
5. Run the full existing test suite and two independent full Godot reports. The report checker must verify byte equality, exact schema, exact coverage, public-field boundary, and actual category coverage.

## Files expected to change

- `data/validation/vertical_slice_balance_instrumentation_matrix.json`
- `src/validation/vertical_slice_balance_public_policy.gd`
- `src/validation/vertical_slice_balance_instrumentation.gd`
- `src/validation/vertical_slice_balance_report_runner.gd`
- `tests/verify_vertical_slice_balance_public_policy.gd`
- `tests/verify_vertical_slice_balance_instrumentation.gd`
- `tests/verify_vertical_slice_balance_report_runner.gd`
- `tests/check_vertical_slice_balance_report.py`
- Decision/status/execution records and the one-time protected-change approval record required for the exact PR

No player-facing Scene, asset, combat card, candidate/profile, shared resolver, save, route, or platform file belongs to this change.

## Adversarial review plan

1. **Canonical scope:** confirm the two missing archetypes against the review-ready owner and retain every current policy.
2. **Input fairness:** inject private sentinels and compare placements byte-for-byte.
3. **Consumer boundary:** reject any diff outside the validation/test/document/approval surface.
4. **Measurement semantics:** ensure category counts prove only public action-category coverage, not player fairness or card balance.
5. **Determinism/evidence:** require two exact report bytes and label all Human/visible/Android/accessibility/release/numerical claims `NOT_RUN`.
