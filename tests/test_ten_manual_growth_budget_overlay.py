import copy
import json
import math
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json"
CHECKER = ROOT / "tools/check_ten_manual_growth_budget_overlay.py"
SOURCE = ROOT / "docs/planning-data/approved_20260804_existing_action_reprice_contract.json"

LEGACY_ALIASES = {
    "falling_petal_chasing_sword": "mount_hua_plum_blossom_sword",
    "rebounding_vajra_fist": "shaolin_arhat_vajra_art",
    "four_ounces_move_thousand_pounds": "wudang_taiji_sword",
    "chained_road_lock": "yang_family_spear",
    "returning_qi_meridian": "mount_hua_purple_mist_art",
    "ten_paces_position_reversal": "xiaoyao_lingbo_footwork",
}
NEW_STAR7 = {
    "beggars_dragon_subduing_palm",
    "sichuan_tang_hidden_weapons",
    "hebei_peng_five_tigers_saber",
    "nangong_boundless_sky_sword",
}
ALL_MANUALS = set(LEGACY_ALIASES.values()) | NEW_STAR7


class TenManualGrowthBudgetOverlayTest(unittest.TestCase):
    def load_contract(self) -> dict:
        self.assertTrue(CONTRACT.is_file(), "ten-manual growth budget contract is missing")
        return json.loads(CONTRACT.read_text(encoding="utf-8"))

    def run_checker(self, contract_path: Path = CONTRACT) -> subprocess.CompletedProcess[str]:
        self.assertTrue(CHECKER.is_file(), "ten-manual budget checker is missing")
        return subprocess.run(
            [sys.executable, str(CHECKER), "--contract", str(contract_path)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def mutate(self, edit) -> Path:
        data = copy.deepcopy(self.load_contract())
        edit(data)
        temp = tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8")
        json.dump(data, temp, ensure_ascii=False, indent=2)
        temp.write("\n")
        temp.close()
        return Path(temp.name)

    def assert_mutation_rejected(self, edit, expected: str):
        path = self.mutate(edit)
        result = self.run_checker(path)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(expected, result.stdout + result.stderr)

    def test_contract_and_checker_exist(self):
        self.assertTrue(CONTRACT.is_file())
        self.assertTrue(CHECKER.is_file())

    def test_approved_contract_passes(self):
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("TEN_MANUAL_GROWTH_BUDGET_OVERLAY_PASS", result.stdout)

    def test_pricing_snapshot_matches_current_authority(self):
        pricing = self.load_contract()["pricing"]
        self.assertEqual(pricing["movement_ticks_per_tile"], 15)
        self.assertEqual(pricing["range_ticks_per_tile_beyond_one"], 15)
        self.assertEqual(pricing["stamina_allowance_ticks_per_point"], 4)
        self.assertEqual(pricing["internal_allowance_ticks_per_point"], 7)
        self.assertEqual(pricing["slot_budget_ticks"], {"1": 20, "2": 50, "3": 80})
        self.assertEqual(pricing["automatic_tolerance_ticks"], 5)

    def test_legacy_aliases_preserve_source_budgets_then_integrate_plus_ten(self):
        data = self.load_contract()
        source = json.loads(SOURCE.read_text(encoding="utf-8"))
        source_rows = {row["action_id"]: row for row in source["actions"]}
        self.assertEqual(data["legacy_star7_aliases"], LEGACY_ALIASES)
        for source_id, manual_id in LEGACY_ALIASES.items():
            row = data["star7_profiles"][manual_id]
            source_budget = source_rows[source_id]["available_budget_ticks"]
            self.assertEqual(row["source_action_id"], source_id)
            self.assertEqual(row["effective_existing_budget_ticks"], source_budget)
            self.assertEqual(row["star7_final_budget_ticks"], source_budget + 10)
            self.assertEqual(row["star9_bonus_ticks"], 10 + math.floor((source_budget + 10) * 0.20))
            self.assertEqual(row["star9_total_budget_ticks"], row["star7_final_budget_ticks"] + row["star9_bonus_ticks"])

    def test_four_new_star7_profiles_are_complete_and_balanced(self):
        data = self.load_contract()
        self.assertEqual(set(data["new_star7_manual_ids"]), NEW_STAR7)
        self.assertEqual(set(data["star7_profiles"]), ALL_MANUALS)
        for manual_id in NEW_STAR7:
            row = data["star7_profiles"][manual_id]
            self.assertEqual(row["source_type"], "NEW_APPROVED_PROFILE")
            self.assertEqual(row["star7_final_budget_ticks"], row["available_budget_ticks"])
            self.assertLessEqual(abs(row["variance_ticks"]), 5)
            self.assertEqual(row["star9_bonus_ticks"], 10 + math.floor(row["star7_final_budget_ticks"] * 0.20))

    def test_all_ten_ultimate_profiles_are_complete_and_balanced(self):
        profiles = self.load_contract()["ultimate_profiles"]
        self.assertEqual(set(profiles), ALL_MANUALS)
        for manual_id, row in profiles.items():
            for key in [
                "action_slots",
                "stamina_cost",
                "internal_cost",
                "movement_tiles",
                "max_range",
                "base_effect_ticks_excluding_distance",
                "distance_effect_ticks",
                "condition_allowance_ticks",
                "other_resource_allowance_ticks",
                "effect_cost_ticks",
                "available_budget_ticks",
                "variance_ticks",
            ]:
                self.assertIsInstance(row[key], int, f"{manual_id}:{key}")
            self.assertLessEqual(abs(row["variance_ticks"]), 5, manual_id)

    def test_budget_formula_is_slot_resource_condition_other(self):
        data = self.load_contract()
        pricing = data["pricing"]
        for table_name in ["star7_profiles", "ultimate_profiles"]:
            for manual_id, row in data[table_name].items():
                if row.get("source_type") == "LEGACY_ALIAS":
                    continue
                expected_distance = (
                    row["movement_tiles"] * pricing["movement_ticks_per_tile"]
                    + max(0, row["max_range"] - 1) * pricing["range_ticks_per_tile_beyond_one"]
                )
                expected_effect = row["base_effect_ticks_excluding_distance"] + expected_distance
                expected_available = (
                    pricing["slot_budget_ticks"][str(row["action_slots"])]
                    + row["stamina_cost"] * pricing["stamina_allowance_ticks_per_point"]
                    + row["internal_cost"] * pricing["internal_allowance_ticks_per_point"]
                    + row["condition_allowance_ticks"]
                    + row["other_resource_allowance_ticks"]
                )
                self.assertEqual(row["distance_effect_ticks"], expected_distance, manual_id)
                self.assertEqual(row["effect_cost_ticks"], expected_effect, manual_id)
                self.assertEqual(row["available_budget_ticks"], expected_available, manual_id)
                self.assertEqual(row["variance_ticks"], expected_effect - expected_available, manual_id)

    def test_scope_remains_planning_only(self):
        scope = self.load_contract()["scope_boundary"]
        self.assertFalse(scope["product_code_changed"])
        self.assertFalse(scope["godot_scene_changed"])
        self.assertFalse(scope["html_poc_changed"])
        self.assertFalse(scope["runtime_data_changed"])
        self.assertEqual(scope["human_balance_validation"], "NOT_RUN")

    def test_rejects_alias_or_plus_ten_drift(self):
        self.assert_mutation_rejected(
            lambda d: d["legacy_star7_aliases"].update({"rebounding_vajra_fist": "beggars_dragon_subduing_palm"}),
            "TEN_MANUAL_LEGACY_ALIAS_CONFLICT",
        )
        self.assert_mutation_rejected(
            lambda d: d["star7_profiles"]["shaolin_arhat_vajra_art"].update({"star7_final_budget_ticks": 76}),
            "TEN_MANUAL_STAR7_FORMULA_CONFLICT",
        )

    def test_rejects_new_profile_or_ultimate_formula_drift(self):
        self.assert_mutation_rejected(
            lambda d: d["star7_profiles"]["beggars_dragon_subduing_palm"].update({"available_budget_ticks": 999}),
            "TEN_MANUAL_BUDGET_FORMULA_CONFLICT",
        )
        self.assert_mutation_rejected(
            lambda d: d["ultimate_profiles"]["mount_hua_purple_mist_art"].update({"variance_ticks": 12}),
            "TEN_MANUAL_VARIANCE_CONFLICT",
        )

    def test_rejects_scope_drift(self):
        self.assert_mutation_rejected(
            lambda d: d["scope_boundary"].update({"runtime_data_changed": True}),
            "TEN_MANUAL_BUDGET_SCOPE_CONFLICT",
        )


if __name__ == "__main__":
    unittest.main()
