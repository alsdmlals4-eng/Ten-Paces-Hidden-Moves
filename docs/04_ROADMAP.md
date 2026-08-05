# 십보강호 구현 로드맵과 검증 기준

> 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`  
> 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 전투 규칙: `docs/02_COMBAT_RULES.md`  
> 병합 후 감사: `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`

## 1. 현재 단계

```yaml
merged_planning_checkpoint: bbed0fd4d278ca0e0d52f4e6d9083aafa1997318
merged_pr_lineage: 84,86,87,88
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: 92
active_planning_parent_pr: 91
active_approval_count: 8/10
active_decision_state: APPROVED_DRAFT_OBSERVATION_ANSWER_LEAK_GUARDRAILS
phase: VERTICAL_SLICE_APP_FLOW_PLANNING
project_core: CORE_CONFIRMED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
base_release: 9.4.3
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: GRADE_FARMING_RISK
t1_greenlight: NOT_GRANTED
```

PR #89는 자원 포화 완화 Draft, PR #91은 그 위의 조건 난도 보정·작업 운영 정책 Draft, PR #92는 그 위의 파생 스탯·오판 구제 Draft다. PR #92는 PR #91보다 먼저, PR #91은 PR #89보다 먼저 독립 병합하지 않는다. PR #90은 `[대체됨]`, PR #85는 `[보류]`다.

## 2. 프로젝트 코어 확정

> 공개된 객관 정보와 관찰로 잠긴 상대 계획을 추론하고, `3수 → 3수 → 4수` 비공개 계획으로 거리·순서·합·방어·회피·중단을 파훼한 뒤 복기에서 원인을 이해하고 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

확정 기준:

- [x] AI 비치팅 금지와 적 계획 선잠금.
- [x] 10칸·3/3/4·전조·중단·순차 해결.
- [x] 기초 행동10종과 핵심 스테이터스5종.
- [x] 이동·사거리15틱, 1/2/3수 예산20/50/80틱.
- [x] 기술1 조건부 저점/고점·5성 무료20%·연격 총피해 선계산.
- [x] 묶음 회복 기력1·내력0·절초기세1.
- [x] 조건 난도 여섯 구간·유효 시도·수동 재분류 Gate.
- [x] 파생 체력·기력·내력 공식과 결과 역전·중대 구제 분리.
- [x] 관찰 행동1수·관찰량1·앞 슬롯 직접 공개 유지와 공정성·측정 가드레일.
- [x] 승인 배치10·조기 체크포인트·모든 작업 TDD·현업 벤치마킹.

기획 승인은 런타임 구현이나 사람 검증 완료를 뜻하지 않는다.

## 3. 핵심 위험 순서

| 위험 | 상태 | 다음 조치 |
|---|---|---|
| `RESOURCE_SATURATION_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 회복 세금·고갈 측정 |
| `CONDITION_CALIBRATION_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 성공률·구간 이탈·체감 측정 |
| `WRONG_PLAN_RESCUE_RISK` | `MITIGATED_PENDING_HUMAN_MEASUREMENT` | 결과 역전률·중대 구제율·올바른 계획 증폭률 |
| `OBSERVATION_ANSWER_LEAK_RISK` | `ACCEPTED_PENDING_HUMAN_MEASUREMENT` | 직접 공개 유지·사람 측정 |
| `GRADE_FARMING_RISK` | 미확정 | 정규화·상한·반복 감쇠 |
| `RUNTIME_AUTHORITY_GAP` | P0 | Build 승인 뒤 구현 |

## 4. 현재 작업 순서

```text
전투 종료 등급 파밍 위험
→ STAR9_PUBLIC_READ_BRANCH_TEMPLATE
→ 여섯 개별 9성 자동 분기
→ 여섯 10성 고유 절초
→ 비스탯 노드 기대가치·가중치
→ 전체 핵심 재미·정본 적대적 검토
→ [기획 완료]
→ 이미지·애니메이션·HX 승인
→ [이미지 완료]
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex BUILD
```

개별 9성은 공통 템플릿 전에 작성하지 않는다.

## 5. 남은 기획 Gate

- [x] 자원 포화 위험 계약.
- [x] 조건 난도 보정 계약.
- [x] 잘못된 계획 구제·파생 스탯 계약.
- [x] 관찰 정답 유출 가드레일·측정 계약.
- [ ] 등급 파밍 방지 계약.
- [ ] 9성 공통 템플릿과 여섯 분기.
- [ ] 10성 절초와 비스탯 노드.

9성 필수 필드:

- 공개 trigger와 유효 시도 정의.
- 성공 사건·실패 지점·상대 대응.
- all-or-nothing 범위·고점·저점.
- 측정 지표·재분류 Gate.

## 6. 구현 전 Combat Build Gate

- 최신 Decision·approved contract·amendment 일치.
- 조건 실패 전부0, 연격 분배, 고정 이동, 추가 입력 금지 회귀 테스트.
- 자원 포화·조건 성공률·오판 구제 위험 측정 계획.
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
- 성공 고점 만족도·실패 저점 수용도 기록.
- 내력0 묶음률·회복 행동 선택률 기록.
- 잘못된 계획의 결과 역전률·중대 구제율·올바른 계획 증폭률 기록.

현재 `human_validation: NOT_RUN`이다.

## 11. T1 — 최소 세로 슬라이스

T1 진입에는 기획·검토·이미지 완료, Godot·Windows·접근성·성능 검증, 신규 플레이어5명 STEP14가 필요하다. 현재 `t1_greenlight: NOT_GRANTED`다.

## 12. 온라인 경쟁 Gate

등록 스냅샷, 버전 호환, 관찰 대칭성, 평점·반복 대전·어뷰징 방지, 보안·네트워크, 사람 경쟁 테스트가 필요하다.

## 13. 정본 생명주기 운영

- `[현행]`: 후속 기획·구현 인계.
- `[대체됨]`: 역사·migration·회귀만.
- `[보류]`: 명시적 재개 전 병합 금지.
- `[폐기]`: 현재·역사 가치가 모두 없을 때만.

병합 뒤 Active Context·Roadmap·Sheet를 같은 Decision ID로 즉시 갱신한다.

## 14. 전체 적대적 검토 분류

각 항목은 `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`로 기록한다.

- `KEEP`: AI 비치팅 금지, 10칸·3/3/4, 전조·중단, 복기.
- `AMPLIFY`: 조건 성공·실패 원인과 다음 계획 변경.
- `CHANGE`: 실측으로 확인된 수치만 별도 Decision으로 변경.
- `REMOVE`: 해결 중 추가 입력·숨은 정보 참조·구형 권위 사용.
- `DEFER`: 온라인·최종 모바일·후보 전체 제작.
- `RETEST`: 오판 구제·기술 대체율·등급 파밍·자원 회복.

## 15. 중단·축소 조건

- 관찰 없이 정답 추측에 의존.
- 특정 능력치·기술이 다른 선택을 지배.
- 조건 실패 시 부분 보상 발생.
- 묶음 회복이 비용 선택을 무력화.
- 높은 능력치가 잘못된 계획을 반복 구제.
- 관찰이 정답 정보를 공개.
- 최신 계획 미구현 런타임을 완료로 홍보.

위 조건이 확인되면 콘텐츠 확장보다 원인 분리·재검토를 우선한다.
