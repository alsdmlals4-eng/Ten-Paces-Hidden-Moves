#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


def write(relative: str, text: str) -> None:
    (ROOT / relative).write_text(text, encoding="utf-8")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"{label}: expected one occurrence, found {count}")
    return text.replace(old, new, 1)


def sync_active_context() -> None:
    path = "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md"
    text = read(path)
    text = replace_once(
        text,
        "> 현재 7성·9성 숙련 예산 권위: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`  \n",
        "> 현재 7성·9성 숙련 예산 부모 권위: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`  \n"
        "> 현재 초기 무공서 10권 성장 권위: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`  \n",
        "active authority header",
    )
    text = replace_once(text, "active_approval_count: 10/10", "active_approval_count: 9/10", "active count")
    text = replace_once(
        text,
        "active_decision_state: APPROVED_DRAFT_STAR7_STAR9_MASTERY_BONUS",
        "active_decision_state: APPROVED_DRAFT_TEN_RECOGNIZABLE_MARTIAL_MANUALS",
        "active state",
    )
    text = replace_once(
        text,
        "next_planning_decision: SIX_STAR7_MASTERY_BONUS_ALLOCATIONS",
        "next_planning_decision: TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",
        "active next",
    )
    text = replace_once(text, "## 현재 승인 계보 — 10/10", "## 이전 승인 계보 — 10/10", "active lineage")
    text = replace_once(
        text,
        "10. `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`\n\n지원 권위:",
        "10. `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`\n\n"
        "## 현재 승인 배치 — 9/10\n\n"
        "- `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`\n"
        "- 초기 10권의 문파·이름·주/보조능력치 적합성·3/5/7/9/10성 성장·예산을 승인한다.\n"
        "- 능력치별 권수·균등 분포·쿼터는 설계 규칙으로 사용하지 않는다.\n"
        "- 런타임 구현은 `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE` 전까지 금지한다.\n\n"
        "지원 권위:",
        "active current batch",
    )
    text = replace_once(
        text,
        "- 7성 기술2는 현행 repricing 유효 예산에 숙련 보너스 `+10틱`을 받지만 실제 배분은 다음 Decision까지 미승인이다.\n"
        "- 9성 추가 예산은 `10 + floor(7성 최종 예산×0.20)`이며 단일 효과·무분기·추가입력/비용 없음이다.",
        "- 기존 6권 기술2는 현행 repricing 유효 예산에 `+10틱`을 통합하고, 신규 4권 기술2는 새 승인 예산 프로필을 사용한다.\n"
        "- 초기 10권의 9성은 `10 + floor(7성 최종 예산×0.20)` 안에서 단일 효과·무분기·추가입력/비용 없음으로 승인됐다.\n"
        "- 초기 10권의 10성 절초는 각각 고유 해결 순서와 `±5틱` 계획 예산을 가진다.\n"
        "- 주·보조능력치 권수 분포는 검사하지 않고 문파·무학·동작·피해 방식 적합성만 검사한다.",
        "active summary",
    )
    text = replace_once(
        text,
        "- `[현행]`: 전투 가격·repricing·기술1·7/9성 숙련 예산·자원 포화·조건 보정·파생 스탯·오판 구제·관찰 직접 공개·등급 파밍 방지·작업 운영 정책.",
        "- `[현행]`: 초기 무공서 10권 성장·전투 가격·repricing·기술1·7/9성 예산 부모·자원 포화·조건 보정·파생 스탯·오판 구제·관찰 직접 공개·등급 파밍 방지·작업 운영 정책.",
        "active lifecycle",
    )
    old_gate = """```text
SIX_STAR7_MASTERY_BONUS_ALLOCATIONS
→ SIX_STAR9_SINGLE_COMPLETION_BONUSES
→ SIX_STAR10_UNIQUE_ULTIMATES
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
→ [기획 완료]
→ 이미지·애니메이션·HX 승인
→ [이미지 완료]
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex BUILD
```

10/10 체크포인트이므로 새 승인 배치를 열기 전 현재 PR 계보·정본·Sheet의 일치를 먼저 검토한다."""
    new_gate = """```text
TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE
→ RED 런타임 계약·회귀 검사
→ Godot 데이터·카드·해결기 구현
→ 사람·밸런스 검증
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

현재 승인 배치는 9/10이다. GitHub·Google Sheet 정본 동기화 뒤 런타임 구현은 별도 승인 Gate에서 시작한다."""
    text = replace_once(text, old_gate, new_gate, "active gate")
    text = replace_once(
        text,
        "planning_checkpoint: DRAFT_PR92_STAR7_STAR9_MASTERY_BONUS_10_OF_10",
        "planning_checkpoint: DRAFT_PR92_TEN_RECOGNIZABLE_MARTIAL_MANUALS_9_OF_10",
        "active checkpoint",
    )
    write(path, text)


