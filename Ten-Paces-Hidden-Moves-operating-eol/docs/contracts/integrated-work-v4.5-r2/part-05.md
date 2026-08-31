## 32. Open/Draft PR 전체 감사와 변경 단위

### 32.1 작업 시작·배치 종료·병합 후 Open/Draft PR 전체 확인

현재 프로젝트의 **모든 Open/Draft PR**을 조회한다.
same-goal PR만 보는 것으로 끝내지 않는다.

각 PR에 대해:

```yaml
pr_audit:
  number:
  title:
  draft_or_open:
  purpose:
  changed_scope:
  base_sha:
  head_sha:
  current_main_compatibility:
  duplicate_or_overlap:
  proposal_only:
  reference_only:
  do_not_merge:
  ci_status:
  required_check:
  unresolved_threads:
  adversarial_findings:
  user_approval_scope:
  risk:
  disposition:
```

Disposition:

```text
MERGE_ELIGIBLE
SYNC_WITH_MAIN_THEN_REVERIFY
KEEP_OPEN_WITH_REASON
PROPOSAL_ONLY_DO_NOT_MERGE
REFERENCE_ONLY_DO_NOT_MERGE
BLOCKED_VALIDATION
SUPERSEDED_CLOSE
STALE_CLOSE
USER_DECISION_REQUIRED
```

### 32.2 자동 병합 가능 PR

다음을 모두 만족하면 최신 main과 동기화하고 검증한 뒤 병합한다.

- 이미 사용자 승인 범위
- 저위험
- 목적·변경 범위가 명확
- current main 충돌 없음
- 중복 PR 아님
- 모든 필수 검증 PASS
- exact current validation target PASS
- 적대적 검토 P0/P1 없음
- unresolved thread 없음
- proposal-only/reference-only/DO_NOT_MERGE 아님

### 32.3 병합 금지 PR

다음은 자동 병합하지 않는다.

- proposal-only
- reference-only
- `DO_NOT_MERGE`
- 증거 수집용 보존 PR
- 검증 부족
- stale base인데 재검증 안 됨
- 승인 범위 밖
- 중요한 충돌 미승인
- protected behavior 침범

이유와 후속 조치를 기록한다.

### 32.4 병합 후 재감사

한 PR을 병합한 뒤:

```text
new main reread
→ all remaining Open/Draft PR reread
→ base drift
→ stale/duplicate/superseded
→ cleanup
→ required follow-up
```

### 32.5 PR 변경 단위

Google의 small change 관행과 Base의 하나의 Goal/활성 PR 원칙을 참고한다.

하나의 PR은 가능한 한:

```text
한 독립 문제
한 승인/rollback 경계
관련 regression
```

을 갖는다.

다음을 섞지 않는다.

- unrelated dependency update
- formatting/BOM cleanup
- 별도 policy
- unrelated refactor
- 새 사용자 결정

---

## 33. 병합 후

병합 성공 응답만 믿지 않는다.

```text
new main SHA
→ merged files reread
→ current decisions
→ affected canon
→ consumers/tests
→ open/recent PRs
→ branch cleanup
→ applicable Sheet readback
→ post-merge adversarial review
```

실행하지 않은 branch cleanup을 완료라고 보고하지 않는다.

---

## 34. 로컬 전달

사용자 로컬 정상 경로:

```text
GitHub Desktop
→ Fetch origin
→ Pull origin
→ local main SHA 확인
→ Godot
→ Run Project
```

dirty/diverged 상태에서 force/reset으로 덮지 않는다.

---

## 35. Godot Project Play 완료 Gate

개별 Scene 실행만으로 완료하지 않는다.

필수:

```text
application/run/main_scene
→ startup
→ 대표 문제
→ 대표 행동
→ 첫 선택
→ 첫 결과
→ 성공/실패
→ 복귀 또는 다음 흐름
```

가능하면 Windows·Android 각 delivery profile에서 확인한다.

### 35.1 완성형 Vertical Slice 기준 — v4.4 보호 계약

Vertical Slice가 완료되려면 최소 다음이 실제로 연결되어야 한다.

```yaml
vertical_slice_complete:
  representative_problem:
  representative_player_action:
  meaningful_choice:
  system_response:
  first_result:
  success_failure_or_resolution:
  feedback_and_reward:
  return_or_next_flow:
  save_or_state_continuity_when_applicable:
  windows_run:
  android_run_or_explicit_not_run:
  tech_evidence:
  ui_evidence:
  human_usability_evidence:
  player_experience_evidence:
```

개별 Scene·기능·mock 화면만 동작하는 상태는 Vertical Slice 완료가 아니다.

### 35.2 로컬 접근이 없는 에이전트

