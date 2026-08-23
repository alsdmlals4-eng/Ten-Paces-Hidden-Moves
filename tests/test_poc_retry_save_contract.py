from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLANNING = ROOT / "docs" / "planning-data"
CAMPAIGN_PLAN = ROOT / "docs" / "superpowers" / "plans" / "2026-07-26-poc-campaign-progression-implementation-plan.md"


class PocRetrySaveContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.run_state = json.loads((PLANNING / "poc_run_state_contract.json").read_text(encoding="utf-8"))
        self.map_data = json.loads((PLANNING / "poc_map_rewards.json").read_text(encoding="utf-8"))
        self.plan = CAMPAIGN_PLAN.read_text(encoding="utf-8")

    def test_retry_counter_is_not_rolled_back_by_pre_battle_snapshot(self) -> None:
        snapshot = self.run_state["pre_battle_snapshot"]
        retry = self.run_state["defeat_retry"]
        self.assertFalse(snapshot["includes_all_run_state_fields"])
        self.assertIn("same_battle_retry_count", snapshot["excluded_run_state_fields"])
        self.assertEqual("PRE_RETRY_COUNTER", retry["cost_basis"])
        self.assertEqual(
            "READ_COUNTER_COMPUTE_COST_CHECK_BALANCE_CHARGE_RESTORE_ROLLBACK_FIELDS_INCREMENT_COUNTER_PERSIST",
            retry["transition_order"],
        )
        self.assertEqual("PREVIOUS_PLUS_ONE_AFTER_RESTORE", retry["counter_update"])
        self.assertTrue(retry["paid_currency_is_not_rolled_back"])

    def test_save_contract_binds_payload_to_deterministic_runtime_catalog_identity(self) -> None:
        compatibility = self.run_state["save_compatibility"]
        self.assertEqual("runtime_catalog_digest", compatibility["save_field"])
        self.assertEqual("SHA256_CANONICAL_JSON", compatibility["digest_algorithm"])
        self.assertEqual("INCOMPATIBLE_SAVE_CATALOG", compatibility["mismatch_result"])
        self.assertIn("generated_at", compatibility["excluded_nondeterministic_fields"])
        self.assertIn("created_at", compatibility["excluded_nondeterministic_fields"])
        for source in (
            "poc_martial_arts.json",
            "poc_enemy_duels.json",
            "poc_map_rewards.json",
            "poc_balance_budget.json",
            "poc_run_state_contract.json",
        ):
            self.assertIn(source, compatibility["canonical_source_files"])

    def test_grade_rounding_owner_and_implementation_plan_agree(self) -> None:
        calculation = self.map_data["performance_grade"]["calculation"]
        self.assertEqual("ROUND_HALF_UP_PER_DIMENSION", calculation["rounding"])
        self.assertIn("ROUND_HALF_UP_PER_DIMENSION", self.plan)
        self.assertIn("54.5 / 69.5 / 84.5", self.plan)

    def test_route_verification_budget_is_fail_closed_at_1024_seeds(self) -> None:
        generation = self.map_data["generation_contract"]
        self.assertEqual(1024, generation["minimum_property_test_seed_count"])
        self.assertIn("1,024", self.plan)
        self.assertNotIn("at least ten seeds", self.plan)


if __name__ == "__main__":
    unittest.main()
