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
- 현재 Base release: `9.4.1`.
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
| 현재 체크포인트 감사 | `docs/reviews/2026-08-02_TAG_AND_PLANNING_CANON_AUDIT.md` |
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
5. `TEN-DEC-20260802-THREAT-ID-ACTION-01` — 로그·복기 안정 ID
6. `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
7. `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`
8. `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`
9. `TEN-DEC-20260802-TECHNIQUE-AUTHORING-TAG-FIXED-STAT-01`
10. `TEN-DEC-20260802-STAT-REFERENCE-PRICE-BASE4-01`

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

## 현재 전투 핵심

- 기초 행동 10종, 사용자 표시 `준비`, 강화 없는 `전조`.
- 연격 대 연격은 현재 순번 피해 단위끼리 앞에서부터 합한다.
- 현재 순번 정산 뒤 양측 공격이 유지되고 다음 피해 단위가 모두 있으면 다음 순번도 합한다.
- 합 패배·동점은 현재 피해 단위만 취소·상쇄한다.
- 체력 피해 중단은 피격측 후속타를 취소하며 강건이 중단을 막으면 다음 합을 계속할 수 있다.
- 한쪽 피해 단위가 끝나면 상대 잔여타는 단독으로 해결한다.
- 사거리 밖 현재 순번 합도 같은 지속 조건을 사용한다.
- 여러 합 승리에도 절초기세는 공격 행동당 최대 +1이다.
- 완전 파훼 사건은 공격 행동당 최대 1회다.

## 구조화 계획 데이터

이번 체크포인트의 승인 계약:

- `approved_20260802_basic_actions_palm_clash_contract.json`
- `approved_20260802_out_of_range_clash_reward_contract.json`
- `approved_20260802_out_of_range_clash_grade_value_contract.json`
- `approved_20260802_clash_threat_repeat_attenuation_contract.json`
- `approved_20260802_threat_identity_by_action_id_contract.json`
- `approved_20260802_multihit_complete_parry_contract.json`
- `approved_20260802_complete_parry_health_damage_only_contract.json`
- `approved_20260802_battle_grade_five_primary_metrics_contract.json`
- `approved_20260802_technique_authoring_tag_fixed_stat_contract.json`
- `approved_20260802_stat_reference_price_base4_contract.json`

## 현재 상태

```yaml
main_before_checkpoint_merge: 07b3f15c50d9900321bcec3897b8d0b726bd174e
checkpoint_pr: 72
checkpoint_approvals: 10/10
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
base_release: 9.4.1
action_selection:
  implementation_status: IMPLEMENTED_CURRENT
  automated_validation: PASS
  human_validation: NOT_RUN
latest_combat_planning:
  implementation_status: NOT_STARTED
full_product_flow_runtime: NOT_STARTED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
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

정확한 합 표현은 `현재 순번 합 → 피해·중단 정산 → 양측 공격 유지·다음 피해 단위 존재 시 다음 순번 합`이다.

## 현재 다음 작업

`VERTICAL_SLICE_APP_FLOW_SHELL` 구현 Packet 정밀화:

1. App Root·Scene·화면 상태.
2. `RunSession`·`SaveService`.
3. 시작 무공 6중4.
4. Route·Node·Briefing.
5. Combat 진입·복귀.
6. Result·Reward·Retry transaction.
7. 자동·Godot·Windows·접근성·성능·사람 검증.

후속 GrillMe:

- 시작 스테이터스 총점·분배.
- 속공·강공·장풍 정확 수치.
- 전투 종료 5지표 산식과 다수 합 승리 정규화.
- 챔피언 등록 슬롯·시즌·매칭·어뷰징·친선전 관찰.
