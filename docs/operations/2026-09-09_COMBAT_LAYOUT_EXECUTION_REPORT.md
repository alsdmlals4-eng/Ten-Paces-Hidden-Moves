# 전투 화면 교정 실행 기록

기준544fcbbaff0448edf265e381c70ad3d48fd61b7b / 보호baseline477697842bf14d95e670f01b0fe815e384b53658 / Work Mode BUILD / project router·combat-implementation-handoff·combat-ux-and-accessibility·ten-paces-verification·reference-freshness·execution-report / Skill Mode bounded correction and independent review.

## 작업 전 문제와 채택

PR335 actual native에서 빈 영역·작은 전투원·글자와 VFX 중첩을 확인했다. Sep02 무대 전용/52%/초기42%와 Sep04 준비/실행/current-only owner를 실제 코드에 대조했다. 9/1과9/9의10사례 동일 판단 차원과 현재 Godot CanvasItem/Tween/Image 공식 근거를 교차 확인했다. 결과는 Decision과 exact implementation plan에 연결하며 새 Base pin·외부 dependency·원본 이미지 변경은 없다.

## 전체 범위 검토 이력

1. 최초 전체 소스·승인 화면·실제 consumer·남은 검증·비용·후속 호환을 검토해 숨겨진 계획의 재배치, 인물의 논리칸 크기 의존, 독립 텍스트/VFX 중첩을 확인했다. stage-only 책임 원본이 최신 구조 변경으로 취소되지 않았음을 확인했다.
2. 최초 명세·정본·실제3파일·미수정 overlay/scene/assets·회귀·runtime 계획·장기 비용을 독립 대조했다. L1–5(visible ink,이동 anchor,준비공간,VFX false무시,초기42%의 전구간오용)가 실제 발견되어 clean exit를 거절했다.
3. 수정 명세와 전체 위 경계·제약·5종 viewport·모션/저장 보존·회귀/캡처 비용을 다시 대조했다. 추가 R1은 super의 일시 planning rect와 최종 배치를 혼동한 MOVE 취소다. 안정적인 마지막 최종 rect와0.01 tolerance 및 same-size 직접/deferred 회귀로 교정했다.
4. 별도 검토자가 교정 원본0626f2956be878d16837cfabcf04d388b774a8fc8962f0055eefb0b119e47a61와 G 동기화 계획7c32dbc828bec054038c8d2526b8af70b9eed02d35e599871df42417c0a02e2c를 재검토해 APPROVED_FOR_CONTROLLER_BUILD_DISPATCH했다. 이 단계는 scoped specification review이며 구현 후 전체범위 검토를 대체하지 않는다.

프로젝트5회 clean-exit 계약은 최종 diff와 실제 증거가 갖춰질 때까지 미완료다. 논점별 목록을 완료 loop로 만들거나 새 context reviewer라고 주장하지 않는다.

## 실행과 실제 증거

- main544 fresh fetch, 현재 unrelated Draft199/200 READ_ONLY. G를 별도 codex branch로 생성하고 사용자 dirty root 및 기존 worktree를 보존했다.
- import/제품 변경 전 adopted wrapper는 external approval false로 PASS했다.
- 3개 제품 경로의 신규 승인과 날짜별 BUILD를 기록했다. 아직 protected diff가 없을 때 approval true wrapper는 “requires exactly one detected protected-path error”로 거부됐다. 미수정 보호 경로라는 gate 조건이며 승인 확대나 우회로 해결하지 않는다. 실제 제품 변경 후 같은 manifest로 재검증한다.
- controller 문서 patch 구성의 첫 JS는 syntax error로 실행 전 종료되어 파일 변경이 없었다. 정정 후 apply_patch로 기록했다. 제품 RED 증거가 아니다.
- Task1은 별도 implementer에 test-first로 배정했다. import 생성 sidecar는 제품 수정과 구분해 보존하고 추적하지 않는다. behavioral RED/GREEN/native/CI 결과는 실제 실행 뒤 추가한다.

## 한계·다음 안전 작업

