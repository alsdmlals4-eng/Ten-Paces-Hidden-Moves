# 십보강호 REPEAT_POC 코어 검증 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (권장) 또는 `superpowers:executing-plans`로 이 계획을 작업 항목별 실행한다. 각 항목은 Red → Green → Refactor → 관련 전체 검증 → 독립 커밋 순서를 지킨다.

**Goal:** 현행 10칸·4/7·3/3/4 전투 판정을 보존하면서 플레이어 가설 기록, 결정적 복기, 읽을 수 있는 라이벌 성향을 추가하고 동일 빌드의 신규 플레이어 STEP 14를 실행할 수 있는 상태로 만든다.

**Architecture:** `CombatResolutionEngine`의 판정 공식과 반환된 `timing_results`·`presentation_events`를 권위 원본으로 유지한다. AI는 공개 상태를 whitelist snapshot으로 변환한 뒤 데이터 기반 복수 후보를 점수화하고 seed로 선택한다. 플레이어 가설과 복기 요약은 전투 판정 밖의 UI·summary 계층에서 관리한다.

**Tech Stack:** Godot 4.7 feature set, GDScript, JSON 계약 데이터, Python `unittest` Governance, Godot headless verifier, Windows 수동 검증.

## Global Constraints

- 기준 base는 PR #15 `agent/project-core-confirmation`의 실행 시점 최신 head다. 계획 작성 시 head는 `b39e1e757e05faefa2860f4d642a38ea76732cdf`다.
- 제품 구현의 원기준은 PR #7 `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`다.
- 10칸, 플레이어 4번·상대 7번, 거리 3, `3수 → 3수 → 4수`, 합·방어·회피·필중·중단·강건 공식은 변경하지 않는다.
- AI는 플레이어의 미확정 placement·대상·방향·절초 예약·예상 자원을 읽지 않는다.
- 새 기초 행동·절초·세력·무공·성장·경제·저장 시스템을 추가하지 않는다.
- 복기 UI는 전투 판정을 재계산하거나 정답 행동·승률·예측률을 제시하지 않는다.
- 실제 실행하지 않은 Godot·Windows·사람·접근성·성능·Required Check는 `PASS`로 기록하지 않는다.
- 각 PR은 독립 롤백이 가능해야 하며 force push·reset·rebase로 PR #7 또는 PR #15를 덮어쓰지 않는다.

---

## 파일 책임 지도

| 책임 | 생성·수정 경로 | 공개 인터페이스 |
|---|---|---|
| 현행 계약 정렬 | `docs/02_COMBAT_RULES.md`, `docs/05_COMBAT_POC_SPEC.md`, `docs/08_TEST_CHECKLIST.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`, `data/combat/combat_board_poc.json`, `.github/reference-freshness.json`, `tests/test_project_governance.py` | board schema 17, `enemy_plan_source` |
| 라이벌 데이터 | `data/combat/combat_rival_tendency_poc.json` | profile schema 1, `rival_t0_midrange_pressure` |
| AI 후보 정책 | `src/combat/combat_ai_planner.gd` | 기존 `build_bundle_actions(state, bundle_index, cards_by_id)` 유지, `get_last_trace()` 추가 |
| 가설 기록 | `data/combat/combat_hypothesis_poc.json`, `src/ui/opponent_hypothesis_panel.gd`, `scenes/ui/opponent_hypothesis_panel.tscn` | `hypothesis_selected(snapshot)` |
| 복기 요약 | `src/combat/combat_review_summary_builder.gd` | `build_summary(result, player_plan_snapshot, hypothesis_snapshot, state_before)` |
| 복기 UI | `src/ui/combat_review_panel.gd`, `scenes/ui/combat_review_panel.tscn` | `show_summary(summary)`, `clear_summary()` |
| 전투 조정 | `src/combat/combat_board_preview.gd`, `data/combat/combat_board_poc.json` | 묶음 commit snapshot, review panel 전환 |
| Godot 검증 | `tests/verify_ai_rival_tendency.gd`, `tests/verify_combat_review_summary.gd`, `tests/verify_combat_review_ui.gd`, 기존 verifier | headless PASS marker |
| 실행 스크립트 | `tools/verify_and_commit_combat_foundation.ps1` | 신규 verifier 세 개 실행 |
| 사람 검증 | `docs/08_TEST_CHECKLIST.md`, `docs/research/STEP14_REPEAT_POC_PROTOCOL.md`, `docs/research/STEP14_REPEAT_POC_RESULTS.md` | 고정 build SHA·참가자 5명 기록 |

