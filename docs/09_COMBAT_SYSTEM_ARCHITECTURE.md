# 십보강호 전투 시스템 아키텍처

> 책임: 현재 T0 전투의 실제 파일·데이터·상태·판정 경계와 STEP 11 이후 확장 계약  
> 규칙 원본: `docs/02_COMBAT_RULES.md`  
> 범위 원본: `docs/05_COMBAT_POC_SPEC.md`

## 1. 아키텍처 원칙

```text
JSON 데이터·사용자 입력
→ 행동 계획 검증
→ 전투 판정 엔진
→ 확정 상태·문자열 로그
→ HUD·전장·슬롯·기록 표현
```

- 전투 결과는 `CombatResolutionEngine`이 계산한다.
- `CombatBoardPreview`는 씬 조립·입력 연결·판정 호출·결과 반영을 담당한다.
- UI는 계획 예상값을 계산할 수 있지만 `[진행]` 전 확정 전투 상태를 바꾸지 않는다.
- 애니메이션·VFX·오디오는 판정을 다시 계산하지 않는다.
- 현재 POC는 typed domain object나 event bus가 아니라 `Dictionary`와 문자열 로그를 사용한다.
- 문서의 목표 모델과 실제 존재하는 클래스·파일을 구분한다.
- 현재 상대는 시드 기반 AI가 아니라 JSON 고정 계획이다.

## 2. 현재 기술 기준

| 항목 | 값 |
|---|---|
| 엔진 feature | Godot 4.7 |
| 언어 | GDScript |
| 렌더러 | GL Compatibility |
| 메인 씬 | `res://scenes/combat/combat_board_preview.tscn` |
| 기준 viewport | 1440×900 |
| window override | 1280×800 |
| 전장 | 10칸, 플레이어 4번·상대 7번 시작 |
| 사용자 확인 | Windows STEP 0~10·TARGETING 10.5, 최신 4/7 확인 대기 |
| 구현 브랜치 | `agent/t0-combat-poc-board` |

목표 플랫폼 성능 예산과 최소 사양은 `NOT_RUN`이다.

## 3. 실제 파일 책임

### 3.1 데이터

| 경로 | 실제 책임 |
|---|---|
| `data/cards/basic_cards.json` | 카드 ID·이름·분류·슬롯·비용·사거리·피해·이동·문구·태그 |
| `data/combat/combat_board_poc.json` | 전장 10칸·플레이어 4번·상대 7번·응답 규칙 메타·레이아웃 계약 |
| `data/combat/combat_action_timing_preview.json` | `[3,3,4]`·현재 라운드·묶음·수·슬롯 상태 |
| `data/combat/combat_hud_preview.json` | 양측 표시 데이터·최대 자원·시작 패널티·기세 fixture |
| `data/combat/combat_resolution_preview.json` | 판정 순서·회복량·방어 수치·상대 고정 행동 계획 |
| `data/combat/combat_progress_preview.json` | 진행 버튼 문구·활성 조건 메타 |
| `data/combat/combat_log_preview.json` | 초기 로그·기록 패널 상태 |

`preview` 명칭은 현재 POC fixture임을 뜻한다. 전체판의 영속 게임 데이터 Schema가 아니다.

### 3.2 시작 위치 계약 소비자

`combat_board_poc.json`이 시작 위치의 데이터 원본이다.

| 소비자 | 책임 |
|---|---|
| `CombatBoardPreview` | 계약값을 읽고 4번·7번에 캐릭터·점유 상태 배치 |
| BoardPreview fallback | 계약 로드 실패 시에도 4번·7번 사용 |
| `CombatResolutionEngine.make_initial_state()` | 전달받은 시작 타일을 `player.tile`, `enemy.tile`에 저장 |
| `tests/check_combat_board_contract.py` | JSON·fallback·Godot verifier·SVG 일치 검사 |
| `tests/verify_combat_board.gd` | 실제 씬 snapshot·메타·이동·공격 fixture 검사 |
| `tests/verify_response_rules.gd` | 대응·자원 독립 fixture 시작 위치 검사 |
| 배치 기준 SVG | 사람용 승인 참고에서 4번·7번과 발 앵커 표현 |
| 책임 원본·Skill·Context | 규칙·범위·검증 상태 전파 |

