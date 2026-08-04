# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`  
> 정본 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 병합 후 감사: `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`  
> 현재 기술1 효과·5성 권위: `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`  
> 현재 자원 포화 완화 권위: `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
merged_planning_checkpoint: bbed0fd4d278ca0e0d52f4e6d9083aafa1997318
merged_pr_lineage: 84,86,87,88
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: 89
active_planning_parent_pr: NONE
active_approval_count: 7/10
active_decision_state: APPROVED_DRAFT_RESOURCE_SATURATION_MITIGATION
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
next_planning_decision: CONDITION_CALIBRATION_RISK
```

PR #84·#86·#87·#88은 main에 병합된 역사 계보다. 현재 자원 포화 완화는 Draft PR #89에서 검증 중이며, 병합 전에는 main 런타임 권위가 아니다. PR #85 HTML PoC는 `[보류]`로 닫혔으며 현재 제품 권위가 아니다.

자동·정적 검증 통과는 Godot·Windows·접근성·성능·사람 검증을 대신하지 않는다.

## 프로젝트 코어

공개 상태와 반복 습관을 읽고 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·순차 합·대응·중단으로 파훼하고 복기로 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트다.

핵심 루프:

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
- 성장 수치는 거리·순서·대응을 확장해야 하며 잘못된 계획을 자동 구제하면 안 된다.
- 핵심 재미는 승리율만이 아니라 결과 원인을 이해하고 다음 계획을 바꾸는 데 있다.
- 기력은 묶음 템포, 내력은 여러 묶음에 걸친 장기 자원, 절초기세는 전투 진행·성공 사건의 승부 자원으로 분리한다.

## 런타임 기준선

- `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`
- `TEN-DEC-20260801-SITUATION-SCREEN-01`
- `work_mode: REVIEW`, `integration_pr: 65`는 현재 런타임 기준선이다.
- 현재 런타임은 일부 `IMPLEMENTED_LEGACY`이며 최신 성장·전투 정본이 구현되지 않았다.
- 별도 Build 승인 전 제품 코드·Scene·런타임 데이터를 변경하지 않는다.

## 현재 승인 계보 — 7/10

1. `TEN-DEC-20260803-STAR10-ULTIMATE-PRIMARY-STAT12-01`
2. `TEN-DEC-20260803-STARTING-MARTIAL-SECONDARY-STATS-01`
3. `TEN-DEC-20260803-INTERMEDIATE-NODE-PERMANENT-STAT-REWARDS-01`
4. `TEN-DEC-20260803-MARTIAL-TECHNIQUE-ROLE-AND-SCALING-MATRIX-01`
5. `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-1-BASE-EFFECTS-AND-BUDGETS-01` — `[대체됨]` 역사 효과 증거
6. `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-2-BASE-EFFECTS-AND-BUDGETS-01`
7. `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`

지원 권위:

- `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01` — 묶음 내력 자동 회복 필드만 부분 개정
- `TEN-DEC-20260804-EXISTING-ACTIONS-REPRICE-01`
- `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`
- `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`

## 현재 정본 요약

- 기초 행동 10종과 `3수→3수→4수`.
- 3성 기술1 주4, 7성 기술2 주8, 10성 절초 주12.
- 승인 예산표는 틱만 사용한다.
- 이동 1칸과 사거리1 초과 1칸은 각각 15틱이다.
- 사용 가능 예산은 `슬롯 예산 + 확정 자원 소모 허용량 + 조건 허용량`이다.
- 기존 승인 행동의 유효 비용·슬롯은 `approved_20260804_existing_action_reprice_contract.json`이 소유한다.
- 기술1 효과·조건·5성 patch는 `approved_20260804_technique1_conditional_rework_star5_contract.json`이 소유한다.
- 기술1은 조건 실패 시 낮은 저점, 성공 시 높은 고점을 가진다.
- 조건 실패 시 연결 묶음은 전부 0이며 부분 지급·이월·대체·전환이 없다.
- 같은 행동이 스스로 만든 조건으로 가격 감소를 받을 수 없다.
- 5성 patch는 별도 비용 없이 유효 예산의 20%를 무료 강화 예산으로 받는다.
- 연격은 총피해를 한 번 계산하고 `40% / 30% / 나머지`로 분배한다.
- 취소·실패한 후속타 피해는 재분배·이월하지 않는다.
- 묶음 전환 자동 회복의 유효값은 `기력1·내력0·절초기세1`이다.
- 라운드 시작에 별도 내력 자동 회복이 없다.
- 내력은 준비된 명상·청심조식·승인 조건부 회수 등 명시적 효과로만 회복한다.
- 부모 계약의 `bundle_transition_recovery.internal: 1`은 `[대체됨]`이며 overlay 미적용은 `CANON_CONFLICT`다.

