from __future__ import annotations

import importlib.util
import json
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

    def test_stale_current_token_is_rejected_even_with_appended_override(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "README.md").write_text(
                "한 칸에 한 전투원\n\n## 최신 갱신\n한 칸 최대 2인",
                encoding="utf-8",
            )
            config = {
                "strict_current_files": ["README.md"],
                "forbidden_current_tokens": ["한 칸에 한 전투원"],
                "required_current_tokens": {"README.md": ["한 칸 최대 2인"]},
            }
            with self.assertRaises(FRESHNESS.FreshnessError):
                FRESHNESS.validate_current_tokens(root, config)

    def test_board_schema_drift_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "data/combat").mkdir(parents=True)
            (root / "registry").mkdir(parents=True)
            (root / "data/combat/combat_board_poc.json").write_text(
                json.dumps({"schema_version": 15}), encoding="utf-8"
            )
            expected_ids = ["skill-a", "skill-b"]
            (root / "registry/SKILL_REGISTRY.json").write_text(
                json.dumps(
                    {
                        "base_integration": {
                            "commit": "a" * 40,
                            "shared_skill_routes": {
                                "a": "skill-a",
                                "b": "skill-b",
                            },
                        },
                        "skills": [{}, {}, {}, {}],
                    }
                ),
                encoding="utf-8",
            )
            config = {
                "board_contract_path": "data/combat/combat_board_poc.json",
                "expected_board_schema_version": 16,
                "skill_registry_path": "registry/SKILL_REGISTRY.json",
                "expected_base_commit": "a" * 40,
                "expected_base_skill_ids": expected_ids,
            }
            with self.assertRaises(FRESHNESS.FreshnessError):
                FRESHNESS.validate_structured_contracts(root, config)

    def test_stale_base_commit_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "data/combat").mkdir(parents=True)
            (root / "registry").mkdir(parents=True)
            (root / "data/combat/combat_board_poc.json").write_text(
                json.dumps({"schema_version": 16}), encoding="utf-8"
            )
            (root / "registry/SKILL_REGISTRY.json").write_text(
                json.dumps(
                    {
                        "base_integration": {
                            "commit": "b" * 40,
                            "shared_skill_routes": {"a": "skill-a"},
                        },
                        "skills": [{}, {}, {}, {}],
                    }
                ),
                encoding="utf-8",
            )
            config = {
                "board_contract_path": "data/combat/combat_board_poc.json",
                "expected_board_schema_version": 16,
                "skill_registry_path": "registry/SKILL_REGISTRY.json",
                "expected_base_commit": "a" * 40,
                "expected_base_skill_ids": ["skill-a"],
            }
            with self.assertRaises(FRESHNESS.FreshnessError):
                FRESHNESS.validate_structured_contracts(root, config)

    def test_missing_or_duplicate_base_route_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "data/combat").mkdir(parents=True)
            (root / "registry").mkdir(parents=True)
            (root / "data/combat/combat_board_poc.json").write_text(
                json.dumps({"schema_version": 16}), encoding="utf-8"
            )
            (root / "registry/SKILL_REGISTRY.json").write_text(
                json.dumps(
                    {
                        "base_integration": {
                            "commit": "a" * 40,
                            "shared_skill_routes": {
                                "a": "skill-a",
                                "b": "skill-a",
                            },
                        },
                        "skills": [{}, {}, {}, {}],
                    }
                ),
                encoding="utf-8",
            )
            config = {
                "board_contract_path": "data/combat/combat_board_poc.json",
                "expected_board_schema_version": 16,
                "skill_registry_path": "registry/SKILL_REGISTRY.json",
                "expected_base_commit": "a" * 40,
                "expected_base_skill_ids": ["skill-a", "skill-b"],
            }
            with self.assertRaises(FRESHNESS.FreshnessError):
                FRESHNESS.validate_structured_contracts(root, config)


if __name__ == "__main__":
    unittest.main()
