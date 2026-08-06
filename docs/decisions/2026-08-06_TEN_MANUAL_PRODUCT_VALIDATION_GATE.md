# 초기 10권 자동 제품 검증 Decision

- Decision ID: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`
- 상태: `APPROVED_AND_IMPLEMENTED_PARTIAL_AUTOMATED_COMPLETE`
- 승인 근거: 사용자 `권장안대로 진행` 후 written spec 승인
- 부모 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`
- evidence source head: `7494f50c48573168542781e007eeab6af11dda7d`
- workflow run: `31068098197`
- Windows artifact: `8954602789`

## 승인 결과

- Windows x86_64 Release export: PASS.
- export된 실행 파일 Windows CI runtime: PASS.
- 초기 10권 × 3·5·7·9·10성 50개 시나리오: 50/50 PASS.
- 1280×800·1440×900·1920×1080: PASS.
- 키보드·마우스 합성 입력, 포커스, 레이아웃, 자동 접근성: PASS.
- 성능 baseline: CAPTURED.

```yaml
runtime_authority: PRODUCT_VALIDATION_AUTOMATED
product_gate: PARTIAL_AUTOMATED_COMPLETE
windows_ci_runtime: PASS
windows_local_render: NOT_RUN
gamepad_physical: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
human_step14: NOT_RUN
balance_validation: NOT_RUN
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

## 성능 baseline

- exported runtime: 3018.23ms.
- peak working set: 188674048 bytes.
- exe+pck: 123037256 bytes.
- runner: windows-latest.
- Godot: 4.7.1.

동일 runner·Godot 버전이 아니면 직접 회귀 비교하지 않는다.

## 금지 해석

자동 증거를 로컬 Windows 렌더·실물 입력·접근성 사용자·Release 성능·사람 플레이·최종 밸런스·T1·MVP·Draft 해제·병합 승인으로 확대하지 않는다.

## 다음 Gate

1. `TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE`.
2. `TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE`.
3. `TEN_MANUAL_BALANCE_MEASUREMENT_GATE`.
