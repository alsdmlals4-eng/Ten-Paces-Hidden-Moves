# 십보강호 활성 컨텍스트

> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`  
> 정본 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 관찰 권위: `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`  
> 초기 무공서 10권 성장 권위: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`  
> 초기 무공서 10권 런타임 기반: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`  
> 초기 무공서 UI·AI 채택 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`  
> 초기 무공서 자동 제품 검증 권위: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`  
> 빌드 승인: `docs/implementation/BUILD_APPROVAL_2026-08-06.md`

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
merged_planning_checkpoint: bbed0fd4d278ca0e0d52f4e6d9083aafa1997318
merged_pr_lineage: 84,86,87,88
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: BUILD
active_planning_pr: 92
active_planning_parent_pr: 91
active_approval_count: 10/10
active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED
primary_platform: PC
future_platform: MOBILE_CONSIDERATION_ONLY
engine: Godot 4.7
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
base_release_pinned: 9.4.3
runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_PR92
latest_combat_planning_runtime: PRODUCT_VALIDATION_AUTOMATED
runtime_ui_adoption: ADOPTED
runtime_ai_adoption: ADOPTED_PUBLIC_STATE_LOADOUT_ONLY
automated_validation: PASS
windows_validation: CI_EXPORT_RUNTIME_PASS_LOCAL_NOT_RUN
human_validation: NOT_RUN
balance_validation: NOT_RUN
accessibility_validation: AUTOMATED_PASS_USER_NOT_RUN
performance_validation: BASELINE_CAPTURED_RELEASE_NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE
```

현재 체크포인트는 `DRAFT_PR92_TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_10_OF_10`이다. PR #92는 PR #91 위에 쌓인 Draft이므로 PR #91보다 먼저 독립 병합·Draft 해제·종료하지 않는다. PR #91도 PR #89보다 먼저 독립 병합하지 않는다. PR #90은 `[대체됨]`, PR #85 HTML PoC는 `[보류]`다.

자동 제품 검증은 Windows CI export·runtime, 세 해상도, 합성 입력, 자동 접근성, 성능 baseline까지만 증명한다. 로컬 Windows 렌더·실물 입력·접근성 사용자·Release 성능·사람 플레이·밸런스 승인을 대신하지 않는다.

## 프로젝트 코어

공개 상태와 반복 습관을 읽고 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·순차 합·대응·중단으로 파훼하고, 복기로 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트다.

```text
객관 정보 조사·관찰
→ 잠긴 상대 묶음 추론
→ 비공개 계획 확정
→ 거리·순서·합·회피·방어·중단 해결
→ 원인 복기
→ 다음 계획 변경
```

보호 규칙:

- AI는 미확정 플레이어 계획을 참조하지 않는다.
- 적은 관찰 공개 전에 현재 묶음을 잠그고 공개 뒤 교체하지 않는다.
- 행동 묶음 확정 뒤 추가 플레이어 선택을 요구하지 않는다.
- 기술 이동은 고정 방향·합법 타일 폴백을 사용한다.
- 이동으로 거리가 바뀌면 종속 공격 전에 사거리를 다시 검사한다.
- 성장 수치는 잘못된 계획을 자동 구제하지 않는다.
- 스탯 보정은 합법성·거리·순서·중단·성공 Gate 뒤에만 적용한다.
- 9성은 기술2에 단일·무분기 효과 하나만 추가한다.
- 능력치별 무공서 권수·균등 분포·최소/최대 쿼터는 사용하지 않는다.
- 주·보조능력치는 문파·무학·동작·피해 방식 적합성으로만 결정한다.

## 관찰 권위

`TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`은 후속 무공·런타임·UI·AI Decision 뒤에도 유지된다.

관찰은 행동1수→관찰량1→적 선잠금 뒤 앞 슬롯 실제 행동 종류 직접 공개를 유지한다.

- 적은 공개 전에 현재 묶음을 잠근다.
- 공개 뒤 적 계획을 교체하지 않는다.
- 정답 카드·정확한 대응 추천·숨은 AI 가중치는 공개하지 않는다.
- 관찰 약화나 자동 비용 인상은 사람 측정과 별도 Decision 전까지 금지한다.

## 현재 제품 연결 권위

`TEN_MANUAL_UI_AI_ADOPTION_GATE` 승인에 따라 런타임 기반을 실제 전투 미리보기의 UI와 공개 상태 AI에 연결했다.

### 행동 선택 UI

