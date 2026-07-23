# 십보강호 최종 적대적 검토 및 MVP 마감 계획

> 기준: PR #15 `agent/project-core-confirmation@ff3787325efff19894e66bde440895fb15cb6a66`
> 대상 base: PR #7 `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`
> Work Mode: `REVIEW → 최소 문서 BUILD → REVIEW`
> 최종 완료 가능 상태: 현재 `UNVERIFIED` — 사람 STEP 14·보조기기·Release 성능·Required Check 강제·전체 대화 접근성이 미확인이다.

## Global Constraints

- 최신 사용자 지시와 접근 가능한 대화 결정이 최우선이다.
- 프로젝트 코어·10칸·4/7·3/3/4·합·대응·중단·비치팅 AI 계약을 변경하지 않는다.
- `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`, 제품 Godot 테스트를 수정하지 않는다.
- 구형 파일은 감사 없이 삭제하지 않는다.
- 실제 실행하지 않은 검증은 `PASS`로 기록하지 않는다.
- 등록 문서와 Skill Registry의 `source_only` 발행 정책을 유지한다.
- PDF는 저장소 정본이 아닌 사용자용 파생본으로 별도 생성한다.

## Task 1. 기준선과 대화 결정 원장

- 해결할 finding: 접근 가능한 대화 범위와 저장소 기준이 섞일 위험.
- 사용자 가치: 승인·기각·보류 사항을 다시 뒤집지 않는다.
- 현재 상태: 현재 대화의 일부 이전 메시지가 컨텍스트에서 생략되어 있다.
- 목표 상태: 접근 가능한 결정과 `UNVERIFIED_CONTEXT`를 분리 기록한다.
- 수정할 책임 원본: 최종 감사 보고서.
- 수정 금지: 확인할 수 없는 과거 결정을 임의 확정하지 않는다.
- Red 검증: 최신 사용자 지시·PR #15·Issue #13·Active Context 간 상태표 작성.
- Green 구현: 결정 원장에 `CONFIRMED/LATEST_OVERRIDE/SUPERSEDED/REJECTED/DEFERRED/PROPOSED_ONLY/UNRESOLVED/UNVERIFIED_CONTEXT` 사용.
- 회귀 검사: 사용자 제외 범위가 누락 기능으로 재등장하지 않는지 확인.
- 완료 기준: 모든 핵심 결정에 책임 원본·실제 경로·검증 상태가 연결된다.
- 롤백: 보고서 커밋만 되돌린다.
- 예상 독립 커밋: `docs: record final adversarial review evidence`.

## Task 2. 운영 진입점과 프로젝트 상태 동기화

- 해결할 finding: `AGENTS.md`, `START_HERE`, 허브 문서가 `147a...`, 구 정합화 브랜치, `CORE_REVIEW_PENDING`을 현재 상태로 기록한다.
- 사용자 가치: 새 작업자가 올바른 코어·기준 SHA·다음 게이트에서 시작한다.
- 현재 상태: PR #15의 코어 문서와 운영 진입점이 충돌한다.
- 목표 상태: `659c57e7...`, PR #15, `CORE_CONFIRMED`, `REPEAT_POC`, `human_step14: NOT_RUN`으로 정렬한다.
- 수정할 책임 원본: `AGENTS.md`, `START_HERE.md`, 허브 `START_HERE.md`, `ROADMAP.md`, `DEVELOPMENT_GATES.md`, `HANDOFF.md`, `docs/BASE_RULES_VERSION.md`.
- 수정할 코드·데이터·자산: 없음.
- 연결 영향: README·Active Context·Documentation Map·PR #7/#15 설명.
- 수정 금지: 제품 규칙·수치·코드·데이터.
- Red 검증: 활성 운영 문서에서 `147a...`, `agent/pr7-canonical-skill-refresh`, 현재형 `CORE_REVIEW_PENDING` 검색.
- Green 구현: 최신 기준과 미검증 경계를 본문 자체에 반영.
- Refactor: 중복된 과거 작업 절차를 현행 상태·다음 행동으로 축약.
- 회귀 검사: Base SHA, Issue #13, 제품 보호 경로, 사람 증거 경계 유지.
- 완료 기준: 운영 진입점끼리 현재 상태 충돌이 없다.
- 롤백: 해당 문서 커밋을 되돌린다.
- 예상 독립 커밋: `docs: synchronize active project state`.

## Task 3. 정본 최신성 회귀 강화

