# 잘못된 계획 구제·파생 스탯 체계 설계

- 설계 승인일: 2026-08-05
- 제안 Decision ID: `TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01`
- 부모 브랜치: PR #91 exact head `ffdbd385abb75b0f314400601c7a3120acc616e9`
- 상태: `USER_APPROVED_DESIGN_PENDING_IMPLEMENTATION_PLAN`
- 제품 런타임: `NOT_IMPLEMENTED`

## 1. 목표

성장은 올바른 거리·순서·대응·자원 계획을 더 강하게 만들어야 한다. 높은 능력치가 사거리 실패, 대응 누락, 불리한 합, 자원 오판 같은 잘못된 계획을 자동으로 올바른 계획으로 바꾸면 안 된다.

동시에 공격력·방어력·최대 체력·최대 기력·최대 내력 등 핵심 전투 수치는 다섯 핵심 스탯과 명시적으로 연결되어야 한다.

## 2. 승인된 잘못된 계획 구제 분류

잘못된 계획 구제를 한 지표로 합치지 않고 두 단계로 분리한다.

### 2.1 결과 역전

기준 스탯4에서는 실패·패배·행동 전 사망이지만, 동일 계획·동일 상대 계획·동일 난수에서 현재 능력치 때문에 성공·승리·생존으로 바뀐 경우다.

### 2.2 중대 구제

최종 성공·실패 분류는 바뀌지 않았지만, 현재 능력치가 잘못된 계획의 손실을 기준 결과보다 지나치게 줄인 경우다.

중대 구제는 다음 중 하나를 만족하고 결과 역전에는 해당하지 않는 사건이다.

- 체력 손실이 기준 결과보다 50% 이상 감소.
- 실패 심각도 단계가 2단계 이상 완화.
- 기준 결과의 중단·큰 피해·자원 붕괴가 현재 결과에서 사실상 무의미해짐.

결과 역전은 중대 구제와 중복 집계하지 않는다.

### 2.3 실패 심각도 단계

반사실 비교에서 다음 단계를 사용한다.

| 단계 | 정의 |
|---:|---|
| 0 | 의도한 핵심 결과 달성, 중대한 손실 없음 |
| 1 | 기준 최대 체력의 25% 미만 손실 또는 경미한 자원 손실, 행동 자체는 유효 |
| 2 | 기준 최대 체력의 25% 이상 50% 미만 손실, 핵심 조건 실패, 또는 다음 고비용 행동 1개가 불가능해짐 |
| 3 | 행동 중단·무효화, 기준 최대 체력의 50% 이상 손실, 또는 후속 계획 2개 이상이 자원 붕괴로 무효화 |
| 4 | 패배·사망·전투 지속 불가 |

현재 결과의 단계가 기준 결과보다 2 이상 낮아졌다면 중대 구제 후보로 기록한다.

## 3. 반사실 비교 계약

각 검증 대상 행동 묶음은 두 번 해결한다.

```text
actual_result
= 현재 유효 스탯 + 확정된 플레이어 계획 + 잠긴 상대 계획 + 동일 난수

reference_result
= 모든 비교 대상 핵심 스탯을 4로 고정
  + 나머지 상태·계획·난수 동일
```

고정해야 하는 값:

- 행동 카드와 배치 순서.
- 대상·거리·위치.
- 확정 시점 상태 이상과 비스탯 버프·디버프.
- 잠긴 상대 행동 묶음.
- 난수 시드와 난수 소비 순서.
- 조건 trigger와 해결 순서.

변경 가능한 값은 핵심 스탯과 그 스탯에서 직접 파생되는 연속 수치·최대치뿐이다.

### 3.1 체력·자원 풀 정규화

기준 스탯4의 최대치가 실제 최대치보다 낮아질 수 있으므로 현재값을 그대로 복사하지 않는다. 이미 받은 피해와 이미 소비한 자원량을 보존한다.

```text
missing_health = actual_max_health - actual_current_health
reference_current_health
= clamp(reference_max_health - missing_health, 0, reference_max_health)

spent_stamina = actual_max_stamina - actual_current_stamina
reference_current_stamina
= clamp(reference_max_stamina - spent_stamina, 0, reference_max_stamina)

spent_internal = actual_max_internal - actual_current_internal
reference_current_internal
= clamp(reference_max_internal - spent_internal, 0, reference_max_internal)
```

비스탯 직접 최대치 보너스는 actual과 reference 양쪽에 동일하게 적용한 뒤 위 정규화를 수행한다. 최대치 차이를 무료 회복이나 추가 피해로 해석하지 않는다.

## 4. 잘못된 계획 판정

### 4.1 기계 판정 가능

