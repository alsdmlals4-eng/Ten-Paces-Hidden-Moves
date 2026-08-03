# 십보강호 구현 로드맵과 검증 기준

> 책임: 현재 기획·검토·이미지·구현 패키지와 Vertical Slice 진입·검증 게이트  
> 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`  
> 전투 규칙: `docs/02_COMBAT_RULES.md`  
> PoC 계약: `docs/05_COMBAT_POC_SPEC.md`  
> 테스트: `docs/08_TEST_CHECKLIST.md`

## 1. 현재 단계

```yaml
main_state_sync_commit: add26649717a0b1bdf6eee40ad0b6214c9738eb4
last_planning_checkpoint_merge: d9f38e6f3cacaf170d4b290e95b3645114639aff
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: 84
active_planning_head: PR_METADATA_AUTHORITY
active_approval_count: 5/10
active_decision_state: APPROVED_PENDING_MERGE
phase: VERTICAL_SLICE_APP_FLOW_PLANNING
project_core: CORE_CONFIRMED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
base_release: 9.4.3
action_selection_dock:
  implementation_status: IMPLEMENTED_CURRENT
  automated_validation: PASS
  windows_validation: NOT_RUN
  human_validation: NOT_RUN
latest_combat_planning:
  authority_status: CURRENT_APPROVED_PLANNING
  implementation_status: NOT_STARTED
