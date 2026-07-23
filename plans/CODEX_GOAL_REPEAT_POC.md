# Codex Goal — REPEAT_POC 기술 구현

Codex는 다음 문서를 순서대로 읽고 작업한다.

1. `AGENTS.md`.
2. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
3. `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`.
4. `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`.
5. `docs/decisions/2026-07-24_CI_COST_OPTIMIZATION_AND_ACTIONS_FREEZE.md`.
6. `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`.
7. `docs/02_COMBAT_RULES.md`.
8. `docs/05_COMBAT_POC_SPEC.md`.
9. `docs/08_TEST_CHECKLIST.md`.
10. `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`.
11. 실제 관련 코드·데이터·테스트.

## Actions 비용 동결

```yaml
actions_availability: DEFERRED_ACTIONS_QUOTA
resume_signal: USER_DECLARES_ACTIONS_AVAILABLE
ci_enabled_variable: false
```

- 사용자가 “Actions 사용 가능”이라고 선언하기 전에는 Actions가 필요한 검증을 실행하지 않는다.
- Actions 미실행 상태를 `PASS`로 기록하지 않는다.
- A0 추가 구현·Green 판정은 CI 최적화 적용과 Actions 재개 후 수행한다.
- `CI_ENABLED=true` 활성화 전 자동 job은 runner를 할당하지 않아야 한다.

## 실행 지시

- Work Mode: `BUILD → REVIEW`.
- 동결 중 현재 Task는 `CI_COST_OPTIMIZATION`만 허용한다.
- 제품 Task A0~A3는 `PAUSED_ACTIONS_QUOTA`다.
- 재개 후 계획의 Task 1부터 순서대로 실행한다.
- 한 번에 하나의 Task만 `in_progress`로 둔다.
- 각 Task는 Red 실패 증거 → 최소 Green → Refactor → 관련 전체 검증 → 독립 커밋으로 끝낸다.
- 같은 파일을 수정하는 Task는 병렬 실행하지 않는다.
- PR-A0~A3를 독립 스택형 PR로 유지한다.
- 구현 중 계획과 실제 파일이 충돌하면 임의로 추측하지 말고 finding과 근거를 기록한다.
- 기존 사용자·Codex 변경을 되돌리지 않는다.
- force push·reset·rebase를 사용하지 않는다.
- 실제 실행하지 않은 검증은 `NOT_RUN`, `DEFERRED_ACTIONS_QUOTA`, `DEFERRED_BY_USER` 또는 `UNVERIFIED`로 기록한다.
- 신규 플레이어 STEP 14는 실행하지 않는다.
- 사람 검증 없이 T1·MVP·재미 검증 완료를 선언하지 않는다.

## Actions 재개 후 첫 작업

```text
CI 최적화 Workflow 수동 검증
→ Required Check 정렬
→ PR #17 최신 base 반영
→ Task 1 A0 전체 Green
```

시작 기준:

```yaml
branch: agent/project-core-confirmation
product_baseline: 659c57e7ffa588ad6a6471ed9b5394985b159eaf
project_core: CORE_CONFIRMED
product_gate: REPEAT_POC
implementation: PARTIAL_ON_PR_17
actions_validation: DEFERRED_ACTIONS_QUOTA
human_step14: DEFERRED_BY_USER
```
