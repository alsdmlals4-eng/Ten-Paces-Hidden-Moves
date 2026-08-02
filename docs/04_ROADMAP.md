# 십보강호 구현 로드맵과 검증 기준

> 책임: 현재 구현 패키지·Vertical Slice 진입 순서·검증 게이트  
> 태그·상태: `docs/00_TAG_STATUS_REGISTRY.md`  
> 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`  
> 전투 규칙: `docs/02_COMBAT_RULES.md`  
> PoC 계약: `docs/05_COMBAT_POC_SPEC.md`

## 1. 현재 단계

```yaml
reviewed_main_before_this_audit: 7082dab1c66e994ce3be1861640754f97080ed5c
phase: VERTICAL_SLICE_APP_FLOW_PLANNING
project_core: CORE_CONFIRMED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
latest_operating_pr: 68
latest_planning_pr: 71
action_selection_dock:
  implementation_status: IMPLEMENTED_CURRENT
  automated_validation: PASS
  windows_validation: NOT_RUN
  human_validation: NOT_RUN
full_product_flow_runtime: NOT_STARTED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
t1_greenlight: NOT_GRANTED
```

## 2. 완료된 기획 기준선

- [x] 1대1·10칸·3/3/4·비공개 계획·공개 상태 AI·복기 코어.
- [x] 플레이어 전용 `[관찰]`, 적 현재 묶음 계획 잠금, 관찰량 이월.
- [x] 외공·근골·신법·내공·심안 5종 영구 스테이터스.
- [x] 무공서 1~10성, 2·4·6·8성 스테이터스, 3·7성 기술, 5·9성 강화·임계, 10성 절초.
- [x] 데모 주요 비무 5슬롯×후보3명, 중간 노드8개.
- [x] 정식 주요 비무 10슬롯×후보3명, 중간 노드18개.
- [x] 주요 비무 10전 뒤 전설 후보2명 공개·1명 선택 천하제일인전.
- [x] 고정 챔피언 스냅샷·천하제일인전 한 경기 행동 프로필·시즌 평점 비동기 경쟁 기획.
- [x] 공식 랭킹전 양측 `[관찰]` 금지와 관찰 의존 효과 공식 변환 원칙.
- [x] 3수 계획 편집·해결·복기 UX.
- [x] 무공서→해금 기술→수 배치 ActionSelectionDock.
- [x] 필수 화면4종·P0 상황10종·Scene 소유권.
- [x] PC 우선·모바일 후속 고려 플랫폼 범위.
- [x] Base v9.4 운영 계약 적용.

위 항목의 기획 승인은 런타임 구현·사람 검증 완료를 뜻하지 않는다.

## 3. 현재 Gate — App Flow Shell 구현 Packet

다음 항목을 실제 저장소 파일·Scene·상태 계약으로 닫아야 한다.

- [ ] App Root·화면 상태·Scene 소유권의 정확한 파일 경로.
- [ ] `RunSession`·`SaveService` 최소 Schema·저장·복구.
- [ ] 시작 무공 6중4 선택 데이터·UI·취소·확정.
- [ ] Route·Node·Briefing 상태·입출력·실패.
- [ ] 기존 Combat 진입·복귀.
- [ ] Result·Reward·Retry 단일 transaction.
- [ ] 중복 입력·저장 실패·same-seed 재진입 회귀.
- [ ] 키보드·마우스·게임패드 Focus.
- [ ] 1280×800·1440×900·16:9 safe area.
- [ ] 자동·Godot·Windows·접근성·성능·사람 수용 기준.
- [ ] 롤백 단위와 보호 경로.

## 4. 다음 BUILD 패키지

패키지명: `VERTICAL_SLICE_APP_FLOW_SHELL`.

```text
BOOT
→ MAIN
→ RUN_SETUP
→ ROUTE
→ NODE
→ DUEL_BRIEFING
→ COMBAT
→ COMBAT_REVIEW
→ DUEL_RESULT
→ REWARD_OR_RETRY
```

포함:

- 저충실도 App Root와 화면 상태 전환.
- Main·Setup·Route·Node·Briefing Shell.
- 최소 `RunSession`·`SaveService`.
- 기존 Combat PoC 진입·복귀.
- 보상·재도전 transaction.

제외:

- 후보15명 전체 제작.
- 주요 비무6~10 런타임.
- 천하제일인·챔피언 배틀 런타임·서버.
- 최종 아트·오디오.
- 모바일 포팅·스토어·터치 전용 UX.
- 사람 검증 PASS 주장.

## 5. 콘텐츠 제작 순서

```text
슬롯별 대표 후보1명으로 제품 흐름 증명
→ 두 번째 후보·노드 반복 제작
→ 제작 시간·데이터 재사용·사람 검증
→ 검증된 슬롯부터 후보3명으로 확장
```

후보 수를 줄이는 결정이 아니라 파이프라인 위험을 먼저 검증하는 제작 순서다.

## 6. Demo·정식 회차

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
  type: FUTURE_FINALE
  candidates_presented: 2
  player_selects: 1
champion_battle:
  type: FUTURE_ONLINE
  implementation_status: BLOCKED_NOT_AUTHORIZED
```

