# 플레이 흐름 개선 루프 — 구현 계획과 실행 기록

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
