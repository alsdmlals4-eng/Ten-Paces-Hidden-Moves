# 십보강호 구현 로드맵과 검증 기준

> 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`
> 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`
> 플랫폼 Decision: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`
> 플랫폼 Adapter Decision: `TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`
> 성장 Decision: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`
> 런타임 기반 Decision: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`
> UI·AI 채택 Decision: `TEN_MANUAL_UI_AI_ADOPTION_GATE`
> 자동 제품 검증 Decision: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`

## 1. 현재 단계

```yaml
merged_planning_checkpoint: 7d20c2c9d5d1c92b80d32dc9bf25bd833a48ad58
merged_pr_lineage: 84,86,87,88,89,91,92,100,101
product_implementation_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90
merged_product_pr: 92
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: REVIEW
active_planning_pr: 102
active_planning_parent_pr: NONE
active_approval_count: 1/10
active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED
phase: VERTICAL_SLICE_APP_FLOW_PLANNING
project_core: CORE_CONFIRMED
platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01
platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01
design_platforms: WINDOWS_ANDROID
platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS
windows_validation: CI_EXPORT_RUNTIME_PASS_LOCAL_NOT_RUN
android_validation: NOT_RUN
base_release: 9.4.3
next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION
next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
t1_greenlight: NOT_GRANTED
```

PR #89·#91·#92 제품 계보와 PR #101 post-merge 플랫폼 정본은 main에 병합됐다. 제품 구현 병합 Commit은 `a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90`이며, PR #90은 `[대체됨]`, PR #85는 `[보류]`다.

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
- [x] PR #92 main 병합과 보호 경로 승인 Gate.

UI·AI 채택과 자동 제품 검증은 완료됐지만 로컬 Windows 렌더·실물 입력·접근성 사용자·Release 성능·사람·실제 Android·밸런스 승인은 완료되지 않았다.

## 3. 핵심 재미·시스템 정렬

핵심 재미:

```text
공개 상태·반복 습관 읽기
→ 잠긴 상대 묶음 추론
→ 비공개 3/3/4 계획 확정
→ 거리·순서·합·대응·중단 해결
→ 결정적 원인 복기
→ 다음 계획 변경
```

핵심 시스템은 관찰·선잠금, 비공개 행동 묶음, 결정적 전투 해결, 복기·적응이다. 무공·성취도·자원·등급·보상·loadout·앱 흐름·플랫폼 adapter는 보조 시스템이며 다음 조건을 지킨다.

- 정답을 직접 제시하지 않는다.
- 잘못된 계획을 수치로 자동 구제하지 않는다.
- 성장으로 추론·거리·순서·중단 Gate를 우회하지 않는다.
- 불투명한 적 loadout이나 숨은 AI 정보로 공정성을 훼손하지 않는다.
- 메타 성장과 콘텐츠 제작량이 복기·적응보다 중심이 되지 않는다.

## 4. 현재 작업

완료된 제품 배치는 `10/10`이며 PR #92로 main에 병합됐다.

```text
TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE — 완료·병합
→ manifest + 무공서별 10개 데이터
→ MartialManualRegistry
→ MartialEffectPipeline
→ TenManualCombatResolutionEngine 기반

TEN_MANUAL_UI_AI_ADOPTION_GATE — 완료·병합
→ ActionSelectionDock loadout·성취도 연결
→ 3/5/7/9/10성 잠금·overlay·절초 표시
→ 공개 상태 AI 적 loadout 후보 연결
→ bundle effect pipeline 실행
→ 준비·자동 배치 계보 보존

TEN_MANUAL_PRODUCT_VALIDATION_GATE — 자동 증거 완료·병합
→ Windows CI export·runtime
→ 50개 제품 시나리오
→ 세 해상도·합성 입력·자동 접근성
→ 성능 baseline
```

### 자동 제품 검증 권위

- [x] 10권 × 3·5·7·9·10성 = 50개 제품 시나리오.
- [x] Windows x86_64 Release export.
- [x] export된 실행 파일 Windows CI runtime.
- [x] 1280×800·1440×900·1920×1080.
- [x] 키보드·마우스 합성 입력과 포커스·레이아웃 자동 접근성.
- [x] 성능 baseline 캡처.
- [x] SHA·artifact·사람 상태 과장 validator.
- [ ] 로컬 Windows 렌더와 실물 입력.
- [ ] 실제 Android export·설치·실기기·터치·앱 생명주기.
- [ ] 접근성 사용자 검증.
- [ ] Release 성능 검증.
- [ ] STEP 14 신규 플레이어 5명.

