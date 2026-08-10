# 십보강호 활성 컨텍스트

> 이 문서는 **변동 상태의 단독 책임 원본**이다. 제품 규칙 전문을 복제하지 않고 현재 checkpoint, 검증 상태, 미완료 Gate, 다음 실행 순서만 연결한다.

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
project_main_checkpoint: 43841d3cc6667d821c10df75272b239f314f3df0
active_project_pr: NONE
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: REVIEW
active_planning_pr: NONE
active_planning_parent_pr: NONE
active_approval_count: 1/10
active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED
source_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01
next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION
next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
automated_validation: PASS
human_validation: NOT_RUN
product_implementation_authorized: false
base_release_pinned: 9.4.3
base_remote_main_observed: 637dad32c773c56a27d44d847518580848dee493
base_remote_observation: BCP_2026_011_IMPLEMENTED_NO_AUTOMATIC_PROJECT_ADOPTION
```

현재 project main은 PR #133의 HiGodot export exclusion 병합과 PR #134의 canon closeout을 포함한다. 이 문서의 `project_main_checkpoint`는 이 handoff 작업을 시작할 때의 기준 SHA이며, 이 문서 자체가 병합되면 다음 세션은 반드시 GitHub `main`을 다시 읽어 새 SHA를 우선한다.

## 현재 권위와 보호 결정

- 플랫폼 범위: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`.
- 플랫폼 Adapter 아키텍처: `TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`.
- 행동 선택 UX: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`.
- 상황 화면 구조: `TEN-DEC-20260801-SITUATION-SCREEN-01`.
- 관찰 정답 누출 방지: `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`.
- GUT 9.7.1 reconciliation/export boundary: `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`.
- Hera v1 live QA: `TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01`.
- 활성 Godot toolchain: `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`.
- 과거 v6 인덱스는 `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`이며 최신 Decision보다 높은 권한을 갖지 않는다.

제품 코어·전투 규칙·성장·UI·저장 의미는 해당 분야 책임 원본을 따른다. 이 문서는 그 전문을 대체하지 않는다.

## 완료·검증됨

```yaml
completed_verified:
  gut_9_7_1_reconciliation: PASS
  godot_4_7_1_local_gut_junit: PASS
  hera_v1_exact_pair_live_qa: PASS
  higodot_l2_export_exclusion_authoring: PASS
  higodot_l1_export_readback: PASS
  windows_product_export_regression: PASS
  pck_tooling_exclusion_probe: PASS
  pr_133_export_preset_merge: PASS
  pr_134_canon_closeout_merge: PASS
