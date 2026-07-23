# 십보강호 문서·Skill 지도

## 기본 읽기

```text
AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ 이 문서
→ 질문별 책임 원본
→ 실제 파일·테스트·PR·Issue
```

## 질문별 책임 원본

| 질문 | 책임 원본 | 검증 |
|---|---|---|
| 현재 프로젝트 코어·핵심 루프·불변 조건 | `docs/01_GAME_DESIGN.md` | `CORE_CONFIRMED` |
| 코어 확정 근거 | `docs/decisions/2026-07-23_PROJECT_CORE_DECISION_RECORD.md` | 사용자 승인·적대적 회귀 |
| 통합 명세 | `docs/decisions/2026-07-23_CORE_INTEGRATED_SPEC_AND_IMPLEMENTATION_PLAN.md` | WP·DoD·롤백 |
| 최종 적대적 검토 | `docs/decisions/2026-07-24_FINAL_ADVERSARIAL_REVIEW_AND_MVP_CLOSEOUT.md` | finding·미검증 |
| REPEAT_POC 기술 Goal | `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md` | Issue #16·범위 보호 |
| Codex 시작 | `plans/CODEX_GOAL_REPEAT_POC.md` | Red 우선·독립 PR |
| 상세 구현 순서 | `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md` | A0~A3·검증·롤백 |
| 기계 판독 상태 | `docs/decisions/2026-07-24_REPEAT_POC_IMPLEMENTATION_STATUS.json` | 기술/사람 상태 분리 |
| 보류 플레이테스트 자료 | `docs/research/README.md` | `DEFERRED_BY_USER / DO_NOT_RUN` |
| 현재 상태·다음 작업 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` | 실제 PR·Issue 대조 |
| 전투 판정·거리·자원·합·AI | `docs/02_COMBAT_RULES.md` + 실제 `data/`·`src/` | 자동·Godot·반례 |
| 콘텐츠·T1·HOLD | `docs/03_CONTENT_CATALOG.md` | 단계 경계 |
| 제품 순서 | `docs/04_ROADMAP.md` | 진입·중단 기준 |
| 운영 순서 | `[기획서]/00_프로젝트_허브/ROADMAP.md` | Actions·Health Review |
| POC·T1·T2 | `docs/05_COMBAT_POC_SPEC.md` | 구현·기계·사람 증거 분리 |
| 전투 UI·접근성 | `docs/07_COMBAT_UI_SPEC.md` + 실제 씬 | 입력·정보 채널 |
| QA·완료 주장 | `docs/08_TEST_CHECKLIST.md` | 정적·Godot·Windows·사람 상태 |
| 아키텍처·AI·재시작 | `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` | 실제 클래스·Dictionary |
| 연출 | `docs/10_COMBAT_PRESENTATION_PLAN.md` | event·폴백 |
| Base 적용 | `docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md` | 공용/전용 경계 |
| Base SHA·Skill | `docs/BASE_RULES_VERSION.md` | SHA·Registry |
| 작업·제품 게이트 | `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md` | 기술·사람 증거 분리 |
| 세션 인수 | `[기획서]/00_프로젝트_허브/HANDOFF.md` | exact SHA·다음 행동 |

## Skill 라우팅

- 운영체계: `managing-game-project-operating-system`.
- stale 정리: `pruning-stale-and-nonfunctional-material`.
- 정본 최신성: `auditing-canonical-reference-freshness`.
- 변경 검증: `reviewing-and-validating-project-changes`.
- 프로젝트 코어: `identifying-project-core`, `establishing-project-core`.
- 적대적 검토: `running-adversarial-review-and-refinement`.
- 전투 설계: `ten-paces-game-design`.
- 전투 UX: `combat-ux-and-accessibility`.
- Godot 인수: `combat-implementation-handoff`.
- 검증: `ten-paces-verification`.

Base 활성 Skill 전체 ID와 trigger는 `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`이 책임진다.

## 실제 구현 경로

```text
data/
scenes/
src/
assets/
addons/
tests/
tools/
project.godot
```

## 현재 GitHub 기준

- PR #7: `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 최신 전투 승인: Issue #13.
- 코어 확정·계획 PR: #15 `agent/project-core-confirmation`.
- REPEAT_POC Goal: Issue #16.
- 현재 구현 단계: `A0_CONTRACT_ALIGNMENT`.
- 신규 플레이어 STEP 14: `DEFERRED_BY_USER`.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.

## 경계

- 한 질문에 현행 책임 원본 하나만 둔다.
- 결정 기록은 현재 계약을 대체하지 않는다.
- 기술 구현 완료와 사람 검증 완료를 구분한다.
- 보류 플레이테스트 자료는 기본 구현 입력에서 제외한다.
- Workflow·Actions·Godot·Windows·사람 검수를 각각 구분한다.
- 모든 등록 문서와 Skill Registry는 `source_only`다.
