# Base main 전면 동기화 감사

## 1. 작업 계약

- 대상 저장소: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`
- 기존 적용 Base: `eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- 신규 적용 Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- Base 비교: 기존 기준보다 `155` commits ahead, changed files `70`
- Work Mode: `PLAN → BUILD → REVIEW`
- 주 Skill: `managing-game-project-operating-system`
- Skill Mode: `audit → reconcile-legacy → migrate → verify`
- 후속 검증: `auditing-canonical-reference-freshness`, `reviewing-and-validating-project-changes`
- 사용자 승인 근거: Base 전체 확인·프로젝트 반영·세부 PR 체크 직접 요청

## 2. 보존 계약

다음은 Base 동기화로 변경하지 않는다.

- 십보강호의 세계관·용어·밸런스·전투 수치·콘텐츠 범위
- 승인된 전투 POC 구현과 사용자 Windows 확인 결과
- 기존 `docs/01~11`, `docs/[백업]`, PR·Git 이력
- 승인 이미지·UI 방향·Godot 자산
- 실행하지 않은 런타임·접근성·성능·Branch protection 검증의 미검증 상태

템플릿과 Base 전용 스킬 패키지를 폴더째 복사하지 않는다. 프로젝트의 기존 책임 원본·경로·스킬에 분화해 반영한다.

## 3. 핵심 적용 결과

| Base 변화 | 프로젝트 적용 |
|---|---|
| Work Mode `PLAN / BUILD / REVIEW` | `AGENTS.md`, `AI_WORKFLOW.md`, Skill Registry, PR 보고 형식에 적용 |
| 자동 Skill·Skill Mode 라우팅 | `default_selection=automatic-trigger-match`, 실행 보고 필수화 |
| 13개 통합 Skill | 프로젝트 로컬 스킬은 유지하고 Base 통합 Skill·mode와 연결 |
| 구형 파일 reconciliation | 처리 상태와 승인 없는 삭제 금지를 Source Audit·Lifecycle·Gates에 적용 |
| 정본 최신성 감사 | 전용 설정·검사기·회귀 테스트·Workflow 단계 추가 |
| 정책 기반 발행 | `source_only / milestone_sync / always_sync`를 Registry·Governance에 적용 |
| 접근성·성능 검증 | 변경 영향이 있을 때만 실행하고 미실행을 `NOT_RUN/UNVERIFIED`로 분리 |
| Skill 패키지 무결성 | Registry·SKILL.md·Learning Log·고아 reference/script 연결 검사 추가 |
| 실행 순서 분해 | 결과·의존성·게이트·롤백 기반 실행 계획 템플릿 연결 |
| 벤치마크·플레이테스트 | 출처·표본·행동·결정 분리와 `ADOPT/ADAPT/AVOID/TEST/IGNORE` 계약 적용 |

## 4. Base 변경 파일 70개 전수 판정

상태:

- `ADAPT`: 프로젝트 운영 파일에 직접 분화 반영
- `ADD_LOCAL`: 프로젝트용 검사·템플릿을 추가
- `REFERENCE`: Base 원본을 경로로 참조하고 프로젝트에 중복 복사하지 않음
- `LEGACY_ALIAS`: 제거된 구형 Skill은 새 통합 Skill·mode로 연결
- `BASE_ONLY`: Base 자체 저장소 검증·사례이므로 프로젝트에는 복사하지 않되 관련 계약은 반영

### 4.1 GitHub·루트·운영 문서

