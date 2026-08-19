# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`
> 이 문서는 **변동 상태의 단독 책임 원본**이다. 제품 규칙 전문을 복제하지 않고 현재 상태, 검증 상태, 미완료 Gate, 다음 실행 순서를 연결한다. 후속 Decision 뒤에도 회귀가 찾아야 하는 제품·플랫폼·관찰 권위의 발견 표식은 별도 섹션으로 보존한다.
> 핵심 결투 타이밍 discovery locator: `3/3/4`. 세부 전투 규칙은 `docs/02_COMBAT_RULES.md`가 책임진다.
> live 상태 판단은 저장된 SHA를 current authority로 재사용하지 않고 매 resume/post-merge마다 GitHub `main` + exact Project Notion current truth를 다시 읽는다. Google Sheets는 2026-08-20 v4.7 사용자 작업계약에 따라 신규 기획 입력이 아니라 migration-only다.

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
current_truth_source: GITHUB_MAIN_PLUS_EXACT_PROJECT_NOTION_LIVE_READ
current_main_policy: ALWAYS_REFETCH_GITHUB_MAIN
base_remote_main_policy: ALWAYS_REFETCH_CURRENT_MAIN
live_exact_sha_authority: NONE_REFETCH_REQUIRED
active_project_pr: 165
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: 165
active_planning_parent_pr: NONE
active_approval_count: 1/10
active_decision_state: JIANGHU_JOURNEY_VERTICAL_SLICE_APPROVED
source_decision: TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01
product_gate: PARTIAL_AUTOMATED_COMPLETE
platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01
platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01
design_platforms: WINDOWS_ANDROID
platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS
windows_validation: CI_EXPORT_RUNTIME_PASS_LOCAL_NOT_RUN
android_validation: NOT_RUN
engine: Godot 4.7
runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92
latest_combat_planning_runtime: PRODUCT_VALIDATION_AUTOMATED
automated_validation: PASS
human_validation: NOT_RUN
accessibility_validation: AUTOMATED_PASS_USER_NOT_RUN
performance_validation: BASELINE_CAPTURED_RELEASE_NOT_RUN
product_implementation_authorized: false
next_package: VERTICAL_SLICE_TEXTUAL_UX_AND_CONTENT_AUTHORING
next_planning_decision: VERTICAL_SLICE_OPPONENT_ROUTE_CONTENT_DETAIL_GATE
planning_visual_next: PAUSED_UNTIL_USER_EXPLICIT_IMAGE_REQUEST
planning_visual_review: TEN_IMG_001_CHAT_EXPLORATIONS_REVIEWED_NOT_AN_ASSET
planning_visual_authority: TEN-DEC-20260808-TEN-IMG-001-VISUAL-REQUIREMENT-APPROVAL-01
planning_visual_overlay: TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01
ci_supply_chain_followup: RESOLVED_ISSUE_140
base_release_pinned: 9.4.3
base_remote_observation: CURRENT_REMOTE_REQUIRES_LIVE_REFETCH_NO_AUTOMATIC_PROJECT_ADOPTION
```

플랫폼 Adapter 구현 Gate는 여전히 제품 구현 경계로 유효하지만, 최신 사용자 지시와 `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01`에 따라 **현재 활성 작업은 구현이 아니라 Vertical Slice 텍스트 기획**이다. `product_implementation_authorized: false`를 유지한다. TEN-IMG-001은 chat exploration 뒤 사용자 지시로 추가 생성이 중단됐고 새 이미지 생성은 사용자가 다시 명시적으로 요청하기 전까지 진행하지 않는다.

이 live block에는 current main SHA를 저장하지 않는다. 새 세션·post-merge에서는 GitHub `main`, 열린 PR, exact Project Notion, current operating/entry gate를 다시 읽고 의미 상태만 판정한다. exact SHA/run ID는 아래의 명시적 역사·관측 증거로만 취급한다.

## 관측 증거 스냅샷

다음 값은 당시 확인된 **역사/관측 증거**이며 live current authority가 아니다.

```yaml
historical_project_main_at_handoff: 43841d3cc6667d821c10df75272b239f314f3df0
historical_base_main_at_handoff: 637dad32c773c56a27d44d847518580848dee493
merged_planning_checkpoint: 023385d372d127044d48afcb50e6f232ab9ffaa1
merged_pr_lineage: 84,86,87,88,89,91,92,100,101,102
product_implementation_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90
merged_product_pr: 92
evidence_source_head: 0a8bf577b936ddac5cb7130a0cc58e519ea6eff6
platform_adapter_merge_commit: 023385d372d127044d48afcb50e6f232ab9ffaa1
merged_platform_adapter_pr: 102
observed_project_main_2026_08_11: 0a9e74b09816be891b3fb1cccca5e700a9ead064
observed_base_main_2026_08_11: 315c66eea9614c284b9c11c4d522141065dfa4b0
observed_recent_canon_reconciliation_prs: 137,138,139
planning_pr_2026_08_20: 165
planning_pr_2026_08_20_base: 0e9955afe791c43255176a4e89d89cf58be9b76a
```

위 `observed_*` 값과 planning PR base도 다음 merge 뒤 자동 current가 되지 않는다. current 여부는 항상 live refetch로 다시 판정한다.

## 현재 권위와 보호 결정

- 강호 비무행·플레이어 역할·5전 감정곡선·비전투 App Flow: `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01`, `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`.
- 플랫폼 범위: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`.
- 플랫폼 Adapter 아키텍처: `TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`.
- 행동 선택 UX: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`.
- 상황 화면 구조: `TEN-DEC-20260801-SITUATION-SCREEN-01`.
- 전투 UI 정보 위계·거리·관찰 표시 오버레이: `TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01`.
- 관찰 정답 누출 방지: `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`.
- 초기 무공서 런타임 기반 권위: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`.
- 초기 무공서 UI·AI 채택 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`.
- 초기 무공서 자동 제품 검증 권위: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`.
- GUT 9.7.1 reconciliation/export boundary: `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`.
- Hera v1 live QA: `TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01`.
- 활성 Godot toolchain: `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`.
- TEN-IMG-001 exploration 권한: `TEN-DEC-20260808-TEN-IMG-001-VISUAL-REQUIREMENT-APPROVAL-01`; chat exploration은 수행됐지만 제품 자산 승격 없이 `NOT_AN_ASSET`, 추가 생성은 `PAUSED_BY_USER`다.
- CI 공급망 follow-up: Issue #140은 `RESOLVED / CLOSED_COMPLETED`이며 active 후속 작업이 아니다.
- 과거 v6 인덱스는 `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`이며 최신 Decision보다 높은 권한을 갖지 않는다.

