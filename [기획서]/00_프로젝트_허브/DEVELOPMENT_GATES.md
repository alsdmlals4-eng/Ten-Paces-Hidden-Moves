# 십보강호 개발 게이트

> 현재 상태 책임 원본: `ACTIVE_CONTEXT.md`  
> 현재 GitHub 상태: GitHub main / PR metadata / exact-head Actions  
> 사람용 프로젝트 상태·Flow·Visual: repository human-facing owners
> legacy Google Sheet: `MIGRATION_ONLY_UNTIL_REMOVAL`  
> 현재 상세 로드맵: `../../../docs/04_ROADMAP.md`

이 문서는 **Gate의 안정 조건만** 책임진다. 현재 PR, exact SHA, 제품 stage, current work mode, 다음 package, 현재 완료/차단 판정 같은 mutable state는 복제하지 않는다.

## 1. 상태 축

```yaml
work_mode: PLAN | BUILD | REVIEW
gate: APPROVED | APPROVED_WITH_CONDITIONS | REWORK | REPEAT_VALIDATION | HOLD | STOP | UNVERIFIED
implementation: IMPLEMENTED | PARTIALLY_IMPLEMENTED | PLANNED | PROPOSED_ONLY | DEFERRED | REMOVED | UNVERIFIED
```

파일 존재·Actions·Godot headless·Windows 실제 실행·Android 실제 기기·접근성·성능·사람 플레이는 서로 다른 evidence layer다.

## 2. 현재 게이트

현재 판정을 이 문서에서 계산하거나 저장하지 않는다.

```yaml
current_state_owner: ACTIVE_CONTEXT
current_pr_authority: GITHUB_PR_METADATA
current_exact_head_evidence: GITHUB_ACTIONS
current_human_workspace: REPOSITORY_HUMAN_FACING_CANON
current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME
google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL
gate_document_semantics: CONDITIONS_ONLY
base_remote_policy: LATEST_COMPLETED_MAIN_PROGRESSIVE_LOAD
```

새 작업과 post-merge 판정은 latest Base/project main, current PR metadata, Active Context/current JSON, repository human-facing owners를 fresh-read한 뒤 이 Gate 조건에 대입한다. Notion/legacy Sheet는 migration 질문에서만 필요한 locator를 읽는다. 과거 exact SHA나 PR 번호를 current verdict로 재사용하지 않는다.

## 3. G0 — 권한·기준선

진입 조건:

- 최신 사용자 지시와 프로젝트 코어를 확인한다.
- latest Base owner, project main/open PR, current structured state, repository human-facing owners를 fresh-read한다.
- 현행 workspace contract `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`을 사용한다.
- 사람용 설명/Flow/Visual과 structured/runtime truth는 repository를 우선한다.
- Google Sheets는 신규 Decision/현재 상태의 sync surface가 아니라 migration compatibility source다.
- project Base v9.4.3 pin과 Base remote current를 구분한다.
- branch/head 상태와 main 상태를 별도 축으로 기록한다.
- 중요한 결정은 현재 조사 + 최소 3개 실질 대안 + 장기 비용/위험/rollback 비교를 거친다.

## 4. G1 — 전투 코어 보호

제품 구현·회귀에서 보호해야 할 조건:

- `[기초] [무공] [절초]` 출처와 무공서→해금 기술 계약.
- 전체 10수·`3/3/4`와 현재 묶음 편집 의미.
- 다중 슬롯 `[전조] → [실행]` 연결 행동 블록.
- 진행 전 이동·제거와 확정 뒤 잠금 의미.
- 절초기세 예약·환불 등 current 승인 자원 규칙.
- 공개 정보 기반 AI와 미확정 플레이어 계획 열람 금지.
- 자동 검증과 Human/device evidence 분리.

정확한 값은 `docs/02_COMBAT_RULES.md`, 최신 Decision, 실제 runtime에서 읽는다.

## 5. G2 — 정본·Decision·동기화

필수 조건:

- 병합 main과 active PR state를 분리한다.
- 승인 Decision을 repository Decision/planning JSON/domain owner에 동일 의미로 연결한다.
- destination readback 전에는 cross-surface sync 완료를 주장하지 않는다.
- mutable current state는 Active Context/current JSON/GitHub metadata/repository owners에서 읽는다.
- legacy Sheet ID/tab은 migration locator로만 사용한다.
- 변경이 검증 가능한 동작/계약이면 RED→GREEN과 exact-head evidence를 갖는다.

## 6. G3 — 기획 완료

`PLANNING_COMPLETE` 판정은 current user approval + Active Context/current planning contract에서 읽는다. 안정 조건은 다음이다.

