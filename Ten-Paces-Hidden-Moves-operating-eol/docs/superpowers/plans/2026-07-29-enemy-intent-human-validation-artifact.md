# 적 의도 단서 사람 검증 Artifact 실행 계획 — 합성 위험 교정판

```yaml
session_packet_id: TEN-PACES-HV-001
project: 십보강호
baseline_branch: main
baseline_commit: 908633e66fe0ece3f3ba533df0b9a202f6f3d2d5
base_governance_commit: 9c4071c5ecefe28769b512d426442338ceb7acdd
base_governance_path: docs/knowledge/game-development/HUMAN_VALIDATION_ARTIFACT_GOVERNANCE.md
base_synthetic_governance_path: docs/knowledge/game-development/SYNTHETIC_TESTER_SIMULATION_GOVERNANCE.md
synthetic_review_source: docs/research/2026-07-29_ENEMY_INTENT_SYNTHETIC_TESTER_REPORT.md
artifact_status: READY_AFTER_SYNTHETIC_REMEDIATION
human_validation: NOT_RUN
implementation_authority: NONE
```

> 이 문서는 연구 준비와 사람 관찰만 승인한다. v6 결정 원장, 전투 수치, AI, 행동 우선순위, Scene·Script·JSON을 변경하지 않는다.

## 1. 결정 질문

> 방향성 단서가 정확한 다음 행동을 공개하지 않으면서도, 플레이어가 공개 상태만 보고 세운 계획을 단서 공개 뒤 근거 있게 수정하고 주 가설·차선 가설을 함께 유지하게 하는가?

## 2. Artifact fidelity와 주장 상한

```yaml
artifact_fidelity:
  stage_0: CARD_STATE_ONLY
  stage_1: CARD_WITH_DIRECTIONAL_SIGNALS
  stage_2: EXISTING_POC_OVERLAY
simulated_components:
  - PROTOTYPE_ONLY_SIGNAL 카드
scripted_components:
  - 카드 기반 실제 의도·설명 공개
fixed_outcomes:
  - 시나리오 A/B 연구용 의도
  - 시나리오 C의 동일 공개 카드·교차 hidden intent
claim_ceiling:
  can_claim:
    - 공개 상태만 본 계획과 단서 후 계획의 차이
    - 단서 용어와 공개 상태를 함께 연결하는지
    - 주 가설과 차선 가설을 함께 만드는지
    - 단서가 정답 공개·찍기·범용 계획 합리화로 읽히는 반복 결함
  cannot_claim:
    - 실제 AI가 항상 해당 의도를 선택한다는 것
    - 실제 전투 밸런스와 재미 통과
    - 최종 애니메이션·UI·접근성 통과
    - 전체 플레이어 집단에 대한 통계적 일반화
```

### 실제 전투 인과 사용 조건

- 카드 이해 검증과 실제 전투 인과 검증을 분리한다.
- 실제 전투 결과를 증거로 사용할 때는 AI 의도와 행동 묶음을 고정하는 fixture 또는 재현 가능한 seed가 있어야 한다.
- fixture·seed가 없거나 결과가 문서와 다르면 runtime 결과를 증거로 사용하지 않고 카드 기반 이해 검증만 수행한다.
- 불일치가 한 번이라도 발생하면 해당 runtime 세션은 `STOP`으로 분류한다.

## 3. 보호 경계와 기존 실행 경로

| 역할 | 경로 |
|---|---|
| 실행 Scene | `scenes/combat/combat_board_preview.tscn` |
| 전투 연결 | `src/combat/combat_board_preview.gd` |
| 가설 UI | `scenes/ui/opponent_hypothesis_panel.tscn`, `src/ui/opponent_hypothesis_panel.gd` |
| 복기 UI | `scenes/ui/combat_review_panel.tscn`, `src/ui/combat_review_panel.gd` |
| 가설 데이터 | `data/combat/combat_hypothesis_poc.json` |
| 전투 기준 | `data/combat/combat_board_poc.json` |