제품 코어·전투 규칙·성장·UI·저장 의미는 해당 분야 책임 원본을 따른다. 이 문서는 그 전문을 대체하지 않는다.

## 선행 UX·앱 흐름 권위

- `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01` — Main→시작 6중4→비무행 도입→Briefing→Combat→Result/Review/Reward→Route 2노드→다음 비무→5전 완주.
- `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`.
- `TEN-DEC-20260801-SITUATION-SCREEN-01`.
- 역사 구현 표식: `runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65`.
- V6 원장: `2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.

위 신규 App Flow는 계획 권위이며 제품 구현을 허가하지 않는다. PR #65 앱 흐름 기반은 역사·호환 근거이고 현재 구현 권위는 상단 YAML의 `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`다.

## 제품 연결·성장 보호 표식

- 적 AI는 자기 명시적 loadout과 공개 상태만 사용하며 **플레이어 비공개 계획·미확정 배치·포인터는 참조하지 않는다**.
- 능력치별 무공서 권수·균등 분포·최소/최대 쿼터는 사용하지 않는다.
- 무공서·무학 사용자-facing 동기화는 exact Project Notion의 확정 기획 작업면과 해당 GitHub 권위 문서의 Decision ID를 대조한다. Google Sheets는 신규 입력이 아니라 migration-only다.

이 세 표식은 후속 플랫폼·handoff 정리로 제품 권위가 사라졌다고 오인하지 않기 위한 discovery contract다.

## 자동 제품 검증 권위

```yaml
product_gate: PARTIAL_AUTOMATED_COMPLETE
evidence_source_head: 0a8bf577b936ddac5cb7130a0cc58e519ea6eff6
workflow_run_id: 31074079068
windows_artifact_id: 8956790279
windows_export: PASS
windows_ci_runtime: PASS
scenario_matrix: 50/50 PASS
local_windows_visible_render: NOT_RUN
release_performance: NOT_RUN
human_step14: NOT_RUN
balance_validation: NOT_RUN
```

Windows CI 기준 runtime은 약 2344.67ms, peak working set은 188571648 bytes, exe+pck는 123037256 bytes였다. runner 또는 Godot 버전이 바뀌면 직접 baseline 비교를 금지한다.

이 자동 제품 증거는 Windows CI export/runtime·합성 입력·자동 접근성·성능 baseline 범위다. 로컬 visible render, 실물 입력, 접근성 사용자, Release 성능, 실제 Android, 사람 플레이를 대신하지 않는다.

## 관찰 권위

`TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`은 후속 무공·런타임·UI·AI·강호행로 Decision 뒤에도 유지된다.

관찰은 행동1수→관찰량1→적 선잠금 뒤 앞 슬롯 실제 행동 종류 직접 공개를 유지한다.

- 적은 공개 전에 현재 묶음을 잠근다.
- 공개 뒤 적 계획을 교체하지 않는다.
- 정답 카드·정확한 대응 추천·숨은 AI 가중치는 공개하지 않는다.
- 관찰 약화나 자동 비용 인상은 사람 측정과 별도 Decision 전까지 금지한다.
- `OBSERVATION_ANSWER_LEAK_RISK`: `PENDING_HUMAN_MEASUREMENT`.

## 역사적 발견·회귀 호환 표식

다음 문자열은 과거 계보와 구형 회귀의 **발견용 표식일 뿐 현행 mutable state가 아니다**.

- 초기 T0 계보: `PR #7`, `Issue #13`.
- 초기 코어 검토 상태: `CORE_REVIEW_PENDING`.
- PR #92 병합 전 관찰 승인 스냅샷: `active_planning_pr: 92`.
- 제품 병합 전 상태: `active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED`.
- 제품 병합 전 다음 Gate: `next_planning_decision: TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE`.
- 플랫폼 전용 operating-state 표식: `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED`, `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`.

