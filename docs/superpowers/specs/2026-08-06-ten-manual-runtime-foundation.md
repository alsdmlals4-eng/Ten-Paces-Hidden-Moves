# 초기 무공서 10권 런타임 기반 설계

> Decision gate: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`  
> 사용자 승인: `2026-08-06 권장안대로 진행`  
> 부모 Decision: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`  
> 상태: `APPROVED_RUNTIME_FOUNDATION_DESIGN`

## 목표

승인된 초기 무공서 10권의 3·5·7·9·10성 구조를 Godot 런타임이 읽고 검증하고 실행할 수 있는 기반으로 옮긴다. 현행 기본 행동 8종과 공용 절초 3종은 호환 회귀 기준으로 유지하며, UI 전면 교체와 최종 밸런스 조정은 이 기반 검증 뒤 별도 단계에서 진행한다.

## 선택한 접근

### 채택: 호환 레지스트리 + 순차 효과 프로그램

1. `data/cards/martial_manual_cards.json`을 초기 10권의 런타임 카드 정본으로 추가한다.
2. 각 무공서는 3성 기술1, 5성 기술1 overlay, 7성 기술2, 9성 기술2 단일 overlay, 10성 절초를 가진다.
3. `MartialManualRegistry`가 숙련도에 따라 3·7·10성 카드를 해금하고 5·9성 overlay를 정확한 대상 카드에 합성한다.
4. 카드 효과는 카드명별 하드코딩 대신 순서가 있는 `effect_steps`로 표현한다.
5. `MartialEffectPipeline`이 상태 선행, 이동, 사거리 재확인, 독립 타격, 조건부 후속, 자원·상태 획득, 전투당 사용권을 결정적으로 처리한다.
6. `CombatResolutionEngine`은 기존 기본·공용 절초 로드를 유지하면서 새 레지스트리의 해금 카드를 선택적으로 병합한다.

### 기각: 기존 카드 전면 교체

공용 절초 3종과 현재 UI·AI·회귀 테스트를 즉시 10권 카드로 교체하면 변경 범위가 지나치게 커지고, 무공별 문제와 UI·AI 문제를 분리해 진단하기 어렵다.

### 기각: 데이터만 추가

JSON만 추가하고 실제 Godot 로더·효과 실행기를 두지 않으면 `PLANNING_ONLY` 상태를 실질적으로 벗어나지 못한다.

## 런타임 데이터 계약

- 능력치별 권수·균등 분포·최소/최대 쿼터는 존재하지 않는다.
- 각 무공서의 `primary_stat`, `secondary_stat`은 승인된 문파·무학 적합성과 정확히 일치해야 한다.
- 각 무공서에는 카드 3개와 overlay 2개가 정확히 존재한다.
  - 카드: `star3`, `star7`, `star10`
  - overlay: `star5 -> star3`, `star9 -> star7`
- 9성 overlay는 `effect_steps`를 정확히 하나만 추가하며 분기·추가 입력·추가 비용을 만들지 않는다.
- 각 실행 카드에는 다음 필드가 필요하다.
  - `id`, `name`, `manual_id`, `unlock_star`
  - `category`, `resolution_phase`, `targeting_mode`
  - `action_slots`, `stamina_cost`, `internal_cost`
  - `range.min`, `range.max`
  - `effect_steps`
  - `budget_reference`
- 최종 수치가 아직 사람 밸런스 검증을 받지 않은 필드는 `balance_status: PROVISIONAL_WITHIN_APPROVED_BUDGET`으로 표시한다.

## 효과 단계 최소 어휘

첫 런타임 기반에서 허용하는 단계는 다음으로 제한한다.

- `GAIN_STATUS`
- `GAIN_RESOURCE`
- `CONSUME_STATUS`
- `CONSUME_ONCE_PER_BATTLE`
- `MOVE_TOWARD`
- `MOVE_AWAY`
- `RECHECK_RANGE`
- `ATTACK`
- `INDEPENDENT_ATTACK`
- `SPECIAL_CLASH`
- `BREAK_DEFENSE`
- `PUSH_TARGET`
- `REQUIRE_ACTUAL_HP_HITS`
- `REQUIRE_DEFENSE_ZERO`
- `REQUIRE_CLASH_WIN`
- `REQUIRE_EVADE_SUCCESS`
- `GAIN_MOMENTUM_ON_COMPLETE`
- `START_DEFENSE_LOSS_RECORD`
- `END_DEFENSE_LOSS_RECORD`

새 독·출혈·무작위 타수·숨은 계획 열람·자동 합 승리 효과는 추가하지 않는다.

## 특수 불변조건

### 자하신공

- 전투당 사용권은 전조 시작 단계에서 즉시 소모한다.
- 이후 중단·전투불능이 되어도 사용권을 환불하지 않는다.
- 절초기세 +1은 전체 효과 프로그램 완료 시에만 지급한다.
- 전투 중 사용권 재충전은 없다.

### 나한금강공

- 방어·강건 생성 단계가 공격 또는 전조보다 먼저 실행된다.
- 강건은 현행 중단 방지 규칙만 사용한다.
- 강건 소진 뒤에는 정상적으로 중단될 수 있다.
- 무적·피해 무시·절대 중단 면역을 만들지 않는다.

### 이동과 공격

- 공격 전에 이동하거나 공격 사이에 이동하면 다음 공격 전에 반드시 `RECHECK_RANGE`가 존재해야 한다.
- 회마창은 첫 찌르기 → 후퇴 → 사거리 재확인 → 두 번째 찌르기 순서를 고정한다.
- 소요 반격은 회피 성공 → 이동 전 반격 → 이동 순서를 고정한다.

## 호환 경계

- `basic_cards.json`과 `ultimate_cards.json`은 삭제하거나 ID를 바꾸지 않는다.
- 기존 `cards_by_id` 조회는 계속 동작한다.
- 새 카드는 명시적인 무공서 loadout과 숙련도 정보가 있을 때만 병합한다.
- 기존 AI가 새 무공을 자동 선택하지 않는다. AI 이식은 별도 승인 범위다.
- 현행 Scene과 액션 선택 UI는 이번 단계에서 전면 교체하지 않는다.

## 검증

### Python 계약

- 10권 roster·문파·능력치·이름 일치
- 카드 3개·overlay 2개 구조
- 5성·9성 대상과 단일 효과 규칙
- 허용 effect-step 어휘
- 특수 규칙 순서
- 공용 카드 호환성

### Godot 런타임

- 숙련도 3/5/7/9/10별 해금과 overlay 합성
- 원본 JSON 불변성
- 상태 선행 실행
- 독립 다단과 조건부 후속
- 이동 뒤 사거리 재확인
- 자하 사용권 소모·미환불·완료 보상
- 강건의 제한된 중단 방지
- 기존 기본·공용 절초 카드 조회 회귀

## 범위 밖

- 최종 피해 계수·사람 밸런스 승인
- 모든 카드의 최종 일러스트·연출·음향
- 무공서 선택 UI 전면 교체
- 적 AI의 10권 무공 운용
- 모바일 UX와 접근성 사람 검증
- PR 병합·Draft 해제
