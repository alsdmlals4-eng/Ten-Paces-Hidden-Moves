#!/usr/bin/env python3
"""Validate the compact Ten Paces project operating-system contract."""

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
        raise ContractError(
            f"invalid JSON: {path.as_posix()}:{exc.lineno}:{exc.colno}: {exc.msg}"
        ) from exc
    if not isinstance(value, dict):
        raise ContractError(f"JSON root must be an object: {path.as_posix()}")
    return value


def resolve_from(owner: Path, relative: str) -> Path:
    return (owner.parent / relative).resolve()


def validate_required_paths(root: Path, config: dict[str, Any]) -> None:
    missing = [
        str(path)
        for path in config.get("required_paths", [])
        if not (root / str(path)).exists()
    ]
    if missing:
        raise ContractError("required paths are missing: " + ", ".join(missing))


def validate_entrypoints(root: Path) -> None:
    start = (root / "START_HERE.md").read_text(encoding="utf-8")
    agents = (root / "AGENTS.md").read_text(encoding="utf-8")
    for token in (
        "AGENTS.md",
        "ACTIVE_CONTEXT.md",
        "DOCUMENTATION_MAP.md",
        "PR #7",
        "Issue #13",
    ):
        if token not in start:
            raise ContractError(f"root START_HERE does not route to {token}")
    for token in (
        "PLAN",
        "BUILD",
        "REVIEW",
        "Skill Mode",
        "execution-report",
        "기준 SHA",
        "reference-freshness",
    ):
        if token not in agents:
            raise ContractError(f"AGENTS is missing the routing contract token: {token}")


def validate_schema_contracts(root: Path) -> None:
    design = load_json(root / "schemas/design-document-registry-v3.schema.json")
    if "Ten-Paces-Hidden-Moves" not in str(design.get("$id", "")):
        raise ContractError("design registry schema $id must belong to this project")
    document = design.get("$defs", {}).get("document", {})
    properties = document.get("properties", {})
    policies = set(properties.get("publication_policy", {}).get("enum", []))
    if policies != {"source_only", "milestone_sync", "always_sync"}:
        raise ContractError("design registry schema publication policies are incomplete")
    source_only_rule = None
    for rule in document.get("allOf", []):
        expected = (
            rule.get("if", {})
            .get("properties", {})
            .get("publication_policy", {})
            .get("const")
        )
        if expected == "source_only":
            source_only_rule = rule.get("then", {}).get("properties", {})
            break
    if source_only_rule is None:
        raise ContractError("design registry schema lacks source_only conditional shape")
    for field in (
        "output_pdf",
        "output_docx",
        "asset_dir",
        "publication_manifest",
        "generator",
    ):
        if source_only_rule.get(field, {}).get("type") != "null":
            raise ContractError(f"design schema source_only must null {field}")
    if source_only_rule.get("diagram_policy", {}).get("const") != "none":
        raise ContractError("design schema source_only must disable diagrams")

    skill = load_json(root / "schemas/skill-registry-v3.schema.json")
    if "Ten-Paces-Hidden-Moves" not in str(skill.get("$id", "")):
        raise ContractError("Skill registry schema $id must belong to this project")
    presentation = skill.get("properties", {}).get("human_presentation", {})
    presentation_policies = set(
        presentation.get("properties", {}).get("publication_policy", {}).get("enum", [])
    )
    if "source_only" not in presentation_policies:
        raise ContractError("Skill registry schema must support source_only")


