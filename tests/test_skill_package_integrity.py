from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json"


def load_registry() -> dict:
    return json.loads(REGISTRY.read_text(encoding="utf-8"))


def test_active_skill_packages_are_registered_and_readable() -> None:
    registry = load_registry()
    skills = registry["skills"]
    ids: set[str] = set()
    paths: set[Path] = set()
    for skill in skills:
        assert skill["status"] == "ACTIVE"
        assert skill["load_by_default"] is False
        assert skill["skill_id"] not in ids
        ids.add(skill["skill_id"])
        path = ROOT / skill["path"]
        assert path.is_file(), skill["path"]
        assert path not in paths
        paths.add(path)
        text = path.read_text(encoding="utf-8")
        assert "description:" in text
        assert skill["learning_log"] == "skills/SKILL_LEARNING_LOG.md"
        assert skill["trigger_tags"]
        assert skill["use_when"]
        assert skill["do_not_use_when"]
        assert skill.get("skill_modes")


def test_selected_disciplines_have_known_entrypoints() -> None:
    registry = load_registry()
    ids = {skill["skill_id"] for skill in registry["skills"]}
    for discipline in registry["selected_disciplines"]:
        entrypoints = registry["discipline_entrypoints"].get(discipline)
        assert entrypoints, discipline
        assert set(entrypoints) <= ids


def test_registry_uses_latest_base_routing_contract() -> None:
    registry = load_registry()
    policy = registry["routing_policy"]
    assert policy["default_selection"] == "automatic-trigger-match"
    assert policy["automatic_selection"] is True
    assert policy["user_skill_declaration_required"] is False
    assert policy["require_execution_report"] is True
    assert policy["work_modes"] == ["PLAN", "BUILD", "REVIEW"]
    assert registry["base_integration"]["commit"] == "ee265576da7f67d3278f8099dd97d4e714ef0651"
    assert (ROOT / registry["base_integration"]["legacy_aliases"]).is_file()
