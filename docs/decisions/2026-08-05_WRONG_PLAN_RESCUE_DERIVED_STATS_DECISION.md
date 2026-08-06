# 잘못된 계획 구제·파생 스탯 결정

- Decision ID: `TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01`
- 승인일: 2026-08-05
- 상태: `CURRENT_APPROVED_PLANNING_GOVERNANCE`
- 위험 상태: `MITIGATED_PENDING_HUMAN_MEASUREMENT`
- 부모: `TEN-DEC-20260803-UNCAPPED-CORE-STATS-01`, `TEN-DEC-20260802-STAT-REFERENCE-PRICE-BASE4-01`
- 선행 stacked Decision: `TEN-DEC-20260805-CONDITION-CALIBRATION-01`
- 상세 계약: `docs/planning-data/approved_20260805_wrong_plan_rescue_derived_stats_contract.json`
- 제품 런타임: `NOT_IMPLEMENTED`

## 1. 승인 결론

성장은 올바른 거리·순서·대응·자원 계획을 강화한다. 스탯은 사거리 밖 공격, 대응 누락, 잘못된 순서, 숨은 계획 오독 같은 구조적 실패를 성공으로 바꾸지 않는다.

잘못된 계획 구제는 서로 중복되지 않는 두 사건으로 나눈다.

- `OUTCOME_REVERSAL`: 기준 스탯4의 실패·패배·사망이 현재 스탯에서 성공·승리·생존으로 바뀜.
- `MAJOR_RESCUE`: 결과 역전은 아니지만 체력 손실이 50% 이상 줄거나 실패 심각도가 2단계 이상 완화됨.

결과 역전을 먼저 판정하며 중대 구제와 중복 집계하지 않는다.

## 2. 파생 수치

```text
max_health = 26 + constitution
max_stamina = 4 + floor(agility / 4)
max_internal = 3 + floor(internal_power / 4)
```

기준 스탯4의 파생값은 `체력30·기력5·내력4`다. 핵심 스탯은 무상한이며 기력·내력 임계값은 `4,8,12,16,20...`에서 계속 증가한다.

| 스탯 | 연속 파생 수치 | 금지되는 자동 구제 |
|---|---|---|
| 외공 | 명시된 외공 피해·방어 파괴 | 사거리·명중·타격 수 증가 |
| 근골 | 명시된 방어 효과·최대 체력 | 방어 행동 없는 상시 피해 감소 |
| 신법 | 명시된 신법 수치·최대 기력 | 이동·회피 횟수·행동 우선권 연속 증가 |
| 내공 | 내공 피해·회복·보호·안정화·최대 내력 | 최대치 상승 시 현재 내력 충전 |
| 심안 | 합 위력·공개 정보 판독 성공 보상 | 숨은 계획·AI 가중치·정답 대응 공개 |

## 3. 해결 순서

```text
합법성
→ 거리·순서·이동·중단
→ 적중·방어·회피·합·조건 성공
→ 성공한 효과의 스탯 수치 보정
→ 동일 계획·상대 계획·난수의 기준 스탯4 재계산
→ 결과 역전·중대 구제·올바른 계획 증폭 분류
```

스탯 보정은 앞 단계의 구조적 실패를 우회하지 않는다.

## 4. 반사실 정규화

기준 스탯4 재계산에서는 이미 받은 피해와 이미 소비한 자원을 보존한다.

```text
reference_current_health = clamp(reference_max_health - missing_health, 0, reference_max_health)
reference_current_stamina = clamp(reference_max_stamina - spent_stamina, 0, reference_max_stamina)
reference_current_internal = clamp(reference_max_internal - spent_internal, 0, reference_max_internal)
```

최대치 차이를 무료 회복이나 추가 피해로 해석하지 않는다.

## 5. 구형 공격력 생명주기

`data/combat/combat_hud_preview.json`의 `attack_power: 8`은 역사 PoC 표시로 보존하지만 현행 공식 권위에서는 `[대체됨]`이다.

각 행동은 `fixed_base_value + declared stat coefficient`를 직접 선언한다. 구형 통합 공격력을 다시 더하면 `DOUBLE_SCALING_CONFLICT`다.

## 6. 측정 지표

- `wrong_plan_outcome_reversal_rate`
- `wrong_plan_major_rescue_rate`
- `correct_plan_amplification_rate`

사람 플레이 전에는 목표 임계값을 확정하거나 재미·밸런스 PASS를 주장하지 않는다.

## 7. 권위 경계

유지:

- 핵심 스탯 무상한 정책.
- 기준 스탯4 가격 체계.
- 기존 기본 행동·기술의 승인 계수.
- 구조값의 연속 스탯 성장 금지.

이번 Decision이 소유:

- 파생 체력·기력·내력 공식.
- 스탯별 허용 연속 출력과 금지 자동 구제.
- 반사실 비교·정규화·구제 분류.
- 구형 통합 공격력의 공식 권위 대체.

## 8. 검증 경계

```yaml
static_validation: PASS_REQUIRED
human_validation: NOT_RUN
balance_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
performance_validation: NOT_RUN
```

다음 위험은 `OBSERVATION_ANSWER_LEAK_RISK`다.
