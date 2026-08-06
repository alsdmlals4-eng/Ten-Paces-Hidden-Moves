# 십보강호 구현 로드맵과 검증 기준

> 책임: 현재 기획·검토·이미지·구현 패키지와 Vertical Slice 진입·검증 게이트  
> 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`  
> 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 전투 규칙: `docs/02_COMBAT_RULES.md`  
> 병합 후 감사: `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`  
> PoC 계약: `docs/05_COMBAT_POC_SPEC.md`  
> 테스트: `docs/08_TEST_CHECKLIST.md`

## 1. 현재 단계

```yaml
merged_planning_checkpoint: 0ba841ff2e62b2f716466356dd9e7ffcf587d150
merged_pr_lineage: 84,86,87
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: NONE
active_planning_parent_pr: NONE
active_approval_count: 7/10
active_decision_state: MERGED_CANON_CHECKPOINT
phase: VERTICAL_SLICE_APP_FLOW_PLANNING
project_core: CORE_CONFIRMED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
base_release: 9.4.3
latest_combat_planning:
  authority_status: CURRENT_APPROVED_PLANNING
  implementation_status: NOT_STARTED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: STAR9_PUBLIC_READ_BRANCH_TEMPLATE
t1_greenlight: NOT_GRANTED
```

PR #84·#86·#87은 병합 완료된 역사 계보다. 현행 권위는 main의 Decision·approved contract·책임 원본이다. PR #85 HTML PoC는 `[보류]`로 닫혔으며 별도 재개 승인 전 병합·제품 참조를 금지한다.

## 2. 프로젝트 코어 확정

프로젝트 코어는 다음과 같다.

> 공개된 객관 정보와 관찰로 잠긴 상대 계획을 추론하고, 서로의 미확정 계획을 모르는 상태에서 `3수 → 3수 → 4수`를 설계해 거리·순서·합·방어·회피·중단으로 파훼한 뒤 복기에서 원인을 이해하고 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

확정 기준선:

- [x] 1대1·10칸·3/3/4·비공개 계획·공개 상태·복기 코어.
- [x] AI는 미확정 플레이어 계획을 읽지 않으며 관찰 전에 현재 묶음을 잠금.
- [x] 기초 행동 10종과 순번별 합·중단·잔여타 해결.
- [x] 외공·근골·신법·내공·심안 5종과 무상한 핵심 스테이터스.
- [x] 슬롯 예산 1수20틱·2수50틱·3수80틱.
- [x] 이동1칸15틱·공격 사거리1 초과1칸15틱.
- [x] 시작 총합20·평균4, 3성 주4·7성 주8·10성 주12.
- [x] 짝수 성 고정 스테이터스 지급과 중간 노드 회차 최대+2.
- [x] 역할 우선 기술 작성과 같은 효과 주·보조 이중 배수 금지.
- [x] 기존 승인 행동 15종의 유효 비용·슬롯 repricing.
- [x] 기술1 6종의 조건부 저점/고점 효과와 5성 무료20% 강화.
- [x] 조건 실패 시 연결 묶음 전부0·부분 지급/이월/대체/전환 금지.
- [x] 연격 총피해 1회 계산 후 40%/30%/나머지 분배.
- [x] 여섯 7성 기술2의 상태 전환형 고급 상호작용·틱 예산.
- [x] 행동 묶음 확정 뒤 추가 선택 금지와 고정 이동 폴백.
- [x] canonical ID와 역사 alias 분리.
- [x] PC 우선·모바일 후속 고려.
- [x] Base v9.4.3 공유 Skill Adapter 적용.

기획 승인은 런타임 구현·사람 검증 완료를 뜻하지 않는다.

## 3. 병합 후 적대적 검토 결론

현재 구조는 핵심 재미와 맞는다. 즉시 수치나 전투 골격을 교체하기보다 다음 위험을 실측하는 것이 우선이다.

| 위험 | 왜 핵심 재미를 위협하는가 | 현재 조치 |
|---|---|---|
| `RESOURCE_SATURATION_RISK` | 묶음마다 3자원+1이 희소성과 명상·준비 가치를 약화할 수 있음 | 규칙 유지·상한률/낭비율/선택률 실측 |
| `CONDITION_CALIBRATION_RISK` | 조건 계수가 실제 성공률과 다르면 무료 고효율 또는 함정이 됨 | 기술별 성공률과 선언 난도 범위 비교 |
| `WRONG_PLAN_RESCUE_RISK` | 높은 능력치가 잘못된 거리·순서를 구제하면 계획 재미가 수치에 대체됨 | 올바른 읽기와 잘못된 읽기의 성과 차이 측정 |
| `OBSERVATION_ANSWER_LEAK_RISK` | 관찰이 정답을 직접 주면 추론 긴장이 사라짐 | 계획 변경률·추론 설명률·금지 정보 노출 검사 |
| `GRADE_FARMING_RISK` | 등급 산식 미확정으로 합·회피·절초 반복 파밍 가능 | 산식 Decision 전 제품 권위 금지 |
| `RUNTIME_AUTHORITY_GAP` | 최신 기획이 현재 런타임에 미구현 | Build 승인 전 구현 완료 주장 금지 |

실측 전 자원 회복량·조건 계수·능력치 배수를 자동 조정하지 않는다.

## 4. 현재 작업 순서

```text
9성 공개 정보 자동 분기 공통 템플릿
→ 여섯 개별 9성 분기
→ 여섯 10성 고유 절초 효과·슬롯·자원·틱 예산
→ 비스탯 노드 기대가치·배치·가중치
→ 전투 종료 5지표 등급 산식·파밍 방지
→ 전체 핵심 재미·정본 적대적 검토
→ [기획 완료]
→ 필요한 이미지·애니메이션·HX 생성·검수·승인
→ [이미지 완료]
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex BUILD
→ Godot·Windows·접근성·성능·사람 검증
```

기존처럼 여섯 9성 분기를 바로 독립 작성하지 않는다. 먼저 공통 trigger·실패 경로·가격·복기·대응 수단을 고정해 분기 간 설계 편차와 숨은 정보 참조를 막는다.

현재 제외:

- 기획·검토·이미지 Gate 전 Codex BUILD.
- 최신 전투·성장 규칙의 무단 런타임 구현.
- 행동 해결 도중 추가 선택 UI.
- PR #85 HTML PoC 병합 또는 현행 정본 참조.
- 후보 15명 전체 제작.
- 최종 아트·오디오·모바일 포팅.
- 사람 검증 PASS 주장.

## 5. 남은 기획 Gate

### 5.1 9성 공통 템플릿

필수 필드:

- 공개 정보만 사용하는 trigger.
- 적 계획 잠금 뒤에도 미공개 정보 접근 금지.
- 행동 묶음 중 추가 입력 없는 자동 발동.
- 조건 실패 시 어느 효과가 0이 되는지 명시.
- 조건 난도 계수와 예상 성공 범위.
- 상대가 취할 수 있는 대응 수단.
- 복기에서 보여줄 성공·실패 원인 문구.
- 기술1·기술2 대체율과 실제 성공률 측정 계획.

### 5.2 개별 9성 분기

- [ ] 유운검결.
- [ ] 금강호체공.
- [ ] 태극유전검.
- [ ] 추풍창법.
- [ ] 청심양생공.
- [ ] 무영십보.

### 5.3 10성 절초

- [ ] 여섯 고유 절초 효과.
- [ ] 행동 슬롯·기력·내력·절초기세 비용.
- [ ] 이동·사거리·조건·중단 ledger.
- [ ] 기술1·2를 무효화하지 않는 역할.

### 5.4 회차·평가

- [ ] 비스탯 노드의 수련·회복·정보 기대가치·배치·가중치.
- [ ] 전투 종료 5지표의 가중치·정규화·S/A/B/C 경계·상한.
- [ ] 합·회피·절초 반복 파밍 방지.
- [ ] 챔피언 등록·시즌·매칭·어뷰징 방지 정책은 온라인 Gate로 유지.

## 6. 구현 전 Combat Build Gate

별도 Build 승인과 다음 입력이 필요하다.

- 승인된 시작 능력치·성장·잠금 계약.
- 승인된 기본 공격·사거리·자원 틱 ledger.
- 승인된 기존 행동 유효 슬롯·비용 repricing overlay.
- 승인된 기술1 조건부 효과·5성 patch overlay.
- 승인된 여섯 7성 기술2 contract.
- 후속 승인될 9성 자동 분기·10성 절초 ledger.
- 조건 trigger와 all-or-nothing 실패 회귀 테스트.
- 연격 총피해 선계산·분배·후속타 취소 테스트.
- 고정 이동 방향·경계·점유·이동불가 폴백 테스트.
- 행동 묶음 해결 중 추가 입력 금지 테스트.
- 짝수 성 지급·노드 보상·저장 왕복 중복 방지 테스트.
- canonical ID와 `legacy_manual_alias` migration 검증.
- 자원 포화·조건 성공률·잘못된 계획 구제 위험의 측정 계획.

현재 제품 런타임은 `IMPLEMENTED_LEGACY` 차이를 유지한다.

## 7. 콘텐츠 제작 순서

```text
슬롯별 대표 후보1명으로 제품 흐름 증명
→ 두 번째 후보·노드 반복 제작
→ 제작 시간·데이터 재사용·사람 검증
→ 검증된 슬롯부터 후보3명으로 확장
```

## 8. Demo·정식 회차

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

## 9. 공통 검증 게이트

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
- PR은 exact head에서 검증한다.
- review thread·Sheet drift·head 이동·P0/P1 미처리가 있으면 병합하지 않는다.
- 승인 예산은 효과 원가·슬롯·자원/조건 가격·사용 가능 예산·편차를 틱으로 읽는다.
- 조건 실패는 연결 효과 전부0이며 부분 지급·이월·대체·전환이 없어야 한다.
- 5성 예산은 `round_half_up(유효 사용 가능 예산×0.20)`와 일치해야 한다.
- `[대체됨]`과 `[보류]` 자료는 현행 제품 권위에서 제외한다.

## 10. STEP 14

- 신규 플레이어 5명.
- 4명 이상 치명적 차단 없이 데모 흐름 완료 또는 이탈 이유 기록.
- 4명 이상 3/3/4와 결정적 원인을 설명.
- 3명 이상 상대 가능 행동을 조사·추론.
- 3명 이상 노드 선택 뒤 다음 계획 변경.
- 3명 이상 재도전에서 계획 변경.
- 행동 묶음 해결 중 추가 선택 창이 발생하지 않는지 기록.
- 기술1 실패 저점·성공 고점과 조건을 설명할 수 있는지 기록.
- 유운삼첩 총피해 분배와 후속타 취소를 이해하는지 기록.
- 기술2가 기술1을 전 상황에서 대체하지 않는지 기록.
- 자원 상한·자동 회복 낭비·명상/준비 선택률 기록.
- 고능력치가 잘못된 계획을 구제한 사례 기록.

현재 `human_validation: NOT_RUN`이다.

## 11. T1 — 최소 세로 슬라이스

T1 진입 Gate:

- 기획 완료·검토 완료·이미지 완료.
- App Flow Shell 자동·Godot 검증.
- Windows 실제 실행.
- 접근성·해상도·성능 검증.
- 신규 플레이어5명 STEP 14.
- 두 번째 상대·노드 반복 제작 증거.

현재 `t1_greenlight: NOT_GRANTED`다.

## 12. 온라인 경쟁 Gate

필요 증거:

- 등록 스냅샷 재현성과 버전 호환·격리.
- 행동 프로필 안정성.
- 공식 관찰 변환표 대칭성·효과 예산.
- 평점·반복 대전 제한·어뷰징 방지.
- 계정·개인정보·보안·네트워크 운영.
- 사람 경쟁 테스트.

## 13. 정본 생명주기 운영

- `[현행]`: 후속 기획·구현 인계에 사용.
- `[대체됨]`: 역사 재현·migration diff에만 사용.
- `[보류]`: 명시적 재개 전 병합·제품 참조 금지.
- `[폐기]`: 현재·역사 권위가 모두 없을 때만 사용.
- 상세 목록은 `docs/CANON_LIFECYCLE_REGISTRY.md`를 따른다.
- 병합 뒤 `ACTIVE_CONTEXT`·로드맵·Sheet 상태를 같은 Decision ID로 즉시 갱신한다.

## 14. 전체 적대적 검토 분류

각 검토 항목은 `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST` 중 하나로 기록한다.

- `KEEP`: AI 비치팅 금지, 10칸·3/3/4, 전조·중단, 복기.
- `AMPLIFY`: 관찰 근거 설명, 조건 성공·실패 원인, 다음 계획 변경.
- `CHANGE`: 실측으로 자원 포화·조건 가격 오류가 확인된 항목만 별도 Decision으로 변경.
- `REMOVE`: 행동 해결 중 추가 입력, 숨은 정보 참조, 구형 권위의 현재 참조.
- `DEFER`: 온라인 경쟁·최종 모바일·후보15명 전체 제작.
- `RETEST`: 고능력치 계획 구제, 기술1/2 대체율, 등급 파밍, 자원 회복 낭비.

## 15. 중단·축소 조건

- 성장·노드 선택이 피해 증가만 만든다.
- 조사·관찰 없이 정답 추측에 의존한다.
- 연격·장풍·특정 능력치가 다른 선택을 지배한다.
- 기술2가 기술1을 전 상황에서 대체한다.
- 조건 난도가 실제 성공률·실패 지점과 무관하게 부풀려진다.
- 같은 행동이 스스로 만든 조건으로 가격 감소를 받는다.
- 조건 실패 시 부분 지급·이월·대체·전환이 발생한다.
- 묶음 회복이 자원 상한을 반복 포화시켜 비용 선택을 무력화한다.
- 높은 능력치가 잘못된 계획을 반복 구제한다.
- 관찰이 기술명·정확한 피해·방향 등 정답 정보를 공개한다.
- 최신 계획 미구현 런타임을 완료 상태로 홍보한다.

위 조건이 확인되면 콘텐츠 확장보다 원인 분리·재검토를 우선한다.
