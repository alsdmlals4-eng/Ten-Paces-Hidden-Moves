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
