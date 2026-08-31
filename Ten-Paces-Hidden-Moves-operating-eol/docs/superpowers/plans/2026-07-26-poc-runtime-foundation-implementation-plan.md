# PoC Runtime Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 승인된 planning 계약을 현행 Godot 전투 엔진이 소비할 수 있는 런타임 데이터·상태·판정·AI 계약으로 구현한다.

**Architecture:** Python build-time compiler가 `docs/planning-data`를 검증하고 canonical `data/runtime/poc_runtime_catalog.json`을 생성한다. Godot은 planning 문서를 직접 읽지 않고 `PocRuntimeCatalog` strict loader를 통해 생성물만 소비한다. `RunStateStore`는 회차 진행을, `CombatResolutionEngine`은 단일 전투 판정을 소유하며, 확정 결과는 안정 event stream으로 표현 계층에 전달한다.

**Tech Stack:** Godot 4.x, GDScript, Python 3, JSON, unittest, Godot headless verification scripts.

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
- runtime 생성물은 build-time compiler 외의 손수 편집을 금지한다.

---

### Task 1: Build-time runtime catalog compiler

**Files:**
- Create: `tools/build_poc_runtime_catalog.py`
- Create: `tests/test_poc_runtime_catalog_builder.py`
- Create: `data/runtime/poc_runtime_catalog.json`
- Create: `src/runtime/poc_runtime_catalog.gd`
- Create: `tests/verify_p0_runtime_adapter.gd`
- Modify: `.github/workflows/documentation-governance.yml`

**Interfaces:**
- Python: `build_catalog(root: Path) -> dict`, `write_catalog(root: Path) -> Path`.
- Godot: `PocRuntimeCatalog.load_catalog(path := "res://data/runtime/poc_runtime_catalog.json") -> Dictionary`.
- Source inputs: planning JSON 6종.
- Runtime output: cards, manuals, first-five duels, map constraints, rewards, grades, run contract.

- [ ] **Step 1: Write Python RED tests**

Test deterministic output, five-duel filtering, duplicate ID rejection, unknown trigger rejection, retry costs `[1,2,3]`, and output drift detection.

```bash
python -m unittest tests.test_poc_runtime_catalog_builder -v
```

Expected: import failure because compiler does not exist.

- [ ] **Step 2: Implement minimal compiler**

```python
def build_catalog(root: Path) -> dict:
    planning = load_and_validate_planning(root)
    return {
        "schema_version": 1,
        "source_contract": "NON_RUNTIME_POC_PLANNING",
        "cards": build_cards(planning),
        "manuals": build_manuals(planning),
        "duels": build_first_five_duels(planning),
        "map": build_map_contract(planning),
        "rewards": build_rewards(planning),
        "grades": build_grade_contract(planning),
        "run_contract": build_run_contract(planning),
    }
```

Write canonical UTF-8 JSON with sorted keys disabled only where array order is semantic, two-space indentation, and trailing newline.

- [ ] **Step 3: Verify generator GREEN and drift check**

```bash
python tools/build_poc_runtime_catalog.py --root . --write
python -m unittest tests.test_poc_runtime_catalog_builder -v
python tools/build_poc_runtime_catalog.py --root . --check
```

Expected: tests PASS and `--check` reports no generated-file drift.

- [ ] **Step 4: Write Godot loader RED test**

```gdscript
extends SceneTree

const Catalog = preload("res://src/runtime/poc_runtime_catalog.gd")

func _init() -> void:
    var catalog: Dictionary = Catalog.new().load_catalog()
    assert(catalog.get("schema_version") == 1)
    assert(catalog.get("duels", []).size() == 5)
    assert(catalog.get("run_contract", {}).get("retry_costs") == [1, 2, 3])
    print("P0_RUNTIME_ADAPTER_PASS")
    quit(0)
```

```bash
godot --headless --path . --script res://tests/verify_p0_runtime_adapter.gd
```

Expected: preload failure.

- [ ] **Step 5: Implement strict Godot loader**

Loader validates schema version, root types, required sections, runtime ID uniqueness, and first-five duel boundary. It returns `{}` and emits an explicit error on invalid input. It never opens `res://docs/planning-data`.

- [ ] **Step 6: Add CI checks and commit**

```bash
python tools/build_poc_runtime_catalog.py --root . --check
python -m unittest tests.test_poc_runtime_catalog_builder -v
godot --headless --path . --script res://tests/verify_p0_runtime_adapter.gd
git add tools/build_poc_runtime_catalog.py tests/test_poc_runtime_catalog_builder.py data/runtime/poc_runtime_catalog.json src/runtime/poc_runtime_catalog.gd tests/verify_p0_runtime_adapter.gd .github/workflows/documentation-governance.yml
git commit -m "feat: compile validated PoC runtime catalog"
```

### Task 2: RunState and combat snapshot boundary

**Files:**
- Create: `src/run/run_state_store.gd`
- Create: `src/run/run_retry_service.gd`
- Create: `tests/verify_p0_run_retry.gd`
- Modify: `src/combat/combat_board_preview.gd`

**Interfaces:**
- `start_run(seed: int, selected_manual_ids: Array[String]) -> Dictionary`.
- `create_pre_battle_snapshot(battle_id: String) -> Dictionary`.
- `commit_victory(result: Dictionary) -> Dictionary`.
- `restore_for_retry() -> Dictionary`.
- `next_cost(retry_count: int) -> int`.
- `pay_and_restore(run_state: Dictionary) -> Dictionary`.

