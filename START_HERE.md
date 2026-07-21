# 십보강호 시작 지점

이 문서는 새 채팅, 새 GPT, 새 Codex와 새 작업자가 `Ten-Paces-Hidden-Moves`를 시작할 때 사용하는 최상위 라우터다.

## 현재 기준선

- 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`
- 적용 Base: `alsdmlals4-eng/Base@ee265576da7f67d3278f8099dd97d4e714ef0651`
- Base 적용 기록: `docs/BASE_RULES_VERSION.md`
- Base 전수 감사: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`
- 운영체계 PR: `#5 agent/base-full-11-migration`
- 전투 POC PR: `#7 agent/t0-combat-poc-board`
- 현재 사용자 작업 경로: `C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves`

원격 변경과 사용자 로컬 파일은 자동 양방향 동기화가 아니다. 현재 작업 환경에서 Windows 경로를 직접 읽지 못하면 원격 저장소만 기준으로 변경하고 로컬 미커밋 상태는 `[미검증]`으로 남긴다.

## 가장 먼저 읽기

```text
최신 사용자 지시
→ START_HERE.md
→ AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ [기획서]/00_프로젝트_허브/START_HERE.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ DEVELOPMENT_GATES.md
→ ROADMAP.md
→ [기획서]/DESIGN_DOCUMENT_REGISTRY.json
→ 현재 책임 원본
→ SKILL_REGISTRY.json
→ 필요한 Base 통합 Skill·Skill Mode와 프로젝트 Skill
→ Issue·Plan·실행 순서
→ 실제 코드·데이터·자산·테스트
```

`Base를 전부 살펴본다`는 모든 파일과 Skill을 무작정 읽는다는 뜻이 아니다. Base의 `START_HERE → AGENTS → OPERATING_MODEL → WORK_MODE_AND_SKILL_ROUTING → DOCUMENTATION_MAP → SKILL_REGISTRY`를 따라 현재 요청에 적용되는 책임 원본과 변경 소비자를 빠짐없이 추적한다.

## Work Mode·Skill 자동 라우팅

- `PLAN`: 요구·근거·정본·실행 순서
- `BUILD`: 승인 범위 구현·갱신
- `REVIEW`: 적대적 검토·검증·판정

사용자는 Skill이나 Skill Mode를 선언할 필요가 없다. Registry trigger와 비사용 조건으로 필요한 최소 Skill을 자동 선택한다. L1 이상 작업은 사용한 Work Mode·Skill·Skill Mode, 이유, 수행 내용, 결과·증거와 미검증을 보고한다.

## 현재 제품 방향

십보강호는 `[강호낭인]`이 10칸 전장에서 상대의 수를 읽고 행동을 배치하는 1대1 무협 로그라이트다.

- 전장: 정확히 10칸
- 시작 위치: 플레이어 3번, 상대 8번
- 라운드: `3수 → 3수 → 4수`, 총 10수
- 10수 완료: 전투 종료가 아니라 다음 라운드 진입
- 판정 순서: `대응 → 속공 → 이동 → 일반 공격`
- 기초 행동 8종: 이동·보법·막기·회피·속공·강공·명상·태세
- 절초 기세: 최대 5칸
- 카드 비용: 행동 슬롯·기력·내력
- 덱·손패·행동력 없음
- 데모: 1~5전, 5전째 예선 결승
- 전체판: 10전

세부 책임 원본:

- 전체 경험: `docs/01_GAME_DESIGN.md`
- 전투 규칙: `docs/02_COMBAT_RULES.md`
- UI: `docs/07_COMBAT_UI_SPEC.md`
- 검증: `docs/08_TEST_CHECKLIST.md`
- 시스템 경계: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- 연출: `docs/10_COMBAT_PRESENTATION_PLAN.md`
- 구현 데이터·코드: `data/`, `src/`, `scenes/`, `tests/`

## 현재 구현 상태

- STEP 0~10 전투 UI·카드·10칸 전장·HUD·행동 슬롯·배치·판정 구현
- TARGETING 10.5 이동 목적지·공격 방향 지정 구현
- RESPONSE 10.6 막기·회피·태세 연계 구현
- RESOURCE PREVIEW 10.6 행동 배치 즉시 자원 예상치 구현
- 사용자 Windows Godot에서 STEP 0~10과 대상 지정까지 확인
- RESPONSE 10.6 최신 통합 런타임 확인은 대기

현재 상태의 상세 원본은 `ACTIVE_CONTEXT.md`와 PR #7이다.

## 책임 원본·발행

- 서술 중심 기획은 Markdown, Registry·Manifest·상태·ID·경로·게임 데이터는 JSON으로 관리한다.
- 한 질문에 현행 책임 원본은 하나다.
- 기존 `docs/01~11`, `docs/[백업]`, `docs/[보류]`, Plan과 Git 이력을 삭제하지 않는다.
- 문서 발행 정책은 `source_only / milestone_sync / always_sync` 중 하나다.
- PDF·DOCX·다이어그램은 파생본이며 독립 원본이 아니다.
- PDF·Skill Map 발행은 도구·렌더·사람 검수 전까지 `MIGRATION_PENDING`이다.

## 현재 운영 상태

```text
Base 최신 main 감사              완료
70개 변경 파일 처리표             완료
Work Mode·Skill 라우팅 동기화      진행 중
Governance·최신성·Skill 무결성      검증 중
PDF·Manifest 발행                  MIGRATION_PENDING
Branch protection Required Check   미확인
RESPONSE 10.6 Windows 런타임        사용자 확인 대기
```

파일 존재, 정적 검사, Actions 성공, 실제 런타임, 사람 시각 검수, Required Check 강제를 서로 다른 상태로 기록한다.
