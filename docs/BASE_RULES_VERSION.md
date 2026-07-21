# Base 규칙 적용 버전

## 기준 정보

- Base 저장소: `alsdmlals4-eng/Base`
- 기준 브랜치: `main`
- 이전 기준 커밋: `eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- 현재 기준 커밋: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 비교 결과: 이전 기준보다 `155` commits ahead, changed files `70`
- 프로젝트 동기화 날짜: `2026-07-21`
- 적용 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`
- 최초 대상 기준 커밋: `0ac66389ad6b1d10019680ebf1417d423fa1466e`
- 운영체계 PR: `#5 agent/base-full-11-migration`
- 전투 POC 스택 PR: `#7 agent/t0-combat-poc-board`
- 상세 전수 감사: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`

정식 버전 이름만으로 Unreleased 계약을 재현할 수 없으므로 Base commit SHA를 동기화 기준선으로 사용한다. 프로젝트는 이 파일과 로컬 운영 문서를 우선하고 원격 Base는 업데이트 감사 때만 비교한다.

## 현재 적용한 Base 운영 계약

### Work Mode·Skill 라우팅

- Work Mode는 `PLAN / BUILD / REVIEW` 중 현재 단계의 주 모드 하나를 사용한다.
- 사용자가 Skill 이름을 선택하지 않아도 Registry trigger로 최소 Skill·Skill Mode를 자동 선택한다.
- `load_by_default=false`는 자동 선택 금지가 아니라 trigger가 없을 때 읽지 않는다는 뜻이다.
- 주 책임 분야 Skill은 최대 하나이며 Foundation Skill은 필요한 최소 개수만 사용한다.
- L1 이상 완료 보고에는 실제 사용한 Work Mode·Skill·Skill Mode, 선택 이유, 수행 내용, 결과·증거와 미검증을 기록한다.

### 통합 Skill

Base의 활성 실행 Skill은 13개다.

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

통합 전 Skill ID는 `skills/LEGACY_SKILL_ALIASES.md`에서 새 Skill과 Skill Mode로 연결한다. 새 운영 문서·Registry·작업 계약에는 구형 ID를 사용하지 않는다.

### 책임 원본·발행

- 한 질문에는 Registry에 등록된 Markdown 또는 JSON 책임 원본 하나만 둔다.
- 서술 중심 기획은 Markdown, Registry·Manifest·상태·ID·경로·게임 데이터는 JSON을 사용한다.
- 문서 발행 정책은 `source_only / milestone_sync / always_sync` 중 하나다.
- PDF·DOCX·다이어그램은 파생본이며 독립 책임 원본이 아니다.
- `CURRENT`, 자동 렌더, AI 시각 검수, 사용자 시각 검수는 독립 상태다.
- 생성 실패 시 기존 정상 산출물을 보존한다.

### 기존 프로젝트 안전 적용

```text
PLAN: audit
→ 필요 시 reconcile-legacy 처리표
→ 목표 구조·보존·롤백 제안
→ 사용자 승인
→ BUILD: 승인된 UPDATE·MERGE·STUB·ARCHIVE·DELETE·migrate
→ REVIEW: reference-freshness·회귀·복구 검증
→ verify
```

구형 파일은 `CURRENT / UPDATE_IN_PLACE / MERGE_TO_CANONICAL / COMPATIBILITY_STUB / ARCHIVE_HISTORY / DELETE_APPROVED / KEEP_UNRESOLVED`로 판정한다. 고유 정보·참조·파생본·복구·사용자 승인이 확인되지 않으면 삭제하지 않는다.

### 변경 검증

```text
contract-check
→ 필요한 경우 external-source-review
→ 정본·경로·ID·Schema 변경 시 reference-freshness
→ static-validation
→ runtime-validation
→ 적용 시 accessibility-review
→ 적용 시 performance-profile
→ regression
→ evidence-report
```

실행하지 않은 검증은 `NOT_RUN`, `UNVERIFIED` 또는 `[미검증]`으로 기록한다. Workflow 파일 존재, Actions 성공, Required Check 강제는 서로 다른 상태다.

## 십보강호 프로젝트 구체화

Base는 작업 방법을 책임지고 다음 프로젝트 고유 정보는 십보강호 저장소가 책임진다.

- 10칸 전장과 플레이어 3번·상대 8번 시작 위치
- 한 라운드 `3수 → 3수 → 4수`, 총 10수
- 판정 순서 `대응 → 속공 → 이동 → 일반 공격`
- 기초 행동 8종: 이동·보법·막기·회피·속공·강공·명상·태세
- 절초 기세 최대 5칸
- 강공·보법·대응 연계·자원 미리보기 세부 규칙
- 5전 데모와 전체 10전 범위
- Godot 경로·코드·자산·테스트·실제 런타임 상태

현재 구조:

- 기존 `docs/01~11`은 Markdown 책임 원본으로 보존한다.
- `[기획서]/DESIGN_DOCUMENT_REGISTRY.json`이 책임·경로·발행 정책을 연결한다.
- `[기획서]/00_프로젝트_허브`는 상태·Registry·Skill·게이트 라우터이며 제품 본책 전문을 복제하지 않는다.
- 선택 책임 분야는 게임 디자인, UX·UI·접근성, 개발·엔지니어링, QA, 프로덕션·PM, 통합검수다.
- 기존 본책·백업·보류·Plan은 별도 승인 전 이동·삭제하지 않는다.

## Base 최신 변화의 프로젝트 반영

- Work Mode와 자동 Skill·Skill Mode 라우팅
- 실행 이유·결과·증거 보고
- 통합 Skill과 Legacy Alias
- 구형 파일 reconciliation 처리표
- 정본·참조 최신성 감사와 untouched 소비자 검사
- 정책 기반 문서 발행
- 벤치마크·플레이어 증거·PoC·플레이테스트 계약
- 접근성·성능 조건부 검증
- Skill 패키지 Registry·reference·script 무결성 검사
- 실행 순서의 결과·의존성·게이트·롤백 계약

## 검증 상태

### 확인됨

- Base `START_HERE`, `AGENTS`, `OPERATING_MODEL`, `WORK_MODE_AND_SKILL_ROUTING`, `DOCUMENTATION_MAP`, `SKILL_REGISTRY`, Changelog와 기존 기준 이후 70개 변경 파일을 감사했다.
- 프로젝트의 루트·허브·Registry·Skill·Workflow·전투 POC 상태를 대조했다.
- 상세 파일별 판정은 `BASE_MAIN_SYNC_AUDIT.md`에 기록했다.
- 기존 제품 본책·백업·보류·Plan을 제거하지 않았다.

### 진행 중

- 프로젝트 운영 파일의 Work Mode·자동 라우팅·최신 구현 상태 갱신
- 정본 최신성·Skill 패키지 무결성 검사와 Workflow 연결
- PR #5·#7 체크리스트 갱신

### `MIGRATION_PENDING`

- 기획서 PDF·Publication Manifest
- Project Skill Map PDF·선택 DOCX·다이어그램
- 발행 도구·한글 폰트·LibreOffice·Poppler·Mermaid 실제 사전점검
- PDF 전 페이지 자동 렌더·사용자 시각 검수

### `[미검증]`

- 사용자 로컬 작업본의 미커밋 파일과 원격 차이
- RESPONSE 10.6 최신 Godot 런타임 판정
- 실제 접근성 사용자 검수
- 목표 플랫폼 성능 프로파일
- Branch protection Required Check 강제 상태

## Base 환류 계약

```text
프로젝트 관찰·검증
→ 프로젝트 고유 값 분리
→ 기존 Base 중복·충돌 확인
→ Base [수정제안서] 제안 전용 PR
→ 사용자 검토·구현 승인
→ 별도 Base 구현 PR
→ 프로젝트 Learning Log 갱신
```

사용자가 특정 Base 변경을 직접 승인한 경우에만 제안 단계를 생략할 수 있다.

## 갱신 조건

다음 경우 Base `main`과 프로젝트의 차이를 다시 감사한다.

- Base 기준 SHA를 변경할 때
- Work Mode·Skill·Skill Mode·Registry Schema가 바뀔 때
- 책임 원본·경로·ID·발행 정책·생성기가 바뀔 때
- 프로젝트 운영체계를 설치·정리·마이그레이션·대규모 검증할 때
- 프로젝트 교훈을 Base 제안으로 제출하거나 승인 구현한 뒤
- 새 작업자가 현재 Base 기준과 프로젝트 문서의 충돌을 발견할 때

Base 원격과 프로젝트는 자동 동기화되지 않는다. 이 파일의 SHA와 프로젝트별 차이가 재현 가능한 기준이다.
