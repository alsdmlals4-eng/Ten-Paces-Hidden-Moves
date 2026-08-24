---
contract_name: PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION
contract_version: '4.8'
status: ACTIVE_BASE_CURRENT_MAIN_THIN_ADAPTER_PROJECT_EXECUTION_CONTRACT
revision: '2026-08-24-r2'
current_binding_decision: TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01
source_uploaded_sha256: 6f0541048e084746f6777223521361d0339dbfb2e223c70947f694f1c050f508
base_repository: https://github.com/alsdmlals4-eng/Base
base_snapshot_policy: ALWAYS_REFETCH_CURRENT_COMPLETED_MAIN
adapter_policy: THIN_ADAPTER_DO_NOT_DUPLICATE_BASE_CANON
project_fact_policy: PROJECT_CANON_AND_ACTUAL_IMPLEMENTATION_FIRST
project_repository: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves
project_default_branch: main
human_workspace: NOTION_DEFAULT_PROJECT_WORKSPACE
runtime_structured_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME
google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL
open_pr_policy: OPEN_PR_READ_ONLY_BY_DEFAULT
current_task_pr_policy: CURRENT_TASK_CONTINUATION_AUTHORIZES_READY_MERGE
force_and_ruleset_bypass_policy: FORBIDDEN
quality_priority: QUALITY_OVER_RESPONSE_SPEED
minimum_viable_alternatives: 3
adversarial_full_loop_minimum: 5
implementation_reality_gate: REQUIRED
visual_generation_policy: TEXT_BRIEF_THEN_EXPLICIT_USER_APPROVAL_THEN_EXACTLY_ONE_RESULT
execution_scope_guard: PROJECT_WORK_ONLY_WHEN_CURRENT_USER_REQUEST_AUTHORIZES_EXECUTION
protected_product_paths:
  - data/
  - src/
  - scenes/
  - assets/
  - addons/
  - project.godot
historical_contract:
  decision: TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01
  status: SUPERSEDED_HISTORICAL_EVIDENCE
  body_root: docs/contracts/integrated-work-v4.5-r2/
---

# 프로젝트 총기획·시각화·구현·검증·병합 통합 작업지시문 v4.8 — 십보강호

이 문서는 십보강호의 **현재 프로젝트 실행 계약 진입점**이다. Base의 상세 playbook을 프로젝트에 복제하지 않고, 십보강호가 계속 보존해야 하는 프로젝트 불변식·authority·증거 경계만 소유한다.

## 1. 시작 순서

```text
최신 사용자 지시
→ 최신 Base completed main + Base root AGENTS.md
→ 이 프로젝트 AGENTS.md
→ 이 v4.8 project adapter
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ current planning JSON + GitHub live metadata + exact Project Notion
→ 최신 관련 Decision / 질문별 owner
→ 실제 code/data/scene/resource/asset/test/runtime
```

Base 원격 최신 규칙은 progressive-load로 사용하며, 과거 Base snapshot이나 release pin을 current remote truth로 재사용하지 않는다. 프로젝트의 과거 Base v9.4.3 pin은 채택 이력·호환 증거이며 최신 사용자 지시와 이 계약을 덮어쓰지 않는다.

## 2. 권위와 DOMAIN SPLIT

```text
사용자의 최신 명시 지시
→ project AGENTS / 보안 / 엔진 / 데이터 규칙
→ Active Context + 승인 계약
→ current Decision + 분야 정본
→ actual code/data/scene/resource/asset/test/runtime
→ 프로젝트가 채택한 호환 adapter/lock
→ Base latest completed main owner
→ 검증된 외부 근거
→ 추론 / 과거 대화 / 역사 문서
```

### Notion — `NOTION_HUMAN_FACING_CANON`

- 사람용 Project Home.
- 전체 Flow / Storyboard.
- 세계관·캐릭터·핵심 시스템 설명.
- 승인 Visual.
- 사람이 비교·수정하는 핵심 표와 전체 그림.
- Benchmark/Reference의 human-facing 요약.

### Repository — `REPOSITORY_STRUCTURED_CANON` + `REPOSITORY_RUNTIME_TRUTH`

- Markdown / JSON structured canon.
- game data / code / Scene / Resource / tracked asset.
- tests / CI / build·runtime evidence.

### Google Sheets — `MIGRATION_ONLY_UNTIL_REMOVAL`

