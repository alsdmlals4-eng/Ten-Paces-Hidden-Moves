from __future__ import annotations

import hashlib
import json
import unittest
from pathlib import Path

from tests.test_integrated_work_contract_v48r2 import IntegratedWorkContractV48R2Tests  # noqa: F401


ROOT = Path(__file__).resolve().parents[1]
DECISION_ID = "TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01"
SOURCE_SHA256 = "3f898b7e2749a2e1900e9df48183f02d4fbc735fd0e80297f28bb09317144de4"
BOUND_SHA256 = "0cc7943594d78824d6b3390232f61f12b8199d2f9f3b8817bf9953ed5aa90061"
RECONSTRUCTION = "JOIN_PART_BYTES_WITH_SINGLE_LF_SEPARATOR"
DECISION = ROOT / "docs" / "decisions" / "2026-08-11_INTEGRATED_WORK_CONTRACT_V4_5_R2_BINDING_DECISION.md"
CONTRACT = ROOT / "docs" / "planning-data" / "approved_20260811_integrated_work_contract_v4_5_r2_binding.json"
PARTS = [
    ROOT / "docs" / "contracts" / "integrated-work-v4.5-r2" / f"part-{index:02d}.md"
    for index in range(1, 7)
]
STORED_PARTS = [
    (18909, "14836db5ac172e2fb6fdcf9ac78a86f2f0b452199f728ba88e386e174100dd3d"),
    (10535, "2d8478ac1efe7c8f9fea1b39c94f9b765036d9fe33b275b9bc6dc088a77aaa07"),
    (10234, "6169bfaeba5db007fd9d71470c0135fa8675cfcc33ac7bd8a319a3e7155c4662"),
    (12081, "e430dd1e7919597807a9560c499a8713d2b8907e74b4a14dd714cbad9c5e188c"),
    (11851, "56a2035ed9e1a5dce72ea0e9691202231ca27759453be1260ef7e123f7b79c4c"),
    (14988, "3103f7e874a96a5c80f677d7ca9cf35c0838fe5f5215cff6ad16bf24018188e2"),
]


class IntegratedWorkContractV45R2HistoryTests(unittest.TestCase):
    def test_v45r2_binding_is_retained_as_historical_evidence(self) -> None:
        self.assertTrue(DECISION.is_file())
        self.assertTrue(CONTRACT.is_file())
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(DECISION_ID, payload["decision_id"])
        self.assertEqual("4.5", payload["contract_version"])
        self.assertEqual("2026-08-11-r2", payload["revision"])
        self.assertEqual(SOURCE_SHA256, payload["source_uploaded_sha256"])
        self.assertEqual(BOUND_SHA256, payload["project_bound_sha256"])
        self.assertEqual(RECONSTRUCTION, payload["normative_body_reconstruction"])
        self.assertIn(DECISION_ID, DECISION.read_text(encoding="utf-8"))

    def test_v45r2_normative_parts_remain_byte_exact(self) -> None:
        actual_parts: list[bytes] = []
        for index, (part, expected) in enumerate(zip(PARTS, STORED_PARTS), start=1):
            self.assertTrue(part.is_file(), f"Missing historical normative body part: {part.relative_to(ROOT)}")
            data = part.read_bytes()
            actual_parts.append(data)
            expected_size, expected_hash = expected
            with self.subTest(part=index):
                self.assertEqual(expected_size, len(data))
                self.assertEqual(expected_hash, hashlib.sha256(data).hexdigest())
        reconstructed = b"\n".join(actual_parts)
        self.assertEqual(BOUND_SHA256, hashlib.sha256(reconstructed).hexdigest())
        self.assertEqual(78603, len(reconstructed))

    def test_v45r2_is_not_the_current_cold_start_decision(self) -> None:
        for relative in ("AGENTS.md", "START_HERE.md"):
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertNotIn(
                f"current_work_contract: {DECISION_ID}",
                text,
                f"{relative} must not promote historical v4.5 as current",
            )


if __name__ == "__main__":
    unittest.main()
