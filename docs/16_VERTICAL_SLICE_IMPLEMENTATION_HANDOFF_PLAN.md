# 십보강호 · 첫 Vertical Slice 구현 Handoff 계획

> Planning Complete Decision: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`  
> 상태: `PLANNING_COMPLETE_USER_APPROVED`  
> 구현 권한: `false` — 사용자의 별도 구현 요청 + current Entry Gate 확인 전 변경 금지

이 문서는 **기획 완료 뒤 구현을 시작할 때 무엇을 다시 읽고 어떤 순서로 묶을지**를 정리하는 handoff다. 제품 코드·Scene·runtime data 자체를 변경하지 않는다.

## 1. 구현 전 fresh-read Gate

구현 요청이 들어오면 과거 세션의 SHA/PR 상태를 그대로 사용하지 않는다.

1. Project `main`과 열린 PR을 다시 조회한다.
2. exact Project Notion Home 및 `09~13` 기획 페이지를 다시 읽는다.
3. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`와 `docs/planning-data/current_user_planning_status.json`을 대조한다.
4. `docs/planning-data/current_entry_gate_20260808.json`과 current operating state를 다시 읽는다.
5. 진행 중인 다른 PR/브랜치는 수정하지 않는다.
6. 구현 권한과 플랫폼 검증 ceiling을 fresh truth 기준으로 다시 판정한다.

`current_user_planning_status.json`과 최신 Planning Complete Decision은 2026-08-20 사용자 명시 `기획완료`의 최신 user-directed planning gate다. 오래된 Review Ready 문구가 남아 있으면 이 최신 Decision/Notion current truth와 대조해 live router를 교정한다.

## 2. 구현 기준선

다음 기획을 구현 입력으로 사용한다.

- `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`
- `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`
- `docs/14_VERTICAL_SLICE_LOADOUT_ROUTE_BUDGET_WIREFRAME.md`
- `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`
- `docs/decisions/2026-08-20_VERTICAL_SLICE_PLANNING_COMPLETE_DECISION.md`
- `docs/planning-data/current_user_planning_status.json`

전투 규칙과 무공/기술은 해당 분야 정본을 우선한다.

## 3. 보호 대상

구현 중 다음을 임의로 재설계하지 않는다.

- 논리 10칸 전장.
- `3수 → 3수 → 4수` 계획.
- 플레이어/적 현재 계획 비공개.
- AI가 플레이어 미확정 입력을 읽지 않는 anti-cheat.
- 거리·합·대응·중단·복기.
- 시작 무공 6중4.
- 5개 주요 비무 슬롯 × 후보 3명.
- 비무 사이 정확히 2개의 Route 방문.
- 다음 상대는 Result 뒤 Route 전에 선확정.
- Combat Review는 Combat Overlay, Duel Result는 별도 Scene.
- `[관찰]`의 플레이어 전용 권위.
- 기존 10권 무공 재사용 우선.
- aggregate 비전투 시간 예산이 화면별 개별 상한보다 우선.

## 4. 권장 구현 순서

### Phase I · Run/App Flow Shell

`Main → Setup → Intro → Briefing → Combat → Review → Result → Route → 다음 Briefing → 5전 완료` 상태 전이를 먼저 연결한다.

완료 기준:
- 5전 경로가 placeholder 텍스트/기존 런타임 전투를 사용해도 상태 손실 없이 끝까지 왕복 가능.
- Scene 경계가 기획과 일치.
- 재시작/이어하기 대상 상태가 명시됨.

### Phase II · RunState와 후보 15명

- 후보 15명의 슬롯/working name/loadout/습관/반례/Briefing 훅을 data-driven으로 연결.
- 적 AI는 승인된 공개 정보만 사용.
- 후보 1명 때문에 새 전투 판정 시스템을 만들지 않음.

### Phase III · Setup / Briefing

- 시작 6중4 선택.
- 상대 공개 정보와 플레이어 현재 상태 표시.
- 실제 잠금 계획·AI 가중치·정답 대응·확률 명중률은 표시 금지.

