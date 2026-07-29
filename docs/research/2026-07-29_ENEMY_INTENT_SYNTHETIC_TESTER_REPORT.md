# 십보강호 적 의도 단서 합성 테스터 보고서

```yaml
simulation_id: TEN-PACES-SYNTH-001
validation_method: SYNTHETIC_TESTER_SIMULATION
evidence_tier: T6_AI_INFERENCE
baseline_commit: 929b4b545e9a41e38d8b6d43dfcdd478daae0057
base_governance_commit: 9c4071c5ecefe28769b512d426442338ceb7acdd
structure_analysis: docs/research/2026-07-29_SYNTHETIC_TESTER_STRUCTURE_ANALYSIS.md
human_validation: NOT_RUN
ai_simulation: COMPLETED
implementation_authority: NONE
assumption_not_observation: true
```

## 1. 결정 질문

> 방향성 단서가 정확한 행동을 공개하지 않으면서 공개 상태와 결합되어 주 가설·차선 가설·3수 계획 수정을 만들 수 있는가?

실제 사람의 이해율·재미·선호를 판정하지 않는다. 현재 카드 문구와 규칙에서 예상 가능한 결함만 공격한다.

## 2. 페르소나별 가정

### TACTICAL_NOVICE

```yaml
scenario_id: TP-INTENT-A
assumed_first_attempt:
  - "첫 수를 빠르게 끊으려는 기색"을 quick_attack의 직접 번역처럼 읽을 가능성
  - competing hypothesis를 고려하기보다 단서와 이름이 가장 가까운 항목을 선택할 가능성
reasoning_basis: 단서 문구와 가설 이름의 의미 거리가 지나치게 가까움
confidence: HIGH
counterexample: 가설 이름을 숨기고 행동 범주만 제시하면 직접 매칭이 약해질 수 있음
adversarial_question: 단서를 이해한 것인가, 같은 단어를 찾은 것인가?
assumption_not_observation: true
```

### TACTICAL_EXPERT

```yaml
scenario_id: TP-INTENT-C
assumed_first_attempt:
  - enemy_momentum 5와 "기세가 한 점으로 모인다"를 결합해 ultimate를 사실상 확정 정보로 처리
  - 차선 가설을 형식적으로만 적고 실제 계획은 절초 대응 하나에 집중
reasoning_basis: 최고 기세 상태와 절초 계열 표현이 중복 신호로 작동
confidence: HIGH
counterexample: heavy_prepare도 최고 기세에서 합리적 보상을 가지면 경쟁 가설이 살아날 수 있음
adversarial_question: 불확실성이 남아 있는가, 정답을 두 번 보여주는가?
assumption_not_observation: true
```

### IMPATIENT_READER

```yaml
scenario_id: TP-INTENT-B
assumed_first_attempt:
  - 상태 수치보다 강조된 단서 아이콘만 보고 response_or_recover를 선택
  - 3수 계획은 기존 선호 카드 순서를 유지하고 설명만 단서에 맞춰 사후 작성
reasoning_basis: 카드·아이콘이 상태 표보다 시각적으로 우세할 가능성
confidence: MEDIUM
counterexample: 계획 제출 전에 상태 사실을 하나 선택하도록 강제하면 사후 합리화를 줄일 수 있음
adversarial_question: 단서가 계획을 바꿨는가, 설명만 바꿨는가?
assumption_not_observation: true
```

### ROBUST_PLAN_OPTIMIZER

```yaml
scenario_id: ALL
assumed_first_attempt:
  - 단서마다 계획을 바꾸지 않고 방어·간보기·반격의 범용 3수 묶음을 반복
  - 정확 추론보다 최악 상황 손실을 줄이는 안정 계획을 선택
reasoning_basis: 단서 활용 보상과 단서 무시 비용이 아직 수치·계약으로 증명되지 않음
confidence: HIGH
counterexample: 각 가설에 대한 대응 계획이 상충하고 범용 계획의 기회비용이 충분하면 지배 전략이 사라짐
adversarial_question: 추론이 승리 조건인가, 장식적인 추가 점수인가?
assumption_not_observation: true
```

### META_GAMER

```yaml
scenario_id: TP-INTENT-C
assumed_first_attempt:
  - bundle_size 4와 momentum 5를 절초 발생 규칙으로 외움
  - 문구보다 상태 임계값으로 정답을 결정
reasoning_basis: 반복 세션에서 상태 조합과 의도가 고정되면 메타 룩업 테이블이 형성됨
confidence: MEDIUM
counterexample: 동일 상태에서 복수 의도가 실제 후보가 되면 메타 확정은 약화됨
adversarial_question: 추론인가, 임계값 암기인가?
assumption_not_observation: true
```

