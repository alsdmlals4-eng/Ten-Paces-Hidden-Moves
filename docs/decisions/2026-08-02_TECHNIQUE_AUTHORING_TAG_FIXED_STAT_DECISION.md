# 기술 작성의 태그·고정치·스테이터스 참조 결정

- Decision ID: `TEN-DEC-20260802-TECHNIQUE-AUTHORING-TAG-FIXED-STAT-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `9/10`
- 복구 근거:
  - `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
  - `docs/06_STARTING_FACTION_MASTERY_DATA.md`
  - `docs/planning-data/poc_balance_budget.json`
  - 사용자 보정: 관찰·이동·회피·강화는 고정, 나머지 행동 효과는 능력치 참조

## 1. 승인 결론

기술은 중앙 기술 점수표에서 다음 요소를 **서로 분리해 선택·기록·가격 계산**한다.

1. 행동 구조와 비용
2. 전투 효과·조건 태그
3. 항상 적용되는 고정 기본치
4. 주·보조 스테이터스 참조와 각각의 배수
5. 5·9성 기본 강화와 스테이터스 임계 효과

태그만 적거나 최종 피해 숫자만 적는 기술은 작성 완료로 인정하지 않는다. 각 구성 요소는 `price_id × quantity` ledger 항목으로 추적할 수 있어야 한다.

## 2. 기술 작성 순서

### 2.1 행동 구조 확정

먼저 다음 구조를 확정한다.

- 행동 종류와 출처: 기초·무공·절초
- 슬롯 수와 `[전조]` 수
- 비용: 기력·내력·절초기세·체력 등
- 대상·방향·실행 단계
- 공격 사거리와 이동 거리
- 타격 수·복합 행동 구성

이 값들은 기술의 문법과 실행 가능 조건이며, 스테이터스 1점마다 연속 증가하지 않는다.

### 2.2 태그 선택

승인된 태그 사전에서 필요한 태그를 선택한다.

예: `[필중]`, `[강건]`, `[연격 N]`, `[밀치기 N]`, `[추격 N]`, `[후퇴 N]`, `[방어]`, `[회피]`.

- 태그는 판정 권한·트리거·효과 종류를 정의한다.
- 각 태그와 태그 수량 `N`은 중앙 가격표의 별도 `price_id`로 계산한다.
- 태그는 능력치 참조를 암묵적으로 부여하지 않는다.
- 태그 수량은 기본적으로 고정치이며, 명시적인 5·9성 patch 또는 스테이터스 임계 효과가 있을 때만 변경한다.

### 2.3 고정 기본치 선택

피해·방어도·회복·자원 회복·방어 파괴처럼 수치 결과가 있는 효과는 기술이 항상 보장하는 고정 기본치를 가진다.

예시 공식:

```text
최종 연속 수치 = 고정 기본치 + 스테이터스 참조 보정
```

고정 기본치는 중앙 가격표에서 효과 종류별 단가와 수량으로 계산한다.

### 2.4 스테이터스 참조 선택

고정 전용 효과를 제외한 행동 효과는 외공·근골·신법·내공·심안 중 최소 1개를 참조한다.

- 주 스테이터스 1개는 필수다.
- 기술 정체성상 필요할 때 보조 스테이터스 1개를 추가할 수 있다.
- 한 효과의 참조 스테이터스는 최대 2개다.
- 각 참조는 스테이터스 ID와 배수를 명시한다.
- 서로 다른 행동은 같은 스테이터스를 참조해도 배수가 다를 수 있다.

확정된 기초 공격 방향:

- `[속공]`: 고정 피해 + 외공 참조
- `[강공]`: 고정 피해 + 외공 참조, 속공과 다른 배수
- `[장풍]`: 고정 피해 + 내공 참조

정확한 고정 피해·배수·반올림은 기술 점수표의 스테이터스 참조 가격 항목을 복구한 뒤 별도 승인한다.

## 3. 고정 전용 효과

다음 기본 효과는 연속 스테이터스 참조를 사용하지 않는 고정치다.

- `[관찰]`: 기본 관찰량
- `[이동]`·`[보법]`: 이동 칸 수
- `[회피]`: 기본 회피 횟수와 회피 판정 권한
- `[준비]`: 다음 행동 강화의 기본 효과

