# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`  
> 현재 기술1 효과·5성 권위: `docs/decisions/2026-08-04_TECHNIQUE1_CONDITIONAL_REWORK_STAR5_DECISION.md`

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
main_canon_maintenance_merge: add26649717a0b1bdf6eee40ad0b6214c9738eb4
last_planning_checkpoint_merge: d9f38e6f3cacaf170d4b290e95b3645114639aff
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: 87
active_planning_parent_pr: 86
active_approval_count: 7/10
active_decision_state: APPROVED_PENDING_MERGE
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
next_planning_decision: INDIVIDUAL_STAR_9_READ_BASED_BRANCHES
```

PR #87은 PR #86 전투 가격·기존 승인 행동 repricing 정본 위에 쌓인 `7/10` 계획 PR이다. exact head와 CI 결과는 GitHub PR 메타데이터를 권위로 사용한다.

자동·정적 검증 통과는 Windows·접근성·성능·사람 검증을 대신하지 않는다.

## 프로젝트 코어

공개 상태와 반복 습관을 읽고 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·순차 합·대응·중단으로 파훼하고 복기로 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트다.

- AI는 미확정 플레이어 계획을 참조하지 않는다.
- 핵심 재미는 불완전한 정보에서 계획하고 결과 원인을 이해해 다음 계획을 바꾸는 데 있다.
- 영구 스테이터스는 외공·근골·신법·내공·심안이며 디자인 하드캡은 없다.
- GrillMe는 정본 확인→적대적 검토→벤치마크·현업 비교→권장안→승인 동기화 순서로 진행한다.

## 런타임 기준선

- `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`
- `TEN-DEC-20260801-SITUATION-SCREEN-01`
- `work_mode: REVIEW`, `integration_pr: 65`는 현재 런타임 기준선이다.
- 최신 전투·성장 기획은 런타임에 아직 반영되지 않았다.

## 현재 승인 계보 — 7/10

1. `TEN-DEC-20260803-STAR10-ULTIMATE-PRIMARY-STAT12-01`
2. `TEN-DEC-20260803-STARTING-MARTIAL-SECONDARY-STATS-01`
3. `TEN-DEC-20260803-INTERMEDIATE-NODE-PERMANENT-STAT-REWARDS-01`
4. `TEN-DEC-20260803-MARTIAL-TECHNIQUE-ROLE-AND-SCALING-MATRIX-01`
5. `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-1-BASE-EFFECTS-AND-BUDGETS-01` — 효과 권위는 7번으로 대체됨
6. `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-2-BASE-EFFECTS-AND-BUDGETS-01`
7. `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`

지원 전투 경제 권위:

- `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01`
- `TEN-DEC-20260804-EXISTING-ACTIONS-REPRICE-01`

## 현재 정본 요약

- 기초 행동10종과 `3수→3수→4수`.
- 3성 기술1 주4, 7성 기술2 주8, 10성 절초 주12.
- 승인 예산표는 틱만 사용한다.
- 이동1칸과 사거리1 초과1칸은 각각15틱이다.
- 사용 가능 예산은 `슬롯 예산 + 확정 자원 소모 허용량 + 조건 허용량`이다.
- 기존 승인 행동의 유효 비용·슬롯은 `approved_20260804_existing_action_reprice_contract.json`이 소유한다.
- 3성 기술1 효과·조건·5성 patch는 `approved_20260804_technique1_conditional_rework_star5_contract.json`이 소유한다.
- 기술1은 조건 실패 시 낮은 저점, 성공 시 높은 고점을 가진다.
- 조건 난도 가격 계수는 쉬움0.85·보통0.70·어려움0.55·매우어려움0.40·극단적0.25다.
- 조건 실패 시 연결 효과 묶음은 전부0이며 부분 지급·이월·대체·전환이 없다.
- 같은 행동이 스스로 만든 조건으로 가격 감소를 받을 수 없다.
- 5성 patch는 별도 비용 없이 유효 예산의20%를 무료 강화 예산으로 받는다.
- 연격은 총피해를 한 번 계산하고 `40% / 30% / 나머지`로 분배한다.
- 취소·실패한 후속타 피해는 재분배·이월하지 않는다.
- 행동 묶음 확정 뒤 추가 플레이어 선택을 요구하지 않는다.

## 구현 차이

현재 런타임에는 최신 시작 능력치·성장·해금, 승인된 기술1·기술2, 조건부 효과·5성 patch, 주요 비무5전·노드8개가 구현되지 않았다. 별도 Build 승인 전 제품 코드·Scene·런타임 데이터를 변경하지 않는다.

## 역사·회귀 추적

- `PR #7`과 `Issue #13`은 T0 `STEP 0~13` 구현·검토 계보다.
- `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`는 과거 v6 승인 이력 인덱스다.
- 과거 `CORE_REVIEW_PENDING`은 사용자 승인 뒤 `CORE_CONFIRMED`로 종료됐다.
- `STEP 14` 사람 검증은 `NOT_RUN`이다.
- 과거 PoC 무공 ID는 `legacy_manual_alias`로만 보존한다.
- 과거 기술1 효과 표는 역사 증거이며 제품 유효 효과 권위가 아니다.
- 과거 예산점 병기와 음수 credit은 역사 PoC 검증 호환이며 현행 승인 표시가 아니다.

## 다음 작업 Gate

```text
여섯 7성 기술2의 9성 공개 정보 기반 자동 조건 분기 GrillMe
→ 무공별 10성 고유 절초 효과·예산
→ 남은 승인 최대 10건
→ [기획 완료]
→ 전체 적대적 검토
→ [검토 완료]
→ 이미지·애니메이션·HX 생성·검수·승인
→ [이미지 완료]
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex BUILD
```

## 검증 경계

```yaml
planning_checkpoint: ACTIVE_DRAFT_7_OF_10_PR87
product_code_changed: false
html_poc_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
network_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
demo_ready: NO
```
