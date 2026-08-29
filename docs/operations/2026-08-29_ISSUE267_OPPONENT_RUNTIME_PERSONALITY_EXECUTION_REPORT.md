# Issue #267 · 첫 5전 상대 런타임 성향 바인딩 실행 보고

```yaml
report_id: TEN-OPS-20260830-ISSUE267-OPPONENT-RUNTIME-PERSONALITY-01
issue: 267
work_mode: BUILD
baseline_main: 2d42ffbb2572c66e3eb317e129fbf00036bbcdd7
verified_runtime_head: e5631e8b0e324020fa82c36aac04882f1b250f5d
decision: TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01
implementation_contract: TEN-IMP-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01
skill_mode:
  - ten-paces-hidden-moves-workflow-router / BUILD
  - combat-implementation-handoff / BUILD
  - systematic-debugging / diagnose-before-fix
  - test-driven-development / RED-GREEN
  - auditing-canonical-reference-freshness / validate
  - running-adversarial-review-and-refinement / full-scope
  - reviewing-and-validating-project-changes / validation
  - hera-godot:live-editor / headless-editor-check
status: IMPLEMENTED_AUTOMATED_GODOT_VERIFIED_AWAITING_ISSUE267_PR
```

## 작업 전 문제

첫 5전 후보 15명은 `signature_manual_id`와 `signature_star_seed`만 전투에 전달하고 있었다. 후보의 `runtime_archetype_id`, 기초 행동 선호 순서, 최종 스테이터스 총량은 소비자가 없어 Briefing의 읽을 수 있는 습관이 실제 전투 AI와 연결되지 않았다.

## 조사·비교와 현재 출처 관련성

