# Representative Policy Coverage Result Review

~~~yaml
report_id: TEN-OPS-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-RESULT-REVIEW-01
decision: TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01
baseline_origin_main: 8e6ace1205e44fb6f0b83b281fb0862ce009a528
work_mode: REVIEW
scope: SCHEMA_3_6750_ROW_PUBLIC_POLICY_RESULT_INTERPRETATION_NO_NUMERICAL_MUTATION
approval_source: "user explicit: 좋아 진행해; existing approved long-horizon direction"
report_sha256: A0669A0727C9608B6A240910CE529263C1982C510E4B3C376BD58D8AB5F66558
report_size_bytes: 5850807
independent_report_runs: 2
completed_scenarios: 6750
current_source_relevance_check: REUSE_ALLOWED_SAME_DAY_12_GAME_PACKET_SAME_SINGLE_DUEL_BALANCE_DIMENSION_SAME_RUNTIME_STATE
local_machine_status: PASS
remote_ci_status: PASS_PR292_PR293_PR294
numerical_balance_decision: NO_NUMERICAL_MUTATION_RECOMMENDED_FROM_SCHEMA_3_EVIDENCE
next_evidence_gate: HUMAN_PLAYER_AND_WINDOWS_VISIBLE_BALANCE_REVIEW_BEFORE_ANY_NUMERICAL_PROPOSAL
windows_visible_evidence: NOT_RUN_FOR_BALANCE_REVIEW
human_player_evidence: NOT_RUN
android_device_evidence: NOT_RUN
accessibility_evidence: NOT_RUN
release_evidence: NOT_RUN
~~~

## 작업 전 문제

schema 3은 review-ready contract의 여섯 공개 player archetype을 모두 실제 resolver에 넣고 두 번의 byte-identical 6,750행 report를 만들었다. 그러나 이 입력은 사람의 최적·평균 전략이나 난이도 목표가 아니다. 결과의 후보별 경고를 카드·후보·AI·공유 resolver 수치 변경으로 잘못 해석하지 않도록, 정책·후보·시작 조합·AI seed를 분리해 검토한다.

## 조사·비교 결과

`docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md`의 same-day 12-game packet을 재사용했다. 이번 검토는 같은 단일 비무 balance measurement dimension, 같은 `opening_no_route`, 같은 public-information boundary와 같은 runtime state만 해석한다. 해당 packet의 `Yomi 2` meter-to-super, `Fights in Tight Spaces`/`Shogun Showdown` positioning-and-timing 관찰은 공개 기세·거리 행동을 따로 측정하는 방식에만 `ADAPT`한다. deck/hand/draw 및 one-hit kill 구조는 계속 `REJECT`다. 이 desk research는 십보강호의 사람 플레이나 수치 적정성을 검증하지 않는다.

## 결과 분해

모든 행은 `15 candidates × 15 legal starter loadouts × 6 public policies × 5 explicit AI seeds`의 실제 resolver duel이다. 각 policy에는 1,125행이 있고, 각 `candidate × policy` aggregate는 75행, 각 `candidate × policy × starter loadout` cell은 단 5개 seed로 구성된다.

| Public policy | Rows | Player win | Player loss | Win rate |
| --- | ---: | ---: | ---: | ---: |
| `public_approach_pressure` | 1,125 | 356 | 769 | 31.64% |
| `public_distance_control` | 1,125 | 60 | 1,065 | 5.33% |
| `public_evade_then_ultimate` | 1,125 | 645 | 480 | 57.33% |
| `public_guarded_exchange` | 1,125 | 0 | 1,125 | 0.00% |
| `public_mixed_exchange` | 1,125 | 567 | 558 | 50.40% |
| `public_recovery_range` | 1,125 | 35 | 1,090 | 3.11% |

6,750행은 모두 win 또는 loss로 끝났고 draw와 timeout은 모두 0이다. 이는 이 fixed input에서 resolver termination과 report 재현성을 보이는 결과일 뿐, draw/timeout의 제품 목표나 실제 난이도를 정하지 않는다.

같은 슬롯 안에서 candidate aggregate 차이가 15%p를 넘는 관측 trigger는 다음과 같다.

| Policy | Slot | Candidate win-rate range | Spread | 해석 경계 |
| --- | --- | ---: | ---: | --- |
| `public_evade_then_ultimate` | 1 | 20.00%~80.00% | 60.00%p | 회피 후 기세·절초 우선이라는 의도적 policy 조건이 포함된 조사 trigger |
| `public_evade_then_ultimate` | 2 | 20.00%~60.00% | 40.00%p | 위와 같음 |
| `public_mixed_exchange` | 3 | 65.33%~88.00% | 22.67%p | 공격·guard·recovery·ultimate 우선순위가 섞인 입력의 후보별 조사 trigger |
| `public_mixed_exchange` | 4 | 49.33%~81.33% | 32.00%p | 위와 같음 |
| `public_distance_control` | 5 | 0.00%~16.00% | 16.00%p | 최대 사거리 우선 policy의 조사 trigger |
| `public_recovery_range` | 4 | 0.00%~16.00% | 16.00%p | 회복 우선 policy의 조사 trigger |

