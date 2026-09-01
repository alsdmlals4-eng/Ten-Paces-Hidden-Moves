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

    def _write_launch_manifest(
        self,
        project_root: Path,
        source: Path,
        *,
        created_at_utc: str | None = None,
        exact_commit: str | None = None,
    ) -> Path:
        commit = exact_commit or self.source_commit
        run_root = project_root / "build" / "issue54-human-validation" / commit
        run_root.mkdir(parents=True, exist_ok=True)
        launch_manifest = run_root / "issue54-human-validation-launch.json"
        if created_at_utc is None:
            source_time = datetime.fromtimestamp(source.stat().st_mtime, UTC)
            created_at_utc = (source_time - timedelta(seconds=1)).isoformat()
        launch_manifest.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "launcher_id": "ISSUE54_HUMAN_VALIDATION_LAUNCHER",
                    "created_at_utc": created_at_utc,
                    "project_root": str(project_root.resolve()),
                    "exact_git_commit": commit,
                    "fresh_artifact_gate": "FRESH_RUNTIME_ARTIFACT_GATE",
                },
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )
        return launch_manifest

    def _run(
        self,
        project_root: Path,
        source: Path,
        capture_id: str,
        *extra: str,
        launch_manifest: Path | None = None,
    ) -> subprocess.CompletedProcess[str]:
        consumer = project_root / "src" / "combat" / "combat_board_preview.gd"
        consumer.parent.mkdir(parents=True, exist_ok=True)
        consumer.write_text("# capture-test consumer\n", encoding="utf-8")
        if launch_manifest is None:
            launch_manifest = self._write_launch_manifest(project_root, source)
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
                "--source-commit",
                self.source_commit,
                "--launch-manifest",
                str(launch_manifest),
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

    def test_policy_and_manifest_define_repository_controlled_runtime_capture(self) -> None:
        self.assertTrue(DECISION.is_file(), f"missing policy Decision: {DECISION}")
        self.assertTrue(MANIFEST.is_file(), f"missing manifest: {MANIFEST}")
        self.assertTrue(VISUAL_GATE.is_file(), f"missing visual gate: {VISUAL_GATE}")

        decision_text = DECISION.read_text(encoding="utf-8")
        gate_text = VISUAL_GATE.read_text(encoding="utf-8")
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))

        self.assertIn("TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01", decision_text)
        self.assertIn("CAPTURE_NOT_APPLICABLE_NO_RUNTIME_CONSUMER", decision_text)
        self.assertIn("MACHINE_RUNTIME_CAPTURE", decision_text)
        self.assertIn("TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01", gate_text)
        self.assertEqual("TEN_RUNTIME_VISUAL_CAPTURE_MANIFEST", manifest["manifest_role"])
        self.assertIsInstance(manifest["captures"], list)

    def test_registrar_copies_png_and_records_exact_runtime_evidence_boundary(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "source.png"
            self._write_png(source)

            result = self._run(project_root, source, "TEN-RVC-20260901-001")
            self.assertEqual(0, result.returncode, result.stderr)

            manifest_path = project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            self.assertEqual("TEN_RUNTIME_VISUAL_CAPTURE_MANIFEST", manifest["manifest_role"])
            entry = manifest["captures"][0]
            self.assertEqual("TEN-RVC-20260901-001", entry["capture_id"])
            self.assertEqual(self.source_commit, entry["source_commit"])
            producer = entry["producer_run"]
            self.assertEqual("ISSUE54_HUMAN_VALIDATION_LAUNCHER", producer["launcher_id"])
            self.assertEqual(
                f"build/issue54-human-validation/{self.source_commit}/issue54-human-validation-launch.json",
                producer["launch_manifest_path"],
            )
            launch_manifest = project_root / producer["launch_manifest_path"]
            self.assertEqual(sha256(launch_manifest.read_bytes()).hexdigest(), producer["launch_manifest_sha256"])
            self.assertEqual("MACHINE_RUNTIME_CAPTURE", entry["evidence_level"])
            self.assertEqual("NOT_RUN", entry["evidence_ceiling"]["human_usability"])
            self.assertEqual("NOT_RUN", entry["evidence_ceiling"]["android_actual_device"])
            self.assertEqual(1280, entry["image"]["width"])
            self.assertEqual(800, entry["image"]["height"])

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
            invalid.write_text("not an image", encoding="utf-8")

            result = self._run(project_root, invalid, "TEN-RVC-20260901-002")
            self.assertNotEqual(0, result.returncode)
            self.assertIn("PNG", result.stderr)
            self.assertFalse((project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json").exists())

    def test_registrar_rejects_a_missing_declared_consumer(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "source.png"
            self._write_png(source)

            result = self._run(
                project_root,
                source,
                "TEN-RVC-20260901-006",
                "--consumer",
                "src/combat/does_not_exist.gd",
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("consumer does not exist", result.stderr)

    def test_registrar_rejects_capture_older_than_launch_run_without_creating_evidence(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "stale-source.png"
            self._write_png(source)
            stale_time = (datetime.now(UTC) - timedelta(minutes=10)).timestamp()
            os.utime(source, (stale_time, stale_time))
            launch_manifest = self._write_launch_manifest(
                project_root,
                source,
                created_at_utc=datetime.now(UTC).isoformat(),
            )

            result = self._run(
                project_root,
                source,
                "TEN-RVC-20260901-007",
                launch_manifest=launch_manifest,
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("older than launch run", result.stderr)
            self.assertFalse(
                (project_root / "docs" / "evidence" / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json").exists()
            )

    def test_registrar_requires_explicit_reason_for_a_third_capture_of_one_work_item(self) -> None:
        self.assertTrue(SCRIPT.is_file(), f"missing registrar: {SCRIPT}")
        with tempfile.TemporaryDirectory() as temporary:
            project_root = Path(temporary) / "project"
            project_root.mkdir()
            source = Path(temporary) / "source.png"
            self._write_png(source)

            self.assertEqual(0, self._run(project_root, source, "TEN-RVC-20260901-003").returncode)
            self.assertEqual(0, self._run(project_root, source, "TEN-RVC-20260901-004").returncode)
            third = self._run(project_root, source, "TEN-RVC-20260901-005")
            self.assertNotEqual(0, third.returncode)
            self.assertIn("allow-additional-state", third.stderr)

            allowed = self._run(
                project_root,
                source,
                "TEN-RVC-20260901-005",
                "--allow-additional-state",
                "--additional-state-reason",
                "baseline comparison was not previously captured",
            )
            self.assertEqual(0, allowed.returncode, allowed.stderr)


if __name__ == "__main__":
    unittest.main()