- `PUBLIC_RANGE_MISMATCH`: 확정 시 공개 정보만으로도 사거리 성공 불가.
- `PUBLIC_RESOURCE_OVERCOMMIT`: 확정 시 공개 정보상 비용 지불 불가 또는 후속 계획 붕괴가 확정.
- `PUBLIC_ORDERING_MISMATCH`: 공개된 해결 규칙상 원하는 대응보다 늦음.
- `MISSING_DEFENSE_RESPONSE`: 공개된 유효 위협에 방어·회피·중단 대응을 두지 않음.
- `CONDITION_PUBLICLY_IMPOSSIBLE`: 공개 상태에서 조건 성공 불가.

### 4.2 공개 후 판정

- `PREDICTION_MISS`: 잠긴 상대 계획 공개 후 예상 범주가 불일치.
- `COUNTER_SELECTION_MISS`: 선택한 대응이 실제 상대 행동 범주와 맞지 않음.
- `POSITION_READ_MISS`: 상대 이동을 잘못 읽어 거리 계획 실패.

공개 후 판정은 replay reason code와 사람 검토로 확인하며, AI의 내부 가중치나 미공개 계획을 확정 전에 사용하지 않는다.

## 5. 핵심 KPI와 가드레일

### 5.1 결과 역전률

```text
wrong_plan_outcome_reversal_rate
= 결과 역전 수 / 유효한 잘못된 계획 사건 수
```

### 5.2 중대 구제율

```text
wrong_plan_major_rescue_rate
= 중대 구제 수 / 유효한 잘못된 계획 사건 수
```

### 5.3 올바른 계획 증폭률

```text
correct_plan_amplification_rate
= 현재 스탯이 올바른 계획의 보상을 증가시킨 사건 수
  / 유효한 올바른 계획 사건 수
```

### 5.4 즉시 실패 가드레일

다음은 표본 크기와 무관하게 허용하지 않는다.

- 능력치가 사거리 밖 공격을 적중으로 바꿈.
- 능력치가 이동거리·사거리·행동 슬롯·타격 수·회피 횟수를 점당 연속 증가시킴.
- 방어 행동 없이 근골이 상시 피해를 무효화함.
- 심안이 미공개 상대 계획·AI 가중치·정답 대응을 공개함.
- 최대 자원 증가가 현재 자원을 즉시 채움.
- 구형 통합 공격력과 개별 기술 스탯 계수가 동시에 적용됨.

사람 플레이 전 재미·밸런스 PASS는 주장하지 않는다.

## 6. 다섯 핵심 스탯과 파생 수치

핵심 스탯은 `외공·근골·신법·내공·심안`을 유지한다. 핵심 스탯 자체는 무상한이지만 구조적 파생값은 연속 성장하지 않는다.

### 6.1 외공

외공은 외공 계열 행동의 연속 피해·명시된 방어 파괴량에만 적용한다.

```text
final_external_effect
= floor(fixed_base_value + external_power * declared_coefficient)
```

외공은 사거리·명중·타격 수·행동 슬롯을 늘리지 않는다.

### 6.2 근골

근골은 성공한 방어 행동·방어 기술의 방어량과 최대 체력에 연결한다.

```text
max_health = 26 + constitution

final_defense_effect
= floor(fixed_base_value + constitution * declared_coefficient)
```

기준 근골4에서 최대 체력30을 유지한다. 근골은 방어 행동이 없을 때 상시 피해 감소를 제공하지 않는다.

### 6.3 신법

신법은 신법 기술의 명시된 연속 수치와 최대 기력에 연결한다.

```text
max_stamina = 4 + floor(agility / 4)
```

기준 신법4에서 최대 기력5다. 최대치 증가 시 현재 기력은 증가하지 않는다. 이동거리·회피 횟수·행동 우선권·확정 회피는 명시적 성급/기술 임계값에서만 바뀐다.

### 6.4 내공

내공은 내공 공격·회복·보호·상태 안정화의 명시된 연속 수치와 최대 내력에 연결한다.

```text
max_internal = 3 + floor(internal_power / 4)
```

기준 내공4에서 최대 내력4다. 최대치 증가 시 현재 내력은 증가하지 않는다. 묶음 전환 내력 자동 회복은 계속 0이며, 명상·청심조식·승인 조건부 효과만 내력을 회복한다.

### 6.5 심안

심안은 합 위력, 공개 정보를 정확히 읽은 뒤의 조건부 보상, 반격 성공 뒤의 명시된 수치에만 적용한다.

심안은 다음을 제공하지 않는다.

- 미공개 계획 열람.
- AI 가중치 열람.
- 틀린 대응의 자동 교체.
- 무조건 합 승리·반격·회피.

