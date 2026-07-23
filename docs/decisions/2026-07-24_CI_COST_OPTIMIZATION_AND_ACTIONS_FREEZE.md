# CI 비용 최적화와 Actions 동결 결정

> 상태: `IMPLEMENTED_FOR_REVIEW / ACTIONS_NOT_RUN`  
> 사용자 결정: GitHub Actions 사용량이 초기화되고 사용 가능 선언이 있기 전까지 runner 검증을 실행하지 않는다.  
> 활성화 변수: repository variable `CI_ENABLED=true`

## 1. 목적

문서 정본 변경에도 문서·전투 계약이 여러 Workflow에서 반복 실행되던 구조를 제거하고, 검증 비용을 변경 위험에 비례하도록 분리한다.

```text
문서 전용 PR
→ Ubuntu + Python 3.12 + 문서 정본 validator

코드·데이터·씬·테스트·Workflow PR
→ Ubuntu + 전체 정적 계약 + Godot 4.7.1 headless

main 병합·nightly
→ Ubuntu·Windows × Python 3.11·3.12·3.13
→ Godot는 Python 3.12에서 OS별 1회만 실행
```

## 2. 중복 제거 구조

### Pull Request

`Documentation Governance` 하나가 변경 파일을 `docs` 또는 `code`로 분류한다.

- `docs`: 운영체계·정본 최신성·Skill 무결성·Governance·canonical impact만 실행한다.
- `code`: 위 검증과 카드·전투 계약·PowerShell parse·Godot verifier를 한 job에서 실행한다.
- 기존 `Card Component Contract`의 PR·push 자동 trigger는 제거하고 수동 진단 전용으로 유지한다.
- 동일 PR에서 두 개의 전체 정적 계약 Workflow가 중복 실행되지 않는다.

### main·nightly

`Full Validation Matrix`만 전체 OS·Python 조합을 실행한다. Godot와 PowerShell parse는 각 OS의 Python 3.12 job에서만 실행해 6회 중복을 2회로 줄인다.

## 3. 취소·캐시 정책

모든 CI Workflow는 다음 계약을 가진다.

```yaml
concurrency:
  group: ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

새 커밋이 들어오면 같은 PR·branch의 이전 실행을 취소한다. Godot 4.7.1 바이너리는 OS별 cache key를 사용한다.

## 4. Actions 동결 게이트

모든 job은 runner 할당 전 다음 조건을 확인한다.

```yaml
if: ${{ vars.CI_ENABLED == 'true' }}
```

`CI_ENABLED`가 없거나 `false`이면 Workflow run은 생성될 수 있지만 job은 `skipped`이며 runner minute를 사용하지 않는다.

현재 상태:

```yaml
actions_availability: DEFERRED_ACTIONS_QUOTA
ci_enabled: false
automatic_runner_validation: NOT_RUN
workflow_yaml_static_parse: PASS_LOCAL
python_tooling_compile: PASS_LOCAL
```

## 5. Actions 필수 검증

다음은 로컬 정적 검토로 대체할 수 없다.

1. PR 변경 분류가 실제 `pull_request.base.sha`·`head.sha`에서 동작하는지 확인.
2. Ubuntu runner에서 Godot 4.7.1 공식 바이너리 다운로드·cache·headless 실행.
3. Windows runner에서 Godot 4.7.1과 경로·실행 파일 처리.
4. Python 3.11·3.12·3.13 전체 매트릭스.
5. `concurrency.cancel-in-progress`의 실제 이전 run 취소.
6. Branch protection Required Check 이름을 `documentation-governance`와 새 matrix 정책에 맞추는 작업.

위 항목은 사용자가 “Actions 사용 가능”이라고 선언한 뒤 실행한다.

## 6. 재개 순서

```text
CI_ENABLED=true 설정
→ Documentation Governance workflow_dispatch(scope=docs)
→ Documentation Governance workflow_dispatch(scope=code)
→ Card Component Contract 수동 진단 1회
→ Full Validation Matrix 수동 1회
→ Required Check 정렬
→ PR-A0 최신 base 반영·전체 Green 확인
```

## 7. 비용 보호 규칙

- PR에서 Windows matrix를 실행하지 않는다.
- 문서 전용 PR에서 Godot·PowerShell·카드·전투 전체 계약을 실행하지 않는다.
- artifact는 기본 업로드하지 않는다. 실패 로그는 Actions 기본 로그를 사용한다.
- Godot 성능 verifier는 main/nightly `full` profile에서만 실행한다.
- 새 커밋 전 이전 run 결과를 기다리지 않으며 concurrency가 자동 취소한다.
- Actions가 동결된 동안 검증 상태를 `PASS`로 기록하지 않는다.
