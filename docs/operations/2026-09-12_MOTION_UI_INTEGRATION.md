# 2026-09-12 모션·전투 화면 통합 실행 기록

## 현재 범위

- 기준 main: `ed2104d98872c63eac27999830aeae9c15a00bdc`.
- 작업 branch: `codex/motion-integration-20260912`.
- 사용자 지시: 삭제 가능한 파일·폴더는 삭제 대기로 이동하고 링크 제공, 프로젝트 남은 작업 확인 후 진행.
- Work Mode BUILD / Skill `combat-ux-and-accessibility` ui-contract/runtime-review, `ten-paces-verification` regression/evidence-report, systematic-debugging, test-driven-development, live-editor.
- 이전 미완료 작업의 source base: `885c91ee934a6f096c79c7d0cfb5f31db4de7f5c`; 현재 보존 위치 `.worktrees/tenpaces-staging-direction-20260909`.
- 기존 `2026-09-09_CHARACTER_MOTION_INTEGRATION.md` 상단에 기록된 같은 승인 작업의 전체 검토 2회를 유지한다. 이번에는 최신 main 정합성·충돌·발견 결함의 영향 회귀를 수행하며 회차를 재시작하지 않는다.

## 현재 근거와 채택 방식

CURRENT_SOURCE_RELEVANCE_CHECK: APPLICABLE. 동일한 확정 사건의 표현·접지·모션 감소 차원은 `docs/reviews/2026-09-09_COMBAT_FEEDBACK_BENCHMARK.md`의 10개 사례를 재사용한다. 다른 프로젝트의 구현이나 새 게임 규칙을 가져오지 않았다.

2026-09-12 공식 Godot AtlasTexture 문서의 region/filter_clip와 CanvasItem shader의 출력 alpha를 다시 확인했다. 원본 프레임을 재사용하는 ADAPT이며 실제 PNG 투명 배경과 shader keying을 혼동하지 않는다.
- https://docs.godotengine.org/en/stable/classes/class_atlastexture.html
- https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html

FEASIBLE: 기존 source·scene·회귀·소비처가 존재한다. 최신 main에 전체 옛 폴더를 덮어쓰는 방법은 최신 v2 편성·저장·47개 승인 정적 원화를 퇴행시키므로 제외했다. 최신 main의 격리 작업 폴더에서 43개 기존 수정 파일을 3-way 통합하고 필요한 신규 코드·검사·원본 5개만 재사용했다. 이전 시안 v1·사용하지 않는 속공 후보·PDF 생성 도구는 전송하지 않았다. 기존 승인 원본 6개는 삭제하지 않았다.

GitHub main readback: ed2104d9. 기존 open PR199(문서 진입점), PR200(Base 채택)은 현 모션/UI와 직접 제품 변경이 겹치지 않아 보존한다. 현재 채택 Base pin 9.4.4는 변경하지 않았다. 초기 깨끗한 main 작업본의 공식 운영계약 wrapper PASS.

## 발견과 교정

1. 기존 720p 계획 슬롯 잘림과 관찰 열 부족을 `verify_battle_first_layout` / `verify_preparation_columns`로 RED 확인 후 이전 승인 화면 통합으로 GREEN.
2. action_choice_card의 실제 충돌을 승인 원화 provider와 새 전체비율 카드 배치를 모두 유지해 해결.
3. 자동 병합된 상세창이 구형 atlas와 승인 원화를 동시에 표시했다. `verify_motion_roster_integration`에서 실제 콘텐츠 이미지 2개 RED → 승인 원화 1개, 기본 행동 atlas fallback 유지 GREEN.
4. 빈 효과 설명을 split한 뒤 인덱스 0을 읽던 오류를 같은 실제 상세창 검사에서 재현 후 빈 배열 처리. 성공 문자열만 보고 script error를 무시하지 않는다.
5. GPU 캡처에서 상단 이름이 장식 테두리에 걸리는 문제를 확인. `verify_portrait_hud`의 안전 상단·체력행 비중첩 RED 후 이름/자원행 위치 교정 GREEN. 상대 비공개 수치를 공개하지 않는다.
6. 기존 24개 자산 원장 보존 해시를 신규 추가분까지 계산하던 fixture RED. 기존 24개 및 승인 47개 레코드 검사를 유지하고 정확한 후속 5개 ID·해시 검사를 분리했다. 과거 승인 receipt 해시는 변경하지 않았다.

