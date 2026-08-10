## 25. 구현 원칙·Test First

### 25.1 격리 작업

- 최신 `origin/main` 또는 current remote main을 기준으로 별도 branch/worktree를 사용한다.
- Base와 프로젝트 변경을 같은 PR에 섞지 않는다.
- 동일 Goal PR이 있으면 중복 PR을 만들지 않는다.
- 예상 파일과 실제 changed files를 계속 대조한다.
- 관련 없는 BOM/format/file-mode cleanup을 기능 변경에 섞지 않는다.

### 25.2 작업마다 TDD 항상 적용

모든 작업은 TDD 또는 그 작업 유형에 맞는 **test-first 증거**를 먼저 만든다.

| 작업 유형 | 먼저 만드는 실패 증거·수용 기준 |
|---|---|
| 코드·게임 로직 | 실패 단위·통합·회귀 |
| 데이터·밸런스 | schema·범위·불변식·시뮬레이션 실패 |
| Scene·Resource | 로드·참조·signal·state transition |
| UI·입력 | state·focus·resolution·input scenario |
| 이미지·애니메이션 | size·style·readability·frame·import acceptance |
| 문서·기획 | 누락·충돌을 재현하는 audit/checklist/contract |
| CI·배포 | failing validation job 또는 재현 절차 |
| PR hygiene | stale/duplicate/mergeability/required-check expected failure |

```text
요구/Decision
→ RED
→ failure reason verification
→ minimal GREEN
→ related regression
→ adversarial case
→ exact validation target
```

자동 테스트가 불가능한 작업도 **관찰 가능한 실패 조건과 수용 기준을 먼저** 작성한다.

### 25.3 TDD 증거 기록

```yaml
tdd_unit:
  id:
  requirement_or_decision_id:
  red_test_or_acceptance:
  red_result:
  failure_reason_verified:
  minimal_change:
  green_result:
  regression_suite:
  adversarial_case:
  evidence_location:
  commit_sha:
```

테스트를 나중에 추가하고 TDD를 했다고 주장하지 않는다.

### 25.4 최소 변경·Godot 안전

- 목표에 필요한 파일만 수정한다.
- save schema·public interface·Resource path를 무단 변경하지 않는다.
- Scene/Resource 텍스트 대량 치환을 기본값으로 두지 않는다.
- NodePath, UID, signal, owner, ext/sub resource를 검증한다.
- autoload/InputMap 중복 등록을 막는다.
- 현재 Godot 버전에 없는 API를 추측하지 않는다.
- deprecated 제거 시 모든 active consumer를 추적한다.

### 25.5 기본 RED→GREEN 루프

모든 실질 변경은 가능한 한 다음을 따른다.

```text
RED
→ verify failure reason
→ minimal GREEN
→ refactor only if needed
→ exact regression
```

회귀 테스트가 없던 정책/계약 문제라면 먼저 failing contract를 만든다.

금지:

- 테스트를 작성했지만 RED를 확인하지 않음
- unrelated 실패를 목표 실패라고 오인
- 테스트 통과를 런타임/사람 검증으로 과장

---

## 26. PowerShell·Codex 실행 프로토콜

Codex/Godot 구현은 **PHASE A 기획 완료 + 사용자 기획 완료 선언 + PHASE B 최종 검수** 뒤에만 실행한다.

### 26.1 기본 실행 명령

사용자가 지정한 기본 명령:

```powershell
codex.cmd -a never -s workspace-write
```

이 명령은 런타임에서 설치된 Codex CLI가 실제로 지원하는지 먼저 확인한다.
지원하지 않으면 추측해서 변형하지 않고 blocker 처리한다.

### 26.2 승인 클릭 최소화

Codex 자체는 `-a never`로 내부 승인 프롬프트를 만들지 않는 것을 기본으로 한다.

사용자 `[승인]` 요청은 **최대 2개**의 상위 단계 Gate로 제한한다.

```text
[승인 1/2]
기획 완료 + 최종 구현 패키지 잠금 + PowerShell/Codex BUILD 시작

[승인 2/2]
사용자 로컬에서만 가능한 privileged/manual action 또는 최종 수동 전달 Gate가 실제로 필요할 때
```

두 번째 승인이 필요하지 않으면 억지로 만들지 않는다.
GitHub PR 병합은 현재 대화의 이미 승인된 범위에서 별도 `[승인]` 횟수로 계산하지 않는다.

### 26.3 Full-auto 원칙

