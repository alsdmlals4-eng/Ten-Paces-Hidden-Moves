# Balance Instrumentation Implementation Execution Report

~~~yaml
report_id: TEN-EXEC-20260830-BALANCE-INSTRUMENTATION-IMPLEMENTATION-01
decision: TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
baseline_origin_main: 75168849691e3965e7d665dcb1af97485756e6cf
implementation_commit: e2666380fdf335bee71703973bb0389ce90f4358
branch: codex/balance-instrumentation-contract-20260830
work_mode: BUILD
implementation_status: IMPLEMENTED_BRANCH_MACHINE_VERIFIED_HEADLESS_FULL_MATRIX_PR_PENDING
execution_date: 2026-08-30
approval_source: "user explicit: 승인"
scope: ENGINE_DIRECT_NON_SHIPPING_DETERMINISTIC_SINGLE_DUEL_V1
matrix_dimensions: "15 candidates × 15 legal starter loadouts × 3 public policies × 5 AI seeds = 3375"
full_report_sha256: 899EC5562E06EBBA2072F7601E7FD7C17AF3E96DD7F19095B52CF8478810895C
full_report_size_bytes: 2353326
windows_visible_evidence: NOT_RUN
human_player_evidence: NOT_RUN
android_device_evidence: NOT_RUN
accessibility_evidence: NOT_RUN
release_evidence: NOT_RUN
~~~

## 작업 전 문제

사용자 승인 뒤에도 첫 5전 후보와 시작 무공 조합을 실제 해결 엔진으로 일관되게 비교할 검증 소비처가 없었다. 기존 후보 binding은 실제 전투별로 동작했지만, 15개 후보·합법적인 4-of-6 시작 조합·세 공개 플레이어 정책·다섯 AI seed를 한 단일 결투 matrix로 재현하고 비교할 정규화된 결과 행은 없었다.

PDF 예시는 정본으로 승격하지 않았으며, 새 구현은 현재 repository의 후보 catalog, starter catalog, combat HUD, resolver, metrics, public-state AI만 소비한다.

## 채택한 구조와 이유

~~~text
current catalogs + matrix JSON
  -> public-only placement policy
  -> fresh VerticalSliceMetricsCombatResolutionEngine per scenario
  -> actual resolve_bundle for 3/3/4, maximum 12 rounds
  -> minimal public row (outcome, bundle count, existing 5 metrics)
  -> sorted JSON report + independent byte comparison
~~~

- `data/validation/vertical_slice_balance_instrumentation_matrix.json`이 입력 차원과 opening_no_route를 고정한다.
- `VerticalSliceBalancePublicPolicy`는 공개 tile·자원·공개 이력·허용 카드 정의만 읽는다. 미확정 계획, UI pointer/preview, observation, AI trace/weight는 읽거나 결과에 직렬화하지 않는다.
- `VerticalSliceBalanceInstrumentation`은 각 scenario마다 새 engine, planner, binding, loadout, initial state를 만들고 기존 resolver·metrics를 호출한다. 전투 공식을 Python 또는 새 계산기로 복제하지 않는다.
- `VerticalSliceBalanceReportRunner`는 성공한 모든 행을 scenario ID로 정렬하고, 전체 실행 중 하나라도 invalid면 보고서를 만들지 않는다.
- Python 검사는 combat 결과를 재계산하지 않고 coverage, fixed row schema, public-data boundary, 정렬, byte equality만 검사한다.

## 실제 구현 결과

| Surface | Result |
| --- | --- |
| Matrix contract and fail-closed scenario expansion | 15 candidates, 15 legal starter loadouts, 3 policies, 5 seeds, 3,375 scenarios |
| Public player policy | approach pressure, guarded exchange, recovery/range only |
| Resolver execution | current `VerticalSliceMetricsCombatResolutionEngine.resolve_bundle` only; 3/3/4 across at most 12 rounds |
| Row boundary | scenario/candidate/loadout/policy/seed/route/outcome/bundle count plus exactly five existing battle metrics |
| Report output | deterministic sorted UTF-8 JSON with trailing newline; 2,353,326 bytes |
| Game-facing surfaces | unchanged: scene, save/load, player-facing combat data, card values, asset, audio, Android, telemetry, auto-tuning |

## 검증 증거

| Command / check | Result | Evidence ceiling |
| --- | --- | --- |
| `verify_vertical_slice_balance_public_policy.gd` | exit 0 | public policy IDs, legal placements, private sentinel isolation |
| `verify_vertical_slice_balance_instrumentation.gd` | exit 0 | matrix dimensions, fresh candidate state, fail-closed candidate, normalized public rows |
| `verify_vertical_slice_balance_report_runner.gd` | exit 0 | sampled report ordering, count fields, deterministic serialization, privacy boundary |
| `verify_ai_rival_tendency.gd` | exit 0 | existing public-state AI regression |
| `tests/run_vertical_slice_balance_instrumentation.gd -- --output <temp-a>` | exit 0, 3,375 rows | first full actual-engine report |
| same command with independent `<temp-b>` | exit 0, 3,375 rows | independent second full actual-engine report |
| first / second full-run elapsed wall time | approximately 150s / 157s | current local validation cost; no timing threshold claim |
| `Get-FileHash -Algorithm SHA256 <temp-a>, <temp-b>` | identical `899EC556…10895C` | report bytes share one SHA-256 |
| `python tests/check_vertical_slice_balance_report.py <temp-a> <temp-b>` | `VERTICAL_SLICE_BALANCE_REPORT_CHECK_OK` | byte equality, 15×15×3×5 coverage, fixed row/metric schema, privacy tokens |

