#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE_HEAD = "7494f50c48573168542781e007eeab6af11dda7d"
RUN_ID = "31068098197"
ARTIFACT_ID = "8954602789"
DECISION = "TEN_MANUAL_PRODUCT_VALIDATION_GATE"
NEXT_DECISION = "TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE"


def path(relative: str) -> Path:
    result = ROOT / relative
    result.parent.mkdir(parents=True, exist_ok=True)
    return result


def replace_once(relative: str, old: str, new: str) -> None:
    target = path(relative)
    text = target.read_text(encoding="utf-8")
    if new in text:
        return
    if old not in text:
        raise RuntimeError(f"missing replacement token in {relative}: {old!r}")
    target.write_text(text.replace(old, new, 1), encoding="utf-8")


def insert_before(relative: str, marker: str, heading: str, block: str) -> None:
    target = path(relative)
    text = target.read_text(encoding="utf-8")
    if heading in text:
        return
    if marker not in text:
        raise RuntimeError(f"missing insertion marker in {relative}: {marker!r}")
    target.write_text(text.replace(marker, block.rstrip() + "\n\n" + marker, 1), encoding="utf-8")


def write(relative: str, content: str) -> None:
    path(relative).write_text(content.rstrip() + "\n", encoding="utf-8")


# ACTIVE_CONTEXT: keep product core and parent authorities; move only the current evidence state.
replace_once(
    "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md",
    "> 초기 무공서 UI·AI 채택 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`  \n",
    "> 초기 무공서 UI·AI 채택 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`  \n> 초기 무공서 자동 제품 검증 권위: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`  \n",
)
for old, new in [
    ("active_decision_state: TEN_MANUAL_UI_AI_ADOPTED", "active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED"),
    ("runtime_implementation: TEN_MANUAL_UI_AI_ADOPTION_PR92", "runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_PR92"),
    ("latest_combat_planning_runtime: UI_AI_ADOPTED", "latest_combat_planning_runtime: PRODUCT_VALIDATION_AUTOMATED"),
    ("windows_validation: NOT_RUN", "windows_validation: CI_EXPORT_RUNTIME_PASS_LOCAL_NOT_RUN"),
    ("accessibility_validation: NOT_RUN", "accessibility_validation: AUTOMATED_PASS_USER_NOT_RUN"),
    ("performance_validation: NOT_RUN", "performance_validation: BASELINE_CAPTURED_RELEASE_NOT_RUN"),
    ("next_planning_decision: TEN_MANUAL_PRODUCT_VALIDATION_GATE", f"next_planning_decision: {NEXT_DECISION}"),
    ("DRAFT_PR92_TEN_MANUAL_UI_AI_ADOPTION_10_OF_10", "DRAFT_PR92_TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_10_OF_10"),
]:
    replace_once("[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md", old, new)
replace_once(
    "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md",
    "자동 검증 통과는 Windows·접근성·성능·사람 플레이·밸런스 승인을 대신하지 않는다.",
    "자동 제품 검증은 Windows CI export·runtime, 세 해상도, 합성 입력, 자동 접근성, 성능 baseline까지만 증명한다. 로컬 Windows 렌더·실물 입력·접근성 사용자·Release 성능·사람 플레이·밸런스 승인을 대신하지 않는다.",
)
insert_before(
    "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md",
    "## 현재 위험과 다음 순서",
    "## 자동 제품 검증 권위",
    f"""## 자동 제품 검증 권위

`{DECISION}`은 UI·AI 채택 부모 권위 위에서 자동 제품 증거만 승인한다.

```yaml
product_gate: PARTIAL_AUTOMATED_COMPLETE
evidence_source_head: {EVIDENCE_HEAD}
workflow_run_id: {RUN_ID}
windows_artifact_id: {ARTIFACT_ID}
windows_export: PASS
windows_ci_runtime: PASS
scenario_matrix: 50/50 PASS
resolution_matrix: 1280x800,1440x900,1920x1080 PASS
keyboard_synthetic: PASS
mouse_synthetic: PASS
accessibility_automated: PASS
performance_baseline: CAPTURED
windows_local_render: NOT_RUN
gamepad_physical: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
human_step14: NOT_RUN
balance_validation: NOT_RUN
```

Windows CI 기준 runtime은 약 3018.23ms, peak working set은 188674048 bytes, exe+pck는 123037256 bytes였다. runner 또는 Godot 버전이 바뀌면 직접 baseline 비교를 금지한다.

Google Sheet 정본 탭 `03_무공서_무학`은 최종 exact head 검증 뒤 같은 Decision/SHA로 갱신한다.""",
)

# Product roadmap.
replace_once(
    "docs/04_ROADMAP.md",
    "> UI·AI 채택 Decision: `TEN_MANUAL_UI_AI_ADOPTION_GATE`\n",
    "> UI·AI 채택 Decision: `TEN_MANUAL_UI_AI_ADOPTION_GATE`  \n> 자동 제품 검증 Decision: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`\n",
)
for old, new in [
    ("active_decision_state: TEN_MANUAL_UI_AI_ADOPTED", "active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED"),
    ("next_planning_decision: TEN_MANUAL_PRODUCT_VALIDATION_GATE", f"next_planning_decision: {NEXT_DECISION}"),
]:
    replace_once("docs/04_ROADMAP.md", old, new)
