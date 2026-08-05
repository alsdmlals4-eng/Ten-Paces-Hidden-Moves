# 십보강호 정본 생명주기 등록부

- 기반 권위: `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`
- 현행 성장 권위: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`
- 7성·9성 예산 부모: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`
- 위험 완화: `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`, `TEN-DEC-20260805-CONDITION-CALIBRATION-01`, `TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01`, `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`, `TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01`
- 작업 운영: `TEN-DEC-20260805-WORK-GOVERNANCE-01`
- 기준 main: `bbed0fd4d278ca0e0d52f4e6d9083aafa1997318`

## 상태 정의

| 표시 | 의미 | 허용 사용 |
|---|---|---|
| `[현행]` | 현재 기획·검증 권위 | 후속 작성·구현 인계·검증 |
| `[대체됨]` | 새 Decision이 권위 인수 | 역사·migration·회귀 증거 |
| `[보류]` | 증거 보존·진행 중지 | 명시적 재개 전 참고만 |
| `[폐기]` | 현재·역사 가치 없음 | 참조 금지 |

## `[현행]` 권위

| 분야 | 권위 |
|---|---|
| 활성 상태 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` |
| 로드맵 | `docs/04_ROADMAP.md` |
| 전투 부모 | `docs/02_COMBAT_RULES.md` |
| 자원 회복 개정 | `docs/02_COMBAT_RULES_RESOURCE_RECOVERY_AMENDMENT.md` |
| 조건 난도 개정 | `docs/02_COMBAT_RULES_CONDITION_CALIBRATION_AMENDMENT.md` |
| 파생 스탯·오판 구제 개정 | `docs/02_COMBAT_RULES_DERIVED_STATS_AND_RESCUE_AMENDMENT.md` |
| 관찰 직접 공개 개정 | `docs/02_COMBAT_RULES_OBSERVATION_GUARDRAILS_AMENDMENT.md` |
| 등급 파밍 방지 개정 | `docs/02_COMBAT_RULES_GRADE_FARMING_GUARDRAILS_AMENDMENT.md` |
| 7성·9성 예산 부모 개정 | `docs/02_COMBAT_RULES_STAR7_STAR9_MASTERY_BONUS_AMENDMENT.md` |
| 초기 무공서 10권 전투 해결 개정 | `docs/02_COMBAT_RULES_TEN_RECOGNIZABLE_MARTIAL_MANUALS_AMENDMENT.md` |
| 초기 무공서 10권 읽기 카탈로그 | `docs/03_TEN_MARTIAL_MANUALS_CATALOG.md` |
| 거리·중단·예산 부모 | `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01` |
| 기존 행동 비용·기술2 유효 예산 | `TEN-DEC-20260804-EXISTING-ACTIONS-REPRICE-01` |
| 기술1 효과·조건·5성 | `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01` |
| 7성·9성 예산 부모·단일 효과 템플릿 | `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01` |
| 초기 10권 문파·능력치 적합성·3/5/7/9/10성 성장 | `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01` |
| 묶음 내력 회복 최종값 | `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01` |
| 조건 측정·재분류 | `TEN-DEC-20260805-CONDITION-CALIBRATION-01` |
| 파생 수치·오판 구제 측정 | `TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01` |
| 관찰 직접 공개·정답 유출 측정 | `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01` |
| 등급 원시/유효 분리·반복 감쇠·경제 Gate | `TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01` |
| 배치·체크포인트·TDD·벤치마킹 | `TEN-DEC-20260805-WORK-GOVERNANCE-01` |

현행 contracts:

- `approved_20260804_combat_pricing_interruption_recovery_contract.json`
- `approved_20260804_resource_saturation_internal_recovery_contract.json`
- `approved_20260804_existing_action_reprice_contract.json`
- `approved_20260804_technique1_conditional_rework_star5_contract.json`
- `approved_20260805_condition_calibration_contract.json`
- `approved_20260805_wrong_plan_rescue_derived_stats_contract.json`
- `approved_20260805_observation_answer_leak_guardrails_contract.json`
- `approved_20260805_grade_farming_guardrails_contract.json`
- `approved_20260805_star7_star9_mastery_bonus_contract.json`
- `approved_20260806_ten_recognizable_martial_manuals_contract.json`
- `approved_20260806_ten_manual_growth_budget_overlay_contract.json`
- `approved_20260805_work_governance_contract.json`

## `[대체됨]`

| 대상 | 대체 권위 | 허용 사용 |
|---|---|---|
| 부모 `bundle_transition_recovery.internal=1` | 자원 포화 Decision | 과거 재현만 |
| `docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md` | 전투 가격 Decision | 과거 ledger만 |
| 2026-08-03 기술1 효과 Decision·contract | 2026-08-04 기술1 Decision | 역사·migration만 |
| 역사 기술2 계약의 구형 `available_budget_ticks` | 기존 행동 repricing + 7/9성 숙련 Decision | 기본 효과 근거만; 현행 예산 금지 |
| 9성 공개 정보 자동 분기 가설 | 7/9성 숙련 Decision | 역사적 설계 검토만 |
| `data/combat/combat_hud_preview.json`의 `attack_power: 8` 공식 권위 | 파생 스탯 Decision | 역사 PoC 표시·재현만 |
| PR #90과 비최종 condition-calibration branch | PR #91 | 오류 추적만 |

## `[보류]`

| 대상 | 상태 | 재개 조건 |
|---|---|---|
| GitHub PR #85 HTML Technique1 PoC | 닫힘·병합 금지·제품 권위 없음 | 명시적 재개 승인 |
| PR #85 테스트 결과 | 역사 참고 | 최신 계약 재작성·재검증 |
| 초기 10권 런타임 구현 | 기획·예산 승인, 제품 미구현 | `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE` 승인 |
| 최종 등급 가중치·체력 정규화·라운드 감점·S/A/B/C 컷 | 원자료·파밍 방지 선확정 | 사람 표본과 별도 GrillMe |
| 등급 기반 재화·수련·드롭·영구재화 보상 | 사람 검증 전 금지 | 30승·5상대·표본 집중40% 이하와 새 Decision |

## `[폐기]`

현재 없음.

## PR 계보

| PR | 상태 |
|---:|---|
| #84 | `[병합됨]` `81765e35c179b7a57eaa527a307080b63c32f0b8` |
| #86 | `[병합됨]` `731e6431e76ebc76841f9253e87cd1e7a693ebb2` |
| #87 | `[병합됨]` `0ba841ff2e62b2f716466356dd9e7ffcf587d150` |
| #88 | `[병합됨]` `bbed0fd4d278ca0e0d52f4e6d9083aafa1997318` |
| #89 | Draft·자원 포화 완화 |
| #90 | `[대체됨]` 닫힘 |
| #91 | Draft·부모 #89·조건 보정·작업 운영 |
| #92 | Draft·부모 #91·파생 스탯·관찰·등급·7/9성 예산 부모·초기 무공서 10권·현재 배치9/10 |
| #85 | `[보류]` HTML PoC |

## `CANON_CONFLICT`

- 현행 repricing overlay 없이 역사 기술2 예산을 7성 기준으로 사용.
- 7성 숙련 보너스를 +10틱 이외 값으로 적용.
- 9성 20% 항을 반올림·올림하거나 7성 최종 예산이 아닌 다른 기준에 적용.
- 9성에 상황별 분기·공개 trigger·우선순위·추가입력·추가비용·복수 효과를 추가.
- 7성·9성이 기술1 역할을 복제해 전 상황에서 대체.
- 숙련 보너스로 거리·순서·합·회피·중단 실패를 자동 삭제.
- 2026-08-06 계약을 무시하고 구형 6권 이름·능력치·미승인 상태를 현행으로 사용.
- 능력치별 무공서 권수·균등 분포·쿼터를 강제해 문파·무학 적합성을 왜곡.
- `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE` 전에 10권 제품 런타임 데이터를 생성.
- 부모 내력 자동회복1을 overlay 없이 현행값으로 사용.
- 조건 성공률에 따라 자동·실시간 repricing.
- 공개상 불가능한 사용을 가격 분모에 포함.
- 스탯이 구조 실패·숨은 계획 접근을 우회.
- 구형 `attack_power: 8`을 행동별 스탯 계수에 다시 더함.
- 원시 합·회피·절초 로그 자체를 등급 감쇠로 삭제·축소.
- 같은 적 공격 행동 인스턴스가 합·회피 합계1.0을 초과해 등급에 반영.
- 기준 라운드 이후 합·회피·절초 양의 반영량을 계속 누적.
- 사람 검증·새 Decision 전에 등급을 경제에 연결.
- 승인10건 초과 배치를 분리하지 않음.
- RED 없이 구현하거나 문서 작업을 TDD 예외로 처리.
- `[대체됨]`·`[보류]` 자료를 현행 제품 권위로 사용.
- `IMPLEMENTED_LEGACY`를 최신 계획 구현 완료로 표시.
- 실행하지 않은 검증을 PASS로 표시.

## 다음 Gate

`TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`가 다음 Decision이다. 현재 승인 배치는 `9/10`이다.

```text
TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE
→ RED 런타임 계약·회귀 검사
→ 10권 제품 데이터·카드·해결기 구현
→ 사람·밸런스 검증
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

기획 승인만으로 제품 코드·Godot Scene·런타임 데이터 구현 완료를 주장하면 안 된다.
