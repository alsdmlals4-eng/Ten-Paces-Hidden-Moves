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
        if not TOOL.is_file():
            self.skipTest("validator not implemented yet")
        validator = load_validator()
        validator.run(ROOT)

    def test_current_stage_and_node_contract(self) -> None:
        directory = ROOT / "docs/planning-data"
        duels = json.loads((directory / "poc_enemy_duels.json").read_text(encoding="utf-8"))
        map_data = json.loads((directory / "poc_map_rewards.json").read_text(encoding="utf-8"))

        ordered = sorted(duels["major_duels"], key=lambda item: item["order"])
        expected_subset = [item["id"] for item in ordered[:5]]
        self.assertEqual(expected_subset, duels["poc_runtime_subset"])
        self.assertEqual(
            ["tutorial", "stage_1", "stage_1", "stage_1", "stage_1", "stage_2", "stage_2", "stage_2", "stage_3", "stage_3"],
            [item["stage_id"] for item in ordered],
        )
        self.assertEqual("POC_PRIMARY", ordered[4]["status"])
        self.assertEqual("ultimate_access", ordered[4]["progression_unlock"]["type"])
        self.assertEqual("after_victory", ordered[4]["progression_unlock"]["timing"])

        poc = map_data["poc_slice"]
        self.assertEqual(expected_subset, poc["major_duels"])
        self.assertEqual(4, poc["gap_count"])
        self.assertEqual({"min": 2, "target": 2.5, "max": 3}, poc["intermediate_nodes_per_gap"])
        self.assertEqual({"min": 8, "target": 10, "max": 12}, poc["total_intermediate_nodes"])
        self.assertEqual({"min": 13, "target": 15, "max": 17}, poc["target_visited_nodes"])

        hidden = map_data["campaign_structure"]["hidden_duel"]
        self.assertEqual("FUTURE_HIDDEN", hidden["status"])
        self.assertEqual("after_stage_3", hidden["position"])
        self.assertFalse(hidden["required_for_main_ending"])

    def test_out_of_tolerance_budget_is_rejected(self) -> None:
        if not TOOL.is_file():
            self.skipTest("validator not implemented yet")
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
        if not TOOL.is_file():
            self.skipTest("validator not implemented yet")
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
