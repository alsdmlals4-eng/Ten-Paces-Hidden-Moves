# 1수·2수·3수 계획 편집 UX 결정

> Decision ID: `TEN-DEC-20260731-PLAN-EDITOR-01`  
> 상태: `APPROVED_PLANNING`  
> Work Mode: `PLAN`  
> 런타임 권한: `NONE`

## 승인 계약

```yaml
three_move_editor:
  slots: 3
  empty_slot: WAIT
  editing_before_commit: FREE
  editing_after_commit: PROHIBITED
  preview_scope: PLAYER_KNOWN_STATE_ONLY
  invalid_plan_commit: PROHIBITED
  warning_plan_commit: CONFIRMABLE
  multi_slot_action: CONTIGUOUS_LINKED_SLOTS
  opponent_plan_preview: PROHIBITED
  post_resolution_comparison: REQUIRED
```

## 편집 흐름

```text
수 슬롯 선택
→ 행동 팔레트에서 행동 선택
→ 필요 시 방향·대상 지정
→ 계획 전체 재검증
→ 경고·오류 확인
→ 계획 확정
```

- `손패`가 아니라 항상 접근 가능한 `행동 팔레트`로 표현한다.
- 클릭 선택을 기본 조작으로 사용하고 드래그는 보조 기능으로 둔다.
- 행동 더블클릭은 첫 번째 빈 수에 빠르게 배치한다.
- 슬롯 제거 시 뒤 행동을 자동으로 당기지 않는다.
- 빈 슬롯은 확정 시 비용 0의 `[대기]`로 변환한다.

## 슬롯 상태

- `EMPTY`
- `FOCUSED`
- `VALID`
- `WARNING`
- `INVALID`
- `LOCKED`
- `RESOLVING`
- `RESOLVED`
- `CANCELLED`

`WARNING`은 확정 가능하고 `INVALID`는 확정 불가능하다.

## 계획 사전 검증 범위

표시 가능:

- 현재 공개 상태
- 플레이어 자신의 위치 변화
- 행동 비용과 실행 시점 예상 자원
- 고정 사거리와 전장 경계
- 다중 슬롯 점유
- 준비·실행 연결 조건

표시 금지:

- 상대의 실제 계획
- 실제 합 발생 여부
- 최종 명중·피해 예측
- 승패 확률
- 상대 이동의 유령 경로

## 다중 슬롯 무공

- 연속된 수만 점유한다.
- 현재 묶음을 넘어갈 수 없다.
- 하나의 무공 프레임으로 연결해 표시한다.
- 일부 단계만 제거할 수 없다.
- 준비 중 중단되면 미실행 실행 단계가 취소된다.

## 계획 확정

- 오류가 없고 대상 선택이 완료되어야 한다.
- 경고가 없으면 즉시 확정한다.
- 경고가 있으면 위험 요약 후 확정할 수 있다.
- 확정 직후 입력을 잠그고 불변 `CommittedPlan`을 생성한다.
- 확정 후 취소·편집을 허용하지 않는다.

## Godot 경계

```text
CombatPlanningLayer
├─ BundleHeader
├─ DuelViewport
├─ PlanTimeline
├─ ActionPalette
├─ DetailDock
└─ CommitBar
```

- `CombatPlanningController`: 편집 상태와 입력 흐름
- `PlanningValidator`: 자원·위치·조건 검증
- `PlanTimelineView`: 표시 전용
- `ActionPaletteView`: 목록·분류·Focus 표시
- UI는 판정 규칙을 자체 계산하지 않는다.

## 완료 기준

- 3수 순서가 즉시 이해된다.
- 마우스·키보드·게임패드로 같은 기능을 사용할 수 있다.
- 행동 교체 시 전체 계획 오류가 즉시 갱신된다.
- 중단된 수가 화면에 남아 취소 원인을 보여준다.
- 확정된 계획과 실제 결과를 수별로 비교할 수 있다.

## 게이트

```yaml
planning_complete: false
review_complete: false
runtime_implementation: prohibited
human_validation: not_run
codex_handoff: false
```
