# 십보강호 전투 시스템 아키텍처

> 책임: 현재 T0 전투 판정·데이터·UI 경계와 T1 이후 확장 지점  
> 규칙 원본: `docs/02_COMBAT_RULES.md`  
> 범위 원본: `docs/05_COMBAT_POC_SPEC.md`

## 1. 핵심 원칙

```text
데이터와 입력
→ 전투 도메인 판정
→ 구조화된 결과·로그
→ UI·VFX·오디오 표현
```

- 전투 규칙은 씬·애니메이션과 분리한다.
- UI는 입력과 계획 예상값을 제공하지만 피해·자원·승패를 확정하지 않는다.
- VFX·애니메이션·오디오는 확정 결과를 재생하며 다시 계산하지 않는다.
- 같은 입력과 시드에서 재현 가능한 판정을 목표로 한다.
- 문파·무공은 공용 판정 단계와 수정 지점을 사용하며 임의의 별도 해상 절차를 만들지 않는다.
- 현재 T0에는 과거 `행동력`, `2수 잠금`, `합 수치 비교` 구조를 사용하지 않는다.

## 2. 현재 기술 기준

- 엔진: Godot 4.7 feature set
- 언어: GDScript
- 렌더러: GL Compatibility
- 사용자 확인 플랫폼: Windows 데스크톱
- 메인 씬: `res://scenes/combat/combat_board_preview.tscn`
- 구현 브랜치: `agent/t0-combat-poc-board`
- 구현 PR: Draft PR #7

목표 플랫폼 성능 예산과 최소 사양은 아직 `NOT_RUN`이다.

## 3. 시스템 층

| 층 | 책임 | 대표 경로 |
|---|---|---|
| 카드 데이터 | ID·비용·사거리·피해·이동량·태그 | `data/cards/basic_cards.json` |
| 전투 fixture | 전장·시작 위치·HUD·적 고정 계획 | `data/combat/` |
| 전투 판정 | 위치·자원·대응·공격·피해·라운드 | `src/combat/combat_resolution_engine.gd` |
| 전장 조정 | 씬 구성·카드 선택·슬롯·대상·로그 연결 | `src/combat/combat_board_preview.gd` |
| 행동 계획 UI | 슬롯 점유·대상·예상 자원·진행 조건 | `src/ui/action_timing_panel.gd` 등 |
| 표현 | 전장·캐릭터·카드·HUD·로그 | `scenes/`, `src/ui/` |
| 검증 | 데이터·정적 계약·Godot 통합 | `tests/`, `tools/` |

## 4. T0 도메인 모델

### 4.1 `CombatState`

전투의 확정 상태를 소유한다.

```text
round_number
bundle_index
current_timing
board_size
player_position
enemy_position
player/enemy health, stamina, internal, momentum
status and future interruption flags
```

- UI 노드의 텍스트나 색을 상태 원본으로 사용하지 않는다.
- 전투 시작 시 체력·기력·내력을 최대치−시작 패널티로 초기화한다.
- 절초 기세는 fixture 값에서 시작하며 자동 완충하지 않는다.

### 4.2 `ActionDefinition`

카드가 가진 불변 데이터다.

```text
id
name
category
resolution_phase
action_slots
stamina_cost
internal_cost
range
move_range
damage
defense
recovery
tags
```

실제 필드의 책임 원본은 `basic_cards.json`이다. UI에 표시하지 않는 내부 필드와 플레이어 문구를 구분한다.

### 4.3 `PlannedAction`

행동 슬롯에 배치된 실행 계획이다.

```text
action_id
start_timing
occupied_timings
execute_timing
target_tile
attack_direction
combo_action_ids
validation_state
```

- 다중 슬롯 행동은 마지막 점유 수에서 실행한다.
- 이동·공격은 명시적 대상 또는 방향을 가진다.
- UI는 계획을 수정할 수 있지만 `[진행]` 뒤 해당 묶음은 불변이다.

### 4.4 `BundlePlan`

현재 행동 묶음의 계획과 검증 결과다.

```text
round
bundle
editable_timings
planned_actions
predicted_stamina
predicted_internal
is_complete
validation_errors
```

예상 자원은 계획 검증용이며 확정 전투 자원과 분리한다.

