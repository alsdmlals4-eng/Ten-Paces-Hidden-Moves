from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / "tools" / "classify_ci_scope.py"
SPEC = importlib.util.spec_from_file_location("classify_ci_scope", MODULE_PATH)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("cannot load classify_ci_scope.py")
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class CiScopeTests(unittest.TestCase):
    def test_docs_only_change(self) -> None:
        self.assertEqual("docs", MODULE.classify(["README.md", "docs/01_GAME_DESIGN.md"]))

    def test_mixed_change_is_code(self) -> None:
        self.assertEqual("code", MODULE.classify(["docs/01_GAME_DESIGN.md", "src/combat/a.gd"]))

    def test_workflow_change_is_code(self) -> None:
        self.assertEqual("code", MODULE.classify([".github/workflows/documentation-governance.yml"]))

    def test_empty_change_defaults_to_code(self) -> None:
        self.assertEqual("code", MODULE.classify([]))


if __name__ == "__main__":
    unittest.main()
