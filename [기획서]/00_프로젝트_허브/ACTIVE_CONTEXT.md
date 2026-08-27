# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`
> 이 문서는 **변동 상태의 단독 책임 원본**이다. 제품 규칙 전문을 복제하지 않고 현재 상태, 검증 상태, 미완료 Gate, 다음 실행 순서를 연결한다. 후속 Decision 뒤에도 회귀가 찾아야 하는 제품·플랫폼·관찰 권위의 발견 표식은 별도 섹션으로 보존한다.
> 핵심 결투 타이밍 discovery locator: `3/3/4`. 세부 전투 규칙은 `docs/02_COMBAT_RULES.md`가 책임진다.
> live 상태 판단은 저장된 SHA를 current authority로 재사용하지 않고 매 resume/post-merge마다 GitHub `main` + exact Project Notion current truth를 다시 읽는다. Google Sheets는 current r5.4 계약에 따라 신규 기획 입력이 아닌 `MIGRATION_ONLY_UNTIL_REMOVAL` compatibility source다.

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
current_work_contract: TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01
current_truth_source: GITHUB_MAIN_PLUS_EXACT_PROJECT_NOTION_LIVE_READ
legacy_discovery_compatibility: "current_truth_source: GITHUB_MAIN_PLUS_SHEET_LIVE_READ"
legacy_sheet_migration_locator: "03_무공서_무학"
current_main_policy: ALWAYS_REFETCH_GITHUB_MAIN
base_remote_main_policy: ALWAYS_REFETCH_CURRENT_MAIN
live_exact_sha_authority: NONE_REFETCH_REQUIRED
active_project_pr: GITHUB_PR_METADATA_REFETCH_REQUIRED
product_stage: FIRST_FIVE_DUEL_PHASE_I_VI_IMPLEMENTED
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: REVIEW
active_planning_pr: NONE
active_planning_parent_pr: NONE
active_approval_count: 1/10
active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED
source_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01
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
phase_i_vi_implementation: AUTHORIZED_AND_MERGED
future_product_mutation_authorized: false
next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION
next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
user_directed_planning_work_mode: COMPLETE
user_directed_planning_decision: TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01
user_directed_planning_next_package: CONTINUE_CONSUMER_FIRST_VISUAL_ASSET_PRODUCTION_IN_GPT_WORK_THEN_HUMAN_VALIDATION
user_directed_planning_next_decision: GPT_WORK_FRESH_READ_AND_CONSUMER_ASSET_DERIVATION_GATE
user_directed_planning_status: PLANNING_COMPLETE_VISUAL_PRODUCTION_ACTIVE
user_directed_planning_pr_authority: GITHUB_PR_METADATA
planning_execution_surface: GPT_WORK
planning_work_handoff: docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md
planning_visual_next: USER_DECISION_REQUIRED_FOR_NEXT_CONSUMER_ASSET
planning_visual_generation: NO_AUTOMATIC_NEXT_RESULT
planning_visual_review: DOGYEOM_STATUS_PORTRAIT_01_IMPLEMENTED_AUTOMATED_GODOT_VERIFIED_20260826_WINDOWS_HUMAN_VISUAL_NOT_RUN
planning_visual_state: docs/planning-data/current_visual_production_handoff_20260826.json
planning_visual_historical_state: docs/planning-data/current_visual_production_handoff_20260825.json
planning_visual_authority: TEN-DEC-20260820-VISUAL-UX-SYSTEM-01
planning_visual_production_decision: TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01
planning_visual_requirement_status: COMPLETE
planning_visual_overlay: TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01
ci_supply_chain_followup: RESOLVED_ISSUE_140
base_release_pinned: 9.4.3
base_remote_observation: CURRENT_REMOTE_REQUIRES_LIVE_REFETCH_NO_AUTOMATIC_PROJECT_ADOPTION
```

`legacy_discovery_compatibility`와 `legacy_sheet_migration_locator`의 Sheet 문자열은 기존 회귀·발견 도구가 과거 상태·콘텐츠 표를 찾기 위한 호환 토큰일 뿐이다. 실제 current truth는 `GITHUB_MAIN_PLUS_EXACT_PROJECT_NOTION_LIVE_READ`이며 신규 기획 입력·Decision 동기화는 Project Notion + GitHub를 사용하고 Google Sheets는 migration-only다.

`active_planning_*`, `active_decision_state`, `next_package`, `next_planning_decision`은 `docs/planning-data/current_operating_state.json`이 소유하는 플랫폼 운영 상태와 동기화한다. 완료된 Vertical Slice 기획/Visual production 상태는 `docs/planning-data/current_user_planning_status.json`, `docs/planning-data/current_visual_production_handoff_20260826.json`, `user_directed_planning_*`·`planning_visual_*` overlay가 소유하며 기존 플랫폼 운영 계약을 덮어쓰지 않는다.

플랫폼 Adapter 구현 Gate는 향후 플랫폼 확장 경계로 계속 유효하다. 2026-08-20 `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`과 `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01` 자체는 제품 구현 권한이 아니었지만, 후속 `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`이 첫 5전 PC-first Vertical Slice Phase I–VI 구현을 명시적으로 허용했고 해당 범위는 현재 `main`에 병합됐다. 따라서 현재 상태는 `phase_i_vi_implementation: AUTHORIZED_AND_MERGED`이며, **추가 제품 mutation**만 `future_product_mutation_authorized: false`로 새 명시 요청 + fresh Gate를 요구한다. 현재 Visual production은 r5.4의 `text brief → explicit approval → exactly one result → review` 경계와 `TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01`의 **actual game consumer required** 원칙을 함께 사용한다. 사용자는 이후 작업 surface를 **GPT Work**로 지정했으며, Work에서도 Project GitHub + exact Project Notion fresh-read가 current authority보다 우선하는 memory 대체물이 아니다.

이 live block에는 current main SHA나 열린 PR 번호를 저장하지 않는다. 새 세션·post-merge에서는 GitHub `main`, 열린 PR, exact Project Notion, current operating/visual/entry gate를 다시 읽고 의미 상태만 판정한다. exact SHA/run ID·PR 번호는 아래의 명시적 역사·관측 증거로만 취급한다.

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
planning_detail_prs_2026_08_20: 166,168,170
planning_review_ready_sync_pr_2026_08_20: 171
planning_complete_prs_2026_08_20: 172,173
planning_pr_2026_08_20_base: 0e9955afe791c43255176a4e89d89cf58be9b76a
historical_pre_phase_i_vi_product_stage: VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_COMPLETE_HANDOFF_READY
historical_pre_phase_i_vi_product_implementation_authorized: false
phase_i_vi_completion_pr: 183
phase_i_vi_completion_merge_commit: dfe25dec47f02229ecc5c92cdad7b6e1929525c8
authority_bootstrap_pr: 186
authority_bootstrap_merge_commit: 43a6e625c57c6f3e50b562e494fec074be553457
```

