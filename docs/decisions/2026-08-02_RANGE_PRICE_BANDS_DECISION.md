# 최대 사거리 구간 가격 결정

- Decision ID: `TEN-DEC-20260802-RANGE-PRICE-BANDS-01`
- 승인일: 2026-08-02
- 상태: `SUPERSEDED`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `2/10`
- 선행 결정: `TEN-DEC-20260802-BASIC-ATTACK-FORMULAS-SLOT-BUDGET-01`
- 장풍 공식 후속 결정: `TEN-DEC-20260802-BASIC-PALM-DAMAGE-GROWTH-01`
- 대체 결정: `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01`

> 이 문서의 `0/10/25/40틱` 최대 사거리 구간은 역사 기록으로만 유지한다. 현재 승인 가격은 이동·사거리 공통 1칸당 15틱이며 새 결정이 우선한다.

## 1. 과거 승인 결론

공격 기술의 사거리 비용은 선형 칸당 가격이 아니라 **최대 사거리별 총비용**으로 계산했다.

| 최대 사거리 | 총비용 | 기술 점수 |
|---:|---:|---:|
| 1 | 0틱 | 0점 |
| 2 | 10틱 | 0.5점 |
| 3 | 25틱 | 1.25점 |
| 4 | 40틱 | 2점 |

- 위 값은 `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01`에 의해 대체되었다.
- 과거 승인 기술과 diff를 재현하는 역사 데이터에서만 사용할 수 있다.
- 신규·수정 기술의 가격 계산에는 사용할 수 없다.

## 2. 과거 기초 공격 재계산

기준 스테이터스 4에서:

| 행동 | 피해·배수 | 사거리 | 비용 크레딧 | 과거 합계/목표 |
|---|---:|---:|---:|---:|
| 속공 | 25틱 | 0틱 | -4틱 | 21/20틱 |
| 강공 | 55틱 | 10틱 | -11틱 | 54/50틱 |
| 장풍 | 30틱 | 25틱 | -7틱 | 48/50틱 |

현재 가격으로는 속공 +1틱, 강공 +9틱, 장풍 +3틱 편차이며 강공은 재검토 대상이다.

## 3. 역사적 설계 목적

- 10칸 전장에서 공격 가능 구간 확대의 실제 전술 가치를 점수에 반영한다.
- 사거리와 피해를 별도 가격으로 분리한다.
- 장거리 고화력 기술의 과잉 효율을 발견한다.

이 목적은 유지되지만 가격 모델은 이동·사거리 통합 15틱 선형 모델로 변경되었다.

## 4. 권위·호환 경계

- 과거 모델 ID: `MAX_RANGE_TOTAL_TICKS`
- 현재 모델 ID: `UNIFIED_DISTANCE_PER_TILE_TICKS`
- 과거 `range_per_tile_beyond_one` 4틱과 0/10/25/40 구간은 역사 검증 호환용이다.
- 현재 `range_per_tile_beyond_one`과 `movement_per_tile`은 모두 15틱이다.
- 제품 코드와 런타임 판정은 변경하지 않는다.

## 5. 검증 요구

1. 이 문서가 `SUPERSEDED`로 표시됨.
2. 신규 가격 계산이 새 Decision을 참조함.
3. 기존 기술은 자동 수정되지 않고 before/after diff 대상으로 남음.
4. 런타임 구현 완료로 오인하지 않음.

```yaml
authority_status: SUPERSEDED
superseded_by: TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01
historical_pricing_model: MAX_RANGE_TOTAL_TICKS
current_pricing_model: UNIFIED_DISTANCE_PER_TILE_TICKS
historical_range_total_ticks:
  1: 0
  2: 10
  3: 25
  4: 40
current_distance_ticks_per_tile: 15
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 2/10
```
