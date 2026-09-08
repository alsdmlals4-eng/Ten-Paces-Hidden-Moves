import hashlib
import json
import re
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MERGE = "81ef0f0b2ede9cd63d6a2aba521a645efc1d4e5f"


class Pr322ArchiveTests(unittest.TestCase):
    def test_exact_manifest_is_retained_as_history_not_live_authority(self):
        raw = subprocess.check_output(["git", "show", f"{MERGE}:docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"], cwd=ROOT)
        original = json.loads(raw)
        record = (ROOT / "docs/operations/2026-09-08_PR322_PROTECTED_CHANGE_APPROVAL_RECORD.md").read_text(encoding="utf-8")
        self.assertIn(f"implementation_merge_commit: {MERGE}", record)
        self.assertIn(hashlib.sha256(raw).hexdigest().upper(), record)
        archived = json.loads(re.search(r"```json\n(.*?)\n```", record, re.S).group(1))
        self.assertEqual(original, archived)
        self.assertIn("NOT_CURRENT_EXECUTION_AUTHORITY", record)
        self.assertIn("active_authority: false", record)
        self.assertIn("implementation_authority: NONE", record)


if __name__ == "__main__":
    unittest.main()