AI seed는 policy aggregate에도 영향을 보였다. 예를 들어 `public_evade_then_ultimate`는 seed 0에서 73.33%, 나머지 네 seed에서 53.33%였고, `public_mixed_exchange`는 43.11%~52.44% 범위였다. 또한 1,350개의 candidate-policy-loadout cell 중 849개는 0/5, 197개는 5/5였다. cell당 5 seed라는 크기와 극단적인 policy가 함께 만드는 결과이므로, 이것을 후보 약화/강화의 직접 근거로 쓰지 않는다.

## 채택한 구조와 이유

`NO_NUMERICAL_MUTATION_RECOMMENDED`를 채택한다.

1. schema 3은 이미 GDD가 요구한 여섯 공개 행동 archetype을 전부 포괄하며, 정책 자체가 사람의 평균 전략이 아니다.
2. `opening_no_route`는 Route/reward/growth/campaign/retry의 난이도 흐름을 포함하지 않는다.
3. Human/player, balance-focused Windows-visible usability, Android device, accessibility-user, release-performance evidence가 없다.
4. 따라서 candidate profile, starter loadout, card cost/effect, stat formula, AI behavior, shared resolver, scene/UI, save data에는 변경을 가하지 않는다.

## 다섯 번의 적대 검토

1. **입력 무결성:** report SHA-256, 5,850,807 bytes, schema 3, 6,750 fixed public rows와 두 독립 run의 동일 bytes를 대조했다. private plan, AI trace/weight, UI intent, observation answer는 행에 없다.
2. **정책 편향:** guarded/recovery/distance-control policy의 낮은 승률과 evade/ultimate/mixed의 높은 승률을 제품 후보의 공정성 지표로 합산하지 않았다.
3. **표본 크기:** candidate-policy aggregate 75행과 candidate-policy-loadout cell 5 seed를 구분했다. 0/5 또는 5/5 cell을 확정 수치 변경 근거로 승격하지 않았다.
4. **시드 분리:** policy별 seed variation을 보존했으며 seed 0의 evade/ultimate 결과를 카드나 후보 수치 조정으로 귀속하지 않았다.
5. **장기 적합성:** 현 측정기는 공개 정보 경계와 engine-direct resolver를 보존한다. 다음 numerical Decision은 human balance protocol과 visible screen review를 추가한 뒤에만 열 수 있고, 자동 tuning을 도입하지 않는다.

## 실제 준비 결과와 사용 예

수치 변경 없이 review owner와 execution record를 추가했다. 이후 balance review가 열리면 이 문서는 “혼합 정책 slot 3/4와 회피·절초 slot 1/2를 우선 관찰할 후보”로만 사용한다. 예를 들어 플레이어가 실제 화면에서 `3/3/4` 수를 계획·공개·해결하는 과정에서 어떤 기술을 합법적으로 선택했는지와 왜 실패/성공했는지를 기록한 뒤, 같은 후보·시작 조합·seed strata와 교차해서만 수치 변경 후보를 제안한다.

## 기대효과

- 기계 측정의 완결성과 사람 대상 난이도 판단을 분리한다.
- 경고가 나와도 카드/후보/AI를 자동으로 약화·강화하지 않아 코어 전투 의미와 저장 호환성을 보호한다.
- 실제 플레이 관찰이 준비되면 공개 policy·candidate·loadout·seed를 같은 기준으로 재현해 원인을 추적할 수 있다.

## 검증 증거

| 검증 | 결과 | 한계 |
| --- | --- | --- |
| SHA-256 및 크기 readback | PASS — `A066…66558`, 5,850,807 bytes | report 존재·동일성만 증명 |
| public row 분해 | PASS — 6,750 rows, 6 policies, 5 seeds, 15 candidates/loadouts | 사람 행동의 분포 아님 |
| project operating system / canonical freshness / approval lifecycle | PASS | repository consistency만 증명 |
| Python regression | PASS — 428 tests | 화면의 사람 가독성·재미를 증명하지 않음 |
| PR #292/#293/#294 remote CI | PASS | remote automation이며 numerical balance PASS 아님 |

## 자동화·학습 반영

다음 numerical review는 policy aggregate를 단일 승률로 해석하지 않고 최소 `policy × candidate × starter_loadout × ai_decision_seed` strata를 먼저 제시해야 한다. 수치 변경 전에는 human/player protocol과 Windows-visible review를 별도 증거로 남긴다.

## 미검증·남은 위험

1. 실제 사람의 일반/숙련 플레이, 판단 시간, 기술 카드 가독성, VS 공개 연출의 이해도는 `NOT_RUN`이다.
2. Android 실제 기기, 접근성 사용자, release performance는 `NOT_RUN`이다.
3. 별도 사람 대상 evidence가 없으므로 numerical balance PASS와 player-facing quality PASS는 주장하지 않는다.

`CLEAN_REVIEW_EXIT`: schema 3 측정은 재현 가능하고 coverage는 완결됐지만, 이 결과만으로 numerical mutation을 열지 않는다.
