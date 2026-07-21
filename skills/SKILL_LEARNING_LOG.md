# 십보강호 Skill Learning Log

실패, 중요한 결정, 재사용 가능한 교훈, 실제 검증 결과가 있는 Skill 호출을 기록한다. 한 번의 성공을 공용 강제 규칙이나 `VERIFIED` 지식으로 승격하지 않는다.

## 기록 형식

```yaml
date:
work_item:
work_mode: PLAN | BUILD | REVIEW
skill_id:
skill_mode:
selection: automatic | user-directed
trigger:
reason:
work_performed:
result:
evidence:
verification_status: PASS | PARTIAL | FAIL | NOT_RUN
exceptions:
user_feedback:
learning_state: OBSERVATION | HYPOTHESIS | PATTERN | VERIFIED
skill_change: NONE | PROPOSED | APPLIED
next_review_trigger:
```

## 2026-07-20 — Base schema v3 Governance foundation

```yaml
date: 2026-07-20
work_item: Issue #4 / PR #5
work_mode: PLAN → BUILD → REVIEW
skill_id: project-operations-and-handoff
skill_mode: route → context-update → handoff
selection: automatic
trigger: base-migration, cold-start
reason: 기존 본책을 보존하면서 프로젝트 운영 라우터와 Registry가 필요했다.
work_performed:
  - 루트 START_HERE와 프로젝트 허브 설치
  - Design·Skill Registry와 Development Gates 설치
  - Documentation Governance 검사와 Workflow 설치
result: Governance foundation 정적 검사 성공
evidence:
  - PR #5
  - documentation-governance Actions 성공
verification_status: PARTIAL
exceptions:
  - 사용자 Windows 작업본과 Godot 미검증
  - PDF·Manifest 미발행
user_feedback: Base 전체 구조를 프로젝트에 맞게 정리·최신화 요청
learning_state: OBSERVATION
skill_change: APPLIED
next_review_trigger: Base 기준 SHA 변경 또는 콜드 스타트 실패
```

## 2026-07-21 — 전투 POC STEP 0~10

```yaml
date: 2026-07-21
work_item: PR #7
work_mode: BUILD → REVIEW
skill_id: combat-implementation-handoff
skill_mode: implementation-contract → build → runtime-handoff
selection: automatic
trigger: godot, combat-engine, combat-ui, runtime-validation
reason: 승인된 10칸·3/3/4 전투 계약을 실제 Godot 컴포넌트와 판정으로 연결해야 했다.
work_performed:
  - 카드 UI·10칸 전장·캐릭터·배경·상단 HUD
  - 10수 행동 슬롯·8개 기초 행동·상세·로그·진행·배치
  - 이동 목적지·공격 방향과 묶음 판정
  - 강공·보법·시작 자원·대응 연계·자원 미리보기
result: STEP 0~10과 TARGETING 10.5 구현, RESPONSE 10.6 구현
evidence:
  - data/, scenes/, src/, tests/
  - 사용자 Windows F5에서 STEP 0~10·대상 지정 확인
  - Card Component Contract·Documentation Governance 성공
verification_status: PARTIAL
exceptions:
  - RESPONSE 10.6 최신 사용자 런타임 확인 대기
  - 접근성·성능·플레이테스트 미실행
user_feedback: 배경·HUD·행동 배치·슬롯 제한·대상 지정 정상 확인
learning_state: PATTERN
skill_change: APPLIED
next_review_trigger: RESPONSE 10.6 런타임 실패 또는 STEP 11 진입
```

## 2026-07-21 — Base 최신 main 전면 동기화

```yaml
date: 2026-07-21
work_item: Base ee265576 sync / PR #5 and PR #7
work_mode: PLAN → BUILD → REVIEW
skill_id: managing-game-project-operating-system
skill_mode: audit → reconcile-legacy → migrate → verify
selection: user-directed
trigger: existing-project, base-migration, legacy-reconciliation, operating-system-health
reason: 기존 Base 기준 이후 155개 커밋·70개 변경 파일을 누락 없이 프로젝트 운영체계에 반영해야 했다.
work_performed:
  - Base START_HERE·AGENTS·OPERATING_MODEL·WORK_MODE routing·Documentation Map·Registry 확인
  - 70개 변경 파일 전수 처리표 작성
  - Work Mode·자동 Skill·Skill Mode 라우팅 적용
  - Legacy Alias·정본 최신성·Skill 패키지 무결성·정책 기반 발행 계약 적용
  - 현재 전투 POC 상태로 루트·허브 문서 갱신
result: 운영 파일 동기화와 정적 검증 체계 확장 진행
evidence:
  - [기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md
  - docs/BASE_RULES_VERSION.md
  - AGENTS.md, START_HERE.md, README.md
verification_status: PARTIAL
exceptions:
  - 최종 Actions와 두 PR 체크리스트 갱신 진행 중
  - PDF·접근성·성능·Branch protection·최신 Godot 런타임 미검증
user_feedback: Base를 전부 자세히 읽고 누락 없이 프로젝트와 PR에 반영 요청
learning_state: PATTERN
skill_change: APPLIED
next_review_trigger: Base SHA 변경, stale reference 발견, final Actions 실패
```

## 현재 교훈

- Base 원격을 폴더째 복사하지 않고 Registry·Documentation Map으로 적용 책임을 분화한다.
- Active Context는 실제 구현과 사용자 확인을 반영해야 하며 초기 마이그레이션 상태에 머물면 안 된다.
- 정본 변경은 변경 파일뿐 아니라 untouched 소비자·테스트·파생본을 확인해야 한다.
- Workflow 존재·Actions 성공·Godot 런타임·Required Check 강제는 독립 상태다.
- 프로젝트 고유 전투 수치·용어·Godot 경로는 Base에 승격하지 않는다.
