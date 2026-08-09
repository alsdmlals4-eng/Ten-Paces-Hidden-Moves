# Local Godot Evidence Collector Decision

- Decision ID: `TEN-DEC-20260809-LOCAL-GODOT-EVIDENCE-COLLECTOR-01`
- Status: `APPROVED_COLLECTOR_CONTRACT_PR130_EXACT_471_GUT_JUNIT_LOCAL_ACCEPTED_HERA_PENDING`
- Approval: 사용자 `그렇게하자.`
- Scope: 로컬 Windows checkout의 Godot/HiGodot(Godot AI)/GUT/Hera/Git 상태를 한 번의 PowerShell 실행으로 수집하는 **증거 전용 진단기**
- Product/runtime feature change: `NONE`

## 결정

`tools/collect_godot_live_evidence.ps1`을 프로젝트의 로컬 검증 증거 수집 진입점으로 사용한다. 이 도구의 권위는 `EVIDENCE_COLLECTION_ONLY`이며 GitHub REMOTE_CI, HiGodot persistent authoring, GUT deterministic tests, Hera live QA의 권위를 대체하지 않는다.

## 안전 계약

- tracked/persistent 프로젝트 파일을 의도적으로 수정하지 않는다.
- `git pull/reset/clean/stash/commit/checkout/switch/merge/rebase`를 수행하지 않는다.
- plugin enable/disable, `project.godot`, Scene/Resource/Script persistent authoring을 수행하지 않는다.
- 산출물은 `build/local-validation/<UTC>/`에만 쓴다.
- secret/token/authorization/api-key/password 및 URL credential을 redaction한다.
- 시작 worktree가 dirty면 Godot import/GUT/Hera smoke를 실행하지 않는다.
- Git 상태를 신뢰할 수 없으면 mutation-capable runtime checks를 fail-closed한다.
- runtime 단계 뒤에도 tracked Git 상태를 다시 확인하고 실제 content change가 생기면 이후 GUT/Hera smoke를 fail-closed한다.
- Windows/Godot stat-only metadata touch와 실제 content change를 분리한다.
- GUT는 process exit 0만으로 PASS하지 않으며 canonical `build/test-results/gut.xml`이 새로 생성되어야 `gut.status=PASS`, `gut.junit_status=PASS`가 된다.
- blocker가 있어도 JSON은 남기되 해당 blocker를 PASS로 승격하지 않는다.

## Windows collector 결함·보강 이력

### PR #122 — native argument / Git fail-open

최초 Windows 실제 실행에서 PowerShell 자동 변수 `$args` 충돌과 Git-unavailable fail-open을 발견했다. PR #122에서 helper 인수를 `$CommandArgs`로 변경하고 Git 상태 미검증 시 runtime checks를 `NOT_RUN_GIT_UNAVAILABLE_SAFETY`로 막았다.

```yaml
pr: 122
merge_main: 6bee030f00f994aedab0782f490cd93eeb7dfc5a
result: MERGED_WINDOWS_SAFE_ARGUMENT_FIX
```

### Historical wrong-version run

사용자가 isolated checkout에서 collector를 실행했으나 실제 executable은 exact 4.7.1이 아니라 Godot `4.7.stable.official.5b4e0cb0f`였다. 이 실행은 GUT exit 0 이력을 남겼지만 exact-4.7.1 acceptance에는 사용하지 않았다. 또한 native stderr warning과 final Git-state 해석 결함을 노출했다.

```yaml
actual_godot_version: 4.7.stable.official.5b4e0cb0f
expected_local_acceptance_version: 4.7.1
gut_exit_code: 0
acceptance: HISTORICAL_NON_ACCEPTANCE_VERSION
```

### PR #127 — exact 4.7.1 / native stderr / post-runtime safety

PR #127은 TDD로 다음을 수정했다.

- exact `Godot_v4.7.1-stable_win64.exe`를 broad `Godot_v4.7*.exe`보다 먼저 탐색한다.
- local acceptance target prefix를 `4.7.1.`로 명시하고 mismatch는 fail-closed한다.
- Windows PowerShell native stderr는 `$ErrorActionPreference="Continue"` 구간에서 수집하고 실제 `$LASTEXITCODE`로 성공/실패를 판정한다.
- Godot 단계 후 tracked Git 상태를 재검사한다.
- Godot가 실제 tracked content를 dirty하게 만들면 GUT을 `GUT_RUN_BLOCKED_POST_GODOT_DIRTY_WORKTREE`로 막는다.
- Hera smoke 직전에도 runtime Git clean 상태를 재검사한다.
- `godot.import_parse`를 blocker 목록에 포함한다.

```yaml
pr: 127
validated_exact_head: 38e849dcd3eab610618b798597c0b62a80e16a62
merge_main: 0f34d5543ee946a06bd2ad0bb9e86f7b4e3920c5
result: MERGED_EXACT_471_POSTCHECK_HARDENING
```

### PR #129 — stat-only metadata vs actual content

Exact 4.7.1 import가 Windows/Godot의 stat-only `.import` touch를 만들 수 있으나 `git diff`상 실제 내용 변화가 없다는 로컬 증거를 기준으로, collector는 porcelain/stat 표시와 실제 tracked/staged/untracked content state를 분리한다. 실제 content change는 계속 fail-closed한다.

```yaml
pr: 129
merge_main: 5233ec87a5aa5ef5d64280b8abe8d26c4c16c5e2
result: MERGED_CONTENT_CLEAN_STAT_ONLY_RECONCILIATION
```

