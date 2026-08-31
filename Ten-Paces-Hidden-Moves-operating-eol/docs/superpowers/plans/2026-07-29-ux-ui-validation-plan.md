# Ten Paces UX/UI Validation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 십보강호의 적 의도·거리·3/3/4 계획·합·복기 UX를 최신 기획 Gate 안에서 검증 가능한 카드 fixture, 플레이 과제와 사람 테스트 기준으로 고정한다.

**Architecture:** 현재 `CONCEPT_APPROVAL`, `PLANNING_ONLY_PROFILE`, 런타임 변경 금지 상태를 유지한다. 먼저 카드·계획·예상 결과·합 인과의 검증 계약을 정리하고, 16권 절초와 최신 기획이 사용자 승인된 뒤 별도 Codex Goal에서 구현·런타임 검증을 진행한다.

**Tech Stack:** GitHub Markdown/Issues, PC 16:9, Godot·GDScript는 후속 승인 단계에서만 사용, 키보드·마우스·게임패드 입력 계약.

## Global Constraints

- `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`의 `CONCEPT_APPROVAL`, `PLAN`, `PLANNING_ONLY_PROFILE`을 유지한다.
- `runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL`을 우회하지 않는다.
- 현행 T0 구현은 역사·기술 기준선이며 최신 v6 기획 통과 증거가 아니다.
- 3/3/4, 거리, 무공, AI, 합, 피해·상태 규칙은 UX 작업에서 변경하지 않는다.
- 제품 코드·Scene·data·asset과 HTML 기획 대시보드는 변경하지 않는다.
- STEP 14 사람 검증은 실행 전까지 `NOT_RUN`으로 유지한다.

---

### Task 1: 최신 권한과 검증 범위 고정

**Files:**
- Read: `AGENTS.md`
- Read: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Read: `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`
- Read: `docs/UX_UI_SYSTEM.md`
- Read: `docs/BASE_UX_UI_ADOPTION.md`

**Interfaces:**
- Consumes: 최신 v6 원장과 UX/UI 책임 원본.
- Produces: 구현을 포함하지 않는 UX 검증 Issue.

- [ ] **Step 1:** 제품 단계·Work Mode·실행 프로필·런타임 금지를 Issue에 기록한다.
- [ ] **Step 2:** 현행 T0 구현, 과거 BUILD 문서, v6 결정 원장의 권한 차이를 기록한다.
- [ ] **Step 3:** 3/3/4, 10칸 거리, 카드 비용·사거리·합 인과를 보호 조건으로 고정한다.
- [ ] **Step 4:** Base main SHA와 프로젝트 UX 책임 원본을 명시한다.

### Task 2: 카드·계획 fixture 정의

**Files:**
- Create after planning approval: `docs/validation/TEN_PACES_UX_UI_FIXTURE_CATALOG.md`
- Read: `docs/02_COMBAT_RULES.md`
- Read: `docs/07_COMBAT_UI_SPEC.md`
- Read: `docs/UX_UI_SYSTEM.md`

**Interfaces:**
- Consumes: 현행 규칙과 최신 v6 권한 원장.
- Produces: 정적 UI·프로토타입·사람 테스트가 공유하는 상태 세트.

- [ ] **Step 1:** 사거리와 비용이 모두 유효한 카드 선택 상태를 정의한다.
- [ ] **Step 2:** 사거리 부족, 자원 부족, 대상 무효, 슬롯 충돌을 각각 정의한다.
- [ ] **Step 3:** 같은 목적이지만 비용·거리·효과·조건이 다른 카드 3장을 비교하는 fixture를 정의한다.
- [ ] **Step 4:** 3수 묶음과 4수 묶음에서 순서가 결과를 바꾸는 계획 fixture를 정의한다.
- [ ] **Step 5:** 합·중단·반격·상태 변화가 연속 발생하는 사건 fixture를 정의한다.
- [ ] **Step 6:** 긴 한국어 효과, 최대 비용·수치, 자기 대상·사거리 없음, 누락 이미지 fixture를 정의한다.
- [ ] **Step 7:** 확인된 적 의도와 아직 불확실한 의도 단서를 구분하는 fixture를 정의한다.

