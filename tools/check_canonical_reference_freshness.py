#!/usr/bin/env python3
"""Validate Ten Paces canonical references and current-entrypoint freshness."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


class FreshnessError(RuntimeError):
    pass


def load_json(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise FreshnessError(f"missing config: {path.as_posix()}") from exc
    except json.JSONDecodeError as exc:
        raise FreshnessError(
            f"invalid JSON: {path.as_posix()}:{exc.lineno}:{exc.colno}: {exc.msg}"
        ) from exc
    if not isinstance(data, dict):
        raise FreshnessError("config root must be an object")
    return data


def read_text(root: Path, relative: str) -> str:
    path = root / relative
    if not path.is_file():
        raise FreshnessError(f"required freshness file is missing: {relative}")
    return path.read_text(encoding="utf-8", errors="replace")


def validate_current_tokens(root: Path, config: dict[str, Any]) -> None:
    forbidden = [str(value) for value in config.get("forbidden_current_tokens", [])]
    for relative in config.get("strict_current_files", []):
        text = read_text(root, str(relative))
        found = [token for token in forbidden if token in text]
        if found:
            raise FreshnessError(
                f"stale current tokens in {relative}: {', '.join(found)}"
            )

    required_map = config.get("required_current_tokens", {})
    if not isinstance(required_map, dict):
        raise FreshnessError("required_current_tokens must be an object")
    for relative, tokens in required_map.items():
        text = read_text(root, str(relative))
        missing = [str(token) for token in tokens if str(token) not in text]
        if missing:
            raise FreshnessError(
                f"missing current tokens in {relative}: {', '.join(missing)}"
            )


def validate_canonical_rules(root: Path, config: dict[str, Any]) -> None:
    rules = config.get("canonical_reference_rules", [])
    if not isinstance(rules, list):
        raise FreshnessError("canonical_reference_rules must be a list")
    for rule in rules:
        if not isinstance(rule, dict):
            raise FreshnessError("canonical reference rule must be an object")
        name = str(rule.get("name", "unnamed"))
        canonical = str(rule.get("canonical_path", ""))
        if not canonical or not (root / canonical).is_file():
            raise FreshnessError(f"missing canonical path for {name}: {canonical}")
        tokens = [str(value) for value in rule.get("reference_tokens", [])]
        if not tokens:
            raise FreshnessError(f"reference tokens are required for {name}")
        for consumer in rule.get("required_consumers", []):
            relative = str(consumer)
            text = read_text(root, relative)
            if not any(token in text for token in tokens):
                raise FreshnessError(
                    f"canonical reference missing: rule={name} consumer={relative}"
                )


def validate_legacy_aliases(root: Path, config: dict[str, Any]) -> None:
    relative = str(config.get("legacy_aliases_path", ""))
    text = read_text(root, relative)
    required_ids = [
        "conducting-deep-requirement-interviews",
        "routing-project-work-by-discipline",
        "transforming-requests-into-prompts",
        "installing-game-project-operating-system",
        "migrating-existing-game-project-structure",
        "verifying-game-project-operating-system",
        "writing-game-design-documents",
        "publishing-discipline-bibles",
        "reviewing-external-ai-drafts",
        "promoting-project-knowledge",
        "reviewing-and-implementing-base-change-proposals",
    ]
    missing = [value for value in required_ids if value not in text]
    if missing:
        raise FreshnessError("legacy aliases are incomplete: " + ", ".join(missing))


def run(root: Path, config_path: Path) -> None:
    config = load_json(config_path)
    if int(config.get("schema_version", 0)) != 1:
        raise FreshnessError("reference freshness schema_version must be 1")
    validate_current_tokens(root, config)
    validate_canonical_rules(root, config)
    validate_legacy_aliases(root, config)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--config", default=".github/reference-freshness.json")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    config_path = (root / args.config).resolve()
    try:
        run(root, config_path)
    except FreshnessError as exc:
        print(f"canonical reference freshness: FAIL\n{exc}")
        return 1
    print("canonical reference freshness: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