- [x] `.github/reference-freshness.json` → `ADD_LOCAL`: 프로젝트 정본·Skill·전투 규칙 소비자 기준 설정
- [x] `.github/workflows/validate-game-project-operating-system.yml` → `ADAPT`: 기존 `documentation-governance.yml`에 최신성·Skill 무결성 단계 통합
- [x] `AGENTS.md` → `ADAPT`: Work Mode, 자동 라우팅, 실행 보고, reconciliation, 접근성·성능·참조 최신성
- [x] `README.md` → `ADAPT`: 현행 10수 POC와 최신 Base 기준으로 수정
- [x] `START_HERE.md` → `ADAPT`: Base Operating Model·Work Mode·Skill Routing·프로젝트 허브 순서
- [x] `docs/AI_SHARED_WORK_RULES.md` → `REFERENCE`: 핵심 규칙을 프로젝트 `AGENTS.md`에 분화
- [x] `docs/AI_SKILL_ADOPTION_GUIDE.md` → `REFERENCE`: Skill Registry·Execution Report 규칙에 분화
- [x] `docs/AI_WORKFLOW_RULES.md` → `ADAPT`: 프로젝트 `AI_WORKFLOW.md`에 분화
- [x] `docs/DOCUMENTATION_MAP.md` → `ADAPT`: 프로젝트 허브 `DOCUMENTATION_MAP.md`에 분화
- [x] `docs/MVP_WORKFLOW_CHECKLIST.md` → `ADAPT`: `DEVELOPMENT_GATES.md`와 PR 체크리스트에 분화
- [x] `docs/OPERATING_MODEL.md` → `ADAPT`: 프로젝트 운영 생명주기·상태·발행·검증 계약에 반영
- [x] `docs/WORK_MODE_AND_SKILL_ROUTING.md` → `ADAPT`: 프로젝트 Work Mode·Skill·Skill Mode 자동 선택 계약에 반영
- [x] `docs/knowledge/README.md` → `BASE_ONLY`: Base 지식 인덱스이며 프로젝트는 필요한 Base 경로만 참조
- [x] `docs/knowledge/methods/DISCIPLINE_PDF_PUBLICATION_METHOD.md` → `REFERENCE`: `managing-design-documents: publish/validate`
- [x] `docs/knowledge/methods/DISCIPLINE_SKILL_EVOLUTION_METHOD.md` → `REFERENCE`: `evolving-project-discipline-skills`
- [x] `docs/knowledge/methods/EXISTING_PROJECT_SAFE_MIGRATION_METHOD.md` → `REFERENCE`: 운영체계 Skill `audit/reconcile-legacy/migrate`
- [x] `docs/knowledge/methods/GAME_PROJECT_OPERATING_SYSTEM_METHOD.md` → `REFERENCE`: `docs/OPERATING_MODEL.md`와 운영체계 Skill
- [x] `docs/knowledge/methods/PROJECT_HANDOFF_CONTEXT_METHOD.md` → `REFERENCE`: `maintaining-project-context-and-handoff`

### 4.2 Schema

- [x] `schemas/base-skill-registry-v1.schema.json` → `REFERENCE`: Base 공유 Registry Schema, 프로젝트 v3 Registry에 자동 라우팅 필드 적용
- [x] `schemas/design-document-registry-v3.schema.json` → `ADAPT`: `source_only/milestone_sync/always_sync`와 독립 발행 상태 반영

### 4.3 Skill·reference

