# 십보강호 세션 인수

> 이 파일은 새 채팅·새 담당자·새 에이전트가 현재 작업을 재개하기 위한 **세션 경계 스냅샷**이다. 변동 상태의 단독 책임 원본은 `ACTIVE_CONTEXT.md`이며, 이 문서보다 GitHub current truth와 `ACTIVE_CONTEXT.md`가 우선한다.

## 현재 상태

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
runtime_work_mode: REVIEW
integration_pr: 65
runtime_integration_pr: 65
project_main_at_handoff_start: 43841d3cc6667d821c10df75272b239f314f3df0
active_project_pr: NONE
active_planning_work_mode: REVIEW
active_planning_pr: NONE
active_approval_count: 1/10
active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
automated_validation: PASS
human_validation: NOT_RUN
next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION
next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
base_release_pinned: 9.4.3
base_remote_main_observed: 637dad32c773c56a27d44d847518580848dee493
product_implementation_authorized: false
```

이 handoff 자체가 병합된 뒤에는 위 `project_main_at_handoff_start`를 current main으로 오인하지 않는다. 새 세션의 첫 행동은 GitHub `main`을 다시 읽어 실제 새 SHA를 확인하는 것이다.

## 이번 세션에서 완료·검증된 것

현재 main에는 다음 완료 상태가 이미 정본화되어 있다.

- GUT v9.7.1 reconciliation 및 exact Godot 4.7.1 local GUT/JUnit acceptance.
- Hera v1.0.0 exact pair local live QA acceptance.
- HiGodot L2를 통한 product export exclusion authoring.
- HiGodot L1 readback.
- Windows release export exit 0.
- PCK regression probe exit 0.
- 승인된 GUT/tests/`.gutconfig.json` export exclusion.
- Godot AI runtime export 보존.
- PR #133 export preset 병합.
- PR #134 export boundary canon closeout 병합.
- Google Sheet 00·02·04·99의 export boundary 동기화.

승인된 exclusion 대상은 오직 다음 셋이다.

```text
addons/gut/**
tests/**
.gutconfig.json
```

다른 addon family를 임의로 제외하지 않는다.

## 이번 세션에서 중단·연기된 것

사용자는 `VERIFY_LOCAL_WINDOWS_ANDROID_DEVICE_AND_HUMAN_GATES`를 **나중에 다시 작업**하고 지금은 인수인계를 진행하도록 지시했다.

최신 local collector V2 시도:

```yaml
collector_version: V2_NO_COLLECTION_LENGTH_PROPERTY
baseline_head: 43841d3cc6667d821c10df75272b239f314f3df0
origin_main: 43841d3cc6667d821c10df75272b239f314f3df0
initial_repo_content_delta: 0
reached_phase: GODOT_DISCOVERY
status: FAIL_OR_BLOCKED_COLLECTOR
failure_class: POWERSHELL_NATIVE_CAPTURE_NULL_HANDLING_BUG
android_gate_result: NOT_RUN
windows_runtime_result_in_this_attempt: NOT_RUN
human_result: NOT_RUN
disposition: DEFERRED_BY_USER
```

오류는 collector 함수가 비어 있는 native stdout/stderr를 null-safe하게 처리하지 못해 `.Trim()` 계열 처리를 시도한 구현 문제다. **Android 제품 실패 증거가 아니다.**

V2 collector 구현은 다시 사용하지 않는다.

## 현재 Entry Gate

현재 정본은 다음을 유지한다.

```yaml
local_windows_core: PASS
local_android_device: BLOCKED_UNVERIFIED
human_validation: BLOCKED_NOT_RUN
windows_android_adapter_implementation_gate: BLOCKED_BY_ENTRY_GATE
product_implementation_authorized: false
allowed_next_actions:
  - VERIFY_LOCAL_WINDOWS_ANDROID_DEVICE_AND_HUMAN_GATES
  - RECHECK_WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
```

Android 실제 지원 완료, 실기기 완료, 사람 검증 완료를 주장하지 않는다.

## 새 세션 첫 읽기 순서

1. Base `alsdmlals4-eng/Base` 최신 root structure, latest `main`, open PR을 다시 조회한다.
2. Project `alsdmlals4-eng/Ten-Paces-Hidden-Moves` default branch, latest `main`, open PR을 다시 조회한다.
3. Google Sheet `00_프로젝트_허브`, `02_현재_확정결정`, `04_누락_충돌_감사`, `99_변경이력`을 다시 읽는다.
4. `AGENTS.md`.
5. `docs/BASE_RULES_VERSION.md`와 `skills/PROJECT_BASE_ADAPTER.json`.
6. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
7. 이 `HANDOFF.md`.
8. `docs/planning-data/current_operating_state.json`.
9. `docs/planning-data/current_entry_gate_20260808.json`.
10. 질문별 분야 책임 원본과 실제 코드·테스트·PR metadata.

과거 채팅·이 파일의 과거 SHA·로컬 temp 경로를 current truth로 간주하지 않는다.

## 플랫폼 작업 재개 시 첫 실행

사용자가 플랫폼/device/human 작업을 다시 시작하라고 하면 추가 제품 결정을 요구하지 말고 같은 승인 범위에서 다음 순서로 재개한다.

```text
fresh Base/project/Sheet/current-entry readback
→ current main과 saved handoff 차이 교정
→ null-safe local collector 재구성
→ Windows local automated runtime 재검증
→ Android SDK / export-template / ADB / connected-device preflight
→ 실제 결과 분류
→ RECHECK_WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
```

Windows PowerShell native-process capture는 V2의 직접 stream 혼합 구현 대신 다음 원칙을 사용한다.

```text
Start-Process
+ -Wait
+ -PassThru
+ RedirectStandardOutput
+ RedirectStandardError
+ 빈 파일/null을 명시적으로 empty string으로 정규화
```

collector는 repository 내용을 수정하면 안 된다.

## 자동화로 승격할 수 없는 검증

다음은 실제 수행 전 `NOT_RUN`이다.

- Windows visible local render.
- physical keyboard/mouse usability observation.
- physical gamepad.
- accessibility-user validation.
- Release-device performance judgment.
- Android actual APK/AAB install and first visible launch.
- Android touch/select/place/move/remove/confirm/cancel/inspect.
- Android back, safe area, cutout.
- Android background/foreground, pause/resume, process recreation.
- Android thermal/battery/frame-time observation.
- STEP 14 신규 플레이어 5명.

자동 제품 시나리오나 CI를 사람 검증으로 대체하지 않는다.

## Base 상태

이 handoff 준비 중 Base remote `main`은 `637dad32c773c56a27d44d847518580848dee493`까지 전진했고 BCP-2026-011의 게임 기능 L2 상세 Spec 계층이 `IMPLEMENTED` 상태로 닫혔다.

현재 프로젝트의 Base authority는 프로젝트 `docs/BASE_RULES_VERSION.md`와 `skills/PROJECT_BASE_ADAPTER.json` pin이 우선한다. remote Base의 새 기능을 이 handoff에서 자동 채택하거나 프로젝트 Gate를 변경하지 않는다.

Base에는 이미 `maintaining-project-context-and-handoff`와 `maintaining-long-running-task-continuity` owner가 있으므로 이번 작업에서 새 Handoff/Progress Skill이나 Base Change Proposal을 만들지 않는다.

## 보호 범위

이번 인수인계는 상태 정리만 한다. 다음은 변경하지 않는다.

- 제품 코어·전투 규칙·성장 의미.
- `data/`, `src/`, `scenes/`, `assets/`, `addons/`.
- `project.godot`.
- `export_presets.cfg`.
- 기존 Decision ID/승인 의미.
- current entry gate의 `product_implementation_authorized: false`.

## 주의할 stale 자료

- PR #82는 현재 active planning PR이 아니다.
- 과거 HANDOFF의 `APPROVED_PENDING_MERGE`, `active_planning_pr: 82`, `289378c...`는 역사 상태다.
- 일부 discovery/history 문서에 과거 PR #80/#82 체크포인트가 남아 있어도 **변동 상태 판단은 GitHub metadata + `ACTIVE_CONTEXT.md` + current planning JSON**을 우선한다.
- `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`는 역사 승인 인덱스다.

## 완료 후 다음 상태

이 handoff PR이 exact-head 검증과 병합을 통과하면 Google Sheet 허브와 변경이력을 post-merge main SHA로 동기화한다. 그 뒤 세션을 종료해도 새 작업자는 위 읽기 순서만으로 플랫폼 preflight를 다시 시작할 수 있어야 한다.

## LOCAL_EXECUTOR_HANDOFF_CHECKPOINT — 2026-08-12

현재 local-executor 인수인계의 Decision은 `TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`이다. 실행 정본은 `tools/start_ten_paces_local_executor.ps1`이며, 사용자 지시로 local readiness를 여기서 잠시 멈추고 프로젝트 인수인계/BCP closeout을 우선한다.

```yaml
launcher: tools/start_ten_paces_local_executor.ps1
launcher_generation: v5
launcher_sha256_observed: db7717ad7fda58a43aaf42c930d6c27a2b70d8862db894208c3ae2a861f9db7c
windows_parser_install: PASS
dedicated_godot_4_7_1: RUNTIME_OBSERVED
godot_ai_3_1_4_http_8003_ws_9503: RUNTIME_OBSERVED
hera_auth_source_observed: shared_token
hera_exact_project: RUNTIME_OBSERVED_NO_SECRET_SAVED
codex_dedicated_home_login: COMPLETED_TO_INTERACTIVE_SESSION
codex_exact_project_sandbox_ready: RUNTIME_OBSERVED
in_codex_fresh_readiness: NOT_RUN
fresh_powershell_repeat_run: NOT_RUN
```

historical PID/port/session은 current target 증거로 재사용하지 않는다. launcher 자체는 orchestration evidence이며 live readiness PASS가 아니다.

### 다음 실행 순서

```text
fresh Base/project/Sheet readback
→ IN_CODEX_FRESH_READINESS_GATE
→ exact project/CODEX_HOME/dedicated Godot/Godot AI 3.1.4 HTTP 8003 WS 9503
→ smallest read-only Godot AI MCP live call
→ Hera v1.0.0 exact-project read-only status
→ GUT 9.7.1 + pre/post repo no-new-mutation
→ OVERALL PASS일 때만 FRESH_POWERSHELL_REPEAT_RUN_GATE
→ repeat-run PASS 뒤 승인된 제품 작업 재개 여부를 current user/Entry Gate/Decision과 함께 판정
```

`IN_CODEX_FRESH_READINESS_GATE`와 `FRESH_POWERSHELL_REPEAT_RUN_GATE`는 아직 실행하지 않았으므로 `NOT_RUN` 상태를 유지한다.

### Recent applicable troubleshooting lessons

- `LRN-TEN-LOCAL-001`: editor API가 필요한 bootstrap은 standalone `--script`가 아니라 실제 headless editor의 `@tool` context를 사용한다. 상세 owner: `skills/SKILL_LEARNING_LOG.md`.
- `LRN-TEN-LOCAL-002`: Windows PowerShell 5.1의 `NativeCommandError` 포장은 native stderr의 의미와 process exit code를 분리해 판정한다.
- `LRN-TEN-LOCAL-003`: reused Hera editor 인증 불일치 시 exact-project PID를 먼저 고정하고 지원 auth source를 secret 출력 없이 검증한다.
- `LRN-TEN-LOCAL-004`: 실행 launcher는 대화 임시 산출물에 머무르지 않고 repository executable + regression contract로 저장한다.

### Base 동시 작업 안전

`BASE_PROPOSAL_CONCURRENCY_REFETCH_REQUIRED`: 다른 채팅/프로젝트가 Base BCP를 동시에 처리할 수 있다. Base proposal 작업을 재개할 때는 저장된 BCP 번호나 Registry snapshot을 신뢰하지 않고 반드시 latest Base `main` + `[수정제안서]/PROPOSAL_REGISTRY.json` + 모든 open proposal-only PR + same-goal BCP를 다시 읽는다. 다른 프로젝트의 branch/BCP/Registry entry는 수정·되돌림·재번호화하지 않고 자기 proposal delta만 처리한다.
