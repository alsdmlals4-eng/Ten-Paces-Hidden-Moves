# Local Godot Evidence Collector Decision

- Decision ID: `TEN-DEC-20260809-LOCAL-GODOT-EVIDENCE-COLLECTOR-01`
- Status: `APPROVED_COLLECTOR_CONTRACT_PR127_HARDENED_EXACT_471_RERUN_PENDING`
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
- **runtime 단계 뒤에도 tracked Git 상태를 다시 확인**하고 dirty가 생기면 이후 GUT/Hera smoke를 fail-closed한다.
- blocker가 있어도 JSON은 남기되 PASS로 승격하지 않는다.

## Windows collector 결함 이력

### PR #122 — native argument / Git fail-open

최초 Windows 실제 실행에서 PowerShell 자동 변수 `$args` 충돌과 Git-unavailable fail-open을 발견했다. PR #122에서 helper 인수를 `$CommandArgs`로 변경하고 Git 상태 미검증 시 runtime checks를 `NOT_RUN_GIT_UNAVAILABLE_SAFETY`로 막았다.

```yaml
pr: 122
merge_main: 6bee030f00f994aedab0782f490cd93eeb7dfc5a
result: MERGED_WINDOWS_SAFE_ARGUMENT_FIX
```

### clean current-main run and uploaded fresh evidence

사용자가 새 isolated checkout에서 collector를 실행했고 초기 콘솔은 clean/current Git, GUT PASS, Godot import FAIL, Hera CLI unresolved를 보고했다. 이후 실제 산출물 3개를 업로드해 다음이 확정됐다.

```yaml
checkout: C:/Users/user/AppData/Local/Temp/ten-paces-live-validation-20260809-213134
head: f0d85bd81981e608a43979ed0e5dc7a8763bd15f
initial_git: CLEAN_CURRENT
actual_godot_executable: C:/Users/user/Downloads/Godot_v4.7-stable_win64.exe/Godot_v4.7-stable_win64.exe
actual_godot_version: 4.7.stable.official.5b4e0cb0f
expected_local_acceptance_version: 4.7.1
import_log: WARNING_45_OBJECTDB_INSTANCES_LEAKED_AT_EXIT_ONLY
collector_import_exit_code: -1
gut_exit_code: 0
post_run_tracked_state: DIRTY_TRACKED_IMPORT_METADATA
hera_cli: NOT_FOUND
```

업로드된 `godot-import-parse.txt`에는 fatal parse/import error가 아니라 ObjectDB leak warning 한 줄만 있었다. 따라서 기존 `import FAIL`은 프로젝트 결함으로 확정하지 않는다.

또 JSON은 final short status에 다수의 tracked `.import` 수정이 있는데 `final_git.working_tree_clean=true`를 유지하고 있었다. 이 모순은 collector가 초기 clean 값을 복사한 뒤 final clean을 재계산하지 않은 결함이다.

### PR #127 — exact 4.7.1 / native stderr / post-runtime safety

PR #127은 TDD로 다음을 수정했다.

- exact `Godot_v4.7.1-stable_win64.exe`를 broad `Godot_v4.7*.exe`보다 먼저 탐색한다.
- local acceptance target prefix를 `4.7.1.`로 명시하고 mismatch는 fail-closed한다.
- Windows PowerShell native stderr는 `$ErrorActionPreference="Continue"` 구간에서 수집하고 실제 `$LASTEXITCODE`로 성공/실패를 판정한다.
- Godot 단계 후 tracked Git 상태를 재검사한다.
- Godot가 tracked files를 dirty하게 만들면 GUT을 `GUT_RUN_BLOCKED_POST_GODOT_DIRTY_WORKTREE`로 막는다.
- Hera smoke 직전에도 runtime Git clean 상태를 재검사한다.
- final Git cleanliness를 실제 porcelain 결과로 재계산한다.
- `godot.import_parse`를 blocker 목록에 포함한다.

```yaml
pr: 127
validated_exact_head: 38e849dcd3eab610618b798597c0b62a80e16a62
merge_main: 0f34d5543ee946a06bd2ad0bb9e86f7b4e3920c5
changed_files:
  - tools/collect_godot_live_evidence.ps1
  - tests/test_local_godot_evidence_collector_contract.py
result: MERGED_EXACT_471_POSTCHECK_HARDENING
local_hardened_rerun: NOT_RUN
```

Ready 재검증에서 PR Validation, collector contract tests, PowerShell parser, Project Base Adapter, Full Validation, Active Toolchain, Windows Product Gate의 Godot 4.7.1 import/export/product validation이 모두 성공했다.

## 현재 claim ceiling

이전 GUT exit 0은 실제 실행 이력으로 보존하지만 Godot 4.7 stable에서 수행됐다. 따라서 exact 4.7.1 local acceptance PASS로 사용하지 않는다.

```yaml
collector_pr127_merged: true
hardened_collector_local_rerun: NOT_RUN
local_git_initial_clean_current_historical: PASS_USER_LOCAL_FILE_READBACK
local_godot_4_7_execution: HISTORICAL_NON_ACCEPTANCE_VERSION
local_godot_4_7_1_import_parse: NOT_RUN
local_gut_exit0_under_4_7: HISTORICAL_PASS_GODOT_4_7_REVALIDATION_REQUIRED
local_gut_acceptance_under_4_7_1: BLOCKED_REQUIRES_EXACT_GODOT_4_7_1_RERUN
hera_cli_pair: HERA_CLI_ADDON_PAIR_UNVERIFIED
hera_status: NOT_RUN
hera_smoke_skip_game: NOT_RUN
hera_phase_source_delta: NOT_RUN
```

## 다음 실제 Gate

1. **새 fresh clean clone**에서 merged PR #127 collector를 사용한다.
2. exact Godot 4.7.1 executable을 명시하거나 collector exact discovery로 확인한다.
3. `godot-version.txt`가 `4.7.1.` prefix인지 확인한다.
4. import/parse 결과와 post-runtime Git cleanliness를 확인한다.
5. post-Godot clean일 때만 GUT 9.7.1 결과를 acceptance evidence로 사용한다.
6. 그 다음 Hera exact v1.0.0 CLI SHA/version → status → pre snapshot → smoke `--skip-game` → post delta `NONE` 순서로 검증한다.
7. 실제 실행한 PASS만 GitHub/Sheet에 승격한다.

## Active toolchain 관계

현행 toolchain Decision은 `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`이다.

- Godot AI / HiGodot `3.1.3`: `SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY`
- GUT `9.7.1`: `DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY`
- Hera Agent Godot `1.0.0`: `LIVE_QA_AND_OBSERVABILITY_ONLY`, persistent mutation `FORBIDDEN`

collector hardening은 이 역할을 변경하지 않는다.