- [x] `skills/LEGACY_SKILL_ALIASES.md` → `ADD_LOCAL`: 프로젝트용 Base 통합 Skill 별칭표 추가
- [x] `skills/SKILL_LEARNING_LOG.md` → `ADAPT`: Work Mode·Skill Mode·실행 결과·미검증 필드 적용
- [x] `skills/SKILL_REGISTRY.json` → `ADAPT`: 13개 Base 통합 Skill 라우팅과 프로젝트 스킬 연결
- [x] `skills/analyzing-and-refining-game-concepts/SKILL.md` → `REFERENCE`: 컨셉·DDD·벤치마크·플레이테스트·PoC mode 연결
- [x] `skills/analyzing-and-refining-game-concepts/references/benchmark-player-evidence-and-playtests.md` → `REFERENCE`: 조사·플레이테스트 템플릿 연결
- [x] `skills/auditing-and-refining-ui-art/SKILL.md` → `REFERENCE`: 구현된 Godot UI 감사 시 사용
- [x] `skills/auditing-canonical-reference-freshness/SKILL.md` → `ADD_LOCAL`: 프로젝트 검사·감사 템플릿·Workflow로 실행
- [x] `skills/conducting-deep-requirement-interviews/SKILL.md` removed → `LEGACY_ALIAS`: `managing-project-intake-and-work-contract: clarify`
- [x] `skills/designing-vertical-slices/SKILL.md` → `REFERENCE`: T0 POC와 Vertical Slice를 구분하고 접근성·성능·외부 플레이 증거 추가
- [x] `skills/evolving-project-discipline-skills/SKILL.md` → `REFERENCE`: 프로젝트 Skill 갱신·통합·학습 계약
- [x] `skills/installing-game-project-operating-system/SKILL.md` removed → `LEGACY_ALIAS`: `managing-game-project-operating-system: install`
- [x] `skills/managing-base-change-proposals/SKILL.md` → `REFERENCE`: 프로젝트 교훈의 BCP 생명주기
- [x] `skills/managing-design-documents/SKILL.md` → `REFERENCE`: 책임 원본·발행 정책
- [x] `skills/managing-game-project-operating-system/SKILL.md` → `ADAPT`: 이번 감사·마이그레이션의 주 절차
- [x] `skills/managing-project-intake-and-work-contract/SKILL.md` → `ADAPT`: 자동 Work Mode·라우팅·실행 계약·실행 보고
- [x] `skills/managing-project-intake-and-work-contract/references/ambiguity-and-closure.md` renamed → `REFERENCE`: 새 경로 사용
- [x] `skills/managing-project-intake-and-work-contract/references/question-and-source-model.md` renamed → `REFERENCE`: 새 경로 사용
- [x] `skills/managing-project-intake-and-work-contract/references/work-decomposition-and-sequencing.md` → `ADD_LOCAL`: 실행 순서 Plan 템플릿 연결
- [x] `skills/migrating-existing-game-project-structure/SKILL.md` removed → `LEGACY_ALIAS`: 운영체계 Skill `audit/migrate`
- [x] `skills/orchestrating-deepseek-worktrees/SKILL.md` → `REFERENCE`: 외부 AI 대량 작업이 있을 때만 사용
- [x] `skills/promoting-project-knowledge/SKILL.md` removed → `LEGACY_ALIAS`: `managing-base-change-proposals`
- [x] `skills/publishing-discipline-bibles/SKILL.md` removed → `LEGACY_ALIAS`: `managing-design-documents: publish/validate`
- [x] `skills/reviewing-and-implementing-base-change-proposals/SKILL.md` removed → `LEGACY_ALIAS`: `managing-base-change-proposals`
- [x] `skills/reviewing-and-validating-project-changes/SKILL.md` → `ADAPT`: 계약·정적·런타임·접근성·성능·회귀 검증
- [x] `skills/reviewing-and-validating-project-changes/references/accessibility-and-performance-validation.md` → `REFERENCE`: UI·성능 영향 작업에 조건부 적용
- [x] `skills/reviewing-external-ai-drafts/SKILL.md` removed → `LEGACY_ALIAS`: 변경 검증 Skill `external-source-review`
- [x] `skills/routing-project-work-by-discipline/SKILL.md` removed → `LEGACY_ALIAS`: intake Skill `route`
- [x] `skills/transforming-requests-into-prompts/SKILL.md` removed → `LEGACY_ALIAS`: intake Skill `contract`
- [x] `skills/verifying-game-project-operating-system/SKILL.md` removed → `LEGACY_ALIAS`: 운영체계 Skill `verify`
- [x] `skills/writing-game-design-documents/SKILL.md` removed → `LEGACY_ALIAS`: `managing-design-documents: author/update`

### 4.4 Template

- [x] `templates/AGENTS.project.md` → `ADAPT`: 프로젝트 `AGENTS.md` 갱신
- [x] `templates/planning/EXECUTION_SEQUENCE_PLAN.md` → `ADD_LOCAL`: 검증 가능한 단계·의존성·게이트·롤백 템플릿
- [x] `templates/planning/GAME_BENCHMARK_PLAYER_EVIDENCE.md` → `ADD_LOCAL`: 벤치마크·플레이어 증거 기록 템플릿
- [x] `templates/planning/GAME_CONCEPT_DIRECTION_REVIEW.md` → `ADD_LOCAL`: 컨셉·DDD·PoC 재조정 템플릿
- [x] `templates/project-operations/AI_WORKFLOW.md` → `ADAPT`: 프로젝트 AI Workflow 갱신
- [x] `templates/project-operations/LEGACY_ARTIFACT_RECONCILIATION.md` → `ADD_LOCAL`: 구형 파일 처리표
- [x] `templates/project-operations/PROJECT_START_HERE.md` → `ADAPT`: 루트·허브 START_HERE 갱신
- [x] `templates/project-operations/README.md` → `REFERENCE`: 전체 복사 금지, 선택 분화 설치 원칙 적용
- [x] `templates/project-operations/SKILL_EXECUTION_REPORT.md` → `ADD_LOCAL`: L1 이상 실행 보고 템플릿
- [x] `templates/project-operations/SKILL_REGISTRY.json` → `ADAPT`: 자동 라우팅 정책 필드 적용
- [x] `templates/project-operations/github/check_design_document_publications.py` → `ADAPT`: 정책 기반 발행 검사 계약만 반영, PDF 강제는 현재 보류
- [x] `templates/project-operations/github/documentation-governance.json` → `ADAPT`: 필수 최신성·스킬 무결성 설정 추가
- [x] `templates/quality/CANONICAL_REFERENCE_FRESHNESS_AUDIT.md` → `ADD_LOCAL`: 감사 기록 템플릿
- [x] `templates/quality/PROJECT_CHANGE_VALIDATION.md` → `ADD_LOCAL`: 변경 검증 증거 템플릿