full_product_flow_runtime: NOT_STARTED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: STARTING_MARTIAL_TECHNIQUE_2_BASE_EFFECTS_AND_BUDGETS
t1_greenlight: NOT_GRANTED
```

PR #80의 10개 승인 정본은 main에 병합됐고 PR #81에서 main·Sheet 상태를 동기화했다. PR #83은 활성 정본 신선도를 Base 9.4.3과 최신 main에 맞춰 교정했다. PR #82의 승인 2건은 충돌 브랜치에서 보존된 뒤 PR #84로 이전됐다. PR #84는 여섯 시작 무공의 3성 기술1 구조·공식·투명 예산까지 승인한 활성 배치 `5/10`이다.

`active_planning_head`의 정확한 SHA는 자기참조 문서가 아니라 GitHub PR 메타데이터를 권위로 사용한다. `work_mode: REVIEW`·`integration_pr: 65`는 런타임 기준선이고 현재 GrillMe는 별도 `PLAN` 축이다. 기획 배치 완료 전 App Flow Shell 구현 권한은 없다.

## 2. 프로젝트 코어 확정

완료된 기획 기준선:

- [x] 1대1·10칸·3/3/4·비공개 계획·공개 상태 AI·복기 코어.
- [x] 기초 행동10종과 전조·준비 분리.
- [x] 장풍·사거리 밖 합·절초기세 보상.
- [x] 순번별 연격 합·중단·잔여타 해결.
- [x] 외공·근골·신법·내공·심안5종과 무상한 핵심 스테이터스.
- [x] 기술 작성의 태그·고정치·주/보조 능력치·사거리·자원 비용 분리.
- [x] 슬롯 예산1수20틱·2수50틱·3수80틱, 최대 사거리 총비용0/10/25/40틱.
- [x] 속공 `floor(3+외공×0.50)`, 강공 `floor(7+외공×1.00)`, 장풍 `floor(3+내공×0.75)`.
- [x] 시작 기본2×5+자유6+시작 무공 보너스4=총20·평균4.
- [x] 시작3성 기술 주4, 7성 기술 주8, 10성 절초 주12.
- [x] 짝수 성 신규 지급: 2성 주1, 4성 주1·보조1, 6성 주2·보조1, 8성 주3·보조2.
- [x] 시작 무공 여섯 종의 주·보조 매핑.
- [x] 데모 중간 노드 영구 스테이터스 최대2회·노드당 두 능력치 중 하나+1·회차 종료 초기화.
- [x] 역할 우선 기술 작성·주 능력치 핵심 효과·보조 능력치 선택적 별도 효과.
- [x] 같은 효과 주/보조 이중 배수와 구조값 점당 연속 증가 금지.
- [x] 기술1 기본 운용법·기술2 고급 상호작용·5성 역할 강화·9성 수읽기 분기.
- [x] 여섯 3성 기술1: 유운삼첩·금강가세·운수회신·추풍일섬·청심조식·철각유영.
- [x] 여섯 3성 기술1의 행동 슬롯·비용·사거리·공식·기준 능력치4 ledger.
- [x] 예산표에 효과 원가·자원 소모 크레딧·조건 크레딧·순예산·목표·편차를 틱/점으로 분리 표시.
- [x] 과거 PoC 무공 ID를 `legacy_manual_alias`로 격리하고 canonical ID 사용.
- [x] 전투 종료 등급의 5개 원자료: 회피·합·잃은 체력·라운드·절초 사용.
- [x] 무공서1~10성 성장 골격.
- [x] 데모 주요 비무5슬롯×후보3명·노드8개.
- [x] 정식 주요 비무10슬롯×후보3명·노드18개.
- [x] 주요 비무10전 뒤 후보2명 공개·1명 선택 천하제일인전.
- [x] 챔피언 스냅샷·행동 프로필·시즌 평점 비동기 경쟁 원칙.
- [x] 공식 랭킹전 관찰 금지와 관찰 의존 효과 공식 변환 원칙.
- [x] ActionSelectionDock과 필수 화면·Scene 소유권 기획.
- [x] PC 우선·모바일 후속 고려.
- [x] Base v9.4.3 공유 Skill Adapter 적용.
- [x] GrillMe·주요 기획에 벤치마킹·현업 비교 프로토콜 적용.

기획 승인은 런타임 구현·사람 검증 완료를 뜻하지 않는다.

## 3. 현재 작업 순서

```text
PR #84 남은 GrillMe 승인
→ [기획 완료]
→ 전체 정본·PR·Sheet 적대적 검토
→ [검토 완료]
→ 필요한 이미지·애니메이션·HX 생성·검수·승인
→ [이미지 완료]
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex BUILD
→ Windows·접근성·성능·사람 검증
```

현재 구현 후보 패키지:

```text
BOOT → MAIN → RUN_SETUP → ROUTE → NODE → DUEL_BRIEFING
→ COMBAT → COMBAT_REVIEW → DUEL_RESULT → REWARD_OR_RETRY
```

예정 포함:

- 저충실도 App Root와 화면 상태 전환.
- Main·Setup·Route·Node·Briefing Shell.
- 최소 `RunSession`·`SaveService`.
- 기존 Combat PoC 진입·복귀.
- 보상·재도전 transaction.

현재 제외:

- 기획·검토·이미지 Gate 전 Codex BUILD.
- 최신 전투·성장 규칙의 무단 런타임 구현.
- 후보15명 전체 제작.
- 주요 비무6~10·천하제일인·챔피언 서버 런타임.
- 최종 아트·오디오·모바일 포팅.
- 사람 검증 PASS 주장.

## 4. 남은 기획 Gate

후속 GrillMe 핵심 항목:

- [ ] 여섯 7성 기술2의 정확한 행동 슬롯·비용·사거리·고정 효과·계수.
- [ ] 여섯 5성 기술1 patch의 실제 효과·조건·5틱 ledger.
- [ ] 기술별 9성 수읽기 분기의 실제 효과·조건·예산.
- [ ] 무공별 10성 고유 절초 효과·행동 슬롯·자원·예산.
- [ ] 비스탯 노드의 수련·회복·정보 기대가치·배치·가중치.
- [ ] 전투 종료 5지표의 가중치·정규화·S/A/B/C 경계.
- [ ] 한 공격 안 다수 합 승리 상한·정규화·파밍 방지.
- [ ] 절초 사용 평가와 패배 전투 등급 제공 여부.
- [ ] 챔피언 등록 슬롯·교체·보관 정책.
- [ ] 시즌 길이·매칭 범위·반복 상대 제한·어뷰징 방지.
- [ ] 친선전·자기 등록본 관찰 규칙.
- [ ] 고능력치가 잘못된 계획을 덮는 비율의 사람 검증.

## 5. 구현 전 Combat Build Gate

별도 Build 승인과 다음 입력이 필요하다.

- 승인된 시작 능력치·2성 보너스·3/7/10성 잠금 계약.
- 승인된 속공·강공·장풍 공식, 슬롯 예산, 사거리·자원 ledger.
- 승인된 중간 노드 성장과 역할 우선·선택적 배수 계약.
- 승인된 여섯 3성 기술1 정확 효과·계수·투명 예산 contract.
- 후속 승인될 5성 patch·7성 기술2·9성 분기 ledger.
- 관찰·장풍을 포함한 기초 행동 데이터와 UI.
- 순번 합→체력 피해·중단→다음 합·잔여 단독타 테스트.
- 짝수 성 지급·노드 보상·저장 왕복 중복 방지 테스트.
- 같은 효과 이중 배수 금지와 구조값 임계 처리 테스트.
- 무상한 실제값을 공식·요구치·AI·UI·저장에 사용하는 검증.
- 기술 ledger와 런타임 adapter Schema.
- canonical ID와 `legacy_manual_alias` migration 검증.
- 전투 종료 5지표 이벤트와 산식.

현재 제품 런타임은 `IMPLEMENTED_LEGACY` 차이를 유지한다.

## 6. 콘텐츠 제작 순서

```text
슬롯별 대표 후보1명으로 제품 흐름 증명
→ 두 번째 후보·노드 반복 제작
→ 제작 시간·데이터 재사용·사람 검증
→ 검증된 슬롯부터 후보3명으로 확장
```

후보 수를 줄이는 결정이 아니라 제작 파이프라인 위험을 먼저 검증하는 순서다.

## 7. Demo·정식 회차

```yaml
demo:
  major_duels: 5
  candidates_per_slot: 3
  intermediate_nodes: 8
  target_playtime: 15_to_22_minutes