고정 가설은 `approach / quick_attack / heavy_prepare / response_or_recover / ultimate / none`이며, `3수 → 해결 → 3수 → 해결 → 4수 → 해결` 구조를 유지한다.

## 4. 최소 세션 패킷

1. 공개 상태 카드: 거리, 체력·기력·내력·기세, 최근 해결 결과.
2. `pre_signal_plan` 기록지: 상태만 보고 세운 3수 계획과 최악 상황 대비 이유.
3. 방향성 단서 카드 2장: 아이콘+문구, `PROTOTYPE_ONLY_SIGNAL` 표시.
4. 가설 기록지: 주 가설, 차선 가설, 상태 사실, 사용 단서, 단서 후 계획.
5. `plan_change_delta` 기록지: 유지·교체한 수와 근거, 단서를 무시해도 같은 계획인지 여부.
6. 해결 후 복기지: 실제 또는 scripted 결과, 귀인, 다음 수정안.
7. 진행자 개입 기록지: 질문·설명·교정·결과 공개 시점.

## 5. 시나리오

단서 문구는 `빠르게`, `회복`, `강공`, `절초`처럼 가설 이름과 직접 대응하는 단어를 사용하지 않는다. 자세·리듬·자원 변화 범주의 관측만 제공한다.

### A — 원거리의 전진 압력

```yaml
scenario_id: TP-INTENT-A
bundle: 1
distance: 3
signals:
  - "앞발 뒤꿈치가 들리고 어깨선이 전방으로 좁아진다"
  - "검끝이 짧은 호흡마다 한 번씩 낮아진다"
primary_research_intent: quick_attack
competing_hypotheses: [approach, heavy_prepare]
```

### B — 근거리의 폐쇄 자세

```yaml
scenario_id: TP-INTENT-B
bundle: 2
distance: 1
recent_resolution: "상대 피해·기력 소비, 내력 유지"
signals:
  - "검을 몸 가까이 거두고 팔꿈치가 닫힌다"
  - "체중이 뒷발에 머문 채 시선이 손과 거리 사이를 오간다"
primary_research_intent: response_or_recover
competing_hypotheses: [heavy_prepare, quick_attack]
```

### C — 최고 기세의 큰 자세: 동일 공개 카드 교차 fixture

참가자에게는 아래 공개 상태와 단서만 보여준다. 진행자 key에서만 `C-U` 또는 `C-H`를 교차 배정한다. 공개 카드만으로 한 답이 확정되면 결함이다.

```yaml
scenario_id: TP-INTENT-C
bundle: 3
distance: 2
enemy_momentum: 5
bundle_size: 4
signals:
  - "검로를 몸 바깥으로 크게 열고 발 간격을 넓힌다"
  - "호흡 사이마다 기세 변화가 멈추고 자세가 고정된다"
public_competing_hypotheses: [ultimate, heavy_prepare, approach]
hidden_key_variants:
  C-U:
    research_intent: ultimate
  C-H:
    research_intent: heavy_prepare
assignment:
  group_1: [C-U, C-H]
  group_2: [C-H, C-U]
```

`C-U/C-H`는 제품 AI 확률이나 최종 행동 규칙이 아니라, 동일 상태에서 경쟁 가설이 실제로 살아 있는지 공격하는 연구용 fixture다.

## 6. 진행자 스크립트

> 정확한 다음 수를 맞히는 시험이 아닙니다. 먼저 공개 상태만 보고 세 수를 정해 주세요. 이후 두 단서를 본 뒤 무엇을 유지하거나 바꿨는지, 가장 유력한 가설과 아직 남는 다른 가능성을 설명해 주세요.

