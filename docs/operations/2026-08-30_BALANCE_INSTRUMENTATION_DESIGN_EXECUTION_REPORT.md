# Balance Instrumentation Design Execution Report

~~~yaml
report_id: TEN-EXEC-20260830-BALANCE-INSTRUMENTATION-DESIGN-01
decision: TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
baseline_origin_main: 75168849691e3965e7d665dcb1af97485756e6cf
branch: codex/balance-instrumentation-contract-20260830
work_mode: PLAN
implementation_status: NOT_STARTED_WRITTEN_SPEC_REVIEW_REQUIRED
publication_policy: source_only
execution_date: 2026-08-30
user_approval: "권장안대로 진행해; godot에 기획안들 전부 다 구현될 때까지 멈추지마"
skill_modes:
  - ten-paces-hidden-moves-workflow-router / validated routing
  - ten-paces-game-design / balance-review
  - ten-paces-verification / contract-check
  - managing-design-documents / source-only publication discipline
  - auditing-canonical-reference-freshness / consumer and derived-owner review
  - running-adversarial-review-and-refinement / five full-scope loops
  - hera-godot:live-editor / runtime-session isolation
~~~

## 작업 전 문제

PR #273으로 후보별 runtime personality binding은 실제 `VerticalSliceMetricsCombatResolutionEngine`에 연결되어 있었지만, current owners 일부는 이를 아직 handoff-ready / runtime-not-run으로 적고 있었다. 또한 후보·시작 무공·공개 정책·AI seed 조합의 실제 resolver 결과를 재현·비교하는 계측기는 없었다. 이 상태에서 수치를 바꾸거나 별도 규칙 복제기를 만들면, 제품과 다른 숫자 또는 근거 없는 밸런스 판정을 만들 위험이 있었다.

## 조사·비교 결과

| 대상 | 관찰 | 결론 |
| --- | --- | --- |
| 현 main | `75168849691e3965e7d665dcb1af97485756e6cf`를 fresh fetch/readback했고 branch와 merge-base가 일치했다. | 기준선 drift 없음. |
| 현재 데이터 | opponent catalog 15명, starter catalog 6개, 선택 수 4개다. | `15 × C(6,4) × 3 × 5 = 3,375` scenario가 현재 source와 일치한다. |
| 실제 runtime | binding adapter, metrics engine, martial-loadout setup, public history, `ai_decision_seed`가 실제 GDScript에 존재한다. | 별도 규칙을 쓰지 않고 engine-direct harness가 가능하다. |
| validation surface | `src/validation/`에는 기존 non-shipping validator가 있고, `data/validation/`과 이번 runner 이름은 아직 없다. | validation-only 파일을 같은 경계에 추가해 player-facing startup과 분리한다. |
| 공식 Godot 근거 | Godot command-line docs는 `--headless` / standalone script 흐름을, RNG docs는 독립 seed/state 개념을 설명한다. | 현재 script-based verifier와 existing `ai_decision_seed`를 활용하는 것이 타당하다. 이 문서는 실제 harness 실행의 증거는 아니다. |

외부 source relevance는 material Godot 실행방식 판단에만 적용했다. 게임의 규칙·수치·UX 의미는 repository canon이 owner이므로 외부 사례를 새 정본으로 채택하지 않았다.

## 채택한 구조와 이유

`TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01`은 다음 A안을 채택한다.

~~~text
actual current resolver
  + 15 candidates
  + every legal 4-of-6 starter loadout
  + 3 public-only player policies
  + 5 explicit AI seeds
  + opening_no_route
  = deterministic 3,375 single-duel rows
~~~

이는 Route/보상/성장까지 자동화하는 campaign simulator를 보류하고, Python으로 combat rule을 복제하는 안을 거절한다. v1은 수치 변경, balance PASS, 자동 튜닝, hidden plan/AI trace 기록, save/UI/asset/Android 변경을 모두 제외한다. 각 scenario가 새 engine/planner/state를 만들고, 결과는 actual resolver가 생성한 public outcome만 정규화한다.

## 실제 준비 결과

