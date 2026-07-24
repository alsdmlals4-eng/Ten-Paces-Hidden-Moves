from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]


def text(path: str) -> str:
    target = ROOT / path
    assert target.is_file(), f"missing A2 file: {path}"
    return target.read_text(encoding="utf-8")


def main() -> None:
    data = json.loads(text("data/combat/combat_hypothesis_poc.json"))
    assert data["schema_version"] == 1
    assert [item["id"] for item in data["options"]] == [
        "approach", "quick_attack", "heavy_prepare",
        "response_or_recover", "ultimate", "none",
    ]
    panel = text("src/ui/opponent_hypothesis_panel.gd")
    assert "snapshot_hypothesis" in panel
    assert "기록한 가설 없음" in panel
    summary = text("src/combat/combat_review_summary_builder.gd")
    for token in ("class_name CombatReviewSummaryBuilder", "CAUSE_PRIORITY", "NO_SINGLE_DECISIVE_CAUSE", "result.duplicate(true)"):
        assert token in summary, f"summary builder missing {token}"
    assert "resolve_bundle(" not in summary
    assert "damage" not in summary.lower() or "recompute" in summary.lower()
    print("review contract: PASS")


if __name__ == "__main__":
    main()