---

### Task 1: 정본 SHA·AI source·board schema 정렬

**Files:**
- Modify: `docs/02_COMBAT_RULES.md`
- Modify: `docs/05_COMBAT_POC_SPEC.md`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Modify: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- Modify: `data/combat/combat_board_poc.json`
- Modify: `.github/reference-freshness.json`
- Modify: `tests/test_project_governance.py`

**Interfaces:**
- Consumes: PR #7 구현 기준 `659c57e7...`, `combat_resolution_preview.json.enemy_plan_source = public_state_ai`.
- Produces: board schema 17, 단일 AI source 표현, fixture plan은 `ai_enabled == false`일 때만 허용한다는 계약.

- [ ] **Step 1: Red — 현재 충돌을 검출하는 Governance 테스트 작성**

`tests/test_project_governance.py`에 다음 의미의 테스트를 추가한다.

```python
def test_combat_ai_source_is_synchronized(self):
    board = self._load_json("data/combat/combat_board_poc.json")
    resolution = self._load_json("data/combat/combat_resolution_preview.json")
    self.assertEqual(17, board["schema_version"])
    self.assertEqual("public_state_ai", board["resolution_engine"]["enemy_plan_source"])
    self.assertTrue(board["resolution_engine"]["fixture_enemy_plan_allowed_when_ai_disabled"])
    self.assertNotIn("fixed_enemy_preview_plan", board["resolution_engine"])
    self.assertEqual("public_state_ai", resolution["enemy_plan_source"])
```

- [ ] **Step 2: Red 실행**

Run:

```bash
python -m unittest tests.test_project_governance.ProjectGovernanceTests.test_combat_ai_source_is_synchronized -v
```

Expected: `schema_version` 16 또는 `fixed_enemy_preview_plan` 때문에 FAIL.

- [ ] **Step 3: Green — board 계약 최소 변경**

`data/combat/combat_board_poc.json`의 `resolution_engine`을 다음 계약으로 바꾼다.

```json
{
  "schema_version": 17,
  "resolution_engine": {
    "enemy_plan_source": "public_state_ai",
    "fixture_enemy_plan_allowed_when_ai_disabled": true
  }
}
```

기존 `resolution_engine`의 다른 필드는 그대로 유지하고 `fixed_enemy_preview_plan`만 제거한다.

- [ ] **Step 4: Green — 문서와 freshness 정렬**

- 네 제품 문서의 구현 기준 SHA를 `659c57e7ffa588ad6a6471ed9b5394985b159eaf`로 바꾼다.
- `docs/02`와 `docs/09`에 `enemy_bundles` fixture는 AI를 명시적으로 끈 독립 테스트에서만 사용한다고 기록한다.
- `.github/reference-freshness.json.expected_board_schema_version`을 17로 올린다.
- strict required token의 `"schema_version": 16`을 17로 교체한다.
- 역사·Git 이력·백업의 schema 16은 활성 소비자가 아니므로 수정하지 않는다.

- [ ] **Step 5: Green 검증**

```bash
python -m unittest tests.test_project_governance -v
```

Expected: 모든 Governance 테스트 PASS.

- [ ] **Step 6: 회귀 검사**

```bash
python tools/check_canonical_reference_freshness.py --config .github/reference-freshness.json --base 659c57e7ffa588ad6a6471ed9b5394985b159eaf --head HEAD
```

Expected: 활성 파일의 old SHA·schema 16·`fixed_enemy_preview_plan` 잔존 0.

- [ ] **Step 7: Commit**

```bash
git add docs/02_COMBAT_RULES.md docs/05_COMBAT_POC_SPEC.md docs/08_TEST_CHECKLIST.md docs/09_COMBAT_SYSTEM_ARCHITECTURE.md data/combat/combat_board_poc.json .github/reference-freshness.json tests/test_project_governance.py
git commit -m "fix: align combat baseline and AI source contract"
```

