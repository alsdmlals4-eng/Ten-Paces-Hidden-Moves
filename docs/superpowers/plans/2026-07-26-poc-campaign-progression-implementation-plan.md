# PoC Campaign Progression Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 주요 비무 1~5, 네 구간의 중간 노드, 성장·보상·등급·10성 절초를 하나의 재현 가능한 회차 흐름으로 구현한다.

**Architecture:** `RunStateStore`가 현재 노드·체력·성장·재화를 소유하고, `PocCampaignController`가 `PocRuntimeCatalog`이 로드한 결투·지도 카탈로그를 순회한다. 전투 결과는 `RewardService`가 한 번만 commit하며 UI는 선택지를 표시할 뿐 수치를 계산하지 않는다.

**Tech Stack:** Godot 4.x, GDScript, generated JSON runtime catalog, Godot headless tests.

## Global Constraints

- 구현 범위는 주요 비무 1~5와 네 gap뿐이다.
- 각 gap은 실제 방문 노드 2~3개다.
- 총 중간 노드 8~12, 주요 비무 포함 총 방문 13~17이다.
- 주요 비무 보상 선택은 자유6 / 지정5+자유3 / 문파 무공3성이다.
- 동일 주요 비무 보상은 한 번만 commit한다.
- 3성→10성 총비용은 38포인트다.
- 집중 경로는 주요 비무 1~4에서 지정5+자유3을 같은 무공에 선택한 32 + 노드 최소6이다.
- 자유 경로는 자유24 + 고효율 노드 목표14이며 모든 seed에 보장하지 않는다.
- 기본 절초 3종은 시작 가용, 무공별 절초는 해당 무공 10성에서만 해금한다.
- 승리 후 회복은 `min(missing_health, 2 + medical)`이다.

---

### Task 1: Campaign runtime catalog

**Files:**
- Create: `src/run/poc_campaign_catalog.gd`
- Create: `tests/verify_p0_campaign_catalog.gd`

**Interfaces:**
- Consumes: `PocRuntimeCatalog.load_catalog()`의 `duels`와 `map` 섹션.
- Produces: `get_duel(order: int) -> Dictionary`, `get_gap(from_order: int) -> Dictionary`, `build_route(seed: int) -> Array[Dictionary]`.

- [ ] Write a failing test asserting duel orders `[1,2,3,4,5]`, four gaps, 2–3 nodes per gap, total 13–17 visited entries, and no duel 6+.
- [ ] Run `godot --headless --path . --script res://tests/verify_p0_campaign_catalog.gd` and confirm RED.
- [ ] Implement deterministic route generation using stable node IDs and run seed.
- [ ] Reject duplicate node IDs, unsupported node types, and routes outside gap counts.
- [ ] Run GREEN and commit as `feat: add deterministic PoC campaign catalog`.

### Task 2: Campaign controller and node transitions

**Files:**
- Create: `src/run/poc_campaign_controller.gd`
- Create: `scenes/run/poc_campaign_screen.tscn`
- Create: `src/ui/poc_campaign_screen.gd`
- Create: `tests/verify_p0_campaign_flow.gd`

**Interfaces:**
- `start_new_run(seed: int, selected_manual_ids: Array[String])`.
- `enter_current_node() -> Dictionary`.
- `complete_current_node(result: Dictionary) -> Dictionary`.
- Signals: `node_entered(node)`, `battle_requested(duel)`, `reward_requested(reward_context)`, `run_completed(summary)`.

- [ ] Write RED flow: manual selection → duel1 → 2–3 nodes → duel2 → ... → duel5 → run completion.
- [ ] Verify visited node IDs append exactly once and current node advances only after a committed result.
- [ ] Implement battle node, training node, faction node, event node, inn node, and market node handlers with minimal PoC fields.
- [ ] Keep unimplemented node effects explicit as rejected data rather than silent no-op.
- [ ] Run GREEN and commit as `feat: orchestrate five-duel PoC campaign`.

### Task 3: Starting manual selection and mastery state

**Files:**
- Create: `src/run/manual_mastery_service.gd`
- Create: `scenes/run/manual_selection_screen.tscn`
- Create: `src/ui/manual_selection_screen.gd`
- Create: `tests/verify_p0_manual_selection.gd`

**Interfaces:**
- `validate_starting_selection(ids: Array[String]) -> bool` requires exactly four unique IDs from six candidates.
- `initialize_mastery(ids: Array[String]) -> Dictionary` sets selected manuals to mastery 3 and unselected manuals absent.
- `add_training(manual_id: String, points: int) -> Dictionary` applies cumulative thresholds and unlocks.

- [ ] Test exactly four unique manuals, all starting at 3, no deck/hand/equip cap, and invalid IDs rejected.
- [ ] Test 38 points advances one manual from 3 to 10 using canonical thresholds.
- [ ] Test basic ultimates exist independently from manual 10-star ultimates.
- [ ] Implement and run tests.
- [ ] Commit as `feat: add starting manual and mastery progression`.

### Task 4: Reward ownership and choices

