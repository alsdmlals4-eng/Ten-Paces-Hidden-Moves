# 십보강호 문서 지도

## 기본 읽기

```text
AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ docs/00_TAG_STATUS_REGISTRY.md
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·테스트·PR
```

- Base route·Adapter: `skills/PROJECT_BASE_ADAPTER.json`.
- 현재 Base release: `9.4.3`.
- 프로젝트 고유 Skill Registry: `skills/SKILL_REGISTRY.json`.
- 과거 v6 원장은 승인 이력 인덱스이며 최신 사용자 승인 Decision이 우선한다.
- planning JSON은 정적 계약이며 런타임이 직접 읽지 않는다.
- 병합된 main 상태와 활성 Draft PR 상태를 별도 축으로 기록한다.

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
| 최근 병합 체크포인트 | PR #80, `d9f38e6f3cacaf170d4b290e95b3645114639aff` |
| 활성 기획 배치·승인 수·다음 Decision | `ACTIVE_CONTEXT.md` + GitHub PR metadata |
| 구현 사실 | 실제 `data/`, `src/`, `scenes/`, `tests/`, `project.godot` |

## 최신 활성 Decision

현재 승인 Decision의 전체 순서·상태·대체 관계는 `ACTIVE_CONTEXT.md`, `docs/CANON_LIFECYCLE_REGISTRY.md`, `docs/decisions/`, `docs/planning-data/approved_*.json`이 책임진다.

현재 핵심 권위에는 다음이 포함된다.

- `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
- `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`
- `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`
- `TEN-DEC-20260805-CONDITION-CALIBRATION-01`
- `TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01`
- `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`
- `TEN-DEC-20260805-WORK-GOVERNANCE-01`

우선순위:

```text
최신 사용자 지시
→ 최신 사용자 승인 Decision·approved planning JSON
→ 분야 책임 원본 docs/01~11
→ ACTIVE_CONTEXT·Roadmap·Google Sheet 요약
→ 실제 구현·테스트
→ 과거 계획·초안·백업
```

실제 구현과 최신 Decision이 다르면 구현을 `IMPLEMENTED_LEGACY`로 분류하고 차이를 보고한다.

## 현재 전투·성장 핵심

- 기초 행동 10종, 사용자 표시 `준비`, 강화 없는 `전조`.
- 연격 대 연격은 현재 순번 피해 단위끼리 앞에서부터 합한다.
- 현재 순번 정산 뒤 양측 공격이 유지되고 다음 피해 단위가 모두 있으면 다음 순번도 합한다.
- 합 패배·동점은 현재 피해 단위만 취소·상쇄한다.
- 체력 피해 중단은 피격측 후속타를 취소하며 강건이 중단을 막으면 다음 합을 계속할 수 있다.
- 한쪽 피해 단위가 끝나면 상대 잔여타는 단독으로 해결한다.
- 사거리 밖 현재 순번 합도 같은 지속 조건을 사용한다.
- 여러 합 승리에도 절초기세는 공격 행동당 최대 +1이다.
- 완전 파훼 사건은 공격 행동당 최대 1회다.
- 시작 능력치는 기본 2×5+자유 6+선택 무공 네 개의 2성 주 능력치+1로 총합 20이다.
- 3성 첫 기술은 주 영구 능력치 4, 7성 두 번째 기술은 8, 10성 절초는 12를 요구한다.
- 짝수 성은 2성 주+1, 4성 주+1·보조+1, 6성 주+2·보조+1, 8성 주+3·보조+2를 최초 도달 시 지급한다.
- 핵심 스테이터스는 디자인 하드캡이 없으며 기존 1~15는 검증 구간이다.

## 구조화 계획 데이터

최근 병합 체크포인트와 활성 Draft의 승인 계약은 `docs/planning-data/approved_*.json`에 Decision별로 보존한다. 활성 계약 목록과 순서는 `ACTIVE_CONTEXT.md` 및 `CANON_LIFECYCLE_REGISTRY.md`에서 찾는다.

## 현재 상태

활성 PR·exact head·승인 수·다음 Decision은 `ACTIVE_CONTEXT.md`의 단독 책임이다. 이 지도에는 변동 상태를 복제하지 않는다.

안정 상태:

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
runtime_work_mode: REVIEW
planning_work_mode: PLAN
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
latest_combat_planning_runtime: NOT_STARTED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
base_release: 9.4.3
human_validation: NOT_RUN
```

## 구형·오해 표현 차단

다음 표현은 활성 정본으로 사용하지 않는다.

- 사용자 표시 `태세`.
- 범용 공격력·방어력 중심 신규 성장.
- 공개 성향·대표 위협·정답 파훼법 자동 공개.
- 피격 시 소모되는 방어도.
- 적 미래 묶음 선잠금.
- `첫 피해 단위만 합에 참여`.
- `첫 합 실패 시 후속타 전체 취소`.
- `후속 피해 단위는 다시 합하지 않음`.
- 체력 피해·중단 정산과 무관한 무조건 전체 타격 합.
- 위협 대응30·100→50→0 감쇠를 현재 전투 종료 등급 산식으로 사용.
- 능력치 배수 가격 미결정.
- 천하제일인 후보6명 고정·사전 예고·첫 후보 자동 배정.
- 챔피언 배틀 미정·HOLD.
- Base 9.4.0·9.4.1을 현재 Adapter 권한으로 표시.
- PR #65·#72·#80을 현재 활성 승인 PR로 표시.

정확한 합 표현은 `현재 순번 합 → 피해·중단 정산 → 양측 공격 유지·다음 피해 단위 존재 시 다음 순번 합`이다.

## 현재 다음 작업

`ACTIVE_CONTEXT.md`의 다음 Gate를 따른다. 기획 완료 후 전체 검토를 닫고, 필요한 이미지·애니메이션·HX를 생성·검수한 뒤 `VERTICAL_SLICE_APP_FLOW_SHELL` Codex 구현으로 진행한다.