증거: `0a8bf577b936ddac5cb7130a0cc58e519ea6eff6` / workflow `31074079068` / artifact `8956790279`. 현재 판정은 `PARTIAL_AUTOMATED_COMPLETE`다.

## 5. Windows·Android 기본 대상

`TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`에 따라 두 플랫폼을 기본 설계 대상으로 유지한다.

공유 단일 코어:

- 전투 규칙·AI·콘텐츠·ID·수치·seed.
- 저장 Schema·버전·마이그레이션 의미.
- 결과·복기·보상·진행 도메인 규칙.

분리 adapter:

- 장치 중립 입력 의도와 키보드·마우스·게임패드·터치 변환.
- 반응형 UI·안전영역·밀도·포커스·터치 표적.
- 뒤로가기·pause/resume·background/foreground·suspend/restore.
- 스토어·업적·클라우드·권한 같은 선택적 플랫폼 서비스.
- export·그래픽 품질·메모리·프레임·발열·배터리 예산.

동일 규칙·데이터·저장 의미는 필수지만 픽셀 동일 UI와 동시 출시는 필수가 아니다. 실제 Android 증거가 없으므로 `android_validation: NOT_RUN`이다.

### Adapter Architecture 계약 승인

`TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`에서 다음을 고정했다.

- 전투·AI·콘텐츠 ID·수치·저장 Schema·결정적 해결은 단일 공유 코어.
- device-neutral logical command와 InputMap 소비 경계.
- compact `≤899`, standard `≤1439`, wide `≥1440` logical px.
- 핵심 touch target `48dp`, landscape primary, safe area·cutout·Android back 처리.
- 묶음 commit/resolve·노드 선택·결과 진입 checkpoint와 atomic save·backup·migration.
- Compatibility renderer 공통 기준선과 Windows EXE+PCK / Android AAB·APK export 경계.
- 실제 Android·로컬 Windows·실물 gamepad·사용자 접근성·Release 성능은 `NOT_RUN`.

다음 작업:

