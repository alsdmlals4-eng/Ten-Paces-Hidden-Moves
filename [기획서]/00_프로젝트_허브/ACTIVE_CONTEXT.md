# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
main_canon_maintenance_merge: add26649717a0b1bdf6eee40ad0b6214c9738eb4
last_planning_checkpoint_merge: d9f38e6f3cacaf170d4b290e95b3645114639aff
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: 84
active_approval_count: 6/10
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
next_planning_decision: STARTING_MARTIAL_TECHNIQUE_1_STAR5_ROLE_PATCHES
```

자동·정적 검증 통과는 Windows·접근성·성능·사람 검증을 대신하지 않는다. PR #83은 정본 신선도 결함을 main에 동기화했고 PR #82의 승인 2건은 새 main 기반 PR #84로 이전했다.

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

## 현재 활성 승인 — 6/10

1. `TEN-DEC-20260803-STAR10-ULTIMATE-PRIMARY-STAT12-01`
2. `TEN-DEC-20260803-STARTING-MARTIAL-SECONDARY-STATS-01`
3. `TEN-DEC-20260803-INTERMEDIATE-NODE-PERMANENT-STAT-REWARDS-01`
4. `TEN-DEC-20260803-MARTIAL-TECHNIQUE-ROLE-AND-SCALING-MATRIX-01`
5. `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-1-BASE-EFFECTS-AND-BUDGETS-01`
6. `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-2-BASE-EFFECTS-AND-BUDGETS-01`

## 현재 정본 요약

- 기초 행동10종과 `3수→3수→4수`.
- 3성 기술1 주4, 7성 기술2 주8, 10성 절초 주12.
- 3성 기술1: 유운삼첩·금강가세·운수회신·추풍일섬·청심조식·철각유영.
- 7성 기술2: 낙영추검·반진권·사량발천근·연환쇄로·회기전맥·십보환위.
- 승인 예산표는 틱만 사용한다.
- 사용 가능 예산은 `슬롯 예산 + 자원 소모 예산 추가분 + 조건 예산 추가분`이다.
- 기력1은 +4틱, 내력1은 +7틱이며 2수·기력1·내력1은 `50+4+7=61틱`이다.
- 행동 묶음 확정 뒤 추가 플레이어 선택을 요구하지 않는다.
- 기술 안 이동은 고정 전진·고정 후퇴와 경계·점유·이동불가 폴백을 가진다.
- 추풍일섬은 고정 전진1로 개정됐다.
- 기술1과 기술2는 기준 능력치4에서 허용 편차 `±5틱` 안에 있다.

## 구현 차이

현재 런타임에는 최신 시작 능력치·성장·해금, 승인된 기술1·기술2, 주요 비무5전·노드8개가 구현되지 않았다. 별도 Build 승인 전 제품 코드·Scene·런타임 데이터를 변경하지 않는다.

## 역사·회귀 추적

- `PR #7`과 `Issue #13`은 T0 `STEP 0~13` 구현·검토 계보다.
- `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`는 과거 v6 승인 이력 인덱스다.
- 과거 `CORE_REVIEW_PENDING`은 사용자 승인 뒤 `CORE_CONFIRMED`로 종료됐다.
- `STEP 14` 사람 검증은 `NOT_RUN`이다.
- 과거 PoC 무공 ID는 `legacy_manual_alias`로만 보존한다.
- 과거 예산점 병기와 음수 credit은 역사 PoC 검증 호환이며 현행 승인 표시가 아니다.

## 다음 작업 Gate

```text
여섯 시작 무공 3성 기술1의 5성 역할 강화 patch·각 5틱 ledger GrillMe
→ 기술2 9성 공개 정보 기반 자동 조건 분기
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
planning_checkpoint: ACTIVE_DRAFT_6_OF_10
product_code_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
network_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
demo_ready: NO
```
