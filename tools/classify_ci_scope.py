from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

DOC_PREFIXES = (
    "docs/",
    "[기획서]/",
    "skills/",
    "templates/",
)
DOC_ROOT_FILES = {
    "README.md",
    "START_HERE.md",
    "AGENTS.md",
}
DOC_CONFIG_FILES = {
    ".github/documentation-governance.json",
    ".github/reference-freshness.json",
}


def normalize(path: str) -> str:
    return path.strip().replace("\\", "/")


def is_documentation_only_path(path: str) -> bool:
    normalized = normalize(path)
    if not normalized:
        return True
    if normalized in DOC_ROOT_FILES or normalized in DOC_CONFIG_FILES:
        return True
    return normalized.startswith(DOC_PREFIXES)


def classify(paths: list[str]) -> str:
    normalized = [normalize(path) for path in paths if normalize(path)]
    if not normalized:
        return "code"
    return "docs" if all(is_documentation_only_path(path) for path in normalized) else "code"


def git_changed_paths(base: str, head: str, root: Path) -> list[str]:
    completed = subprocess.run(
        ["git", "-C", str(root), "diff", "--name-only", base, head],
        check=True,
        text=True,
        capture_output=True,
    )
    return completed.stdout.splitlines()


def write_output(scope: str, changed: list[str], github_output: str | None) -> None:
    print(f"CI scope: {scope}")
    for path in changed:
        print(f" - {path}")
    if github_output:
        output_path = Path(github_output)
        with output_path.open("a", encoding="utf-8") as handle:
            handle.write(f"scope={scope}\n")
            handle.write(f"changed_count={len(changed)}\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Classify a change set as docs-only or code-impacting.")
    parser.add_argument("--base", help="Base commit SHA for git diff.")
    parser.add_argument("--head", help="Head commit SHA for git diff.")
    parser.add_argument("--root", default=".", help="Repository root.")
    parser.add_argument("--path", action="append", default=[], help="Explicit changed path; repeatable.")
    parser.add_argument("--github-output", default=os.environ.get("GITHUB_OUTPUT"))
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    if args.path:
        changed = args.path
    elif args.base and args.head:
        changed = git_changed_paths(args.base, args.head, root)
    else:
        print("Provide --path or both --base and --head.", file=sys.stderr)
        return 2
    scope = classify(changed)
    write_output(scope, changed, args.github_output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
