# PoC Runtime Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 승인된 planning 계약을 현행 Godot 전투 엔진이 소비할 수 있는 런타임 데이터와 상태·판정·AI 계약으로 구현한다.

**Architecture:** planning JSON을 직접 소비하지 않고 `PocRuntimeAdapter`가 검증된 runtime Dictionary로 변환한다. `RunStateStore`는 회차 진행을, `CombatResolutionEngine`은 단일 전투 판정을 소유한다. 판정 결과는 불변 event stream으로 UI와 오디오에 전달한다.

**Tech Stack:** Godot 4.x, GDScript, JSON, Python planning validator, Godot headless verification scripts.

## Global Constraints

- 현행 10칸·4/7·3/3/4와 공개 정보 AI 입력 경계를 보존한다.
- 시작 수치: 체력30, 공격력4, 방어도5, 기력5, 내력5, 기세0/5.
- 속공 원피해4, 강공 원피해10·2슬롯·기력1·내력1, 명상 기력+1·내력+1.
- `[강화]`: 다음 공격 원피해 `floor(raw * 1.5)`, 첫 전조에서 소비, 환불 없음.
- `[강건]`: 실제 중단 1회 방지, 피해·KO 방지 아님.
- 순차 연격은 앞 타격부터 쌍을 만들고 차이 원피해를 적용한다.
- 실제 체력 피해가 발생하면 패자 미실행 후속타를 중단한다. 강건은 한 번만 방지한다.
- `[필중]`은 실제 회피 우회 타격마다 1스택 소비한다.
- 기존 `restart_combat()`은 개발용 완전 초기화로 유지한다.

---

### Task 1: Planning-to-runtime adapter

**Files:**
- Create: `src/runtime/poc_runtime_adapter.gd`
- Create: `data/runtime/poc_runtime_manifest.json`
- Create: `tests/verify_p0_runtime_adapter.gd`
- Modify: `project.godot` only if an autoload is required; prefer explicit dependency injection.

**Interfaces:**
- Consumes: `docs/planning-data/poc_balance_budget.json`, `poc_martial_arts.json`, `poc_enemy_duels.json`, `poc_map_rewards.json`, `poc_run_state_contract.json`.
- Produces: `PocRuntimeAdapter.load_manifest(root_path: String) -> Dictionary`, `build_runtime_catalog() -> Dictionary`.

- [ ] **Step 1: Write the failing adapter test**

```gdscript
extends SceneTree

const Adapter = preload("res://src/runtime/poc_runtime_adapter.gd")

func _init() -> void:
    var adapter := Adapter.new()
    var catalog: Dictionary = adapter.build_runtime_catalog()
    assert(catalog.schema_version == 1)
    assert(catalog.cards.has("basic_quick_attack"))
    assert(catalog.duels.size() == 5)
    assert(catalog.run_contract.retry_costs == [1, 2, 3])
    print("P0_RUNTIME_ADAPTER_PASS")
    quit(0)
```

- [ ] **Step 2: Run the test to verify RED**

```bash
godot --headless --path . --script res://tests/verify_p0_runtime_adapter.gd
```

Expected: preload or class-not-found failure for `poc_runtime_adapter.gd`.

- [ ] **Step 3: Implement strict loading**

```gdscript
class_name PocRuntimeAdapter
extends RefCounted

const PLANNING_ROOT := "res://docs/planning-data"

func build_runtime_catalog() -> Dictionary:
    var martial := _read_json(PLANNING_ROOT + "/poc_martial_arts.json")
    var duels := _read_json(PLANNING_ROOT + "/poc_enemy_duels.json")
    var map_rewards := _read_json(PLANNING_ROOT + "/poc_map_rewards.json")
    var run_contract := _read_json(PLANNING_ROOT + "/poc_run_state_contract.json")
    return {
        "schema_version": 1,
        "cards": _build_cards(martial),
        "manuals": _build_manuals(martial),
        "duels": _build_poc_duels(duels),
        "map": _build_map(map_rewards),
        "run_contract": _build_run_contract(run_contract),
    }
```

Reject unknown IDs, missing required fields, duplicate runtime IDs, non-PoC duels, and unsupported trigger/scope values with `push_error()` plus an empty catalog.

- [ ] **Step 4: Run adapter and planning tests**

```bash
godot --headless --path . --script res://tests/verify_p0_runtime_adapter.gd
python -m unittest tests.test_poc_planning_data -v
```

Expected: adapter PASS token and planning 24/24 PASS.

- [ ] **Step 5: Commit**

```bash
git add src/runtime/poc_runtime_adapter.gd data/runtime/poc_runtime_manifest.json tests/verify_p0_runtime_adapter.gd
git commit -m "feat: add validated PoC runtime adapter"
```