또한 다음 구조적 값도 연속 스테이터스 참조를 사용하지 않는다.

- 공격 사거리
- 행동 슬롯 수와 `[전조]` 수
- 타격 수와 복합 행동 구성
- 비용 감소
- 중단·반격 권한

이 값들은 기술·성취 patch·스테이터스 임계 효과에서 명시적으로만 바꿀 수 있다. 스테이터스 1점마다 자동 증가하지 않는다.

## 4. 능력치 참조 대상

고정 전용 효과가 아닌 수치 결과는 관련 스테이터스를 참조한다.

- 외가 피해·강공·밀치기·방어 파괴: 주로 외공
- 방어도·체력·버티기: 주로 근골
- 내가 피해·내력·호신·회복: 주로 내공
- 간파·반격·전조 대응 수치: 주로 심안
- 신법 계열의 연속 보정 가능한 수치: 신법

`주로`는 기본 매핑이며, 복합 무공은 주·보조 스테이터스를 명시할 수 있다. 참조 없이 최종 숫자만 기록한 신규 피해·방어·회복·자원 기술은 검증 실패다.

## 5. 기술 점수표 ledger

기술의 총 틱은 다음 구성으로 계산한다.

```text
총 틱
= 행동 구조·사거리·이동·타격 틱
+ 태그 틱
+ 고정 기본치 틱
+ 스테이터스 참조 배수 틱
+ 조건·비용 크레딧
```

각 ledger 행은 최소 다음을 가진다.

```yaml
component_id: stable component id
source_table: pricing_ticks | condition_credits | stat_reference_pricing
price_id: stable price id
quantity: integer or snapped authoring unit
derived_ticks: price × quantity
```

- 같은 효과의 고정 기본치와 스테이터스 참조 배수를 한 항목으로 합치지 않는다.
- 태그 비용과 태그가 발생시키는 수치 비용을 중복·누락하지 않는다.
- 중앙 가격 변경은 기존 기술을 자동 수정하지 않고 편차 보고만 생성한다.
- 5·9성 기본 강화와 임계 효과도 별도 ledger를 가진다.

## 6. 현재 누락과 권위 경계

현재 `poc_balance_budget.json`에는 고정 수치·태그·조건·비용 가격은 존재하지만 **스테이터스 참조 배수의 중앙 가격 항목이 없다**.

따라서 다음은 아직 확정하지 않는다.

- 스테이터스 배수 1단위당 틱 가격
- 주·보조 스테이터스의 가격 차이
- 속공·강공·장풍의 정확한 고정 피해와 배수
- 소수 배수 허용 단위와 최종 반올림

기존 `poc_martial_arts.json`의 `ABSOLUTE_RAW_POWER` 기술은 비교·편집용 `POC_HYPOTHESIS`이며, 이 Decision의 능력치 참조 계약을 충족한 최신 공식이 아니다.

## 7. 검증 요구

1. 신규 기술이 행동 구조·태그·고정 기본치·스테이터스 참조를 분리 기록함.
2. 관찰·이동·회피·준비의 기본 효과에 연속 스테이터스 계수를 붙이지 않음.
3. 신규 피해·방어·회복·자원 효과가 최소 1개 스테이터스를 참조함.
4. 한 효과가 최대 주1·보조1의 두 스테이터스만 참조함.
5. 속공·강공은 외공, 장풍은 내공 참조를 기록함.
6. 태그·고정치·스테이터스 배수·조건·비용이 별도 ledger 행으로 재계산됨.
7. 스테이터스 참조 가격표가 없는 상태에서 임의 배수를 구현 승인으로 오인하지 않음.

## 8. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
authoring_layers:
  - structure_and_cost
  - tags
  - fixed_base_value
  - primary_secondary_stat_reference
  - mastery_patch_and_threshold
fixed_only_effects:
  - observation
  - movement
  - dodge
  - strengthen
non_fixed_effect_requires_stat_reference: true
maximum_stat_references_per_effect: 2
score_ledger_separates_tag_fixed_stat: true
stat_reference_price_table: MISSING_TBD
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 9/10
```
