# 십보강호 전투 시스템 아키텍처

> 책임: 현재 T0 전투의 실제 파일·데이터·상태·판정·AI·연출·재시작 경계  
> 규칙 원본: `docs/02_COMBAT_RULES.md`  
> 범위 원본: `docs/05_COMBAT_POC_SPEC.md`  
> 구현 기준: PR #7 `659c57e7ffa588ad6a6471ed9b5394985b159eaf`, REPEAT_POC PR #19 `agent/repeat-poc-a1-rival-ai`

## 1. 아키텍처 원칙

```text
JSON 데이터·사용자 입력
→ 계획·대상·자원 검증
→ 공개 상태 AI 후보 생성·seed 선택
→ CombatResolutionEngine 단일 묶음 판정
→ 확정 state·timing_results·presentation_events·logs
→ CombatBoardPreview가 수별 snapshot 적용
→ HUD·전장·슬롯·VFX·SFX·로그 표현
```

- `CombatResolutionEngine`이 위치·비용·합·방어·피해·상태·기세·중단을 계산한다.
- `CombatAiPlanner`는 공개 상태만으로 합리 후보를 만들고 결정적 seed로 상대 묶음을 선택한다.
- `CombatBoardPreview`는 씬 조립·입력·판정 호출·순차 표현·종료·재시작을 조정한다.
- `ActionTimingPanel`은 현재 묶음의 배치·대상·예상 자원·진행 가능 상태를 소유한다.
- UI·VFX·오디오는 확정 결과를 재생하며 판정을 다시 계산하지 않는다.
- 현재 POC는 typed domain model이나 event bus가 아니라 `Dictionary`와 문자열 로그를 사용한다.
- 저장·불러오기·리플레이·회차 데이터는 T0에 없다.

## 2. 기술 기준

| 항목 | 값 |
|---|---|
| 엔진 | Godot 4.7 feature set |
| 언어 | GDScript |
| 렌더러 | GL Compatibility |
| 메인 씬 | `res://scenes/combat/combat_board_preview.tscn` |
| viewport | 1440×900 |
| window override | 1280×800 |
| 최소 레이아웃 회귀 | 960×640 |
| 구현 브랜치 | `agent/repeat-poc-a1-rival-ai` |
| 제품 기준 SHA | `659c57e7ffa588ad6a6471ed9b5394985b159eaf` |

목표 플랫폼 Release 성능 예산은 `NOT_RUN`이다.

## 3. 실제 파일 책임

### 3.1 데이터

| 경로 | 책임 |
|---|---|
| `data/cards/basic_cards.json` | 기초 행동 8종 ID·슬롯·비용·사거리·피해·문구·태그 |
| `data/cards/ultimate_cards.json` | 절초 3종·단계·슬롯·사거리·계수·필중 |
| `data/combat/combat_board_poc.json` | 전장·4/7·UI 구조·밀착·절초·응답·엔진 메타 |
| `data/combat/combat_action_timing_preview.json` | `[3,3,4]`·라운드·묶음·수·슬롯 상태 |
| `data/combat/combat_hud_preview.json` | 양측 30/5/4/0~5·공격력 8·표시 데이터 |
| `data/combat/combat_resolution_preview.json` | 판정 순서·방어·합·기세·중단·AI source 계약 |
| `data/combat/combat_rival_tendency_poc.json` | 활성 라이벌·공개 단서·후보 수·score window·가중치 |
| `data/combat/combat_progress_preview.json` | 진행 버튼 문구·활성 조건 |
| `data/combat/combat_log_preview.json` | 초기 로그·패널 상태 |

`preview`와 `poc`는 T0 fixture·기술 계약을 뜻하며 전체판 영속 Schema가 아니다.

### 3.2 도메인·조정

| 경로·클래스 | 책임 |
|---|---|
| `src/combat/combat_resolution_engine.gd` / `CombatResolutionEngine` | 초기 상태·예상 자원·묶음 판정·합·방어·이동·중단·기세·이벤트 |
| `src/combat/combat_ai_planner.gd` / `CombatAiPlanner` | 공개 snapshot·후보 scoring·score window 필터·seed 선택·개발자 trace |
| `src/combat/combat_board_preview.gd` / `CombatBoardPreview` | 씬·입력·판정 호출·snapshot 재생·종료·재시작 |
| `src/ui/action_timing_panel.gd` / `ActionTimingPanel` | 슬롯 점유·대상·예상 자원·묶음 진행 |
| `src/ui/combat_progress_button.gd` | 진행 가능 상태·요청 신호 |
| `src/ui/top_combat_hud.gd` | 확정·예상 자원과 상태 표현 |
| `src/ui/combat_log_panel.gd` | 문자열 로그 저장·표시·접기 |

