# Enemy Intent Synthetic Session Execution Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to execute this plan task-by-task.

**Goal:** 교정된 적 의도 카드 Artifact를 실제 참가자 대신 합성 페르소나로 실행해 남은 정답 누출·범용 계획·사후 합리화 위험을 잠정 판정한다.

**Architecture:** 기존 구조 분석서, 합성 위험 보고서, 교정된 사람 검증 Artifact를 읽기 전용 입력으로 사용한다. 가상 행동은 관찰값이나 참가자 수치로 기록하지 않고 `assumed_first_attempt`, 근거, 반례, 신뢰도로만 기록한다.

**Tech Stack:** Markdown, Base Synthetic Tester Governance, 프로젝트 문서 CI

## Global Constraints

- `validation_method: SYNTHETIC_TESTER_SIMULATION`을 사용한다.
- `evidence_tier: T6_AI_INFERENCE`, `human_validation: NOT_RUN`을 유지한다.
- v6 결정 원장, 전투 규칙, AI, Scene, Script, JSON을 변경하지 않는다.
- `ADOPT`, `VALIDATED`, `PLAYTEST_PASSED`를 사용하지 않는다.

---

### Task 1: 합성 세션 Case 실행

**Files:**
- Read: `docs/research/2026-07-29_SYNTHETIC_TESTER_STRUCTURE_ANALYSIS.md`
- Read: `docs/research/2026-07-29_ENEMY_INTENT_SYNTHETIC_TESTER_REPORT.md`
- Read: `docs/superpowers/plans/2026-07-29-enemy-intent-human-validation-artifact.md`
- Create: `docs/research/2026-07-29_ENEMY_INTENT_SYNTHETIC_SESSION_EXECUTION.md`

- [ ] 초보·숙련·성급·최적화·적대적 페르소나의 예상 최초 계획을 기록한다.
- [ ] 상태만 본 계획과 단서 후 계획의 가정 delta를 분리한다.
- [ ] C-U/C-H 동일 공개 fixture에서 두 가설이 실제로 살아 있는지 공격한다.
- [ ] 범용 3수 계획과 설명만 바꾸는 메타 대응을 반례로 기록한다.

### Task 2: 잠정 판정과 검증

- [ ] `PROMISING_DIRECTION / ADAPT / REWORK / REJECT / TEST_REQUIRED`만 사용한다.
- [ ] 사람 행동·재미·실제 전투 인과는 `NOT_RUN`으로 유지한다.
- [ ] branch diff가 계획·합성 실행 보고서 두 파일로 제한되는지 확인한다.
- [ ] PR Validation과 리뷰 스레드를 확인한 뒤 squash merge한다.