직접 해결 가능한 작업은 GPT/Codex가 직접 수행한다.

- 파일 조사
- 코드/문서 수정
- 테스트
- Git 작업
- PR 상태 확인
- benchmark/review
- rerun
- merged-main readback

사용자만 할 수 있는 작업을 제외하고 “직접 해주세요”로 넘기지 않는다.

### 26.4 Ephemeral execution session

PowerShell/Codex/Godot 실행 블록이 끝나면 해당 세션 상태를 영구 권위로 사용하지 않는다.

```text
finish block
→ save evidence
→ close Codex process when applicable
→ close Godot/editor/test process when applicable
→ close PowerShell block when applicable
→ next block starts with fresh repo/process/session read
```

다음 실행은 **처음부터 다시 시작한다고 생각하고** 다음을 재검증한다.

```yaml
fresh_execution_identity:
  current_main_sha:
  branch:
  working_tree:
  codex_version_and_args:
  godot_version:
  godot_process:
  gut_discovery:
  hera_transport:
  exact_target:
```

stale PID/session/editor state를 현재 성공 증거로 사용하지 않는다.

### 26.5 Codex 인계

Codex는 기본 의무 단계가 아니다.

```text
USER_REQUESTED_CODEX_HANDOFF
AND package DoR closed
→ handoff
```

인계 패키지:

```yaml
codex_package:
  repository:
  base_sha:
  target_branch:
  goal:
  approved_scope:
  approval_reference:
  protected_paths:
  current_actual_state:
  affected_files:
  acceptance_criteria:
  tests:
  godot_authoring_boundary:
  rollback:
  required_post_build_review:
```

Codex도 실제 repo/project/Godot 상태를 다시 읽는다.
GPT의 예상 상태를 사실로 가정하지 않는다.

---

## 27. 다층 검증

### 27.1 Contract

- 승인 목표
- 범위
- 보호 대상
- 실제 diff
- 책임 원본

### 27.2 Reference freshness

- 정본 변경
- active consumers
- untouched consumers
- Registry
- Template
- Test
- generated derivative
- manifest/hash

### 27.3 Static

- syntax
- schema
- import
- path
- ID
- data
- asset provenance

### 27.4 Runtime

- startup
- main scene
- interaction
- error path
- save/load
- clean import

### 27.5 UI / Accessibility

- input
- focus
- text
- resolution
- motion
- alternate path

### 27.6 Performance

적용되는 변경에서:

- frame time
- CPU/GPU
- memory
- loading
- network
- mobile thermal

### 27.7 Human/Player

BCP-020 증거층을 별도로 기록한다.

### 27.8 Regression

대표 정상·경계·반례·기존 기능.

---

## 28. 적대적 검토 루프

기본:

```text
attack
→ validate-critique
→ refine-approved-findings
→ regression-recheck
→ decision-report
```

저장소 전체 감사:

```text
repository-scope-map
→ canonical-authority-map
→ full-file-inventory
→ stale-and-duplicate-attack
→ untouched-consumer-attack
→ derivative-and-prompt-drift-attack
→ validate-critique
→ legacy-classification
→ approved-minimal-fix
→ regression-and-freshness-recheck
```

### 28.1 단계별 중요 Skill/프로세스 적용

각 주요 단계에서 필요에 따라 다음을 실제로 적용하고 실행 보고에 남긴다.

```text
brainstorming / design exploration
→ planning / writing-plans
→ TDD
→ systematic debugging when failure appears
→ adversarial review
→ critique validation
→ code/document review
→ verification-before-completion
→ post-merge reconciliation
```

Superpowers 등 외부 프레임워크는 `EXTERNAL_PROCESS_OVERLAY`로 기록한다.
Skill을 단순히 읽은 것과 실제 적용한 것을 구분한다.

### 28.2 1인 개발용 GPT 역할 분리 검토 — v4.4 보호 계약

별도의 인간 독립 리뷰어가 없을 때도 구현자 설명을 그대로 성공 증거로 사용하지 않는다.

```text
GPT REVIEWER ROLE
+ USER PLANNING DECISION AUTHORITY
+ OBJECTIVE TEST / CI / GODOT / SHA EVIDENCE
```

새 검토 패킷을 구성한다.

```yaml
gpt_role_separated_review:
  requirements_or_plan:
  decision_ids: []
  approval_reference:
  base_sha:
  head_sha:
  changed_file_inventory: []
  protected_contracts: []
  tdd_evidence:
  test_commands_and_results:
  godot_runtime_evidence:
  windows_android_evidence:
  visual_asset_audio_acceptance:
  known_deferred_items: []
  implementer_claims: LABELED_NOT_INDEPENDENT_EVIDENCE
```

