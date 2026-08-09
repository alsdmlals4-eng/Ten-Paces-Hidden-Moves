# Local Godot Evidence Collector Decision

- Decision ID: `TEN-DEC-20260809-LOCAL-GODOT-EVIDENCE-COLLECTOR-01`
- Status: `APPROVED_COLLECTOR_CONTRACT_WINDOWS_SAFE_FIX_MERGED_LOCAL_REEVIDENCE_PENDING`
- Approval: 사용자 `그렇게하자.`
- Scope: 로컬 Windows checkout의 Godot/HiGodot(Godot AI)/GUT/Hera/Git 상태를 한 번의 PowerShell 실행으로 수집하는 **증거 전용 진단기**
- Product/runtime feature change: `NONE`

## 결정

`tools/collect_godot_live_evidence.ps1`을 프로젝트의 로컬 검증 증거 수집 진입점으로 사용한다.

이 도구의 권위는 `EVIDENCE_COLLECTION_ONLY`다. GitHub REMOTE_CI, HiGodot persistent authoring, GUT deterministic tests, Hera live QA의 권위를 대체하지 않는다.

### 안전 계약

- tracked/persistent 프로젝트 파일을 수정하지 않는다.
- `git pull/reset/clean/stash/commit/checkout/switch/merge/rebase`를 수행하지 않는다.
- plugin enable/disable, `project.godot`, Scene/Resource/Script persistent authoring을 수행하지 않는다.
- 진단 산출물은 이미 gitignore 대상인 `build/local-validation/<UTC>/`에만 쓴다.
- 명령 출력의 token/secret/authorization/api-key/password 및 URL credential 형태를 redaction한다.
- dirty worktree는 수집기가 복구하지 않고 `LOCAL_SYNC_BLOCKED_DIRTY_WORKTREE`로 기록한다.
- dirty worktree에서는 Godot import/parse, GUT, Hera smoke를 자동 실행하지 않고 `NOT_RUN_DIRTY_WORKTREE_SAFETY`로 기록한다. 이유는 Godot import/test가 `.gd.uid` 등 로컬 생성물을 추가할 수 있기 때문이다.
- Git 상태 자체를 신뢰할 수 없으면 Godot import/parse, GUT, Hera smoke 같은 mutation-capable 검증을 `NOT_RUN_GIT_UNAVAILABLE_SAFETY`로 fail-closed한다.
- Hera `version/status/smoke --skip-game`은 exact CLI가 확인된 경우에만 실행하며, smoke 전후 tracked fingerprint가 같을 때만 `HERA_SOURCE_DELTA_NONE`을 기록한다.
- blocker가 있어도 수집 자체가 끝났다면 JSON을 남기고 `COMPLETE_WITH_BLOCKERS`로 종료한다. blocker를 PASS로 바꾸지 않는다.

## 2026-08-09 최초 사용자 로컬 readback

사용자가 PowerShell에서 직접 제공한 관찰값:

- local branch: `main`
- local HEAD: `8315fde182f4c26669a983c8da71b2174655a823`
- observed `origin/main`: `4433ec60fcda63a5c2996398c47d840251225759`
- relation: `behind 10`
- dirty tracked files: `addons/godot_ai/plugin.cfg`, `project.godot`
- untracked `.gd.uid` files: combat/validation/test 관련 12개
- local Godot AI addon: `3.1.3`
- local GUT addon: `9.7.1`
- local Hera addon: `1.0.0`
- local `project.godot` enabled plugins: Godot AI + GUT + Hera
- local main scene: `res://scenes/combat/combat_board_preview.tscn`
- local Hera autoload evidence: `HeraGameInspector`
- Hera CLI command: `CommandNotFoundException`
- Godot executable command: `$Godot` 미설정으로 실행 증거 없음

당시 판정:

- `LOCAL_SYNC_BLOCKED_DIRTY_WORKTREE`
- `HERA_CLI_NOT_FOUND_OR_PATH_UNSET`
- `GODOT_EXECUTABLE_UNRESOLVED`
- Godot AI 3.1.3 / GUT 9.7.1 / Hera addon 1.0.0 및 plugin enable 상태는 **USER_LOCAL_COMMAND_READBACK**으로 인정한다.
- `GODOT_RUN_VALIDATED`, `GUT_LOCAL_PASS`, `HERA_LIVE_QA_PASS`는 선언하지 않는다.

## 산출물 계약

기본 출력:

- `build/local-validation/<UTC>/godot-live-evidence.json`
- `git-status.txt`, `git-status-after.txt`
- `godot-version.txt`, `godot-import-parse.txt`
- `gut.txt`
- `hera-version.txt`, `hera-status.txt`, `hera-smoke.txt`

