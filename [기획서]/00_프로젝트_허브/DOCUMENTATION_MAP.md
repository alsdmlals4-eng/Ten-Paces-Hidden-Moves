# 십보강호 문서·Skill 지도

## 기본 읽기

```text
../../../AGENTS.md
→ ACTIVE_CONTEXT.md
→ 이 문서
→ 현재 책임 원본
→ 실제 파일·테스트·PR
```

## 질문별 책임 원본

| 질문 | 책임 원본 | 검증 |
|---|---|---|
| 프로젝트 목적·핵심 경험 | `../../../docs/01_GAME_DESIGN.md` | 데모 완주·플레이어 설명 |
| 현재 상태·다음 작업·위험 | `ACTIVE_CONTEXT.md` | 콜드 스타트 |
| 전투 판정·거리·자원·대응 | `../../../docs/02_COMBAT_RULES.md` + `data/`·`src/` | `tests/`·Godot |
| 콘텐츠·보류 | `../../../docs/03_CONTENT_CATALOG.md` | ID·보류 경계 |
| 제품 순서 | `../../../docs/04_ROADMAP.md` | 진입·종료 기준 |
| 운영 순서 | `ROADMAP.md` | Health Review |
| POC·데모·전체판 | `../../../docs/05_COMBAT_POC_SPEC.md` | 10수·5전·10전 |
| 무공·심법·성장 | `../../../docs/06_STARTING_FACTION_MASTERY_DATA.md` | 수치·해금·저장 |
| 전투 UI·접근성 | `../../../docs/07_COMBAT_UI_SPEC.md` + 실제 씬 | 입력·해상도·정보 채널 |
| QA 기준 | `../../../docs/08_TEST_CHECKLIST.md` | 자동·수동·사용자 증거 |
| 아키텍처·저장 | `../../../docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` | 결정론·호환성 |
| 연출 | `../../../docs/10_COMBAT_PRESENTATION_PLAN.md` | 렌더·폴백·결과 불변 |
| Base 적용·학습 | `../../../docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md` | 제안·승인·검증 |
| Base SHA·차이 | `../../../docs/BASE_RULES_VERSION.md` | SHA·날짜·프로젝트 차이 |
| Base 파일별 감사 | `BASE_MAIN_SYNC_AUDIT.md` | 70개 처리표 |
| 최종 통합 검증 | `BASE_MAIN_SYNC_VERIFICATION.md` | 적대적 검토·Actions·보존 |
| 기획 책임·발행 정책 | `../DESIGN_DOCUMENT_REGISTRY.json` | 단일 원본·정책 형태 |
| 프로젝트 Skill | `SKILL_REGISTRY.json` | Base 13개·로컬 4개·무결성 |
| 구형 Skill ID | `../../../skills/LEGACY_SKILL_ALIASES.md` | stale 참조 검사 |
| 변경 소비자 | `DOCUMENT_UPDATE_MATRIX.md` | propagation gap |
| 작업·제품 게이트 | `DEVELOPMENT_GATES.md` | Ready·Done·증거 |
| 경계 인수 | `HANDOFF.md` | 다음 첫 행동 |
| 구형 파일·보존 | `SOURCE_AUDIT.md` | reconciliation |

## Skill 라우팅

Base 공유 Skill:

- 요청·계약: `managing-project-intake-and-work-contract`
- 운영체계: `managing-game-project-operating-system`
- 문서: `managing-design-documents`
- 상태·인수: `maintaining-project-context-and-handoff`
- 컨셉·연구·PoC: `analyzing-and-refining-game-concepts`
- Vertical Slice: `designing-vertical-slices`
- 변경 검증: `reviewing-and-validating-project-changes`
- 정본 최신성: `auditing-canonical-reference-freshness`
- 구현 UI 감사: `auditing-and-refining-ui-art`
- Base 제안: `managing-base-change-proposals`

프로젝트 고유 Skill:

- 전투·성장·대회: `ten-paces-game-design`
- 전투 UI·접근성: `combat-ux-and-accessibility`
- Godot 구현: `combat-implementation-handoff`
- 십보강호 QA: `ten-paces-verification`

나머지 Base 공유 Skill은 `SKILL_REGISTRY.json`의 `shared_skill_routes`에서 필요할 때 선택한다.

## 실제 구현 경로

`data/`, `scenes/`, `src/`, `tests/`, `tools/`, `project.godot`

## 경계

- 운영 문서는 제품 본책 전문을 복제하지 않는다.
- 한 질문에 현행 책임 원본 하나만 둔다.
- 현재 모든 등록 문서와 Skill Registry는 실제 생성기가 없어 `source_only`다.
- PDF가 필요한 마일스톤에서 발행 파이프라인과 함께 필요한 문서만 정책을 승격한다.
- Workflow 존재, Actions 성공, Godot 런타임, 사람 검수, Required Check 강제를 구분한다.
- 백업·보류·제거 후보는 기본 읽기와 구현에서 제외한다.
