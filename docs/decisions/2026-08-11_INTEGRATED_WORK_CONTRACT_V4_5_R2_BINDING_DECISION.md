# Integrated Work Contract v4.5 r2 Binding Decision

```yaml
decision_id: TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01
approved_date: 2026-08-11 KST
status: CURRENT_APPROVED_PROJECT_OPERATING_CONTRACT
supersedes_current_operating_authority: TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01
canonical_document: docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
source_uploaded_file: PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md
source_uploaded_sha256: 3f898b7e2749a2e1900e9df48183f02d4fbc735fd0e80297f28bb09317144de4
project_bound_body_sha256: 0cc7943594d78824d6b3390232f61f12b8199d2f9f3b8817bf9953ed5aa90061
normative_body_reconstruction: JOIN_PART_BYTES_WITH_SINGLE_LF_SEPARATOR
project_repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
project_default_branch: main
project_local_path: C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves
godot_project_path: C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves
project_google_sheet_id: 1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0
base_snapshot_policy: ALWAYS_REFETCH_CURRENT_MAIN_BEFORE_WORK
product_implementation_authorized: false
```

## Decision

사용자의 명시 지시 `작업지시문 v4.5 r2 로 깃허브 정본도 교체해`를 승인 근거로, 프로젝트 통합 작업계약의 current authority를 **v4.5 r2**로 승격한다.

GitHub stable-path 정본 진입점은 `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`다. 전체 normative body는 `docs/contracts/integrated-work-v4.5-r2/part-01.md`부터 `part-06.md`까지의 저장 바이트를 목록 순서대로 두고 **각 part 사이에 단일 LF(`0x0A`)를 삽입하여 재조립**한다. 이는 분할 과정에서 파일 경계로 치환된 원문의 빈 줄을 복원하는 규칙이다. 재조립 SHA-256 `0cc7943594d78824d6b3390232f61f12b8199d2f9f3b8817bf9953ed5aa90061`로 원문 바인딩 무결성을 검증한다.

## Project binding correction

업로드 원문의 Section 4는 재사용 가능한 작업지시문 템플릿이라 `Switchy-Express-Cargo-Puzzle` 경로와 비어 있는 프로젝트 식별자를 포함했다. 이를 십보강호 current authority로 그대로 복사하면 잘못된 로컬/Godot 경로가 정본이 되는 충돌이 발생한다.

따라서 이번 바인딩은 다음 **프로젝트 입력 값만** 교정한다.

- repository: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`
- local/canonical/Godot path: `C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves`
- repository visibility: `public`
- required-check field: `CURRENT_APPLICABLE_REQUIRED_CHECKS_FROM_GITHUB`로 live lookup
- Google Sheet URL 및 required tabs: `00`, `02`, `04`, `71`, `72`, `99`
- decision ledger: `02_현재_확정결정`
- unresolved audit: `04_누락_충돌_감사`
- image review: `72_이미지검수_승인로그`

그 밖의 v4.5 r2 정책·Gate 의미는 변경하지 않는다.

## Authority and history

`TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01`과 `approved_20260806_integrated_work_contract_v4_3_binding.json`은 삭제하거나 재작성하지 않는다. 두 파일은 GUT 9.7.1 채택 스펙 당시의 역사·회귀 증거로 유지하며, **현재 프로젝트 운영계약 권위만** 이 Decision이 supersede한다.

v4.5 r2 원문에 기록된 Base SHA `7ce3fb64fa6303c5da6c7fc27c979f7233b761ac`은 `HISTORICAL_OBSERVATION_ONLY`다. 이번 채택 시점에 fresh-read한 Base current는 `315c66eea9614c284b9c11c4d522141065dfa4b0`였지만, 어느 exact SHA도 stable current authority로 이 계약에 고정하지 않는다. 작업마다 `ALWAYS_REFETCH_CURRENT_MAIN_BEFORE_WORK`를 적용한다.

## High-value gates promoted

- `GPT_CHAT_PLANNING_COMPLETE_BEFORE_POWERSHELL_CODEX_GODOT_BUILD`
- Thin Adapter / Base current refetch
- `EXTERNAL_PROCESS_OVERLAY_AUTHORITY_BOUNDARY`
- `PLAYER_EXPERIENCE_EVIDENCE_GATE`
- `FULL_SHA_ACTION_SUPPLY_CHAIN_GATE`
- `OPEN_DRAFT_PR_FULL_INVENTORY_GATE`
- `PROJECT_SOURCE_BCP_PROPOSAL_GATE`
- `PARTIAL_SKILL_ABSORPTION_GATE`
- `FUNCTION_LEVEL_VALIDITY_CLASSIFICATION_GATE`
- `USER_ACTION_REQUIRED_LAST_GATE`

## Safety boundary

이 Decision은 **작업 방식·증거·병합·정본 운영 계약**을 교체한다. 제품 코어, 전투 규칙, Scene/Resource/runtime data, Android 완료 상태, 사람 검증 상태를 변경하지 않는다. `product_implementation_authorized: false`는 유지된다.