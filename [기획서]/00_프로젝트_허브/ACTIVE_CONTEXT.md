# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `PLAN → REVIEW` — 프로젝트 코어 확정과 STEP 14 진입 계약.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 구현 PR: #7 `agent/t0-combat-poc-board`.
- 구현 기준 SHA: `659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 코어 확정 브랜치: `agent/project-core-confirmation`.
- 최신 전투 승인: Issue #13 STEP 12~14.
- 제품 단계: T0 Prototype.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
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
- Documentation Governance run #462: `PASS`.
- PR #14 기준 Codex 보호 경로 변경: 0건.
- 코어 확정 작업은 문서·기획 계약만 변경하며 `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`을 수정하지 않는다.

## 증거 경계

```yaml
step_0_to_13_implementation: IMPLEMENTED
mechanical_step14_scenarios: RECORDED
windows_and_godot_technical_evidence: PARTIAL_TO_PASS
project_core: CORE_CONFIRMED
human_rule_comprehension: NOT_RUN
opponent_tendency_discovery: NOT_RUN
assistive_technology_user_validation: NOT_RUN
subjective_audio_motion_readability: NOT_RUN
external_playtest: NOT_RUN
release_performance_budget: NOT_RUN
branch_protection_required_checks: NOT_RUN
local_uncommitted_state: UNVERIFIED
t1_greenlight: NOT_GRANTED
```

기계 시나리오와 개발자 반환값 확인은 실제 플레이어 이해·선호·상대 성향 발견을 대체하지 않는다.

## 적대적 검토의 P0

1. 결정적 최소 AI가 라이벌 읽기가 아니라 고정 퍼즐로 굳을 수 있다.
2. 상세 로그만으로는 플레이어가 자신의 가설이 어디서 틀렸는지 알기 어렵다.
3. 사람 STEP 14가 없어 코어 재미·체감 공정성·재도전 행동 증거가 없다.
4. 12세력·10성·10전 가설이 T1 범위를 팽창시킬 수 있다.
5. 합·절초·기세가 다른 읽기 선택을 압도할 가능성이 있다.

## 현재 작업

1. 코어 계약과 결정 기록을 Governance로 검증한다.
2. 기준 SHA 대비 Codex 제품 경로 변경 0건을 재확인한다.
3. 코어 확정 PR을 PR #7에 병합한다.
4. PR #7 본문과 base를 최신 상태로 정리한다.
5. STEP 14 발견형 플레이테스트를 준비한다.
6. 확정 설계안을 PDF로 발행하고 전 페이지 시각 검수한다.

## 다음 제품 작업

```text
결정적 복기 최소안
+ 읽을 수 있는 라이벌 성향 실험 계약
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
