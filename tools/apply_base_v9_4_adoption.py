#!/usr/bin/env python3
"""Apply the approved Base v9.4 operating-contract adoption to Ten Paces.

This migration is intentionally limited to project operating documents, adapters,
generated compatibility views, and contract tests. It does not touch product
code, scenes, data, assets, addons, project.godot, or Google Sheets.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BRANCH_BASELINE = "2d8b9fc2a435322ba26860421eecadf356f53a4b"
BASE_VERSION = "9.4.0"
BASE_PAYLOAD = "a728712cb776ec98f4875914a580fcf7d0156593"
BASE_EVIDENCE = "ef1fba11167e4da0b298123b0c85ebd268191a42"
BASE_FINALIZATION = "87a0b54c2847ce4b685879209205957c170cc1cd"
BASE_REGISTRY_SHA = "693a0dff3f054ecdd653079909e044211473838e73dd9aff07734d1ce5694c59"
NEW_SKILL = "optimizing-ai-model-and-prompt-costs"


def read_json(path: str) -> dict:
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def write_json(path: str, data: dict) -> None:
    (ROOT / path).write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def replace_required(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        raise SystemExit(f"required text missing for {label}: {old!r}")
    return text.replace(old, new, 1)


def append_once(text: str, marker: str, block: str) -> str:
    if marker in text:
        return text
    return text.rstrip() + "\n\n" + block.strip() + "\n"


def route(skill_id: str) -> dict:
    return {"route_id": skill_id, "skill_id": skill_id, "status": "ACTIVE"}


def migrate_adapter() -> str:
    path = "skills/PROJECT_BASE_ADAPTER.json"
    data = read_json(path)
    data["base_release"] = {
        "release_commit": BASE_PAYLOAD,
        "release_evidence_commit": BASE_EVIDENCE,
        "repository": "alsdmlals4-eng/Base",
        "version": BASE_VERSION,
    }
    data["protected_baseline"]["commit"] = BRANCH_BASELINE
    data["skill_registry"]["base"]["sha256"] = BASE_REGISTRY_SHA

    base_routes = data["routing"]["base_routes"]
    if NEW_SKILL not in {item["route_id"] for item in base_routes}:
        base_routes.append(route(NEW_SKILL))
    base_routes.sort(key=lambda item: item["route_id"])
    data["shared_overrides"].setdefault(NEW_SKILL, {})

    write_json(path, data)
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def migrate_snapshot() -> None:
    path = "skills/PROJECT_SKILL_SNAPSHOT.json"
    data = read_json(path)
    data["base_registry"]["sha256"] = BASE_REGISTRY_SHA
    base_routes = data["base_routes"]
    if NEW_SKILL not in {item["route_id"] for item in base_routes}:
        base_routes.append(route(NEW_SKILL))
    base_routes.sort(key=lambda item: item["route_id"])
    data["effective_routes"][NEW_SKILL] = {
        "route_id": NEW_SKILL,
        "skill_id": NEW_SKILL,
        "source": "BASE_SHARED",
        "status": "ACTIVE",
        "target_route_id": NEW_SKILL,
    }
    write_json(path, data)


def migrate_compatibility_views(adapter_sha: str) -> None:
    for path in (
        "skills/BASE_V9_ADAPTER.json",
        "skills/PROJECT_BASE_SKILL_ADAPTER.json",
    ):
        data = read_json(path)
        data["base_release"] = {
            "release_commit": BASE_PAYLOAD,
            "release_evidence_commit": BASE_EVIDENCE,
            "repository": "alsdmlals4-eng/Base",
            "version": BASE_VERSION,
        }
        data["canonical_source_sha256"] = adapter_sha
        if path.endswith("PROJECT_BASE_SKILL_ADAPTER.json"):
            data["shared_skill_overrides"].setdefault(NEW_SKILL, {})
        write_json(path, data)


def migrate_current_documents() -> None:
    replacements = {
        "AGENTS.md": [
            ("base_release_pinned: 9.1.0", "base_release_pinned: 9.4.0"),
            (
                "- 현재 Base 권한은 `skills/PROJECT_BASE_ADAPTER.json`의 v9.1 pin이다.\n- Base v9.3 adoption은 별도 migration PR에서 수행한다.",
                "- 현재 Base 권한은 `skills/PROJECT_BASE_ADAPTER.json`의 v9.4 payload/evidence pin이다.\n- Base v9.4 최종화 Commit은 운영 감사 증거이며 프로젝트 코어·제품 구현 권한을 변경하지 않는다.",
            ),
        ],
        "START_HERE.md": [
            ("base_release_pinned: 9.1.0", "base_release_pinned: 9.4.0"),
        ],
        "README.md": [
            ("base_release_pinned: 9.1.0", "base_release_pinned: 9.4.0"),
            (
                "현재 공용 Skill route는 `skills/PROJECT_BASE_ADAPTER.json`의 Base v9.1 pin을 사용합니다.",
                "현재 공용 Skill route는 `skills/PROJECT_BASE_ADAPTER.json`의 Base v9.4 payload/evidence pin을 사용합니다.",
            ),
        ],
        "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md": [
            ("base_release_pinned: 9.1.0", "base_release_pinned: 9.4.0"),
            ("base_v9_3_migration: SEPARATE_FOLLOWUP", "base_v9_4_adoption: APPLIED_OPERATING_CONTRACT_ONLY"),
            (
                "- Base v9.3은 PR #65 main 안정화 뒤 별도 migration으로 처리한다.",
                "- Base v9.4 운영 계약은 제품 경로를 수정하지 않는 별도 adapter migration으로 적용한다.",
            ),
        ],
        ".agents/skills/ten-paces-hidden-moves-workflow-router/SKILL.md": [
            ("verified v9.1 operating contracts", "verified v9.4 operating contracts"),
        ],
    }
    for path, pairs in replacements.items():
        file_path = ROOT / path
        text = file_path.read_text(encoding="utf-8")
        for old, new in pairs:
            text = replace_required(text, old, new, f"{path}:{old}")
        file_path.write_text(text, encoding="utf-8")

    rules_path = ROOT / "docs/BASE_RULES_VERSION.md"
    rules = rules_path.read_text(encoding="utf-8")
    rules = replace_required(rules, "base_release_version: 9.1.0", "base_release_version: 9.4.0", "rules version")
    rules = replace_required(rules, "release_commit: 3c158f52cfdad889970aef4d6ce6650a6fea0645", f"release_commit: {BASE_PAYLOAD}", "rules payload")
    rules = replace_required(rules, "release_evidence_commit: dd20ad3852e264d7e337e34d2cb963f71053a6cb", f"release_evidence_commit: {BASE_EVIDENCE}", "rules evidence")
    rules = replace_required(rules, "현재 프로젝트 Adapter는 Base 활성 Skill 27개", "현재 프로젝트 Adapter는 Base 활성 Skill 28개", "skill count")
    start = rules.index("## 2. Base 원격 재감사")
    end = rules.index("## 3. 현재 적용 운영 계약")
    section = f"""## 2. Base v9.4 적용 감사

