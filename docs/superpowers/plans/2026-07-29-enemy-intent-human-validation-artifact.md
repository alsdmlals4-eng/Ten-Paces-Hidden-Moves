# 적 의도 단서 사람 검증 Artifact 실행 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans only after a separate product-build approval. This document itself authorizes research preparation and human observation only.

**Goal:** 기존 REPEAT_POC A2·A3 가설 기록·복기 흐름을 이용해, 방향성 단서가 추론을 만들면서 정확 정답 공개나 찍기로 변질되지 않는지 사람 증거로 판정한다.

**Architecture:** 제품 전투 규칙과 AI를 바꾸지 않는다. 현재 실행 Scene과 가설·복기 UI를 그대로 사용하고, 전투 묶음 전에 보여줄 연구용 단서 카드와 관찰 기록지만 별도 Artifact로 운용한다. 단서 카드는 `PROTOTYPE_ONLY_SIGNAL`이며 v6 정본이나 실제 애니메이션 계약이 아니다.

**Tech Stack:** Godot 4.7, `res://scenes/combat/combat_board_preview.tscn`, 기존 `OpponentHypothesisPanel`, 기존 `CombatReviewPanel`, Markdown 연구 카드, 수기 또는 스프레드시트 관찰 기록.

## Global Constraints

- 기준 `main`: `9cfe94dc900ada7b3501327e86ac73b2c7f8ee7d`.
- 상위 Evidence Pack: `docs/decisions/2026-07-29_ENEMY_INTENT_EVIDENCE_PACK_PILOT.md`.
- 최신 설계 권한: `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.
- 한 라운드의 `3수 → 해결 → 3수 → 해결 → 4수 → 해결` 구조를 바꾸지 않는다.
- AI는 플레이어의 미확정 계획을 읽지 않는다.
- 전투 수치·행동·AI 후보·판정 우선순위를 바꾸지 않는다.
- 사람 플레이 전 `VALIDATED`, `ADOPTED`, `MVP_COMPLETE`를 사용하지 않는다.
- 제품 코드·데이터·Scene 변경은 별도 사용자 승인 전 금지한다.

---

## 1. 검증 대상과 현재 실행 경로

### 기존 실행 자산

| 역할 | 현재 경로 |
|---|---|
| 실행 Scene | `scenes/combat/combat_board_preview.tscn` |
| 전투 연결 | `src/combat/combat_board_preview.gd` |
| 가설 선택 UI | `scenes/ui/opponent_hypothesis_panel.tscn` / `src/ui/opponent_hypothesis_panel.gd` |
| 복기 UI | `scenes/ui/combat_review_panel.tscn` / `src/ui/combat_review_panel.gd` |
| 가설 데이터 | `data/combat/combat_hypothesis_poc.json` |
| 전투 기준 | `data/combat/combat_board_poc.json` |
| 가설 자동 계약 | `tests/verify_combat_hypothesis.gd`, `tests/check_repeat_poc_a2_contract.py` |
| 복기 자동 계약 | `tests/verify_combat_review_ui.gd`, `tests/check_repeat_poc_a3_contract.py` |

### 고정 가설 목록

- `approach` — 접근
- `quick_attack` — 속공
- `heavy_prepare` — 강공 준비
- `response_or_recover` — 대응·회복
- `ultimate` — 절초
- `none` — 기록한 가설 없음

이번 검증은 가설 종류를 추가하지 않는다.

## 2. 최소 Artifact 구성

검증 진행자는 다음 네 묶음을 한 세션 패킷으로 사용한다.

1. **상태 카드:** 현재 거리, 체력·기력·내력·기세, 최근 해결 결과.
2. **방향성 단서 카드:** 묶음당 2개, 색상 외 아이콘과 짧은 문구 병행.
3. **가설 기록지:** 참가자가 선택한 가설과 3수 계획 이유를 한 문장으로 기록.
4. **해결 후 복기지:** 실제 행동, 단서 연결, 계획이 막은 것과 허용한 것, 다음 수정안을 기록.

Artifact는 전투 화면 위에 덧붙이는 연구 보조물이다. 실제 UI 자산이나 최종 카피로 승격하지 않는다.

## 3. 연구용 시나리오 카드

### 시나리오 A — 원거리에서 접근과 속공 구분

```yaml
scenario_id: TP-INTENT-A
bundle: 1
board_state:
  player_tile: 4
  enemy_tile: 7
  distance: 3
always_visible:
  - 현재 거리 3
  - 양측 공개 자원
  - 최근 해결 결과 없음
prototype_only_signals:
  - 아이콘: 전진 발끝 / 문구: "앞으로 체중을 싣는다"
  - 아이콘: 짧은 호흡 / 문구: "첫 수를 빠르게 끊으려는 기색"
allowed_hypotheses:
  - approach
  - quick_attack
  - heavy_prepare
research_reveal:
  actual_intent: quick_attack
  explanation: "속공 가능성을 높이는 단서였지만 접근 준비와도 양립할 수 있어 단일 정답 표시는 아니다."
