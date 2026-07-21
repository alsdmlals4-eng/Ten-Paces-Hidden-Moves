#!/usr/bin/env python3
"""Validate Ten Paces project operating-system structure and registries."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


class ContractError(RuntimeError):
    pass


def load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ContractError(f"missing JSON file: {path.as_posix()}") from exc
    except json.JSONDecodeError as exc:
        raise ContractError(f"invalid JSON: {path.as_posix()}:{exc.lineno}:{exc.colno}: {exc.msg}") from exc
    if not isinstance(value, dict):
        raise ContractError(f"JSON root must be an object: {path.as_posix()}")
    return value


def resolve_from(owner: Path, relative: str) -> Path:
    return (owner.parent / relative).resolve()


def validate_required_paths(root: Path, config: dict[str, Any]) -> None:
    for relative in config.get("required_paths", []):
        if not (root / str(relative)).exists():
            raise ContractError(f"required path is missing: {relative}")


def validate_entrypoints(root: Path) -> None:
    start = (root / "START_HERE.md").read_text(encoding="utf-8")
    agents = (root / "AGENTS.md").read_text(encoding="utf-8")
    for token in ("AGENTS.md", "docs/BASE_RULES_VERSION.md", "[기획서]/00_프로젝트_허브/START_HERE.md"):
        if token not in start:
            raise ContractError(f"root START_HERE does not route to {token}")
    for token in ("PLAN", "BUILD", "REVIEW", "Skill Mode", "execution-report"):
        if token not in agents:
            raise ContractError(f"AGENTS is missing the routing contract token: {token}")


def validate_design_registry(root: Path, config: dict[str, Any]) -> None:
    registry_path = root / str(config["design_document_registry"])
    registry = load_json(registry_path)
    if registry.get("schema_version") != 3:
        raise ContractError("design registry schema_version must be 3")
    documents = registry.get("documents", [])
    if not documents:
        raise ContractError("design registry is empty")
    ids: set[str] = set()
    sources: set[str] = set()
    coverage: set[str] = set()
    for document in documents:
        document_id = str(document.get("document_id", ""))
        if not document_id or document_id in ids:
            raise ContractError(f"invalid or duplicate document_id: {document_id!r}")
        ids.add(document_id)
        if document.get("status") != "ACTIVE":
            raise ContractError(f"active registry document is not ACTIVE: {document_id}")
        if document.get("source_format") not in {"markdown", "json"}:
            raise ContractError(f"invalid source_format: {document_id}")
        if document.get("publication_policy") not in {"source_only", "milestone_sync", "always_sync"}:
            raise ContractError(f"invalid publication_policy: {document_id}")
        source = resolve_from(registry_path, str(document.get("source_path", "")))
        if not source.is_file():
            raise ContractError(f"registered source is missing: {document_id}")
        sources.add(source.relative_to(root).as_posix())
        coverage.update(str(value) for value in document.get("responsibility_coverage", []))
    expected = set(str(value) for value in config.get("required_design_sources", []))
    if sources != expected:
        raise ContractError(f"design sources differ: missing={sorted(expected-sources)} unexpected={sorted(sources-expected)}")
    required = set(str(value) for value in registry.get("required_responsibility_coverage", []))
    if not required <= coverage:
        raise ContractError(f"design responsibility coverage is incomplete: {sorted(required-coverage)}")


def validate_skill_registry(root: Path, config: dict[str, Any]) -> None:
    registry = load_json(root / str(config["skill_registry"]))
    policy = registry.get("routing_policy", {})
    expectations = {
        "load_all_skills": False,
        "default_selection": "automatic-trigger-match",
        "automatic_selection": True,
        "user_skill_declaration_required": False,
        "require_trigger_match": True,
        "require_execution_report": True,
        "work_modes": ["PLAN", "BUILD", "REVIEW"],
    }
    for key, expected in expectations.items():
        if policy.get(key) != expected:
            raise ContractError(f"routing policy mismatch: {key}={policy.get(key)!r}")
    skills = registry.get("skills", [])
    ids: set[str] = set()
    for skill in skills:
        skill_id = str(skill.get("skill_id", ""))
        if not skill_id or skill_id in ids:
            raise ContractError(f"invalid or duplicate skill_id: {skill_id!r}")
        ids.add(skill_id)
        if skill.get("status") != "ACTIVE" or skill.get("load_by_default") is not False:
            raise ContractError(f"invalid active skill state: {skill_id}")
        for field in ("path", "learning_log"):
            if not (root / str(skill.get(field, ""))).is_file():
                raise ContractError(f"missing skill {field}: {skill_id}")
        for field in ("trigger_tags", "use_when", "do_not_use_when", "skill_modes"):
            if not skill.get(field):
                raise ContractError(f"missing skill routing field: {skill_id}.{field}")
    for discipline in registry.get("selected_disciplines", []):
        entrypoints = registry.get("discipline_entrypoints", {}).get(discipline, [])
        if not entrypoints or not set(entrypoints) <= ids:
            raise ContractError(f"invalid selected-discipline entrypoint: {discipline}")
    base = registry.get("base_integration", {})
    if base.get("commit") != "ee265576da7f67d3278f8099dd97d4e714ef0651":
        raise ContractError("Skill Registry Base commit is stale")
    if not (root / str(base.get("legacy_aliases", ""))).is_file():
        raise ContractError("Legacy Skill Alias file is missing")


def validate_interviews(root: Path, config: dict[str, Any]) -> None:
    registry_path = root / str(config["interview_registry"])
    registry = load_json(registry_path)
    for item in registry.get("interviews", []):
        if item.get("status") not in {"USER_CONFIRMED", "CLOSED", "HOLD"}:
            raise ContractError(f"unsafe interview status: {item.get('interview_id')}")
        for field in ("record_path", "executable_prompt_path"):
            if not resolve_from(registry_path, str(item.get(field, ""))).is_file():
                raise ContractError(f"missing interview {field}: {item.get('interview_id')}")


def run(root: Path, config_path: Path) -> None:
    config = load_json(config_path)
    validate_required_paths(root, config)
    validate_entrypoints(root)
    validate_design_registry(root, config)
    validate_skill_registry(root, config)
    validate_interviews(root, config)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--config", default=".github/documentation-governance.json")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    try:
        run(root, (root / args.config).resolve())
    except ContractError as exc:
        print(f"project operating system: FAIL\n{exc}")
        return 1
    print("project operating system: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
