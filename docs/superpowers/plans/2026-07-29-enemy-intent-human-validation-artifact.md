# 적 의도 단서 사람 검증 Artifact 실행 계획 — Governance 교정판

```yaml
session_packet_id: TEN-PACES-HV-001
project: 십보강호
baseline_branch: main
baseline_commit: 65dc63ca78b7c8f8bc5ae2f33c75362fcc154909
base_governance: BASE_PR_56_PENDING_MERGE
base_governance_path: docs/knowledge/game-development/HUMAN_VALIDATION_ARTIFACT_GOVERNANCE.md
base_template_path: templates/research/HUMAN_VALIDATION_SESSION_PACKET.md
artifact_status: READY_FOR_HUMAN_SESSION_PREPARATION
human_validation: NOT_RUN
implementation_authority: NONE
```

> 이 문서는 연구 준비와 사람 관찰만 승인한다. v6 결정 원장, 전투 수치, AI, 행동 우선순위, Scene·Script·JSON을 변경하지 않는다.

## 1. 결정 질문

> 방향성 단서가 정확한 다음 행동을 공개하지 않으면서도, 플레이어가 공개 상태와 단서를 연결해 주 가설·차선 가설을 만들고 3수 계획을 수정하게 하는가?

## 2. Artifact fidelity와 주장 상한

```yaml
artifact_fidelity:
  stage_1: CARD
  stage_2: EXISTING_POC_OVERLAY
simulated_components:
  - PROTOTYPE_ONLY_SIGNAL 카드
scripted_components:
  - 카드 기반 실제 의도·설명 공개
fixed_outcomes:
  - 시나리오 A/B/C 연구용 의도
claim_ceiling:
  can_claim:
    - 단서 용어와 공개 상태를 연결하는지
    - 주 가설과 차선 가설을 함께 만드는지
    - 결과 뒤 다음 계획 수정안을 설명하는지
    - 단서가 정답 공개 또는 찍기로 읽히는 반복 결함
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

고정 가설:

- `approach`
- `quick_attack`
- `heavy_prepare`
- `response_or_recover`
- `ultimate`
- `none`

한 라운드의 `3수 → 해결 → 3수 → 해결 → 4수 → 해결` 구조를 유지한다.

## 4. 최소 세션 패킷

1. 공개 상태 카드: 거리, 체력·기력·내력·기세, 최근 해결 결과.
2. 방향성 단서 카드 2장: 아이콘+문구, `PROTOTYPE_ONLY_SIGNAL` 표시.
3. 가설 기록지: 주 가설, 차선 가설, 상태 사실, 사용 단서, 계획 이유.
4. 해결 후 복기지: 실제 또는 scripted 결과, 귀인, 다음 수정안.
5. 진행자 개입 기록지: 질문·설명·교정·결과 공개 시점.

## 5. 시나리오

### A — 원거리 접근과 속공

```yaml
scenario_id: TP-INTENT-A
bundle: 1
distance: 3
signals:
  - "앞으로 체중을 싣는다"
  - "첫 수를 빠르게 끊으려는 기색"
primary_research_intent: quick_attack
competing_hypotheses: [approach, heavy_prepare]
```

관찰: 거리와 두 단서를 함께 사용해 `quick_attack`과 `approach`를 비교하는가.

### B — 근거리 대응·회복과 강공 준비

```yaml
scenario_id: TP-INTENT-B
bundle: 2
distance: 1
recent_resolution: "상대 피해·기력 소비, 내력 유지"
signals:
  - "검을 몸 가까이 거둔다"
  - "호흡을 다시 고른다"
primary_research_intent: response_or_recover
competing_hypotheses: [heavy_prepare, quick_attack]
```

관찰: 회복·방어를 예상하면서도 반격 가능성을 완전히 제거하지 않는가.

### C — 최고 기세의 절초와 강공

```yaml
scenario_id: TP-INTENT-C
bundle: 3
distance: 2
enemy_momentum: 5
bundle_size: 4
signals:
  - "검로를 길게 연다"
  - "기세가 한 점으로 모인다"