규칙:

- 같은 GPT가 구현과 리뷰를 모두 수행할 수 있으므로 완전한 독립 리뷰라고 과장하지 않는다.
- 구현 이유를 방어하기보다 요구·diff·정본·객관 증거를 공격한다.
- 이전 답변의 “성공” 선언보다 GUT·CI·Godot 로그·현재 SHA를 우선한다.
- 사실 / 추론 / 권장안을 분리한다.
- 새 기획 P0/P1 충돌은 Grill Me로 사용자에게 올린다.
- 현재 대화의 자동 병합 승인은 **이미 승인된 범위의 병합 권한**이지 새 기획 충돌의 자동 승인 권한이 아니다.

완료 상태:

```text
GPT_ROLE_REVIEW_COMPLETE
USER_DECISION_COMPLETE_OR_NOT_REQUIRED
OBJECTIVE_TEST_EVIDENCE_COMPLETE
```

**항상 확인할 공격 대상:**

```text
왜곡
충돌
누락
오래된 가정
중복
권위 역전
untouched consumer
불필요한 복잡성
보완 가능성
더 나은 현업 대안
플레이어 경험 증거 과장
```

필수 공격 렌즈:

### 요구·정본
- 핵심 내용 누락
- Decision 부활
- 중복 정본
- 오래된 prompt가 current authority처럼 작동

### 구조·데이터
- 중복 시스템
- schema drift
- save/config 호환성
- 고아 참조

### 플레이어 경험
- 행동 목적 모호
- 첫 선택/결과 부재
- 비용·위험·보상 오해
- 자동 증거로 사람 경험을 과장

### UI·접근성
- 오류/빈 상태
- focus
- 입력
- 해상도
- CJK
- motion

### 자산·권리
- Draft 최종화
- provenance
- license
- IP imitation
- local absolute path

### Godot·플랫폼
- clean import
- startup
- export
- Android lifecycle
- merged-main runtime

### Git·CI·보안
- 승인 범위 밖 diff
- credential/cache
- immutable Action pin
- least privilege
- Required Check target
- strict up-to-date
- unresolved thread
- main movement during review

### 외부 Process Overlay
- overlay가 canon을 덮어쓰는가
- 같은 승인을 다시 요구하는가
- Base Gate를 약화하는가
- 읽은 Skill을 실행했다고 허위 보고하는가

---

## 29. GitHub Actions·CI

public repository에서 standard GitHub-hosted runner는 `REMOTE_CI` 기본이다.

비용 절감:

```text
테스트 삭제 X
→ change risk classification
→ duplicate run cancellation
→ selective expensive dependency
→ single stable ci-gate
```

공급망:

```text
uses: owner/action@<reviewed full-length SHA>
least-privilege permissions
fork / pull_request_target / secret trust boundary review
```

Base current main이 Action pin의 정본이다.
이 thin adapter에 checkout/setup-node SHA를 복제하지 않는다.

---

## 30. Base Repository Setting 정합성 상태

v4.5 작성 시 Base에서 확인된 상태:

```yaml
base_repository_governance:
  protected_ruleset:
    name: solo-main-safety
    required_check: ci-gate
    protected_merge_method: squash
  repository_level_observed:
    squash: enabled
    merge_commit: enabled
    rebase: enabled
  desired_defense_in_depth:
    squash: enabled
    merge_commit: disabled
    rebase: disabled
  tracking_issue: "https://github.com/alsdmlals4-eng/Base/issues/277"
  live_setting_write_status: BLOCKED_UNVERIFIED
```

Issue #277이 해결되기 전에는 repository-level merge/rebase가 꺼졌다고 주장하지 않는다.

이 차이는 Base의 protected Ruleset이 현재 squash를 강제한다는 사실과 별개다.

---

## 31. exact validation target / strict up-to-date

병합 전:

```text
current PR head
current base main
merge-base
test merge / merge queue if applicable
required ci validation target
```

를 다시 읽는다.

**중요**

검증 중 `main`이 전진하면:

```text
OLD GREEN != CURRENT GREEN
```

strict up-to-date 정책을 우회하지 않는다.

```text
new main read
→ conflict/consumer comparison
→ rebase/reconstruct
→ adversarial diff
→ new exact validation
→ ci-gate
→ merge
```

---