---

### Task 2: 데이터 기반 라이벌 복수 후보 정책

**Files:**
- Create: `data/combat/combat_rival_tendency_poc.json`
- Modify: `src/combat/combat_ai_planner.gd`
- Create: `tests/verify_ai_rival_tendency.gd`
- Modify: `tools/verify_and_commit_combat_foundation.ps1`
- Modify: `docs/02_COMBAT_RULES.md`
- Modify: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`

**Interfaces:**
- Consumes: `build_bundle_actions(state: Dictionary, bundle_index: int, cards_by_id: Dictionary) -> Array`.
- Produces: 같은 함수 시그니처 유지, `get_last_trace() -> Dictionary` 추가.
- Trace에는 `public_snapshot`, `rival_id`, `candidate_ids`, `candidate_scores`, `selected_card_id`, `seed`, `reason_codes`만 허용한다.

- [ ] **Step 1: Red — rival verifier 생성**

`tests/verify_ai_rival_tendency.gd`는 다음을 검증한다.

```gdscript
extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var planner := CombatAiPlanner.new()
    var cards := _load_cards()
    var state := _public_state(4, 6, 20, 5, 4, 0, 11)
    var first := planner.build_bundle_actions(state, 1, cards)
    var second := planner.build_bundle_actions(state, 1, cards)
    _expect(first == second, "same state and seed must select the same candidate")
    var trace := planner.get_last_trace()
    for forbidden in ["placements", "player_plan", "targeting_anchor", "ultimate_reservation", "preview_resources"]:
        _expect(not _contains_key_recursive(trace, forbidden), "trace leaked private field: %s" % forbidden)
    _verify_seed_candidate_bounds(planner, state, cards)
    _verify_tendency_distribution(planner, state, cards)
    _finish()
```

PASS marker는 `AI_RIVAL_TENDENCY_VERIFY_OK`로 고정한다.

- [ ] **Step 2: Red 실행**

```bash
godot --headless --path . --script res://tests/verify_ai_rival_tendency.gd
```

Expected: 데이터 파일·`get_last_trace()`·복수 후보가 없어 FAIL.

- [ ] **Step 3: rival 데이터 생성**

`data/combat/combat_rival_tendency_poc.json`:

```json
{
  "schema_version": 1,
  "default_rival_id": "rival_t0_midrange_pressure",
  "rivals": [
    {
      "rival_id": "rival_t0_midrange_pressure",
      "display_name": "중거리 압박형 시범 상대",
      "archetype": "midrange_pressure",
      "public_clues": [
        {"clue_id": "keeps_two_tiles", "text": "두 칸 안팎의 거리를 자주 유지한다."},
        {"clue_id": "prepares_when_safe", "text": "거리가 맞으면 준비가 긴 공격을 노린다."},
        {"clue_id": "guards_when_hurt", "text": "체력이 낮아지면 대응을 섞는다."}
      ],
      "candidate_policy": {
        "max_candidates": 3,
        "score_window": 2.0,
        "deterministic_seed_scope": "round_bundle",
        "tie_breaker": "stable_card_id_then_seed"
      },
      "weights": {
        "approach_when_far": 5.0,
        "heavy_at_distance_two": 6.0,
        "quick_at_distance_one": 5.0,
        "guard_when_health_low": 4.0,
        "evade_when_health_low": 3.0,
        "meditate_when_resource_low": 6.0,
        "ultimate_when_ready": 7.0,
        "retreat_when_engaged": 2.0
      }
    }
  ]
}
```

- [ ] **Step 4: Green — planner를 후보 생성·점수·선택으로 분리**

`CombatAiPlanner`는 다음 메서드를 가진다.

```gdscript
const RIVAL_POLICY_PATH := "res://data/combat/combat_rival_tendency_poc.json"

var _policy_data: Dictionary = {}
var _last_trace: Dictionary = {}

