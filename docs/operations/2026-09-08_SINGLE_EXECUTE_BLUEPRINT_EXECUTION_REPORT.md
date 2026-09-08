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

## 별도 최적화: 동일 action-dock context 재구성 방지

### 작업 전 문제 · 조사·채택 구조

- Task 2 기준 HEAD `ea86c8fe88743d7fa0029bbaefdbc48776ec27f7`; Work Mode `BUILD`; `combat-implementation-handoff/build`, `ten-paces-verification/performance-profile+regression+evidence-report`, TDD, `running-adversarial-review-and-refinement`를 적용했다.
- `CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE`. 동일 consumer의 승인된 Blueprint/10-game packet과 2026-09-08 fresh Godot 공식 optimization guidance를 재사용했다. 측정 후 국소 병목만 줄이는 `ADOPT`, adapter/global cache 및 speculative refactor는 `REJECT`했다.
- 구현 가능성 `FEASIBLE`: `ActionSelectionDock.set_runtime_context`가 동일 loadout/mastery에도 `ActionViewModelAdapter`를 새로 만들고 manual registry를 다시 읽었다. `MartialActionPanel.set_manuals`와 `UltimateActionPanel.set_martial_context`에는 equality guard가 있었지만 그 앞의 dock adapter 비용은 이미 발생했다. Ultimate panel 자체 guard는 owned copy와 readiness flag를 사용해 hidden identical-context registry path가 없음을 확인했다.
- dock에만 `_manual_context_initialized`, owned normalized loadout copy, deep mastery copy를 두고, 두 입력이 실제로 달라질 때만 martial/ultimate manual context를 갱신한다. constraint/resource preview, momentum, reservation과 기타 interaction/target/source/detail 경로는 cache guard 밖에 유지했다.

### 실제 결과 · 사용 예 · 기대효과

- 최초 명시적 empty context는 한 번 초기화한다. 동일 empty/populated input은 manual adapter 경로를 다시 호출하지 않는다. caller가 전달 후 원본 Array/Dictionary를 mutate해도 dock cache/runtime snapshot은 변하지 않는다.
- mastery 3→7 및 loadout identity 변경은 새 view model과 technique/manual identity를 재구성한다. dynamic-only preview actor, constraint, momentum, reservation 변경은 manual registry 재구성 없이 실제 panel output을 갱신한다.
- warmed real dock, four manuals, identical context 100회, synchronous headless 3 samples: 변경 전 controller baseline `539854 / 563441 / 561096 µs`; behavioral RED 임시 baseline `543453 / 545626 / 540126 µs`; 최종 GREEN `1207 / 1187 / 1188 µs`. 같은 microbenchmark에서 중복 파싱 제거를 관측한 것이며 FPS, Windows visible, Android/device 또는 Human-perceived 성능 등가는 주장하지 않는다.

### 검증 증거

