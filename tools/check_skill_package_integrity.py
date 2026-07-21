#!/usr/bin/env python3
"""Validate local Skill packages and shared Base routes."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class SkillIntegrityError(RuntimeError):
    pass


def run(root: Path = ROOT) -> None:
    registry_path = root / "[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json"
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    skills = registry.get("skills", [])
    if len(skills) != 4:
        raise SkillIntegrityError(f"expected four local Skills, found {len(skills)}")

    ids: set[str] = set()
    paths: set[Path] = set()
    for skill in skills:
        skill_id = str(skill.get("skill_id", ""))
        if not skill_id or skill_id in ids:
            raise SkillIntegrityError(f"invalid or duplicate skill_id: {skill_id!r}")
        ids.add(skill_id)
        path = root / str(skill.get("path", ""))
        if not path.is_file() or path in paths:
            raise SkillIntegrityError(f"missing or duplicate SKILL.md: {skill_id}")
        paths.add(path)
        if "description:" not in path.read_text(encoding="utf-8"):
            raise SkillIntegrityError(f"missing frontmatter description: {skill_id}")
        for field in ("trigger_tags", "use_when", "do_not_use_when", "skill_modes"):
            if not skill.get(field):
                raise SkillIntegrityError(f"missing field: {skill_id}.{field}")
        if not (root / str(skill.get("learning_log", ""))).is_file():
            raise SkillIntegrityError(f"missing learning log: {skill_id}")

    if ids & {"project-operations-and-handoff", "project-health-review"}:
        raise SkillIntegrityError("generic Base responsibilities remain duplicated locally")

    entrypoints = registry.get("discipline_entrypoints", {})
    for discipline in registry.get("selected_disciplines", []):
        values = entrypoints.get(discipline)
        if not isinstance(values, list) or not values or not set(values) <= ids:
            raise SkillIntegrityError(f"invalid entrypoint: {discipline}")

    policy = registry.get("routing_policy", {})
    if policy.get("default_selection") != "automatic-trigger-match":
        raise SkillIntegrityError("automatic routing is disabled")
    if policy.get("work_modes") != ["PLAN", "BUILD", "REVIEW"]:
        raise SkillIntegrityError("invalid Work Mode contract")

    base = registry.get("base_integration", {})
    routes = base.get("shared_skill_routes", {})
    if base.get("commit") != "ee265576da7f67d3278f8099dd97d4e714ef0651":
        raise SkillIntegrityError("stale Base commit")
    if not isinstance(routes, dict) or len(routes) != 13 or len(set(routes.values())) != 13:
        raise SkillIntegrityError("Base shared routes must contain 13 unique Skills")
    if not (root / str(base.get("legacy_aliases", ""))).is_file():
        raise SkillIntegrityError("missing Legacy Skill Alias")

    presentation = registry.get("human_presentation", {})
    if presentation.get("publication_policy") != "source_only":
        raise SkillIntegrityError("Skill Registry must use source_only presentation")
    if presentation.get("primary_reading_format") != "SKILL_REGISTRY.json":
        raise SkillIntegrityError("Skill Registry must be the primary reading format")


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
