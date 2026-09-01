from __future__ import annotations

import hashlib
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class BaseV94AiOperationsAdoptionTests(unittest.TestCase):
    def test_exact_base_identity_and_route_are_adopted(self) -> None:
        adapter = json.loads((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_text(encoding="utf-8"))
        snapshot = json.loads((ROOT / "skills/PROJECT_SKILL_SNAPSHOT.json").read_text(encoding="utf-8"))
        self.assertEqual("9.4.4", adapter["base_release"]["version"])
        self.assertEqual("210ec78292fa12ed7563ba743b322dd36103ae4a", adapter["base_release"]["release_commit"])
        self.assertEqual("bb61e68dc3028421b60c11b87ba2abd297ee6f78", adapter["base_release"]["release_evidence_commit"])
        self.assertEqual("08f882d0c77339e8f7ff187c35b79501e0a2958ab1ff1c7aaa1c0ef8dbee45d6", adapter["skill_registry"]["base"]["sha256"])
        self.assertEqual("08f882d0c77339e8f7ff187c35b79501e0a2958ab1ff1c7aaa1c0ef8dbee45d6", snapshot["base_registry"]["sha256"])
        self.assertIn("optimizing-ai-model-and-prompt-costs", {item["route_id"] for item in adapter["routing"]["base_routes"]})
        self.assertEqual("BASE_SHARED", snapshot["effective_routes"]["optimizing-ai-model-and-prompt-costs"]["source"])

    def test_project_local_skills_and_product_paths_are_preserved(self) -> None:
        adapter = json.loads((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_text(encoding="utf-8"))
        self.assertEqual(
            {"combat-implementation-handoff", "combat-ux-and-accessibility", "ten-paces-game-design", "ten-paces-verification"},
            {item["route_id"] for item in adapter["routing"]["project_routes"]},
        )
        self.assertEqual(["data/", "src/", "scenes/", "assets/", "addons/", "project.godot"], adapter["protected_paths"])

    def test_generated_views_bind_to_canonical_adapter(self) -> None:
        adapter_sha = hashlib.sha256((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_bytes()).hexdigest()
        for path in ("skills/BASE_V9_ADAPTER.json", "skills/PROJECT_BASE_SKILL_ADAPTER.json"):
            view = json.loads((ROOT / path).read_text(encoding="utf-8"))
            self.assertEqual(adapter_sha, view["canonical_source_sha256"])
            self.assertEqual("9.4.4", view["base_release"]["version"])

    def test_ai_and_ui_contracts_are_discoverable(self) -> None:
        ai = (ROOT / "[기획서]/00_프로젝트_허브/AI_WORKFLOW.md").read_text(encoding="utf-8")
        ux = (ROOT / "docs/UX_UI_SYSTEM.md").read_text(encoding="utf-8")
        audit = (ROOT / "docs/reviews/2026-08-01_BASE_V9_4_ADOPTION_AUDIT.md").read_text(encoding="utf-8")
        for token in ("[모델 추천]", "HARD_CONSTRAINT", "Interface-first", "Example-as-Fixture", "refresh_trigger", "NOT_RUN"):
            self.assertIn(token, ai)
        for token in ("입력 접수", "처리 중", "중단", "즉시 완료", "빠른 반복", "재진입", "Reduced Motion", "mute", "haptic-off", "권위 시점"):
            self.assertIn(token, ux)
        self.assertIn("product_paths_changed: false", audit)
        self.assertIn("HUMAN_NOT_RUN", audit)


if __name__ == "__main__":
    unittest.main()
