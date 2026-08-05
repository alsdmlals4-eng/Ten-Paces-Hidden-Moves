# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`  
> 정본 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 병합 후 감사: `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`  
> 현재 기술1 효과·5성 권위: `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`  
> 현재 7성·9성 숙련 예산 권위: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`  
> 현재 자원 포화 완화 권위: `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`  
> 현재 조건 난도 보정 권위: `TEN-DEC-20260805-CONDITION-CALIBRATION-01`  
> 현재 파생 스탯·오판 구제 권위: `TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01`  
> 현재 관찰 가드레일 권위: `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`  
> 현재 등급 파밍 방지 권위: `TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01`  
> 현재 작업 운영 권위: `TEN-DEC-20260805-WORK-GOVERNANCE-01`

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
merged_planning_checkpoint: bbed0fd4d278ca0e0d52f4e6d9083aafa1997318
merged_pr_lineage: 84,86,87,88
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: 92
active_planning_parent_pr: 91
active_approval_count: 10/10
active_decision_state: APPROVED_DRAFT_STAR7_STAR9_MASTERY_BONUS
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
engine: Godot 4.7
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
base_release_pinned: 9.4.3
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
latest_combat_planning_runtime: NOT_STARTED
automated_validation: PASS
windows_validation: NOT_RUN
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: SIX_STAR7_MASTERY_BONUS_ALLOCATIONS
```

PR #84·#86·#87·#88은 main에 병합된 역사 계보다. 자원 포화 완화는 Draft PR #89, 조건 난도 보정과 작업 운영 정책은 그 위의 Draft PR #91, 파생 스탯·오판 구제·관찰·등급 파밍 방지·7/9성 숙련 예산은 그 위의 Draft PR #92에서 검증한다. PR #92는 PR #91보다 먼저, PR #91은 PR #89보다 먼저 독립 병합하지 않는다. PR #90은 `[대체됨]`, PR #85 HTML PoC는 `[보류]`다.

자동·정적 검증 통과는 Godot·Windows·접근성·성능·사람 검증을 대신하지 않는다.

## 프로젝트 코어

공개 상태와 반복 습관을 읽고 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·순차 합·대응·중단으로 파훼하고 복기로 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트다.

```text
객관 정보 조사·관찰
→ 잠긴 상대 묶음 추론
→ 비공개 계획 확정
→ 거리·순서·합·회피·방어·중단 해결
→ 원인 복기
→ 다음 계획 변경
```

보호 규칙:

- AI는 미확정 플레이어 계획을 참조하지 않는다.
- 적은 관찰 공개 전에 현재 묶음을 잠그고 공개 뒤 교체하지 않는다.
- 행동 묶음 확정 뒤 추가 플레이어 선택을 요구하지 않는다.
- 기술 이동은 고정 방향·합법 타일 폴백을 사용한다.
- 성장 수치는 잘못된 계획을 자동 구제하면 안 된다.
- 스탯 보정은 합법성·거리·순서·중단·성공 Gate 뒤에만 적용한다.
- 7성·9성은 3성보다 높은 총가치를 가질 수 있으나 기술1과 동일 역할을 수행해 전 상황에서 대체하면 안 된다.
- 9성은 분기 없이 기술2당 단일 완성 보너스 효과 하나만 사용한다.
- 기력은 묶음 템포, 내력은 여러 묶음에 걸친 장기 자원, 절초기세는 승부 자원이다.
- 등급 파밍 방지는 원시 전투 사건을 훼손하지 않고 유효 등급 입력만 제한한다.

## 런타임 기준선

- `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`
- `TEN-DEC-20260801-SITUATION-SCREEN-01`
- `work_mode: REVIEW`, `integration_pr: 65`는 현재 런타임 기준선이다.
- 현재 런타임은 일부 `IMPLEMENTED_LEGACY`이며 최신 성장·전투 정본이 구현되지 않았다.
- 별도 Build 승인 전 제품 코드·Scene·런타임 데이터를 변경하지 않는다.

## 현재 승인 계보 — 10/10

1. `TEN-DEC-20260803-STAR10-ULTIMATE-PRIMARY-STAT12-01`
2. `TEN-DEC-20260803-STARTING-MARTIAL-SECONDARY-STATS-01`
3. `TEN-DEC-20260803-INTERMEDIATE-NODE-PERMANENT-STAT-REWARDS-01`
4. `TEN-DEC-20260803-MARTIAL-TECHNIQUE-ROLE-AND-SCALING-MATRIX-01`
5. `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-1-BASE-EFFECTS-AND-BUDGETS-01` — `[대체됨]`
6. `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-2-BASE-EFFECTS-AND-BUDGETS-01`
7. `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`
8. `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`
9. `TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01`
10. `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`

지원 권위:

- `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01`
- `TEN-DEC-20260804-EXISTING-ACTIONS-REPRICE-01`
- `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`
- `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`
- `TEN-DEC-20260805-CONDITION-CALIBRATION-01`
- `TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01`
- `TEN-DEC-20260805-WORK-GOVERNANCE-01`

## 현재 정본 요약

