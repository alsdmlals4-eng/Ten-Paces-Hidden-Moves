---
contract_name: PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION
contract_version: '4.5'
status: ACTIVE_BASE_CURRENT_MAIN_THIN_ADAPTER_GODOT_DELIVERY_CONTRACT
revision: '2026-08-11-r2'
execution_scope_guard: INSTRUCTION_DOCUMENT_UPDATE_ONLY_UNLESS_EXPLICIT_FUTURE_EXECUTION_REQUEST
planning_phase_policy: GPT_CHAT_PLANNING_COMPLETE_BEFORE_POWERSHELL_CODEX_GODOT_BUILD
planning_completion_trigger: USER_EXPLICIT_PLANNING_COMPLETE_DECLARATION
grill_me_approval_batch_max: 10
grill_me_batch_close_policy: SYNC_CANON_AND_SHEET_THEN_PLANNING_PR_REVIEW_ADVERSARIAL_LOOP
numeric_detail_policy: GPT_RECOMMENDED_WITH_BENCHMARK_AND_TUNING_RANGE
planning_conflict_policy: GRILL_ME_MANDATORY_USER_APPROVAL
current_conversation_merge_policy: RECOMMENDED_AUTO_APPROVAL_WITHIN_ALREADY_APPROVED_SCOPE
open_draft_pr_inventory_required: true
tdd_required_every_task: true
powershell_codex_default_command: "codex.cmd -a never -s workspace-write"
powershell_manual_approval_prompt_max: 2
powershell_session_policy: EPHEMERAL_CLOSE_AND_FRESH_START_EACH_EXECUTION_BLOCK
user_action_blocker_policy: GPT_SOLVES_WHEN_POSSIBLE_ELSE_REQUEST_EXACT_USER_ACTION_AT_END
bcp_project_source_policy: PROPOSAL_FIRST_NO_ACTIVE_BASE_RULE_MUTATION_UNTIL_SEPARATELY_APPROVED_IMPLEMENTATION
skill_absorption_policy: PARTIAL_ABSORPTION_ALLOWED_WITH_FUNCTION_LEVEL_CLASSIFICATION
language: ko-KR
base_repository: https://github.com/alsdmlals4-eng/Base
base_snapshot_observed_when_v4_5_written: 7ce3fb64fa6303c5da6c7fc27c979f7233b761ac
base_snapshot_policy: ALWAYS_REFETCH_CURRENT_MAIN_BEFORE_WORK
base_repository_review_policy: RECURSIVE_INVENTORY_THEN_RELEVANCE_DRIVEN_DEEP_READ
adapter_policy: THIN_ADAPTER_DO_NOT_DUPLICATE_BASE_CANON
usage: >
  최신 Base의 PLAN→BUILD→REVIEW, Registry 기반 최소 Skill 라우팅, Existing Solution First,
  승인 Decision 재사용, EXTERNAL_PROCESS_OVERLAY, BCP-020 플레이어 경험 증거 Gate,
  on-demand Codex, HiGodot/GUT/Hera 역할 분리, public REMOTE_CI, Windows/Android 공용 코어,
  Visual Requirement/Asset Vault, exact validation target PR Gate, merged-main readback,
  사용자 로컬 Fetch/Pull까지 하나의 증거 기반 생명주기로 수행한다.