기존 workbook은 고유 미이관 자료를 찾기 위한 compatibility source다. 신규 기획·승인·상태 관리의 기본 작업면이 아니다. Sheet-only 변경은 current canon으로 자동 승격하지 않는다.

## 3. 십보강호 보호 코어

- 1대1 10칸 일자형 논리 전장.
- 시작 공개 거리 2, 거리 0 `[밀착]`.
- 플레이어 화면은 절대 발판 번호보다 `거리 N` 중심.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 추론.
- AI는 플레이어의 미확정 계획·숨은 기술 배치·UI 의도 신호를 읽지 않는다.
- 덱·손패·드로우·장착 기술 제한 없음.
- 무공서가 아니라 현재 해금 기술을 수에 배치.
- 순차 `[합]`, 방어도, 회피, 중단, 강건, 복기.
- 성장은 판단을 대체하지 않고 파훼 선택지를 확장한다.

정확한 전투 수치·현재 구현 binding은 `docs/02_COMBAT_RULES.md`, 최신 Decision, 실제 runtime을 따른다.

## 4. Mutable state 단일 owner

다음 값은 stable router나 README에 current snapshot으로 복제하지 않는다.

```text
current main SHA
active PR / exact HEAD
current Work Mode
product stage
next package / next Decision
human/device validation state
```

변동 상태는 `ACTIVE_CONTEXT.md` + current structured JSON + GitHub live metadata + exact Project Notion을 fresh-read해 판정한다.

## 5. PLAN / BUILD / REVIEW

- `PLAN`: 의도·근거·대안·설계·Decision 확정.
- `BUILD`: 승인 범위만 구현. 코드·정책·계약 변경은 RED→GREEN을 사용한다.
- `REVIEW`: 전체 영향범위·untouched consumer·정본·test·Notion/repository readback을 적대적으로 검토한다.

`진행해`, `계속해`, `남은 작업 진행`은 이미 승인된 같은 계약의 continuation이다. 새 코어·범위·비용·파괴적 migration 권한을 자동으로 만들지 않는다.

## 6. Open PR / GitHub 안전

- 모든 pre-existing open/draft/ready PR은 기본 `READ_ONLY`다.
- 현재 승인 계약에서 latest completed main으로부터 만든 단 하나의 current-task PR만 exact HEAD·required checks·review/thread/ruleset 확인 후 merge할 수 있다.
- force push, direct main push, admin/ruleset bypass는 금지한다.
- merge 뒤 새 main을 다시 읽기 전에는 완료로 승격하지 않는다.

## 7. 이미지·Visual

새 이미지 생성/스타일 변경은 `canon review → text brief → 사용자 명시 승인 → 정확히 1개 결과 → 사용자 검토` 순서다. 승인 Visual만 exact Notion destination에 attach하고 readback한다. 현재 reference-only 또는 미승인 시안을 제품 자산으로 승격하지 않는다.

## 8. Implementation Reality Gate

```text
DISCOVERY
→ CALLABLE / IMPLEMENTED
→ ACTUAL INVOCATION / EXECUTION
→ DURABLE EFFECT / READBACK
→ RUNTIME / CLIENT / HUMAN OBSERVATION when required
```

파일 존재·CI 성공·Notion readback만으로 재미, 실제 기기, 접근성 사용자, 인간 이해를 PASS 처리하지 않는다.

## 9. 검증·완료

- 중요한 결정은 현재 상태 조사 + 최소 3개 실질 대안 + 장기 총비용/위험/되돌리기 비교를 거친다.
- 적대적 검토는 최소 5회 full loop이며, 5회 이후에도 새 blocking finding이 있으면 계속한다.
- `REQUIRED_WORK_REMAINING: 0`은 completion candidate일 뿐이다.
- implementation/canon/test/consumer/PR/sync/readback correction rescan과 final clean review 뒤에만 완료한다.
- 실행하지 않은 Windows visible, Android physical device, Human usability/player experience, release performance는 `NOT_RUN`으로 유지한다.

## 10. v4.5 r2 역사 보존

`TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`, `docs/planning-data/approved_20260811_integrated_work_contract_v4_5_r2_binding.json`, `docs/contracts/integrated-work-v4.5-r2/`는 재현·감사·rollback을 위한 **역사 증거**다. 삭제하거나 현재 작업계약으로 다시 승격하지 않는다.
