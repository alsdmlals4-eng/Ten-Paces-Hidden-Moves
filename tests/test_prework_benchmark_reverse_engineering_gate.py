from __future__ import annotations

import json
import pathlib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
AGENTS_PATH = ROOT / "AGENTS.md"
PROJECT_CONTRACT_PATH = ROOT / "docs" / "PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md"
DOCUMENTATION_MAP_PATH = ROOT / "[기획서]" / "00_프로젝트_허브" / "DOCUMENTATION_MAP.md"
CONTRACT_PATH = ROOT / "docs" / "planning-data" / "approved_20260805_work_governance_contract.json"
PLANNING_PATH = ROOT / "docs" / "planning-data" / "current_user_planning_status.json"
DECISION_PATH = ROOT / "docs" / "decisions" / "2026-08-30_PREWORK_BENCHMARK_REVERSE_ENGINEERING_GATE_DECISION.md"
REPORT_PATH = ROOT / "docs" / "reviews" / "2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md"
EXECUTION_REPORT_PATH = ROOT / "docs" / "operations" / "2026-08-30_PREWORK_BENCHMARK_REVERSE_ENGINEERING_GATE_EXECUTION_REPORT.md"

DECISION_ID = "TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01"
EXPECTED_GAMES = {
    "YOUR_ONLY_MOVE_IS_HUSTLE",
    "TORIBASH",
    "YOMI_2",
    "FIGHTS_IN_TIGHT_SPACES",
    "INTO_THE_BREACH",
    "SHOGUN_SHOWDOWN",
    "FOR_HONOR",
    "SAMURAI_SHODOWN",
    "HELLISH_QUART",
    "NIDHOGG_2",
    "ABSOLVER",
    "DIE_BY_THE_BLADE",
}


class PreworkBenchmarkReverseEngineeringGateTests(unittest.TestCase):
    def test_contract_requires_ten_or_more_cross_genre_comparables_before_new_work(self) -> None:
        contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
        policy = contract["benchmark_policy"]

        self.assertTrue(policy["required_before_every_project_task"])
        self.assertEqual(DECISION_ID, policy["prework_benchmark_reverse_engineering_gate_decision"])
        self.assertEqual(10, policy["minimum_unique_game_comparables_for_new_l1_plus_package"])
        self.assertEqual(3, policy["minimum_direct_comparables"])
        self.assertEqual(3, policy["minimum_adjacent_system_comparables"])
        self.assertEqual(1, policy["minimum_negative_or_mixed_case"])
        self.assertEqual(
            [
                "OFFICIAL_PRODUCT_FACT_SOURCE",
                "PLAYER_RESPONSE_SIGNAL_OR_DISCLOSED_GAP",
                "MECHANISM",
                "TRANSFER_PRINCIPLE",
                "DO_NOT_COPY_BOUNDARY",
                "ADOPT_ADAPT_AVOID_OR_TEST_DISPOSITION",
            ],
            policy["per_comparable_required_fields"],
        )
        self.assertEqual(
            "NO_SILENT_BYPASS_REUSE_ONLY_WHEN_DECISION_DIMENSION_AND_CURRENT_PROJECT_STATE_MATCH",
            policy["reuse_or_refresh_rule"],
        )

    def test_project_entrypoints_route_new_l1_plus_work_through_the_ten_game_gate(self) -> None:
        agents = AGENTS_PATH.read_text(encoding="utf-8")
        project_contract = PROJECT_CONTRACT_PATH.read_text(encoding="utf-8")

        self.assertIn("PREWORK_BENCHMARK_REVERSE_ENGINEERING_GATE", agents)
        self.assertIn(DECISION_ID, agents)
        self.assertIn(DECISION_ID, project_contract)

    def test_documentation_map_exposes_the_prework_benchmark_owner(self) -> None:
        document_map = DOCUMENTATION_MAP_PATH.read_text(encoding="utf-8")

        self.assertIn(DECISION_ID, document_map)
        self.assertIn("2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md", document_map)

    def test_current_state_exposes_the_user_directed_gate_and_initial_report(self) -> None:
        planning = json.loads(PLANNING_PATH.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, planning["prework_benchmark_gate_decision"])
        self.assertEqual(12, planning["prework_benchmark_initial_unique_game_count"])
        self.assertEqual(str(REPORT_PATH.relative_to(ROOT)).replace("\\", "/"), planning["prework_benchmark_current_report"])
        self.assertEqual(
            "DESK_RESEARCH_SYNTHESIZED_NO_TEN_PACES_HUMAN_PLAYTEST_OR_RUNTIME_CHANGE",
            planning["prework_benchmark_evidence_ceiling"],
        )

    def test_decision_and_execution_report_preserve_scope_and_evidence_boundary(self) -> None:
        decision = DECISION_PATH.read_text(encoding="utf-8")
        execution = EXECUTION_REPORT_PATH.read_text(encoding="utf-8")

        self.assertIn(DECISION_ID, decision)
        self.assertIn("10개 이상", decision)
        self.assertIn("새 L1+", decision)
        self.assertIn("구현 패키지", decision)
        self.assertIn("no silent bypass", decision)
        self.assertIn("deck/hand/draw", decision)
        self.assertIn("Human/player", execution)
        self.assertIn("NOT_RUN", execution)
        self.assertIn("CLEAN_REVIEW_EXIT", execution)

    def test_initial_reverse_engineering_report_has_twelve_officially_sourced_cases_and_non_copy_dispositions(self) -> None:
        report = REPORT_PATH.read_text(encoding="utf-8")

        self.assertIn("benchmark_entry_count: 12", report)
        self.assertIn("OFFICIAL_PRODUCT_FACT", report)
        self.assertIn("LIMITED_PLAYER_RESPONSE_SIGNAL", report)
        self.assertIn("NO_RUNTIME_OR_RULE_MUTATION", report)
        self.assertIn("DO_NOT_COPY", report)
        self.assertIn("[ADOPT]", report)
        self.assertIn("[ADAPT]", report)
        self.assertIn("[AVOID]", report)
        self.assertIn("[TEST]", report)

        actual_games = set()
        for line in report.splitlines():
            if line.startswith("### game_id: "):
                actual_games.add(line.removeprefix("### game_id: ").strip())
        self.assertEqual(EXPECTED_GAMES, actual_games)
        self.assertGreaterEqual(report.count("source_kind: OFFICIAL_PRODUCT_FACT"), 12)
        self.assertGreaterEqual(report.count("DO_NOT_COPY:"), 12)


if __name__ == "__main__":
    unittest.main()
