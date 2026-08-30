# Balance Instrumentation Result Review

~~~yaml
report_id: TEN-OPS-20260830-BALANCE-INSTRUMENTATION-RESULT-REVIEW-01
decision: TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
baseline_origin_main: b629c79110c9a98a4ed0944897fe3eea46f5b507
work_mode: REVIEW
current_source_relevance_check: NOT_APPLICABLE_NO_EXTERNAL_PRODUCT_OR_POLICY_DECISION
scope: OPENING_NO_ROUTE_SINGLE_DUEL_RESULT_INTERPRETATION_AND_APPROVED_POLICY_SEMANTIC_RECOVERY
policy_recovery_scope: src/validation/vertical_slice_balance_public_policy.gd
approval_source: "user explicit: 승인; in-scope recovery authorization"
corrected_report_sha256: F748CC50B7B7BF98CA0FB727383228942F808C17A1E8402B7B151B21DE65F36B
corrected_report_size_bytes: 2353406
corrected_report_runs: 2
corrected_report_scenarios: 3375
local_machine_status: PASS
remote_ci_status: NOT_RUN_ON_THIS_BRANCH
numerical_balance_decision: NOT_RECOMMENDED_FROM_THIS_EVIDENCE
windows_visible_evidence: NOT_RUN
human_player_evidence: NOT_RUN
android_device_evidence: NOT_RUN
accessibility_evidence: NOT_RUN
release_evidence: NOT_RUN
~~~

## 작업 전 문제

PR #280 계측기는 현재 Godot resolver에서 15 후보 × 15개 합법 시작 무공 조합 × 3개 공개 정책 × 5개 AI seed를 실행할 수 있었지만, 결과 해석 전에 `public_approach_pressure`가 승인된 “사거리 밖이면 접근” 의미를 끝까지 지키는지 확인하지 않았다.

초기 두 보고서는 3,375행·동일 SHA-256 `899EC5562E06EBBA2072F7601E7FD7C17AF3E96DD7F19095B52CF8478810895C`로 재현됐으나, 결과 분해에서 시작 거리 2에 현재 사거리 내 공격이 없는 경우에도 이 정책이 빈 계획을 낼 수 있음을 발견했다. 이는 적 수치·무공 수치·공유 resolver의 결함이 아니라 validation-only 정책의 의미 누락이다.

## 조사·비교 결과

| 관찰 | 실제 근거 | 판정 |
| --- | --- | --- |
| 모든 시작 무공 조합이 실제 resolver까지 도달하는가 | 15 × 15 × 3 × 5 = 3,375 scenario가 valid로 종료 | ADOPT — matrix coverage는 유지 |
| 사거리 밖 공격이 없을 때 접근 압박이 이동하는가 | 기존 정책은 거리 `> 2`에서만 먼저 이동하고, 거리 1~2에서 모든 공격 후보가 불가하면 빈 배열을 반환 | MUST_FIX — 명세의 “사거리 밖이면 접근”과 불일치 |
| 전투 수치를 바꿔야 하는가 | 교정 뒤 승/패·피해량은 이전 보고서와 동일, 170 scenario의 진행 묶음 수/라운드만 변화 | REJECT — 이 evidence만으로 숫자 변경 금지 |
| 방어·회복·필살기 수치를 판정할 수 있는가 | 방어 우선 정책은 guard가 항상 우선이고, 세 정책 모두 ultimate를 선택하지 않아 dodge/ultimate 집계는 0 | DEFER — 현 v1 policy coverage만으로 해당 수치를 판정할 수 없음 |

## 채택한 구조와 이유

`public_approach_pressure`는 기존의 공격 우선순위를 보존한다. 다만 현재 공개 거리에서 어떤 공개 공격도 유효·지불 가능하지 않을 경우에만, 적과의 거리가 0보다 크면 기존의 `basic_footwork → basic_move` 공개 이동 선택으로 접근한다.

이 수정은 다음을 바꾸지 않는다.

- 10칸 논리 전장, 시작 공개 거리 2, 3/3/4, 합·방어·회피·중단, resolver, AI 공개 정보 경계
- 후보 profile·`final_stat_total_seed`·무공 카드·기본 카드의 수치와 비용
- Scene·UI·저장·자산·Android·release surface

회귀는 “거리 2, 도달 가능한 공격 없음, 이동은 합법”이라는 최소 공개 상태를 만들고 `basic_move`로 한 칸 접근하는지를 고정한다. 이로써 결과 행의 private plan, AI trace, UI intent 경계도 넓히지 않는다.

