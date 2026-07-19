#!/usr/bin/env python3
"""Validate the Ten Paces Base schema v3 governance foundation.

This checker intentionally uses only the Python standard library so it can run
before the PDF publication toolchain is installed. Publication existence and
visual review are separate gates controlled by the config.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


ALLOWED_DOCUMENT_STATUSES = {
    "ACTIVE",
    "SUPPORT",
    "HOLD",
    "BACKUP",
    "REMOVAL_CANDIDATE",
    "NOT_INSTALLED",
}
ALLOWED_SOURCE_FORMATS = {"markdown", "json"}
ALLOWED_SOURCE_ROLES = {"narrative_spec", "structured_data", "registry", "state"}
ALLOWED_DIAGRAM_POLICIES = {"none", "mermaid", "generated"}
EXCLUDED_DIRS = {".git", ".idea", ".vscode", "__pycache__"}


class GovernanceError(RuntimeError):
    pass


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


def require_path(root: Path, relative: str) -> None:
    path = root / relative
    if not path.exists():
        raise GovernanceError(f"required path is missing: {relative}")


def resolve_from_file(file_path: Path, relative: str) -> Path:
    return (file_path.parent / relative).resolve()


def is_ignored(path: Path, root: Path, ignored_segments: set[str]) -> bool:
    try:
        parts = path.relative_to(root).parts
    except ValueError:
        return False
    return any(part in ignored_segments or part in EXCLUDED_DIRS for part in parts)


def validate_top_level_design_root(root: Path, design_root: str) -> None:
    expected = root / design_root
    if not expected.is_dir():
        raise GovernanceError(f"top-level design root is missing: {design_root}")

    nested: list[str] = []
    for candidate in root.rglob("*"):
        if not candidate.is_dir() or candidate.name != design_root:
            continue
        if candidate == expected or is_ignored(candidate, root, set()):
            continue
        nested.append(candidate.relative_to(root).as_posix())
    if nested:
        raise GovernanceError(
            "nested active design roots are forbidden: " + ", ".join(sorted(nested))
        )


def validate_forbidden_names(
    root: Path,
    active_roots: list[str],
    ignored_segments: set[str],
    patterns: list[str],
) -> None:
    compiled = [re.compile(pattern) for pattern in patterns]
    violations: list[str] = []
    for relative_root in active_roots:
        base = root / relative_root
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if is_ignored(path, root, ignored_segments) or not path.is_file():
                continue
            if any(pattern.search(path.name) for pattern in compiled):
                violations.append(path.relative_to(root).as_posix())
    if violations:
        raise GovernanceError(
            "forbidden active version/copy filenames: " + ", ".join(sorted(violations))
        )


def validate_design_registry(root: Path, config: dict[str, Any]) -> None:
    registry_path = root / str(config["design_document_registry"])
    registry = load_json(registry_path)
    if registry.get("schema_version") != 3:
        raise GovernanceError("design registry schema_version must be 3")
    if registry.get("registry_role") != "ai-design-document-router-and-publication-index":
        raise GovernanceError("unexpected design registry role")

    documents = registry.get("documents")
    if not isinstance(documents, list) or not documents:
        raise GovernanceError("design registry must contain at least one document")

    ids: set[str] = set()
    registered_sources: set[str] = set()
    for index, document in enumerate(documents):
        if not isinstance(document, dict):
            raise GovernanceError(f"documents[{index}] must be an object")
        document_id = document.get("document_id")
        if not isinstance(document_id, str) or not re.fullmatch(r"[a-z0-9][a-z0-9-]*", document_id):
            raise GovernanceError(f"invalid document_id at index {index}: {document_id!r}")
        if document_id in ids:
            raise GovernanceError(f"duplicate document_id: {document_id}")
        ids.add(document_id)

        status = document.get("status")
        if status not in ALLOWED_DOCUMENT_STATUSES:
            raise GovernanceError(f"invalid status for {document_id}: {status!r}")
        if document.get("source_format") not in ALLOWED_SOURCE_FORMATS:
            raise GovernanceError(f"invalid source_format for {document_id}")
        if document.get("source_role") not in ALLOWED_SOURCE_ROLES:
            raise GovernanceError(f"invalid source_role for {document_id}")
        if document.get("publication_policy") != "always_sync":
            raise GovernanceError(f"publication_policy must be always_sync: {document_id}")
        if document.get("diagram_policy") not in ALLOWED_DIAGRAM_POLICIES:
            raise GovernanceError(f"invalid diagram_policy for {document_id}")

        source_path = document.get("source_path")
        if not isinstance(source_path, str) or not source_path:
            raise GovernanceError(f"missing source_path for {document_id}")
        resolved_source = resolve_from_file(registry_path, source_path)
        if not resolved_source.is_file():
            raise GovernanceError(
                f"registered source does not exist for {document_id}: {source_path}"
            )
        try:
            registered_sources.add(resolved_source.relative_to(root.resolve()).as_posix())
        except ValueError as exc:
            raise GovernanceError(
                f"registered source escapes repository for {document_id}: {source_path}"
            ) from exc

        if config.get("enforce_publications"):
            output_pdf = document.get("output_pdf")
            manifest = document.get("publication_manifest")
            for label, relative in (("PDF", output_pdf), ("manifest", manifest)):
                if not isinstance(relative, str) or not resolve_from_file(registry_path, relative).exists():
                    raise GovernanceError(f"missing required {label} for {document_id}: {relative}")

    expected_sources = set(config.get("required_design_sources", []))
    missing_registration = expected_sources - registered_sources
    unexpected_registration = registered_sources - expected_sources
    if missing_registration:
        raise GovernanceError(
            "required design sources are not registered: " + ", ".join(sorted(missing_registration))
        )
    if unexpected_registration:
        raise GovernanceError(
            "unexpected active design sources are registered: " + ", ".join(sorted(unexpected_registration))
        )

    required_coverage = set(registry.get("required_responsibility_coverage", []))
    covered = {
        item
        for document in documents
        for item in document.get("responsibility_coverage", [])
        if isinstance(item, str)
    }
    uncovered = required_coverage - covered
    if uncovered:
        raise GovernanceError(
            "required responsibility coverage is missing: " + ", ".join(sorted(uncovered))
        )


def validate_skill_registry(root: Path, config: dict[str, Any]) -> None:
    registry_path = root / str(config["skill_registry"])
    registry = load_json(registry_path)
    if registry.get("schema_version") != 3:
        raise GovernanceError("skill registry schema_version must be 3")
    if registry.get("registry_role") != "project-skill-router-and-learning-index":
        raise GovernanceError("unexpected skill registry role")

    policy = registry.get("routing_policy")
    if not isinstance(policy, dict):
        raise GovernanceError("routing_policy must be an object")
    if policy.get("load_all_skills") is not False:
        raise GovernanceError("load_all_skills must be false")
    if policy.get("default_selection") != "none":
        raise GovernanceError("default_selection must be none")
    if policy.get("require_trigger_match") is not True:
        raise GovernanceError("require_trigger_match must be true")

    skills = registry.get("skills")
    if not isinstance(skills, list) or not skills:
        raise GovernanceError("skill registry must contain at least one skill")

    skill_ids: set[str] = set()
    for index, skill in enumerate(skills):
        if not isinstance(skill, dict):
            raise GovernanceError(f"skills[{index}] must be an object")
        skill_id = skill.get("skill_id")
        if not isinstance(skill_id, str) or not skill_id:
            raise GovernanceError(f"invalid skill_id at index {index}")
        if skill_id in skill_ids:
            raise GovernanceError(f"duplicate skill_id: {skill_id}")
        skill_ids.add(skill_id)
        if skill.get("load_by_default") is not False:
            raise GovernanceError(f"load_by_default must be false: {skill_id}")
        if skill.get("status") != "ACTIVE":
            raise GovernanceError(f"active registry contains non-ACTIVE skill: {skill_id}")
        triggers = skill.get("trigger_tags")
        if not isinstance(triggers, list) or not triggers:
            raise GovernanceError(f"trigger_tags are required: {skill_id}")
        for field in ("path", "learning_log"):
            relative = skill.get(field)
            if not isinstance(relative, str) or not (root / relative).is_file():
                raise GovernanceError(f"missing {field} for {skill_id}: {relative}")

    selected = registry.get("selected_disciplines")
    if not isinstance(selected, list) or len(selected) != len(set(selected)):
        raise GovernanceError("selected_disciplines must be a unique list")
    required_disciplines = set(config.get("required_skill_disciplines", []))
    missing_disciplines = required_disciplines - set(selected)
    if missing_disciplines:
        raise GovernanceError(
            "required selected disciplines are missing: " + ", ".join(sorted(missing_disciplines))
        )

    entrypoints = registry.get("discipline_entrypoints")
    if not isinstance(entrypoints, dict):
        raise GovernanceError("discipline_entrypoints must be an object")
    for discipline in selected:
        ids = entrypoints.get(discipline)
        if not isinstance(ids, list) or not ids:
            raise GovernanceError(f"selected discipline has no entrypoint: {discipline}")
        unknown = set(ids) - skill_ids
        if unknown:
            raise GovernanceError(
                f"unknown skill entrypoint for {discipline}: {', '.join(sorted(unknown))}"
            )

    manifest_path = root / str(config["skill_map_publication_manifest"])
    manifest = load_json(manifest_path)
    if config.get("enforce_skill_map_publication"):
        pdf_path = registry_path.parent / "PROJECT_SKILL_MAP.pdf"
        if not pdf_path.is_file():
            raise GovernanceError("PROJECT_SKILL_MAP.pdf is required but missing")
        pdf_status = manifest.get("outputs", {}).get("pdf", {}).get("status")
        if pdf_status != "CURRENT":
            raise GovernanceError(f"skill map PDF is not CURRENT: {pdf_status!r}")


def validate_interview_registry(root: Path, config: dict[str, Any]) -> None:
    registry_path = root / str(config["interview_registry"])
    registry = load_json(registry_path)
    if registry.get("schema_version") != 1:
        raise GovernanceError("interview registry schema_version must be 1")
    interviews = registry.get("interviews")
    if not isinstance(interviews, list):
        raise GovernanceError("interviews must be a list")

    ids: set[str] = set()
    for interview in interviews:
        if not isinstance(interview, dict):
            raise GovernanceError("interview entry must be an object")
        interview_id = interview.get("interview_id")
        if not isinstance(interview_id, str) or interview_id in ids:
            raise GovernanceError(f"invalid or duplicate interview_id: {interview_id!r}")
        ids.add(interview_id)
        for field in ("record_path", "executable_prompt_path"):
            relative = interview.get(field)
            if not isinstance(relative, str) or not resolve_from_file(registry_path, relative).is_file():
                raise GovernanceError(f"missing interview {field}: {relative}")
        if interview.get("status") not in {"USER_CONFIRMED", "CLOSED", "HOLD"}:
            raise GovernanceError(
                f"interview is not confirmed or safely closed: {interview_id}"
            )


def validate_entrypoint_content(root: Path) -> None:
    start = (root / "START_HERE.md").read_text(encoding="utf-8")
    for required in ("AGENTS.md", "[기획서]/00_프로젝트_허브/START_HERE.md"):
        if required not in start:
            raise GovernanceError(f"root START_HERE does not route to {required}")


def run(root: Path, config_path: Path) -> None:
    config = load_json(config_path)
    for relative in config.get("required_paths", []):
        require_path(root, relative)
    for relative in config.get("required_design_sources", []):
        require_path(root, relative)

    if config.get("enforce_top_level_design_root"):
        validate_top_level_design_root(root, str(config["design_root"]))

    validate_forbidden_names(
        root,
        list(config.get("active_roots", [])),
        set(config.get("ignored_segments", [])),
        list(config.get("forbidden_active_name_patterns", [])),
    )
    validate_design_registry(root, config)
    validate_skill_registry(root, config)
    validate_interview_registry(root, config)
    validate_entrypoint_content(root)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".", help="repository root")
    parser.add_argument(
        "--config",
        default=".github/documentation-governance.json",
        help="governance config path relative to root",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    config_path = (root / args.config).resolve()
    try:
        run(root, config_path)
    except GovernanceError as exc:
        print(f"governance: FAIL: {exc}", file=sys.stderr)
        return 1
    print("governance: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
