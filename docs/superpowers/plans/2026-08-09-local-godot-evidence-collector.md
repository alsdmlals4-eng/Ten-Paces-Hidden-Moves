# Local Godot Evidence Collector Implementation Plan

> Decision: `TEN-DEC-20260809-LOCAL-GODOT-EVIDENCE-COLLECTOR-01`
> Work mode: BUILD → REVIEW
> Goal: 사용자의 dirty Windows checkout을 자동 변경하지 않으면서, 로컬 Godot/HiGodot/GUT/Hera/Git 증거를 한 번에 수집한다.

## Existing Solution First

- 기존 `tools/run_combat_board.ps1`의 Godot executable discovery 패턴을 재사용한다.
- 과거 PR #108 Windows/WSL2 validation pack은 로컬 CI 대체 목적이므로 직접 재활성화하지 않는다. PowerShell/Windows 처리 패턴만 참고한다.
- GUT은 기존 `.gutconfig.json`과 `res://addons/gut/gut_cmdln.gd`를 사용한다.
- 출력은 기존 `.gitignore`의 `build/` 경계를 재사용한다.

## TDD

### RED

`tests/test_local_godot_evidence_collector_contract.py`에서 다음을 먼저 요구한다.

- collector 파일 존재
- destructive/sync Git 명령 부재
- 명시적 blocker 상태
- Godot/GUT/Hera/project.godot evidence 필드
- secret redaction
- `build/local-validation` JSON output
- dirty-worktree safety skip

PR Validation #1955는 collector 미존재 때문에 의도적으로 실패했다.

### GREEN

최소 구현:

- `tools/collect_godot_live_evidence.ps1`
- PR Validation에서 Python contract test + PowerShell parser 수행
- dirty 상태에서는 Godot import/GUT/Hera smoke를 실행하지 않음
- clean 상태에서만 해당 runtime checks 실행

## Acceptance Criteria

1. PowerShell parser PASS.
2. collector contract tests PASS.
3. 기존 프로젝트 governance/contract tests regression 없음.
4. collector source에 pull/reset/clean/stash/commit/checkout/switch/merge/rebase 없음.
5. project/addon/runtime persistent write 없음.
6. evidence file은 `build/local-validation/` 아래만 생성.
7. user-local blockers를 PASS로 오인하지 않음.
8. PR exact-head checks와 review thread 0 뒤에만 merge.
9. 병합 뒤 merged main readback + Sheet same Decision ID sync.

## Local handoff after merge

사용자 checkout이 dirty하므로 normal pull은 금지한다. 새 script만 remote main에서 TEMP로 읽어 실행한다.

```powershell
Set-Location "C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves"
git fetch --prune origin

git show origin/main:tools/collect_godot_live_evidence.ps1 |
  Set-Content -Encoding UTF8 "$env:TEMP\collect_godot_live_evidence.ps1"

& "$env:TEMP\collect_godot_live_evidence.ps1" `
  -ProjectPath "C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves"
```

Expected current dirty-mode behavior: static/plugin/Git/tool discovery evidence is collected; Godot import/GUT/Hera smoke are safely deferred until local changes are reconciled.
