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
| 현재 활성 승인 배치 | PR #82, `289378c214702223dc0d1e149134438c3e761ba0`, 2/10 |
| 구현 사실 | 실제 `data/`, `src/`, `scenes/`, `tests/`, `project.godot` |

## 최신 활성 Decision

기존 핵심:

- `TEN-DEC-20260802-PLATFORM-SCOPE-01`
- `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
- `TEN-DEC-20260802-FULLRUN-CHAMPION-RANKED-01`
- `TEN-DEC-20260802-RANKED-OBSERVATION-CONVERSION-01`

PR #72 체크포인트:

1. `TEN-DEC-20260802-BASIC-ACTIONS-PALM-CLASH-01`
2. `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-REWARD-01`
3. `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-GRADE-01`
4. `TEN-DEC-20260802-CLASH-THREAT-ATTENUATION-01` — 현재 등급 산식에서는 HOLD
5. `TEN-DEC-20260802-THREAT-ID-ACTION-01`
6. `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
7. `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`
8. `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`
9. `TEN-DEC-20260802-TECHNIQUE-AUTHORING-TAG-FIXED-STAT-01`
10. `TEN-DEC-20260802-STAT-REFERENCE-PRICE-BASE4-01`

PR #80 체크포인트:

1. `TEN-DEC-20260802-BASIC-ATTACK-FORMULAS-SLOT-BUDGET-01`
2. `TEN-DEC-20260802-RANGE-PRICE-BANDS-01`
3. `TEN-DEC-20260802-BASIC-PALM-DAMAGE-GROWTH-01`
4. `TEN-DEC-20260802-STARTING-STAT-ALLOCATION-FIVE-01` — 후속 Decision으로 대체된 역사 승인
5. `TEN-DEC-20260802-STARTING-STAT-TOTAL20-MANUAL-BONUS-01`
6. `TEN-DEC-20260802-STARTING-TECHNIQUE-PRIMARY-STAT4-01`
7. `TEN-DEC-20260802-STARTING-TECHNIQUE-SOFT-GUARANTEE-01`
8. `TEN-DEC-20260802-EVEN-STAR-STAT-ESCALATION-01`
9. `TEN-DEC-20260803-UNCAPPED-CORE-STATS-01`
10. `TEN-DEC-20260803-STAR7-TECHNIQUE-PRIMARY-STAT8-01`

PR #82 현재 승인 `APPROVED_PENDING_MERGE`:

1. `TEN-DEC-20260803-STAR10-ULTIMATE-PRIMARY-STAT12-01`
2. `TEN-DEC-20260803-STARTING-MARTIAL-SECONDARY-STATS-01`

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

최근 병합 체크포인트와 활성 PR의 승인 계약은 `docs/planning-data/approved_*.json`에 Decision별로 보존한다. 활성 PR #82의 현재 계약:

- `approved_20260803_star10_ultimate_primary_stat12_contract.json`
- `approved_20260803_starting_martial_secondary_stats_contract.json`

## 현재 상태

```yaml
main_state_sync_commit: 6d8237e00168e45a7d3c001a0f6b3587b57147b7
last_planning_checkpoint_merge: d9f38e6f3cacaf170d4b290e95b3645114639aff
active_planning_pr: 82
active_planning_head: 289378c214702223dc0d1e149134438c3e761ba0
active_approval_count: 2/10
active_decision_state: APPROVED_PENDING_MERGE
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: PLAN
base_release: 9.4.3
action_selection:
  implementation_status: IMPLEMENTED_CURRENT
  automated_validation: PASS
  human_validation: NOT_RUN
latest_combat_planning:
  authority_status: CURRENT_APPROVED_PLANNING
  implementation_status: NOT_STARTED
full_product_flow_runtime: NOT_STARTED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: INTERMEDIATE_NODE_PERMANENT_STAT_REWARDS
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

GrillMe 승인 묶음:

1. 중간 노드 영구 스테이터스 보상 여부·량.
2. 무공별 기술의 주/보조 배수와 5/9성 임계 효과.
3. 전투 종료 5지표 가중치·정규화·등급 경계.
4. 다수 합 승리 상한·정규화·파밍 방지.
5. 절초 사용 평가와 패배 전투 등급.
6. 챔피언 등록·시즌·매칭·어뷰징·친선전 관찰.
7. 고능력치가 잘못된 계획을 덮는 비율의 사람 검증 계약.

기획 완료 후 전체 검토를 닫고, 필요한 이미지·애니메이션·HX를 생성·검수한 뒤 `VERTICAL_SLICE_APP_FLOW_SHELL` Codex 구현으로 진행한다.