from __future__ import annotations

import importlib.util
import json
import re
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

    def test_external_reference_freshness_allowlist_is_historical_and_scoped(self) -> None:
        config = json.loads(
            (ROOT / ".github/reference-freshness.json").read_text(encoding="utf-8")
        )
        self.assertEqual(
            [
                ".github/reference-freshness.json",
                "docs/operations/2026-08-28_ADVERSARIAL_RESEARCH_FEASIBILITY_GATE_EXECUTION_REPORT.md",
            ],
            config.get("allowed_legacy_globs"),
            "Only the checker configuration and its preserved 2026-08-28 evidence may retain the retired skill path.",
        )

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

    def test_active_combat_docs_use_current_implementation_baseline(self) -> None:
        current_baseline = "659c57e7ffa588ad6a6471ed9b5394985b159eaf"
        stale_baseline = "147a031c75e96bff170d7f99016beb9e85b12066"
        implementation_docs = [
            "docs/02_COMBAT_RULES.md",
            "docs/05_COMBAT_POC_SPEC.md",
            "docs/09_COMBAT_SYSTEM_ARCHITECTURE.md",
        ]
        for relative in implementation_docs:
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn(current_baseline, text, f"{relative} is missing implementation baseline")
            self.assertNotIn(stale_baseline, text, f"{relative} still uses stale baseline")

        checklist = (ROOT / "docs/08_TEST_CHECKLIST.md").read_text(encoding="utf-8")
        self.assertIn(
            "자동 제품 검증 증거 기준:",
            checklist,
            "docs/08_TEST_CHECKLIST.md must identify its separate product-evidence baseline",
        )
        self.assertNotIn(stale_baseline, checklist)

        for relative in ["docs/02_COMBAT_RULES.md", "docs/09_COMBAT_SYSTEM_ARCHITECTURE.md"]:
            text = (ROOT / relative).read_text(encoding="utf-8")
            for token in ["public_state_ai", "enemy_bundles", "ai_enabled == false"]:
                self.assertIn(token, text, f"{relative} is missing fixture boundary {token!r}")

    def test_active_app_flow_operating_state_is_synchronized(self) -> None:
        stable_router_docs = [
            "AGENTS.md",
            "README.md",
            "START_HERE.md",
            "[기획서]/00_프로젝트_허브/START_HERE.md",
            "[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md",
        ]
        forbidden_mutable_snapshots = [
            "product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING",
            "runtime_integration_pr: 65",
            "next_package: VERTICAL_SLICE_APP_FLOW_SHELL",
            "current_sheet_authority: GOOGLE_SHEET_00_02_04_99",
            "product_stage: CONCEPT_APPROVAL",
            "execution_profile: PLANNING_ONLY_PROFILE",
            "runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL",
            "phase: BUILD_IN_PROGRESS",
            "implementation_authorization: GRANTED",
        ]
        for relative in stable_router_docs:
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn(
                "ACTIVE_CONTEXT.md",
                text,
                f"{relative} cannot discover the mutable state authority",
            )
            for token in forbidden_mutable_snapshots:
                self.assertNotIn(
                    token,
                    text,
                    f"{relative} must not duplicate mutable/current snapshot {token!r}",
                )

        start_here_text = (ROOT / "START_HERE.md").read_text(encoding="utf-8")
        for token in (
            "current_state_owner: ACTIVE_CONTEXT",
            "current_pr_authority: GITHUB_PR_METADATA",
            "current_human_workspace: REPOSITORY_HUMAN_FACING_CANON",
            "current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME",
            "google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL",
            "current_work_contract: TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01",
            "ACTIVE_CONTEXT.md",
        ):
            self.assertIn(token, start_here_text, f"START_HERE.md is missing stable router token {token!r}")
        for mutable_key in (
            "runtime_integration_pr:",
            "planning_work_mode:",
            "runtime_implementation:",
            "latest_combat_planning_runtime:",
            "next_package:",
            "human_validation:",
            "current_sheet_authority:",
        ):
            self.assertNotIn(
                mutable_key,
                start_here_text,
                f"START_HERE.md must not duplicate mutable state {mutable_key!r}",
            )

        active_relative = "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
        active_text = (ROOT / active_relative).read_text(encoding="utf-8")
        current_state = json.loads(
            (ROOT / "docs/planning-data/current_operating_state.json").read_text(encoding="utf-8")
        )
        mutable_keys = (
            "active_planning_work_mode",
            "active_planning_pr",
            "active_planning_parent_pr",
            "active_approval_count",
            "active_decision_state",
            "next_package",
            "next_planning_decision",
        )
        for key in mutable_keys:
            token = f"{key}: {current_state[key]}"
            self.assertIn(token, active_text, f"{active_relative} is missing mutable state {token!r}")
        self.assertIn(current_state["source_decision"], active_text)

        for roadmap_relative in (
            "docs/04_ROADMAP.md",
            "[기획서]/00_프로젝트_허브/ROADMAP.md",
        ):
            roadmap_text = (ROOT / roadmap_relative).read_text(encoding="utf-8")
            self.assertIn("ACTIVE_CONTEXT", roadmap_text)
            self.assertIn("current_state_owner: ACTIVE_CONTEXT_PLUS_CURRENT_JSON", roadmap_text)
            self.assertIn(current_state["source_decision"], roadmap_text)
            for key in mutable_keys:
                self.assertIsNone(
                    re.search(rf"(?m)^{re.escape(key)}:\s*", roadmap_text),
                    f"{roadmap_relative} duplicates mutable operating state: {key}",
                )

        for token in [
            "TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01",
            "TEN-DEC-20260801-SITUATION-SCREEN-01",
            "runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92",
            "automated_validation: PASS",
            "human_validation: NOT_RUN",
            "2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md",
        ]:
            self.assertIn(token, active_text, f"{active_relative} is missing state token {token!r}")

        discovery_consumers = [
            "AGENTS.md",
            "START_HERE.md",
            "[기획서]/00_프로젝트_허브/START_HERE.md",
            "[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md",
            "[기획서]/00_프로젝트_허브/ROADMAP.md",
            "[기획서]/00_프로젝트_허브/HANDOFF.md",
        ]
        for relative in discovery_consumers:
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn(
                "ACTIVE_CONTEXT.md",
                text,
                f"{relative} cannot discover the mutable planning-state authority",
            )

        self.assertNotIn("phase: BUILD_IN_PROGRESS", active_text)
        self.assertNotIn("implementation_authorization: GRANTED", active_text)

    def test_v6_authority_and_pr45_integration_files_exist(self) -> None:
        required = [
            "docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md",
            "docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER_PART1A.md",
            "docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER_PART1B.md",
            "docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER_PART2.md",
            "docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER_PART3.md",
            "docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md",
        ]
        for relative in required:
            path = ROOT / relative
            self.assertTrue(path.is_file(), f"missing v6 authority file: {relative}")
            text = path.read_text(encoding="utf-8")
            self.assertNotIn("<LARGE_CONTENT_PLACEHOLDER>", text)
            self.assertNotIn("TODO", text)
            self.assertNotIn("TBD", text)

    def test_superseded_build_documents_are_historical_pointers(self) -> None:
        expected = {
            "docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md": "SUPERSEDED_REFERENCE",
            "docs/decisions/2026-07-26_REVIEW_COMPLETE_AND_BUILD_ENTRY.md": "SUPERSEDED_REFERENCE",
        }
        for relative, token in expected.items():
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn(token, text)
            self.assertIn("2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md", text)

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
            (root / "registry/SKILL_REGISTRY.json").write_text(
                json.dumps(
                    {
                        "base_integration": {
                            "commit": "a" * 40,
                            "shared_skill_routes": {"a": "skill-a", "b": "skill-b"},
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
                            "shared_skill_routes": {"a": "skill-a", "b": "skill-a"},
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