Task1 중간 검증: 주 화면 회귀19.63s 및 plan-lock3.72s GREEN 뒤, planning MOVE의 중복 hidden-tile snap RED1을 추가로 발견해 implementer가 최소 교정했다. Untouched inline은720/800/1080 각2개씩 총6FAIL이었다. 실제 diagnostic의 모든 실패는 visible=false인 이전 묶음TimingSlot02/03이고 현재 패널/CTA/10카드는 통과했다. controller가 src/ui/action_timing_panel.gd115–131와 verifier81–103 및 원인 로그를 독립 확인하여 visible/current-index 일치와 정확한 양수개수 검증을 추가하고, 실제 visible 슬롯만 overlap 검사하는 테스트1개 경로 확대를 명시했다. 기존3제품 경로와 제품 동작은 확대하지 않는다. 첫 잘못 추정한 action_timing_panel 경로 읽기는 실패 후 rg discovery로 정정했으며 검증 결과로 세지 않는다. 추가 실제 GREEN/검토는 후속 기록한다.

Task1·2의 부분 구현·native 검증은 아래와 같이 수행했다. 두 단계의 최종 독립 검토와 로컬 소스 commit을 마쳤으며 Task3 CI 연결, 전체 회귀, producer 이전 receipt와720/800/1080 실제 캡처, 보호 PR/CI/main readback은 남았다. 기존 portrait를 square draw로 표시하는 비율 왜곡은 이번 범위가 개선했다고 주장하지 않는 별도 fidelity 부채다. Human 선호/가독성·청음·실물입력·Android·접근성 사용자·권리·출시·전체 Blueprint 완료는 별도다.

## Task1 실제 구현·독립 검토와 보강

실제 소스 alpha 영역을 캐시해 인물의 보이는 크기·모션 peak를 측정하고, 배경/배너/tint를 같은 전투 무대에 묶었다. 현재 최종 배치와 논리 위치를 구별하여 같은 크기 callback에서는 진행 중 MOVE를 유지하고 실제 resize만 안전하게 snap한다. 원본 그림·도메인·AI·저장·씬·모션 수치는 변경하지 않았다.

- 최초 behavioral RED56 → 최소 GREEN 뒤 planning MOVE RED1 → GREEN을 확인했다. 최종 첫 후보 native는 partition21.2829s / plan-lock3.0598s / inline4.7253s, 모두 exit0·오류0·경고0이었다.
- 별도 검토자는 동결5개 SHA에 결합된 dirty candidate에서 partition20.29s / plan-lock3.42s / inline4.60s를 독립 통과했다. 기반 HEAD544만으로 이 dirty 제품 상태를 재현할 수 없으므로 exact-HEAD 검증이라고 쓰지 않는다. 이 검토자의 실제 두 라운드는 부분 검토 증거이며 프로젝트 최소5회 전체범위 의무를 대체하지 않는다.
- 검토 F1: 새 모션 샘플링의 비종료 회귀가 검사 자체를 끝없이 대기시킬 수 있었다. 같은 test helper에600frames/5000ms 제한과 역할·모션·viewport 실패 메시지를 두고, 각 시나리오에서 실제 tween을 멈춘3-frame negative와 만료 deadline0-sample negative를 검사했다. 실제 모션/source-alpha frame 검사는 유지했다.
- 검토 F2: 배경/배너/tint 참조 누락 시 stage 변경 후 nil 호출이 발생했다. 세 dependency×세 viewport의 실제 RED9 및9 runtime errors를 먼저 확인한 뒤 배치 전에 유효성 guard를 넣었다. stage/성공 baseline/live MOVE/domain 상태 보존과 안전한 참조 복원을 검사했다.
- 보강 최종 native: partition21.0218788s / plan-lock2.9468775s / inline4.6127525s, exit0·오류0·경고0. 잘못된 plan-lock 파일명 실행0.3653917s 실패는 setup 실패로 별도 보존하고 product RED로 세지 않았다.
- controller의 운영계약/채택baseline/이전승인archive/캡처계약 관련5 Python 모듈은17tests PASS3.04s였다. 전체 회귀나 Task2·3 PASS가 아니다.

