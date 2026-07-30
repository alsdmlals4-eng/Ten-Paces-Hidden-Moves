# Base 규칙 적용 버전

## 1. 현행 기준

```yaml
base_repository: alsdmlals4-eng/Base
base_release: v9.3.0
release_state: BASE_RELEASED
release_commit: 30ca6c7b5f93521f0eb0eed42d01437cd43c50ae
release_evidence_commit: 462a86db192d23d0f386281a1eb54b0a8cbad62e
base_registry_path: skills/SKILL_REGISTRY.json
base_registry_sha256: 9847bb2b225c776ad7916930f0f48c490bc2a898bea8e02ea1fdd0e6caac60c1
execution_contract: templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v9.md
execution_contract_version: 9.1
release_line: Base v9.3
adopted_at: 2026-07-31
```

`base-v9.3.lock.json`의 `BASE_RELEASED` 상태와 release/evidence pin을 함께 사용한다. 단일 최신 `main` SHA를 임의로 pin으로 바꾸지 않는다.

## 2. 프로젝트 Application Binding

- 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`.
- 이관 기준 `main`: `bf60548cb461523ff655ce50951f1636808c5c02`.
- 정본 어댑터: `skills/PROJECT_BASE_ADAPTER.json`.
- 생성 route view: `skills/PROJECT_SKILL_SNAPSHOT.json`.
- Workflow Router: `.agents/skills/ten-paces-hidden-moves-workflow-router/SKILL.md`.
- 프로젝트 고유 Skill Registry: `skills/SKILL_REGISTRY.json`.
- `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`은 호환·이력 참조다.
- 제품 정본: v6 결정 원장과 등록된 분야별 책임 원본.
- Sheet ID: `1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0`.
- Sheet 상태: `SHEET_GITHUB_CONFLICT / BLOCKED / NO_AUTOMATIC_OVERWRITE`.

## 3. 권한 순서

```text
최신 사용자 지시
→ 프로젝트 AGENTS·보안·플랫폼 제약
→ 프로젝트 정본·실제 구현·열린 Issue·PR
→ PROJECT_BASE_ADAPTER.json
→ PROJECT_SKILL_SNAPSHOT.json
→ 프로젝트 Workflow Router
→ 고정된 Base v9.3
→ Vertical Slice v9 실행 계약
→ v6~v8·v9.1 자료는 Legacy/Compatibility 입력
```

Adapter·Snapshot·Router의 release pin, Registry hash, route가 불일치하면 실패 처리한다. 추론으로 다른 Base 버전이나 Skill 본문을 섞지 않는다.

## 4. 적용한 공용 운영 계약

- Work Mode: `PLAN / BUILD / REVIEW`.
- 기존 프로젝트 변경: `audit → reconcile → approval bundle → approved migration → verify`.
- 전체 Skill 자동 로드 금지.
- Registry trigger 기반 최소 Skill·Skill Mode 선택.
- L1 이상 `execution-report`.
- `reference-freshness`, baseline diff, 적대적 검토를 분리 수행.
- 실행하지 않은 runtime·device·accessibility·human 검증은 `NOT_RUN`.
- Base 공용 Skill 본문을 프로젝트에 복제하지 않는다.

### Base shared Skill 27개

1. `managing-project-intake-and-work-contract`
2. `managing-game-project-operating-system`
3. `managing-design-documents`
4. `evolving-project-discipline-skills`
5. `maintaining-project-context-and-handoff`
6. `analyzing-and-refining-game-concepts`
7. `designing-vertical-slices`
8. `orchestrating-deepseek-worktrees`
9. `reviewing-and-validating-project-changes`
10. `auditing-canonical-reference-freshness`
11. `designing-art-prompts-and-technique-cards`
12. `auditing-and-refining-ui-art`
13. `managing-base-change-proposals`
14. `identifying-project-core`
15. `establishing-project-core`
16. `running-adversarial-review-and-refinement`
17. `refactoring-with-contract-preservation`
18. `simplifying-skill-bodies`
19. `pruning-stale-and-nonfunctional-material`
20. `synchronizing-local-and-github-state`
21. `maintaining-long-running-task-continuity`
22. `governing-game-user-research-coverage`
23. `creating-user-learning-notes`
24. `building-project-visual-dashboards`
25. `diagnosing-game-engine-runtime-failures`
26. `governing-legacy-retention-and-archives`
27. `evaluating-godot-assets-and-plugins-before-creation`

### 프로젝트 고유 Skill 4개

- `ten-paces-game-design`
- `combat-ux-and-accessibility`
- `combat-implementation-handoff`
- `ten-paces-verification`

프로젝트 고유 Skill은 제품별 판단과 반례만 소유한다. Base shared route와 이름이 충돌하면 `PROJECT_LOCAL_THEN_BASE_SHARED` 우선순위를 따른다.

## 5. 문서·발행·아카이브 계약

- 한 질문에 활성 책임 원본 하나.
- 현재 본책에는 현재 계약만 설명한다.
- 과거 전문은 Git 이력·Change Log·Learning Log·승인된 archive에서 찾는다.
- PDF·DOCX·HTML 대시보드는 파생본이며 원본 권한이 없다.
- HTML 기획 대시보드는 기본 작업 surface가 아니다.
- 생성기가 없는 제품 문서와 Registry는 `source_only`다.
- archive는 현재 정본과 구현 권한을 갖지 않는다.
- 과거 자료를 이동·삭제·빈 파일화하지 않는다.

## 6. 프로젝트 고유 보호 범위

```text
data/
src/
scenes/
assets/
addons/
project.godot
```

Issue #63 운영체계 이관에서는 위 경로를 수정하지 않는다. 제품 단계는 `CONCEPT_APPROVAL`, Work Mode는 `PLAN`, 런타임 구현은 새 사용자 승인 전 금지다.

## 7. 십보강호 제품 계약

- 전장 10칸, 플레이어 4번·상대 7번, 거리 0 `[밀착]`.
- 라운드 `3수 → 3수 → 4수`.
- 합·연격·통합 방어도·공개 상태 기반 AI.
- AI는 플레이어의 미확정 계획을 읽지 않음.
- 덱·손패·드로우·장착 기술 제한 없음.
- 버티컬 슬라이스 앵커 결투 5개, 전체 필수 주요 비무 목표 10전.
- 무공서 16권, 1~10성, 10성 절초.
- T0 구현 사실과 최신 v6 설계 권한을 분리.

### 미래 서버·모바일 경계

- PC 우선, 차후 모바일.
- 10전 완료와 `[천하제일인]` 승리 후 `Champion Build Snapshot` 등록을 검토.
- 사용자는 자신의 캐릭터를 직접 조작·계획하고, 등록 상대는 AI가 조종.
- 자신의 현재·과거 등록 구성과 싸우는 자가 비무를 지원하는 방향.
- 서버·계정·랭킹·시즌·모바일 UI는 별도 Gate 전까지 구현하지 않음.

## 8. 검증 계약

필수 자동·정적 범위:

```text
adapter/schema/pin 검사
→ snapshot provenance·route count 검사
→ project operating system
→ reference-freshness
→ archive governance
→ Markdown·JSON·link 검사
→ baseline protected-path diff
→ adversarial repository-wide review
```

Godot runtime, Windows, 접근성 사용자, 성능, 사람 플레이는 실제 실행 전까지 `NOT_RUN`이다.

## 9. Sheet 동기화 계약

- 운영체계 PR 병합 전 Sheet 쓰기 금지.
- 병합된 `main` SHA를 다시 읽고 GitHub 정본과 Sheet 값을 대조한다.
- 사용자 편집·수식·검증·서식을 자동 덮어쓰지 않는다.
- 충돌이 있으면 `PROPOSED_SHEET_CHANGE` 또는 `BLOCKED`를 유지한다.
- 동기화 후에도 Sheet가 GitHub 정본을 자동 대체하지 않는다.

## 10. Legacy/Compatibility 기록

다음은 과거 채택을 재현하기 위한 자료이며 현행 실행 권한이 아니다.

- Legacy Base core: `alsdmlals4-eng/Base@c987647d01ad2baa028a16e03d85ddfc1572a727`.
- Legacy archive extension: `alsdmlals4-eng/Base@6a224e450f9420223c00921f3c56e051612f92ad`.
- Legacy prompt: `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v8.md`.
- 과거 동기화 설명: `6개 커밋·43개 변경 파일`.
- 상태: `SUPERSEDED_COMPATIBILITY / HISTORY_ONLY`.
- 재현 근거: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`.

과거 v8·v9.1 문자열이 존재한다는 사실만으로 현재 권한을 갖지 않는다. 활성 판단에는 Base v9.3 Adapter와 Vertical Slice v9 계약을 사용한다.
