#!/usr/bin/env python3
"""Validate local Skill packages and shared Base routes."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


class SkillIntegrityError(RuntimeError):
    pass


def load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise SkillIntegrityError(f"missing JSON file: {path.as_posix()}") from exc
    except json.JSONDecodeError as exc:
        raise SkillIntegrityError(
            f"invalid JSON: {path.as_posix()}:{exc.lineno}:{exc.colno}: {exc.msg}"
        ) from exc
    if not isinstance(value, dict):
        raise SkillIntegrityError(f"JSON root must be an object: {path.as_posix()}")
    return value


def run(root: Path = ROOT) -> None:
    registry_path = root / "[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json"
    registry = load_json(registry_path)
    freshness = load_json(root / ".github/reference-freshness.json")

    skills = registry.get("skills", [])
    if not isinstance(skills, list) or len(skills) != 4:
        raise SkillIntegrityError(
            f"expected four local Skills, found {len(skills) if isinstance(skills, list) else 'invalid'}"
        )

    ids: set[str] = set()
    paths: set[Path] = set()
    for skill in skills:
        if not isinstance(skill, dict):
            raise SkillIntegrityError("local Skill entry must be an object")
        skill_id = str(skill.get("skill_id", ""))
        if not skill_id or skill_id in ids:
            raise SkillIntegrityError(f"invalid or duplicate skill_id: {skill_id!r}")
        ids.add(skill_id)
        path = root / str(skill.get("path", ""))
        if not path.is_file() or path in paths:
            raise SkillIntegrityError(f"missing or duplicate SKILL.md: {skill_id}")
        paths.add(path)
        text = path.read_text(encoding="utf-8")
        if "description:" not in text:
            raise SkillIntegrityError(f"missing frontmatter description: {skill_id}")
        for token in ("## 책임", "## 완료 기준"):
            if token not in text:
                raise SkillIntegrityError(f"local Skill body is missing {token}: {skill_id}")
        for field in ("trigger_tags", "use_when", "do_not_use_when", "skill_modes"):
            if not skill.get(field):
                raise SkillIntegrityError(f"missing field: {skill_id}.{field}")
        if skill.get("load_by_default") is not False or skill.get("status") != "ACTIVE":
            raise SkillIntegrityError(f"invalid active/load state: {skill_id}")
        if not (root / str(skill.get("learning_log", ""))).is_file():
            raise SkillIntegrityError(f"missing learning log: {skill_id}")

    if ids & {"project-operations-and-handoff", "project-health-review"}:
        raise SkillIntegrityError("generic Base responsibilities remain duplicated locally")

    entrypoints = registry.get("discipline_entrypoints", {})
    if not isinstance(entrypoints, dict):
        raise SkillIntegrityError("discipline_entrypoints must be an object")
    for discipline in registry.get("selected_disciplines", []):
        values = entrypoints.get(discipline)
        if not isinstance(values, list) or not values or not set(values) <= ids:
            raise SkillIntegrityError(f"invalid entrypoint: {discipline}")

    policy = registry.get("routing_policy", {})
    if policy.get("default_selection") != "automatic-trigger-match":
        raise SkillIntegrityError("automatic routing is disabled")
    if policy.get("load_all_skills") is not False:
        raise SkillIntegrityError("load_all_skills must remain false")
    if policy.get("work_modes") != ["PLAN", "BUILD", "REVIEW"]:
        raise SkillIntegrityError("invalid Work Mode contract")

    base = registry.get("base_integration", {})
    routes = base.get("shared_skill_routes", {}) if isinstance(base, dict) else {}
    expected_commit = str(freshness.get("expected_base_commit", ""))
    expected_ids = {str(value) for value in freshness.get("expected_base_skill_ids", [])}
    if str(base.get("commit", "")) != expected_commit:
        raise SkillIntegrityError("stale Base commit")
    if not isinstance(routes, dict):
        raise SkillIntegrityError("Base shared routes must be an object")
    route_values = [str(value) for value in routes.values()]
    if len(route_values) != len(set(route_values)):
        raise SkillIntegrityError("Base shared routes must contain unique Skills")
    if set(route_values) != expected_ids:
        raise SkillIntegrityError(
            "Base shared routes differ from freshness contract: "
            f"missing={sorted(expected_ids - set(route_values))} "
            f"unexpected={sorted(set(route_values) - expected_ids)}"
        )
    if not (root / str(base.get("legacy_aliases", ""))).is_file():
        raise SkillIntegrityError("missing Legacy Skill Alias")

    presentation = registry.get("human_presentation", {})
    if presentation.get("publication_policy") != "source_only":
        raise SkillIntegrityError("Skill Registry must use source_only presentation")
    if presentation.get("primary_reading_format") != "SKILL_REGISTRY.json":
        raise SkillIntegrityError("Skill Registry must be the primary reading format")
    for field in ("publication_manifest", "generator", "markdown_summary", "diagram_directory"):
        if presentation.get(field) is not None:
            raise SkillIntegrityError(f"source_only Skill Registry must null {field}")


def main() -> int:
    try:
        run()
    except (SkillIntegrityError, json.JSONDecodeError) as exc:
        print(f"skill package integrity: FAIL\n{exc}")
        return 1
    print("skill package integrity: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