- current Decision: `docs/decisions/2026-08-30_BALANCE_INSTRUMENTATION_CONTRACT_DECISION.md`
- 구현 전 written specification: `docs/superpowers/specs/2026-08-30-balance-instrumentation-design.md`
- mutable owner: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` 및 `docs/planning-data/current_user_planning_status.json`
- stale GDD correction: `docs/design/PROJECT_AI_PRODUCTION_SPEC.md`가 #273 binding implementation과 balance simulation `NOT_RUN`을 분리해 기록한다.
- regression guards: current-discovery, human-GDD profile, PC-slice gate tests가 새 Decision/spec/status와 구현된 #273 사실을 고정한다.

새 validation code, scenario JSON, report, CI artifact, game data, combat rule, scene, asset, project setting은 아직 만들거나 바꾸지 않았다. PDF는 `source_only` policy에 따라 새 source-only change로 재발행하지 않았다.

## 사용 예

다음 구현 패키지의 intended local command shape는 다음과 같다. 실제 파일과 command는 written-spec review 후 implementation plan에서 확정한다.

~~~text
Godot --headless --path <exact-worktree> --script tests/run_vertical_slice_balance_instrumentation.gd -- --output <temporary-report.json>
~~~

동일 exact code/data/matrix 입력을 두 번 실행해 byte-identical report인지 검증한다. report가 결과 차이를 보일 때에도, 그것은 별도 data Decision과 Human/player 검증의 입력일 뿐 자동 수치 변경 명령이 아니다.

## 다섯 차례 적대 검토

| Loop | 공격한 범위 | finding / 교정 | 결과 |
| --- | --- | --- | --- |
| 1 | current authority, exact main, GDD truth | GDD가 #273 구현을 `handoff-ready`로 잘못 표기했다. PR #273 implementation/readback과 balance `NOT_RUN`을 분리해 정정했다. | MUST_FIX 해결 |
| 2 | scenario source, arithmetic, long-term scope | candidate 15, starter 6, `C(6,4)=15`, policy 3, seed 5를 current source와 교차 확인했다. campaign/route 자동화는 v1 범위를 넘는다. | v1 3,375 유지, campaign DEFER |
| 3 | actual engine feasibility, isolation, determinism | 실제 binding/configure/loadout/initial-state/resolve/public-history/seed API를 읽었다. scenario 간 fresh engine requirement와 byte-identical output requirement를 명세에 추가·확정했다. | FEASIBLE, implementation RED tests 필요 |
| 4 | public-information boundary, untouched consumers | hidden player plan, pointer, target preview, observation answer, planner trace가 existing regression surface에서 이미 구분됨을 확인했다. 새 policy/report의 금지 목록·sentinel regression을 명세화했고 gameplay coupling search는 empty였다. | boundary 보호 |
| 5 | evidence ceiling, validation cost, derived docs | existing Godot headless baseline 2건은 exit 0이었고 Python/contract checks도 green이었다. 새 harness result는 아직 없으며 source-only policy상 PDF를 재발행하지 않는다. unrelated live editor sessions 2개는 read-only discovery만 하고 건드리지 않았다. | automated baseline only; no false completion |

`CLEAN_REVIEW_EXIT`은 **written-spec document state에 한정해** reached했다: stale fact, scope, source arithmetic, actual engine seam, privacy boundary, derived owner, validation checks를 다시 읽어 unresolved document finding이 없다. 그러나 product package closeout은 아니다. 사용자 written-spec review와 RED-first implementation plan/handoff가 남아 있으므로 runtime implementation, MACHINE_VERIFIED balance report, Windows-visible, Human/player, Android, accessibility, release evidence는 모두 미완료다.

## 검증 증거

| 검증 | 결과 | 증명하는 범위 |
| --- | --- | --- |
| `python -m unittest tests.test_human_game_blueprint_profile tests.test_current_discovery_contract tests.test_pc_first_vertical_slice_implementation_gate tests.test_base_shared_skill_adapter -v` | 29 PASS | current owner/state/GDD/profile/gate contracts |
| `python tests/check_canonical_combat_docs.py` | PASS | combat document map consistency |
| `python tools/check_project_operating_system.py` | PASS | project operating contract |
| `git diff --check` | PASS | whitespace errors 없음 |
| `verify_vertical_slice_opponent_runtime_binding.gd` via Godot 4.7.1 `--headless` | exit 0 | existing candidate runtime binding baseline |
| `verify_ai_rival_tendency.gd` via Godot 4.7.1 `--headless` | exit 0 | existing public-history/seed/privacy baseline |

직접 `python tests/test_current_discovery_contract.py`로 실행한 초기 시도는 Python module path 때문에 `ModuleNotFoundError: No module named 'tests'`였다. source/test 결함으로 취급하지 않고 module invocation으로 바로잡아 위 29 PASS를 재확인했다.

## 자동화·학습 반영

현재 discovery, human-GDD profile, PC-slice gate regression에 새 Decision/spec/status를 연결했다. 후속 harness는 current catalog를 정렬해 읽고 scenario list를 손으로 중복하지 않도록 명세화했다. 동일 프로젝트에서 candidate·starter catalog가 바뀌면 coverage/matrix validation이 먼저 실패해야 한다.

## 미검증·남은 위험

1. 사용자의 written-spec review가 아직 필요하다. 그 전에는 implementation plan 또는 Godot validation-code mutation을 시작하지 않는다.
2. 3,375 scenario의 실제 실행 시간·report 용량·CI artifact route는 코드가 없으므로 `NOT_RUN`이다.
3. 결과 분포, 난이도, 재미, 공정성, accessibility, Windows visible, Android device, release performance는 어떤 PASS도 없다.
4. live Hera discovery에는 Ten-Paces editor가 없었다. 다른 두 project editor session은 분리 상태를 확인했을 뿐 변경하지 않았다.

## Sources

- [Godot command-line documentation](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html), accessed 2026-08-30; headless script feasibility only.
- [Godot random-number generation documentation](https://docs.godotengine.org/en/4.7/tutorials/math/random_number_generation.html), accessed 2026-08-30; existing explicit seed rationale only.