full_run_before_finale:
  major_duels: 10
  candidates_per_slot: 3
  intermediate_nodes: 18
  target_playtime: 30_to_40_minutes
finale:
  scope_status: FUTURE_FINALE
  candidates_presented: 2
  player_selects: 1
champion_battle:
  scope_status: FUTURE_ONLINE
  implementation_status: BLOCKED_NOT_AUTHORIZED
```

## 8. 공통 검증 게이트

```text
계약·Schema
→ JSON·정적 검사
→ 자동 테스트
→ Godot headless
→ Windows runtime·render
→ 접근성·성능
→ 사람 플레이
→ 정본·Sheet 동기화
→ evidence report
```

- 실행하지 않은 검증은 `NOT_RUN`.
- 자동 검증은 Windows·네트워크·사람 검증을 대체하지 않는다.
- PR은 최신 main을 포함한 exact head에서 검증한다.
- review thread·Sheet drift·head 이동·P0/P1이 남으면 병합하지 않는다.
- 기술 예산 검증은 효과 원가·자원 크레딧·조건 크레딧·순예산을 모두 읽는다.

## 9. STEP 14

- 신규 플레이어5명.
- 4명 이상 치명적 차단 없이 데모 흐름 완료 또는 이탈 이유 기록.
- 4명 이상 3/3/4와 결정적 원인을 설명.
- 3명 이상 상대 가능 행동을 조사·추론.
- 3명 이상 노드 선택 뒤 다음 계획 변경.
- 3명 이상 재도전에서 계획 변경.
- 색·모션·음향 단일 채널 의존 없음.
- 고능력치가 잘못된 계획을 덮는 빈도 기록.
- 영구 스테이터스 노드 선택률과 비스탯 노드 포기율 기록.
- 여섯 3성 기술1의 역할·비용·예산 설명 이해도를 기록.

현재 `human_validation: NOT_RUN`이다.

## 10. T1 — 최소 세로 슬라이스

T1 진입 Gate:

- 기획 완료·검토 완료·이미지 완료.
- App Flow Shell 자동·Godot 검증.
- Windows 실제 실행.
- 접근성·해상도·성능 검증.
- 신규 플레이어5명 STEP 14.
- 두 번째 상대·노드 반복 제작 증거.

현재 `t1_greenlight: NOT_GRANTED`다.

## 11. 온라인 경쟁 Gate

필요 증거:

- 등록 스냅샷 재현성과 버전 호환·격리.
- 행동 프로필 안정성.
- 공식 관찰 변환표 대칭성·효과 예산.
- 평점·반복 대전 제한·어뷰징 방지.
- 계정·개인정보·보안·네트워크 운영.
- 사람 경쟁 테스트.

## 12. GrillMe 병합 운영

- 살아 있는 사용자 승인은 최대10건을 한 배치로 처리한다.
- 고위험 충돌·세션 종료·정본 영향이 크면 조기 체크포인트를 허용한다.
- 체크포인트에서 main·브랜치·PR 전체 diff·정본·planning JSON·Sheet를 다시 읽는다.
- 구형 참조·Decision 충돌·중복 권위·구현 범위 누출·검증 과장을 적대적으로 검토한다.
- 미해결 리뷰·CI 실패·Sheet 불일치·head 이동·P0/P1이 있으면 병합하지 않는다.
- exact head만 병합하고 main·Sheet를 재조회한다.

PR #80 체크포인트는 `d9f38e6f3cacaf170d4b290e95b3645114639aff`로 main에 병합됐다. PR #84의 현재 승인 수는 `5/10`, 다음 우선 기획 Decision은 여섯 7성 기술2 기본 효과·예산이다.

## 13. 중단·축소 조건

- 성장·노드 선택이 피해 증가만 만든다.
- 조사·관찰 없이 정답 추측에 의존한다.
- 연격·장풍·특정 스테이터스가 다른 선택을 지배한다.
- 영구 스테이터스가 잘못된 계획을 반복 구제한다.
- 스테이터스 노드가 회복·수련·정보를 지배한다.
- 관찰 누적이 불확실성을 제거한다.
- 등급 산식이 합·회피 반복 파밍을 유도한다.
- 연격 대 연격의 순차 합·중단·잔여타가 이해되지 않는다.
- 3/3/4 또는 무공서→기술 관계가 이해되지 않는다.
- 기술 예산표가 자원 소모 크레딧을 숨긴다.
- 환불·면제 비용에 완전 크레딧을 적용한다.
- 같은 효과 주·보조 계수가 중복된다.
- 구조값이 능력치 점당 증가한다.
- 역사 ID와 canonical ID가 동시에 권위가 된다.
- 같은 데이터 구조로 두 번째 기술·적·노드를 만들 수 없다.
- AI가 미확정 계획을 읽는다.
- 보상·저장이 이중 commit된다.

판정 어휘: `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`.