위 `observed_*` 값과 planning PR base도 다음 merge 뒤 자동 current가 되지 않는다. current 여부는 항상 live refetch로 다시 판정한다.

## 현재 권위와 보호 결정

- 현행 프로젝트 실행 계약: `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`, `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`.
- 첫 5전 Vertical Slice 기획 완료 승인: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`, `docs/planning-data/current_user_planning_status.json`.
- Visual/UX Requirement 승인: `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`, `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`, `docs/planning-data/approved_20260820_vertical_slice_visual_ux_contract.json`.
- Consumer-first Visual production 승인: `TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01`, `docs/decisions/2026-08-26_VISUAL_CONSUMER_ASSET_PRODUCTION_DECISION.md`.
- 현재 Visual production Gate: `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md`, `docs/planning-data/current_visual_production_handoff_20260826.json`.
- GPT Work 인수인계: `docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md` + exact Project Notion `2026-08-26 · GPT Work 인수인계`.
- 2026-08-25 승인 Reference Set: `docs/18_VISUAL_PRODUCTION_HANDOFF_2026-08-25.md`, `docs/planning-data/current_visual_production_handoff_20260825.json` — 승인 Reference와 당시 max-three cadence의 역사 evidence이며 current execution owner가 아니다.
- 구현 Gate: `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`, `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`.
- Phase I–VI 상태: `AUTHORIZED_AND_MERGED`; exact PR/SHA는 위 관측 증거 스냅샷에서만 역사 증거로 보존한다.
- 구현 Handoff: `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`.
- 강호 비무행·플레이어 역할·5전 감정곡선·비전투 App Flow: `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01`, `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`.
- 15명 후보·8개 Route·Briefing/Review/Result 텍스트 UX: `TEN-DEC-20260820-VERTICAL-SLICE-CONTENT-DETAIL-01`, `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`.
- 후보 무공 배정·Route Seed·비전투 Wire: `TEN-DEC-20260820-VERTICAL-SLICE-LOADOUT-ROUTE-WIRE-01`, `docs/14_VERTICAL_SLICE_LOADOUT_ROUTE_BUDGET_WIREFRAME.md`.
- 난이도 Seed·AI 공정성·검증 계약·aggregate 시간 예산·Planning Review Ready: `TEN-DEC-20260820-VERTICAL-SLICE-REVIEW-READY-01`, `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`.
- 플랫폼 범위: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`.
- 플랫폼 Adapter 아키텍처: `TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`.
- 행동 선택 UX: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`.
- 상황 화면 구조: `TEN-DEC-20260801-SITUATION-SCREEN-01`.
- 전투 UI 정보 위계·거리·카드·관찰 표시 오버레이: `TEN-DEC-20260811-COMBAT-UI-INFORMATION-HIERARCHY-01`.
- 관찰 정답 누출 방지: `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`.
- 초기 무공서 런타임 기반 권위: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`.
- 초기 무공서 UI·AI 채택 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`.
- 초기 무공서 자동 제품 검증 권위: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`.
- GUT 9.7.1 reconciliation/export boundary: `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`.
- Hera v1 live QA: `TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01`.
- 활성 Godot toolchain: `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`.
- TEN-IMG-001 exploration 권한: `TEN-DEC-20260808-TEN-IMG-001-VISUAL-REQUIREMENT-APPROVAL-01`; chat exploration은 수행됐지만 제품 자산 승격 없이 `NOT_AN_ASSET`이며 현재 새 이미지 생성은 r5.4 exactly-one Gate를 따른다.
- CI 공급망 follow-up: Issue #140은 `RESOLVED / CLOSED_COMPLETED`이며 active 후속 작업이 아니다.
- 과거 v6 인덱스는 `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`이며 최신 Decision보다 높은 권한을 갖지 않는다.

