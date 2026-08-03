# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
last_planning_checkpoint_merge: d9f38e6f3cacaf170d4b290e95b3645114639aff
current_checkpoint_pr: 82
current_checkpoint_state: APPROVED_DRAFT_PR_NOT_MERGED
current_approval_count: 2/10
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
engine: Godot 4.7
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: PLAN
integration_pr: 65
base_release_pinned: 9.4.1
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
latest_combat_planning_runtime: NOT_STARTED
automated_validation: PASS
windows_validation: NOT_RUN
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: INTERMEDIATE_NODE_PERMANENT_STAT_REWARDS
```

PR #80의 10개 사용자 승인 Decision은 exact-head CI 3종, 문서 전용 diff, main behind0, 리뷰·미해결 스레드0, Google Sheet readback을 확인한 뒤 squash merge됐다. 체크포인트 main SHA는 `d9f38e6f3cacaf170d4b290e95b3645114639aff`다. PR #82는 새 승인 묶음의 두 Decision을 보유한 Draft이며 `10/10` 전에는 병합하지 않는다.

## 프로젝트 코어

> 공개 상태와 반복 습관을 읽고, 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·현재 순번 합·조건부 다음 순번 합·대응·중단으로 파훼하고 복기로 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

- AI는 공개 상태와 해결 이력만 사용하며 미확정 플레이어 계획을 읽지 않는다.
- 영구 전투 스테이터스는 외공·근골·신법·내공·심안이며 디자인 하드캡은 없다.
- 본편 관찰은 플레이어 전용이며 묶음·라운드 경계를 넘어 이월한다.
- 공식 챔피언 랭킹전은 양측 관찰을 금지하고 관찰 의존 효과에 공개·대칭·버전 고정 변환표를 적용한다.
- 태그·상태·범위·검증 어휘는 `docs/00_TAG_STATUS_REGISTRY.md`가 소유한다.
- 이후 GrillMe와 주요 기획은 정본 확인→적대적 검토→관련 벤치마크·현업 비교→선택지·권장안→승인 동기화 순서를 따른다.

## 앱 흐름 권위와 역사 연결

- `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`: 무공서가 아닌 해금 기술을 선택·배치하는 ActionSelectionDock UX 결정.
- `TEN-DEC-20260801-SITUATION-SCREEN-01`: 전투 전 상황 화면과 전투 진입 정보 구조 결정.
- 현재 앱 흐름 권위 원장은 `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`다.
- `PR #7`은 초기 PoC·기획 계보의 canonical freshness 역사 참조이며 최신 Decision이나 본 문서의 현재 기준보다 우선하지 않는다.
- `Issue #13`은 프로젝트 코어 검토와 PoC 검증 이력을 연결하는 역사 참조다.
- 과거 상태 `CORE_REVIEW_PENDING`은 사용자 승인 뒤 `CORE_CONFIRMED`로 종료됐다.
- `STEP 14`는 신규 플레이어 사람 검증 단계이며 현재 `human_validation: NOT_RUN`이다.
- 과거 이력 토큰은 최신 Decision과 본 문서의 현재 기준보다 우선하지 않는다.

## PR #80 체크포인트 승인 정본

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

## PR #82 현재 승인 정본

1. `TEN-DEC-20260803-STAR10-ULTIMATE-PRIMARY-STAT12-01`
2. `TEN-DEC-20260803-STARTING-MARTIAL-SECONDARY-STATS-01`

## 현재 전투·성장 정본 요약