## 7. 공격력 표시와 구형 통합 공격력

현재 HUD의 `attack_power: 8`은 역사 PoC 표시이며 현행 파생 수치 권위로 사용하지 않는다.

새 체계에서 공격력은 하나의 범용 배율이 아니다. 각 행동은 다음을 직접 선언한다.

```text
fixed_base_value
primary_stat
primary_coefficient
optional_secondary_distinct_effect
```

UI의 공격력 표시는 선택한 행동의 예상 최종값 또는 외공/내공별 요약값으로 계산한다. 구형 `attack_power`를 기술 공식에 다시 더하면 `DOUBLE_SCALING_CONFLICT`다.

## 8. 적용 순서

```text
1. 행동 합법성 검사
2. 거리·순서·이동·중단 해결
3. 적중·방어·회피·합·조건 성공 Gate 해결
4. 성공한 효과에만 스탯 보정
5. 실제 결과 기록
6. 동일 상태를 기준 스탯4로 반사실 재계산
7. 결과 역전·중대 구제·올바른 계획 증폭 분류
```

스탯은 1~3단계의 구조적 실패를 우회하지 않는다.

## 9. 현업 벤치마크

### Diablo IV 공식 개발 업데이트

Blizzard는 핵심 스탯이 공격·방어의 복수 효과를 제공하고, 특정 스탯 임계값에서 추가 노드 효과가 열리는 구조를 설명했다. 본 설계는 연속 수치와 4점 단위 자원 최대치 임계값을 분리하는 근거로 참고한다.

- https://news.blizzard.com/en-us/article/23583664/diablo-iv-quarterly-updatedecember-2020

### Diablo Immortal 공식 아이템 설계

Blizzard는 Damage·Armor·Life 같은 파생 수치를 분리하고 Strength·Intelligence·Fortitude·Vitality 등의 속성이 명시적으로 연결되도록 설명한다. 본 설계는 공격·방어·체력·자원을 숨은 통합 수치가 아니라 명시적 파생값으로 관리하는 근거로 참고한다.

- https://news.blizzard.com/en-us/article/23574266/itemization-in-diablo-immortal

### 과잉 스케일링 경고

Diablo IV 패치 노트는 무기 핵심 스탯 보너스가 과도하게 성능을 내어 하향됐다고 명시한다. 본 설계는 한 스탯이 구조 성공과 수치 효율을 동시에 과도하게 강화하지 않도록 즉시 실패 가드레일과 반사실 검증을 둔다.

- https://news.blizzard.com/en-us/article/24092662/diablo-iv-patch-notes-1-0-1-2

벤치마크의 임계값·수치를 복사하지 않고, 십보강호의 관찰·추론·비공개 계획·복기 코어에 맞게 적용한다.

## 10. 권위와 생명주기

- `approved_20260803_uncapped_core_stats_contract.json`: 핵심 스탯 무상한 정책 유지.
- `approved_20260802_stat_reference_price_base4_contract.json`: 기준 스탯4와 효과별 계수 가격 유지.
- 새 계약: 파생 수치 공식·잘못된 계획 반사실 검증·가드레일을 소유.
- `data/combat/combat_hud_preview.json`의 `attack_power: 8`: `[대체됨]` 역사 PoC 필드 후보.
- 제품 런타임·Godot·HTML PoC·런타임 데이터는 별도 Build 승인 전 변경하지 않는다.

## 11. TDD 구현 범위

RED에서 먼저 고정할 회귀 항목:

1. 기준 스탯4에서 체력30·기력5·내력4.
2. 근골1/4/8/12/15 체력 결과 27/30/34/38/41.
3. 신법1/4/8/12/15 기력 결과 4/5/6/7/7.
4. 내공1/4/8/12/15 내력 결과 3/4/5/6/6.
5. 최대치 증가 시 현재 자원 무충전.
6. 반사실 비교에서 받은 피해·소비 자원량 보존.
7. 사거리 밖 공격은 외공이 높아도 실패.
8. 방어 행동이 없으면 근골 방어 보정 0.
9. 구형 통합 공격력과 기술 계수 중복 적용 거부.
10. 동일 계획·난수 반사실 재계산의 결정성.
11. 결과 역전과 중대 구제의 상호 배타 집계.
12. 실패 심각도 2단계 완화 판정.
13. 올바른 계획 증폭은 구제로 집계하지 않음.
14. 심안의 미공개 계획 접근 거부.

## 12. 검증 경계

```yaml
static_validation: REQUIRED
human_validation: NOT_RUN
balance_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
performance_validation: NOT_RUN
```