제품 코어·전투 규칙·성장·UI·저장 의미는 해당 분야 책임 원본을 따른다. 이 문서는 그 전문을 대체하지 않는다.

## 선행 UX·앱 흐름 권위

- `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01` — 아래 첫 5전 Vertical Slice 기획 계보를 사용자 완료 승인한다.
- `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01` — 통합 수묵 전술 화폭, 화면별 정보 위계, 재사용 컴포넌트, 최소 신규 자산 요구사항을 승인하고 당시 명시적 자산/구현 요청 대기로 전환했다. 이후 2026-08-25 사용자가 Visual 작업을 명시 재개했고, 2026-08-26 r5.4 current Gate가 승인당 정확히 1개 결과 cadence를 소유한다.
- `TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01` — 설명용/스타일 검증용 이미지를 current production 대상으로 만들지 않고 실제 게임 소비처가 확인된 자산만 생성한다. 도겸 Character Master와 실제 전장 consumer용 `DOGYEOM_COMBAT_BATTLER_01`은 사용자 승인 완료이며, 상태 패널 consumer용 `DOGYEOM_STATUS_PORTRAIT_01`도 새 원화 1장으로 사용자 승인·Notion binary readback 후 상태 패널에 구현됐다. 도겸 ID만 승인 초상으로 라우팅하며 다른 상대는 generic fallback을 유지한다. 다음 Visual은 자동 시작하지 않고 concrete consumer와 사용자 결정을 요구한다.
- `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01` — Main→시작 6중4→비무행 도입→Briefing→Combat Review Overlay→Duel Result/Reward 별도 Scene→Route 2노드→다음 비무→5전 완주.
- `TEN-DEC-20260820-VERTICAL-SLICE-CONTENT-DETAIL-01` — 후보 15명·8개 Route·텍스트 UX.
- `TEN-DEC-20260820-VERTICAL-SLICE-LOADOUT-ROUTE-WIRE-01` — 기존 10권 재사용·다음 후보 선잠금·Route 수치 Seed·비전투 Wire.
- `TEN-DEC-20260820-VERTICAL-SLICE-REVIEW-READY-01` — 난이도/AI/검증/시간 예산과 최종 기획 검토 준비.
- `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`.
- `TEN-DEC-20260801-SITUATION-SCREEN-01`.
- 역사 구현 표식: `runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65`.
- V6 원장: `2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.

위 App Flow·상세 계약·Visual/UX 요구사항은 계획 권위다. 사용자 `기획완료`와 후속 Visual/UX 승인 자체는 제품 mutation 권한이 아니었고, 이후 `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`이 첫 5전 Phase I–VI bounded implementation을 별도로 승인했다. PR #65와 `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`는 선행 런타임/자동검증 계보로 보존하고, 현재 전체 Phase I–VI 구현 상태는 상단 `phase_i_vi_implementation: AUTHORIZED_AND_MERGED`가 라우팅한다. `DOGYEOM_STATUS_PORTRAIT_01`은 승인 결과를 실제 상태 패널 소비처에 연결했고, focused Godot 자동 검증과 Vertical Slice bridge 회귀가 통과했다. Windows human visual review와 Android evidence는 여전히 별도다.
위 App Flow·상세 계약·Visual/UX 요구사항은 계획 권위다. 사용자 `기획완료`와 후속 Visual/UX 승인 자체는 제품 mutation 권한이 아니었고, 이후 `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`이 첫 5전 Phase I–VI bounded implementation을 별도로 승인했다. PR #65와 `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`는 선행 런타임/자동검증 계보로 보존하고, 현재 전체 Phase I–VI 구현 상태는 상단 `phase_i_vi_implementation: AUTHORIZED_AND_MERGED`가 라우팅한다. `DOGYEOM_STATUS_PORTRAIT_01`은 승인 Master PNG를 복구하지 못한 뒤 사용자 명시 승인으로 새 원화 정확히 1장을 생성·검토·승인했고 Notion 실제 첨부·readback 후 상태 패널 소비처에 연결됐다. focused Godot 자동 검증과 Vertical Slice bridge 회귀가 통과했으며 Windows human visual review와 Android evidence는 여전히 별도다.

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

현행 플랫폼 운영 값은 문서 상단 YAML의 `active_planning_pr`, `active_decision_state`, `next_planning_decision`을 사용한다. 사용자 Vertical Slice 기획/Visual production 상태는 `docs/planning-data/current_user_planning_status.json`, `docs/planning-data/current_visual_production_handoff_20260826.json`, `docs/planning-data/approved_20260820_vertical_slice_visual_ux_contract.json`과 `user_directed_planning_*`·`planning_visual_*` overlay를 사용한다. 제품 병합 권위는 별도 역사 증거인 `merged_product_pr: 92`, `product_implementation_merge_commit`, `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`로 유지한다.

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

## 역사 Entry Gate · 2026-08-08

`docs/planning-data/current_entry_gate_20260808.json`은 Phase I–VI 구현 승인 이전의 플랫폼/제품 pre-implementation Gate다. 후속 `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`이 첫 5전 Phase I–VI 범위의 current implementation authority를 소유하므로, 이 8월 8일 Gate를 현재 구현 미승인 근거로 재사용하지 않는다. Android/device/Human readiness의 역사 evidence ceiling은 계속 보존한다.

```yaml
status: SUPERSEDED_FOR_PHASE_I_VI_IMPLEMENTATION
local_windows_core: PASS_GODOT_GUT_HERA_EXPORT_CORE
local_android_device: BLOCKED_UNVERIFIED
human_validation: BLOCKED_NOT_RUN
windows_android_adapter_implementation_gate: BLOCKED_BY_ENTRY_GATE
product_implementation_authorized: false
allowed_next_actions:
  - REVIEW_VISUAL_UX_REQUIREMENTS_AND_REFERENCES_WITHOUT_IMAGE_GENERATION
  - PREPARE_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_WITHOUT_PRODUCT_MUTATION
  - START_PRODUCT_IMPLEMENTATION_ONLY_AFTER_EXPLICIT_USER_REQUEST_AND_FRESH_GATE
  - VERIFY_LOCAL_WINDOWS_ANDROID_DEVICE_AND_HUMAN_GATES_WHEN_REAUTHORIZED