JSON은 Git/local sync, project.godot, addon version+enabled state, Godot, GUT, Hera, blocker 목록과 collector status를 담는다.

## 2026-08-09 Windows 실제 evidence 결함 조사와 PR #122 closeout

최초 merged collector를 사용자 Windows에서 실제 실행한 결과, 사용자 환경 실패로 보면 안 되는 collector 결함 두 가지가 확인됐다.

1. PowerShell 자동 변수 `$args`와 helper formal parameter `[string[]]$Args`가 충돌해 native command argument 전달을 신뢰할 수 없었다.
2. 그 결과 Git 상태를 `available=false`로 오판한 경우에도 Godot import/GUT/Hera smoke가 fail-open될 수 있었다.

이 증거에서 `git.available=false`인데 같은 PowerShell에서 사용자가 `git`을 정상 실행했고, Godot version 자리에 `_ready()` 관련 출력이 섞였으며, Git 상태 불명인데 import/GUT가 실행된 조합은 실제 프로젝트/도구 실패가 아니라 collector 구현 결함으로 판정했다.

TDD 수정은 PR #122에서 다음 최소 범위로 제한했다.

- `Invoke-Capture` / `Git-Read` formal parameter를 `$CommandArgs`로 변경하고 `@CommandArgs`로 splatting한다.
- Git 상태가 unavailable이면 import/GUT/Hera smoke를 `NOT_RUN_GIT_UNAVAILABLE_SAFETY`로 fail-closed한다.
- stderr/version 정책 확대나 제품/runtime 기능 변경은 포함하지 않는다.

PR #122는 active toolchain 정합화 PR #123/#124 이후 current main 위에 collector+regression test 두 파일만 재구성했다.

```yaml
pr: 122
validated_exact_head: 5d4b2ebcd3603b3433c4008e06fd9ba2796fa314
merge_main: 6bee030f00f994aedab0782f490cd93eeb7dfc5a
changed_files:
  - tools/collect_godot_live_evidence.ps1
  - tests/test_local_godot_evidence_collector_contract.py
ready_revalidation:
  pr_validation: PASS_1983
  project_base_adapter: PASS_248
  full_validation: PASS_1127
  product_gate: PASS_265
review_threads: 0
result: MERGED_WINDOWS_SAFE_FIX
```

PR Validation에서 `Run local Godot evidence collector contract tests`와 `Parse PowerShell automations for code changes`가 모두 성공했다. merged main에서 collector/test blob을 다시 읽어 post-merge readback을 완료했다.

## Active toolchain과의 관계

현행 toolchain 정본은 `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`이다.

- Godot AI / HiGodot `3.1.3`: `SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY`
- GUT `9.7.1`: `DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY`
- Hera Agent Godot `1.0.0`: `LIVE_QA_AND_OBSERVABILITY_ONLY`, persistent mutation `FORBIDDEN`

collector 수정은 이 활성 상태를 바꾸지 않는다. 이전의 GUT/Hera 비활성화 rollback 방향은 `SUPERSEDED_DO_NOT_EXECUTE`다.

## 현재 claim ceiling과 다음 실제 Gate

PR #122 merge는 collector 구현의 hosted 검증 완료이지 로컬 Godot/GUT/Hera PASS가 아니다.

```yaml
fixed_collector_merged: true
local_fixed_collector_rerun: NOT_RUN
local_godot_import_parse: NOT_RUN
local_gut_clean_checkout: NOT_RUN
hera_cli_pair: HERA_CLI_ADDON_PAIR_UNVERIFIED
hera_status: NOT_RUN
hera_smoke_skip_game: NOT_RUN
hera_phase_source_delta: NOT_RUN
```

다음 로컬 순서:

1. clean isolated current-main checkout에서 fixed collector를 실행한다.
2. Git `available/current/clean`을 먼저 확인한 뒤에만 Godot import/parse와 GUT을 실행한다.
3. Hera Windows CLI archive SHA-256과 `hera version`으로 exact v1.0.0 pair를 검증한다.
4. `hera status`가 정확한 Ten Paces 프로젝트를 가리키는지 확인한다.
5. tracked source pre-Hera snapshot을 기록한다.
6. `hera smoke --skip-game`을 실행한다.
7. post-Hera snapshot과 비교해 Hera-phase tracked source delta `NONE`을 요구한다.
8. 실제 실행한 PASS만 GitHub/Sheet에 승격하고 나머지는 `NOT_RUN`/`BLOCKED_UNVERIFIED`로 유지한다.
