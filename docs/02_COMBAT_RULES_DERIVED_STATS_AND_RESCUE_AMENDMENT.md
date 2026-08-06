# 전투 규칙 개정 — 파생 스탯과 잘못된 계획 구제

- 권위: `TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01`
- 부모: `docs/02_COMBAT_RULES.md`
- 적용 범위: 파생 수치·반사실 검증·구제 분류
- 런타임 상태: `NOT_IMPLEMENTED`

## 1. 파생 공식

```text
최대 체력 = 26 + 근골
최대 기력 = 4 + floor(신법 / 4)
최대 내력 = 3 + floor(내공 / 4)
```

| 스탯 | 1 | 4 | 8 | 12 | 15 | 20 |
|---|---:|---:|---:|---:|---:|---:|
| 최대 체력 | 27 | 30 | 34 | 38 | 41 | 46 |
| 최대 기력 | 4 | 5 | 6 | 7 | 7 | 9 |
| 최대 내력 | 3 | 4 | 5 | 6 | 6 | 8 |

핵심 스탯은 무상한이다. 기력·내력 최대치는 `4, 8, 12, 16, 20...`마다 1 증가하며 15에서 멈추지 않는다.

최대치가 증가해도 현재 체력·기력·내력은 즉시 증가하지 않는다. 전투 중 최대치가 변할 경우 이미 받은 피해와 소비량을 보존한다.

## 2. 스탯 책임

- 외공: 성공한 외공 피해와 명시된 방어 파괴량.
- 근골: 성공한 방어 행동·방어 기술의 방어량과 최대 체력.
- 신법: 명시된 신법 수치와 최대 기력.
- 내공: 내공 공격·회복·보호·상태 안정화와 최대 내력.
- 심안: 합 위력과 공개 정보를 정확히 읽은 뒤의 명시된 보상.

방어 행동이 없으면 근골은 상시 피해 감소를 제공하지 않는다. 심안은 미공개 계획·AI 가중치·정답 대응을 공개하거나 틀린 대응을 자동 교체하지 않는다.

## 3. 구조값

다음은 스탯 점당 연속 증가하지 않는다.

- 이동거리.
- 공격 사거리.
- 행동 슬롯.
- 타격 수.
- 회피 횟수.
- 대상 지정 권한.
- 확정 명중.
- 숨은 계획 접근.

구조값은 성급·기술 패치·명시적 임계값 Decision에서만 변경한다.

## 4. 적용 순서

```text
LEGALITY
→ DISTANCE_ORDER_MOVEMENT_INTERRUPTION
→ SUCCESS_GATES
→ STAT_NUMERIC_ADJUSTMENT
→ COUNTERFACTUAL_REPLAY
→ RESCUE_CLASSIFICATION
```

사거리 밖 공격이나 중단된 행동은 외공이 높아도 피해를 만들지 않는다. 방어 행동이 없으면 근골 방어 보정이 없다.

## 5. 반사실 비교

actual과 reference는 플레이어 계획·상대의 잠긴 계획·대상·위치·상태·난수 시드와 소비 순서를 동일하게 유지한다. reference의 핵심 스탯만 모두 4로 고정한다.

```text
missing_health = actual_max_health - actual_current_health
reference_current_health = clamp(reference_max_health - missing_health, 0, reference_max_health)

spent_stamina = actual_max_stamina - actual_current_stamina
reference_current_stamina = clamp(reference_max_stamina - spent_stamina, 0, reference_max_stamina)

spent_internal = actual_max_internal - actual_current_internal
reference_current_internal = clamp(reference_max_internal - spent_internal, 0, reference_max_internal)
```

## 6. 구제 분류

`OUTCOME_REVERSAL`을 먼저 판정한다.

- 기준 결과가 실패·패배·사망이고 실제 결과가 성공·승리·생존이면 결과 역전.
- 결과 역전이 아니면서 체력 손실이 50% 이상 줄거나 실패 심각도가 2단계 이상 줄면 중대 구제.
- 두 분류는 중복 집계하지 않는다.

실패 심각도:

| 단계 | 정의 |
|---:|---|
| 0 | 핵심 결과 달성·중대한 손실 없음 |
| 1 | 기준 최대 체력25% 미만 손실 또는 경미한 자원 손실 |
| 2 | 체력25~50% 손실·핵심 조건 실패·다음 고비용 행동1개 불가 |
| 3 | 행동 중단·체력50% 이상 손실·후속 계획2개 이상 붕괴 |
| 4 | 패배·사망·전투 지속 불가 |

## 7. 역사 PoC 공격력

`data/combat/combat_hud_preview.json`의 `attack_power: 8`은 화면·과거 실행 재현용 역사 필드다. 현행 피해 공식에서는 사용하지 않는다.

```text
구형 attack_power + 행동별 스탯 계수
= DOUBLE_SCALING_CONFLICT
```

제품 데이터 자체는 Build 승인 전 수정하지 않는다.
