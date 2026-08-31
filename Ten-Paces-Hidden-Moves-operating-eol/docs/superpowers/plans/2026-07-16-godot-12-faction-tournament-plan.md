# Godot 2D 12세력 대회 세로 슬라이스 구현 Plan

> **실행 담당자:** 이 Plan의 각 작업은 테스트를 먼저 작성하고, 한 작업 단위가 끝날 때마다 독립 커밋한다.

**Plan 목적:** Godot 4.7.1에서 12세력의 비공개 동시 선택 결투와 내부전부터 결승까지의 9전 회차를 Windows 데스크톱으로 실행 가능하게 만든다.

**구조:** 순수 GDScript 전투 시뮬레이터가 상태와 이벤트를 만들고, Godot 2D 씬은 이를 표시한다. 무기·문파·무공·AI·대진은 Resource 데이터와 카탈로그로 구성해 문파 이름별 엔진 분기를 금지한다.

**기술:** Godot 4.7.1, GDScript, Control 기반 UI, Node2D 전장, Godot headless 테스트 러너, Windows 데스크톱 export.

## 전역 제약

- 10칸 전장, 모든 경기 A=4·B=6·초기 거리 2.
- 같은 칸 중첩·교차·자리 교환을 허용한다.
- 6슬롯 행동열을 양측 비공개로 잠근 뒤 동시에 공개한다.
- 공용 행동은 접근, 후퇴, 공격, 막기, 회피, 밀치기, 무기 교체, 재장전이다.
- 유파 무공·대성은 수치·조건 수정자로만 구현한다.
- AI는 플레이어의 비공개 행동열을 읽거나 잠금 뒤 변경할 수 없다.
- 시작 6세력: 화산, 개방, 당문, 소림, 무당, 마교. 추가 6세력: 양가장, 백우궁, 관군, 아미, 오독, 녹림채.
- 대사·세계관·관계, 덱빌딩, 장비 강화·경제, Steamworks 기능은 포함하지 않는다.

## 확정 전투 수치

### 공통 상태와 행동

| 항목 | 값 |
|---|---:|
| 기본 체력 / 행동력 / 기력 / 내공 | 100 / 6 / 12 / 6 |
| 접근·후퇴 | 슬롯 1, 행동력 1, 기력 1, 1칸 이동 |
| 경공 이동 | 접근·후퇴에 내공 1을 추가해 2칸 이동 |
| 막기 | 슬롯 1, 행동력 1, 기력 1 |
| 회피 | 슬롯 1, 행동력 1, 기력 2, 1칸 이동 후 남은 피해 50% 경감 |
| 밀치기 | 슬롯 1, 행동력 2, 기력 2, 무기 사거리로 판정, 적 1칸 이동 |
| 무기 교체 | 슬롯 1, 행동력 1 |
| 재장전 | 슬롯 1, 행동력 1, 기력 1 |
| 라운드 종료 회복 | 기력 +2, 내공 +1 |
| 독 | 라운드 종료 시 중첩당 체력 -2 |
| 마화 | 사용할 때 체력 -5·중첩 +1, 라운드 종료 시 중첩당 체력 -3 |

### 무기

| 무기 | 사거리 | 공격: 피해 / 행동력 / 기력 | 막기 | 밀치기 | 재장전 |
|---|---|---|---:|---|---|
| 권법 | 0 | 10 / 1 / 1 | 40% | 0 | 없음 |
| 검 | 1 | 9 / 1 / 1 | 35% | 1 | 없음 |
| 도 | 1 | 11 / 1 / 2 | 30% | 1 | 없음 |
| 곤 | 2 | 9 / 1 / 2 | 40% | 2 | 없음 |
| 창 | 2 | 12 / 2 / 3 | 30% | 2 | 없음 |
| 암기 | 2~4 | 8 / 2 / 1 | 25% | 2~4 | 공격·밀치기 뒤 필요 |
| 활 | 3~5 | 14 / 2 / 1 | 20% | 3~5 | 공격·밀치기 뒤 필요 |
| 창·방패 | 2 | 9 / 2 / 2 | 50% | 2 | 없음 |

방패는 활 피해에 대한 막기 경감률을 추가 20%p 올리고, 회피 경감률을 50%에서 35%로 낮춘다. 끝 칸으로 밀리면 대상 기력 -2를 적용한다.

### 문파 1~5성 데이터

`G1`은 1성, `G5`는 대성이다. “+”는 기본 무기·행동 규칙에 더하는 수정값이다.

