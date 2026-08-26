from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

from tools.check_one_time_protected_change_lifecycle import lifecycle_errors


class OneTimeProtectedChangeLifecycleTests(unittest.TestCase):
    def test_new_manifest_is_allowed_for_its_originating_pr(self) -> None:
        errors = lifecycle_errors(
            base_has_manifest=False,
            head_has_manifest=True,
            archive_record_added=False,
            adapter_changed=False,
            adapter_baseline="",
            base_sha="a" * 40,
        )
        self.assertEqual([], errors)

    def test_carried_manifest_is_rejected_for_a_later_pr(self) -> None:
        errors = lifecycle_errors(
            base_has_manifest=True,
            head_has_manifest=True,
            archive_record_added=False,
            adapter_changed=False,
            adapter_baseline="",
            base_sha="a" * 40,
        )
        self.assertEqual(["Active protected approval manifest was carried from the PR base; archive it before unrelated work."], errors)

    def test_no_manifest_pr_remains_unaffected(self) -> None:
        errors = lifecycle_errors(
            base_has_manifest=False,
            head_has_manifest=False,
            archive_record_added=False,
            adapter_changed=False,
            adapter_baseline="",
            base_sha="a" * 40,
        )
        self.assertEqual([], errors)

    def test_cleanup_requires_new_audit_record_and_baseline_promotion(self) -> None:
        errors = lifecycle_errors(
            base_has_manifest=True,
            head_has_manifest=False,
            archive_record_added=False,
            adapter_changed=True,
            adapter_baseline="b" * 40,
            base_sha="a" * 40,
        )
        self.assertEqual(
            [
                "Protected approval cleanup must add an immutable audit record.",
                "Protected approval cleanup must promote skills/PROJECT_BASE_ADAPTER.json protected_baseline.commit to the exact PR base SHA.",
            ],
            errors,
        )

    def test_cli_rejects_cleanup_that_modifies_an_existing_audit_record(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            repository = Path(temporary)
            self._git(repository, "init")
            self._git(repository, "config", "user.email", "test@example.com")
            self._git(repository, "config", "user.name", "Lifecycle Test")
            self._write(repository / "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json", "{}\n")
            self._write(repository / "docs/operations/2026-08-01_PR1_PROTECTED_CHANGE_APPROVAL_RECORD.md", "status: HISTORICAL_MERGED\n")
            self._write_json(repository / "skills/PROJECT_BASE_ADAPTER.json", {"protected_baseline": {"commit": "0" * 40}})
            self._git(repository, "add", ".")
            self._git(repository, "commit", "-m", "base")
            base_sha = self._git(repository, "rev-parse", "HEAD").strip()

            (repository / "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json").unlink()
            self._write(repository / "docs/operations/2026-08-01_PR1_PROTECTED_CHANGE_APPROVAL_RECORD.md", "status: altered\n")
            self._write_json(repository / "skills/PROJECT_BASE_ADAPTER.json", {"protected_baseline": {"commit": base_sha}})
            self._git(repository, "add", "-A")
            self._git(repository, "commit", "-m", "invalid cleanup")

            result = self._run_checker(repository, base_sha)
            self.assertNotEqual(0, result.returncode)
            self.assertIn("must add an immutable audit record", result.stderr)

    def test_cli_accepts_complete_cleanup_transition(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            repository = Path(temporary)
            self._git(repository, "init")
            self._git(repository, "config", "user.email", "test@example.com")
            self._git(repository, "config", "user.name", "Lifecycle Test")
            self._write(repository / "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json", "{}\n")
            self._write_json(repository / "skills/PROJECT_BASE_ADAPTER.json", {"protected_baseline": {"commit": "0" * 40}})
            self._git(repository, "add", ".")
            self._git(repository, "commit", "-m", "base")
            base_sha = self._git(repository, "rev-parse", "HEAD").strip()

            (repository / "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json").unlink()
            self._write(repository / "docs/operations/2026-08-26_PR209_PROTECTED_CHANGE_APPROVAL_RECORD.md", "status: HISTORICAL_MERGED\n")
            self._write_json(repository / "skills/PROJECT_BASE_ADAPTER.json", {"protected_baseline": {"commit": base_sha}})
            self._git(repository, "add", "-A")
            self._git(repository, "commit", "-m", "cleanup")

            result = self._run_checker(repository, base_sha)
            self.assertEqual(0, result.returncode, result.stderr)
            self.assertIn("passed", result.stdout.lower())

    @staticmethod
    def _git(repository: Path, *arguments: str) -> str:
        result = subprocess.run(
            ["git", "-C", str(repository), *arguments],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout

    @staticmethod
    def _run_checker(repository: Path, base_sha: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                "python",
                str(Path(__file__).resolve().parents[1] / "tools/check_one_time_protected_change_lifecycle.py"),
                "--project-root",
                str(repository),
                "--base-sha",
                base_sha,
            ],
            capture_output=True,
            text=True,
            check=False,
        )

    @staticmethod
    def _write(path: Path, content: str) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    @staticmethod
    def _write_json(path: Path, value: dict) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(value), encoding="utf-8")


if __name__ == "__main__":
    unittest.main()