보강 candidate SHA-256: base board `F28B5C5F43599E6D1D8A109F0C5D3B8498BA10F4788F7D2047100DDB6CF040A5`, auto `4F2425378CD44DA3C5D2DAA0A5AC64FBE96B9EE7964632BD216BFDF25422D860`, character `17EEA94F124336617C6046AD1F6FD49084F005ADD64148439EDFD03E18F31FF4`, partition `AA3E72F24D3886637CD83A8633DA046EA0D98F4F65B07552B2FE97793BD1956C`, inline `0A4456812F0E131D527F6B7CD76F4828C347A8A259407DFA9E68BCC944A7CC3B`. 이 candidate의 독립 재검토에서 partition21.3s/plan-lock3.3s/inline5.4s가 통과하고 F1/F2를 닫았다. controller는 정확한5경로만 로컬 commit `fecc72da5a9b087e0823bed6952d6b4e871cb1d3`에 저장했다. 전체 package/CI/main 완료가 아니며, 현재 Task2가 이 commit을 기반으로 진행 중이다.

Import는 exit0이었으나45 ObjectDB/22 resource 종료 진단을 냈다. 원인은 UNVERIFIED이고 특정 플러그인 탓으로 추정하지 않는다. 생성 sidecar/UID는 미추적으로 보존하며 최종 focused native의 오류0과 import 종료 진단을 구분한다. 필요한 자산 파일의 경로 탐색을 잘못한 읽기 실패도 제품 검증 실패로 세지 않는다.

## Task2 실제 구현·독립 검토와 소스 저장

실행 상태에서만 비교/판정 문구/VFX 영역을 분리하고, 실제 CanvasItem 좌표 변환과 인물의 transformed foot으로 효과 위치를 계산한다. 기존 절초1.08 peak가 안전 영역 안에 들어오도록 같은 비율로 맞추며, 배치 실패 시 두 실제 show caller가 연출을 시작하지 않는다. 화면 크기 변경은 보이는 효과1개의 위치만 갱신하고 음향/연출을 재시작하지 않는다. 준비 복귀·건너뛰기는 일시 상태를 비워 효과가 되살아나지 않는다. overlay/font/copy/assets/domain/save는 그대로다.

- 실제 CTA RED6, corrected accessibility RED12, ultimate sampled RED581을 먼저 확인했다. 초기 검사기 Variant/node-name 오류는 setup 실패로 분리했다.
- 원래 tween의1.08 peak가 프레임 사이에 지나가는5개 관측 실패는 실제 `step_finished(0)` 순간의 읽기 전용 관측으로 보완했다. 시간/모션/custom_step 변경 없이 전체 peak envelope와 프레임 검사도 유지한다. 최신 Godot 공식 Tween 문서와 교차 확인했다.
- 테스트의 발 anchor를 독립 transform 식으로 바꾸자 parent scale에서641개 실제 배치 실패가 드러났다. 기존 renderer getter를 수정하지 않고 두 board consumer만 실제 global transform을 사용하도록 최소 교정했다.
- 최종 implementer native6개: ultimate10.7342411s, reveal11.1225436s, accessibility4.9050368s, controls2.479919s, sfx2.5874653s, terminal4.457533s. 모두 exit0·오류0·경고0.
- 다른 reviewer는 exact frozen5hash의 dirty candidate에서 reveal10.465s, ultimate10.563s, accessibility4.538s, partition20.175s를 독립 통과하고 actionable finding 없이 handoff했다. 실제 child/parent/minimum 높이, transformed geometry, resize/no-resurrection와 untouched consumer를 확인한2개 부분 라운드이지 프로젝트 전체5회를 대체하지 않는다.
- 960×640의 비교 영역270px는 지정된 한국어 fixture가 정확히 들어가는 수준이다. 실제 callout 최소168px와 result34px를 측정했으며 모든 미래 번역이나 사람 가독성 통과라고 해석하지 않는다.
- Controller가 보고서/실제 두 제품 diff/5hash/staged-empty를 확인하고 정확한5경로만 `af25b3b7be90ff7f64d8980dc788935d72f3cde2`에 commit했다. Task3는 이 소스에서 이어진다. report 업데이트 첫 patch는 전체 줄 미일치로 거부되어 무변경이었고 정확한 줄로 정정했다.

## Task3 실제 CI 연결·독립 확인

기존 Python 검사가 정확한 `automated-product-evidence` job과 실제 `push` 범위를 확인하도록 보강한 뒤 실행했다. 필요한 partition/action-reveal 명령이 없어서2개 subtest가 실제 RED21.7430637s였다. workflow는 import 이후2개 native 실행과 해당2개 push filter만 총6줄 추가했다. 기존 job/check/action pin/권한/timeout은 변경하지 않았다. 같은 module4PASS22.0464092s와 boardcontract PASS8.1318924s가 GREEN이다.

