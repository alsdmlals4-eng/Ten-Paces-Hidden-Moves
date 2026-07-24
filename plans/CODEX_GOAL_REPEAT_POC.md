# Codex Goal — REPEAT_POC 기술 구현

Codex는 다음 문서를 순서대로 읽고 작업한다.

1. `AGENTS.md`.
2. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
3. `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`.
4. `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`.
5. `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`.
6. `docs/02_COMBAT_RULES.md`.
7. `docs/05_COMBAT_POC_SPEC.md`.
8. `docs/08_TEST_CHECKLIST.md`.
9. `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`.
10. 실제 관련 코드·데이터·테스트.

## 실행 지시

- Work Mode: `BUILD → REVIEW`.
- 계획의 Task 1부터 순서대로 실행한다.
- 한 번에 하나의 Task만 `in_progress`로 둔다.
- 각 Task는 Red 실패 증거 → 최소 Green → Refactor → 관련 전체 검증 → 독립 커밋으로 끝낸다.
- 같은 파일을 수정하는 Task는 병렬 실행하지 않는다.
- PR-A0~A3를 독립 스택형 PR로 유지한다.
- 구현 중 계획과 실제 파일이 충돌하면 임의로 추측하지 말고 finding과 근거를 기록한다.
- 기존 사용자·Codex 변경을 되돌리지 않는다.
- force push·reset·rebase를 사용하지 않는다.
- 실제 실행하지 않은 검증은 `NOT_RUN`, `DEFERRED_BY_USER` 또는 `UNVERIFIED`로 기록한다.
- 신규 플레이어 STEP 14는 실행하지 않는다.
- 사람 검증 없이 T1·MVP·재미 검증 완료를 선언하지 않는다.

## 첫 작업

```text
Task 1 — 정본 SHA·AI source·board schema 정렬
```

시작 기준:

```yaml
branch: agent/project-core-confirmation
product_baseline: 659c57e7ffa588ad6a6471ed9b5394985b159eaf
project_core: CORE_CONFIRMED
product_gate: REPEAT_POC
implementation: NOT_STARTED
human_step14: DEFERRED_BY_USER
```