2026-08-01 적용 기준:

```yaml
base_payload_commit: {BASE_PAYLOAD}
base_trusted_evidence_commit: {BASE_EVIDENCE}
base_pin_finalization_commit: {BASE_FINALIZATION}
base_registry_sha256: {BASE_REGISTRY_SHA}
base_release_state: BASE_RELEASED
project_adoption: V9_4_OPERATING_CONTRACT_APPLIED
product_paths_changed: false
```

Base v9.4의 모델·추론 단계·Prompt caching·비용 측정, 지시 권위, Interface-first Prompt, Context 큐레이션, Artifact 주장 상한, Godot UI 모션 계약을 프로젝트 adapter와 운영 문서에 적용한다. 십보강호의 전투 코어·무공 데이터·저장 Schema·승인 아트·실제 Godot 구현은 이 적용으로 변경하지 않는다.

"""
    rules = rules[:start] + section + rules[end:]
    rules = rules.replace("- PR #65 main 병합 뒤 Base v9.3 migration 시작.\n", "- Base release·Registry·route·Adapter Schema가 다시 변경될 때 재감사.\n")
    rules_path.write_text(rules, encoding="utf-8")


def migrate_ai_workflow() -> None:
    path = ROOT / "[기획서]/00_프로젝트_허브/AI_WORKFLOW.md"
    text = path.read_text(encoding="utf-8")
    text = text.replace("Base 활성 Skill 25개", "Base 활성 Skill 28개")
    block = f"""