```

이 2026-08-08 Entry Gate는 당시 제품/플랫폼 구현 경계를 기록한 역사 증거다. 이후 2026-08-20 PC-first Vertical Slice 구현 Gate가 Phase I–VI를 별도로 승인했고 해당 bounded 구현은 병합되었다. 따라서 여기의 `product_implementation_authorized: false`는 **당시 pre-implementation 상태**로만 읽는다. 새 이미지 생성과 향후 추가 제품 mutation은 여전히 별도 명시 요청/fresh Gate가 필요하며, Android 실제 기기·Windows visible Human·사람 검증은 실제 실행 전 PASS로 승격하지 않는다.

## 역사 플랫폼 preflight 중단 상태 · 2026-08-10

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

새 채팅·제품 구현·플랫폼·Visual 작업을 다시 시작할 때 과거 채팅의 SHA·스크립트를 current truth로 사용하지 않는다. 현재 사용자 지시로 Visual continuation의 기본 실행 surface는 GPT Work다.

```text
1. GPT Work에서 새 세션 시작
2. Base 최신 main/root/Registry/open PR 재조회
3. Project 최신 main/open PR/관련 Decision 재조회
4. current r5.4 project contract + exact Project Notion Home/Visual Bible/Asset Library/GPT Work 인수인계 재조회
5. current_user_planning_status + current_visual_production_handoff_20260826 + docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md + current_operating_state + current_vertical_slice_implementation_gate_20260820 재조회
6. 플랫폼/device 재인가 작업일 때만 current_entry_gate_20260808을 역사 비교 근거로 추가 확인
7. live context 의미 상태와 fresh truth 차이 교정
8. 다음 Visual 요청이면 실제 게임 소비처와 사용자 결정을 먼저 확인한다. `DOGYEOM_STATUS_PORTRAIT_01`은 구현·자동 검증 완료 상태로 재생성하지 않는다.
9. 실제 Godot 제품 구현 요청이면 r5.4 `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF`로 전환하고 Codex가 Project GitHub + Notion을 독립 fresh-read
10. PowerShell은 Godot local 실행·검증이 실제 필요할 때만 사용하며 local Codex launcher로 사용하지 않음
11. 실제 결과와 evidence ceiling을 분류하고 허용된 다음 Gate만 진행
```

자동화되지 않는 항목은 계속 `NOT_RUN`으로 남긴다.

- Windows visible local render.
- physical keyboard/mouse usability observation.
- physical gamepad.
- accessibility-user validation.
- release-device performance judgment.
- Android 실제 APK/AAB install/launch, touch/back/safe-area/lifecycle/performance.
- STEP 14 신규 플레이어 5명.

## Base 관찰

Base remote `main`의 exact SHA는 이 live router에 current 값으로 저장하지 않는다. 매 resume/post-merge마다 `ALWAYS_REFETCH_CURRENT_MAIN`으로 다시 읽고, 프로젝트의 Base 적용 권위는 current r5.4 project contract와 `docs/BASE_RULES_VERSION.md`·`skills/PROJECT_BASE_ADAPTER.json`의 compatibility pin을 구분한다. 새 Base 기능은 별도 current-contract 검토 없이 자동 채택하지 않는다.

과거 handoff에서 관측한 Base SHA는 위 `historical_base_main_at_handoff`에 증거 스냅샷으로 보존한다.

## 먼저 읽을 것

1. `AGENTS.md`.
2. `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md` / `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`.
3. `docs/BASE_RULES_VERSION.md`와 `skills/PROJECT_BASE_ADAPTER.json`.
4. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
5. `docs/planning-data/current_user_planning_status.json`.
6. `docs/planning-data/current_visual_production_handoff_20260826.json`.
7. `docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md`.
8. `docs/planning-data/current_operating_state.json`.
9. `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`.
10. exact Project Notion의 `Project Home`, `02 · 비주얼 바이블`, `03 · UI · 전투 Flow Map`, `04 · 에셋 라이브러리`, `2026-08-26 · GPT Work 인수인계`, `09 · 세계관 · 강호 비무행 · Vertical Slice`, `10 · 상대 15명 · 강호행로 8노드 · 텍스트 UX`, `11 · 상대 무공 배정 · Route 예산 · 비전투 Wire`, `12 · Vertical Slice · 기획 완료 기준선`, `13 · 기획 완료 · Visual/구현 Handoff`와 현재 Decision 페이지.
11. `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`, `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`, `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md`.
12. 질문별 분야 책임 원본과 실제 코드·테스트·GitHub PR metadata.
13. `[기획서]/00_프로젝트_허브/HANDOFF.md`와 `docs/planning-data/current_entry_gate_20260808.json`은 필요한 역사/플랫폼 비교 범위에서만 읽는다.

Google Sheets는 신규 기획 입력 경로로 사용하지 않으며 migration 잔존 정보를 확인해야 할 때만 보조 증거로 읽는다.

## 현재 위험·미검증

- 첫 5전 PC-first Vertical Slice Phase I–VI는 승인 범위가 구현·병합됐다. 다만 Windows visible Human usability, Android 실기기, Human 재미·가독성·몰입, 최종 Visual/VFX/Audio는 계속 `NOT_RUN`이며 완료로 승격하지 않는다.
- 2026-08-25 승인 Reference Set(`TEN-IMG-001`, `TEN-VIS-CHAR-MASTER-001`, `TEN-VIS-A07-CANDIDATE`, `TEN-VIS-A01`)은 Visual continuation 기준으로 승인됐지만 runtime/shipping asset PASS가 아니다. `OPPONENT_CHARACTER_MASTER_01`은 도겸 정체성 reference로 보존한다. `DOGYEOM_STATUS_PORTRAIT_01`은 `USER_APPROVED_2026_08_26` 상태로 사용자 명시 승인 후 정확히 1장의 새 원화를 생성·승인했고 로컬 정본은 `docs/visual-assets/approved/DOGYEOM_STATUS_PORTRAIT_01_v1.png`이며, Asset Library 레코드의 실제 Notion PNG 첨부와 destination readback은 `PASS_20260826`이다. 이 PNG는 `res://assets/portraits/dogyeom_status_portrait_01_v1.png`로 저장되어 `CombatantStatusPanel`에 구현됐다. `slot1_dogyeom` 상태 초상·전신 Battler routing 및 runtime art integration은 `AUTOMATED_GODOT_PASS_20260827_STATUS_PORTRAIT_AND_COMBAT_BATTLER`이다. Windows human usability와 Android 실기기 evidence는 계속 `NOT_RUN`이다.
- `TEN-VIS-A02`는 도겸 상태 초상을 다음으로 두고 나머지 상대 14인의 초상이 미제작이다. `TEN-VIS-A03`은 도겸 Battler source와 `slot1_dogyeom` runtime routing까지 완료됐지만, 나머지 14인 Battler는 미제작·미라우팅이다. `TEN-VIS-A04` Route 8아이콘, `TEN-VIS-A05` Result/Completion 표식, `TEN-VIS-A06` 추가 전투 배경도 실제 consumer 확인 뒤에만 제작한다.
- 후보 영구 스테이터스 총량 `20/22/24/26/28`, 성급 `3/7/7/7/9`, Route 회복 `최대 체력25% + 기력1 + 내력1`은 `REVERSIBLE_*_SEED`이며 실제 밸런스 PASS가 아니다.
- 대량 밸런스 시뮬레이션은 계약만 있고 `NOT_RUN`이다.
- 반복 또래 무인과 후보 15명의 정확한 이름·성별·외형·세부 소속·말투는 `REVERSIBLE_CONTENT_DETAIL`이다.
- aggregate 비전투 예산은 기획상 교정됐지만 실제 15~22분/가독성/몰입 Human 증거는 `NOT_RUN`이다.
- Android export preset 및 제품 Adapter 구현은 별도의 fresh platform Entry Gate가 허용하고 실제 검증하기 전 완료로 승격하지 않는다.
- Android 실제 기기·터치·back·safe area·lifecycle·저장·성능 증거는 `NOT_RUN / BLOCKED_UNVERIFIED`다.
- Windows visible local render·실물 입력·접근성 사용자·Release 성능은 자동 제품 검증과 별개다.
- STEP 14 사람 검증은 `NOT_RUN`이다.
- CI 공급망 mutable/stale action-pin 후속은 Issue #140에서 `RESOLVED / CLOSED_COMPLETED`; 현재 미해결 위험이 아니다.
- `OBSERVATION_ANSWER_LEAK_RISK`는 직접 공개를 바꾸지 않은 채 사람 측정을 기다린다.
- `future_product_mutation_authorized: false`를 유지한다. 이는 이미 병합된 Phase I–VI를 부정하지 않고 **새 추가 mutation**만 차단한다.

