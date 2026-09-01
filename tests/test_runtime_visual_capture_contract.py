from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from hashlib import sha256
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "register_runtime_visual_capture.py"
PREPARE_SCRIPT = ROOT / "tools" / "prepare_runtime_visual_capture.py"
MANIFEST = ROOT / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json"
DECISION = ROOT / "docs" / "decisions" / "2026-09-01_RUNTIME_VISUAL_CAPTURE_EVIDENCE_POLICY_DECISION.md"
VISUAL_GATE = ROOT / "docs" / "19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md"


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

    def _ensure_consumer(self, project_root: Path) -> None:
        consumer = project_root / "src" / "combat" / "combat_board_preview.gd"
        consumer.parent.mkdir(parents=True, exist_ok=True)
        consumer.write_text("# capture-test consumer\n", encoding="utf-8")

    def _prepare(
        self,
        project_root: Path,
        source: Path,
        receipt: Path,
        run_id: str,
    ) -> subprocess.CompletedProcess[str]:
        self._ensure_consumer(project_root)
        return subprocess.run(
            [
                sys.executable,
                str(PREPARE_SCRIPT),
                "--project-root",
                str(project_root),
                "--source-image",
                str(source),
                "--freshness-receipt",
                str(receipt),
                "--capture-run-id",
                run_id,
                "--source-commit",
                self.source_commit,
            ],
            text=True,
            capture_output=True,
            check=False,
        )

    def _run(
        self,
        project_root: Path,
        source: Path,
        receipt: Path,
        run_id: str,
        capture_id: str,
        *extra: str,
        expected_source_commit: str | None = None,
    ) -> subprocess.CompletedProcess[str]:
        self._ensure_consumer(project_root)
        return subprocess.run(
            [
                sys.executable,
                str(SCRIPT),
                "--project-root",
                str(project_root),
                "--source-image",
                str(source),
                "--capture-id",
                capture_id,
                "--capture-run-id",
                run_id,
                "--freshness-receipt",
                str(receipt),
                "--source-commit",
                self.source_commit,
                "--expected-source-commit",
                expected_source_commit or self.source_commit,
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
                *extra,
            ],
            text=True,
            capture_output=True,
            check=False,
        )

    def _prepare_and_write_png(
        self,
        project_root: Path,
        temporary: str,
        sequence: int,
        *,
        width: int = 1280,
        height: int = 800,
    ) -> tuple[Path, Path, str]:
        source = Path(temporary) / f"source-{sequence}.png"
        receipt = Path(temporary) / f"freshness-{sequence}.json"
        run_id = f"TEN-RVC-RUN-20260902-{sequence:03d}"
        prepared = self._prepare(project_root, source, receipt, run_id)
        self.assertEqual(0, prepared.returncode, prepared.stderr)
        self.assertFalse(source.exists())
        self._write_png(source, width=width, height=height)
        return source, receipt, run_id

    def test_policy_and_manifest_define_repository_controlled_runtime_capture(self) -> None:
        self.assertTrue(DECISION.is_file(), f"missing policy Decision: {DECISION}")
        self.assertTrue(MANIFEST.is_file(), f"missing manifest: {MANIFEST}")
        self.assertTrue(VISUAL_GATE.is_file(), f"missing visual gate: {VISUAL_GATE}")
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        self.assertTrue(PREPARE_SCRIPT.is_file(), f"missing freshness preparer: {PREPARE_SCRIPT}")

        decision_text = DECISION.read_text(encoding="utf-8")
        gate_text = VISUAL_GATE.read_text(encoding="utf-8")
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))

        self.assertIn("TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01", decision_text)
        self.assertIn("CAPTURE_NOT_APPLICABLE_NO_RUNTIME_CONSUMER", decision_text)
        self.assertIn("MACHINE_RUNTIME_CAPTURE", decision_text)
        self.assertIn("PREPARED_ABSENT_THEN_PRESENT", decision_text)
        self.assertIn("PRIOR_ARTIFACT_EXISTENCE_IS_NOT_FRESH_EVIDENCE", decision_text)
        self.assertIn("TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01", gate_text)
        self.assertEqual("TEN_RUNTIME_VISUAL_CAPTURE_MANIFEST", manifest["manifest_role"])
        self.assertIsInstance(manifest["captures"], list)

    def test_registrar_copies_png_and_records_exact_runtime_evidence_boundary(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source, receipt, run_id = self._prepare_and_write_png(
                project_root, temporary, 1
            )

            result = self._run(
                project_root,
                source,
                receipt,
                run_id,
                "TEN-RVC-20260901-001",
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
            self.assertEqual("PREPARED_ABSENT_THEN_PRESENT", entry["freshness"]["mode"])
            self.assertEqual(run_id, entry["freshness"]["capture_run_id"])
            self.assertTrue(entry["freshness"]["source_absent_at_prepare"])
            self.assertTrue(entry["freshness"]["trusted_source_identity_match"])
            self.assertIn(
                "NOT_PRODUCER_AUTHENTICITY",
                entry["freshness"]["claim_ceiling"],
            )

            copied = project_root / entry["image"]["path"]
            self.assertTrue(copied.is_file())
            self.assertEqual(sha256(source.read_bytes()).hexdigest(), entry["image"]["sha256"])
            self.assertEqual(sha256(copied.read_bytes()).hexdigest(), entry["image"]["sha256"])

    def test_prepare_rejects_a_preexisting_source_before_runtime_execution(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "stale.png"
            receipt = Path(temporary) / "freshness.json"
            self._write_png(source)

            result = self._prepare(
                project_root,
                source,
                receipt,
                "TEN-RVC-RUN-20260902-010",
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("already exists", result.stderr)
            self.assertFalse(receipt.exists())
            self.assertFalse(
                (project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json").exists()
            )

    def test_registrar_rejects_when_current_run_did_not_create_the_expected_png(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "missing.png"
            receipt = Path(temporary) / "freshness.json"
            run_id = "TEN-RVC-RUN-20260902-011"
            prepared = self._prepare(project_root, source, receipt, run_id)
            self.assertEqual(0, prepared.returncode, prepared.stderr)

            result = self._run(
                project_root,
                source,
                receipt,
                run_id,
                "TEN-RVC-20260901-002",
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("did not create", result.stderr)

    def test_registrar_rejects_a_non_png_without_creating_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            invalid = Path(temporary) / "not-a-png.txt"
            receipt = Path(temporary) / "freshness.json"
            run_id = "TEN-RVC-RUN-20260902-012"
            prepared = self._prepare(project_root, invalid, receipt, run_id)
            self.assertEqual(0, prepared.returncode, prepared.stderr)
            invalid.write_text("not an image", encoding="utf-8")

            result = self._run(
                project_root,
                invalid,
                receipt,
                run_id,
                "TEN-RVC-20260901-003",
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("PNG", result.stderr)
            self.assertFalse((project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json").exists())

    def test_registrar_rejects_a_missing_declared_consumer(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source, receipt, run_id = self._prepare_and_write_png(
                project_root, temporary, 13
            )

            result = self._run(
                project_root,
                source,
                receipt,
                run_id,
                "TEN-RVC-20260901-004",
                "--consumer",
                "src/combat/does_not_exist.gd",
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("consumer does not exist", result.stderr)

    def test_registrar_rejects_trusted_source_commit_mismatch(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source, receipt, run_id = self._prepare_and_write_png(
                project_root, temporary, 14
            )

            result = self._run(
                project_root,
                source,
                receipt,
                run_id,
                "TEN-RVC-20260901-005",
                expected_source_commit="b" * 40,
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("trusted expected source commit", result.stderr)

    def test_registrar_rejects_reuse_of_one_freshness_receipt(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source, receipt, run_id = self._prepare_and_write_png(
                project_root, temporary, 15
            )

            first = self._run(
                project_root,
                source,
                receipt,
                run_id,
                "TEN-RVC-20260901-006",
            )
            self.assertEqual(0, first.returncode, first.stderr)
            second = self._run(
                project_root,
                source,
                receipt,
                run_id,
                "TEN-RVC-20260901-007",
            )
            self.assertNotEqual(0, second.returncode)
            self.assertIn("already consumed", second.stderr)

    def test_registrar_requires_explicit_reason_for_a_third_capture_of_one_work_item(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()

            source1, receipt1, run1 = self._prepare_and_write_png(
                project_root, temporary, 16
            )
            source2, receipt2, run2 = self._prepare_and_write_png(
                project_root, temporary, 17
            )
            source3, receipt3, run3 = self._prepare_and_write_png(
                project_root, temporary, 18
            )

            self.assertEqual(
                0,
                self._run(
                    project_root,
                    source1,
                    receipt1,
                    run1,
                    "TEN-RVC-20260901-008",
                ).returncode,
            )
            self.assertEqual(
                0,
                self._run(
                    project_root,
                    source2,
                    receipt2,
                    run2,
                    "TEN-RVC-20260901-009",
                ).returncode,
            )
            third = self._run(
                project_root,
                source3,
                receipt3,
                run3,
                "TEN-RVC-20260901-010",
            )
            self.assertNotEqual(0, third.returncode)
            self.assertIn("allow-additional-state", third.stderr)

            allowed = self._run(
                project_root,
                source3,
                receipt3,
                run3,
                "TEN-RVC-20260901-010",
                "--allow-additional-state",
                "--additional-state-reason",
                "baseline comparison was not previously captured",
            )
            self.assertEqual(0, allowed.returncode, allowed.stderr)


if __name__ == "__main__":
    unittest.main()
