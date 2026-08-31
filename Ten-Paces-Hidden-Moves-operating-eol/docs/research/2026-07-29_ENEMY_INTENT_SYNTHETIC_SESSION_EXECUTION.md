# 십보강호 적 의도 단서 합성 세션 실행 보고서

```yaml
simulation_id: TEN-PACES-SYNTH-SESSION-002
validation_method: SYNTHETIC_TESTER_SIMULATION
evidence_tier: T6_AI_INFERENCE
baseline_branch: main
baseline_commit: 380128c48cab3c9cf76e758bfb1293c42c37b8b8
base_governance_commit: 9c4071c5ecefe28769b512d426442338ceb7acdd
structure_analysis: docs/research/2026-07-29_SYNTHETIC_TESTER_STRUCTURE_ANALYSIS.md
prior_risk_report: docs/research/2026-07-29_ENEMY_INTENT_SYNTHETIC_TESTER_REPORT.md
source_artifact: docs/superpowers/plans/2026-07-29-enemy-intent-human-validation-artifact.md
synthetic_session: EXECUTED
human_validation: NOT_RUN
runtime_causality: NOT_RUN
implementation_authority: NONE
assumption_not_observation: true
```

## 1. 결정 질문

> 교정된 단서와 `pre_signal_plan → post_signal_plan` 흐름이 정확 행동을 공개하지 않으면서 계획 변화의 근거를 만들고, 동일 공개 상태에서 경쟁 가설을 유지하게 하는가?

이 보고서는 실제 참가자 발언·행동·이해율을 기록하지 않는다. 카드 문구와 절차를 바탕으로 예상 가능한 경로와 반례만 공격한다.

## 2. 가상 페르소나 Case

### TACTICAL_NOVICE

```yaml
assumed_first_attempt:
  pre_signal_plan: [방어, 거리 유지, 반격]
  after_A_signals: 첫 수를 방어에서 끊기 또는 후퇴로 교체하되 approach와 quick_attack을 혼합해 설명
  after_B_signals: 닫힌 자세를 회복보다 방어 준비로 읽을 가능성
  after_C_signals: ultimate와 heavy_prepare를 모두 남기지만 차이를 설명하기 어려움
reasoning_basis: 직접 행동명은 제거됐지만 자세·기세 신호를 전투 범주로 번역하는 사전 지식이 부족함
counterexample: 상태 사실을 선택지 형태로 제공하면 단서와 자원 상태를 함께 연결할 수 있음
confidence: MEDIUM
finding: 단서 어휘 누출은 줄었으나 초보자에게는 범주 번역 보조가 필요함
```

### TACTICAL_EXPERT

```yaml
assumed_first_attempt:
  pre_signal_plan: 상대 기세·거리·최근 자원 소비를 기준으로 위험 대응 계획 구성
  after_A_signals: quick_attack을 주 가설, approach를 차선으로 유지하며 첫 수만 변경
  after_B_signals: response_or_recover와 heavy_prepare를 자원 상태로 구분
  after_C_signals: C-U/C-H 공개 정보만으로 확정하지 않고 두 가설에 공통 대응하는 계획 구성
reasoning_basis: 상태와 단서의 상호작용을 장르 규칙으로 해석할 수 있음
counterexample: 결과 key를 연속 공개하면 이후 Case에서 문구 패턴을 학습해 hidden intent를 역추론할 수 있음
confidence: HIGH
finding: 경쟁 가설 구조는 작동 가능하지만 결과 공개 순서가 학습 편향을 만들 수 있음
```

### IMPATIENT_PLANNER

```yaml
assumed_first_attempt:
  pre_signal_plan: 가장 안전한 세 수를 빠르게 기록
  after_signals: 차선 가설과 delta 이유를 최소 문구로 채우고 실제 계획은 유지
reasoning_basis: 기록 단계가 많아 목적보다 양식 완주를 최적화할 유인이 있음
counterexample: 한 단계씩 잠그고 계획에서 실제로 바뀐 슬롯만 표시하게 하면 형식적 응답이 줄어듦
confidence: HIGH
finding: 단계형 기록은 필요하지만 입력량을 줄이지 않으면 문서 노동이 추론을 압도할 수 있음
```

### OPTIMIZER

```yaml
assumed_first_attempt:
  dominant_plan_candidate: [방어 또는 간보기, 거리 조절, 확정 반격]
  after_signals: 모든 Case에서 같은 계획을 유지하고 단서별 설명만 변경
reasoning_basis: 실제 피해·자원·행동 결과 fixture가 없으면 강건한 범용 계획의 기회비용을 비교할 수 없음
counterexample: cue-informed 계획과 cue-agnostic 계획의 scripted 결과 차이를 같은 상태에서 제시하면 범용 계획을 공격할 수 있음
confidence: HIGH
finding: 현재 카드 세션만으로 단서가 실제 계획 효율을 바꾸는지는 판정 불가
```

