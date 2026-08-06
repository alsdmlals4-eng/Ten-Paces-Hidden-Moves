#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MERGE = "023385d372d127044d48afcb50e6f232ab9ffaa1"


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"missing {label}: {old!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_all_required(path: Path, old: str, new: str, minimum: int, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count < minimum:
        raise SystemExit(f"expected at least {minimum} {label}, found {count}")
    path.write_text(text.replace(old, new), encoding="utf-8")


active = ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
replace_once(active, "merged_planning_checkpoint: 7d20c2c9d5d1c92b80d32dc9bf25bd833a48ad58", f"merged_planning_checkpoint: {MERGE}", "active checkpoint")
replace_once(active, "merged_pr_lineage: 84,86,87,88,89,91,92,100,101", "merged_pr_lineage: 84,86,87,88,89,91,92,100,101,102", "active lineage")
replace_once(active, "active_planning_pr: 102", "active_planning_pr: NONE", "active PR")
replace_once(active, "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED", "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED", "active state")
replace_once(
    active,
    "platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01\n",
    "platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01\n"
    f"platform_adapter_merge_commit: {MERGE}\n"
    "merged_platform_adapter_pr: 102\n",
    "active adapter merge metadata",
)
replace_once(
    active,
    "현재 체크포인트는 `MERGED_PR92_TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_10_OF_10`이다. PR #89·#91·#92 계보는 main에 병합됐고, 제품 구현 병합 Commit은 `a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90`이다.",
    f"현재 기획 체크포인트는 `MERGED_PR102_WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_1_OF_10`이다. PR #89·#91·#92·#100·#101·#102 계보는 main에 병합됐고, 플랫폼 Adapter 아키텍처 병합 Commit은 `{MERGE}`다. 제품 구현 병합 Commit `a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90`과 자동 제품 증거 HEAD는 별도 권위로 유지한다.",
    "active checkpoint prose",
)
replace_once(
    active,
    "현행 운영 값은 문서 상단 YAML의 `active_planning_pr: 102`, `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED`, `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`를 사용한다.",
    "현행 운영 값은 문서 상단 YAML의 `active_planning_pr: NONE`, `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED`, `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`를 사용한다.",
    "active operating prose",
)

roadmap = ROOT / "docs/04_ROADMAP.md"
replace_once(roadmap, "merged_planning_checkpoint: 7d20c2c9d5d1c92b80d32dc9bf25bd833a48ad58", f"merged_planning_checkpoint: {MERGE}", "roadmap checkpoint")
replace_once(roadmap, "merged_pr_lineage: 84,86,87,88,89,91,92,100,101", "merged_pr_lineage: 84,86,87,88,89,91,92,100,101,102", "roadmap lineage")
replace_once(roadmap, "active_planning_pr: 102", "active_planning_pr: NONE", "roadmap PR")
replace_once(roadmap, "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED", "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED", "roadmap state")
replace_once(
    roadmap,
    "platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01\n",
    "platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01\n"
    f"platform_adapter_merge_commit: {MERGE}\n"
    "merged_platform_adapter_pr: 102\n",
    "roadmap adapter merge metadata",
)
replace_once(
    roadmap,
    "PR #89·#91·#92 제품 계보와 PR #101 post-merge 플랫폼 정본은 main에 병합됐다.",
    f"PR #89·#91·#92 제품 계보, PR #101 post-merge 플랫폼 정본, PR #102 Adapter Architecture는 main에 병합됐다. PR #102 병합 Commit은 `{MERGE}`다.",
    "roadmap merged prose",
)
replace_once(
    roadmap,
    "현행 값은 상단 YAML의 `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED`와 `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`다.",
    "현행 값은 상단 YAML의 `WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED`와 `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`다.",
    "roadmap operating prose",
)

hub = ROOT / "[기획서]/00_프로젝트_허브/ROADMAP.md"
replace_once(hub, "active_planning_pr: 102", "active_planning_pr: NONE", "hub PR")
replace_once(hub, "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED", "active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED", "hub state")
replace_once(
    hub,
    "platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01\n",
    "platform_adapter_decision: TEN-DEC-20260806-WINDOWS-ANDROID-ADAPTER-ARCHITECTURE-01\n"
    f"platform_adapter_merge_commit: {MERGE}\n"
    "merged_platform_adapter_pr: 102\n",
    "hub adapter merge metadata",
)
replace_once(
    hub,
    "## Adapter Architecture 승인\n",
    f"## Adapter Architecture 병합 완료\n\n- PR #102 main 병합 Commit: `{MERGE}`.\n",
    "hub architecture heading",
)

product_test = ROOT / "tests/test_product_postmerge_and_platform_canon.py"
replace_all_required(product_test, '"active_planning_pr: 102"', '"active_planning_pr: NONE"', 1, "product active PR token")
replace_all_required(product_test, '"active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED"', '"active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED"', 1, "product active state token")

project_test = ROOT / "tests/test_project_governance.py"
replace_all_required(project_test, '"active_planning_pr: 102"', '"active_planning_pr: NONE"', 1, "governance active PR token")
replace_all_required(project_test, '"active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED"', '"active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED"', 1, "governance active state token")

mastery_test = ROOT / "tests/test_star7_star9_mastery_bonus_contract.py"
replace_all_required(mastery_test, '"active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_APPROVED"', '"active_decision_state: WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_MERGED"', 1, "mastery active state token")

for path in (active, roadmap, hub, product_test, project_test, mastery_test):
    text = path.read_text(encoding="utf-8")
    path.write_text("\n".join(line.rstrip() for line in text.splitlines()) + "\n", encoding="utf-8")
