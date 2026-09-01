from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from datetime import UTC, datetime, timedelta
from hashlib import sha256
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "register_runtime_visual_capture.py"
MANIFEST = ROOT / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json"
DECISION = ROOT / "docs" / "decisions" / "2026-09-01_RUNTIME_VISUAL_CAPTURE_EVIDENCE_POLICY_DECISION.md"
VISUAL_GATE = ROOT / "docs" / "19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md"
RECEIPT_ROLE = "TEN_RUNTIME_VISUAL_CAPTURE_PRODUCER_RECEIPT"
DEFAULT_RUN_ID = "TEN-CAPTURE-RUN-20260902-001"


class RuntimeVisualCaptureContractTests(unittest.TestCase):
    source_commit = "a" * 40

    def _write_png(self, path: Path, *, width: int = 1280, height: int = 800) -> None:
        path.write_bytes(
            b"\x89PNG\r\n\x1a\n"
            + b"\x00\x00\x00\x0dIHDR"
            + width.to_bytes(4, "big")
            + height.to_bytes(4, "big")
            + b"\x08\x06\x00\x00\x00"
            + b"\x00\x00\x00\x00"
            + b"\x00\x00\x00\x00IEND\xaeB`\x82"
        )

    def _write_producer_receipt(
        self,
        receipt_path: Path,
        source: Path,
        *,
        run_id: str = DEFAULT_RUN_ID,
        source_commit: str | None = None,
        producer_status: str = "PASS",
        started_at: datetime | None = None,
        completed_at: datetime | None = None,
        digest: str | None = None,
        byte_count: int | None = None,
        mtime_ns: int | None = None,
        artifact_path: str | None = None,
    ) -> Path:
        receipt_path.parent.mkdir(parents=True, exist_ok=True)
        observed = source.stat()
        source_mtime = datetime.fromtimestamp(observed.st_mtime_ns / 1_000_000_000, UTC)
        started_at = started_at or (source_mtime - timedelta(seconds=1))
        completed_at = completed_at or (source_mtime + timedelta(seconds=1))
        payload = {
            "schema_version": 1,
            "receipt_role": RECEIPT_ROLE,
            "producer_id": "TEST_RUNTIME_CAPTURE_PRODUCER",
            "producer_status": producer_status,
            "run_id": run_id,
            "source_commit": source_commit or self.source_commit,
            "started_at_utc": started_at.isoformat(),
            "completed_at_utc": completed_at.isoformat(),
            "artifact": {
                "path": artifact_path or source.name,
                "sha256": digest or sha256(source.read_bytes()).hexdigest(),
                "bytes": observed.st_size if byte_count is None else byte_count,
                "mtime_ns": observed.st_mtime_ns if mtime_ns is None else mtime_ns,
            },
        }
        receipt_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        return receipt_path

    def _run(
        self,
        project_root: Path,
        source: Path,
        capture_id: str,
        *extra: str,
        receipt: Path | None = None,
        run_id: str = DEFAULT_RUN_ID,
    ) -> subprocess.CompletedProcess[str]:
        consumer = project_root / "src" / "combat" / "combat_board_preview.gd"
        consumer.parent.mkdir(parents=True, exist_ok=True)
        consumer.write_text("# capture-test consumer\n", encoding="utf-8")
        command = [
            sys.executable,
            "-S",
            str(SCRIPT),
            "--project-root",
            str(project_root),
            "--source-image",
            str(source),
            "--capture-id",
            capture_id,
            "--source-commit",
            self.source_commit,
            "--scene-path",
            "res://scenes/combat/combat_board_preview.tscn",
            "--capture-state",
            "combat_preview_normal",
            "--entry-route",
            "normal_combat_preview",
            "--work-item-id",
            "TEN-DESIGN-TEST-001",
            "--consumer",
            "src/combat/combat_board_preview.gd",
            "--diagnostics-errors",
            "0",
            "--diagnostics-warnings",
            "0",
        ]
        if receipt is not None:
            command.extend(["--producer-receipt", str(receipt), "--run-id", run_id])
        command.extend(extra)
        return subprocess.run(
            command,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_policy_and_manifest_define_repository_controlled_runtime_capture(self) -> None:
        self.assertTrue(DECISION.is_file(), f"missing policy Decision: {DECISION}")
        self.assertTrue(MANIFEST.is_file(), f"missing manifest: {MANIFEST}")
        self.assertTrue(VISUAL_GATE.is_file(), f"missing visual gate: {VISUAL_GATE}")

        decision_text = DECISION.read_text(encoding="utf-8")
        gate_text = VISUAL_GATE.read_text(encoding="utf-8")
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))

        self.assertIn("TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01", decision_text)
        self.assertIn("CAPTURE_NOT_APPLICABLE_NO_RUNTIME_CONSUMER", decision_text)
        self.assertIn("PRIOR_ARTIFACT_EXISTENCE_IS_NOT_FRESH_EVIDENCE", decision_text)
        self.assertIn("PRODUCER_RECEIPT_REQUIRED", decision_text)
        self.assertIn("MACHINE_RUNTIME_CAPTURE", decision_text)
        self.assertIn("TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01", gate_text)
        self.assertEqual("TEN_RUNTIME_VISUAL_CAPTURE_MANIFEST", manifest["manifest_role"])
        self.assertIsInstance(manifest["captures"], list)

    def test_registrar_requires_a_current_producer_receipt(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "source.png"
            self._write_png(source)

            result = self._run(project_root, source, "TEN-RVC-20260901-001")
            self.assertNotEqual(0, result.returncode)
            self.assertIn("producer-receipt", result.stderr)
            self.assertFalse((project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json").exists())

    def test_registrar_copies_png_and_records_exact_runtime_evidence_boundary(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "source.png"
            receipt = Path(temporary) / "producer-receipt.json"
            self._write_png(source)
            self._write_producer_receipt(receipt, source)

            result = self._run(
                project_root,
                source,
                "TEN-RVC-20260901-001",
                receipt=receipt,
            )
            self.assertEqual(0, result.returncode, result.stderr)

            manifest_path = project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            self.assertEqual("TEN_RUNTIME_VISUAL_CAPTURE_MANIFEST", manifest["manifest_role"])
            entry = manifest["captures"][0]
            self.assertEqual("TEN-RVC-20260901-001", entry["capture_id"])
            self.assertEqual(self.source_commit, entry["source_commit"])
            self.assertEqual("MACHINE_RUNTIME_CAPTURE", entry["evidence_level"])
            self.assertEqual("NOT_RUN", entry["evidence_ceiling"]["human_usability"])
            self.assertEqual("NOT_RUN", entry["evidence_ceiling"]["android_actual_device"])
            self.assertEqual(1280, entry["image"]["width"])
            self.assertEqual(800, entry["image"]["height"])
            self.assertEqual(DEFAULT_RUN_ID, entry["producer_receipt"]["run_id"])
            self.assertEqual("PASS", entry["producer_receipt"]["producer_status"])
            self.assertEqual(
                sha256(receipt.read_bytes()).hexdigest(),
                entry["producer_receipt"]["receipt_sha256"],
            )
            self.assertNotIn(str(receipt.resolve()), json.dumps(entry))

            copied = project_root / entry["image"]["path"]
            self.assertTrue(copied.is_file())
            self.assertEqual(sha256(source.read_bytes()).hexdigest(), entry["image"]["sha256"])
            self.assertEqual(sha256(copied.read_bytes()).hexdigest(), entry["image"]["sha256"])

    def test_registrar_rejects_a_non_png_without_creating_evidence(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            invalid = Path(temporary) / "not-a-png.txt"
            receipt = Path(temporary) / "producer-receipt.json"
            invalid.write_text("not an image", encoding="utf-8")
            self._write_producer_receipt(receipt, invalid)

            result = self._run(
                project_root,
                invalid,
                "TEN-RVC-20260901-002",
                receipt=receipt,
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("PNG", result.stderr)
            self.assertFalse((project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json").exists())

    def test_registrar_rejects_a_missing_declared_consumer(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "source.png"
            receipt = Path(temporary) / "producer-receipt.json"
            self._write_png(source)
            self._write_producer_receipt(receipt, source)

            result = self._run(
                project_root,
                source,
                "TEN-RVC-20260901-006",
                "--consumer",
                "src/combat/does_not_exist.gd",
                receipt=receipt,
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("consumer does not exist", result.stderr)

    def test_registrar_requires_explicit_reason_for_a_third_capture_of_one_work_item(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "source.png"
            receipt = Path(temporary) / "producer-receipt.json"
            self._write_png(source)
            self._write_producer_receipt(receipt, source)

            self.assertEqual(
                0,
                self._run(project_root, source, "TEN-RVC-20260901-003", receipt=receipt).returncode,
            )
            self.assertEqual(
                0,
                self._run(project_root, source, "TEN-RVC-20260901-004", receipt=receipt).returncode,
            )
            third = self._run(
                project_root,
                source,
                "TEN-RVC-20260901-005",
                receipt=receipt,
            )
            self.assertNotEqual(0, third.returncode)
            self.assertIn("allow-additional-state", third.stderr)

            allowed = self._run(
                project_root,
                source,
                "TEN-RVC-20260901-005",
                "--allow-additional-state",
                "--additional-state-reason",
                "baseline comparison was not previously captured",
                receipt=receipt,
            )
            self.assertEqual(0, allowed.returncode, allowed.stderr)

    def test_registrar_rejects_stale_png_even_when_receipt_hash_matches(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "old-source.png"
            receipt = Path(temporary) / "producer-receipt.json"
            baseline = project_root / "docs" / "evidence" / "golden" / "approved-baseline.png"
            baseline.parent.mkdir(parents=True)
            self._write_png(source)
            self._write_png(baseline, width=640, height=360)
            baseline_before = baseline.read_bytes()
            old_epoch = datetime(2026, 1, 1, tzinfo=UTC).timestamp()
            os.utime(source, (old_epoch, old_epoch))
            started = datetime(2026, 9, 2, 0, 0, tzinfo=UTC)
            self._write_producer_receipt(
                receipt,
                source,
                started_at=started,
                completed_at=started + timedelta(seconds=5),
            )

            result = self._run(
                project_root,
                source,
                "TEN-RVC-20260901-007",
                receipt=receipt,
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("predates producer run", result.stderr)
            self.assertTrue(source.is_file())
            self.assertEqual(baseline_before, baseline.read_bytes())
            self.assertFalse((project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json").exists())

    def test_registrar_rejects_failed_producer_even_when_old_png_exists(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "old-source.png"
            receipt = Path(temporary) / "producer-receipt.json"
            self._write_png(source)
            self._write_producer_receipt(receipt, source, producer_status="FAIL")

            result = self._run(
                project_root,
                source,
                "TEN-RVC-20260901-008",
                receipt=receipt,
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("producer status must be PASS", result.stderr)
            self.assertTrue(source.is_file())
            self.assertFalse((project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json").exists())

    def test_registrar_rejects_run_and_source_identity_mismatch(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "source.png"
            receipt = Path(temporary) / "producer-receipt.json"
            self._write_png(source)

            with self.subTest("run-id"):
                self._write_producer_receipt(receipt, source, run_id="OTHER-RUN")
                result = self._run(
                    project_root,
                    source,
                    "TEN-RVC-20260901-009",
                    receipt=receipt,
                )
                self.assertNotEqual(0, result.returncode)
                self.assertIn("run ID mismatch", result.stderr)

            with self.subTest("source-commit"):
                self._write_producer_receipt(receipt, source, source_commit="b" * 40)
                result = self._run(
                    project_root,
                    source,
                    "TEN-RVC-20260901-009",
                    receipt=receipt,
                )
                self.assertNotEqual(0, result.returncode)
                self.assertIn("source commit mismatch", result.stderr)

    def test_registrar_rejects_artifact_mutated_after_receipt(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "source.png"
            receipt = Path(temporary) / "producer-receipt.json"
            self._write_png(source)
            self._write_producer_receipt(receipt, source)
            source.write_bytes(source.read_bytes() + b"tampered-after-receipt")

            result = self._run(
                project_root,
                source,
                "TEN-RVC-20260901-010",
                receipt=receipt,
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("artifact", result.stderr)
            self.assertIn("mismatch", result.stderr)
            self.assertFalse((project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json").exists())


if __name__ == "__main__":
    unittest.main()
