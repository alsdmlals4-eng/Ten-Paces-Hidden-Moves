# 능력치 참조 배수 가격의 기준 스테이터스 4 결정

- Decision ID: `TEN-DEC-20260802-STAT-REFERENCE-PRICE-BASE4-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `10/10`
- 선행 결정: `TEN-DEC-20260802-TECHNIQUE-AUTHORING-TAG-FIXED-STAT-01`

## 1. 승인 결론

기술 점수표에서 능력치 참조 배수의 예산 가치는 **스테이터스 4**를 밸런스 기준으로 환산한다.

```text
능력치 배수 틱
= 올림(해당 효과 1점의 기존 틱 가격 × 능력치 배수 × 기준 스테이터스 4)
```

예를 들어 피해 1점이 5틱이고 피해 배수 0.25를 선택하면:

```text
올림(5 × 0.25 × 4) = 5틱
```

즉 배수 0.25는 스테이터스 4에서 해당 효과 고정치 1점과 같은 예산 가치를 가진다.

## 2. 초기 스테이터스 기준

- 회차 시작 스테이터스 설계는 각 핵심 스테이터스가 **4 전후에서 실제 전투 공식의 기준 성능을 내는 방향**으로 설계한다.
- 정확한 시작 총점·최저값·최대값·직접 분배량은 별도 성장 Decision에서 확정한다.
- 기존 전체 운용 범위 `1~15`는 유지한다.
- 스테이터스 4는 최대치나 평균 보장값이 아니라 기술 예산과 초기 전투 성능을 비교하기 위한 밸런스 기준점이다.

## 3. 배수 작성 단위

- 기술 작성기의 기본 배수 단위는 `0.25`다.
- 주 능력치와 보조 능력치는 같은 효과량이라면 같은 틱 가격을 사용한다.
- 보조 능력치 할인은 두 능력치로 배수를 분할해 점수를 절약하는 우회를 만들므로 허용하지 않는다.
- 한 효과의 주·보조 능력치 배수는 각각 ledger에 기록하며 합계 배수도 표시한다.
- 배수 단위는 중앙 가격표 설정으로 관리하여 이후 `0.1`, `0.2`, `0.5` 등으로 변경할 수 있으나, 변경 시 기존 기술을 자동 수정하지 않고 편차·전후 차이를 보고한다.

## 4. 실제 전투 수치 반올림

연속 수치 효과의 실제 전투값은 다음 순서로 계산한다.

```text
원시 결과
= 고정 기본치
+ Σ(각 참조 스테이터스 현재값 × 해당 배수)

최종 정수 결과
= 원시 결과를 모두 합산한 뒤 한 번 내림
```

- 각 능력치 항을 개별 반올림하지 않는다.
- 연격 피해 분배처럼 별도 승인된 후속 정수화 규칙은 최종 총량 계산 뒤 적용한다.
- 음수 결과를 허용하지 않는 효과는 최종 단계에서 0을 하한으로 한다.

## 5. 점수표 적용

기술 총 틱은 기존 공식대로 계산한다.

```text
총 틱
= 구조·사거리·이동·타격 틱
+ 태그 틱
+ 고정 기본치 틱
+ 능력치 배수 틱
+ 조건·비용 크레딧
```

능력치 배수 ledger 최소 필드:

```yaml
source_table: stat_reference_pricing
price_id: effect-specific-stat-coefficient
stat_id: external_power | constitution | agility | internal_power | insight
coefficient: 0.25 단위
balance_reference_stat: 4
unit_effect_tick_price: 기존 효과 1점 가격
derived_ticks: ceil(unit_effect_tick_price × coefficient × 4)
```

## 6. 성장·밸런스 검증

기술은 최소 다음 세 지점을 비교한다.

- 저성장: 스테이터스 1
- 기준: 스테이터스 4
- 최대: 스테이터스 15

스테이터스 4에서 슬롯 예산 의도와 맞더라도, 15에서 같은 슬롯·비용의 기술을 압도하거나 기초 행동의 역할을 제거하면 과성장 경고로 검토한다.

복합 기술은 주·보조 스테이터스가 모두 15인 결과도 별도로 검사한다.

## 7. 확정·미확정 경계

이번에 확정:

- 예산 환산 기준 스테이터스 4
- 배수 작성 기본 단위 0.25
- 주·보조 같은 가격, 할인 없음
- 능력치 보정 합산 후 한 번 내림
- 초기 스테이터스 설계 중심을 4 전후로 설정

후속 미확정:

- 시작 스테이터스 총점과 직접 배분 방식
- 속공·강공·장풍의 고정 피해와 정확한 배수
- 효과별 과성장 허용 범위
- 5·9성 patch에서 배수 증가 상한

## 8. 검증 요구

1. 능력치 배수 틱이 효과별 기존 1점 가격과 기준 스테이터스 4를 사용함.
2. 배수 0.25가 스테이터스 4에서 고정치 1점과 같은 예산을 가짐.
3. 주·보조 능력치에 할인 차이가 없음.
4. 기술 결과가 모든 능력치 보정을 합산한 뒤 한 번 내림됨.
5. 스테이터스 1·4·15 결과를 sanity 검사함.
6. 배수 단위 변경 시 기존 기술을 자동 수정하지 않음.
7. 정확한 기초 공격 공식이 별도 승인 전 구현값으로 오인되지 않음.

## 9. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
balance_reference_stat: 4
initial_stat_design_center: 4
stat_operating_range: 1..15
coefficient_snap_step: 0.25
primary_secondary_same_price: true
secondary_discount: false
coefficient_tick_formula: ceil(effect_unit_tick_price * coefficient * 4)
runtime_value_rounding: floor_after_total_sum
central_price_change_auto_edits_existing_techniques: false
static_validation: PENDING_DRAFT_PR
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 10/10
```