## 최종 확정 경계

합 불꽃은 이전 원장의 2026-09-10 사용자 최종 lock을 유지한다. 캐릭터 공격·반응 시트 4개는 원장의 `IMPLEMENTED_WORKING_BRANCH__HUMAN_PENDING` 상태를 유지한다. 이 검토용 branch의 실행은 이미지 최종 확정·출시 권리 검수·main 병합 완료를 뜻하지 않는다. 최신 112쪽 승인 47개 정적 원화 승인을 이 모션 시트에 확대하지 않는다. 새 이미지는 생성하지 않았다.

## 검증

- 최초 통합 native UI: unittest 1건 안의 18개 개별 Godot 프로세스 PASS / 69.282초. 이후 HUD 교정의 영향 검증과 후속 전체 결과는 아래 갱신한다.
- Windows Godot 4.7.2 / OpenGL / RTX3050. 정확한 프로젝트 editor PID45684를 Hera로 확인했고 diagnostics error0. 다른 프로젝트 editor를 변경하지 않았다.
- 준비·무공·계획 실제 GPU capture 성공. 실행 버튼 명령 → 기본 AI/실제 resolver → 카드 공개와 VFX 동시 표시:71개 실제 프레임, reveal=true/vfx=true. 전체 캠페인 native input 완료와 별개다.
- 로컬 증거: `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/`.
- editor import 종료의45 ObjectDB/22 resource 잔류 메시지는 깨끗한 main에서도 재현된 기존 상태다. 개별 게임 실행 오류와 구분하며 숨기지 않는다.
- Human, Android, 실제 게임패드, 접근성 사용자, 실제 음향 장치, Release 성능/출시: NOT_RUN.

## 정리·재사용

사용자의 수동 삭제 선호를 AGENTS.md에 명시했다. 확인된 불필요 파일만 `C:/Users/user/Documents/삭제대기` 아래로 옮기고 원본·새 위치·검증 결과를 안내한다. 미커밋 source/기획/승인 원본은 유지한다. 현재 사용하는 editor cache를 실행 도중 옮기지 않는다. Godot의 새 import sidecar를 제품 승인 범위에 무차별 포함하지 않는다.

## 남은 작업

최종 전체 회귀/CI, 신규 발견 결함의 영향 검증, 이미지 4개 최종 확정, main 전달 및 후속 readback. 이후 무기군별 모션, 전체 Blueprint 공백, Human/기기/접근성/출시 검증은 별도 완료 증거가 필요하다.

## 2026-09-12 영향 검증 추가 결과

- 31개 직접 Godot 회귀 최초 결과29PASS/2FAIL. 실패는 이전 상세창 이름을 기대한 fixture와 양쪽 발을 한 점에 겹치게 하던 역사적 합 기대값이었다.
- 상세창은 승인 원화 texture 일치·구형 중복 부재를 검사하도록 이관했다. 실제 assert44 RED와 동일 검사 GREEN을 보존했다.
- 합 검사는 실제 양측 접근·접지·각자 복귀를 유지하면서, 이미 승인된 몸통 분리 조건을 기대한다. 겹침을 다시 제품에 넣지 않았다. 동일 검사 GREEN.
- 두 교정 뒤 31개 해당 native 검사 전부 통과한 증거가 존재한다. 처음 실행을31PASS로 다시 쓰지 않는다.
- 프로젝트 운영, canonical reference freshness, archive governance, diff whitespace PASS.
- Base remote 관측 d830c0f6967678eed3c208ac6b24f9cd1b262ec3. 채택 payload·검사 pin은 변경하지 않았다.

## 전체 Python 회귀 완료