### LOW_WORKING_MEMORY

```yaml
scenario_id: ALL
assumed_first_attempt:
  - 상태 사실·단서 2개·주 가설·차선 가설·3수 이유를 동시에 유지하지 못함
  - 차선 가설을 빈칸으로 두거나 주 가설의 동의어로 작성
reasoning_basis: 한 번에 요구하는 정보 단위가 많음
confidence: MEDIUM
counterexample: 단계형 입력과 상태 고정 표시가 있으면 부담이 감소함
adversarial_question: 사고 깊이를 측정하는가, 기록 노동을 측정하는가?
assumption_not_observation: true
```

## 3. Finding

| ID | 상태 | 내용 | 최소 조치 |
|---|---|---|---|
| `TP-SYN-F01` | `MUST_FIX_BEFORE_TEST` | A의 속공 문구와 C의 절초 문구가 가설 이름을 직접 번역해 정답 누출 위험 | 문구를 행동명 대신 자세·리듬·자원 변화의 범주 신호로 재작성 |
| `TP-SYN-F02` | `SHOULD_ADAPT` | C에서 momentum 5와 단서가 중복되어 불확실성 소멸 | 동일 상태의 competing intent fixture를 패킷에 추가 |
| `TP-SYN-F03` | `TEST_REQUIRED` | 범용 3수 안정 계획이 단서 활용을 지배하는지 문서만으로 판정 불가 | fixture 기반 cue-informed/agnostic 계획 결과 비교 필요 |
| `TP-SYN-F04` | `SHOULD_ADAPT` | 계획을 바꾸지 않고 설명만 단서에 맞추는 사후 합리화 가능 | 단서 공개 전 baseline 3수 계획을 먼저 기록 |
| `TP-SYN-F05` | `SHOULD_ADAPT` | 차선 가설 요구가 작업기억·문서 노동을 과도하게 늘릴 수 있음 | 단계형 기록과 상태 사실 선택 UI 후보 검토 |
| `TP-SYN-F06` | `COUNTEREXAMPLE` | 모호성을 높이면 초보자에게 무작위 찍기로 느껴질 수 있음 | 모든 단서를 약화하지 말고 category-level 정보량 유지 |

## 4. 권장 수정

사람 세션 패킷의 제품 규칙을 바꾸지 않고 다음 연구 자극물만 수정한다.

1. **baseline plan 선기록**: 상태만 본 3수 계획을 먼저 기록하고 단서 공개 뒤 변경점을 비교한다.
2. **단서 어휘 분리**: `빠르게`, `절초`, `회복`처럼 가설 이름과 직접 매칭되는 단어를 제거한다.
3. **동일 상태 경쟁 fixture**: momentum 5에서도 `ultimate`와 `heavy_prepare`가 모두 가능한 카드 쌍을 준비한다.
4. **범용 계획 공격 질문**: “단서를 무시해도 같은 계획이 최선인가?”를 적대적 질문으로 추가한다.
5. **단계형 기록**: 상태 사실 → 주 가설 → 차선 가설 → 계획 변경 순서로 나눈다.

## 5. 적대적 검토

```yaml
strongest_case_for_current_direction: 방향성 단서는 완전 비공개보다 계획 근거와 결과 복기를 연결할 가능성이 높음
strongest_case_against_current_direction: 현재 문구는 추론보다 의미 매칭을 측정하며 범용 계획이 존재하면 단서가 장식화될 수 있음
hidden_assumption: 올바른 가설이 실제로 다른 3수 계획을 요구한다는 가정
dominant_strategy_risk: 방어-간보기-반격 범용 묶음
facilitator_or_copy_bias: 단서 문구가 가설명을 직접 암시
fidelity_confound: 카드 이해와 실제 전투 인과가 분리되어 있음
canon_conflict_check: NO_CONFLICT
product_path_intrusion_check: NONE
verdict: ADAPT
```

## 6. 판정

```yaml
decision: ADAPT
reason: 방향성 정보의 목적은 유지하지만 정답 누출·범용 계획·사후 합리화 결함을 사람/fixture 테스트 전에 교정해야 함
human_validation: NOT_RUN
runtime_causality: NOT_RUN
actual_fun: NOT_RUN
implementation_authority: NONE
canon_changed: false
next_gate: UPDATE_RESEARCH_STIMULUS_THEN_RUN_FIXTURE_OR_HUMAN_TEST_WHEN_AVAILABLE
```

이 보고서는 v6 결정 원장이나 제품 구현을 변경하지 않는다.