## 7. 검증 계단

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

실행하지 않은 검증은 `NOT_RUN`이다. 자동 검증은 Windows·네트워크·사람 검증을 대체하지 않는다.

## 8. STEP 14

- 신규 플레이어5명.
- 4명 이상 치명적 차단 없이 데모 흐름 완료 또는 이탈 이유 기록.
- 4명 이상 3/3/4와 결정적 원인을 설명.
- 3명 이상 상대 가능 행동을 조사·추론.
- 3명 이상 노드 선택 뒤 다음 계획 변경.
- 3명 이상 재도전에서 계획 변경.
- 색·모션·음향 단일 채널 의존 없음.

현재 `human_validation: NOT_RUN`이다.

## 9. T1 진입 Gate

- App Flow Shell 자동·Godot 검증.
- Windows 실제 실행.
- 접근성·해상도·성능 검증.
- 사람 STEP 14.
- 두 번째 상대·노드 반복 제작 증거.

현재 `t1_greenlight: NOT_GRANTED`다.

## 10. 플랫폼 제작 순서

```text
PC App Flow Shell
→ Windows·저장·성능·STEP 14 검증
→ 대표 콘텐츠 반복 제작성 확인
→ 모바일 타당성 조사
→ 별도 사용자 승인·Decision
→ 필요 시 모바일 포팅
```

모바일은 현재 출시 약속이나 동시 개발 범위가 아니다.

## 11. 온라인 경쟁 Gate

`FUTURE_ONLINE`은 기획 승인 상태지만 구현은 별도 승인 전 `BLOCKED_NOT_AUTHORIZED`다.

필요 증거:

- 등록 스냅샷 재현성.
- 천하제일인전 한 경기 행동 프로필의 안정성.
- 데이터 버전 호환·격리.
- 공식 관찰 변환표의 대칭성·효과 예산.
- 평점·반복 대전 제한·어뷰징 방지.
- 계정·개인정보·보안·네트워크 운영.
- 사람 경쟁 테스트.

## 12. GrillMe 병합 운영

- 최종 살아 있는 사용자 승인10건마다 질문을 중단한다.
- GitHub main·브랜치·PR diff·권위 문서·planning JSON·Google Sheet를 다시 읽는다.
- 누락·충돌·구형 참조·중복 권한·범위 누출·검증 과장을 적대적으로 검토한다.
- 미해결 리뷰·CI 실패·Sheet 불일치·head 이동·P0/P1 충돌이 있으면 병합하지 않는다.
- 검증한 exact head만 병합하고 main·Sheet를 재조회한다.

현재 GrillMe 승인 카운트는 `0/10`이다.

## 13. 중단·축소 조건

- 연격이 다른 공격을 지배한다.
- 성장·노드 선택이 피해 증가만 만든다.
- 노드가 반복 피로만 늘린다.
- 조사·관찰 없이 정답 추측에 의존한다.
- 3/3/4 또는 무공서→기술 관계가 이해되지 않는다.
- 두 번째 무공·적·노드를 같은 데이터 구조로 만들 수 없다.
- 플레이어 미확정 계획을 AI가 읽는다.
- 보상·저장이 이중 commit된다.
- 모바일 고려가 PC 범위를 무단 확장한다.

판정 어휘: `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`.