### 4.5 `ResolutionResult`

판정 엔진이 반환하는 구조화된 결과다.

```text
state_before
state_after
timing_results
resource_changes
position_changes
damage_results
response_results
invalid_actions
log_entries
```

UI는 이 결과를 표현하며 결과 수치를 다시 계산하지 않는다.

## 5. 행동 배치·검증 흐름

```text
카드 선택
→ 빈 슬롯 선택
→ 다중 슬롯 점유 검사
→ 이동 목적지·공격 방향 선택
→ 실행 순서대로 예상 자원 계산
→ 묶음 완성 여부 계산
→ 진행 가능 상태 갱신
```

검증 오류 코드 예:

- `slot_occupied`
- `bundle_boundary_exceeded`
- `target_required`
- `invalid_target`
- `direction_required`
- `insufficient_stamina`
- `insufficient_internal`

플레이어용 로그와 내부 오류 코드를 분리한다.

## 6. 판정 파이프라인

### 6.1 묶음 준비

1. 플레이어 계획의 슬롯·대상·비용을 최종 검증한다.
2. 적 fixture 또는 향후 AI 계획을 같은 형식으로 준비한다.
3. 막기·회피·태세 결합을 묶음 대응 프로필로 만든다.
4. 계획을 불변 입력으로 판정 엔진에 전달한다.

### 6.2 수별 판정

```text
대응 준비
→ 현재 수 속공
→ 현재 수 이동
→ 현재 수 일반 공격·일반 행동
→ 구조화 결과와 로그
→ 다음 수
```

- 속공은 이동보다 먼저 실행된다.
- 일반 공격은 이동 후 실제 위치를 사용한다.
- 같은 수·같은 공격 단계의 쌍방 피해는 동시에 적용한다.
- 현재 T0에는 별도 `ClashResolver`나 합 차이 피해가 없다.

### 6.3 이동

- 지정한 목적지와 실행 시점의 위치를 검증한다.
- 전장 밖·상대 점유 칸은 실패한다.
- 양측이 같은 빈 칸으로 이동하면 둘 다 제자리다.
- 통과·자리 교환·중첩은 현재 `HOLD`다.

### 6.4 공격

- 선택 방향과 상대 방향을 비교한다.
- 실제 거리와 카드 사거리를 비교한다.
- 비용·상태·중단 여부를 확인한다.
- 성립한 공격의 피해와 대응 결과를 계산한다.

## 7. 대응 모델

묶음 시작 시 각 전투원의 대응 프로필을 만든다.

```text
guard_timings
evade_timings
bundle_guard_enabled
bundle_evade_enabled
defense_value
```

### 막기

- 같은 수 후보: 원피해의 50% 감소
- 같은 묶음 후보: 방어도만큼 감소
- 최종 감소량: 두 후보의 최댓값

### 회피

- 일반 회피: 같은 수 완전 회피
- 태세+회피: 묶음 전체 완전 회피

### 태세+막기

- 묶음 전체 막기
- 방어도 4→6

대응 결과에는 원피해·후보 감소량·선택 효과·최종 피해를 포함해 로그가 이유를 설명할 수 있게 한다.

## 8. 자원 모델

### 확정 상태

- 전투 도메인이 현재 기력·내력을 소유한다.
- 행동 판정 시 비용을 적용한다.
- 명상 판정 시 회복을 적용한다.
- 최대치를 초과하지 않는다.

### 계획 예상값

- 현재 묶음의 행동을 실행 수 순서로 가상 계산한다.
- 비용과 명상 회복을 같은 규칙으로 적용한다.
- 값이 0 미만이 되는 첫 행동을 자원 부족으로 표시한다.
- 배치 변경마다 처음부터 재계산한다.
- `[진행]` 전에는 확정 상태를 변경하지 않는다.

같은 계산 규칙을 공유하되 예상 상태와 확정 상태의 객체·책임을 분리한다.

## 9. 구조화 이벤트·로그

권장 이벤트:

- `action_planned`
- `action_removed`
- `target_selected`
- `bundle_committed`
- `response_prepared`
- `action_started`
- `move_resolved`
- `attack_hit`
- `attack_missed`
- `damage_reduced`
- `attack_evaded`
- `resource_changed`
- `action_invalid`
- `bundle_completed`
- `round_advanced`