replace_once(
    "docs/04_ROADMAP.md",
    "UI·AI 채택은 사람·밸런스·Windows·접근성·성능 승인 완료를 뜻하지 않는다.",
    "UI·AI 채택과 자동 제품 검증은 완료됐지만, 로컬 Windows 렌더·실물 입력·접근성 사용자·Release 성능·사람·밸런스 승인은 완료되지 않았다.",
)
insert_before(
    "docs/04_ROADMAP.md",
    "## 4. 제품 연결 범위",
    "### TEN_MANUAL_PRODUCT_VALIDATION_GATE — 자동 증거 완료",
    f"""### TEN_MANUAL_PRODUCT_VALIDATION_GATE — 자동 증거 완료

- [x] 10권 × 3·5·7·9·10성 = 50개 제품 시나리오.
- [x] Windows x86_64 Release export.
- [x] export된 실행 파일 Windows CI runtime.
- [x] 1280×800·1440×900·1920×1080.
- [x] 키보드·마우스 합성 입력과 포커스·레이아웃 자동 접근성.
- [x] 성능 baseline 캡처.
- [x] SHA·artifact·사람 상태 과장 validator.
- [ ] 로컬 Windows 렌더와 실물 입력.
- [ ] 접근성 사용자 검증.
- [ ] Release 성능 검증.
- [ ] STEP 14 신규 플레이어 5명.

증거: `{EVIDENCE_HEAD}` / workflow `{RUN_ID}` / artifact `{ARTIFACT_ID}`. 현재 판정은 `PARTIAL_AUTOMATED_COMPLETE`다.

다음 작업:

```text
{NEXT_DECISION}
→ TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE
→ TEN_MANUAL_BALANCE_MEASUREMENT_GATE
→ 최종 밸런스 Decision
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```""",
)

# Short operational roadmap was stale; replace it with a current pointer and synchronized keys.
write(
    "[기획서]/00_프로젝트_허브/ROADMAP.md",
    f"""# 십보강호 운영 로드맵

> 상세 제품 로드맵: `../../../docs/04_ROADMAP.md`  
> 현재 상태: `ACTIVE_CONTEXT.md`  
> 정본 생명주기: `../../../docs/CANON_LIFECYCLE_REGISTRY.md`

```yaml
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: BUILD
active_planning_pr: 92
active_planning_parent_pr: 91
active_approval_count: 10/10
active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED
next_planning_decision: {NEXT_DECISION}
human_validation: NOT_RUN
base_release_pinned: 9.4.3
```

## 현재 작업

- `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`: 완료.
- `TEN_MANUAL_UI_AI_ADOPTION_GATE`: 완료.
- `TEN_MANUAL_PRODUCT_VALIDATION_GATE`: 자동 증거 완료, `PARTIAL_AUTOMATED_COMPLETE`.
- Windows CI export·runtime, 50개 성취도 시나리오, 3개 해상도, 합성 입력, 자동 접근성, 성능 baseline: PASS/CAPTURED.
- 로컬 Windows·실물 게임패드·접근성 사용자·Release 성능·STEP 14·밸런스: NOT_RUN.

## 다음 순서

```text
{NEXT_DECISION}
→ TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE
→ TEN_MANUAL_BALANCE_MEASUREMENT_GATE
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

## 운영 경계

- PR #92는 PR #91 위의 Draft를 유지한다.
- 자동 증거를 전체 제품 PASS·T1·MVP·병합 권한으로 확대하지 않는다.
- 실행하지 않은 검증은 `NOT_RUN / UNVERIFIED`다.
""",
)

