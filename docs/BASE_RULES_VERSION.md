# Base 규칙 적용·호환 버전

## 1. 현재 실행 권위

프로젝트 작업의 current authority는 다음 순서다.

```text
latest user instruction
→ AGENTS.md
→ docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
   / TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01
   (product safety baseline: TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01)
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
   + current planning JSON + GitHub live metadata + repository human-facing owners
→ current Decisions / domain owners / actual implementation
→ skills/PROJECT_BASE_ADAPTER.json compatibility/adoption evidence
→ latest completed Base main owner when progressive-load is required
```

`skills/PROJECT_BASE_ADAPTER.json`의 release pin은 **프로젝트가 과거 어떤 Base payload를 채택·검증했는지 재현하기 위한 compatibility/adoption evidence**다. 현재 Base remote main을 고정하거나 최신 Base owner 조회를 막는 권위가 아니다.

Base 동기화·채택 이력의 프로젝트 감사 진입점은 `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`다. 이 감사의 과거 SHA나 pin을 current Base remote truth로 승격하지 않는다.

## 2. 현재 호환 pin과 current-main 감사

```yaml
base_repository: alsdmlals4-eng/Base
base_release_version: 9.4.4
release_commit: 210ec78292fa12ed7563ba743b322dd36103ae4a
release_evidence_commit: bb61e68dc3028421b60c11b87ba2abd297ee6f78
release_finalization_commit: 5adc196c0185951f50e49ab5e51586eff8d60886
base_registry_sha256: 08f882d0c77339e8f7ff187c35b79501e0a2958ab1ff1c7aaa1c0ef8dbee45d6
current_base_main_observed_2026_09_01: 19355b7ef065a21d0f2b685c7d9be64a4a3970f8
current_main_adaptation_audit: "[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md"
current_work_receipt: docs/operations/2026-09-01_BASE_CURRENT_ADAPTER_WORK_CONTRACT_RECEIPT.json
adapter: skills/PROJECT_BASE_ADAPTER.json
shared_skill_policy: adapter_only
project_local_skills: 4
publication_policy: source_only
```

v9.4.4 pin은 재현 가능한 release/회귀 기준이고, `19355b7…`은 이번 감사 시점의 current Base `main` 관측값이다. 둘 모두 다음 작업의 permanent current SHA가 아니며, 다음 material 작업은 다시 fetch한다. v9.4.3과 2026-08-26 r5.4 binding의 Base SHA는 historical compatibility evidence로 보존한다.

## 3. Current workspace boundary

- 사람용 Project Home equivalent·Flow·Visual·사람이 수정하는 핵심 표: `REPOSITORY_HUMAN_FACING_CANON`.
- Markdown·JSON·game data·code·Scene·Resource·tests·runtime evidence: `REPOSITORY_STRUCTURED_CANON` / `REPOSITORY_RUNTIME_TRUTH`.
- Google Sheets: `MIGRATION_ONLY_UNTIL_REMOVAL`. 신규 GDD 입력·승인·current state authority가 아니다.

승인 Decision은 repository human-facing owner와 repository structured owner에 연결하고 destination readback한다. Notion/Sheet-only 값은 migration candidate 또는 history로만 취급한다.

새 채팅은 과거 대화를 필수 입력으로 요구하지 않고 Project GitHub + repository owners에서 current state를 재구성한다. Notion은 `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`에 따라 migration/history input이다.

## 4. Skill 구조

현재 프로젝트 고유 Skill authority는 `skills/SKILL_REGISTRY.json`이다.

프로젝트 고유 Skill 4개:

- `ten-paces-game-design`
- `combat-ux-and-accessibility`
- `combat-implementation-handoff`
- `ten-paces-verification`

Base 공유 Skill 본문을 프로젝트에 복제하지 않는다. 프로젝트 Adapter의 과거 route 목록은 채택/회귀 evidence이며, current Base 상세 절차가 필요하면 최신 Base Registry/owner를 progressive-load한다.

## 5. 프로젝트 고유 계약

Base가 아니라 십보강호가 소유한다.

- 1대1 10칸 일자형 논리 전장.
- 시작 공개 거리 2, 거리 0 `[밀착]`.
- 플레이어-facing UI는 `거리 N` 중심.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 합·연격·방어도·회피·중단·강건·복기.
- 무공서 → 현재 해금 기술 → 수 배치.
- 절초기세 `0~5` 예약·환불.
- 공개 상태 기반 상대 AI와 미확정 계획 열람 금지.
- Windows·Android 단일 공유 코어 + platform adapters.
- Godot code/data/Scene/asset/test/runtime state.

정확한 current 수치와 구현 상태는 domain canon + actual runtime을 읽는다.

## 6. r5.4 실행 경계

