from __future__ import annotations

import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools/check_poc_planning_data.py"


def load_validator():
    spec = importlib.util.spec_from_file_location("poc_planning_validator", TOOL)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load PoC planning validator")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class PocPlanningDataTests(unittest.TestCase):
    def test_validator_exists(self) -> None:
        self.assertTrue(TOOL.is_file(), "PoC planning validator must exist")

    def test_current_planning_data_passes(self) -> None:
        load_validator().run(ROOT)

    def test_current_stage_node_and_mastery_contract(self) -> None:
        directory = ROOT / "docs/planning-data"
        duels = json.loads((directory / "poc_enemy_duels.json").read_text(encoding="utf-8"))
        map_data = json.loads((directory / "poc_map_rewards.json").read_text(encoding="utf-8"))
        manuals = json.loads((directory / "poc_martial_arts.json").read_text(encoding="utf-8"))

        ordered = sorted(duels["major_duels"], key=lambda item: item["order"])
        expected_subset = [item["id"] for item in ordered[:5]]
        self.assertEqual(expected_subset, duels["poc_runtime_subset"])
        self.assertEqual(
            ["tutorial", "stage_1", "stage_1", "stage_1", "stage_1", "stage_2", "stage_2", "stage_2", "stage_3", "stage_3"],
            [item["stage_id"] for item in ordered],
        )
        self.assertNotIn("progression_unlock", ordered[4])
        self.assertEqual("focused_mastery_reachability", ordered[4]["progression_milestone"]["type"])
        self.assertEqual(38, ordered[4]["progression_milestone"]["required_training_points"])

        poc = map_data["poc_slice"]
        self.assertEqual(expected_subset, poc["major_duels"])
        self.assertEqual(4, poc["gap_count"])
        self.assertEqual({"min": 2, "target": 2.5, "max": 3}, poc["intermediate_nodes_per_gap"])
        self.assertEqual({"min": 8, "target": 10, "max": 12}, poc["total_intermediate_nodes"])
        self.assertEqual({"min": 13, "target": 15, "max": 17}, poc["target_visited_nodes"])
        self.assertTrue(poc["basic_ultimates_available_from_start"])
        self.assertNotIn("first_ultimate_available_after_duel_id", poc)
        self.assertEqual(expected_subset[4], poc["focused_mastery_milestone"]["possible_before_major_duel_id"])
        self.assertEqual(38, poc["focused_mastery_milestone"]["required_training_points"])
        self.assertEqual({"major_duels_1_to_4_at_B_grade": 24, "focused_intermediate_growth": 14, "total": 38}, poc["focused_mastery_milestone"]["modeled_sources"])

        self.assertTrue(manuals["starting_rule"]["basic_ultimates_available"])
        self.assertEqual(38, manuals["progression_contract"]["focused_mastery_milestone"]["required_training_points"])

        hidden = map_data["campaign_structure"]["hidden_duel"]
        self.assertEqual("FUTURE_HIDDEN", hidden["status"])
        self.assertEqual("after_stage_3", hidden["position"])
        self.assertFalse(hidden["required_for_main_ending"])

    def test_out_of_tolerance_budget_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "docs/planning-data", root / "docs/planning-data")
            path = root / "docs/planning-data/poc_martial_arts.json"
            data = json.loads(path.read_text(encoding="utf-8"))
            technique = data["manuals"][0]["mastery"]["3"]["data"]
            technique["budget"]["variance_ticks"] = 6
            technique["budget"]["within_auto_tolerance"] = True
            path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            with self.assertRaises(validator.PlanningDataError):
                validator.run(root)

    def test_unknown_effect_scope_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "docs/planning-data", root / "docs/planning-data")
            path = root / "docs/planning-data/poc_martial_arts.json"
            data = json.loads(path.read_text(encoding="utf-8"))
            technique = data["manuals"][0]["mastery"]["3"]["data"]
            technique["effects"][0]["scope"] = "PER_BATTLE"
            path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            with self.assertRaises(validator.PlanningDataError):
                validator.run(root)

    def test_non_attack_on_hit_effect_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "docs/planning-data", root / "docs/planning-data")
            path = root / "docs/planning-data/poc_martial_arts.json"
            data = json.loads(path.read_text(encoding="utf-8"))
            technique = next(m for m in data["manuals"] if m["id"] == "clear_heart_nurturing")["mastery"]["3"]["data"]
            technique["effects"][0]["trigger"] = "ON_HIT"
            path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            with self.assertRaises(validator.PlanningDataError):
                validator.run(root)

    def test_pre_hit_modifier_must_start_before_clash(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "docs/planning-data", root / "docs/planning-data")
            path = root / "docs/planning-data/poc_martial_arts.json"
            data = json.loads(path.read_text(encoding="utf-8"))
            technique = next(m for m in data["manuals"] if m["id"] == "flowing_cloud_sword")["mastery"]["7"]["data"]
            technique["effects"][0]["trigger"] = "ON_HIT"
            path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            with self.assertRaises(validator.PlanningDataError):
                validator.run(root)

    def test_obsolete_duel_gated_ultimate_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "docs/planning-data", root / "docs/planning-data")
            path = root / "docs/planning-data/poc_enemy_duels.json"
            data = json.loads(path.read_text(encoding="utf-8"))
            ordered = sorted(data["major_duels"], key=lambda item: item["order"])
            ordered[4]["progression_unlock"] = {"type": "ultimate_access", "timing": "after_victory"}
            path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            with self.assertRaises(validator.PlanningDataError):
                validator.run(root)

    def test_invalid_intermediate_node_range_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "docs/planning-data", root / "docs/planning-data")
            path = root / "docs/planning-data/poc_map_rewards.json"
            data = json.loads(path.read_text(encoding="utf-8"))
            data["poc_slice"]["intermediate_nodes_per_gap"] = {"min": 1, "target": 2, "max": 4}
            path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            with self.assertRaises(validator.PlanningDataError):
                validator.run(root)


if __name__ == "__main__":
    unittest.main()
