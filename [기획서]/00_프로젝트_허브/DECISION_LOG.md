# 십보강호 결정 기록

## DEC-2026-001 — 이전 Base 기준

- 날짜: 2026-07-20
- 상태: `SUPERSEDED`
- 이전 결정: `Base@eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- 대체: DEC-2026-008

## DEC-2026-002 — 기존 Markdown 본책 보존

- 날짜: 2026-07-20
- 상태: 채택
- 결정: `docs/01~11`을 Markdown 책임 원본으로 보존한다.
- 이유: 프로젝트 고유 결정·수치·예외·미검증이 이미 있다.

## DEC-2026-003 — 루트 `[기획서]` 허브

- 날짜: 2026-07-20
- 상태: 채택
- 결정: 운영 Entry Point·Registry는 `[기획서]`에 두고 기존 `docs` 본책을 연결한다.

## DEC-2026-004 — 원본·발행 상태 분리

- 날짜: 2026-07-20
- 상태: 갱신
- 결정: 원본 생명주기·승인·구현·검증·발행 상태를 독립 관리한다.
- 최신 구체화: DEC-2026-015

## DEC-2026-005 — 선택 책임 분야

- 날짜: 2026-07-20
- 상태: 갱신
- 초기 선택: 게임 디자인, UX·UI·접근성, 개발·엔지니어링, QA, 프로덕션·PM, 통합검수.
- 최신 구체화: 공용 프로덕션·통합검수는 Base Skill이 담당하고 프로젝트 로컬 Skill은 4개 분야만 유지한다.

## DEC-2026-006 — Base 제안 승인 흐름

- 날짜: 2026-07-20
- 상태: 채택
- 결정: 프로젝트 교훈은 `[수정제안서]` 제안 PR → 사용자 승인 → 별도 구현 PR을 따른다.
- 예외: 사용자가 특정 Base 변경을 직접 승인한 경우.

## DEC-2026-007 — 로컬·원격 상태 분리

- 날짜: 2026-07-20
- 상태: 채택
- 결정: 원격 변경과 사용자 Windows 미커밋 상태를 자동 동일시하지 않는다.
- 경로: `C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves`

## DEC-2026-008 — 최신 Base 기준

- 날짜: 2026-07-21
- 상태: 채택
- 결정: `Base@ee265576da7f67d3278f8099dd97d4e714ef0651`을 기준선으로 사용한다.
- 비교: 이전 기준보다 155개 커밋·70개 변경 파일.
- 증거: `BASE_MAIN_SYNC_AUDIT.md`.

## DEC-2026-009 — Work Mode·자동 라우팅

- 날짜: 2026-07-21
- 상태: 채택
- 결정: `PLAN / BUILD / REVIEW`와 Registry trigger로 최소 Skill·Skill Mode를 자동 선택한다.
- L1 이상은 사용 이유·수행 내용·결과·증거·미검증을 보고한다.

## DEC-2026-010 — 초기 통합 Skill 구조

- 날짜: 2026-07-21
- 상태: `SUPERSEDED`
- 이전 결정: Base 13개와 프로젝트 로컬 Skill 6개를 연결한다.
- 대체: DEC-2026-014

## DEC-2026-011 — 정본 최신성·Skill 무결성

- 날짜: 2026-07-21
- 상태: 채택
- 결정: 정본·경로·ID·Schema·정책 변경 시 changed 파일과 expected-but-untouched 소비자를 검사한다.
- Skill은 Registry·SKILL.md·trigger·mode·Learning Log·entrypoint를 검사한다.

## DEC-2026-012 — 전투 POC 계약

- 날짜: 2026-07-21
- 상태: 채택
- 결정: 전장 10칸, 라운드 `3수 → 3수 → 4수`, 기초 행동 8종.
- 구현: STEP 0~10, TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6.
- 사용자 확인: STEP 0~10과 대상 지정.

## DEC-2026-013 — 비파괴 동기화

- 날짜: 2026-07-21
- 상태: 채택
- 결정: 제품 본책·백업·보류·Plan·Godot 자산을 삭제·이동하지 않는다.
- 운영 파일 정리는 reconciliation·승계·참조·복구·사용자 승인 뒤 수행한다.

## DEC-2026-014 — Base 공유 13개·로컬 고유 4개

- 날짜: 2026-07-22
- 상태: 채택
- 결정: Base 공유 Skill 13개를 Registry에 유지하고 프로젝트 로컬 Skill은 다음 4개만 둔다.
  - `ten-paces-game-design`
  - `combat-ux-and-accessibility`
  - `combat-implementation-handoff`
  - `ten-paces-verification`
- 제거: `project-operations-and-handoff`, `project-health-review`.
- 승계: Base intake·context/handoff·operating-system·change-validation·freshness Skill.
- 호환: Legacy Alias와 forbidden active path 검사.
- 이유: 공용 기능 중복 없이 십보강호 고유 판단만 로컬에 유지한다.

## DEC-2026-015 — 현재 발행 정책은 `source_only`

- 날짜: 2026-07-22
- 상태: 채택
- 결정: 현재 11개 기획 문서와 Skill Registry는 모두 `source_only`다.
- 이유: 저장소에 `tools/build_design_documents.py`와 실제 PDF 발행 파이프라인이 없다.
- 금지: 실행 불가능한 `always_sync` 또는 가짜 `milestone_sync` 선언.
- 승격 조건: PDF가 필요한 마일스톤에서 생성기·폰트·Manifest·렌더·사용자 검수를 함께 설치.

## DEC-2026-016 — 템플릿·검사 통합

- 날짜: 2026-07-22
- 상태: 채택
- 결정:
  - 컨셉·벤치마크 템플릿을 `GAME_CONCEPT_AND_EVIDENCE_REVIEW.md`로 통합.
  - 정본 최신성 양식을 `PROJECT_CHANGE_VALIDATION.md`에 통합.
  - Governance 회귀 테스트를 `test_project_governance.py`로 통합.
  - 중복 `check_documentation_governance.py` 제거.
- 보존: 실행 순서·실행 보고·reconciliation·변경 검증의 독립 책임.

## DEC-2026-017 — 콜드 스타트 축소

- 날짜: 2026-07-22
- 상태: 채택
- 기본 읽기: `AGENTS → ACTIVE_CONTEXT → DOCUMENTATION_MAP → 현재 책임 원본 → 실제 파일`.
- Gates·Roadmap·Registry·Audit·Handoff는 Map이 지시할 때만 읽는다.
- 이유: 기능을 줄이지 않고 초기 컨텍스트·중복 읽기를 줄인다.

## DEC-2026-018 — Registry와 Schema 동시 검증

- 날짜: 2026-07-22
- 상태: 채택
- 결정: Registry 본문뿐 아니라 Design·Skill Registry Schema의 정책·조건부 필드도 자동 검사한다.
- 발견 결함: Design Registry는 `source_only`인데 이전 Schema가 `always_sync`·PDF·Manifest·생성기를 강제했다.
- 수정: 세 정책을 지원하고 `source_only`의 파생 필드를 null로 강제한다.
- 발행 정책 승격 시 생성기 파일 존재도 검사한다.