core_gates:
  - CURRENT_BASE_MAIN_REFETCH_AND_AUTHORITY_RECOVERY
  - BASE_REPOSITORY_WIDE_INVENTORY_AND_RELEVANCE_DRIVEN_DEEP_READ
  - BASE_SKILL_REGISTRY_AND_WORK_MODE_ROUTING
  - THIN_ADAPTER_NO_BASE_CANON_DUPLICATION
  - EXTERNAL_PROCESS_OVERLAY_AUTHORITY_BOUNDARY
  - PROJECT_GITHUB_AND_GOOGLE_SHEET_WHOLE_STATE_RECOVERY
  - ENTRY_STATE_RECONCILIATION_BLOCKING_GATE
  - WHOLE_PROJECT_AUDIT_FIRST
  - PLANNING_FIRST
  - GPT_CHAT_PLANNING_COMPLETE_BEFORE_LOCAL_BUILD_GATE
  - GAME_DETAIL_PLANNING_STRUCTURE_IMPROVEMENT_FIRST_GATE
  - CORE_FUN_GOAL_AND_SYSTEM_ALIGNMENT_GATE
  - BENCHMARK_AND_INDUSTRY_COMPARISON_GATE
  - EXISTING_SOLUTION_FIRST
  - PREVIOUS_CONTRACT_AND_STRENGTH_PRESERVATION
  - CORE_REQUIREMENT_TRACEABILITY
  - GRILL_ME_CONFLICT_APPROVAL_GATE
  - TEN_DECISION_MAX_BATCH_AND_EARLY_CHECKPOINT_GATE
  - IMMEDIATE_CANON_AND_SHEET_DECISION_SYNC
  - PLAYER_EXPERIENCE_EVIDENCE_GATE
  - FIRST_SESSION_REPRESENTATIVE_EXPERIENCE_GATE
  - DECISION_SCREEN_COMPREHENSION_GATE
  - MINIGAME_NARRATIVE_FUNCTION_GATE_WHEN_APPLICABLE
  - VISUAL_REQUIREMENT_DELETE_TEST_GATE
  - PROJECT_LOCAL_ASSET_VAULT_PROMOTION_GATE
  - LOCAL_GODOT_REFERENCE_LIBRARY_GATE
  - SHARED_AUDIO_VAULT_FIRST_AND_PROVENANCE_GATE
  - ASSET_PROVENANCE_AND_GODOT_IMPORT_GATE
  - HIGODOT_SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY
  - GUT_FOR_GODOT_4_7_X_FORMAL_TEST_AUTHORITY_WHEN_ADOPTED
  - HERA_LIVE_QA_AND_ZERO_SOURCE_DELTA_GATE
  - TEST_FIRST_EVERY_TASK
  - WINDOWS_ANDROID_SHARED_CORE_GATE
  - BUILD_SIZE_AND_PERCEIVED_QUALITY_GATE
  - RUNNABLE_BY_USER_ONE_CLICK_PROJECT_PLAY_GATE
  - ZERO_BUDGET_PUBLIC_REMOTE_CI_GATE
  - ACTIONS_RISK_TIER_AND_SINGLE_CI_GATE
  - FULL_SHA_ACTION_SUPPLY_CHAIN_GATE
  - ON_DEMAND_CODEX_HANDOFF
  - ADVERSARIAL_MULTI_PASS_REVIEW
  - EVIDENCE_BEFORE_COMPLETION
  - EXACT_VALIDATION_TARGET_AND_STRICT_UP_TO_DATE_PR_GATE
  - APPROVED_ITEM_INHERITS_MERGE_AUTHORITY
  - OPEN_DRAFT_PR_FULL_INVENTORY_GATE
  - POWERSHELL_CODEX_MAX_TWO_USER_APPROVAL_GATE
  - POWERSHELL_FRESH_SESSION_RESTART_GATE
  - MERGED_MAIN_READBACK
  - PROJECT_SOURCE_BCP_PROPOSAL_GATE
  - PARTIAL_SKILL_ABSORPTION_GATE
  - FUNCTION_LEVEL_VALIDITY_CLASSIFICATION_GATE
  - USER_ACTION_REQUIRED_LAST_GATE
  - OPTIONAL_SKILL_CREATION_CONSOLIDATION_FIRST
  - BASE_CHANGE_PROPOSAL_PROMOTION_GATE
  - SAFE_LOCAL_FAST_FORWARD_ONLY_SYNC
  - GODOT_CLEAN_MAIN_RUNTIME_GATE
---

# 프로젝트 총기획·검수·구현·병합·로컬 실행 통합 작업지시문 v4.5

> **십보강호 GitHub 프로젝트 바인딩 정본** — 업로드된 `2026-08-11-r2` 원문(SHA-256 `3f898b7e2749a2e1900e9df48183f02d4fbc735fd0e80297f28bb09317144de4`)을 기준으로, Section 4의 프로젝트 식별자·로컬/Godot 경로·Google Sheet 라우팅·GitHub visibility/required-check 조회 정책만 십보강호에 바인딩했다. 정책 본문과 Gate 의미는 원문을 보존한다.

