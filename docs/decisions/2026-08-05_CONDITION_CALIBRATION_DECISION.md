# 조건 난도·실제 성공률 보정 결정

- Decision ID: `TEN-DEC-20260805-CONDITION-CALIBRATION-01`
- 승인일: 2026-08-05
- 상태: `CURRENT_APPROVED_PLANNING_GOVERNANCE`
- 위험 상태: `MITIGATED_PENDING_HUMAN_MEASUREMENT`
- 부모 효과 권위: `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`
- 선행 stacked Decision: `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`
- 상세 계약: `docs/planning-data/approved_20260805_condition_calibration_contract.json`
- 제품 런타임: `NOT_IMPLEMENTED`

## 1. 승인 결론

조건 가격은 작성 시 선언한 구간을 사용하되, 실제 사람 플레이와 어긋날 때 실시간으로 자동 변경하지 않는다. 규칙을 이해한 일반 플레이어의 유효 시도 성공률과 충분한 표본을 근거로 별도 Decision에서만 수동 재분류한다.

현재 기술1 여섯 종의 효과·비용·슬롯·선언 난도·계수는 변경하지 않는다.

## 2. 조건 난도 구간

| 난도 | 유효 시도 성공률 | 가격 계수 |
|---|---:|---:|
| 극단적 | `0 이상 0.15 미만` | `0.25` |
| 매우 어려움 | `0.15 이상 0.30 미만` | `0.40` |
| 어려움 | `0.30 이상 0.50 미만` | `0.55` |
| 보통 | `0.50 이상 0.70 미만` | `0.70` |
| 쉬움 | `0.70 이상 0.85 미만` | `0.85` |
| 준확정 | `0.85 이상 1.00 이하` | `1.00` |

`준확정` 조건은 사실상 안정적으로 발동하므로 조건 할인을 받지 않는다. 구간은 0~1을 빈틈·중복 없이 덮는다.

## 3. 성공률 분모

전체 사용 성공률은 `조건 성공 횟수 / 합법적으로 확정한 해당 기술 사용 횟수`다.

가격 재분류에 쓰는 유효 시도 성공률은 다음과 같다.

```text
조건 성공 횟수 / 확정 시점의 공개 정보상 조건 성공이 가능했던 사용 횟수
```

- 공개 상태만으로 이미 불가능했던 사용은 가격 분모에서 제외하고 `PUBLICLY_IMPOSSIBLE_ATTEMPT`로 기록한다.
- 상대의 숨은 계획·이동·방어·회피·합·중단 때문에 실패한 경우에는 유효 실패로 포함한다.
- 디버그 강제 성공·실패, 치트, 포기·강제 종료 표본은 제외한다.

## 4. 실패 지점

각 시도는 하나의 최종 결과만 가진다.

1. `PUBLIC_STATE_MISMATCH`
2. `PREDICTION_MISS`
3. `POSITION_FAILURE`
4. `INTERRUPTED`
5. `EVADED_OR_MISSED`
6. `NO_HEALTH_DAMAGE`
7. `PARTIAL_CHAIN_FAILURE`
8. `SUCCESS`

같은 trigger를 공유하는 기본 조건 효과와 5성 patch는 하나의 condition group·성공 사건으로 센다.

## 5. 경고·재분류 Gate

경고:

```yaml
min_valid_attempts: 30
min_distinct_battles: 10
min_band_deviation_percentage_points: 10
```

재분류:

```yaml
min_valid_attempts: 100
min_distinct_battles: 30
```

그리고 Wilson 95% 신뢰구간 전체가 선언 구간 밖이거나, 유효 시도50·서로 다른 전투15 이상인 연속 두 배치가 같은 방향으로 이탈해야 한다.

- 한 단계 차이: 새 계수로 다시 계산하고 총원가 편차 `±5틱`을 검사한다.
- 두 단계 이상 차이: `CONDITION_DESIGN_REVIEW_REQUIRED`로 전환한다.
- 효과·비용·슬롯 변경에는 전후 예산표와 별도 사용자 승인이 필요하다.

## 6. 현재 기술 선언 동결

- 유운삼첩 2타 `보통`, 3타 `매우 어려움`, 완주 후퇴 `극단적`.
- 금강가세 완전 방어 `어려움`.
- 운수회신 유효 회피 `어려움`.
- 추풍일섬 창끝 `매우 어려움`.
- 청심조식 저자원 `매우 어려움`.
- 철각유영 완전 탈출 `어려움`.

## 7. 9성 필수 필드

```yaml
declared_difficulty:
coefficient:
public_trigger:
valid_attempt_definition:
success_event:
failure_points:
opponent_counterplay:
all_or_nothing_scope:
high_ceiling:
low_floor:
measurement_metrics:
reclassification_gate:
```

## 8. 악용 방지

- 자동·실시간 repricing 금지.
- 반복 실패 테스트 세션은 `CALIBRATION_TEST_ISOLATED`로 격리.
- 한 기술의 통계를 다른 기술에 대신 적용 금지.
- 부모 효과와 5성 patch의 중복 성공 집계 금지.
- 사람 검증 없이 시뮬레이션으로 고점 만족·저점 수용 PASS 주장 금지.

## 9. 권위 적용

```text
기술1 효과·비용·현재 선언
→ TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01

조건 난도 구간·측정 분모·재분류·anti-gaming
→ TEN-DEC-20260805-CONDITION-CALIBRATION-01
```

부모 기술1 계약은 `[대체됨]`이 아니다. 새 Decision은 향후 조건 작성과 재분류 거버넌스의 현행 overlay다.

## 10. 검증 경계

```yaml
static_validation: PASS_REQUIRED
human_validation: NOT_RUN
balance_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
performance_validation: NOT_RUN
```

다음 위험은 `WRONG_PLAN_RESCUE_RISK`다.
