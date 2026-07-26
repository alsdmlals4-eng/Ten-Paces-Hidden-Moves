from __future__ import annotations

import importlib.util
import json
import shutil
import tempfile
import unittest
from contextlib import contextmanager
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools/check_poc_planning_data.py"
PLANNING = ROOT / "docs/planning-data"


def load_validator():
    spec = importlib.util.spec_from_file_location("poc_planning_validator", TOOL)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load PoC planning validator")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


@contextmanager
def mutated_root():
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        shutil.copytree(PLANNING, root / "docs/planning-data")
        yield root


def read_json(root: Path, name: str) -> dict:
    return json.loads((root / "docs/planning-data" / name).read_text(encoding="utf-8"))


def write_json(root: Path, name: str, data: dict) -> None:
    (root / "docs/planning-data" / name).write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


class PocPlanningDataTests(unittest.TestCase):
    def setUp(self) -> None:
        self.validator = load_validator()

    def assert_rejected(self, root: Path) -> None:
        with self.assertRaises(self.validator.PlanningDataError):
            self.validator.run(root)

    def test_validator_exists(self) -> None:
        self.assertTrue(TOOL.is_file(), "PoC planning validator must exist")

    def test_current_planning_data_passes(self) -> None:
        self.validator.run(ROOT)

    def test_current_stage_node_and_mastery_contract(self) -> None:
        duels = json.loads((PLANNING / "poc_enemy_duels.json").read_text(encoding="utf-8"))
        map_data = json.loads((PLANNING / "poc_map_rewards.json").read_text(encoding="utf-8"))
        manuals = json.loads((PLANNING / "poc_martial_arts.json").read_text(encoding="utf-8"))

        ordered = sorted(duels["major_duels"], key=lambda item: item["order"])
        expected_subset = [item["id"] for item in ordered[:5]]
        self.assertEqual(expected_subset, duels["poc_runtime_subset"])
        self.assertEqual(
            ["tutorial", "stage_1", "stage_1", "stage_1", "stage_1", "stage_2", "stage_2", "stage_2", "stage_3", "stage_3"],
            [item["stage_id"] for item in ordered],
        )
        self.assertNotIn("progression_unlock", ordered[4])
        self.assertEqual("focused_mastery_reachability", ordered[4]["progression_milestone"]["type"])

        poc = map_data["poc_slice"]
        self.assertEqual(expected_subset, poc["major_duels"])
        self.assertEqual(4, poc["gap_count"])
        self.assertEqual({"min": 2, "target": 2.5, "max": 3}, poc["intermediate_nodes_per_gap"])
        self.assertEqual({"min": 8, "target": 10, "max": 12}, poc["total_intermediate_nodes"])
        self.assertEqual({"min": 13, "target": 15, "max": 17}, poc["target_visited_nodes"])
        self.assertTrue(poc["basic_ultimates_available_from_start"])
        self.assertEqual(38, poc["focused_mastery_milestone"]["required_training_points"])

        self.assertTrue(manuals["starting_rule"]["basic_ultimates_available"])
        self.assertEqual(38, manuals["progression_contract"]["focused_mastery_milestone"]["required_training_points"])

    def test_out_of_tolerance_budget_is_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_martial_arts.json")
            technique = data["manuals"][0]["mastery"]["3"]["data"]
            technique["budget"]["variance_ticks"] = 6
            technique["budget"]["within_auto_tolerance"] = True
            write_json(root, "poc_martial_arts.json", data)
            self.assert_rejected(root)

    def test_unknown_effect_scope_is_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_martial_arts.json")
            data["manuals"][0]["mastery"]["3"]["data"]["effects"][0]["scope"] = "PER_BATTLE"
            write_json(root, "poc_martial_arts.json", data)
            self.assert_rejected(root)

    def test_invalid_intermediate_node_range_is_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_map_rewards.json")
            data["poc_slice"]["intermediate_nodes_per_gap"] = {"min": 1, "target": 2, "max": 4}
            write_json(root, "poc_map_rewards.json", data)
            self.assert_rejected(root)

    def test_non_attack_on_hit_effect_is_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_martial_arts.json")
            data["manuals"][4]["mastery"]["3"]["data"]["effects"][0]["trigger"] = "ON_HIT"
            write_json(root, "poc_martial_arts.json", data)
            self.assert_rejected(root)

    def test_pre_hit_modifier_must_start_before_clash(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_martial_arts.json")
            effect = data["manuals"][0]["mastery"]["7"]["data"]["effects"][0]
            effect["trigger"] = "ON_HIT"
            write_json(root, "poc_martial_arts.json", data)
            self.assert_rejected(root)

    def test_obsolete_duel_gated_ultimate_is_rejected(self) -> None:
        with mutated_root() as root:
            duels = read_json(root, "poc_enemy_duels.json")
            map_data = read_json(root, "poc_map_rewards.json")
            duels["stage_contract"]["stage_1"]["first_ultimate_available_after_duel_order"] = 5
            duels["major_duels"][4]["progression_unlock"] = {
                "type": "ultimate_access",
                "timing": "after_victory",
                "scope": "first_available",
            }
            map_data["poc_slice"]["first_ultimate_available_after_duel_id"] = duels["major_duels"][4]["id"]
            write_json(root, "poc_enemy_duels.json", duels)
            write_json(root, "poc_map_rewards.json", map_data)
            self.assert_rejected(root)

    # CE-01
    def test_unknown_patch_field_and_forged_tick_delta_are_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_martial_arts.json")
            patch = data["manuals"][0]["mastery"]["5"]
            patch["changes"]["not_a_real_field"] = 999
            patch["added_budget_ticks"] = 999
            write_json(root, "poc_martial_arts.json", data)
            self.assert_rejected(root)

    # CE-02
    def test_unknown_effect_condition_is_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_martial_arts.json")
            data["manuals"][1]["mastery"]["7"]["data"]["effects"][0]["condition"] = "invented_condition"
            write_json(root, "poc_martial_arts.json", data)
            self.assert_rejected(root)

    # CE-03
    def test_medical_source_drift_between_manual_and_map_is_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_map_rewards.json")
            source = next(item for item in data["medical"]["planned_sources"] if item["source"] == "clear_heart_nurturing" and item["at_mastery"] == 5)
            source["amount"] = 4
            write_json(root, "poc_map_rewards.json", data)
            self.assert_rejected(root)

    # CE-04
    def test_unknown_ai_phase_condition_and_effect_are_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_enemy_duels.json")
            data["major_duels"][0]["phase_change"] = {"condition": "typo_condition", "effect": "typo_effect"}
            write_json(root, "poc_enemy_duels.json", data)
            self.assert_rejected(root)

    # CE-05
    def test_negative_money_and_malformed_duel_reward_are_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_enemy_duels.json")
            reward = data["major_duels"][0]["reward"]
            reward["money"] = -100
            reward["context_reward"] = "???"
            write_json(root, "poc_enemy_duels.json", data)
            self.assert_rejected(root)

    # CE-06 + UDR-03
    def test_reward_options_and_two_38_point_paths_are_structured(self) -> None:
        data = json.loads((PLANNING / "poc_map_rewards.json").read_text(encoding="utf-8"))
        self.assertIn("major_duel_reward_options", data)
        options = {item["id"]: item for item in data["major_duel_reward_options"]["options"]}
        self.assertEqual(6, options["free_training_6"]["total_value"])
        self.assertEqual(8, options["focused_training_5_plus_3"]["total_value"])
        self.assertEqual(10, options["faction_manual_mastery_3"]["comparison_value"])
        paths = data["poc_slice"]["focused_mastery_milestone"]["validated_paths"]
        self.assertEqual(38, paths["focused_rewards_plus_guaranteed_nodes"]["total"])
        self.assertEqual(38, paths["free_rewards_plus_high_efficiency_nodes"]["total"])

    def test_broken_38_point_path_is_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_map_rewards.json")
            self.assertIn("major_duel_reward_options", data)
            option = next(item for item in data["major_duel_reward_options"]["options"] if item["id"] == "focused_training_5_plus_3")
            option["designated_points"] = 0
            option["free_points"] = 0
            option["total_value"] = 0
            write_json(root, "poc_map_rewards.json", data)
            self.assert_rejected(root)

    # CE-07
    def test_each_performance_dimension_weight_must_be_in_range(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_map_rewards.json")
            dimensions = data["performance_grade"]["dimensions"]
            keys = list(dimensions)
            if isinstance(dimensions[keys[0]], dict):
                dimensions[keys[0]]["weight"] = 130
                dimensions[keys[1]]["weight"] = -30
                for key in keys[2:]:
                    dimensions[key]["weight"] = 0
            else:
                dimensions[keys[0]] = 130
                dimensions[keys[1]] = -30
                for key in keys[2:]:
                    dimensions[key] = 0
            write_json(root, "poc_map_rewards.json", data)
            self.assert_rejected(root)

    # CE-08
    def test_empty_node_catalog_is_rejected(self) -> None:
        with mutated_root() as root:
            data = read_json(root, "poc_map_rewards.json")
            data["node_types"] = {}
            data["node_catalog"] = {}
            write_json(root, "poc_map_rewards.json", data)
            self.assert_rejected(root)

    def test_normalized_card_and_budget_ledger_contract_exists(self) -> None:
        data = json.loads((PLANNING / "poc_martial_arts.json").read_text(encoding="utf-8"))
        for manual in data["manuals"]:
            for star in ("3", "7", "10"):
                technique = manual["mastery"][star]["data"]
                self.assertIn(technique["category"], {"attack", "response", "move", "recovery", "strengthen"})
                self.assertIn("resolution_phase", technique)
                self.assertIn("targeting_mode", technique)
                self.assertIn("movement", technique)
                self.assertIn("attack", technique)
                self.assertTrue(technique["budget"]["ledger"])

    def test_ai_profiles_have_executable_bundle_templates(self) -> None:
        data = json.loads((PLANNING / "poc_enemy_duels.json").read_text(encoding="utf-8"))
        self.assertGreater(float(data["ai_contract"]["score_window"]), 0)
        for duel in data["major_duels"]:
            profile = duel["ai_profile"]
            self.assertTrue(profile["weights"])
            self.assertTrue(profile["bundle_templates"])
            self.assertIn(profile["fallback_action_id"], duel["candidate_actions"])

    def test_paid_retry_run_state_contract(self) -> None:
        path = PLANNING / "poc_run_state_contract.json"
        self.assertTrue(path.is_file())
        data = json.loads(path.read_text(encoding="utf-8"))
        retry = data["defeat_retry"]
        self.assertEqual([1, 2, 3], retry["permanent_currency_costs_same_battle"])
        self.assertEqual(3, retry["cost_cap"])
        self.assertEqual("WHEN_ENTERING_DIFFERENT_BATTLE", retry["counter_reset"])
        self.assertEqual("PRE_BATTLE_RUN_STATE", retry["restore_snapshot"])
        self.assertTrue(retry["same_seed"])

    def test_sure_hit_is_stack_based_and_consumed_only_when_bypassing_evade(self) -> None:
        data = json.loads((PLANNING / "poc_balance_budget.json").read_text(encoding="utf-8"))
        policy = data["effect_contract"]["sure_hit_stack_policy"]
        self.assertEqual("ONE_STACK_PER_EFFECTIVE_HIT", policy["unit"])
        self.assertEqual("BYPASSES_AVAILABLE_EVADE", policy["consume_when"])
        self.assertEqual("UNTIL_CONSUMED_OR_BATTLE_END", policy["persistence"])
        self.assertIn("CLASH_CANCELLED", policy["does_not_consume_on"])

    def test_manual_acquisition_and_duplicate_conversion_are_structured(self) -> None:
        data = json.loads((PLANNING / "poc_martial_arts.json").read_text(encoding="utf-8"))
        contract = data["acquisition_contract"]
        self.assertTrue(contract["starting_selection"]["activate_one_star_passive"])
        self.assertEqual(3, contract["new_manual_grant"]["starting_mastery"])
        self.assertEqual(10, contract["duplicate_manual_grant"]["designated_training_points"])

    def test_planning_json_is_canonically_pretty_printed(self) -> None:
        for path in sorted(PLANNING.glob("*.json")):
            value = json.loads(path.read_text(encoding="utf-8"))
            expected = json.dumps(value, ensure_ascii=False, indent=2) + "\n"
            self.assertEqual(expected, path.read_text(encoding="utf-8"), path.name)


if __name__ == "__main__":
    unittest.main()