def sync_roadmap() -> None:
    path = "docs/04_ROADMAP.md"
    text = read(path)
    text = replace_once(
        text,
        "> 7성·9성 숙련 예산: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`",
        "> 초기 무공서 10권 성장: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`  \n"
        "> 7성·9성 예산 부모: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`",
        "roadmap authority header",
    )
    text = replace_once(text, "active_approval_count: 10/10", "active_approval_count: 9/10", "roadmap count")
    text = replace_once(
        text,
        "active_decision_state: APPROVED_DRAFT_STAR7_STAR9_MASTERY_BONUS",
        "active_decision_state: APPROVED_DRAFT_TEN_RECOGNIZABLE_MARTIAL_MANUALS",
        "roadmap state",
    )
    text = replace_once(
        text,
        "next_planning_decision: SIX_STAR7_MASTERY_BONUS_ALLOCATIONS",
        "next_planning_decision: TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",
        "roadmap next",
    )
    text = replace_once(
        text,
        "- [x] 승인 배치10·조기 체크포인트·모든 작업 TDD·현업 벤치마킹.",
        "- [x] 승인 배치10·조기 체크포인트·모든 작업 TDD·현업 벤치마킹.\n"
        "- [x] 한국·중국 무협 인지도 기반 초기 무공서 10권과 문파 표시.\n"
        "- [x] 주·보조능력치 권수 쿼터 폐기와 무공별 적합성 근거.\n"
        "- [x] 10권의 3/5/7/9/10성 성장·절초·해결 순서·계획 예산.",
        "roadmap checklist",
    )
    old_order = """```text
SIX_STAR7_MASTERY_BONUS_ALLOCATIONS
→ SIX_STAR9_SINGLE_COMPLETION_BONUSES
→ SIX_STAR10_UNIQUE_ULTIMATES
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
→ [기획 완료]
→ 이미지·애니메이션·HX 승인
→ [이미지 완료]
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex BUILD
```

현재 배치는 10/10이다. 여섯 개별 7성 배분은 새 승인 배치에서 시작하며, 7성 배분 전에 9성 개별 효과를 작성하지 않는다."""
    new_order = """```text
TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE
→ RED 런타임 계약·회귀 검사
→ 10권 Godot 데이터·카드·해결기 구현
→ 사람·밸런스·가독성 검증
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

현재 배치는 9/10이다. 초기 10권의 기획·예산은 승인됐지만 제품 런타임은 아직 변경하지 않는다."""
    text = replace_once(text, old_order, new_order, "roadmap order")
    text = replace_once(
        text,
        "- [ ] 여섯 7성 `+10틱` 효과 배분.\n"
        "- [ ] 여섯 9성 단일 완성 보너스.\n"
        "- [ ] 10성 절초와 비스탯 노드.",
        "- [x] 초기 10권 7성 기술2 효과와 통합 예산.\n"
        "- [x] 초기 10권 9성 단일 완성 효과.\n"
        "- [x] 초기 10권 10성 절초·해결 순서·계획 예산.\n"
        "- [ ] 10권 런타임 구현 Gate.\n"
        "- [ ] 비스탯 노드 기대값과 가중치.",
        "roadmap gates",
    )
    text = replace_once(
        text,
        "- 7성·9성 예산 overlay 적용과 개별 효과 승인 상태 확인.",
        "- 10권 의미 계약·예산 overlay·역사 alias 적용과 런타임 구현 Gate 확인.",
        "roadmap build gate",
    )
    write(path, text)


