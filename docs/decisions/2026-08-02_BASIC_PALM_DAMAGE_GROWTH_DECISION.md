# 장풍 피해·내공 성장 공식 결정

- Decision ID: `TEN-DEC-20260802-BASIC-PALM-DAMAGE-GROWTH-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `3/10`
- 선행 결정:
  - `TEN-DEC-20260802-BASIC-ATTACK-FORMULAS-SLOT-BUDGET-01`
  - `TEN-DEC-20260802-RANGE-PRICE-BANDS-01`

## 1. 승인 결론

장풍은 밀치기나 별도 거리 제어 효과를 추가하지 않고, 2슬롯·전조·내력 소모·사거리 3의 대가를 **고정 피해와 내공 성장 배수**에 사용한다.

```text
장풍 피해 = floor(3 + 내공 × 0.75)
```

- 고정 피해는 `2 → 3`으로 증가한다.
- 내공 배수는 `0.50 → 0.75`로 증가한다.
- 장풍이 동일 능력치의 속공보다 반드시 낮아야 한다는 과거 제약은 이 Decision으로 대체한다.
- 장풍은 2슬롯 공격이므로 기준 스테이터스 4부터 1슬롯 속공보다 높은 피해를 가질 수 있다.
- `[밀치기]`와 기타 강제 이동 효과는 추가하지 않는다.

## 2. 기준 스테이터스 4 ledger

| 구성 | 틱 |
|---|---:|
| 고정 피해 3 | 15 |
| 내공 배수 0.75 | 15 |
| 최대 사거리 3 | 25 |
| 내력 1 비용 | -7 |
| **합계** | **48틱 / 50틱** |

`-2틱`으로 자동 허용 오차 `±5틱` 안이다. 기존 장풍의 잔여 12틱은 해소되며 별도 부가효과를 추가할 필요가 없다.

## 3. 능력치 검산

| 능력치 | 속공 | 장풍 |
|---:|---:|---:|
| 1 | 3 | 3 |
| 4 | 5 | 6 |
| 15 | 10 | 14 |

- 능력치 1에서는 속공과 장풍이 같은 피해다.
- 기준 스테이터스 4부터 장풍이 더 강하다.
- 최대 스테이터스 15에서도 장풍은 강공 `22`보다 낮아 공격 역할 구분을 유지한다.

## 4. 설계 의도

- 장풍은 낮은 피해로 상대를 밀어내며 거리를 유지하는 행동이 아니다.
- 장풍의 핵심 보상은 전조와 내력 소모를 감수하고 사거리 3에서 사용하는 **내공 성장형 원거리 공격**이다.
- 밀치기를 붙여 반복적인 거리 벌리기와 니가와 플레이를 강화하지 않는다.
- 사거리 가치는 이미 `25틱`을 소비하므로, 피해 공식 외 추가 원거리 보너스를 암묵적으로 부여하지 않는다.

## 5. 대체 범위

이 Decision은 다음 구형 표현을 대체한다.

- `장풍 피해 = floor(2 + 내공 × 0.50)`
- `동일한 능력치에서는 장풍이 항상 속공보다 1 낮다`
- `장풍 38/50틱·잔여 12틱`
- 장풍 잔여 예산에 `[밀치기 1]`을 추가하는 후보

속공·강공 공식과 사거리 가격표는 변경하지 않는다.

## 6. 구현·검증 경계

- 현재 런타임에는 장풍이 없다.
- 이 Decision은 기획 공식·기술 점수 ledger만 승인한다.
- 제품 코드·카드 데이터·전투 엔진 변경은 별도 Build 승인 전 금지한다.

검증 요구:

1. 장풍 공식이 `floor(3 + internal_power × 0.75)`로 기록됨.
2. 기준 스테이터스 4 ledger가 `48/50틱`임.
3. 장풍에 밀치기나 강제 이동이 자동 추가되지 않음.
4. 속공보다 낮아야 한다는 구형 제약이 활성 문서에 남지 않음.
5. 능력치 1·4·15에서 장풍 피해가 각각 3·6·14임.
6. 런타임 구현 완료로 오인하지 않음.

```yaml
authority_status: CURRENT_APPROVED_PLANNING
implementation_status: NOT_STARTED
basic_palm_formula: floor(3 + internal_power * 0.75)
basic_palm_ticks_at_stat_4: 48
basic_palm_target_ticks: 50
basic_palm_variance_ticks: -2
knockback_added: false
quick_attack_lower_damage_constraint: SUPERSEDED
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 3/10
```
