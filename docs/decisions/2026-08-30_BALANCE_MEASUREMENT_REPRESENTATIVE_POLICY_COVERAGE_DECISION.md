# Balance Measurement Representative-Policy Coverage Decision

~~~yaml
decision_id: TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01
status: USER_CONTINUATION_APPROVED_IMPLEMENTED_MERGED_MAIN_PR292_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR293_POSTMERGE_READBACK
decision_date: 2026-08-30
baseline_origin_main: e1aad779fced8ac54da52e03686fe51abb7fb34d
work_mode: PLAN_TO_BUILD
approval_source: "user explicit: 좋아 진행해; existing long-horizon direction: 권장안대로 진행해 / godot에 기획안들 전부 다 구현될 때까지 멈추지마"
predecessor: TEN-DEC-20260830-BALANCE-MEASUREMENT-POLICY-COVERAGE-EXTENSION-01
scope: OPENING_NO_ROUTE_ENGINE_DIRECT_VALIDATION_ONLY_SIX_PLAYER_ARCHETYPE_POLICY_COVERAGE
current_source_relevance_check: REUSE_ALLOWED_SAME_DAY_INITIAL_12_GAME_PACKET_SAME_SINGLE_DUEL_BALANCE_DECISION_DIMENSION_SAME_RUNTIME_STATE_FOUR_OFFICIAL_SOURCES_LIVE_RECHECKED
implementation_feasibility: FEASIBLE_CURRENT_GODOT_4_7_1_ENGINE_AND_PUBLIC_POLICY_BOUNDARY_EXIST
runtime_evidence: TWO_6750_SCENARIO_HEADLESS_GODOT_4_7_1_REPORTS_BYTE_IDENTICAL
windows_visible: NOT_RUN
human_player: NOT_RUN
android_device: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
~~~

## 작업 전 문제

schema 2의 두 byte-identical 4,500행 report는 회피·절초·회복 selection/실행 표본을 확보했다. 하지만 `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`가 사전 검증 최소 시나리오로 든 여섯 player archetype 중 실제 policy는 네 개뿐이다.

| Review-ready archetype | schema 2 policy 상태 |
| --- | --- |
| 공격 압박형 | `public_approach_pressure` |
| 방어 안정형 | `public_guarded_exchange` |
| 거리 통제형 | **없음** |
| 회피/반격형 | `public_evade_then_ultimate` |
| 자원 안정형 | `public_recovery_range` |
| 혼합형 | **없음** |

또한 schema 2 결과에서 policy가 의도적으로 서로 극단적인 0.00%~57.33% player-win sample을 만들었다. same-slot review trigger도 `public_evade_then_ultimate`의 slot 1 (60%p)·slot 2 (40%p), `public_recovery_range`의 slot 4 (16%p)에서 발생했다. 이는 조사 시작 신호이지 카드·후보·공유 resolver 수치를 자동 변경하는 근거가 아니다.

## 조사·비교 결과

| 관찰 | 실제 근거 | 판단 |
| --- | --- | --- |
| Coverage가 deterministic하게 재현되는가 | `B311…B4D5D` SHA-256의 schema 2 4,500행 report 두 회 | ADOPT — 실제 resolver, 공개 정책, fresh scenario isolation을 유지 |
| 결과가 수치 변경을 직접 지시하는가 | `public_guarded_exchange`는 모든 scenario에서 guard 우선, `public_recovery_range`는 회복 우선, `public_evade_then_ultimate`는 기세가 찰 때까지 evade 우선 | REJECT — 각 policy는 사람의 최적·평균 전략이 아니라 독립된 행동 표본 |
| 기존 GDD 최소 archetype을 충족하는가 | review-ready contract의 여섯 archetype 중 distance-control/mixed가 빠짐 | MUST_FIX — validation input coverage를 넓힘 |
| 정보를 더 읽어야 하는가 | 기존 snapshot은 거리·공개 자원·기세·공개 이력·공개 card definition만 제공 | REJECT — hidden player plan, AI trace/weight, UI intent, observation answer를 추가하지 않음 |

동일 balance measurement dimension이며, schema 2 이후 실제 resolver·후보·starter loadout·opening route·공개정보 경계가 바뀌지 않았다. 따라서 same-day 12-game packet을 재사용한다. `Yomi 2`의 meter-to-super는 공개 기세/절초 표본만 확인하는 데 `ADAPT`하고, `Fights in Tight Spaces`·`Shogun Showdown`의 positioning/timing은 거리·행동 결과를 분리 측정하는 데만 `ADAPT`한다. 두 제품의 deck/hand/draw와 `Die by the Blade`의 one-hit 구조는 계속 `REJECT`/`AVOID`다.

