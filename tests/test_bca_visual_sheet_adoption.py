from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE_SHA = "c987647d01ad2baa028a16e03d85ddfc1572a727"
SHEET_ID = "1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0"


class BCAAdoptionHistoryTests(unittest.TestCase):
    def test_historical_base_marker_is_retained(self) -> None:
        for path in ("README.md", "docs/BASE_RULES_VERSION.md"):
            self.assertIn(BASE_SHA, (ROOT / path).read_text(encoding="utf-8"), path)

    def test_sheet_contract_is_migration_only(self) -> None:
        sheet = (ROOT / "docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md").read_text(encoding="utf-8")
        for token in (
            "MIGRATION_ONLY_UNTIL_REMOVAL",
            SHEET_ID,
            "LEGACY_MIGRATION_COMPATIBILITY_SOURCE",
            "NO_NEW_CANON_INPUT",
            "05_GDD_요약",
            "15_조작_게임규칙",
        ):
            self.assertIn(token, sheet)
        self.assertNotIn("workbook_role: USER_FACING_GDD_WORKSPACE", sheet)

    def test_current_project_adapter_does_not_promote_sheet_authority(self) -> None:
        adapter = json.loads((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_text(encoding="utf-8"))
        sheet = adapter["gdd_sheet"]
        self.assertEqual(SHEET_ID, sheet["id"])
        self.assertEqual("MIGRATION_ONLY_UNTIL_REMOVAL", sheet["role"])
        self.assertEqual("COMPATIBILITY_ONLY", sheet["sync_status"])
        self.assertFalse(sheet["current_authority"])

    def test_legacy_registry_is_not_current_skill_authority(self) -> None:
        current = json.loads((ROOT / "skills/SKILL_REGISTRY.json").read_text(encoding="utf-8"))
        legacy = current["legacy_registry"]
        self.assertEqual("EXPLICIT_COMPATIBILITY_REFERENCE_ONLY", legacy["role"])
        self.assertFalse(legacy["automatic_discovery"])


if __name__ == "__main__":
    unittest.main()