| 세력 | G1 | G2 | G3 | G4 | G5 |
|---|---|---|---|---|---|
| 화산 | 이동 뒤 검 공격 피해 +2 | 경공 내공 비용 -1, 경기당 2회 | 회피 뒤 검 공격 행동력 -1 | 검 공격 적중 시 1칸 추격 | 이동·공격을 같은 슬롯에 1회 결합 |
| 개방 | 밀치기 성공 뒤 막기 +15%p | 곤 밀치기 기력 -1 | 막기 성공 뒤 다음 곤 공격 +3 | 밀친 적이 벽이면 피해 +4 | 밀치기 후 1칸 회수 선택 |
| 당문 | 암기 적중 시 독 +1 | 재장전 행동력 -1 | 암기벨트 사용 +2회 | 독 대상 암기 피해 +3 | 경기당 1회 공격 후 장전 유지 |
| 소림 | 막기 40%→55% | 접근 기력 -1 | 거리 0 공격 피해 +3 | 막기 성공 뒤 다음 접근 2칸 | 막기와 권법 공격을 같은 슬롯에 1회 결합 |
| 무당 | 경공 이동의 내공 비용 -1 | 회피 뒤 내공 +1 | 막기 피해 경감의 절반을 기력 회복으로 변환 | 내공 2를 써 막기 +25%p | 경기당 1회 회피 이동 3칸 |
| 마교 | 마화 공격 피해 +6 | 마화 사용 체력 -3 | 마화 중 접근·후퇴 기력 -1 | 마화 2중첩 이상 시 막기 +15%p | 마화 종료 시 중첩 전부 제거, 체력 -8 |
| 양가장 | 창 거리 2 공격 피해 +2 | 창 밀치기 기력 -1 | 밀치기 뒤 1칸 후퇴 가능 | 거리 2 막기 +15%p | 창 공격 적중 후 거리 2로 1칸 회수 |
| 백우궁 | 활 공격 피해 +2 | 재장전 기력 -1 | 화살통 사용 +2회 | 거리 4~5 활 공격 피해 +3 | 경기당 1회 공격 후 장전 유지 |
| 관군 | 활 막기 +20%p, 회피 35% | 방패 막기 기력 -1 | 막기 성공 뒤 밀치기 행동력 -1 | 방패 장착 중 벽 밀치기 피해 +3 | 경기당 1회 막기와 전진 1칸 결합 |
| 아미 | 적중 시 적 기력 -1 | 회피 기력 -1 | 경기당 2회 의술: 내공 1로 체력 +6 | 기력 3 이하 적에게 피해 +3 | 경기당 1회 의술로 독 2중첩 제거 |
| 오독 | 근접 적중 시 독 +1 | 독 대상 공격 피해 +2 | 내공 1로 독장 사거리 1 | 독 3중첩 이상 적의 기력 -1 | 경기당 1회 독을 모두 폭발: 중첩당 피해 3 후 제거 |
| 녹림채 | 도 적중: 적 기력 -1, 자신 +1 | 기력 우위 시 도 피해 +2 | 밀치기 성공 뒤 도 공격 행동력 -1 | 적 기력 2 이하 시 막기 -15%p | 경기당 1회 적 기력 0이면 도 공격 피해 +6 |

## 대진·보상·AI 확정 데이터

| 경기 | 단계 | 상대 난이도 | 보상 선택 | 필수 상대 계열 |
|---:|---|---|---|---|
| 1 | 내부전 | 1성 | 회복 / 수련도 | 시작 문파 훈련 상대 |
| 2 | 내부전 | 1성 | 수련도 / 정탐 | 근접 또는 동거리 |
| 3 | 추천패 | 2성 | 외문 무공서 / 보조장비 / 회복 | 시작 문파와 다른 무기 |
| 4 | 지역 예선 | 2성 | 무공서 / 수련도 / 정탐 | 장거리 또는 거리 2 |
| 5 | 지역 예선 | 2성 | 무공서 / 장비 / 회복 | 아직 만나지 않은 계열 |
| 6 | 본선 | 3성 | 무공서 / 수련도 / 정탐 | 보유 빌드의 약상성 |
| 7 | 본선 | 3성 | 수련도 / 장비 / 회복 | 보유 빌드의 강상성 |
| 8 | 준결승 | 4성 | 대성 수련도 / 외문 무공서 | 혼합 빌드 |
| 9 | 결승 | 5성 | 결과 화면 | 거리·자원 종합형 |

AI 성향은 `aggressive`, `keep_range`, `guard_counter`, `resource_drain` 네 개만 사용한다. 각 세력은 대표 거리와 성향을 하나 갖고, 모든 AI는 예측 깊이 2슬롯·후보 8개로 행동열을 생성한다. 난이도는 점수 보정이 아니라 수련 성급·장비·정탐 정보 차이로만 높인다.

