# Local Godot Evidence Collector Decision

- Decision ID: `TEN-DEC-20260809-LOCAL-GODOT-EVIDENCE-COLLECTOR-01`
- Status: `APPROVED_COLLECTOR_CONTRACT`
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
- Hera `version/status/smoke --skip-game`은 exact CLI가 확인된 경우에만 실행하며, smoke 전후 tracked fingerprint가 같을 때만 `HERA_SOURCE_DELTA_NONE`을 기록한다.
- blocker가 있어도 수집 자체가 끝났다면 JSON을 남기고 `COMPLETE_WITH_BLOCKERS`로 종료한다. blocker를 PASS로 바꾸지 않는다.

## 2026-08-09 사용자 로컬 readback

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

따라서 현재 판정:

- `LOCAL_SYNC_BLOCKED_DIRTY_WORKTREE`
- `HERA_CLI_NOT_FOUND_OR_PATH_UNSET`
- `GODOT_EXECUTABLE_UNRESOLVED`
- Godot AI 3.1.3 / GUT 9.7.1 / Hera addon 1.0.0 및 plugin enable 상태는 **USER_LOCAL_COMMAND_READBACK**으로 인정한다.
- `GODOT_RUN_VALIDATED`, `GUT_LOCAL_PASS`, `HERA_LIVE_QA_PASS`는 아직 선언하지 않는다.

## 산출물 계약

기본 출력:

- `build/local-validation/<UTC>/godot-live-evidence.json`
- `git-status.txt`, `git-status-after.txt`
- `godot-version.txt`, `godot-import-parse.txt`
- `gut.txt`
- `hera-version.txt`, `hera-status.txt`, `hera-smoke.txt`

JSON은 Git/local sync, project.godot, addon version+enabled state, Godot, GUT, Hera, blocker 목록과 collector status를 담는다.

## 후속

1. 이 Decision/collector PR exact-head 검증 및 병합.
2. dirty local checkout에는 pull하지 않고 `git show origin/main:tools/collect_godot_live_evidence.ps1`로 TEMP에 추출해 실행한다.
3. 생성 JSON을 검토해 Godot/Hera executable discovery와 blocker를 판정한다.
4. 사용자 로컬 변경과 `.gd.uid`의 보존/정본 반영 방식을 먼저 reconciliation한 뒤에만 safe fast-forward를 진행한다.
