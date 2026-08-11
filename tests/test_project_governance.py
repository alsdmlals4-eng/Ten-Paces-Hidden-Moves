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
        stable_snapshot_docs = [
            "AGENTS.md",
            "README.md",
            "[기획서]/00_프로젝트_허브/START_HERE.md",
            "[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md",
            "[기획서]/00_프로젝트_허브/ROADMAP.md",
            "[기획서]/00_프로젝트_허브/HANDOFF.md",
        ]
        superseded_active_tokens = [
            "product_stage: CONCEPT_APPROVAL",
            "execution_profile: PLANNING_ONLY_PROFILE",
            "runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL",
            "phase: BUILD_IN_PROGRESS",
            "implementation_authorization: GRANTED",
        ]
        for relative in stable_snapshot_docs:
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn(
                "VERTICAL_SLICE_APP_FLOW_PLANNING",
                text,
                f"{relative} is missing the current product stage",
            )
            self.assertTrue(
                any(
                    token in text
                    for token in (
                        "work_mode: REVIEW",
                        "runtime_work_mode: REVIEW",
                        "런타임 운영 기준은 `REVIEW`",
                        "런타임 기준선",
                    )
                ),
                f"{relative} is missing stable REVIEW runtime evidence",
            )
            self.assertTrue(
                any(
                    token in text
                    for token in (
                        "integration_pr: 65",
                        "runtime_integration_pr: 65",
                        "PR #65",
                    )
                ),
                f"{relative} is missing stable PR #65 runtime evidence",
            )
            for token in superseded_active_tokens:
                self.assertNotIn(token, text, f"{relative} still grants superseded state {token!r}")

        start_here_relative = "START_HERE.md"
        start_here_text = (ROOT / start_here_relative).read_text(encoding="utf-8")
        for token in (
            "current_state_owner: ACTIVE_CONTEXT",
            "current_pr_authority: GITHUB_PR_METADATA",
            "current_sheet_authority: GOOGLE_SHEET_00_02_04_99",
            "product_build_requires_user_planning_complete: true",
            "ACTIVE_CONTEXT.md",
        ):
            self.assertIn(token, start_here_text, f"{start_here_relative} is missing stable router token {token!r}")
        for mutable_key in (
            "runtime_integration_pr:",
            "planning_work_mode:",
            "runtime_implementation:",
            "latest_combat_planning_runtime:",
            "next_package:",
            "human_validation:",
        ):
            self.assertNotIn(
                mutable_key,
                start_here_text,
                f"{start_here_relative} must not duplicate mutable state {mutable_key!r}",
            )
        for token in superseded_active_tokens:
            self.assertNotIn(token, start_here_text, f"{start_here_relative} still grants superseded state {token!r}")

        active_relative = "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
        active_text = (ROOT / active_relative).read_text(encoding="utf-8")
        current_state = json.loads(
            (ROOT / "docs/planning-data/current_operating_state.json").read_text(encoding="utf-8")
        )
        current_mutable_tokens = [
            f"active_planning_pr: {current_state['active_planning_pr']}",
            f"active_approval_count: {current_state['active_approval_count']}",
            f"active_decision_state: {current_state['active_decision_state']}",
            f"next_package: {current_state['next_package']}",
            f"next_planning_decision: {current_state['next_planning_decision']}",
            current_state["source_decision"],
        ]
        for token in current_mutable_tokens:
            self.assertIn(token, active_text, f"{active_relative} is missing mutable state {token!r}")

        hub_roadmap = (
            ROOT / "[기획서]/00_프로젝트_허브/ROADMAP.md"
        ).read_text(encoding="utf-8")
        for token in current_mutable_tokens:
            self.assertIn(token, hub_roadmap, f"hub roadmap is missing mutable state {token!r}")

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
