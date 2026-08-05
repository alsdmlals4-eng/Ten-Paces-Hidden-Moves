# 십보강호 구현 로드맵과 검증 기준

> 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`  
> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`  
> 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 성장 Decision: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`  
> 런타임 기반 Decision: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`  
> UI·AI 채택 Decision: `TEN_MANUAL_UI_AI_ADOPTION_GATE`

## 1. 현재 단계

```yaml
merged_planning_checkpoint: bbed0fd4d278ca0e0d52f4e6d9083aafa1997318
merged_pr_lineage: 84,86,87,88
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: BUILD
active_planning_pr: 92
active_planning_parent_pr: 91
active_approval_count: 10/10
active_decision_state: TEN_MANUAL_UI_AI_ADOPTED
phase: VERTICAL_SLICE_APP_FLOW_PLANNING
project_core: CORE_CONFIRMED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
base_release: 9.4.3
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: TEN_MANUAL_PRODUCT_VALIDATION_GATE
t1_greenlight: NOT_GRANTED
```

PR #92는 PR #91 위에 쌓인 Draft이며 독립 병합·Draft 해제 권한은 없다. PR #90은 `[대체됨]`, PR #85는 `[보류]`다.

## 2. 프로젝트 코어 확정

공개 상태와 관찰로 잠긴 상대 계획을 추론하고 `3수 → 3수 → 4수` 비공개 계획으로 거리·순서·합·방어·회피·중단을 파훼한 뒤, 복기에서 원인을 이해하고 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트다.

확정 기준:

- [x] AI 비치팅 금지와 적 계획 선잠금.
- [x] 10칸·3/3/4·전조·중단·순차 해결.
- [x] 기술1·5성·기술2·9성 단일 효과·10성 절초 구조.
- [x] 능력치 권수 쿼터 폐기와 문파·무학 적합성 우선.
- [x] 초기 무공서 10권 의미·예산 정본.
- [x] 10권 manifest와 분할 런타임 데이터.
- [x] 숙련 해금·overlay 레지스트리.
- [x] 순차 effect pipeline과 명시적 loadout 어댑터.
- [x] 행동 선택 UI의 loadout·성취도 채택.
- [x] 공개 상태 AI의 적 전용 loadout 후보 채택.
- [x] 묶음 해결 안에서 무공 effect program 실행.
- [x] 기존 준비·자동 배치·기본 행동·공용 절초 호환성.
- [x] RED→GREEN과 exact-head 자동 검증.

UI·AI 채택은 사람·밸런스·Windows·접근성·성능 승인 완료를 뜻하지 않는다.

## 3. 현재 작업

완료된 현재 배치는 `10/10`이다.

```text
TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE — 완료
→ manifest + 무공서별 10개 데이터 — 완료
→ MartialManualRegistry — 완료
→ MartialEffectPipeline — 완료
→ TenManualCombatResolutionEngine 기반 — 완료

TEN_MANUAL_UI_AI_ADOPTION_GATE — 완료
→ ActionSelectionDock loadout·성취도 연결 — 완료
→ 3/5/7/9/10성 잠금·overlay·절초 표시 — 완료
→ 공개 상태 AI 적 loadout 후보 연결 — 완료
→ bundle effect pipeline 실행 — 완료
→ 준비·자동 배치 계보 보존 — 완료
→ 전용 Godot 검증과 전체 회귀 — 완료
```

다음 작업:

```text
TEN_MANUAL_PRODUCT_VALIDATION_GATE
→ Godot Windows 실제 실행
→ 접근성·성능 검증
→ STEP 14 신규 플레이어 5명
→ 기술1/2 대체율·자원 포화·적 loadout 공정성·다단 가독성 측정
→ 최종 밸런스 Decision
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

## 4. 제품 연결 범위

현재 `UI_AI_ADOPTED`는 다음을 보장한다.

- 정확한 10권 roster와 문파·주/보조능력치 조합.
- 3·5·7·9·10성 해금과 overlay 합성.
- 플레이어 명시적 loadout의 무공·절초 UI 표시.
- 적 명시적 loadout의 해금 카드만 공개 상태 AI 후보로 사용.
- 상태 선행·이동·사거리 재검사·독립 다단·조건부 후속의 실제 묶음 실행.
- 자하신공 사용권 선소모·미환불·완료 시 기세 지급.
- 나한금강공의 제한된 `[강건]`과 방어 선행.
- 회마창의 공격→후퇴→사거리 재검사→공격.
- 능파미보의 이동 전 반격.
- 만천화우의 결정적 독립 공격 4회.
- 기존 기본 행동·공용 절초·준비·자동 배치 동작 보존.

현재 범위 밖:

- 최종 loadout 획득·교체 경제.
- 적별 최종 무공 배치와 난이도 곡선.
- 최종 피해 계수·자원 비용 승인.
- 최종 연출·아트·음향.
- 사람·Windows·접근성·성능 검증.

## 5. 핵심 위험 순서

| 위험 | 상태 | 다음 조치 |
|---|---|---|
| `RUNTIME_AUTHORITY_GAP` | `MITIGATED_UI_AI_ADOPTED` | 제품 검증 Gate |
| `AI_LOADOUT_FAIRNESS_RISK` | `MITIGATED_PUBLIC_STATE_ONLY` | 적별 사람 측정 |
| `MASTERY_ROLE_REPLACEMENT_RISK` | `PENDING_HUMAN_MEASUREMENT` | 기술1/2 선택률·대체율 |
| `RESOURCE_SATURATION_RISK` | `PENDING_HUMAN_MEASUREMENT` | 회복 세금·고갈 |
| `CONDITION_CALIBRATION_RISK` | `PENDING_HUMAN_MEASUREMENT` | 성공률·조건 체감 |
| `WRONG_PLAN_RESCUE_RISK` | `PENDING_HUMAN_MEASUREMENT` | 결과 역전·구제율 |
| `OBSERVATION_ANSWER_LEAK_RISK` | `PENDING_HUMAN_MEASUREMENT` | 직접 공개 유지 측정 |
| `GRADE_FARMING_RISK` | `PENDING_HUMAN_MEASUREMENT` | 원시/유효 등급 비율 |

## 6. 공통 검증 게이트

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

실행하지 않은 검증은 `NOT_RUN`으로 남긴다.

## 7. STEP 14

- 신규 플레이어 5명.
- 4명 이상 데모 흐름 완료 또는 이탈 이유 기록.
- 4명 이상 3/3/4와 결정적 원인 설명.
- 기술1/기술2 선택률·7성 후 기술1 대체율·9성 효과 이해율 기록.
- 문파·무공서와 주·보조능력치 적합성 체감 기록.
- UI의 성취도·잠금·절초 해금 이해도 기록.
- 적 loadout이 공정하고 읽을 수 있는지 기록.
- 자하신공 사용권·강건·회마창 사거리 실패 이해도 기록.
- 원시/유효 등급 사건과 자원 포화 측정.

현재 `human_validation: NOT_RUN`이다.

## 8. T1 — 최소 세로 슬라이스

T1 진입에는 기획·검토·이미지 완료, Godot·Windows·접근성·성능 검증, 신규 플레이어 5명 STEP 14가 필요하다. 현재 `t1_greenlight: NOT_GRANTED`다.

## 9. 중단·축소 조건

- 10권 UI·AI 채택이 기존 기본 행동·준비·자동 배치 회귀를 깨뜨림.
- 무공 카드가 명시적 loadout 없이 기본 엔진에 침투함.
- 적 AI가 플레이어 비공개 계획이나 플레이어 전용 loadout을 참조함.
- UI에 선택 가능하지만 실제 `effect_steps`가 실행되지 않음.
- 9성이 기술2에 둘 이상의 효과·분기·추가입력을 만듦.
- 이동 뒤 종속 공격이 사거리 재검사를 우회함.
- 자하신공이 중단 뒤 사용권을 환불하거나 미완료 상태에서 기세를 지급함.
- `[강건]`이 무적·절대 중단 면역으로 확장됨.
- 능력치별 권수 분포를 맞추기 위해 문파 적합성을 왜곡함.
- 사람 검증 없이 최종 밸런스나 T1 완료를 주장함.

발생 시 관련 범위를 호환 어댑터 수준으로 축소하고 별도 Decision 전까지 확장하지 않는다.

## 10. 정본 생명주기

각 항목은 `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`로 분류한다.

- `KEEP`: AI 비치팅 금지, 10칸·3/3/4, 전조·중단, 복기, 원시 로그, stat-fit-only 정책.
- `AMPLIFY`: 무공별 역할·성취도·실패 원인 설명.
- `CHANGE`: 사람 측정으로 확인된 수치와 적 loadout만 별도 Decision으로 변경.
- `REMOVE`: 추가 입력, 숨은 계획 접근, 자동 합 승리, 능력치 쿼터.
- `DEFER`: 최종 loadout 경제, 최종 연출, 비스탯 노드 경제.
- `RETEST`: 자원 포화·기술 대체·AI 공정성·관찰·등급 파밍 위험.

병합 전후 Active Context·Roadmap·Lifecycle·Sheet는 같은 Decision ID와 exact SHA를 사용한다.