### 4.5 Test·Tool

- [x] `tests/test_consolidated_skill_references.py` → `ADD_LOCAL`: Legacy Alias와 활성 참조 검사에 분화
- [x] `tests/test_deep_interview_contract.py` → `ADAPT`: intake Skill의 사용자 확인·contract 검사로 대체
- [x] `tests/test_design_document_publication_governance.py` → `ADAPT`: 문서별 발행 정책 검증
- [x] `tests/test_game_project_operating_system_structure.py` → `ADAPT`: 기존 문서 Governance 검사 확장
- [x] `tests/test_policy_driven_publication.py` → `ADD_LOCAL`: 발행 정책 검사 준비, 실제 PDF는 별도 게이트
- [x] `tests/test_project_skill_map_generation.py` → `REFERENCE`: Skill Map 발행을 재개할 때 적용
- [x] `tests/test_reference_freshness.py` → `ADD_LOCAL`: 프로젝트 정본 최신성 회귀 검사
- [x] `tests/test_skill_package_integrity.py` → `ADD_LOCAL`: 활성 프로젝트 Skill 패키지 무결성 검사
- [x] `tools/build_policy_driven_design_documents.py` → `REFERENCE`: PDF 발행 게이트에서 프로젝트 생성기와 함께 적용
- [x] `tools/check_canonical_reference_freshness.py` → `ADD_LOCAL`: 프로젝트 경로·용어·Base SHA·2수 stale 참조 검사

## 5. 프로젝트 현행 drift 판정

| 항목 | 이전 상태 | 동기화 판정 |
|---|---|---|
| Base SHA | `eb40b9…` | 최신 `ee2655…`로 갱신 |
| Skill 선택 | `default_selection=none` | `automatic-trigger-match` |
| Work Mode | 명시 없음 | `PLAN/BUILD/REVIEW` |
| Skill Mode 실행 보고 | 명시 없음 | L1 이상 필수 |
| 제품 소개 | 행동 두 개·2수 중심 | `3수 → 3수 → 4수`, 10수 라운드로 갱신 |
| 기초 행동 | 7종 | 보법 포함 8종 |
| 구현 상태 | STEP 1·2 수준 | STEP 0~10 + TARGETING 10.5 + RESPONSE/RESOURCE 10.6 |
| 런타임 상태 | Windows 기술 검증 완료 | STEP 0~10·방향 지정·배치·4/7·RESPONSE·RESOURCE PREVIEW와 Issue #11 런타임 증거 확보 |
| 접근성·성능 | 일반 문구 | 영향 발생 시 독립 조건부 검증 |
| 정본 최신성 | 수동 검색 | 설정·검사기·Workflow 회귀 검사 |
| 구형 Skill ID | 활성 문서에 잔존 가능 | Legacy Alias로만 허용 |

## 6. 검증 계획

- [ ] 루트·허브 콜드 스타트 순서 일치
- [ ] Base SHA와 동기화 날짜 일치
- [ ] Skill Registry 자동 라우팅 정책 일치
- [ ] 활성 Skill 6개 Registry·SKILL.md·Learning Log 연결
- [ ] Base 통합 Skill Legacy Alias 연결
- [ ] `2수`, `두 행동`, `2수 잠금` stale 현행 표현 차단
- [ ] 현행 10수·3-3-4·8개 기초 행동·STEP 10.6 상태 일치
- [ ] Design Registry 발행 정책 허용값 검사
- [ ] 정본·경로·ID·Schema 소비자 최신성 검사
- [ ] Governance·reference-freshness·Skill package integrity Actions 성공
- [ ] PR #5·#7 본문에 파일별 동기화 체크 반영
- [ ] 사용자 Windows에서 최신 Godot 통합 검증
- [ ] Branch protection Required Check 실제 강제 상태 확인

## 7. 미검증·보류

- PDF·DOCX·다이어그램·Manifest 실제 생성과 전 페이지 시각 검수
- 목표 플랫폼 성능 프로파일
- 접근성 플레이 장벽의 실제 사용자 검수
- 사용자 로컬 저장소의 미커밋 파일 유무
- Branch protection 변경·강제
- RESPONSE 10.6 최신 런타임 판정

## 8. 롤백

- 모든 변경은 기존 파일의 in-place 갱신 또는 새 감사·검증 파일 추가로 제한한다.
- 기존 제품 본책·백업·보류·Plan을 삭제하거나 이동하지 않는다.
- 문제가 생기면 동기화 시작 직전 브랜치 커밋으로 되돌릴 수 있다.
