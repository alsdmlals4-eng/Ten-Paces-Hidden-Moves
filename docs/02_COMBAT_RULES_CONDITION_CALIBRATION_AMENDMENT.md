# 전투 규칙 조건 난도 보정 개정

- 상태: `[현행]` planning amendment
- Decision: `TEN-DEC-20260805-CONDITION-CALIBRATION-01`
- 부모 전투 규칙: `docs/02_COMBAT_RULES.md`
- 부모 기술 효과 권위: `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`
- 상세 계약: `docs/planning-data/approved_20260805_condition_calibration_contract.json`
- 런타임 구현: `NOT_RUN`

## 적용 범위

이 문서는 부모 전투 규칙의 기술 효과·비용·현재 선언 난도를 변경하지 않는다. 다음 항목만 최종 권위를 가진다.

- 조건 난도 성공률 구간.
- 전체 사용 성공률과 유효 시도 성공률 분모.
- 실패 지점 taxonomy.
- 부모 효과와 milestone patch의 중복 성공 집계 방지.
- 경고·재분류 표본 Gate.
- 자동 repricing 금지.
- 향후 9성 조건 작성 필드.

## 난도 구간

```yaml
extreme: [0.00, 0.15, 0.25]
very_hard: [0.15, 0.30, 0.40]
hard: [0.30, 0.50, 0.55]
moderate: [0.50, 0.70, 0.70]
easy: [0.70, 0.85, 0.85]
quasi_certain: [0.85, 1.00, 1.00]
```

각 배열은 `[최솟값, 최댓값, 가격 계수]`다. 마지막 구간만 최댓값1을 포함한다. 준확정 조건은 할인하지 않는다.

## 유효 시도

가격 보정 분모에 포함하려면 다음을 모두 만족해야 한다.

1. 기술이 합법적으로 확정됐다.
2. 확정 시점의 공개 상태상 조건 성공이 가능했다.
3. 디버그·치트·강제 결과가 아니다.
4. 포기·강제 종료로 결과가 소실되지 않았다.

상대의 숨은 대응으로 실패한 경우에는 유효 실패다. 공개 상태상 이미 불가능했던 사용은 분모에서 제외하고 오사용 지표로 기록한다.

## 실패 결과

```text
PUBLIC_STATE_MISMATCH
PREDICTION_MISS
POSITION_FAILURE
INTERRUPTED
EVADED_OR_MISSED
NO_HEALTH_DAMAGE
PARTIAL_CHAIN_FAILURE
SUCCESS
```

한 시도는 정확히 하나의 최종 결과를 가진다. 같은 trigger의 기본 효과와 5성 patch는 하나의 성공 사건으로 집계한다.

## 보정 Gate

```yaml
warning:
  min_valid_attempts: 30
  min_distinct_battles: 10
  min_band_deviation_percentage_points: 10
reclassification:
  min_valid_attempts: 100
  min_distinct_battles: 30
  evidence:
    - WILSON_95_CI_ENTIRELY_OUTSIDE_DECLARED_BAND
    - TWO_CONSECUTIVE_SAME_DIRECTION_BATCHES
```

경고는 가격을 바꾸지 않는다. 재분류도 자동 적용하지 않으며 별도 Decision과 전후 예산표가 필요하다.

## 참조 우선순위

```text
기술 효과·비용·현재 조건
→ docs/02_COMBAT_RULES.md
→ TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01

조건 난도 측정·재분류
→ 이 amendment
→ TEN-DEC-20260805-CONDITION-CALIBRATION-01
```

이 amendment 없이 과거 예상 성공 범위를 현재 재분류 근거로 직접 사용하거나, 실시간 성공률로 가격을 자동 변경하면 `CANON_CONFLICT`다.

## 검증 경계

- 정적·회귀 검증: required.
- 사람·밸런스·Godot·Windows·접근성·성능 검증: `NOT_RUN`.