# Canon registry.
replace_once(
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "- 현행 UI·AI 채택 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`\n",
    "- 현행 UI·AI 채택 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`\n- 현행 자동 제품 검증 권위: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`\n",
)
replace_once(
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "| 초기 10권 UI·AI Decision | `TEN_MANUAL_UI_AI_ADOPTION_GATE` |\n",
    "| 초기 10권 UI·AI Decision | `TEN_MANUAL_UI_AI_ADOPTION_GATE` |\n| 초기 10권 자동 제품 검증 Decision | `TEN_MANUAL_PRODUCT_VALIDATION_GATE` |\n| 자동 제품 검증 증거 | `docs/evidence/TEN_MANUAL_PRODUCT_VALIDATION_EVIDENCE.md` |\n",
)
replace_once(
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "- `approved_20260805_work_governance_contract.json`\n",
    "- `approved_20260805_work_governance_contract.json`\n- `approved_20260806_ten_manual_product_validation_gate_contract.json`\n",
)
replace_once(
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "현재 상태는 `UI_AI_ADOPTED`다.",
    "현재 상태는 `PRODUCT_VALIDATION_AUTOMATED / PARTIAL_AUTOMATED_COMPLETE`다.",
)
replace_once(
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "- Windows·접근성·성능·사람 플레이 승인.",
    "- 로컬 Windows 렌더·실물 입력·접근성 사용자·Release 성능·사람 플레이 승인.",
)
insert_before(
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "## `[대체됨]`",
    "## 자동 제품 검증 증거 경계",
    f"""## 자동 제품 검증 증거 경계

- evidence source head: `{EVIDENCE_HEAD}`.
- workflow: `{RUN_ID}`.
- Windows artifact: `{ARTIFACT_ID}`.
- 50/50 성취도 시나리오, Windows export/runtime, 세 해상도, 합성 입력, 자동 접근성: PASS.
- 성능 baseline: CAPTURED.
- `windows_local_render`, `gamepad_physical`, `accessibility_user`, `release_performance`, `human_step14`: NOT_RUN.
- 위 자동 증거는 T1·MVP·Draft 해제·병합 권한을 만들지 않는다.""",
)
replace_once(
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "`TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`와 `TEN_MANUAL_UI_AI_ADOPTION_GATE`는 완료됐다. 현재 승인 배치는 `10/10`이다.",
    "`TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`, `TEN_MANUAL_UI_AI_ADOPTION_GATE`, `TEN_MANUAL_PRODUCT_VALIDATION_GATE`의 자동 범위는 완료됐다. 현재 승인 배치는 `10/10`이다.",
)
replace_once(
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "TEN_MANUAL_PRODUCT_VALIDATION_GATE\n→ Godot Windows 실제 실행\n→ 접근성·성능 검증\n→ STEP 14 사람·밸런스 검증",
    f"{NEXT_DECISION}\n→ TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE\n→ TEN_MANUAL_BALANCE_MEASUREMENT_GATE",
)

# Development gates and checklist retain all prior sections, adding evidence state.
replace_once(
    "[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md",
    "runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65",
    "runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_PR92",
)
insert_before(
    "[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md",
    "## 11. `[보류]`",
    "## 10A — 초기 10권 자동 제품 검증",
    f"""## 10A — 초기 10권 자동 제품 검증

- [x] Windows x86_64 Release export.
- [x] export된 실행 파일 Windows CI runtime.
- [x] 50개 성취도 제품 시나리오.
- [x] 1280×800·1440×900·1920×1080.
- [x] 합성 키보드·마우스와 자동 접근성.
- [x] 성능 baseline.
- [ ] 로컬 Windows·실물 입력·접근성 사용자·Release 성능.
- [ ] STEP 14 신규 플레이어 5명.

판정: `PARTIAL_AUTOMATED_COMPLETE`; 증거 `{EVIDENCE_HEAD}` / `{RUN_ID}` / `{ARTIFACT_ID}`.""",
)
replace_once(
    "docs/08_TEST_CHECKLIST.md",
    "> 현재 구현 기준: `659c57e7ffa588ad6a6471ed9b5394985b159eaf`",
    f"> 자동 제품 검증 증거 기준: `{EVIDENCE_HEAD}`",
)
insert_before(
    "docs/08_TEST_CHECKLIST.md",
    "## 20. STEP 14 사람 플레이",
    "## 19A. 초기 10권 자동 제품 검증",
    f"""## 19A. 초기 10권 자동 제품 검증

- [x] 계약·validator 변조 테스트.
- [x] 10권 × 3·5·7·9·10성 = 50개 시나리오.
- [x] Windows x86_64 Release export.
- [x] export된 실행 파일 Windows CI runtime.
- [x] 1280×800·1440×900·1920×1080.
- [x] 키보드·마우스 합성 입력.
- [x] 포커스·레이아웃·자동 접근성.
- [x] 성능 baseline 캡처.
- [x] evidence SHA와 artifact metadata 검증.
- [ ] 로컬 Windows 렌더.
- [ ] 실물 게임패드.
- [ ] 접근성 사용자.
- [ ] Release 성능.
- [ ] STEP 14 참가자 5명.

현재 판정: `PARTIAL_AUTOMATED_COMPLETE`; `{EVIDENCE_HEAD}` / workflow `{RUN_ID}` / artifact `{ARTIFACT_ID}`.""",
)

