# STEP 14 REPEAT_POC 플레이테스트 프로토콜 초안

> 상태: `DRAFT / BUILD_SHA_NOT_LOCKED / DO_NOT_RUN`  
> Goal: `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`  
> 구현 계획: `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`

이 문서는 테스트 실행 전에 질문·표본·판정 기준을 고정하기 위한 초안이다. 구현·전체 검증을 통과한 정확한 build SHA가 기록되기 전에는 참가자 테스트를 시작하지 않는다.

## 1. 검증할 플레이어 경험

플레이어가 다음 순서를 실제 행동으로 보이는지 관찰한다.

```text
공개 상태·이력 읽기
→ 상대 의도 가설 선택
→ 3/3/4 계획 확정
→ 실제 행동과 결정적 교차점 이해
→ 다음 묶음 또는 재도전에서 계획 변경
```

## 2. 표본과 진행 조건

```yaml
participant_count: 5
first_play_only: true
prior_project_knowledge: none
facilitator_help: critical_blocker_only
session_recording: screen_and_observation_notes
build_commit: NOT_LOCKED
status: DO_NOT_RUN
```

- 프로젝트 문서를 읽었거나 개발에 참여한 사람은 표본에서 제외한다.
- 첫 판 중 규칙 정답·AI 성향·추천 행동을 설명하지 않는다.
- 진행 불가능한 입력 장벽에서만 최소 조작 도움을 준다.
- 관찰·참가자 발화·분석자의 해석·개선 제안을 분리한다.

## 3. 필수 시나리오

1. 첫 묶음 계획을 완성한다.
2. 가설 선택지를 사용하거나 `아직 모르겠다`를 선택한다.
3. 한 묶음의 판정과 결정적 복기를 읽는다.
4. 최소 한 판을 끝낸다.
5. 패배·승리와 관계없이 한 번 재도전하거나 다음 수를 구체적으로 말한다.
6. 키보드 또는 참가자가 선택한 입력 방식으로 진행한다.
7. 모션 감소·음향 끄기 중 하나를 사용해 정보가 유지되는지 확인한다.

## 4. 관찰 질문

- 3수·3수·4수 묶음 차이를 자기 말로 설명하는가?
- 가설 선택이 실제 계획 순서에 영향을 주는가?
- 상대 실제 행동과 자신의 가설 차이를 설명하는가?
- 결정적 원인 하나를 거리·방향·합·대응·순서·자원 중 하나로 설명하는가?
- 상대의 반복 성향 하나를 안내 없이 발견하는가?
- 다음 묶음 또는 재도전에서 행동·순서·대상을 실제로 바꾸는가?
- 복기 UI가 정답 추천처럼 느껴지는가?
- 색·모션·음향이 없어도 핵심 결과를 이해하는가?

## 5. 참가자별 기록 양식

```yaml
participant_id:
build_commit:
godot_version:
windows_version:
viewport:
input_method:
prior_turn_based_tactics_experience:
prior_fighting_game_experience:
completed_battle: true | false
critical_blocker:
hypothesis_choices: []
hypothesis_affected_plan: true | false | unclear
explained_3_3_4: PASS | PARTIAL | FAIL
explained_decisive_cause: PASS | PARTIAL | FAIL
identified_rival_tendency: PASS | PARTIAL | FAIL
changed_plan_on_retry: PASS | PARTIAL | FAIL
voluntary_retry_or_next_move: PASS | PARTIAL | FAIL
single_channel_information_barrier: yes | no
observed_behavior: []
verbatim_summary: []
facilitator_intervention: []
status: PASS | PARTIAL | FAIL | BLOCKED
```

## 6. 사전 고정 통과 신호

- 5명 중 4명 이상 치명적 차단 없이 한 판 완료.
- 5명 중 4명 이상 3/3/4와 결정적 원인 하나 설명.
- 5명 중 3명 이상 안내 없이 라이벌 성향 하나 발견.
- 5명 중 3명 이상 재도전에서 계획을 실질적으로 변경.
- 5명 중 3명 이상 자발적 재도전 또는 구체적 다음 수 제시.
- 핵심 정보가 색·모션·음향 하나에만 의존한 참가자 0명.

통과 신호는 첫 참가자 실행 뒤 변경하지 않는다. 변경이 필요하면 기존 결과를 폐기하지 말고 새 프로토콜 버전과 새 표본으로 재시험한다.

## 7. 결과 판정

각 관찰은 다음 중 하나로 분류한다.

```text
KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST
```

최종 제품 상태는 다음 중 하나만 사용한다.

```yaml
human_step14: PASS | PARTIAL | FAIL | BLOCKED
product_gate: T1_GREENLIGHT_REVIEW | REPEAT_POC
```

STEP 14 통과는 곧바로 T1 구현 승인이나 MVP 완료를 의미하지 않는다. 최신 Development Gates에서 남은 필수 증거를 다시 확인한다.