```

관찰 핵심: 참가자가 `속공`을 골랐는지가 아니라, 공개 거리와 두 단서를 근거로 복수 가능성을 비교하는지 본다.

### 시나리오 B — 근거리에서 대응·회복과 강공 준비 구분

```yaml
scenario_id: TP-INTENT-B
bundle: 2
board_state:
  distance: 1
  recent_resolution: "첫 묶음에서 상대가 피해를 입고 기력을 소비함"
always_visible:
  - 현재 거리 1
  - 상대 기력 감소
  - 상대 내력 유지
prototype_only_signals:
  - 아이콘: 닫힌 상체 / 문구: "검을 몸 가까이 거둔다"
  - 아이콘: 긴 들숨 / 문구: "호흡을 다시 고른다"
allowed_hypotheses:
  - response_or_recover
  - heavy_prepare
  - quick_attack
research_reveal:
  actual_intent: response_or_recover
  explanation: "회복·방어 쪽 단서가 강하지만 반격 준비와 완전히 분리되지는 않는다."
```

관찰 핵심: 참가자가 방어·회복을 예상하면서도 공격 가능성을 완전히 배제하지 않는지 본다.

### 시나리오 C — 최고 기세에서 절초와 강공 준비 구분

```yaml
scenario_id: TP-INTENT-C
bundle: 3
board_state:
  distance: 2
  enemy_momentum: 5
  bundle_size: 4
always_visible:
  - 상대 기세 5
  - 현재 거리 2
  - 마지막 4수 묶음
prototype_only_signals:
  - 아이콘: 크게 열린 검로 / 문구: "검로를 길게 연다"
  - 아이콘: 모인 기세 / 문구: "기세가 한 점으로 모인다"
allowed_hypotheses:
  - ultimate
  - heavy_prepare
  - approach
research_reveal:
  actual_intent: ultimate
  explanation: "절초가 유력하지만 거리 조정이나 강공 준비가 대안으로 남아야 한다."
```

관찰 핵심: 기세 5라는 항상 공개 정보가 단서를 대신하는 정답 아이콘이 되는지, 단서가 불필요하게 중복되는지 본다.

## 4. 진행자 스크립트

### 시작 안내

다음 문장을 그대로 읽는다.

> "상대의 정확한 다음 수를 맞히는 시험이 아닙니다. 화면에서 확인한 상태와 두 단서를 이용해 가장 그럴듯한 가설을 세우고, 다른 가능성이 남는지도 설명해 주세요. 틀린 선택도 실패가 아니라 단서가 어떻게 읽혔는지 확인하는 자료입니다."

### 시나리오당 순서

1. 상태 카드를 10초 동안 보여준다.
2. 방향성 단서 카드 2개를 동시에 공개한다.
3. 참가자에게 가장 유력한 가설 1개와 차선 가설 1개를 말하게 한다.
4. 현재 PoC에서 3수 계획을 구성하게 한다.
5. 진행 직전에 선택 가설과 계획 이유를 기록한다.
6. 묶음을 해결한다.
7. 기존 `CombatReviewPanel`을 먼저 읽게 한다.
8. 연구용 실제 의도·단서 설명 카드를 추가로 보여준다.
9. 다음 묶음에서 바꿀 계획을 한 문장으로 말하게 한다.

진행자는 정답 여부를 칭찬하거나 힌트를 주지 않는다.

## 5. 참가자 구성과 순서

```yaml
minimum_participants: 6
segments:
  low_tactical_experience: 3
  experienced_tactical_or_roguelike: 3
session_minutes: 25-35
scenario_order:
  participant_1_3: [A, B, C]
  participant_4_6: [C, B, A]
```

순서를 역전해 학습 효과와 피로 편향을 줄인다. 동일 참가자에게 단서 문구를 중간에 수정하지 않는다.

## 6. 관찰 기록지

시나리오마다 한 행을 기록한다.

| 필드 | 기록 규칙 |
|---|---|
| `participant_id` | 개인 식별정보가 없는 코드 |
| `experience_segment` | `LOW` 또는 `EXPERIENCED` |
| `scenario_id` | A/B/C |
| `primary_hypothesis` | 고정 가설 ID |
| `secondary_hypothesis` | 고정 가설 ID 또는 `none` |
| `state_fact_used` | 참가자가 실제로 언급한 항상 공개 정보 |
| `signal_used` | 언급한 단서 0~2개 |
| `plan_reason` | 참가자의 표현을 요약하지 말고 핵심 문구 기록 |
| `decision_seconds` | 단서 공개부터 진행 요청까지 |
| `changed_plan_count` | 묶음 확정 전 수정 횟수 |
| `post_result_attribution` | `CLUE_INTERPRETATION / RANDOMNESS / UI_CONFUSION / RULE_MISMATCH / OTHER` |
| `next_adjustment` | 다음 계획 수정안 |
| `exact_answer_feeling` | 1~5, 5는 사실상 정답 공개 |
| `guessing_feeling` | 1~5, 5는 근거 없는 찍기 |
| `observer_note` | 오터치·정보 미확인·색상 의존 등 관찰 사실 |

## 7. 계산식과 판정 기준

### 계산

- 합리적 가설 형성: 상태 사실 1개 이상과 단서 1개 이상을 근거로 주·차선 가설을 설명한 세션.
- 단서 기반 실패 귀인: 틀린 결과 뒤 `CLUE_INTERPRETATION`을 말하고 다음 수정안을 제시한 세션.
- 단일 정답화: 주·차선 가설 없이 한 가설만 가능하다고 말하며 `exact_answer_feeling >= 4`인 세션.
- 찍기화: 상태 사실과 단서를 하나도 언급하지 못하고 `guessing_feeling >= 4`인 세션.

### Pilot 판정

```yaml
ADOPT:
  rational_hypothesis_rate: ">= 0.75"
  clue_based_attribution_rate: ">= 0.67"
  single_answer_rate: "<= 0.25"
  guessing_rate: "<= 0.25"
  median_decision_seconds_per_bundle: "<= 90"