### Task 3: 플레이 과제와 정보 계층 검증

**Files:**
- Create after planning approval: `docs/validation/TEN_PACES_UX_UI_VALIDATION_PACKET.md`
- Read: `docs/UX_UI_SYSTEM.md`
- Read: `docs/08_TEST_CHECKLIST.md`

**Interfaces:**
- Consumes: Task 2 fixture.
- Produces: 적 의도→3/3/4 계획→합→복기 과제.

- [ ] **Step 1:** 플레이어가 적 의도 단서와 현재 거리·자원·슬롯을 설명하게 한다.
- [ ] **Step 2:** 카드 3장을 비용·사거리·핵심 효과·조건 축으로 비교하게 한다.
- [ ] **Step 3:** 카드·슬롯·대상을 배치하고 실행 전 충돌·중단 위험을 확인하게 한다.
- [ ] **Step 4:** 실행 전 카드·슬롯·대상을 취소하고 이전 의미 위치로 복귀하게 한다.
- [ ] **Step 5:** 합 연출 뒤 발동 순서·중단·반격·상태 변화·자원 소비를 설명하게 한다.
- [ ] **Step 6:** 예상과 실제가 달라진 원인을 말하고 다음 계획에서 바꿀 한 가지를 선택하게 한다.

### Task 4: 사람 테스트·입력 기준 정의

**Files:**
- Create after planning approval: `docs/validation/TEN_PACES_UX_UI_VALIDATION_PACKET.md`
- Update after execution: `docs/UX_UI_SYSTEM.md`
- Update after execution: `docs/08_TEST_CHECKLIST.md`

**Interfaces:**
- Consumes: Task 2~3.
- Produces: STEP 14 사람 검증 판정.

- [ ] **Step 1:** 신규 플레이어 5명에게 튜토리얼 도움 없이 한 라운드 3/3/4 계획과 복기를 수행하게 한다.
- [ ] **Step 2:** 5명 중 4명 이상이 실행 전 비용·사거리·대상·충돌을 설명해야 통과하도록 정한다.
- [ ] **Step 3:** 5명 중 4명 이상이 `focused`와 `selected`, 실행 전 취소 가능 상태를 구분해야 통과하도록 정한다.
- [ ] **Step 4:** 5명 중 4명 이상이 합 결과의 핵심 인과와 다음 계획 변경을 연결해야 통과하도록 정한다.
- [ ] **Step 5:** 키보드·마우스·게임패드 각각 카드→슬롯→대상→상세→복기를 완주해야 통과하도록 정한다.
- [ ] **Step 6:** 합 연출·음향을 줄이거나 꺼도 사건 순서와 결과 원인이 남아야 통과하도록 정한다.

### Task 5: 구현 진입 Gate와 패키지 분리

**Files:**
- Update after user approval: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Update after user approval: `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`
- Create after user approval: 별도 Codex Goal Issue

**Interfaces:**
- Consumes: 최신 기획 승인, 절초 설계 상태, Task 2~4 계약.
- Produces: 최소 전투 UX 구현·검증 패키지.

- [ ] **Step 1:** 16권 절초와 최신 기획의 사용자 승인 전 런타임 변경 금지를 유지한다.
- [ ] **Step 2:** 승인 후 실제 카드·계획·대상·합 Scene과 View Data·Signal 소유자를 읽기 전용으로 조사한다.
- [ ] **Step 3:** 카드 정보 계층, 3/3/4 계획, 실행 전 검토, 합 인과, 복기만 첫 구현 패키지에 포함한다.
- [ ] **Step 4:** AI·거리·피해·상태·무공 데이터 변경은 별도 변경 제안으로 분리한다.
- [ ] **Step 5:** 자동 계약, Godot runtime, 입력·포커스, 사람 이해, 접근성 사용자 증거를 독립 상태로 보고한다.

## Verification Commands

현재 계획 PR은 문서·정본·Skill 계약만 검증한다.

```bash
python -m unittest tests.test_active_document_references -v
python -m unittest tests.test_skill_package_integrity -v
```

제품 런타임과 STEP 14 사람 검증은 새 사용자 승인 뒤 별도 Issue에서만 실행한다.
