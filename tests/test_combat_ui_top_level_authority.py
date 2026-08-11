from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class CombatUiTopLevelAuthorityTests(unittest.TestCase):
    def test_agents_core_uses_current_public_start_distance_and_labels_legacy_coordinates(self) -> None:
        text = (ROOT / "AGENTS.md").read_text(encoding="utf-8")
        core = text.split("## 5. 프로젝트 코어", 1)[1].split("## 6. 행동 선택 계약", 1)[0]

        self.assertIn("시작 공개 거리 2", core)
        self.assertIn("4/7 시작 좌표는 `IMPLEMENTED_LEGACY`", core)
        self.assertNotIn("플레이어 4번·상대 7번 시작.", core)

    def test_base_rules_project_contract_uses_public_distance_and_labels_runtime_legacy(self) -> None:
        text = (ROOT / "docs/BASE_RULES_VERSION.md").read_text(encoding="utf-8")
        core = text.split("## 6. 프로젝트 고유 계약", 1)[1].split(
            "## 7. 현재 프로젝트 상태와 검증", 1
        )[0]

        self.assertIn("시작 공개 거리 2", core)
        self.assertIn("4/7 시작 좌표는 `IMPLEMENTED_LEGACY`", core)
        self.assertIn("새 절대 시작 좌표는 `IMPLEMENTATION_BINDING_PENDING`", core)
        self.assertNotIn("플레이어 4번·상대 7번 시작과 거리 0 `[밀착]`.", core)


if __name__ == "__main__":
    unittest.main()