def sync_mastery() -> None:
    path = "docs/06_STARTING_FACTION_MASTERY_DATA.md"
    text = read(path)
    text = replace_once(text, "active_batch: 10/10", "active_batch: 9/10", "mastery batch")
    text = replace_once(
        text,
        "current_decision: TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01",
        "current_decision: TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01",
        "mastery decision",
    )
    text = replace_once(
        text,
        "next_decision: SIX_STAR7_MASTERY_BONUS_ALLOCATIONS",
        "next_decision: TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",
        "mastery next",
    )
    text = replace_once(
        text,
        "현재 T0에는 세력 선택·수련 분기·개별 7성/9성 보너스 효과가 구현되지 않았다.",
        "초기 10권의 문파·3/5/7/9/10성 효과와 예산은 기획 승인됐지만 T0 제품 런타임에는 아직 구현되지 않았다.",
        "mastery runtime",
    )
    text = replace_once(
        text,
        "- 7성·9성 숙련 예산: `approved_20260805_star7_star9_mastery_bonus_contract.json`",
        "- 7성·9성 예산 부모: `approved_20260805_star7_star9_mastery_bonus_contract.json`\n"
        "- 초기 10권 의미·능력치 적합성·성급별 효과: `approved_20260806_ten_recognizable_martial_manuals_contract.json`\n"
        "- 초기 10권 기술2·절초 계획 예산: `approved_20260806_ten_manual_growth_budget_overlay_contract.json`\n"
        "- 플레이어용 목록: `docs/03_TEN_MARTIAL_MANUALS_CATALOG.md`",
        "mastery authorities",
    )
    text = replace_once(
        text,
        "개별 7성 +10틱 배분과 9성 효과는 아직 미승인이다.",
        "초기 10권의 7성 기술2·9성 단일 효과·10성 절초는 승인됐으며, 제품 런타임 구현은 별도 Gate까지 금지한다.",
        "mastery approvals",
    )
    text = replace_once(text, "## 세력 정체성 후보", "## 역사적 6권 역할표", "mastery history heading")
    text = replace_once(
        text,
        "이 표는 동일 역할 금지를 위한 책임 원본이다. 실제 +10틱 효과와 9성 단일 효과는 후속 Decision에서 확정한다.",
        "이 표는 구형 이름의 역할 계보를 추적하는 역사 자료다. 현재 표시명·문파·능력치·성장 효과는 2026-08-06 10권 계약과 카탈로그를 따른다.",
        "mastery history note",
    )
    text = replace_once(
        text,
        "현재 T0 런타임에는 공용 절초 3종이 역사 PoC 데이터로 존재한다. 시작 무공별 10성 절초는 주 영구 능력치12 요구만 승인됐고 개별 효과는 미승인이다.",
        "현재 T0 런타임에는 공용 절초 3종이 역사 PoC 데이터로 존재한다. 초기 10권의 고유 절초는 기획·예산 승인됐지만 런타임에는 아직 구현되지 않았다.",
        "mastery ultimates",
    )
    old_gate = """```text
SIX_STAR7_MASTERY_BONUS_ALLOCATIONS
→ SIX_STAR9_SINGLE_COMPLETION_BONUSES
→ SIX_STAR10_UNIQUE_ULTIMATES
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```"""
    new_gate = """```text
TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE
→ RED 런타임 계약·회귀 검사
→ 10권 Godot 데이터·카드·해결기 구현
→ 사람·밸런스 검증
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```"""
    text = replace_once(text, old_gate, new_gate, "mastery gate")
    write(path, text)