`GODOT_BIN`을 승인 로컬4.7.2 console에 고정한 pytest: **511PASS / 676.07초**. 별도 실행한 `test_visual_continuation.py`만 제외된 결과다. 명령에 없는 파일명 `test_durable_continue_process.py`를 ignore로 지정했으나 실제 durable 모듈 이름은 `test_durable_save_contract.py`이므로 긴9개 저장 회귀도 실제 포함됐다. 성공 개수를 부풀리지 않는다. 실행 중 HUD 및 관련 fixture 교정이 있었으므로 한 번의 frozen-exact-HEAD 전체 실행이라고 주장하지 않는다. 해당 HUD/직접 native31 및 원장2건의 후속 영향 검증을 별도로 보존했다.

원격 첫 검사에서 `check_combat_board_contract.py`의 추가 자산/공용 도겸 경로 fixture와 이번 diff의 날짜별 BUILD 승인 기록 누락을 확인했다. 기존 원본24개·승인47개의 해시와 실제 역할별 native 검사를 유지해 같은 checker를 GREEN으로 교정했고, 현재 사용자의 연속 구현 지시를 지정된 BUILD_APPROVAL_2026-09-12.md 경로에 기록했다. 승인/보호 검사를 제거하거나 우회하지 않았다.


## CI 영향 회귀 교정

509ab721 원격 검사29SUCCESS/5FAILURE를 확인했다. 두 줄 요약, 현재 모션 프레임 HUD, 오른쪽 관찰 열 하단 실행 버튼으로 변경된 소비처의 기존 fixture를 갱신했다. 전투 캐릭터 크기는 선택된 원본 프레임의 픽셀과 key 제거 조건으로 독립 측정한다. 실제 적군을 80%로 축소해 불균형을 탐지하는 negative control과 원상복구 검사는 유지한다. 이미 별도 정본 검사에 존재하는 idle 66%/authored pose 75% stage 상한을 적용한다.

실제 제품 결함도 분리해 교정했다. 카드가 생성된 뒤 native 글꼴 높이를 변경하면 설명이 카드 바깥으로 나가는 RED를 재현했다. summary 최소 높이 변경을 관찰해 그림 영역 50px와 설명 하단 여백을 함께 보존하도록 다시 배치한다. 720p 실행 버튼은 요청48px보다 scene 최소56px가 커 하단이 잘렸다. 실제 최소 높이로 버튼 및 관찰 패널 공간을 배분해 같은 경계 검사 RED→GREEN을 확인했다. Linux CI 결과는 별도 원격 readback 전까지 완료로 표시하지 않는다.

Godot 4.7.1 Windows의 동일 native 검사와 1280x720/1280x800/1920x1080 영향 회귀 증거는 기존 validation 폴더에 보관한다. 1800프레임 제한으로 완료 문자열 이전 종료된 frontal partition 실행은 PASS가 아니며, 제한 없이 다시 실행한다. context invalidation은 전용 성공 문자열 ACTION_DOCK_CONTEXT_INVALIDATION_OK로 판정한다.


## 현재 전달본과 재개 방법

검토 PR: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/pull/342 . Draft 이유는 원장에 남은 캐릭터 시트의 최종 확정이다. CI 결과는 PR의 최신 head 검사를 직접 읽는다.

4.7.1의 Full Validation native31개를 전부 실행했다. 최초30PASS/1FAIL은 선택 무공서별1개 해금/1개 잠금을 기대한 구형 무공 fixture였다. 전체 보유 무공의 해금 기술3개와 선택 무공서가 바뀌어도 유지되는 목록, 미해금 기술 실행 차단, 비무 제약의 비활성·접근성 설명·교차 무공 실행을 검사하도록 이관한 뒤 동일 검사 PASS. 원격 product-evidence의 구형 합 VFX atlas 하단 기대값도 이미 최종 확정된 독립 alpha 불꽃과 흰 핵 보존을 확인하도록 교정해 동일 검사 PASS. 공격용 legacy matte 검사는 유지했다.

카드 높이와 실행 버튼 수정 이후 Windows4.7.1 GPU 준비3화면을 다시 캡처했다. 경로: C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/final-471 . 기존71프레임 실행 증거는 이전 제품 revision의 motion/VFX 증거이며 최신 준비 배치 캡처와 구분한다.


