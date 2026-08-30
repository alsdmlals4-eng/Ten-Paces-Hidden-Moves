# Balance Measurement Representative-Policy Coverage — Implementation Execution Report

~~~yaml
report_id: TEN-EXEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01
decision: TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01
status: IMPLEMENTED_MERGED_MAIN_PR292_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_CLEANUP_PENDING_PR
baseline_origin_main: e1aad779fced8ac54da52e03686fe51abb7fb34d
merged_main_commit: 3575e0405001514b7b3bdfb5b1c23f9caa34eca0
merged_pull_request: 292
remote_ci_status: PASS_PR292
work_mode: BUILD
approval_source: "user explicit: 좋아 진행해; retained long-horizon continuation approval"
current_source_relevance_check: REUSE_ALLOWED_SAME_DAY_INITIAL_12_GAME_PACKET_SAME_SINGLE_DUEL_BALANCE_DECISION_DIMENSION_SAME_RUNTIME_STATE_FOUR_OFFICIAL_SOURCES_LIVE_RECHECKED
implementation_feasibility: FEASIBLE_CURRENT_GODOT_4_7_1_ENGINE_AND_PUBLIC_POLICY_BOUNDARY_EXIST
godot_version: 4.7.1.stable.official.a13da4feb
full_report_scenarios: 6750
independent_full_runs: 2
report_sha256: A0669A0727C9608B6A240910CE529263C1982C510E4B3C376BD58D8AB5F66558
report_size_bytes: 5850807
protected_change_archive: docs/operations/2026-08-30_PR292_PROTECTED_CHANGE_APPROVAL_RECORD.md
protected_base_commit: 7072c3b49130434d1bf213d2275004c4f91a789e
product_mutation: NONE
asset_mutation: NONE
ui_scene_save_ai_formula_mutation: NONE
windows_visible: NOT_RUN
human_player: NOT_RUN
android_device: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
numerical_balance: NOT_DECIDED
~~~

## 작업 전 문제

schema 2 report는 4,500 actual resolver duels에서 guard/evade/recovery/ultimate 표본을 확보했지만, review-ready contract에 적힌 여섯 player archetype 중 거리 통제와 혼합 표본이 없었다. same-slot warning trigger도 발생했지만, 네 정책은 의도적으로 한 행동을 강하게 우선하므로 그 결과를 card/profile 수치 변경으로 자동 해석하면 안 됐다.

## 조사·비교 결과

- 최신 same-day 12-game benchmark packet은 현재의 single-duel balance measurement dimension과 engine state가 동일해 재사용했다. Yomi 2의 공개 meter-to-super 원칙은 public momentum/ultimate coverage에만 `ADAPT`했고, Fights in Tight Spaces/Shogun Showdown의 deck/hand/draw는 계속 `REJECT`, Die by the Blade의 one-hit 구조는 `AVOID`다.
- `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`의 six archetype와 현 policy IDs를 대조해 `public_distance_control`, `public_mixed_exchange` 두 입력의 부재를 확인했다.
- 현 Godot resolver, public snapshot, policy legality boundary, report runner, current candidate/loadout catalog를 직접 읽었다. validation-only seam에서 15 × 15 × 6 × 5 = 6,750 scenarios가 가능했고, shared combat/card/profile values, UI/Scene/assets/save/AI boundary를 변경할 필요가 없었다.

## 채택한 구조와 이유

- schema 2의 네 policy를 그대로 보존하고, `public_distance_control`은 reachable public attack 중 greatest `range.max`를 deterministic card-ID tie-break로 선택한다. 아무 공개 공격도 없을 때만 public move, 그마저 불가하면 guard를 선택한다.
- `public_mixed_exchange`는 public momentum이 최대일 때 legal ultimate, public history가 있고 resource가 모자랄 때 recovery, 그 외 reachable attack → public move → guard 순서로 선택한다.
- report schema 3은 행의 식별/결과 shape를 바꾸지 않고 `policy_selection_counts`만 `attack`, `move`, `guard`, `evade`, `recovery`, `ultimate` 여섯 aggregate count로 확장했다. per-card ID, target, hidden plan, AI trace/weight, preview/pointer, observation answer는 여전히 기록하지 않는다.

## 실제 구현 결과