## 0. v4.5의 역할 — Base 복제본이 아니라 프로젝트 Thin Adapter

v4.5는 v4.4의 프로젝트 고유 요구·경로·안전 경계를 보존하면서, Base가 이미 소유하는 세부 절차를 이 파일에 다시 복사하지 않는다.

**핵심 원칙**

```text
이 파일이 Base current main의 운영 절차와 충돌
→ Base current authority가 우선

이 파일이 프로젝트 고유 값·경로·보호 요구·명시 승인과 관련
→ 이 파일과 프로젝트 정본이 우선

외부 process framework가 실행 절차를 추가
→ EXTERNAL_PROCESS_OVERLAY로만 합성
→ 프로젝트/Base 정본 권한은 획득하지 않음
```

v4.4에서 관찰했던 Base 구조·Skill 수·Action pin·릴리스 상태는 역사적 증거다.
v4.5는 그것을 현재 사실로 하드코딩하지 않는다.

현재 v4.5 작성 시점에 관찰한 Base `main`:

```yaml
base_main_observed:
  sha: 7ce3fb64fa6303c5da6c7fc27c979f7233b761ac
  meaning: HISTORICAL_OBSERVATION_ONLY
  use_as_permanent_authority: false
```

매 작업 시작 시 실제 Base `main`을 다시 조회한다.

### 0.1 지시 범위 경계 — 문서 작성과 실제 실행을 분리

이 작업지시문을 작성·갱신하는 요청에서는 **지시문 범위를 넘어 실제 저장소·PR·Base·Godot·PowerShell·Codex 작업을 실행하지 않는다.**

```yaml
instruction_authoring_request:
  may_edit_instruction_document: true
  may_research_and_compare: true
  may_inspect_attached_or_explicitly_requested_sources: true
  may_execute_project_build_or_repo_mutation: false
  may_merge_or_close_prs: false
  may_run_powershell_codex_godot: false
```

실제 실행은 사용자가 별도의 실행 요청을 하거나, 이 계약의 실행 단계에 명시적으로 진입했을 때만 허용한다.

### 0.2 프로젝트 작업 순서 — 절대 순서

프로젝트의 정상 작업 순서는 다음 세 단계다.

```text
PHASE A — GPT CHAT PLANNING
1. 게임 세부기획서 작업구조 개선
2. 기획 작업
3. 필요한 이미지 생성·검토
4. Grill Me로 기획 충돌 승인
5. 주요 승인 Decision을 GitHub 정본·계획 데이터·연결 Google Sheet에 즉시 동기화
6. 최대 10건 승인 배치마다 planning/document PR 검수·적대적 검토·필요시 병합
7. 사용자와 함께 기획 전체를 닫음

USER GATE
→ 사용자가 명시적으로 “기획 완료” 선언

PHASE B — FINAL PLANNING REVIEW
8. 전체 기획 정본 재조회
9. 기능 단위 분해
10. 이미 반영됨 / 현재에도 유효 / 충돌·구형 분류
11. 벤치마킹·현업 비교
12. 작업순서·의존성·보호범위 최종 확정
13. 적대적 검토·브레인스토밍·Superpowers 검증
14. 구현 패키지 Definition of Ready 닫기

PHASE C — POWERSHELL / CODEX / GODOT BUILD
15. PowerShell에서 Codex 실행
16. HiGodot/GUT/Hera 역할 경계에 따라 구현·테스트·QA
17. PR·exact validation target·ci-gate·적대적 검토
18. 승인 범위 안이면 자동 병합
19. merged-main readback
20. 사용자 로컬 Fetch/Pull 및 Godot Project Play
```

**중요:** PHASE A/B가 끝나기 전에는 PowerShell/Codex/Godot persistent implementation을 시작하지 않는다.
기획 중 10건 승인 배치 병합은 기획 정본·Decision·문서 변경을 닫는 것이며, Godot BUILD 시작 승인이 아니다.

---

## 1. 최초 진입 순서

작업 시작 시 다음 순서로 읽는다.

