# 십보강호 정본 생명주기 등록부

- 기반 권위 Decision: `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`
- 현재 위험 완화 Decision: `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`
- 기준 main: `bbed0fd4d278ca0e0d52f4e6d9083aafa1997318`
- 목적: 구형 파일·필드·PR·계약이 현행 정본으로 오인되는 것을 차단한다.

## 상태 정의

| 표시 | 의미 | 허용 사용 |
|---|---|---|
| `[현행]` | 현재 기획·검증 권위 | 후속 작성·구현 인계·검증 |
| `[대체됨]` | 새 Decision이 권위 인수 | 역사 재현·migration diff·회귀 증거 |
| `[보류]` | 증거 보존, 현재 진행 중지 | 명시적 재개 승인 전 참고만 |
| `[폐기]` | 현재·역사 권위와 복구 가치 없음 | 참조 금지 |

상태가 없는 파일은 그 자체로 현행임을 뜻하지 않는다. 활성 컨텍스트·책임 원본·Decision·approved contract의 명시적 계보로 판정한다.

## `[현행]` 권위

| 분야 | 권위 |
|---|---|
| 활성 운영 상태 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` |
| 기획·구현 순서 부모 | `docs/04_ROADMAP.md` |
| 핵심 위험 순서 개정 | `docs/04_ROADMAP_RESOURCE_RISK_AMENDMENT.md` |
| 전투 규칙 부모 | `docs/02_COMBAT_RULES.md` |
| 묶음·라운드 자원 회복 개정 | `docs/02_COMBAT_RULES_RESOURCE_RECOVERY_AMENDMENT.md` |
| 거리·자원·중단·회복 부모 | `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01` |
| 묶음 전환 내력 회복 최종값 | `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01` |
| 기존 행동 유효 비용·슬롯 | `TEN-DEC-20260804-EXISTING-ACTIONS-REPRICE-01` |
| 기술1 효과·조건·5성 | `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01` |
| 병합 후 정본·핵심 재미 감사 | `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01` |

현행 approved contracts:

- `docs/planning-data/approved_20260804_combat_pricing_interruption_recovery_contract.json`
- `docs/planning-data/approved_20260804_resource_saturation_internal_recovery_contract.json`
- `docs/planning-data/approved_20260804_existing_action_reprice_contract.json`
- `docs/planning-data/approved_20260804_technique1_conditional_rework_star5_contract.json`
- `docs/planning-data/approved_20260804_postmerge_canon_adversarial_audit_contract.json`

## `[대체됨]`

| 파일·필드 | 대체 권위 | 허용 사용 |
|---|---|---|
| `approved_20260804_combat_pricing_interruption_recovery_contract.json: bundle_transition_recovery.internal=1` | `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01` | 과거 전투 경제 재현만; 현재 유효값은 0 |
| `docs/02_COMBAT_RULES.md`의 `기력 +1·내력 +1·절초기세 +1` 묶음 전환 문구 | `docs/02_COMBAT_RULES_RESOURCE_RECOVERY_AMENDMENT.md` | 과거 규칙 재현만 |
| `docs/04_ROADMAP.md`의 `RESOURCE_SATURATION_RISK 규칙 유지·곧바로 STAR9` 순서 | `docs/04_ROADMAP_RESOURCE_RISK_AMENDMENT.md` | 과거 순서 재현만 |
| `docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md` | `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01` | 과거 사거리 ledger 재현만 |
| `docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md` | `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01` | 과거 기술1 효과 근거만 |
| `docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json` | `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01` | migration·before/after 회귀만 |

`docs/planning-data/poc_balance_budget.json`의 `pricing_ticks`는 파일 전체가 대체된 것이 아니라 `LEGACY_APPROVED_TECHNIQUE_LEDGER_SNAPSHOT` 영역이다. 신규·수정 작성 가격은 `active_authoring_distance_pricing_ticks`와 `range_pricing_contract`의 15틱 규칙만 사용한다.

## `[보류]`

| 대상 | 상태 | 재개 조건 |
|---|---|---|
| GitHub PR #85 HTML Technique1 PoC | 닫힘·병합 금지·제품 권위 없음 | 사용자의 명시적 HTML 검증 재개 승인 |
| PR #85의 HTML 자동 테스트 결과 | 역사 참고 증거 | 최신 main 계약으로 재작성·재검증 후 별도 승인 |

## `[폐기]`

현재 없음. 역사 추적·회귀·migration 가치가 있는 자료는 `[대체됨]` 또는 `[보류]`로 보존한다.

## PR 계보

| PR | 커밋·상태 | 생명주기 |
|---:|---|---|
| #84 | `81765e35c179b7a57eaa527a307080b63c32f0b8` | `[병합됨]` 성장·기술 기반 6/10 |
| #86 | `731e6431e76ebc76841f9253e87cd1e7a693ebb2` | `[병합됨]` 전투 경제·repricing |
| #87 | `0ba841ff2e62b2f716466356dd9e7ffcf587d150` | `[병합됨]` 기술1 조건·5성 7/10 |
| #88 | `bbed0fd4d278ca0e0d52f4e6d9083aafa1997318` | `[병합됨]` 병합 후 정본·핵심 재미 감사 |
| #89 | Draft | `[현행 제안]` 자원 포화 내력 자동 회복 제거 |
| #85 | 미병합 | `[보류]` HTML PoC |

## 참조 금지 규칙

다음은 `CANON_CONFLICT`다.

- 부모 전투 계약·규칙서의 `bundle_transition_recovery.internal=1`을 overlay 없이 현재 런타임 값으로 사용
- 부모 로드맵의 대체된 위험 순서를 현재 작업 순서로 사용
- `[대체됨]` 수치·효과를 신규 런타임 데이터에 직접 사용
- `[보류]` PR 또는 산출물을 main 병합 근거로 사용
- 병합된 PR 번호를 활성 작업 권위로 사용
- Decision보다 오래된 표를 “현재 승인값”으로 표시
- `IMPLEMENTED_LEGACY` 런타임을 최신 계획 구현 완료로 표시
- 실행하지 않은 Godot·Windows·접근성·성능·사람 검증을 PASS로 표시

## 다음 기획 Gate

`CONDITION_CALIBRATION_RISK`의 측정·가격 보정 계약을 확정한 뒤 `WRONG_PLAN_RESCUE_RISK`, `OBSERVATION_ANSWER_LEAK_RISK`, `GRADE_FARMING_RISK`를 순서대로 검토한다. 이후 `STAR9_PUBLIC_READ_BRANCH_TEMPLATE`을 진행한다.

조건 위험 계약은 실제 성공률, 선언 난도 범위, 실패 지점, 고점 만족도, 저점 수용도, 기술 포기율을 필수로 한다.
