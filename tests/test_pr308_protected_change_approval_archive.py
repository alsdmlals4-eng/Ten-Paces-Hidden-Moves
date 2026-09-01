from __future__ import annotations

import hashlib
import re
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RECORD = ROOT / "docs" / "operations" / "2026-09-01_PR308_PROTECTED_CHANGE_APPROVAL_RECORD.md"
PR308_MERGE = "ef7a48d2769b17b4632b695191a293ee40524ac4"
MANIFEST_PATH = "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"
EXPECTED_PATHS = (
    "src/combat/combat_board_preview_auto.gd",
    "src/ui/action_selection/action_selection_dock.gd",
    "src/ui/combat_progress_button.gd",
)


class Pr308ProtectedChangeApprovalArchiveTests(unittest.TestCase):
    def test_record_preserves_the_exact_original_approval_paths_and_hash(self) -> None:
        record = RECORD.read_text(encoding="utf-8")
        manifest = subprocess.check_output(
            ["git", "show", f"{PR308_MERGE}:{MANIFEST_PATH}"],
            cwd=ROOT,
        )

        self.assertIn(f"implementation_merge_commit: {PR308_MERGE}", record)
        self.assertIn(
            f"approval_manifest_sha256: {hashlib.sha256(manifest).hexdigest().upper()}",
            record,
        )
        section = re.search(
            r"approved_protected_paths_exact:\n(?P<paths>(?:  - .+\n)+)",
            record,
        )
        self.assertIsNotNone(section)
        archived_paths = tuple(re.findall(r"^  - (.+)$", section.group("paths"), re.MULTILINE))
        self.assertEqual(EXPECTED_PATHS, archived_paths)


if __name__ == "__main__":
    unittest.main()
