# 십보강호 운영 로드맵

> 상세 제품 로드맵: `../../../docs/04_ROADMAP.md`  
> 현재 상태 단독 책임 원본: `ACTIVE_CONTEXT.md` + `../../../docs/planning-data/current_operating_state.json` + `../../../docs/planning-data/current_user_planning_status.json`  
> 정본 생명주기: `../../../docs/CANON_LIFECYCLE_REGISTRY.md`  
> 사람용 상태·Flow·Visual: exact Project Notion  
> 현행 작업계약: `TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`

이 문서는 **운영 방향·완료 계보·후속 Gate 의존 관계**를 보여 주는 stable router다. 활성 PR, exact SHA, Work Mode, 승인 수, 제품 stage, 현재 decision state, next package/Decision 같은 mutable checkpoint는 여기에 복제하지 않는다.

## 현재 단계

```yaml
current_state_owner: ACTIVE_CONTEXT_PLUS_CURRENT_JSON
current_human_workspace: EXACT_PROJECT_NOTION
current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME
google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL
platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01
platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01
design_platforms: WINDOWS_ANDROID
platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS
```

현재 Phase I–VI 구현 여부, 현재 검증 상태, 후속 제품 mutation 권한은 `ACTIVE_CONTEXT.md`와 current JSON을 fresh-read해 판정한다.

## 완료 계보

- `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`: main 병합.
- `TEN_MANUAL_UI_AI_ADOPTION_GATE`: main 병합.
- `TEN_MANUAL_PRODUCT_VALIDATION_GATE`: 자동 증거 `PARTIAL_AUTOMATED_COMPLETE`, PR #92 main 병합.
- 제품 구현 계보: `product_implementation_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90`, `merged_product_pr: 92`.
- Windows CI export·runtime, 50개 성취도 시나리오, 3개 해상도, 합성 입력, 자동 접근성, 성능 baseline: PASS/CAPTURED.
- Adapter Architecture 계보: `platform_adapter_merge_commit: 023385d372d127044d48afcb50e6f232ab9ffaa1`, `merged_platform_adapter_pr: 102`.
- PR #102는 역사적 병합 계보이며 현재 active PR이 아니다.

## Adapter Architecture 보호선

- 공유 코어: 전투·AI·콘텐츠 ID·수치·저장·결정적 해결.
- Adapter: 입력·반응형 UI·앱 생명주기·플랫폼 서비스·품질·export.
- 기본값: 48dp touch target, landscape primary, safe area·back 처리, atomic checkpoint save.
- Android/Windows/Human의 최신 evidence는 이 문서에 snapshot으로 저장하지 않고 current authority에서 읽는다.

## 다음 순서

후속 후보 Gate의 의존 관계는 다음과 같다.

```text
WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
→ LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE
→ TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE
→ TEN_MANUAL_BALANCE_MEASUREMENT_GATE
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

이 순서는 현재 Build 승인이나 `next_planning_decision`을 뜻하지 않는다. 실제 진입은 최신 사용자 요청 + current Gate를 다시 확인한다.

## 운영 경계

- Windows와 Android는 동일 전투·AI·데이터·저장 코어를 사용한다.
- 입력·반응형 UI·앱 생명주기·플랫폼 서비스·품질·export만 분리한다.
- 로컬 Windows visible, 실물 게임패드, 실제 Android, 접근성 사용자, Release 성능, STEP 14, 밸런스는 각각 독립 evidence layer다.
- 자동 증거를 전체 제품 PASS·T1·MVP·Android 지원 완료로 확대하지 않는다.
- Google Sheets는 신규 Decision/current state sync surface가 아니라 `MIGRATION_ONLY_UNTIL_REMOVAL` compatibility source다.