### 3.3 표현·자산

- `scenes/combat/`: 배경·전장·타일·전투원.
- `scenes/ui/`: HUD·카드·슬롯·상세·로그·진행.
- `src/ui/`: Control 데이터 적용·그리기·입력.
- `assets/`: 배경·전투원·초상·카드·VFX·SFX와 manifest.

## 4. 시작 위치와 전장 계약 소비자

`data/combat/combat_board_poc.json`이 전장 메타 원본이다.

```text
combat_board_poc.json schema 17
→ CombatBoardPreview 4/7 로드와 fallback
→ CombatResolutionEngine.make_initial_state(player_tile, enemy_tile)
→ ActionTimingPanel 대상 예상 위치
→ CombatAiPlanner 공개 위치 입력
→ board/response/AI/restart verifier
→ 참조 SVG·활성 문서·Skill·Context
```

전장 규칙 변경은 다음을 함께 확인한다.

- `tile_count`, `player_start_tile`, `enemy_start_tile`.
- 밀착·한 칸 최대 2인.
- 정지 상대 진입·공동 목적지.
- 자리 교환·통과 금지.
- 대상 후보·캐릭터 발 앵커·상태·로그.

## 5. 현재 `CombatState`

`CombatResolutionEngine.make_initial_state()`가 반환하는 최상위 Dictionary:

```text
round_number
bundle_index
player
enemy
ai_decision_seed
```

`CombatBoardPreview`가 런타임에서 추가한다.

```text
ai_enabled = true
```

`player`·`enemy`의 주요 필드:

```text
name
epithet
side/faction 표시 데이터
health: [current, maximum]
attack_power
stamina: [current, maximum]
internal: [current, maximum]
momentum: [current, maximum]
statuses
start_penalties
tile
next_attack_bonus
fortitude_next_attack
```

- 초기 타일은 4/7이다.
- 체력·기력·내력은 최대치에서 시작 패널티를 차감한다.
- 기세는 0/5에서 시작한다.
- 동적 상태는 `next_attack_bonus`, `fortitude_next_attack`와 동기화한다.
- 전투 종료 여부는 현재 별도 영속 state enum이 아니라 체력과 `CombatBoardPreview._presentation_state`로 조정한다.

## 6. 행동 정의와 계획

### 6.1 `ActionDefinition`

실제 원본은 카드 JSON Dictionary다.

```text
id
name
source
category
resolution_phase
range_text
range
move_range
dash_before_attack
action_slots
stamina_cost
internal_cost
damage
attack_power_coefficient
block
restore fields
effect_text
tags
targeting_mode
```

기초 카드에 없는 필드는 기본값으로 처리한다. `action_point_cost`와 공통 `guard_reduction`은 금지 필드다.

### 6.2 `PlannedAction`

`ActionTimingPanel.placements`의 주요 필드:

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

엔진 변환 뒤:

```text
actor
anchor_index
span
execution_timing = anchor_index + span - 1
definition
targeting_mode
target_tile
direction
origin_tile
```

- 다중 슬롯 앞 수는 준비, 마지막 수는 실행이다.
- 결합 행동은 합성 definition에 원본 카드와 대응 효과를 가진다.
- 절초도 같은 placement·대상·묶음 경계 계약을 사용한다.

### 6.3 계획 미리보기

`preview_player_plan(state, placements)` 반환:

```text
valid
state
invalid_anchors
events
```

입력 state를 깊은 복사해 비용·명상 회복을 실행 순서로 계산하고 실제 `combat_state`는 변경하지 않는다.

## 7. 공개 상태 라이벌 후보 AI 경계

`CombatAiPlanner.build_bundle_actions(state, bundle_index, cards_by_id)` 시그니처를 유지한다. 내부 pipeline은 다음과 같다.

```text
공개 CombatState
→ whitelist public_snapshot
→ 활성 rival profile 가중치
→ 행동 후보 scoring
→ 최고점 - 2.0 score window
→ 최대 3개 rational candidates
→ round/bundle 범위 결정 seed
→ 행동 1개와 개발자 trace
```

