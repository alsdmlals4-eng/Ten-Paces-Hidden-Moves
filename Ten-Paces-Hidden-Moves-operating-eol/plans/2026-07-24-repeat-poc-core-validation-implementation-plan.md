# 십보강호 REPEAT_POC 기술 구현 계획

> 실행 방식: `superpowers:executing-plans`  
> 상태: `READY / IMPLEMENTATION_NOT_STARTED`  
> 사용자 결정: 신규 플레이어 STEP 14는 `DEFERRED_BY_USER`이며 현재 실행 범위가 아니다.

## Goal

현행 10칸·4/7·3/3/4 전투 판정을 보존하면서 다음 기술 계약을 구현한다.

1. 정본 SHA·AI source·board schema 정렬.
2. 공개 정보만 사용하는 읽을 수 있는 라이벌 복수 후보 정책.
3. 플레이어가 직접 기록하는 가설 snapshot.
4. 판정 결과에서 도출되는 결정적 원인 summary.
5. 키보드·모션 감소에서도 읽히는 복기 UI.

사람 테스트를 실행하지 않으므로 기술 구현 완료 이후에도 재미·이해도·상대 성향 발견은 `UNVERIFIED`로 남긴다.

## Architecture

- `CombatResolutionEngine`의 판정 공식과 `timing_results`·`presentation_events`를 권위 원본으로 유지한다.
- AI는 공개 상태 whitelist snapshot만 사용한다.
- 플레이어 가설과 복기 요약은 판정 밖 UI·summary 계층에서 관리한다.
- 복기 UI는 결과를 재계산하지 않는다.

## Global Constraints

- 제품 원기준: `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 10칸, 4/7, 거리 3, `3수 → 3수 → 4수` 불변.
- 합·방어·회피·필중·중단·강건 공식 불변.
- private placement·대상·방향·절초 예약·preview resource를 AI에 전달하지 않는다.
- 새 행동·절초·세력·성장·경제·저장 시스템을 추가하지 않는다.
- 정답 행동·승률·예측률을 표시하지 않는다.
- 실제 실행하지 않은 검증을 `PASS`로 기록하지 않는다.
- PR-A0~A3는 독립 롤백 가능한 스택형 PR로 유지한다.

## PR 순서

```text
PR-A0 정본·schema 17·AI source
→ PR-A1 라이벌 복수 후보 AI
→ PR-A2 가설 snapshot·결정적 summary
→ PR-A3 복기 UI·접근성·기술 closeout
```

---

## Task 1 / PR-A0 — 정본 SHA·AI source·board schema 정렬

### Files

- `docs/02_COMBAT_RULES.md`
- `docs/05_COMBAT_POC_SPEC.md`
- `docs/08_TEST_CHECKLIST.md`
- `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- `data/combat/combat_board_poc.json`
- `.github/reference-freshness.json`
- `tests/test_project_governance.py`

### Red

`tests/test_project_governance.py`에 다음 의미의 테스트를 먼저 추가한다.

```python
def test_combat_ai_source_is_synchronized(self):
    board = json.loads((ROOT / "data/combat/combat_board_poc.json").read_text(encoding="utf-8"))
    resolution = json.loads((ROOT / "data/combat/combat_resolution_preview.json").read_text(encoding="utf-8"))
    self.assertEqual(17, board["schema_version"])
    self.assertEqual("public_state_ai", board["resolution_engine"]["enemy_plan_source"])
    self.assertTrue(board["resolution_engine"]["fixture_enemy_plan_allowed_when_ai_disabled"])
    self.assertNotIn("fixed_enemy_preview_plan", board["resolution_engine"])
    self.assertEqual("public_state_ai", resolution["enemy_plan_source"])
```

Red expected: schema 16 또는 `fixed_enemy_preview_plan` 때문에 실패.

### Green

- board schema를 17로 올린다.
- `resolution_engine.enemy_plan_source = public_state_ai`를 명시한다.
- `fixture_enemy_plan_allowed_when_ai_disabled = true`를 명시한다.
- `fixed_enemy_preview_plan`을 제거한다.
- 네 제품 문서의 구현 기준을 `659c57e7...`로 정렬한다.
- fixture `enemy_bundles`는 `ai_enabled == false`인 독립 테스트에서만 허용한다고 문서화한다.
- freshness의 expected schema와 required token을 17로 갱신한다.

### Verification

```bash
python -m unittest tests.test_project_governance -v
python tools/check_canonical_reference_freshness.py --config .github/reference-freshness.json --base 659c57e7ffa588ad6a6471ed9b5394985b159eaf --head HEAD
```

### Commit

`fix: align combat baseline and AI source contract`

---

## Task 2 / PR-A1 — 데이터 기반 라이벌 복수 후보 정책

### Files

- Create: `data/combat/combat_rival_tendency_poc.json`
- Modify: `src/combat/combat_ai_planner.gd`
- Create: `tests/verify_ai_rival_tendency.gd`
- Modify: `tools/verify_and_commit_combat_foundation.ps1`
- Modify: `docs/02_COMBAT_RULES.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`

### Contract

- 기존 `build_bundle_actions(state, bundle_index, cards_by_id)` 시그니처 유지.
- `get_last_trace() -> Dictionary` 추가.
- trace 허용 키: `public_snapshot`, `rival_id`, `candidate_ids`, `candidate_scores`, `selected_card_id`, `seed`, `reason_codes`.
- 같은 공개 상태·seed는 같은 선택.
- 다른 seed도 score window의 합리 후보 밖 행동을 선택하지 않는다.
- private plan 관련 키는 snapshot·trace에 존재하지 않는다.

