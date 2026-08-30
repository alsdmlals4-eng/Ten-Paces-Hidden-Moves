from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC_PATH = ROOT / "docs/design/PROJECT_AI_PRODUCTION_SPEC.md"
MAP_PATH = ROOT / "[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md"
REGISTRY_PATH = ROOT / "[기획서]/DESIGN_DOCUMENT_REGISTRY.json"
GOVERNANCE_PATH = ROOT / ".github/documentation-governance.json"

PROJECT_SOURCE_SHA = "afa152b985975a3f8e6292ca0298d22a95c03872"
DELIVERY_BASELINE_SHA = "18d647c34ae8544d58d79e870f82dde1ef1d0c55"
PAIR_ID = "ten-paces-hidden-moves-20260829-afa152b"
CURRENT_PDF = "exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260829.pdf"
HISTORICAL_PDF = "exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260828.pdf"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


class HumanGameBlueprintProfileContract(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.spec = read(SPEC_PATH)
        cls.doc_map = read(MAP_PATH)
        cls.registry = json.loads(read(REGISTRY_PATH))
        cls.governance = json.loads(read(GOVERNANCE_PATH))

    def test_exactly_two_current_master_roles_and_snapshot_lineage(self) -> None:
        match = re.search(
            r"### 00\.3 MASTER ARTIFACT ROLES\n(?P<body>.*?)\n### 00\.4 ",
            self.spec,
            flags=re.DOTALL,
        )
        self.assertIsNotNone(match, "master-role section must precede the reader route")
        roles = re.findall(
            r"^\| `(AI_PRODUCTION_SPEC_MARKDOWN|HUMAN_MASTER_GDD_PDF)` \|",
            match.group("body"),
            flags=re.MULTILINE,
        )
        self.assertEqual(roles, ["AI_PRODUCTION_SPEC_MARKDOWN", "HUMAN_MASTER_GDD_PDF"])
        self.assertIn(f"pair_id: {PAIR_ID}", self.spec)
        self.assertIn(f"project_sha: {PROJECT_SOURCE_SHA}", self.spec)
        self.assertIn(f"delivery_lineage_commit: {DELIVERY_BASELINE_SHA}", self.spec)
        self.assertTrue((ROOT / CURRENT_PDF).is_file())
        self.assertTrue((ROOT / HISTORICAL_PDF).is_file())
        self.assertIn(f"`{CURRENT_PDF}` = `CURRENT_PAIRED_DERIVED_PUBLICATION`", self.spec)
        self.assertIn(f"`{HISTORICAL_PDF}` = `HISTORICAL_DERIVED_NOT_CURRENT_SOURCE`", self.spec)
        self.assertNotIn(f"`{CURRENT_PDF}` = `HISTORICAL_DERIVED_NOT_CURRENT_SOURCE`", self.spec)

    def test_layered_reader_route_and_reusable_contracts(self) -> None:
        required = (
            "HUMAN_GAME_BLUEPRINT_GDD_LAYERED_PROFILE",
            "NO_SEPARATE_BLUEPRINT_ARTIFACT",
            "PROJECT_PLAYER_LAYER",
            "SYSTEM_LAYER",
            "CONTENT_UX_PRESENTATION_LAYER",
            "PRODUCTION_EVIDENCE_LAYER",
            "3-MINUTE PROJECT / PLAYER READ",
            "10-MINUTE SYSTEM + CONTENT / UX / PRESENTATION READ",
            "DETAIL READ",
            "IMPLEMENTATION READ",
            "VERIFICATION READ",
            "REUSABLE_FLOW_AND_SYSTEM_CARDS",
            "STATE_AND_EVIDENCE_LEGEND",
        )
        for token in required:
            self.assertIn(token, self.spec)
            if token in required[:11]:
                self.assertIn(token, self.doc_map)
        route_positions = [self.spec.index(token) for token in required[6:11]]
        self.assertEqual(route_positions, sorted(route_positions))

    def test_current_consumers_are_not_inverted(self) -> None:
        positive = (
            "CURRENT_RUNTIME_CONSUMED_FIELDS | `signature_manual_id`, `signature_star_seed`, "
            "`runtime_archetype_id`, `basic_action_focus_ids`, `final_stat_total_seed` | "
            "current loadout/route/result plus Issue #267 per-combat binding, derived stats, and planner consumer"
        )
        negative = (
            "MEASURED_BY_VALIDATION_ONLY_INSTRUMENTATION_NOT_NUMERICALLY_DECIDED | profile weights, "
            "derived stat total, player/loadout/policy/seed outcome distribution | schema 2 4,500-row coverage "
            "is merged historical machine evidence. Successor `TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-"
            "POLICY-COVERAGE-01` is merged in PR #292 with remote CI PASS and schema 3 six-archetype 6,750-row "
            "byte-identical machine evidence; PR #293 archived the one-time approval and has exact-main readback, "
            "and it is not a numerical balance decision."
        )
        self.assertIn(positive, self.spec)
        self.assertIn(negative, self.spec)
        self.assertNotIn(
            "CURRENT_RUNTIME_CONSUMED_FIELDS | `behavior_focus`, `basic_action_focus_ids`, `final_stat_total_seed`",
            self.spec,
        )
        self.assertNotIn(
            "NOT_CONSUMED_BY_COMBAT_PERSONALITY_OR_STATS | `signature_manual_id`, `signature_star_seed`",
            self.spec,
        )
        self.assertNotIn(
            "NOT_CONSUMED_BY_COMBAT_PERSONALITY_OR_STATS | `behavior_focus`, "
            "`basic_action_focus_ids`, `final_stat_total_seed` | Issue #267 future binding",
            self.spec,
        )
        self.assertIn("IMPLEMENTED_MERGED_MAIN_PR273_POSTMERGE_READBACK", self.spec)
        self.assertIn("MACHINE_RUNTIME_VERIFIED_FOR_BINDING; BALANCE_SIMULATION_NOT_RUN", self.spec)

    def test_prospective_gate_grandfathers_only_issue_267(self) -> None:
        lifecycle = (
            "PLAN -> REQUIRED_IMAGE_AND_MATERIAL_PREPARATION -> "
            "BLUEPRINT_REVIEW_PUBLICATION -> USER_FINAL_REVIEW_APPROVAL -> IMPLEMENTATION_START"
        )
        for owner in (self.spec, self.doc_map):
            self.assertIn(lifecycle, owner)
            self.assertIn("ISSUE267_EXISTING_APPROVED_PACKAGE_GRANDFATHERED_NON_RETROACTIVE", owner)
            self.assertIn("LATER_PACKAGES_REQUIRE_BLUEPRINT_REVIEW_AND_USER_FINAL_APPROVAL", owner)
            self.assertIn("NO_POST_ADOPTION_IMPLEMENTATION_PACKAGE_BEFORE_USER_FINAL_APPROVAL", owner)
            self.assertIn("EXISTING_MERGED_RUNTIME_FACTS_NO_ROLLBACK", owner)
            self.assertNotIn("ISSUE267_HANDOFF_READY_DOES_NOT_BYPASS_USER_FINAL_APPROVAL", owner)
        self.assertIn("IMAGE_MODEL_REQUIRED_FOR_IMAGE_CREATION_OR_EDITING", self.spec)
        self.assertIn("TEXT_NATIVE_EXACT_DIAGRAMS", self.spec)

    def test_registry_adds_ai_spec_without_false_pdf_generator(self) -> None:
        matches = [
            entry
            for entry in self.registry["documents"]
            if entry["source_path"] == "../docs/design/PROJECT_AI_PRODUCTION_SPEC.md"
        ]
        self.assertEqual(len(matches), 1)
        entry = matches[0]
        self.assertEqual(entry["status"], "ACTIVE")
        self.assertEqual(entry["source_role"], "narrative_spec")
        self.assertEqual(entry["publication_policy"], "source_only")
        self.assertIsNone(entry["output_pdf"])
        self.assertIsNone(entry["publication_manifest"])
        self.assertIsNone(entry["generator"])
        serialized = json.dumps(self.registry, ensure_ascii=False)
        self.assertNotIn(CURRENT_PDF, serialized)
        self.assertNotIn(HISTORICAL_PDF, serialized)
        self.assertNotIn("BLUEPRINT", serialized.upper())

    def test_governance_required_sources_exactly_match_registry_sources(self) -> None:
        registry_sources = {
            (REGISTRY_PATH.parent / entry["source_path"])
            .resolve()
            .relative_to(ROOT)
            .as_posix()
            for entry in self.registry["documents"]
        }
        configured_sources = set(self.governance["required_design_sources"])
        self.assertEqual(configured_sources, registry_sources)


if __name__ == "__main__":
    unittest.main()
