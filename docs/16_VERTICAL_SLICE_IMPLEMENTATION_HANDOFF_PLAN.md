# 십보강호 · 첫 Vertical Slice 구현 Handoff 계획

> Planning Complete Decision: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`  
> Visual/UX Decision: `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`  
> 상태: `SUPERSEDED_HISTORICAL_PHASE_I_VI_IMPLEMENTATION_HANDOFF`
> Visual/UX 상태: `REQUIREMENT_COMPLETE`  
> 역사 구현 권한: `false` — 이 문서 작성 당시의 Gate. 현재 추가 제품 구현은 남은 Phase 1 검토와 단일 통합 구현 계약 뒤에만 판단한다.

이 문서는 첫 5전 Phase I–VI 구현 전에 작성한 handoff다. 해당 bounded flow는 이후 main에 병합됐으며, 이 문서는 그 당시 범위·근거를 보존한다. 다음 구현은 이 문서를 현재 계약으로 재사용하지 않고, 남은 Phase 1 검토와 사용자 승인 뒤 작성될 단일 통합 구현 계약을 따른다.

## 1. 구현 전 fresh-read Gate

구현 요청이 들어오면 과거 세션의 SHA/PR 상태를 그대로 사용하지 않는다.

1. Project `main`과 열린 PR을 다시 조회한다.
2. exact Project Notion Home 및 `09~13` 기획 페이지와 `02 · 비주얼 바이블`, `03 · UI · 전투 Flow Map`, `04 · 에셋 라이브러리`를 다시 읽는다.
3. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`와 `docs/planning-data/current_user_planning_status.json`을 대조한다.
4. `docs/planning-data/current_entry_gate_20260808.json`과 current operating state를 다시 읽는다.
5. 진행 중인 다른 PR/브랜치는 수정하지 않는다.
6. 구현 권한과 플랫폼 검증 ceiling을 fresh truth 기준으로 다시 판정한다.

`current_user_planning_status.json`과 최신 Planning/Visual Decision은 이 문서의 2026-08-20 계획 상태보다 우선한다. 오래된 Review Ready/Visual Review Pending/implementation-pending 문구가 남아 있으면 current GitHub·Notion·runtime truth와 대조해 live router를 교정한다.

## 2. 구현 기준선

다음 기획을 구현 입력으로 사용한다.

- `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`
- `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`
- `docs/14_VERTICAL_SLICE_LOADOUT_ROUTE_BUDGET_WIREFRAME.md`
- `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`
- `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`
- `docs/decisions/2026-08-20_VERTICAL_SLICE_PLANNING_COMPLETE_DECISION.md`
- `docs/decisions/2026-08-20_VERTICAL_SLICE_VISUAL_UX_SYSTEM_DECISION.md`
- `docs/planning-data/current_user_planning_status.json`
- `docs/planning-data/approved_20260820_vertical_slice_visual_ux_contract.json`

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
- 통합 수묵 전술 화폭과 전장 우선 정보 위계.
- 카드를 덱/손패/드로우 시스템으로 재해석하지 않음.

## 4. 권장 구현 순서

### Phase I · Run/App Flow Shell

`Main → Setup → Intro → Briefing → Combat → Review → Result → Route → 다음 Briefing → 5전 완료` 상태 전이를 먼저 연결한다.

완료 기준:
- 5전 경로가 기존 런타임 전투를 사용해 상태 손실 없이 끝까지 왕복 가능.
- Scene 경계가 기획과 일치.
- 재시작/이어하기 대상 상태가 명시됨.
- Visual 컴포넌트는 최종 자산이 없어도 구조화된 placeholder/frame으로 교체 가능하게 구성.

### Phase II · RunState와 후보 15명

- 후보 15명의 슬롯/working name/loadout/습관/반례/Briefing 훅을 data-driven으로 연결.
- 적 AI는 승인된 공개 정보만 사용.
- 후보 1명 때문에 새 전투 판정 시스템을 만들지 않음.
- 상대별 별도 UI를 만들지 않고 공통 Portrait/Battler/Briefing frame을 사용.

### Phase III · Setup / Briefing

