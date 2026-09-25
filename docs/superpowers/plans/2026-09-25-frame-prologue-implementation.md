# 10초 전투와 출사표 구현 계획

> 실행: 현재 승인 범위에서 계속 구현한다. 독립 도메인은 dispatching-parallel-agents로 분리하고, 연결·전체 검토·실행은 주 작업이 담당한다. 별도의 재승인을 요구하지 않는다.

**Goal:** 승인7화면의 실제 데이터·입력·10초 전투·출사표·HTML을 연결한다.
**Architecture:** 새 시간축 판정은 기존 기술 정의/무공 효과를 재사용하는 독립 모듈이다. 새 전투 화면은 해당 모듈의 공개 뷰와 판정 기록만 소비한다. 도입은 기존 회차 상태에 버전 있는 진행 정보를 추가한다. 구형 저장의 판정 의미는 조용히 바꾸지 않는다.
**Tech Stack:** Godot4.7.1 GDScript, JSON, 기존 Python HTML 발행기.
**Spec:** docs/decisions/2026-09-25_FRAME_TIMELINE_AND_PROLOGUE.md

## 공통 제약과 검토 초점

100틱/10초,1틱0.1초; 관찰30/60/90틱. 데이터가 판정 권위, UI는 재계산 금지. 원래 작업 폴더와 import 변경 보호. 기존 무공30종·기초10종·절초 정의 재사용. 적 계획의 숨은 필드는 공개 뷰에서 제거한다. 잔여 후딜·확정 저장·사망 시점·중복 보상·첫행로 반복 방지·구형 저장을 각 소유 테스트에서 확인한다.

## Task1 — 시간축 도메인

파일: data/combat/frame_timeline.json, src/combat/frame_timeline_engine.gd, tests/verify_frame_timeline.gd.
인터페이스: configure(player_loadout,player_mastery,enemy_loadout,enemy_mastery,enemy_binding,constraints=[],giyun=[]), make_initial_state(hud_data,player_tile=4,enemy_tile=6), cards_for(actor), validate_plan(plan,state,actor="player"), lock_enemy_plan(state), public_enemy_plan(state), resolve_window(state,plan).
계획 항목: {card_id,start_tick,direction,move_steps}; start_tick은 현재 창의0~99. 결과: {ok,state,events,samples,review,terminal}. canonical timing은 frame_timing={startup,active,recovery,total}로 정의한다.
- [x] RED: 빈/겹친 계획, 경계 이월, 동시 공격 합, 활성 회피, 관찰 공개 경계, 동일 입력 결정성, AI 비공개 계획 독립성 검사.
- [x] GREEN: 실제 정의와 선후딜을 해석하고 비용·타격·관찰을 정확히 한 번 적용한다.
- [x] Godot headless 검사와 실제30무공 정의의 시간/효과 연결 확인.

## Task2 — 출사표와 비전투 화면

파일: src/run/vertical_slice_run_state.gd, src/run/vertical_slice_shell.gd, 새 src/ui/ink/*onboarding* 및 src/run/*intro* 보조 모듈, tests/verify_frame_prologue.gd.
인터페이스: start_new_frame_run(seed,save_id), is_frame_run(); snapshot의 선택 필드 frame에 version과 도입 진행 저장. 기존 snapshot은 frame 없이 그대로 검증한다.
- [x] RED: 새 게임 첫 화면,6중4선택,규칙단계,첫행로1회 뒤 브리핑, 재진입 중복 효과 방지,도입 저장 복원.
- [x] GREEN: 출사표·규칙·노드형 행로와 능력치 사건, 시안형 브리핑/결과/메인. 버튼은 native Control과 실제 모델 연결.
- [x] 종래 회차 테스트와 도입 테스트 확인.

## Task3 — 프레임 전투 화면과 저장 통합

파일: src/ui/frame/*, src/run/frame_combat_bridge.gd, src/run/run_checkpoint_codec.gd, 관련 shell 분기, tests/verify_frame_bridge.gd, tests/verify_frame_durability.gd, tests/verify_frame_playback_view.gd.
인터페이스: 기존 bridge의 configure_vertical_slice_loadouts/apply_vertical_slice_player_resources/configure_checkpoint_identity/get_last_stable_checkpoint/restore_combat_checkpoint 및 terminal 신호 유지. run.frame 여부로 새 장면을 선택한다.
- [x] RED: 배치/이동/취소,발동100틱 경계,확정/해결 저장 복원,재생 건너뛰기 중복 적용 거절.
- [x] GREEN: 대치·공개 상태·거리·관찰·2줄 시간축·삽화선택·상세,10초 실시간 연출·VFX·하단결과·복기.
- [x] 저장 버전7을 추가하고 기존1/2/5/6 읽기 회귀를 확인한다.

## Task4 — 승인 원화와 HTML

파일: assets/ui/ink_frame/, 자산 manifest, tools/HTML 발행 관련 모듈, docs/blueprint 기존 owner 및 파생 output.
- [x] 승인 시안에서 필요한 배경을 실제 이미지 도구로 만들고 글자/버튼은 native UI로 둔다.
- [x] 기존 번호/코멘트와 폐기 기록을 보존하고 새 실제 화면을 정확한 분류에 연결한다.
- [x] 3/3/4 현행 설명을10초·관찰·출사표 구조로 갱신하고 HTML 링크/영상 재생을 확인한다.

## Task5 — 전체 검토·실행·전달

- [x] 전체 범위 검토 후 발견한 결함을 회귀로 고친다.
- [x] Godot4.7.1 실제 새 게임→첫 비무→결과/복기→이어하기와 준비 크기별 화면을 촬영한다.
- [x] 관련 자동 회귀·HTML 발행·Windows 실행본을 확인하고 두 번째 전체 검토를 수행한다.
- [x] 정확한 변경 파일만 커밋하고 PR367의 최신 검사/검토 상태를 별도 확인한다. 신규 원화 최종 검수와 기존 무공 의미 불일치가 남아 Draft로 전달하며 병합 완료로 처리하지 않는다.

## 사전 인터페이스 검토

Task1→3: frame_timing은 모두 정수틱이며 UI는초표시로만 변환한다. Task2→3: run.frame 추가와 저장schema7은분리; codec은주작업소유. Task3→4: HTML은 실제 촬영과 명시한 원본만 사용한다. 승인 이전7시안은계획예시로표시한다.