1. Vertical Slice/App Flow 범위가 승인 Decision과 owner로 추적 가능하다.
2. 제품 의미·수치 충돌은 기존 승인 또는 사용자 명시 결정으로 해결된다.
3. 핵심 재미를 수치 성장·관찰 정답화·등급 파밍이 대체하지 않는다.
4. current Decision·분야 정본·planning JSON·필요한 repository human-facing projection이 충돌하지 않는다.
5. current-scope P0/P1이 해결되거나 명시적 blocker로 분리된다.
6. 실행하지 않은 Human/device evidence를 기획 완료와 혼합하지 않는다.
7. 이미지 생성물 자체는 기획 완료의 필수 선행조건이 아니다.

## 7. G4 — 전체 검토 완료

`REVIEW_COMPLETE` 조건:

- current 승인 범위와 actual implementation을 다시 대조한다.
- 변경 파일뿐 아니라 untouched owner·active consumer·derived JSON·cold-start router·test·repository destination을 공격 검토한다.
- 핵심 시스템·보조 시스템·핵심 재미·목표 정렬을 검증한다.
- normal·failure·edge·counterexample·regression·information-leak·accessibility/responsive/save/commit 경계를 적용 범위만큼 검토한다.
- minimum 5 full adversarial loops 뒤 새 blocking finding이 0이어야 한다.
- 사람 usability, Windows visible, Android actual device, 접근성 사용자, release performance를 수행하지 않았으면 `NOT_RUN`을 유지한다.
- 이미지 생성물 자체는 REVIEW_COMPLETE의 필수 선행조건이 아니다.

## 8. G5 — 이미지·애니메이션·Visual Asset

```yaml
PLANNING_COMPLETE does not require generated images: true
REVIEW_COMPLETE does not require generated images: true
image_generation_requires_explicit_user_request: true
visual_gate_result: APPROVED_ASSET_OR_NO_NEW_ASSET_REQUIRED
```

- 새 이미지 생성/스타일 변경은 `canon review → text brief → scoped single generation → 사용자 final lock → repository readback` 순서다.
- `NO_NEW_ASSET_REQUIRED`이면 새 이미지를 만들지 않는다.
- chat exploration/reference-only 결과는 별도 승인 전 제품 자산이 아니다.
- 전장·HUD·무공 카드·합/복기 등 플레이어 판단 가독성이 장식보다 우선한다.
- 승인 Visual은 repository source/provenance/consumer owner에 기록하고 destination readback한다.

## 9. G6 — 후속 제품 BUILD

첫 5전 Vertical Slice Phase I–VI의 현재 구현 여부는 Active Context + actual runtime에서 읽으며 이 stable Gate가 “미구현”으로 고정하지 않는다.

추가 제품 mutation의 BUILD 진입 조건:

- current user request가 해당 제품 변경을 명시적으로 승인한다.
- current operating contract와 관련 Decision이 범위를 허용한다.
- exact baseline, protected items, acceptance criteria, affected consumers, test/rollback 계획이 있다.
- 코드·정책·계약 변경은 RED→GREEN으로 시작한다.
- Windows/Android/Human evidence가 필요한 주장과 필요하지 않은 정적 변경을 구분한다.
- **사용자 명시 Build 승인** 없이 코어·주요 UX·경제·저장 의미를 확대하지 않는다.

기존 Phase I–VI 구현 완료를 미래의 모든 product mutation 승인으로 재사용하지 않는다.

## 10. G7 — Runtime·Device·Human 검증

실제 실행 뒤에만 evidence로 승격할 항목:

- Windows 실제 Godot visible 실행.
- 키보드·마우스·게임패드 핵심 흐름.
- Android export·설치·실기기 touch/back/safe-area/lifecycle.
- 목표 viewport에서 responsive layout과 focus/터치 영역.
- 접근성 사용자 검증과 성능 profile.
- 신규 플레이어 Human usability/player-experience validation.
- 핵심 mindgame에서 공개 정보가 충분하고 AI information leak가 없는지 사람/로그 검증.

자동 CI가 성공해도 실행하지 않은 항목은 `NOT_RUN / UNVERIFIED`다.

## 11. 역사 evidence

PR #65, PR #92, 과거 Windows CI run, 과거 Sheet sync, v4.5 r2 integrated contract는 당시의 역사/회귀 evidence로 보존한다. current state나 current operating authority로 재승격하지 않는다.

## 12. 검증 순서

```text
latest Base / Project / current state / repository owner fresh-read
→ current scope + authority
→ benchmark/trade study when decision-relevant
→ RED contract when executable
→ minimal GREEN
→ reference-freshness
→ static/automated/runtime as applicable
→ normal/failure/edge/counterexample/regression
→ exact-head PR checks + threads 0
→ merge
→ new main readback
→ exact repository destination readback when affected
→ remaining-work recalculation
→ final adversarial clean exit
```

실행하지 않은 검증은 `NOT_RUN / UNVERIFIED`다.