```text
Base current main SHA
→ recursive tracked-file inventory 또는 동등한 전체 범위 증거
→ START_HERE.md
→ AGENTS.md
→ docs/OPERATING_MODEL.md
→ docs/WORK_MODE_AND_SKILL_ROUTING.md
→ docs/DOCUMENTATION_MAP.md
→ skills/SKILL_REGISTRY.json
→ docs/generated/BASE_ACTIVE_SKILLS.md
→ 현재 요청에 필요한 책임 원본·Skill·mode·reference·Template·Test
→ 동일 Goal의 열린·최근 병합 PR
→ 대상 프로젝트 AGENTS/START_HERE/Active Context/Decision/Sheet/정본
→ 실제 코드·데이터·Scene·Resource·자산·테스트
```

`Base를 전부 살펴본다`는 의미:

```text
전체 저장소 범위와 권한 지도를 먼저 복원
+
현재 작업과 관계 있는 owner·consumer·test·recent PR을 깊게 읽음
```

다음을 의미하지 않는다.

```text
모든 Skill 본문을 무조건 컨텍스트에 로드
모든 과거 문서를 current authority로 취급
README 몇 개만 읽고 전체 검토 완료 주장
```

활성 Skill 수는 Registry 관찰값일 뿐 설계 목표가 아니다.
Skill 수를 유지하려고 필요한 독립 Skill을 금지하거나, 숫자를 늘리기 위해 중복 Skill을 만들지 않는다.

---

## 2. 권위 순서

현재 실행의 사실·결정 권위는 다음 순서로 해석한다.

1. 사용자의 최신 명시 지시와 승인된 결정
2. 현재 환경의 system/developer/security 실행 제약
3. 프로젝트 `AGENTS.md`, 보안·엔진·데이터 계약
4. 프로젝트 Active Context와 승인된 실행 계약
5. `CURRENT_CONFIRMED_DECISIONS` 및 등록된 분야 정본
6. 실제 코드·데이터·Scene·Resource·자산·테스트
7. 프로젝트에 채택된 Base Adapter/lock/snapshot
8. Base remote current `main`
9. 외부 공식·전문가·현업·플레이어 근거
10. 과거 draft·과거 prompt·검색 캐시·추정

외부 근거는 프로젝트 정본을 대체하지 않는다.
반대로 프로젝트 문서가 실제 코드·데이터와 충돌하면 충돌을 숨기지 않는다.

---

## 3. EXTERNAL_PROCESS_OVERLAY — Superpowers 등 외부 프로세스 합성

Base current `docs/CAPABILITY_COMPOSITION_MAP.md`의 계약을 따른다.

```yaml
external_process_overlay:
  authority: EXECUTION_PROCESS_ONLY
  overlay_name_or_source:
  applied_process_skills_or_gates: []
  approval_state: NEW_APPROVAL | REUSED_APPROVAL | NOT_REQUIRED | BLOCKED
  approval_reference:
  conflict_state: NONE | OVERLAY_CONFLICT | BLOCKED_UNVERIFIED
  extra_evidence: []
```

예:

- Superpowers brainstorming
- writing-plans
- test-driven-development
- systematic-debugging
- requesting-code-review
- verification-before-completion
- 기타 system/developer가 요구하는 실행 프로세스

규칙:

1. 외부 프로세스는 **현재 실행 방법**을 강화할 수 있다.
2. 프로젝트 정본·`CURRENT_CONFIRMED_DECISIONS`를 소유하거나 덮어쓰지 않는다.
3. Base의 안전·증거·보호 Gate를 약화하지 않는다.
4. 정확히 같은 승인 범위는 `REUSED_APPROVAL`로 처리한다.
5. 기술 재검증 때문에 같은 기획 승인을 다시 요구하지 않는다.
6. 범위·코어·보호 행동·사용자 결정이 실제로 바뀌면 새 승인 Gate를 연다.
7. 외부 Skill을 읽은 것과 실제 실행한 것을 구분한다.
8. 충돌은 `OVERLAY_CONFLICT`로 기록하고 안전하게 해소할 수 없으면 `BLOCKED_UNVERIFIED`.
9. 외부 프로세스를 썼다는 이유만으로 Base Skill을 새로 만들지 않는다.

실행 보고에는 최소 다음을 남긴다.

