#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"missing {label}: {old!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


active = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
roadmap = ROOT / "docs/04_ROADMAP.md"

replace_once(
    active,
    "WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT\n→ LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE",
    "WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE\n→ LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE",
    "active next sequence",
)
replace_once(
    active,
    "현행 운영 값은 문서 상단 YAML의 `active_planning_pr: NONE`, `TEN_MANUAL_PRODUCT_VALIDATION_MERGED`, `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT`만 사용한다.",
    "현행 운영 값은 문서 상단 YAML의 `active_planning_pr: 102`, `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED`, `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`를 사용한다. 제품 병합 권위는 별도 `merged_product_pr: 92`와 `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`로 유지한다.",
    "active historical current-state prose",
)
replace_once(
    roadmap,
    "현행 값은 상단 YAML의 `TEN_MANUAL_PRODUCT_VALIDATION_MERGED`와 `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT`다.",
    "현행 값은 상단 YAML의 `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED`와 `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`다. 제품 병합 권위는 `merged_product_pr: 92`와 제품 구현 병합 Commit으로 별도 보존한다.",
    "roadmap historical current-state prose",
)
