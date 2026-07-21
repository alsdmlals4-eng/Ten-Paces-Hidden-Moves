# 십보강호 결정 기록

## DEC-2026-001 — Base 기준 SHA

- 날짜: 2026-07-20
- 상태: `SUPERSEDED`
- 이전 결정: `Base@eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- 대체 결정: DEC-2026-008

## DEC-2026-002 — 기존 Markdown 본책 보존

- 날짜: 2026-07-20
- 상태: 채택
- 결정: `docs/01~11`을 schema v3 Markdown 단일 책임 원본으로 등록한다.
- 이유: 기존 본책에 프로젝트 고유 결정·수치·예외·미검증이 있다.
- 재검토: 구조화 데이터 필요·사용자 승인·보존 대조·발행 준비 시.

## DEC-2026-003 — 루트 `[기획서]` 허브

- 날짜: 2026-07-20
- 상태: 채택
- 결정: 운영 진입점·Registry는 `[기획서]`에 두고 기존 `docs` 본책을 연결한다.
- 이유: 현재 상태를 빠르게 찾으면서 기존 경로를 보존한다.

## DEC-2026-004 — 원본·발행 상태 분리

- 날짜: 2026-07-20
- 상태: 갱신
- 결정: 원본 생명주기·승인·구현·검증·발행 상태를 독립 관리한다.
- 발행 정책: `source_only / milestone_sync / always_sync`.
- PDF·DOCX·다이어그램은 파생본이며 독립 원본이 아니다.

## DEC-2026-005 — 선택 책임 분야

- 날짜: 2026-07-20
- 상태: 채택
- 결정: 게임 디자인, UX·UI·접근성, 개발·엔지니어링, QA, 프로덕션·PM, 통합검수를 선택한다.
- 재검토: 독립 본책·산출물·반복 작업이 생길 때.

## DEC-2026-006 — Base 제안 승인 흐름

- 날짜: 2026-07-20
- 상태: 채택
- 결정: 프로젝트 교훈은 `[수정제안서]` 제안 PR → 사용자 승인 → 별도 구현 PR을 따른다.
- 예외: 사용자가 특정 Base 변경을 직접 승인한 경우.

## DEC-2026-007 — 로컬·원격 상태 분리

- 날짜: 2026-07-20
- 상태: 채택
- 결정: 원격 변경과 사용자 Windows 작업본의 미커밋 상태를 자동 동일시하지 않는다.
- 현재 경로: `C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves`
- 재검토: 직접 Git 상태·파일·테스트를 확인할 때.

## DEC-2026-008 — 최신 Base 기준 갱신

- 날짜: 2026-07-21
- 상태: 채택
- 결정: `Base@ee265576da7f67d3278f8099dd97d4e714ef0651`을 기준선으로 사용한다.
- 비교: 이전 기준보다 155개 커밋·70개 변경 파일.
- 이유: Work Mode·통합 Skill·정본 최신성·정책 발행·Skill 무결성 계약을 적용한다.
- 증거: `BASE_MAIN_SYNC_AUDIT.md`.
- 재검토: Base SHA 변경 또는 새 정식 릴리스 채택 시.

## DEC-2026-009 — Work Mode·Skill 자동 라우팅

- 날짜: 2026-07-21
- 상태: 채택
- 결정: `PLAN / BUILD / REVIEW`와 Registry trigger로 최소 Skill·Skill Mode를 자동 선택한다.
- 사용자는 Skill 이름을 선언할 필요가 없다.
- L1 이상은 사용 이유·수행 내용·결과·증거·미검증을 보고한다.
- 금지: 전체 Skill 로드, 주 책임 분야 Skill 여러 개, 사용하지 않은 Skill 보고.

## DEC-2026-010 — 통합 Skill과 Legacy Alias

- 날짜: 2026-07-21
- 상태: 채택
- 결정: Base의 13개 통합 Skill을 공용 원본으로 참조하고 프로젝트 Skill 6개에 분화한다.
- 구형 Base Skill ID는 `skills/LEGACY_SKILL_ALIASES.md`에서만 현재 Skill·mode로 연결한다.
- 새 Entry Point·Registry·작업 계약에는 구형 ID를 사용하지 않는다.

## DEC-2026-011 — 정본 최신성·Skill 무결성 자동 검사

- 날짜: 2026-07-21
- 상태: 채택
- 결정: 정본·경로·ID·Schema·정책 변경 시 changed 파일뿐 아니라 expected-but-untouched 소비자를 검사한다.
- Skill은 Registry·SKILL.md·trigger·mode·Learning Log·entrypoint 연결을 검사한다.
- 현행 Entry Point의 `2수·두 행동·7개 기초 행동` 재등장을 차단한다.

## DEC-2026-012 — 전투 POC 현재 계약

- 날짜: 2026-07-21
- 상태: 채택
- 결정: 전장은 10칸, 라운드는 `3수 → 3수 → 4수`, 기초 행동은 8종이다.
- 구현 상태: STEP 0~10, TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6.
- 사용자 확인: STEP 0~10과 대상 지정.
- 미검증: 최신 RESPONSE 10.6 Windows 런타임.

## DEC-2026-013 — 기존 파일 비파괴 동기화

- 날짜: 2026-07-21
- 상태: 채택
- 결정: Base 동기화는 운영 파일 in-place 갱신과 새 감사·검증 파일 추가로 제한한다.
- 기존 제품 본책·백업·보류·Plan·자산은 삭제·이동하지 않는다.
- Cleanup은 별도 reconciliation·보존 대조·사용자 승인 뒤 수행한다.