---

### Task 1: Godot 프로젝트와 headless 테스트 기반 만들기

**파일:**

- Create: `project.godot`
- Create: `scripts/core/action_types.gd`
- Create: `tests/test_case.gd`
- Create: `tests/test_runner.gd`
- Create: `tests/test_action_types.gd`
- Create: `.gitignore`

**인터페이스:**

- `ActionTypes.Type`은 `APPROACH`, `RETREAT`, `ATTACK`, `GUARD`, `EVADE`, `PUSH`, `SWAP`, `RELOAD`, `WAIT`를 가진다.
- `TestCase.assert_equal(actual, expected, message)`과 `TestCase.assert_true(condition, message)`는 실패 수를 반환한다.
- `tests/test_runner.gd`는 `--headless --script`로 종료 코드 0/1을 반환한다.

- [ ] `tests/test_action_types.gd`에 다음 실패 테스트를 작성한다.

```gdscript
func run(case: TestCase) -> void:
    case.assert_equal(ActionTypes.Type.ATTACK, 2, "attack enum must stay stable")
    case.assert_equal(ActionTypes.Type.RELOAD, 7, "reload enum must stay stable")
```

- [ ] `godot --headless --path . --script tests/test_runner.gd`를 실행해 `ActionTypes` 누락 실패를 확인한다.
- [ ] `scripts/core/action_types.gd`에 아래 열거형을 구현한다.

```gdscript
class_name ActionTypes
extends RefCounted

enum Type { APPROACH, RETREAT, ATTACK, GUARD, EVADE, PUSH, SWAP, RELOAD, WAIT }
```

- [ ] 테스트 러너가 `tests/`의 `test_*.gd`를 실행하고 실패 수가 0이면 `quit(0)`하는 최소 구현을 작성한다.
- [ ] headless 테스트가 `PASS 2 assertions`로 끝나는지 확인한다.
- [ ] 커밋: `chore: bootstrap Godot project and test runner`

### Task 2: 전투 데이터 Resource와 확정 수치 카탈로그 만들기

**파일:**

- Create: `scripts/data/weapon_data.gd`
- Create: `scripts/data/faction_data.gd`
- Create: `scripts/data/martial_art_data.gd`
- Create: `scripts/data/accessory_data.gd`
- Create: `scripts/data/combat_catalog.gd`
- Create: `tests/test_combat_catalog.gd`
- Modify: `docs/06_STARTING_FACTION_MASTERY_DATA.md`

**인터페이스:**

```gdscript
static func weapon(id: StringName) -> WeaponData
static func faction(id: StringName) -> FactionData
static func martial_art(faction_id: StringName, grade: int) -> MartialArtData
static func all_faction_ids() -> Array[StringName]
```

- [ ] 다음 실패 테스트를 작성한다.

```gdscript
func run(case: TestCase) -> void:
    case.assert_equal(CombatCatalog.all_faction_ids().size(), 12, "all factions are playable data")
    case.assert_equal(CombatCatalog.weapon(&"bow").max_range, 5, "bow maximum range")
    case.assert_equal(CombatCatalog.martial_art(&"shaolin", 1).guard_bonus, 0.15, "shaolin guard")
    case.assert_equal(CombatCatalog.martial_art(&"green_forest", 1).drain_stamina, 1, "bandit drain")
```

- [ ] 카탈로그에 위 ‘확정 전투 수치’ 표의 8무기와 12세력·각 5성 효과를 그대로 입력한다.
- [ ] `AccessoryData`에 `hidden_belt`(기본 3회, 당문 G3에서 5회)와 `quiver`(기본 2회, 백우궁 G3에서 4회)를 넣는다.
- [ ] `docs/06_STARTING_FACTION_MASTERY_DATA.md`를 이 Plan의 수치 표와 일치하도록 갱신한다.
- [ ] 테스트를 통과한다.
- [ ] 커밋: `feat: add combat data for twelve factions`

### Task 3: 순수 전투 상태와 한 슬롯 해상기 만들기

**파일:**

- Create: `scripts/combat/combat_state.gd`
- Create: `scripts/combat/action_order.gd`
- Create: `scripts/combat/combat_event.gd`
- Create: `scripts/combat/combat_resolver.gd`
- Create: `tests/test_combat_resolver.gd`

**인터페이스:**

```gdscript
static func initial(left: FighterState, right: FighterState) -> CombatState
func resolve_slot(state: CombatState, left: ActionOrder, right: ActionOrder) -> Dictionary
# 반환값: { "state": CombatState, "events": Array[CombatEvent] }
```

