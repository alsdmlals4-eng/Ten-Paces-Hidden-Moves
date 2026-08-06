#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATHS = [
    ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md",
    ROOT / "[기획서]/00_프로젝트_허브/ROADMAP.md",
    ROOT / "docs/04_ROADMAP.md",
]

for path in PATHS:
    lines = path.read_text(encoding="utf-8").splitlines()
    path.write_text("\n".join(line.rstrip() for line in lines) + "\n", encoding="utf-8")