```

승인된 product export exclusion은 다음 셋뿐이다.

```text
addons/gut/**
tests/**
.gutconfig.json
```

`addons/godot_ai/runtime/game_helper.gd`를 포함한 Godot AI runtime은 export에 보존됐다. 다른 addon family exclusion은 승인되지 않았다.

## 현재 Entry Gate

`docs/planning-data/current_entry_gate_20260808.json`의 현재 의미는 다음과 같다.

```yaml
local_windows_core: PASS_GODOT_GUT_HERA_EXPORT_CORE
local_android_device: BLOCKED_UNVERIFIED
human_validation: BLOCKED_NOT_RUN
windows_android_adapter_implementation_gate: BLOCKED_BY_ENTRY_GATE
product_implementation_authorized: false
allowed_next_actions:
  - VERIFY_LOCAL_WINDOWS_ANDROID_DEVICE_AND_HUMAN_GATES
  - RECHECK_WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
```

Android 완료, 실제 기기 완료, 사람 검증 완료를 아직 주장하면 안 된다.

## 이번 세션의 플랫폼 preflight 중단 상태

사용자가 2026-08-10에 `VERIFY_LOCAL_WINDOWS_ANDROID_DEVICE_AND_HUMAN_GATES` 작업을 **나중에 다시 수행하기로 명시적으로 연기**하고 인수인계를 우선하도록 지시했다.

가장 최근 로컬 collector 시도에서 확인된 사실:

```yaml
collector_version: V2_NO_COLLECTION_LENGTH_PROPERTY
expected_project_head: 43841d3cc6667d821c10df75272b239f314f3df0
initial_repository_content_delta: 0
head_equals_origin_main: true
reached_phase: GODOT_DISCOVERY
collector_result: FAIL_OR_BLOCKED_COLLECTOR
failure_class: POWERSHELL_NATIVE_CAPTURE_NULL_HANDLING_BUG
error_summary: null stream value was trimmed/called as an object
windows_export_in_this_attempt: NOT_RUN
windows_50_scenario_runtime_in_this_attempt: NOT_RUN
android_sdk_adb_device_result: NOT_RUN
android_product_result: NOT_RUN
human_validation: NOT_RUN
user_disposition: DEFERRED_BY_USER
```

이 실패는 Android 제품 실패가 아니다. `GODOT_DISCOVERY`에서 collector 구현이 중단됐으므로 플랫폼 결과는 `BLOCKED_UNVERIFIED / NOT_RUN`으로 유지한다.

## 다음 재개 절차

플랫폼 작업을 다시 시작할 때 과거 채팅의 SHA·스크립트를 그대로 신뢰하지 않는다.

```text
1. Base 최신 main/root/open PR 재조회
2. Project 최신 main/open PR/관련 Decision 재조회
3. Google Sheet 00·02·04·99 재조회
4. current_entry_gate와 current_operating_state 재조회
5. main/Sheet/Handoff stale 여부 교정
6. V2 collector 구현은 재사용하지 않음
7. Windows PowerShell native process는 Start-Process -Wait -PassThru + stdout/stderr 분리 방식으로 null-safe 수집
8. Windows local automated runtime + Android SDK/ADB/device preflight 실행
9. 실제 결과 분류
10. RECHECK_WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
```

다음 collector에서 자동화되지 않는 항목은 계속 `NOT_RUN`으로 남긴다.

- Windows visible local render.
- physical keyboard/mouse usability observation.
- physical gamepad.
- accessibility-user validation.
- release-device performance judgment.
- Android 실제 APK/AAB install/launch, touch/back/safe-area/lifecycle/performance.
- STEP 14 신규 플레이어 5명.

## Base 관찰

Base remote `main`은 이 handoff 준비 중 `637dad32c773c56a27d44d847518580848dee493`까지 전진했고 BCP-2026-011 게임 기능 L2 상세 Spec 계층 lifecycle이 `IMPLEMENTED`로 닫혔다.

이 변화는 현재 프로젝트의 handoff owner나 Android/device/human Gate를 자동 변경하지 않는다. 프로젝트 운영 권위는 `docs/BASE_RULES_VERSION.md`와 `skills/PROJECT_BASE_ADAPTER.json`의 pin을 우선하며, 새 Base 기능의 프로젝트 적용은 별도 current-contract 검토 없이 추정하지 않는다.

## 먼저 읽을 것

1. `AGENTS.md`.
2. `docs/BASE_RULES_VERSION.md`와 `skills/PROJECT_BASE_ADAPTER.json`.
3. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
4. `[기획서]/00_프로젝트_허브/HANDOFF.md`.
5. `docs/planning-data/current_operating_state.json`.
6. `docs/planning-data/current_entry_gate_20260808.json`.
7. 질문별 분야 책임 원본과 실제 코드·테스트·GitHub PR metadata.

## 현재 위험·미검증

- Android export preset 및 제품 Adapter 구현은 current Entry Gate가 허용하기 전 완료로 승격하지 않는다.
- Android 실제 기기·터치·back·safe area·lifecycle·저장·성능 증거는 `NOT_RUN / BLOCKED_UNVERIFIED`다.
- Windows visible local render·실물 입력·접근성 사용자·Release 성능은 자동 제품 검증과 별개다.
- STEP 14 사람 검증은 `NOT_RUN`이다.
- `TEN-IMG-001` generation은 별도 미실행 상태다.
- `product_implementation_authorized: false`를 유지한다.

## 상태 표현 규칙

- 완료 증거가 없으면 `PASS`로 쓰지 않는다.
- 과거 PR/branch/Handoff가 GitHub current truth와 충돌하면 current GitHub + 현재 책임 원본을 우선하고 stale 기록을 교정한다.
- PR #82와 그 SHA는 역사 자료이지 현재 active planning PR이 아니다.
- 사용자 최신 지시로 중단된 작업은 실패로 승격하지 않고 `DEFERRED_BY_USER`와 실제 검증 ceiling을 함께 기록한다.