## Base v9.4 모델·지시·Context 계약

- `[모델 추천]` 요청 시 작업 위험·재작업 비용·속도를 기준으로 모델과 추론 단계를 제안하고, 실제 설정 변경은 사용자가 수행한 다음 checkpoint부터 적용한다.
- `HARD_CONSTRAINT`는 보안·권한·데이터 무결성·저장 호환성·불가역 변경에만 사용한다.
- 일반 기술 구조는 `RECOMMENDED_DEFAULT`, 표현·비파괴 초안은 `JUDGMENT_SPACE`로 구분한다.
- Prompt는 `problem / player_or_user_value / inputs / authority_and_source / output_contract / invariants / failure_conditions / validation`의 Interface-first 계약을 우선한다.
- 예시는 정답 권위가 아니라 정상·실패·경계·회귀 Fixture 또는 Golden Set으로 보존한다.
- Context는 `decision_question / include_criteria / exclude_criteria / authority_level / freshness / known_conflicts / progressive_load_trigger / refresh_trigger`를 기록한다.
- 화면·Schema·Fixture는 실제 Godot 런타임·사람 이해·접근성·성능을 자동 증명하지 않는다. 실행하지 않은 항목은 `NOT_RUN` 또는 `HUMAN_NOT_RUN`이다.

Base identity: payload `{BASE_PAYLOAD}`, evidence `{BASE_EVIDENCE}`, Registry `{BASE_REGISTRY_SHA}`.
"""
    text = append_once(text, "## Base v9.4 모델·지시·Context 계약", block)
    path.write_text(text, encoding="utf-8")


def migrate_ux_contract() -> None:
    path = ROOT / "docs/UX_UI_SYSTEM.md"
    text = path.read_text(encoding="utf-8")
    text = text.replace("Base content commit: `0fd95f4513343e77fd664af2763a01b02f52545b`", f"Base content commit: `{BASE_PAYLOAD}`")
    marker = "## 9. 검증 매트릭스"
    if "## 8A. UI 모션·중단·반복 계약" not in text:
        block = """## 8A. UI 모션·중단·반복 계약

UI 모션은 다음 상태를 명확하게 표현하되 전투 결과를 소유하지 않는다.

```text
입력 접수
→ 처리 중
→ 도메인 결과 확정
→ 결과 표현
```

- 카드 선택·슬롯 배치·상세 팝업·합 연출은 입력 중단과 즉시 완료 경로를 가진다.
- 빠른 반복 입력과 재진입에서 중복 배치·중복 비용·중복 보상·transform drift가 발생하지 않아야 한다.
- `Reduced Motion`은 핵심 상태·사건 순서·결과 원인을 보존하며, `mute`와 `haptic-off`에서도 텍스트·아이콘·로그로 동등한 정보를 제공한다.
- `AnimationPlayer`·`Tween` 완료 signal은 전투 판정·자원 소비·저장·보상의 권위 시점이 아니다.
- 모션이 취소되거나 건너뛰어져도 CombatState와 결과 로그는 동일해야 한다.

검증되지 않은 실제 화면 반복 피로·Windows 성능·사람 이해는 `NOT_RUN` 또는 `HUMAN_NOT_RUN`으로 유지한다.

"""
        if marker not in text:
            raise SystemExit("UX validation marker missing")
        text = text.replace(marker, block + marker, 1)
    path.write_text(text, encoding="utf-8")


def migrate_maps_and_audit() -> None:
    audit_path = ROOT / "docs/reviews/2026-08-01_BASE_V9_4_ADOPTION_AUDIT.md"
    audit_path.write_text(
        f"""# Base v9.4 프로젝트 적용 감사 — 십보강호