### PR #130 — GUT JUnit acceptance gate

사용자 exact 4.7.1 실행에서 GUT 2/2 tests, 10 assertions, exit 0이었지만 `Could not create export file res://build/test-results/gut.xml` 경고와 XML 부재를 발견했다. canonical hosted GUT workflow는 JUnit directory 준비와 `gut.xml` 존재를 필수로 요구하므로 local collector도 같은 기준으로 TDD 보강했다.

PR #130은:

- `build/test-results`를 실행 전에 준비한다.
- stale ignored `gut.xml`을 제거한다.
- `-gconfig=res://.gutconfig.json`을 명시한다.
- test execution과 JUnit status를 분리한다.
- XML이 없으면 `GUT_JUNIT_EXPORT_NOT_FOUND`로 fail-closed한다.
- 성공한 `gut.xml`을 timestamped evidence directory로 복사한다.

```yaml
pr: 130
validated_exact_head: 79e1c0171df4a1733c46b2e150c303dc9251b499
merge_main: 1ecfb77eca6df0731c74f89ffe6d5dd16c6466d6
result: MERGED_GUT_JUNIT_ACCEPTANCE_GATE
```

## 2026-08-10 exact 4.7.1 local rerun — accepted

사용자가 PR #130 merged main을 fresh isolated checkout으로 clone하고 exact Godot 4.7.1을 명시해 collector를 재실행한 전체 PowerShell transcript를 제공했다.

Canonical evidence record:

`docs/planning-data/local_godot_471_gut_junit_acceptance_20260810.json`

```yaml
checkout: C:/Users/user/AppData/Local/Temp/ten-paces-pr130-gut-junit-20260810-002755
head: 1ecfb77eca6df0731c74f89ffe6d5dd16c6466d6
origin_main: 1ecfb77eca6df0731c74f89ffe6d5dd16c6466d6
initial_worktree: CLEAN
sync_status: LOCAL_SYNC_CURRENT
godot_version: 4.7.1.stable.official.a13da4feb
godot_status: PASS
godot_import_parse: PASS
gut_version: 9.7.1
gut_status: PASS
gut_test_execution_status: PASS
gut_junit_status: PASS
canonical_gut_xml_exists: true
evidence_gut_xml_exists: true
final_working_tree_content_clean: true
final_porcelain_clean: false
stat_only_status_possible: true
hera_cli: HERA_CLI_NOT_FOUND_OR_PATH_UNSET
collector_status: COMPLETE_WITH_BLOCKERS
core_result: PASS
```

PowerShell transcript에 보인 두 번의 `else` 오류는 사용자가 interactive paste에서 `if { ... }`를 먼저 실행한 뒤 `else`를 별도 명령으로 입력해 발생한 표시용 wrapper 오류다. 그 전에 collector 자체가 완료되었고, JSON-derived Godot/GUT/JUnit 결과와 `gut.xml` existence가 모두 PASS/True로 출력되었으므로 core acceptance를 낮추지 않는다.

## 현재 claim ceiling

```yaml
collector_pr130_merged: true
hardened_collector_local_rerun: PASS
local_git_initial_clean_current: PASS_USER_LOCAL_COMMAND_TRANSCRIPT
local_godot_4_7_1_import_parse: PASS_USER_LOCAL_COMMAND_TRANSCRIPT
local_gut_9_7_1_test_execution_under_4_7_1: PASS_USER_LOCAL_COMMAND_TRANSCRIPT
local_gut_9_7_1_junit_under_4_7_1: PASS_USER_LOCAL_COMMAND_TRANSCRIPT
local_gut_evidence_xml_present: PASS_USER_LOCAL_COMMAND_TRANSCRIPT
local_content_clean_after_runtime: PASS_USER_LOCAL_COMMAND_TRANSCRIPT
hera_cli_pair: HERA_CLI_ADDON_PAIR_UNVERIFIED
hera_status: NOT_RUN
hera_smoke_skip_game: NOT_RUN
hera_phase_source_delta: NOT_RUN
```

Exact Godot 4.7.1 import/parse + GUT/JUnit 로컬 gate는 닫혔다. `collector_status=COMPLETE_WITH_BLOCKERS`는 Hera CLI가 아직 없기 때문이며 Godot/GUT/JUnit core PASS를 무효화하지 않는다.

## 다음 실제 Gate

1. Hera official Windows v1.0.0 CLI archive SHA-256을 검증한다.
2. `hera version`이 exact `1.0.0`인지 확인한다.
3. exact Ten Paces editor target, localhost/shared-token을 secret redaction 조건으로 확인한다.
4. tracked source pre-Hera snapshot을 기록한다.
5. `hera status`와 `hera smoke --skip-game`을 수행한다.
6. post-Hera tracked source delta가 `NONE`인지 확인한다.
7. Hera acceptance 완료 전에는 Hera live-QA PASS를 주장하지 않는다.

## Active toolchain 관계

현행 toolchain Decision은 `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`이다.

- Godot AI / HiGodot `3.1.3`: `SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY`
- GUT `9.7.1`: `DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY`
- Hera Agent Godot `1.0.0`: `LIVE_QA_AND_OBSERVABILITY_ONLY`, persistent mutation `FORBIDDEN`

collector acceptance는 이 역할을 변경하지 않으며 product implementation authorization도 부여하지 않는다.
