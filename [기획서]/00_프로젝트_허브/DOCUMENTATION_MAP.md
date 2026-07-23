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
| 현재 방향·핵심 경험 가설 | `docs/01_GAME_DESIGN.md` | 프로젝트 코어 PLAN·사용자 승인 |
| 현재 상태·다음 작업·위험 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` | 콜드 스타트·실제 PR 대조 |
| 전투 판정·거리·자원·합·AI | `docs/02_COMBAT_RULES.md` + 실제 `data/`·`src/` | 자동·Godot·반례 |
| 콘텐츠·T1·HOLD | `docs/03_CONTENT_CATALOG.md` | 실제 ID·단계 경계 |
| 제품 순서 | `docs/04_ROADMAP.md` | 진입·중단 기준 |
| 운영 순서 | `[기획서]/00_프로젝트_허브/ROADMAP.md` | Health Review·Actions |
| POC·T1·T2·전체판 | `docs/05_COMBAT_POC_SPEC.md` | 구현·기계·사람 증거 분리 |
| 세력·무공·심법·성장 | `docs/06_STARTING_FACTION_MASTERY_DATA.md` | T1 진입·가설 상태 |
| 전투 UI·접근성 | `docs/07_COMBAT_UI_SPEC.md` + 실제 씬 | 입력·해상도·정보 채널 |
| QA·완료 주장 | `docs/08_TEST_CHECKLIST.md` | 정적·자동·Godot·Windows·사람 |
| 아키텍처·AI·재시작 | `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` | 실제 클래스·Dictionary·호환성 |
| 연출·VFX·SFX | `docs/10_COMBAT_PRESENTATION_PLAN.md` | event·결과 불변·폴백 |
| Base 적용·학습 | `docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md` | 공용/전용 경계·BCP |
| Base SHA·활성 Skill | `docs/BASE_RULES_VERSION.md` | SHA·비교·Registry |
| Base 변경 영향 감사 | `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md` | 6개 커밋·43개 파일 처리 |
| 최종 통합 검증 | `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_VERIFICATION.md` | 반례·Actions·baseline 보존 |
| 기획 책임·발행 정책 | `[기획서]/DESIGN_DOCUMENT_REGISTRY.json` | 단일 원본·required section |
| Skill 자동 라우팅 | `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json` | Base 25 route·로컬 4개 |
| 구형 Skill ID | `skills/LEGACY_SKILL_ALIASES.md` | stale ID·호환 검색 |
| 변경 소비자 | `[기획서]/00_프로젝트_허브/DOCUMENT_UPDATE_MATRIX.md` | propagation gap |
| 작업·제품 게이트 | `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md` | Ready·Done·사람 증거 |
| 세션·브랜치 인수 | `[기획서]/00_프로젝트_허브/HANDOFF.md` | exact SHA·다음 첫 행동 |
| 구형 파일·보존 | `[기획서]/00_프로젝트_허브/SOURCE_AUDIT.md` | reconciliation·복구 |

## Skill 라우팅

### 이번 정합화

- 운영체계 감사: `managing-game-project-operating-system`.
- stale 가지치기: `pruning-stale-and-nonfunctional-material`.
- 계약 보존 구조 변경: `refactoring-with-contract-preservation`.
- Skill 본문 간소화: `simplifying-skill-bodies`.
- Git 상태 보존: `synchronizing-local-and-github-state`.
- 장기 작업 연속성: `maintaining-long-running-task-continuity`.
- 정본 최신성: `auditing-canonical-reference-freshness`.
- 변경 검증: `reviewing-and-validating-project-changes`.

### 다음 프로젝트 코어 PLAN

- 기존 코어 사실 판정: `identifying-project-core`.
- 핵심 컨셉·벤치마킹·PoC: `analyzing-and-refining-game-concepts`.
- 코어 제안·불변 조건·사용자 승인: `establishing-project-core`.
- 공격적 결함 검토: `running-adversarial-review-and-refinement`.
- 유저리서치 범위: `governing-game-user-research-coverage`.

### 프로젝트 고유 Skill

- 전투·성장·대회: `ten-paces-game-design`.
- 전투 UX·접근성: `combat-ux-and-accessibility`.
- Godot 구현 인수: `combat-implementation-handoff`.
- 십보강호 반례·증거: `ten-paces-verification`.

Base 활성 Skill 25개 전체 ID와 trigger는 `SKILL_REGISTRY.json`이 책임진다. 전체를 기본 로드하지 않는다.

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

- PR #7: `agent/t0-combat-poc-board`.
- 기준 SHA: `147a031c75e96bff170d7f99016beb9e85b12066`.
- 최신 승인 Issue: #13.
- 정합화 브랜치: `agent/pr7-canonical-skill-refresh`.

구형 Draft PR은 기본 읽기·병합 입력이 아니다. 고유 정보 보존 확인 뒤 superseded 상태로 정리한다.

## 경계

- 운영 문서는 제품 본책 전문을 복제하지 않는다.
- 한 질문에 현행 책임 원본 하나만 둔다.
- 활성 본문에는 현재 계약만 두고 과거 전문은 Git 이력에서 찾는다.
- 모든 등록 문서와 Skill Registry는 생성기가 없어 `source_only`다.
- Workflow 존재·Actions 성공·Godot 런타임·Windows 기술 증거·사람 검수·Required Check 강제를 구분한다.
- 백업·보류·제거 후보·과거 Plan은 기본 읽기와 구현에서 제외한다.