primary_research_intent: ultimate
competing_hypotheses: [heavy_prepare, approach]
```

관찰: 공개 기세 5가 이미 정답 표시인지, 단서가 유의미한 비교 정보를 추가하는지 본다.

## 6. 진행자 스크립트

시작 문구:

> 정확한 다음 수를 맞히는 시험이 아닙니다. 공개 상태와 두 단서로 가장 유력한 가설과 아직 남는 다른 가능성을 설명하고, 그 판단이 3수 계획에 어떤 영향을 주는지 말해 주세요.

시나리오 순서:

1. 상태 카드 공개.
2. 단서 카드 공개.
3. **피드백 전 first attempt**로 주·차선 가설과 계획 이유 기록.
4. 카드 이해 단계에서는 scripted 의도 카드를 공개한다.
5. runtime 단계는 fixture·seed가 확인된 경우만 실행한다.
6. 공개한 결과와 진행자 설명을 `facilitator_intervention`에 기록한다.
7. **post-feedback attempt**로 바꿀 가설·계획을 기록한다.
8. 자기보고는 행동 기록 뒤에 질문한다.

진행자는 가설 선택을 칭찬·추천하거나 참가자의 문장을 완성하지 않는다.

## 7. 참가자와 순서

```yaml
pilot_purpose: DIRECTIONAL_FINDING_AND_DEFECT_DISCOVERY
minimum_participants: 6
segments:
  low_tactical_experience: 3
  experienced_tactical_or_roguelike: 3
order:
  group_1: [A, B, C]
  group_2: [C, B, A]
session_minutes: 25-35
```

6명 결과는 통계적 유의성이나 전체 유저 일반화를 의미하지 않는다.

## 8. 관찰 기록

한 참가자·시나리오당 한 행을 기록한다.

| 필드 | 정의 |
|---|---|
| `participant_id` | 개인정보 없는 코드 |
| `segment` | LOW / EXPERIENCED |
| `scenario_id` | A/B/C |
| `first_attempt_primary` | 피드백 전 주 가설 |
| `first_attempt_secondary` | 피드백 전 차선 가설 |
| `state_fact_used` | 참가자가 언급한 공개 사실 |
| `signal_used` | 언급한 단서 |
| `first_plan_reason` | 참가자 핵심 표현 |
| `facilitator_intervention` | 결과·설명·교정 문구와 시점 |
| `post_feedback_hypothesis` | 피드백 뒤 수정 가설 |
| `post_feedback_plan` | 다음 계획 수정안 |
| `behavior_observation` | 실제 선택·시간·되돌리기 |
| `player_self_report` | 정답 공개감·찍기감·이유 |
| `system_or_artifact_log` | fixture/seed 또는 scripted 카드 ID |
| `critical_incident` | 정답 누출·규칙 불일치·정보 미확인 |

## 9. 판정

비율은 `n/N` 참고값으로만 기록한다. 다음 순서로 판정한다.

1. 규칙·fixture·카드 불일치가 있으면 `STOP`.
2. 심각도 높은 정답 누출·근거 없는 찍기 사례 확인.
3. 서로 다른 참가자 2명 이상에게 반복된 동일 결함 확인.
4. LOW와 EXPERIENCED의 차이 확인.
5. 행동, 자기보고, 진행자 개입을 비교.

```yaml
PROMISING_DIRECTION:
  required_patterns:
    - "서로 다른 참가자 2명 이상이 상태 사실과 단서를 함께 사용해 주·차선 가설을 설명"
    - "결과 뒤 구체적인 다음 계획 수정안 제시"
    - "심각도 높은 규칙 불일치 또는 단일 정답 누출 없음"
  claim: "더 높은 fidelity의 적 의도 표현 Prototype로 진행할 방향을 지지"
ADAPT:
  condition: "핵심 추론은 보이지만 특정 단서의 정답화·과밀·용어 혼란이 반복됨"
REWORK:
  condition: "상태와 단서를 연결하지 못하거나 계획 수정으로 이어지지 않음"
REJECT:
  condition: "정답 아이콘 추종 또는 근거 없는 찍기가 핵심 행동보다 우세함"
STOP:
  condition: "카드·fixture·실제 전투 규칙 불일치 또는 진행자 정답 누출"
```

이 fidelity에서는 `ADOPT`를 선언하지 않는다.

## 10. 미실행 검증과 현재 상태

```yaml
product_runtime_causality: NOT_RUN_UNLESS_FIXTURE_OR_SEED
final_ui: NOT_RUN
accessibility: NOT_RUN
performance: NOT_RUN
external_sample: NOT_RUN
human_validation: NOT_RUN
product_code_changed: false
canon_changed: false
implementation_authority: NONE
next_gate: RUN_DIRECTIONAL_PILOT_AND_WRITE_SEPARATED_EVIDENCE_REPORT
```