새 시작 위치를 변경할 때 한 소비자만 수정하지 않는다.

### 3.3 판정·조정

| 경로·클래스 | 실제 책임 |
|---|---|
| `src/combat/combat_resolution_engine.gd` / `CombatResolutionEngine` | 초기 상태·자원 예상·묶음 판정·위치·대응·피해·로그 |
| `src/combat/combat_board_preview.gd` / `CombatBoardPreview` | 씬 조립·카드 선택·대상 선택·진행 신호·판정 결과 적용 |
| `src/ui/action_timing_panel.gd` / `ActionTimingPanel` | 슬롯 점유·대상·예상 자원 유효성·묶음 진행 |
| `src/ui/combat_progress_button.gd` | 진행 가능 상태와 신호 |
| `src/ui/top_combat_hud.gd` | 확정·예상 자원의 상단 표현 |
| `src/ui/combat_log_panel.gd` | 문자열 로그 저장·표시·접기 |

### 3.4 표현

- `scenes/combat/`: 전투판·배경·캐릭터 placeholder.
- `scenes/ui/`: HUD·카드·슬롯·진행·상세·로그.
- `src/ui/`: 각 Control의 데이터 적용·그리기·입력.
- `assets/`: SVG 카드·배경·참고 자산.

## 4. 현재 T0 도메인 모델

아래 이름은 이해를 위한 논리 역할이다. 현재 별도 Resource·class로 모두 구현된 것은 아니다.

### 4.1 논리 `CombatState`

실제 `make_initial_state()` 반환 Dictionary:

```text
round_number
bundle_index
player
enemy
```

`player`와 `enemy`는 HUD 원본 Dictionary를 복사한 뒤 다음을 포함한다.

```text
name
side
faction
portrait_id
health: [current, maximum]
stamina: [current, maximum]
internal: [current, maximum]
momentum: [current, maximum]
statuses
start_penalties
tile
next_attack_bonus
```

초기 타일:

```text
player.tile = 4
enemy.tile = 7
```

- 체력·기력·내력은 최대치−시작 패널티로 초기화한다.
- 기세는 fixture 현재값을 유지한다.
- `current_timing`은 `ActionTimingPanel`이 소유한다.
- 전투 승패·중단·AI 시드·저장 버전은 현재 상태에 없다.

### 4.2 논리 `ActionDefinition`

실제 원본은 카드 JSON Dictionary다.

```text
id
name
source
category
range_text
range
move_range
action_slots
stamina_cost
internal_cost
damage
block
stamina_restore
internal_restore
effect_text
tags
```

현재 판정 단계는 별도 `resolution_phase` 필드가 아니라 카드 분류와 ID로 구분한다.

### 4.3 논리 `PlannedAction`

`ActionTimingPanel.placements`의 실제 Dictionary:

```text
card_id
card_name
definition
anchor_index
span
indices
targeting_mode
target_ready
resource_ready
target_tile
direction
origin_tile
target_text
```

- `execution_timing`은 `anchor_index + span - 1`로 판정 엔진에서 계산한다.
- 이동·공격이 아닌 행동은 `targeting_mode = none`이다.
- 결합 행동은 합성된 `definition` 안에 원본 카드 ID와 결합 효과를 가진다.

### 4.4 논리 `BundlePlan`

현재 별도 `BundlePlan` class는 없다.

- `ActionTimingPanel.timing_data`: 라운드·현재 묶음·현재 수·`[3,3,4]`.
- `placements`: 행동 계획.
- `resource_plan_valid`: 예상 자원 유효성.
- `get_pending_target_anchor()`: 미지정 대상.
- `is_current_bundle_complete()`: 슬롯·대상·자원 완료.
- `get_runtime_context()`: 판정 요청 문맥.