**Files:**
- Create: `src/run/reward_service.gd`
- Create: `scenes/run/major_duel_reward_screen.tscn`
- Create: `src/ui/major_duel_reward_screen.gd`
- Create: `tests/verify_p0_reward_choices.gd`

**Interfaces:**
- `build_major_duel_options(duel_id: String, grade: String) -> Array[Dictionary]`.
- `commit_choice(run_state: Dictionary, battle_result_id: String, option_id: String, target_manual_id: String = "") -> Dictionary`.
- Reward ledger key: `battle_result_id`; duplicate commit returns an error and no mutation.

- [ ] Test free6 grants six unrestricted points.
- [ ] Test focused grants five designated plus three free points.
- [ ] Test faction manual grants the configured manual at mastery 3 and no extra central reward.
- [ ] Test duplicate commit, invalid manual, and choice after rollback.
- [ ] Implement UI as a pure selection surface using service-provided totals.
- [ ] Run tests and commit as `feat: implement exclusive major duel rewards`.

### Task 5: Grade calculator

**Files:**
- Create: `src/run/performance_grade_service.gd`
- Create: `tests/verify_p0_performance_grade.gd`

**Interfaces:**
- Dimensions: five 0–100 scores.
- Weights: 30/25/15/15/15.
- Thresholds: S≥85, A≥70, B≥55, C≥0.
- Rounding owner: `ROUND_HALF_UP_PER_DIMENSION`, matching `poc_map_rewards.json`; do not replace it with language/runtime-default rounding.
- Boundary fixtures: `54.5 / 69.5 / 84.5` must be covered explicitly so half-step behavior cannot drift between the JSON owner, implementation, and tests.
- `calculate(dimensions: Dictionary) -> Dictionary` returns rounded weighted score, clamped 0–100, and grade.

- [ ] Test boundary values 84/85, 69/70, 54/55 plus `54.5 / 69.5 / 84.5`, and invalid negative/over-100 dimensions.
- [ ] Test no direct round, stalemate, or hidden-plan penalty.
- [ ] Implement and commit as `feat: calculate explainable duel grades`.

### Task 6: Node reward supply and 38-point routes

**Files:**
- Create: `src/run/node_reward_service.gd`
- Modify: `src/run/poc_campaign_catalog.gd`
- Create: `tests/verify_p0_growth_routes.gd`

**Interfaces:**
- `sum_designated_supply(route: Array, manual_id: String) -> int`.
- `sum_high_efficiency_free_supply(route: Array) -> int`.

- [ ] Test every generated route guarantees at least six designated-compatible training points across four gaps.
- [ ] Test target routes can offer fourteen high-efficiency free points but do not claim universal guarantee.
- [ ] Test no node reward is negative and no gap exceeds 2–3 nodes.
- [ ] Implement deterministic supply constraints and commit as `feat: guarantee focused mastery route`.

### Task 7: Victory health recovery and battle transition

**Files:**
- Modify: `src/run/run_state_store.gd`
- Modify: `src/run/poc_campaign_controller.gd`
- Create: `tests/verify_p0_victory_recovery.gd`

**Interfaces:**
- `apply_victory_recovery(current_health: int, max_health: int, medical: int) -> int`.

- [ ] Test medical 0–4, no overheal, zero missing HP, and health persistence into next battle.
- [ ] Ensure stamina, internal, momentum, guard, evade, sure-hit, empowerment, and fortitude reset at battle entry while persistent HP does not.
- [ ] Run tests and commit as `feat: persist health and apply victory recovery`.

### Task 8: Campaign save boundary

**Files:**
- Create: `src/run/run_state_serializer.gd`
- Create: `tests/verify_p0_run_state_serialization.gd`

**Interfaces:**
- `serialize(run_state: Dictionary) -> String`.
- `deserialize(payload: String) -> Dictionary`.
- Include `schema_version`; reject unknown future versions.

- [ ] Test deterministic round-trip for run seed, route IDs, health, manuals/mastery, currency, permanent currency, retry count, reward ledger, and current battle snapshot metadata.
- [ ] Do not implement migration beyond current schema; return an explicit unsupported-version error.
- [ ] Commit as `feat: serialize PoC run state contract`.

### Task 9: Campaign integration gate

**Files:**
- Modify: `.github/workflows/full-validation.yml`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Create: `docs/decisions/2026-07-26_P0_CAMPAIGN_PROGRESSION_EVIDENCE.md`

- [ ] Run runtime catalog, retry, campaign catalog, flow, manual, reward, grade, growth, recovery, and serialization verifiers.
- [ ] Run all runtime foundation and legacy combat regressions.
- [ ] Execute a headless deterministic run from manual selection through duel 5 for at least `1,024` deterministic seeds when the runtime route generator exists; until then record `NOT_RUN`, never a static PASS.
- [ ] Assert every run has 13–17 visits and every focused route reaches 38 before duel 5.
- [ ] Record PASS/FAIL/NOT_RUN and return to REVIEW before presentation integration.