func build_bundle_actions(state: Dictionary, bundle_index: int, cards_by_id: Dictionary) -> Array:
    var snapshot := _build_public_snapshot(state, bundle_index)
    var profile := _default_profile()
    var candidates := _generate_candidates(snapshot, cards_by_id)
    _score_candidates(candidates, snapshot, profile)
    var selected := _select_candidate(candidates, int(snapshot["seed"]), profile)
    _last_trace = _build_trace(snapshot, profile, candidates, selected)
    return [] if selected.is_empty() else [_to_planned_action(selected, snapshot)]

func get_last_trace() -> Dictionary:
    return _last_trace.duplicate(true)
```

`_build_public_snapshot()`은 다음 키만 새 Dictionary에 복사한다.

```text
round_number, bundle_index, bundle_start, bundle_end, slots,
player_tile, enemy_tile, distance,
enemy_health, enemy_health_max,
enemy_stamina, enemy_internal,
enemy_momentum, enemy_momentum_max,
seed
```

원본 `state` 전체를 trace 또는 후보에 저장하지 않는다.

- [ ] **Step 5: 후보 규칙 구현**

- 거리 3 이상: `basic_move`; 내력 1 이상이면 `basic_footwork`; 자원 부족이면 `basic_meditate`.
- 거리 2: `basic_heavy_attack`, `basic_move`, `basic_guard`, 자원 조건을 만족하면 `basic_evade`.
- 거리 0~1: `basic_quick_attack`, `basic_guard`, `basic_evade`, 유효한 후퇴 칸이 있으면 `basic_move`.
- 기세 5: 거리·슬롯 조건에 맞는 절초를 후보에 추가한다.
- 후보 0개는 자원 소모 없는 `basic_guard`, 그것도 없으면 빈 Array를 반환한다.
- score 내림차순·card ID 오름차순으로 정렬하고 최고점에서 `score_window` 이내의 최대 3개만 seed 선택 pool에 둔다.
- 선택 인덱스는 `abs(seed) % pool.size()`다.

- [ ] **Step 6: Green 검증**

```bash
godot --headless --path . --script res://tests/verify_ai_rival_tendency.gd
```

Expected: `AI_RIVAL_TENDENCY_VERIFY_OK`.

- [ ] **Step 7: 기존 AI·판정 회귀**

```bash
godot --headless --path . --script res://tests/verify_ultimate_interrupt_engagement.gd
godot --headless --path . --script res://tests/verify_combat_terminal_presentation.gd
```

Expected: 기존 PASS marker 유지.

- [ ] **Step 8: PowerShell 검증에 신규 verifier 추가 후 Commit**

```bash
git add data/combat/combat_rival_tendency_poc.json src/combat/combat_ai_planner.gd tests/verify_ai_rival_tendency.gd tools/verify_and_commit_combat_foundation.ps1 docs/02_COMBAT_RULES.md docs/09_COMBAT_SYSTEM_ARCHITECTURE.md
git commit -m "feat: add readable deterministic rival candidate policy"
```

---

### Task 3: 플레이어 가설 기록 계약

**Files:**
- Create: `data/combat/combat_hypothesis_poc.json`
- Create: `src/ui/opponent_hypothesis_panel.gd`
- Create: `scenes/ui/opponent_hypothesis_panel.tscn`
- Modify: `src/combat/combat_board_preview.gd`
- Modify: `data/combat/combat_board_poc.json`
- Create: `tests/verify_combat_hypothesis_capture.gd`
- Modify: `tools/verify_and_commit_combat_foundation.ps1`

**Interfaces:**
- Produces signal: `hypothesis_selected(snapshot: Dictionary)`.
- Snapshot schema: `hypothesis_id`, `label`, `round_number`, `bundle_index`, `captured_before_commit`.
- `none`은 유효한 선택이며 복기에서 “가설을 기록하지 않음”으로 표시한다.

- [ ] **Step 1: Red verifier 작성**

검증 항목:

1. 정확히 6개 선택지: `approach`, `quick_attack`, `heavy_preparation`, `response_or_recovery`, `ultimate`, `none`.
2. 선택은 판정 전 snapshot으로 고정된다.
3. 판정 중 선택 변경이 차단된다.
4. 다음 묶음에서 `none`으로 초기화된다.
5. `combat_state`와 `CombatResolutionEngine` 입력에는 hypothesis가 추가되지 않는다.

PASS marker: `COMBAT_HYPOTHESIS_CAPTURE_VERIFY_OK`.

- [ ] **Step 2: Red 실행**

```bash
godot --headless --path . --script res://tests/verify_combat_hypothesis_capture.gd
```

Expected: panel·data·snapshot이 없어 FAIL.

- [ ] **Step 3: hypothesis 데이터 생성**

```json
{
  "schema_version": 1,
  "default_id": "none",
  "options": [
    {"id": "approach", "label": "접근한다"},
    {"id": "quick_attack", "label": "속공을 건다"},
    {"id": "heavy_preparation", "label": "강공을 준비한다"},
    {"id": "response_or_recovery", "label": "대응하거나 회복한다"},
    {"id": "ultimate", "label": "절초를 노린다"},
    {"id": "none", "label": "아직 모르겠다"}
  ]
}
```

- [ ] **Step 4: UI 구현 계약**

`OpponentHypothesisPanel`은 포커스 가능한 `OptionButton`과 설명 Label만 가진다.

```gdscript
signal hypothesis_selected(snapshot: Dictionary)

