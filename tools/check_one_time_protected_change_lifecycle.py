#!/usr/bin/env python3
"""Enforce the PR-only lifetime of a protected-change approval manifest."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


APPROVAL_PATH = "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"
ADAPTER_PATH = "skills/PROJECT_BASE_ADAPTER.json"
ARCHIVE_RECORD_SUFFIX = "PROTECTED_CHANGE_APPROVAL_RECORD.md"


def lifecycle_errors(
    *,
    base_has_manifest: bool,
    head_has_manifest: bool,
    archive_record_added: bool,
    adapter_changed: bool,
    adapter_baseline: str,
    base_sha: str,
) -> list[str]:
    if base_has_manifest and head_has_manifest:
        return ["Active protected approval manifest was carried from the PR base; archive it before unrelated work."]
    if not base_has_manifest or head_has_manifest:
        return []

    errors: list[str] = []
    if not archive_record_added:
        errors.append("Protected approval cleanup must add an immutable audit record.")
    if not adapter_changed or adapter_baseline != base_sha:
        errors.append(
            "Protected approval cleanup must promote skills/PROJECT_BASE_ADAPTER.json protected_baseline.commit to the exact PR base SHA."
        )
    return errors


def _git(root: Path, *arguments: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", "-C", str(root), *arguments],
        capture_output=True,
        text=True,
        check=False,
    )


def _base_has_path(root: Path, base_sha: str, path: str) -> bool:
    return _git(root, "cat-file", "-e", f"{base_sha}:{path}").returncode == 0


def _added_paths(root: Path, base_sha: str) -> set[str]:
    result = _git(root, "diff", "--name-status", f"{base_sha}...HEAD")
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "could not read PR changed paths")
    added_paths: set[str] = set()
    for line in result.stdout.splitlines():
        status, separator, path = line.partition("\t")
        if status == "A" and separator and path:
            added_paths.add(path.replace("\\", "/"))
    return added_paths


def _adapter_baseline(root: Path) -> str:
    try:
        adapter = json.loads((root / ADAPTER_PATH).read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return ""
    if not isinstance(adapter, dict):
        return ""
    protected_baseline = adapter.get("protected_baseline")
    if not isinstance(protected_baseline, dict):
        return ""
    value = protected_baseline.get("commit")
    return value if isinstance(value, str) else ""


def validate(root: Path, base_sha: str) -> list[str]:
    added_paths = _added_paths(root, base_sha)
    return lifecycle_errors(
        base_has_manifest=_base_has_path(root, base_sha, APPROVAL_PATH),
        head_has_manifest=(root / APPROVAL_PATH).is_file(),
        archive_record_added=any(
            path.startswith("docs/operations/") and path.endswith(ARCHIVE_RECORD_SUFFIX)
            for path in added_paths
        ),
        adapter_changed=ADAPTER_PATH in _git(root, "diff", "--name-only", f"{base_sha}...HEAD").stdout.splitlines(),
        adapter_baseline=_adapter_baseline(root),
        base_sha=base_sha,
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--base-sha", required=True)
    options = parser.parse_args()
    if not re.fullmatch(r"[0-9a-f]{40}", options.base_sha):
        print("Protected approval lifecycle validation failed: --base-sha must be an exact 40-character SHA", file=sys.stderr)
        return 1
    try:
        errors = validate(options.project_root.resolve(), options.base_sha)
    except RuntimeError as error:
        errors = [str(error)]
    if errors:
        print("Protected approval lifecycle validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("Protected approval lifecycle validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
