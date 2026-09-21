# 플레이 흐름 개선 루프 — 구현 계획과 실행 기록

## 후속 표적 교정 계획: 행로 선택에서 다음 단계까지의 초점

실행: `route-focus-red.log`에서 실제 Enter 선택 뒤 continuation 초점 부재를 확인했다. 기존 성공 transaction 반환값을 사용해 초점을 인계하고, 같은 행로 내 성공한 다음 단계에서 첫 선택지를 연결했다. `route-focus-green.log` PASS 후 Windows4.7.1 actual 입력22검사 PASS, stderr empty. root result는 synthetic terminal fixture이며 실제 전투 승리 증거가 아니다. 선택/다음단계/휴식에 실제 key event를 사용하고, 중단 선택은 초점·자원을 유지하며 중복 휴식은 추가 회복0이다. `route-focus-rest.png`의 실제 GPU 화면을 직접 확인했다. legacy ROUTE_GROWTH/INFO에 무관한 구현을 추가하지 않았다. 새로운 전체 검토가 아니라 같은 승인 흐름의 후속 결함 교정이다.

기준58385c2a / 동일main·Base·10개 비교. 결과 보상 다음의 실제 current 소비처는 `JIANGHU`이며 과거 ROUTE_GROWTH/ROUTE_INFO 화면을 새 기본으로 복원하지 않는다. `VerticalSliceRouteShell._choose_jianghu`는 선택 결과를 게시하면서 선택 버튼을 제거/숨기고, 다음 단계에서는 같은 확정 버튼을 비활성화한다. 두 경계에서 키보드 사용자의 다음 조작 위치가 사라질 수 있다.

동일 선택/확정·focus dimension의 위10개 공식 비교를 재사용한다. Shogun/Celeste의 메뉴 변경·focus 가림 교정에서 전달한 원칙이다. FEASIBLE: 기존 성공한 transaction 이후에만 다음 활성 Control로 focus를 전달한다. 규칙·행로 추첨·선택 즉시 적용·4회/3갈래·저장 변경 없음. 대안: 성공 경계의 명시적 focus ADOPT; 매 프레임 자동 focus REJECT(사용자 탐색을 훔침); 화면 전체 재구성 REJECT(불필요).

순서: 기존 inn/route fixture의 실제 Enter 연속 입력과 선택/휴식 중복0 RED → 성공한 선택 뒤 continuation, 성공한 다음 단계 뒤 첫 선택지로 focus → 메뉴/결과/행로 경계 영향 회귀 → owner와 CI. 실패하거나 중단된 transaction은 focus를 이동하지 않는다. 기존 전체 검토2회를 초기화하지 않는다.

## 후속 개발 반복: 결과 보상 탐색 (구현 전 계획)

### execution-report

