from __future__ import annotations

import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "tools/check_canonical_reference_freshness.py"


def load_checker():
    spec = importlib.util.spec_from_file_location("ten_paces_reference_freshness", MODULE_PATH)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_current_repository_reference_freshness() -> None:
    checker = load_checker()
    checker.run(ROOT, ROOT / ".github/reference-freshness.json")


def test_stale_current_token_fails(tmp_path: Path) -> None:
    checker = load_checker()
    target = tmp_path / "README.md"
    target.write_text("행동 두 개", encoding="utf-8")
    config = {
        "strict_current_files": ["README.md"],
        "forbidden_current_tokens": ["행동 두 개"],
        "required_current_tokens": {},
    }
    try:
        checker.validate_current_tokens(tmp_path, config)
    except checker.FreshnessError:
        return
    raise AssertionError("stale current token must fail")
