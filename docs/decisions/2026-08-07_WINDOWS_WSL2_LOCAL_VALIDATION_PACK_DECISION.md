# Windows + WSL2 로컬 Python 검증팩 결정

- Decision ID: `TEN-DEC-20260807-WINDOWS-WSL2-LOCAL-VALIDATION-PACK-01`
- 부모 Decision:
  - `TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01`
  - `TEN-DEC-20260807-ACTIONS-BUDGET-MANUAL-VALIDATION-FALLBACK-01`
- 사용자 승인 시각: 2026-08-07 07:19 KST
- 상태: `PACK_IMPLEMENTED_LOCAL_EXECUTION_PENDING`

## 목적

GitHub Actions 예산을 사용할 수 없는 동안 `.github/workflows/full-validation.yml`의 `matrix-contracts` 명령을 로컬 Windows와 WSL2 Ubuntu에서 재현한다. 검증 환경은 모두 필수다.

- Windows Python 3.11
- Windows Python 3.12
- Windows Python 3.13
- WSL2 Ubuntu Python 3.12

Windows Python 3.13은 현재 Actions 매트릭스의 3.11·3.12 명령 집합을 그대로 사용하는 로컬 선행 호환성 확장이다. 이를 GitHub Actions에서 3.13이 실행됐다는 뜻으로 사용하지 않는다.

## Fail-closed 규칙

- 동일한 exact HEAD에서 네 환경을 모두 실행한다.
- 실행 전후 `git status --porcelain`이 비어 있어야 한다.
- 환경 하나라도 없거나 명령 하나라도 실패하면 전체 결과는 FAIL이다.
- `matrix-contracts` 명령이 workflow와 달라지면 `WORKFLOW_COMMAND_DRIFT`로 차단한다.
- 패키지 설치나 환경 변경을 자동 수행하지 않는다.
- 결과는 `build/local-validation` 아래 환경별 JSON·로그·통합 summary로 남긴다.
- HEAD가 바뀌면 결과는 무효다.

## Claim ceiling

네 환경이 모두 통과한 경우에만 `LOCAL_PYTHON_MATRIX_4_OF_4_PASS`를 주장할 수 있다.

이 검증팩에는 Godot import, GUT 실행, JUnit 생성, export 검증, Windows 제품 실행, Android, 사람 검증이 포함되지 않는다.

```yaml
CURRENT_HEAD_GODOT_GUT_NOT_RUN: true
product_implementation_effect: NONE
production_readiness: false
```

따라서 기존 `PARTIAL_VALIDATED_EXPORT_GATE_OPEN`과 `BLOCKED_PENDING_HIGODOT_L1` 상태를 자동 해제하지 않는다.