## 플랫폼별 표본 누락으로 발견된 절초 확대 결함

dced1b70 원격33SUCCESS/1FAILURE. 실패한 frontal partition은 Linux의 특정 프레임에서 적 절초의 높이가 stage75%를 넘었다(75.075%). 단순 오차 허용 확대 대신 실제 tween의 최대 확대에 모든 원본 공격 자세를 대입하는 결정적 검사를 추가했다. enemy frame2/3가 세 화면 크기 모두77.684%로 RED였다. 절초의 추가 확대를1.12에서1.08로 제한하면 동일 원본의 보수적 최대는74.910%다. idle58%, 원본 이미지, frame 순서, 접지, 판정·피해·AI·저장은 유지한다. 기존1.12 상한 반환값은 다른 보수적 envelope 검사와의 호환을 위해 유지한다. 전체 자세 최대값 검사와 실제 시간 진행 검사를 함께 사용해 빠른/느린 host의 표본 누락을 막는다.


## 실제 입력 캠페인 경로 이관

f671f1d9 원격33SUCCESS/1FAILURE. 절초 최대 자세·Windows·일반 headless 검사는 통과했고 실제 입력10전 probe가 숨겨진 옛 무공서 버튼을 누르다 중단됐다. 현재 UI는 모든 해금 기술을 한 목록에서 선택하므로 probe는 목록의 실제 버튼과 그 무공ID를 검증하고 기존 native 입력 helper로 활성화한다. 미해금/제약 차단, 실제 슬롯 점유, terminal HP/이력 대조, 보상10회·행로36회·가짜 성공 거부는 유지한다. 제품 규칙이나 정책, 보존된 초기 fixture bytes는 변경하지 않는다. 10전 완료는 새 exact HEAD 원격 재실행으로 확인한다.


원격 실행 로그에서 runner 시작00:30:38→native10전 시작00:35:14(4분37초)를 측정했다. 기존 로컬 native 전체약5분35초만 더해도 후속 저장/편성 검사 전에10분을 넘으므로, 제품 evidence job 제한을10→15분으로 조정했다. Windows job과 같은 유한 제한이며 native 자체 wall deadline, 실패 조건, 기본 재생 속도와 전체 검사를 유지한다. 이 조정은 timeout을 PASS로 처리하지 않으며 최신 원격 결과를 따로 확인한다.

## 사용자 최신 연속 개선 지시 · Base fresh-read와 실제 적용

