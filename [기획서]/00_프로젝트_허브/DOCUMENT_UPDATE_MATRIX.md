# 십보강호 문서 갱신 매트릭스

변경 후 아래 영향을 확인한다. 모든 파일을 관성적으로 수정하지 않고 실제 책임이 영향을 받은 항목만 갱신한다.

| 변경 유형 | 필수 책임 원본 | 함께 확인 | 검증 |
|---|---|---|---|
| 프로젝트 방향·데모 범위 | `docs/01_GAME_DESIGN.md` | README, Active Context, 04, 05 | 범위·용어 검색, 콜드 스타트 |
| 전투 판정·거리·합·자원 | `docs/02_COMBAT_RULES.md` | 05, 07, 08, 09, 10, 구현 Plan | 규칙→이벤트→UI→QA 추적 |
| 콘텐츠 포함·제외·보류 | `docs/03_CONTENT_CATALOG.md` | 01, 04, 05, 06, 보류 인덱스 | ID·보류 혼입 검사 |
| 제품 순서·우선순위 | `docs/04_ROADMAP.md` | Active Context, Handoff, Plan | 단계·진입·종료 기준 |
| 데모·Vertical Slice | `docs/05_COMBAT_POC_SPEC.md` | 01, 04, 08, 09, 10 | 5전/10전·보유/미보유 경로 |
| 무공·심법·성장 | `docs/06_STARTING_FACTION_MASTERY_DATA.md` | 02, 03, 05, 08, 09 | 수치·제한·데이터 계약 |
| UI·카드·접근성 | `docs/07_COMBAT_UI_SPEC.md` | 02, 08, 09, 10, 실제 렌더 | 3초 판독·포커스·해상도 |
| 테스트·완료 기준 | `docs/08_TEST_CHECKLIST.md` | Gates, 관련 본책, Plan | 체크리스트와 실행 증거 분리 |
| 아키텍처·데이터·저장 | `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` | 02, 05, 06, 07, 08, 10 | 실제 경로·결정론·저장 |
| 연출·VFX·오디오·폴백 | `docs/10_COMBAT_PRESENTATION_PLAN.md` | 02, 07, 08, 09 | 전후 렌더·결과 불변성 |
| Base 채택·교훈 | `docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md` | BASE_RULES_VERSION, Skill Learning Log | 제안·승인·검증 상태 |
| Base 기준 커밋 | `docs/BASE_RULES_VERSION.md` | AGENTS, 허브 Changelog, Source Audit | SHA·날짜·프로젝트 차이 |
| 현재 단계·위험 | 허브 `ACTIVE_CONTEXT.md` | HANDOFF, ROADMAP, README | 콜드 스타트 |
| 책임 문서 추가·이동 | `DESIGN_DOCUMENT_REGISTRY.json` | Documentation Map, 링크, PDF Manifest | 중복 ID·경로·보존 대조 |
| 스킬 추가·변경 | `SKILL_REGISTRY.json` | Skill Map, Learning Log, Documentation Map | trigger·진입점·상태 |
| 승인 이미지·실제 캡처 | Visual Source·Asset Manifest | 관련 본책·PDF Manifest | 캐노니컬 경로·사람 검수 |
| PDF 생성기·입력 변경 | Publication Manifest | Design Registry, PDF, 렌더 결과 | 해시·무재작성·전 페이지 |
| 구현 파일·저장 포맷 | 09 + 현재 Plan | 02, 05, 08, Active Context | Godot 테스트·마이그레이션 |
| Issue·Plan 완료 | Issue·Plan | Active Context, Roadmap, Handoff, Changelog | 완료 증거·미검증 |
| 보류 재개 | 관련 본책 | 보류 인덱스, Roadmap, Test, Plan | 재개 승인·범위 |
| 파일 삭제·이동 | Source Audit 처리표 | 모든 참조·Git 이력·보존 대조 | 사용자 승인·복구 |

## PR 종료 체크

- [ ] 변경 유형을 식별했다.
- [ ] 주 책임 원본이 한 개다.
- [ ] 영향을 받지 않은 문서를 불필요하게 장문 복제하지 않았다.
- [ ] Active Context·Roadmap·Handoff 영향 여부를 확인했다.
- [ ] Registry·Manifest 영향 여부를 확인했다.
- [ ] 실행한 검증과 미검증을 분리했다.
- [ ] 백업·보류·제거 후보를 활성 범위와 분리했다.
- [ ] Base 승격 후보는 자동 반영하지 않고 제안 계약을 따랐다.