### Task 2: RunState and combat snapshot boundary

**Files:**
- Create: `src/run/run_state_store.gd`
- Create: `src/run/run_retry_service.gd`
- Create: `tests/verify_p0_run_retry.gd`
- Modify: `src/combat/combat_board_preview.gd` at combat entry/exit and defeat handling.

**Interfaces:**
- Produces: `RunStateStore.start_run(seed: int, selected_manual_ids: Array[String])`, `create_pre_battle_snapshot(battle_id: String)`, `commit_victory(result: Dictionary)`, `restore_for_retry() -> Dictionary`.
- Produces: `RunRetryService.next_cost(retry_count: int) -> int`, `pay_and_restore(run_state: Dictionary) -> Dictionary`.

- [ ] **Step 1: Write failing retry tests**

Test first retry cost 1, second 2, third and later 3; another battle resets to 1; combat damage rolls back; permanent currency payment does not roll back; same battle seed remains unchanged.

```gdscript
assert(service.next_cost(0) == 1)
assert(service.next_cost(1) == 2)
assert(service.next_cost(2) == 3)
assert(service.next_cost(8) == 3)
```

- [ ] **Step 2: Run to verify RED**

```bash
godot --headless --path . --script res://tests/verify_p0_run_retry.gd
```

- [ ] **Step 3: Implement state ownership**

`RunStateStore` owns run seed, node position, persistent health, manuals/mastery, medical, currency, permanent currency, visited nodes, reward ledger, current battle ID, retry count, and pre-battle snapshot. `CombatState` owns only round/bundle, positions, combat resources, statuses, events, and battle outcome.

- [ ] **Step 4: Integrate without changing `restart_combat()`**

Add a separate `request_paid_retry()` path in `combat_board_preview.gd`. Never call `restart_combat()` from the paid retry service.

- [ ] **Step 5: Run retry and legacy restart tests**

```bash
godot --headless --path . --script res://tests/verify_p0_run_retry.gd
godot --headless --path . --script res://tests/verify_step12_13_restart_ai.gd
```

- [ ] **Step 6: Commit**

```bash
git add src/run src/combat/combat_board_preview.gd tests/verify_p0_run_retry.gd
git commit -m "feat: separate run state and paid retries"
```

### Task 3: New base numbers and status model

**Files:**
- Modify: `src/combat/combat_resolution_engine.gd`
- Modify: `data/cards/basic_cards.json`
- Modify: `data/combat/combat_hud_preview.json`
- Create: `tests/verify_p0_base_numbers.gd`

**Interfaces:**
- `make_initial_state(player_tile: int, enemy_tile: int, persistent_health: int = 30) -> Dictionary`.
- Actor status fields: `guard`, `evade_charges`, `sure_hit_stacks`, `empowered_pending`, `fortitude_interrupt_charges`.

- [ ] Write failing assertions for HP30/AP4/guard5/stamina5/internal5/momentum0, quick4, heavy10, meditate +1/+1.
- [ ] Run and confirm RED against legacy values.
- [ ] Replace legacy `[준비]+2` with `empowered_pending` and `floor(raw * 1.5)`.
- [ ] Replace legacy fortitude damage behavior with one interruption-prevention charge.
- [ ] Run new and legacy-compatible tests; update only tests that encode superseded values.
- [ ] Commit as `feat: align combat base values and statuses`.

### Task 4: Sequential multi-hit clash resolver

**Files:**
- Modify: `src/combat/combat_resolution_engine.gd`
- Create: `src/combat/sequential_hit_resolver.gd`
- Create: `tests/verify_p0_sequential_clash.gd`

**Interfaces:**
- Produces: `SequentialHitResolver.resolve_pair(left_hit: Dictionary, right_hit: Dictionary, state: Dictionary) -> Dictionary`.
- Result fields: `raw_difference`, `guard_absorbed`, `health_damage`, `effects`, `interruption`, `remaining_hits`, `events`.

- [ ] **Step 1: Write failing cases**

Cover equal raw cancellation, 8 vs 5 difference 3, guard absorption before HP, actual HP damage interruption, fortitude preserving follow-ups once, unmatched winner hits, simultaneous death after pair effects, and action-level momentum cap +1.

- [ ] **Step 2: Run RED**

```bash
godot --headless --path . --script res://tests/verify_p0_sequential_clash.gd
```

- [ ] **Step 3: Implement the pair pipeline**

```text
raw clash
→ loser cancellation or tie cancellation
→ evade
→ guard
→ HP
→ hit effects
→ interruption/fortitude
→ KO
```

