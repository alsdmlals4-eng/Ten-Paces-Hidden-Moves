# CI 비용 최적화와 Actions 할당량 게이트

## 결정

GitHub Actions 할당량이 다음 초기화 시점까지 제한되어 있으므로, 자동 검증은 변경 범위에 따라 분기하고 전체 검증은 저장소 변수로 차단한다.

```yaml
actions_quota: UNAVAILABLE_UNTIL_USER_NOTICE
full_validation: BLOCKED_BY_ACTIONS_QUOTA
required_resume_signal: USER_CONFIRMS_ACTIONS_AVAILABLE
```

실행하지 않은 검증은 `PASS`가 아니라 `BLOCKED_BY_ACTIONS_QUOTA` 또는 `NOT_RUN`으로 기록한다.

## PR 검증 구조

`.github/workflows/documentation-governance.yml`은 PR당 Ubuntu runner 하나만 사용한다.

### 문서 전용 변경

다음 경로만 바뀐 경우:

- Markdown과 기획 문서
- 문서·Skill·운영 JSON
- README, START_HERE, AGENTS

실행:

```text
Ubuntu latest
Python 3.12
운영체계 validator
정본 freshness
Skill integrity
Governance regression
canonical combat document impact map
```

카드·전투 전체 계약, PowerShell 파싱, Godot, Windows matrix는 실행하지 않는다.

### 코드·데이터·씬·워크플로 변경

다음 경로 중 하나가 바뀐 경우:

```text
project.godot
data/
src/
scenes/
assets/
addons/
tests/*.gd 또는 tests/*.py
tools/*.ps1 또는 tools/*.cmd
.github/workflows/
```

실행:

```text
Ubuntu latest
Python 3.12
전체 정적 계약 1회
PowerShell parser 1회
```

Godot와 운영체제/Python matrix는 할당량 게이트가 열리기 전에는 실행하지 않는다.

## 전체 검증 구조

`.github/workflows/full-validation.yml`이 다음 이벤트를 소유한다.

- `main` push
- nightly schedule
- 수동 dispatch

단, 저장소 변수 `ACTIONS_FULL_VALIDATION_ENABLED`가 정확히 `true`일 때만 runner를 할당한다.

### Python matrix

```text
Ubuntu latest × Python 3.11, 3.12
Windows latest × Python 3.11, 3.12
```

### Godot

Godot 4.7 headless verifier는 Ubuntu에서 한 번만 실행한다. Python matrix 각 셀에서 Godot를 반복하지 않는다.

## 중복 실행 방지

두 워크플로는 다음을 사용한다.

```yaml
concurrency:
  group: ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

같은 PR에 새 커밋이 올라오면 이전 실행을 취소한다.

기존 `.github/workflows/card-component-contract.yml`은 PR Validation과 동일한 정적 검사를 중복 실행했으므로 삭제했다.

## 비용 절감 규칙

- PR 검증은 runner 하나에서 경로 분류와 해당 검사만 수행한다.
- 성공 artifact는 업로드하지 않는다.
- Godot는 전체 검증에서 한 번만 실행한다.
- Windows는 PR마다 실행하지 않는다.
- nightly는 변수 비활성 시 job-level `if`에서 runner 할당 전에 건너뛴다.
- 실패 재실행은 원인 수정 커밋 후 최신 실행만 사용한다.

## Actions 사용 가능 통보 후 재개 순서

사용자가 "Actions 사용 가능"이라고 명시하면 다음을 수행한다.

1. 저장소 변수 `ACTIONS_FULL_VALIDATION_ENABLED=true` 설정 여부를 확인한다.
2. PR #17 최신 head에서 `Full Validation`을 수동 실행한다.
3. Ubuntu·Windows Python matrix 결과를 기록한다.
4. Godot 4.7 설치와 headless verifier 결과를 기록한다.
5. 실패 시 해당 job만 원인 분석하고 전체 재실행을 반복하지 않는다.
6. 성공한 정확한 commit SHA를 Issue #16, PR #17, 상태 JSON에 기록한다.

## 현재 증거 경계

```yaml
pr_scope_routing: IMPLEMENTED_NOT_ACTIONS_VERIFIED
concurrency_cancellation: IMPLEMENTED_NOT_ACTIONS_VERIFIED
duplicate_card_workflow: REMOVED
full_matrix: BLOCKED_BY_ACTIONS_QUOTA
godot_headless: BLOCKED_BY_ACTIONS_QUOTA
windows_matrix: BLOCKED_BY_ACTIONS_QUOTA
human_step14: DEFERRED_BY_USER
```
