# REPEAT_POC A2·A3 가설 기록·결정적 복기 설계

> 기준: `agent/repeat-poc-a1-rival-ai@4d4a9d1d6e9119c41aab8259fff05dcd2b6cd473`
> Goal: `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`
> 구현 계획: `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`

## 1. 범위

A2는 플레이어가 직접 선택한 상대 의도 가설을 commit 직전에 snapshot하고, 판정 엔진의 권위 결과에서 결정적 원인 summary를 도출한다. A3는 그 summary를 읽기 전용 복기 패널로 표현하고 다음 묶음 또는 재시작으로 진행하는 명시적 게이트를 제공한다.

추가하지 않는 것:

- 새 행동·절초·세력·성장·경제·저장.
- AI의 private plan 입력.
- 정답 카드·승률·예측률.
- 미선택 가설 자동 추정.
- 판정·피해·거리 공식 재계산.

## 2. A2 구성요소

### 2.1 가설 데이터

`data/combat/combat_hypothesis_poc.json`은 다음 ID를 고정한다.

```text
approach
quick_attack
heavy_prepare
response_or_recover
ultimate
none
```

`none`은 오직 `기록한 가설 없음`을 의미한다.

### 2.2 OpponentHypothesisPanel

`OpponentHypothesisPanel`은 planning 상태에서만 편집 가능한 선택 UI다.

공개 API:

- `select_hypothesis(id: String) -> bool`
- `get_current_hypothesis_snapshot() -> Dictionary`
- `set_locked(value: bool) -> void`
- `reset_to_initial() -> void`

snapshot은 `id`, `label`, `recorded`만 포함한다. 시스템은 선택하지 않은 가설을 추정하지 않는다.

### 2.3 CombatReviewSummaryBuilder

`CombatReviewSummaryBuilder.build_summary(result, player_plan_snapshot, hypothesis_snapshot, state_before)`는 입력을 깊은 복사해 읽고 다음 구조를 반환한다.

```text
hypothesis
opponent_actual
cause_code
cause_label
decisive_timing
distance_before
distance_after
review_dimension
player_plan_count
```

원인 우선순위:

```text
clash > interrupted > defense > direction > range > resource > position > order
```

builder는 `CombatResolutionEngine`, `resolve_bundle`, 피해 공식 또는 AI candidate score를 호출하지 않는다.

## 3. A2 데이터 흐름

```text
planning 가설 선택
+ player placement
+ state before
→ 진행 버튼 요청 직전 deep snapshot
→ CombatResolutionEngine.resolve_bundle()
→ authoritative result
→ CombatReviewSummaryBuilder.build_summary()
→ last_review_summary
```

가설과 player plan은 commit 직전에 고정된다. 이후 UI 선택 변경이나 placement 초기화가 summary를 바꾸지 않는다.

## 4. A3 구성요소

### 4.1 CombatReviewPanel

표시 계층:

```text
내 가설
상대 실제 행동
결정적 수·원인
전후 거리
다음 검토 차원
[상세 기록] [다음 묶음 또는 재시작]
```

상세 기록 버튼은 기존 `CombatLogPanel`을 펼친다. 패널은 계산하지 않고 summary Dictionary만 표시한다.

### 4.2 상태 전이

```text
presenting_result
→ review_ready
→ 사용자가 계속 버튼 선택
→ next_bundle_ready 또는 combat_ended
```

review가 열려 있는 동안 카드·슬롯·타일·진행 입력은 잠긴다. 전투 종료도 review를 먼저 표시하고 계속 버튼 문구를 `결전 다시 시작`으로 바꾼다.

## 5. 접근성

- 가설 selector와 review 두 버튼은 키보드 포커스 순서에 포함한다.
- 모든 핵심 정보는 Label text와 accessibility name/description에 존재한다.
- 모션 감소·즉시 완료·음향 끄기에서도 동일한 summary text를 유지한다.
- 960×640에서는 중앙 overlay가 전장 결과와 하단 계획 UI를 가리지 않도록 최대 폭·높이를 제한한다.

## 6. 오류·경계 처리

- 알 수 없는 가설 ID는 `none`으로 강등한다.
- 결과 이벤트가 비어 있으면 cause는 `order`이며 실제 행동은 `행동 정보 없음`으로 표시한다.
- state에 타일이 없으면 시작 거리와 종료 거리를 0으로 처리한다.
- summary 입력은 mutation하지 않는다.
- restart는 가설, committed snapshot, summary, review panel 상태를 모두 초기화한다.

## 7. 검증

A2:

- 정적 contract Red→Green.
- 가설 ID·선택·잠금·reset·none 보존.
- cause fixture: clash, interrupted, defense, direction, range, resource, position, order.
- 입력 mutation 0.

A3:

- review hierarchy와 버튼 동작.
- review 중 입력 잠금.
- log 상세 연결.
- 다음 묶음·전투 종료·재시작 분기.
- keyboard focus, accessibility semantics, reduced motion, 960×640 layout.
- 기존 전투·AI·절초·중단·재시작 회귀.

## 8. 스택과 롤백

```text
PR #19 / A1
→ PR-A2 agent/repeat-poc-a2-hypothesis-summary
→ PR-A3 agent/repeat-poc-a3-review-ui-closeout
```

A2 롤백 시 가설·summary 계층만 제거하고 기존 판정과 로그를 유지한다. A3 롤백 시 review panel과 `review_ready` 게이트만 제거하고 기존 `next_bundle_ready` 흐름으로 복귀한다.

## 9. 증거 경계

```yaml
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
product_gate: REPEAT_POC
t1_greenlight: NOT_GRANTED
mvp_complete: false
```
