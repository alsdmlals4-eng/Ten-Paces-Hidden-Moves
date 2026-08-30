# Balance Measurement-Policy Coverage Result Review

~~~yaml
report_id: TEN-OPS-20260830-BALANCE-MEASUREMENT-POLICY-COVERAGE-RESULT-REVIEW-01
decision: TEN-DEC-20260830-BALANCE-MEASUREMENT-POLICY-COVERAGE-EXTENSION-01
baseline_origin_main: e1aad779fced8ac54da52e03686fe51abb7fb34d
work_mode: REVIEW
scope: SCHEMA_2_4500_ROW_RESULT_INTERPRETATION_AND_SUCCESSOR_MEASUREMENT_DECISION
approval_source: "user explicit: 좋아 진행해; in-scope continuation authorization"
report_sha256: B311E75470063A96A382356C55C03E107CDF23316EB8035C360298B0DF7B4D5D
report_size_bytes: 3725259
independent_report_runs: 2
completed_scenarios: 4500
local_machine_status: PASS
remote_ci_status: PASS_PR289
numerical_balance_decision: NOT_RECOMMENDED_FROM_SCHEMA_2_EVIDENCE
successor_measurement_decision: TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01
windows_visible_evidence: NOT_RUN
human_player_evidence: NOT_RUN
android_device_evidence: NOT_RUN
accessibility_evidence: NOT_RUN
release_evidence: NOT_RUN
~~~

## 작업 전 문제

schema 2 coverage extension은 v1의 0 dodge/ultimate와 unobservable recovery 선택을 교정했다. 그러나 report를 수치 조정 판단으로 사용하기 전에, policy가 review-ready contract가 요구한 six-player-archetype surface를 충분히 대표하는지와 warning trigger가 실제로 무엇을 뜻하는지 분리해야 했다.

## 결과 분해

| Public policy | Rows | Player win | Player loss | Guard | Evade | Recovery | Ultimate use |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `public_approach_pressure` | 1,125 | 356 (31.64%) | 769 (68.36%) | 0 | 0 | 0 | 0 |
| `public_guarded_exchange` | 1,125 | 0 (0.00%) | 1,125 (100.00%) | 6,465 | 0 | 2,430 | 0 |
| `public_recovery_range` | 1,125 | 35 (3.11%) | 1,090 (96.89%) | 0 | 0 | 3,877 | 0 |
| `public_evade_then_ultimate` | 1,125 | 645 (57.33%) | 480 (42.67%) | 0 | 4,980 | 0 | 3,030 |

All 4,500 rows ended as a win or loss; draw and timeout were both zero. The report therefore proves resolver termination for this input set, but it does not establish a desirable draw/timeout target.

The review-ready warning line, “same-slot candidate win-rate difference > 15%p,” triggered in these synthetic policy slices:

- `public_evade_then_ultimate`: slot 1 range **60%p** (20%~80%), slot 2 range **40%p** (20%~60%).
- `public_recovery_range`: slot 4 range **16%p** (0%~16%).

The policy-level spread itself is 57.33%p (0.00%~57.33%). This is expected from policies that always choose guard/recovery/evade first; treating the aggregate as a player build win rate would conflate validation behavior with product balance.

## Decision

No candidate, card, recovery, stat, AI, or resolver value is changed. The correct action is to close the GDD’s two missing validation inputs — distance-control and mixed — and re-run a six-policy report. A later numerical Decision must decompose same-slot triggers by policy/loadout/seed and use Human/player evidence before it proposes value changes.

## Five adversarial review loops

1. **Report integrity:** checked schema 2, exact 4,500 row count, two equal file bytes, fixed public row keys, and no forbidden private fields. No instrumentation corruption finding.
2. **Outcome interpretation:** separated policy-conditioned player wins from a player skill/build/ranking claim. The guard/recovery extremes prevent any automatic fairness conclusion.
3. **GDD coverage:** compared actual four IDs to the six archetypes named in `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`; distance-control and mixed were absent.
4. **Warning triggers:** preserved the 60%p/40%p/16%p findings as investigation triggers only; no cross-slot stat-seed comparison or card value mutation was smuggled in.
5. **Long-term fit/evidence ceiling:** selected a small public-policy successor that uses the current engine and schema boundary; kept Windows-visible, Human/player, Android, accessibility, release, and numerical-balance evidence unclaimed.

`CLEAN_REVIEW_EXIT`: the schema 2 result has a clear non-numerical next action. It is not a numerical balance PASS or an implementation closeout for the successor.

## Remaining risk

1. `opening_no_route` does not represent Route/reward/growth/campaign/retry difficulty.
2. Six deterministic policies will remain measurement inputs, not human behavior or an automatic tuning oracle.
3. The eventual six-policy result still needs separate Human/player, visible Windows, Android, accessibility, and release-performance evidence before any player-facing quality claim.
