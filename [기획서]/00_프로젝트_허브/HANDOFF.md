# 십보강호 인수인계

> 현재 상태 원본: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`

## 첫 행동

1. 루트 `AGENTS.md`를 읽는다.
2. `ACTIVE_CONTEXT.md`와 `DOCUMENTATION_MAP.md`를 읽는다.
3. PR #7 `agent/t0-combat-poc-board`의 HEAD `659c57e7...`와 현재 작업 branch의 ancestry를 확인한다.
4. Issue #13의 승인 규칙과 `docs/02_COMBAT_RULES.md`를 대조한다.
5. 프로젝트 코어는 `docs/01_GAME_DESIGN.md`, 코어 확정 과정은 `docs/decisions/2026-07-23_PROJECT_CORE_DECISION_RECORD.md`에서 읽는다.
6. Registry trigger로 최소 Skill·Skill Mode를 선택한다.
7. 구현 작업이면 실제 `data/`, `src/`, `scenes/`, `assets/`, `tests/`를 확인한다.

## 현재 기준

- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 구현 PR: #7 `agent/t0-combat-poc-board`.
- 기준 SHA: `659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 최신 승인: Issue #13 STEP 12~14.
- 코어 확정 PR: #15 `agent/project-core-confirmation`.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.

## 완료된 구현

- STEP 0~13.
- 10칸·4/7·거리 3·밀착.
- 3/3/4·기초 행동 8종·절초 3종.
- 합·방어·회피·필중·중단·강건.
- 공개 상태 기반 최소 AI.
- 승패·무승부·완전 재시작.
- 순차 연출·키보드·모션 감소·음향 제어.

## 완료된 운영·코어 작업

- Base 활성 Skill 25개 route와 프로젝트 고유 Skill 4개 유지.
- board schema 16·Base SHA·Skill 집합 freshness 계약.
- PR #14 정본·Skill·Governance 최신화를 PR #7에 병합.
- PR #7 HEAD를 `659c57e7...`로 고정.
- 프로젝트 코어를 `CORE_CONFIRMED`로 기록.
- T1 범위를 2개 스타일·성향이 다른 상대 3명·전투 3회·수평 보상으로 제한.
- 실제 사람 STEP 14 전에는 `REPEAT_POC`와 `T1_NOT_GRANTED` 유지.

## 현재 PR #15 마감 작업

- 활성 운영 진입점의 기준 SHA·코어 상태·다음 게이트 동기화.
- 5회 적대적 검토와 final finding 기록.
- Governance가 상태 전파 누락을 다시 허용하지 않도록 freshness 계약 보강.
- PR #7·#15 설명과 실제 diff·검증 경계 정렬.
- 사용자용 PDF는 저장소 `source_only` 정책과 분리해 파생본으로 발행.

## 미검증

- 현재 대화의 일부 이전 메시지: `UNVERIFIED_CONTEXT`.
- 실제 사용자 STEP 14 규칙 이해·성향 발견·재도전 행동.
- 실제 보조기기 사용자 사용성.
- 주관적 음향·모션 읽기성.
- 외부 POC 표본.
- 목표 장치 Release 성능.
- Branch protection Required Check 강제.
- 사용자 로컬 미커밋 파일과 원격 차이.

## 보호 범위

PR #15 마감에서는 다음을 변경하지 않는다.

- `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`.
- 제품 Godot 런타임 테스트.
- 사용자 로컬 변경.
- 백업·보류·과거 Plan·Git 이력.
- T1 이후 성장·세력 가설의 고유 정보.

force push·reset·rebase를 금지한다.

## 다음 작업

1. PR #15 최신 head에서 Governance·Card/Combat Contract를 확인한다.
2. `659c57e7...` 대비 제품 보호 경로 변경 0건을 재확인한다.
3. PR #7과 PR #15 본문을 현재 STEP 0~13·코어·사람 증거 경계로 정렬한다.
4. PR #15는 문서·검증 결함이 없을 때만 PR #7에 통합한다.
5. 결정적 복기와 읽을 수 있는 라이벌 성향을 별도 승인 계약으로 준비한다.
6. 동일 SHA의 STEP 14 신규 플레이어 5명 발견형 테스트를 실행한다.
7. 결과로 `T1_GREENLIGHT_REVIEW` 또는 `REPEAT_POC`를 판정한다.

## 중단 기준

- PR #7 HEAD 또는 기준 SHA가 예상과 다르다.
- 보호 경로에 예상 밖 변경이 있다.
- Actions 실패 원인을 확인하지 않았다.
- 사람 증거 없이 STEP 14·T1을 통과 처리하려 한다.
- 읽을 수 있는 라이벌 성향을 AI 치팅이나 근거 없는 무작위로 구현하려 한다.
- 구형 PR의 고유 정보 보존을 확인하지 않고 닫거나 병합하려 한다.
