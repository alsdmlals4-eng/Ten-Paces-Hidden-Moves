# 십보강호 구현 로드맵과 검증 기준

> 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`  
> 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 전투 규칙: `docs/02_COMBAT_RULES.md`  
> 초기 무공서 10권 성장: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`  
> 7성·9성 예산 부모: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`

## 1. 현재 단계

```yaml
merged_planning_checkpoint: bbed0fd4d278ca0e0d52f4e6d9083aafa1997318
merged_pr_lineage: 84,86,87,88
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: 92
active_planning_parent_pr: 91
active_approval_count: 9/10
active_decision_state: APPROVED_DRAFT_TEN_RECOGNIZABLE_MARTIAL_MANUALS
phase: VERTICAL_SLICE_APP_FLOW_PLANNING
project_core: CORE_CONFIRMED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
base_release: 9.4.3
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE
t1_greenlight: NOT_GRANTED
```

PR #89는 자원 포화 완화 Draft, PR #91은 그 위의 조건 난도 보정·작업 운영 정책 Draft, PR #92는 그 위의 파생 스탯·오판 구제·관찰·등급 파밍 방지·7/9성 숙련 예산 Draft다. PR #92는 PR #91보다 먼저, PR #91은 PR #89보다 먼저 독립 병합하지 않는다. PR #90은 `[대체됨]`, PR #85는 `[보류]`다.

## 2. 프로젝트 코어 확정

> 공개된 객관 정보와 관찰로 잠긴 상대 계획을 추론하고, `3수 → 3수 → 4수` 비공개 계획으로 거리·순서·합·방어·회피·중단을 파훼한 뒤 복기에서 원인을 이해하고 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

확정 기준:

- [x] AI 비치팅 금지와 적 계획 선잠금.
- [x] 10칸·3/3/4·전조·중단·순차 해결.
- [x] 기초 행동10종과 핵심 스테이터스5종.
- [x] 이동·사거리15틱, 1/2/3수 예산20/50/80틱.
- [x] 기술1 조건부 저점/고점·5성 무료20%·연격 총피해 선계산.
- [x] 7성 기술2 `+10틱` 숙련 예산.
- [x] 9성 `10 + floor(7성 최종 예산×20%)` 단일 완성 보너스 템플릿.
- [x] 가치 상위호환·역할 비대체와 분기·추가입력·추가비용 금지.
- [x] 묶음 회복 기력1·내력0·절초기세1.
- [x] 조건 난도 여섯 구간·유효 시도·수동 재분류 Gate.
- [x] 파생 체력·기력·내력 공식과 결과 역전·중대 구제 분리.
- [x] 관찰 행동1수·관찰량1·앞 슬롯 직접 공개 유지와 공정성·측정 가드레일.
- [x] 원시 등급 사건 보존·동일 행동 감쇠·행동 인스턴스 상한·기준 라운드·경제 미연결.
- [x] 승인 배치10·조기 체크포인트·모든 작업 TDD·현업 벤치마킹.
- [x] 한국·중국 무협 인지도 기반 초기 무공서 10권과 문파 표시.
- [x] 주·보조능력치 권수 쿼터 폐기와 무공별 적합성 근거.
- [x] 10권의 3/5/7/9/10성 성장·절초·해결 순서·계획 예산.

기획 승인은 런타임 구현이나 사람 검증 완료를 뜻하지 않는다.

## 3. 핵심 위험 순서

| 위험 | 상태 | 다음 조치 |
|---|---|---|
| `RESOURCE_SATURATION_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 회복 세금·고갈 측정 |
| `CONDITION_CALIBRATION_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 성공률·구간 이탈·체감 측정 |
| `WRONG_PLAN_RESCUE_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 결과 역전률·중대 구제율·올바른 계획 증폭률 |
| `OBSERVATION_ANSWER_LEAK_RISK` | `ACCEPTED_PENDING_HUMAN_MEASUREMENT` | 직접 공개 유지·사람 측정 |
| `GRADE_FARMING_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 원시/유효 비율·반복 대응·기준 라운드·경제 미연결 측정 |
| `MASTERY_ROLE_REPLACEMENT_RISK` | `ACCEPTED_PENDING_HUMAN_MEASUREMENT` | 기술1/2 대체율·9성 이해도 측정 |
| `RUNTIME_AUTHORITY_GAP` | P0 | Build 승인 뒤 구현 |

## 4. 현재 작업 순서

```text
TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE
→ RED 런타임 계약·회귀 검사
→ 10권 Godot 데이터·카드·해결기 구현
→ 사람·밸런스·가독성 검증
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

현재 배치는 9/10이다. 초기 10권의 기획·예산은 승인됐지만 제품 런타임은 아직 변경하지 않는다.

## 5. 남은 기획 Gate

- [x] 자원 포화 위험 계약.
- [x] 조건 난도 보정 계약.
- [x] 잘못된 계획 구제·파생 스탯 계약.
- [x] 관찰 정답 유출 가드레일·측정 계약.
- [x] 등급 파밍 방지 계약.
- [x] 7성·9성 공통 숙련 예산과 9성 단일 효과 템플릿.
- [x] 초기 10권 7성 기술2 효과와 통합 예산.
- [x] 초기 10권 9성 단일 완성 효과.
- [x] 초기 10권 10성 절초·해결 순서·계획 예산.
- [ ] 10권 런타임 구현 Gate.
- [ ] 비스탯 노드 기대값과 가중치.

7성 개별 배분 필수 필드:

- 현행 기술2 기준 예산과 +10틱 배분 내역.
- 무공 정체성 연결.
- 기술1과 다른 사용 시점·전술 역할.
- 기술1/2 대체율 측정.
- 실패 규칙과 상대 대응 유지.

9성 개별 효과 필수 필드:

- 단일 효과 한 문장.
- 사용 가능한 추가 예산.
- 분기·추가입력·추가비용·복수 효과 없음.
- 기술2 핵심 역할 유지.
- 기술1 역할 복제 금지.
- 자동 정답·규칙 우회 금지.

## 6. 구현 전 Combat Build Gate

- 최신 Decision·approved contract·amendment 일치.
- 조건 실패 전부0, 연격 분배, 고정 이동, 추가 입력 금지 회귀 테스트.
- 10권 의미 계약·예산 overlay·역사 alias 적용과 런타임 구현 Gate 확인.
- 자원 포화·조건 성공률·오판 구제·관찰·등급 파밍·기술 대체 위험 측정 계획.
- 등급 원시 사건과 유효 반영량 분리 및 사람 검증 전 경제 연결 금지.
- 스탯 파생 공식과 구형 통합 공격력 이중 적용 금지.
- canonical ID와 역사 alias migration.
- 별도 사용자 Build 승인.

현재 제품 런타임은 `IMPLEMENTED_LEGACY`다.

## 7. 콘텐츠 제작 순서

```text
대표 후보1명으로 흐름 증명
→ 두 번째 후보·노드 반복 제작
→ 제작 시간·재사용·사람 검증
→ 검증된 슬롯부터 후보3명 확장
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
```

## 9. 공통 검증 게이트

```text
계약·Schema
→ RED 회귀 테스트
→ GREEN 최소 구현
→ REFACTOR
→ exact-head CI
→ Godot headless
→ Windows runtime·render
→ 접근성·성능
→ 사람 플레이
→ 정본·Sheet 동기화
```

실행하지 않은 검증은 `NOT_RUN`이다. `[대체됨]`·`[보류]` 자료는 현행 제품 권위에서 제외한다.

## 10. STEP 14

- 신규 플레이어5명.
- 4명 이상 데모 흐름 완료 또는 이탈 이유 기록.
- 4명 이상 3/3/4와 결정적 원인 설명.
- 조건별 전체 사용률·유효 시도 성공률·실패 지점 기록.
- 기술1/기술2 선택률·7성 후 기술1 대체율·9성 효과 이해율 기록.
- 내력0 묶음률·회복 행동 선택률 기록.
- 잘못된 계획의 결과 역전률·중대 구제율·올바른 계획 증폭률 기록.
- 등급 원시/유효 반영량 비율·같은 행동 반복 대응·기준 라운드 이후 사건 기록.
- 경제 연결 전 완료 승리30회·서로 다른 상대5종·단일 상대 표본40% 이하 충족.

현재 `human_validation: NOT_RUN`이다.

## 11. T1 — 최소 세로 슬라이스

T1 진입에는 기획·검토·이미지 완료, Godot·Windows·접근성·성능 검증, 신규 플레이어5명 STEP14가 필요하다. 현재 `t1_greenlight: NOT_GRANTED`다.

## 12. 온라인 경쟁 Gate

등록 스냅샷, 버전 호환, 관찰 대칭성, 평점·반복 대전·어뷰징 방지, 보안·네트워크, 사람 경쟁 테스트가 필요하다. 전투 종료 등급 감쇠는 온라인 시즌 평점에 자동 적용하지 않는다.

## 13. 정본 생명주기 운영

- `[현행]`: 후속 작성·구현 인계.
- `[대체됨]`: 역사·migration·회귀만.
- `[보류]`: 명시적 재개 전 병합 금지.
- `[폐기]`: 현재·역사 가치가 모두 없을 때만.

병합 뒤 Active Context·Roadmap·Sheet를 같은 Decision ID로 즉시 갱신한다.

## 14. 전체 적대적 검토 분류

각 항목은 `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`로 기록한다.

- `KEEP`: AI 비치팅 금지, 10칸·3/3/4, 전조·중단, 복기, 원시 전투 로그.
- `AMPLIFY`: 무공별 역할 차이, 기술 성공·실패 원인, 복기 설명.
- `CHANGE`: 실측으로 확인된 수치만 별도 Decision으로 변경.
- `REMOVE`: 해결 중 추가 입력·숨은 정보 참조·구형 권위·9성 분기·등급 경제 연결.
- `DEFER`: 온라인·최종 모바일·후보 전체 제작·최종 등급 가중치와 컷.
- `RETEST`: 오판 구제·기술 대체율·등급 파밍·자원 회복·숙련 보너스 체감.

## 15. 중단·축소 조건

- 관찰 없이 정답 추측에 의존.
- 특정 능력치·기술이 다른 선택을 지배.
- 7성 기술2가 기술1과 동일 역할로 전 상황에서 대체.
- 9성 효과가 분기·추가 입력·복수 효과로 복잡해짐.
- 숙련 보너스가 거리·순서·합·회피·중단 실패를 반복 구제.
- 조건 실패 시 부분 보상 발생.
- 묶음 회복이 비용 선택을 무력화.
- 관찰이 정답 정보를 공개.
- 같은 안전 행동 반복 또는 전투 지연이 등급 양의 반영량을 계속 생성.
- 사람 검증 전 등급이 재화·수련·드롭·영구재화에 영향.
- 최신 계획 미구현 런타임을 완료로 홍보.

위 조건이 확인되면 콘텐츠 확장보다 원인 분리·재검토를 우선한다.