- `ActionSelectionDock`은 `martial_loadout`과 `martial_mastery_by_manual`을 받는다.
- `MartialManualRegistry`가 무공 카드의 유일한 공급 원본이다.
- 무공 탭은 문파·무공서·주/보조능력치·현재 성취도·3성/7성 잠금을 표시한다.
- 5성은 기술1 overlay, 9성은 기술2 단일 overlay로 표시한다.
- 10성 절초는 기존 공용 절초와 함께 절초 탭에 표시한다.

### 공개 상태 AI

- 적 AI는 자기 명시적 loadout에서 현재 성취도로 해금된 카드만 후보로 평가한다.
- 공개 거리·자원·묶음 슬롯·비용·사거리만 사용한다.
- 플레이어 비공개 계획·미확정 배치·포인터는 참조하지 않는다.
- 적 loadout이 없으면 기존 공개 상태 AI 후보가 유지된다.

### 전투 해결

- `TenManualCombatResolutionEngine`은 준비 엔진을 상속한다.
- `[준비]`와 자동 배치 후처리를 보존한다.
- 선택된 무공은 실행 수에서 `MartialEffectPipeline`의 `effect_steps`를 실제 처리한다.
- 무공 피해도 현행 중단 규칙을 통과한다.
- 특수 합은 공개 상대 합 위력을 사용하며 자동 승리는 없다.

PoC 명시적 loadout은 `data/combat/ten_manual_loadout_poc.json`에 플레이어와 적을 분리해 기록한다. 이는 향후 세이브·성장 시스템으로 교체되는 임시 제품 미리보기 경계다.

## 초기 무공서 10권

| 문파·유파 | 무공서 | 주 / 보조 | 10성 절초 | 전투 방향 |
|---|---|---|---|---|
| 화산파 | 매화검결 | 신법 / 외공 | 이십사수매화검법 | 이동형 적중 연격 |
| 소림사 | 나한금강공 | 외공 / 내공 | 여래신장 | 강건·방어·근접 장격 |
| 무당파 | 태극검결 | 심안 / 내공 | 태극혜검 | 흘리기·합·반격 |
| 양가 | 양가창결 | 외공 / 신법 | 회마창 | 창끝 거리·재반격 |
| 화산파 | 자하심법 | 내공 / 근골 | 자하신공 | 자원 순환·위기 복귀 |
| 소요파 | 소요보결 | 신법 / 심안 | 능파미보 | 회피·반격·변위 |
| 개방 | 강룡장결 | 내공 / 근골 | 항룡십팔장 | 중후한 장력·정면 돌파 |
| 사천당문 | 천기암기록 | 심안 / 신법 | 만천화우 | 원거리 독립 다단 압박 |
| 하북팽가 | 팽가도결 | 근골 / 외공 | 오호단문도 | 방어 파괴·결착 |
| 남궁세가 | 창궁무애검법 | 내공 / 심안 | 제왕검형 | 준비형 검압·합 결착 |

성장 구조는 `3성 기술1 → 5성 기술1 추가 효과 → 7성 기술2 → 9성 기술2 단일 완성 효과 → 10성 대표 절초`다.

## 특수 불변조건

### 자하신공

- 전투당 1회 사용권을 프로그램 시작 시 소모한다.
- 중단·전투불능에도 사용권을 환불하지 않는다.
- 전체 프로그램 완료 시에만 절초기세 +1을 지급한다.

### 나한금강공

- 방어와 `[강건]`을 공격 전에 생성한다.
- `[강건]`은 현행 중단 1회 방지 범위만 사용한다.
- 무적·피해 무시·절대 중단 면역은 없다.

### 회마창·능파미보·만천화우

- 회마창: 공격 → 후퇴 → 사거리 재검사 → 두 번째 공격.
- 능파미보: 회피 성공 → 이동 전 반격 → 후퇴 → 준비 상태.
- 만천화우: 무작위 타수가 아니라 독립 공격 4회를 결정적으로 처리한다.

## 검증 상태

RED 증거:

- runtime manifest·레지스트리·pipeline 부재: workflow `31049328495`.
- combat adapter 부재: workflow `31050666862`.
- UI·AI loadout 분리와 bundle pipeline 연결 부재: workflow `31053963064`.
- 최종 제품 Artifact 재실행 뒤 정본이 이전 SHA·run·artifact·성능값을 유지한 회귀: workflow `31076828345`의 `product-gate-contract` 실패.

GREEN 범위:

- Godot 4.7.1 무공 UI·AI 채택 검증.
- 기존 ActionSelectionDock과 공개 상태 AI 회귀.
- 10권 manifest·숙련 레지스트리·effect pipeline 검증.
- PR Validation과 Full Validation.
- 기존 전투·관찰·등급·숙련·예산·Base 회귀.

사람·밸런스·로컬 Windows 렌더·실물 게임패드·접근성 사용자·Release 성능 검증은 `NOT_RUN`이다.

## 자동 제품 검증 권위

`TEN_MANUAL_PRODUCT_VALIDATION_GATE`은 UI·AI 채택 부모 권위 위에서 자동 제품 증거만 승인한다.

```yaml
product_gate: PARTIAL_AUTOMATED_COMPLETE
evidence_source_head: 0a8bf577b936ddac5cb7130a0cc58e519ea6eff6
workflow_run_id: 31074079068
windows_artifact_id: 8956790279
windows_export: PASS
windows_ci_runtime: PASS
scenario_matrix: 50/50 PASS
resolution_matrix: 1280x800,1440x900,1920x1080 PASS
keyboard_synthetic: PASS
mouse_synthetic: PASS
accessibility_automated: PASS
performance_baseline: CAPTURED
windows_local_render: NOT_RUN
gamepad_physical: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
human_step14: NOT_RUN
balance_validation: NOT_RUN
```

Windows CI 기준 runtime은 약 2344.67ms, peak working set은 188571648 bytes, exe+pck는 123037256 bytes였다. runner 또는 Godot 버전이 바뀌면 직접 baseline 비교를 금지한다.

Google Sheet 정본 탭 `03_무공서_무학`은 최종 exact head 검증 뒤 같은 Decision/SHA로 갱신한다.

## 현재 위험과 다음 순서

| 위험 | 상태 | 다음 조치 |
|---|---|---|
| `RUNTIME_AUTHORITY_GAP` | `MITIGATED_UI_AI_ADOPTED` | 사람·플랫폼 검증 |
| `AI_LOADOUT_FAIRNESS_RISK` | `MITIGATED_PUBLIC_STATE_ONLY` | 적별 loadout 사람 측정 |
| `MASTERY_ROLE_REPLACEMENT_RISK` | `PENDING_HUMAN_MEASUREMENT` | 기술1/2 선택률·대체율 측정 |
| `RESOURCE_SATURATION_RISK` | `PENDING_HUMAN_MEASUREMENT` | 회복 세금·고갈 측정 |
| `OBSERVATION_ANSWER_LEAK_RISK` | `PENDING_HUMAN_MEASUREMENT` | 직접 공개 유지·사람 측정 |
| `GRADE_FARMING_RISK` | `PENDING_HUMAN_MEASUREMENT` | 원시/유효 등급 비율 측정 |

```text
TEN_MANUAL_PRODUCT_VALIDATION_GATE
→ Godot Windows 실제 실행
→ 접근성·성능 검증
→ STEP 14 신규 플레이어 5명
→ 기술 대체율·자원 포화·적 loadout 공정성·다단 가독성 측정
→ 최종 밸런스 Decision
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

## 선행 UX·앱 흐름 권위

현재 UI·AI 채택은 다음 선행 권위를 대체하지 않고 계보로 보존한다.

- `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`
- `TEN-DEC-20260801-SITUATION-SCREEN-01`
- 역사 구현 표식: `runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65`
- V6 원장: `2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`

위 표식은 PR #65 앱 흐름 기반의 역사·호환 근거이며 현재 구현 권위는 상단 YAML의 `TEN_MANUAL_UI_AI_ADOPTION_PR92`다.

## 역사적 기준 표식

`PR #7`, `Issue #13`, `CORE_REVIEW_PENDING`은 초기 프로젝트 코어 검토 이력을 찾기 위한 reference-freshness 표식이며 현재 작업 상태가 아니다. 현재 코어는 승인됐고, 현행 상태는 위 YAML과 Decision 원장을 따른다.

## 정본 동기화 원칙

주요 승인과 구현 상태는 GitHub 권위 문서와 연결된 Google Sheet에 같은 Decision ID와 exact SHA로 기록한다. `03_무공서_무학` 탭에는 10권의 문파·무학 방향·주/보조능력치·3/5/7/9/10성 성취도를 한 행씩 유지한다. 현재 PR #92는 Draft·stacked 상태이며 병합 권한은 별도 사용자 승인에 속한다.