- 기초 행동10종: 이동·보법·막기·회피·속공·강공·관찰·명상·준비·장풍.
- 전조는 강화 없는 점유·표시 단계이고 준비가 고정 강화 행동이다.
- 속공 `floor(3+외공×0.50)`, 강공 `floor(7+외공×1.00)`, 장풍 `floor(3+내공×0.75)`.
- 슬롯 예산은1수20틱·2수50틱·3수80틱, 사거리 총비용은1=0·2=10·3=25·4=40틱.
- 장풍은 밀치기 없는2수 내공 성장형 원거리 공격이며 기준 스테이터스4부터 속공보다 높은 피해를 가질 수 있다.
- 연격 대 연격은 현재 순번 피해 단위끼리 앞에서부터 합한다.
- 현재 순번 정산 뒤 양측 체력 피해가0이고 두 공격 행동이 유지되며 다음 피해 단위가 모두 있으면 다음 순번도 다시 합한다.
- 체력 피해로 한쪽 공격이 중단되면 그쪽 후속 피해 단위를 취소하고 상대 잔여타는 단독으로 해결한다. 강건이 중단을 막으면 다음 합을 계속할 수 있다.
- 사거리 밖 합 승리도 절초기세와 `ON_CLASH_WIN`을 얻지만 해당 피해 단위의 적중·체력 피해 효과는 발생하지 않는다.
- 시작 능력치는 기본2×5+자유6+선택 무공4개의2성 주능력치+1로 최종 총합20·평균4다.
- 시작3성 기술은 주 영구 능력치4, 7성 두 번째 기술은 주 영구 능력치8, 10성 고유 절초는 주 영구 능력치12를 요구한다.
- 3·7·10성의 무공 자체 자동 주 능력치 하한은3·6·9이며, 추가 영구 투자량은 각각+1·+2·+3이다.
- 요구치 미달 시 해당 기술·절초만 잠기며 무공 수련과 기존 보상은 유지되고, 영구 요구치 충족 시 추가 비용 없이 자동 활성화한다.
- 임시 능력치는 기술·절초 해금에 사용하지 않으며 활성화 후 임시 감소로 재잠금하지 않는다.
- 모든 시작 무공4개 조합에 네 첫 기술을 여는 최소 추천 배분이 존재하지만 동시 활성은 강제하지 않는다.
- 짝수 성은 최초 도달 시 새로 지급한다: 2성 주+1, 4성 주+1·보조+1, 6성 주+2·보조+1, 8성 주+3·보조+2.
- 시작 무공 주/보조 벡터: 유운 신법/외공, 금강 근골/내공, 태극 심안/내공, 추풍 외공/신법, 청심 내공/근골, 무영 신법/심안.
- 보조 능력치는4성부터 지급하며 모든 기술의 자동 이중 배수나3/7/10성 해금 요구를 뜻하지 않는다.
- 핵심 스테이터스에는 디자인 하드캡이 없고 기존1~15는 검증 구간이다. 실제값을 공식·요구치에 사용하며 검증점은1·4·15·현재 합법 최대값이다.
- 전투 종료 등급 핵심 원자료는 회피 성공·합 승리·잃은 체력·라운드 수·절초 사용이다.

## 구현 차이

현재 main 런타임은 다음이 최신 기획과 다르다.

- 관찰·장풍이 없는 기초 행동8종.
- 일부 레거시 데이터의 절대 원공격력.
- 최신 시작 총합20·무공 주/보조 벡터·잠금 미리보기·짝수 성 지급·3/7/10성 요구 미구현.
- 무상한 실제값의 공식·요구치·AI·UI·저장 연결 미구현.
- 주요 비무5전·노드8개·성장·새 결과 등급 미구현.

별도 Build 승인 전 제품 코드·Scene·런타임 데이터는 변경하지 않는다.

## 다음 제품 작업

현재 구현 우선 패키지는 `VERTICAL_SLICE_APP_FLOW_SHELL`이다.

1. App Root·Scene·화면 상태.
2. `RunSession`·`SaveService`.
3. 시작 무공6중4와 능력치 배분·잠금 미리보기 Shell.
4. Route·Node·Briefing.
5. Combat 진입·복귀.
6. Result·Reward·Retry transaction.
7. 자동·Godot·Windows·접근성·성능·사람 검증.

## 다음 승인 묶음의 남은 기획

- 중간 노드 영구 스테이터스 보상 여부·량.
- 무공별 개별 기술의 주/보조 배수·5/9성 임계 효과.
- 5개 전투 종료 지표의 가중치·정규화·등급 경계.
- 한 공격 행동 안의 다수 합 승리 상한·정규화·파밍 방지.
- 절초 사용의 평가 방식과 패배 전투 등급.
- 챔피언 등록 슬롯·시즌·매칭·어뷰징·친선전 관찰 규칙.
- 고능력치가 잘못된 계획을 덮는 비율의 사람 검증.

## 검증 경계

```yaml
planning_checkpoint: DRAFT_PR82_2_OF_10
checkpoint_merge: d9f38e6f3cacaf170d4b290e95b3645114639aff
product_code_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
network_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
human_step14: NOT_RUN
demo_ready: NO
```