- 권위 순서에 따라 Issue #267, `TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01`, 구현 계약, handoff, 실제 candidate/card/bridge/resolver/planner/test 소비자를 fresh-read했다.
- 2026-08-30 현재 Godot 4.7.1 로컬 실행 환경과 [공식 JSON 문서](https://docs.godotengine.org/en/stable/classes/class_json.html)를 확인했다. `JSON.parse_string()`은 Variant를 반환하며 숫자 파싱이 float 경로를 사용할 수 있으므로, runtime binding validator는 JSON 숫자가 정수형이 아니라도 **정수값**이면 허용하고 비정수·음수·합계 불일치는 거절한다. 이것은 기존 card/JSON 소비와 호환되는 최소 조치다.
- 신규 알고리즘·외부 서비스·유료 도구·이미지·Scene 변경은 필요하지 않았다. `NO_BASE_PROMOTION`: JSON 숫자 정규화와 Godot editor import 격리는 이 저장소의 현행 data/validation 환경에 국한된 교훈이다.

## 채택한 구조와 이유

```text
locked opponent candidate
→ VerticalSliceOpponentRuntimeBinding (검증·deep copy·결정론적 stat 배분)
→ VerticalSliceCombatBridge (원자적 사전 검증)
→ fresh VerticalSliceMetricsCombatResolutionEngine
   ├─ enemy candidate_id + derived stats
   └─ per-instance CombatAiPlanner runtime profile
→ shared resolver's bounded public_resolution_history
→ 3/3/4-legal bound AI actions
```

- 다섯 reusable archetype data와 15개 후보 매핑을 data-owned로 유지해 후보별 GDScript 분기를 만들지 않았다.
- bridge는 바인딩이 거절되면 기존 snapshot과 combat state를 바꾸지 않고, 매 전투에 새 metrics engine을 만들어 이전 후보 성향·스탯이 누출되지 않게 했다.
- resolver는 묶음 완료 후 `[실행]` action만 `round_number`, `bundle_index`, `actor`, `card_id`, `category`, `outcome` 여섯 필드로 투영하고, 오래된 것부터 버려 최대 6개만 보유한다.
- planner는 바인딩이 있을 때만 profile 우선순위, legal focus bonus `+1.20/+0.60/+0.30`, 거리 3 유지 이동, 최근 공개 player 해결 기록 2개, 최대 두 행동 scheduling을 쓴다. 바인딩이 없으면 기존 global rival profile과 단일 행동 trace를 그대로 유지한다.

## 실제 구현과 복구 결과

1. `data/run/vertical_slice_opponent_archetypes.json`과 candidate adapter로 15→5 mapping, 20분모 largest-remainder stat allocation, invalid input fail-closed를 구현했다.
2. 후보 `slot3_seolha`는 기존 owner에 focus ID가 둘뿐이었고 approved plan은 정확히 셋을 요구했다. 사용자의 “필요한 승인 모두 승인·자동 복구” 범위에서 기존 `basic_move`, `basic_footwork`의 순서를 보존하고, 장풍·보법형/거리 제어 identity와 existing basic card pool에 맞는 `basic_palm`을 세 번째 legal focus로 추가했다. 이는 새 core Decision이 아니라 계약 충족을 위한 최소 `CANON_CONFLICT` 복구다.
3. JSON 숫자가 Godot에서 float Variant로 읽히는 첫 GREEN 실패를 발견했고, 정수값 검사로 수정했다. 모든 profile weight/total/stat output 검증은 계속 exact integer semantics를 보장한다.
4. shared resolver와 public AI를 연결했다. 현재 player plan, target/direction preview, hover/focus, observation answer, profile weight/focus list는 planner input·trace에 포함되지 않는다.
5. CI는 binding static contract와 Godot integration verifier를 Full Validation 및 Vertical Slice run-state workflow에 추가했다.

## 사용 예

- `slot3_seolha` 전투 시작: `range_control` profile과 total 24 derived stats가 하나의 새 engine에만 바인딩된다. 공개 거리가 2이고 legal movement만 있는 상황에서는 tile 6에서 tile 7로 후퇴해 선호 거리 3을 향한다.
- `slot4_cheongheo` 전투: 완료된 player action 중 가장 최신 두 기록만 사용한다. 현재 계획·UI 미리보기·관찰 정답은 같은 상태에 추가해도 action/trace가 변하지 않는다.
- `slot5_*` 전투: 첫 action의 실제 span을 예약한 뒤 남은 슬롯에만 서로 다른 두 번째 legal action을 배치하며, 3/3/4 boundary를 넘지 않는다.

## 검증 증거

검증 head는 `e5631e8b0e324020fa82c36aac04882f1b250f5d`이며 별도 disposable worktree에서 실행했다.

| 범주 | 수행 | 결과 |
|---|---|---|
| TDD RED | missing archetype data, missing binding API, missing public history assertions | 기대한 failure 관찰 후 최소 구현으로 GREEN |
| Static | `check_project_operating_system.py`, canonical reference freshness, skill package integrity, binding contract, canonical combat docs | PASS |
| Python | targeted discovery/governance 32개 및 전체 `test_*.py` | 32 PASS, 419 PASS |
| Godot parser | `--headless --editor --path . --quit` | exit 0; disposable worktree에서 성공. editor teardown의 plugin/resource diagnostic은 발생했으나 parse failure는 아님 |
| Affected Godot | binding/catalog/setup, public AI, resolver, prepare, ten-manual, action selection, Vertical Slice shell/bridge/route/retry/result/completion, interruption integration | 19 scripts PASS |
| Known unrelated regression | `verify_clash_guard_sure_hit.gd` | FAIL: `A 6-versus-8 clash must deal only 2 damage ... expected=28`; Task 3 전 baseline `f287cab3`에서도 동일 재현. Issue #267 범위 밖이며 본 변경의 PASS로 가리지 않음 |
| Windows-visible / Human / accessibility-user / Android device / release performance | 실제 실행하지 않음 | `NOT_RUN` |
| balance simulation | 별도 instrumentation contract 없음 | `NOT_RUN` |

## 적대적 검토와 clean exit

1. **정본·scope**: 후보/계약/실제 consumer를 대조해 decks, save, economy, Scene, asset, UI 의미 변경이 없는지 확인했다.
2. **data validity**: 5 profile·15 mapping·weight total·focus legality·positive derived stats·seed total·deep-copy를 공격했고, JSON number representation failure를 고쳤다.
3. **lifetime/rollback**: invalid binding이 bridge snapshot/state를 바꾸지 않는지, retry와 second engine이 서로 다른 binding을 유지하는지 검증했다.
4. **fairness/privacy**: execution-only 6-record projection, counter의 newest two player records, private plan/UI/observation mutation 불변성을 검증했다.
5. **rules/long-term fit**: range retreat, legal current card pool, two-slot preparation anchor, 3/3/4 non-overlap, unbound default trace를 검증했다. 기존 clash test failure는 pre-existing baseline으로 분리했다.

`MUST_FIX_REMAINING: 0` for the authorized Issue #267 implementation scope. 다음 안전 작업은 Issue #267 PR의 exact-head CI/review/merge/readback이며, 그 뒤에는 별도 승인된 balance instrumentation contract다.

## 자동화·학습 반영

- full and scoped CI workflows now invoke the binding contract and integration verifier.
- Godot editor parse가 tracked `.import` artefact를 대량 변경하는 환경이라 exact-head parse는 disposable worktree에서 실행하고, 검증 후 agent-created temporary worktree를 제거한다.
- evidence 기록 후 final full regression에서 `runtime_work_mode: BUILD`와 Issue #267 PR readback 단계는 실제 Current Context와 일치하지만, post-merge lifecycle validator와 네 개의 current-status consumer test가 과거 `REVIEW` / `REPOSITORY_ONLY_GPT_WORK` / handoff 문자열을 고정값으로 요구한 것을 발견했다. 새 BUILD 허용과 unknown mode 거절을 먼저 RED로 확인한 뒤, validator를 project work-mode enum(`PLAN` / `BUILD` / `REVIEW`)으로 좁히고 stale expectation을 현재 owner 값으로만 갱신했다. final branch validation은 Python `421 PASS`, operating-system/reference/skill/binding/combat-doc checks `PASS`, 핵심 binding/catalog/setup/AI/resolver Godot verifier `5 PASS`다.
- PR #273의 첫 remote CI readback에서 runtime path 변경에 필요한 당일 BUILD 승인 record와 one-time protected approval manifest/label이 빠진 것을 fail-closed로 확인했다. `BUILD_APPROVAL_2026-08-30.md`, exact 10-path manifest, PR-base baseline pin 및 Base-generated views로 복구했고, Base `2828a74…` contract validator를 `external-approval=true`로 재현해 GREEN을 확인했다. 이 manifest는 해당 PR 한 번에만 유효하므로 merge 뒤 별도 cleanup PR에서 immutable archive와 baseline promotion을 수행해야 한다.
- Base promotion disposition remains `NO_BASE_PROMOTION`.
