# 십보강호 문서 지도

## 기본 읽기

```text
AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·테스트·PR
```

- Base route·Adapter: `skills/PROJECT_BASE_ADAPTER.json`.
- 프로젝트 고유 Skill Registry: `skills/SKILL_REGISTRY.json`.
- 과거 v6 원장은 승인 이력 인덱스이며 최신 날짜별 Decision이 우선한다.

## 질문별 현재 책임 원본

| 질문 | 현재 책임 원본 |
|---|---|
| 현재 단계·권한·다음 작업 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` |
| 전체 문서 책임·위치 | `[기획서]/DESIGN_DOCUMENT_REGISTRY.json` |
| 과거 v6 승인 인덱스 | `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md` |
| 프로젝트 코어 | `docs/01_GAME_DESIGN.md` |
| 전투 판정 | `docs/02_COMBAT_RULES.md` |
| 회차·노드·천하제일인 | `docs/decisions/2026-07-31_COMBAT_ROUTE_AND_CHAMPION_DECISION.md` |
| 절차형 상대·경로 | `docs/decisions/2026-07-31_PROCEDURAL_DUEL_POOL_AND_ROUTE_DECISION.md` |
| 슬롯 3 거리 학습 | `docs/decisions/2026-07-31_SLOT3_DISTANCE_DUEL_AND_ROUTE_DECISION.md` |
| 3수 계획 편집 | `docs/decisions/2026-07-31_THREE_MOVE_PLANNING_EDITOR_UX_DECISION.md` |
| 해결·복기 | `docs/decisions/2026-07-31_COMBAT_RESOLUTION_AND_REVIEW_UX_DECISION.md` |
| 무공서→기술→수 배치 | `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md` |
| 행동 선택 구현 결과 | `docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md` |
| 필수 화면·P0 상태·Scene 소유권 | `docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md` |
| 주 플랫폼·미래 모바일 범위 | `docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md` |
| 상황별 상세 명세 | `docs/superpowers/specs/2026-07-31-situation-screen-implementation-spec.md` |
| 다음 구현 순서 | `docs/04_ROADMAP.md` |
| 콘텐츠 | `docs/03_CONTENT_CATALOG.md` |
| PoC·Vertical Slice | `docs/05_COMBAT_POC_SPEC.md` |
| 무공·성장 | `docs/06_STARTING_FACTION_MASTERY_DATA.md` |
| UI·접근성 | `docs/07_COMBAT_UI_SPEC.md` |
| 테스트·미검증 | `docs/08_TEST_CHECKLIST.md` |
| 전투 시스템 책임 | `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` |
| 2026-08-01 Base·프로젝트·Sheet 감사 | `docs/reviews/2026-08-01_BASE_PROJECT_SHEET_ADVERSARIAL_AUDIT.md` |
| 최신 총기획·정본·Sheet 감사 | `docs/reviews/2026-08-02_BASE_PROJECT_SHEET_TOTAL_PLANNING_AUDIT.md` |
| 구현 사실 | 실제 `data/`, `src/`, `scenes/`, `tests/`, `project.godot` |

## 최신 Decision 우선순위

```text
최신 사용자 지시
→ 2026-08-02 Decision
→ 2026-08-01 Decision
→ 2026-07-31 Decision
→ v6 Decision Authority Ledger
→ 분야 책임 원본
→ 실제 구현·테스트
→ 과거 계획·초안
```

실제 구현과 최신 Decision이 다르면 `CANON_CONFLICT`로 보고한다.

## 구조화 계획 데이터

- `approved_20260731_combat_route_contract.json`.
- `approved_20260731_procedural_duel_pool_route_contract.json`.
- `approved_20260731_slot3_distance_route_contract.json`.
- `approved_20260731_combat_resolution_review_contract.json`.
- `approved_20260801_martial_technique_timeline_ux_contract.json`.
- `approved_20260801_situation_screen_contract.json`.
- `approved_20260802_platform_scope_contract.json`.

`docs/planning-data/*.json`은 직접 런타임에서 읽지 않는다.

## 현재 상태

```yaml
project_main: c5771ddae40f58d88824d9319fc4ef6cd1053bba
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
integration_pr: 65
latest_operating_pr: 68
action_selection: IMPLEMENTED_AUTOMATED_VALIDATION_PASS_HUMAN_PENDING
situation_screen_architecture: APPROVED_PLANNING
platform_scope: PC_CURRENT_MOBILE_CONSIDERATION_ONLY
full_product_flow_runtime: NOT_STARTED
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
```

## 역사·중복 방지

- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 이력이다.
- PR #45는 v6 계획 통합 이력이다.
- PR #65는 ActionSelectionDock·화면 구조·Sheet post-merge 동기화 이력이다.
- PR #68은 Base v9.4 운영 계약 적용 이력이다.
- 2026-07-26 BUILD 문서와 고정형 연교→묵진 경로는 `SUPERSEDED_REFERENCE`다.
- 같은 질문에 여러 현재 정본을 두지 않는다.
- 상세 Spec의 과거 상태 문구보다 최신 Decision이 승인 상태를 소유한다.

## `[보류]`

- 16권 절초 개별 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 모바일 포팅·스토어·크로스 세이브.
- 최종 아트·오디오 폴리싱.

## Base v9.4 적용

- `docs/reviews/2026-08-01_BASE_V9_4_ADOPTION_AUDIT.md`: Base v9.4 payload·evidence·Registry와 프로젝트 보호 경계 감사.
