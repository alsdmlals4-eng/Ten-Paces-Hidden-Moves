#!/usr/bin/env python3
from __future__ import annotations

import json
import pathlib
import re
import sys
from typing import Any

ROOT = pathlib.Path(__file__).resolve().parents[1]
ACTIVE_PATH = pathlib.Path("[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md")
ROADMAP_PATH = pathlib.Path("docs/04_ROADMAP.md")
AGENTS_PATH = pathlib.Path("AGENTS.md")
MASTERY_PATH = pathlib.Path("docs/06_STARTING_FACTION_MASTERY_DATA.md")
REGISTRY_PATH = pathlib.Path("docs/CANON_LIFECYCLE_REGISTRY.md")
RUNTIME_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-06_TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE.md")
UI_AI_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-06_TEN_MANUAL_UI_AI_ADOPTION_GATE.md")
PRODUCT_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-06_TEN_MANUAL_PRODUCT_VALIDATION_GATE.md")
PRODUCT_CONTRACT_PATH = pathlib.Path("docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json")
PRODUCT_EVIDENCE_PATH = pathlib.Path("docs/evidence/TEN_MANUAL_PRODUCT_VALIDATION_EVIDENCE.md")
STEP14_PROTOCOL_PATH = pathlib.Path("docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md")
STEP14_RESULTS_PATH = pathlib.Path("docs/research/STEP14_REPEAT_POC_RESULTS_TEMPLATE.md")
BUILD_APPROVAL_PATH = pathlib.Path("docs/implementation/BUILD_APPROVAL_2026-08-06.md")
RUNTIME_MANIFEST_PATH = pathlib.Path("data/cards/martial_manual_cards.json")
UI_AI_LOADOUT_PATH = pathlib.Path("data/combat/ten_manual_loadout_poc.json")
RANGE_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md")
OLD_TECHNIQUE_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md")
OLD_TECHNIQUE_CONTRACT_PATH = pathlib.Path("docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json")
OLD_PLATFORM_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md")
PLATFORM_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md")
CURRENT_STATE_PATH = pathlib.Path("docs/planning-data/current_operating_state.json")
AUDIT_CONTRACT_PATH = pathlib.Path("docs/planning-data/approved_20260804_postmerge_canon_adversarial_audit_contract.json")

EXPECTED_RISKS = {"RESOURCE_SATURATION_RISK", "CONDITION_CALIBRATION_RISK", "WRONG_PLAN_RESCUE_RISK", "OBSERVATION_ANSWER_LEAK_RISK", "GRADE_FARMING_RISK", "RUNTIME_AUTHORITY_GAP"}
OPERATING_KEYS = ("active_planning_work_mode", "active_planning_pr", "active_planning_parent_pr", "active_approval_count", "active_decision_state", "next_package", "next_planning_decision")
PRODUCT_EVIDENCE_HEAD = "0a8bf577b936ddac5cb7130a0cc58e519ea6eff6"
PRODUCT_WORKFLOW_RUN = "31074079068"
PRODUCT_WINDOWS_ARTIFACT = "8956790279"
PRODUCT_MERGE_COMMIT = "a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90"
PLATFORM_DECISION_ID = "TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01"

class CanonLifecycleError(ValueError):
    pass

def require(condition: bool, message: str) -> None:
    if not condition:
        raise CanonLifecycleError(message)

def read_text(root: pathlib.Path, relative: pathlib.Path) -> str:
    target = root / relative
    require(target.is_file(), f"missing canon lifecycle file: {relative.as_posix()}")
    return target.read_text(encoding="utf-8")

def read_json(root: pathlib.Path, relative: pathlib.Path) -> dict[str, Any]:
    value = json.loads(read_text(root, relative))
    require(isinstance(value, dict), f"{relative.as_posix()} must contain a JSON object")
    return value

def yaml_scalar(text: str, key: str) -> str:
    values = re.findall(rf"(?m)^{re.escape(key)}:\s*([^\s#]+)\s*(?:#.*)?$", text)
    require(len(values) == 1, f"operating checkpoint key must appear exactly once: {key}")
    return values[0]

def require_tokens(text: str, tokens: list[str], label: str) -> None:
    for token in tokens:
        require(token in text, f"{label} missing token: {token}")

