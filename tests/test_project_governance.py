from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_module(name: str, relative: str):
    path = ROOT / relative
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {relative}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


OPERATING = load_module("ten_paces_operating", "tools/check_project_operating_system.py")
FRESHNESS = load_module("ten_paces_freshness", "tools/check_canonical_reference_freshness.py")
SKILLS = load_module("ten_paces_skills", "tools/check_skill_package_integrity.py")


class ProjectGovernanceTests(unittest.TestCase):
    def test_current_operating_system(self) -> None:
        OPERATING.run(ROOT, ROOT / ".github/documentation-governance.json")

    def test_current_reference_freshness(self) -> None:
        FRESHNESS.run(ROOT, ROOT / ".github/reference-freshness.json")

    def test_current_skill_integrity(self) -> None:
        SKILLS.run(ROOT)

    def test_stale_current_token_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "README.md").write_text("행동 두 개", encoding="utf-8")
            config = {
                "strict_current_files": ["README.md"],
                "forbidden_current_tokens": ["행동 두 개"],
                "required_current_tokens": {},
            }
            with self.assertRaises(FRESHNESS.FreshnessError):
                FRESHNESS.validate_current_tokens(root, config)


if __name__ == "__main__":
    unittest.main()