첫 전체 실행에서 public policy 반환값을 `Array[Dictionary]`로 너무 좁게 선언해 Godot runtime type error가 반복되는 결함을 발견했다. 그 실행은 보고서를 쓰지 못했으며 증거로 사용하지 않았다. 같은 실행 명령으로 시작된 PID와 command line을 확인한 뒤 그 PID만 종료하고, `Array` 경계로 고친 후 표본 회귀와 두 full run을 다시 수행했다. 다른 프로젝트의 Godot process는 건드리지 않았다.

## 자동화·학습 반영

- PowerShell에서 외부 Godot의 `$LASTEXITCODE` 전파가 신뢰되지 않은 경우가 있었으므로, 이 패키지는 `Start-Process -Wait -PassThru`의 process exit code로 headless pass/fail을 판정했다.
- direct `--headless --editor` 스캔은 추적되는 `.import` timestamp changes와 새 cache artifact를 만들 수 있다. 이후 검증은 direct headless script 실행을 우선하고, 스캔이 만든 비정본 import artifact는 source diff와 분리해 복구했다.
- JSON 수가 Godot에서 integral float로 읽히는 경계를 contract normalizer가 명시적으로 처리한다. 보고서 행은 다시 정수로 정규화한다.
- matrix source가 바뀌면 expected dimensions와 legal catalog combinations가 먼저 fail-closed하도록 했다.
- GitHub Actions `godot-headless`에는 빠른 public-policy, instrumentation, report-runner regression을 추가했다. full 3,375×2 report는 명시 runner command로 유지해 CI 비용을 숨기지 않고 independent byte evidence를 보존한다.

## 다섯 차례 적대 검토

| Loop | 공격한 범위 | finding / 교정 | 결과 |
| --- | --- | --- | --- |
| 1 | current canon, Decision, mutable owner | written-spec review pending 상태가 사용자 `승인` 및 구현 사실과 충돌했다. Decision, ACTIVE_CONTEXT, planning JSON, discovery 및 PC-slice state-consumer regressions을 branch machine evidence로 함께 전환했다. | MUST_FIX 해결 |
| 2 | matrix source and coverage | current catalog 15, starter 6의 legal 4-of-6=15, policy 3, seed 5를 실제 source와 contract test로 재검증했다. report checker는 15×15×3×5와 fixed row keys를 독립 확인한다. | clean |
| 3 | resolver, AI/public boundary, untouched regressions | new policy/instrumentation/report tests와 existing opponent binding, rival tendency, Phase 2 resolver regression을 Godot 4.7.1에서 실행했다. report checker가 private planner/UI tokens를 재귀 거부한다. | clean |
| 4 | actual full-run behavior and scenario isolation | full runner가 `Array[Dictionary]` 반환 경계를 너무 좁게 선언한 runtime type error를 드러냈다. invalid run은 폐기하고, generic Array 경계로 교정한 뒤 표본과 3,375행 독립 두 run을 다시 수행했다. | MUST_FIX 해결 |
| 5 | diff, consumer scope, cost, rollback | baseline 대비 예상 밖 경로 0, protected runtime data/scene/project/assets 변경 0을 확인했다. 한글 path quote가 allowlist false finding을 만들었으나 `core.quotePath=false` readback으로 해결했다. 두 full run은 약 150/157초, report는 temp-only다. | clean |

`CLEAN_REVIEW_EXIT`은 이 validation-only branch package에 한정해 reached했다. PR 통합 전에는 branch machine evidence이고, 통합 후에는 exact `origin/main` readback과 CI required checks가 별도로 필요하다.

## 미검증·남은 위험

1. 이 결과는 headless machine evidence다. Windows visible 화면, human/player fun·fairness·readability, Android physical device, accessibility, release performance는 아직 `NOT_RUN`이다.
2. `timeout`·win/loss 분포는 후보 수치 변경 권고가 아니다. 수치 변경은 별도 balance Decision, data change, regression, human/player 검증이 필요하다.
3. 현재 증거는 isolated branch의 exact implementation commit에 대한 것이다. PR review, required checks, merge, post-merge `origin/main` readback은 아직 수행 전이다.
4. Matrix는 명시적으로 `opening_no_route` single duel만 다룬다. Route/보상/성장/캠페인과 retry UX는 범위 밖이다.