현행 운영 값은 문서 상단 YAML의 `active_planning_pr`, `active_decision_state`, `next_planning_decision`을 사용한다. 제품 병합 권위는 별도 역사 증거인 `merged_product_pr: 92`, `product_implementation_merge_commit`, `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`로 유지한다.

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
  pr_137_platform_cold_start_canon: PASS
  pr_138_combat_reprice_canon: PASS
  pr_139_internal_recovery_canon: PASS
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
  - CONTINUE_VERTICAL_SLICE_PLANNING_UNDER_LATEST_USER_DIRECTION
  - VERIFY_LOCAL_WINDOWS_ANDROID_DEVICE_AND_HUMAN_GATES_WHEN_REAUTHORIZED
  - RECHECK_WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE_AFTER_PLANNING_COMPLETE
```

이 Entry Gate는 제품/플랫폼 구현 경계다. 기획 작업은 현재 사용자 지시 범위에서 계속할 수 있지만 제품 구현 권한은 아니다. TEN-IMG-001 추가 생성 `PAUSED_BY_USER`를 덮어쓰지 않는다. Android 완료, 실제 기기 완료, 사람 검증 완료를 아직 주장하면 안 된다.

## 이번 세션의 플랫폼 preflight 중단 상태

사용자가 2026-08-10에 `VERIFY_LOCAL_WINDOWS_ANDROID_DEVICE_AND_HUMAN_GATES` 작업을 나중에 다시 수행하기로 연기하고 인수인계를 우선했다. 이 이력은 역사 증거로 보존하며 현재 사용자 지시가 새로 들어오면 다시 current truth를 읽고 재판정한다.

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

이 실패는 Android 제품 실패가 아니다. `GODOT_DISCOVERY`에서 collector 구현이 중단됐으므로 플랫폼 결과는 `BLOCKED_UNVERIFIED / NOT_RUN`으로 유지한다. 위 `expected_project_head`도 당시 collector의 역사 입력값일 뿐 current authority가 아니다.

## 다음 재개 절차

플랫폼 작업을 다시 시작할 때 과거 채팅의 SHA·스크립트를 그대로 신뢰하지 않는다.

```text
1. Base 최신 main/root/open PR 재조회
2. Project 최신 main/open PR/관련 Decision 재조회
3. exact Project Notion Home·Work·Flow·Core System 재조회
4. current_entry_gate와 current_operating_state 재조회
5. live context 의미 상태와 fresh truth 차이 교정
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

Base remote `main`의 exact SHA는 이 live router에 current 값으로 저장하지 않는다. 매 resume/post-merge마다 `ALWAYS_REFETCH_CURRENT_MAIN`으로 다시 읽고, 프로젝트의 Base 적용 권위는 `docs/BASE_RULES_VERSION.md`와 `skills/PROJECT_BASE_ADAPTER.json`의 pin을 우선한다. 새 Base 기능은 별도 current-contract 검토 없이 자동 채택하지 않는다.

과거 handoff에서 관측한 Base SHA는 위 `historical_base_main_at_handoff`에 증거 스냅샷으로 보존한다.

## 먼저 읽을 것

1. `AGENTS.md`.
2. `docs/BASE_RULES_VERSION.md`와 `skills/PROJECT_BASE_ADAPTER.json`.
3. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
4. `[기획서]/00_프로젝트_허브/HANDOFF.md`.
5. `docs/planning-data/current_operating_state.json`.
6. `docs/planning-data/current_entry_gate_20260808.json`.
7. exact Project Notion의 `Project Home`, `01 · 프로젝트 전체 작업계획`, `03 · UI · 전투 Flow Map`, `08 · 핵심 시스템 · 상세`와 현재 Decision 페이지.
8. 질문별 분야 책임 원본과 실제 코드·테스트·GitHub PR metadata.