### Red

`tests/verify_ai_rival_tendency.gd`에서 다음을 검증한다.

- 데이터 파일과 profile schema 존재.
- same state/seed 재현.
- 다른 seed 후보 경계.
- 공개 clue와 선택 이유 code 일치.
- private field recursive leak 0.

PASS marker: `AI_RIVAL_TENDENCY_VERIFY_OK`.

### Green

- 라이벌 1명만 구현한다: `rival_t0_midrange_pressure`.
- 공개 단서: 중거리 유지, 안전한 강공 준비, 저체력 대응.
- 후보는 최대 3개, score window 2.0.
- seed는 round/bundle 범위에서 결정적이다.
- 근거 없는 완전 랜덤은 금지한다.

### Verification

신규 verifier와 기존 combat AI·판정 회귀를 실행한다.

### Commit

`feat: add readable seeded rival candidate policy`

---

## Task 3 / PR-A2 — 플레이어 가설 snapshot·결정적 summary

### Files

- Create: `data/combat/combat_hypothesis_poc.json`
- Create: `src/ui/opponent_hypothesis_panel.gd`
- Create: `scenes/ui/opponent_hypothesis_panel.tscn`
- Create: `src/combat/combat_review_summary_builder.gd`
- Create: `tests/verify_combat_hypothesis.gd`
- Create: `tests/verify_combat_review_summary.gd`
- Modify: `src/combat/combat_board_preview.gd`
- Modify: 관련 UI·전투 문서

### Contract

가설 ID:

```text
approach / quick_attack / heavy_prepare / response_or_recover / ultimate / none
```

- commit 직전 snapshot한다.
- `none`은 “기록한 가설 없음”으로만 표시한다.
- 시스템이 가설을 추정하지 않는다.
- summary는 `result`, player plan snapshot, hypothesis snapshot, state before만 소비한다.
- 우선 cause code: `clash > interrupted > defense > direction > range > resource > position > order`.
- 판정 엔진을 호출하거나 피해를 재계산하지 않는다.

### Verification

- 가설 선택·초기화·미선택 보존.
- 합·중단·방어·회피·필중·사거리 fixture의 cause code.
- summary input mutation 0.

### Commits

- `feat: record player opponent hypotheses`
- `feat: derive deterministic combat review summaries`

---

## Task 4 / PR-A3 — 복기 UI·접근성·기술 closeout

### Files

- Create: `src/ui/combat_review_panel.gd`
- Create: `scenes/ui/combat_review_panel.tscn`
- Modify: `src/combat/combat_board_preview.gd`
- Create: `tests/verify_combat_review_ui.gd`
- Modify: 실행 스크립트·UI spec·QA 문서·상태 문서

### UI hierarchy

```text
내 가설
상대 실제 행동
결정적 수·원인
전후 거리
다음 검토 차원
[상세 기록] [다음 묶음 또는 재시작]
```

- 상세 로그는 기존 `CombatLogPanel`만 소유한다.
- 계속 전에는 다음 묶음 입력을 잠근다.
- 전투 종료에서도 복기를 먼저 읽고 재시작으로 이동한다.
- 모션 감소·즉시 완료·키보드에서도 동일한 text 정보를 제공한다.
- AI score·candidate trace·정답 카드는 표시하지 않는다.

### Verification

```bash
python -m unittest tests.test_project_governance -v
powershell -ExecutionPolicy Bypass -File tools/verify_and_commit_combat_foundation.ps1 -NoPush
```

추가 수동 기술 확인:

- Windows 1440×900·960×640.
- 포인터·키보드.
- 모션 감소·음향 끄기.
- 가설 `none`, 합·회피·필중·중단, 전투 종료·재시작.

### Technical closeout state

```yaml
technical_implementation: PASS | PARTIAL | FAIL | BLOCKED
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
product_gate: REPEAT_POC
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

### Commit

`feat: add accessible decisive review flow`

---

## 최종 기술 완료 기준

- 활성 정본에서 old SHA·schema 16·`fixed_enemy_preview_plan`이 현재 계약으로 남지 않는다.
- 같은 공개 상태·seed는 같은 AI 선택을 만든다.
- 다른 seed도 합리 candidate pool 밖 행동을 선택하지 않는다.
- private player plan 값이 AI snapshot·trace에 없다.
- 플레이어 가설이 commit 전에 snapshot되고 미선택은 추정 없이 표시된다.
- 결정적 cause fixture가 예상 code를 반환한다.
- review UI가 판정을 재계산하지 않는다.
- 키보드·모션 감소에서 동일 정보가 제공된다.
- Governance·Godot·Windows 기술 결과가 기록된다.
- 사람 테스트 미실행을 `PASS`로 대체하지 않는다.
- T1·MVP·재미 검증 완료를 선언하지 않는다.

## Deferred research

`docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md`와 결과 템플릿은 향후 사용자 결정이 바뀔 때만 다시 활성화한다. 현재 상태는 `DEFERRED_BY_USER / DO_NOT_RUN`이다.

## Rollback

- PR-A0: schema·정본 계약 커밋만 revert.
- PR-A1: planner의 기존 공개 함수 시그니처를 유지하며 이전 정책으로 복귀.
- PR-A2: hypothesis·summary 계층 제거 시 기존 판정·로그 유지.
- PR-A3: review feature flag를 끄고 기존 `next_bundle_ready` 흐름으로 복귀.
