# Base 규칙 적용 버전

## 1. 기준

- Base: `alsdmlals4-eng/Base@41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 이전 프로젝트 기준: `ee265576da7f67d3278f8099dd97d4e714ef0651`.
- 추가 비교: 6개 커밋·43개 변경 파일.
- 동기화 날짜: `2026-07-23`.
- 전투 기준: PR #7 `agent/t0-combat-poc-board@147a031c75e96bff170d7f99016beb9e85b12066`.
- 최신 승인 범위: Issue #13 STEP 12~14.
- 감사: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`.
- 검증: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_VERIFICATION.md`.

정식 버전명보다 commit SHA를 재현 가능한 기준으로 사용한다. 일상 작업은 프로젝트에 동기화된 Registry·검사·문서를 우선하고 Base 원격은 재감사 조건에서만 다시 비교한다.

## 2. 적용한 공용 운영 계약

### Work Mode·Skill

- Work Mode: `PLAN / BUILD / REVIEW`.
- Registry trigger 기반 최소 Skill·Skill Mode 자동 선택.
- 전체 Skill 기본 로드 금지.
- 주 책임 분야 Skill 최대 1개, 필요한 Foundation만 조건부 선택.
- L1 이상 `execution-report`.
- 기존 프로젝트 변경은 `audit → reconcile-legacy → 승인 변경 → verify`.

### Base 활성 Skill 25개

1. `managing-project-intake-and-work-contract`
2. `managing-game-project-operating-system`
3. `managing-design-documents`
4. `evolving-project-discipline-skills`
5. `maintaining-project-context-and-handoff`
6. `analyzing-and-refining-game-concepts`
7. `designing-vertical-slices`
8. `orchestrating-deepseek-worktrees`
9. `reviewing-and-validating-project-changes`
10. `auditing-canonical-reference-freshness`
11. `designing-art-prompts-and-technique-cards`
12. `auditing-and-refining-ui-art`
13. `managing-base-change-proposals`
14. `identifying-project-core`
15. `establishing-project-core`
16. `running-adversarial-review-and-refinement`
17. `refactoring-with-contract-preservation`
18. `simplifying-skill-bodies`
19. `pruning-stale-and-nonfunctional-material`
20. `synchronizing-local-and-github-state`
21. `maintaining-long-running-task-continuity`
22. `governing-game-user-research-coverage`
23. `creating-user-learning-notes`
24. `building-project-visual-dashboards`
25. `diagnosing-game-engine-runtime-failures`

프로젝트에 Base Skill 패키지를 복제하지 않는다. `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`이 ID와 trigger를 라우팅한다.

### 프로젝트 고유 Skill 4개

- `ten-paces-game-design`.
- `combat-ux-and-accessibility`.
- `combat-implementation-handoff`.
- `ten-paces-verification`.

로컬 Skill은 프로젝트 고유 판단·반례만 소유하고 현재 STEP 상태는 Active Context와 본책에서 읽는다.

## 3. 문서·발행 계약

- 한 질문에 Markdown 또는 JSON 책임 원본 하나.
- 현재 본책은 현재 계약만 설명한다.
- 과거 전문은 Git 이력·Change Log·Learning Log에서 찾는다.
- 날짜별 보정 절을 활성 본문에 누적하지 않는다.
- PDF·DOCX·다이어그램은 파생본이다.
- 현재 11개 제품 기획 문서와 Skill Registry는 생성기가 없어 `source_only`다.
- PDF가 필요한 마일스톤에서 생성기·폰트·Manifest·렌더·사용자 검수를 함께 설치하고 필요한 문서만 `milestone_sync`로 승격한다.
- 생성 실패 시 기존 정상 산출물을 보존한다.

## 4. 정본 최신성 계약

`.github/reference-freshness.json`이 다음 구조화 기대값을 소유한다.

- board contract schema 16.
- Base commit `41a20584...`.
- Base 활성 Skill 25개.
- 프로젝트 고유 Skill 4개.
- 활성 문서의 필수 현행 토큰과 금지 stale 토큰.
- 책임 원본→활성 소비자 연결.

운영·Skill 검사기는 이 설정을 읽고 별도 SHA·Skill 수를 하드코딩하지 않는다.

## 5. 십보강호 고유 계약

프로젝트에만 남긴다.

- `[강호낭인]`.
- 전장 10칸, 플레이어 4번·상대 7번, 거리 3, 거리 0 `[밀착]`.
- 라운드 `3수 → 3수 → 4수`.
- 기초 행동 8종과 절초 3종.
- 합·방어·회피·필중·중단·강건.
- 공개 상태 기반 최소 AI.
- 승패·무승부·4/7 재시작.
- T0 단일 전투 → T1 최소 세로 슬라이스 → T2 5전 데모 → 전체 10전.
- 세력·무공·심법·성장·제약 가설.
- Godot 코드·데이터·씬·자산·테스트·런타임 상태.

## 6. 이번 동기화 결과

- Base 6개 커밋·43개 파일을 프로젝트 영향 기준으로 재감사했다.
- 프로젝트 코어·적대적 검토·구조 최적화·동기화·연속성·유저리서치·런타임 진단 Skill을 route에 추가했다.
- 로컬 Skill 4개는 유지하고 진행 상태 복제를 제거했다.
- board schema 16·Base SHA·Skill 집합을 단일 freshness 설정으로 통합했다.
- stale 문장 위에 최신 보정 절을 붙여도 실패하는 반례를 추가했다.
- 추적된 Python 캐시를 제거하고 재발을 차단했다.
- PR #7 제품 코드·데이터·씬·자산은 정합화 범위에서 보호한다.

## 7. 검증 상태

```yaml
base_diff_audit: COMPLETE
registry_update: APPLIED_IN_REFRESH_BRANCH
document_rewrite: IN_PROGRESS
governance_checks: NOT_RUN_ON_REFRESH_HEAD
card_contract: NOT_RUN_ON_REFRESH_HEAD
product_file_preservation: PENDING_FINAL_DIFF
human_step14: NOT_RUN
```

최신 Actions와 최종 baseline diff 전에는 통합 완료로 표시하지 않는다.

## 8. 재감사 조건

- Base SHA·Skill Registry·coverage 변경.
- board schema·전장·라운드·합·절초·AI 계약 변경.
- 책임 원본·경로·ID·Schema·발행 정책 변경.
- 프로젝트 코어 승인·재개방.
- STEP 14 사람 결과와 T1 진입.
- 운영체계 통합·삭제·대규모 검증.
