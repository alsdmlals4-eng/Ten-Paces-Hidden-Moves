#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = "7d20c2c9d5d1c92b80d32dc9bf25bd833a48ad58"


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        raise SystemExit(f"missing expected token for {label}: {old!r}")
    return text.replace(old, new, 1)


def patch_active_context() -> None:
    path = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        "> 플랫폼 권위: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`  ",
        "> 플랫폼 권위: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`  \n> 플랫폼 Adapter 아키텍처 권위: `TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`  ",
        "active authority",
    )
    text = replace_once(text, "merged_planning_checkpoint: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90", f"merged_planning_checkpoint: {MAIN}", "active checkpoint")
    text = replace_once(text, "merged_pr_lineage: 84,86,87,88,89,91,92,100", "merged_pr_lineage: 84,86,87,88,89,91,92,100,101", "active lineage")
    text = replace_once(text, "active_planning_pr: NONE", "active_planning_pr: 102", "active pr")
    text = replace_once(text, "active_approval_count: 10/10", "active_approval_count: 1/10", "active approval")
    text = replace_once(text, "active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_MERGED", "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED", "active state")
    text = replace_once(
        text,
        "platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01",
        "platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01\nplatform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01",
        "active adapter decision",
    )
    text = replace_once(text, "next_package: VERTICAL_SLICE_APP_FLOW_SHELL", "next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION", "active package")
    text = replace_once(text, "next_planning_decision: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT", "next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", "active next gate")
    section = """## Windows·Android Adapter 아키텍처 권위

`TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`은 부모 플랫폼 Decision을 제품 구조 계약으로 구체화한다.

```yaml
shared_core: COMBAT_RULES_AI_CONTENT_IDS_NUMERIC_BALANCE_SAVE_SCHEMA_DETERMINISTIC_RESOLUTION
adapter_layers: [INPUT, RESPONSIVE_UI, APP_LIFECYCLE, PLATFORM_SERVICES, QUALITY_EXPORT]
logical_input_boundary: LOGICAL_COMMANDS_OR_INPUTMAP_ONLY
responsive_breakpoints: COMPACT_899_STANDARD_1439_WIDE_1440
minimum_touch_target_dp: 48
android_orientation: LANDSCAPE_PRIMARY
android_safe_area: REQUIRED
save_write_policy: TEMP_WRITE_VALIDATE_ATOMIC_REPLACE
renderer_baseline: GL_COMPATIBILITY
android_export: NOT_RUN
implementation_authority: PLANNING_CONTRACT_ONLY
```

보호 규칙:

- Windows·Android 전투 규칙·AI·콘텐츠 ID·수치·저장 의미를 분기하지 않는다.
- hover 또는 drag만으로 가능한 필수 행동을 두지 않는다.
- compact 화면에서도 거리·3/3/4 계획·비용·사거리·관찰·합·중단·복기 원인을 보존한다.
- Android back은 overlay 닫기 → 되돌릴 수 있는 단계 취소 → pause/종료 확인 순서를 사용한다.
- pause 한 시점에만 저장을 의존하지 않고 결정적 경계 checkpoint를 사용한다.
- Android AAB/APK·설치·실기기·터치·safe area·lifecycle·성능 증거 전에는 지원 완료를 주장하지 않는다.

현재 코드 감사에서 Android export preset, 제품 InputMap action, RunSession, SaveService, safe-area·lifecycle adapter는 `NOT_RUN / NOT_IMPLEMENTED`다. 기존 leaf control의 raw key·mouse 입력은 제품 실패가 아니라 구현 Gate의 migration inventory다.

"""
    text = replace_once(text, "## 관찰 권위\n", section + "## 관찰 권위\n", "active adapter section")
    path.write_text(text, encoding="utf-8")


