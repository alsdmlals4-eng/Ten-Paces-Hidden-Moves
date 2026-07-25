from __future__ import annotations

import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_checker():
    path = ROOT / "tools/check_archive_governance.py"
    spec = importlib.util.spec_from_file_location("ten_paces_archive_checker", path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


checker = load_checker()


class ArchiveRetentionGovernanceTests(unittest.TestCase):
    def test_current_repository_contract_passes(self) -> None:
        self.assertEqual([], checker.validate(ROOT))

    def test_shared_extension_pin_and_route_match(self) -> None:
        expected = checker.EXPECTED_BASE_COMMIT
        routes = json.loads((ROOT / "skills/BASE_SHARED_SKILL_ROUTES.json").read_text(encoding="utf-8"))
        project_adapter = json.loads((ROOT / "skills/PROJECT_BASE_SKILL_ADAPTER.json").read_text(encoding="utf-8"))
        archive_adapter = json.loads((ROOT / "[기획서]/00_프로젝트_허브/ARCHIVE_RETENTION_ADAPTER.json").read_text(encoding="utf-8"))
        registry = json.loads((ROOT / "[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json").read_text(encoding="utf-8"))
        self.assertEqual(expected, routes["base"]["commit"])
        self.assertEqual(expected, project_adapter["base"]["commit"])
        self.assertEqual(expected, archive_adapter["base"]["commit"])
        self.assertEqual(expected, registry["base_integration"]["shared_extension_commit"])
        self.assertEqual(
            "governing-legacy-retention-and-archives",
            registry["base_integration"]["shared_skill_routes"]["legacy_retention_and_archives"],
        )

    def test_archive_policy_forbids_blank_files_and_secrets(self) -> None:
        adapter = json.loads((ROOT / "[기획서]/00_프로젝트_허브/ARCHIVE_RETENTION_ADAPTER.json").read_text(encoding="utf-8"))
        self.assertTrue(adapter["policies"]["preserve_original_content"])
        self.assertFalse(adapter["policies"]["blank_placeholders_allowed"])
        self.assertFalse(adapter["policies"]["secrets_may_be_archived"])
        self.assertFalse(adapter["policies"]["default_active_authority"])
        self.assertEqual("NONE", adapter["policies"]["default_implementation_authority"])

    def test_base_shared_skill_body_is_not_copied(self) -> None:
        self.assertFalse((ROOT / "skills/governing-legacy-retention-and-archives/SKILL.md").exists())

    def test_archive_readme_declares_non_authority_and_preservation(self) -> None:
        text = (ROOT / "docs/archive/README.md").read_text(encoding="utf-8")
        for token in (
            "현재 정본이 아니며 구현 권한이 없다",
            "원문을 비우지 않는다",
            "비밀키",
            "기존 구형 자료를 이동·삭제·재작성하지 않는다",
        ):
            self.assertIn(token, text)


if __name__ == "__main__":
    unittest.main()