사용자 Windows 로컬에는 접근할 수 없지만 GitHub에는 접근 가능한 경우:

1. 원격 조사·PR·CI·병합·merged-main readback까지만 실제 수행한다.
2. 로컬 Fetch/Pull·PowerShell·Godot 실행을 했다고 주장하지 않는다.
3. `LOCAL_SYNC_BLOCKED_NO_LOCAL_ACCESS`, `GODOT_RUN_BLOCKED_NO_LOCAL_ACCESS`를 기록한다.
4. 정확한 사용자 작업 명령·기대 SHA·성공 판정을 **최종 User Action Required 섹션에 모아** 제공한다.
5. 사용자가 결과를 제공하면 그 증거로 후속 판정을 한다.

---

## 36. Base 승격

프로젝트에서 발견한 재사용 후보:

```text
project evidence
→ function-level classification
→ repeated/generalizable pattern
→ [수정제안서]/BCP - [프로젝트명] project-source proposal
→ evidence pack
→ proposal/index registration
→ proposal PR
→ review/approval
→ separate approved Base implementation PR when active rules must change
→ Base Registry change only when that implementation is separately authorized
→ Base tests / freshness / adversarial review
→ merge
```

### 36.1 프로젝트 출처형 BCP 규칙

수정제안서를 작성할 때 **Base 활성 규칙을 proposal 단계에서 직접 건드리지 않는다.**

권장 구조:

```text
[수정제안서]/
└─ BCP - [프로젝트명] - [개선주제]/
   ├─ PROPOSAL.md
   └─ evidence/
      ├─ PROJECT_VALIDATION.md
      ├─ BEFORE_AFTER.md
      ├─ COUNTEREXAMPLES.md
      └─ TRACEABILITY.md
```

```yaml
bcp_project_source:
  source_project:
  source_decision_ids: []
  source_commits_or_prs: []
  problem_observed:
  validated_improvement:
  evidence:
  reusable_boundary:
  project_specific_values_removed:
  existing_base_owner:
  conflict_analysis:
  proposed_absorption:
  rollback:
```

### 36.2 “Registry 등록”의 충돌 방지 해석

`Base 활성 규칙은 건드리지 않는다`와 `Registry 등록 → PR → 검증 → 병합`을 동시에 만족시키기 위해 다음을 구분한다.

```text
PROPOSAL PHASE
→ BCP proposal/index/registry 성격의 등록
→ [수정제안서] 범위
→ active Skill/Rule Registry 변경 금지

APPROVED IMPLEMENTATION PHASE
→ 별도 승인 reference
→ 필요한 경우 active skills/SKILL_REGISTRY.json 또는 owner 변경
→ 별도 implementation PR
→ TDD/freshness/adversarial/ci-gate
→ merge
```

즉 proposal-only PR에서 active `skills/SKILL_REGISTRY.json`을 미리 바꾸지 않는다.
현재 Base의 BCP 프로토콜이 별도 proposal registry/index를 제공하면 그것을 사용한다.
그런 surface가 없으면 proposal 안에 registration metadata를 남기고 active Registry는 구현 PR까지 기다린다.

proposal 등록과 active Base 구현을 같은 단계로 합치지 않는다.

프로젝트 고유 값·경로·아트를 Base에 승격하지 않는다.

---

## 37. Skill 변화·부분 흡수

### 37.1 전체 Skill을 가져오지 않아도 부분 흡수

외부/프로젝트 Skill을 검토할 때 “전체 채택 또는 전체 거부” 이분법을 금지한다.

흡수 후보:

- 특정 mode
- review lens
- checklist
- test pattern
- failure classification
- prompt 구조
- reference 문서
- evidence schema
- debugging step
- tool integration pattern

```yaml
skill_absorption:
  source_skill_or_framework:
  feature_or_function:
  source_license_or_usage_boundary:
  classification:
  reusable_part:
  rejected_part:
  target_existing_base_skill_or_doc:
  why_partial_absorption_is_better:
  regression_needed:
```

기존 Base owner에 자연스럽게 흡수되면 새 Skill을 만들지 않는다.

### 37.2 기능 단위 분해·상태 분류

Skill·기능·규칙·문서·workflow를 다음처럼 **기능 단위**로 쪼갠다.

```text
ALREADY_INTEGRATED
CURRENTLY_VALID
CONFLICTING_OR_OUTDATED
PARTIALLY_REUSABLE
MISSING_AND_NEEDED
DEFERRED_WITH_REASON
```

| 기능 단위 | 현재 Base/프로젝트 위치 | 상태 | 충돌/구형 이유 | 흡수/유지/제거 권장 | 증거 |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

### 37.3 새 Skill 후보

