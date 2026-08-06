from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DECISION_ID = "TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01"
PARENT_DECISION_ID = "TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01"
OFFICIAL_COMMIT = "aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605"
OFFICIAL_TREE = "5d6893836af4917ee62b1a395125a7530b1f239d"
INITIAL_PROJECT_TREE = "09d040309bbed0e07420ad72c4aa69cbd0e58190"
TOOL = ROOT / "tools/check_gut_9_7_1_reconciliation.py"
CONTRACT = ROOT / "docs/planning-data/approved_20260807_gut_9_7_1_reconciliation.json"
DECISION = ROOT / "docs/decisions/2026-08-07_GUT_9_7_1_RECONCILIATION_VALIDATION_DECISION.md"
CONFIG = ROOT / ".gutconfig.json"
GUT_TEST = ROOT / "tests/gut/test_martial_manual_registry.gd"
WORKFLOW = ROOT / ".github/workflows/gut-9-7-1-reconciliation.yml"


def load_tool():
    spec = importlib.util.spec_from_file_location("gut_reconciliation", TOOL)
    if spec is None or spec.loader is None:
        raise RuntimeError("GUT reconciliation validator cannot be loaded")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class Gut971ReconciliationTests(unittest.TestCase):
    def test_scene_normalization_only_removes_load_steps_metadata(self) -> None:
        tool = load_tool()
        upstream = '[gd_scene load_steps=4 format=3 uid="uid://x"]\n\n[node name="A" type="Node"]\n'
        imported = '[gd_scene format=3 uid="uid://x"]\n\n[node name="A" type="Node"]\n'
        self.assertEqual(tool.normalize_godot_scene(upstream), tool.normalize_godot_scene(imported))
        changed = '[gd_scene format=3 uid="uid://x"]\n\n[node name="B" type="Node"]\n'
        self.assertNotEqual(tool.normalize_godot_scene(upstream), tool.normalize_godot_scene(changed))

    def test_tree_comparison_accepts_only_the_two_observed_scene_normalizations(self) -> None:
        tool = load_tool()
        with tempfile.TemporaryDirectory() as temp:
            temp_root = Path(temp)
            upstream = temp_root / "upstream"
            project = temp_root / "project"
            upstream.mkdir()
            project.mkdir()
            (upstream / "same.gd").write_text("extends Node\n", encoding="utf-8")
            (project / "same.gd").write_text("extends Node\n", encoding="utf-8")
            for name in ("GutScene.tscn", "UserFileViewer.tscn"):
                (upstream / name).write_text(
                    '[gd_scene load_steps=2 format=3 uid="uid://x"]\n\n[node name="A" type="Node"]\n',
                    encoding="utf-8",
                )
                (project / name).write_text(
                    '[gd_scene format=3 uid="uid://x"]\n\n[node name="A" type="Node"]\n',
                    encoding="utf-8",
                )
            report = tool.compare_addon_trees(project, upstream)
            self.assertEqual(report["exact_match_count"], 1)
            self.assertEqual(
                report["normalized_scene_matches"],
                ["GutScene.tscn", "UserFileViewer.tscn"],
            )
            self.assertEqual(report["unexpected_mismatches"], [])
            self.assertEqual(report["missing_from_project"], [])
            self.assertEqual(report["extra_in_project"], [])

    def test_tree_comparison_rejects_semantic_or_unexpected_differences(self) -> None:
        tool = load_tool()
        with tempfile.TemporaryDirectory() as temp:
            temp_root = Path(temp)
            upstream = temp_root / "upstream"
            project = temp_root / "project"
            upstream.mkdir()
            project.mkdir()
            (upstream / "test.gd").write_text("extends Node\n", encoding="utf-8")
            (project / "test.gd").write_text("extends RefCounted\n", encoding="utf-8")
            report = tool.compare_addon_trees(project, upstream)
            self.assertEqual(report["unexpected_mismatches"], ["test.gd"])
            with self.assertRaisesRegex(tool.ReconciliationError, "unexpected addon difference"):
                tool.require_acceptable_tree(report)

    def test_contract_records_verified_source_and_partial_authority(self) -> None:
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(payload["decision_id"], DECISION_ID)
        self.assertEqual(payload["parent_decision_id"], PARENT_DECISION_ID)
        self.assertEqual(payload["official_source"]["commit"], OFFICIAL_COMMIT)
        self.assertEqual(payload["official_source"]["addon_tree"], OFFICIAL_TREE)
        self.assertEqual(payload["initial_project_addon_tree"], INITIAL_PROJECT_TREE)
        self.assertEqual(
            payload["expected_normalized_scene_variances"],
            ["GutScene.tscn", "UserFileViewer.tscn"],
        )
        self.assertEqual(payload["authority_state"], "PARTIAL_VALIDATED_EXPORT_GATE_OPEN")
        self.assertEqual(payload["export_exclusion"], "BLOCKED_PENDING_HIGODOT_L1")
        self.assertEqual(payload["product_implementation_effect"], "NONE")

    def test_consumer_path_is_real_and_junit_is_required(self) -> None:
        config = json.loads(CONFIG.read_text(encoding="utf-8"))
        self.assertEqual(config["dirs"], ["res://tests/gut"])
        self.assertEqual(config["junit_xml_file"], "res://build/test-results/gut.xml")
        self.assertTrue(config["should_exit"])
        test_text = GUT_TEST.read_text(encoding="utf-8")
        self.assertIn("extends GutTest", test_text)
        self.assertIn("assert_eq(registry.get_manual_ids().size(), 10)", test_text)
        workflow_text = WORKFLOW.read_text(encoding="utf-8")
        for marker in (
            "bitwes/Gut",
            "v9.7.1",
            "Require exact PR head",
            "Compare installed GUT tree to official tag",
            "Hash production scope before GUT",
            "Run GUT project tests",
            "Require JUnit output",
            "Verify production hash unchanged",
        ):
            self.assertIn(marker, workflow_text)

    def test_production_hash_scope_excludes_tooling_and_outputs(self) -> None:
        tool = load_tool()
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "src").mkdir()
            (root / "src/product.gd").write_text("extends Node\n", encoding="utf-8")
            (root / "addons/gut").mkdir(parents=True)
            (root / "addons/gut/tool.gd").write_text("tool\n", encoding="utf-8")
            (root / "build/test-results").mkdir(parents=True)
            (root / "build/test-results/gut.xml").write_text("<testsuites/>\n", encoding="utf-8")
            before = tool.hash_production_scope(root)
            (root / "addons/gut/tool.gd").write_text("changed tool\n", encoding="utf-8")
            (root / "build/test-results/gut.xml").write_text("changed report\n", encoding="utf-8")
            self.assertEqual(before, tool.hash_production_scope(root))
            (root / "src/product.gd").write_text("changed product\n", encoding="utf-8")
            self.assertNotEqual(before, tool.hash_production_scope(root))

    def test_decision_and_validator_preserve_claim_ceiling(self) -> None:
        decision_text = DECISION.read_text(encoding="utf-8")
        validator_text = TOOL.read_text(encoding="utf-8")
        for marker in (
            DECISION_ID,
            "GUT_TREE_NORMALIZATION_VARIANCE",
            "PARTIAL_VALIDATED_EXPORT_GATE_OPEN",
            "BLOCKED_PENDING_HIGODOT_L1",
            "PRODUCT_IMPLEMENTATION_EFFECT_NONE",
        ):
            self.assertIn(marker, decision_text)
        self.assertIn(OFFICIAL_COMMIT, validator_text)
        self.assertIn(OFFICIAL_TREE, validator_text)
        self.assertIn(INITIAL_PROJECT_TREE, validator_text)


if __name__ == "__main__":
    unittest.main()