- 새 지시: Base fresh-read 후 벤치마킹·실무조사·구현·개선을 별도 반복 승인 없이 계속한다.
- Base 현재 원격 `d830c0f6967678eed3c208ac6b24f9cd1b262ec3`의 AGENTS, intake/continuous/review owners, 재사용 handoff·TEN_PACES profile·registry를 확인했다. 로컬 Base HEAD `68792fc38340a19945ba6b15eedef39f55d50705`와 구분하며 프로젝트9.4.4 채택 pin은 유지했다.
- Work Mode BUILD/REVIEW; Skill `managing-project-intake-and-work-contract` start/resume, `continuous-work-execution`, `combat-ux-and-accessibility` runtime-review. 현재 Base validator 두 파일을 별도 검증 폴더에 읽기 전용 원본에서 추출했다. root receipt 실행 start PASS; 기록 검사는 구현 증거와 별개다.
- 외부 게임10개 직접 원출처를 읽고 비교했다. 직접 전술 비교4개, 인접6개, 혼합 사례 포함. 출처·관측·적용·복사 금지·공개 정보 한계는 `2026-09-12_PRESENTATION_CONTROLS_WORK_CONTRACT_RECEIPT.json`의 단일 benchmark owner에 기록했다. 비공개 제작 과정이나 대표 플레이어 반응은 추정하지 않았다.
- 실무 채택: Tactical Breach Wizards의 작은 화면 레이아웃/방향키 조작 개선과 인증 후 별도 플레이어 검증, Mario+Rabbids의 효과음·카메라 조절, Celeste의 단축키 충돌 교정 사례를 기존 버튼·슬라이더·포커스에 ADAPT했다. 대형 설정 창과 단축키 전용안은 현재 두 컨트롤의 비용·발견성 비교로 제외했다. 다른 로컬 프로젝트는 조사하지 않았다.
- 실제 구현: 제품 화면에서 숨겨졌던 소리와 효과음 음량을 모션 감소 옆에 복원했다. native Enter로 mute, Left로 volume 감소, 전투 상태 불변, 세 해상도 경계·복기 문장 비중첩을 검사한다. 기존 SFX와 입력 처리 재사용, 새 게임 규칙·이미지·비용·저장 schema 변경은 없다.
- RED: `audio-controls-red.log`, 숨겨진 컨트롤6실패. GREEN: `verify_combat_keyboard_accessibility-final-audio.log`, 실제 입력 포함 PASS. 포커스 순서/링/보조 이름도 해당 실제 컨트롤로 검증한다.
- 원격4499e9ee의 native10전은 PASS지만 뒤의 카드 geometry 검사12실패로 job 전체 FAIL이었다. 이를 성공으로 보고하지 않았다. Linux 두 줄17px 글꼴 조건을 로컬 테스트에 주입해 같은12실패를 재현했다(`card-native-metrics-red.log`). 준비 영역 최소296px로720p 경계만8px 조정해 카드185px 높이를 수용했다. 같은 카드 검사 GREEN. 전투 실행 후 원래 responsive 경계 복귀 검사는 오차를 넓히는 대신 최초 실제 경계와 재진입 경계의 일치를 추가했다.
- 로컬 실제 native 캠페인 ba9b615a: 288입력,10전10승,보상10,행로36,383223ms,failures0. 4499 변경은 CI제한/문서뿐이었다. 이는 특정 보존 v2 fixture의 자동 입력 증거이며 사람 난이도/전체 밸런스 증거가 아니다.
- 실제4.7.1 OpenGL 캡처: `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/audio-controls/preparation-plan.png`. 이미지 모델 시안이 아닌 게임 GPU 화면이며 새 소리/음량/모션 조절을 시각 확인했다.
- 기존 승인 계보의 정확히2회 전체 검토는 유지한다. 이번 후속은 발견 결함별 정본·코드·untouched consumer·경계·회귀와 더 작은 대안 재확인이며 세 번째 전체 검토로 이름을 바꾸어 추가하지 않는다. 불필요한 새 설정 프레임워크/자산/저장 마이그레이션을 제외했고, 카드공간 회귀와 오래된 숨김/60% 고정 fixture를 교정했다.
- 영향 Python 검사9PASS/76.47초(한 항목 안의 native visual18개 포함), 실제 카드/키보드/포커스/보조 이름/복기/레이아웃 검사 증거를 validation 폴더에 보존한다. 최신 head CI 상태는 GitHub를 직접 조회한다.
- 재사용 교훈: 접근성 컨트롤은 노드/label 존재만으로 완료가 아니며 실제 visible+focus+input+domain 불변을 검사해야 한다. 글꼴 최소크기는 개별 카드뿐 아니라 부모의 두 행 높이에도 반영해야 한다. 프로젝트 owner/회귀에 반영했고, Base 공용 승격은 검증된 다른 소비처가 없어 후보로만 둔다.
- 미검증: 설정의 앱 재실행 간 저장, 실제 음향 장치, Human/Android/실물게임패드/접근성 사용자/출시. 현재 설정은 해당 전투 화면 인스턴스 안에서 유지된다. 이미지4장의 최종 visual lock은 별개로 유지하며 이 작업에서 승인 문자열을 만들지 않았다.

최종 국소 확인: 전투 판넬/접지/모든 공격 프레임 peak/화면 복귀 검사 PASS(frontal-final-audio-2.log), 복기·레이아웃·focus 순서·focus ring·보조 이름 PASS. resize를 의도적으로 수행하는 fixture에서는 변경 전 viewport 좌표와 비교하지 않고 새 viewport의 bounded partition을 검사하며, 크기 불변 경로의 복귀 위치는 처음과0.5px 이내 일치한다. 정리 보조181개 이동·해시 확인, 삭제 대기 총800파일(목록 포함).