## 적대적 검토 결론

현재 전투 구조는 관찰·추론·비공개 계획·복기 코어와 일치한다. 위험은 다음 순서로 하나씩 완화·측정한다.

| 위험 | 상태 | 핵심 검증 |
|---|---|---|
| `RESOURCE_SATURATION_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 내력0 묶음률·내력 제약 계획 변경률·고내력 연속 사용률·회복 행동 세금 여부 |
| `CONDITION_CALIBRATION_RISK` | P1·다음 작업 | 기술별 조건 성공률·선언 난도 범위 이탈·실패 지점 분포 |
| `WRONG_PLAN_RESCUE_RISK` | P1·미실측 | 고능력치가 잘못된 계획을 구제하는 비율 |
| `OBSERVATION_ANSWER_LEAK_RISK` | P1·미실측 | 관찰이 추론 재료인지 정답 공개인지 |
| `GRADE_FARMING_RISK` | P1·미확정 | 등급 가중치·정규화·상한·파밍 방지 |
| `RUNTIME_AUTHORITY_GAP` | P0 | 최신 계획이 제품 런타임에 미구현 |

자원 포화 완화는 사람 검증 전 PASS가 아니다. `RECOVERY_TAX_RISK`와 `RESOURCE_STARVATION_RISK`가 남아 있으므로 개별 기술 비용·내력 최대치·명시적 회복량을 임의 조정하지 않는다.

## 생명주기 요약

- `[현행]`: 2026-08-04 전투 가격·repricing·기술1 조건/5성 계약과 자원 포화 내력 회복 overlay.
- `[대체됨]`: 2026-08-02 구형 사거리 가격, 2026-08-03 구형 기술1 효과 Decision·contract, 부모 계약의 `bundle_transition_recovery.internal: 1` 필드.
- `[보류]`: PR #85 HTML PoC와 그 자동 테스트 결과.
- `[폐기]`: 현재 없음.

상세 목록과 허용 참조 범위는 `docs/CANON_LIFECYCLE_REGISTRY.md`를 따른다.

## 다음 작업 Gate

```text
조건 난도·실제 성공률 보정 계약
→ 잘못된 계획 구제 위험
→ 관찰 정답 유출 위험
→ 전투 종료 등급 파밍 위험
→ 9성 공개 정보 자동 분기 공통 템플릿
→ 여섯 개별 9성 분기
→ 무공별 10성 고유 절초 효과·예산
→ 비스탯 노드 기대가치·배치
→ 전체 핵심 재미·정본 적대적 검토
→ [기획 완료]
→ 이미지·애니메이션·HX 생성·검수·승인
→ [이미지 완료]
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex BUILD
```

## 역사·회귀 추적

- `PR #7`과 `Issue #13`은 T0 `STEP 0~13` 구현·검토 계보다.
- `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`는 과거 v6 승인 이력 인덱스다.
- 과거 `CORE_REVIEW_PENDING`은 사용자 승인 뒤 `CORE_CONFIRMED`로 종료됐다.
- `STEP 14` 사람 검증은 `NOT_RUN`이다.
- 과거 PoC 무공 ID는 `legacy_manual_alias`로만 보존한다.
- 과거 예산점·음수 credit은 역사 PoC 호환이며 현행 승인 표시가 아니다.

## 검증 경계

```yaml
planning_checkpoint: DRAFT_PR89_RESOURCE_SATURATION_MITIGATION
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
