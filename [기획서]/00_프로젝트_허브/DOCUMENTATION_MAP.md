# 십보강호 문서·스킬 지도

## 최초 읽기

```text
../../../START_HERE.md
→ ../../../AGENTS.md
→ START_HERE.md
→ ACTIVE_CONTEXT.md
→ DEVELOPMENT_GATES.md
→ ../DESIGN_DOCUMENT_REGISTRY.json
→ SKILL_REGISTRY.json
→ 현재 작업의 책임 원본
→ Issue·Plan·실제 파일·검증
```

## 질문별 책임 원본

| 질문 | 책임 원본 | 관련 검증 |
|---|---|---|
| 프로젝트 목적·핵심 경험 | `../../../docs/01_GAME_DESIGN.md` | 데모 완주·사용자 설명 가능성 |
| 현재 상태·다음 작업·위험 | `ACTIVE_CONTEXT.md` | 콜드 스타트 |
| 전투 판정·거리·합·자원 | `../../../docs/02_COMBAT_RULES.md` | `docs/08_TEST_CHECKLIST.md` 전투 항목 |
| 콘텐츠 목록·포함·보류 | `../../../docs/03_CONTENT_CATALOG.md` | ID·보류 경계 감사 |
| 제품 구현 순서 | `../../../docs/04_ROADMAP.md` | 단계별 종료 기준 |
| 운영체계 마이그레이션 순서 | `ROADMAP.md` | Health Report |
| 데모·전체판 구현 범위 | `../../../docs/05_COMBAT_POC_SPEC.md` | 5전·10전 범위 검증 |
| 무공·심법·성장 | `../../../docs/06_STARTING_FACTION_MASTERY_DATA.md` | 성급·수련·10성 제한 테스트 |
| 전투 UI·카드·접근성 | `../../../docs/07_COMBAT_UI_SPEC.md` | 3초 판독·포커스·최소 해상도 |
| 전체 QA 기준 | `../../../docs/08_TEST_CHECKLIST.md` | 실제 테스트 명령·결과 |
| 도메인·데이터·저장 경계 | `../../../docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` | 순수 시뮬레이터·이벤트·저장 감사 |
| 전투·대회 연출 | `../../../docs/10_COMBAT_PRESENTATION_PLAN.md` | 전후 렌더·폴백·피로도 |
| Base 적용·프로젝트 교훈 | `../../../docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md` | 제안·승인·검증 상태 |
| 적용 Base 커밋·차이 | `../../../docs/BASE_RULES_VERSION.md` | SHA·동기화 날짜 |
| 기획 문서 Registry | `../DESIGN_DOCUMENT_REGISTRY.json` | JSON·경로·단일 책임 검사 |
| 프로젝트 스킬 Registry | `SKILL_REGISTRY.json` | trigger·진입점·Learning Log 검사 |
| 변경 영향 | `DOCUMENT_UPDATE_MATRIX.md` | PR 체크 |
| 작업·제품 게이트 | `DEVELOPMENT_GATES.md` | Ready·검증·완료 증거 |
| 다음 작업자 인계 | `HANDOFF.md` | 첫 행동 재현 |
| 기존 구조·보존 | `SOURCE_AUDIT.md` | 변경 전후 보존 대조 |

## 작업별 최소 읽기

| 작업 | 최소 문서·스킬 |
|---|---|
| 현재 방향·인수 | 루트 START_HERE, AGENTS, ACTIVE_CONTEXT, HANDOFF |
| 전투 규칙·밸런스 | 01, 02, 05, 09, 게임 디자인 스킬 |
| 절초 기세·상단 HUD | ACTIVE_CONTEXT, 02, 04, 05, 06, 07, 08, 09, 10, UX 스킬 |
| UI·카드·접근성 | 07, 10, 실제 화면·자산, UX 스킬 |
| 구현 | AGENTS, Gates, 02, 05, 09, 현재 Plan, 실제 파일, 엔지니어링 스킬 |
| 검수 | 08, 관련 본책, 실제 테스트·렌더, QA·통합검수 스킬 |
| 문서·인수인계 | 허브 문서, Registry, Project Operations 스킬 |
| Base 업데이트 | BASE_RULES_VERSION, Base START_HERE·CHANGELOG·Registry, SOURCE_AUDIT |
| PDF 발행 | Design Registry, 발행 Manifest, 생성기, 사람 시각 검수 |

## 책임 분야

현재 선택 분야:

1. 게임 디자인.
2. UX·UI·접근성.
3. 개발·엔지니어링.
4. QA.
5. 프로덕션·PM.
6. 통합검수.

설정·내러티브, 테크니컬 아트, 아트, 사운드, 분석·유저리서치는 공용 카탈로그에는 남기되 현재 독립 본책·진입 스킬을 설치하지 않는다. 향후 독립 책임과 실제 산출물이 생기면 Registry에 추가한다.

## 책임 경계

- 운영 Markdown은 현재 상태와 경로를 라우팅하고 제품 본책의 전문을 복제하지 않는다.
- 기존 `docs/01~11`은 현재 schema v3 Markdown 단일 책임 원본이다.
- JSON은 Registry·상태·ID·경로·Manifest를 책임진다.
- PDF는 사람용 최신 파생본이며 독립 원본이 아니다.
- UI·VFX·오디오는 전투·성장·저장 결과를 소유하지 않는다.
- 체크리스트 존재와 실제 테스트 통과를 구분한다.
- GitHub Workflow 파일 존재와 Actions 성공·Required Check 강제를 구분한다.

## 우선순위

충돌 시:

1. 사용자의 최신 확정 지시.
2. 루트 `AGENTS.md`.
3. 허브 `ACTIVE_CONTEXT.md`.
4. 승인된 프로젝트 책임 원본과 Issue·Plan.
5. 실제 구현·데이터·자산·테스트 증거.
6. 프로젝트에 고정된 Base 커밋과 프로젝트별 차이.
7. Base 원격 최신 `main`.
8. 과거 대화·초안·추정.

실제 파일과 문서가 다르면 차이를 보고하고 사용자 변경을 임의로 되돌리지 않는다.

## 수명주기

- `docs/[백업]/`: 보존 근거 확인용, 기본 읽기·수정 제외.
- `docs/[보류]/`: 재개 승인 전 구현 금지.
- 제거 후보: 고유 정보·참조·복구·승인·보존 대조 전 삭제 금지.
- 단순 이전 버전: Git 이력으로 보존.