## 2026-09-21 · 무공별 프리셋과 합 후속 동작 (진행 중)

- 승인: 현재 대화의 “좋아 권장안대로 필요한 연관 작업까지 계속 진행해”. 기준 HEAD c83fba125ddcc8952cf567b5ee8dc5ac85c27d13, main e5ec55e6, Base 최신 main23ecad5a (#883/#885), PR342 Draft. 다른 PR199/200은 운영 변경이며 제품 연출을 흡수하지 않는다.
- Work Mode BUILD; Skill combat-implementation-handoff/build, combat-ux-and-accessibility/ui-contract, executing-plans. 운영 계약 validator PASS. 기존 합 방향/사용자 참조와 Godot 공식 Tween 순차·병렬·ease·중단 규약 재사용(직전 설계 턴 확인); 새 게임 규칙/외부 제작법 검증으로 확대하지 않는다.
- 계획/FEASIBLE: 카드 ID→표현 JSON→pure preset/sequence→기존 board/character 소비. 상호 합 두 기록은 동일 합 조건에서 한 번, 무공은 SPECIAL_CLASH 및 실제 HIT/BLOCKED만 순서대로 표시. 합 후 이어지는 타격은 대기 자세 리셋 없이 연결한다. 사거리 실패/미실행 타격은 새 공격으로 만들지 않는다. 기간/이동 폭/정지/곡선은 표현용이며 판정/AI/저장/승인 이미지 bytes를 보존한다.
- 보호/한계: 원거리/맨손/무기 불명 합은 검 접촉을 강제하지 않는다. 비검 무공의 고유 자세 자산은 아직 없으므로 명시적인 중립 자세 대체이며 고유 모션/최종 자산 완료가 아니다. 새 생성 이미지는 이 작업의 필수가 아니며 기존 미승인 모션4장의 final lock을 대체하지 않는다.
- 검증 계획: pure pair/ordered facts/원본 불변/43카드 매핑, 실제 Godot 연결/복귀/skip/reduced/fast, 역할 반전·장풍·상쇄·중단/실패와 관련 회귀. WHY는 기술 구분과 합 이후 인과 판독, 반례는 두 번 격돌/없는 추가타/중간 대기 복귀/반복 지연이다. 사람 재미 판단은 HUMAN_NOT_RUN.
- 최초 RED: verify_card_motion_presets.gd 미구현 choreography 확인1실패. 초기 코드형 추론2오류를 명시형으로 교정, pure16검사 PASS. 최초 board 실행은 정리된 import sidecar 부재로 asset loader 실패하여 PASS가 아니며 editor import 후 재검증한다.


### 9월21일 검증·전체 검토 완료

- 구현:43기술 ID를 실제 actor-owned definitions에 대조했다. 카드/무공 family/override를 기존 board·character에 연결하고5-key profile 계약은 보존했다. 확정 무공 SPECIAL_CLASH/HIT/BLOCKED 및 일반 합 mirror만 disposable cue로 변환한다. 실제 engine10무공 결과의 표시 피해 합과 원본 불변을 검사한다.
- 전체 검토1: fresh-context 독립 검토로 중간skip의 패자/상쇄 위치 잔류와 overkill 표시 피해를 발견했다. 실제 Windows 캡처에서 VS/공개 거리 중첩도 확인했다. 결함별 실패 회귀5건을 `*-review-red.log`에 보존하고, 모든 참여자 원점 저장/실제 HP손실 예산 분배/장식 VS 양보로 교정했다. 독립 probe에서도 앞의2건 GREEN.
- 전체 검토2: root가 정본·전체 diff·그대로인 resolution/martial pipeline/5-key profile/AI/save 및 실제 consumer·코스트·검증·자산 한계를 재대조했다. 양측 역할/상쇄·unknown contact·누락 자산/미실행 공격·초기/중간 skip·fast/reduced·단독/연타·회복 경로를 확인했다. 신규 확정 P1/P2 없음. 이 승인 단위의 전체 검토2회를 완료하며 이후 결함만 집중 교정한다.
- 최종 로컬: pure134검사 PASS; Windows GPU22검사 PASS; 신규 pure 포함 headless9개 묶음(actor ultimate 실제10무공/합 alpha/공개 flow/skip/terminal/SFX/합 반동/inline 결과) PASS; 설정별도프로세스 write/read PASS; 저장호환/전투checkpoint/획득무공3그룹 PASS; Python static485/실패0 PASS. native 캡처 clash-result.png/follow-through.png를 직접 확인했다. 단독 synthetic choreography 화면이며 실제 플레이 승리/사람 재미 증거로 과장하지 않는다.
- 초기 실패 구분: 이미지 import 부재·동적형 추론 오류는 교정했다. native test의 최초 복귀 좌표5실패는 planning→resolution 배치 변경 전 좌표와 비교한 fixture 문제로, 실제 resolution 배치를 확정한 뒤 비교하도록 고쳤다. preferences 최초 인자 없는 실행은 실행방법 오류이며 write/read와 격리 경로로 재실행했다. 예전 universal sword/고정 windup fixture는 승인한 카드별 계약/명시적 검 대 검 사실로 교정했다. 원 실패 로그를 삭제하지 않는다.
- 도구/실행: exact project.godot와 Hera editor18016/4.7.1·UI guidance 확인. 다른 프로젝트 editor는 사용하지 않았다. Hera diagnostics의 마지막 공용 로그는 의도한 RED 실행을 가리켜 clean으로 표시하지 않는다. 성공 증거는 격리 APPDATA 실행의 원본 로그와 실제 GPU PNG다. editor import/export의 기존45 ObjectDB·22resource 종료 진단은 남아 있어 무진단 종료라고 보고하지 않는다.
- 사용자 검증용 export: `card-motion-20260921/windows-test-build/TenPacesHiddenMoves.exe`와 같은 폴더 PCK. export exit0 및 그 실제 binary의 TEN_MANUAL_EXPORTED_PRODUCT_VALIDATION_OK/50시나리오 PASS. 원격 exact HEAD는 GitHub live metadata로 별도 확인한다. 기존4장 final lock 전 PR342 Draft와 비검 고유 자세/사람 재미/Android/출시 미검증은 유지한다.
- 증거 root: `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/card-motion-20260921`. 기존 월간 작업일지 동일 파일에9월21일 추가,13쪽(요약2+보존11); 문서 발행은 runtime 검증과 별개다.

정리: 이번 실행이 만든 미추적 import/uid200개만 paired source·절대경로·SHA-256을 확인해 `C:/Users/user/Documents/삭제대기/십보강호_모션통합_20260912_064614/card-motion-20260921`로 이동했다. restore-manifest.json에 원위치와 해시가 있으며 사용자가 직접 삭제한다. 원본 자산과 다른 editor/작업 폴더는 삭제하지 않았다.

원격 후속 결함 교정: 최초4d2055f4의 automated-product-evidence가 camera fixture120초 timeout으로 실패했다. 로컬에서 `Real impact consumer must start camera feedback` assertion을 재현했다(camera-local-red.log). fixture에 card_id가 없어 새 unknown preset의 camera0을 사용한 원인이며 제품 카메라를 강제 활성화하지 않고 실제 basic_quick_attack ID와 명시적 검 접촉 사실로 교정했다. unknown card의 shake0 반례와20초 fixture watchdog도 추가했다. 같은 camera 검사 GREEN; 실패한 최초 HEAD를 원격 전체 PASS로 보고하지 않는다. 기존2회 전체 검토를 초기화하지 않는 결함별 후속 교정이다.

카메라 교정 뒤 동일 approved visual continuation18개 그룹 전체 PASS(80.693초). 테스트를 위해 잠시 복원한200개 sidecar는 해시가 같음을 확인해 같은 삭제 대기 위치로 반환했다. 제품 파일/빌드 bytes는4d2055f4와 동일하며 후속 커밋은 fixture와 실행 기록만 변경한다.