# STEP 14 is reactivated, but no participant data is fabricated.
write(
    "docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md",
    f"""# STEP 14 REPEAT_POC 플레이테스트 프로토콜

> 상태: `REACTIVATED_BY_USER / READY_NOT_RUN`  
> 제품 Gate: `{DECISION}`  
> 고정 자동 증거 build: `{EVIDENCE_HEAD}`

```yaml
protocol_status: REACTIVATED_BY_USER
build_commit: {EVIDENCE_HEAD}
participant_count: 0
human_step14: NOT_RUN
status: READY_NOT_RUN
```

## 실행 전제

- 자동 제품 증거 workflow `{RUN_ID}`와 Windows artifact `{ARTIFACT_ID}`가 존재한다.
- 참가자는 신규 플레이어 5명이다.
- 첫 참가자 이후 질문·통과 기준을 변경하지 않는다.
- 관찰 사실·참가자 발화 요약·진행자 개입·해석을 분리한다.
- 자동검증이나 가상 응답을 사람 결과로 기록하지 않는다.

## 고정 질문

- 3/3/4 묶음을 자기 말로 설명하는가?
- 결정적 원인을 거리·방향·합·대응·순서·자원 중 하나로 설명하는가?
- 문파·무공서·별 성취도와 기술 해금을 이해하는가?
- 상대의 반복 성향을 발견하는가?
- 다음 묶음 또는 재도전에서 계획을 변경하는가?
- 색·모션·음향 없이 핵심 결과를 이해하는가?

## 통과 신호

- 4/5 이상 전투 완료.
- 4/5 이상 3/3/4와 결정적 원인 설명.
- 3/5 이상 상대 성향 발견.
- 3/5 이상 계획 변경.
- 3/5 이상 자발적 재도전 또는 다음 수 선택.
- 핵심 결과를 막는 단일 정보 채널 장벽 0건.

실행 전 결과는 모두 `NOT_RUN`이다.
""",
)
write(
    "docs/research/STEP14_REPEAT_POC_RESULTS_TEMPLATE.md",
    f"""# STEP 14 REPEAT_POC 결과 기록

> 상태: `READY_NOT_RUN`  
> 프로토콜: `docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md`  
> build commit: `{EVIDENCE_HEAD}`

```yaml
build_commit: {EVIDENCE_HEAD}
godot_version: 4.7.1
windows_ci_runtime: PASS
windows_local_render: NOT_RUN
viewport_matrix: 1280x800,1440x900,1920x1080
input_methods_automated: [keyboard_synthetic, mouse_synthetic]
input_methods_physical: []
participant_count: 0
human_step14: NOT_RUN
protocol_changed_after_first_participant: false
```

| 참가자 | 한 판 완료 | 3/3/4 설명 | 결정적 원인 설명 | 성향 발견 | 계획 변경 | 자발적 재도전/다음 수 | 단일 채널 장벽 | 상태 |
|---|---|---|---|---|---|---|---|---|
| P01 | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN |
| P02 | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN |
| P03 | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN |
| P04 | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN |
| P05 | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN |

## 관찰 원문 템플릿

```yaml
participant_id:
observed_behavior: []
verbatim_summary: []
facilitator_intervention: []
interpretation: []
suggested_change: []
```

## 통과 신호 집계

```yaml
completed_battle_4_of_5: NOT_RUN
explained_bundle_and_cause_4_of_5: NOT_RUN
identified_tendency_3_of_5: NOT_RUN
changed_plan_3_of_5: NOT_RUN
voluntary_retry_or_next_move_3_of_5: NOT_RUN
single_channel_barrier_zero: NOT_RUN
```

```yaml
automated_product_gate: PARTIAL_AUTOMATED_COMPLETE
human_step14: NOT_RUN
product_gate: HUMAN_VALIDATION_PENDING
t1_greenlight: NOT_GRANTED
mvp_complete: false
```
""",
)

# Decision and evidence summary.
write(
    "docs/decisions/2026-08-06_TEN_MANUAL_PRODUCT_VALIDATION_GATE.md",
    f"""# 초기 10권 자동 제품 검증 Decision

- Decision ID: `{DECISION}`
- 상태: `APPROVED_AND_IMPLEMENTED_PARTIAL_AUTOMATED_COMPLETE`
- 승인 근거: 사용자 `권장안대로 진행` 후 written spec 승인
- 부모 권위: `TEN_MANUAL_UI_AI_ADOPTION_GATE`
- evidence source head: `{EVIDENCE_HEAD}`
- workflow run: `{RUN_ID}`
- Windows artifact: `{ARTIFACT_ID}`

## 승인 결과

- Windows x86_64 Release export: PASS.
- export된 실행 파일 Windows CI runtime: PASS.
- 초기 10권 × 3·5·7·9·10성 50개 시나리오: 50/50 PASS.
- 1280×800·1440×900·1920×1080: PASS.
- 키보드·마우스 합성 입력, 포커스, 레이아웃, 자동 접근성: PASS.
- 성능 baseline: CAPTURED.

```yaml
runtime_authority: PRODUCT_VALIDATION_AUTOMATED
product_gate: PARTIAL_AUTOMATED_COMPLETE
windows_ci_runtime: PASS
windows_local_render: NOT_RUN
gamepad_physical: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
human_step14: NOT_RUN
balance_validation: NOT_RUN
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

## 성능 baseline

- exported runtime: 3018.23ms.
- peak working set: 188674048 bytes.
- exe+pck: 123037256 bytes.
- runner: windows-latest.
- Godot: 4.7.1.

동일 runner·Godot 버전이 아니면 직접 회귀 비교하지 않는다.

## 금지 해석

자동 증거를 로컬 Windows 렌더·실물 입력·접근성 사용자·Release 성능·사람 플레이·최종 밸런스·T1·MVP·Draft 해제·병합 승인으로 확대하지 않는다.

## 다음 Gate

1. `{NEXT_DECISION}`.
2. `TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE`.
3. `TEN_MANUAL_BALANCE_MEASUREMENT_GATE`.
""",
)
write(
    "docs/evidence/TEN_MANUAL_PRODUCT_VALIDATION_EVIDENCE.md",
    f"""# 초기 10권 자동 제품 검증 증거

```yaml
decision_id: {DECISION}
evidence_source_head: {EVIDENCE_HEAD}
workflow_run_id: {RUN_ID}
windows_artifact_id: {ARTIFACT_ID}
windows_artifact_name: ten-manual-product-validation-{EVIDENCE_HEAD}
artifact_digest: sha256:b266edee31662d788cb2cdb16c32ea0380842c84a5d72a3201a4709afdab0cc7
scenario_count: 50
scenario_passed: 50
scenario_failed: 0
windows_export: PASS
windows_ci_runtime: PASS
resolution_matrix: PASS
keyboard_synthetic: PASS
mouse_synthetic: PASS
accessibility_automated: PASS
performance_baseline: CAPTURED
windows_local_render: NOT_RUN
gamepad_physical: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
human_step14: NOT_RUN
participant_count: 0
product_gate: PARTIAL_AUTOMATED_COMPLETE
```

## artifact readback

- Windows executable: 109212160 bytes.
- PCK: 13825096 bytes.
- combined: 123037256 bytes.
- runtime elapsed: 3018.23ms.
- peak working set: 188674048 bytes.
- stdout: `TEN_MANUAL_EXPORTED_PRODUCT_VALIDATION_OK`.
- stderr: empty.
- scenario evidence elapsed: 12ms; failures: none.

생성 JSON은 Actions artifact이며 저장소 정본이 아니다. 이 문서는 검증된 요약과 증거 식별자만 보존한다.
""",
)