Resolve all matched pairs in order, then execute unmatched surviving hits. Never apply interruption before the current hit's effects.

- [ ] **Step 4: Run GREEN and existing combat contract tests**

Run `verify_p0_sequential_clash.gd` plus existing combat, ultimate, interrupt, and prepare verifiers.

- [ ] **Step 5: Commit**

```bash
git add src/combat/sequential_hit_resolver.gd src/combat/combat_resolution_engine.gd tests/verify_p0_sequential_clash.gd
git commit -m "feat: resolve sequential multi-hit clashes"
```

### Task 5: Effect triggers and stacked sure-hit

**Files:**
- Create: `src/combat/combat_effect_dispatcher.gd`
- Modify: `src/combat/combat_resolution_engine.gd`
- Create: `tests/verify_p0_effect_triggers.gd`
- Create: `tests/verify_p0_sure_hit_stacks.gd`

**Interfaces:**
- `dispatch(trigger: StringName, action: Dictionary, hit: Dictionary, context: Dictionary) -> Array[Dictionary]`.
- Supported triggers: `ON_ACTION_START`, `ON_ACTION_RESOLVE`, `ON_CLASH_WIN`, `ON_EVADE_SUCCESS`, `ON_HIT`, `ON_HEALTH_DAMAGE`, `ON_ACTION_END`.

- [ ] Test `PER_HIT` vs `ONCE_PER_ACTION`, no `ON_ACTION_END` after interruption, `ON_HIT` at zero HP damage, no `ON_HEALTH_DAMAGE` at zero HP damage.
- [ ] Test sure-hit consumption only when an available evade would have prevented the hit.
- [ ] Verify no stack consumption on clash cancellation, interruption, no target, range failure, or no evade charge.
- [ ] Implement dispatcher and per-action consumption ledger.
- [ ] Run both new tests and existing ultimate/evade tests.
- [ ] Commit as `feat: add effect dispatcher and sure-hit stacks`.

### Task 6: AI three-action bundle templates

**Files:**
- Modify: `src/combat/combat_ai_planner.gd`
- Modify: `data/combat/combat_rival_tendency_poc.json`
- Create: `tests/verify_p0_ai_bundle_templates.gd`

**Interfaces:**
- Preserve: `build_bundle_actions(state: Dictionary, bundle_index: int, cards_by_id: Dictionary) -> Array`.
- Return up to three scheduled actions with stable `timing`, `card_id`, target fields, `ai_seed`, `ai_reason`, and `candidate_id`.

- [ ] Write RED tests for maximum three rational candidates, deterministic same snapshot+seed, no player uncommitted inputs, valid multi-action template, and fallback.
- [ ] Implement public snapshot whitelist and structured score modifiers from runtime duel data.
- [ ] Select one candidate template by deterministic seed; return all scheduled actions in that template.
- [ ] Run `verify_p0_ai_bundle_templates.gd` and `verify_ai_rival_tendency.gd`.
- [ ] Commit as `feat: execute deterministic AI bundle templates`.

### Task 7: Stable presentation event contract

**Files:**
- Create: `src/combat/combat_event_ids.gd`
- Modify: `src/combat/combat_resolution_engine.gd`
- Modify: `src/combat/combat_review_summary_builder.gd`
- Create: `tests/verify_p0_event_stream.gd`

**Interfaces:**
- Event fields: `event_id`, `sequence`, `round`, `bundle`, `timing`, `actor`, `target`, `action_id`, `hit_index`, `payload`, `state_snapshot`.

- [ ] Test strict sequence ordering and event IDs for clash, guard, HP damage, effect, interruption, fortitude, sure-hit consumption, reward boundary, and retry payment.
- [ ] Emit events from domain code only; UI must not calculate damage or reward.
- [ ] Update review summary builder to consume event IDs rather than parse display strings.
- [ ] Run event, review summary, and A2/A3 regression tests.
- [ ] Commit as `feat: publish stable combat presentation events`.

### Task 8: Runtime foundation verification gate

**Files:**
- Modify: `.github/workflows/full-validation.yml`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Create: `docs/decisions/<date>_P0_RUNTIME_FOUNDATION_EVIDENCE.md`

- [ ] Run planning validator and 24 tests.
- [ ] Run every new Godot verifier from Tasks 1–7.
- [ ] Run existing combat, AI, restart, ultimate, prepare, A2, and A3 verifiers.
- [ ] Run `godot --headless --path . --quit` and reject parser warnings promoted to errors.
- [ ] Record exact commands, commit SHA, Godot version, OS, PASS/FAIL/NOT_RUN.
- [ ] Return to REVIEW before campaign integration.