def validate_design_registry(root: Path, config: dict[str, Any]) -> None:
    registry_path = root / str(config["design_document_registry"])
    registry = load_json(registry_path)
    if registry.get("schema_version") != 3:
        raise ContractError("design registry schema_version must be 3")
    if not registry.get("publication_note"):
        raise ContractError("design registry must explain its publication state")
    documents = registry.get("documents", [])
    if not isinstance(documents, list) or not documents:
        raise ContractError("design registry is empty")

    ids: set[str] = set()
    sources: set[str] = set()
    coverage: set[str] = set()
    for document in documents:
        if not isinstance(document, dict):
            raise ContractError("design document entry must be an object")
        document_id = str(document.get("document_id", ""))
        if not document_id or document_id in ids:
            raise ContractError(f"invalid or duplicate document_id: {document_id!r}")
        ids.add(document_id)
        if document.get("status") != "ACTIVE":
            raise ContractError(f"registered document is not ACTIVE: {document_id}")
        if document.get("source_format") not in {"markdown", "json"}:
            raise ContractError(f"invalid source_format: {document_id}")
        policy = document.get("publication_policy")
        if policy not in {"source_only", "milestone_sync", "always_sync"}:
            raise ContractError(f"invalid publication_policy: {document_id}")
        source = resolve_from(registry_path, str(document.get("source_path", "")))
        if not source.is_file():
            raise ContractError(f"registered source is missing: {document_id}")
        sources.add(source.relative_to(root).as_posix())
        coverage.update(str(value) for value in document.get("responsibility_coverage", []))

        text = source.read_text(encoding="utf-8")
        for section in document.get("required_sections", []):
            if str(section) not in text:
                raise ContractError(
                    f"registered source is missing required section: {document_id}: {section}"
                )

        if policy == "source_only":
            for field in (
                "output_pdf",
                "output_docx",
                "asset_dir",
                "publication_manifest",
                "generator",
            ):
                if document.get(field) is not None:
                    raise ContractError(
                        f"source_only document must not declare {field}: {document_id}"
                    )
            if document.get("diagram_policy") != "none":
                raise ContractError(
                    f"source_only document must use diagram_policy=none: {document_id}"
                )
        else:
            for field in ("output_pdf", "publication_manifest", "generator"):
                if not isinstance(document.get(field), str) or not document.get(field):
                    raise ContractError(f"published document is missing {field}: {document_id}")
            generator = root / str(document["generator"])
            if not generator.is_file():
                raise ContractError(
                    f"publication generator is missing: {document_id}: {document['generator']}"
                )

    expected = {str(value) for value in config.get("required_design_sources", [])}
    if sources != expected:
        raise ContractError(
            f"design sources differ: missing={sorted(expected-sources)} "
            f"unexpected={sorted(sources-expected)}"
        )
    required = {
        str(value) for value in registry.get("required_responsibility_coverage", [])
    }
    if not required <= coverage:
        raise ContractError(
            f"design responsibility coverage is incomplete: {sorted(required-coverage)}"
        )


def validate_skill_registry(root: Path, config: dict[str, Any]) -> None:
    registry = load_json(root / str(config["skill_registry"]))
    freshness = load_json(root / str(config["reference_freshness_config"]))
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

    presentation = registry.get("human_presentation", {})
    if presentation.get("publication_policy") != "source_only":
        raise ContractError("project Skill Registry must use source_only presentation")
    if presentation.get("primary_reading_format") != "SKILL_REGISTRY.json":
        raise ContractError("project Skill Registry must be the primary reading format")
    for field in (
        "publication_manifest",
        "generator",
        "markdown_summary",
        "diagram_directory",
    ):
        if presentation.get(field) is not None:
            raise ContractError(f"source-only Skill Registry must not declare {field}")

    base = registry.get("base_integration", {})
    expected_commit = str(freshness.get("expected_base_commit", ""))
    if str(base.get("commit", "")) != expected_commit:
        raise ContractError("Skill Registry Base commit is stale")
    shared_routes = base.get("shared_skill_routes", {})
    expected_ids = {str(value) for value in freshness.get("expected_base_skill_ids", [])}
    if not isinstance(shared_routes, dict):
        raise ContractError("Base shared Skill routes must be an object")
    values = [str(value) for value in shared_routes.values()]
    if len(values) != len(set(values)):
        raise ContractError("Base shared Skill routes must be unique")
    if set(values) != expected_ids:
        raise ContractError(
            "Base shared Skill routes differ from freshness config: "
            f"missing={sorted(expected_ids-set(values))} "
            f"unexpected={sorted(set(values)-expected_ids)}"
        )
    if not (root / str(base.get("legacy_aliases", ""))).is_file():
        raise ContractError("Legacy Skill Alias file is missing")

    skills = registry.get("skills", [])
    if not isinstance(skills, list) or len(skills) != 4:
        raise ContractError(
            f"expected four project-specific local Skills, found {len(skills) if isinstance(skills, list) else 'invalid'}"
        )
    ids: set[str] = set()
    for skill in skills:
        if not isinstance(skill, dict):
            raise ContractError("project Skill entry must be an object")
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

    forbidden_local = {"project-operations-and-handoff", "project-health-review"}
    if ids & forbidden_local:
        raise ContractError(
            f"generic Base responsibilities remain duplicated locally: {sorted(ids & forbidden_local)}"
        )

    for discipline in registry.get("selected_disciplines", []):
        entrypoints = registry.get("discipline_entrypoints", {}).get(discipline, [])
        if not entrypoints or not set(entrypoints) <= ids:
            raise ContractError(f"invalid selected-discipline entrypoint: {discipline}")


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
    validate_schema_contracts(root)
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