def validate_operating_state(active: str, roadmap: str, current_state: dict[str, Any]) -> None:
    active_state = {key: yaml_scalar(active, key) for key in OPERATING_KEYS}
    roadmap_state = {key: yaml_scalar(roadmap, key) for key in OPERATING_KEYS}
    require(active_state == roadmap_state, "operating checkpoint mismatch between active context and roadmap")

    require(current_state.get("schema_version") == 1, "current operating state schema differs")
    require(current_state.get("authority") == "CURRENT_OPERATING_STATE", "current operating state authority differs")
    require(isinstance(current_state.get("source_decision"), str) and current_state.get("source_decision"), "current operating state source Decision missing")
    expected_state = current_state
    messages = {
        "active_planning_work_mode": "active planning work mode differs",
        "active_planning_pr": "active planning PR differs from current planning authority",
        "active_planning_parent_pr": "active planning parent PR differs",
        "active_approval_count": "active approval count differs",
        "active_decision_state": "active decision state differs",
        "next_package": "next package differs",
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

def validate_platform_authority(agents: str, old_decision: str, decision: str) -> None:
    require("# [대체됨]" in old_decision and "상태: `SUPERSEDED`" in old_decision, "old platform Decision must be SUPERSEDED")
    require_tokens(old_decision, [PLATFORM_DECISION_ID, "primary_platform: PC", "future_platform: MOBILE_CONSIDERATION_ONLY"], "old platform Decision")
    require_tokens(decision, [
        PLATFORM_DECISION_ID,
        "status: APPROVED_PLANNING",
        "design_targets: [WINDOWS, ANDROID]",
        "logic_and_data_core: SINGLE_SHARED_CORE",
        "separated_adapters: [INPUT, RESPONSIVE_UI, APP_LIFECYCLE, PLATFORM_SERVICES, QUALITY_EXPORT]",
        "same_day_release_required: false",
        "android_runtime_evidence: NOT_RUN",
        "android_device_evidence: NOT_RUN",
        "android_performance_evidence: NOT_RUN",
    ], "current platform Decision")
    require_tokens(agents, [
        f"platform_decision: {PLATFORM_DECISION_ID}",
        "design_platforms: WINDOWS_ANDROID",
        "platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS",
        "android_runtime_evidence: NOT_RUN",
        "전투 규칙·AI·콘텐츠·ID·수치·저장 Schema는 하나의 공유 코어",
    ], "AGENTS platform contract")

def validate_runtime_authority(runtime_decision: str, build_approval: str, manifest: dict[str, Any]) -> None:
    require_tokens(runtime_decision, ["TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE", "APPROVED_RUNTIME_FOUNDATION", "RUNTIME_FOUNDATION", "PR #92", "PR #91"], "runtime Decision")
    require_tokens(build_approval, ["registry + ordered effect pipeline + explicit engine loadout integration", "human validation: NOT_RUN", "balance validation: NOT_RUN"], "runtime build approval")
    require(manifest.get("runtime_status") == "RUNTIME_FOUNDATION", "runtime manifest authority differs")
    require(manifest.get("stat_quota_rules_enabled") is False, "runtime manifest re-enabled stat quota rules")
    files = manifest.get("manual_files")
    require(isinstance(files, dict) and len(files) == 10, "runtime manifest must map exactly ten manuals")
    compatibility = manifest.get("compatibility")
    require(isinstance(compatibility, dict) and compatibility.get("legacy_default_behavior_unchanged") is True, "legacy default behavior must remain unchanged")
    require(compatibility.get("explicit_loadout_required") is True, "martial cards must require an explicit loadout")

def validate_ui_ai_authority(ui_ai_decision: str, loadout: dict[str, Any]) -> None:
    require_tokens(ui_ai_decision, ["TEN_MANUAL_UI_AI_ADOPTION_GATE", "APPROVED_AND_IMPLEMENTED", "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "martial_loadout", "martial_mastery_by_manual", "플레이어 비공개 계획", "MartialEffectPipeline", "31053963064", "03_무공서_무학"], "UI AI Decision")
    require(loadout.get("authority") == "TEN_MANUAL_UI_AI_ADOPTION_GATE", "ten-manual loadout authority differs")
    require(isinstance(loadout.get("player"), dict) and isinstance(loadout.get("enemy"), dict), "player and enemy loadouts must be separate")
    require(bool(loadout["player"].get("loadout")) and bool(loadout["enemy"].get("loadout")), "player and enemy loadouts must be explicit")

def validate_product_authority(decision: str, contract: dict[str, Any], evidence: str, protocol: str, results: str) -> None:
    require_tokens(decision, [
        "TEN_MANUAL_PRODUCT_VALIDATION_GATE",
        "APPROVED_AND_IMPLEMENTED_PARTIAL_AUTOMATED_COMPLETE",
        PRODUCT_EVIDENCE_HEAD,
        PRODUCT_WORKFLOW_RUN,
        PRODUCT_WINDOWS_ARTIFACT,
        "2344.67",
        "188571648",
        "123037256",
        "windows_local_render: NOT_RUN",
        "human_step14: NOT_RUN",
        "t1_greenlight: NOT_GRANTED",
    ], "product Decision")
    require(contract.get("decision_id") == "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "product contract decision differs")
    require(contract.get("required_scenario_count") == 50 and len(contract.get("scenario_matrix", [])) == 50, "product contract scenario count differs")
    require(contract.get("forced_not_run") == ["windows_local_render", "gamepad_physical", "accessibility_user", "release_performance", "human_step14"], "product contract NOT_RUN axes differ")
    require_tokens(evidence, [
        PRODUCT_EVIDENCE_HEAD,
        PRODUCT_WORKFLOW_RUN,
        PRODUCT_WINDOWS_ARTIFACT,
        "scenario_passed: 50",
        "windows_ci_runtime: PASS",
        "PARTIAL_AUTOMATED_COMPLETE",
        "windows_local_render: NOT_RUN",
        "participant_count: 0",
        "2344.67",
        "188571648",
        "123037256",
    ], "product evidence")
    require_tokens(protocol, ["REACTIVATED_BY_USER", "participant_count: 0", "human_step14: NOT_RUN", PRODUCT_EVIDENCE_HEAD, PRODUCT_WORKFLOW_RUN, PRODUCT_WINDOWS_ARTIFACT], "STEP14 protocol")
    require_tokens(results, ["participant_count: 0", "human_step14: NOT_RUN", "P05 | NOT_RUN", "t1_greenlight: NOT_GRANTED"], "STEP14 results")

def validate_superseded_authority(range_decision: str, old_decision: str, old_contract: dict[str, Any]) -> None:
    require("# [대체됨]" in range_decision and "상태: `SUPERSEDED`" in range_decision, "range Decision lifecycle label [대체됨] missing")
    require("# [대체됨]" in old_decision and "상태: `SUPERSEDED`" in old_decision, "Technique1 Decision must be SUPERSEDED")
    require(old_contract.get("authority_status") == "SUPERSEDED_HISTORICAL_EVIDENCE", "superseded Technique1 contract cannot claim current authority")
    require(old_contract.get("lifecycle_label_ko") == "[대체됨]", "superseded Technique1 contract Korean lifecycle label missing")

def validate_registry(registry: str) -> None:
    require_tokens(registry, ["[현행]", "[대체됨]", "[보류]", "[폐기]", "PR #85 HTML Technique1 PoC", "닫힘·병합 금지·제품 권위 없음", "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE", "TEN_MANUAL_UI_AI_ADOPTION_GATE", "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "PRODUCT_VALIDATION_AUTOMATED", "approved_20260806_ten_manual_product_validation_gate_contract.json", "능력치별 무공서 권수·균등 분포·최소/최대 쿼터"], "canon lifecycle registry")

def validate_mastery(mastery: str) -> None:
    require_tokens(mastery, ["active_batch: 10/10", "implementation_authority: RUNTIME_FOUNDATION", "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE", "TEN_MANUAL_UI_AI_ADOPTION_GATE", "현재 Windows·접근성·성능·사람·밸런스 검증은 `NOT_RUN`이다"], "growth authority")

def validate_historical_audit(data: dict[str, Any]) -> None:
    require(set(data.get("adversarial_risks", {})) == EXPECTED_RISKS, "adversarial risk coverage differs")
    held = data.get("held_artifacts")
    require(isinstance(held, list) and len(held) == 1 and held[0].get("merge_allowed") is False, "held HTML PR cannot be mergeable authority")
    order = data.get("next_planning_order")
    require(isinstance(order, list) and order and order[0] == "STAR9_PUBLIC_READ_BRANCH_TEMPLATE", "9-star template must precede individual branches")

def validate(root: pathlib.Path = ROOT) -> None:
    active = read_text(root, ACTIVE_PATH)
    roadmap = read_text(root, ROADMAP_PATH)
    mastery = read_text(root, MASTERY_PATH)
    registry = read_text(root, REGISTRY_PATH)
    validate_operating_state(active, roadmap, read_json(root, CURRENT_STATE_PATH))
    validate_platform_authority(read_text(root, AGENTS_PATH), read_text(root, OLD_PLATFORM_DECISION_PATH), read_text(root, PLATFORM_DECISION_PATH))
    validate_runtime_authority(read_text(root, RUNTIME_DECISION_PATH), read_text(root, BUILD_APPROVAL_PATH), read_json(root, RUNTIME_MANIFEST_PATH))
    validate_ui_ai_authority(read_text(root, UI_AI_DECISION_PATH), read_json(root, UI_AI_LOADOUT_PATH))
    validate_product_authority(read_text(root, PRODUCT_DECISION_PATH), read_json(root, PRODUCT_CONTRACT_PATH), read_text(root, PRODUCT_EVIDENCE_PATH), read_text(root, STEP14_PROTOCOL_PATH), read_text(root, STEP14_RESULTS_PATH))
    validate_superseded_authority(read_text(root, RANGE_DECISION_PATH), read_text(root, OLD_TECHNIQUE_DECISION_PATH), read_json(root, OLD_TECHNIQUE_CONTRACT_PATH))
    validate_registry(registry)
    validate_mastery(mastery)
    validate_historical_audit(read_json(root, AUDIT_CONTRACT_PATH))

if __name__ == "__main__":
    try:
        validate(ROOT)
    except (CanonLifecycleError, json.JSONDecodeError, OSError) as exc:
        print(f"CANON_LIFECYCLE_ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
    print("CANON_LIFECYCLE_OK")
