# 십보강호 구현 로드맵과 검증 기준

> 현재 상태 단독 책임 원본: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` + `docs/planning-data/current_operating_state.json` + `docs/planning-data/current_user_planning_status.json`  
> 전투 규칙 책임 원본: `docs/02_COMBAT_RULES.md`  
> 생명주기: `docs/CANON_LIFECYCLE_REGISTRY.md`  
> 사람용 Project Home·Flow·Visual: repository human-facing owners
> 현행 workspace 계약: `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01` (product safety baseline: r5.4)

이 문서는 **장기 로드맵·제품 증거 계보·다음 Gate의 순서**를 소유한다. 활성 PR, exact HEAD, 현재 Work Mode, 승인 수, 현재 stage, 다음 package/Decision 같은 mutable operating checkpoint는 복제하지 않는다. 작업 재개 시 Active Context/current JSON/GitHub live metadata/repository owners를 fresh-read한다.

## 전투 화면과 후속 전투 실행 교정 순서

동작 자산은 [상단 합과 결과별 반응](decisions/2026-09-09_CLASH_STAGING_AND_OUTCOME_DIRECTION.md)의 조사 → 핵심 자세 → 양쪽 결과 반응·회복 → 효과 off/on → 승인·엔진 연결 순서로 제작한다. 기존 게임 구현 증거와 새 모션 미검증 상태를 합치지 않는다.

`TEN-DEC-20260909-COMBAT-LAYOUT-CORRECTION-01`은 PR335에서 남은 실제 화면 배치 결함을 교정한다. 상태별 무대·캐릭터 렌더 경계·공유 바닥·현재 행동/효과 영역 → 실제 모션/긴 문구/native 캡처 → 전체 회귀와 보호 전달 순서다. 전투 규칙·저장·승인 원본 이미지 변경은 이 패키지 밖이다. 고유 무공 순차 실행과 기존 v1 여정 호환을 별도 계약으로 이어가고 성장·사건·정탐/상태·보상 공백을 다음에 다룬다. mutable 진행 상태는 위 current owners를 따른다.

## 1. 현재 단계 — 상태 읽기와 보존된 구현 계보

화면 교정 뒤에도 계획 관찰 설명과 장식의 간섭, 긴 한글의 자연스러운 줄바꿈, 합 순간의 인물 식별성, portrait 비율/불투명 발·그림자의 접지감과1080 계획 여백은 아틀라스 품질 후속의 실제 검토 항목이다. bounded geometry/native 통과만으로 삭제하지 않는다. 순차 전투·성장/사건/상태/보상 정합성을 우선 연결한 뒤 실제 consumer별로 교정하고 같은 장면의 재캡처로 확인한다.

현재 상태는 이 문서 안의 스냅샷으로 판정하지 않는다.

```yaml
current_state_owner: ACTIVE_CONTEXT_PLUS_CURRENT_JSON
current_human_workspace: REPOSITORY_HUMAN_FACING_CANON
current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME
google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL
platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01
platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01
design_platforms: WINDOWS_ANDROID
platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS
```

다음 값은 현재 상태가 아니라 **병합된 제품 구현·자동 검증 계보**다.

```yaml
product_implementation_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90
merged_product_pr: 92
product_validation_authority: TEN_MANUAL_PRODUCT_VALIDATION_GATE
product_validation_result: PARTIAL_AUTOMATED_COMPLETE
platform_adapter_merge_commit: 023385d372d127044d48afcb50e6f232ab9ffaa1
merged_platform_adapter_pr: 102
```

PR #92와 PR #102는 재현 가능한 병합 계보이며 현재 active PR이 아니다. 첫 5전 Vertical Slice Phase I–VI의 최신 구현 상태와 이후 제품 mutation 권한은 Active Context/current user planning status에서 읽는다. 기존 구현 완료를 향후 Android/UX/경제/저장/콘텐츠 변경의 자동 승인으로 재사용하지 않는다.

## 2. 프로젝트 코어 확정

병합된 저장·10전 완주 증거는 `docs/operations/2026-09-08_DURABLE_SAVE_EXECUTION_REPORT.md`에 보존한다. 새 표시·판정 작업으로 과거 검증 기록을 대체하지 않는다.

전투 피드백 교정 계보는 PR #335이며 `docs/operations/2026-09-09_COMBAT_FEEDBACK_EXECUTION_REPORT.md`와 해당 승인 보존 기록에서 검사·병합·실제 화면의 한계를 확인한다. 표시 교정은 공통 판정·기존 저장 호환과 전체 아틀라스 구현을 대신하지 않는다.

`TEN-DEC-20260908-DURABLE-RUN-CONTINUE-01`의 전달 순서는 strict 저장·전투 checkpoint → 실제 title/shell·생명주기 연결 → 격리된 새 프로세스 재개·10전 캠페인 → 저장 지연 교정 → `TEN-DEC-20260909-MARTIAL-ACTOR-BINDING-CORRECTION-01`의 각 전투원 성급·능력치 실행/복구 일치 → 독립 검수·보호 전달이다. 이 계보는 PR #333으로 main에 병합됐고 최초 공개 저장은 교정된 semantic identity를 사용한다. 전투 표시 교정은 `TEN-DEC-20260909-COMBAT-FEEDBACK-CORRECTION-01`이 소유한다. actor-owned 절초·실제 방어/실패·전조/실행과 승패 음향을 검증한 뒤, 고유 대응 무공과 공통 피해·방어 해결의 실제 누락을 별도 실행 계약으로 교정한다. 그 도메인 변경은 기존 공개 저장의 완주 호환을 함께 명세해야 하며 표시 수정에 숨겨 넣지 않는다. 이후 성장 지출·영구 능력치 지급·해금 조건·보유 무공 전투 확장과 `growth/events/status/reward` 공백을 다룬다. 도메인 진단 책임 기록은 `docs/reviews/2026-09-09_MARTIAL_DOMAIN_INTEGRATION_PREFLIGHT.md`, 현재 완료 상태와 남은 Gate는 Active Context/current JSON에서 읽는다. 자동 재개·분류 검증은 Human·Android·출시 또는 whole Blueprint complete 증거를 대체하지 않는다.

`TEN-DEC-20260908-BIMU-CONSTRAINT-RUNTIME-01` 비무 제약의 전달 순서는 승인 catalog → frozen duel receipt → 공유 engine 강제 →
native 선택·봉인 피드백 → 로컬 회귀/실제 캡처 → exact-head CI·보호 병합이다.
현재 결과와 남은 Gate는 `docs/operations/2026-09-08_BIMU_CONSTRAINT_RUNTIME_EXECUTION_REPORT.md`
및 current owner에서 읽는다. 전체 Blueprint 및 Human/Android 검수를 이 패키지로 닫지 않는다.

10전 연속 구현의 완료 Gate는 종료 결과를 넣는 상태 회귀만으로 닫지 않는다.
실제 전투 판정·AI·누적 자원·보상·36회 행로 → native UI 입력/렌더 → Blueprint
콘텐츠 대조 → 보호된 CI/병합 순서로 검증한다. 사람 플레이·Android·출시 권리
검수는 자동 캠페인 완주와 별도다. 실행 기록과 최신 결과는 Active Context 및
`docs/operations/2026-09-08_TEN_DUEL_CAMPAIGN_IMPLEMENTATION.md`에서 읽는다.

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

자동 제품 증거가 존재해도 로컬 Windows visible, 실물 입력, 접근성 사용자, 실제 Android, Release 성능, 신규 플레이어, 최종 밸런스는 별도 evidence layer다.

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

## 4. 현재 작업 계보와 자동 제품 검증

완료된 초기 10권 제품 배치는 `10/10`이며 PR #92 계보로 main에 병합됐다.

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
- [ ] 로컬 Windows visible과 실물 입력.
- [ ] 실제 Android export·설치·실기기·터치·앱 생명주기.
- [ ] 접근성 사용자 검증.
- [ ] Release 성능 검증.
- [ ] STEP 14 신규 플레이어 5명.

증거: `0a8bf577b936ddac5cb7130a0cc58e519ea6eff6` / workflow `31074079068` / artifact `8956790279`. 현재 자동 증거 판정은 `PARTIAL_AUTOMATED_COMPLETE`다.

## 5. Windows·Android 기본 대상과 다음 Gate 순서

`TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`과 `TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`에 따라 Windows·Android는 같은 전투·AI·콘텐츠·ID·수치·저장 의미를 공유한다.

공유 단일 코어:

- 전투 규칙·AI·콘텐츠 ID·수치·seed.
- 저장 Schema·버전·migration 의미.
- 결과·복기·보상·진행 도메인 규칙.

플랫폼 adapter:

- device-neutral logical command와 키보드·마우스·게임패드·터치 변환.
- compact `≤899`, standard `≤1439`, wide `≥1440` logical px.
- 핵심 touch target `48dp`, landscape primary, safe area·cutout·Android back.
- pause/resume·background/foreground·suspend/restore.
- Windows EXE+PCK / Android AAB·APK export와 품질·성능 예산.

후속 후보 순서:

```text
WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
→ LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE
→ TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE
→ TEN_MANUAL_BALANCE_MEASUREMENT_GATE
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

