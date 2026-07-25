# Base 규칙 적용 버전

## 1. 기준

- 기존 Base Registry: `alsdmlals4-eng/Base@41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 신규 adapter-only 공용 route: `alsdmlals4-eng/Base@c7c1103e4a69f8fdc9ee27aa382a21288605a7fb`.
- 프로젝트 route Registry: `[기획서]/00_프로젝트_허브/BASE_SHARED_SKILL_ROUTES.json`.
- 프로젝트 어댑터: `[기획서]/00_프로젝트_허브/BASE_SHARED_SKILL_ADAPTER.json`.
- 제3자 자산·플러그인 기록: `[기획서]/00_프로젝트_허브/THIRD_PARTY_ASSET_AND_PLUGIN_INVENTORY.json`.
- 이전 프로젝트 기준의 재현 가능한 SHA는 `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`가 보존한다.
- 추가 비교: 6개 커밋·43개 변경 파일.
- 동기화 날짜: `2026-07-25`.
- 전투 기준: PR #7 `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 코어 확정 PR: #15 `agent/project-core-confirmation`.
- 최신 승인 범위: Issue #13 STEP 12~14.
- 감사: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`.
- 검증: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_VERIFICATION.md`.

기존 25개 Base Skill은 기존 고정 커밋을 유지하고, 신규 두 공용 Skill만 별도 route Registry의 고정 커밋에서 읽는다. 일상 작업은 프로젝트에 동기화된 Registry·route·adapter·검사·문서를 우선하고 Base 원격은 재감사 조건에서만 다시 비교한다.

## 2. 적용한 공용 운영 계약

### Work Mode·Skill

- Work Mode: `PLAN / BUILD / REVIEW`.
- Registry trigger 기반 최소 Skill·Skill Mode 자동 선택.
- 전체 Skill 기본 로드 금지.
- 주 책임 분야 Skill 최대 1개, 필요한 Foundation만 조건부 선택.
- L1 이상 `execution-report`.
- 기존 프로젝트의 레거시 수명주기는 `governing-legacy-retention-and-archives`를 route하고, 운영체계 설치·마이그레이션은 `managing-game-project-operating-system`이 담당한다.
- Godot 기능·에셋·플러그인은 직접 제작 전에 `evaluating-godot-assets-and-plugins-before-creation`으로 기본 기능·공식 Store·기존 Asset Library·GitHub·itch.io·상용 후보를 조사한다.
- 구매·계정 연결·프로젝트 설치는 별도 사용자 승인 범위에서만 수행한다.

### 기존 Base 활성 Skill 25개

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

### 신규 adapter-only 공용 Skill 2개

1. `governing-legacy-retention-and-archives`
2. `evaluating-godot-assets-and-plugins-before-creation`

프로젝트에 Base Skill 패키지를 복제하지 않는다. 기존 25개는 `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`, 신규 두 Skill은 `[기획서]/00_프로젝트_허브/BASE_SHARED_SKILL_ROUTES.json`이 ID와 trigger를 라우팅하고 프로젝트 어댑터가 경로·정본·검증기만 연결한다.

### 프로젝트 고유 Skill 4개

- `ten-paces-game-design`.
- `combat-ux-and-accessibility`.
- `combat-implementation-handoff`.
- `ten-paces-verification`.

로컬 Skill은 십보강호 고유 판단·반례만 소유하고 현재 STEP 상태는 Active Context와 본책에서 읽는다. 앞으로 프로젝트 로컬 Skill은 프로젝트 전용 책임에만 만들며, Base 공용 책임은 adapter route로 사용한다.

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

`.github/reference-freshness.json`이 기존 Registry 세대의 다음 구조화 기대값을 소유한다.

- board contract schema 16.
- 기존 Base commit `41a20584...`.
- 기존 Base 활성 Skill 25개.
- 프로젝트 고유 Skill 4개.
- 활성 문서의 필수 현행 토큰과 금지 stale 토큰.
- 책임 원본→활성 소비자 연결.

신규 adapter-only 두 Skill의 정합성은 `BASE_SHARED_SKILL_ROUTES.json`, `BASE_SHARED_SKILL_ADAPTER.json`, `THIRD_PARTY_ASSET_AND_PLUGIN_INVENTORY.json`의 JSON 검사와 Base route 커밋·경로 대조로 별도 검증한다. 기존 freshness 기대값을 무단 변경하지 않는다.

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

- Base 기존 25개 Skill pin은 그대로 보존했다.
- 레거시 보존·아카이브와 Godot 에셋·플러그인 선행 검색을 신규 adapter-only route로 연결했다.
- 프로젝트 경로·정본·보호 대상·검증기는 프로젝트 어댑터에만 기록했다.
- 기존 `godot_ai` 애드온은 출처·버전·라이선스가 확인되기 전 `EXISTING_REVIEW_REQUIRED`로 보존했다.
- 로컬 Skill 4개는 유지하고 공용 Skill 복사본을 새로 만들지 않았다.
- 실제 레거시 삭제, 특정 에셋 구매·설치, 제품 코드·씬·데이터 수정은 수행하지 않았다.

## 7. 검증 상태

```yaml
base_legacy_registry_pin: PRESERVED
base_shared_route_pin: ADOPTED
project_adapter: ADDED
third_party_inventory: INITIALIZED
registry_update: NOT_REQUIRED_FOR_EXTENSION_ROUTE
product_file_preservation: PASS_FOR_DOCUMENT_AND_JSON_SCOPE
project_core: CORE_CONFIRMED
product_gate: REPEAT_POC
human_step14: NOT_RUN
runtime_validation: NOT_RUN
```

Godot 코드·Scene·데이터를 변경하지 않았으므로 Godot 런타임과 사람 STEP 14를 자동 PASS로 표시하지 않는다.

## 8. 재감사 조건

- 기존 Base SHA·Skill Registry·coverage 변경.
- adapter-only Base route SHA·Skill ID·어댑터 계약 변경.
- Godot 버전·목표 플랫폼·`addons/`·제3자 라이선스 변경.
- board schema·전장·라운드·합·절초·AI 계약 변경.
- 책임 원본·경로·ID·Schema·발행 정책 변경.
- 프로젝트 코어 승인·재개방.
- STEP 14 사람 결과와 T1 진입.
- 운영체계 통합·삭제·대규모 검증.
