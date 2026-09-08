import base64
import hashlib
import json
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MERGE = "fe720f5dce686ea5b2ff68a1ec078d53544a0e92"
HEAD = "baabfc7ae6a29f6ebc47ea5644a110bc7258fc38"
RECORD = ROOT / "docs/operations/2026-09-09_PR333_PROTECTED_CHANGE_APPROVAL_RECORD.md"


def test_pr333_approval_bytes_are_archived_and_authority_is_retired():
    raw = subprocess.check_output(
        ["git", "show", f"{MERGE}:docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"],
        cwd=ROOT,
    )
    record = RECORD.read_text(encoding="utf-8")
    assert hashlib.sha256(raw).hexdigest().upper() in record
    assert base64.b64decode(re.search(r"```base64\n(.*?)\n```", record, re.S).group(1)) == raw
    assert json.loads(re.search(r"```json\n(.*?)\n```", record, re.S).group(1)) == json.loads(raw)
    assert "active_authority: false" in record
    assert "implementation_authority: NONE" in record
    assert "approval_lifecycle: ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY" in record
    assert f"implementation_merge_commit: {MERGE}" in record
    assert f"implementation_exact_head: {HEAD}" in record
    active = ROOT / "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"
    if active.exists():
        assert active.read_bytes() != raw, "the exact retired PR333 approval must not be reactivated"


def test_pr333_current_mutable_owners_are_aligned_to_verified_successor():
    active = (ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md").read_text(encoding="utf-8")
    operating = json.loads((ROOT / "docs/planning-data/current_operating_state.json").read_text(encoding="utf-8"))
    status = json.loads((ROOT / "docs/planning-data/current_user_planning_status.json").read_text(encoding="utf-8"))
    durable = status["durable_continue_continuation"]

    for key in (
        "active_planning_work_mode",
        "active_planning_pr",
        "active_planning_parent_pr",
        "active_approval_count",
        "active_decision_state",
        "next_package",
        "next_planning_decision",
    ):
        assert f"{key}: {operating[key]}" in active
    assert f"user_directed_planning_next_package: {operating['next_package']}" in active
    assert f"user_directed_planning_next_decision: {operating['next_planning_decision']}" in active
    assert durable["decision"] == "TEN-DEC-20260909-MARTIAL-ACTOR-BINDING-CORRECTION-01"
    assert durable["integration_status"] == "MAIN_MERGED_VERIFIED_PR333"
    assert durable["implementation_pr"] == 333
    assert durable["implementation_exact_head"] == HEAD
    assert durable["merge_commit"] == MERGE
    assert durable["remote_check_summary"] == "32_SUCCESS_0_CURRENT_FAILURE_0_PENDING_PLUS_HISTORICAL_MISSING_LABEL_FAILURE"
    assert status["next_phase"] == operating["next_package"]
    assert status["next_product_execution_surface"] == operating["next_package"]


def test_pr333_roadmaps_and_execution_record_preserve_merged_evidence_and_evidence_ceiling():
    detailed = (ROOT / "docs/04_ROADMAP.md").read_text(encoding="utf-8")
    hub = (ROOT / "[기획서]/00_프로젝트_허브/ROADMAP.md").read_text(encoding="utf-8")
    report = (ROOT / "docs/operations/2026-09-08_DURABLE_SAVE_EXECUTION_REPORT.md").read_text(encoding="utf-8")

    assert "docs/operations/2026-09-08_DURABLE_SAVE_EXECUTION_REPORT.md" in detailed
    assert "../../../docs/04_ROADMAP.md" in hub
    assert "PR #333" in detailed and "PR #333" in hub
    assert "PR #333" in report
    assert MERGE in report
    assert "34265224533" in report and "34265510529" in report

    closeout = report.split("## PR #333 merge and one-time approval closeout — 2026-09-09", 1)[1]
    merged_run = closeout.split("The controller's approval-aware root wrapper", 1)[1].split("\n\n", 1)[0]
    assert "without imported Godot metadata failed with missing global classes and was terminated" in merged_run
    assert "it is not a product-test PASS" in merged_run
    assert "After that import, `python -m pytest -q` passed **490 tests in 329.82s**" in merged_run
    assert "45 ObjectDB and 22 resource teardown warnings" in merged_run

    evidence_ceiling = closeout.split("The next safe package", 1)[1].split("\n\n", 1)[0]
    assert "Human play/physical input/audio quality" in evidence_ceiling
    assert "whole Blueprint completion" in evidence_ceiling
    assert "those remain `NOT_RUN`" in evidence_ceiling
