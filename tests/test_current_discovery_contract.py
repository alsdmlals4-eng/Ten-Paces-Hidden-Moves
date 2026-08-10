from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_root_start_here_uses_current_windows_android_platform_authority() -> None:
    text = (ROOT / "START_HERE.md").read_text(encoding="utf-8")

    assert "design_platforms: WINDOWS_ANDROID" in text
    assert "platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS" in text
    assert "현재 대상 플랫폼은 `Windows`와 `Android`다." in text

    stale_tokens = [
        "primary_platform: PC",
        "future_platform: MOBILE_CONSIDERATION_ONLY",
        "현재 주 플랫폼은 `PC`다.",
        "모바일은 `CONSIDERATION_ONLY`",
    ]
    for token in stale_tokens:
        assert token not in text, f"START_HERE.md still exposes stale platform authority: {token}"