- 시작 6중4 선택.
- 상대 공개 정보와 플레이어 현재 상태 표시.
- 실제 잠금 계획·AI 가중치·정답 대응·확률 명중률은 표시 금지.
- Setup은 덱빌더 손패처럼 보이지 않게 하고 무공 정체성 선택으로 표현.

### Phase IV · Review / Result

- Combat Review Overlay는 이미 발생한 사건 1~3개의 인과를 보여 준다.
- 전장 위치를 유지한 채 원인 분석 대상만 강조한다.
- 다음 행동을 자동 추천하지 않는다.
- Result Scene에서 승패·등급·보상·다음 상대 선확정을 처리한다.

### Phase V · Route 8노드

- Growth/Recovery → Information/Preparation 순서를 네 구간에서 보존.
- 성장 경로는 집중 `+6`, 자유 `+14` 경로를 보존.
- 회복 `최대 체력 25% + 기력1 + 내력1`은 `REVERSIBLE_BALANCE_SEED`; 별도 검증 전 하드 확정값으로 취급하지 않는다.
- Route는 거대 월드맵/별도 메타게임으로 확장하지 않는다.

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
- 숨은 계획 정보가 Briefing/Route/Visual state로 누출되지 않음
- 구조화 UI text/data가 이미지에 종속되지 않음

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

## 7. Visual / UX 기준선

Visual/UX Requirement & Reference Review는 `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`로 완료됐다.

구현 시 다음을 사용한다.

- `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`.
- `docs/planning-data/approved_20260820_vertical_slice_visual_ux_contract.json`.
- exact Project Notion `02 · 비주얼 바이블`, `03 · UI · 전투 Flow Map`, `04 · 에셋 라이브러리`.
- 현행 `docs/07_COMBAT_UI_SPEC.md`와 활성 asset manifest.

핵심:

- 통합 수묵 전술 화폭.
- 전장이 가장 큰 시각 질량.
- 커밋 전 불확실성 / 해결 후 인과 명확성.
- 기존 배경·카드 Atlas·초상·battler·먹+금 VFX 계보 재사용 우선.
- 15명 공통 캐릭터 프레임 + 인물 실루엣 차별화.
- `TEN-VIS-A01~A06`은 요구사항 승인 상태지만 아직 생성되지 않음.
- 새 이미지 생성은 사용자가 명시적으로 요청할 때만 수행.

최종 Visual이 없어도 구조화 frame/component부터 구현할 수 있지만, placeholder 또는 미승인 이미지를 Human 몰입/첫인상 PASS 근거로 사용하지 않는다.

## 8. 검증 ceiling

Planning/Visual Requirement 완료 이후에도 다음은 현재 PASS가 아니다.

- 대량 밸런스 시뮬레이션: `NOT_RUN`.
- Human 재미·가독성·몰입: `NOT_RUN`.
- Human 최종 Visual 승인: `NOT_RUN`.
- Windows visible local render/실물 입력: `NOT_RUN`.
- Android 실제 기기: `NOT_RUN / BLOCKED_UNVERIFIED`.
- Release 성능: `NOT_RUN`.
- 최종 이미지·아트·VFX·오디오: `NOT_GENERATED_OR_NOT_APPROVED`.

구현 완료 보고에서 자동 검증과 사람/실기기 검증을 합쳐 표현하지 않는다.

## 9. 롤백

후속 구현이 코어 또는 Visual/UX 계약과 충돌하면:

1. Planning Complete Decision과 Visual/UX Decision은 역사 승인 기록으로 보존한다.
2. 충돌한 구현만 revert/분리한다.
3. 필요한 경우 후속 Planning/Visual Reopen Decision을 추가한다.
4. 기존 승인 기획을 조용히 덮어쓰지 않는다.

## 10. 다음 실행

역사 종료 상태는 `AWAITING_EXPLICIT_ASSET_OR_IMPLEMENTATION_REQUEST`였다. 현재 상태는 `docs/planning-data/current_user_planning_status.json`과 Active Context가 소유하며, 남은 Phase 1 검토와 사용자 핵심 결정을 닫은 뒤 하나의 통합 구현 계약만 작성한다.
