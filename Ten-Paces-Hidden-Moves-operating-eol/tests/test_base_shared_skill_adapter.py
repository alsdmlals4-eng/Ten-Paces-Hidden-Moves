from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE_COMMIT = "6a224e450f9420223c00921f3c56e051612f92ad"


def load(path: str) -> dict:
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


class BaseSharedSkillAdapterTests(unittest.TestCase):
    def test_pins_routes_and_project_policy(self) -> None:
        route = load("skills/BASE_SHARED_SKILL_ROUTES.json")
        adapter = load("skills/PROJECT_BASE_SKILL_ADAPTER.json")
        archive = load("[기획서]/00_프로젝트_허브/ARCHIVE_RETENTION_ADAPTER.json")
        self.assertEqual({route["base"]["commit"], adapter["base"]["commit"], archive["base"]["commit"]}, {BASE_COMMIT})
        self.assertEqual(route["base_registry_route"]["adapter"], "skills/PROJECT_BASE_SKILL_ADAPTER.json")
        self.assertFalse(route["base_registry_route"]["copy_skill_bodies_to_project"])
        self.assertEqual(
            {item["skill_id"] for item in route["routes"].values()},
            {"governing-legacy-retention-and-archives", "evaluating-godot-assets-and-plugins-before-creation"},
        )
        self.assertEqual(route["routes"]["legacy_retention_and_archives"]["adapter"], "[기획서]/00_프로젝트_허브/ARCHIVE_RETENTION_ADAPTER.json")
        policy = route["local_skill_policy"]
        self.assertEqual(policy["base_shared_skills"], "adapter-only")
        self.assertEqual(policy["project_specific_skills"], "local-only")
        self.assertFalse(policy["duplicate_base_skill_bodies"])

    def test_bound_paths_and_non_authoritative_archive(self) -> None:
        adapter = load("skills/PROJECT_BASE_SKILL_ADAPTER.json")
        archive = load("[기획서]/00_프로젝트_허브/ARCHIVE_RETENTION_ADAPTER.json")
        for path in adapter["role_bindings"].values():
            self.assertTrue((ROOT / path).exists(), path)
        self.assertTrue((ROOT / adapter["third_party_inventory"]).is_file())
        self.assertTrue((ROOT / adapter["license_record"]).is_file())
        self.assertFalse(archive["policies"]["default_active_authority"])
        self.assertEqual(archive["policies"]["default_implementation_authority"], "NONE")
        self.assertEqual(load("docs/archive/MANIFEST.json")["manifest_role"], "project-archive-retention-index")


if __name__ == "__main__":
    unittest.main()
