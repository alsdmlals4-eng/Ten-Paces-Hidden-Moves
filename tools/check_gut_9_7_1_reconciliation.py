#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any


OFFICIAL_COMMIT = "aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605"
OFFICIAL_TREE = "5d6893836af4917ee62b1a395125a7530b1f239d"
INITIAL_PROJECT_TREE = "09d040309bbed0e07420ad72c4aa69cbd0e58190"
EXPECTED_NORMALIZED_SCENE_VARIANCES = {
    "GutScene.tscn",
    "UserFileViewer.tscn",
    "gui/GutSceneTheme.tres",
}
PRODUCTION_ROOTS = (
    "src",
    "scenes",
    "data",
    "assets",
    "addons",
    "project.godot",
    "export_presets.cfg",
)


class ReconciliationError(RuntimeError):
    pass


def normalize_godot_text_resource(text: str) -> str:
    """Normalize only optional first-line load_steps metadata in Godot text resources."""
    lines = text.splitlines(keepends=True)
    if not lines:
        return text
    if lines[0].startswith(("[gd_scene ", "[gd_resource ")):
        lines[0] = re.sub(r"\sload_steps=\d+", "", lines[0], count=1)
    return "".join(lines)


def normalize_godot_scene(text: str) -> str:
    """Backward-compatible alias for the bounded Godot text-resource normalizer."""
    return normalize_godot_text_resource(text)


def _files(root: Path) -> dict[str, Path]:
    if not root.is_dir():
        raise ReconciliationError(f"missing directory: {root}")
    return {
        path.relative_to(root).as_posix(): path
        for path in root.rglob("*")
        if path.is_file()
    }


def compare_addon_trees(project_addon: Path, upstream_addon: Path) -> dict[str, Any]:
    project_files = _files(project_addon)
    upstream_files = _files(upstream_addon)
    project_names = set(project_files)
    upstream_names = set(upstream_files)

    missing = sorted(upstream_names - project_names)
    extra = sorted(project_names - upstream_names)
    exact_matches: list[str] = []
    normalized_scene_matches: list[str] = []
    unexpected_mismatches: list[str] = []

    for name in sorted(project_names & upstream_names):
        project_bytes = project_files[name].read_bytes()
        upstream_bytes = upstream_files[name].read_bytes()
        if project_bytes == upstream_bytes:
            exact_matches.append(name)
            continue
        if name.endswith((".tscn", ".tres")):
            try:
                project_text = project_bytes.decode("utf-8")
                upstream_text = upstream_bytes.decode("utf-8")
            except UnicodeDecodeError:
                unexpected_mismatches.append(name)
                continue
            if normalize_godot_text_resource(project_text) == normalize_godot_text_resource(upstream_text):
                normalized_scene_matches.append(name)
                continue
        unexpected_mismatches.append(name)

    return {
        "official_commit": OFFICIAL_COMMIT,
        "official_addon_tree": OFFICIAL_TREE,
        "initial_project_addon_tree": INITIAL_PROJECT_TREE,
        "project_file_count": len(project_files),
        "upstream_file_count": len(upstream_files),
        "exact_match_count": len(exact_matches),
        "normalized_scene_matches": normalized_scene_matches,
        "unexpected_mismatches": unexpected_mismatches,
        "missing_from_project": missing,
        "extra_in_project": extra,
        "accepted_variance_policy": "GODOT_TEXT_RESOURCE_LOAD_STEPS_METADATA_ONLY",
    }


def require_acceptable_tree(
    report: dict[str, Any],
    expected_normalized: set[str] = EXPECTED_NORMALIZED_SCENE_VARIANCES,
) -> None:
    for key, label in (
        ("missing_from_project", "missing upstream addon file"),
        ("extra_in_project", "extra project addon file"),
        ("unexpected_mismatches", "unexpected addon difference"),
    ):
        values = report.get(key, [])
        if values:
            raise ReconciliationError(f"{label}: {values}")
    actual = set(report.get("normalized_scene_matches", []))
    if actual != expected_normalized:
        raise ReconciliationError(
            "normalized text resource variance differs: "
            f"expected={sorted(expected_normalized)} actual={sorted(actual)}"
        )


