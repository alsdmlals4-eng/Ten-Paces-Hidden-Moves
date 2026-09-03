from __future__ import annotations

import json
import importlib.util
import re
import sys
import tempfile
import unittest
from pathlib import Path

from pypdf import PdfReader


ROOT = Path(__file__).resolve().parents[1]
SPEC_PATH = ROOT / "docs/design/PROJECT_AI_PRODUCTION_SPEC.md"
MAP_PATH = ROOT / "[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md"
REGISTRY_PATH = ROOT / "[기획서]/DESIGN_DOCUMENT_REGISTRY.json"
GOVERNANCE_PATH = ROOT / ".github/documentation-governance.json"

PROJECT_SOURCE_SHA = "afa152b985975a3f8e6292ca0298d22a95c03872"
DELIVERY_BASELINE_SHA = "18d647c34ae8544d58d79e870f82dde1ef1d0c55"
PAIR_ID = "ten-paces-hidden-moves-20260829-afa152b"
BASELINE_PDF = "exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260829.pdf"
CURRENT_PDF = "exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf"
HISTORICAL_PDF = "exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260828.pdf"
ADDITIVE_PDF = "exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf"


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
        self.assertTrue((ROOT / BASELINE_PDF).is_file())
        self.assertTrue((ROOT / CURRENT_PDF).is_file())
        self.assertTrue((ROOT / HISTORICAL_PDF).is_file())
        self.assertIn(f"`{CURRENT_PDF}` = `CURRENT_HUMAN_DERIVED_PUBLICATION`", self.spec)
        self.assertIn("HUMAN_BLUEPRINT_ADDITIVE_20260902", self.spec)
        self.assertIn(f"`{BASELINE_PDF}` = `PRESERVED_BASELINE_SOURCE_36_PAGES`", self.spec)
        self.assertIn(f"`{HISTORICAL_PDF}` = `HISTORICAL_DERIVED_NOT_CURRENT_SOURCE`", self.spec)
        self.assertNotIn(f"`{CURRENT_PDF}` = `HISTORICAL_DERIVED_NOT_CURRENT_SOURCE`", self.spec)
        self.assertNotIn("TEN_PACES_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT_2026-09-02.pdf | current", self.doc_map)

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

    def test_current_human_master_is_additive_and_preserves_all_36_baseline_pages(self) -> None:
        """A focused visual addendum must never replace the full human blueprint."""
        baseline_path = ROOT / BASELINE_PDF
        additive_path = ROOT / CURRENT_PDF
        self.assertEqual(CURRENT_PDF, ADDITIVE_PDF)
        self.assertTrue(additive_path.is_file(), "the additive human-master PDF must be published")

        baseline = PdfReader(str(baseline_path))
        additive = PdfReader(str(additive_path))
        self.assertEqual(len(baseline.pages), 36)
        self.assertGreaterEqual(len(additive.pages), 46)
        additive_pages = [page.extract_text() for page in additive.pages]
        next_additive_index = 0
        for baseline_page in baseline.pages:
            baseline_text = baseline_page.extract_text()
            next_additive_index = additive_pages.index(baseline_text, next_additive_index) + 1

    def test_incremental_blueprint_exposes_goals_systems_case_statuses_and_visual_production_flow(self) -> None:
        """The human master must expose the new planning layers as rendered PDF content."""
        current = PdfReader(str(ROOT / CURRENT_PDF))
        rendered_text = "\n".join(page.extract_text() or "" for page in current.pages)

        # A regression that merely kept the old 46-page addendum would lose this
        # user-requested decision surface while still preserving the baseline.
        self.assertGreaterEqual(len(current.pages), 52)
        for required_heading in (
            "프로젝트 목표 · 시스템 지도",
            "단계별 FM · Flow Map",
            "준비 화면 · 구조 와이어프레임",
            "전투 화면 · 구조 와이어프레임",
            "이미지 제작 파이프라인",
            "케이스별 현재 상태",
        ):
            self.assertIn(required_heading, rendered_text)

        # The production board must communicate the requested whole-scene →
        # separated-candidate → composition progression, not just display art.
        self.assertIn("전체 장면 후보", rendered_text)
        self.assertIn("분리 후보", rendered_text)
        self.assertIn("합성 · Godot 런타임", rendered_text)

    def test_image_production_board_preserves_full_portrait_module_bounds(self) -> None:
        """Tall, transparent battler candidates must be contained rather than cropped in the production board."""
        generator_path = ROOT / "tools" / "build_frontal_duel_visual_blueprint_pdf.py"
        module_spec = importlib.util.spec_from_file_location("frontal_blueprint_generator", generator_path)
        self.assertIsNotNone(module_spec)
        module = importlib.util.module_from_spec(module_spec)
        assert module_spec.loader is not None
        module_spec.loader.exec_module(module)

        contain = getattr(module, "contain_dimensions", None)
        self.assertTrue(callable(contain), "the production board needs a portrait-safe contain geometry helper")
        self.assertEqual(contain(1024, 1536, 110, 54), (36, 54))

    def test_human_blueprint_rebuild_has_a_bounded_publication_size(self) -> None:
        """Repeated visual evidence must not turn one retained 52-page Blueprint into an oversized duplicate binary."""
        with tempfile.TemporaryDirectory(prefix="ten-paces-human-blueprint-size-") as directory:
            output = Path(directory) / "human-blueprint.pdf"
            builder_path = ROOT / "tools" / "build_human_game_blueprint_pdf.py"
            module_spec = importlib.util.spec_from_file_location("human_blueprint_builder", builder_path)
            self.assertIsNotNone(module_spec)
            module = importlib.util.module_from_spec(module_spec)
            assert module_spec.loader is not None
            sys.path.insert(0, str(builder_path.parent))
            try:
                module_spec.loader.exec_module(module)
            finally:
                sys.path.pop(0)
            module.build(output)
            self.assertLess(
                output.stat().st_size,
                32 * 1024 * 1024,
                "a current 52-page derived PDF should reuse compressed visual evidence rather than embed redundant full-resolution rasters",
            )


if __name__ == "__main__":
    unittest.main()