### 7.1 tendency 데이터

`data/combat/combat_rival_tendency_poc.json`:

```text
schema_version = 1
active_rival_id = rival_t0_midrange_pressure
max_candidates = 3
score_window = 2.0
profiles[0].public_clues
profiles[0].weights
```

현재 공개 단서 ID는 `midrange_pressure`, `safe_heavy_prepare`, `low_health_response`다.

### 7.2 `public_snapshot` whitelist

```text
round_number
bundle_index
bundle_start
bundle_slots
player_tile
enemy_tile
distance
player_health
enemy_health
enemy_health_max
enemy_stamina
enemy_internal
enemy_momentum
enemy_momentum_max
ai_decision_seed
```

플래너는 입력 state 전체를 trace에 복사하지 않는다.

### 7.3 출력 행동

한 묶음에 대표 행동 하나를 반환한다.

```text
timing
card_id
targeting_mode
target_tile
direction
ai_seed
ai_reason
```

`ai_reason`은 `public_distance_<거리>`와 선택된 공개 reason code를 결합한다.

### 7.4 개발자 trace

`get_last_trace() -> Dictionary`의 허용 키:

```text
public_snapshot
rival_id
candidate_ids
candidate_scores
selected_card_id
seed
reason_codes
```

- 같은 공개 상태·seed는 같은 행동과 trace를 반환한다.
- 다른 seed도 합리 후보 밖 행동을 선택하지 않는다.
- trace는 정적·Godot 검증용이며 플레이어 UI에는 노출하지 않는다.

### 7.5 금지 입력

- 플레이어 현재 placement.
- 미확정 대상·방향.
- 절초 예약.
- 예상 자원.
- 포인터·포커스·상세 패널.

운영 계약은 `combat_resolution_preview.json.enemy_plan_source = public_state_ai`이며 `enemy_bundles`는 빈 객체다. 테스트가 fixture plan을 주입할 수 있는 유일한 경계는 `ai_enabled == false`인 독립 회귀다. `ai_enabled == true`인 `CombatBoardPreview` 런타임은 `CombatAiPlanner`만 사용한다.

## 8. 묶음 판정과 반환 구조

`resolve_bundle(player_placements, context, state)`는 다음을 수행한다.

1. 입력 state를 깊은 복사한다.
2. 플레이어 계획과 AI 계획을 내부 행동으로 만든다.
3. 대응 비용과 방어 profile을 준비한다.
4. 각 수의 준비 이벤트를 기록한다.
5. 속공·이동·일반 행동을 규칙 순서로 계산하되 같은 수 공격을 `deferred_attacks`에 모은다.
6. 같은 수 공격군의 합·단독 피해·방어·중단을 한 번 정산한다.
7. utility 행동을 적용한다.
8. 각 수의 state snapshot과 presentation event를 저장한다.
9. 묶음 완료 기세를 지급한다.

