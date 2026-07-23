# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `REVIEW → 최소 문서 BUILD → REVIEW` — PR #15 최종 적대적 검토와 MVP 마감 검증.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 구현 PR: #7 `agent/t0-combat-poc-board`.
- 구현 기준 SHA: `659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 코어 확정·마감 브랜치: `agent/project-core-confirmation`.
- 최신 전투 승인: Issue #13 STEP 12~14.
- 제품 단계: T0 Prototype.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- 최종 마감 판정: `REVISE`.
- T1 진입: `NOT_GRANTED`.
- 상태 전이 기록: `CORE_REVIEW_PENDING → CORE_CONFIRMED`.

## 확정된 프로젝트 코어

> 상대의 공개된 상태와 반복 습관을 읽고, 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·`[합]`·대응·중단으로 한 수를 파훼하고, 그 이유를 복기해 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

```text
대전 격투식 수읽기·파훼
> 전술 퍼즐식 거리·순서
> 로그라이트 성장
```

### 코어 보호 경계

- 1대1 무협 라이벌 결투.
- 10칸 일자형 전장.
- 비공개 `3수 → 3수 → 4수`, 총 10수 계획.
- 공개 정보와 반복 습관에 기반한 상대 읽기.
- AI는 플레이어의 미확정 계획을 읽지 않는다.
- 덱·손패 없이 항상 사용할 수 있는 소수 공용 행동.
- 위치·순서·대응·파훼가 원시 피해량보다 우선.
- 결과 이유를 복기하고 다음 계획을 변경한다.

책임 원본은 `docs/01_GAME_DESIGN.md`, 확정 과정은 `docs/decisions/2026-07-23_PROJECT_CORE_DECISION_RECORD.md`가 기록한다.

## 현재 구현

- STEP 0~13 구현.
- TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6.
- 10칸·4/7·거리 3·거리 0 `[밀착]`.
- `3수 → 3수 → 4수`.
- 기초 행동 8종·절초 3종.
- `[합]`·순차 방어·회피·필중·중단·강건.
- 공개 상태 기반 결정적 최소 AI.
- 승패·무승부·4/7 완전 재시작.
- 수별 `timing_results`·`presentation_events` 연출.
- 키보드 포커스·모션 감소·음향 제어·UI Automation 기술 증거.

세부 판정은 `docs/02_COMBAT_RULES.md`, 범위는 `docs/05_COMBAT_POC_SPEC.md`, 증거는 `docs/08_TEST_CHECKLIST.md`, 실제 상태는 `data/`, `src/`, `scenes/`, `assets/`, `tests/`가 책임진다.

## GitHub·검증 상태

- PR #14 정본·Skill·Governance 최신화: PR #7에 병합 완료.
- PR #7 통합 후 HEAD: `659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- PR #15 시작 head `ff378732...` Documentation Governance run #466: `PASS`.
- PR #15 시작 head 대비 제품 보호 경로 변경: 0건.
- PR #15 최신 head의 Governance·Card/Combat Contract: `PENDING`.
- PR #15 unresolved review thread: 0건.
- Branch protection Required Check 강제: `UNVERIFIED`.
- 저장소 등록 문서·Skill Registry 발행 정책: `source_only`.

## 최종 적대적 검토 결과

책임 원본:

- 실행 계획: `plans/2026-07-24-final-adversarial-review-closeout-plan.md`.
- 최종 보고: `docs/decisions/2026-07-24_FINAL_ADVERSARIAL_REVIEW_AND_MVP_CLOSEOUT.md`.

이번 마감에서 수정한 영역:

- `AGENTS.md`.
- 루트·허브 `START_HERE.md`.
- `docs/BASE_RULES_VERSION.md`.
- 허브 `DEVELOPMENT_GATES.md`, `ROADMAP.md`, `HANDOFF.md`, `DOCUMENTATION_MAP.md`.
- `tests/test_project_governance.py`.