## 실제 결과

두 독립 Godot 4.7.1 headless full run은 각각 3,375행을 만들었고, 같은 SHA-256 `F748CC50B7B7BF98CA0FB727383228942F808C17A1E8402B7B151B21DE65F36B`를 산출했다. `tests/check_vertical_slice_balance_report.py`는 두 파일의 byte equality·정렬·coverage·공개 데이터 경계를 통과했다.

| 비교 | 수정 전 | 정책 교정 후 | 변화 |
| --- | ---: | ---: | ---: |
| 전체 승리 | 391 | 391 | 0 |
| 전체 패배 | 2,984 | 2,984 | 0 |
| timeout / draw | 0 / 0 | 0 / 0 | 0 / 0 |
| player health lost | 행별 동일 | 행별 동일 | 0행 |
| outcome 변경 | — | — | 0행 |
| battle metric 또는 resolved bundle 변경 | — | — | 170행 |
| successful dodges / ultimate uses | 0 / 0 | 0 / 0 | 0 / 0 |

정정은 `public_approach_pressure`에만 영향을 주었다. 170개 행은 후보·시작 무공·seed에 따라 해결 묶음 수 또는 경과 라운드가 바뀌었지만, 이번 `opening_no_route` 단일 결투 표본에서 체력 손실과 최종 승패는 유지됐다. 그러므로 현 결과는 candidate/technique 숫자 조정 근거나 사람 플레이 난이도 PASS가 아니다.

## 검증 증거

| 검사 | 결과 | 증거 한계 |
| --- | --- | --- |
| 새 out-of-range 접근 RED | 기존 정책에서 Godot exit 1 | 결함 재현; 증거로 사용하지 않음 |
| `verify_vertical_slice_balance_public_policy.gd` | PASS | 공개 정책의 접근 회귀와 privacy/legality |
| `verify_vertical_slice_balance_instrumentation.gd` | PASS | matrix·fresh state·normalized row |
| `verify_vertical_slice_balance_report_runner.gd` | PASS | report ordering·serialization·boundary |
| `verify_vertical_slice_opponent_runtime_binding.gd` | PASS | 기존 후보 runtime binding 회귀 |
| `verify_phase2_combat_resolution.gd` | PASS | 기존 shared resolver 회귀 |
| full runner A/B + Python checker | PASS, 3,375 × 2, byte-identical | headless MACHINE_VERIFIED만 해당 |

## 다섯 차례 적대 검토

1. **정본·범위:** 최신 `origin/main` SHA와 Decision·설계를 대조해, 숫자 변경이 아니라 이미 승인된 공개 정책 의미의 복구만 허용했다.
2. **행동 의미:** 거리 2에서 공개 공격이 전부 불가한 최소 상태를 만들어 기존 empty-plan 반환을 RED로 재현했다.
3. **소비처·경계:** policy와 test만 바꾸고 candidate data, combat data, resolver, save, Scene, UI, asset의 변경이 없음을 확인했다.
4. **실행 증거:** focused Godot 회귀 4개와 full matrix 독립 2회를 실행해, 수정 후 scenario valid·결정성·privacy checker를 재확인했다.
5. **결과 해석:** 승패·체력·timeout·draw 차이와 170개의 progression-only 차이를 분리해, 숫자 변경 권고를 만들지 않는 clean exit를 확인했다.

## 자동화·학습 반영

새 회귀는 “거리 수치가 2 이하” 같은 우연한 조건이 아니라 “현재 공개 공격이 모두 사거리 밖이면 접근”이라는 정책 의미를 직접 고정한다. 향후 card range·시작 자원이 달라져도, 공개 공격 후보가 없을 때 빈 계획으로 정지하는 회귀는 Godot에서 즉시 실패한다.

## 미검증·남은 위험

1. 이 결과는 `opening_no_route` 단일 결투와 세 개의 고정 공개 정책만 다룬다. Route·보상·성장·캠페인·retry UX에는 적용하지 않는다.
2. 방어와 회피를 교차시키는 행동, 회복의 임계값, 필살기 사용은 현 policy set가 충분히 표본화하지 않는다. 이를 바꾸려면 수치 변경과 별개로 새 measurement-policy Decision이 필요하다.
3. Windows visible 화면, human/player fun·fairness·readability, Android, 접근성 사용자, release performance는 모두 `NOT_RUN`이다.
4. 이 branch의 remote CI와 merge/readback, active protected approval archive, protected baseline promotion은 아직 완료 전이다.
