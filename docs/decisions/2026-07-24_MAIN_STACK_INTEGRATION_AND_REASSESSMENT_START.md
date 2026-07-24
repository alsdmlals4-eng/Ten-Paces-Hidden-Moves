# main 스택 통합 완료와 프로젝트 전면 재감사 시작

- 결정일: 2026-07-24
- 상태: `MAIN_INTEGRATED / REASSESSMENT_PLANNING_IN_PROGRESS`
- 프로젝트: `십보강호`
- 저장소: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`
- 통합 PR: #41
- main merge commit: `8b4380da79029dee5e07aae2622846fcf62e9431`
- 재감사 브랜치: `planning/project-reassessment-and-pointed-fun`

## 1. 결정

분산되어 있던 운영체계·T0 전투 POC·REPEAT_POC A0~A3·후속 입력 규칙 스택을 최종 제품 head 기준으로 한 번에 `main`에 통합한다.

```text
main
→ PR #5 Base 운영체계 반영
→ PR #7 T0 STEP 0~13 전투 POC
→ PR #15 프로젝트 코어·REPEAT_POC 계획
→ PR #17 A0 계약 정렬·CI 최적화
→ PR #19 A1 공개 상태 라이벌 후보 AI
→ PR #22 A2 가설 snapshot·결정적 summary
→ PR #25 A3 복기 UI·review gate
→ PR #35 [준비]·[전조]·카드/절초 자동 배치
→ PR #41 main 통합
```

최종 제품 branch `agent/prepare-momentum-and-auto-placement`는 통합 전 main보다 `701 commits ahead / 0 behind`였고 merge base는 당시 main head와 같았다. 통합 뒤 main과 제품 branch를 비교한 결과 제품 branch는 `0 ahead / 1 behind`, changed files `0`이다. 차이는 PR #41 merge commit 한 개뿐이다.

## 2. 기술 증거

- PR #35 closeout head PR Validation run #686: `PASS`.
- 통합 PR #41 PR Validation run #687: `PASS`.
- 동일 제품 tree의 Full Validation run #21: `PASS`.
  - Ubuntu Python 3.11·3.12.
  - Windows Python 3.11·3.12.
  - Ubuntu Godot 4.7 import.
  - 기존 전투·절초·재시작·접근성·AI·A2·A3 회귀.
  - 신규 준비 기세·자동 배치·절초 취소 환불 verifier.

GitHub 커넥터는 merge commit의 push-triggered workflow run을 직접 반환하지 않았다. 따라서 `main push Full Validation`은 별도 관찰 증거가 없으며 `NOT_OBSERVED_VIA_CONNECTOR`로 기록한다. 이를 PASS로 추정하지 않는다.

## 3. GitHub 정리

- Issue #16은 기술 Goal 완료로 닫았다.
- 선택된 제품 스택 PR #5·#7·#15·#17·#19·#22·#25·#35는 `INTEGRATED_BY_PR_41`로 종료했다.
- 대안 A2/A3 PR #32·#33은 `SUPERSEDED`로 종료했다.
- 검증 전용 PR #27~#31은 `VALIDATION_ONLY / CLOSE_WITHOUT_MERGE`로 종료했다.
- 구형 설계·운영·CI PR #2·#3·#6·#12·#18은 현행 main과 충돌하거나 대체되어 `SUPERSEDED`로 종료했다.

PR·branch·Git 이력은 삭제하지 않는다.

## 4. 현행 기술 기준

- 10칸 일자형 전장, 플레이어 4번·상대 7번, 시작 거리 3.
- 비공개 `3수 → 3수 → 4수`.
- 덱·손패 없는 공용 행동.
- `[합]`·방어·회피·필중·중단·강건.
- 공개 상태 기반 라이벌 후보 AI.
- 플레이어가 직접 기록한 가설 snapshot.
- 권위 판정 결과만 읽는 결정적 복기.
- 복기 확인 전 다음 계획 입력 잠금.
- `basic_stance` 표시명 `[준비]`, 다중 슬롯 선행 수 `[전조]`.
- 모든 카드와 절초의 가장 앞 연속 빈 구간 자동 배치.
- 절초는 진행 전 취소 시 기세 5 환불.

## 5. 증거 경계

```yaml
technical_implementation_complete: true
main_stack_integration: COMPLETE
main_tree_matches_validated_product_tree: true
main_push_full_validation: NOT_OBSERVED_VIA_CONNECTOR
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
subjective_usability: UNVERIFIED
product_gate: REPEAT_POC
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

기술 통합은 실제 플레이어의 이해·라이벌 성향 발견·재미·조작 선호·시장 적합성을 증명하지 않는다.

## 6. 다음 단계: C 전면 재감사

통합된 main을 단일 기준으로 다음을 다시 검토한다.

1. 대상 플레이어와 플레이 맥락.
2. 프로젝트 코어와 한 문장 가치 제안.
3. 반복되는 뾰족한 재미와 실제 선택 밀도.
4. 전투·복기·라이벌·성장 루프의 정렬.
5. 유사 게임 대비 차별 원리와 시장 위험.
6. 제작 범위·콘텐츠 부채·UX 장벽.
7. 가장 위험한 미검증 가설과 다음 최소 PoC.

C 단계는 `PLANNING_IN_PROGRESS`다. 새 기능 구현, T1 확장, 콘텐츠 선제 제작은 설계 승인 전 금지한다. 사용자가 명시적으로 `기획 완료`라고 선언하기 전까지 기획 검토·개선 루프를 유지한다.