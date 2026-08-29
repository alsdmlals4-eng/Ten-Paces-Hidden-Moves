from __future__ import annotations

import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ADAPTER_PATH = ROOT / "skills/PROJECT_BASE_ADAPTER.json"
COMPATIBILITY_VIEWS = (
    ROOT / "skills/BASE_V9_ADAPTER.json",
    ROOT / "skills/PROJECT_BASE_SKILL_ADAPTER.json",
)


class CanonicalAdapterProtectedBaselineAuthorityTests(unittest.TestCase):
    def test_canonical_adapter_uses_ancestry_authority_and_refreshes_views(self) -> None:
        adapter = json.loads(ADAPTER_PATH.read_text(encoding="utf-8"))
        baseline = adapter["protected_baseline"]

        self.assertEqual("CANONICAL_ADAPTER_SOURCE", baseline["policy_source_type"])
        self.assertEqual("skills/PROJECT_BASE_ADAPTER.json", baseline["policy_source_path"])

        adapter_hash = hashlib.sha256(ADAPTER_PATH.read_bytes()).hexdigest()
        for view_path in COMPATIBILITY_VIEWS:
            view = json.loads(view_path.read_text(encoding="utf-8"))
            self.assertEqual("GENERATED_COMPATIBILITY_VIEW", view["artifact_role"])
            self.assertEqual("skills/PROJECT_BASE_ADAPTER.json", view["canonical_source"])
            self.assertEqual(adapter_hash, view["canonical_source_sha256"])


if __name__ == "__main__":
    unittest.main()
