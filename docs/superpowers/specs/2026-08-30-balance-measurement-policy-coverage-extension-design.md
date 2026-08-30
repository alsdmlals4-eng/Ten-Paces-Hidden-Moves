# Balance Measurement-Policy Coverage Extension Design

~~~yaml
status: USER_CONTINUATION_APPROVED_IMPLEMENTED_LOCAL_MACHINE_VERIFIED_PENDING_PR
decision: TEN-DEC-20260830-BALANCE-MEASUREMENT-POLICY-COVERAGE-EXTENSION-01
baseline_origin_main: 65fc68a299e0b62a187baadb798d0ca82388b580
scope: VALIDATION_ONLY_PUBLIC_POLICY_AND_REPORT_SCHEMA_EXTENSION
runtime_mutation: NONE
~~~

## Goal

Keep the v1 3,375-scenario baseline comparable while adding a fourth deterministic public policy that reaches evade and ultimate behavior. Make the report prove policy coverage without serializing private combat intent or card/target detail.

## Architecture

```text
matrix JSON (4 public policies)
  -> VerticalSliceBalancePublicPolicy
  -> real VerticalSliceMetricsCombatResolutionEngine
  -> per-scenario fixed policy_selection_counts + existing battle_metrics
  -> sorted schema-v2 JSON report
  -> Godot/Python coverage and privacy checks
```

`public_evade_then_ultimate` receives the same public snapshot as every v1 policy. It uses only public tile distance, player stamina/internal/momentum, legal card definitions, bundle bounds and completed public history. At full momentum it chooses the distance-compatible basic ultimate; before that it selects evade when legal, then falls back to the existing public recovery/range policy.

## Exact boundary

| Area | Included | Excluded |
| --- | --- | --- |
| Validation matrix | Four policies, 4,500 single duels, original seeds and opening_no_route context | Route, rewards, growth, campaign automation |
| Policy logic | One public evade-to-ultimate selector | Hidden enemy action, AI trace/weights, pending plan, UI signals |
| Report | Schema 2 and four aggregate selection counts | Card IDs, target directions, private plans, player recommendations |
| Runtime | Existing resolver and metrics engine only | Formula/card/profile/candidate/UI/asset/save mutation |
| Evidence | Godot headless and deterministic JSON checking | Human fairness/fun, accessibility, Android, release performance |

## Failure conditions and tests

- A missing fourth policy, an evade selection before momentum is full, or an unreachable/ineligible ultimate at full momentum fails `verify_vertical_slice_balance_public_policy.gd`.
- Any matrix other than 15 × 15 × 4 × 5, missing normalized aggregate keys, private data leak, or invalid candidate fails `verify_vertical_slice_balance_instrumentation.gd`.
- A non-schema-2 report or wrong coverage-extension Decision ID fails `verify_vertical_slice_balance_report_runner.gd`.
- A full report with zero guard, evade, recovery, ultimate selection, zero successful dodge, or zero executed ultimate fails `check_vertical_slice_balance_report.py`.

## Rollback

Revert only `data/validation/`, `src/validation/`, validation tests and this Decision/spec/report lineage. No migration, save compatibility, player-facing runtime or asset rollback exists because none is changed.