Controller가 실제2파일 전체 diff/module/report와 import 앞뒤/untouched job 경계를 독립 확인하고 같은 module을 다시 실행해4PASS21.9033521s 및 boardcontract PASS를 확인했다. 당시 대상 소스는 동결 Task3 dirty candidate였으며 실제 원격 CI 실행으로 부풀리지 않는다. exact2hash와 staged-empty 확인 뒤2경로만 로컬 source commit했다. 최종 전체 검사·policy capture·보호 wrapper·원격 exact HEAD CI·main readback은 다음 단계다.

## 최종 source·전체 회귀·5회 전체 범위 검토

Task3 소스는 `eda26a97f25a931ac02ba739d5c4921720512d41`에 저장됐다. controller가 정확한 이 source에서 전체 `python -m pytest -q`를 실행해 **499PASS315.57s, exit0**를 확인했다(명령 전체 Stopwatch316.3693454s). 앞선 부분 candidate 실행과 구분한다. 제품은 기존3경로, 전체 구현 diff는10경로783추가/101삭제다. 실제 신규 loop나 benchmark를 발명하지 않는다.

독립 최종 소스 검토 보고서 SHA `DB79DE1FFF7D8F7CAC7E055268B7964D2AEDA80845E0C58CFA6829362CEF2931`은 다음 **5회 full-scope**를 수행했다. 동일 재사용 agent context이며 fresh-context라고 주장하지 않는다.

1. 현재 권위/ratified scope와 exact10-file diff, 기존 code/data/scene/asset/test 및 비용·후속v2 경계를 대조했다.
2. 실제 alpha/draw/변환·이동·배경과 미수정Title/HUD/승인6asset, 실행 증거·회귀·캐시 수명을 대조했다.
3. 독립 lane/current-only/가시 효과 재배치와 두 show caller, skip/no-resurrection, untouched overlay 및 runtime/장기 비용을 대조했다.
4. v1 도메인/AI/저장 보존과 독립 oracle, native·전체검사·CI wiring/pin/권한 및 실패 가능성을 대조했다.
5. 위 전체 범위를 다시 확인하고 invalid-input/비용/검증 한계와 오래된 current 문구를 점검했다. 지원 viewport/정상 의존성 범위에서 새 blocker 없이 bounded source ACCEPT로 종료했다.

비차단 후속: auto layout이 lane 계산의 false를 마지막 성공 rect 기록 전에 별도로 소비하지 않는 missing-lane 강건성 seam은 남았다. 지원 크기/native 및 base show 실패처리가 통과했다고 이 미검증 조건까지 해결됐다고 쓰지 않는다. 기존 portrait 비율, 자연스러운 가독성/접지/중첩은 별도 품질 작업이다.

## 실제 native 캡처와 실패 보존

정본003–035 총33장, 최종007–035의29장 실제 call chain을 별도 검토했다. source는eda26a97이며007–021은 실제 Board dock/CTA로720/800/1080에서 준비→이번 수 비교→이동→합→다음 준비다. 추가800 팽가/기존 절초는 실제 resolver-seeded event, 긴 문구030은 명시적 표시 fixture, 도겸029는 실제 enemy 소비처다. mute/reduced/skip,033–035 실제800→1080 Window 변경 중 Tween/alpha/scale/SFX marker 보존과 복귀를 확인했다. 정상 RunSession 전체 캠페인 증거로 확대하지 않는다.

캡처 companion `docs/runtime-captures/TEN-COMBAT-LAYOUT-20260909/README.md`가 matrix/fixture/receipt/진단/실패 경계를 소유한다. 004/006 alpha0 초기 화면, 강제embedded800, 초기 whole-sequence timeout,022 callback-baseline resize실패는 보존하며 PASS로 승격하지 않는다. 최종 helper E3CE는 실제 Window 변경 직전 snapshot을 사용하고 정확한 동등성을 검사한다. peak callback1.08과 PNG/resize baseline약1.078875는 다른 순간이다. compile-only1.1704145s exit0와033–035 최종 native는 실제 이후 증거이며 helper notes의 당시 NOT_RUN을 소급 변경하지 않는다.