### ADVERSARIAL_RESPONDER

```yaml
assumed_first_attempt:
  exploit: 계획 슬롯은 유지하고 `plan_change_delta`의 설명만 바꿔 단서를 사용한 것처럼 보이게 함
  secondary_exploit: C-U/C-H 결과 key를 기억해 다음 공개 카드의 숨은 의도를 추정
reasoning_basis: 평가 기준이 문장 근거 중심이면 행동 변화 없는 사후 합리화가 가능함
counterexample: 계획 카드의 실제 슬롯·대상·자원 변경만 delta로 인정하고 결과 key 순서를 독립화하면 악용이 감소함
confidence: HIGH
finding: 설명 변화와 계획 변화의 판정 계약을 더 엄격히 해야 함
```

## 3. 시나리오별 잠정 결과

| 시나리오 | 잠정 결과 | 근거 | 남은 위험 |
|---|---|---|---|
| A | `PROMISING_DIRECTION` | 직접 번역 어휘 제거 후 quick attack·approach를 경쟁 가설로 유지 가능 | 초보자는 두 범주를 혼합할 수 있음 |
| B | `ADAPT` | 상태·최근 자원 정보가 response/recover 해석에 기여 | 닫힌 자세를 단순 방어로만 읽을 위험 |
| C-U/C-H | `PROMISING_DIRECTION` | 동일 공개 정보로 한 정답을 확정할 수 없게 됨 | 결과 key 학습과 공통 범용 계획 가능 |
| 전체 기록 흐름 | `ADAPT` | pre/post 계획 분리로 사후 합리화 탐지 가능 | 기록 노동과 설명만 바꾸는 메타 대응 |

## 4. Finding

| ID | 판정 | 내용 | 후속 조치 |
|---|---|---|---|
| `TP-SS-F01` | `PROMISING_DIRECTION` | 가설 이름의 직접 번역을 제거해 정답 누출 위험이 감소 | 현재 범주 신호 강도 유지 |
| `TP-SS-F02` | `ADAPT` | 초보자가 자세 신호를 전투 범주로 번역하기 어려울 수 있음 | 상태 사실 선택 보조와 짧은 범주 설명 검토 |
| `TP-SS-F03` | `TEST_REQUIRED` | 범용 3수 계획이 단서 활용 계획보다 실제로 열등한지 카드만으로 판정 불가 | 동일 fixture의 cue-informed/agnostic 결과 행렬 작성 |
| `TP-SS-F04` | `ADAPT` | 계획은 그대로 두고 설명만 바꾸는 메타 대응 가능 | 슬롯·대상·자원 변경만 `plan_change_delta`로 인정 |
| `TP-SS-F05` | `ADAPT` | C-U/C-H 결과 공개가 이후 Case 학습 편향을 만들 수 있음 | 결과 key 순서 교차·Case 간 key 명칭 비공개 |
| `TP-SS-F06` | `TEST_REQUIRED` | 실제 AI 행동과 계획 인과는 fixture·seed 없이는 확인 불가 | runtime 상태 유지 `NOT_RUN` |

## 5. 적대적 판정

```yaml
strongest_case_for_direction: 상태만 본 계획과 단서 후 계획을 분리하고 동일 공개 카드에 경쟁 hidden intent를 두면 정답 맞히기보다 계획 근거 변화를 검토할 수 있음
strongest_case_against_direction: 실제 결과 차이가 없으면 모든 단서에 통하는 범용 계획과 형식적 설명이 지배할 수 있음
hidden_assumption: 서로 다른 가설이 실제로 다른 최적 계획을 요구한다는 가정
dominant_strategy_risk: 방어-간보기-반격 범용 묶음
copy_or_facilitator_bias: 결과 key 공개 순서 학습
fidelity_limit: CARD_AND_SCRIPTED_INTENT_ONLY
provisional_decision: PROMISING_DIRECTION
```

## 6. 잠정 결론

```yaml
synthetic_session_result: PROMISING_DIRECTION
reason: 직접 정답 어휘와 사후 계획 작성 문제는 완화됐으나 범용 계획의 실제 기회비용과 runtime 인과는 아직 증명할 수 없음
design_revision_authority: PROVISIONAL_RESEARCH_ARTIFACT_ONLY
human_validation: NOT_RUN
actual_fun: NOT_RUN
runtime_causality: NOT_RUN
product_code_changed: false
canon_changed: false
implementation_authority: NONE
next_gate: AUTHOR_CUE_INFORMED_VS_AGNOSTIC_STATIC_OUTCOME_MATRIX_AND_KEEP_RUNTIME_TEST_REQUIRED
```

이 결과는 v6 원장이나 전투 구현을 승인하지 않는다.
