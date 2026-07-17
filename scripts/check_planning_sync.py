#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / "[기획서]"

ACTIVE_TYPES = ["game_design", "programming", "art", "sound", "qa_pm"]
ACTIVE_PATHS = [
    "[기획서]/01_게임기획/게임기획서.md",
    "[기획서]/06_프로그래밍/프로그래밍_기획서_로드맵_MVP.md",
    "[기획서]/04_아트디자인/아트_기획서.md",
    "[기획서]/07_사운드/사운드_기획서.md",
    "[기획서]/08_QA_PM/QA_PM_기획서.md",
]
IMAGE_INDEX = "[기획서]/04_아트디자인/이미지_인덱스.md"

REQUIRED_DIRS = [
    "01_게임기획",
    "04_아트디자인",
    "06_프로그래밍",
    "07_사운드",
    "08_QA_PM",
    "assets/예시이미지",
]
REQUIRED_FILES = [
    "[기획서]/README.md",
    "[기획서]/manifest.json",
    "[기획서]/00_통합/팀별_기획서_체계_및_갱신규칙.md",
    IMAGE_INDEX,
    *ACTIVE_PATHS,
    "docs/ACTIVE_CONTEXT.md",
    "docs/DOCUMENTATION_MAP.md",
    ".github/pull_request_template.md",
    "project.godot",
    "scenes/combat_playtest.tscn",
    "src/combat/combat_simulator.gd",
    "src/ui/combat_playtest.gd",
    "tests/run_all.gd",
]
FRONTMATTER_KEYS = ("title", "status", "updated", "audience", "source_of_truth")
ACTIVE_REQUIRED_MARKERS = (
    "## 0. 한눈에 보기",
    "## 목차",
    "현재 상태",
    "다음 작업",
    "부록",
)

errors: list[str] = []
active_status_paths: list[str] = []


def fail(message: str) -> None:
    errors.append(message)


for rel in REQUIRED_DIRS:
    if not (PLAN / rel).is_dir():
        fail(f"missing planning directory: [기획서]/{rel}")

for rel in REQUIRED_FILES:
    if not (ROOT / rel).is_file():
        fail(f"missing required file: {rel}")

# Every planning markdown must keep common metadata and valid local image links.
for md in PLAN.rglob("*.md"):
    text = md.read_text(encoding="utf-8")
    rel = md.relative_to(ROOT)
    if not text.startswith("---\n"):
        fail(f"missing frontmatter: {rel}")
        continue
    end = text.find("\n---\n", 4)
    if end < 0:
        fail(f"unclosed frontmatter: {rel}")
        continue
    front = text[4:end]
    for key in FRONTMATTER_KEYS:
        if not re.search(rf"(?m)^{re.escape(key)}\s*:", front):
            fail(f"missing frontmatter key '{key}': {rel}")

    status_match = re.search(r'(?m)^status\s*:\s*["\']?([^"\'\n]+)', front)
    if status_match and status_match.group(1).strip() == "활성":
        active_status_paths.append(str(rel))

    for target in re.findall(r"!\[[^\]]*\]\(([^)]+)\)", text):
        if "://" not in target and not (md.parent / target).resolve().is_file():
            fail(f"broken image link: {rel} -> {target}")

# Exactly five planning markdown files may have the exact active status.
if active_status_paths != ACTIVE_PATHS:
    fail(f"exact active-status documents must match the five plans: {active_status_paths}")

# Active plans must be readable handoff documents, not thin indexes.
for rel in ACTIVE_PATHS:
    path = ROOT / rel
    if not path.is_file():
        continue
    text = path.read_text(encoding="utf-8")
    for marker in ACTIVE_REQUIRED_MARKERS:
        if marker not in text:
            fail(f"active plan missing section '{marker}': {rel}")
    if len(text.splitlines()) < 80:
        fail(f"active plan is too short for standalone handoff: {rel}")

manifest_path = PLAN / "manifest.json"
manifest: dict[str, object] = {}
if manifest_path.is_file():
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except Exception as exc:  # pragma: no cover - defensive reporting
        fail(f"invalid manifest.json: {exc}")

if manifest:
    active_docs = manifest.get("active_documents")
    if not isinstance(active_docs, list):
        fail("manifest must define active_documents list")
        active_docs = []

    if len(active_docs) != 5:
        fail(f"manifest must expose exactly five active documents, found {len(active_docs)}")

    found_types: list[str] = []
    found_paths: list[str] = []
    for item in active_docs:
        if not isinstance(item, dict):
            fail("manifest active_documents entries must be objects")
            continue
        doc_type = item.get("type")
        path = item.get("path")
        if isinstance(doc_type, str):
            found_types.append(doc_type)
        if isinstance(path, str):
            found_paths.append(path)
            if not (ROOT / path).is_file():
                fail(f"manifest active document missing: {path}")
        if doc_type == "art":
            image_index = item.get("image_index")
            if image_index != IMAGE_INDEX:
                fail(f"art plan must own the canonical image index: {IMAGE_INDEX}")

    if found_types != ACTIVE_TYPES:
        fail(f"manifest active document types/order mismatch: {found_types}")
    if found_paths != ACTIVE_PATHS:
        fail(f"manifest active document paths/order mismatch: {found_paths}")
    if "documents" in manifest:
        fail("legacy manifest key 'documents' must not expose extra active plans")

    supporting = manifest.get("supporting_documents", [])
    if not isinstance(supporting, list):
        fail("manifest supporting_documents must be a list")
    else:
        for rel in supporting:
            if not isinstance(rel, str) or not (ROOT / rel).is_file():
                fail(f"manifest supporting document missing: {rel}")

    for impl in manifest.get("implementation", []):
        if not isinstance(impl, str) or not (ROOT / impl).is_file():
            fail(f"manifest implementation missing: {impl}")

# Entry pages must expose the five active plans as the primary set.
readme_path = PLAN / "README.md"
map_path = ROOT / "docs/DOCUMENTATION_MAP.md"
for entry_path in (readme_path, map_path):
    if not entry_path.is_file():
        continue
    text = entry_path.read_text(encoding="utf-8")
    for rel in ACTIVE_PATHS:
        filename = Path(rel).name
        if filename not in text:
            fail(f"entry document does not link active plan '{filename}': {entry_path.relative_to(ROOT)}")
    if "활성 기획서 5개" not in text:
        fail(f"entry document must label the five-plan entry set: {entry_path.relative_to(ROOT)}")

# Art is the single source of truth for image direction.
art_path = ROOT / ACTIVE_PATHS[2]
art_text = art_path.read_text(encoding="utf-8") if art_path.is_file() else ""
if "이미지_인덱스.md" not in art_text:
    fail("art plan must link the canonical image index")

if errors:
    print("Planning sync check FAILED")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("Planning sync check PASSED")
print("- exact active planning documents: 5")
print(f"- planning markdown files: {len(list(PLAN.rglob('*.md')))}")
print(f"- reference images: {len(list((PLAN / 'assets/예시이미지').glob('*')))}")