```text
WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
→ LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE
→ TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE
→ TEN_MANUAL_BALANCE_MEASUREMENT_GATE
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

## 6. 제품 연결 범위

현재 보장:

- 정확한 10권 roster와 문파·주/보조능력치 조합.
- 3·5·7·9·10성 해금과 overlay 합성.
- 플레이어 명시적 loadout의 무공·절초 UI 표시.
- 적 명시적 loadout의 해금 카드만 공개 상태 AI 후보로 사용.
- 상태 선행·이동·사거리 재검사·독립 다단·조건부 후속의 실제 묶음 실행.
- 자하신공 사용권·나한금강공 강건·회마창 사거리 재검사·능파미보 이동 전 반격·만천화우 독립 4회.
- 기존 기본 행동·공용 절초·준비·자동 배치 동작 보존.

현재 범위 밖:

- 최종 loadout 획득·교체 경제.
- 적별 최종 무공 배치와 난이도 곡선.
- 최종 피해 계수·자원 비용 승인.
- 최종 연출·아트·음향.
- 로컬 Windows·실제 Android·접근성 사용자·Release 성능·사람·밸런스 검증.

## 7. 핵심 위험 순서

| 위험 | 상태 | 다음 조치 |
|---|---|---|
| `RUNTIME_AUTHORITY_GAP` | `MITIGATED_UI_AI_ADOPTED` | 로컬·실기기 검증 |
| `ANDROID_ADAPTER_GAP` | `PLANNING_APPROVED_IMPLEMENTATION_NOT_RUN` | adapter 계약·실기기 Gate |
| `AI_LOADOUT_FAIRNESS_RISK` | `MITIGATED_PUBLIC_STATE_ONLY` | 적별 사람 측정 |
| `MASTERY_ROLE_REPLACEMENT_RISK` | `PENDING_HUMAN_MEASUREMENT` | 기술1/2 선택률·대체율 |
| `RESOURCE_SATURATION_RISK` | `PENDING_HUMAN_MEASUREMENT` | 회복 세금·고갈 |
| `CONDITION_CALIBRATION_RISK` | `PENDING_HUMAN_MEASUREMENT` | 성공률·조건 체감 |
| `WRONG_PLAN_RESCUE_RISK` | `PENDING_HUMAN_MEASUREMENT` | 결과 역전·구제율 |
| `OBSERVATION_ANSWER_LEAK_RISK` | `PENDING_HUMAN_MEASUREMENT` | 직접 공개 유지 측정 |
| `GRADE_FARMING_RISK` | `PENDING_HUMAN_MEASUREMENT` | 원시/유효 등급 비율 |

## 8. 공통 검증 게이트

```text
계약·Schema
→ RED 회귀 테스트
→ GREEN 최소 구현
→ REFACTOR
→ exact-head CI
→ Godot headless
→ Windows runtime·render
→ Android export·device·lifecycle
→ 접근성·성능
→ 사람 플레이
→ 정본·Sheet 동기화
```

실행하지 않은 검증은 `NOT_RUN`으로 남긴다.

## 9. STEP 14

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

## 10. T1 — 최소 세로 슬라이스

T1 진입에는 기획·검토·이미지 완료, 로컬 Windows·실제 Android·접근성·성능 검증, 신규 플레이어 5명 STEP 14가 필요하다. 현재 `t1_greenlight: NOT_GRANTED`다.

## 11. 중단·축소 조건

- 10권 UI·AI 채택이 기존 기본 행동·준비·자동 배치 회귀를 깨뜨림.
- 무공 카드가 명시적 loadout 없이 기본 엔진에 침투함.
- 적 AI가 플레이어 비공개 계획이나 플레이어 전용 loadout을 참조함.
- UI에 선택 가능하지만 실제 `effect_steps`가 실행되지 않음.
- 9성이 기술2에 둘 이상의 효과·분기·추가입력을 만듦.
- 이동 뒤 종속 공격이 사거리 재검사를 우회함.
- 자하신공이 중단 뒤 사용권을 환불하거나 미완료 상태에서 기세를 지급함.
- `[강건]`이 무적·절대 중단 면역으로 확장됨.
- 능력치별 권수 분포를 맞추기 위해 문파 적합성을 왜곡함.
- Windows와 Android가 서로 다른 전투 규칙·데이터·저장 의미를 가짐.
- 실제 기기·사람 검증 없이 Android·최종 밸런스·T1 완료를 주장함.

발생 시 관련 범위를 호환 adapter 수준으로 축소하고 별도 Decision 전까지 확장하지 않는다.

## 12. 역사적 회귀 호환 표식

다음 문자열은 PR #92 병합 전 회귀의 발견용 표식일 뿐 현행 상태가 아니다.

- `active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED`.
- `next_planning_decision: TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE`.

현행 값은 상단 YAML의 `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED`와 `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`다. 제품 병합 권위는 `merged_product_pr: 92`와 제품 구현 병합 Commit으로 별도 보존한다.

## 13. 정본 생명주기

각 항목은 `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`로 분류한다.

- `KEEP`: AI 비치팅 금지, 10칸·3/3/4, 전조·중단, 복기, 원시 로그, stat-fit-only, 단일 공유 코어.
- `AMPLIFY`: 무공별 역할·성취도·실패 원인 설명, 플랫폼별 정보·조작 동등성.
- `CHANGE`: 사람·실기기 측정으로 확인된 수치·적 loadout·UI 밀도·품질 프로필만 별도 Decision으로 변경.
- `REMOVE`: 추가 입력, 숨은 계획 접근, 자동 합 승리, 능력치 쿼터, 플랫폼별 도메인 규칙 복제.
- `DEFER`: 최종 loadout 경제, 최종 연출, 비스탯 노드 경제, 온라인·크로스 세이브·과금.
- `RETEST`: 자원 포화·기술 대체·AI 공정성·관찰·등급 파밍·Android 생명주기·성능 위험.

병합 전후 Active Context·Roadmap·Lifecycle·Sheet는 같은 Decision ID와 exact SHA를 사용한다.
