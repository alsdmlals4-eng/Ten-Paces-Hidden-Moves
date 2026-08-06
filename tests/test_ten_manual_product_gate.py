from __future__ import annotations

import copy
import json
import tempfile
import unittest
from pathlib import Path

from tools.validate_ten_manual_product_gate import (
    build_contract_from_manifest,
    validate_contract_document,
    validate_evidence_document,
)


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "data/cards/martial_manual_cards.json"


class TenManualProductGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
        self.contract = build_contract_from_manifest(self.manifest)
        self.valid_evidence = {
            "decision_id": "TEN_MANUAL_PRODUCT_VALIDATION_GATE",
            "head_sha": "a" * 40,
            "godot_version": "4.7.1",
            "platform": "windows-x86_64",
            "scenario_count": 50,
            "scenario_passed": 50,
            "scenario_failed": 0,
            "windows_export": "PASS",
            "windows_ci_runtime": "PASS",
            "windows_local_render": "NOT_RUN",
            "keyboard_synthetic": "PASS",
            "mouse_synthetic": "PASS",
            "gamepad_physical": "NOT_RUN",
            "resolution_matrix": "PASS",
            "accessibility_automated": "PASS",
            "accessibility_user": "NOT_RUN",
            "performance_baseline": "CAPTURED",
            "release_performance": "NOT_RUN",
            "human_step14": "NOT_RUN",
            "participant_count": 0,
            "product_gate": "PARTIAL_AUTOMATED_COMPLETE",
            "artifact": {
                "name": "ten-manual-product-validation-a",
                "workflow_run_id": "12345",
                "build_utc": "2026-08-06T00:00:00Z",
                "preset": "Windows Desktop Product Validation",
                "repository": "alsdmlals4-eng/Ten-Paces-Hidden-Moves",
                "pr": 92,
                "head_sha": "a" * 40,
            },
            "performance_environment": {
                "runner": "windows-latest",
                "godot_version": "4.7.1",
            },
        }

    def test_generated_contract_contains_exact_fifty_scenarios(self) -> None:
        errors = validate_contract_document(self.contract, self.manifest)
        self.assertEqual([], errors)
        self.assertEqual(50, len(self.contract["scenario_matrix"]))
        pairs = {
            (row["manual_id"], row["mastery"])
            for row in self.contract["scenario_matrix"]
        }
        self.assertEqual(50, len(pairs))

    def test_contract_rejects_forty_nine_scenarios(self) -> None:
        mutated = copy.deepcopy(self.contract)
        mutated["scenario_matrix"] = mutated["scenario_matrix"][:-1]
        errors = validate_contract_document(mutated, self.manifest)
        self.assertTrue(any("scenario_count" in error for error in errors), errors)

    def test_evidence_rejects_human_pass_with_zero_participants(self) -> None:
        mutated = copy.deepcopy(self.valid_evidence)
        mutated["human_step14"] = "PASS"
        errors = validate_evidence_document(
            mutated,
            self.contract,
            expected_sha="a" * 40,
        )
        self.assertTrue(any("human_step14" in error for error in errors), errors)

    def test_evidence_rejects_ci_claimed_as_local_windows_pass(self) -> None:
        mutated = copy.deepcopy(self.valid_evidence)
        mutated["windows_local_render"] = "PASS"
        errors = validate_evidence_document(
            mutated,
            self.contract,
            expected_sha="a" * 40,
        )
        self.assertTrue(any("windows_local_render" in error for error in errors), errors)

    def test_evidence_rejects_mismatched_head_sha(self) -> None:
        mutated = copy.deepcopy(self.valid_evidence)
        mutated["head_sha"] = "b" * 40
        errors = validate_evidence_document(
            mutated,
            self.contract,
            expected_sha="a" * 40,
        )
        self.assertTrue(any("head_sha" in error for error in errors), errors)

    def test_valid_automated_partial_evidence_passes(self) -> None:
        errors = validate_evidence_document(
            self.valid_evidence,
            self.contract,
            expected_sha="a" * 40,
        )
        self.assertEqual([], errors)


if __name__ == "__main__":
    unittest.main()