## 상태 표현 규칙

- 완료 증거가 없으면 `PASS`로 쓰지 않는다.
- live current state는 exact SHA나 열린 PR 번호를 내장하지 않고 GitHub + exact Project Notion을 다시 읽어 판정한다.
- exact SHA/run ID/PR 번호는 `관측 증거 스냅샷`, Decision, evidence 문서처럼 역사·관측 역할이 명확한 곳에만 둔다.
- 과거 PR/branch/Handoff가 GitHub current truth와 충돌하면 current GitHub + 현재 책임 원본을 우선하고 live router만 교정한다.
- HANDOFF는 명시적 session snapshot이므로 자동 current화하지 않는다.
- PR #82와 그 SHA는 역사 자료이지 현재 active planning PR이 아니다.
- 사용자 최신 지시로 중단된 작업은 실패로 승격하지 않고 `DEFERRED_BY_USER`와 실제 검증 ceiling을 함께 기록한다.

## 역사 LOCAL_EXECUTOR_HANDOFF_CHECKPOINT — 2026-08-12 · CURRENT EXECUTION SUPERSEDED

`TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`의 로컬 실행환경 작업은 당시 사용자의 인수인계 우선 지시로 checkpoint에서 멈췄다. 실행 산출물은 `tools/start_ten_paces_local_executor.ps1`이며, 아래 값은 당시 환경/학습/회귀를 보존하는 역사 evidence다. r5.4 current execution route가 아니다.

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

historical PID/port/session, `IN_CODEX_FRESH_READINESS_GATE`, `FRESH_POWERSHELL_REPEAT_RUN_GATE`, project-specific `CODEX_HOME`, dedicated 8003/9503 port route는 current readiness 선행조건이 아니다. 현재는 r5.4에 따라 local Godot 실행·검증이 실제 필요할 때만 PowerShell을 사용하고, 실제 Godot 제품 구현은 `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF` 뒤 Codex가 Project GitHub + Notion을 독립 fresh-read해 자신의 구현환경에서 수행한다. 과거 launcher/process/listening-port 존재를 current readiness PASS로 승격하지 않는다.
