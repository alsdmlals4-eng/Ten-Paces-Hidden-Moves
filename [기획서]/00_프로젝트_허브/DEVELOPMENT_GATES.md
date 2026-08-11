# 십보강호 개발 게이트

> 현재 상태 책임 원본: `ACTIVE_CONTEXT.md`  
> 현재 GitHub 상태: GitHub main / PR metadata / exact-head Actions  
> 현재 Sheet 상태: `00_프로젝트_허브`, `02_현재_확정결정`, `04_누락_충돌_감사`, `99_변경이력`  
> 현재 상세 로드맵: `../../../docs/04_ROADMAP.md`  
> 과거 v6 결정 인덱스: `../../../docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`

이 문서는 **Gate의 안정 조건만** 책임진다. 현재 PR, exact SHA, 현재 stage, 현재 work mode, 현재 완료/차단 판정 같은 변동 상태는 복제하지 않는다.

## 1. 상태 축

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING | PROTOTYPE_AND_VERTICAL_SLICE | PRODUCTION_APPROVAL | RELEASE_CANDIDATE_APPROVAL
work_mode: PLAN | BUILD | REVIEW
gate: APPROVED | APPROVED_WITH_CONDITIONS | REWORK | REPEAT_VALIDATION | HOLD | STOP | UNVERIFIED
implementation: IMPLEMENTED | PARTIALLY_IMPLEMENTED | PLANNED | PROPOSED_ONLY | DEFERRED | REMOVED | UNVERIFIED
```

파일 존재·Actions·Godot headless·Windows 실제 실행·Android 실제 기기·접근성·성능·사람 플레이는 서로 다른 증거다.

## 2. 현재 게이트

현재 상태를 이 문서에서 계산하거나 저장하지 않는다.

```yaml
current_state_owner: ACTIVE_CONTEXT
current_pr_authority: GITHUB_PR_METADATA
current_exact_head_evidence: GITHUB_ACTIONS
current_sheet_authority: GOOGLE_SHEET_00_02_04_99
gate_document_semantics: CONDITIONS_ONLY
base_remote_policy: LIVE_REFETCH_NO_AUTOMATIC_PROJECT_ADOPTION
```

새 작업과 post-merge 판정은 반드시 Base/project/Sheet를 fresh-read한 뒤 이 Gate 조건에 대입한다. 과거 exact SHA나 PR 번호를 현재 판정으로 재사용하지 않는다.

## 3. G0 — 권한·기준선

진입 조건:

- 최신 사용자 지시와 프로젝트 코어를 확인한다.
- Base 구조/main/open PR, project main/open PR, Sheet current truth를 fresh-read한다.
- 모든 작업 전에 벤치마킹·현업 조사를 수행하고 프로젝트에 맞는 요소만 취한다.
- 승인 Decision은 동일 ID로 GitHub 정본·구조화 계약·Sheet에 연결한다.
- 과거 v6 원장과 구현 계보는 역사/호환 증거로 보존하되 최신 current Decision보다 높게 취급하지 않는다.
- Base release/Adapter pin과 Base remote current observation을 구분한다.
- branch/head 상태와 main 상태를 별도 축으로 기록한다.

판정은 `ACTIVE_CONTEXT.md`, live GitHub metadata, Sheet readback에서 계산한다.

## 4. G1 — ActionSelectionDock 런타임 기준선

제품 구현·회귀에서 보호해야 할 조건:

- `[기초] [무공] [절초]` 출처와 무공서→해금 기술 계약을 보존한다.
- 전체 10수·`3/3/4`와 현재 묶음 편집 의미를 보존한다.
- 다중 슬롯은 `[전조] → [실행]` 연결 행동 블록을 보존한다.
- 진행 전 이동·제거와 확정 뒤 잠금 의미를 구분한다.
- 절초기세 예약·환불 등 현재 승인된 자원 규칙을 정본에서 읽는다.
- 자동 검증은 로컬 Windows visible/실물 입력/사람 이해도 검증을 대신하지 않는다.

현재 runtime의 `IMPLEMENTED_LEGACY`와 최신 `CURRENT_APPROVED_PLANNING` 차이는 별도 delta ledger에서 추적한다.

## 5. G2 — 기획 배치·정본·Sheet

필수 조건:

- 병합 main 상태와 활성 Draft 상태를 분리한다.
- 승인 Decision을 같은 ID로 Decision·planning JSON·분야 정본·Sheet에 연결한다.
- 모든 작업은 전용 RED→GREEN 회귀와 exact-head 검증을 갖는다.
- mutable current state는 `ACTIVE_CONTEXT.md`, GitHub metadata, Sheet current tabs에서만 읽는다.
- 최대 10건 또는 허용된 조기 체크포인트에서 전체 적대적 검토를 수행한다.
- 병합 후 새 main과 Sheet `SYNCED_TO_MAIN` readback을 기록한다.

## 6. G3 — 기획 완료

`PLANNING_COMPLETE` 후보가 되기 위한 필수 조건:

1. 현재 Vertical Slice/App Flow 범위가 책임 원본과 승인 Decision으로 추적 가능하다.
2. 제품 의미·수치 충돌은 기존 승인 또는 사용자 명시 결정으로 해결된다.
3. 핵심 재미를 수치 성장·관찰 정답화·등급 파밍이 대체하지 않는다.
4. Decision·분야 정본·planning JSON·Sheet ID가 일치한다.
5. `IMPLEMENTED_LEGACY`와 최신 기획 delta가 명시된다.
6. current-scope `P0/P1 = 0`이다.
7. exact-head CI가 성공하고 review thread가 0이다.
8. 이미지 생성물은 이 Gate의 선행조건이 아니다.

Stage 1은 먼저 `PLANNING_COMPLETION_CANDIDATE`를 만들고, 프로젝트 operating contract가 요구하는 사용자 명시 `기획 완료` 뒤에만 `PLANNING_COMPLETE` 전환이 가능하다.

## 7. G4 — 전체 검토 완료

`REVIEW_COMPLETE` 조건:

- G3의 `PLANNING_COMPLETE`가 성립한다.
- Base·프로젝트·Sheet 권위를 다시 대조한다.
- 변경 파일뿐 아니라 untouched 책임 원본·active consumers·derived JSON·cold-start routers·Sheet를 공격 검토한다.
- 핵심 시스템·보조 시스템·핵심 재미·목표 정렬을 검증한다.
- normal·failure·edge·counterexample·regression·information-leak·accessibility·responsive·save/commit 경계를 검토한다.
- 모든 review P0/P1을 해결하거나 명시적으로 승인된 예외로 닫는다.
- exact-head CI·threads0·GitHub/Sheet readback이 일치한다.
- 이미지 생성물은 이 Gate의 선행조건이 아니다.

사람 usability, local Windows visible, Android 실제 기기, 실물 입력을 수행하지 않았다면 `NOT_RUN`을 유지한다.

## 8. G5 — 이미지·애니메이션·HX

```yaml
PLANNING_COMPLETE does not require generated images: true
REVIEW_COMPLETE does not require generated images: true
image_generation_gate: AFTER_REVIEW_COMPLETE
visual_gate_result: VISUAL_COMPLETE_OR_NO_NEW_ASSET_REQUIRED
```

`REVIEW_COMPLETE` 뒤에만 시각 자산 생성 단계로 진입한다.

- `NEW_ASSET_REQUIRED_AFTER_REVIEW`: 승인된 텍스트 요구사항에 따라 생성·provenance 기록·검수한다.
- `NO_NEW_ASSET_REQUIRED`: 새 이미지를 만들지 않고 `VISUAL_COMPLETE_OR_NO_NEW_ASSET_REQUIRED`를 만족시킬 수 있다.
- 생성 결과는 최초에 `NOT_AN_ASSET`이며 별도 검수/승인 전 제품 자산이 아니다.
- 전장·HUD·무공 카드·합/복기 등 플레이어 판단 가독성이 장식보다 우선이다.
- 승인 자산·버전·용도·화면 위치·금지 요소·권리 provenance를 Sheet 71·72에 기록한다.
- 미승인 이미지나 chat exploration은 구현 권한을 만들지 않는다.

이 Gate는 **이미지를 무조건 만들어야 한다는 뜻이 아니다.** 필요성 자체가 승인된 텍스트 요구사항으로 판정되어야 한다.

## 9. G6 — `VERTICAL_SLICE_APP_FLOW_SHELL` Codex BUILD

대표 App Flow:

```text
App Root
→ Main
→ 시작 무공 선택/구성
→ Route·Node·Briefing
→ Combat
→ Review
→ Result·Reward·Retry/Continue
```

BUILD 진입 조건:

- `PLANNING_COMPLETE`.
- `REVIEW_COMPLETE`.
- `VISUAL_COMPLETE_OR_NO_NEW_ASSET_REQUIRED`.
- 별도 구현 Plan·Branch·RED→GREEN 회귀 계약.
- **사용자 명시 Build 승인**.
- `RunSession`·`SaveService` 책임 소유권과 save/retry/reward commit 계약.
- 전환 중 입력 잠금·저장 실패·보상 이중 commit·resume/retry 실패 경로 테스트 계획.

`PLANNING_COMPLETE`, `REVIEW_COMPLETE`, 이미지 생성, 제품 BUILD 승인은 서로 다른 Gate이며 서로를 자동으로 대신하지 않는다.

## 10. G7 — Vertical Slice·사람 검증

실행 뒤에만 증거로 승격할 항목:

- Windows 실제 Godot visible 실행.
- 키보드·마우스·게임패드 핵심 흐름.
- Android export·설치·실기기 touch/back/safe-area/lifecycle.
- 목표 viewport에서 responsive layout과 focus/터치 영역.
- 접근성 사용자 검증과 성능 프로파일.
- `STEP 14` 신규 플레이어 검증.
- 두 번째 상대·노드 반복 제작 증거.
- 고능력치가 잘못된 계획을 과도하게 구제하는지 사람/데이터 검증.

자동 CI가 성공해도 실행하지 않은 항목은 `NOT_RUN / UNVERIFIED`다.

## 10A — 초기 10권 자동 제품 검증의 역사 증거

```yaml
historical_evidence_snapshot: TEN_MANUAL_AUTOMATED_PRODUCT_VALIDATION
current_status_authority: ACTIVE_CONTEXT_AND_LIVE_EVIDENCE
```

다음은 당시 자동 제품 검증이 증명한 **역사 snapshot**이며 current mutable status가 아니다.

- Windows x86_64 Release export.
- export된 실행 파일 Windows CI runtime.
- 50개 성취도 제품 시나리오.
- 1280×800·1440×900·1920×1080.
- 합성 키보드·마우스와 자동 접근성.
- 성능 baseline.

역사 증거: `7494f50c48573168542781e007eeab6af11dda7d` / run `31068098197` / artifact `8954602789`.

당시 자동 증거는 로컬 Windows·실물 입력·접근성 사용자·Release 성능·Android 실제 기기·STEP14를 증명하지 않았다. 현재 여부는 live evidence에서 다시 판단한다.

## 11. `[보류]` / 현재 Vertical Slice 비차단 후보

다음 항목은 별도 Decision이 없는 한 첫 App Flow/Vertical Slice의 무조건 선행 조건으로 사용하지 않는다.

- 후보 15명 전체 제작.
- 16권 절초 개별 설계.
- 주요 비무 6~10 runtime.
- 천하제일인·비동기 기능.
- 스토어 출시·크로스 세이브·온라인 서비스.
- 최종 아트·오디오 폴리싱.

Android는 현재 기본 대상 플랫폼이므로 `모바일 포팅`을 장기 보류 항목으로 취급하지 않는다.

## 12. 검증 순서

```text
Base / Project / Sheet fresh-read
→ 벤치마킹·현업 조사
→ project-fit 판정
→ contract RED
→ 최소 변경
→ focused GREEN
→ reference-freshness
→ syntax·static
→ automated tests
→ 필요 시 Godot headless / Windows CI product evidence
→ normal·failure·edge·counterexample·regression
→ exact-head PR / Full / Product checks
→ review threads 0
→ merge
→ merged-main readback
→ Sheet readback
→ evidence-report
```

실행하지 않은 검증은 `NOT_RUN / UNVERIFIED`다.