| Policy | Rows | Player wins | Player losses | Action coverage actually selected |
| --- | ---: | ---: | ---: | --- |
| `public_approach_pressure` | 1,125 | 356 | 769 | attack 3,458; move 344 |
| `public_guarded_exchange` | 1,125 | 0 | 1,125 | guard 6,465; recovery 2,430 |
| `public_recovery_range` | 1,125 | 35 | 1,090 | attack 2,156; move 136; recovery 3,877 |
| `public_evade_then_ultimate` | 1,125 | 645 | 480 | evade 4,980; ultimate 3,030 |
| `public_distance_control` | 1,125 | 60 | 1,065 | attack 3,293; move 210; guard 2,758 |
| `public_mixed_exchange` | 1,125 | 567 | 558 | attack 1,815; guard 101; recovery 3,093; ultimate 2,242 |

The exact aggregate totals are attack `10,722`, move `690`, guard `9,324`, evade `4,980`, recovery `9,400`, ultimate `5,272`. Every 6,750 row resolved as win/loss; draw/timeout were `0/0`. These counts show that the intended validation inputs exercised every action category across the suite. They do not establish a target outcome distribution.

## 검증 증거

- **TDD RED:** before implementation, the focused Godot policy verifier rejected missing distance-control/mixed IDs and their expected legal placements; instrumentation rejected 4,500 rather than 6,750; the report runner rejected schema 2 / predecessor contract.
- **TDD GREEN:** `verify_vertical_slice_balance_public_policy.gd`, `verify_vertical_slice_balance_instrumentation.gd`, and `verify_vertical_slice_balance_report_runner.gd` passed under Godot `4.7.1.stable.official.a13da4feb`.
- **Two full runs:** two independent headless `run_vertical_slice_balance_instrumentation.gd` runs each emitted 6,750 current-resolver rows with the same SHA-256 `A0669A0727C9608B6A240910CE529263C1982C510E4B3C376BD58D8AB5F66558`.
- **Public report checker:** two reports passed byte equality, schema 3, all candidate/loadout/policy/seed coverage, fixed selection-key shape, non-negative metrics, category coverage, sorted scenario IDs, and forbidden private-field rejection.
- **Repository regression:** the first complete Python suite exposed two stale exact-string assertions: they still named the schema 1/schema 2 predecessor state and predecessor `next_phase`. Updating those assertions to the current schema 3/PR-lifecycle owner made the complete suite pass: `428 tests in 16.145s`.

## 다섯 번의 전체 적대 검토

| Loop | 공격한 범위 | finding / correction | Result |
| --- | --- | --- | --- |
| 1 | Canon/GDD coverage | six intended archetypes vs four actual policies | Added exactly distance-control and mixed validation inputs; no player rule change |
| 2 | Privacy/fairness | new choice could accidentally depend on hidden state | Existing private-sentinel placement equality includes every six policy; PASS |
| 3 | Category semantics | “mixed must move” was over-specified for the current input set | First 6,750 report exposed zero mixed moves; changed checker to require category coverage across the two new policies, where distance-control supplies move and mixed supplies guard/recovery/ultimate |
| 4 | Resolver/determinism | static policy labels could pass without runtime action | Two whole current-resolver reports are byte-identical and category counts are derived from actual placements |
| 5 | Scope/evidence ceiling | warning trigger could be misreported as a balance fix | Preserved numerical decision as `NOT_DECIDED`; no combat/card/profile/UI/asset/save/platform diff |

`CLEAN_REVIEW_EXIT`: no unresolved scope, public-information, report-shape, deterministic-run, or stated acceptance-criterion issue remains locally. PR #292 remote checks passed and the product change is merged in `main`; one-time approval archive cleanup and post-merge state readback remain open. All non-machine evidence is still open.

## 자동화·학습 반영

The checker now rejects a report that merely lists six policies but fails to exercise attack/move/guard/evade/recovery/ultimate in the actual full matrix. It also distinguishes a per-policy expectation from the approved suite-level coverage claim, so future policy changes cannot silently pass because of an impossible sub-policy assertion. The two repository-facing state tests now also make predecessor schema/status wording fail rather than silently accepting an outdated measurement evidence ceiling.

## 미검증·남은 위험

1. PR #292 merged with remote CI PASS. The active protected manifest is being converted to its immutable archive and the protected baseline is being promoted on this cleanup branch; this cleanup PR and its exact-main readback are still pending.
2. `opening_no_route` remains a single-duel input. Route/reward/growth/campaign/retry difficulty is not measured.
3. Windows-visible usability, Human/player fun/fairness/readability, Android device, accessibility user, release performance, and numerical balance remain `NOT_RUN` / `NOT_DECIDED`.
