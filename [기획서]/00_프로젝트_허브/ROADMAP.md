# 십보강호 운영 로드맵

> 상세 제품 로드맵: `../../../docs/04_ROADMAP.md`  
> 현재 상태: `ACTIVE_CONTEXT.md`  
> 정본 생명주기: `../../../docs/CANON_LIFECYCLE_REGISTRY.md`  
> 플랫폼 권위: `../../../docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md`

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: REVIEW
active_planning_pr: NONE
active_planning_parent_pr: NONE
active_approval_count: 10/10
active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_MERGED
product_implementation_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90
merged_product_pr: 92
platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01
design_platforms: WINDOWS_ANDROID
platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS
windows_validation: CI_EXPORT_RUNTIME_PASS_LOCAL_NOT_RUN
android_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT
human_validation: NOT_RUN
base_release_pinned: 9.4.3
```

## 완료

- `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`: main 병합.
- `TEN_MANUAL_UI_AI_ADOPTION_GATE`: main 병합.
- `TEN_MANUAL_PRODUCT_VALIDATION_GATE`: 자동 증거 `PARTIAL_AUTOMATED_COMPLETE`, PR #92 main 병합.
- Windows CI export·runtime, 50개 성취도 시나리오, 3개 해상도, 합성 입력, 자동 접근성, 성능 baseline: PASS/CAPTURED.

## 다음 순서

```text
WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT
→ LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE
→ TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE
→ TEN_MANUAL_BALANCE_MEASUREMENT_GATE
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

## 운영 경계

- Windows와 Android는 동일 전투·AI·데이터·저장 코어를 사용한다.
- 입력·반응형 UI·앱 생명주기·플랫폼 서비스·품질·export만 분리한다.
- 로컬 Windows·실물 게임패드·실제 Android·접근성 사용자·Release 성능·STEP 14·밸런스는 `NOT_RUN`이다.
- 자동 증거를 전체 제품 PASS·T1·MVP·Android 지원 완료로 확대하지 않는다.