func set_bundle_context(round_number: int, bundle_index: int) -> void
func get_snapshot() -> Dictionary
func set_locked(value: bool) -> void
func reset_for_next_bundle(round_number: int, bundle_index: int) -> void
```

`CombatBoardPreview._on_progress_requested()`는 `_resolve_and_present()` 호출 전에 `get_snapshot()` 결과와 `action_timing_panel.get_resolution_placements().duplicate(true)`를 지역 snapshot으로 저장한다. `combat_state`에는 기록하지 않는다.

- [ ] **Step 5: Layout·focus 계약**

- 패널은 action timing row 상단 중앙에 배치한다.
- 960×640에서 전장·슬롯·진행 버튼을 가리지 않는다.
- focus 순서: 카드 → 슬롯/대상 → 가설 → 진행 → 재생 제어 → 로그.
- 색상 외에 선택 label과 assistive description을 제공한다.

- [ ] **Step 6: Green 검증 및 Commit**

```bash
godot --headless --path . --script res://tests/verify_combat_hypothesis_capture.gd
godot --headless --path . --script res://tests/verify_combat_focus_order.gd
godot --headless --path . --script res://tests/verify_combat_layout_accessibility.gd
```

```bash
git add data/combat/combat_hypothesis_poc.json data/combat/combat_board_poc.json src/ui/opponent_hypothesis_panel.gd scenes/ui/opponent_hypothesis_panel.tscn src/combat/combat_board_preview.gd tests/verify_combat_hypothesis_capture.gd tools/verify_and_commit_combat_foundation.ps1
git commit -m "feat: capture player rival hypothesis before commit"
```

---

### Task 4: 결정적 복기 summary builder

**Files:**
- Create: `src/combat/combat_review_summary_builder.gd`
- Create: `tests/verify_combat_review_summary.gd`
- Modify: `docs/02_COMBAT_RULES.md`
- Modify: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`

**Interfaces:**
- Consumes: `result.resolved_actions`, `result.timing_results`, `result.presentation_events`, commit 시점 player plan snapshot, hypothesis snapshot, state before.
- Produces:

```yaml
schema_version: 1
hypothesis:
player_plan:
enemy_plan:
decisive_timing:
cause_code:
cause_label:
state_before:
state_after:
suggested_dimension:
summary_text:
```

- [ ] **Step 1: Red fixture 작성**

`tests/verify_combat_review_summary.gd`에서 합·사거리·방향·막기·회피·필중·중단·자원 대표 fixture를 직접 엔진으로 실행하고 builder 결과를 검사한다.

우선순위는 다음으로 고정한다.

```text
combat_end
→ interrupted
→ clash_loss / clash_win / clash_draw
→ miss_direction / miss_range
→ sure_hit
→ evade
→ block
→ damage
→ movement
→ resource
→ no_decisive_event
```

PASS marker: `COMBAT_REVIEW_SUMMARY_VERIFY_OK`.

- [ ] **Step 2: Red 실행**

```bash
godot --headless --path . --script res://tests/verify_combat_review_summary.gd
```

Expected: builder class가 없어 FAIL.

