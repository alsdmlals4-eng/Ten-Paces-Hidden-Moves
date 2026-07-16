#!/usr/bin/env python3
from __future__ import annotations
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / "[기획서]"
REQUIRED_DIRS = ["00_통합", "01_게임기획", "02_전투기획", "03_UI_UX", "04_아트디자인", "05_플레이테스트", "assets/예시이미지"]
REQUIRED_FILES = [
    "[기획서]/README.md", "[기획서]/manifest.json",
    "[기획서]/00_통합/통합_게임기획서.md",
    "[기획서]/01_게임기획/게임_핵심경험_및_범위.md",
    "[기획서]/02_전투기획/2수전투_및_절초기세.md",
    "[기획서]/03_UI_UX/전투_UI_UX_기획서.md",
    "[기획서]/04_아트디자인/전투_아트디자인_가이드.md",
    "[기획서]/05_플레이테스트/T0_플레이테스트_계획.md",
    "project.godot", "scenes/combat_playtest.tscn",
    "src/combat/combat_simulator.gd", "src/ui/combat_playtest.gd", "tests/run_all.gd",
]
FRONTMATTER_KEYS = ("title", "status", "updated", "audience", "source_of_truth")
errors: list[str] = []

for rel in REQUIRED_DIRS:
    if not (PLAN / rel).is_dir(): errors.append(f"missing planning directory: [기획서]/{rel}")
for rel in REQUIRED_FILES:
    if not (ROOT / rel).is_file(): errors.append(f"missing required file: {rel}")

for md in PLAN.rglob("*.md"):
    text = md.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        errors.append(f"missing frontmatter: {md.relative_to(ROOT)}")
        continue
    end = text.find("\n---\n", 4)
    if end < 0:
        errors.append(f"unclosed frontmatter: {md.relative_to(ROOT)}")
        continue
    front = text[4:end]
    for key in FRONTMATTER_KEYS:
        if not re.search(rf"(?m)^{re.escape(key)}\s*:", front): errors.append(f"missing frontmatter key '{key}': {md.relative_to(ROOT)}")
    for target in re.findall(r"!\[[^\]]*\]\(([^)]+)\)", text):
        if "://" not in target and not (md.parent / target).resolve().is_file(): errors.append(f"broken image link: {md.relative_to(ROOT)} -> {target}")

manifest_path = PLAN / "manifest.json"
if manifest_path.is_file():
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        for doc in manifest.get("documents", []):
            if not (ROOT / doc["path"]).is_file(): errors.append(f"manifest document missing: {doc['path']}")
            for image in doc.get("images", []):
                if not (ROOT / image).is_file(): errors.append(f"manifest image missing: {image}")
        for impl in manifest.get("implementation", []):
            if not (ROOT / impl).is_file(): errors.append(f"manifest implementation missing: {impl}")
    except Exception as exc:
        errors.append(f"invalid manifest.json: {exc}")

if errors:
    print("Planning sync check FAILED")
    for error in errors: print(f"- {error}")
    sys.exit(1)
print("Planning sync check PASSED")
print(f"- planning markdown files: {len(list(PLAN.rglob('*.md')))}")
print(f"- reference images: {len(list((PLAN/'assets/예시이미지').glob('*')))}")