이 순서는 **후보 Gate의 의존 관계**일 뿐 현재 Build 승인이나 next package 값을 저장하지 않는다. 실제 진입은 최신 사용자 요청과 current Gate를 다시 확인한다.

## 6. 제품 연결 범위

현재 확인한 연결 범위:

- 정확한 10권 roster와 문파·주/보조능력치 조합.
- 3·5·7·9·10성 해금과 overlay 합성.
- 플레이어 명시적 loadout의 무공·절초 UI 표시.
- 적 명시적 loadout의 해금 카드만 공개 상태 AI 후보로 사용.
- 실제 actor-owned 정의와 능력치에 따른 일반 무공 이동·사거리 재검사·다단·일부 조건부 후속 실행. 직접 effect pipeline 테스트와 실제 bundle 경로를 동일시하지 않는다.
- 회마창 사거리 재검사·만천화우 독립 공격과 자하신공의 완료 시 회복 경로는 확인했다. 자하 사용권의 첫 전조 소비, 나한 강건의 첫 전조/중단 보호, 능파미보의 실제 회피 후 반격은 현재 bundle 경로에 누락·충돌이 있어 완료로 보장하지 않는다.
- 기존 기본 행동·공용 절초·준비·자동 배치 동작 보존.

현재 범위 밖 또는 별도 evidence가 필요한 항목:

