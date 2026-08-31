# 7성·9성 무공 숙련 보너스 결정

- Decision ID: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`
- 승인일: 2026-08-05
- 상태: `CURRENT_APPROVED_PLANNING_GOVERNANCE`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 승인 배치: `10/10`
- 상세 계약: `docs/planning-data/approved_20260805_star7_star9_mastery_bonus_contract.json`

## 1. 승인 결론

무공 성장의 원칙을 **가치 상위호환·역할 비대체**로 확정한다.

- 3성 기술1은 무공의 기본 운용법이다.
- 5성은 기술1의 기존 역할을 무료로 강화한다.
- 7성 기술2는 같은 무공의 원리를 다른 전술 역할로 응용하며, 현행 기술2 유효 예산에 숙련 보너스 `+10틱`을 받는다.
- 9성은 기술2를 상황별로 분기하지 않는다. 기술2마다 단일 완성 보너스 효과 하나만 추가하며 예산은 `10틱 + 7성 최종 예산의 20% 내림`이다.
- 10성은 별도 고유 절초다.

기술2는 기술1보다 높은 총가치를 가질 수 있지만 기술1과 같은 발동 시점·전술 목적을 수행해 전 상황에서 대체하면 실패다.

## 2. 예산 원본

7성 계산은 역사 기술2 계약이 아니라 현행 repricing overlay의 `category=technique_2`, `available_budget_ticks`를 읽는다.

| 기술2 | 현행 기준 예산 | 7성 최종 `+10` |
|---|---:|---:|
| 낙영추검 | 65 | 75 |
| 반진권 | 65 | 75 |
| 사량발천근 | 66 | 76 |
| 연환쇄로 | 75 | 85 |
| 회기전맥 | 61 | 71 |
| 십보환위 | 96 | 106 |

## 3. 9성 예산

```text
star9_bonus_ticks
= 10 + floor(star7_final_budget_ticks × 0.20)

star9_total_budget_ticks
= star7_final_budget_ticks + star9_bonus_ticks
```

| 기술2 | 7성 최종 | 9성 추가 | 9성 누적 최종 |
|---|---:|---:|---:|
| 낙영추검 | 75 | 25 | 100 |
| 반진권 | 75 | 25 | 100 |
| 사량발천근 | 76 | 25 | 101 |
| 연환쇄로 | 85 | 27 | 112 |
| 회기전맥 | 71 | 24 | 95 |
| 십보환위 | 106 | 31 | 137 |

20% 항은 정수 틱으로 내림한다.

## 4. 9성 단순화 계약

각 9성 기술2에는 다음을 적용한다.

- 완성 보너스 효과 정확히 하나.
- 상황별 분기·공개 trigger·우선순위 목록 없음.
- 행동 해결 중 추가 입력·버튼·선택 없음.
- 추가 기력·내력·절초기세 비용 없음.
- 복수 효과·다중 보너스 중첩 없음.
- 카드 설명 한 문장.
- 기술2 핵심 역할 변경 금지.
- 기술1 역할 복제·전 상황 대체 금지.
- 거리·순서·합·회피·중단 실패를 자동으로 지우는 정답 효과 금지.

## 5. 미승인 범위

이번 Decision은 공통 예산과 작성 템플릿만 승인한다.

- 여섯 7성 `+10틱` 실제 효과 배분: `PENDING_SEPARATE_GRILLME_DECISION`.
- 여섯 9성 단일 완성 효과: `PENDING_SEPARATE_GRILLME_DECISION`.
- 10성 절초 효과: 미승인.

기존 7성 기술2의 효과·비용·조건을 이 Decision만으로 자동 변경하지 않는다.

## 6. 후속 순서

```text
SIX_STAR7_MASTERY_BONUS_ALLOCATIONS
→ SIX_STAR9_SINGLE_COMPLETION_BONUSES
→ SIX_STAR10_UNIQUE_ULTIMATES
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

10/10 체크포인트를 닫은 뒤 새 승인 배치에서 후속 효과를 개별 검토한다.

## 7. 검증 경계

- 제품 코드·Godot Scene·HTML PoC·런타임 데이터 변경 없음.
- 자동 계약·회귀 검증만 수행한다.
- Godot·Windows·접근성·성능·사람·밸런스 검증은 `NOT_RUN`이다.