- 기초 행동 10종과 `3수→3수→4수`.
- 이동·사거리 1칸은 각각 15틱.
- 기술1은 조건 실패 시 낮은 저점, 성공 시 높은 고점.
- 조건 실패 시 연결 묶음 전부0; 부분 지급·이월·대체·전환 없음.
- 5성 patch는 별도 비용 없이 유효 예산의20%.
- 7성 기술2는 현행 repricing 유효 예산에 숙련 보너스 `+10틱`을 받지만 실제 배분은 다음 Decision까지 미승인이다.
- 9성 추가 예산은 `10 + floor(7성 최종 예산×0.20)`이며 단일 효과·무분기·추가입력/비용 없음이다.
- 연격은 총피해를 한 번 계산하고 `40% / 30% / 나머지`로 분배.
- 묶음 전환 자동 회복은 `기력1·내력0·절초기세1`; 라운드 시작 별도 내력 회복 없음.
- 조건 난도는 극단적·매우 어려움·어려움·보통·쉬움·준확정 여섯 구간.
- 가격 재분류는 규칙을 이해한 일반 플레이어의 유효 시도 성공률을 기준으로 하며 자동 repricing하지 않는다.
- 파생 수치는 `체력=26+근골`, `기력=4+floor(신법/4)`, `내력=3+floor(내공/4)`.
- 외공·근골·신법·내공·심안은 성공한 명시 효과만 강화하고 구조 실패를 우회하지 않는다.
- 잘못된 계획 구제는 `결과 역전`과 `중대 구제`로 분리하고 중복 집계하지 않는다.
- 관찰은 행동1수→관찰량1→적 선잠금 뒤 앞 슬롯 실제 행동 종류 직접 공개를 유지하며 자동 정답 대응은 생성하지 않는다.
- 등급 원시 합·회피·손실·라운드·절초 사건은 모두 기록하고, 등급 반영량만 동일 행동 `1.0→0.5→0`, 공격 인스턴스 합계 최대1, 합/회피 각 상한3으로 제한한다.
- 기준 라운드 기본값은3이며 이후 합·회피·절초 양의 반영량은0이지만 원시 사건·손실·라운드는 계속 기록한다.
- 유효 절초는 기준 라운드 안의 첫 비비용 효과 발생1회만 반영하고, 사람 검증 전 등급을 경제에 연결하지 않는다.
- 구형 `attack_power: 8`은 현행 공식 권위에서 `[대체됨]`이며 행동별 스탯 계수에 더하지 않는다.
- 승인 배치는 최대10건이며 고위험 충돌·세션 종료·큰 정본 영향에서 조기 체크포인트를 허용한다.
- 모든 작업은 `RED→GREEN→REFACTOR→exact-head verification`을 따른다.

## 적대적 검토 결론

| 위험 | 상태 | 다음 검증 |
|---|---|---|
| `RESOURCE_SATURATION_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 회복 세금·자원 고갈 |
| `CONDITION_CALIBRATION_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 성공률·구간 이탈·고점/저점 체감 |
| `WRONG_PLAN_RESCUE_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 결과 역전률·중대 구제율·올바른 계획 증폭률 |
| `OBSERVATION_ANSWER_LEAK_RISK` | `ACCEPTED_PENDING_HUMAN_MEASUREMENT` | 직접 공개 유지·자동 nerf 금지·사람 측정 |
| `GRADE_FARMING_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 원시/유효 비율·반복 대응·기준 라운드 이후 사건·경제 미연결 |
| `MASTERY_ROLE_REPLACEMENT_RISK` | `ACCEPTED_PENDING_HUMAN_MEASUREMENT` | 기술1/2 선택률·전 상황 대체율·한 문장 이해율 |
| `RUNTIME_AUTHORITY_GAP` | P0 | 최신 계획 미구현 |

## 생명주기 요약

- `[현행]`: 전투 가격·repricing·기술1·7/9성 숙련 예산·자원 포화·조건 보정·파생 스탯·오판 구제·관찰 직접 공개·등급 파밍 방지·작업 운영 정책.
- `[대체됨]`: 구형 사거리·구형 기술1·부모 내력 자동회복1·구형 통합 공격력 공식 권위·9성 자동 분기 가설·PR #90.
- `[보류]`: PR #85 HTML PoC.
- `[폐기]`: 현재 없음.

## 다음 작업 Gate

```text
SIX_STAR7_MASTERY_BONUS_ALLOCATIONS
→ SIX_STAR9_SINGLE_COMPLETION_BONUSES
→ SIX_STAR10_UNIQUE_ULTIMATES
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
→ [기획 완료]
→ 이미지·애니메이션·HX 승인
→ [이미지 완료]
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex BUILD
```

10/10 체크포인트이므로 새 승인 배치를 열기 전 현재 PR 계보·정본·Sheet의 일치를 먼저 검토한다.

## 역사·회귀 추적

- `PR #7`과 `Issue #13`은 T0 `STEP 0~13` 구현·검토 계보다.
- `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`는 과거 v6 승인 이력 인덱스다.
- 과거 `CORE_REVIEW_PENDING`은 사용자 승인 뒤 `CORE_CONFIRMED`로 종료됐다.
- `STEP 14` 사람 검증은 `NOT_RUN`이다.

## 검증 경계

```yaml
planning_checkpoint: DRAFT_PR92_STAR7_STAR9_MASTERY_BONUS_10_OF_10
product_code_changed: false
html_poc_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
network_validation: NOT_RUN
accessibility_validation: NOT_RUN
performance_validation: NOT_RUN
human_validation: NOT_RUN
balance_validation: NOT_RUN
demo_ready: NO
```