# Replace lifecycle checker with the same historical guardrails plus the new product authority.
write(
    "tools/check_postmerge_canon_lifecycle.py",
    '''#!/usr/bin/env python3
from __future__ import annotations

import json
import pathlib
import re
import sys
from typing import Any

ROOT = pathlib.Path(__file__).resolve().parents[1]
ACTIVE_PATH = pathlib.Path("[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md")
ROADMAP_PATH = pathlib.Path("docs/04_ROADMAP.md")
MASTERY_PATH = pathlib.Path("docs/06_STARTING_FACTION_MASTERY_DATA.md")
REGISTRY_PATH = pathlib.Path("docs/CANON_LIFECYCLE_REGISTRY.md")
RUNTIME_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-06_TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE.md")
UI_AI_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-06_TEN_MANUAL_UI_AI_ADOPTION_GATE.md")
PRODUCT_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-06_TEN_MANUAL_PRODUCT_VALIDATION_GATE.md")
PRODUCT_CONTRACT_PATH = pathlib.Path("docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json")
PRODUCT_EVIDENCE_PATH = pathlib.Path("docs/evidence/TEN_MANUAL_PRODUCT_VALIDATION_EVIDENCE.md")
STEP14_PROTOCOL_PATH = pathlib.Path("docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md")
STEP14_RESULTS_PATH = pathlib.Path("docs/research/STEP14_REPEAT_POC_RESULTS_TEMPLATE.md")
BUILD_APPROVAL_PATH = pathlib.Path("docs/implementation/BUILD_APPROVAL_2026-08-06.md")
RUNTIME_MANIFEST_PATH = pathlib.Path("data/cards/martial_manual_cards.json")
UI_AI_LOADOUT_PATH = pathlib.Path("data/combat/ten_manual_loadout_poc.json")
RANGE_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md")
OLD_TECHNIQUE_DECISION_PATH = pathlib.Path("docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md")
OLD_TECHNIQUE_CONTRACT_PATH = pathlib.Path("docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json")
AUDIT_CONTRACT_PATH = pathlib.Path("docs/planning-data/approved_20260804_postmerge_canon_adversarial_audit_contract.json")

EXPECTED_RISKS = {"RESOURCE_SATURATION_RISK", "CONDITION_CALIBRATION_RISK", "WRONG_PLAN_RESCUE_RISK", "OBSERVATION_ANSWER_LEAK_RISK", "GRADE_FARMING_RISK", "RUNTIME_AUTHORITY_GAP"}
OPERATING_KEYS = ("active_planning_pr", "active_planning_parent_pr", "active_approval_count", "active_decision_state", "next_planning_decision")

class CanonLifecycleError(ValueError):
    pass

def require(condition: bool, message: str) -> None:
    if not condition:
        raise CanonLifecycleError(message)

def read_text(root: pathlib.Path, relative: pathlib.Path) -> str:
    target = root / relative
    require(target.is_file(), f"missing canon lifecycle file: {relative.as_posix()}")
    return target.read_text(encoding="utf-8")

def read_json(root: pathlib.Path, relative: pathlib.Path) -> dict[str, Any]:
    value = json.loads(read_text(root, relative))
    require(isinstance(value, dict), f"{relative.as_posix()} must contain a JSON object")
    return value

def yaml_scalar(text: str, key: str) -> str:
    values = re.findall(rf"(?m)^{re.escape(key)}:\\s*([^\\s#]+)\\s*(?:#.*)?$", text)
    require(len(values) == 1, f"operating checkpoint key must appear exactly once: {key}")
    return values[0]

def require_tokens(text: str, tokens: list[str], label: str) -> None:
    for token in tokens:
        require(token in text, f"{label} missing token: {token}")

def validate_operating_state(active: str, roadmap: str) -> None:
    active_state = {key: yaml_scalar(active, key) for key in OPERATING_KEYS}
    roadmap_state = {key: yaml_scalar(roadmap, key) for key in OPERATING_KEYS}
    require(active_state == roadmap_state, "operating checkpoint mismatch between active context and roadmap")
    require(active_state["active_planning_pr"] == "92", "active planning PR differs from current Draft PR #92")
    require(active_state["active_planning_parent_pr"] == "91", "active planning parent PR differs")
    require(active_state["active_approval_count"] == "10/10", "active approval count differs")
    require(active_state["active_decision_state"] == "TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED", "active decision state differs")
    require(active_state["next_planning_decision"] == "TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE", "next planning decision differs")
    require_tokens(active, [
        "runtime_work_mode: REVIEW", "runtime_integration_pr: 65",
        "runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED_PR92",
        "latest_combat_planning_runtime: PRODUCT_VALIDATION_AUTOMATED",
        "windows_validation: CI_EXPORT_RUNTIME_PASS_LOCAL_NOT_RUN",
        "accessibility_validation: AUTOMATED_PASS_USER_NOT_RUN",
        "performance_validation: BASELINE_CAPTURED_RELEASE_NOT_RUN",
        "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE", "TEN_MANUAL_UI_AI_ADOPTION_GATE",
        "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "PARTIAL_AUTOMATED_COMPLETE",
        "플레이어 비공개 계획·미확정 배치·포인터는 참조하지 않는다",
        "능력치별 무공서 권수·균등 분포·최소/최대 쿼터는 사용하지 않는다",
        "03_무공서_무학",
    ], "active context")
    require_tokens(roadmap, [
        "프로젝트 코어 확정", "현재 작업", "STEP 14", "T1 — 최소 세로 슬라이스",
        "공통 검증 게이트", "중단·축소 조건", "KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST",
        "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "PARTIAL_AUTOMATED_COMPLETE",
        "TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE", "NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT",
    ], "roadmap")

def validate_runtime_authority(runtime_decision: str, build_approval: str, manifest: dict[str, Any]) -> None:
    require_tokens(runtime_decision, ["TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE", "APPROVED_RUNTIME_FOUNDATION", "RUNTIME_FOUNDATION", "PR #92", "PR #91"], "runtime Decision")
    require_tokens(build_approval, ["registry + ordered effect pipeline + explicit engine loadout integration", "human validation: NOT_RUN", "balance validation: NOT_RUN"], "runtime build approval")
    require(manifest.get("runtime_status") == "RUNTIME_FOUNDATION", "runtime manifest authority differs")
    require(manifest.get("stat_quota_rules_enabled") is False, "runtime manifest re-enabled stat quota rules")
    files = manifest.get("manual_files")
    require(isinstance(files, dict) and len(files) == 10, "runtime manifest must map exactly ten manuals")
    compatibility = manifest.get("compatibility")
    require(isinstance(compatibility, dict) and compatibility.get("legacy_default_behavior_unchanged") is True, "legacy default behavior must remain unchanged")
    require(compatibility.get("explicit_loadout_required") is True, "martial cards must require an explicit loadout")

def validate_ui_ai_authority(ui_ai_decision: str, loadout: dict[str, Any]) -> None:
    require_tokens(ui_ai_decision, ["TEN_MANUAL_UI_AI_ADOPTION_GATE", "APPROVED_AND_IMPLEMENTED", "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "martial_loadout", "martial_mastery_by_manual", "플레이어 비공개 계획", "MartialEffectPipeline", "31053963064", "03_무공서_무학"], "UI AI Decision")
    require(loadout.get("authority") == "TEN_MANUAL_UI_AI_ADOPTION_GATE", "ten-manual loadout authority differs")
    require(isinstance(loadout.get("player"), dict) and isinstance(loadout.get("enemy"), dict), "player and enemy loadouts must be separate")
    require(bool(loadout["player"].get("loadout")) and bool(loadout["enemy"].get("loadout")), "player and enemy loadouts must be explicit")

def validate_product_authority(decision: str, contract: dict[str, Any], evidence: str, protocol: str, results: str) -> None:
    require_tokens(decision, ["TEN_MANUAL_PRODUCT_VALIDATION_GATE", "APPROVED_AND_IMPLEMENTED_PARTIAL_AUTOMATED_COMPLETE", "7494f50c48573168542781e007eeab6af11dda7d", "31068098197", "8954602789", "windows_local_render: NOT_RUN", "human_step14: NOT_RUN", "t1_greenlight: NOT_GRANTED"], "product Decision")
    require(contract.get("decision_id") == "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "product contract decision differs")
    require(contract.get("required_scenario_count") == 50 and len(contract.get("scenario_matrix", [])) == 50, "product contract scenario count differs")
    require(contract.get("forced_not_run") == ["windows_local_render", "gamepad_physical", "accessibility_user", "release_performance", "human_step14"], "product contract NOT_RUN axes differ")
    require_tokens(evidence, ["scenario_passed: 50", "windows_ci_runtime: PASS", "PARTIAL_AUTOMATED_COMPLETE", "windows_local_render: NOT_RUN", "participant_count: 0"], "product evidence")
    require_tokens(protocol, ["REACTIVATED_BY_USER", "participant_count: 0", "human_step14: NOT_RUN", "7494f50c48573168542781e007eeab6af11dda7d"], "STEP14 protocol")
    require_tokens(results, ["participant_count: 0", "human_step14: NOT_RUN", "P05 | NOT_RUN", "t1_greenlight: NOT_GRANTED"], "STEP14 results")

def validate_superseded_authority(range_decision: str, old_decision: str, old_contract: dict[str, Any]) -> None:
    require("# [대체됨]" in range_decision and "상태: `SUPERSEDED`" in range_decision, "range Decision lifecycle label [대체됨] missing")
    require("# [대체됨]" in old_decision and "상태: `SUPERSEDED`" in old_decision, "Technique1 Decision must be SUPERSEDED")
    require(old_contract.get("authority_status") == "SUPERSEDED_HISTORICAL_EVIDENCE", "superseded Technique1 contract cannot claim current authority")
    require(old_contract.get("lifecycle_label_ko") == "[대체됨]", "superseded Technique1 contract Korean lifecycle label missing")

def validate_registry(registry: str) -> None:
    require_tokens(registry, ["[현행]", "[대체됨]", "[보류]", "[폐기]", "PR #85 HTML Technique1 PoC", "닫힘·병합 금지·제품 권위 없음", "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE", "TEN_MANUAL_UI_AI_ADOPTION_GATE", "TEN_MANUAL_PRODUCT_VALIDATION_GATE", "PRODUCT_VALIDATION_AUTOMATED", "approved_20260806_ten_manual_product_validation_gate_contract.json", "능력치별 무공서 권수·균등 분포·최소/최대 쿼터"], "canon lifecycle registry")

def validate_mastery(mastery: str) -> None:
    require_tokens(mastery, ["active_batch: 10/10", "implementation_authority: RUNTIME_FOUNDATION", "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE", "TEN_MANUAL_UI_AI_ADOPTION_GATE", "현재 Windows·접근성·성능·사람·밸런스 검증은 `NOT_RUN`이다"], "growth authority")

def validate_historical_audit(data: dict[str, Any]) -> None:
    require(set(data.get("adversarial_risks", {})) == EXPECTED_RISKS, "adversarial risk coverage differs")
    held = data.get("held_artifacts")
    require(isinstance(held, list) and len(held) == 1 and held[0].get("merge_allowed") is False, "held HTML PR cannot be mergeable authority")
    order = data.get("next_planning_order")
    require(isinstance(order, list) and order and order[0] == "STAR9_PUBLIC_READ_BRANCH_TEMPLATE", "9-star template must precede individual branches")

def validate(root: pathlib.Path = ROOT) -> None:
    active = read_text(root, ACTIVE_PATH)
    roadmap = read_text(root, ROADMAP_PATH)
    mastery = read_text(root, MASTERY_PATH)
    registry = read_text(root, REGISTRY_PATH)
    validate_operating_state(active, roadmap)
    validate_runtime_authority(read_text(root, RUNTIME_DECISION_PATH), read_text(root, BUILD_APPROVAL_PATH), read_json(root, RUNTIME_MANIFEST_PATH))
    validate_ui_ai_authority(read_text(root, UI_AI_DECISION_PATH), read_json(root, UI_AI_LOADOUT_PATH))
    validate_product_authority(read_text(root, PRODUCT_DECISION_PATH), read_json(root, PRODUCT_CONTRACT_PATH), read_text(root, PRODUCT_EVIDENCE_PATH), read_text(root, STEP14_PROTOCOL_PATH), read_text(root, STEP14_RESULTS_PATH))
    validate_superseded_authority(read_text(root, RANGE_DECISION_PATH), read_text(root, OLD_TECHNIQUE_DECISION_PATH), read_json(root, OLD_TECHNIQUE_CONTRACT_PATH))
    validate_registry(registry)
    validate_mastery(mastery)
    validate_historical_audit(read_json(root, AUDIT_CONTRACT_PATH))

if __name__ == "__main__":
    try:
        validate(ROOT)
    except (CanonLifecycleError, json.JSONDecodeError, OSError) as exc:
        print(f"CANON_LIFECYCLE_ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
    print("CANON_LIFECYCLE_OK")
''',
)

