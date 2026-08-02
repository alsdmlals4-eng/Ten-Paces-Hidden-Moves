# 십보강호 문서 지도

## 기본 읽기

```text
AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ docs/00_TAG_STATUS_REGISTRY.md
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·테스트·PR
```

- Base route·Adapter: `skills/PROJECT_BASE_ADAPTER.json`.
- 프로젝트 고유 Skill Registry: `skills/SKILL_REGISTRY.json`.
- 과거 v6 원장은 승인 이력 인덱스이며 최신 사용자 승인 Decision이 우선한다.
- planning JSON은 정적 계약이며 런타임이 직접 읽지 않는다.

## 질문별 현재 책임 원본

| 질문 | 현재 책임 원본 |
|---|---|
| 현재 단계·권한·다음 작업 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` |
| 태그·상태 이름 | `docs/00_TAG_STATUS_REGISTRY.md` |
| 전체 문서 책임·위치 | `[기획서]/DESIGN_DOCUMENT_REGISTRY.json` |
| 프로젝트 코어·제품 범위 | `docs/01_GAME_DESIGN.md` |
| 전투 판정·관찰 종류 | `docs/02_COMBAT_RULES.md` |
| 콘텐츠·범위·HOLD | `docs/03_CONTENT_CATALOG.md` |
| 구현·검증 순서 | `docs/04_ROADMAP.md` |
| PoC·Vertical Slice | `docs/05_COMBAT_POC_SPEC.md` |
| 무공·성장 | `docs/06_STARTING_FACTION_MASTERY_DATA.md` |
| UI·접근성 | `docs/07_COMBAT_UI_SPEC.md` |
| 테스트·미검증 | `docs/08_TEST_CHECKLIST.md` |
| 시스템·저장·AI 경계 | `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` |
| 최신 총기획 감사 | `docs/reviews/2026-08-02_BASE_PROJECT_SHEET_TOTAL_PLANNING_AUDIT.md` |
| 구현 사실 | 실제 `data/`, `src/`, `scenes/`, `tests/`, `project.godot` |

## 최신 활성 Decision

- `TEN-DEC-20260802-PLATFORM-SCOPE-01`
- `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
- `TEN-DEC-20260802-FULLRUN-CHAMPION-RANKED-01`
- `TEN-DEC-20260802-RANKED-OBSERVATION-CONVERSION-01`

우선순위:

```text
최신 사용자 지시
→ 최신 사용자 승인 Decision·approved planning JSON
→ 분야 책임 원본 docs/01~11
→ Active Context·Roadmap·Google Sheet 요약
→ 실제 구현·테스트
→ 과거 계획·초안·백업
```

실제 구현과 최신 Decision이 다르면 구현을 `IMPLEMENTED_LEGACY`로 분류하고 차이를 보고한다.

## 구조화 계획 데이터

활성 계약:

- `approved_20260802_platform_scope_contract.json`
- `approved_20260802_observation_stats_mastery_contract.json`
- `approved_20260802_fullrun_champion_ranked_contract.json`
- `approved_20260802_ranked_observation_conversion_contract.json`

선행 계약:

- `approved_20260731_procedural_duel_pool_route_contract.json`
- `approved_20260731_slot3_distance_route_contract.json`
- `approved_20260731_combat_resolution_review_contract.json`
- `approved_20260801_martial_technique_timeline_ux_contract.json`
- `approved_20260801_situation_screen_contract.json`

## 현재 상태

```yaml
reviewed_main_before_this_audit: 7082dab1c66e994ce3be1861640754f97080ed5c
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
latest_operating_pr: 68
latest_planning_pr: 71
action_selection:
  implementation_status: IMPLEMENTED_CURRENT
  automated_validation: PASS
  human_validation: NOT_RUN
full_product_flow_runtime: NOT_STARTED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
```

## 구형 표현 차단

다음 표현은 활성 정본으로 사용하지 않는다.

- 범용 공격력·방어력 중심 신규 성장.
- 공개 성향·대표 위협·정답 파훼법 자동 공개.
- 피격 시 소모되는 방어도.
- 적 미래 묶음 선잠금.
- 10성 절초·진의 선택.
- 천하제일인 후보6명 고정·사전 예고·첫 후보 자동 배정.
- 챔피언 배틀 미정·HOLD.
- 관찰 의존 무공의 랭킹전 처리 미결정.

## 현재 다음 작업

`VERTICAL_SLICE_APP_FLOW_SHELL` 구현 Packet 정밀화:

1. App Root·Scene·화면 상태.
2. `RunSession`·`SaveService`.
3. 시작 무공 6중4.
4. Route·Node·Briefing.
5. Combat 진입·복귀.
6. Result·Reward·Retry transaction.
7. 자동·Godot·Windows·접근성·성능·사람 검증.

## 역사·보류

- PR #65: ActionSelectionDock·화면 구조.
- PR #68: Base v9.4 운영 계약.
- PR #69: 플랫폼·관찰·스테이터스·성장.
- PR #70: 정식 회차·천하제일인·챔피언 랭킹.
- PR #71: 랭킹 관찰 변환·병합 게이트.

보류:

- 기술별 정확한 랭킹전 변환 수치.
- 주요 비무6~10 런타임.
- 천하제일인·챔피언 배틀 서버·런타임.
- 모바일 포팅·스토어·크로스 세이브.
- 최종 아트·오디오.