Controller가 final editor session `combat-layout-20260909@ad2e`의 editor 진단을 읽어0error/18warning을 보존했다. 별도 검토자는 원문 text/structuredContent와 정리본18행 모두 일치함을 확인했다. 17product+1helper 경고이며 개별 game run_id가 없으므로 모든 runtime의 완전 무오류/무경고는 아니다. 최종 캡처 검토 SHA `A0376B7A5F62655878FF12E401301A8CD91F4B45C4860A22B676B1C92D7B51C0`은 bounded ACCEPT와 실제 typography/actor중첩/접지/여백 한계를 명시한다.

## 실행환경·복구와 자동화 교훈

Hera 설치CLI1.0은 최신 skill에 제시된 game --pid를 지원하지 않았다. exact editor + 실제 scene game의 단일 PID/parent/creation/full command를 새로 확인하고 기존 지원명령을 사용했으며 다른 editor6628에 fallback하지 않았다. 실제 Godot 공식 Game View 설명 및 game_view_plugin source에서 프로젝트별 embed_on_play 경로를 확인해 G의 ignored local metadata만false로 바꾸고 owned editor를 정상 재시작했다. 전역 설정/프로젝트 제품 설정/다른 사용자 세션은 변경하지 않았다.

일시 standalone capture game32064는 정상 CloseMainWindow를 받을 창handle이 없었다. exactPID/parent/creation/fullcmd를 검증하고8초 종료 대기 실패 뒤 그 owned helper만 종료했다. 저장 없는 캡처 fixture이며 다른 프로세스/파일은 삭제하지 않았다. 이후 실제 editor가 실행한 게임은 identity 확인 후 editor의 stop 경로로 정상 정리했다. imports/UID는 사용자 자료가 아니라도 즉시 삭제하지 않고 최종 소유권·editor 종료·백업 확인 뒤 정확한 경로만 처리한다.

재사용 교훈: 논리 visible은 fade 완료가 아니다. raw Tween 신호와 최종 캡처 프레임도 동일 순간이 아니다. callback peak 검증, 실제 frozen baseline, receipt-before-producer, 실제 Window 크기와 one-run diagnostics를 서로 구별한다. 고정 sleep/가짜 canvas/검증 tolerance 완화 대신 bounded 관측을 사용했다. 공용 규칙 승격은 하지 않았으며 프로젝트 companion/helper에 재현 가능한 제한된 방법만 보존했다.

## 현재 증거 상한과 다음 안전 작업

최종 문서/정본 교정 후 native를 실행하지 않는486검사17.44s가 PASS했다. 운영계약/참조신선도도PASS했다. 파생생성기의 최초 호출은 필수 Base 경로 누락으로 실패했고, 바로잡은 일반 생성은 보호 제품+generated metadata를 감지해 거절했다. 이를 승인 확대/우회로 해결하지 않았다. exact owned editor28152를 CloseMainWindow/10초 대기로 정상 종료한 뒤 G 내부의 generated untracked metadata95개(62import/33uid,64184bytes)를 경로·SHA별 백업/검증하고 비재귀로 제거했다. 원본 자산/코드/캡처는 보존됐으며 ignored `layout-sidecar-backup-20260909/receipt.json`과 복사본으로 복구 가능하다. tracked79개는 Git 필터 적용 blob이HEAD와 정확히 같은 LF/CRLF 차이만 확인해 index를 새로 읽었고 staged content0이었다. 이후 채택된 approved-project wrapper는baseline477/exact3제품 승인으로PASS했다. 재import나 다른 작업의native lane 접근은 하지 않았다. 몇 차례 다른 worktree 전용 문서 경로를 잘못 읽은 setup 실패는 성공/제품 결함으로 세지 않았다.

새 fetch의remote main544fcbb와열린Draft199/200 READ_ONLY를 다시 확인했다. 여섯 원본 assetSHA는 계획의보존값과 전부 같았다. 이후 PR/exact CI/main 결과는 실제 도착한 뒤 기록한다.

독립 문서전달 검토 F90C52D71E5350A139A8D31F478667A159050FFF89C539CCD641E8D3B3A3C4D0는 실제33PNG/receipt/진단18행/자산6개와 current owners를 대조해 DELIVERY_PENDING 범위에서ACCEPT했다. metadata외 실제54개 문서/캡처만 commit01535fec023d38c7cc6080ad408d9fe994fa268c에 저장하고 clean branch를push했다. 현재작업 PR337을정상생성하고 exact head01535fec/base544/approved-protected-change label/OPEN/nonDraft/MERGEABLE을live확인했다. 최초원격검사는진행중이며 PASS로미리기록하지않는다.

