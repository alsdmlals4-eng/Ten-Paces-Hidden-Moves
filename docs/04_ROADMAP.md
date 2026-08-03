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
active_approval_count: 6/10
active_decision_state: APPROVED_PENDING_MERGE
phase: VERTICAL_SLICE_APP_FLOW_PLANNING
project_core: CORE_CONFIRMED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
base_release: 9.4.3
latest_combat_planning:
  authority_status: CURRENT_APPROVED_PLANNING
  implementation_status: NOT_STARTED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: STARTING_MARTIAL_TECHNIQUE_1_STAR5_ROLE_PATCHES
t1_greenlight: NOT_GRANTED
```

PR #84는 여섯 3성 기술1과 여섯 7성 기술2의 구조·공식·틱 예산까지 승인한 활성 배치 `6/10`이다. 정확한 head SHA는 GitHub PR 메타데이터를 권위로 사용한다. 현재 GrillMe는 `PLAN`이며 기획·검토·이미지 Gate 전 제품 구현 권한은 없다.

## 2. 프로젝트 코어 확정

완료된 기획 기준선:

- [x] 1대1·10칸·3/3/4·비공개 계획·공개 상태·복기 코어.
- [x] 기초 행동10종과 순번별 합·중단·잔여타 해결.
- [x] 외공·근골·신법·내공·심안5종과 무상한 핵심 스테이터스.
- [x] 슬롯 예산1수20틱·2수50틱·3수80틱, 최대 사거리 총비용0/10/25/40틱.
- [x] 시작 총합20·평균4, 3성 주4·7성 주8·10성 주12.
- [x] 짝수 성 고정 스테이터스 지급과 중간 노드 회차 최대+2.
- [x] 역할 우선 기술 작성과 같은 효과 주·보조 이중 배수 금지.
- [x] 여섯 3성 기술1의 구조·비용·공식·틱 예산.
- [x] 여섯 7성 기술2의 상태 전환형 고급 상호작용·틱 예산.
- [x] 예산표는 틱만 사용하고 `슬롯+자원 소모 추가분+조건 추가분`으로 사용 가능 예산을 표시.
- [x] 기력1 +4틱, 내력1 +7틱.
- [x] 행동 묶음 확정 뒤 추가 선택 금지.
- [x] 기술 안 이동은 고정 전진·고정 후퇴와 경계 폴백 사용.
- [x] 추풍일섬은 고정 전진1로 개정.
- [x] 기술1·기술2 모두 기준 능력치4에서 `±5틱` 안.
- [x] canonical ID와 역사 alias 분리.
- [x] PC 우선·모바일 후속 고려.
- [x] Base v9.4.3 공유 Skill Adapter 적용.

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

현재 제외:

- 기획·검토·이미지 Gate 전 Codex BUILD.
- 최신 전투·성장 규칙의 무단 런타임 구현.
- 행동 해결 도중 추가 선택 UI.
- 후보15명 전체 제작.
- 최종 아트·오디오·모바일 포팅.
- 사람 검증 PASS 주장.

## 4. 남은 기획 Gate

- [ ] 여섯 5성 기술1 patch의 실제 효과·조건·각 5틱 ledger.
- [ ] 여섯 9성 공개 정보 기반 자동 조건 분기.
- [ ] 무공별 10성 고유 절초 효과·행동 슬롯·자원·틱 예산.
- [ ] 비스탯 노드의 수련·회복·정보 기대가치·배치·가중치.
- [ ] 전투 종료 5지표의 가중치·정규화·S/A/B/C 경계.
- [ ] 챔피언 등록·시즌·매칭·어뷰징 방지 정책.
- [ ] 고능력치가 잘못된 계획을 덮는 비율의 사람 검증.

9성 자동 분기는 공개 조건으로 자동 발동해야 하며 행동 묶음 중 선택 창을 만들지 않는다. 선택형 기술은 별도 UX·중단/재개·저장·복기 계약 전까지 보류한다.

## 5. 구현 전 Combat Build Gate

별도 Build 승인과 다음 입력이 필요하다.

- 승인된 시작 능력치·성장·잠금 계약.
- 승인된 기본 공격·사거리·자원 틱 ledger.
- 승인된 여섯 3성 기술1과 여섯 7성 기술2 contract.
- 후속 승인될 5성 patch·9성 자동 분기 ledger.
- 고정 이동 방향·경계·점유·이동불가 폴백 테스트.
- 행동 묶음 해결 중 추가 입력 금지 테스트.
- 짝수 성 지급·노드 보상·저장 왕복 중복 방지 테스트.
- canonical ID와 `legacy_manual_alias` migration 검증.

현재 제품 런타임은 `IMPLEMENTED_LEGACY` 차이를 유지한다.

## 6. 콘텐츠 제작 순서

```text
슬롯별 대표 후보1명으로 제품 흐름 증명
→ 두 번째 후보·노드 반복 제작
→ 제작 시간·데이터 재사용·사람 검증
→ 검증된 슬롯부터 후보3명으로 확장
```

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
- PR은 최신 main을 포함한 exact head에서 검증한다.
- review thread·Sheet drift·head 이동·P0/P1이 남으면 병합하지 않는다.
- 승인 예산 검증은 효과 원가·슬롯 예산·자원/조건 추가분·사용 가능 예산·편차를 틱으로 읽는다.

## 9. STEP 14

- 신규 플레이어5명.
- 4명 이상 치명적 차단 없이 데모 흐름 완료 또는 이탈 이유 기록.
- 4명 이상 3/3/4와 결정적 원인을 설명.
- 3명 이상 상대 가능 행동을 조사·추론.
- 3명 이상 노드 선택 뒤 다음 계획 변경.
- 3명 이상 재도전에서 계획 변경.
- 행동 묶음 해결 중 추가 선택 창이 발생하지 않는지 기록.
- 기술1·기술2의 역할과 틱 예산 설명 이해도를 기록.

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
- 체크포인트에서 main·브랜치·PR 전체 diff·정본·planning JSON·Sheet를 다시 읽는다.
- 미해결 리뷰·CI 실패·Sheet 불일치·head 이동·P0/P1이 있으면 병합하지 않는다.
- exact head만 병합하고 main·Sheet를 재조회한다.

현재 승인 수는 `6/10`, 다음 우선 기획 Decision은 여섯 5성 기술1 역할 강화 patch다.

## 13. 중단·축소 조건

- 성장·노드 선택이 피해 증가만 만든다.
- 조사·관찰 없이 정답 추측에 의존한다.
- 연격·장풍·특정 스테이터스가 다른 선택을 지배한다.
- 기술2가 기술1을 전 상황에서 대체한다.
- 승인표에 틱 외 예산 단위를 병기한다.
- 자원 소모 예산 추가분을 숨긴다.
- 환불·면제 비용에 완전한 예산 추가분을 적용한다.
- 행동 묶음 해결 중 추가 선택을 요구한다.
- 이동 방향·경계·이동불가 폴백이 결정되지 않는다.
- 같은 효과 주·보조 계수가 중복된다.
- 구조값이 능력치 점당 증가한다.
- 역사 ID와 canonical ID가 동시에 권위가 된다.
- 같은 데이터 구조로 두 번째 기술·적·노드를 만들 수 없다.
- 보상·저장이 이중 commit된다.

판정 어휘: `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`.
