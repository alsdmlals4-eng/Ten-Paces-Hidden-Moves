from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class PcFirstVerticalSliceImplementationGateTests(unittest.TestCase):
    def test_scoped_gate_allows_pc_slice_without_promoting_deferred_validation(self) -> None:
        gate_path = ROOT / "docs" / "planning-data" / "current_vertical_slice_implementation_gate_20260820.json"
        gate = json.loads(gate_path.read_text(encoding="utf-8"))

        self.assertEqual(
            "TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01",
            gate["decision_id"],
        )
        self.assertEqual("AUTHORIZED", gate["pc_first_vertical_slice_implementation"])
        self.assertEqual("BLOCKED_UNVERIFIED", gate["android_physical_device"])
        self.assertEqual("NOT_RUN", gate["human_validation"])
        self.assertEqual("BLOCKED_BY_EXISTING_PLATFORM_GATE", gate["windows_android_adapter_implementation"])
        self.assertFalse(gate["image_generation_authorized"])

    def test_current_user_status_preserves_pc_slice_history_and_current_visual_readback(self) -> None:
        status_path = ROOT / "docs" / "planning-data" / "current_user_planning_status.json"
        status = json.loads(status_path.read_text(encoding="utf-8"))

        self.assertEqual(
            "BALANCE_INSTRUMENTATION_RESULT_REVIEW_SEPARATE_DECISION_IF_NUMERICAL_CHANGE",
            status["next_phase"],
        )
        self.assertEqual(
            "BALANCE_INSTRUMENTATION_RESULT_REVIEW_SEPARATE_DECISION_IF_NUMERICAL_CHANGE",
            status["next_product_execution_surface"],
        )
        self.assertTrue(status["vertical_slice_pc_implementation_authorized"])
        self.assertFalse(status["windows_android_adapter_implementation_authorized"])
        self.assertEqual("USER_EXPLICIT_NON_IMAGE_WORK_REQUEST", status["implementation_request_source"])
        self.assertEqual(
            "USER_APPROVED_COMBAT_REFERENCE_REFERENCE_SET_20260825_OPPONENT_CHARACTER_MASTER_DOGYEOM_COMBAT_BATTLER_AND_DOGYEOM_STATUS_PORTRAIT_01_20260826_PLUS_INK_MIST_VALLEY_DUEL_01_COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01_AND_TEN_BASIC_TECHNIQUE_INK_ATLAS_01_USER_FINAL_LOCKED_MACHINE_RUNTIME_VERIFIED_20260830",
            status["final_visual_reference_status"],
        )
        self.assertEqual(
            "CONSUMER_FIRST_DOGYEOM_STATUS_PORTRAIT_IMPLEMENTED_AUTOMATED_VERIFIED_PLUS_INK_MIST_VALLEY_DUEL_01_AND_COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01_TEN_BASIC_TECHNIQUE_INK_ATLAS_01_USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_MACHINE_RUNTIME_VERIFIED_20260830",
            status["visual_asset_requirement_status"],
        )


if __name__ == "__main__":
    unittest.main()
