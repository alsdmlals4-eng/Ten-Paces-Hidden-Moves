# 십보강호 프로젝트 허브 시작 지점

## 기본 경로

```text
../../../AGENTS.md
→ ../../../docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 파일·테스트·GitHub metadata
→ repository human-facing owner when human-facing information is relevant
```

- 현행 작업계약: `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`.
- 이전 `TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`은 `SUPERSEDED_HISTORICAL_EVIDENCE`다.
- 프로젝트 Skill authority: `../../../skills/SKILL_REGISTRY.json`.
- 이 디렉터리의 `SKILL_REGISTRY.json`은 legacy compatibility reference이며 기본 자동 discovery 대상이 아니다.
- Base 동기화/채택의 current audit와 compatibility evidence는 `BASE_MAIN_SYNC_AUDIT.md`, `../../../docs/BASE_RULES_VERSION.md`에서 읽고, 새 L1+ 작업은 repository-owned work receipt를 먼저 만든다.

## 현재 상태 authority

이 파일은 **stable router**이며 mutable state를 저장하지 않는다.

```yaml
current_state_owner: ACTIVE_CONTEXT
current_pr_authority: GITHUB_PR_METADATA
current_human_workspace: REPOSITORY_HUMAN_FACING_CANON
current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME
google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL
current_work_contract: TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01
```

활성 PR·exact head·현재 Work Mode·제품 단계·구현 상태·승인 수·다음 package/Decision·device/Human evidence는 `ACTIVE_CONTEXT.md`, current JSON, GitHub live metadata, repository human-facing owners를 fresh-read해 판정한다. Notion은 migration/history input이다.

## 허브 책임

- `ACTIVE_CONTEXT.md`: 변동 상태와 현재 위험/다음 Gate.
- `DOCUMENTATION_MAP.md`: 질문별 current owner와 history/compatibility 경계.
- `DEVELOPMENT_GATES.md`: stable 진입/검증 조건.
- `ROADMAP.md`: 제품 장기 순서와 역사 checkpoint; current state는 Active Context가 우선.
- `HANDOFF.md`: 세션 스냅샷/history; current state owner가 아님.
- `../../../skills/SKILL_REGISTRY.json`: 현재 project-local Skill authority.

## 핵심 프로젝트 경계

- 10칸·시작 공개 거리2·3/3/4·공개 정보 추론·거리·합·대응·중단·복기가 핵심이다.
- AI의 미확정 플레이어 계획 열람은 금지한다.
- Windows/Android는 단일 게임 코어 + platform adapters를 사용한다.
- 사람용 전체 Flow/Visual/핵심 표와 구현/런타임 사실은 repository가 소유한다.
- Google Sheets는 신규 GDD 작업면이 아니라 고유 미이관 자료의 migration compatibility source다.
- 새 이미지 생성은 scoped single generation 후 user final lock 경계를 따른다.

## 역사·보류

- PR #7·Issue #13: T0 `STEP 0~13` 계보.
- PR #45: v6 재설계 이력.
- PR #65: ActionSelectionDock 구현 이력.
- PR #92: 초기 10권 제품 검증 계보.
- v4.8 r2와 v4.5 r2 integrated contract는 `SUPERSEDED_HISTORICAL_EVIDENCE`다.
- 16권 절초 개별 설계, 주요 비무 6~10 런타임, 천하제일인·비동기 기능, 최종 아트/오디오 폴리싱은 별도 current Decision 없이는 자동 실행하지 않는다.

자동 검증은 Windows visible Godot, 실제 Android, 접근성 사용자, Release 성능, 사람 플레이를 증명하지 않는다.