- [ ] **Step 3: builder 구현**

```gdscript
class_name CombatReviewSummaryBuilder
extends RefCounted

func build_summary(
    result: Dictionary,
    player_plan_snapshot: Array,
    hypothesis_snapshot: Dictionary,
    state_before: Dictionary
) -> Dictionary:
    var decisive := _select_decisive_event(result)
    return {
        "schema_version": 1,
        "hypothesis": _normalize_hypothesis(hypothesis_snapshot),
        "player_plan": _summarize_player_plan(player_plan_snapshot),
        "enemy_plan": _summarize_enemy_plan(result.get("resolved_actions", [])),
        "decisive_timing": int(decisive.get("timing", 0)),
        "cause_code": str(decisive.get("cause_code", "no_decisive_event")),
        "cause_label": _cause_label(str(decisive.get("cause_code", "no_decisive_event"))),
        "state_before": _state_summary(state_before),
        "state_after": _state_summary(result.get("state", {})),
        "suggested_dimension": _suggested_dimension(decisive),
        "summary_text": _summary_text(decisive, hypothesis_snapshot)
    }
```

- [ ] **Step 4: 정직한 가설 비교 규칙**

- `hypothesis_id == none`이면 `summary_text`에 “가설을 기록하지 않음”을 사용한다.
- 실제 enemy action과 category가 일치할 때만 “예상이 맞았다”고 표시한다.
- 불일치하면 “예상과 달랐다”고 표시한다.
- 가설 label을 AI가 생성하거나 상세 행동으로 확장하지 않는다.
- `suggested_dimension`은 `거리`, `방향`, `대응`, `순서`, `자원` 중 하나이며 카드 ID를 추천하지 않는다.

- [ ] **Step 5: Green·회귀 검증 및 Commit**

```bash
godot --headless --path . --script res://tests/verify_combat_review_summary.gd
godot --headless --path . --script res://tests/verify_ultimate_interrupt_engagement.gd
```

```bash
git add src/combat/combat_review_summary_builder.gd tests/verify_combat_review_summary.gd docs/02_COMBAT_RULES.md docs/09_COMBAT_SYSTEM_ARCHITECTURE.md
git commit -m "feat: derive deterministic combat review summaries"
```

---

### Task 5: 결정적 복기 UI·전투 흐름 통합

**Files:**
- Create: `src/ui/combat_review_panel.gd`
- Create: `scenes/ui/combat_review_panel.tscn`
- Modify: `src/combat/combat_board_preview.gd`
- Modify: `data/combat/combat_board_poc.json`
- Create: `tests/verify_combat_review_ui.gd`
- Modify: `tools/verify_and_commit_combat_foundation.ps1`
- Modify: `docs/07_COMBAT_UI_SPEC.md`
- Modify: `docs/08_TEST_CHECKLIST.md`

**Interfaces:**
- `CombatReviewPanel.show_summary(summary: Dictionary) -> void`.
- `CombatReviewPanel.clear_summary() -> void`.
- signal `details_requested`, signal `continue_requested`.

- [ ] **Step 1: Red UI verifier 작성**

검증 항목:

- 묶음 판정·연출 종료 뒤 review panel이 표시된다.
- 기본 화면에는 가설, 상대 실제 요약, 결정적 수·원인, 전후 거리, 검토 차원만 표시된다.
- 상세 로그는 기존 `CombatLogPanel`에서만 제공한다.
- 계속 버튼을 누르기 전 다음 묶음 편집은 잠긴다.
- 전투 종료에서도 review panel을 먼저 읽은 뒤 재시작 버튼으로 이동한다.
- 모션 감소·즉시 완료에서도 동일 summary text다.
- 키보드 focus: review → 상세 기록 → 계속/재시작.

PASS marker: `COMBAT_REVIEW_UI_VERIFY_OK`.

- [ ] **Step 2: Red 실행**

```bash
godot --headless --path . --script res://tests/verify_combat_review_ui.gd
```

Expected: review panel이 없어 FAIL.

- [ ] **Step 3: BoardPreview 통합**

`_resolve_and_present()`의 지역 변수로 다음을 유지한다.

