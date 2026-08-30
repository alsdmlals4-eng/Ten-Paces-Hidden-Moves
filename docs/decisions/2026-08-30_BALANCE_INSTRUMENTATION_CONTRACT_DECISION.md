# TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01

~~~yaml
decision_id: TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
status: IMPLEMENTED_MERGED_MAIN_PR280_REMOTE_CI_PASS_PROTECTED_APPROVAL_CLEANUP_PR_PENDING
decision_date: 2026-08-30
approval_source: "user explicit: 권장안대로 진행해; godot에 기획안들 전부 다 구현될 때까지 멈추지마; written-spec approval: 승인"
scope: FIRST_FIVE_DETERMINISTIC_SINGLE_DUEL_BALANCE_INSTRUMENTATION_V1
canonical_rule_owners:
  - docs/02_COMBAT_RULES.md
  - docs/09_COMBAT_SYSTEM_ARCHITECTURE.md
  - docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md
  - data/run/vertical_slice_opponents.json
  - src/run/vertical_slice_metrics_combat_resolution_engine.gd
design_spec: docs/superpowers/specs/2026-08-30-balance-instrumentation-design.md
runtime_mutation: AUTHORIZED_AND_IMPLEMENTED_MERGED_MAIN_PR280_VALIDATION_ONLY_SCOPE
automated_evidence: HEADLESS_FULL_MATRIX_MACHINE_VERIFIED_3375_ROWS_TWO_BYTE_IDENTICAL_REPORTS
godot_runtime_evidence: HEADLESS_GODOT_4_7_1_FULL_MATRIX_PASS
windows_visible_evidence: NOT_RUN
human_player_evidence: NOT_RUN_DEFERRED_BY_USER_FOR_CURRENT_STAGE
~~~

## 결정

첫 5전 후보의 runtime personality binding이 실제 Godot 전투 엔진에 구현된 상태에서, 다음 패키지는 수치 조정이 아니라 실제 엔진 단일 결투의 결정적 계측이다. 계측기는 후보 15명, 현재 가능한 4-of-6 시작 무공 조합, 공개 상태만 읽는 세 가지 플레이어 정책, 명시된 AI 시드 행렬을 실제 resolver에 입력한다.

이 Decision은 잠정 profile weight, final_stat_total_seed, Route 회복 수치, 기본/무공 카드 수치를 바꾸지 않는다. 자동 보고서는 측정값이며 밸런스·재미·공정성의 최종 PASS가 아니다.

## 플레이어 약속

~~~
후보의 공개 습관과 전투 결과
→ 실제 해결 엔진에서 재현 가능한 난이도 데이터
→ 수치 변경이 필요하다면 근거를 가진 별도 선택
→ 사람 플레이에서 재미·가독성·공정성 재검증
~~~

플레이어의 미확정 계획, 상대의 잠긴 현재 행동, AI 점수·가중치, 관찰 답안, UI 의도는 계측 정책과 결과 파일 모두에서 제외한다.

## 비교한 대안

| Alternative | Disposition | Reason |
| --- | --- | --- |
| 실제 Godot resolver를 호출하는 headless single-duel harness | ADOPT | 현재 gameplay rule을 재구현하지 않고 후보 binding과 전투 결과를 직접 측정한다. |
| Route/보상/성장까지 포함한 5전 자동 캠페인 | DEFER | 자동 정책이 새 기획 권위가 되어 현재 후보 난이도 문제를 흐릴 수 있다. |
| Python 규칙 복제 시뮬레이터 | REJECT | 실제 resolver와 drift하면 숫자가 제품 증거가 되지 않는다. |

## 보호·제외

- 10칸, 공개 시작 거리 2, 3/3/4, 합·방어·회피·중단, 공유 resolver, 공개 상태 AI 경계와 retry 의미를 바꾸지 않는다.
- 현재 run_seed 또는 저장/로드 스키마를 바꾸지 않는다. 계측 전용 ai_decision_seed만 명시 입력으로 기록한다.
- UI, Scene, asset, audio, Android, 릴리스, 외부 텔레메트리, 수치 자동 조정, 플레이어 공략 추천은 범위 밖이다.
- 첫 v1은 opening_no_route만 측정한다. Route/캠페인 난이도는 결과를 검토한 뒤 별도 Decision으로 다룬다.

## 수용 기준

1. 3,375개 시나리오는 현재 후보·시작 무공·정책·시드에서 결정적으로 생성되고, 하나라도 invalid이면 성공 보고를 만들지 않는다.
2. 보고서의 결과와 원인 수는 실제 VerticalSliceMetricsCombatResolutionEngine 해결 결과에서만 나온다.
3. 동일 입력 두 회 실행은 byte-identical JSON을 산출하며, scenario 간 engine/planner 상태가 누출되지 않는다.
4. 결과 파일과 policy는 비공개 계획·AI trace/weight·UI-only 데이터를 읽거나 기록하지 않는다.
5. 자동 계측 성공은 MACHINE_VERIFIED일 뿐 Human/Windows visible/Android/accessibility/release/balance PASS가 아니다.

## 다음 경계

사용자는 작성 명세를 `승인`했고, validation-only harness는 PR #280으로 병합되어 remote CI까지 통과했다. headless full matrix와 byte-identical report는 여전히 기계 증거일 뿐 Windows visible·Human/player·Android·accessibility·release·balance PASS는 아니다. PR #280의 active protected approval은 별도 lifecycle cleanup PR에서 archive되어야 하며, 그 정리가 끝난 뒤에도 측정 결과가 실제 수치 변경을 권하면 별도의 balance Decision과 데이터 회귀가 필요하다.
