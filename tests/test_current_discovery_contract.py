from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class CurrentDiscoveryContractTests(unittest.TestCase):
    def test_root_start_here_uses_current_windows_android_platform_authority(self) -> None:
        text = (ROOT / "START_HERE.md").read_text(encoding="utf-8")

        self.assertIn("design_platforms: WINDOWS_ANDROID", text)
        self.assertIn("platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS", text)
        self.assertIn("현재 대상 플랫폼은 `Windows`와 `Android`다.", text)

        stale_tokens = [
            "primary_platform: PC",
            "future_platform: MOBILE_CONSIDERATION_ONLY",
            "현재 주 플랫폼은 `PC`다.",
            "모바일은 `CONSIDERATION_ONLY`",
        ]
        for token in stale_tokens:
            self.assertNotIn(
                token,
                text,
                f"START_HERE.md still exposes stale platform authority: {token}",
            )

    def test_combat_rules_use_current_strong_attack_reprice_authority(self) -> None:
        text = (ROOT / "docs" / "02_COMBAT_RULES.md").read_text(encoding="utf-8")

        self.assertIn(
            "| 강공 | 2 | 기력 1·내력 2 |",
            text,
            "Combat canon must expose the approved strong-attack effective cost.",
        )
        self.assertNotIn(
            "| 강공 | 2 | 기력 1·내력 1 |",
            text,
            "Combat canon still exposes the superseded pre-reprice strong-attack cost.",
        )


if __name__ == "__main__":
    unittest.main()