T1에서 AI와 저장·복기가 필요해질 때 명시적 immutable plan object로 승격할 수 있다.

### 4.5 현재 자원 예상 반환

`preview_player_plan()`:

```text
valid
state
invalid_anchors
events
```

- 입력 상태를 복사해 예상 상태를 만든다.
- 실행 수 순서로 비용과 명상 회복을 적용한다.
- 부족 행동 anchor를 반환한다.
- 실제 `combat_state`를 변경하지 않는다.

### 4.6 현재 `ResolutionResult`

`resolve_bundle()`의 실제 반환 Dictionary:

```text
state
logs
resolved_actions
round_number
bundle_index
bundle_start
bundle_end
resolution_order
defenses
```

현재 반환하지 않는 항목:

- `state_before`.
- 별도 `state_after` 키.
- typed `resource_changes`·`damage_results`·`position_changes` 배열.
- event ID·localized log key.

현재 상세 원인은 문자열 로그와 `resolved_actions`, `defenses`에 부분적으로 기록한다.

## 5. 입력·계획 흐름

```text
카드 클릭
→ 현재 묶음 빈 슬롯 클릭
→ span 연속 점유 검사
→ 이동 칸 또는 공격 방향 선택
→ 자원 계획 전체 재계산
→ 진행 가능 상태 갱신
```

현재 검증 실패:

- 현재 묶음이 아님.
- 슬롯이 이미 점유됨.
- span이 묶음 경계를 넘음.
- 대상 방향 또는 목적지가 없음.
- 예상 기력·내력이 부족함.

현재 내부에서 통일된 enum 오류 코드를 반환하지 않는다.

## 6. 판정 호출 흐름

`CombatBoardPreview._on_progress_requested()`:

```text
묶음 완료 재확인
→ 대상 선택 상태 해제
→ resolve_bundle() 동기 호출
→ 반환 state를 combat_state로 교체
→ 문자열 로그 추가
→ ActionTimingPanel 다음 묶음 진행
→ 선택·상세 해제
→ 진행 버튼 판정 완료 상태
→ HUD·전장 위치 갱신
→ 다음 묶음 준비 로그
```

- 현재 판정은 한 신호 호출 안에서 동기적으로 끝난다.
- 판정 단계별 애니메이션 큐나 비동기 입력 잠금 상태는 없다.

## 7. 4/7 시작 fixture 흐름

현재 1묶음 통합 검증의 기준 예:

```text
초기: 플레이어 4 / 상대 7
1수: 플레이어 이동 4→5 / 상대 이동 7→6
2수: 플레이어 명상 / 상대 막기
3수: 플레이어 오른쪽 속공 / 상대 왼쪽 속공
결과: 거리 1에서 속공 단계 판정
```

- 시작 거리 3이므로 이동 전 속공·강공은 사거리 밖이다.
- 양측 첫 이동 뒤 5번·6번에서 인접한다.
- 테스트가 판정 엔진의 다른 fixture에 영향받지 않도록 독립 규칙 테스트에서는 `enemy_bundles`를 비운다.

## 8. 판정 파이프라인

### 8.1 묶음 준비

1. 플레이어 placement를 실행 행동으로 변환한다.
2. 상대 고정 plan을 같은 내부 행동 형태로 변환한다.
3. 모든 대응 비용을 먼저 지불한다.
4. 막기·회피·태세 결합으로 묶음 방어 profile을 만든다.

### 8.2 수별 판정

```text
현재 수 속공
→ 현재 수 이동
→ 현재 수 일반 공격
→ 현재 수 명상·단독 태세
→ 다음 수
```

규칙 표기:

```text
대응 → 속공 → 이동 → 일반 공격
```

