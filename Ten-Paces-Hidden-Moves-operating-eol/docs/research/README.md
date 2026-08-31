# 십보강호 플레이테스트 기록

이 폴더는 실제 사람 플레이테스트의 프로토콜·관찰 원문·결과 판정을 보존한다.

## 현재 상태

```yaml
human_step14: DEFERRED_BY_USER
execution_scope: EXCLUDED_FROM_CURRENT_GOAL
build_sha_locked: false
status: DO_NOT_RUN
human_validation: UNVERIFIED
product_gate: REPEAT_POC
```

- 프로토콜 초안: `STEP14_REPEAT_POC_PROTOCOL_DRAFT.md`.
- 결과 템플릿: `STEP14_REPEAT_POC_RESULTS_TEMPLATE.md`.
- 기술 Goal: `../decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`.
- 상세 구현 계획: `../../plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`.

현재 Goal은 A0~A3 기술 구현과 자동·Godot·Windows 검증만 수행한다. 이 폴더의 문서는 삭제하지 않지만 기본 구현 입력과 완료 게이트에서 제외한다.

사람 테스트가 없으므로 규칙 이해도, 라이벌 성향 발견, 재도전 계획 변경, 주관적 재미와 공정성은 `UNVERIFIED`다. 기계 시나리오·개발자 눈검사·자동 테스트로 이를 대체하지 않는다.
