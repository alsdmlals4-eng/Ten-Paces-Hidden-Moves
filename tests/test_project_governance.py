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

    def test_combat_ai_source_is_synchronized(self) -> None:
        board = json.loads(
            (ROOT / "data/combat/combat_board_poc.json").read_text(encoding="utf-8")
        )
        resolution = json.loads(
            (ROOT / "data/combat/combat_resolution_preview.json").read_text(
                encoding="utf-8"
            )
        )
        engine = board["resolution_engine"]
        self.assertEqual(17, board["schema_version"])
        self.assertEqual("public_state_ai", engine["enemy_plan_source"])
        self.assertTrue(engine["fixture_enemy_plan_allowed_when_ai_disabled"])
        self.assertNotIn("fixed_enemy_preview_plan", engine)
        self.assertEqual("public_state_ai", resolution["enemy_plan_source"])

    def test_active_operating_state_is_synchronized(self) -> None:
        expected = {
            "AGENTS.md": [
                "659c57e7ffa588ad6a6471ed9b5394985b159eaf",
                "CORE_CONFIRMED",
                "REPEAT_POC",
                "NOT_GRANTED",
            ],
            "START_HERE.md": [
                "659c57e7ffa588ad6a6471ed9b5394985b159eaf",
                "CORE_CONFIRMED",
                "REPEAT_POC",
                "NOT_GRANTED",
            ],
            "docs/BASE_RULES_VERSION.md": [
                "659c57e7ffa588ad6a6471ed9b5394985b159eaf",
                "CORE_CONFIRMED",
                "REPEAT_POC",
                "human_step14: NOT_RUN",
            ],
            "[기획서]/00_프로젝트_허브/START_HERE.md": [
                "659c57e7ffa588ad6a6471ed9b5394985b159eaf",
                "CORE_CONFIRMED",
                "REPEAT_POC",
                "NOT_GRANTED",
            ],
            "[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md": [
                "659c57e7ffa588ad6a6471ed9b5394985b159eaf",
                "CORE_CONFIRMED / PRODUCT_GATE_REPEAT_POC",
                "NOT_GRANTED / REPEAT_POC",
            ],
            "[기획서]/00_프로젝트_허브/ROADMAP.md": [
                "659c57e7ffa588ad6a6471ed9b5394985b159eaf",
                "CORE_CONFIRMED / PRODUCT_GATE_REPEAT_POC",
                "HUMAN_NOT_RUN",
                "NOT_GRANTED",
            ],
            "[기획서]/00_프로젝트_허브/HANDOFF.md": [
                "659c57e7ffa588ad6a6471ed9b5394985b159eaf",
                "CORE_CONFIRMED",
                "REPEAT_POC",
                "NOT_GRANTED",
            ],
        }
        forbidden = [
            "147a031c75e96bff170d7f99016beb9e85b12066",
            "agent/pr7-canonical-skill-refresh",
            "현재 판정: `CORE_REVIEW_PENDING`",
        ]
        for relative, required_tokens in expected.items():
            text = (ROOT / relative).read_text(encoding="utf-8")
            for token in required_tokens:
                self.assertIn(token, text, f"{relative} is missing current token {token!r}")
            for token in forbidden:
                self.assertNotIn(token, text, f"{relative} still contains stale token {token!r}")

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
