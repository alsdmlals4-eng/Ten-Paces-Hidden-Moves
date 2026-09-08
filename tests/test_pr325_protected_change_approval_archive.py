import base64
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MERGE = "12fe75ca795c9af640a58eff975e2a6cbe02888d"


def test_pr325_approval_bytes_and_retired_authority():
    raw = subprocess.check_output(["git", "show", f"{MERGE}:docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"], cwd=ROOT)
    record = (ROOT / "docs/operations/2026-09-08_PR325_PROTECTED_CHANGE_APPROVAL_RECORD.md").read_text(encoding="utf-8")
    assert hashlib.sha256(raw).hexdigest().upper() in record
    assert base64.b64decode(re.search(r"```base64\n(.*?)\n```", record, re.S).group(1)) == raw
    assert json.loads(re.search(r"```json\n(.*?)\n```", record, re.S).group(1)) == json.loads(raw)
    assert "active_authority: false" in record
    assert "implementation_authority: NONE" in record
    assert "ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY" in record
    # History must remain valid when a later scoped approval or baseline is adopted.
    assert f"implementation_merge_commit: {MERGE}" in record