def patch_product_roadmap() -> None:
    path = ROOT / "docs/04_ROADMAP.md"
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        "> 플랫폼 Decision: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`  ",
        "> 플랫폼 Decision: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`  \n> 플랫폼 Adapter Decision: `TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`  ",
        "roadmap authority",
    )
    text = replace_once(text, "merged_planning_checkpoint: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90", f"merged_planning_checkpoint: {MAIN}", "roadmap checkpoint")
    text = replace_once(text, "merged_pr_lineage: 84,86,87,88,89,91,92,100", "merged_pr_lineage: 84,86,87,88,89,91,92,100,101", "roadmap lineage")
    text = replace_once(text, "active_planning_pr: NONE", "active_planning_pr: 102", "roadmap pr")
    text = replace_once(text, "active_approval_count: 10/10", "active_approval_count: 1/10", "roadmap approval")
    text = replace_once(text, "active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_MERGED", "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED", "roadmap state")
    text = replace_once(
        text,
        "platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01",
        "platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01\nplatform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01",
        "roadmap adapter decision",
    )
    text = replace_once(text, "next_package: VERTICAL_SLICE_APP_FLOW_SHELL", "next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION", "roadmap package")
    text = replace_once(text, "next_planning_decision: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT", "next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", "roadmap next gate")
    text = replace_once(text, "PR #89·#91·#92 승인 계보는 main에 병합됐다.", "PR #89·#91·#92 제품 계보와 PR #101 post-merge 플랫폼 정본은 main에 병합됐다.", "roadmap merged prose")
    contract_section = """### Adapter Architecture 계약 승인

`TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01`에서 다음을 고정했다.

- 전투·AI·콘텐츠 ID·수치·저장 Schema·결정적 해결은 단일 공유 코어.
- device-neutral logical command와 InputMap 소비 경계.
- compact `≤899`, standard `≤1439`, wide `≥1440` logical px.
- 핵심 touch target `48dp`, landscape primary, safe area·cutout·Android back 처리.
- 묶음 commit/resolve·노드 선택·결과 진입 checkpoint와 atomic save·backup·migration.
- Compatibility renderer 공통 기준선과 Windows EXE+PCK / Android AAB·APK export 경계.
- 실제 Android·로컬 Windows·실물 gamepad·사용자 접근성·Release 성능은 `NOT_RUN`.

"""
    text = replace_once(
        text,
        "다음 작업:\n\n```text\nWINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT\n",
        contract_section + "다음 작업:\n\n```text\nWINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE\n",
        "roadmap next sequence",
    )
    path.write_text(text, encoding="utf-8")


def patch_hub_roadmap() -> None:
    path = ROOT / "[기획서]/00_프로젝트_허브/ROADMAP.md"
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        "> 플랫폼 권위: `../../../docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md`",
        "> 플랫폼 권위: `../../../docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md`  \n> 플랫폼 Adapter 권위: `../../../docs/decisions/2026-08-06_WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_DECISION.md`",
        "hub authority",
    )
    text = replace_once(text, "active_planning_pr: NONE", "active_planning_pr: 102", "hub pr")
    text = replace_once(text, "active_approval_count: 10/10", "active_approval_count: 1/10", "hub approval")
    text = replace_once(text, "active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_MERGED", "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED", "hub state")
    text = replace_once(
        text,
        "platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01",
        "platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01\nplatform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01",
        "hub adapter decision",
    )
    text = replace_once(text, "next_package: VERTICAL_SLICE_APP_FLOW_SHELL", "next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION", "hub package")
    text = replace_once(text, "next_planning_decision: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT", "next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", "hub next gate")
    text = replace_once(text, "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT\n→ LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE", "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE\n→ LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE", "hub sequence")
    text = replace_once(
        text,
        "## 다음 순서\n",
        "## Adapter Architecture 승인\n\n- 공유 코어: 전투·AI·콘텐츠 ID·수치·저장·결정적 해결.\n- Adapter: 입력·반응형 UI·앱 생명주기·플랫폼 서비스·품질·export.\n- 기본값: 48dp touch target, landscape primary, safe area·back 처리, atomic checkpoint save.\n- Android 구현·export·실기기 증거는 `NOT_RUN`.\n\n## 다음 순서\n",
        "hub contract section",
    )
    path.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    patch_active_context()
    patch_product_roadmap()
    patch_hub_roadmap()
