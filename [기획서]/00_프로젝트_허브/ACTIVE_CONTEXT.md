# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `REVIEW`.
- 단계: `REVIEW_IN_PROGRESS / PLANNING_COMPLETE / REVIEW_BUILD_APPLIED_AND_STATICALLY_VERIFIED`.
- 단일 제품 기준: `main@48c26c02d53fe49a34b831f5bcf0924ae36f5dbd`.
- 작업 branch: `agent/poc-planning-baseline-and-legacy-audit`.
- 최신 승인 기준: `docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md`.
- 전체 적대적 검토: `docs/decisions/2026-07-26_FULL_ADVERSARIAL_REVIEW_LOOP.md`.
- 승인 BUILD 기록: `docs/decisions/2026-07-26_ADVERSARIAL_REVIEW_BUILD_REMEDIATION.md`.
- 기획 완료 선언: `2026-07-26 USER_CONFIRMED`.
- 프로젝트 코어: `CORE_CONFIRMED`; 과거 `CORE_REVIEW_PENDING` 종료.
- 구현 계보: PR #7·Issue #13의 T0와 PR #41·#42의 과거 승인 기록을 보존한다.
- 코어 전투: 10칸·4/7·비공개 3/3/4, 순차 타격쌍 `[합]`, 공개 상태 기반 AI.
- 현행 런타임: `IMPLEMENTED_LEGACY`.
- 신규 플레이어 STEP 14: `NOT_RUN`.
- T1: `NOT_GRANTED`.

## 전체 적대적 검토 결과

- `TECHNICAL_REVIEW_PROPOSAL`: 14건 검수안으로 정리하고 planning BUILD 범위 승인.
- `USER_DECISION_REQUIRED`: 3건 모두 사용자 결정 완료.
- `BLOCKED_UNVERIFIED`: runtime·Godot·Windows·접근성·성능·사람 증거가 필요한 9건 유지.
- `NO_CHANGE`: 코어·PoC 범위·확장 경계 11건 보호.

## 사용자 결정

1. 패배 시 전투 직전 `RunState`를 복원해 같은 seed로 재도전한다.
2. 같은 전투 재도전은 `[영구재화]` 1→2→3개, 3 상한, 다른 전투 진입 시 초기화한다.
3. `[필중]`은 스택형이며 실제 회피를 우회한 유효 타격마다 1스택을 소비한다.
4. 주요 비무 보상은 자유6 / 지정 무공5+자유3 / 문파 무공3성이다.
5. 주요 비무5 진입 전 10성 경로는 집중32+최소 노드6 또는 자유24+고효율 노드14다.

## 승인된 REVIEW BUILD

- planning JSON에 정규화 card·tick ledger·patch·AI template·node·reward·grade·RunState 계약을 추가했다.
- `poc_run_state_contract.json`을 추가했다.
- CE-01~08과 사용자 결정 계약을 validator와 24개 단위 테스트로 고정했다.
- 로컬 증거: `24/24 PASS`, standalone validator `PASS`.
- 승인 BUILD 검증 기준 head: `eb06bd78316348bd3aa6027a8057575ee4dc9053`.
- 승인 BUILD PR Validation `#775`: 운영체계·reference freshness·planning 24개·기존 전투 계약·PowerShell parse 전체 `PASS`.
- 제품 `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`은 변경하지 않았다.

최신 PR head와 최신 CI run은 PR #45 본문·Actions를 추적 원장으로 사용한다.

## 다음 플레이 가능한 범위

주요 비무1은 튜토리얼, 2~5는 스테이지1 초반부다. 각 주요 비무 사이 중간 노드2~3개, 총 방문13~17개다. 기본 절초3종은 시작부터 사용 가능하고 무공별 10성 절초는 해당 무공 10성 도달로 열린다.

주요 비무6~8은 스테이지2, 9~10은 스테이지3 확장 데이터다. 천마·무림맹주 같은 천하제일인 히든 배틀은 본편 결말 필수가 아니다.

## 책임 원본

- 코어: `docs/01_GAME_DESIGN.md`.
- 전투: `docs/02_COMBAT_RULES.md`.
- 콘텐츠·지도·적: `docs/03_CONTENT_CATALOG.md` + `docs/planning-data/`.
- 성장: `docs/06_STARTING_FACTION_MASTERY_DATA.md`.
- PoC: `docs/05_COMBAT_POC_SPEC.md`.
- UI·QA·아키텍처·연출: `docs/07~10`.

## 구현 차이

main은 속공6·강공8·방어도4·내력4·명상2/1·`[준비]`+2·구형 강건과 단일 전투 상태를 구현한다. 신규 기획은 속공4·강공10·방어도5·내력5·명상1/1·`[강화]`×1.5·중단1회 강건·순차 연격·스택형 필중·RunState 유료 재도전을 요구한다.

## 최종 REVIEW 판정

- TRP-01~13: 승인 BUILD에 최소 반영하고 정적·참조·회귀 검증 완료.
- TRP-14: PR branch는 역사상 main보다 1커밋 뒤에서 갈라졌지만 현재 PR base가 `main@48c26c02d53fe49a34b831f5bcf0924ae36f5dbd`이고 `mergeable=true`다. main 전용 변경은 이번 BUILD와 겹치지 않아 별도 중복 merge commit 없이 PR 가상 병합이 base를 보존하는 것으로 재분류했다.
- 최종 판정: `PASS_WITH_FOLLOWUP`.
- Follow-up: 신규 Godot runtime·Windows·접근성·성능·사람 플레이는 `BLOCKED_UNVERIFIED / NOT_RUN`.

## 다음 작업

1. 사용자의 명시적 `검수 완료` 선언을 기다린다.
2. 선언 뒤에만 Codex 런타임 구현 인계와 P0 작업계획으로 전환한다.
3. 구현 뒤 별도 REVIEW에서 Godot·Windows·저장 migration·접근성·성능·사람 증거를 수집한다.
