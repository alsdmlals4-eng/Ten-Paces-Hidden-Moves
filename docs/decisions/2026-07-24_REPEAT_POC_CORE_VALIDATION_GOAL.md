# REPEAT_POC 기술 구현 Goal

> 상태: `READY_FOR_CODEX / IMPLEMENTATION_NOT_STARTED`  
> 기준 branch: `agent/project-core-confirmation`  
> 제품 원기준: PR #7 `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`  
> 상세 실행 계획: `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`

## Goal

현행 판정 공식을 보존하면서 다음 기술 경험 계약을 구현·자동 검증한다.

> 플레이어가 상대의 공개 단서로 의도를 하나 기록하고, 그 가정에 맞춰 3/3/4 계획을 건 뒤, 공개 순간 무엇을 맞히고 틀렸는지 결정적 원인으로 이해하고 다음 묶음에서 계획을 바꿀 수 있는 도구를 제공한다.

## 사용자 결정

- 신규 플레이어 STEP 14는 이번 Goal에서 실행하지 않는다.
- 사람 테스트 상태는 `DEFERRED_BY_USER`다.
- 사람 증거가 없으므로 재미·이해도·성향 발견·T1 적합성은 `UNVERIFIED`로 남긴다.
- 기술 구현 완료와 제품 검증 완료를 동일시하지 않는다.

## 완료 순서

```text
A0 정본 SHA·AI source·schema 정렬
→ A1 데이터 기반 라이벌 복수 후보 정책
→ A2 플레이어 가설 기록·결정적 summary
→ A3 복기 UI·접근성 흐름
→ TECHNICAL_CLOSEOUT
```

## 고정 계약

- 10칸·4/7·거리 3.
- 비공개 `3수 → 3수 → 4수`.
- 합·방어·회피·필중·중단·강건 판정 공식 불변.
- AI는 공개 상태만 사용한다.
- 새 행동·절초·세력·경제·성장·저장 시스템 추가 금지.
- 복기는 정답 행동·승률·예측률을 제공하지 않는다.
- 플레이어가 기록하지 않은 가설을 시스템이 추정하지 않는다.
- 사람 증거 없이 T1 또는 MVP 완료 선언 금지.

## 제품 산출물

1. board schema 17과 단일 `public_state_ai` 계약.
2. 한 라이벌의 공개 단서·성향·candidate policy 데이터.
3. 같은 state·seed 재현, 다른 seed의 합리 후보 집합.
4. `접근 / 속공 / 강공 준비 / 대응·회복 / 절초 / 모르겠다` 가설 snapshot.
5. 결정적 원인 cause code와 검토 차원 summary.
6. 키보드·모션 감소에서도 읽히는 복기 UI.
7. 전체 자동·Godot·Windows 기술 검증 기록.

## PR 경계

- PR-A0: 정본·Schema.
- PR-A1: 라이벌 AI.
- PR-A2: 가설·summary.
- PR-A3: review UI·기술 closeout.

각 PR은 독립적인 Red·Green·Refactor·검증·롤백을 가진다. 거대 PR로 합치지 않는다.

## 필수 검증

- `python -m unittest tests.test_project_governance -v`.
- canonical reference freshness.
- 신규 AI·hypothesis·summary·review UI Godot verifier.
- 기존 합·절초·중단·재시작·키보드·레이아웃 회귀.
- Windows 1440×900·960×640 포인터/키보드 기술 확인.

## 보류 검증

- 신규 플레이어 이해도.
- 라이벌 성향 발견률.
- 재도전 계획 변경률.
- 주관적 재미·공정성·복기 만족도.

위 항목은 `DEFERRED_BY_USER / UNVERIFIED`이며 기술 검증으로 대체하지 않는다.

## 중단 조건

- private player plan이 AI snapshot·trace에 들어간다.
- 복기 UI가 판정을 재계산한다.
- 가설 미선택을 시스템이 임의 해석한다.
- 고정 알고리즘 암기가 상대 읽기보다 강해진다.
- 3/3/4가 결단이 아니라 입력 대기열로만 느껴질 위험을 완료 주장으로 숨긴다.
- 새 콘텐츠·성장 범위가 코어 검증보다 커진다.

## 최종 판정

이 Goal의 기술 완료는 제품 검증 완료가 아니다.

```yaml
codex_goal: READY
implementation: NOT_STARTED
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
product_gate: REPEAT_POC
t1_greenlight: NOT_GRANTED
mvp_complete: false
```
