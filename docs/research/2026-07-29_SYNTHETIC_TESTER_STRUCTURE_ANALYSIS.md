# 십보강호 합성 테스터 적용 구조 분석

```yaml
analysis_id: TEN-PACES-SYNTH-STRUCTURE-001
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
baseline_branch: main
baseline_commit: 929b4b545e9a41e38d8b6d43dfcdd478daae0057
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
validation_method: SYNTHETIC_TESTER_SIMULATION
evidence_tier: T6_AI_INFERENCE
human_validation: NOT_RUN
implementation_authority: NONE
base_governance_source: Base PR #61
```

## 1. 분석 목적

적 의도 단서 사람 검증 패킷을 AI 가상 페르소나로 사전 공격하려면, 십보강호의 현재 Skill·정본·작업 게이트를 먼저 복원해야 한다. 이 분석서는 합성 결과가 v6 결정 원장이나 실제 전투 검증으로 오인되지 않도록 실행 책임을 고정한다.

## 2. 콜드 스타트 구조

```text
START_HERE.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ [기획서]/00_프로젝트_허브/SKILL_REGISTRY.json
→ v6 결정 권한 원장
→ 적 의도 Evidence Pack
→ 사람 검증 Artifact
→ 프로젝트 Skill·Base Skill
→ QA·적대적 검토
```

현재 프로젝트는 기획 승인 단계이며 런타임 구현·제품 변경 권한을 갖지 않는다. 합성 시뮬레이션은 사람 검증을 실행한 것이 아니며 기존 전투 Scene·Script·JSON을 수정하지 않는다.

## 3. current_skill_registry

`[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`은 Base Skill Route와 프로젝트 전용 Skill을 함께 관리한다.

### selected_project_skills

| Skill | Mode | 책임 |
|---|---|---|
| `ten-paces-game-design` | `playtest-recalibration` | 적 의도 추론·3수 계획·결과 복기의 설계 위험을 기획 질문으로 환원 |
| `ten-paces-game-design` | `poc-contract` | 기존 시나리오·카드·fixture의 claim ceiling 보호 |
| `ten-paces-verification` | `contract-check` | v6 원장·데이터·문서의 불일치 검출 |
| `ten-paces-verification` | `evidence-report` | T6 합성 결과와 사람·런타임 미검증 상태 분리 |

### selected_base_skills

| Skill | Mode | 책임 |
|---|---|---|
| `governing-game-user-research-coverage` | `plan-evidence` | 합성 페르소나가 실제 표본으로 오인되지 않도록 Evidence 층 관리 |
| `running-adversarial-review-and-refinement` | `attack` | 정답 누출·지배 전략·찍기·메타 공략 공격 |
| `running-adversarial-review-and-refinement` | `validate-critique` | 가정에 근거가 있는지 반례와 대조 |
| `reviewing-and-validating-project-changes` | `evidence-report` | 제품 경로 비침범·미검증·결정 상태 보고 |

새 합성 테스터 Skill을 만들지 않는다.

## 4. canonical_sources

| 책임 | 경로 | 사용 방식 |
|---|---|---|
| 최신 상태 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` | Work Mode·금지 범위 확인 |
| 문서 라우팅 | `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md` | 결과 문서 연결 |
| Skill 라우팅 | `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json` | 실행 Skill·mode 선택 |
| v6 결정 권한 | `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md` | 코어 규칙 변경 금지 |
| Evidence Pack | `docs/decisions/2026-07-29_ENEMY_INTENT_EVIDENCE_PACK_PILOT.md` | 결정 질문·근거·권장안 |
| 사람 검증 패킷 | `docs/superpowers/plans/2026-07-29-enemy-intent-human-validation-artifact.md` | 시나리오·claim ceiling·후속 TEST |

## 5. 보호 경로

```yaml
protected_paths:
  - scenes/combat/combat_board_preview.tscn
  - src/combat/combat_board_preview.gd
  - scenes/ui/opponent_hypothesis_panel.tscn
  - src/ui/opponent_hypothesis_panel.gd
  - scenes/ui/combat_review_panel.tscn
  - src/ui/combat_review_panel.gd
  - data/combat/combat_hypothesis_poc.json
  - data/combat/combat_board_poc.json
  - docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
```

합성 결과는 위 파일을 변경하거나 구현 권한을 만들지 않는다.

## 6. validation_routes

| 증거 | 현재 상태 | 책임 |
|---|---|---|
| 문서·계약 CI | 사용 가능 | PR Validation |
| 실제 Godot 전투 | `NOT_RUN` | fixture 또는 seed 필요 |
| 사람 관찰 | `NOT_RUN` | 외부 참가자 없음 |
| 접근성·성능 | `NOT_RUN` | 제품 UI·Build 필요 |
| 합성 설계 검토 | `T6_AI_INFERENCE` | 이번 보고서 |

## 7. 합성 테스트에 사용할 시나리오

- `TP-INTENT-A`: 원거리 접근과 속공.
- `TP-INTENT-B`: 근거리 대응·회복과 강공 준비.
- `TP-INTENT-C`: 최고 기세의 절초와 강공.

합성 시뮬레이션은 실제 AI 선택 결과를 만들지 않는다. 카드 문구·공개 상태·경쟁 가설·계획 변경 가능성만 공격한다.

## 8. 페르소나 렌즈

| ID | 공격 목적 |
|---|---|
| `TACTICAL_NOVICE` | 상태와 단서의 관계를 처음 보는 관점 |
| `TACTICAL_EXPERT` | 단서가 깊이를 만들지 않고 답만 누출하는지 공격 |
| `IMPATIENT_READER` | 텍스트를 건너뛰고 아이콘·강조만 따르는 위험 |
| `ROBUST_PLAN_OPTIMIZER` | 단서를 무시해도 안전한 3수 지배 계획이 있는지 공격 |
| `META_GAMER` | momentum·bundle 번호로 정답을 외우는 위험 |
| `LOW_WORKING_MEMORY` | 상태·단서·주/차선 가설·3수 계획의 동시 부담 |

## 9. 산출물과 권한

```yaml
structure_analysis: COMPLETED
simulation_report: docs/research/2026-07-29_ENEMY_INTENT_SYNTHETIC_TESTER_REPORT.md
human_session_packet_changed: false
product_code_changed: false
canon_changed: false
human_validation: NOT_RUN
implementation_authority: NONE
```