- 속공은 이동 전 위치를 사용한다.
- 일반 공격은 이동 후 위치를 사용한다.
- 같은 수·같은 공격 단계의 피해는 동시에 적용한다.
- 별도 합 승패 판정은 없다.

### 8.3 비용

- 대응 비용은 묶음 방어 profile 준비 시 지불한다.
- 속공·이동·일반 행동은 실행 시점에 지불한다.
- 자원 부족이면 해당 행동은 무효다.
- 방향·사거리·목적지 실패는 비용 지불 뒤 발생할 수 있다.
- 명상은 실행 시 회복한다.

## 9. 이동 모델

1. actor의 현재 칸을 읽는다.
2. 플레이어는 지정 목적지, 상대 fixture는 direction·move_range로 목적지를 계산한다.
3. 전장 범위와 이동 거리, 상대 현재 점유 칸을 검증한다.
4. 양측 목적지가 같은 빈 칸인지 확인한다.
5. 유효한 이동을 동시에 적용한다.

현재 제한:

- 같은 칸 중첩 없음.
- 서로 통과 없음.
- 자리 교환 없음.
- 밀치기 없음.

## 10. 공격·대응 모델

### 10.1 공격

1. 비용 지불.
2. 단독 태세의 다음 공격 보너스 읽기.
3. 선택 방향과 상대 방향 비교.
4. 실제 거리와 사거리 비교.
5. 회피 확인.
6. 막기 감소 계산.
7. 최종 피해를 같은 단계 대기 피해에 추가.
8. 단계 종료 시 양측 피해 동시 적용.
9. 최종 피해가 1 이상이면 공격자 기세 1 증가.

### 10.2 대응 profile

```text
guard_timings
evade_timings
bundle_guard
bundle_evade
guard_block
```

- 기본 막기: 묶음 방어도 4, 같은 수 50% 후보.
- 일반 회피: 같은 수 완전 회피.
- 태세+막기: 묶음 방어·방어도 6.
- 태세+회피: 묶음 전체 회피.

RESPONSE 10.6은 구현됐으나 최신 Windows 판정 확인 대기다.

## 11. 로그·표현 경계

### 현재

- 엔진은 플레이어용 한국어 문자열을 직접 생성한다.
- BoardPreview가 `CombatLogPanel.append_entry()`로 추가한다.
- UI는 문자열을 다시 해석하지 않는다.
- 로그는 메모리 Array이며 저장·검색·현지화 구조가 없다.

### T1 권장

```text
event_type
actor_id
timing
phase
source_action_id
target_id
before_values
after_values
reason_code
presentation_key
```

구조화 이벤트를 먼저 만들고 문구는 presentation layer에서 생성한다. T0에서 필요 이상으로 선행 리팩터링하지 않는다.

## 12. STEP 11 확장 경계

피격 중단은 아직 구현되지 않았다.

필요 최소 계약:

```text
pending action execution timing
interruptible flag
actual damage received this timing
focus protection
fortitude protection
hard-control or defeated override
interrupted action ids
```

- 실제 피해는 이후 미실행 행동을 기본 중단한다.
- 같은 단계에서 이미 성립한 공격의 동시성은 유지한다.
- 집중·강건은 일반 피해 중단을 방지한다.
- 사망·강제 제어는 보호보다 우선한다.
- 다중 슬롯 행동의 모든 점유 슬롯을 취소 상태로 표시한다.

현재 `interruption_enabled = false`를 완료 구현으로 오해하지 않는다.

## 13. STEP 12 AI 경계

AI 입력:

- 공개 위치·거리.
- 공개 체력·기력·내력·기세.
- 공개 상태.
- 이전 묶음 행동과 결과.
- 자신의 행동 목록과 성향.

금지 입력:

- 플레이어의 현재 placement.
- 선택 중 카드·포인터 위치.
- 계획 예상 자원.
- UI 상세 상태.

AI 출력은 플레이어와 같은 슬롯·대상·자원 검증을 통과해야 한다.

