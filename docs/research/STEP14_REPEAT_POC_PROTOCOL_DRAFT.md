# STEP 14 REPEAT_POC 플레이테스트 프로토콜 초안

> 상태: `DEFERRED_BY_USER / DO_NOT_RUN`  
> 현재 Goal 포함 여부: `EXCLUDED`  
> Goal: `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`

## 보존 이유

이 문서는 향후 사용자가 사람 테스트를 다시 활성화할 경우 질문·표본·판정 기준을 사전에 고정하기 위한 보류 자료다. 현재 구현 계획, 완료 기준, T1 게이트에서는 사용하지 않는다.

## 미실행 상태

```yaml
participant_count: 0
build_commit: NOT_LOCKED
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
status: DO_NOT_RUN
```

## 재활성화 조건

다음 조건이 모두 충족되고 사용자가 명시적으로 실행을 지시한 경우에만 새 버전으로 활성화한다.

1. A0~A3 기술 구현 완료.
2. Governance·Godot·Windows 기술 검증 기록.
3. 정확한 build SHA 고정.
4. 표본·진행 방식·관찰 항목 재승인.

## 보류된 검증 질문

- 3/3/4 묶음을 자기 말로 설명하는가?
- 가설 선택이 실제 계획에 영향을 주는가?
- 결정적 원인을 거리·방향·합·대응·순서·자원 중 하나로 설명하는가?
- 라이벌의 반복 성향을 발견하는가?
- 다음 묶음 또는 재도전에서 계획을 변경하는가?
- 색·모션·음향 없이도 핵심 결과를 이해하는가?

## 증거 경계

자동 테스트와 개발자 검수는 위 질문에 답하지 않는다. 현재 결과는 모두 `UNVERIFIED`이며, 기술 구현 완료를 사람 검증 완료로 해석하지 않는다.
