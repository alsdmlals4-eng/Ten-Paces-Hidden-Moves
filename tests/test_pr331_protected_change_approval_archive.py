import base64
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MERGE = "bf161025b63edd7eb441b2c4f2ae9da5155f68da"


def test_pr331_approval_bytes_and_retired_authority():
    raw = subprocess.check_output(["git", "show", f"{MERGE}:docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"], cwd=ROOT)
    record = (ROOT / "docs/operations/2026-09-08_PR331_PROTECTED_CHANGE_APPROVAL_RECORD.md").read_text(encoding="utf-8")
    assert hashlib.sha256(raw).hexdigest().upper() in record
    assert base64.b64decode(re.search(r"```base64\n(.*?)\n```", record, re.S).group(1)) == raw
    assert json.loads(re.search(r"```json\n(.*?)\n```", record, re.S).group(1)) == json.loads(raw)
    assert "active_authority: false" in record
    assert "implementation_authority: NONE" in record
    assert "ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY" in record
    assert f"implementation_merge_commit: {MERGE}" in record
    active = ROOT / "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"
    if active.exists():
        assert active.read_bytes() != raw, "the exact retired PR331 approval must not be reactivated"


def test_pr331_current_owners_describe_merged_scope_and_next_gap():
    active = (ROOT / "[기획서]" / "00_프로젝트_허브" / "ACTIVE_CONTEXT.md").read_text(encoding="utf-8")
    status = json.loads((ROOT / "docs/planning-data/current_user_planning_status.json").read_text(encoding="utf-8"))
    assert MERGE in active
    assert "branch-local" not in active.split("## 현재 기준", 1)[1].split("\n\n", 1)[0]
    inline = status["inline_combat_results_continuation"]
    assert inline["integration_status"] == "MAIN_MERGED_VERIFIED"
    assert inline["merge_commit"] == MERGE
    assert "native-input complete campaign verification" not in status["constraint_continuation"]["remaining"]
    assert "IMPLEMENTED_LEGACY" not in status["user_directed_planning_status"]
    assert status["next_product_execution_surface"] == "BLUEPRINT_SAVE_CONTINUE_AND_EVENT_STATUS_REWARD_CANON_GAPS"
    assert status["next_phase"] == "BLUEPRINT_SAVE_CONTINUE_AND_EVENT_STATUS_REWARD_CANON_GAPS"


def test_pr331_linked_current_routing_fields_are_aligned():
    active = (ROOT / "[기획서]" / "00_프로젝트_허브" / "ACTIVE_CONTEXT.md").read_text(encoding="utf-8")
    operating = json.loads((ROOT / "docs/planning-data/current_operating_state.json").read_text(encoding="utf-8"))
    next_gap = "BLUEPRINT_SAVE_CONTINUE_AND_EVENT_STATUS_REWARD_CANON_GAPS"
    merged_status = "THREE_BRANCH_FOUR_CHOICE_JIANGHU_USER_APPROVED_CURRENT_DOCUMENTATION_AND_CANDIDATE_ATLAS_MACHINE_VERIFIED_RUNTIME_ROUTE_SINGLE_EXECUTE_INLINE_CAUSAL_AND_TERMINAL_RESULT_SURFACES_MAIN_MERGED_VERIFIED_HUMAN_ANDROID_ACCESSIBILITY_RELEASE_NOT_RUN"
    assert f"next_package: {next_gap}" in active
    assert f"user_directed_planning_next_package: {next_gap}" in active
    assert f"user_directed_planning_status: {merged_status}" in active
    # PR331 remains historical merged evidence; a scoped verified successor may
    # advance the live operating package without rewriting the archived approval.
    assert f"next_package: {operating['next_package']}" in active
    assert f"active_decision_state: {operating['active_decision_state']}" in active
    status = json.loads((ROOT / "docs/planning-data/current_user_planning_status.json").read_text(encoding="utf-8"))
    assert status["durable_continue_continuation"]["decision"] == operating["source_decision"]
    assert (ROOT / status["durable_continue_continuation"]["implementation_record"]).is_file()
