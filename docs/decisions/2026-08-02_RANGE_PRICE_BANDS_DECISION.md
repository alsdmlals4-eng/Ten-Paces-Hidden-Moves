# 최대 사거리 구간 가격 결정

- Decision ID: `TEN-DEC-20260802-RANGE-PRICE-BANDS-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `2/10`
- 선행 결정: `TEN-DEC-20260802-BASIC-ATTACK-FORMULAS-SLOT-BUDGET-01`
- 장풍 공식 후속 결정: `TEN-DEC-20260802-BASIC-PALM-DAMAGE-GROWTH-01`

## 1. 승인 결론

공격 기술의 사거리 비용은 선형 칸당 가격이 아니라 **최대 사거리별 총비용**으로 계산한다.

| 최대 사거리 | 총비용 | 기술 점수 |
|---:|---:|---:|
| 1 | 0틱 | 0점 |
| 2 | 10틱 | 0.5점 |
| 3 | 25틱 | 1.25점 |
| 4 | 40틱 | 2점 |

- 사거리 2·3·4의 값은 누적 총비용이다.
- 기존 `사거리 1 초과 매 1칸 +4틱` 선형 규칙은 현재 승인 기술에 사용하지 않는다.
- 사거리 5 이상은 임의로 외삽하지 않으며 별도 Decision 전까지 `TBD`다.
- 최소 사거리·방향 제한·사각·대상 제한은 최대 사거리 가격과 별도 조건 ledger로 계산한다.

## 2. 기초 공격 재계산

기준 스테이터스 4에서:

| 행동 | 피해·배수 | 사거리 | 비용 크레딧 | 합계/목표 |
|---|---:|---:|---:|---:|
| 속공 | 25틱 | 0틱 | -4틱 | 21/20틱 |
| 강공 | 55틱 | 10틱 | -11틱 | 54/50틱 |
| 장풍 | 30틱 | 25틱 | -7틱 | 48/50틱 |

- 강공은 `+4틱`, 장풍은 `-2틱`으로 모두 자동 허용 오차 안이다.
- 장풍 피해·배수는 후속 Decision `TEN-DEC-20260802-BASIC-PALM-DAMAGE-GROWTH-01`이 소유한다.
- 사거리 비용은 공격 피해·능력치 배수·자원 비용과 별도 ledger 행으로 기록한다.

## 3. 설계 목적

- 10칸 전장에서 공격 가능 구간 확대의 실제 전술 가치를 점수에 반영한다.
- 사거리 3 이상이 근접 공격과 같은 값으로 취급되는 왜곡을 방지한다.
- 사거리와 피해를 별도 비용으로 만들어 장거리 고화력 기술의 과잉 효율을 드러낸다.

## 4. 권위·호환 경계

- 중앙 점수표의 새 승인 가격 모델은 `MAX_RANGE_TOTAL_TICKS`다.
- 레거시 POC 기술이 참조하는 `range_per_tile_beyond_one` 키는 역사 데이터 검증 호환용으로만 남길 수 있다.
- 신규·수정 승인 기술은 레거시 선형 키를 사용하면 검증 실패다.
- 제품 코드와 런타임 판정은 변경하지 않는다.

## 5. 검증 요구

1. 사거리 1/2/3/4가 각각 0/10/25/40틱으로 계산됨.
2. 가격을 칸별 증분으로 중복 합산하지 않음.
3. 강공 ledger가 54틱, 장풍이 48틱으로 계산됨.
4. 사거리 5 이상이 자동으로 55틱 등으로 확장되지 않음.
5. 런타임 구현 완료로 오인하지 않음.

```yaml
authority_status: CURRENT_APPROVED_PLANNING
pricing_model: MAX_RANGE_TOTAL_TICKS
range_total_ticks:
  1: 0
  2: 10
  3: 25
  4: 40
range_5_plus: TBD
legacy_linear_pricing: SUPERSEDED_FOR_CURRENT_APPROVED_TECHNIQUES
heavy_attack_ticks: 54
basic_palm_ticks: 48
basic_palm_variance_ticks: -2
basic_palm_formula_decision: TEN-DEC-20260802-BASIC-PALM-DAMAGE-GROWTH-01
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 2/10
```