- [ ] 다음 실패 테스트를 작성한다.

```gdscript
func test_movement_is_simultaneous(case: TestCase) -> void:
    var state := TestFactory.state_at(4, 6)
    var result := CombatResolver.resolve_slot(state, TestFactory.order_approach(), TestFactory.order_approach())
    case.assert_equal(result.state.left.position, 5, "left advances")
    case.assert_equal(result.state.right.position, 5, "right advances into same cell")

func test_attack_checks_distance_after_movement(case: TestCase) -> void:
    var state := TestFactory.state_at(4, 6, &"fist", &"hidden")
    var result := CombatResolver.resolve_slot(state, TestFactory.order_approach_attack(), TestFactory.order_wait())
    case.assert_true(result.events.any(func(e): return e.kind == &"hit"), "fist hits after entering range zero")
```

- [ ] 자원 부족은 `invalid_action` 이벤트와 대기 처리, 이동은 동시 처리, 공격·밀치기는 이동 후 거리 판정으로 구현한다.
- [ ] 일반 막기, 회피, 벽 밀치기 기력 -2, 장전 필요 상태, 무기 교체를 구현한다.
- [ ] 테스트에 동일 칸 중첩·교차·재장전 불가·방패 활 경감·회피 경감도 추가한다.
- [ ] 모든 전투 테스트를 통과한다.
- [ ] 커밋: `feat: resolve shared combat actions`

### Task 4: 유파·대성 수정자와 상태 효과를 해상기에 연결하기

**파일:**

- Create: `scripts/combat/modifier_engine.gd`
- Modify: `scripts/combat/combat_resolver.gd`
- Modify: `scripts/combat/combat_state.gd`
- Create: `tests/test_modifiers.gd`

**인터페이스:**

```gdscript
static func modify(context: Dictionary, martial_arts: Array[MartialArtData]) -> Dictionary
static func end_round(state: CombatState) -> Dictionary
```

- [ ] 다음 실패 테스트를 작성한다.

```gdscript
func run(case: TestCase) -> void:
    case.assert_equal(TestFactory.shaolin_guard_damage(20), 9, "55 percent guard leaves 45 percent")
    case.assert_equal(TestFactory.poison_after_round(100, 2), 96, "two poison stacks deal four")
    case.assert_equal(TestFactory.green_forest_stamina_after_hit(8, 4), [9, 3], "bandit drains one stamina")
```

- [ ] 독·마화·장전·방패·화살통·암기벨트 상태를 공통 상태로 구현한다.
- [ ] 12세력 G1~G5의 수정자를 `modifier_engine.gd`가 데이터로 읽어 적용하게 한다.
- [ ] 문파 이름으로 `if faction ==` 분기하지 않고, 수정자 키와 수치만으로 처리한다.
- [ ] 경기당 1회 효과는 `uses_remaining` 상태로 관리한다.
- [ ] 테스트를 통과한다.
- [ ] 커밋: `feat: apply faction mastery modifiers`

### Task 5: 공정한 AI 행동열과 9전 대진·보상·저장 구현하기

**파일:**

- Create: `scripts/tournament/ai_planner.gd`
- Create: `scripts/tournament/tournament_run.gd`
- Create: `scripts/tournament/reward_generator.gd`
- Create: `scripts/tournament/run_save.gd`
- Create: `tests/test_ai_planner.gd`
- Create: `tests/test_tournament_run.gd`

**인터페이스:**

```gdscript
func plan(public_state: CombatState, profile: OpponentProfile, seed: int) -> Array[ActionOrder]
func begin_run(start_faction: StringName, seed: int) -> TournamentRun
func resolve_match(result: MatchResult, reward_index: int) -> void
func save_to(path: String) -> Error
static func load_from(path: String) -> TournamentRun
```

- [ ] 다음 실패 테스트를 작성한다.

```gdscript
func run(case: TestCase) -> void:
    var run := TournamentRun.begin_run(&"shaolin", 44)
    case.assert_equal(run.current_match, 1, "run starts at internal match one")
    for match_index in range(1, 10):
        case.assert_true(run.next_opponent().faction_id != run.start_faction or match_index <= 2, "no early self-faction repeat")
        run.debug_win_current_match(0)
    case.assert_true(run.is_complete(), "nine matches reach final")

func test_ai_queue_is_deterministic_from_public_seed(case: TestCase) -> void:
    var first := AiPlanner.new().plan(TestFactory.public_state(), TestFactory.archer_profile(), 9)
    var second := AiPlanner.new().plan(TestFactory.public_state(), TestFactory.archer_profile(), 9)
    case.assert_equal(first, second, "AI locks one queue from public input")
```

