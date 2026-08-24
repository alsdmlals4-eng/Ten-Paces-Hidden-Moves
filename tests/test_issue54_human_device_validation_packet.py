import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "docs/validation/TEN_PACES_UX_UI_FIXTURE_CATALOG.md"
PACKET = ROOT / "docs/validation/TEN_PACES_UX_UI_VALIDATION_PACKET.md"
CONTRACT = ROOT / "docs/planning-data/current_issue54_human_device_validation_packet.json"


class Issue54HumanDeviceValidationPacketTests(unittest.TestCase):
    def test_required_artifacts_exist(self):
        self.assertTrue(FIXTURE.is_file(), "Issue #54 fixture catalog must exist")
        self.assertTrue(PACKET.is_file(), "Issue #54 executable validation packet must exist")
        self.assertTrue(CONTRACT.is_file(), "Issue #54 structured validation contract must exist")

    def test_fixture_catalog_covers_core_ux_failure_modes(self):
        text = FIXTURE.read_text(encoding="utf-8")
        for token in (
            "3수 → 해결 → 3수 → 해결 → 4수 → 해결",
            "VALID_SELECTION",
            "RANGE_INSUFFICIENT",
            "RESOURCE_INSUFFICIENT",
            "INVALID_TARGET",
            "SLOT_COLLISION",
            "PLAN_ORDER_CHANGES_RESULT",
            "CLASH_CAUSAL_CHAIN",
            "LONG_KOREAN_TEXT",
            "CONFIRMED_VS_UNCERTAIN_INTENT",
            "SHARED_PLAYER_AI_MARTIAL_POOL",
            "BAD_CONTENT_ASYMMETRY",
        ):
            self.assertIn(token, text)

    def test_validation_packet_preserves_evidence_boundaries(self):
        text = PACKET.read_text(encoding="utf-8")
        for token in (
            "tools/collect_godot_live_evidence.ps1",
            "QA Evidence Studio",
            "Windows visible local",
            "physical gamepad",
            "Android actual device",
            "accessibility user",
            "Human fun/readability/immersion",
            "5명 중 4명 이상",
            "15명 상대 식별성",
            "focused",
            "selected",
            "[합]",
            "BAD_CONTENT_ASYMMETRY",
            "NOT_RUN",
            "자동 증거는 Human PASS를 대신하지 않는다",
        ):
            self.assertIn(token, text)

    def test_structured_contract_is_machine_readable_and_non_promotional(self):
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(payload["issue_number"], 54)
        self.assertEqual(payload["status"], "READY_FOR_HUMAN_DEVICE_EXECUTION")
        self.assertFalse(payload["runtime_mutation_authorized"])
        self.assertEqual(payload["human_validation"]["target_participants"], 5)
        self.assertEqual(payload["human_validation"]["pass_threshold"], 4)
        self.assertEqual(payload["windows_visible_local_usability"], "NOT_RUN")
        self.assertEqual(payload["physical_gamepad"], "NOT_RUN")
        self.assertEqual(payload["android_physical_device"], "NOT_RUN")
        self.assertEqual(payload["accessibility_user"], "NOT_RUN")
        self.assertEqual(payload["human_fun_readability_immersion"], "NOT_RUN")
        self.assertEqual(payload["fifteen_opponent_identifiability"], "NOT_RUN")
        self.assertEqual(payload["release_performance"], "NOT_RUN")
        self.assertEqual(payload["shared_player_ai_martial_pool"]["enemy_exclusive_manuals_allowed"], False)
        self.assertEqual(payload["shared_player_ai_martial_pool"]["enemy_exclusive_techniques_allowed"], False)
        self.assertEqual(payload["shared_player_ai_martial_pool"]["remaining_four_acquisition_paths"], "NOT_ASSERTED_IMPLEMENTED")

        close_requirements = payload["close_issue_only_when"]
        self.assertIn("physical_gamepad_has_real_evidence", close_requirements)
        self.assertIn("accessibility_user_has_real_evidence", close_requirements)
        self.assertIn("fifteen_opponent_identifiability_has_real_evidence", close_requirements)
        self.assertFalse(any("declared_shipping" in item for item in close_requirements))
        self.assertFalse(any("explicit_release_scope_decision" in item for item in close_requirements))


if __name__ == "__main__":
    unittest.main()
