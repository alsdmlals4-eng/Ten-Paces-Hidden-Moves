#!/usr/bin/env python3
"""Validate Ten Paces canonical references and active-file freshness."""

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
        raise FreshnessError(f"missing config or JSON: {path.as_posix()}") from exc
    except json.JSONDecodeError as exc:
        raise FreshnessError(
            f"invalid JSON: {path.as_posix()}:{exc.lineno}:{exc.colno}: {exc.msg}"
        ) from exc
    if not isinstance(data, dict):
        raise FreshnessError(f"JSON root must be an object: {path.as_posix()}")
    return data


def read_text(root: Path, relative: str) -> str:
    path = root / relative
    if not path.is_file():
        raise FreshnessError(f"required freshness file is missing: {relative}")
    return path.read_text(encoding="utf-8", errors="replace")


def validate_absent_paths(root: Path, config: dict[str, Any]) -> None:
    present = [
        str(relative)
        for relative in config.get("forbidden_active_paths", [])
        if (root / str(relative)).exists()
    ]
    if present:
        raise FreshnessError("superseded active paths still exist: " + ", ".join(present))


def validate_current_tokens(root: Path, config: dict[str, Any]) -> None:
    forbidden = [str(value) for value in config.get("forbidden_current_tokens", [])]
    for relative in config.get("strict_current_files", []):
        text = read_text(root, str(relative))
        found = [token for token in forbidden if token in text]
        if found:
            raise FreshnessError(
                f"stale current tokens in {relative}: " + ", ".join(found)
            )

    required_map = config.get("required_current_tokens", {})
    if not isinstance(required_map, dict):
        raise FreshnessError("required_current_tokens must be an object")
    for relative, tokens in required_map.items():
        text = read_text(root, str(relative))
        missing = [str(token) for token in tokens if str(token) not in text]
        if missing:
            raise FreshnessError(
                f"missing current tokens in {relative}: " + ", ".join(missing)
            )


def validate_structured_contracts(root: Path, config: dict[str, Any]) -> None:
    board_path = root / str(config.get("board_contract_path", ""))
    board = load_json(board_path)
    expected_board_schema = int(config.get("expected_board_schema_version", 0))
    if expected_board_schema <= 0:
        raise FreshnessError("expected_board_schema_version must be a positive integer")
    if int(board.get("schema_version", 0)) != expected_board_schema:
        raise FreshnessError(
            "combat board schema is stale: "
            f"expected={expected_board_schema} actual={board.get('schema_version')!r}"
        )

    registry_path = root / str(config.get("skill_registry_path", ""))
    registry = load_json(registry_path)
    base = registry.get("base_integration", {})
    if not isinstance(base, dict):
        raise FreshnessError("Skill Registry base_integration must be an object")

    expected_commit = str(config.get("expected_base_commit", ""))
    if not expected_commit:
        raise FreshnessError("expected_base_commit is required")
    actual_commit = str(base.get("commit", ""))
    if actual_commit != expected_commit:
        raise FreshnessError(
            f"Skill Registry Base commit is stale: expected={expected_commit} actual={actual_commit}"
        )

    expected_ids_value = config.get("expected_base_skill_ids", [])
    if not isinstance(expected_ids_value, list) or not expected_ids_value:
        raise FreshnessError("expected_base_skill_ids must be a non-empty list")
    expected_ids = [str(value) for value in expected_ids_value]
    if len(expected_ids) != len(set(expected_ids)):
        raise FreshnessError("expected_base_skill_ids contains duplicates")

    routes = base.get("shared_skill_routes", {})
    if not isinstance(routes, dict):
        raise FreshnessError("shared_skill_routes must be an object")
    actual_ids = [str(value) for value in routes.values()]
    if len(actual_ids) != len(set(actual_ids)):
        raise FreshnessError("Base shared Skill routes contain duplicate targets")
    if set(actual_ids) != set(expected_ids):
        missing = sorted(set(expected_ids) - set(actual_ids))
        unexpected = sorted(set(actual_ids) - set(expected_ids))
        raise FreshnessError(
            f"Base shared Skill routes differ: missing={missing} unexpected={unexpected}"
        )

    local_skills = registry.get("skills", [])
    if not isinstance(local_skills, list) or len(local_skills) != 4:
        raise FreshnessError(
            f"expected four project-specific local Skills, found {len(local_skills) if isinstance(local_skills, list) else 'invalid'}"
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
    text = read_text(root, str(config.get("legacy_aliases_path", "")))
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
        "project-operations-and-handoff",
        "project-health-review",
    ]
    missing = [value for value in required_ids if value not in text]
    if missing:
        raise FreshnessError("legacy aliases are incomplete: " + ", ".join(missing))


def run(root: Path, config_path: Path) -> None:
    config = load_json(config_path)
    if int(config.get("schema_version", 0)) != 1:
        raise FreshnessError("reference freshness schema_version must be 1")
    validate_absent_paths(root, config)
    validate_current_tokens(root, config)
    validate_structured_contracts(root, config)
    validate_canonical_rules(root, config)
    validate_legacy_aliases(root, config)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--config", default=".github/reference-freshness.json")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    try:
        run(root, (root / args.config).resolve())
    except FreshnessError as exc:
        print(f"canonical reference freshness: FAIL\n{exc}")
        return 1
    print("canonical reference freshness: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