```yaml
external_process_execution:
  overlay_name_or_source:
  read_skills: []
  actually_executed_skills_or_gates: []
  approval_reference:
  approval_reused:
  extra_evidence: []
  unresolved_overlay_conflict:
```

---

## 4. 프로젝트 입력 계약

아래 값은 v4.4의 프로젝트 고유 입력을 보존한다.
작업 시작 시 실제 환경과 대조하며, 빈 값은 자동으로 채워졌다고 추정하지 않는다.

```yaml
mode: AUTO | AUDIT_ONLY | PLAN_AND_IMPLEMENT | REVIEW_ONLY | MERGE_AND_DELIVER

base_repository: "https://github.com/alsdmlals4-eng/Base"
base_branch: "main"
base_snapshot_observed_when_v4_5_written: "7ce3fb64fa6303c5da6c7fc27c979f7233b761ac"
base_snapshot_policy: ALWAYS_REFETCH_CURRENT_MAIN_BEFORE_WORK
base_repository_review_policy: RECURSIVE_INVENTORY_THEN_RELEVANCE_DRIVEN_DEEP_READ

project_repository: "https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves"
project_default_branch: "main"

project_local_path: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"
canonical_local_checkout: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"
godot_project_path: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"

godot_executable:
godot_target_family: "4.7.x"
godot_recommended_exact_version_observed_at_v4_5_update: "4.7.1-stable"
godot_exact_version_to_verify:
godot_project_file: "project.godot"
startup_scene:
application_run_main_scene:

higodot:
  canonical_source_repository: "hi-godot/godot-ai"
  pinned_version_or_commit:
  adoption_record:
  authority: SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY
  authoring_scope:
    - scene
    - node
    - script
    - resource
    - theme
    - animation
    - signal
    - project_settings
    - input_map
    - autoload
    - godot_project_filesystem
  adoption_status: NOT_VERIFIED

gut:
  canonical_source_repository: "bitwes/Gut"
  expected_version_when_godot_4_7_x: "9.7.1"
  source_branch_or_release: "godot_4_7"
  pinned_source_commit:
  license_expected: "MIT"
  authority: DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY_WHEN_ADOPTED
  adoption_record:
  adoption_status: NOT_VERIFIED

hera_agent:
  canonical_asset_store: "https://store.godotengine.org/asset/notnull92/hera-agent-godot/"
  canonical_source:
  exact_cli_version:
  exact_addon_version:
  role: LIVE_QA_AND_OBSERVABILITY_ONLY
  persistent_source_mutation: FORBIDDEN
  transport: LOCALHOST_ONLY
  acceptance_source_delta: NONE
  adoption_status: NOT_VERIFIED

github:
  gh_cli_expected_installed: true
  gh_version:
  gh_auth_status:
  repository_visibility: public
  actions_budget_usd: 0
  default_ci_mode: REMOTE_CI
  allowed_runner_class: STANDARD_GITHUB_HOSTED
  forbidden_by_budget:
    - LARGER_RUNNER
    - GPU_RUNNER
    - PAID_CUSTOM_IMAGE
  required_check: CURRENT_APPLICABLE_REQUIRED_CHECKS_FROM_GITHUB
  merge_method_preference: squash
  local_user_handoff: FETCH_ORIGIN_THEN_PULL_ORIGIN

target_platforms:
  - Windows
  - Android

shared_core_policy: SINGLE_GAME_LOGIC_AND_DATA_CORE
platform_separation_policy: INPUT_UI_PLATFORM_INTEGRATION_AND_DELIVERY_PROFILE_ONLY
windows_export_required: true
android_export_required: true
target_resolutions: []
target_aspect_ratios: []
input_methods:
  - keyboard_mouse
  - gamepad_when_applicable
  - touch
  - android_back
accessibility_requirements: []

build_size_policy:
  objective: PRESERVE_PERCEIVED_QUALITY_WHILE_REMOVING_WASTED_BYTES
  measure_separately:
    - DOWNLOAD
    - INSTALLED
    - RUNTIME
    - PATCH
  font_policy: UNIFY_FAMILY_AND_THEME_ROLES_NOT_FORCE_SINGLE_FILE
  platform_delivery_profiles: WINDOWS_AND_ANDROID_SEPARATE

project_google_sheet: "https://docs.google.com/spreadsheets/d/1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0/edit?gid=0#gid=0"
google_sheet_required_tabs_or_ranges:
  - "00_프로젝트_허브"
  - "02_현재_확정결정"
  - "04_누락_충돌_감사"
  - "71_이미지기획_생성목록"
  - "72_이미지검수_승인로그"
  - "99_변경이력"
decision_ledger_source: "02_현재_확정결정"
unresolved_items_source: "04_누락_충돌_감사"
image_review_sheet_tab_or_range: "72_이미지검수_승인로그"
entry_state_reconciliation_required: true

project_asset_vault:
  local_root: "<project-root>/.asset-vault/"
  godot_local_projection: "res://assets/_vault_local/"
  tracked_manifest: "ASSET_MANIFEST.yml"
  approval_boundary: PROJECT_ASSET_APPROVED
  tracked_promotion_required: true

local_godot_reference_library:
  path: "C:/Users/user/Documents/GitHub/Godot_Reference"
  authority: REFERENCE_ONLY
  expected_categories:
    - Templates
    - Official_Demos
    - Plugins_Reference
    - Sandbox
    - Archive/Source_Zips
  known_reference_candidates:
    - godot-demo-projects-master
    - loading_serialization
    - gui_multiple_resolutions
    - 3d_graphics_settings
    - Global-Asset-Manager-2.0.1
    - Maaack_Game_Template_if_present

shared_audio_vault_path: "C:/Users/user/Documents/GitHub/shered audio vault"
shared_audio_vault_access: READ_ONLY_SOURCE_LIBRARY
shared_audio_vault_first: true
audio_runtime_reference_policy: COPY_APPROVED_ASSETS_INTO_RES_NOT_ABSOLUTE_PATH

current_goal:
requested_deliverables:
vertical_slice_scope:

protected_decisions: []
protected_behaviors: []
protected_files_or_assets: []
explicit_exclusions: []

planning_first: true
test_first_every_task: true
numeric_detail_policy: GPT_RECOMMENDED_WITH_EVIDENCE_AND_TUNING_RANGE
planning_conflict_policy: GRILL_ME_AND_REQUIRE_USER_APPROVAL
grill_me_approval_batch_max: 10
benchmark_policy: OFFICIAL_AND_PROFESSIONAL_RESEARCH_REQUIRED_WHEN_DECISION_RELEVANT

codex_handoff_policy: ON_DEMAND_CODEX_HANDOFF
codex_handoff_trigger: USER_REQUESTED_CODEX_HANDOFF
codex_package_definition_of_ready: REQUIRED
codex_preflight_policy: OPTIONAL_RISK_BASED
gpt_godot_preproduction_allowed: true

new_skill_policy: CONSOLIDATION_FIRST_BUT_ALLOWED_WITH_INDEPENDENT_BOUNDARY
base_promotion_policy: BCP_PROPOSAL_THEN_SEPARATE_APPROVED_IMPLEMENTATION_PR

implementation_authority: APPROVED_CANON_AND_RECOMMENDED_NON_CONFLICTING_DETAILS
merge_authority: APPROVED_ITEM_INHERITS_MERGE_AUTHORITY
merge_reapproval_required_for_same_approved_scope: false
post_merge_local_sync_authority: AUTHORIZED_AFTER_MERGE
godot_launch_authority: AUTHORIZED_AFTER_LOCAL_SYNC
```

### 4.1 경로 해석

- `project_local_path` = Git 저장소 루트.
- `godot_project_path` = 실제 `project.godot`이 존재하는 폴더.
- 둘이 같아도 정상.
- 로컬 경로는 사용자 환경 입력이며 Base 공용 정본으로 승격하지 않는다.
- `shared_audio_vault_path`의 `shered` 표기는 v4.4의 사용자 원문을 그대로 보존한다.

### 4.2 보호 입력

```text
[핵심 내용]

```

프로젝트 목적·확정 방향·필수 경험·기능·콘텐츠·금지 사항·완료 기준은 의미를 삭제하거나 약화하지 않는다.

---
