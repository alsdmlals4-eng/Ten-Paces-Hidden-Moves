# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 질문별 책임 원본
→ 실제 코드·데이터·씬·자산·테스트·PR·Issue
```

전체 Skill 폴더, 백업·보류·과거 Plan·닫힌 PR을 기본 컨텍스트로 로드하지 않는다.

## 현재 기준

- 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`.
- Base: `alsdmlals4-eng/Base@41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- Base 버전·차이: `docs/BASE_RULES_VERSION.md`.
- Skill Registry: `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`.
- 현재 구현 기준: PR #7 `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`; legacy 승인 추적 Issue #13.
- 최신 기획·검수: PR #45 `agent/poc-planning-baseline-and-legacy-audit`.
- 통합 기획 기준선: `docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md`.
- 적대적 검토·검수안: `docs/decisions/2026-07-26_FULL_ADVERSARIAL_REVIEW_LOOP.md`.
- 현재 단계: `REVIEW_IN_PROGRESS`; `검수 완료` 전 제품 런타임 인계 금지.

## Work Mode

- `PLAN`: 요구·코어·근거·대안·실행 순서.
- `BUILD`: 승인 범위 구현.
- `REVIEW`: 적대적 검토·반례·검증.

Skill·Skill Mode는 Registry trigger로 자동 선택한다. L1 이상은 기준 SHA·선택 이유·수행·결과·증거·미검증을 `execution-report`로 남긴다.

## 현재 제품 상태

- 10칸, 플레이어 4번·상대 7번, 시작 거리 3.
- 같은 칸 최대 2인과 거리 0 `[밀착]`.
- 라운드 `3수 → 3수 → 4수`.
- 기초 행동 8종·절초 3종.
- 순차 타격쌍 `[합]`·누적 방어도·회피·스택형 필중·중단·강건.
- 공개 상태 기반 결정적 후보 AI.
- 승패·무승부와 전투 직전 `RunState` 유료 재도전 계약.
- STEP 0~13 구현·기술 증거.
- STEP 14 기계 시나리오 기록.
- 실제 사용자 STEP 14: `NOT_RUN`.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.

## 다음 순서

```text
PR #45 승인 검수안 최소 BUILD
→ REVIEW 복귀·정적·참조·회귀 검증
→ 사용자 `검수 완료`
→ Codex 런타임 구현 인계
→ Godot·Windows·접근성·성능·STEP 14 사람 검증
→ KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST
```

## 상태 경계

정적 Actions 성공은 Godot 런타임·Windows 사용자 경험·접근성 사용자 검수·Release 성능·PDF 발행·Branch protection 강제를 증명하지 않는다. 원격 변경과 사용자 로컬 미커밋 파일도 자동으로 동일하지 않다.