STEP 11 이후:

- `action_interrupted`
- `interruption_prevented`
- `actor_defeated`

이벤트에는 원인 코드와 플레이어용 로그 키를 함께 둘 수 있지만 UI 문자열 자체를 판정 입력으로 사용하지 않는다.

## 10. STEP 11 확장 경계

피격 중단은 아직 구현 완료가 아니다.

필요한 데이터:

```text
interruptible
pending_action_ids
focus
fortitude
hard_control
defeated
```

예정 규칙:

- 실제 피해는 이후 미실행 행동을 기본 중단한다.
- 같은 단계에서 이미 성립한 공격의 동시성은 유지한다.
- 집중·강건은 일반 피해 중단을 방지한다.
- 사망·강제 제어는 집중·강건보다 우선한다.

현재 구현에 이 상태가 존재한다고 가정하지 않는다.

## 11. STEP 12 AI 경계

`AiPlanner`는 다음 공개 정보만 사용한다.

- 양측 위치·거리
- 공개 체력·기력·내력·기세
- 공개 상태
- 이전 수와 묶음의 행동·결과
- 자신의 행동 정의와 성향

사용 금지:

- 플레이어의 현재 비공개 계획
- 포인터 위치·선택 중 카드
- UI 미리보기 상태

최소 성향 예:

- 접근 선호
- 거리 유지
- 자원 부족 시 명상 선호
- 공격 예상 시 대응 선호
- 강공 준비 빈도
- 제한된 실수 확률

AI 출력은 플레이어와 같은 `BundlePlan` 형식을 사용한다.

## 12. STEP 13 종료·재시작 경계

필요 상태:

- `combat_status: active/player_win/enemy_win/draw`
- 종료 원인
- 최종 로그
- 입력 잠금
- 초기 fixture 재적용

재시작은 씬 재생성 여부와 무관하게 전투 상태·슬롯·대상·HUD·로그를 동일한 초기 fixture로 되돌려야 한다.

## 13. T1 이후 확장

T0 통과 뒤 다음을 별도 모듈로 추가한다.

| 모듈 | 책임 |
|---|---|
| `OpponentProfile` | 성향·강도·성장·정보 키 |
| `TournamentState` | 경기·단계·상대 풀 |
| `TrainingState` | 무공·심법·수련 포인트 |
| `RewardResolver` | 성과·보상 선택 |
| `ConstraintResolver` | 시작 패널티·행동 제한·추가 보상 |
| `SaveData` | 회차·상대·성장·재도전 |

이 모듈은 현재 T0 판정 엔진에 문파 전용 분기를 삽입하지 않고 공용 데이터·수정자·이벤트로 연결한다.

과거 합·무기 교체·밀치기·장전·보조병장은 재설계 승인 전 `HOLD`다.

## 14. 저장·호환성

현재 T0에는 전체 회차 저장이 완료되지 않았다.

향후 원칙:

- 안정된 문자열 ID를 사용한다.
- 표시 이름을 저장 키로 사용하지 않는다.
- Schema 버전을 저장한다.
- 데이터 필드 추가 시 기본값과 migration을 제공한다.
- 상대 성장·AI 시드·보상 결과는 재도전에서 임의 재추첨하지 않는다.

## 15. 검증 경계

### 정적

- JSON 구조와 필수·금지 필드
- 10칸·3/3/4·8개 행동
- 대상·방향·다중 슬롯
- 대응·자원 예상 계약
- 구형 2수·행동력·합 구조의 현행 재등장

### 런타임

- Godot 파싱
- 묶음별 판정
- 위치·자원·피해·라운드 변화
- 포인터·키보드 입력
- 종료·재시작

### 사용자

- 규칙 이해
- 실패 이유 설명
- 상대 성향 발견
- 재도전 의사

정적 성공은 런타임·사용자 검증을 대신하지 않는다.

## 16. 현재 상태

- STEP 0~10: 구현
- TARGETING 10.5: 구현·사용자 확인
- RESPONSE 10.6: 구현·사용자 확인 대기
- RESOURCE PREVIEW 10.6: 구현·사용자 확인 대기
- STEP 11~14: 미구현·미실행