```gdscript
var state_before := combat_state.duplicate(true)
var player_plan_snapshot := action_timing_panel.get_resolution_placements().duplicate(true)
var hypothesis_snapshot := opponent_hypothesis_panel.get_snapshot()
var result := resolution_engine.resolve_bundle(player_plan_snapshot, context, combat_state)
var review_summary := review_summary_builder.build_summary(
    result, player_plan_snapshot, hypothesis_snapshot, state_before
)
```

연출 완료 뒤 `_set_presentation_state("review_ready")`로 전환하고 panel을 표시한다. `review_ready`에서는 계획 입력을 잠그고 review panel·로그·재생 제어만 허용한다. 계속 버튼에서만 다음 bundle로 advance하고 hypothesis를 reset한다.

- [ ] **Step 4: UI 정보 위계**

```text
내 가설
상대 실제 행동
결정적 2수 · 합 패배
거리 1 → 1
다음에는 ‘순서’를 검토
[상세 기록] [다음 묶음]
```

승률·예측률·정답 카드·AI 내부 score·candidate trace는 표시하지 않는다.

- [ ] **Step 5: Green·접근성 회귀 및 Commit**

```bash
godot --headless --path . --script res://tests/verify_combat_review_ui.gd
godot --headless --path . --script res://tests/verify_combat_keyboard_accessibility.gd
godot --headless --path . --script res://tests/verify_combat_focus_order.gd
godot --headless --path . --script res://tests/verify_combat_layout_accessibility.gd
godot --headless --path . --script res://tests/verify_combat_presentation_liveness.gd
```

```bash
git add src/ui/combat_review_panel.gd scenes/ui/combat_review_panel.tscn src/combat/combat_board_preview.gd data/combat/combat_board_poc.json tests/verify_combat_review_ui.gd tools/verify_and_commit_combat_foundation.ps1 docs/07_COMBAT_UI_SPEC.md docs/08_TEST_CHECKLIST.md
git commit -m "feat: add accessible decisive review flow"
```

---

### Task 6: 전체 검증·고정 빌드·STEP 14 프로토콜

**Files:**
- Create: `docs/research/STEP14_REPEAT_POC_PROTOCOL.md`
- Create: `docs/research/STEP14_REPEAT_POC_RESULTS.md`
- Modify: `docs/05_COMBAT_POC_SPEC.md`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `[기획서]/00_프로젝트_허브/ROADMAP.md`
- Modify: `[기획서]/00_프로젝트_허브/HANDOFF.md`

**Interfaces:**
- Protocol은 고정 build SHA, Godot version, Windows version, viewport, input method, participant order를 소유한다.
- Results는 관찰·발화·해석·제안을 분리한다.

- [ ] **Step 1: 전체 정적 검증**

```bash
python -m unittest tests.test_project_governance -v
python tools/check_canonical_reference_freshness.py --config .github/reference-freshness.json --base 659c57e7ffa588ad6a6471ed9b5394985b159eaf --head HEAD
```

Expected: PASS.

- [ ] **Step 2: 전체 Godot 검증**

Windows 또는 Godot 4.x가 설치된 검증 환경에서:

```powershell
powershell -ExecutionPolicy Bypass -File tools/verify_and_commit_combat_foundation.ps1 -NoPush
```

Expected: 기존 verifier와 신규 AI·hypothesis·summary·review UI verifier 모두 PASS, 작업 트리 side effect 0.

- [ ] **Step 3: Windows 수동 기술 확인**

- 1440×900과 960×640.
- 포인터·키보드.
- 모션 감소 켬/끔, 음향 켬/끔.
- 정상 묶음, 가설 `none`, 합·회피·필중·중단, 전투 종료, 재시작 10회.
- 결과는 PASS/PARTIAL/FAIL/NOT_RUN으로 기록한다.

- [ ] **Step 4: 고정 빌드와 프로토콜 작성**

`STEP14_REPEAT_POC_PROTOCOL.md`에 다음을 고정한다.

```yaml
build_commit: <검증 통과한 정확한 SHA>
participant_count: 5
first_play_only: true
facilitator_help: critical_blocker_only
required_scenarios:
  - complete_one_battle
  - explain_3_3_4
  - explain_one_decisive_cause
  - identify_one_rival_tendency
  - change_plan_on_retry
  - check_non_single-channel_information
```