## 판정

```yaml
decision_id: DEC-2026-08-01-001
issue: 67
baseline_commit: {BRANCH_BASELINE}
base_version: {BASE_VERSION}
base_payload: {BASE_PAYLOAD}
base_evidence: {BASE_EVIDENCE}
base_finalization: {BASE_FINALIZATION}
base_registry_sha256: {BASE_REGISTRY_SHA}
adoption_scope: OPERATING_CONTRACT_ONLY
product_paths_changed: false
gdd_sheet_written: false
runtime_validation: NOT_RUN
human_validation: HUMAN_NOT_RUN
```

## 적용

- canonical `PROJECT_BASE_ADAPTER.json`과 generated snapshot·compatibility view를 v9.4 payload/evidence에 맞췄다.
- 공용 route `optimizing-ai-model-and-prompt-costs`를 추가하고 프로젝트 고유 Skill 4개를 보존했다.
- AI Workflow에 `[모델 추천]`, 지시 권위, Interface-first Prompt, Example-as-Fixture, Context 큐레이션, Artifact 주장 상한을 연결했다.
- UX/UI 정본에 입력 접수·처리 중·도메인 결과·결과 표현, 중단·즉시 완료·연타·재진입·Reduced Motion·mute·haptic-off 계약을 연결했다.

## 보호 확인

변경 금지 경로:

```text
data/
src/
scenes/
assets/
addons/
project.godot
```

무공 카드 규칙, 문파, 사거리, 비용, 행동 슬롯, 기력·내력, 전투 코어, 저장 Schema, 승인 아트 방향은 변경하지 않는다.

## 적대적 검토 질문

1. 모션 완료가 전투 판정·비용·보상·저장의 권위 시점이 되었는가.
2. 중단·즉시 완료·빠른 반복·재진입에서 결과가 중복되는가.
3. Context 큐레이션이 반대 근거·실패 사례·보호 규칙을 제거하는가.
4. `[모델 추천]`이 실제 모델 설정 변경을 완료했다고 오인시키는가.
5. 문서·Fixture만으로 Godot 런타임·사람 이해·성능을 PASS 처리하는가.

## 증거 상한

- adapter·snapshot·문서·정적 계약: 자동 검증 대상.
- Godot 실제 화면·Windows·실물 입력·성능: `NOT_RUN`.
- 신규 플레이어 이해·반복 피로·재미: `HUMAN_NOT_RUN`.
- provider 실제 비용·cache hit·절감률: `NOT_RUN`.
""",
        encoding="utf-8",
    )

    docs_map = ROOT / "docs/DOCUMENTATION_MAP.md"
    text = docs_map.read_text(encoding="utf-8")
    line = "14. [Base v9.4 적용 감사](reviews/2026-08-01_BASE_V9_4_ADOPTION_AUDIT.md) — payload·evidence·Registry와 프로젝트 보호 경계."
    if line not in text:
        anchor = "13. [Base 적용·학습 기록](11_BASE_ADOPTION_AND_LEARNING_LOG.md) — 채택·구체화·검증·Base 제안 경계."
        text = replace_required(text, anchor, anchor + "\n" + line, "docs map")
    docs_map.write_text(text, encoding="utf-8")

    hub_map = ROOT / "[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md"
    text = hub_map.read_text(encoding="utf-8")
    hub_line = "- `docs/reviews/2026-08-01_BASE_V9_4_ADOPTION_AUDIT.md`: Base v9.4 payload·evidence·Registry와 프로젝트 보호 경계 감사."
    text = append_once(text, hub_line, "## Base v9.4 적용\n\n" + hub_line)
    hub_map.write_text(text, encoding="utf-8")


def migrate_tests() -> None:
    path = ROOT / "tests/test_base_v9_adoption.py"
    text = path.read_text(encoding="utf-8")
    text = text.replace("test_v9_1_canonical_adapter_preserves_planning_boundary", "test_v9_4_canonical_adapter_preserves_planning_boundary")
    text = replace_required(text, 'self.assertEqual(data["base_release"]["version"], "9.1.0")', 'self.assertEqual(data["base_release"]["version"], "9.4.0")', "adoption test version")
    path.write_text(text, encoding="utf-8")

    new_test = ROOT / "tests/test_base_v94_ai_operations_adoption.py"
    new_test.write_text(
        f"""from __future__ import annotations