반환 Dictionary:

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
timing_results
presentation_events
```

`timing_results` 항목:

```text
timing
phase
state
events
```

현재 구조화 event와 문자열 로그가 함께 존재한다. event ID·현지화 키·typed result class·리플레이 직렬화는 T1 이후 후보다.

## 9. 판정 세부 경계

### 9.1 대응

- 묶음 시작 시 대응 비용을 지불하고 profile을 만든다.
- 막기 방어도 4, 같은 수는 차감 뒤 반감.
- 태세+막기 방어도 6, 묶음 전체.
- 회피는 같은 수, 태세+회피는 묶음 전체.

### 9.2 공격과 합

- 속공은 이동 전에 돌진·위치·유효성을 계산한다.
- 같은 실행 수의 속공·일반 공격은 같은 공격군에서 합을 판정한다.
- 합은 원공격력 차이를 피해 후보로 만든다.
- 파공검기 `[필중]`은 회피만 무시한다.
- 합 정산 뒤 피해·중단·전투 불능을 한 번 반영한다.

### 9.3 이동

- 전장 범위와 카드 이동 거리를 확인한다.
- 정지 상대 칸과 공동 빈 목적지를 허용한다.
- 자리 교환·상대 통과를 금지한다.
- 유효 이동을 동시에 적용한다.

### 9.4 중단·강건

- 실제 피해가 발생한 같은 수의 미실행 행동만 기본 중단한다.
- 준비 이벤트와 이후 수 계획은 유지한다.
- 전투 불능은 이후 행동을 취소한다.
- 강건은 1슬롯 속공 단계 중단만 한 번 막고 피해는 유지한다.

## 10. 순차 표현 상태

`CombatBoardPreview`의 표현 상태:

```text
planning
→ committed
→ resolving
→ presenting_result
→ next_bundle_ready
```

체력 0이면:

```text
combat_ended
```

- `planning`, `next_bundle_ready`에서만 일반 계획 입력을 허용한다.
- 엔진 결과의 각 `timing_results.state`를 수별로 적용한다.
- 캐릭터 이동·HUD·기세·상태가 해당 수에 갱신된다.
- VFX·SFX·텍스트는 event를 소비한다.
- 빠른 재생·즉시 완료·모션 감소도 같은 state를 사용한다.

## 11. 종료·재시작

`CombatBoardPreview._combat_has_ended()`는 양측 health current가 0 이하인지 확인한다.

종료 시:

- `_presentation_state = combat_ended`.
- 계획 입력 잠금.
- 종료 결과 문구·로그.
- 재시작 버튼 표시.

`restart_combat()`은 다음을 초기화한다.

- presentation skip·event·history.
- 선택 행동·대상 상태.
- 절초 예약 anchor.
- resolution/progress count.
- 재생 중 audio·VFX·결과 라벨.
- `ActionTimingPanel.reset_to_initial()`.
- `make_initial_state()`의 4/7·30/5/4/0~5 상태.
- `ai_enabled = true`.
- `planning`과 포커스·진행 가능 상태.

현재 저장 파일을 복원하는 재도전이 아니라 동일 POC fixture의 완전 초기화다.

## 12. 표현·접근성 경계

- Control은 state와 event를 표현한다.
- 카드·슬롯·타일·진행·재생·재시작·옵션에 명시적 포커스를 설정한다.
- `accessibility_name`·설명은 한국어 기능과 결과를 전달한다.
- 모션 감소·음향 끄기에서 텍스트·상태·로그가 남는다.
- UI Automation 기술 노출과 실제 보조기기 사용성은 별도 증거다.

## 13. 현재 없는 영속 구조

T0에는 다음이 없다.

- 회차 저장·불러오기.
- 전투 중 저장과 계획 복구.
- 리플레이 파일.
- 보상·수련·대회 상태.
- 상대 성장·전투 간 성향 프로필 영속화.
- Schema migration.

T1에서 필요성이 확인될 때 다음 typed 모델을 검토한다.

| 후보 | 이유 |
|---|---|
| `CombatState` | 저장·복기·migration |
| `ActionDefinition` Resource | 무공·심법·수정자 확장 |
| immutable `PlannedAction`/`BundlePlan` | AI·저장·리플레이 |
| `ResolutionResult` | 구조화 로그·분석·연출 큐 |
| `CombatEvent` | 현지화·VFX·사운드·리플레이 |

T0 기술 구현 전에 필요 이상으로 선행 리팩터링하지 않는다.

## 14. 검증 경계

### 정적·자동

- JSON Schema와 ID·필드.
- 10칸·4/7·거리 3·밀착.
- `[3,3,4]`·기초 8종·절초 3종.
- 카드 비용·사거리·피해·계수.
- 합·방어·회피·필중·중단·강건.
- 라이벌 tendency schema·공개 단서·후보 3개·score window 2.0.
- 같은 공개 상태·seed 결정론과 합리 후보 경계.
- AI snapshot·trace의 whitelist와 금지 입력.
- 종료·재시작 초기화.
- 문서·Skill·fallback·fixture 최신성.

### Godot·Windows

- GDScript 파싱과 씬 실행.
- 전장·발 앵커·대상·판정.
- 수별 snapshot·VFX·SFX·입력 잠금.
- 키보드·최소 해상도·UI Automation.
- `verify_ai_rival_tendency.gd`의 결정론·후보 경계·비공개 입력 차단.
- Ubuntu·Windows × Python 계약 매트릭스와 Ubuntu Godot headless는 Full Validation에서 분리 실행한다.

### 사람

- 규칙 이해와 실패 복기.
- AI 성향 발견과 공정성 신뢰.
- 절초 투자 판단.
- 계획 수정·재도전 행동.
- 보조기기·모션·음향 장벽.

현재 사람 검증은 `DEFERRED_BY_USER / UNVERIFIED`다. 실행하지 않은 범위를 기술 `PASS`로 대체하지 않는다.
