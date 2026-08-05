# 십보강호 정본 생명주기 등록부

- 기반 권위: `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`
- 현행 성장 권위: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`
- 현행 런타임 기반 권위: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`
- 현행 UI·AI 채택 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`
- 7성·9성 예산 부모: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`
- 작업 운영: `TEN-DEC-20260805-WORK-GOVERNANCE-01`
- 기준 main: `bbed0fd4d278ca0e0d52f4e6d9083aafa1997318`

## 상태 정의

| 표시 | 의미 | 허용 사용 |
|---|---|---|
| `[현행]` | 현재 기획·검증·제품 연결 권위 | 후속 작성·구현 인계·검증 |
| `[대체됨]` | 새 Decision이 권위 인수 | 역사·migration·회귀 증거 |
| `[보류]` | 증거 보존·진행 중지 | 명시적 재개 전 참고만 |
| `[폐기]` | 현재·역사 가치 없음 | 참조 금지 |

## `[현행]` 권위

| 분야 | 권위 |
|---|---|
| 활성 상태 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` |
| 로드맵 | `docs/04_ROADMAP.md` |
| 전투 부모 | `docs/02_COMBAT_RULES.md` |
| 초기 10권 전투 해결 개정 | `docs/02_COMBAT_RULES_TEN_RECOGNIZABLE_MARTIAL_MANUALS_AMENDMENT.md` |
| 초기 10권 읽기 카탈로그 | `docs/03_TEN_MARTIAL_MANUALS_CATALOG.md` |
| 초기 10권 성장 Decision | `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01` |
| 초기 10권 런타임 기반 Decision | `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE` |
| 초기 10권 UI·AI Decision | `TEN_MANUAL_UI_AI_ADOPTION_GATE` |
| 런타임 빌드 승인 | `docs/implementation/BUILD_APPROVAL_2026-08-06.md` |
| 런타임 manifest | `data/cards/martial_manual_cards.json` |
| 무공서별 데이터 | `data/cards/martial_manuals/` |
| PoC 플레이어·적 loadout | `data/combat/ten_manual_loadout_poc.json` |
| 숙련 레지스트리 | `src/combat/martial_manual_registry.gd` |
| 순차 효과 pipeline | `src/combat/martial_effect_pipeline.gd` |
| 준비 호환 전투 어댑터 | `src/combat/combat_resolution_engine_ten_manuals.gd` |
| 제품 전투 장면 어댑터 | `src/combat/combat_board_preview_ten_manuals_auto.gd` |
| 행동 선택 UI 공급자 | `src/ui/action_selection/action_view_model_adapter.gd` |
| 공개 상태 AI | `src/combat/combat_ai_planner.gd` |
| 기술1 효과·조건·5성 | `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01` |
| 7성·9성 예산 부모 | `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01` |
| 자원 회복 | `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01` |
| 조건 측정·재분류 | `TEN-DEC-20260805-CONDITION-CALIBRATION-01` |
| 파생 수치·오판 구제 | `TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01` |
| 관찰 직접 공개 | `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01` |
| 등급 파밍 방지 | `TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01` |
| 작업 운영 | `TEN-DEC-20260805-WORK-GOVERNANCE-01` |

현행 contracts:

- `approved_20260804_existing_action_reprice_contract.json`
- `approved_20260804_technique1_conditional_rework_star5_contract.json`
- `approved_20260805_star7_star9_mastery_bonus_contract.json`
- `approved_20260806_ten_recognizable_martial_manuals_contract.json`
- `approved_20260806_ten_manual_growth_budget_overlay_contract.json`
- `approved_20260805_condition_calibration_contract.json`
- `approved_20260805_wrong_plan_rescue_derived_stats_contract.json`
- `approved_20260805_observation_answer_leak_guardrails_contract.json`
- `approved_20260805_grade_farming_guardrails_contract.json`
- `approved_20260805_work_governance_contract.json`

## 제품 연결 권위 경계

현재 상태는 `UI_AI_ADOPTED`다.

보장:

- 정확한 초기 10권 roster와 승인된 문파·주/보조능력치.
- 3·5·7·9·10성 카드 해금과 overlay 합성.
- 행동 선택 UI의 명시적 플레이어 loadout·성취도 표시.
- 10성 무공 절초와 기존 공용 절초의 동시 표시.
- 적 AI의 적 전용 loadout과 공개 상태 기반 후보 평가.
- 플레이어 비공개 계획·미확정 배치·포인터 접근 금지.
- 묶음 해결 안에서 순차 effect pipeline 실행.
- 자하신공·나한금강공·회마창·능파미보·만천화우의 핵심 불변조건.
- 명시적 loadout에서만 무공 카드 병합.
- 기본 행동·공용 절초 3종·준비·자동 배치의 호환성.

아직 권위가 없는 범위:

- 최종 loadout 획득·교체 경제.
- 적별 최종 무공 배치와 난이도 곡선.
- 최종 밸런스·연출·아트·음향.
- Windows·접근성·성능·사람 플레이 승인.

## `[대체됨]`

| 대상 | 대체 권위 | 허용 사용 |
|---|---|---|
| 부모 묶음 내력 자동회복1 | 자원 포화 Decision | 과거 재현만 |
| `docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md` | 전투 가격 Decision | 과거 ledger만 |
| 2026-08-03 기술1 효과 Decision·contract | 2026-08-04 기술1 Decision | 역사·migration만 |
| 역사 기술2 계약의 구형 예산 | repricing + 7/9성 숙련 Decision | 기본 효과 근거만 |
| 9성 공개 정보 자동 분기 가설 | 7/9성 숙련 Decision | 역사적 설계 검토만 |
| 구형 `attack_power: 8` 공식 권위 | 파생 스탯 Decision | 역사 PoC 표시만 |
| PR #90과 비최종 condition branch | PR #91 | 오류 추적만 |
| 런타임 미구현 상태 | `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE` | 과거 체크포인트만 |
| UI·AI 미채택 상태 | `TEN_MANUAL_UI_AI_ADOPTION_GATE` | 과거 런타임 기반 체크포인트만 |

## `[보류]`

| 대상 | 상태 | 재개 조건 |
|---|---|---|
| GitHub PR #85 HTML Technique1 PoC | 닫힘·병합 금지·제품 권위 없음 | 명시적 재개 승인 |
| PR #85 테스트 결과 | 역사 참고 | 최신 계약 재작성·재검증 |
| 최종 loadout 경제 | PoC fixture만 존재 | 성장·획득 경제 Decision |
| 적별 최종 loadout·난이도 | 공개 상태 경계만 구현 | 사람 측정과 난이도 Decision |
| 최종 등급 가중치·컷 | 사람 표본 전 보류 | 별도 Decision |
| 등급 기반 경제 보상 | 사람 검증 전 금지 | 30승·5상대·표본 집중40% 이하와 새 Decision |

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
| #92 | Draft·부모 #91·초기 10권 성장·런타임 기반·UI·AI 채택·현재 배치10/10 |
| #85 | `[보류]` HTML PoC |

## `CANON_CONFLICT`

- 능력치별 무공서 권수·균등 분포·최소/최대 쿼터를 강제함.
- 승인된 문파·주/보조능력치 조합을 분포 때문에 변경함.
- 5성이 star3 이외 카드를 변경함.
- 9성이 star7 이외를 변경하거나 복수 효과·분기·추가입력·추가비용을 만듦.
- 이동 뒤 종속 공격이 사거리 재검사를 우회함.
- 자하신공 사용권을 중단 뒤 환불하거나 미완료 상태에서 기세를 지급함.
- `[강건]`을 무적·피해 무시·절대 중단 면역으로 확장함.
- 명시적 loadout 없이 무공 카드를 기본 엔진에 삽입함.
- 적 AI가 플레이어 전용 loadout이나 비공개 계획을 참조함.
- UI에 선택 가능한 무공 카드가 실제 `effect_steps`를 실행하지 않음.
- 기본 행동·공용 절초·준비·자동 배치 ID나 동작을 삭제·변경함.
- 숨은 계획 접근·자동 정답·자동 합 승리를 추가함.
- 사람 검증 없이 최종 밸런스·T1 완료를 주장함.
- PR #92를 PR #91보다 먼저 독립 병합하거나 Draft 해제함.
- `[대체됨]`·`[보류]` 자료를 현행 제품 권위로 사용함.

## 다음 Gate

`TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`와 `TEN_MANUAL_UI_AI_ADOPTION_GATE`는 완료됐다. 현재 승인 배치는 `10/10`이다.

```text
TEN_MANUAL_PRODUCT_VALIDATION_GATE
→ Godot Windows 실제 실행
→ 접근성·성능 검증
→ STEP 14 사람·밸런스 검증
→ 적 loadout 공정성·기술 대체율·자원 포화 측정
→ 최종 밸런스 Decision
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

자동 검증만으로 Windows·접근성·성능·사람·밸런스 완료를 주장하면 안 된다.