- [ ] Write RED cases for costs 1/2/3 cap, different-battle reset, damage rollback, permanent-currency non-rollback, same battle seed, insufficient balance, and reward non-commit on defeat.
- [ ] Run `godot --headless --path . --script res://tests/verify_p0_run_retry.gd` and confirm RED.
- [ ] Implement state ownership: RunState owns route, persistent HP, mastery, medical, currencies, reward ledger, battle ID, retry count, snapshot; CombatState owns only battle-local state.
- [ ] Add separate `request_paid_retry()` path. Never call `restart_combat()` from paid retry.
- [ ] Run new retry and existing restart tests.
- [ ] Commit as `feat: separate run state and paid retries`.

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
- [ ] Replace legacy fortitude behavior with one interruption-prevention charge.
- [ ] Run new tests and update only regressions that encode explicitly superseded values.
- [ ] Commit as `feat: align combat base values and statuses`.

### Task 4: Sequential multi-hit clash resolver

**Files:**
- Create: `src/combat/sequential_hit_resolver.gd`
- Modify: `src/combat/combat_resolution_engine.gd`
- Create: `tests/verify_p0_sequential_clash.gd`

**Interfaces:**
- `resolve_pair(left_hit: Dictionary, right_hit: Dictionary, state: Dictionary) -> Dictionary`.
- Result: raw difference, guard absorbed, HP damage, effects, interruption, remaining hits, events.

- [ ] RED cases: tie cancellation, 8 vs 5 difference3, guard before HP, HP interruption, one-use fortitude, unmatched hits, simultaneous death after effects, action momentum cap +1.
- [ ] Implement pair pipeline: clash → evade → guard → HP → effects → interruption/fortitude → KO.
- [ ] Resolve matched pairs in order, then unmatched surviving hits. Never interrupt before current-hit effects.
- [ ] Run new test plus existing combat, ultimate, interrupt, and prepare verifiers.
- [ ] Commit as `feat: resolve sequential multi-hit clashes`.

### Task 5: Effect triggers and stacked sure-hit

**Files:**
- Create: `src/combat/combat_effect_dispatcher.gd`
- Modify: `src/combat/combat_resolution_engine.gd`
- Create: `tests/verify_p0_effect_triggers.gd`
- Create: `tests/verify_p0_sure_hit_stacks.gd`

**Interfaces:**
- `dispatch(trigger: StringName, action: Dictionary, hit: Dictionary, context: Dictionary) -> Array[Dictionary]`.
- Triggers: `ON_ACTION_START`, `ON_ACTION_RESOLVE`, `ON_CLASH_WIN`, `ON_EVADE_SUCCESS`, `ON_HIT`, `ON_HEALTH_DAMAGE`, `ON_ACTION_END`.

- [ ] Test `PER_HIT` and `ONCE_PER_ACTION` consumption.
- [ ] Test no `ON_ACTION_END` after interruption; `ON_HIT` at zero HP damage; no `ON_HEALTH_DAMAGE` at zero HP damage.
- [ ] Test sure-hit consumption only when an available evade is actually bypassed.
- [ ] Test no consumption on clash cancellation, interruption, missing target, range failure, or absent evade.
- [ ] Implement dispatcher and per-action consumption ledger.
- [ ] Run new and existing ultimate/evade tests.
- [ ] Commit as `feat: add effect dispatcher and sure-hit stacks`.

### Task 6: AI three-action bundle templates

**Files:**
- Modify: `src/combat/combat_ai_planner.gd`
- Modify: `data/combat/combat_rival_tendency_poc.json`
- Create: `tests/verify_p0_ai_bundle_templates.gd`

**Interfaces:**
- Preserve `build_bundle_actions(state, bundle_index, cards_by_id) -> Array`.
- Return the scheduled actions of one selected template with stable timing, target, seed, reason, and candidate ID.

- [ ] RED cases: maximum three rational candidates, deterministic same snapshot+seed, no uncommitted player inputs, valid multi-action template, valid fallback.
- [ ] Implement public snapshot whitelist and structured score modifiers from runtime duel data.
- [ ] Select one candidate template deterministically and return every scheduled action in that template.
- [ ] Run new AI test and `verify_ai_rival_tendency.gd`.
- [ ] Commit as `feat: execute deterministic AI bundle templates`.

### Task 7: Stable presentation event contract

**Files:**
- Create: `src/combat/combat_event_ids.gd`
- Modify: `src/combat/combat_resolution_engine.gd`
- Modify: `src/combat/combat_review_summary_builder.gd`
- Create: `tests/verify_p0_event_stream.gd`

**Interfaces:**
- Event fields: `event_id`, `sequence`, `round`, `bundle`, `timing`, `actor`, `target`, `action_id`, `hit_index`, `payload`, `state_snapshot`.

- [ ] Test strict sequence and IDs for clash, guard, HP damage, effect, interruption, fortitude, sure-hit consumption, reward boundary, and retry payment.
- [ ] Emit events only from domain code; UI does not calculate damage or reward.
- [ ] Update review summary builder to consume IDs rather than parse display strings.
- [ ] Run event, summary, A2, and A3 regressions.
- [ ] Commit as `feat: publish stable combat presentation events`.

### Task 8: Runtime foundation verification gate

**Files:**
- Modify: `.github/workflows/full-validation.yml`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Create: `docs/decisions/2026-07-26_P0_RUNTIME_FOUNDATION_EVIDENCE.md`

- [ ] Run planning validator, planning 24 tests, generator tests, and generated-file drift check.
- [ ] Run every Godot verifier from Tasks 1–7.
- [ ] Run existing combat, AI, restart, ultimate, prepare, A2, and A3 verifiers.
- [ ] Run `godot --headless --path . --quit` and reject parse errors.
- [ ] Record exact commands, commit SHA, Godot version, OS, and PASS/FAIL/NOT_RUN.
- [ ] Return to REVIEW before campaign integration.