def sync_registry() -> None:
    path = "docs/CANON_LIFECYCLE_REGISTRY.md"
    text = read(path)
    text = replace_once(
        text,
        "- 현행 성장 권위: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`",
        "- 현행 성장 권위: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`\n"
        "- 7성·9성 예산 부모: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`",
        "registry header",
    )
    text = replace_once(
        text,
        "| 7성·9성 숙련 예산 개정 | `docs/02_COMBAT_RULES_STAR7_STAR9_MASTERY_BONUS_AMENDMENT.md` |",
        "| 7성·9성 예산 부모 개정 | `docs/02_COMBAT_RULES_STAR7_STAR9_MASTERY_BONUS_AMENDMENT.md` |\n"
        "| 초기 무공서 10권 전투 해결 개정 | `docs/02_COMBAT_RULES_TEN_RECOGNIZABLE_MARTIAL_MANUALS_AMENDMENT.md` |\n"
        "| 초기 무공서 10권 읽기 카탈로그 | `docs/03_TEN_MARTIAL_MANUALS_CATALOG.md` |",
        "registry table",
    )
    text = replace_once(
        text,
        "| 7성·9성 숙련 예산·단일 효과 템플릿 | `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01` |",
        "| 7성·9성 예산 부모·단일 효과 템플릿 | `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01` |\n"
        "| 초기 10권 문파·능력치 적합성·3/5/7/9/10성 성장 | `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01` |",
        "registry authority row",
    )
    text = replace_once(
        text,
        "- `approved_20260805_star7_star9_mastery_bonus_contract.json`\n- `approved_20260805_work_governance_contract.json`",
        "- `approved_20260805_star7_star9_mastery_bonus_contract.json`\n"
        "- `approved_20260806_ten_recognizable_martial_manuals_contract.json`\n"
        "- `approved_20260806_ten_manual_growth_budget_overlay_contract.json`\n"
        "- `approved_20260805_work_governance_contract.json`",
        "registry contracts",
    )
    text = replace_once(
        text,
        "| 여섯 7성 +10틱 실제 효과 배분 | 예산만 승인 | 새 승인 배치·개별 GrillMe |\n"
        "| 여섯 9성 단일 완성 효과 | 템플릿만 승인 | 7성 배분 뒤 개별 GrillMe |",
        "| 초기 10권 런타임 구현 | 기획·예산 승인, 제품 미구현 | `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE` 승인 |",
        "registry held",
    )
    text = replace_once(
        text,
        "| #92 | Draft·부모 #91·파생 스탯·오판 구제·관찰·등급·7/9성 숙련 예산·10/10 |",
        "| #92 | Draft·부모 #91·파생 스탯·관찰·등급·7/9성 예산 부모·초기 무공서 10권·현재 배치9/10 |",
        "registry PR",
    )
    text = replace_once(
        text,
        "- 별도 Decision 전에 여섯 개별 7성/9성 효과를 승인 또는 런타임 생성.",
        "- 2026-08-06 계약을 무시하고 구형 6권 이름·능력치·미승인 상태를 현행으로 사용.\n"
        "- 능력치별 무공서 권수·균등 분포·쿼터를 강제해 문파·무학 적합성을 왜곡.\n"
        "- `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE` 전에 10권 제품 런타임 데이터를 생성.",
        "registry conflicts",
    )
    old_gate = """`SIX_STAR7_MASTERY_BONUS_ALLOCATIONS`가 다음 Decision이다. 현재 승인 배치는 `10/10`으로 닫혔다.

```text
SIX_STAR7_MASTERY_BONUS_ALLOCATIONS
→ SIX_STAR9_SINGLE_COMPLETION_BONUSES
→ SIX_STAR10_UNIQUE_ULTIMATES
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

여섯 개별 7성 효과와 9성 효과를 현재 권위로 사용하면 안 된다. 자동 조정 없이 새 GrillMe Decision으로만 승인한다."""
    new_gate = """`TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`가 다음 Decision이다. 현재 승인 배치는 `9/10`이다.

```text
TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE
→ RED 런타임 계약·회귀 검사
→ 10권 제품 데이터·카드·해결기 구현
→ 사람·밸런스 검증
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

기획 승인만으로 제품 코드·Godot Scene·런타임 데이터 구현 완료를 주장하면 안 된다."""
    text = replace_once(text, old_gate, new_gate, "registry gate")
    write(path, text)