write(
    "tests/test_postmerge_canon_lifecycle.py",
    '''from __future__ import annotations

import importlib.util
import json
import re
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VALIDATOR_PATH = ROOT / "tools" / "check_postmerge_canon_lifecycle.py"
TARGETS = [
    "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md",
    "docs/04_ROADMAP.md",
    "docs/06_STARTING_FACTION_MASTERY_DATA.md",
    "docs/CANON_LIFECYCLE_REGISTRY.md",
    "docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md",
    "docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md",
    "docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json",
    "docs/planning-data/approved_20260804_postmerge_canon_adversarial_audit_contract.json",
    "docs/decisions/2026-08-06_TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE.md",
    "docs/implementation/BUILD_APPROVAL_2026-08-06.md",
    "data/cards/martial_manual_cards.json",
    "docs/decisions/2026-08-06_TEN_MANUAL_UI_AI_ADOPTION_GATE.md",
    "data/combat/ten_manual_loadout_poc.json",
    "docs/decisions/2026-08-06_TEN_MANUAL_PRODUCT_VALIDATION_GATE.md",
    "docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json",
    "docs/evidence/TEN_MANUAL_PRODUCT_VALIDATION_EVIDENCE.md",
    "docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md",
    "docs/research/STEP14_REPEAT_POC_RESULTS_TEMPLATE.md",
]

def load_validator():
    spec = importlib.util.spec_from_file_location("postmerge_canon_lifecycle", VALIDATOR_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("post-merge canon validator cannot be loaded")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def copy_fixture(destination: Path) -> None:
    for relative in TARGETS:
        source = ROOT / relative
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)

def replace_scalar(text: str, key: str, value: str) -> str:
    pattern = rf"(?m)^{re.escape(key)}:\\s*\\S+\\s*$"
    replaced, count = re.subn(pattern, f"{key}: {value}", text)
    if count != 1:
        raise AssertionError(f"expected one scalar for {key}, found {count}")
    return replaced

class PostMergeCanonLifecycleTests(unittest.TestCase):
    def test_current_repository_passes(self) -> None:
        load_validator().validate(ROOT)

    def test_stale_active_pr_state_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            for relative in TARGETS[:2]:
                p = root / relative; p.write_text(replace_scalar(p.read_text(encoding="utf-8"), "active_planning_pr", "87"), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "active planning PR"):
                validator.validate(root)

    def test_active_context_and_roadmap_must_share_checkpoint(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[1]; p.write_text(replace_scalar(p.read_text(encoding="utf-8"), "active_planning_parent_pr", "999"), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "operating checkpoint mismatch"):
                validator.validate(root)

    def test_product_validation_state_cannot_revert_to_ui_ai(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            for relative in TARGETS[:2]:
                p = root / relative; p.write_text(replace_scalar(p.read_text(encoding="utf-8"), "active_decision_state", "TEN_MANUAL_UI_AI_ADOPTED"), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "active decision state"):
                validator.validate(root)

    def test_runtime_foundation_cannot_reenable_stat_quotas(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[10]; data = json.loads(p.read_text(encoding="utf-8")); data["stat_quota_rules_enabled"] = True; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "stat quota"):
                validator.validate(root)

    def test_runtime_foundation_requires_explicit_loadout(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[10]; data = json.loads(p.read_text(encoding="utf-8")); data["compatibility"]["explicit_loadout_required"] = False; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "explicit loadout"):
                validator.validate(root)

    def test_ui_ai_loadout_must_separate_player_and_enemy(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[12]; data = json.loads(p.read_text(encoding="utf-8")); del data["enemy"]; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "player and enemy loadouts"):
                validator.validate(root)

    def test_ui_ai_loadout_authority_cannot_drift(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[12]; data = json.loads(p.read_text(encoding="utf-8")); data["authority"] = "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE"; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "loadout authority"):
                validator.validate(root)

    def test_product_contract_cannot_drop_one_scenario(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[14]; data = json.loads(p.read_text(encoding="utf-8")); data["scenario_matrix"] = data["scenario_matrix"][:-1]; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "scenario count"):
                validator.validate(root)

    def test_step14_cannot_claim_human_pass_with_zero_participants(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[16]; p.write_text(p.read_text(encoding="utf-8").replace("human_step14: NOT_RUN", "human_step14: PASS", 1), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "STEP14 protocol"):
                validator.validate(root)

    def test_superseded_contract_cannot_claim_current_authority(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[6]; data = json.loads(p.read_text(encoding="utf-8")); data["authority_status"] = "CURRENT_APPROVED_PLANNING"; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "superseded Technique1 contract"):
                validator.validate(root)

    def test_missing_korean_superseded_label_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[4]; p.write_text(p.read_text(encoding="utf-8").replace("[대체됨]", "[현행]"), encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "range Decision lifecycle"):
                validator.validate(root)

    def test_missing_core_fun_risk_is_rejected(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[7]; data = json.loads(p.read_text(encoding="utf-8")); del data["adversarial_risks"]["RESOURCE_SATURATION_RISK"]; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "adversarial risk coverage"):
                validator.validate(root)

    def test_held_html_pr_cannot_be_mergeable_authority(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[7]; data = json.loads(p.read_text(encoding="utf-8")); data["held_artifacts"][0]["merge_allowed"] = True; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "held HTML PR"):
                validator.validate(root)

    def test_individual_star9_work_cannot_skip_shared_template(self) -> None:
        validator = load_validator()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); copy_fixture(root)
            p = root / TARGETS[7]; data = json.loads(p.read_text(encoding="utf-8")); data["next_planning_order"] = data["next_planning_order"][1:]; p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\\n", encoding="utf-8")
            with self.assertRaisesRegex(validator.CanonLifecycleError, "9-star template"):
                validator.validate(root)

if __name__ == "__main__":
    unittest.main()
''',
)

print("TEN_MANUAL_PRODUCT_GATE_CANON_SYNC_READY")