1. 상태만 공개한다.
2. 피드백 없이 `pre_signal_plan`, `pre_signal_plan_reason`, `worst_case_covered`를 기록한다.
3. 두 단서를 공개한다.
4. `post_signal_primary`, `post_signal_secondary`, `post_signal_plan`을 기록한다.
5. `plan_change_delta`에 유지·교체한 수와 단서가 없어도 같은 계획을 썼을지 기록한다.
6. 카드 이해 단계에서는 배정된 scripted 의도 카드를 공개한다.
7. runtime 단계는 fixture·seed가 확인된 경우만 실행한다.
8. 공개한 결과와 설명을 `facilitator_intervention`에 기록한다.
9. `post_feedback_attempt`로 바꿀 가설·다음 계획을 기록한다.
10. 행동 기록 뒤 자기보고를 질문한다.

진행자는 가설 선택을 칭찬·추천하거나 참가자의 문장을 완성하지 않는다. 단서 공개 전에 가설명이나 예상 행동을 언급하지 않는다.

## 7. 참가자와 기록

```yaml
pilot_purpose: DIRECTIONAL_FINDING_AND_DEFECT_DISCOVERY
minimum_participants: 6
segments:
  low_tactical_experience: 3
  experienced_tactical_or_roguelike: 3
order:
  group_1: [A, B, C-U, C-H]
  group_2: [C-H, C-U, B, A]
session_minutes: 30-40
```

한 참가자·시나리오당 다음을 분리 기록한다.

- `pre_signal_plan`, `pre_signal_plan_reason`, `worst_case_covered`.
- `post_signal_primary`, `post_signal_secondary`, `state_fact_used`, `signal_used`.
- `post_signal_plan`, `plan_change_delta`, `unchanged_plan_reason`.
- 동일 범용 계획 반복 여부와 단서 없이도 같은 계획을 선택했는지.
- `facilitator_intervention`.
- `post_feedback_hypothesis`, `post_feedback_plan`.
- `behavior_observation`, `player_self_report`.
- fixture/seed 또는 scripted 카드 ID.
- 심각도 높은 `critical_incident`.

## 8. 판정

비율은 `n/N` 참고값으로만 기록한다.

```yaml
PROMISING_DIRECTION:
  required_patterns:
    - "서로 다른 참가자 2명 이상이 상태 사실과 단서를 함께 사용해 주·차선 가설을 설명"
    - "단서 후 계획 변화 또는 계획 유지의 구체적 근거를 제시"
    - "C-U/C-H에서 공개 카드만으로 한 의도를 확정 답으로 취급하지 않음"
    - "심각도 높은 규칙 불일치 또는 단일 정답 누출 없음"
  claim: "더 높은 fidelity의 적 의도 표현 Prototype로 진행할 방향을 지지"
ADAPT:
  condition: "핵심 추론은 보이지만 특정 단서의 정답화·과밀·용어 혼란 또는 범용 계획 반복이 나타남"
REWORK:
  condition: "상태와 단서를 연결하지 못하거나 단서가 계획 변화·유지 근거로 이어지지 않음"
REJECT:
  condition: "정답 아이콘 추종·근거 없는 찍기·단서 무시 범용 계획이 핵심 행동보다 우세함"
STOP:
  condition: "카드·fixture·실제 전투 규칙 불일치 또는 단서 공개 전 진행자 정답 누출"
```

이 fidelity에서는 `ADOPT`를 선언하지 않는다.

## 9. 현재 상태

```yaml
synthetic_must_fix_applied:
  direct_answer_copy_removed: true
  pre_signal_plan_added: true
  same_state_competing_fixture_added: true
human_session_executed: false
product_runtime_causality: NOT_RUN_UNLESS_FIXTURE_OR_SEED
final_ui: NOT_RUN
accessibility: NOT_RUN
performance: NOT_RUN
external_sample: NOT_RUN
human_validation: NOT_RUN
product_code_changed: false
canon_changed: false
implementation_authority: NONE
next_gate: RUN_REVISED_DIRECTIONAL_PILOT_AND_WRITE_SEPARATED_EVIDENCE_REPORT
```
