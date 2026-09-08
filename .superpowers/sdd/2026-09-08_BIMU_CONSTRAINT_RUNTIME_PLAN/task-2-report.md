# Task 2 — 비무 제약 RunState·engine 연결

## 기준·작업 전 문제

- 기준 SHA: `e2b34d1b14b9942fe58b3d4e1263081ad43cd0d1`.
- Branch: `codex/bimu-constraint-runtime-20260908`.
- Work Mode: BUILD. Skill / Mode: `combat-implementation-handoff` / build; `ten-paces-verification` / contract-check, runtime-validation, regression, evidence-report.
- 순수 모델은 있었으나 실제 run, retry, bridge, engine에 consumer가 없었다.
- 현재 AGENTS, Base version, integrated contract, Active Context, registry/router, 두 project skill, 승인 Decision, Task1 interfaces와 실제 runtime owner를 fresh-read했다. Router의 일반 validator locator는 프로젝트에 없어 adapter의 실제 `python tools/check_project_operating_system.py --root .`로 확인: `project operating system: PASS`, exit 0.
- 기존 import/capture/uid/controller plan dirt는 보존했고 해당 파일을 stage하지 않았다.

## 조사·비교 및 구조

`CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE`. 같은 승인 패키지의 `docs/operations/2026-09-08_BIMU_CONSTRAINT_RUNTIME_PLAN.md` intro에 기록된 10사례 비교 재사용과 2026-09-08 Hades/GoW/Godot official refresh를 적용한다. 새 의미·새 수치·새 벤치마크 주장은 없다. 실제 초기 상태, 무공 registry, AI 잠금, panel preview와 native commit 진입점을 대조해 FEASIBLE로 판정했다.

- RunState가 pending 선택과 `duel_index/run_seed/enemy_candidate_id`에 묶인 frozen receipt를 소유한다. BRIEFING→COMBAT에서 재검증 후 snapshot보다 먼저 freeze한다.
- Retry snapshot은 receipt identity와 원래 frozen receipt를 progression mutation 전에 검증한다. 재도전은 같은 receipt, 새 비무/실패 종료/새 run은 초기화. 기존 receipt 없는 빈 선택 snapshot 호환은 보존한다. 디스크 저장 schema는 추가하지 않았다.
- Bridge의 마지막 optional `bimu_receipt: Dictionary = {}`는 기존 호출을 보존한다. 선택은 actual loadout/registry/상대 ID로 재검증하고 supplied `valid` flag를 신뢰하지 않는다. mastery는 registry configure 전, stats/resource는 기존 초기 state와 candidate stats binding 뒤에 overlay한다.
- engine이 canonical `cards_by_id` 및 player-owned card IDs로 봉인한다. placement.card_id와 definition.id 양쪽을 검사하므로 source/category/manual_id/span 위조가 실제 금지 ID를 숨기지 못한다. preview와 resolve_bundle, direct resolve_martial_card가 같은 이유를 사용한다.
- bundle 거부는 `rejected=true`, `failure_reason=BIMU_CONSTRAINT_FORBIDDEN_ACTION`, `constraint_reasons`, 동일 state 복사, 빈 resolved/presentation events를 반환한다. metrics accumulation 및 적 계획 생성 전에 반환한다.
- Shell은 frozen receipt를 실제 bridge에 전달한다. 기존 action_timing_panel 429–437의 preview는 이미 host.resolution_engine을 소비한다.

## TDD 증거

공통 실행 명령, 작업 디렉터리는 이 worktree:

```powershell
& 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://tests/verify_bimu_constraint_runtime.gd
```

1. 제품 변경 전 RED: exit 1, `Missing run lifecycle and engine constraint integration`.
2. 구현 후 첫 실행은 `resources reach engine` 실패. 조사 결과 기존 엔진은 HUD current를 그대로 쓰지 않고 maximum minus start_penalties로 초기화한다. fixture를 실제 `start_penalties` consumer로 고쳐 감소된 current+1 및 cap을 확인했다. 승인 resource 의미는 바꾸지 않았다.
3. 모든 seal을 actual registry로 확인하는 확장 검사는 starter 4종에 recovery 기술이 없어 `real card selector reaches CST_TECH_RECOVERY_SEAL` 실패. fixture를 전체 actual manual registry/mastery10으로 확장했고 회복 봉인을 포함한 모든 selector 경로를 확인했다.
4. 자체 검토에서 base board `combat_board_preview.gd:1051–1067`가 cached complete 뒤 commit count/presentation을 먼저 바꾸고 resolver의 rejected 결과를 별도로 검사하지 않음을 확인했다. 첫 주입 fixture는 slot assignment가 없어 기존 complete gate에 막혀 거짓 양성이었다. actual 3-slot assignments와 stale resource validity를 넣고 fixture가 complete/unlocked임을 assert해 교정했다.
5. 수정된 native commit 회귀 RED: bridge guard가 없으면 exit 1, `commit guard rejects before presentation and time mutation`.
6. 최소 bridge `_on_progress_requested` override로 즉시 engine preview 재검증을 super commit 앞에 추가. GREEN: `BIMU_CONSTRAINT_RUNTIME_OK`, exit 0. base-wide 변경 없음.

## 검증 결과

다음 각 script를 동일 명령의 `--script res://tests/<name>`으로 한 번 scoped regression 실행했다. 전부 exit 0, Godot script/error/leak warning 없음.

