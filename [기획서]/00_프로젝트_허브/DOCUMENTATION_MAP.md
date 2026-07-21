# 십보강호 문서·Skill 지도

## 최초 읽기

```text
../../../START_HERE.md
→ ../../../AGENTS.md
→ ../../../docs/BASE_RULES_VERSION.md
→ START_HERE.md
→ ACTIVE_CONTEXT.md
→ DEVELOPMENT_GATES.md
→ ROADMAP.md
→ ../DESIGN_DOCUMENT_REGISTRY.json
→ 현재 책임 원본
→ SKILL_REGISTRY.json
→ 필요한 Base 통합 Skill·Skill Mode와 프로젝트 Skill
→ Issue·Plan·실제 파일·검증
```

## 질문별 책임 원본

| 질문 | 책임 원본 | 관련 검증 |
|---|---|---|
| 프로젝트 목적·핵심 경험 | `../../../docs/01_GAME_DESIGN.md` | 데모 완주·사용자 설명 가능성 |
| 현재 상태·다음 작업·위험 | `ACTIVE_CONTEXT.md` | 콜드 스타트 |
| 전투 판정·거리·자원·대응 | `../../../docs/02_COMBAT_RULES.md`, 실제 `data/`·`src/` | `tests/`, Godot 실행 |
| 콘텐츠 목록·포함·보류 | `../../../docs/03_CONTENT_CATALOG.md` | ID·보류 경계 감사 |
| 제품 구현 순서 | `../../../docs/04_ROADMAP.md` | 단계별 종료 기준 |
| 운영체계 순서 | `ROADMAP.md` | Health Report |
| POC·데모·전체판 범위 | `../../../docs/05_COMBAT_POC_SPEC.md` | 10수·5전·10전 검증 |
| 무공·심법·성장 | `../../../docs/06_STARTING_FACTION_MASTERY_DATA.md` | 수련·해금 제한 테스트 |
| 전투 UI·카드·접근성 | `../../../docs/07_COMBAT_UI_SPEC.md`, 실제 씬 | 포인터·최소 해상도·정보 채널 |
| 전체 QA 기준 | `../../../docs/08_TEST_CHECKLIST.md` | 자동·수동·사용자 증거 |
| 도메인·데이터·저장 경계 | `../../../docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` | 판정·이벤트·저장 감사 |
| 전투·대회 연출 | `../../../docs/10_COMBAT_PRESENTATION_PLAN.md` | 전후 렌더·폴백·피로도 |
| Base 적용·프로젝트 교훈 | `../../../docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md` | 제안·승인·검증 상태 |
| 적용 Base SHA·차이 | `../../../docs/BASE_RULES_VERSION.md` | SHA·동기화 날짜 |
| Base 최신 70파일 감사 | `BASE_MAIN_SYNC_AUDIT.md` | 처리표·PR 체크 |
| 기획 문서 Registry | `../DESIGN_DOCUMENT_REGISTRY.json` | JSON·경로·단일 책임·발행 정책 |
| 프로젝트 Skill Registry | `SKILL_REGISTRY.json` | trigger·mode·Learning Log·패키지 무결성 |
| 구형 Skill ID | `../../../skills/LEGACY_SKILL_ALIASES.md` | 활성 stale 참조 검사 |
| 변경 영향 | `DOCUMENT_UPDATE_MATRIX.md` | coupled consumer 검사 |
| 작업·제품 게이트 | `DEVELOPMENT_GATES.md` | Ready·검증·완료 증거 |
| 다음 작업자 인계 | `HANDOFF.md` | 첫 행동 재현 |
| 기존 구조·보존 | `SOURCE_AUDIT.md` | reconciliation·보존 대조 |

## Work Mode·작업별 Skill

| 작업 | Work Mode·Skill·Skill Mode |
|---|---|
| 요청 접수·계약 | `PLAN`, `managing-project-intake-and-work-contract: route/clarify/contract` |
| 큰 작업 순서화 | `PLAN`, intake Skill `decompose-and-sequence` |
| 운영체계 감사·정리 | `PLAN→BUILD→REVIEW`, `managing-game-project-operating-system: audit/reconcile-legacy/migrate/verify` |
| 기획 책임 원본·발행 | `managing-design-documents: author/update/restructure/publish/validate` |
| 현재 상태·인수 | `maintaining-project-context-and-handoff` |
| 핵심 컨셉·DDD·PoC | `analyzing-and-refining-game-concepts` |
| 벤치마크·플레이어 증거 | 위 Skill `benchmark-and-player-research` |
| 플레이테스트·실험 | 위 Skill `playtest-and-experiment` |
| Vertical Slice | `designing-vertical-slices` |
| 전투 규칙·밸런스 | `ten-paces-game-design` + 필요 Base 컨셉 Skill |
| UI·카드·접근성 | `combat-ux-and-accessibility`, 필요 시 `accessibility-review` |
| Godot 구현 | `combat-implementation-handoff` |
| 변경 검증 | `reviewing-and-validating-project-changes` |
| 정본 최신성 | `auditing-canonical-reference-freshness` |
| 구현된 UI 감사 | `auditing-and-refining-ui-art` |
| Base 제안 | `managing-base-change-proposals` |

## 현재 제품 구현 경로

- 카드: `../../../data/cards/`
- 전투 데이터: `../../../data/combat/`
- 씬: `../../../scenes/`
- 판정·전장 코드: `../../../src/combat/`
- UI 코드: `../../../src/ui/`
- 검증: `../../../tests/`
- 자동화: `../../../tools/`

## 책임 경계

- 운영 문서는 제품 본책 전문을 복제하지 않는다.
- 한 질문에 현행 책임 원본 하나만 둔다.
- JSON은 Registry·상태·ID·경로·Manifest·게임 데이터를 책임진다.
- PDF·DOCX·다이어그램은 파생본이다.
- UI·VFX·오디오는 전투 결과를 재계산하지 않는다.
- Workflow 존재, Actions 성공, Required Check 강제를 구분한다.
- 변경된 정본뿐 아니라 변경됐어야 할 소비자·테스트·파생본도 확인한다.

## 상태·수명주기

- `docs/[백업]`: 역사·복구용, 기본 수정 제외
- `docs/[보류]`: 재개 승인 전 구현 금지
- 제거 후보: 고유 정보·참조·복구·사용자 승인 전 삭제 금지
- 과거 Skill ID: Legacy Alias·Learning Log·Git 이력에서만 허용
