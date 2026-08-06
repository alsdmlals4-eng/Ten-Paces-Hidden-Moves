#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"missing {label}: {old!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


contract = ROOT / "docs/planning-data/approved_20260806_windows_android_adapter_architecture_contract.json"
replace_once(
    contract,
    '  "platforms": [\n',
    '  "current_operating_state": {\n'
    '    "active_planning_work_mode": "REVIEW",\n'
    '    "active_planning_pr": "102",\n'
    '    "active_planning_parent_pr": "NONE",\n'
    '    "active_approval_count": "1/10",\n'
    '    "active_decision_state": "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED",\n'
    '    "next_planning_decision": "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE"\n'
    '  },\n'
    '  "platforms": [\n',
    "adapter contract current operating state",
)

architecture_test = ROOT / "tests/test_windows_android_adapter_architecture_contract.py"
replace_once(
    architecture_test,
    '        self.assertEqual(data["core_policy"]["authority"], "SINGLE_SHARED_CORE")\n',
    '        self.assertEqual(data["core_policy"]["authority"], "SINGLE_SHARED_CORE")\n'
    '        self.assertEqual(\n'
    '            data["current_operating_state"],\n'
    '            {\n'
    '                "active_planning_work_mode": "REVIEW",\n'
    '                "active_planning_pr": "102",\n'
    '                "active_planning_parent_pr": "NONE",\n'
    '                "active_approval_count": "1/10",\n'
    '                "active_decision_state": "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED",\n'
    '                "next_planning_decision": "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE",\n'
    '            },\n'
    '        )\n',
    "adapter architecture test current state",
)

architecture_checker = ROOT / "tools/check_windows_android_adapter_architecture_contract.py"
replace_once(
    architecture_checker,
    '    if batch.get("maximum_decision_count") != 10:\n        errors.append("APPROVAL_BATCH_CONFLICT")\n\n    core = data.get("core_policy", {})\n',
    '    if batch.get("maximum_decision_count") != 10:\n'
    '        errors.append("APPROVAL_BATCH_CONFLICT")\n\n'
    '    expected_operating_state = {\n'
    '        "active_planning_work_mode": "REVIEW",\n'
    '        "active_planning_pr": "102",\n'
    '        "active_planning_parent_pr": "NONE",\n'
    '        "active_approval_count": "1/10",\n'
    '        "active_decision_state": "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED",\n'
    '        "next_planning_decision": "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE",\n'
    '    }\n'
    '    if data.get("current_operating_state") != expected_operating_state:\n'
    '        errors.append("CURRENT_OPERATING_STATE_CONFLICT")\n\n'
    '    core = data.get("core_policy", {})\n',
    "adapter checker current state",
)