제품 코드·데이터·씬·자산·Godot 테스트는 수정하지 않았다.

## 남은 MUST_FIX

1. `docs/02_COMBAT_RULES.md`, `docs/05_COMBAT_POC_SPEC.md`, `docs/08_TEST_CHECKLIST.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`의 이전 구현 기준 SHA를 현행 `659c57e7...`로 정렬한다.
2. `data/combat/combat_board_poc.json`의 `fixed_enemy_preview_plan`과 판정 데이터·코드의 `public_state_ai` 의미 충돌을 별도 제품 계약에서 수정한다.
3. 플레이어가 실제로 세운 가설을 기록하지 않은 상태에서 `내 예상`을 생성하지 않는다.
4. 사람 STEP 14 전 결정적 복기 최소안과 읽을 수 있는 라이벌 성향을 구현·검증한다.
5. PR #7 본문을 STEP 0~13·Issue #13·현재 증거 경계로 갱신한다.
6. PR #15 최신 head Actions와 최종 protected-path diff를 확인한다.

## 증거 경계

```yaml
step_0_to_13_implementation: IMPLEMENTED
mechanical_step14_scenarios: RECORDED
windows_and_godot_technical_evidence: PARTIAL_TO_PASS
project_core: CORE_CONFIRMED
final_closeout_decision: REVISE
full_conversation_review: UNVERIFIED_CONTEXT
human_rule_comprehension: NOT_RUN
opponent_tendency_discovery: NOT_RUN
assistive_technology_user_validation: NOT_RUN
subjective_audio_motion_readability: NOT_RUN
external_playtest: NOT_RUN
release_performance_budget: NOT_RUN
branch_protection_required_checks: UNVERIFIED
local_uncommitted_state: UNVERIFIED
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

기계 시나리오와 개발자 반환값 확인은 실제 플레이어 이해·선호·상대 성향 발견을 대체하지 않는다.

## 다음 제품 작업

```text
남은 정본 SHA·AI source 충돌 수정
→ 플레이어 가설 기록 최소 계약
→ 결정적 복기 최소안
→ 읽을 수 있는 라이벌 성향 실험
→ STEP 14 신규 플레이어 5명
→ 이해·성향 발견·계획 변경 관찰
→ KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST
→ T1_GREENLIGHT_REVIEW 또는 REPEAT_POC
```

### STEP 14 발견형 통과 신호

- 5명 중 4명 이상이 치명적 차단 없이 한 판 완료.
- 5명 중 4명 이상이 3/3/4와 결정적 판정 원인 하나를 설명.
- 5명 중 3명 이상이 안내 없이 상대 성향 하나를 발견.
- 5명 중 3명 이상이 재도전에서 계획을 실질적으로 변경.
- 5명 중 3명 이상이 자발적으로 다시 하거나 구체적 다음 수를 제시.
- 핵심 정보가 색·모션·음향 하나에만 의존한 참가자가 없음.

## 기본 읽기

1. `AGENTS.md`.
2. 이 `ACTIVE_CONTEXT.md`.
3. `DOCUMENTATION_MAP.md`.
4. `docs/01_GAME_DESIGN.md`.
5. 질문별 책임 원본.
6. 실제 파일·테스트·PR·Issue.

백업·보류·과거 Plan·닫힌 PR은 기본 읽기에서 제외한다.

## 중단 조건

- PR #7 HEAD가 예상과 다르게 이동했다.
- 보호 경로에 의도하지 않은 변경이 나타났다.
- Actions 실패 원인을 확인하지 않고 통합하려 한다.
- 실제 사용자 증거 없이 STEP 14 또는 T1을 통과 처리한다.
- 라이벌 성향을 미확정 계획 읽기 또는 근거 없는 무작위로 구현하려 한다.
- 코어보다 콘텐츠 수·성장 수치·대회 분량이 우선되기 시작한다.
- 남은 `MUST_FIX` 또는 필수 `UNVERIFIED`를 숨기고 MVP 완료를 선언한다.