실제 실행 시 `<검증 통과한 정확한 SHA>`를 실제 SHA로 교체하지 않은 상태에서는 프로토콜을 CURRENT로 표시하지 않는다.

- [ ] **Step 5: 사람 STEP 14 실행·기록**

통과 신호:

- 5명 중 4명 이상 치명적 차단 없이 한 판 완료.
- 5명 중 4명 이상 3/3/4와 결정적 원인 하나 설명.
- 5명 중 3명 이상 안내 없이 라이벌 성향 하나 발견.
- 5명 중 3명 이상 재도전에서 계획을 실질적으로 변경.
- 5명 중 3명 이상 자발적 재도전 또는 구체적 다음 수 제시.
- 핵심 정보가 색·모션·음향 하나에만 의존한 참가자 0명.

- [ ] **Step 6: 결과 판정**

각 finding을 `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`로 판정한다.

```yaml
human_step14: PASS | PARTIAL | FAIL | BLOCKED
product_gate: T1_GREENLIGHT_REVIEW | REPEAT_POC
mvp_complete: false
```

사람 STEP 14 통과만으로 전체 MVP 완료를 선언하지 않는다. 접근성 사용자·Release 성능·Required Check가 현재 완료 기준에 필수인지 최신 게이트에서 다시 판정한다.

- [ ] **Step 7: 상태 문서·PR 갱신 및 Commit**

```bash
git add docs/research/STEP14_REPEAT_POC_PROTOCOL.md docs/research/STEP14_REPEAT_POC_RESULTS.md docs/05_COMBAT_POC_SPEC.md docs/08_TEST_CHECKLIST.md "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md" "[기획서]/00_프로젝트_허브/ROADMAP.md" "[기획서]/00_프로젝트_허브/HANDOFF.md"
git commit -m "docs: lock repeat POC playtest evidence gate"
```

---

## PR 순서

1. `PR-A0` — 정본 SHA·AI source·schema 17 정렬.
2. `PR-A1` — 데이터 기반 라이벌 복수 후보 정책.
3. `PR-A2` — 가설 기록 + 결정적 summary builder.
4. `PR-A3` — 복기 UI·전투 흐름·접근성 통합.
5. `PR-A4` — 고정 빌드·STEP 14 프로토콜과 결과.

각 PR은 직전 PR을 base로 하는 스택형 PR로 만들고, 직전 PR이 변경되면 ancestry를 확인한 뒤 `merge` 또는 새 branch로 전파한다. force rebase는 사용하지 않는다.

## 최종 완료 기준

- 활성 정본에서 old SHA·schema 16·`fixed_enemy_preview_plan`이 현재 계약으로 남지 않는다.
- 같은 공개 상태·같은 seed는 같은 AI 선택을 만든다.
- 다른 seed도 합리적 candidate pool 밖 행동을 선택하지 않는다.
- private player plan 값이 AI snapshot·trace에 없다.
- 플레이어 가설이 commit 전에 snapshot되고, 미선택은 추정 없이 표시된다.
- 합·방어·회피·필중·중단 fixture가 결정적 cause code를 정확히 선택한다.
- review UI가 판정을 재계산하지 않고 키보드·모션 감소에서 동일 정보를 제공한다.
- 전체 Governance·Godot·Windows 검증 결과가 기록된다.
- 동일 build SHA로 STEP 14를 실행한다.
- 필수 미검증이 남으면 `MVP_COMPLETE`를 선언하지 않는다.

## Rollback

- PR-A0: schema 17·문서 정렬 커밋만 revert하고 schema 16 소비자를 복구한다.
- PR-A1: `CombatAiPlanner` 공개 함수 시그니처를 유지한 채 기존 `_choose_card` 구현으로 되돌린다.
- PR-A2: hypothesis panel과 summary builder를 제거해도 판정·기존 로그가 유지된다.
- PR-A3: review panel feature flag를 끄고 기존 `next_bundle_ready` 흐름으로 복귀한다.
- PR-A4: 연구 문서만 되돌리며 관찰 원문은 삭제하지 않고 역사로 보존한다.