def sync_validators_and_tests() -> None:
    path = "tools/check_postmerge_canon_lifecycle.py"
    text = read(path)
    text = replace_once(text, 'active_state["active_approval_count"] == "10/10"', 'active_state["active_approval_count"] == "9/10"', "validator count")
    text = replace_once(text, 'active_state["active_decision_state"] == "APPROVED_DRAFT_STAR7_STAR9_MASTERY_BONUS"', 'active_state["active_decision_state"] == "APPROVED_DRAFT_TEN_RECOGNIZABLE_MARTIAL_MANUALS"', "validator state")
    text = replace_once(text, 'active_state["next_planning_decision"] == "SIX_STAR7_MASTERY_BONUS_ALLOCATIONS"', 'active_state["next_planning_decision"] == "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE"', "validator next")
    text = replace_once(
        text,
        '"TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01",\n        "DRAFT_PR92_STAR7_STAR9_MASTERY_BONUS_10_OF_10",',
        '"TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01",\n        "DRAFT_PR92_TEN_RECOGNIZABLE_MARTIAL_MANUALS_9_OF_10",',
        "validator active tokens",
    )
    text = replace_once(
        text,
        '"SIX_STAR7_MASTERY_BONUS_ALLOCATIONS",\n        "SIX_STAR9_SINGLE_COMPLETION_BONUSES",',
        '"TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",\n        "NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT",',
        "validator roadmap tokens",
    )
    text = replace_once(
        text,
        '"approved_20260805_star7_star9_mastery_bonus_contract.json",\n        "SIX_STAR7_MASTERY_BONUS_ALLOCATIONS",',
        '"approved_20260806_ten_recognizable_martial_manuals_contract.json",\n        "approved_20260806_ten_manual_growth_budget_overlay_contract.json",\n        "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",',
        "validator registry tokens",
    )
    text = replace_once(text, '"active_batch: 10/10",', '"active_batch: 9/10",', "validator mastery batch")
    text = replace_once(
        text,
        '"SIX_STAR7_MASTERY_BONUS_ALLOCATIONS",',
        '"approved_20260806_ten_recognizable_martial_manuals_contract.json",\n        "approved_20260806_ten_manual_growth_budget_overlay_contract.json",\n        "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE",',
        "validator mastery gate token",
    )
    text = replace_once(
        text,
        'require("active_batch: 9/10" not in mastery, "growth authority still claims active batch 9/10")',
        'require("active_batch: 10/10" not in mastery, "growth authority still claims superseded active batch 10/10")',
        "validator mastery negative",
    )
    write(path, text)

    path = "tests/test_star7_star9_mastery_bonus_contract.py"
    text = read(path)
    pattern = re.compile(
        r"    def test_current_canon_moves_to_ten_of_ten\(self\):.*?(?=\n    def test_rejects_star7_bonus_drift)",
        re.S,
    )
    replacement = '''    def test_later_ten_manual_decision_owns_current_canon(self):
        active = (ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md").read_text(encoding="utf-8")
        roadmap = (ROOT / "docs/04_ROADMAP.md").read_text(encoding="utf-8")
        mastery = (ROOT / "docs/06_STARTING_FACTION_MASTERY_DATA.md").read_text(encoding="utf-8")
        for current in [active, roadmap]:
            self.assertIn("active_approval_count: 9/10", current)
            self.assertIn("active_decision_state: APPROVED_DRAFT_TEN_RECOGNIZABLE_MARTIAL_MANUALS", current)
            self.assertIn("next_planning_decision: TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE", current)
        self.assertIn("active_batch: 9/10", mastery)
        self.assertIn("approved_20260806_ten_recognizable_martial_manuals_contract.json", mastery)
        self.assertIn("approved_20260806_ten_manual_growth_budget_overlay_contract.json", mastery)
        self.assertNotIn("active_batch: 10/10", mastery)
'''
    text, count = pattern.subn(replacement.rstrip(), text)
    if count != 1:
        raise RuntimeError(f"star7 current-state test: expected one block, found {count}")
    write(path, text)

    path = ".github/workflows/documentation-governance.yml"
    text = read(path)
    anchor = """      - name: Validate Star7 Star9 mastery bonus contract
        run: python tools/check_star7_star9_mastery_bonus_contract.py

      - name: Validate PoC planning data"""
    insertion = """      - name: Validate Star7 Star9 mastery bonus contract
        run: python tools/check_star7_star9_mastery_bonus_contract.py

      - name: Run ten-manual semantic regression tests
        run: python -m unittest tests.test_ten_recognizable_martial_manuals_contract -v

      - name: Validate ten-manual semantic contract
        run: python tools/check_ten_recognizable_martial_manuals_contract.py

      - name: Run ten-manual budget regression tests
        run: python -m unittest tests.test_ten_manual_growth_budget_overlay -v

      - name: Validate ten-manual budget overlay
        run: python tools/check_ten_manual_growth_budget_overlay.py

      - name: Validate PoC planning data"""
    text = replace_once(text, anchor, insertion, "PR workflow integration")
    write(path, text)


def main() -> int:
    sync_active_context()
    sync_roadmap()
    sync_mastery()
    sync_registry()
    sync_validators_and_tests()
    print("TEN_MANUAL_CURRENT_AUTHORITY_SYNC_PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