```text
existing Skill mode/ref로 해결 가능
→ 통합/부분 흡수

독립 reusable input/output/authority/validation boundary 존재
→ 새 Skill 후보
```

Skill 숫자 목표는 없다.

---

### 37.4 최적 작업에 필요한 요소가 없을 때

최적 작업에 필요한 핵심 요소가 없으면 **해당 의존 단계는 중단**한다.
그러나 독립적으로 진행 가능한 조사·기획·검토까지 불필요하게 멈추지 않는다.

```yaml
missing_requirement:
  item:
  why_needed:
  benefit_if_available:
  can_gpt_resolve_directly:
  safe_auto_install_or_config_possible:
  dependent_stage_blocked:
  independent_work_can_continue:
  user_action_required:
  exact_steps:
  verification_after_action:
```

원칙:

1. GPT가 현재 권한·도구로 안전하게 해결 가능하면 직접 해결한다.
2. 사용자만 할 수 있는 설치·로그인·권한·로컬 UI 조작이면 dependent stage를 `BLOCKED_USER_ACTION`으로 둔다.
3. 사용자 요청은 가능하면 현재 응답의 **마지막 `User Action Required`**에 모은다.
4. 보안·데이터 손실·과금·법률 위험 때문에 즉시 확인이 필요한 경우만 즉시 중단·질문한다.
5. 예: GitHub CLI가 없으면 왜 필요한지, 설치 시 장점, 공식 설치 방법, `gh --version` / `gh auth status` 확인법을 제공한다.
6. 설치가 “있으면 좋은 것”인지 “없으면 진행 불가”인지 구분한다.

## 38. 증거 Manifest

```yaml
evidence_manifest:
  base:
    current_main_sha:
    registry_read:
    selected_skills: []
    executed_skill_modes: []
    external_process_overlay:

  project:
    repository:
    base_sha:
    head_sha:
    approval_reference:
    decisions: []
    protected_items: []

  planning:
    core_game_model:
    requirement_traceability:
    benchmark_sources: []
    professional_comparisons: []
    existing_solution_disposition:
    grill_me_decisions: []
    grill_me_batch_checkpoint:
    planning_complete_user_declaration:
    final_planning_review:

  implementation:
    phase: GPT_PLANNING | FINAL_REVIEW | POWERSHELL_CODEX_BUILD
    powershell_codex_command:
    powershell_approval_prompts_used:
    fresh_execution_identity:
    changed_files: []
    tests_red:
    tests_green:
    runtime:

  player_experience:
    TECH_EVIDENCE:
    UI_EVIDENCE:
    HUMAN_USABILITY_EVIDENCE: NOT_RUN
    PLAYER_EXPERIENCE_EVIDENCE: NOT_RUN
    first_session:
    decision_screen:
    minigame_gate:

  assets:
    images:
    audio:
    provenance:
    asset_vault:
    local_reference_library:

  godot:
    version:
    higodot:
    gut:
    hera:
    clean_import:
    application_run_main_scene:
    project_play:
    tracked_source_delta_after_qa:

  platforms:
    windows:
    android:
    build_size:

  github:
    open_draft_pr_inventory:
    pr:
    review_head_sha:
    base_sha:
    ci_validation_target_sha:
    required_check:
    unresolved_threads:
    strict_up_to_date:
    merge_commit:
    new_main_sha:
    branch_cleanup:

  sheet:
    decision_sync:
    reread:

  skill_absorption:
    function_classification:
    partial_absorptions: []

  blockers:
    user_action_required: []

  local_delivery:
    fetch:
    pull:
    local_main_sha:
    godot_run:
```

---

## 39. 완료 판정

최상위 성공은 다음처럼 단계별 증거가 있어야 한다.

```text
BASE_CURRENT_AUTHORITY_RECOVERED
→ PROJECT_STATE_RECONCILED
→ PLANNING_COMPLETE
→ DECISIONS_SYNCED
→ IMPLEMENTATION_COMPLETE
→ TECH_EVIDENCE_RECORDED
→ UI_EVIDENCE_RECORDED_WHEN_APPLICABLE
→ HUMAN/PLAYER_EVIDENCE_RECORDED_OR_EXPLICIT_NOT_RUN
→ ADVERSARIAL_REVIEW_COMPLETE
→ EXACT_CURRENT_VALIDATION_TARGET_PASSED
→ CI_GATE_PASSED
→ MERGED_MAIN_VERIFIED
→ POST_MERGE_RECHECK_COMPLETE
→ LOCAL_SYNCED_OR_EXPLICIT_BLOCKED
→ PROJECT_PLAY_VALIDATED_OR_EXPLICIT_BLOCKED
```

`NOT_RUN`을 숨기지 않는다.

---
