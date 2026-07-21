# 십보강호 변경 영향 매트릭스

모든 문서를 관성적으로 수정하지 않는다. 주 책임 원본 하나를 갱신하고 실제 영향 소비자·테스트·파생본을 확인한다.

| 변경 유형 | 주 책임 원본 | 함께 확인 | 검증 |
|---|---|---|---|
| 프로젝트 방향·데모 | `docs/01_GAME_DESIGN.md` | README, Active Context, 04, 05 | 용어·범위·콜드 스타트 |
| 전투 판정·거리·자원·대응 | `docs/02_COMBAT_RULES.md` | 05, 07, 08, 09, 10, `data/`, `src/`, `tests/`, PR | 규칙→데이터→판정→UI→QA |
| 행동 카드·비용·사거리 | `data/cards/basic_cards.json` 또는 02 | 03, 07, 08, 판정 엔진, UI, 계약 검사 | 데이터·표시·자원·경계 |
| 콘텐츠 포함·보류 | `docs/03_CONTENT_CATALOG.md` | 01, 04, 05, 06, 보류 인덱스 | ID·보류 혼입 |
| 제품 순서·게이트 | `docs/04_ROADMAP.md` | Active Context, Handoff, Plan | 진입·종료·의존성 |
| POC·Vertical Slice | `docs/05_COMBAT_POC_SPEC.md` | 01, 04, 08, 09, 10 | POC/5전/10전 경계 |
| 무공·심법·성장 | `docs/06_STARTING_FACTION_MASTERY_DATA.md` | 02, 03, 05, 08, 09 | 수치·제한·데이터 |
| UI·카드·접근성 | `docs/07_COMBAT_UI_SPEC.md` | 02, 08, 09, 10, 씬·실제 렌더 | 정보 채널·포커스·해상도 |
| 테스트·완료 기준 | `docs/08_TEST_CHECKLIST.md` | Gates, 관련 본책, tests, PR | 체크리스트·실행 증거 분리 |
| 아키텍처·저장 | `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` | 02, 05, 06, 07, 08, 10, 실제 경로 | 결정론·저장·호환성 |
| 연출·VFX·오디오 | `docs/10_COMBAT_PRESENTATION_PLAN.md` | 02, 07, 08, 09 | 결과 불변·전후 렌더 |
| Base 채택·교훈 | `docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md` | Base Rules, Audit, Skill Learning Log | 제안·승인·검증 상태 |
| Base SHA | `docs/BASE_RULES_VERSION.md` | AGENTS, README, START_HERE, Audit, Changelog | SHA·변경 집합·프로젝트 차이 |
| 현재 구현 상태 | `ACTIVE_CONTEXT.md` | README, Roadmap, Handoff, PR | 실제 코드·사용자 증거 |
| 책임 문서·경로·ID·Schema | Design Registry 또는 해당 정본 | Documentation Map, 소비자, 생성기, tests, Manifest | reference-freshness |
| 발행 정책·생성기 | Design Registry·Manifest | PDF·DOCX·diagram·해시·렌더 | 정책 기반 발행·기존 정상본 보존 |
| Skill 추가·통합·mode | Skill Registry | SKILL.md, Legacy Alias, Skill Map, Learning Log, entrypoint, tests | 패키지 무결성·stale ID |
| Work Mode·작업 계약 | AGENTS·AI Workflow | Registry, templates, Active Context, PR | execution-report |
| 승인 이미지·캡처 | Visual Source·Asset Manifest | 본책, 씬, PDF Manifest | 캐노니컬 경로·사용자 검수 |
| 구현 파일·저장 포맷 | 실제 코드·09·Plan | 02, 05, 08, Context | Godot·저장 migration·회귀 |
| 접근성 영향 | 07·08 | 실제 UI·입력·옵션·로그 | accessibility-review |
| 성능 영향 | 성능 계약·Plan | 목표 플랫폼·대표/최악 장면 | performance-profile |
| 벤치마크·플레이테스트 | 조사·실험 기록 | 01, 04, 05, Learning Log | 출처·표본·사전 기준 |
| Issue·Plan 완료 | Issue·Plan | Context, Roadmap, Handoff, Changelog | 완료 증거·미검증 |
| 보류 재개 | 관련 본책 | 보류 인덱스, Roadmap, Test, Plan | 사용자 재개 승인 |
| 파일 삭제·이동 | reconciliation 처리표 | 모든 참조·파생본·복구·Git | 승인·reference-freshness |

## PR 종료 체크

- [ ] Work Mode와 주 책임 분야를 기록했다.
- [ ] 변경 유형과 주 책임 원본 하나를 식별했다.
- [ ] 실제 변경과 보호 대상을 대조했다.
- [ ] 정본·경로·ID·Schema 소비자와 untouched 파일을 확인했다.
- [ ] Active Context·Roadmap·Handoff 영향을 확인했다.
- [ ] Design·Skill Registry·Legacy Alias·Manifest 영향을 확인했다.
- [ ] 발행 정책에 따른 파생본 상태를 확인했다.
- [ ] 정적·자동·런타임·사용자 검증을 분리했다.
- [ ] 접근성·성능 영향 또는 미실행 이유를 기록했다.
- [ ] 백업·보류·제거 후보를 활성 범위와 분리했다.
- [ ] 삭제·이동은 reconciliation·복구·사용자 승인을 확인했다.
- [ ] Base 제안은 프로젝트 고유 값과 공용 교훈을 분리했다.
- [ ] 사용한 Skill·Skill Mode의 이유·결과·증거를 보고했다.