## 14. STEP 13 종료·재시작 경계

필요 상태:

```text
combat_status
end_reason
input_enabled
final_result
```

- 체력 0 판정.
- 동시 0 처리.
- 종료 뒤 입력 잠금.
- 결과 요약.
- 초기 fixture로 재시작.
- 재시작 시 플레이어 4번·상대 7번으로 복원.
- 노드·신호·로그 누적 없음.

## 15. T1 목표 모델

T0 플레이테스트 뒤 필요성이 확인될 때만 typed 모델로 승격한다.

| 목표 타입 | 도입 이유 |
|---|---|
| `CombatState` | 저장·복기·상태 migration |
| `ActionDefinition` Resource | 무공·심법·수정자 확장 |
| `PlannedAction` | 플레이어·AI 공통 계획과 중단 |
| `BundlePlan` | immutable commit·AI 검증·리플레이 |
| `ResolutionResult` | 구조화 로그·연출 큐·분석 |
| `CombatEvent` | 현지화·VFX·사운드·리플레이 |

이 이름은 목표 인터페이스이며 현재 파일·class가 존재한다고 가정하지 않는다.

## 16. T1 이후 모듈

| 모듈 | 책임 |
|---|---|
| Opponent Profile | 성향·강도·성장·정보 키 |
| Tournament State | 경기·단계·상대 풀 |
| Training State | 무공·심법·수련 포인트 |
| Reward Resolver | 성과·보상 선택 |
| Constraint Resolver | 시작 패널티·행동 제한·추가 보상 |
| Save Data | 회차·상대·성장·재도전 |

문파별 예외를 판정 엔진의 독립 절차로 추가하지 않고 공용 데이터·수정자·이벤트로 연결한다.

## 17. 저장·호환성

현재 T0에는 회차 저장·불러오기가 없다.

향후 원칙:

- 안정된 문자열 ID 사용.
- 표시 이름을 저장 키로 사용하지 않음.
- Schema 버전 기록.
- 필드 추가 시 기본값·migration 제공.
- 상대 성장·AI 시드·보상 결과의 의도치 않은 재추첨 방지.
- 시작 위치를 저장한다면 전장 계약 버전과 함께 migration.

## 18. 검증 경계

### 정적

- JSON 필수·금지 필드.
- 10칸·플레이어 4번·상대 7번·시작 거리 3.
- 3/3/4·8개 행동.
- 카드 비용·사거리·피해.
- 대상·방향·다중 슬롯.
- 대응·자원 예상.
- 문서와 실제 Dictionary 키.
- 코드 fallback·Godot fixture·SVG 최신성.
- 구형 전투 구조의 활성 재등장.

### Godot

- GDScript 파싱.
- 4번·7번 초기 상태와 발 앵커.
- 묶음 판정.
- 4→5·7→6 이동 fixture.
- 위치·자원·피해·라운드.
- RESPONSE·RESOURCE PREVIEW.
- STEP 11 이후 중단.
- STEP 13 이후 종료·재시작.

### 사용자

- 최신 4번·7번 렌더.
- 규칙 이해.
- 실패 이유 설명.
- 상대 성향 발견.
- 재도전 의사.

정적 성공은 Godot·사용자·접근성·성능 검증을 대신하지 않는다.

## 19. 현재 상태

| 범위 | 상태 |
|---|---|
| 시작 위치 4/7 데이터·코드·테스트·SVG | 구현·정적 확인 대기 |
| 시작 위치 4/7 Windows | 미확인 |
| STEP 0~10 | 구현·사용자 부분 확인 |
| TARGETING 10.5 | 구현·사용자 확인 |
| RESPONSE 10.6 | 구현·사용자 확인 대기 |
| RESOURCE PREVIEW 10.6 | 구현·사용자 확인 대기 |
| STEP 11~14 | 미구현·미실행 |
| typed domain model·event bus·save | 미구현 |
| 접근성·성능 | NOT_RUN |