ADAPT:
  condition: "핵심 가설 형성은 보이나 단서 하나의 정답화·과밀·접근성 문제가 반복됨"
REWORK:
  condition: "신규 참가자 다수가 상태와 단서를 연결하지 못하거나 계획 시간이 120초를 반복 초과함"
REJECT:
  condition: "추론보다 정답 아이콘 추종 또는 근거 없는 찍기가 우세함"
STOP:
  condition: "연구 카드 설명과 실제 전투 결과·자원·거리 규칙이 불일치함"
```

표본 6명은 방향성 판단용이며 통계적 일반화를 주장하지 않는다.

## 8. 증거 저장 계약

사람 테스트를 실행한 뒤에만 다음 파일을 별도 PR로 생성한다.

```text
docs/validation/2026-XX-XX_ENEMY_INTENT_HUMAN_VALIDATION_REPORT.md
```

보고서에는 다음만 기록한다.

- 실행한 `main` SHA와 Godot 버전.
- 참가자 수와 구분.
- 시나리오별 원자료 표.
- 계산식 결과.
- 예상과 달랐던 행동.
- `ADOPT / ADAPT / REWORK / REJECT` 판정.
- v6 정본 변경 필요 여부.
- 구현 권한과 미실행 검증 상태.

원자료에 이름·연락처·음성 파일 경로를 기록하지 않는다.

## 9. 실행 작업

### Task 1: 기준선 고정

**Files:** 읽기 전용으로 `project.godot`, `data/combat/combat_board_poc.json`, `data/combat/combat_hypothesis_poc.json`을 확인한다.

- [ ] 실행 직전 `main` SHA를 기록한다.
- [ ] Godot 4.7에서 메인 Scene이 열리는지 확인한다.
- [ ] 가설 6개와 3/3/4 순서가 이 문서와 일치하는지 확인한다.
- [ ] 불일치 시 사람 테스트를 시작하지 않는다.

### Task 2: 세션 패킷 준비

**Files:** 이 문서의 시나리오 카드와 기록지를 인쇄하거나 읽기 전용 화면으로 준비한다.

- [ ] A/B/C 카드의 `PROTOTYPE_ONLY_SIGNAL` 표시를 유지한다.
- [ ] 실제 정답 카드는 참가자 응답 전 숨긴다.
- [ ] 상태 카드와 단서 카드가 색상 없이도 구분되는지 확인한다.

### Task 3: 파일럿 실행

- [ ] LOW 3명과 EXPERIENCED 3명을 분리 기록한다.
- [ ] 참가자 1~3과 4~6의 시나리오 순서를 반대로 적용한다.
- [ ] 행동 관찰과 사후 자기보고를 별도 열에 기록한다.
- [ ] 규칙 불일치가 한 번이라도 발견되면 해당 세션을 중단한다.

### Task 4: 판정 보고

- [ ] 계산식을 동일하게 적용한다.
- [ ] 재미있다는 응답만으로 통과시키지 않는다.
- [ ] 정답률 자체를 성공 지표로 사용하지 않는다.
- [ ] 사람 증거가 없으면 상태를 계속 `HUMAN_VALIDATION_NOT_RUN`으로 유지한다.

## 10. 적대적 셀프 리뷰

- 단서 카드가 실제 최종 애니메이션으로 오인될 수 있음 → 모든 카드에 `PROTOTYPE_ONLY_SIGNAL` 유지.
- 실제 의도 공개가 사후 정답 강의가 될 수 있음 → 대안 가설이 왜 가능했는지도 함께 설명.
- 숙련자가 기존 규칙 지식만으로 답할 수 있음 → 차선 가설과 근거를 반드시 요구.
- 신규 플레이어가 카드 용어를 이해하지 못할 수 있음 → 고정 가설 라벨과 설명은 기존 `combat_hypothesis_poc.json` 문구 사용.
- 6명 결과를 제품 전체의 재미 증명으로 과장할 수 있음 → Pilot 판정만 허용하고 MVP·T1 게이트와 분리.

## 11. 현재 상태

```yaml
artifact_status: READY_FOR_HUMAN_SESSION_PREPARATION
product_code_changed: false
canon_changed: false
human_validation: NOT_RUN
implementation_authority: NONE
next_gate: RUN_SIX_PARTICIPANT_PILOT_AND_WRITE_REPORT
rollback: remove this document only
```
