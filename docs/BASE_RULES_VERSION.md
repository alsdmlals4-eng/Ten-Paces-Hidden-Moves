# Base 규칙 적용·호환 버전

## 1. 현재 실행 권위

프로젝트 작업의 current authority는 다음 순서다.

```text
latest user instruction
→ AGENTS.md
→ docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
   / TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
   + current planning JSON + GitHub live metadata + exact Project Notion
→ current Decisions / domain owners / actual implementation
→ skills/PROJECT_BASE_ADAPTER.json compatibility/adoption evidence
→ latest completed Base main owner when progressive-load is required
```

`skills/PROJECT_BASE_ADAPTER.json`의 Base v9.4.3 pin은 **프로젝트가 과거 어떤 Base payload를 채택·검증했는지 재현하기 위한 compatibility/adoption evidence**다. 현재 Base remote main을 고정하거나 최신 Base owner 조회를 막는 권위가 아니다.

Base 동기화·채택 이력의 프로젝트 감사 진입점은 `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`다. 이 감사의 과거 SHA나 pin을 current Base remote truth로 승격하지 않는다.

## 2. 보존된 Base v9.4.3 채택 증거

```yaml
base_repository: alsdmlals4-eng/Base
base_release_version: 9.4.3
release_commit: 7dd1a4f80388bc5faca767ff74a3eb32dc9d0ac8
release_evidence_commit: da33a350d61b8adc52df97fccc7001708a933370
release_finalization_commit: 0b7c94f38d959efc0fc9442274c60b2e268a3c97
adapter: skills/PROJECT_BASE_ADAPTER.json
shared_skill_policy: adapter_only
project_local_skills: 4
publication_policy: source_only
```

이 pin을 이유로 최신 Base의 운영 owner, Notion/repository domain split, Sheets migration-only 정책을 무시하지 않는다.

## 3. Current workspace boundary

- 사람용 Project Home·Flow·Visual·사람이 수정하는 핵심 표: `NOTION_HUMAN_FACING_CANON`.
- Markdown·JSON·game data·code·Scene·Resource·tests·runtime evidence: `REPOSITORY_STRUCTURED_CANON` / `REPOSITORY_RUNTIME_TRUTH`.
- Google Sheets: `MIGRATION_ONLY_UNTIL_REMOVAL`. 신규 GDD 입력·승인·current state authority가 아니다.

승인 Decision은 필요한 의미를 Notion human-facing owner와 repository structured owner에 연결하고 destination readback한다. 과거 Sheet-only 값은 migration candidate 또는 history로만 취급한다.

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

## 6. 과거 Base baseline

다음은 current Base authority가 아니라 **역사 회귀 증거**다.

```yaml
historical_base_core_sha: c987647d01ad2baa028a16e03d85ddfc1572a727
historical_archive_extension_sha: 6a224e450f9420223c00921f3c56e051612f92ad
historical_comparison_scope: "6개 커밋·43개 변경 파일"
historical_shared_skill_count_marker: "28개"
```

이 값은 과거 test/adapter/Decision을 재현하기 위해 보존한다. 새 작업의 current Base main으로 사용하지 않는다.

## 7. 검증 경계

- Base pin 존재 = 최신 Base 적용 완료가 아니다.
- connector/tool discovery = actual invocation PASS가 아니다.
- CI/자동 검증 = Windows visible, Android actual device, 접근성 사용자, Human play PASS가 아니다.
- 실행하지 않은 증거는 `NOT_RUN` 또는 `BLOCKED_UNVERIFIED`다.

Base release·Registry·route·Adapter schema가 바뀌거나, 프로젝트 current contract/domain split이 바뀌면 compatibility impact를 다시 감사한다.

## 8. 역사 작업계약

- `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`은 `SUPERSEDED_HISTORICAL_EVIDENCE`다.
- v4.5 r2 Decision/JSON/normative body는 삭제하지 않고 재현·감사·rollback evidence로 보존한다.
- current project operating contract는 v4.8 r2다.