| Script | 관찰 결과 |
|---|---|
| verify_bimu_constraint_model.gd | BIMU_CONSTRAINT_MODEL_OK cases=45 |
| verify_bimu_constraint_runtime.gd | BIMU_CONSTRAINT_RUNTIME_OK |
| verify_vertical_slice_run_state.gd | VERTICAL_SLICE_RUN_STATE_VERIFY_OK |
| verify_vertical_slice_failure_retry.gd | VERTICAL_SLICE_FAILURE_RETRY_VERIFY_OK |
| verify_vertical_slice_opponent_runtime_binding.gd | VERTICAL_SLICE_OPPONENT_RUNTIME_BINDING_VERIFY_OK |
| verify_vertical_slice_combat_bridge.gd | VERTICAL_SLICE_COMBAT_BRIDGE_VERIFY_OK |
| verify_vertical_slice_opponent_shell_binding.gd | VERTICAL_SLICE_OPPONENT_SHELL_BINDING_VERIFY_OK |
| verify_vertical_slice_setup_briefing.gd | VERTICAL_SLICE_SETUP_BRIEFING_VERIFY_OK |
| verify_ten_duel_campaign.gd | TEN_DUEL_CAMPAIGN_STATE_OK; synthetic terminal results |
| probe_sequential_ten_duel_campaign.gd | SEQUENTIAL_DUEL/SEQUENTIAL_CAMPAIGN_SUMMARY; exit 0, real resolver/public AI campaign |

마지막 native commit guard 추가 뒤 영향 검증만 재실행했다: runtime, combat_bridge, review_result 모두 exit 0; `VERTICAL_SLICE_REVIEW_RESULT_VERIFY_OK` 확인.

집중 테스트는 pending copy/invalid atomicity, frozen identity, malformed retry rejection before progression, same retry, next duel/new run/zero choice, forged definition each seal, direct martial rejection, prelocked enemy plan preservation, all four enemy overlays in real configured engine, registry mastery unlock, source catalog unchanged, repeated state/bind no accumulation, actual shell receipt handoff, forged valid flag bridge rejection, native stale commit guard를 포함한다.

`git diff --check -- <owned files>` exit 0. Git의 기존 LF→CRLF 안내만 있었고 whitespace 오류는 없다.

## 다음 UI task 인터페이스·사용 예

```gdscript
run_state.validate_bimu_constraints(selection) # valid/errors/spent/disclosed effects, no mutation
run_state.select_bimu_constraints(selection) # BRIEFING only, bool; [] valid
run_state.get_pending_bimu_constraints() # deep Array copy
run_state.get_frozen_bimu_receipt() # deep Dictionary copy; empty before freeze
run_state.advance() # briefing confirmation freezes
resolution_engine.get_action_lock_reason(card_id) # Korean reason or empty; actual owned registry lookup
resolution_engine.get_bimu_receipt() # validated normalized model receipt
```

UI는 9종 model options를 표시하고 RunState validation/engine reason을 소비한다. 수치·봉인 규칙을 UI에서 재계산하지 않는다. `get_vertical_slice_loadout_snapshot()`은 원래 enemy mastery와 `effective_enemy_mastery_by_manual`을 모두 제공한다. 반복 bind에는 원래 mastery를 공급해 +2 누적을 피한다. `get_bimu_enemy_mastery(original_masteries)`는 모델의 copy overlay다.

## 5회 자체 적대 검토·학습

1. 정본/승인: 9종/0–2/3점/1강화·current duel만 연결. reward/save/AI 정보/거리/3-3-4/asset 내용 변경 없음.
2. lifecycle/거부 원자성: pending copy, freeze-before-snapshot, wrong-duel restore before progression mutation, retry/new duel/reset 회귀 확인.
3. 실제 diff/untouched consumer: registry normalized source와 canonical ID 검사, panel host engine preview 확인. base board stale readiness 문제를 실제 RED로 검출해 bridge scope에서 교정.
4. 실제 실행/반례: HUD initialization fixture와 absent recovery fixture, vacuous slot fixture를 교정. 초기화 API와 actual card/slot 상태를 테스트하는 재사용 가능한 회귀로 보존. prelocked AI plan/metrics no mutation 확인.
5. 장기 적합성/비용/clean exit: 순수 모델 재사용, UI 계산 금지, optional compatibility argument, per-engine copy overlay, 기존 큰 RunState/board 구조는 재작성하지 않음. 마지막 focused tests 및 scoped regression 통과, 추가 finding 없음.

## 변경 파일·미검증

- `src/run/vertical_slice_run_state.gd`
- `src/run/vertical_slice_metrics_combat_resolution_engine.gd`
- `src/run/vertical_slice_combat_bridge.gd`
- `src/run/vertical_slice_shell.gd` (frozen receipt handoff only)
- `tests/verify_bimu_constraint_runtime.gd`
- 이 report.

Task3 선택 화면/카드 봉인 이유 표시/포커스·scroll 최적화는 아직 구현하지 않았다. Windows visible/Human/Android/accessibility-user/release 성능은 NOT_RUN. 전체 Python/GUT/CI/remote integration은 controller Task4 범위이며 이 보고서는 11종 scoped Godot scripts의 기계 evidence다. 원본 assets/import/capture/uid와 controller plan은 건드리지 않았다. UI가 engine rejected 값을 별도 소비하는 다른 직접 호출 경로를 새로 만들 경우, presentation/time advance 전에 rejected 처리를 유지해야 한다.
