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


if __name__ == "__main__":
    unittest.main()