import hashlib
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class BaseV94AiOperationsAdoptionTests(unittest.TestCase):
    def test_exact_base_identity_and_route_are_adopted(self) -> None:
        adapter = json.loads((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_text(encoding="utf-8"))
        snapshot = json.loads((ROOT / "skills/PROJECT_SKILL_SNAPSHOT.json").read_text(encoding="utf-8"))
        self.assertEqual("{BASE_VERSION}", adapter["base_release"]["version"])
        self.assertEqual("{BASE_PAYLOAD}", adapter["base_release"]["release_commit"])
        self.assertEqual("{BASE_EVIDENCE}", adapter["base_release"]["release_evidence_commit"])
        self.assertEqual("{BASE_REGISTRY_SHA}", adapter["skill_registry"]["base"]["sha256"])
        self.assertEqual("{BASE_REGISTRY_SHA}", snapshot["base_registry"]["sha256"])
        self.assertIn("{NEW_SKILL}", {{item["route_id"] for item in adapter["routing"]["base_routes"]}})
        self.assertEqual("BASE_SHARED", snapshot["effective_routes"]["{NEW_SKILL}"]["source"])

    def test_project_local_skills_and_product_paths_are_preserved(self) -> None:
        adapter = json.loads((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_text(encoding="utf-8"))
        self.assertEqual(
            {{"combat-implementation-handoff", "combat-ux-and-accessibility", "ten-paces-game-design", "ten-paces-verification"}},
            {{item["route_id"] for item in adapter["routing"]["project_routes"]}},
        )
        self.assertEqual(["data/", "src/", "scenes/", "assets/", "addons/", "project.godot"], adapter["protected_paths"])

    def test_generated_views_bind_to_canonical_adapter(self) -> None:
        adapter_sha = hashlib.sha256((ROOT / "skills/PROJECT_BASE_ADAPTER.json").read_bytes()).hexdigest()
        for path in ("skills/BASE_V9_ADAPTER.json", "skills/PROJECT_BASE_SKILL_ADAPTER.json"):
            view = json.loads((ROOT / path).read_text(encoding="utf-8"))
            self.assertEqual(adapter_sha, view["canonical_source_sha256"])
            self.assertEqual("{BASE_VERSION}", view["base_release"]["version"])

    def test_ai_and_ui_contracts_are_discoverable(self) -> None:
        ai = (ROOT / "[기획서]/00_프로젝트_허브/AI_WORKFLOW.md").read_text(encoding="utf-8")
        ux = (ROOT / "docs/UX_UI_SYSTEM.md").read_text(encoding="utf-8")
        audit = (ROOT / "docs/reviews/2026-08-01_BASE_V9_4_ADOPTION_AUDIT.md").read_text(encoding="utf-8")
        for token in ("[모델 추천]", "HARD_CONSTRAINT", "Interface-first", "Example-as-Fixture", "refresh_trigger", "NOT_RUN"):
            self.assertIn(token, ai)
        for token in ("입력 접수", "처리 중", "중단", "즉시 완료", "빠른 반복", "재진입", "Reduced Motion", "mute", "haptic-off", "권위 시점"):
            self.assertIn(token, ux)
        self.assertIn("product_paths_changed: false", audit)
        self.assertIn("HUMAN_NOT_RUN", audit)


if __name__ == "__main__":
    unittest.main()
""",
        encoding="utf-8",
    )


def main() -> None:
    adapter_sha = migrate_adapter()
    migrate_snapshot()
    migrate_compatibility_views(adapter_sha)
    migrate_current_documents()
    migrate_ai_workflow()
    migrate_ux_contract()
    migrate_maps_and_audit()
    migrate_tests()


if __name__ == "__main__":
    main()
