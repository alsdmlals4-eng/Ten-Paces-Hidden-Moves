---
contract_name: PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION
contract_version: '4.5'
status: ACTIVE_BASE_CURRENT_MAIN_THIN_ADAPTER_GODOT_DELIVERY_CONTRACT
revision: '2026-08-11-r2'
current_binding_decision: TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01
execution_scope_guard: INSTRUCTION_DOCUMENT_UPDATE_ONLY_UNLESS_EXPLICIT_FUTURE_EXECUTION_REQUEST
planning_phase_policy: GPT_CHAT_PLANNING_COMPLETE_BEFORE_POWERSHELL_CODEX_GODOT_BUILD
planning_completion_trigger: USER_EXPLICIT_PLANNING_COMPLETE_DECLARATION
base_repository: https://github.com/alsdmlals4-eng/Base
base_snapshot_observed_when_v4_5_written: 7ce3fb64fa6303c5da6c7fc27c979f7233b761ac
base_snapshot_policy: ALWAYS_REFETCH_CURRENT_MAIN_BEFORE_WORK
adapter_policy: THIN_ADAPTER_DO_NOT_DUPLICATE_BASE_CANON
project_repository: "https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves"
project_local_path: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"
canonical_local_checkout: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"
godot_project_path: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"
project_google_sheet: "https://docs.google.com/spreadsheets/d/1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0/edit?gid=0#gid=0"
decision_ledger_source: "02_현재_확정결정"
unresolved_items_source: "04_누락_충돌_감사"
image_review_sheet_tab_or_range: "72_이미지검수_승인로그"
source_uploaded_sha256: 3f898b7e2749a2e1900e9df48183f02d4fbc735fd0e80297f28bb09317144de4
project_bound_body_sha256: 0cc7943594d78824d6b3390232f61f12b8199d2f9f3b8817bf9953ed5aa90061
core_gates:
  - EXTERNAL_PROCESS_OVERLAY_AUTHORITY_BOUNDARY
  - PLAYER_EXPERIENCE_EVIDENCE_GATE
  - FULL_SHA_ACTION_SUPPLY_CHAIN_GATE
  - OPEN_DRAFT_PR_FULL_INVENTORY_GATE
  - PROJECT_SOURCE_BCP_PROPOSAL_GATE
  - PARTIAL_SKILL_ABSORPTION_GATE
  - FUNCTION_LEVEL_VALIDITY_CLASSIFICATION_GATE
  - USER_ACTION_REQUIRED_LAST_GATE
normative_body_parts:
  - docs/contracts/integrated-work-v4.5-r2/part-01.md
  - docs/contracts/integrated-work-v4.5-r2/part-02.md
  - docs/contracts/integrated-work-v4.5-r2/part-03.md
  - docs/contracts/integrated-work-v4.5-r2/part-04.md
  - docs/contracts/integrated-work-v4.5-r2/part-05.md
  - docs/contracts/integrated-work-v4.5-r2/part-06.md
---

# 프로젝트 총기획·검수·구현·병합·로컬 실행 통합 작업지시문 v4.5 r2 — 십보강호 정본 진입점

이 파일은 `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`로 승인된 **현행 프로젝트 통합 작업계약의 stable-path 정본 진입점**이다.

업로드된 `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`의 정책 본문은 프로젝트 식별자·로컬/Godot 경로·Google Sheet 라우팅·GitHub 조회 정책만 십보강호에 바인딩했다. 템플릿의 다른 프로젝트 식별자는 current authority가 아니다.

전체 normative body는 위 `normative_body_parts` 6개를 **목록 순서대로 바이트 결합한 내용**이다. 결합 SHA-256은 `0cc7943594d78824d6b3390232f61f12b8199d2f9f3b8817bf9953ed5aa90061`이어야 한다. 이 해시가 맞지 않으면 `CANON_CONFLICT / BLOCKED_UNVERIFIED`로 처리한다. 이 진입 파일과 body part가 충돌하면 body part 재조립 해시와 binding Decision을 함께 검토하며 임의 해석하지 않는다.

## 현재 프로젝트 바인딩

```yaml
project_repository: "https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves"
project_default_branch: main
project_local_path: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"
canonical_local_checkout: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"
godot_project_path: "C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves"
project_google_sheet: "https://docs.google.com/spreadsheets/d/1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0/edit?gid=0#gid=0"
decision_ledger_source: "02_현재_확정결정"
unresolved_items_source: "04_누락_충돌_감사"
image_review_sheet_tab_or_range: "72_이미지검수_승인로그"
```

## Base snapshot 의미

v4.5 r2 원문 작성 시 관측값은 역사 증거일 뿐 current Base 권위가 아니다.

```yaml
base_snapshot_observed_when_v4_5_written: 7ce3fb64fa6303c5da6c7fc27c979f7233b761ac
meaning: HISTORICAL_OBSERVATION_ONLY
use_as_permanent_authority: false
base_snapshot_policy: ALWAYS_REFETCH_CURRENT_MAIN_BEFORE_WORK
```

## 현행 핵심 Gate 발견 표식

다음 표식은 cold-start discovery를 위한 요약이며 세부 절차는 normative body가 책임진다.

```text
GPT_CHAT_PLANNING_COMPLETE_BEFORE_POWERSHELL_CODEX_GODOT_BUILD
EXTERNAL_PROCESS_OVERLAY_AUTHORITY_BOUNDARY
PLAYER_EXPERIENCE_EVIDENCE_GATE
FULL_SHA_ACTION_SUPPLY_CHAIN_GATE
OPEN_DRAFT_PR_FULL_INVENTORY_GATE
PROJECT_SOURCE_BCP_PROPOSAL_GATE
PARTIAL_SKILL_ABSORPTION_GATE
FUNCTION_LEVEL_VALIDITY_CLASSIFICATION_GATE
USER_ACTION_REQUIRED_LAST_GATE
```

v4.3 바인딩 Decision과 JSON은 GUT 채택 당시의 역사·회귀 증거로 보존하며 current operating authority로 사용하지 않는다.