로컬 source·499기계검사·실제 Board native와5회 전체 소스/별도 캡처 검토는 완료했다. 현재 문구/파생 owner/보호 wrapper/정확한 PR head의 원격CI·병합·main readback은 후속 실제 결과로 갱신한다. ordered-v2/S1–S4는 별도 격리 작업으로 계속하고, 기존v1완주호환·성장·사건·정탐/상태·보상·아틀라스 품질은 남았다. 전체 Blueprint/Human/청음/실기기/접근성/권리/출시 완료가 아니다.

## PR337 실제 CI 실패와 검사 기준 교정

Current head `6433e1f44fa119535360b3ba1c09709713e9ba9d`의 Full Validation run `34313348268`, job `102344389343`에서 `verify_combat_board.gd`의 comparable-scale 검사 1개가 실제 실패했다. Godot 4.7.1의 종료 코드는 1이다. 이전 Python 전체 499 PASS는 이 별도 CI native 명령의 성공을 보장하지 않았으며 이 실패를 덮어쓰지 않는다.

Controller와 별도 검토자가 actual source/CI 원문을 대조했다. 승인된 제품은 원본별 투명 여백을 제외한 실제 인물 높이를 정규화하지만, 오래된 검사는 Control.size를 비교했다. Decision과 계획에 검사기 1개를 명시적으로 추가하고 독립 알파/draw/global 변환 측정, 기존 0.01 tolerance 및 52%/1.12 상한, 실제 scale 변경 반례를 요구했다. 제품·자산·행동을 바꾸는 수정은 허용하지 않았다. 앞선 10개 경로의 5회 검토는 역사 증거로 보존하고 새 검사기 교정은 별도 diff 검토·회귀·최종 exact-head CI로 검증한다.

새 import를 실행하지 않고, 이전에 백업한 G 전용 background metadata 3개를 경로·SHA로 확인해 임시 복원했다. H의 실행 lane을 명시적으로 반환받은 뒤 G의 이 좁은 native 검증만 허용했다.

기존 native RED는 동일 assertion 1개/exit1/5.4536871s로 재현했다. 교정 후 board는 exit0/5.9002316s, untouched partition은 20.7887381s, accessibility는 5.8427054s에 통과했다. 실제 enemy scale 0.8 반례의 높이 120.519996643066→96.4159927368164에서 불일치를 검출하고 즉시 복원했다. 기존 10개 구현 경로의 해시는 전부 동일하다. Controller가 실제 diff·원본 renderer·검사 call chain·CI 명령과 전체 보고서를 독립 확인하고, 최종 frozen board를 다시 실행해 exit0/5.3382864s 및 같은 반례 검출을 확인했다. 근거는 capture companion의 `board_oracle_correction_review.md`다.

보드 종료에서 ObjectDB 2개 경고가 양쪽 실행에 남았다. verbose로 AudioStreamWAV/AudioStreamPlaybackWAV 각 refcount1을 확인했지만 정확한 할당 원인은 미확정이다. 이미 제품 종료 시 stop/stream=null이 있으므로 정리 누락으로 단정하지 않는다. 최종 momentum cue와 한 프레임 후 프로세스 종료의 시점 차이는 source 기반 가설이며, 음소거/자연 재생 완료/제한된 종료 대기 반례는 아직 실행하지 않았다. 경고를 숨기거나 오디오 제품 범위를 이 CI 교정에 추가하지 않았다. 이전 원격 head는 30 SUCCESS/1 FAILURE로 종료했고 새 head CI는 아직 별도 확인이 필요하다.

교정 후 non-engine 486검사 18.50s, 운영계약·참조신선도·보호 승인 wrapper는 모두 통과했다. G에 살아 있는 Godot 프로세스가 없음을 확인하고 임시 복원했던 metadata 3개만 다시 백업 SHA와 대조해 비재귀 제거했다. 기존 백업으로 복구 가능하며 원본 PNG·캡처·제품은 보존됐다. 최종 변경은 검사기 1개와 해당 범위·증거 문서뿐이다.
