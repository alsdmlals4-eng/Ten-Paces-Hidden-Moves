import base64
import hashlib
import json
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MERGE = "477697842bf14d95e670f01b0fe815e384b53658"
HEAD = "8509813e0b0bb3df8f69ae5fb4baf410d02df7aa"
RECORD = ROOT / "docs/operations/2026-09-09_PR335_PROTECTED_CHANGE_APPROVAL_RECORD.md"


def test_pr335_exact_approval_is_preserved_but_not_reusable():
    raw = subprocess.check_output(
        ["git", "show", f"{MERGE}:docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"], cwd=ROOT
    )
    record = RECORD.read_text(encoding="utf-8")
    assert hashlib.sha256(raw).hexdigest().upper() in record
    assert base64.b64decode(re.search(r"```base64\n(.*?)\n```", record, re.S).group(1)) == raw
    assert json.loads(re.search(r"```json\n(.*?)\n```", record, re.S).group(1)) == json.loads(raw)
    for field in ("active_authority: false", "implementation_authority: NONE",
                  "approval_lifecycle: ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY",
                  f"implementation_merge_commit: {MERGE}", f"implementation_exact_head: {HEAD}"):
        assert field in record
    active = ROOT / "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"
    if active.exists():
        assert active.read_bytes() != raw, "retired PR335 approval cannot authorize new work"


def test_pr335_publication_evidence_is_immutable_and_locatable():
    status = json.loads((ROOT / "docs/planning-data/current_user_planning_status.json").read_text(encoding="utf-8"))
    history = status["combat_feedback_continuation"]
    assert history["implementation_pr"] == 335
    assert history["implementation_exact_head"] == HEAD
    assert history["merge_commit"] == MERGE
    assert history["remote_check_summary"] == "32_SUCCESS_0_FAILURE_0_PENDING"
    assert history["full_candidate_tests"] == {"source_commit": HEAD, "passed": 497, "duration_seconds": 335.30}
    assert history["human_android_accessibility_release"] == "NOT_RUN"
    for key in ("implementation_record", "approval_archive"):
        assert (ROOT / history[key]).is_file()
    for path in ("docs/04_ROADMAP.md", "[기획서]/00_프로젝트_허브/ROADMAP.md"):
        assert "PR #335" in (ROOT / path).read_text(encoding="utf-8")
