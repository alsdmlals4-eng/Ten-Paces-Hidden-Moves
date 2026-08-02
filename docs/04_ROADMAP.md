# 십보강호 구현 로드맵과 검증 기준

> 책임: 현재 구현 패키지·Vertical Slice 진입 순서·검증 게이트  
> 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`  
> 전투 규칙: `docs/02_COMBAT_RULES.md`  
> PoC 계약: `docs/05_COMBAT_POC_SPEC.md`  
> 테스트: `docs/08_TEST_CHECKLIST.md`

## 1. 현재 단계

```yaml
current_main_before_pr72_merge: 07b3f15c50d9900321bcec3897b8d0b726bd174e
checkpoint_pr: 72
checkpoint_approvals: 10/10
phase: VERTICAL_SLICE_APP_FLOW_PLANNING
project_core: CORE_CONFIRMED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
base_release: 9.4.1
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
t1_greenlight: NOT_GRANTED
```

## 2. 프로젝트 코어 확정

완료된 기획 기준선:

- [x] 1대1·10칸·3/3/4·비공개 계획·공개 상태 AI·복기 코어.
- [x] 기초 행동10종과 전조·준비 분리.
- [x] 장풍·사거리 밖 합·절초기세 보상.
- [x] 연격 현재 순번 피해 단위끼리 합하고 양측 공격이 유지되면 다음 순번 합을 반복.
- [x] 체력 피해 중단 시 피격측 후속타 취소, 강건 시 공격 유지 가능, 한쪽 종료 시 상대 잔여타 단독 해결.
- [x] 외공·근골·신법·내공·심안 5종, 범위1~15.
- [x] 기술 작성의 태그·고정치·주/보조 능력치 배수 분리.
- [x] 능력치 배수 기준 스테이터스4·단위0.25·합산 후 내림.
- [x] 전투 종료 등급의 5개 원자료: 회피·합·잃은 체력·라운드·절초 사용.
- [x] 무공서1~10성 성장 골격.
- [x] 데모 주요 비무5슬롯×후보3명·노드8개.
- [x] 정식 주요 비무10슬롯×후보3명·노드18개.
- [x] 주요 비무10전 뒤 후보2명 공개·1명 선택 천하제일인전.
- [x] 챔피언 스냅샷·한 경기 행동 프로필·시즌 평점 비동기 경쟁 원칙.
- [x] 공식 랭킹전 관찰 금지와 관찰 의존 효과 공식 변환 원칙.
- [x] ActionSelectionDock과 필수 화면·Scene 소유권 기획.
- [x] PC 우선·모바일 후속 고려.
- [x] Base v9.4.1 공유 Skill Adapter 적용.

기획 승인은 런타임 구현·사람 검증 완료를 뜻하지 않는다.

## 3. 현재 작업

현재 구현 우선 패키지는 `VERTICAL_SLICE_APP_FLOW_SHELL`이다.

```text
BOOT → MAIN → RUN_SETUP → ROUTE → NODE → DUEL_BRIEFING
→ COMBAT → COMBAT_REVIEW → DUEL_RESULT → REWARD_OR_RETRY
```

포함:

- 저충실도 App Root와 화면 상태 전환.
- Main·Setup·Route·Node·Briefing Shell.
- 최소 `RunSession`·`SaveService`.
- 기존 Combat PoC 진입·복귀.
- 보상·재도전 transaction.

제외:

- 최신 기초 행동10종·스테이터스 배수의 무단 런타임 구현.
- 후보15명 전체 제작.
- 주요 비무6~10·천하제일인·챔피언 서버 런타임.
- 최종 아트·오디오·모바일 포팅.
- 사람 검증 PASS 주장.

## 4. 남은 기획 Gate

후속 GrillMe에서 결정할 핵심 항목:

- [ ] 시작 스테이터스 총점·최저값·직접 분배 방식.
- [ ] 속공·강공·장풍의 정확한 고정 피해·배수.
- [ ] 5개 전투 종료 지표의 가중치·정규화·S/A/B/C 경계.
- [ ] 한 공격 행동 안의 다수 합 승리 상한·정규화·파밍 방지.
- [ ] 절초 사용 평가와 패배 전투의 등급 제공 여부.
- [ ] 챔피언 등록 슬롯·교체·보관 정책.
- [ ] 시즌 길이·매칭 범위·반복 상대 제한·어뷰징 방지.
- [ ] 친선전·자기 등록본의 관찰 규칙.

## 5. 구현 전 Combat Build Gate

최신 전투 규칙을 구현하려면 별도 Build 승인과 다음 입력이 필요하다.

- 정확한 시작 스테이터스.
- 속공·강공·장풍 고정 피해·배수.
- 관찰·장풍을 포함한 기초 행동 데이터와 UI.
- 현재 순번 합→체력 피해·중단→다음 순번 합·잔여 단독타 판정 테스트.
- 기술 ledger와 런타임 adapter Schema.
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

- 실행하지 않은 검증은 `NOT_RUN`이다.
- 자동 검증은 Windows·네트워크·사람 검증을 대체하지 않는다.
- PR은 최신 main을 포함한 exact head에서 검증한다.
- review thread·Sheet drift·head 이동·P0/P1이 남으면 병합하지 않는다.

## 9. STEP 14

- 신규 플레이어 5명.
- 4명 이상 치명적 차단 없이 데모 흐름 완료 또는 이탈 이유 기록.
- 4명 이상 3/3/4와 결정적 원인을 설명.
- 3명 이상 상대 가능 행동을 조사·추론.
- 3명 이상 노드 선택 뒤 다음 계획 변경.
- 3명 이상 재도전에서 계획 변경.
- 색·모션·음향 단일 채널 의존 없음.

현재 `human_validation: NOT_RUN`이다.

## 10. T1 진입 Gate

- App Flow Shell 자동·Godot 검증.
- Windows 실제 실행.
- 접근성·해상도·성능 검증.
- 신규 플레이어5명 STEP 14.
- 두 번째 상대·노드 반복 제작 증거.

현재 `t1_greenlight: NOT_GRANTED`다.

## 11. 온라인 경쟁 Gate

필요 증거:

- 등록 스냅샷 재현성과 버전 호환·격리.
- 행동 프로필의 안정성.
- 공식 관찰 변환표의 대칭성·효과 예산.
- 평점·반복 대전 제한·어뷰징 방지.
- 계정·개인정보·보안·네트워크 운영.
- 사람 경쟁 테스트.

## 12. GrillMe 병합 운영

- 살아 있는 사용자 승인10건마다 질문을 중단한다.
- main·브랜치·PR 전체 diff·정본·planning JSON·Sheet를 다시 읽는다.
- 구형 참조·Decision 충돌·중복 권위·구현 범위 누출·검증 과장을 적대적으로 검토한다.
- 미해결 리뷰·CI 실패·Sheet 불일치·head 이동·P0/P1이 있으면 병합하지 않는다.
- exact head만 병합하고 main·Sheet를 재조회한다.

현재 체크포인트는 `10/10 MERGE_GATE`다. 병합 완료 뒤 다음 GrillMe는 `0/10`에서 시작한다.

## 13. 중단·축소 조건

- 성장·노드 선택이 피해 증가만 만든다.
- 조사·관찰 없이 정답 추측에 의존한다.
- 연격·장풍·특정 스테이터스가 다른 선택을 지배한다.
- 연격 대 연격에서 순차 합·중단·잔여타 규칙이 이해되지 않는다.
- 3/3/4 또는 무공서→기술 관계가 이해되지 않는다.
- 같은 데이터 구조로 두 번째 기술·적·노드를 만들 수 없다.
- AI가 미확정 계획을 읽는다.
- 보상·저장이 이중 commit된다.

판정 어휘: `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`.