## 결정

1. 기존 네 validation-only public policy를 삭제하거나 의미를 바꾸지 않는다.
2. 다음 두 policy를 추가해 review-ready의 여섯 player archetype coverage를 정확히 채운다.
   - `public_distance_control`: 현재 공개 거리에서 도달 가능한 기술 중 가장 긴 공개 최대 사거리를 우선하고, 도달 가능한 공격이 없을 때만 공개·합법 이동으로 거리를 좁힌다. 밀착에서 공격이 모두 불가하면 공개 guard fallback을 쓴다.
   - `public_mixed_exchange`: 공개 기세가 최대이고 절초가 현재 거리에서 합법이면 절초를 먼저 쓴다. 그 외에는 공개 자원/거리/공개 해결 이력에 따라 회복, 도달 가능한 공격, 접근, guard를 정해진 순서로 섞는다. hidden opponent intent나 UI 신호는 절대 읽지 않는다.
3. report schema를 **3**으로 올리고, 고정 aggregate `policy_selection_counts`를 `attack`, `move`, `guard`, `evade`, `recovery`, `ultimate` 여섯 키로 확장한다. card ID, target, pending plan, trace, weight, UI-only data는 행에 기록하지 않는다.
4. matrix를 15 candidates × 15 legal starter loadouts × 6 public policies × 5 explicit AI seeds = **6,750** actual resolver duels로 확장한다. `opening_no_route`, 공개 시작 거리 2, `3/3/4`, maximum 12 rounds는 유지한다.
5. 결과 검토의 numerical decision은 이 package의 두 independent Godot 4.7.1 report가 완료된 뒤에도 자동으로 PASS/조정하지 않는다. 다음 numerical Decision 후보는 same-slot trigger의 원인을 후보 stat seed, focus profile, loadout, policy, seed별로 분해한 뒤에만 만든다.

## 보호·제외

- 10칸 논리 전장, 시작 거리 2, `3/3/4`, 합·방어·회피·중단·강건, player/enemy combat values, candidate profile, shared resolver, AI public-information boundary, retry와 save/load를 바꾸지 않는다.
- Scene/UI/asset/audio/localization/Android/route/campaign/telemetry/auto-tuning/출시 작업을 바꾸지 않는다.
- 이 policy는 공략 추천, 사람 수준의 플레이, 난이도 판정, numerical balance PASS가 아니다.

## 수용 기준

1. 여섯 policy는 public snapshot만 사용하고 private sentinel을 주입해도 placement가 달라지지 않는다.
2. 새 policy 모두 실제 engine legality boundary를 통과하며, unknown policy는 fail-closed다.
3. matrix는 정확히 6,750 scenario를 생성하고 current 15 candidates, 15 legal starter selections, 5 seeds, `opening_no_route`를 유지한다.
4. schema 3 report는 fixed public row schema와 여섯 aggregate selection key만 포함하며, new distance-control/mixed policy가 적어도 하나의 attack/move/guard/recovery/ultimate 표본을 실제 resolver run에서 만든다.
5. 같은 exact source/input의 two independent Godot 4.7.1 headless runs가 byte-identical report를 만든다.
6. complete report의 same-slot warning trigger를 수치 변경이 아니라 investigation record로 보존한다.

## 실제 구현 결과

Two independent Godot 4.7.1 headless runs produced 6,750 rows each with identical SHA-256 `A0669A0727C9608B6A240910CE529263C1982C510E4B3C376BD58D8AB5F66558`. The public report checker confirmed all six policies, five seeds, all 15 candidates/loadouts, schema 3 fixed row shape, six aggregate selection keys, and the private-field deny list.

The policy set collectively recorded non-zero public category selections for attack `10,722`, move `690`, guard `9,324`, evade `4,980`, recovery `9,400`, and ultimate `5,272`. `public_distance_control` supplied attack/move/guard coverage; `public_mixed_exchange` supplied attack/guard/recovery/ultimate coverage. This confirms input coverage only.

## 다음 경계

이 package는 부족한 measurement input을 메우는 validation-only successor다. candidate/profile/card 수치 변경, Human/player balance decision, Windows-visible usability, Android, accessibility, release performance는 새 evidence와 별도 Decision 없이는 수행·주장하지 않는다.