- [ ] 9경기 표의 단계·난이도·보상 풀과 12세력 상대 풀·중복 방지 규칙을 구현한다.
- [ ] AI 후보 8개, 2슬롯 평가, 네 성향의 점수 함수를 구현한다. 숨은 플레이어 행동열은 함수 입력에 넣지 않는다.
- [ ] 패배 시 최초 무료·이후 명망 소모·회차당 1회·재기 전리품과 수련도를 구현한다.
- [ ] `user://run_save.json`에 버전 포함 저장·불러오기와 손상 파일 시 새 회차 복귀를 구현한다.
- [ ] 테스트를 통과한다.
- [ ] 커밋: `feat: add tournament run fair AI and persistence`

### Task 6: 2D 대회·전투 UI와 이벤트 재생 만들기

**파일:**

- Create: `scenes/main_menu.tscn`, `scenes/faction_select.tscn`, `scenes/tournament_screen.tscn`, `scenes/battle_screen.tscn`, `scenes/result_screen.tscn`
- Create: `scripts/ui/main_menu.gd`, `scripts/ui/faction_select.gd`, `scripts/ui/tournament_screen.gd`, `scripts/ui/battle_screen.gd`, `scripts/ui/result_screen.gd`, `scripts/ui/battle_event_player.gd`
- Create: `assets/placeholder/README.md`
- Modify: `project.godot`

**인터페이스:**

```gdscript
func bind_run(run: TournamentRun) -> void
func submit_orders(orders: Array[ActionOrder]) -> void
func play_events(events: Array[CombatEvent]) -> void
signal battle_finished(result: MatchResult)
```

- [ ] `BattleScreen`에서 10개의 클릭 불가 보드 칸, A/B 스프라이트 자리, 거리 표시, 체력·행동력·기력·내공, 상태 아이콘, 6슬롯 행동 배치를 먼저 배치한다.
- [ ] 행동 버튼은 비용·사거리·장전·장비 횟수를 미리 검증하고, 불가능한 이유를 툴팁으로 보여 준다.
- [ ] 양측 잠금 뒤 슬롯을 동시 공개하고 `CombatEvent` 순서대로 이동·피격·밀치기·상태 변화를 0.25초 간격으로 재생한다.
- [ ] 결과 로그에 `공용 행동 → 무기 → 유파·대성 → 결과`를 한 줄씩 표시한다.
- [ ] 대진 화면에서 9전 단계, 다음 상대 공개 정보, 보상, 대성 진행, 재도전 횟수를 표시한다.
- [ ] 플레이 가능한 최소 흐름: 새 회차 → 문파 선택 → 전투 → 보상 → 다음 경기 → 결과 화면을 수동 점검한다.
- [ ] 커밋: `feat: add playable 2D tournament interface`

### Task 7: 전체 검증·Windows export·문서 동기화

**파일:**

- Create: `export_presets.cfg`
- Create: `tests/test_full_run.gd`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Modify: `README.md`

- [ ] 다음 통합 테스트를 작성한다.

```gdscript
func run(case: TestCase) -> void:
    for faction_id in CombatCatalog.start_faction_ids():
        var run := TournamentRun.begin_run(faction_id, faction_id.hash())
        while not run.is_complete() and not run.is_lost():
            run.debug_resolve_current_match_with_ai()
        case.assert_true(run.reached_stage(&"main"), "%s reaches main bracket" % faction_id)
```

- [ ] 12세력 각각에 대해 대표 G1 효과와 G5 효과가 최소 한 번 검증되도록 매트릭스 테스트를 추가한다.
- [ ] `godot --headless --path . --script tests/test_runner.gd`가 성공하는지 확인한다.
- [ ] Godot 에디터에서 Windows export preset을 만들고 `build/windows/TenPacesHiddenMoves.exe`로 내보낸다.
- [ ] 실행 파일로 새 회차·전투·보상·저장·불러오기를 수동 확인한다.
- [ ] 테스트 체크리스트와 README에 실제 실행 명령과 검증 결과를 기록한다.
- [ ] 커밋: `build: verify Windows vertical slice export`

## Plan 자체 검토

- 12세력, 9전, 공정 AI, 재도전, 데이터 기반 수정자, 2D UI, Windows export가 각각 작업 2~7에 배정됐다.
- 모든 기능 작업은 실패 테스트 → 최소 구현 → 통과 테스트 → 커밋 순서다.
- 문파 전용 엔진 분기를 허용하는 항목, 미확정 수치, 별도 경제·대화·Steamworks 작업은 포함하지 않았다.
