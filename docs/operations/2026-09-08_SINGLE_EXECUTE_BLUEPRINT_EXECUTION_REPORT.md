# 단일 `행동 실행` Blueprint 전환 실행 보고서

## 작업 전 문제

- 기준 SHA: `6faa39cd074f2f8a67e042d5ccaa2ceee31b6a19`; 최신 `origin/main` `32a01130ee385b2070de408b345b8a579c32198b`를 최종 커밋 전에 병합했다.
- Work Mode: `BUILD`. Skills / Skill Mode: `combat-implementation-handoff` implementation, `combat-ux-and-accessibility` semantic control, `ten-paces-verification` regression/runtime, `running-adversarial-review-and-refinement` full-scope review.
- `CombatBoardPreviewAuto._on_progress_requested`의 첫 호출 조기 반환이 별도 `plan_locked` CTA를 노출했고 두 번째 호출만 base resolver로 넘겼다. 승인 Blueprint는 CTA를 정확히 `행동 실행`으로 하고 유효한 한 번의 활성화가 계획 종료와 한 번의 해결을 함께 시작하도록 대체한다.

## 조사·비교 결과

- `CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE`. 같은 전면 결투/행동 공개 consumer를 대상으로 이미 승인된 10-game Blueprint packet과 최신 Decision 1.2를 재사용했다. 새 게임 규칙·플랫폼·권리 판단이 없어 추가 외부 검색은 `NOT_APPLICABLE`이다.
- 실제 consumer는 auto override의 조기 반환, base board의 authoritative commit/resolve, progress button의 label/tooltip/accessibility였다. resolver·AI·예약·보상·저장·route·audio consumer는 수정할 필요가 없었다.
- 구현 가능성: `FEASIBLE`. 기존 base transition은 완전한 묶음과 target readiness를 검사하고 committed snapshot 뒤 exactly-once resolve를 수행한다.

## 채택한 구조와 이유

- auto override는 완전한 유효 입력에서 계획 surface를 닫고 같은 호출에서 기존 base transition에 위임한다.
- CTA text/accessibility name은 정확히 `행동 실행`; tooltip/description은 완성된 현재 묶음을 한 번 실행한다는 의미로 통일했다.
- `_plan_locked` 저장 필드는 restart/compatibility snapshot을 위해 남기되 player-facing 중간 상태로 진입하지 않는다. resolver와 3/3/4·ultimate reservation·public-only AI 경계는 그대로다.

## 실제 구현·사용 예·기대효과

- 완성된 묶음: `행동 실행` 한 번 → 하단 계획 controls 종료 → committed/resolving/presentation → review.
- 미완성/target 미확정: progress disabled 또는 transition guard에서 거절. resolving 중 반복 입력: 두 번째 resolution을 만들지 않는다. review continue 뒤 `next_bundle_ready`와 다음 3/3/4 묶음은 유지된다.
- 네이티브 캠페인은 과거 목표값 387을 고정하지 않고 실제 관측 `343` activations를 기록했다.

## 검증 증거