- 고유 대응 무공, 일반/무공 공통 방어·합·회피·피해 순서, 첫 전조 비용/once/강건과 기존 v1 저장 완주 호환. 실제 진단은 `docs/reviews/2026-09-09_MARTIAL_DOMAIN_INTEGRATION_PREFLIGHT.md`를 따른다.
- 최종 loadout 획득·교체 경제.
- 적별 최종 무공 배치와 난이도 곡선.
- 최종 피해 계수·자원 비용 승인.
- 최종 연출·아트·음향.
- 로컬 Windows·실제 Android·접근성 사용자·Release 성능·사람·밸런스 검증.

## 7. 핵심 위험 순서

| 위험 | 상태 | 다음 조치 |
|---|---|---|
| `RUNTIME_AUTHORITY_GAP` | `MITIGATED_UI_AI_ADOPTED` | 로컬·실기기 검증 |
| `ANDROID_ADAPTER_GAP` | `PLANNING_APPROVED_IMPLEMENTATION_NOT_RUN` | 명시 Build 승인 후 adapter/실기기 Gate |
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
→ Windows runtime·visible
→ Android export·device·lifecycle
→ 접근성·성능
→ 사람 플레이
→ repository destination readback
```

Google Sheets는 신규 정본 sync 단계가 아니다. 고유 미이관 자료를 확인하는 migration 질문에서만 `MIGRATION_ONLY_UNTIL_REMOVAL` source로 읽는다. 실행하지 않은 검증은 `NOT_RUN / UNVERIFIED`로 남긴다.

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

현재 Human evidence 여부는 Active Context/current user planning status에서 읽으며 자동 CI로 승격하지 않는다.

## 10. T1 — 최소 세로 슬라이스

`T1`은 과거부터 이어지는 사람 증거 기반 승격 Gate 이름이다. 현재 first-five-duel Phase I–VI 구현 완료와 같은 뜻이 아니다. 진입 여부는 로컬/기기/접근성/사람 evidence와 최신 Decision을 다시 읽어 판정하며, 과거 `t1_greenlight` 값을 이 Roadmap에 current scalar로 저장하지 않는다.

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

다음 문자열은 과거 회귀 테스트·문서 이력을 찾기 위한 표식일 뿐 현행 상태가 아니다.

- `active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED`.
- `next_planning_decision: TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE`.
- PR #92는 초기 10권 제품 검증 계보이며 현재 active PR이 아니다.
- 과거 PC-first 구현 Gate 이름은 첫 구현 범위를 설명하는 역사 용어이며 현재 플랫폼 권위는 Windows·Android dual-target Decision이다.

현재 Work Mode·PR·승인 수·제품 stage·다음 package/Decision은 Active Context/current JSON/GitHub metadata에서만 읽는다.

## 13. 정본 생명주기

각 항목은 `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`로 분류한다.

- `KEEP`: AI 비치팅 금지, 10칸·3/3/4, 전조·중단, 복기, 원시 로그, stat-fit-only, 단일 공유 코어.
- `AMPLIFY`: 무공별 역할·성취도·실패 원인 설명, 플랫폼별 정보·조작 동등성.
- `CHANGE`: 사람·실기기 측정으로 확인된 수치·적 loadout·UI 밀도·품질 프로필만 별도 Decision으로 변경.
- `REMOVE`: 추가 입력, 숨은 계획 접근, 자동 합 승리, 능력치 쿼터, 플랫폼별 도메인 규칙 복제.
- `DEFER`: 최종 loadout 경제, 최종 연출, 비스탯 노드 경제, 온라인·크로스 세이브·과금.
- `RETEST`: 자원 포화·기술 대체·AI 공정성·관찰·등급 파밍·Android 생명주기·성능 위험.

병합 전후에는 repository owner를 같은 의미로 동기화하고 readback한다. Google Sheets와 historical Notion은 migration-only compatibility source이며 current Decision/state sync surface가 아니다.