```yaml
current_project_contract: TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01
product_contract_baseline: TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01
previous_project_contract: TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01
previous_project_contract_status: SUPERSEDED_HISTORICAL_EVIDENCE
local_codex_orchestration: RETIRED_NOT_USED
codex_product_implementation: INDEPENDENT_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF_ONLY
powershell: LOCAL_GODOT_OR_VALIDATION_ONLY_NOT_CODEX_LAUNCHER
visual_generation: TEXT_BRIEF_THEN_SCOPED_SINGLE_GENERATION_THEN_USER_FINAL_LOCK
localization_minimum: [ko, en, ja, zh-*]
chinese_variant: UNKNOWN_UNVERIFIED
responsive_minimum: [pc_standard, pc_wide_or_ultrawide, mobile_landscape]
```

- 실제 Godot 제품 구현은 `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF` 뒤 Codex가 Project GitHub + repository owners를 독립 fresh-read한다.
- GPT→PowerShell→local Codex, project-specific CODEX_HOME, 과거 dedicated port checkpoint를 current readiness로 사용하지 않는다.
- 호환 가능한 host에서는 shared approved exact Godot pin + Godot AI 기본 포트 + exact project/editor/session identity를 기본으로 한다.
- 새 이미지 생성은 scoped single generation 뒤 user final lock이다. 2026-08-25 max-three 메모와 pre-generation approval은 history다.

### 6.1 current Base 작업 진입의 프로젝트식 적용

새 L1+ 작업은 프로젝트 canon과 실제 consumer를 먼저 읽은 뒤, repository-owned receipt로 다음을 남긴다.

```text
exact Project/Base source readback
→ task-appropriate benchmark/reuse evidence
→ scope-limited context·configuration hygiene inventory
→ stale/conflict correction 또는 명시적 defer
→ approval-bound work sequence
→ code/asset/document mutation
→ verification and reuse-learning handoff
```

- Base의 `PROJECT_START_CANON_CHECKLIST_REQUIRED`, `REUSE_FIRST_PREFLIGHT_REQUIRED`, `LEGACY_CONTEXT_CONFIGURATION_HYGIENE_REQUIRED`를 채택한다.
- 게임 규칙·UI·시각 자산처럼 player-facing package에는 기존 `TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01`의 10개 이상 비교 gate를 보존한다. 운영 문서·adapter-only 변경은 현재 Base owner와 exact project consumer의 `REUSED_EVIDENCE`로 한정하며, 무관한 게임 사례를 형식적으로 늘리지 않는다.
- Base의 feature contract 모듈화는 새/변경 기능에서만 `owner → contract → code/data/Scene → consumer → test`를 같은 변경 단위로 연결하는 방식으로 적용한다. 기존 전투 모듈을 일괄 재구성하지 않는다.
- conditional Blueprint/wireframe은 연결된 player-facing 시스템 변경의 이해·구현 gate가 실제로 필요할 때만 만든다. 이 운영계약 갱신 자체에는 새 화면 consumer가 없으므로 `NOT_APPLICABLE_WITH_REASON`이다.
- 화면이 실제로 바뀌는 경우에만 project-local runtime capture manifest/capture를 갱신한다. 이번 문서·adapter 작업은 제품 화면을 바꾸지 않아 새 Godot capture를 만들지 않는다.
- 정리는 날짜·파일명 기준으로 하지 않는다. `OBSOLETE_CANDIDATE`의 active reference/consumer 0, Git 복구 가능 삭제, readback이 모두 확인될 때만 삭제한다.

## 7. 과거 Base baseline

다음은 current Base authority가 아니라 **역사 회귀 증거**다.

```yaml
historical_base_core_sha: c987647d01ad2baa028a16e03d85ddfc1572a727
historical_archive_extension_sha: 6a224e450f9420223c00921f3c56e051612f92ad
historical_comparison_scope: "6개 커밋·43개 변경 파일"
historical_shared_skill_count_marker: "28개"
```

이 값은 과거 test/adapter/Decision을 재현하기 위해 보존한다. 새 작업의 current Base main으로 사용하지 않는다.

## 8. 검증 경계

- Base pin 존재 = 최신 Base 적용 완료가 아니다.
- connector/tool discovery = actual invocation PASS가 아니다.
- CI/자동 검증 = Windows visible, Android actual device, 접근성 사용자, Human play PASS가 아니다.
- 실행하지 않은 증거는 `NOT_RUN` 또는 `BLOCKED_UNVERIFIED`다.
- 과거 local executor process/port/session 존재 = current Godot/Codex readiness PASS가 아니다.

Base release·Registry·route·Adapter schema가 바뀌거나, 프로젝트 current contract/domain split이 바뀌면 compatibility impact를 다시 감사한다.

## 9. 역사 작업계약

- `TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`은 `SUPERSEDED_HISTORICAL_EVIDENCE`다.
- `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`은 `SUPERSEDED_HISTORICAL_EVIDENCE`다.
- 과거 Decision/JSON/normative body는 삭제하지 않고 재현·감사·rollback evidence로 보존한다.
- r5.4의 product safety boundary는 유지하되, current workspace authority는 `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`이다.