- Behavioral RED fix round 1: 최종 production helper seam과 동일한 test instrumentation을 유지하고 `ActionSelectionDock._set_manual_context`에서 invalidation guard/owned cache만 임시 제거한 isolated uncommitted baseline을 실행했다. 같은 focused command가 정상 parse/runtime 뒤 `identical empty expected=1 actual=2`, `identical populated expected=2 actual=4`, `dynamic-only expected=2 actual=5`, `warmed identical expected=4 actual=308`, `ACTION_DOCK_CONTEXT_INVALIDATION_FAILED count=7`로 실패했다. 100회 samples는 `[543453, 545626, 540126]`였다. 이 임시 baseline은 즉시 폐기하고 `git diff --exit-code HEAD --`로 production/test 3경로가 최종 commit과 동일함을 확인했다.
- GREEN/measurement: guard/owned cache 복원 후 `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_action_dock_context_invalidation.gd` → 최종 `ACTION_DOCK_REFRESH_MEASUREMENT identical_100_usec=[1207, 1187, 1188]`, `ACTION_DOCK_CONTEXT_INVALIDATION_OK`; warmed count는 기대 4를 유지했다.
- Fail-closed status fix round 2: PowerShell에서 Godot stdout/stderr를 `$output`으로 받고 즉시 `$nativeCode=$LASTEXITCODE`로 캡처했다. `nativeCode != 0`이면 그 값을 반환하고, native 0이어도 `FAILED` marker 존재 또는 `OK` marker 부재면 wrapper `42`를 반환하는 순서로 실행했다. 동일 guard-only 임시 baseline은 assertions와 `FAILED count=7`, samples `[553713, 558264, 571180]`, `RED_NATIVE_EXIT=1`, 실제 wrapper process status `1`을 반환했다. 최종 경로를 commit 상태로 복원·readback한 GREEN은 samples `[1198, 1349, 1348]`, `ACTION_DOCK_CONTEXT_INVALIDATION_OK`, `GREEN_NATIVE_EXIT=0`, wrapper status `0`이었다. 따라서 이전 shell 표시의 false 0을 성공으로 사용하지 않으며 RED/GREEN process status가 모두 fail-closed로 확인됐다.
- Final whole-branch fix wave: 새 regression이 공통 CI에서 실행되지 않는 P2를 `validate-ten-manual-ui-ai-adoption.yml`의 기존 dock step 바로 뒤에 연결했다. Binding test는 step 부재에서 `1 failed`/exit `1` RED였고, 추가 뒤 current-discovery와 함께 `20 passed`였다. CI step은 Godot output과 `native_status=$?`를 캡처해 native nonzero를 `exit "$native_status"`로 그대로 전파하고, native 0에서도 `ACTION_DOCK_CONTEXT_INVALIDATION_OK` marker가 없으면 `grep -q` nonzero로 닫힌다. 로컬 동등 wrapper는 samples `[1181, 1181, 1158]`, OK marker, native/wrapper exit `0`이었다. Workflow/test/report만 변경하며 protected product manifest와 BUILD scope는 추가 변경하지 않았다.
- Controller final native replay (product HEAD `29173fe6`와 같은 product bytes): 10 wins, 0 draws, 10 rewards, 36 routes, 343 activations, elapsed `133203ms`, failures 0. 이는 headless native campaign evidence이며 physical/Human/Android/release PASS가 아니다.
- 관련 Godot: `verify_action_selection_dock.gd`, `verify_martial_action_panel.gd`, `verify_combat_action_selection_integration.gd`, `verify_bimu_constraint_ui.gd`, `verify_bimu_constraint_runtime.gd`, `verify_ultimate_ui.gd` PASS. Ultimate test 종료의 기존 `2 ObjectDB instances were leaked` warning은 이 변경의 신규 failure로 승격하지 않았다.
- 전체 Python: `python -m pytest -q` → `474 passed in 17.73s`. Task 1 native campaign은 player behavior 변경이 없고 controller가 최종 native replay/capture를 별도 수행하므로 재사용했으며, 이번 task에서 새 Human/device evidence로 승격하지 않았다.
- 운영/보호경로 회귀: `python tools/check_project_operating_system.py` PASS; 지정 unittest 4모듈 `Ran 9 tests ... OK`.

### 5회 전체 범위 적대 검토

1. 초기화/empty를 공격: readiness flag 없이 empty equality가 첫 setup을 건너뛸 위험을 차단했고 explicit empty regression으로 확인했다.
2. aliasing/stale state를 공격: normalized Array와 deep Dictionary를 cache가 소유하며 caller mutation 뒤 retained snapshot/mastery가 유지됨을 확인했다.
3. dynamic consumer를 공격: cache guard를 manual pair에만 한정하고 preview summary, constraint locked count/summary, momentum, reservation의 실제 output 변경을 회귀로 확인했다.
4. genuine change/ultimate를 공격: mastery unlock과 loadout identity가 재구성되고 ultimate panel의 자체 initialized/equality guard가 identical hidden registry path를 차단함을 확인했다.
5. 범위/장기 적합성/비용을 공격: global cache·frame delay·adapter/renderer refactor·data/schema/editor setting·gameplay 변화 0, Task 1 경로 보존, generated import/UID unstaged 유지. 신규 MUST_FIX 0으로 `CLEAN_REVIEW_EXIT`.

### 자동화·학습 반영 · 미검증 위험

- deterministic focused regression은 wall-time threshold 대신 실제 production build seam 호출 수와 실제 panel/view-model output을 검증한다. benchmark 숫자는 진단 출력이며 CI 합격 조건이 아니다.
- 보호 manifest와 same-date BUILD record에 실제 추가 product path 한 개를 append했고 CTA scope 및 기존 경로를 보존했다.
- Windows visible/physical input, gamepad, Human UX/perceived performance, accessibility user, Android actual device/touch/lifecycle, release performance/rights/store, controller independent review/capture/exact CI/merge/readback은 `NOT_RUN`이다.