def _iter_production_files(root: Path):
    for relative in PRODUCTION_ROOTS:
        path = root / relative
        if not path.exists():
            continue
        if path.is_file():
            yield path
            continue
        for child in path.rglob("*"):
            if not child.is_file():
                continue
            rel = child.relative_to(root).as_posix()
            if rel == "addons/gut" or rel.startswith("addons/gut/"):
                continue
            yield child


def hash_production_scope(root: Path) -> dict[str, Any]:
    files: dict[str, str] = {}
    for path in sorted(_iter_production_files(root), key=lambda value: value.as_posix()):
        relative = path.relative_to(root).as_posix()
        files[relative] = hashlib.sha256(path.read_bytes()).hexdigest()
    aggregate = hashlib.sha256()
    for relative, digest in sorted(files.items()):
        aggregate.update(relative.encode("utf-8"))
        aggregate.update(b"\0")
        aggregate.update(digest.encode("ascii"))
        aggregate.update(b"\n")
    return {
        "algorithm": "sha256",
        "scope": [
            "src/**",
            "scenes/**",
            "data/**",
            "assets/**",
            "addons/** except addons/gut/**",
            "project.godot",
            "export_presets.cfg",
        ],
        "file_count": len(files),
        "files": files,
        "digest": aggregate.hexdigest(),
    }


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _read_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ReconciliationError(f"invalid evidence file {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ReconciliationError(f"evidence is not an object: {path}")
    return payload


def command_compare_tree(args: argparse.Namespace) -> None:
    report = compare_addon_trees(Path(args.project_addon), Path(args.upstream_addon))
    require_acceptable_tree(report)
    report["result"] = "PASS_NORMALIZED_EQUIVALENCE"
    _write_json(Path(args.report), report)
    print(
        "GUT tree reconciliation: PASS "
        f"({report['exact_match_count']} exact, "
        f"{len(report['normalized_scene_matches'])} normalized text resource variances)"
    )


def command_hash_production(args: argparse.Namespace) -> None:
    payload = hash_production_scope(Path(args.root))
    _write_json(Path(args.output), payload)
    print(f"production scope hash: {payload['digest']} ({payload['file_count']} files)")


def command_verify_hash(args: argparse.Namespace) -> None:
    before = _read_json(Path(args.before))
    after = _read_json(Path(args.after))
    if before.get("files") != after.get("files") or before.get("digest") != after.get("digest"):
        before_files = before.get("files", {})
        after_files = after.get("files", {})
        changed = sorted(
            name
            for name in set(before_files) | set(after_files)
            if before_files.get(name) != after_files.get(name)
        )
        raise ReconciliationError(f"production scope changed during GUT execution: {changed}")
    print(f"production hash invariant: PASS ({before.get('digest')})")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Validate GUT 9.7.1 reconciliation evidence")
    subparsers = parser.add_subparsers(dest="command", required=True)

    compare_parser = subparsers.add_parser("compare-tree")
    compare_parser.add_argument("--project-addon", required=True)
    compare_parser.add_argument("--upstream-addon", required=True)
    compare_parser.add_argument("--report", required=True)
    compare_parser.set_defaults(func=command_compare_tree)

    hash_parser = subparsers.add_parser("hash-production")
    hash_parser.add_argument("--root", required=True)
    hash_parser.add_argument("--output", required=True)
    hash_parser.set_defaults(func=command_hash_production)

    verify_parser = subparsers.add_parser("verify-hash")
    verify_parser.add_argument("--before", required=True)
    verify_parser.add_argument("--after", required=True)
    verify_parser.set_defaults(func=command_verify_hash)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    try:
        args.func(args)
    except ReconciliationError as exc:
        parser.error(str(exc))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
