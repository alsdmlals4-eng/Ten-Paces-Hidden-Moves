# 십보강호 제품 문서 지도

> 최상위 운영 지도: [`[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`](../%5B기획서%5D/00_%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8_%ED%97%88%EB%B8%8C/DOCUMENTATION_MAP.md)

## 1. 최초 진입

```text
../START_HERE.md
→ ../AGENTS.md
→ ../[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ 00_TAG_STATUS_REGISTRY.md
→ 01_GAME_DESIGN.md
→ 질문별 책임 원본
→ 실제 data/scenes/src/tests/PR
```

최신 사용자 승인 Decision과 approved planning JSON이 과거 Ledger·백업·구형 구현보다 우선한다. 실제 구현이 다르면 `IMPLEMENTED_LEGACY`로 기록한다.

## 2. 제품 문서 읽기 순서

1. `00_TAG_STATUS_REGISTRY.md` — 제품 태그·전투 키워드·상태 어휘.
2. `01_GAME_DESIGN.md` — 정체성·핵심 루프·제품 범위.
3. `02_COMBAT_RULES.md` — 기초 행동10종·관찰·순차 피해 단위 합·연격·능력치 배수·종료 등급.
4. `03_CONTENT_CATALOG.md` — 데모·정식 후반·천하제일인·온라인·HOLD.
5. `04_ROADMAP.md` — 다음 구현·기획·검증 Gate.
6. `05_COMBAT_POC_SPEC.md` — 첫 데모 계약.
7. `06_STARTING_FACTION_MASTERY_DATA.md` — 무공서1~10성·기술 성장.
8. `07_COMBAT_UI_SPEC.md` — HUD·입력·접근성.
9. `08_TEST_CHECKLIST.md` — 완료 증거·미검증 경계.
10. `09_COMBAT_SYSTEM_ARCHITECTURE.md` — 상태·이벤트·저장·AI.
11. `10_COMBAT_PRESENTATION_PLAN.md` — 판정 사건 연출.
12. `11_BASE_ADOPTION_AND_LEARNING_LOG.md` — Base 채택·제안·검증.

## 3. 현재 필수 Decision

기존 제품 기준:

- `TEN-DEC-20260802-PLATFORM-SCOPE-01`
- `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
- `TEN-DEC-20260802-FULLRUN-CHAMPION-RANKED-01`
- `TEN-DEC-20260802-RANKED-OBSERVATION-CONVERSION-01`

PR #72 전투 체크포인트:

- `TEN-DEC-20260802-BASIC-ACTIONS-PALM-CLASH-01`
- `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-REWARD-01`
- `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-GRADE-01`
- `TEN-DEC-20260802-CLASH-THREAT-ATTENUATION-01` — 현 등급 산식 HOLD
- `TEN-DEC-20260802-THREAT-ID-ACTION-01` — 로그·복기 ID
- `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
- `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`
- `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`
- `TEN-DEC-20260802-TECHNIQUE-AUTHORING-TAG-FIXED-STAT-01`
- `TEN-DEC-20260802-STAT-REFERENCE-PRICE-BASE4-01`

## 4. 현재 고정 제품 계약

- 1대1 10칸, 시작4/7, 거리0 `[밀착]`.
- `3수→3수→4수` 비공개 계획.
- 적 묶음 계획 잠금→관찰 공개→플레이어 계획.
- 기초 행동10종, 사용자 표시 `준비`, 강화 없는 `전조`.
- 연격 대 연격은 현재 순번 피해 단위끼리 합하고, 양측 공격이 유지되면 다음 순번 합을 반복한다.
- 합 패배·동점은 현재 피해 단위만 취소·상쇄한다.
- 체력 피해 중단은 피격측 후속 피해 단위를 취소하며, 강건은 공격을 유지시킬 수 있다.
- 한쪽 피해 단위가 끝나면 상대 잔여타는 단독으로 해결한다.
- 비소모 방어도·피해 단위 회피·필중·중단·강건.
- 능력치 배수 기준4·작성 단위0.25·합산 후 한 번 내림.
- 전투 종료 원자료: 회피·합·잃은 체력·라운드·절초 사용.
- 데모 주요 비무5×후보3, 노드8개.
- 정식 주요 비무10×후보3, 노드18개, 이후 천하제일인전.
- 챔피언 배틀은 `FUTURE_ONLINE`, 별도 승인 전 구현 차단.
- PC 우선, 모바일 후속 고려.

## 5. 작업별 최소 읽기

| 작업 | 최소 문서 |
|---|---|
| 방향·인수 | Active Context, 00, 01, 04 |
| 전투 규칙·밸런스 | 00, 01, 02, 05, 08, 최신 Decision·contract |
| 기술 작성·능력치 | 02, 05, 06, `poc_balance_budget.json`, 두 authoring Decision |
| 무공·성장 | 02, 03, 05, 06, 08 |
| 콘텐츠·경로 | 01, 03, 04, 05, planning JSON |
| UI·접근성 | 02, 07, 08, 09, 10, 실제 Scene |
| App Flow 구현 | Active Context, 04, 05, 08, 09, 실제 파일 |
| 천하제일인·챔피언 | 01, 03, 04, Champion Decision |
| 검수 | 00, 08, 감사 문서, PR diff·CI·실제 실행 |
| Base 업데이트 | Base lock·Adapter·11·최신 Base 원본 |

## 6. 구형·오해 표현 차단

활성 정본에서 사용하지 않는다.

- 사용자 표시 `태세`.
- 기초 행동8종 또는9종을 최신 전체 목록으로 표현.
- `첫 피해 단위만 합에 참여한다`는 표현.
- `첫 합 실패 시 공격 행동의 후속타가 전부 취소된다`는 표현.
- `후속 피해 단위는 다시 합하지 않는다`는 표현.
- 체력 피해·중단 정산과 무관하게 모든 피해 단위를 무조건 끝까지 합한다는 표현.
- 위협 대응30과 100→50→0 감쇠를 현 등급 산식으로 표현.
- 스테이터스 배수 가격 `MISSING_TBD`.
- 중간 노드2~3·PoC 방문13~17을 최신 범위로 표현.
- 범용 공격력·방어력 중심 성장과 공개 성향.
- 천하제일인 후보6명 고정·사전 예고.

정확한 표현은 `현재 순번 합 → 피해·중단 정산 → 양측 공격 유지 및 다음 피해 단위 존재 시 다음 순번 합`이다.

## 7. 현재 상태

```yaml
main_before_checkpoint_merge: 07b3f15c50d9900321bcec3897b8d0b726bd174e
base_release: 9.4.1
checkpoint_pr: 72
checkpoint_approvals: 10/10
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
runtime_latest_combat_contract: NOT_STARTED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
```

## 8. 갱신 규칙

- 새 규칙·태그는 GrillMe 승인 Decision이 필요하다.
- 명칭 정규화·구형 참조 제거는 유지보수로 처리한다.
- 책임 경로가 바뀌면 두 문서 지도·Active Context·Sheet를 함께 갱신한다.
- `v2`, `final`, `latest` 복제본 대신 Git 이력을 사용한다.
- 자동·Godot·Windows·접근성·네트워크·사람 검증을 분리한다.