- Fresh import: `Godot_v4.7.1-stable_win64_console.exe --headless --editor --path . --quit`; 생성 import/UID는 unstaged 유지.
- RED: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_frontal_duel_plan_lock.gd`가 변경 전 label, one-activation resolution, presentation 진입 3 assertions에서 의도대로 실패.
- GREEN: 같은 focused command PASS. 같은 Godot invocation으로 `verify_combat_board.gd`, `verify_combat_pointer_lock.gd`, `verify_combat_keyboard_accessibility.gd`, `verify_combat_action_reveal.gd`, `verify_combat_presentation_liveness.gd`, `verify_combat_terminal_presentation.gd`, `verify_ultimate_ui.gd` PASS; `python tests/check_prepare_auto_placement_contract.py` PASS.
- 전체 Python: `python -m pytest -q` → `474 passed in 15.95s` (latest-main reconciliation 뒤 최종 재실행; 최초 run `474 passed in 15.85s`).
- ordinary-default native campaign: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/probe_native_ten_duel_campaign.gd` → exit 0, `activations=343`, 10 wins/10 duels, 10 rewards, 36 routes, real terminal HP/history consistency, Shaolin/Yang seven-star와 base ultimate 사용, exact bidirectional resource assertions PASS; elapsed `140394ms`.
- Base validator: 초기 operating-contract check PASS. 생성 import/UID가 없는 clean controller checkout에서 `python C:/Users/user/Documents/GitHub/Base/tools/check_approved_project_operating_contract.py --project-root . --base-repository C:/Users/user/Documents/GitHub/Base --protected-base 12fe75ca795c9af640a58eff975e2a6cbe02888d --approval docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json --external-approval true --check` PASS. 구현 작업트리에서는 의도적으로 보존한 generated import/UID가 추가 protected delta로 감지되므로 exact-path validator를 재해석하지 않는다.
- 알려진 ObjectDB/audio exit warning은 기존 진단이며 억제·수정하지 않았다.

## 5회 전체 범위 적대 검토

1. 승인 의미와 실제 call graph를 공격: auto 조기 반환만 superseded이며 base resolver가 authoritative임을 확인. 별도 resolver 변경을 배제했다.
2. invalid input을 공격: incomplete/target-incomplete는 기존 completeness/target gate에서 차단되고 focused/board/target tests로 유지됨을 확인.
3. 중복·비공개 경계를 공격: resolving 재입력은 disabled/locked로 exactly-once; committed snapshot과 AI public-state input은 무변경임을 diff와 회귀로 확인.
4. 후속 묶음·자원·campaign을 공격: review→`next_bundle_ready`, 3/3/4, reservation, real HP/history, rewards/routes, seven-star/ultimate, resource round-trip이 native run에서 유지됐다.
5. 범위·장기 적합성·비용을 공격: reward/numeric/save/route/audio/engine/art 변화 0, dead alias 추가 0, generated imports unstaged, 보호 manifest는 정확한 3개 product path만 승인. 추가 MUST_FIX 0으로 `CLEAN_REVIEW_EXIT`.

## 자동화·학습 반영

- focused test와 전체 native probe가 single activation exactly-once를 직접 소유하도록 갱신했다. 두-click 기대를 남기지 않고 기존 target/resource/reveal/review assertions는 유지했다.
- 보호 변경은 baseline `12fe75ca…`와 정확한 product path 3개로 `PROJECT_PROTECTED_CHANGE_APPROVAL.json`에 등록했다. archive/promotion은 controller의 merge lifecycle 책임이다.
- `.github/workflows/validate-base-v9-adoption.yml`의 changed-BUILD-record gate를 충족하도록 기존 `BUILD_APPROVAL_2026-09-08.md`에 이전 package를 보존한 별도 CTA continuation을 추가했다.
- Review fix round 1 검증: `git diff --name-only origin/main` 결과에 workflow와 같은 runtime/BUILD 정규식을 적용한 명령 → `CHANGED_PATH_BUILD_GATE PASS runtime=3 build=1`; `python -m unittest tests.test_base_v9_adoption tests.test_approved_protected_change_adoption tests.test_approved_protected_change_workflow tests.test_base_current_work_contract_adaptation` → `Ran 9 tests ... OK`; `python tools/check_project_operating_system.py` → `project operating system: PASS`.

## 미검증·남은 위험

- standalone review 제거는 별도 Blueprint gap이며 이번 범위 밖이다.
- Windows visible physical mouse/keyboard, gamepad, Human UX/fun/readability, accessibility user, Android device/touch/back/safe-area/lifecycle, release performance/rights/store는 `NOT_RUN`이다.
- controller의 독립 review, runtime capture, exact CI, protected merge, postmerge main readback은 아직 수행되지 않았다.
