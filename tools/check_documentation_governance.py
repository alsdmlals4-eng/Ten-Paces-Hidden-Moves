#!/usr/bin/env python3
"""Validate the Ten Paces project operating-system contract."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


class GovernanceError(RuntimeError):
    pass


ALLOWED_DOCUMENT_STATUSES = {
    "ACTIVE", "SUPPORT", "HOLD", "BACKUP", "REMOVAL_CANDIDATE", "NOT_INSTALLED"
}
ALLOWED_PUBLICATION_POLICIES = {"source_only", "milestone_sync", "always_sync"}
ALLOWED_SOURCE_FORMATS = {"markdown", "json"}
ALLOWED_SOURCE_ROLES = {"narrative_spec", "structured_data", "registry", "state"}
ALLOWED_DIAGRAM_POLICIES = {"none", "mermaid", "generated"}


def load_json(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise GovernanceError(f"missing JSON file: {path.as_posix()}") from exc
    except json.JSONDecodeError as exc:
        raise GovernanceError(
            f"invalid JSON: {path.as_posix()}:{exc.lineno}:{exc.colno}: {exc.msg}"
        ) from exc
    if not isinstance(data, dict):
        raise GovernanceError(f"JSON root must be an object: {path.as_posix()}")
    return data


def require_paths(root: Path, relatives: list[str]) -> None:
    missing = [relative for relative in relatives if not (root / relative).exists()]
    if missing:
        raise GovernanceError("required paths are missing: " + ", ".join(missing))


def resolve_from(file_path: Path, relative: str) -> Path:
    return (file_path.parent / relative).resolve()


def validate_design_registry(root: Path, config: dict[str, Any]) -> None:
    registry_path = root / str(config["design_document_registry"])
    registry = load_json(registry_path)
    if registry.get("schema_version") != 3:
        raise GovernanceError("design registry schema_version must be 3")
    if registry.get("registry_role") != "ai-design-document-router-and-publication-index":
        raise GovernanceError("unexpected design registry role")
    documents = registry.get("documents")
    if not isinstance(documents, list) or not documents:
        raise GovernanceError("design registry must contain documents")

    ids: set[str] = set()
    sources: set[str] = set()
    covered: set[str] = set()
    for index, document in enumerate(documents):
        if not isinstance(document, dict):
            raise GovernanceError(f"documents[{index}] must be an object")
        document_id = str(document.get("document_id", ""))
        if not re.fullmatch(r"[a-z0-9][a-z0-9-]*", document_id):
            raise GovernanceError(f"invalid document_id: {document_id!r}")
        if document_id in ids:
            raise GovernanceError(f"duplicate document_id: {document_id}")
        ids.add(document_id)
        if document.get("status") not in ALLOWED_DOCUMENT_STATUSES:
            raise GovernanceError(f"invalid document status: {document_id}")
        if document.get("source_format") not in ALLOWED_SOURCE_FORMATS:
            raise GovernanceError(f"invalid source format: {document_id}")
        if document.get("source_role") not in ALLOWED_SOURCE_ROLES:
            raise GovernanceError(f"invalid source role: {document_id}")
        if document.get("publication_policy") not in ALLOWED_PUBLICATION_POLICIES:
            raise GovernanceError(f"invalid publication policy: {document_id}")
        if document.get("diagram_policy") not in ALLOWED_DIAGRAM_POLICIES:
            raise GovernanceError(f"invalid diagram policy: {document_id}")
        source_path = str(document.get("source_path", ""))
        source = resolve_from(registry_path, source_path)
        if not source.is_file():
            raise GovernanceError(f"registered source is missing: {document_id}: {source_path}")
        sources.add(source.relative_to(root.resolve()).as_posix())
        covered.update(str(value) for value in document.get("responsibility_coverage", []))
        if config.get("enforce_publications") and document.get("publication_policy") != "source_only":
            for field in ("output_pdf", "publication_manifest"):
                relative = document.get(field)
                if not isinstance(relative, str) or not resolve_from(registry_path, relative).exists():
                    raise GovernanceError(f"missing publication {field}: {document_id}")

    expected = set(str(value) for value in config.get("required_design_sources", []))
    if sources != expected:
        raise GovernanceError(
            "design source registration mismatch: missing="
            + ",".join(sorted(expected - sources))
            + " unexpected="
            + ",".join(sorted(sources - expected))
        )
    required_coverage = set(str(value) for value in registry.get("required_responsibility_coverage", []))
    if not required_coverage <= covered:
        raise GovernanceError("required responsibility coverage is incomplete")


def validate_skill_registry(root: Path, config: dict[str, Any]) -> None:
    registry = load_json(root / str(config["skill_registry"]))
    if registry.get("schema_version") != 3:
        raise GovernanceError("skill registry schema_version must be 3")
    policy = registry.get("routing_policy", {})
    expected_policy = {
        "load_all_skills": False,
        "default_selection": "automatic-trigger-match",
        "automatic_selection": True,
        "user_skill_declaration_required": False,
        "require_trigger_match": True,
        "require_execution_report": True,
        "work_modes": ["PLAN", "BUILD", "REVIEW"],
    }
    for key, expected in expected_policy.items():
        if policy.get(key) != expected:
            raise GovernanceError(f"invalid routing policy {key}: {policy.get(key)!r}")

    skills = registry.get("skills")
    if not isinstance(skills, list) or not skills:
        raise GovernanceError("skill registry must contain skills")
    ids: set[str] = set()
    for skill in skills:
        skill_id = str(skill.get("skill_id", ""))
        if not skill_id or skill_id in ids:
            raise GovernanceError(f"invalid or duplicate skill_id: {skill_id!r}")
        ids.add(skill_id)
        if skill.get("status") != "ACTIVE" or skill.get("load_by_default") is not False:
            raise GovernanceError(f"invalid active skill state: {skill_id}")
        for field in ("path", "learning_log"):
            relative = str(skill.get(field, ""))
            if not relative or not (root / relative).is_file():
                raise GovernanceError(f"missing {field} for {skill_id}: {relative}")
        for field in ("trigger_tags", "use_when", "do_not_use_when", "skill_modes"):
            if not skill.get(field):
                raise GovernanceError(f"missing {field}: {skill_id}")

    selected = registry.get("selected_disciplines", [])
    entrypoints = registry.get("discipline_entrypoints", {})
    for discipline in selected:
        values = entrypoints.get(discipline)
        if not isinstance(values, list) or not values:
            raise GovernanceError(f"selected discipline has no entrypoint: {discipline}")
        if not set(values) <= ids:
            raise GovernanceError(f"unknown entrypoint for {discipline}")

    base = registry.get("base_integration", {})
    if base.get("commit") != "ee265576da7f67d3278f8099dd97d4e714ef0651":
        raise GovernanceError("skill registry Base commit is stale")
    if not (root / str(base.get("legacy_aliases", ""))).is_file():
        raise GovernanceError("legacy aliases file is missing")


def validate_interview_registry(root: Path, config: dict[str, Any]) -> None:
    registry_path = root / str(config["interview_registry"])
    registry = load_json(registry_path)
    if registry.get("schema_version") != 1:
        raise GovernanceError("interview registry schema_version must be 1")
    ids: set[str] = set()
    for interview in registry.get("interviews", []):
        interview_id = str(interview.get("interview_id", ""))
        if not interview_id or interview_id in ids:
            raise GovernanceError(f"invalid interview_id: {interview_id!r}")
        ids.add(interview_id)
        if interview.get("status") not in {"USER_CONFIRMED", "CLOSED", "HOLD"}:
            raise GovernanceError(f"unsafe interview status: {interview_id}")
        for field in ("record_path", "executable_prompt_path"):
            relative = str(interview.get(field, ""))
            if not resolve_from(registry_path, relative).is_file():
                raise GovernanceError(f"missing interview {field}: {interview_id}")


def validate_entrypoints(root: Path) -> None:
    start = (root / "START_HERE.md").read_text(encoding="utf-8")
    agents = (root / "AGENTS.md").read_text(encoding="utf-8")
    for token in ("AGENTS.md", "docs/BASE_RULES_VERSION.md", "[기획서]/00_프로젝트_허브/START_HERE.md"):
        if token not in start:
            raise GovernanceError(f"root START_HERE does not route to {token}")
    for token in ("PLAN", "BUILD", "REVIEW", "automatic-trigger-match"):
        if token not in agents:
            raise GovernanceError(f"AGENTS missing Base routing token: {token}")


def run(root: Path, config_path: Path) -> None:
    config = load_json(config_path)
    require_paths(root, [str(value) for value in config.get("required_paths", [])])
    require_paths(root, [str(value) for value in config.get("required_design_sources", [])])
    validate_entrypoints(root)
    validate_design_registry(root, config)
    validate_skill_registry(root, config)
    validate_interview_registry(root, config)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--config", default=".github/documentation-governance.json")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    try:
        run(root, (root / args.config).resolve())
    except GovernanceError as exc:
        print(f"documentation governance: FAIL\n{exc}")
        return 1
    print("documentation governance: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