Google Sheets는 신규 기획 입력 경로로 사용하지 않으며 migration 잔존 정보를 확인해야 할 때만 보조 증거로 읽는다.

## 현재 위험·미검증

- 강호 비무행 세계·5전 감정곡선·App Flow는 `CURRENT_APPROVED_PLANNING`; 제품 구현과 사람 재미 증거는 아직 없다.
- 반복 또래 무인의 정확한 이름·성별·외형·소속·향후 대전 시점은 `REVERSIBLE_CONTENT_DETAIL`이다.
- Android export preset 및 제품 Adapter 구현은 current Entry Gate가 허용하기 전 완료로 승격하지 않는다.
- Android 실제 기기·터치·back·safe area·lifecycle·저장·성능 증거는 `NOT_RUN / BLOCKED_UNVERIFIED`다.
- Windows visible local render·실물 입력·접근성 사용자·Release 성능은 자동 제품 검증과 별개다.
- STEP 14 사람 검증은 `NOT_RUN`이다.
- `TEN-IMG-001`은 chat exploration까지 수행·검토했으나 제품 자산이 아니며 추가 생성은 사용자 지시로 `PAUSED_BY_USER`; 현재는 텍스트 정본 검토를 우선한다.
- CI 공급망 mutable/stale action-pin 후속은 Issue #140에서 `RESOLVED / CLOSED_COMPLETED`; 현재 미해결 위험이 아니다.
- `OBSERVATION_ANSWER_LEAK_RISK`는 직접 공개를 바꾸지 않은 채 사람 측정을 기다린다.
- `product_implementation_authorized: false`를 유지한다.

## 상태 표현 규칙

- 완료 증거가 없으면 `PASS`로 쓰지 않는다.
- live current state는 exact SHA를 내장하지 않고 GitHub + exact Project Notion을 다시 읽어 판정한다.
- exact SHA/run ID는 `관측 증거 스냅샷`, Decision, evidence 문서처럼 역사·관측 역할이 명확한 곳에만 둔다.
- 과거 PR/branch/Handoff가 GitHub current truth와 충돌하면 current GitHub + 현재 책임 원본을 우선하고 live router만 교정한다.
- HANDOFF는 명시적 session snapshot이므로 자동 current화하지 않는다.
- PR #82와 그 SHA는 역사 자료이지 현재 active planning PR이 아니다.
- 사용자 최신 지시로 중단된 작업은 실패로 승격하지 않고 `DEFERRED_BY_USER`와 실제 검증 ceiling을 함께 기록한다.

## LOCAL_EXECUTOR_HANDOFF_CHECKPOINT — 2026-08-12

`TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`의 로컬 실행환경 작업은 사용자의 인수인계 우선 지시로 현재 checkpoint에서 멈춘다. 실행 정본은 `tools/start_ten_paces_local_executor.ps1`이며, 이 checkpoint는 제품 구현 완료를 의미하지 않는다.

```yaml
local_executor_launcher: tools/start_ten_paces_local_executor.ps1
launcher_generation: v5
launcher_sha256_observed: db7717ad7fda58a43aaf42c930d6c27a2b70d8862db894208c3ae2a861f9db7c
windows_powershell_parser_install: PASS
dedicated_godot_4_7_1: RUNTIME_OBSERVED
higodot_godot_ai_3_1_4_http_8003_ws_9503: RUNTIME_OBSERVED
hera_exact_project_auth: RUNTIME_OBSERVED_SHARED_TOKEN_NO_SECRET_SAVED
codex_project_specific_home_login: COMPLETED_TO_INTERACTIVE_SESSION
codex_exact_project_sandbox_ready: RUNTIME_OBSERVED
IN_CODEX_FRESH_READINESS: NOT_RUN
FRESH_POWERSHELL_REPEAT_RUN: NOT_RUN
product_mutation_after_checkpoint: NOT_AUTHORIZED_BY_READINESS_EVIDENCE
```

historical PID/port/session 값은 이 문서에서 current authority로 사용하지 않는다. 새 세션은 GitHub/exact Project Notion을 먼저 다시 읽은 뒤 `IN_CODEX_FRESH_READINESS_GATE`를 수행하고, 그 Gate가 PASS일 때만 `FRESH_POWERSHELL_REPEAT_RUN_GATE`로 진행한다. 두 Gate가 끝날 때까지 launcher/process/listening-port 존재를 live readiness PASS로 승격하지 않는다.
