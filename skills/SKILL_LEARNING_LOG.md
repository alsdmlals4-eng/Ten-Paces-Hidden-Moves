# 십보강호 Skill Learning Log

실패, 중요한 결정, 재사용 가능한 교훈과 실제 검증 결과가 있는 Skill 호출을 기록한다. 한 번의 성공을 공용 강제 규칙이나 `VERIFIED` 지식으로 승격하지 않는다.

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

## 2026-07-20 — Governance foundation

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
  - 루트 START_HERE와 프로젝트 허브
  - Design·Skill Registry와 Gates
  - Documentation Governance Workflow
result: 초기 Governance foundation 정적 검사 성공
evidence: PR #5
verification_status: PARTIAL
exceptions:
  - 현재 이 로컬 Skill ID는 Base intake·context/handoff로 통합되어 Legacy Alias에서만 유지
  - 당시 Godot·발행 미검증
learning_state: OBSERVATION
skill_change: APPLIED
next_review_trigger: Base 기준 또는 콜드 스타트 변경
```

## 2026-07-21 — 전투 POC STEP 0~10.6

```yaml
date: 2026-07-21
work_item: PR #7
work_mode: BUILD → REVIEW
skill_id: combat-implementation-handoff
skill_mode: implementation-contract → build → runtime-handoff
selection: automatic
trigger: godot, combat-engine, combat-ui, runtime-validation
reason: 승인된 10칸·3/3/4 전투 계약을 Godot 컴포넌트와 판정으로 연결해야 했다.
work_performed:
  - 카드 UI·10칸 전장·배경·상단 HUD
  - 10수 행동 슬롯·기초 행동 8종·배치
  - 이동 목적지·공격 방향·묶음 판정
  - 강공·보법·대응 연계·자원 미리보기
result: STEP 0~10, TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6 구현
evidence:
  - data/, scenes/, src/, tests/
  - 사용자 Windows STEP 0~10·대상 지정 확인
verification_status: PARTIAL
exceptions:
  - RESPONSE·RESOURCE PREVIEW 10.6 최신 사용자 런타임 대기
  - 접근성·성능·플레이테스트 미실행
learning_state: PATTERN
skill_change: APPLIED
next_review_trigger: STEP 10.6 런타임 실패 또는 STEP 11
```

## 2026-07-21 — Base latest main 전면 동기화

```yaml
date: 2026-07-21
work_item: Base ee265576 / PR #5·#7
work_mode: PLAN → BUILD → REVIEW
skill_id: managing-game-project-operating-system
skill_mode: audit → reconcile-legacy → migrate → verify
selection: user-directed
trigger: existing-project, base-migration, operating-system-health
reason: 이전 기준 이후 155개 커밋·70개 변경 파일을 누락 없이 반영해야 했다.
work_performed:
  - Base canonical 운영 문서·13개 Skill 확인
  - 70개 변경 파일 전수 처리표
  - Work Mode·자동 Skill 라우팅·Legacy Alias
  - 정본 최신성·Skill 무결성·접근성·성능 계약
result: Base 공용 계약과 현재 전투 상태를 운영 구조에 반영
evidence:
  - BASE_MAIN_SYNC_AUDIT.md
  - docs/BASE_RULES_VERSION.md
verification_status: PASS
exceptions:
  - 로컬 Godot 최신 기능·발행·접근성·성능·Branch protection 미검증
learning_state: PATTERN
skill_change: APPLIED
next_review_trigger: Base SHA 또는 canonical contract 변경
```

## 2026-07-22 — 가지치기·통합·적대적 개선

```yaml
date: 2026-07-22
work_item: Base operating-system optimization / PR #5·#7
work_mode: PLAN → BUILD → REVIEW
skill_id: managing-game-project-operating-system
skill_mode: audit → reconcile-legacy → migrate → verify
selection: user-directed
trigger: prune, simplify, refactor, adversarial-review, no-function-loss
reason: Base 기능을 유지하면서 로컬 중복·가짜 발행 상태·과도한 초기 컨텍스트를 제거해야 했다.
work_performed:
  - Base 공유 13개 유지, 로컬 Skill 6개를 고유 4개로 축소
  - 제거된 로컬 Skill을 Base Skill과 Legacy Alias로 승계
  - Skill Map·가짜 Manifest 제거, Registry source_only 전환
  - 컨셉·벤치마크·freshness·회귀 테스트 통합
  - 중복 checker 제거, cold-start 문서 축소
  - Design Registry와 Schema를 대조하고 정책 충돌 수정
  - 발행 정책 승격 시 generator 존재 검사 추가
result: 기능 책임을 유지한 채 운영 파일·읽기 경로·검사 구조 간소화
evidence:
  - de9ad6e…→optimized head compare: 운영 파일만 변경
  - Documentation Governance 실패 4회에서 누락 경로 복구
  - 수동 적대 검토에서 Schema 충돌 발견·수정
  - operating-system·freshness·Skill integrity·unittest 성공
verification_status: PASS
exceptions:
  - PR #7 최종 재동기화와 Actions 확인 진행
  - Godot 최신 기능·PDF·접근성·성능·플레이테스트·Branch protection 미검증
user_feedback: 기능 약화 없이 간결하고 명확한 구조 요청
learning_state: PATTERN
skill_change: APPLIED
next_review_trigger: 로컬 Skill 증가, 발행 정책 승격, stale path 재등장, Base SHA 변경
```

## 현재 교훈

- Base 공용 절차를 로컬 Skill로 복제하지 않는다.
- 프로젝트 로컬 Skill은 고유 규칙·경로·검증에만 둔다.
- 발행 정책은 생성기·폰트·Manifest·렌더가 실제로 존재할 때만 승격한다.
- Registry 본문과 JSON Schema를 함께 검증한다.
- 삭제는 기능 승계·Legacy Alias·복구·자동 재등장 차단을 함께 제공한다.
- changed 파일뿐 아니라 untouched 소비자와 Entry Point를 검사한다.
- Workflow 존재·Actions 성공·Godot 런타임·Required Check는 독립 상태다.
