#!/usr/bin/env python3
"""Validate active Ten Paces project skill packages."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json"


class SkillIntegrityError(RuntimeError):
    pass


def run(root: Path = ROOT) -> None:
    registry_path = root / "[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json"
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    skills = registry.get("skills", [])
    if not skills:
        raise SkillIntegrityError("active project Skill Registry is empty")
    ids: set[str] = set()
    paths: set[Path] = set()
    for skill in skills:
        skill_id = str(skill.get("skill_id", ""))
        if not skill_id or skill_id in ids:
            raise SkillIntegrityError(f"invalid or duplicate skill_id: {skill_id!r}")
        ids.add(skill_id)
        path = root / str(skill.get("path", ""))
        if not path.is_file() or path in paths:
            raise SkillIntegrityError(f"missing or duplicated SKILL.md: {skill_id}: {path}")
        paths.add(path)
        text = path.read_text(encoding="utf-8")
        if "description:" not in text:
            raise SkillIntegrityError(f"Skill frontmatter description is missing: {skill_id}")
        for field in ("trigger_tags", "use_when", "do_not_use_when", "skill_modes"):
            if not skill.get(field):
                raise SkillIntegrityError(f"registry field is missing: {skill_id}.{field}")
        learning = root / str(skill.get("learning_log", ""))
        if not learning.is_file():
            raise SkillIntegrityError(f"learning log is missing: {skill_id}")

    selected = registry.get("selected_disciplines", [])
    entrypoints = registry.get("discipline_entrypoints", {})
    for discipline in selected:
        values = entrypoints.get(discipline)
        if not isinstance(values, list) or not values:
            raise SkillIntegrityError(f"selected discipline has no entrypoint: {discipline}")
        if not set(values) <= ids:
            raise SkillIntegrityError(f"unknown entrypoint for selected discipline: {discipline}")

    policy = registry.get("routing_policy", {})
    if policy.get("default_selection") != "automatic-trigger-match":
        raise SkillIntegrityError("automatic trigger routing is not enabled")
    if policy.get("work_modes") != ["PLAN", "BUILD", "REVIEW"]:
        raise SkillIntegrityError("Work Mode contract is invalid")
    base = registry.get("base_integration", {})
    if base.get("commit") != "ee265576da7f67d3278f8099dd97d4e714ef0651":
        raise SkillIntegrityError("Base integration commit is stale")
    if not (root / str(base.get("legacy_aliases", ""))).is_file():
        raise SkillIntegrityError("Legacy Skill Alias file is missing")


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