- 해결할 finding: Governance run #466이 성공했지만 운영 진입점의 오래된 기준을 차단하지 못했다.
- 사용자 가치: 이후 코어 상태 변경이 일부 문서에만 반영되는 회귀를 조기에 차단한다.
- 현재 상태: `HANDOFF.md`가 strict current 목록에 없고 필수 토큰이 구 상태를 요구한다.
- 목표 상태: 최신 상태 토큰과 핵심 운영 파일을 freshness 설정에 등록한다.
- 수정할 책임 원본: `.github/reference-freshness.json`, `tests/test_project_governance.py`.
- 수정 금지: 자연어 문장 전체의 정확 일치 강제, 역사·백업 경로의 과거 표현 제거.
- Red 검증: 현재 설정이 `CORE_REVIEW_PENDING`을 필수 토큰으로 요구하고 HANDOFF를 검사하지 않는 사실 기록.
- Green 구현: current token을 `CORE_CONFIRMED/REPEAT_POC/659c...`로 갱신하고 HANDOFF·Gates·운영 Roadmap을 strict 소비자로 등록한다.
- Refactor: 오래된 기준은 파일별 required token과 content drift 검사로 관리한다.
- 회귀 검사: 허용된 상태 전이 문구 `CORE_REVIEW_PENDING → CORE_CONFIRMED`는 차단하지 않는다.
- 완료 기준: 최신 Governance가 성공하고 새 반례가 통과한다.
- 롤백: config/test 커밋을 되돌린다.
- 예상 독립 커밋: `test: guard current core and baseline references`.

## Task 4. 5회 적대적 검토와 최종 보고

- 해결할 finding: 동일 관점의 반복 검토·완료 과대 주장 위험.
- 사용자 가치: 수정 여부와 MVP 진입 판단을 증거로 이해한다.
- 공격 회차:
  1. 대화·요구사항·책임 범위.
  2. 논리·모순·판정 가능성.
  3. 경계 조건·데이터·호환성.
  4. 플레이어 경험·UX·접근성·운영.
  5. GitHub 최신성·통합 회귀·PR.
- 산출물: `docs/decisions/2026-07-24_FINAL_ADVERSARIAL_REVIEW_AND_MVP_CLOSEOUT.md`.
- finding 판정: `MUST_FIX/SHOULD_FIX/DEFER/REJECT/UNVERIFIED`.
- 완료 기준: 각 회차가 직전 finding·수정·최신 diff를 입력으로 사용한다.
- 롤백: 보고서 커밋을 되돌린다.
- 예상 독립 커밋: `docs: record final adversarial review evidence`.

## Task 5. PR·검증·PDF 마감

- 해결할 finding: PR #7 설명이 구 계약을 현재 상태로 기록하고 PR #15가 차단 결함을 알리지 않는다.
- 사용자 가치: GitHub 화면만 보고도 실제 범위·검증·병합 차단 사유를 이해한다.
- 수정 대상: PR #7·PR #15 제목/본문 또는 최종 댓글, 필요 시 PR #15 Draft 상태.
- 검증:
  - PR #15 base/head·changed files·protected path diff.
  - unresolved review thread.
  - 최신 Actions와 commit status.
  - Required Check 강제 가능 여부.
- PDF: 최종 보고 Markdown을 사용자용 DOCX→PDF로 변환하고 모든 페이지를 렌더 검수한다.
- Manifest: 저장소 정책이 `source_only`이므로 저장소 Publication Manifest를 임의 생성하지 않는다. 사용자용 파생본 해시는 최종 보고에 기록한다.
- 완료 기준: 원격 브랜치 head와 커밋 목록을 재확인하고, 남은 필수 `UNVERIFIED` 때문에 MVP 완료를 선언하지 않는다.
- 롤백: PR 메타데이터를 이전 본문으로 복원하고 보고서 커밋을 revert한다.
- 예상 독립 커밋: 없음 — PR 메타데이터 갱신과 사용자용 PDF 발행.

## 최종 판정 규칙

- 활성 stale 참조·실패 검사·필수 미검증이 남으면 `ACCEPT` 또는 `ACCEPT_WITH_FOLLOWUP`을 사용하지 않는다.
- 사람 STEP 14·보조기기·Release 성능·Required Check 강제·전체 대화 접근성이 확인되지 않으면 최종 판정은 최소 `UNVERIFIED`다.
- 문서·검사 자체에 수정이 더 필요하면 `REVISE`다.
- 외부 권한·원격 쓰기·필수 환경이 작업을 막으면 `BLOCKED`다.