### Phase IV · Review / Result

- Combat Review Overlay는 이미 발생한 사건 1~3개의 인과를 보여 준다.
- 다음 행동을 자동 추천하지 않는다.
- Result Scene에서 승패·등급·보상·다음 상대 선확정을 처리한다.

### Phase V · Route 8노드

- Growth/Recovery → Information/Preparation 순서를 네 구간에서 보존.
- 성장 경로는 집중 `+6`, 자유 `+14` 경로를 보존.
- 회복 `최대 체력 25% + 기력1 + 내력1`은 `REVERSIBLE_BALANCE_SEED`; 별도 검증 전 하드 확정값으로 취급하지 않는다.

### Phase VI · Completion Summary

- 5전 종료 뒤 이번 회차의 주요 선택·읽기·성장 변화만 요약.
- 장황한 세계관 설명보다 플레이어가 바꾼 계획과 기억점을 우선.

## 5. TDD / 정적 검증 계약

구현 전/중 최소 다음을 자동 검증한다.

- `LOADOUT_LEGALITY`
- `RESOURCE_PAYABILITY`
- `SLOT_LEARNING_FIT`
- `BUILD_DIVERSITY`
- `ROUTE_BUDGET`
- AI anti-cheat / hidden-plan regression
- Result에서 다음 후보 선잠금
- Route가 후보를 reroll하지 않음
- Review와 Result Scene 역할 분리
- 시작 6중4 선택 보존

새 기능마다 실패 테스트를 먼저 만들고 최소 변경으로 통과시킨다.

## 6. 밸런스 사전검증

15명 × 플레이어 원형 6종의 deterministic scenario matrix를 실행할 수 있는 계약을 유지한다.

조사 trigger:
- 동일 슬롯 후보 간 승률 차이 `>15%p`.
- 합법 플레이 원형 하나가 슬롯 전체에서 `<25%`.
- 한 원형이 모든 후보에서 `>80%`.
- Slot 1 평균 라운드가 Slot 5보다 김.
- Recovery/Growth 선택 중 하나가 모든 조건에서 지배적.

이 값은 자동 밸런스 FAIL 공식이 아니라 원인 조사 trigger다.

## 7. Visual / UX 단계

현재 다음 phase는 `VISUAL_UX_REQUIREMENT_AND_REFERENCE_REVIEW`다.

- 기존 Notion 비주얼 바이블·전투 Flow·승인 레퍼런스를 먼저 확인한다.
- 최종 게임에 사용할 UI/캐릭터/전장 시각 요구를 화면 역할별로 정리한다.
- 새 이미지 생성은 사용자가 명시적으로 요청할 때만 수행한다.
- 생성·승인된 시각자료가 있다면 구조화/레이어화/재사용 후보를 분리하여 구현 입력으로 사용한다.

## 8. 검증 ceiling

Planning Complete 이후에도 다음은 현재 PASS가 아니다.

- 대량 밸런스 시뮬레이션: `NOT_RUN`.
- Human 재미·가독성·몰입: `NOT_RUN`.
- Windows visible local render/실물 입력: `NOT_RUN`.
- Android 실제 기기: `NOT_RUN / BLOCKED_UNVERIFIED`.
- Release 성능: `NOT_RUN`.
- 최종 아트/VFX/오디오: `NOT_APPROVED`.

구현 완료 보고에서 자동 검증과 사람/실기기 검증을 합쳐 표현하지 않는다.

## 9. 롤백

후속 구현이 코어와 충돌하면:

1. Planning Complete Decision은 역사 승인 기록으로 보존한다.
2. 충돌한 구현만 revert/분리한다.
3. 필요한 경우 후속 Planning Reopen Decision을 추가한다.
4. 기존 승인 기획을 조용히 덮어쓰지 않는다.

## 10. 다음 실행

사용자가 구현을 별도로 요청하면 이 handoff와 fresh current truth를 기반으로 **구현 작업 계약/계획**을 작성한 뒤 승인 범위에서만 제품 변경을 시작한다.
