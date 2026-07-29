# Enemy Intent Synthetic Remediation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 합성 검토에서 확인된 정답 누출·범용 계획·사후 합리화 위험을 사람 검증 Artifact의 연구 자극물과 기록 순서에 반영한다.

**Architecture:** 기존 사람 검증 Artifact 한 파일만 연구 실행 계약으로 유지한다. 제품 코드·데이터·v6 원장은 변경하지 않고, baseline 계획과 단서 후 계획을 분리하며 동일 상태 경쟁 의도 fixture를 카드 수준에서 추가한다.

**Tech Stack:** Markdown 연구 계약, 프로젝트 문서 CI

## Global Constraints

- `T6_AI_INFERENCE`는 사람 관찰을 대체하지 않는다.
- `human_validation: NOT_RUN`과 `implementation_authority: NONE`을 유지한다.
- `scenes/**`, `src/**`, `data/**`, v6 결정 원장을 변경하지 않는다.

---

### Task 1: 사람 검증 Artifact 자극물 교정

**Files:**
- Modify: `docs/superpowers/plans/2026-07-29-enemy-intent-human-validation-artifact.md`

**Interfaces:**
- Consumes: `docs/research/2026-07-29_ENEMY_INTENT_SYNTHETIC_TESTER_REPORT.md`
- Produces: 단서 전 baseline 계획, 단서 후 가설·계획 delta, 동일 상태 경쟁 fixture

- [ ] **Step 1:** metadata를 현재 main과 Base 합성 Governance commit으로 갱신한다.
- [ ] **Step 2:** A/B/C 단서에서 가설 이름의 직접 번역 어휘를 제거한다.
- [ ] **Step 3:** C에 동일 공개 상태·동일 단서의 `ultimate/heavy_prepare` hidden-key fixture를 추가한다.
- [ ] **Step 4:** 상태만 본 `pre_signal_plan`을 먼저 기록한 뒤 단서를 공개하도록 진행 순서를 변경한다.
- [ ] **Step 5:** `plan_change_delta`와 범용 계획 반복 여부를 관찰 필드에 추가한다.

### Task 2: 검증과 병합

**Files:**
- Verify: changed-files diff
- Verify: repository PR validation

**Interfaces:**
- Consumes: Task 1의 Artifact
- Produces: 제품 경로 비침범과 문서 계약 통과 증거

- [ ] **Step 1:** branch diff가 계획과 Artifact 문서만 포함하는지 확인한다.
- [ ] **Step 2:** PR Validation을 실행하고 성공을 확인한다.
- [ ] **Step 3:** 미해결 리뷰 스레드가 없는지 확인한다.
- [ ] **Step 4:** 검증된 HEAD를 squash merge한다.