- 보호 변경 계약·canonical reference freshness·work receipt resume PASS. 검증 중 되돌린 생성 sidecar184개는 원래 삭제 대기로 반환하고 전부 기존 SHA-256과 일치함을 확인했다. 새 격리 저장 fixture1폴더/7파일은 `C:/Users/user/Documents/삭제대기/십보강호_모션통합_20260912_064614/result-rewards-20260913`에 이동하고 original/destination/hash manifest를 남겼다. 실제 삭제0, outer checkout 사용자 변경 보존.
- RED: `result-navigation-red.log`에서720p panel/footer 넘침, 비스크롤 목록, 선택 후 focus 소실, receipt/중복 전수 의미 누락을 확인했다. 초기 탐색 테스트는 이미 선택한 뒤 다른 보상을 고르려 해 실패했으며, `RunState.set_pending_result_reward`와 `verify_ten_duel_campaign.gd`의 첫 receipt 보존 계약을 읽고 이 기대를 교정했다. 도메인 규칙은 수정하지 않았다. 선택 전 변경 불가 안내와 선택 후 다른 버튼 잠금을 UI에 반영했다.
- 구현: 기존 Result shell에 ScrollContainer와 안정된 reward key 기반 버튼 재사용. 선택 문구만 갱신해 focus 유지. 마지막 버튼의 하단1px가 잘리는 actual rect RED를 재현하고 컨테이너 layout 다음 프레임에 focus-ring 여백을 포함한 가시 영역으로 보정했다. 이전 deferred 호출은 실제 focus owner가 바뀌면 무시한다. 내부 receipt 문구를 제거하고 이미 보유한 무공의 전수는 기록 보관만 한다는 실제 처리를 설명한다.
- 검증: 최종 result regression76개 PASS. 10권/12선택은 progression owner를 이용한 명시적 화면 stress fixture이며 유효한 전체 저장 이력을 주장하지 않는다. 960×640/1280×720/1920×1080 bounds, 방향키/Tab/Enter, 선택·메뉴 중단·복귀·다른 보상 잠금·실제 확정 후 행로 진입과 보상1회 PASS. Windows4.7.1 실제 GPU720p/1080p 캡처를 직접 확인했고 해당 실행 stderr는 비어 있다. 카운터 합산 수정 전 visible 로그의37은 true 검사만 센 표시이며, 최종 전체76은 true/false/equality를 모두 센 수다.
- 인접 회귀: completion summary, menu60, synthetic ten-duel state, failure/retry, completed-record return33 모두 exit0. Python governance/retry-save22개 PASS. 이 결과를 물리 gamepad/접근성 사용자/Human/Android/Release PASS로 승격하지 않는다. 기존34CI는 a5dcb9db 기준이고 이번 exact HEAD는 PR342 live metadata로 확인한다.
- 실제 evidence root: `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/`의 result-rewards-720p.png, result-rewards-720p-1080p.png 및 validation/result-navigation-*.log, validation/*-result-final.log. Godot4.7.1 binary bytes/version만 재사용했으며 다른 프로젝트의 editor/scene에는 연결하지 않았다.
- 학습: 선택 가능한 UI와 실제 첫 선택 고정 계약을 함께 검증해야 한다. 스크롤 존재만으로 마지막 focus ring 가시성을 보장하지 않으므로 실제 rect와 입력 검사를 기존 mandatory `validate-vertical-slice-run-state` 회귀에 추가했다. 버튼 수/저장 Schema/규칙을 늘리는 추상화 없이 기존 소비처를 교정했다. 기존 전체 검토2회를 초기화하지 않고 이 결함별 증거와 untouched 도메인/저장/행로/완주 회귀를 추가했다.

기준 a5dcb9db1f6f8b4e61a7704701f9f4feddc48ced / main ed2104d9 / Base d830c0f6. PR342의34개 exact 검사 PASS, 다른 PR199/200은 해당 보상 UI와 무관한 문서·adapter diff로 보존한다. 사용자 `작업 계속진행해`와 전체 완성 연속 구현 지시 범위. PLAN→BUILD→REVIEW. Skill: project UX ui-contract/runtime-review, implementation-contract/build, verification/regression; brainstorming bounded, writing-plans, systematic-debugging/TDD. 기존 전체 검토2회 계보를 유지하고 결함별 회귀를 수행한다.

CURRENT_SOURCE_RELEVANCE_CHECK: 같은 공개 결과·선택 탐색·pause/저장 경계 비교의10개 공식 본문을 다시 읽었다(2026-09-13). 아래 기존 비교표의 직접4/인접6을 유지하며 새 소비처에 다음과 같이 적용한다. 반응 근거는 개발자 패치 및 공개 문서의 한계이며 대표 플레이어 조사는 아니다.

| 사례 | 공식 사실·공백 | 결과 보상 소비처 판정 / DO_NOT_COPY |
|---|---|---|
| Shogun Showdown / 직접·혼합 | 1.0에서 상점 긴 설명이 선택 기술을 가리던 문제 교정, 보유 기술 강화 단계 표시; reward 중 gamepad/map 결함 수정 | 선택 항목 가림·보유 상태 설명 ADAPT / 덱·상점·재추첨 제외 |
| Tactical Breach Wizards / 직접 | 공식 소개에 자유 rewind를 명시, 보상 화면 초점 구현은 공개 안 됨 | 확정 전 비교와 확정 구분 ADAPT / 전투 rewind 제외 |
| Fights in Tight Spaces / 직접·혼합 | 역사 EA FAQ의 controller 지원과 remap 부재 별도 명시 | 키보드 회귀와 실제 기기 증거 분리 ADAPT / 역사 기능을 현행 보증으로 쓰지 않음, 덱 제외 |
| Into the Breach / 직접 | 공식 Steam 설명의 적 공격 예고·결과 대응 구조, 보상 내부 UI 미공개 | 공개 결과만 설명 TEST / 적 숨은 계획 예고 AVOID |
| Knights in Tight Spaces / 인접·혼합 | 종료/pause 사이 저장 손상과 너무 빠른 재시작 정지 수정, 상태 문구 명료화 | 보상 선택과 확정·중단 경계 ADAPT / 보상 수치·파티·모드 제외 |
| Celeste / 인접·혼합 | 긴 메뉴에서 조작 안내 유지, pause 스크롤 결함과 입력 충돌 교정 | 긴 목록·Tab/방향키·메뉴 복귀 ADAPT / 이동·assist 규칙 제외 |
| Hades / 인접 | 공식 FAQ의 저장 복구와 입력 문제 안내; 내부 reward 초점 구현 미공개 | 기존 저장 owner 보호 ADAPT / 내부 구현 추정 및 새 저장 슬롯 제외 |
| TLOU2 / 인접 | HUD 크기·배경·명암 조절과 음향 정보의 시각 대체 | 글자를 줄여 목록을 억지 수용하지 않음 ADAPT / 자동 조준·게임 보조 제외 |
| Ratchet & Clank / 인접 | 상호작용 대상 대비와 메뉴 parallax 끄기 | 선택 체크와 정지 레이아웃 ADAPT / 신규 shader·게임속도 제외 |
| Slay the Spire / 인접 | 공식 소개의 조합 선택과 경로 위험 선택; 이 문서에 초점 구현 미공개 | 기존 모든 성장 선택지 보존 ADAPT / 덱·손패·드로우·유물 제외 |

출처는 아래10개 URL과 Into the Breach 대체 Steam URL을 따른다. 기술 근거: https://docs.godotengine.org/en/stable/classes/class_scrollcontainer.html 의 follow_focus/ensure_control_visible와 https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html 의 명시적 focus 및 숨김 시 focus 손실. stable 설명을 exact4.7.1 검증으로 대신하지 않는다.

FEASIBLE: `vertical_slice_shell_result_auto.gd`는 결과 버튼을 매 렌더마다 remove/queue_free하여 선택 직후 초점 소유자가 사라진다. 보유 무공 수+2개 버튼을 비스크롤 VBox에 넣어 작은 화면에서 높이가 늘어난다. `VerticalSliceProgressionState.apply_reward_receipt`는 이미 보유한 전수를 pending_duplicate_transfers에만 보관한다. 모델/저장 Schema/보상 수치는 그대로 두고 이 실제 의미를 표시한다.

대안3개: (1) 기존 목록에 ScrollContainer와 안정된 버튼 식별·초점 보존 ADOPT — 모든 선택지와 현행 2단계 선택/확정 재사용. (2) 페이지/별도 팝업 REJECT — 새 탐색 상태·닫기 경계 증가. (3) 보유 무공 일부만 노출 또는 글자 축소 REJECT — 선택지/가독성 손실.

구현 순서: 기존 실제 Result fixture에서720p10권/12선택과 입력 후 초점·성장 불변 RED → 스크롤과 동일 구성 버튼 재사용 → 내부 receipt 문구 제거 및 중복 전수의 현행 보관 의미 명시 → 실제 Tab/Enter와 메뉴 중단·다음 행로 화면 복귀·중복 보상 방지 → 기존 review/result·completion·menu·저장 회귀 및 visible720p/1080p → owner/보호 경로/CI/readback.

완료 기준: 보상 선택 전/후/확정 후를 구분하며 선택만으로 자원·수련·보상 이력이 증가하지 않는다. 모든 현재 무공 보상이 키보드/스크롤로 도달 가능하고 확정 버튼이 화면 안에 남는다. 현재 선택은 체크와 초점으로 구분하며 새 전투/로드 시 유효 목록만 반영한다. grade 산식과 중복 전수 변환은 새로 만들지 않는다. 원화 생성 불필요. 다른 프로젝트 Hera editor에는 연결하지 않고 격리된 해당 프로젝트 Godot 실행으로 검증한다.

## 후속 개발 반복: 완주 기록 보존과 제목 복귀 (구현 전 계획)

### 후속 execution-report

- 최신 사용자 범위 재확인: 게임 전체 완성·구현까지 개선 루프를 계속한다. 개별 패키지는 전체 게임 완료 선언이 아니라 계획→구현→검증을 추적하는 단위다. 자동으로 해결할 수 있는 잔여 구현을 계속 찾고 처리하며 Human/실기기/출시 증거는 별도로 유지한다.
- 최종 관련 회귀: completion return33, game menu60, variable save compatibility, save entry isolation, durable continue 모두 종료 코드0. 보호 변경 계약 검사 PASS. 생성 sidecar184개와 이번 완료 복귀 테스트의 격리 폴더13개(파일53개)를 수동 삭제 대기 `C:/Users/user/Documents/삭제대기/십보강호_모션통합_20260912_064614/completion-return-20260913`로 이동하고237개 파일 SHA-256 readback을 확인했다. 원래 경로·복원 목적지는 CSV에 기록했고 실제 삭제는 수행하지 않았다.
- 실제 구현: `VerticalSliceCompletionShell.return_to_title`는 완료 상태·저장 확인 뒤 기존 scene을 새 제목 인스턴스로 교체한다. 저장과 현재 설정 owner를 이어주고 이전 인스턴스를 해제한다. domain MAIN/retire는 호출하지 않는다. 제목의 완료 체크포인트는 `완주 기록 보기`로 표시하고 새 여정 확정 시 교체되는 한계를 안내한다.
- RED: `completion-return-red.log`에서 실제 완료 checkpoint를 로드한 뒤 복귀 진입점 부재를 확인했다. GREEN에서 기록 열람/취소/확정19개 검사 PASS. 취소 입력은 main root와 실제 확인 Window를 구분해야 하므로 기존 native 회귀처럼 Viewport의 입력 경로로 전달했다. 버튼 신호를 직접 발행해 통과시키지 않았다.
- 추가 RED: `completion-return-late-pause-red.log`에서 복귀 예약 직후 pause가 들어오면 화면이 바뀌는 문제를 재현했다. deferred 실행 직전 accepts_commands와 완료 상태를 재확인해 교정했다.
- 확장 검사: v1/v2 완료 fixture, 저장 실패·복구, pause, 늦은 pause, 중복 복귀, 제목 포커스, 기록/보상 불변, 새 여정 취소/확정/새 generation, 미완료 복귀 거절, 정상 및 쓰기 실패 설정 유지. v1 최종33개 PASS; v2 Windows33개 PASS. GPU720p/1080p 제목 캡처를 직접 확인했다. 로그/이미지 root: `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/`의 validation/completion-return-*와 completion-return/.
- Windows 미해결 진단: embedded ConfirmationDialog 취소/확정에 Godot `_sub_window_grab_focus` index 진단이 발생한다. `--dialog-baseline`으로 새 복귀를 실행하지 않은 기존 제목의 확인창에서도 재현했다(`completion-return-dialog-baseline-open.log`). 상태/저장 검사는 성공하지만 무진단 runtime/Human PASS가 아니다. 원본 engine source와 Window 문서를 확인했으며 검증되지 않은 엔진 패치를 적용하지 않았다. 별도 회귀 fixture를 남겼다.
- 학습/자동화: 완료 domain을 MAIN으로 바꾸는 것이 저장 retire로 이어진다는 consumer 차이를 찾아 기존 scene 진입점 재사용을 선택했다. 비동기 화면 교체는 요청 시점뿐 아니라 실행 직전에도 lifecycle guard가 필요하다. v1/v2 실제 입력 검사를 기존 product CI에 각각 연결했다. 새 저장 Schema나 유료 의존성은 없다. 기존 전체 검토2회는 초기화하지 않았다.
- Python governance/retry-save22개와 canonical reference freshness PASS. 원격 latest HEAD 결과는 PR342를 직접 읽는다. 캐릭터4장 최종 확정, Human/Android/실물 입력·음향/출시와 기존 편집기 종료45 ObjectDB/22resource 진단은 별도다.

기준 c5d82e3a1d64b4e138abd7992db1d016c672e7f0 / main ed2104d9 / Base d830c0f6, 채택9.4.4 유지. 이전 변경34CI PASS 확인. 최신 사용자 지시는 계획·연결·구현·개선을 재승인 없이 이어가는 것이다. PLAN→BUILD→REVIEW, project UX ui-contract/runtime-review, implementation-contract/build, verification regression-validation, writing-plans/TDD를 사용한다.

CURRENT_SOURCE_RELEVANCE_CHECK: 아래10개 공식 출처의 본문을 다시 확인했다. 직접 Shogun Showdown/Tactical Breach Wizards/Fights in Tight Spaces/Into the Breach, 인접 Knights in Tight Spaces/Celeste/Hades/TLOU2/Ratchet & Clank/Slay the Spire. 같은 메뉴/재학습/저장 경계 차원을 재사용하며 다음 새 근거로 복귀 동작을 구체화한다. 반응은 개발자 수정 이력과 공개 공백에 한정한다.

- Shogun1.0: 종료 후 Restart/Back to camp 분리, 메뉴에서 ending 재열람. 결과 열람과 새 여정 생성 분리 ADAPT. 덱/쿨다운/영구 성장 복사 금지.
- Knights 공식 패치: pause→level-end 사이 quit 저장 손상과 완료 직후 재시작 lock-up 수정. 중복 활성화/해제 순서/저장 보존 회귀 ADAPT. 다중 모드/공유 슬롯 도입 금지.
- Hades 공식 FAQ: .sav/.sav.bak 복구 안내와 별도 설정. 기존 검증된 완료 기록 보존 ADAPT. 공개되지 않은 내부 상태 머신 추정 금지.
- Into the Breach 제작사 페이지 재조회 실패. 공식 Steam About This Game으로 대체: https://store.steampowered.com/app/590380/Into_the_Breach/ . 새 시도와 전체 적 공격 예고가 설명되지만 시간 되감기/예고 복사는 REJECT.
- 나머지6개는 아래 비교표의 실제 공개 사실과 DO_NOT_COPY를 유지한다. 새 회차 저장 기능이 공개되지 않은 문서에서 해당 기능을 추정하지 않는다.

FEASIBLE: 저장 owner는 active COMPLETION을 이미 복원한다. run_state를 MAIN으로 바꾸면 coordinator가 retire로 쓰므로 이 방식은 사용하지 않는다. 저장 성공 확인 뒤 기존 shell scene을 새 타이틀 인스턴스로 교체하고 동일 저장/설정 경로를 전달한다. 기존 새 여정 확인과 generation 교체는 재사용한다.

대안: 새 shell 복귀 ADOPT(기존 진입점 재사용); domain은 완료인데 UI flag만 제목으로 전환 REJECT(파생 화면과 이중 상태); domain MAIN 전환 REJECT(기존 retire 의미). 모델·Schema·보상·재도전·코어·다중 슬롯은 변경하지 않는다.

구현 순서: 저장된10전 fixture→완주→실제 Enter 제목 복귀→완주 기록 재열람→새 여정 취소/확정 RED; 최소 구현; 파일/generation/보상 횟수 보존과 중복 클릭·중단·저장 실패 guard; v1/v2/메뉴/이어하기 회귀; Windows720p/1080p 캡처; owner·보호 경로·CI·readback·수동 삭제 대기 정리.

완료 기준: 기록을 보는 동작은 새 여정이나 보상을 생성하지 않는다. 제목 복귀·취소에는 기존 완료 저장이 남고 기존 확인 후에만 새 generation을 생성한다. 다른 화면/중단/저장 실패에서는 복귀를 거절한다. 별도 기록관·메타 성장·영구 보상은 추가하지 않는다. 두 차례 전체 적대 검토 계보를 초기화하지 않고 이번 범위의 실제 결함/consumer/실행/장기 적합성을 표적 검토한다.

AgentMemory 도구는 현재 노출되지 않아 현행 저장소와 직전 실행 기록으로 재개했다. Hera status의 editor는 다른 프로젝트(GRIMOIRE)이므로 연결하지 않았다. 본 프로젝트의 격리된 Godot 실행으로 검증한다. 묶음 문서 갱신 실행이 자동 검토에서 사유 없이 차단되어 읽기와 파일 패치로 분리했다.

사용자 2026-09-13: 유사 장르 조사로 기획을 구체화·연결하고 구현/개선을 연속 수행하며 별도 승인을 요청하지 말라는 지시. 이 기록은 다음 실행 가능한 간극을 선택하는 현재 개선 큐다. 원화 최종 승인/Human 증거를 자동 생성하지 않는다.

- source HEAD: 3bebe3c2428a2aa34d15edf8feca7268a76e7305; main ed2104d98872c63eac27999830aeae9c15a00bdc; Base d830c0f6967678eed3c208ac6b24f9cd1b262ec3. 채택9.4.4 유지.
- Work Mode PLAN → BUILD → REVIEW. Skills: combat-ux-and-accessibility/ui-contract/runtime-review, combat-implementation-handoff/build, ten-paces-verification/regression-validation, writing-plans, TDD.
- 같은 PR342 격리 checkout을 사용한다. 다른 두 PR199/200과 원본 폴더는 이번 제품 흐름과 무관하여 보존한다.

## 현재 구현 대조와 다음 작업

| 영역 | 실제 상태 | 다음 작업 |
|---|---|---|
| 16명·가변 편성·브리핑·전투·정탐 | PR340 구현, 현행 회귀 존재 | 현재 동작 보호 |
| 보상·성장·행로·10전 완주·v1/v2 이어하기 | 제품 구현 및 native 회귀 존재 | 메뉴 사용 전후 불변 검증 |
| 소리·음량·모션 감소 저장 | 직전 커밋 구현/34CI PASS | 타이틀/비전투에서도 조절할 소비처 연결 |
| 일시정지 | shell service와 회귀 존재, 사용자 진입점 없음 | MENU-01: 공개 메뉴와 Esc, 입력 차단·포커스 복귀 |
| 규칙 재학습 | 정본 존재, 게임 내 다시 읽기 없음 | GUIDE-01: 정본 기반 선택형 비무 안내 |
| 설정과 실행 중 상태 동기화 | board 인스턴스 초기 로드만 존재 | MENU-02: 메뉴 설정→현재 board 적용, 실패 피드백 |
| 신규 모션/Human/Android/실물 음향/출시 | 별도 증거 미충족 | 자동 구현 큐와 분리, 사실상 승인/기기 증거 발명 금지 |

## CURRENT_SOURCE_RELEVANCE_CHECK / 10개 게임 비교

2026-09-13 공식 제품 설명·개발자 패치·접근성 문서 본문 확인. 직접4/인접6, 부정·혼합 사례 포함. 공개 설명은 실제 내부 코드나 대표 플레이어 실험이 아니다. 모든 사례의 반응 근거는 아래 명시한 개발자 공개 수정 이력 또는 공개 공백에 한정하며 리뷰 수치로 UX 인과를 추정하지 않는다.

| 게임·분류 | 확인한 사실/공개 공백 | 전달 원칙·우리 적용 | DO_NOT_COPY / 판정 |
|---|---|---|---|
| Shogun Showdown · 직접/혼합 | 2024-05 패치의 메뉴 재구성·튜토리얼 개편·키 재설정, reward 도중 gamepad give-up 수정; 09월 alt-tab/continue 결함 수정 | 메뉴·전투·저장 사이 연결을 실제 입력으로 검사 | 덱·쿨다운·재시작 규칙 제외 / ADAPT |
| Tactical Breach Wizards · 직접 | 공식 소개의 자유 rewind 실험과 다시 읽는 conspiracy map | 학습을 사용자가 다시 열 수 있게 하되 확정 결과는 보호 | rewind/적 예고 도입 금지 / ADAPT |
| Fights in Tight Spaces · 직접/혼합 | 역사 EA FAQ: controller 지원과 remapping 부재를 별도로 명시, 구조 변경 시 진행 유지 한계 | 키 하나 존재를 완전한 입력 지원으로 과장하지 않음 | 덱·모멘텀 금지, 당시 FAQ를 현재 기능표로 쓰지 않음 / ADAPT |
| Into the Breach · 직접 | 공식 소개는 모든 적 공격 예고를 전략 핵심으로 설명 | 우리 안내에 공개/비공개 경계를 명시해야 함 | 전체 적 계획 공개 금지 / AVOID |
| Knights in Tight Spaces · 인접/혼합 | 2025-07 Advanced Tutorial 마지막 단계 멈춤 수정, 06월 두 모드 공유 save slot 주의 | 의무 튜토리얼 대신 언제든 닫는 안내, pause/복귀 중 domain 불변 | 모드·파티·장비·공유 새 슬롯 제외 / ADAPT |
| Celeste · 인접/혼합 | pause 입력 버퍼, 메뉴 키 충돌 방지, Options에서 pause overlay 숨김 및 스크롤 결함 수정 | Esc 중복/echo, focus trap/복귀, 작은 화면 검증 | 플랫폼 물리·assist 난도·quick restart 미도입 / ADAPT |
| Hades · 인접 | 공식 지원은 Profile1.sjson 설정을 다룸; 메뉴 pause 구현은 해당 문서에 공개하지 않음 | 기존 독립 preferences owner 재사용, 알 수 없는 pause 구현 추정 금지 | 진행/보상 구조 복사 금지 / ADAPT |
| The Last of Us Part II · 인접 | 공식 접근성의 선택형 hints·dodge prompt 빈도와 별도 조작 설정 | 안내는 선택적으로 다시 열며 강제 진행/자동 정답을 만들지 않음 | 전투 자동화·적 탐지 보조 제외 / ADAPT |
| Ratchet & Clank Rift Apart · 인접 | pause-menu parallax 끄기, 화면 흔들림과 SFX/UI 음량 구분 | 설정 메뉴 자체는 정지한 레이아웃, 현재 구현된 소리 채널만 조절 | 새 채널·게임속도·공격 shortcut 미도입 / ADAPT |
| Slay the Spire · 인접 | 공식 소개는 위험/안전 경로 선택과 매번 달라지는 경로를 명시 | 비무→행로→성장→다음 비무 연결을 규칙 안내에 포함 | 덱/손패/드로우/유물 미도입 / ADAPT |

출처:
- https://steamcommunity.com/app/2084000/announcements/
- https://store.steampowered.com/app/1043810/Tactical_Breach_Wizards/
- https://store.epicgames.com/p/fights-in-tight-spaces--early-access-faq?lang=en-US
- https://www.subsetgames.com/itb.html
- https://steamcommunity.com/app/2315400/allnews/
- https://www.celestegame.com/changelog.html
- https://www.supergiantgames.com/faqs/hades/
- https://www.playstation.com/en-us/games/the-last-of-us-part-ii/accessibility/
- https://support.insomniac.games/hc/en-us/articles/46716208107795-What-Accessibility-options-does-Ratchet-Clank-Rift-Apart-feature
- https://store.steampowered.com/app/646570/Slay_the_Spire/

기술 근거: Godot 공식 pausing 문서 https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html — paused에서도 Always 노드와 signal은 동작한다. 따라서 menu만 Always, 전투는 기존 Pausable과 coordinator command gate를 재사용하고 배경 Control 입력도 막는다. Ubisoft 접근성 URL 한 건은 읽기 실패하여 근거에서 제외하고 Slay the Spire 공식 페이지로 대체했다.

## 설계·대안·구현 가능성

FEASIBLE: 현재 shell의 pause/flush/recovery, preferences owner, Godot PanelContainer/ScrollContainer/Button을 연결한다. 새로운 규칙·진행 저장 필드·자산·외부 의존성은 필요 없다.

1. ADOPT: 작은 공용 메뉴 Control과 shell 연결. 타이틀·비전투·전투 어디서든 메뉴 버튼/Esc로 열고 닫는다. 처음 메뉴가 없다는 기능 회귀 RED를 확인한다.
2. ADAPT: 독립 settings owner를 재사용하고 닫기 전 board 상태를 동기화한다. 현재 planning 배치/타깃은 그대로 유지하며 재시작하지 않는다. 메뉴 열기 때 기존 stable flush를 사용하되 미확정 입력을 저장 완료로 말하지 않는다.
3. REJECT: 전투에만 독립 settings 팝업 — 첫 진입 전 접근이 불가하고 별도 수명이 생김.
4. REJECT: 강제 첫 플레이 튜토리얼 — 새 progression/save contract와 soft-lock 경계가 불필요하게 늘어남.

메뉴는 현재3설정·명시적 저장 상태·비무 안내·돌아가기를 제공한다. destructive 새 여정/포기/종료 기능을 추가하지 않는다. Esc는 기존 modal 확인창을 우선하며 한 번 입력을 두 번 처리하지 않는다. focus는 메뉴 내부에 순환하고 닫은 뒤 유효한 이전 컨트롤로 복원한다. 폰트와 기존 잉크/종이 UI 스타일을 재사용한다.

안내는 거리(0은 밀착), 3수→해결→3수→해결→4수→해결, 현재 해금 기술 배치, 공개 상태·해결 이력에 의한 추론, 비무→보상/행로→성장→다음 비무, 확정 전 배치가 이어하기에서 초기화된다는 현재 계약만 설명한다. UI가 피해·보상·상대 계획을 계산하지 않는다.

## 실행 순서 / 검증

- [ ] MENU-01: native 버튼/Esc 진입 실패 RED → 메뉴/pause 연결 → 배경 입력 차단·echo·닫기·포커스 복귀·pause frame 불변 GREEN.
- [ ] MENU-02: 타이틀 설정→새 전투 / 현재 전투 메뉴 설정→복귀 일치, 저장 실패 피드백, 기존 process restart 회귀.
- [ ] GUIDE-01: 정본 기반 선택형 안내·닫기·키보드·작은 화면 스크롤. 공개 정보 경계 및 장면/여정 무변경 검증.
- [ ] 두 번 전체 검토의 기존 계보와 이번 새 큐를 구분해 실제 결함·검증을 기록. 관련 지속 저장/전투/키보드 회귀, Windows GPU 캡처, 원격 exact HEAD 검증, 원본 보존과 수동 삭제 이동.
- [ ] 다음 큐 재점검: 실제 미구현이 확인된 항목만 선택하고, 기존 구현을 문서의 오래된 NOT_RUN만으로 중복 구현하지 않는다.

롤백은 이번 UI/shell 연결과 안내 파일만 되돌리는 방식이며 여정 Schema migration은 없다. 사용자 설정 파일과 이전 사용자 작업/원화는 보존한다.

### 다음 개발 반복: 완주 복기 연결 (구현 전 계획)

실제 완료 UI가 집계한 cause_code를 그대로 출력한다. 전투 복기의 기존 CAUSE_LABELS를 조회하여 동일한 한국어 설명과 실제 횟수를 표시한다. 알 수 없는 과거 코드는 중립 문구로 표시하고 원본 기록은 유지한다. 전투 계산·집계·저장 Schema 변경은 없다. 위 10개 비교 중 다시 읽는 학습/공개 결과 연결이라는 동일 차원을 재사용한다. 실제 10전 fixture를 완료 shell에 연결하는 실패 회귀→최소 수정→전체 완료 집계 회귀 순서로 수행한다. 완주 후 재시작은 기존 비활성 버튼만으로 승인된 전환이라고 추정하지 않고 별도 의미/저장 owner 확인 큐에 둔다.

완주 정보가 10전·원인·성장·행로를 한 Label에 누적하는데 세로 스크롤이 없다. 720p에서 실제 패널/버튼 bounds를 먼저 검사한다. 넘침이 재현되면 완료 화면에만 스크롤을 적용하고 원문/횟수는 유지한다. 기존 브리핑 스크롤과 같은 Godot 구조를 사용하며 다른 화면 복귀 시 부모·정렬을 복원한다. 메뉴 비교 중 Celeste의 스크롤/복귀 결함 방지 원칙을 동일 차원에서 적용한다.

## execution-report / 개발 반복 결과

위 source SHA, PLAN→BUILD→REVIEW, 명시 Skill/Mode를 사용했다. 메뉴/안내와 완주 복기를 연결하는 두 개발 반복을 수행했다. 동일 PR 계보의 전체 검토 2회를 초기화하지 않고 실제 새 diff·정본·untouched consumer·실행·비용·장기 적합성을 표적 검토했다.

- 첫 반복: 공용 메뉴/선택형 안내, Esc/Enter/Tab/좌우 입력, 현재 shell 일시정지·저장 서비스 재사용. 첫 전투 전 설정과 진행 중 전투 컨트롤을 같은 preferences owner에 연결했다. 메뉴는 승인 paper surface를 재사용하며 새 그림·의존성·진행 Schema는 없다.
- RED: `game-menu-red.log`에서 미구현 진입점 확인. 경계 확장 RED에서 닫기→즉시 다시 열기 시 지연 포커스 복귀가 새 메뉴 입력을 빼앗는 문제를 실제 focus owner 로그로 확인했다. epoch/현재 visible 검사로 오래된 복귀 요청을 무시하도록 교정했다.
- GREEN: `game-menu-boundaries-green.log`, 실제 Windows `game-menu-visible.log` 각각60개 검사 PASS. 1280×720/1440×900/1920×1080, 포커스 순환·복귀, 창 중단과 메뉴 중단의 결합, 저장 실패 후 현재 적용, 화면 제거 후 pause 해제, 여정/전투 상태 불변. GPU 캡처3개 중720p를 직접 열어 확인했다.
- 두 번째 반복: 완료 UI의 raw cause_code를 기존 CombatReviewSummaryBuilder 한국어 설명에 연결했다. `completion-copy-red.log`3실패→GREEN. 원본 완료 snapshot과 실제 집계는 동일하다.
- 추가 재현: `completion-layout-red.log`에서720p 패널/하단 넘침 및 스크롤 부재3실패. 완료 전용 ScrollContainer와 다른 화면 복귀 시 설명 parent 복원으로 교정했다. `completion-layout-green.log`, Windows `completion-visible.log` PASS. 실제 GPU 캡처 `game-menu/completion-1280x720.png`에서 마지막 복기·성장·36행로/10보상·마무리 문장과 화면 안의 하단을 직접 확인했다.
- 영향 회귀9종: completion_summary, game_menu, durable_run_continue, presentation_preferences, variable_shell, save_entry_isolation, combat_keyboard_accessibility, combat_focus_order, combat_review_ui PASS. 로그: evidence root `validation/verify_*-flow.log`. 손상 ConfigFile fixture의 parse 오류는 예상된 기본값 복구 검사이며16개 검사 PASS.
- Python governance/retry-save22개 및 canonical reference freshness PASS. 메뉴와 완료 native 회귀를 기존 제품 CI에 연결해 재발을 자동 감시한다. 실제 원격 최신 HEAD 결과는 PR342에서 읽으며 이전34PASS를 이번 변경에 재사용하지 않는다.
- 비용/장기 적합성: 기존 설정·pause·공개 복기 owner만 재사용했다. 개별 화면이 전투/보상/저장 규칙을 재계산하지 않는다. 지연 UI 작업은 해당 화면 생명주기를 확인해야 한다는 교훈을 epoch 회귀와 CI에 반영했다. 공용 Base 코드는 변경하지 않았다.

미검증: Human 접근성/밸런스, Android 실기기, 실물 게임패드/음향 장치, 출시. 캐릭터4장 최종 확정은 기존 상태 그대로다. 완료 후 새 여정 전환/기록 보존의 승인 의미는 다음 정본 대조 대상이며, 비활성 CTA만 보고 저장을 교체하도록 바꾸지 않았다.

최종 로컬 확인: 독립 프로세스 설정 write26/read24 PASS. Godot4.7.1 editor import exit0, 기존 baseline과 동일한45 ObjectDB/22resource 종료 진단이 남아 무진단 editor PASS로 표현하지 않는다. 프로젝트 보호 계약 PASS. 검증용180 sidecar는 SHA-256 일치 확인 후 원래 삭제 대기 위치로 반환했고, 이번 부산물은 동일 폴더 `playable-flow-20260913/files.csv`에 원래 경로/해시와 함께 모았다. 실제 삭제는 없다.


## 2026-09-20 P04/P06a 보상 선택과 행로 효과

기준 aa7f91c0 / Work Mode PLAN→BUILD→REVIEW / Skill combat-implementation-handoff(build), executing-plans, live-editor, systematic-debugging, requesting-code-review, pdf(edit). 사용자의 계속 지시와 명세 §8 권장A를 적용했다. Decision `docs/decisions/2026-09-20_REWARD_CHOICE_AVAILABILITY.md`, 계획은 기존 REMAINING_GAME_IMPLEMENTATION_SPEC.md의9월20일 절. 현재 Base23ecad5 및 main e5ec55e6를 재확인했고 관련 PR342/무관PR199·200 경계를 유지했다. CURRENT_SOURCE_RELEVANCE_CHECK: 기존 비교 재사용과 공식 제품/엔진 focus 문서 재조회; 내부 게임 구현·사람 재미 근거로 과장하지 않는다.

변경: 새 보상 선택은 이미 보유한 전수를 model/domain에서 거부한다. 선택불가 이유, disabled 초점 제외, 기존 자유6/집중5+자유3을 유지한다. 과거 pending/history v1~v4는 원래 방식으로 읽고 확정하며 소급 보상0. 행로5종의 실제 적용과 disposable 미리보기는 같은 progression helper를 사용한다. 기존 receipt/36선택/수치/상대 공개 범위/schema/content identity를 보존한다. pending 결과는 기존 전투·행로 기록에서 재구성하고 영구능력 공급/새 사건 의미는 추가하지 않는다.

RED와 교정: 중복 view·새 명령 방어 부재를 실패 검사로 확인했다. 초기 fixture의 v4 배분 누락으로 무제한 advance 반복이 생겨 task test만 중단하고 bounded 반복으로 교정했다. save_id 불일치·이미 누적된 pool을0으로 가정한 fixture도 현재 계약에 맞췄다. 이는 제품 결함 통과 증거로 세지 않는다. 행로 view 부재1실패→공유 계산/소비처 구현→1315검사0실패. 관련 과거 테스트는 중복 대신 현재 가능한 대안을 고르도록 바꾸되 역사 중복의 복원 검사를 별도로 유지했다.

전체 검토1(독립 fresh context): 정본·전체 diff·미변경 ledger/session/roster/codec·실제 비용/장기 호환/초점을 대조하고, 과거 player_resources 생략 저장에서 결과 설명이{}로 사라지는 P2를 v1~v4로 실제 재현했다. 교정은 resource_delta_known=false로 불명 자원량을 표시하고 결정 가능한 수련/단서는 유지하는 방식이다. 네 버전 선택/확정/복원 추가검사가 통과했다.
전체 검토2(root 교정본): 전체 변경과 과거 pending/확정·strict codec·공유5효과·36지점/3갈래·보유10권·반복단서 encounter 격리·상한·회복 불명·선택잠금/메뉴 복귀·CI trigger/기존 consumer/실제 캡처·보고 경계를 대조했다. 추가 확정 P1/P2는 없다. 큰 새 정책/상점/환율/엔진/이미지 제작 대신 기존 owner 연결을 유지했다. 자동/합성 결과를 Human 재미 또는 실제 승리로 취급하지 않는다.

증거 root: `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/reward-route-20260920`. 최종 중복/역사 저장352검사, 행로36지점×3선택·적용/복원1315검사, Windows GPU 보상80검사와 행로41검사(960×640/1280×720/1920×1080), 정적485검사 통과. 전수·v3성장·저장·행로·P03성장·구형호환 관련 회귀7개가 통과했고 cache는 무출력 비정상종료1회 후 단독재실행 PASS(0실패); 원인 미확정 실행 실패를 제품 PASS로 숨기지 않는다. 정적 선택기 이름 오기로 불필요한 장시간 durable 묶음이 포함된 실행은 task process identity 확인 뒤 중단하고 올바른 정적485묶음만 재실행했다. 새 회귀는 CI에도 연결했다.

실제 편집기19824의 exact4.7.1/project 경로와 Hera UI guidance를 확인했다. Windows native InputEvent/renderer로 선택불가 건너뛰기·과거 선택 표시·메뉴복귀·행로 결과/화면 경계를 확인하고 PNG를 직접 검수했다. 신규 이미지 생성이나 최종 미감 승인은 아니다. task editor 종료 뒤 생성 sidecar195개를 `C:/Users/user/Documents/삭제대기/십보강호_모션통합_20260912_064614/reward-route-20260920`에 원본/목적지/hash manifest와 함께 이동했다. 원본 코드·자산과 다른 작업 폴더는 보존했다.

같은 월간 PDF/9월20일 항목에 누적했고 기존 상세11쪽을 보존했다. 최초 렌더에서 부연 문장이 혼자 새쪽으로 밀려 간격만 조정해12쪽을 유지하고 재검수했다. 실제 미실시 Human/Android/기기/출시와 네 모션 final lock은 그대로다. GitHub exact HEAD 검사와 branch/main은 PR342 live metadata가 책임 원본이다. 계획+편집기 실행 복합 요청의 자동 검토 거절은 세부 이유 없이 policy blocked였고, 한정된 문서 diff와 별도 실행으로 검토 가능한 형태로 진행했다.
# 2026-09-21 continuation — first five diverse duels and P05

Approval: latest user `좋아 작업 진행해 / 강호행로 및 5 전째까지 각기 다른 상대,무공과 겨룰 수 있는상태`. Baseline `8403105196ad8d68bd484636be48d255b4d92ca3`; PLAN→BUILD; project implementation-contract/build + verification runtime/regression; executing-plans inline and TDD. Main `e5ec55e6`, Base `23ecad5a` freshly read; contract validator PASS. PR342 is still Draft for four final motion locks; unrelated PR199/200 preserved.

Plan: (1) new-run first five candidate AND signature-manual uniqueness with deterministic weighted draw; preserve persisted rosters, source rows, all existing save identities and stages6–10 repeat policy. (2) P05 raw/effective/reason aggregation, no final S/A/B/C formula or economic reward change; optional versioned grade evidence in combat checkpoint, missing old evidence explicitly unavailable. (3) real first-five combat/16 intervening route choices, actual enemy manual use, restore boundaries, native UI captures and user build. (4) two whole-scope reviews total, focused defect correction, existing canon/monthly evidence update and PR checks. No new art, no core/AI privacy/resource changes.

CURRENT_SOURCE_RELEVANCE_CHECK: reuse existing P05 guardrail and remaining-spec benchmark. Godot official RandomNumberGenerator documentation read 2026-09-21 confirms seed reproducibility but internal algorithm is not a stable cross-version contract: https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html . Therefore stored resolved encounters remain authoritative; no load-time re-roll. No new game comparison quota or unrelated source expansion. Feasibility: FEASIBLE local code/headless/native; Human fun/Android/final art/release NOT_RUN.

Experience hypothesis: first five distinct people and signature styles make each duel present a new observation/response problem. Counterexamples: different names but same signature, signature never available/executed, route unable to reach next opponent, loading changes opponent, repetitive choices despite diversity. Machine evidence tests the first four; player experience still needs Human observation.

RED: 256 seeds,170 repeated first-five rosters; P05 executable aggregator absent. Ruling: opening variety is a new-generation policy, not a roster schema change. Old repeated frozen rosters remain valid; users need a new journey for guaranteed opening diversity.

### 2026-09-21 구현·실제 5전 인수

- 책임 결정: `docs/decisions/2026-09-21_FIRST_FIVE_DUELS_AND_GRADE_EVIDENCE.md`. 변경은 같은 승인 PR342이며 다른 worktree/PR199·200, Base·설치 플러그인·전역 설정·승인 원화와 기존 단계별 수치를 보호했다.
- 실제 AI 감사: 초기 탐색에서 대표 무공이 보유만 되고 실사용은0이었다. 합법 대표 기술 소개 선택을 stats-v4에 연결했다. 기존 공개 이력6건을 재사용하며 숨은 플레이어 계획/입력 의도는 읽지 않는다. 대표 기술을 반드시 사용하게 피해·사거리·중단을 우회하지 않는다.
- 독립 전체 검토1/2: 대응 무공이 일반 막기로 바뀌는 기존 결함, 비공격 상대의 특별합 유효가점, native 인수의 이름만 확인하는 거짓 양성을 발견했다. 태극·소요 프로그램을 실제 실행 수의 준비/성공 후 효과로 연결하고, 비용1회·미사용 회피 만료·실제 피해/효과를 기록했다. 명상/이동/막기 상대 합은 원시 지표 보존·유효 성과 제외. native 검사는 대표 무공의 실제 효과 사건을 필수로 요구한다. 당가3성은 순수공격이고 관찰은5성 overlay라는 데이터 재확인으로 검토자의 초기 stage1 불가 판단을 정정했으며 테스트 면제를 제거했다.
- 표적 후속: 대응 절초의 damage/non-cost 기록 누락을 발견·교정했다. 공격 없는 소요10의 잠깐 회피 grant를 유효절초로 세지 않는다. 태극10/소요7·10의 실제 반격, 자기 실행 수, 비용1회, 다음 묶음 JSON 복원 경계, legacy 대응의 상태 동등성을 추가 검증했다. 전체 검토를 재시작하지 않았다.
- 전체 검토2/2(root): 승인/Decision/consumer/diff/관련 미수정 AI·저장·연출·효과 pipeline/실행 로그/비용·유지 부담을 대조했다. 새 확장 프레임워크 대신 v4 전용 작은 timed-response adapter와 기존 pipeline을 연결한다. 저장에는 transient/callable이 없으며 원화·기존v1~v3 identity·그림 lock 경계를 보존한다. 최종 등급/경제를 구현으로 위장하지 않고 다음 P06·P12를 남긴다.

Windows4.7.1 NVIDIA GPU 실제 UI 자동 입력(seed1, accelerated replay/reduced motion는 probe에만 적용): **5승·16행로·실패0 / 174871ms**. 승패·체력 결과를 주입하지 않았다. 도겸(강룡장결)→풍목(팽가도결)→우람(양가창결)→담월(소요보결)→비연(천기암기록) 각각 대표3성 프로그램의 타격/이동/회피준비 효과를 기록했다. 담월 후속 회피 조건이 실패하면 보너스 이동·기세가 실행되지 않는 사건도 보존했다. 매 결과 경계의 실제 저장 readback과 확정 상대10행 일치를 확인했다. `result-5.png`에서 집계 설명·선택지·확정 버튼의 겹침 없이 보이는 것을 직접 확인했다. 이 seed는 가능한 플레이 경로의 증거이지 모든 전략의 승리/균형 보장이 아니다.

검증 근거 root: `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/five-duels-20260921/`.

| 검증 | 결과/로그 |
|---|---|
| 첫5 고유·재현·기존 중복 저장 수용 | 256seeds / 16후보, verify_first_five_diversity.log |
| 기존 전체 편성 검사 | 10000seeds / VARIABLE_OPPONENT_ROSTER_PASS |
| 공개정보·대표 기술 선택 | 176checks / verify_signature_ai.log |
| 유효 집계 | 19checks / verify_battle_grade_aggregator.log; 비공격 source RED3건 후 GREEN |
| 실제 대응 효과·고성 반격·legacy | verify_timed_martial_response.log PASS; 첫 RED19건은 -red.log 보존 |
| 저장·성장·결과·행로 | checkpoint resume, variable save compat, actor binding,160row codec, growth157, result80, route PASS |
| 연출·정보 경계 | card motion Windows22, integration information boundaries PASS |
| 실제5전 | probe_native_first_five-native.log 및 briefing/result1~5, route.png |

탐색 한계: `campaign-exploration.json`은 AI 소개 수정 뒤/대응 최종 교정 전 10seed의 공개 정책 탐색이다. 9/10이5전에 도달했고 seed34는 재도전 포함2전에서 패배했다. 균형 PASS나 최신 전체 플레이 결과로 승격하지 않는다. 초기 seed42 native 실패도 일반 정책/이전 후보의 결과다. 최종 native 인수는 위 seed1이며 별도로 구분한다.

export: `windows-test-build/TenPacesHiddenMoves.exe`와 pck. 첫 격리 APPDATA export는 템플릿 경로 부재로 실패했고, 설치된 정확한4.7.1 템플릿을 사용하는 정상 경로로 재실행해 성공했다. 프로젝트/플러그인 전역 설정은 변경하지 않았다. import/export 종료의 기존 플러그인 ObjectDB45/resource22 진단은 이전 모션 작업에서도 있던 환경 진단으로 보존한다. 게임 native5전 로그의 스크립트 오류와 구분한다.

월간 기존 PDF의9월21일 항목에 병합했다. 13쪽 유지(요약2+기존 상세11), 기존 상세 content stream 동일, 새 요약2쪽 렌더 직접 검수. 발행 SHA256 `ac9910515d285ea43f71f7b7a622d366134624a1e2fe50669f78925b41347e2f`. 입력 화면/계정/결제 증빙은 미첨부이며 과거 작업일과 오늘 기록·캡처일을 구분한다.

자동/실제 실행은 Human 재미·Android·접근성 사용자·final art·release가 아니다. PR342 Draft의 네 모션 최종 lock은 그대로이며 main 병합 완료를 주장하지 않는다. 원격 exact HEAD/빌드 연결·최종 회귀·복구 가능한 정리 readback은 아래 마감 기록에서 확정한다.

### 9월21일 첫5전 마감 readback

전체 Python/Godot 회귀 `python-suite.log`: **500개 대상,2 skipped,실패0 / 802.951초**. 별도 프로세스의 실제 저장·이어하기 계약을 포함한다. 신규 대응/집계 표적 회귀는 추가 실행 로그에 분리했다. 독립 검토자의 마지막 표적 확인은 남은 확정P1/P2 없음이며, 대응 단위 검사의 저장 부분은 새 엔진 검증이 아닌 **JSON 왕복 후 같은 엔진의 다음 묶음**임을 주석에 정확히 고쳤다. 별도 프로세스 checkpoint 근거는 전체 회귀와 연결한다.

참조 freshness/project operating PASS. 보호 계약의 첫 검사는 import가 재생성한 미추적 sidecar 때문에 exact approved-path 불일치였고, 이를 승인 경로에 덧붙여 우회하지 않았다. 실제 검사에서 생성된 `.uid/.import`208개를 사용자 지시대로 `C:/Users/user/Documents/삭제대기/십보강호_모션통합_20260912_064614/first-five-20260921`에 이동했다. 전체 원래 경로·크기·SHA256·복구 안내를 `restore-manifest.json`에 기록하고 이동 후 해시를 대조했다. 기존 원본/이전 삭제대기 폴더는 보존했으며 파일 삭제0. 정리 후 같은 승인 보호 계약 PASS. task-created editor17356만 종료하고 기존 편집기/다른 프로젝트는 보존했다.

Windows export exit0, export된 파일의50무공 시나리오 PASS. exe SHA256 `5bf89f938102f0e3119a5fdaafac4f55884c877681667d0dce844509c8bd8752`, pck `afefc8ebe81acf4c6b0f0ef76e862571e1b500eef5240adf6f05a08a8911e50e`. 실행 방법은 같은 폴더 `실행안내.txt`. 현재 제품 tree는 이 build와 일치하며 이후 기록-only 마감은 별도로 구분한다. 처음 smoke metadata의84031051은 수정 전 baseline이므로 해당 source identity를 빌드 commit으로 인용하지 않고 commit 확정 후 receipt에서 바로잡는다.

제품 구현 commit: 52e1ce4e1b6311557808184b9bc6eb0d7fe0be0e. 이 commit의 product tree에 맞춰 export smoke metadata를 재발행했고50건을 확인했다. 로컬/원격 작업 branch 일치와 clean worktree를 확인했다. 이후 정본의 무공 표시명 교정은 문서-only이며 제품 파일은 같다. 최종 원격 상태와 build SHA/트리는 외부 evidence의 delivery-receipt.json 및 PR342 exact HEAD live checks를 대조한다.

### 원격 검사에서 발견한 전수 fixture 의존성 교정

첫 원격 run35546542990의 standalone acquired-manual 검사는 실패했다. 저장/전투 기능의 실패가 아니라 과거 추첨 seed34가 새 첫5 고유 정책에서도6종 비시작 무공을 모두 제공한다는 테스트 가정이 원인이었다(`ci-failure.log`, owned7/expected10). 로컬500개 suite는 이 standalone CI 진입점을 포함하지 않으므로 그 PASS로 덮지 않는다.

`verify_acquired_manual_flow.gd`는 실제 generator에서 최대4096개 seed를 확인해 마지막 전투 전에 실제6종 전수가 가능한 편성을 선택한다. 실제 보상 receipt로10종을 얻고 전투/저장/이어하기에서 쓰는 기존 인수는 그대로이며, 테스트를 통과시키려고 제품 추첨·전수 규칙·기존 legacy fixture를 변경하지 않았다. 현재 찾은 seed39에서 기본473검사·fixture 생성479검사가 통과했다. 새 v1/5권·v2/5권·v2/10권과 기존 legacy v1/v2의 독립 프로세스 Continue는 각21검사로 확인한다. 이는 synthetic terminal을 사용하는 전수/저장 계약 검사이고 실제 전투5승 근거와 별개다. 제품 tree는52e1ce4e 및 배포물과 동일하다. 새 전체 검토를 시작하지 않고 실패한 소비처의 표적 교정/회귀로 처리했다.


## 2026-09-21 사용자 화면 결함 교정

기준 branch8e8b2a0 / main e5ec55e6 / 최신 Base23ecad5a. Work Mode PLAN→BUILD→REVIEW; Skill workflow-router, combat-ux-and-accessibility(build), ten-paces-verification(review), systematic-debugging, test-driven-development, requesting-code-review, imagegen(edit), pdf(edit). 외부 유사 사례를 새 판단 근거로 추가할 작업이 아닌 기존 사용자 지정 화면/확정 효과/실제 consumer 결함 교정이므로 CURRENT_SOURCE_RELEVANCE_CHECK는 내부 근거 재사용이다. 기존 전체 검토 예산을 초기화하지 않고 이번 실제 diff를 독립 검토하고 지적을 표적 교정했다.

### 계획·보호·실행
1. 승인된 상대 초상16종을 HUD candidate_id와 연결한다. 전신 provider는 도겸 외 공용 검객이라는 별도 자산 공백을 숨기지 않는다.
2. 시작6무공의 실제 authored effect_steps/비용/수/능력 요구치를 선택 전에 보여준다. 능력 설명은 현재 resolver 소비와 일치시키며 새 능력 효과를 만들지 않는다. 좌우 스크롤을 사용해720p에서 출발 버튼을 유지한다.
3. 사용자가 지정한 여정형 참조를 재사용하고 새 여정·이어하기·설정은 실제 키보드/마우스 제어로 연결한다. 기존525×282 이미지의 주석/해상도는 원본 한계이며 고해상도 승인 artwork로 과장하지 않는다. 손상/비호환/IO/백업 복구 안내와 저장 위치 설명을 유지한다.
4. timed martial ATTACK/EVADED가 시각 cue에서 누락되는 원인을 수정한다. 혼합 적중/회피의 순서·피해0을 보존한다. 비검 원거리 시전은 검 베기 대신 기존 neutral 상태의 준비/회복 scale을 적용하고 skip/reset을 검증한다. 무기별 고유 포즈 제작 완료가 아니다.

전투 판정, 상대 추첨/저장, 숨은 정보, 승인 이미지 원본, 전역 설정/다른 PR/outer dirty checkout은 수정하지 않았다. title의 참조 재사용만 새 runtime asset으로 명시하며 생성 캐릭터는 별도 후보다.

### 검증과 발견한 실패
증거 폴더: `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/user-feedback-20260921`. 초기 회귀34실패→교정. 독립 검토에서 천공 조건부 준비 소비/특수 합 설명 누락과 이어하기 위치 tooltip 덮어쓰기를 발견, review-red.log40검사2실패→review-green.log40검사0실패. timed response 실제 resolver 회피 cue, 프리셋134, headless/Windows GPU card-motion23, shell/bridge/durable continue 회귀를 확인했다.

native-ui.log는 실제 Windows GPU에서 설정→닫기→새 여정→4권 선택→720p 확인0실패. 최초 probe는 물리 창 크기와 stretch 논리좌표를 혼용해 거짓 overflow를 보고했고 좌표/scale을 일치시켜 재검증했다. growth UI는 스크롤 콘텐츠 전체가 창 안이어야 한다는 구형 인수를 viewport+스크롤 도달성으로 교정해24검사0실패. 관련 native 캡처는 title.png/setup-720.png/setup-selected.png. UI 자동 입력과 사람이 이해/재미를 느꼈다는 검증은 별개다.

### 아직 미완료인 시각 범위
적 HUD16종은 연결됐으나 전투장 전신 중복은 아직 해결되지 않았다. 우람·담월·비연·풍목 후보는 기존 승인 초상을 인물 reference로 사용했다. 첫 출력의 비크로마 배경은 실패 이력이며 재교정했다. 크로마 원본과 실제 alpha 결과를 함께 보관하고 포즈 방향/무기와 프레임 경계/피벗을 추가 검수해야 한다. 후보 자동 승인/제품 연결은 하지 않는다. PR342는 기존4모션 final lock과 이 미완료 범위를 포함한 Draft로 유지한다. Human 재미/Android/출시는 NOT_RUN.

추가 closeout:18종 기존 visual suite 중17종 통과, 하나는 ID미지정fallback 기대를 이름있는 Yeongyo와 함께 바꾼 테스트 오류를 분리해 단독GREEN으로 교정했다. 승인 보호계약/referencefreshness/정적combatboardPASS. 새4전신 RGBA의 완전투명 픽셀과불투명피사체를 확인하고 Windows candidate-preview.png에서 실제 alpha 렌더를 확인했다. 장창/도 등은 정방격자영역을 넘으므로 고유region/피벗 연결 검증 전이다. 후보원본8개와상태는 docs/visual-assets/candidates/TEN-OPPONENT-FEEDBACK-20260921/candidates.json, .gdignore로제품export에서제외. Windows export exit0 및배포물50시나리오PASS. 기존45ObjectDB/22resource editor종료진단은기록유지. editor생성sidecar211개를 삭제대기feedback-20260921로해시대조이동, 삭제0.