postmerge = ROOT / "tools/check_postmerge_canon_lifecycle.py"
replace_once(
    postmerge,
    'PLATFORM_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md")\n',
    'PLATFORM_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md")\n'
    'ADAPTER_CONTRACT_PATH = pathlib.Path("docs/planning-data/approved_20260806_windows_android_adapter_architecture_contract.json")\n',
    "postmerge adapter contract path",
)
old_function = '''def validate_operating_state(active: str, roadmap: str) -> None:
    active_state = {key: yaml_scalar(active, key) for key in OPERATING_KEYS}
    roadmap_state = {key: yaml_scalar(roadmap, key) for key in OPERATING_KEYS}
    require(active_state == roadmap_state, "operating checkpoint mismatch between active context and roadmap")
    require(active_state["active_planning_work_mode"] == "REVIEW", "active planning work mode differs")
    require(active_state["active_planning_pr"] == "NONE", "active planning PR must be NONE after PR #92 merge")
    require(active_state["active_planning_parent_pr"] == "NONE", "active planning parent PR must be NONE after merge")
    require(active_state["active_approval_count"] == "10/10", "active approval count differs")
    require(active_state["active_decision_state"] == "TEN_MANUAL_PRODUCT_VALIDATION_MERGED", "active decision state differs")
    require(active_state["next_planning_decision"] == "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT", "next planning decision differs")
    require_tokens(active, [
        f"product_implementation_merge_commit: {PRODUCT_MERGE_COMMIT}",
        "merged_product_pr: 92",
        "runtime_work_mode: REVIEW", "runtime_integration_pr: 65",
        "runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92",
        "latest_combat_planning_runtime: PRODUCT_VALIDATION_AUTOMATED",
        "windows_validation: CI_EXPORT_RUNTIME_PASS_LOCAL_NOT_RUN",
        "android_validation: NOT_RUN",
        f"platform_decision: {PLATFORM_DECISION_ID}",
        "design_platforms: WINDOWS_ANDROID",
        "platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS",
        "accessibility_validation: AUTOMATED_PASS_USER_NOT_RUN",
        "performance_validation: BASELINE_CAPTURED_RELEASE_NOT_RUN",
        "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE", "TEN_MANUAL_UI_AI_ADOPTION_GATE",
        "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "PARTIAL_AUTOMATED_COMPLETE",
        PRODUCT_EVIDENCE_HEAD, PRODUCT_WORKFLOW_RUN, PRODUCT_WINDOWS_ARTIFACT,
        "플레이어 비공개 계획·미확정 배치·포인터는 참조하지 않는다",
        "능력치별 무공서 권수·균등 분포·최소/최대 쿼터는 사용하지 않는다",
        "03_무공서_무학",
    ], "active context")
    require("DRAFT_PR92_TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_10_OF_10" not in active, "active context retains Draft PR #92 checkpoint")
    require_tokens(roadmap, [
        f"product_implementation_merge_commit: {PRODUCT_MERGE_COMMIT}",
        "merged_product_pr: 92",
        "프로젝트 코어 확정", "핵심 재미·시스템 정렬", "현재 작업", "STEP 14", "T1 — 최소 세로 슬라이스",
        "공통 검증 게이트", "중단·축소 조건", "KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST",
        "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "PARTIAL_AUTOMATED_COMPLETE",
        f"증거: `{PRODUCT_EVIDENCE_HEAD}` / workflow `{PRODUCT_WORKFLOW_RUN}` / artifact `{PRODUCT_WINDOWS_ARTIFACT}`",
        "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT", "LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE",
        "NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT",
    ], "roadmap")
'''
new_function = '''def validate_operating_state(active: str, roadmap: str, current_contract: dict[str, Any]) -> None:
    active_state = {key: yaml_scalar(active, key) for key in OPERATING_KEYS}
    roadmap_state = {key: yaml_scalar(roadmap, key) for key in OPERATING_KEYS}
    require(active_state == roadmap_state, "operating checkpoint mismatch between active context and roadmap")

    expected_state = current_contract.get("current_operating_state")
    require(isinstance(expected_state, dict), "current planning authority must define current_operating_state")
    messages = {
        "active_planning_work_mode": "active planning work mode differs",
        "active_planning_pr": "active planning PR differs from current planning authority",
        "active_planning_parent_pr": "active planning parent PR differs",
        "active_approval_count": "active approval count differs",
        "active_decision_state": "active decision state differs",
        "next_planning_decision": "next planning decision differs",
    }
    for key in OPERATING_KEYS:
        require(str(expected_state.get(key)) == active_state[key], messages[key])

    require_tokens(active, [
        f"product_implementation_merge_commit: {PRODUCT_MERGE_COMMIT}",
        "merged_product_pr: 92",
        "runtime_work_mode: REVIEW", "runtime_integration_pr: 65",
        "runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92",
        "latest_combat_planning_runtime: PRODUCT_VALIDATION_AUTOMATED",
        "windows_validation: CI_EXPORT_RUNTIME_PASS_LOCAL_NOT_RUN",
        "android_validation: NOT_RUN",
        f"platform_decision: {PLATFORM_DECISION_ID}",
        "platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01",
        "design_platforms: WINDOWS_ANDROID",
        "platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS",
        "accessibility_validation: AUTOMATED_PASS_USER_NOT_RUN",
        "performance_validation: BASELINE_CAPTURED_RELEASE_NOT_RUN",
        "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE", "TEN_MANUAL_UI_AI_ADOPTION_GATE",
        "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "PARTIAL_AUTOMATED_COMPLETE",
        PRODUCT_EVIDENCE_HEAD, PRODUCT_WORKFLOW_RUN, PRODUCT_WINDOWS_ARTIFACT,
        "플레이어 비공개 계획·미확정 배치·포인터는 참조하지 않는다",
        "능력치별 무공서 권수·균등 분포·최소/최대 쿼터는 사용하지 않는다",
        "03_무공서_무학",
    ], "active context")
    require("DRAFT_PR92_TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_10_OF_10" not in active, "active context retains Draft PR #92 checkpoint")
    require_tokens(roadmap, [
        f"product_implementation_merge_commit: {PRODUCT_MERGE_COMMIT}",
        "merged_product_pr: 92",
        "프로젝트 코어 확정", "핵심 재미·시스템 정렬", "현재 작업", "STEP 14", "T1 — 최소 세로 슬라이스",
        "공통 검증 게이트", "중단·축소 조건", "KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST",
        "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "PARTIAL_AUTOMATED_COMPLETE",
        f"증거: `{PRODUCT_EVIDENCE_HEAD}` / workflow `{PRODUCT_WORKFLOW_RUN}` / artifact `{PRODUCT_WINDOWS_ARTIFACT}`",
        "TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01",
        "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE", "LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE",
        "NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT",
    ], "roadmap")
'''
replace_once(postmerge, old_function, new_function, "postmerge operating state function")
replace_once(
    postmerge,
    '    validate_operating_state(active, roadmap)\n',
    '    validate_operating_state(active, roadmap, read_json(root, ADAPTER_CONTRACT_PATH))\n',
    "postmerge validate call",
)

postmerge_test = ROOT / "tests/test_postmerge_canon_lifecycle.py"
replace_once(
    postmerge_test,
    '    "docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md",\n',
    '    "docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md",\n'
    '    "docs/planning-data/approved_20260806_windows_android_adapter_architecture_contract.json",\n',
    "postmerge fixture adapter contract",
)
