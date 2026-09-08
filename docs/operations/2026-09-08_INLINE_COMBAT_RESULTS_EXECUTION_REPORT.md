# Inline combat results implementation execution report

## 작업 전 문제

해결 뒤 활성 제품 흐름이 별도 복기 오버레이와 추가 확인 클릭에서 멈췄고, 1280×720 계열에서 `RevealResult`가 명목 카드 높이보다 커진 callout과 겹쳤다. 결과 원인은 resolver가 이미 만든 summary/event에 있었지만 active 화면과 terminal Result가 일관되게 소비하지 않았다.

## 조사·비교 결과

`CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE`. 같은 reveal/replay 차원의 9월 1일 열 게임 비교와 9월 4일 승인 Decision을 재사용했다. Godot Container/Label 공식 문서에 따라 실제 combined minimum size와 wrap 경계를 채택했다. 새 게임 메커니즘·새 자산·새 외부 비용은 없다.

## 채택한 구조와 이유

- base board가 `_finish_bundle_presentation(terminal)`과 `_advance_to_next_bundle()`을 소유한다.
- 비종료 묶음은 실제 `CombatReviewSummaryBuilder` cause를 inline label에 보존하고 자동으로 다음 묶음을 연다.
- 종료 묶음은 bridge가 기존 terminal receipt를 ready→deferred confirmed 순서로 한 번씩 방출한다. RunState의 내부 `REVIEW` 이름과 API는 유지된다.
- Result model/shell은 같은 immutable `review_summary.cause_label`을 표시한다.
- reveal callout은 `get_combined_minimum_size()`로 높이를 산정하고 결과 strip을 그 아래에 둔다. 공격 event에 이미 존재하는 raw power와 resource cost만 표시하며 UI 계산은 하지 않는다.

## 실제 구현 또는 준비 결과

활성 standalone review overlay/click을 제거했고 standalone terminal에서는 기존 restart control만 남겼다. 기존 legacy review scene과 고립 unit consumer는 삭제하지 않았다. CI 두 제품 경로에 `verify_inline_combat_results.gd`를 연결했고 active board/reveal/liveness/terminal/bridge/native campaign fixture를 새 흐름으로 이관했다.

## 사용 예·기대효과

플레이어는 한 묶음 해결 직후 실제 원인을 전투 화면에서 읽고 추가 클릭 없이 다음 계획으로 복귀한다. 마지막 해결은 실제 원인·metrics·resources를 별도 Result에 한 번 전달한다. 720/800/1080 layout regression은 callout과 result rect가 겹치거나 region 밖으로 나가면 실패한다.

## 검증 증거

- Godot 4.7.1 fresh editor import: native exit 0. import가 만든 `.import`/`.uid` churn은 소유 변경에서 제외.
- focused inline/board/reveal/liveness/terminal/bridge/result regressions: PASS, native exit 0.
- fix round 2 current readback: `verify_inline_combat_results.gd` native exit 0, `verify_vertical_slice_combat_bridge.gd` native exit 0, `tests/test_campaign_runtime_ci.py` 2 PASS; inline과 bridge의 실제 CI 호출을 함께 검증했다.
- final layout wave prospective RED: 실제 rect 검사를 추가한 parse-clean regression이 callout/VS, heading/phase/callout 침범과 1280×720·1280×800 inline/timing-slot 교차로 native exit 1이었다. 이는 controller의 1280×800 capture에서 짧은 4줄 callout이 약 325px로 남은 실제 결함을 재현한 뒤 production 수정 전에 기록했다. 활성 `ActionSelectionDock` source tab/visible card 검사를 추가하자 nominal timing height만 사용한 중간 수정도 720/800에서 bounded-row와 timing-slot invariant로 native exit 1이었다. 그 세로 행 수정은 720에서 dock top 536px, 최소 176px와 bottom margin을 합쳐도 712px이고 실제 readable card minimum은 이를 넘어 일부 visible button이 viewport 밖으로 나가 native exit 1이었다.
- final layout wave GREEN: reveal은 목표 폭을 먼저 고정하고 wrapped label/container가 정착한 뒤 실제 minimum height를 deferred 재측정한다. heading·phase·양쪽 callout·VS·result의 region 포함/비교차, short→long→short 높이 reset과 720/800/1080 배치를 검사한다. 최종 correction은 원래 dock/timing/duel 세로 예산을 복원하고 timing panel 및 progress control 오른쪽부터 활성 dock 오른쪽 경계까지의 남는 폭을 bounded causal lane으로 사용한다. deferred readback은 timing/progress/source tabs/visible product action cards 비교차와 모든 visible card의 viewport 포함을 확인한다. focused inline/reveal/board/partition/liveness/bridge/action-source 7개는 모두 native exit 0.
- `python -m pytest -q`: 476 PASS.
- native ordinary-default ten-duel campaign: 10 wins, 10 rewards, 36 routes, 299 activations, failures 0, native exit 0. 실제 UI path이며 terminal state injection 없음.
- final layout wave 뒤 ordinary-default native campaign 재실행: 10 wins, 10 rewards, 36 routes, 299 activations, failures 0, native exit 0. 별도 synthetic terminal-state smoke의 PASS는 이 증거로 사용하지 않았다.
- CI compatibility correction: PR #331 exact head `51fd10c6`의 네 matrix가 pytest 기본 수집 밖 standalone `check_repeat_poc_a3_contract.py`에서 제거된 `_show_review_panel`을 요구해 실패했다. 로컬 exact command도 assertion과 exit 1을 재현했다. A3는 legacy panel component/isolated test를 보존하되 active board에는 `_finish_bundle_presentation`, inline cause, hidden overlay와 automatic next bundle을 요구하도록 이관했고 pytest가 standalone guard를 subprocess로 실행한다. Workflow의 `verify_combat_review_ui.gd` active-board 절반도 실제 3-card UI 실행 뒤 next-ready/inline/hidden-overlay를 검증하도록 이관했다.
- 같은 audit에서 workflow `verify_combat_action_selection_integration.gd`가 `review_ready`를 직접 주입한 뒤 assertion line 57에서 멈추고 SceneTree를 종료하지 않아 30초 이후에도 살아 있는 native RED를 재현했다. 승인 흐름 `resolving → next_bundle_ready`로 바꾸고 모든 실패를 `_expect`로 수집해 명시적 `quit(1)`로 종료한다. A3 및 9개 standalone workflow Python checks exit 0, pytest CI guard 3 PASS, review UI/action-selection integration 및 관련 inline/liveness/terminal/bridge/result native checks exit 0이다. 제품 코드는 변경하지 않았다.
- RED 한계: 새 regression을 구현 변경 뒤 작성해 별도 behavioral nonzero RED를 캡처하지 못했다. 기존 `verify_combat_board.gd`는 이관 전 old `review_ready` 기대 때문에 실제 nonzero였지만 이는 새 요구의 독립 RED 증거로 승격하지 않는다.
- protected lifecycle: fresh-import worktree에서는 generated `.import`/`.uid` delta 때문에 local nonzero였지만, controller가 clean `6ba11a32`에서 exact manifest lifecycle과 Base operating validators PASS를 확인했다. 생성 churn은 제품 변경으로 승인·커밋하지 않았다.
- fix round 1 prospective RED: duplicate terminal finish는 ready signal `actual=2`로 native exit 1, clash/cost regression은 `15 vs 10 · 차이 5` 누락과 존재하지 않는 `내력0` 표시로 native exit 1. parse-only 실패를 먼저 제거한 뒤 behavior RED를 기록했다.
- `RETROSPECTIVE_REGRESSION_SENSITIVITY`: exact `ccebd6b199454da0109934d0ab9c23e214c6a9c9`를 detached 격리 worktree에 체크아웃하고, 최종 test/helper는 그대로 둔 채 production의 `_finish_bundle_presentation` 전환만 기존 `review_ready` + standalone summary 표시로 임시 되돌렸다. fresh import는 exit 0이었고 `Godot_v4.7.1-stable_win64_console.exe --headless --path <isolated-worktree> --script res://tests/verify_inline_combat_results.gd`는 `No modal review click is required`, `No standalone product review overlay`, `Actual inline cause is retained`로 실패하여 native exit 1이었다. 이는 실제 이전 production 전환에 대한 regression 민감도 증거이며 최초 구현의 TDD chronology를 대체하지 않는다.

## 자동화·학습 반영

아래 5회는 최초 구현자의 자체검토 기록이다. 당시 `CLEAN_REVIEW_EXIT`로 판단했지만 이후 독립 review가 terminal 중복 ready와 causal field 표시 결함을 발견했으므로 최종 독립 clean 판정이 아니다.

1. 정본/코어 공격: resolver와 summary builder를 유지하고 UI 계산 추가 없음 — CLEAN.
2. diff/untouched consumer 공격: legacy isolated widget 보존, active review-click fixture 이관 — CLEAN.
3. receipt/teardown 공격: ready 뒤 deferred confirmed, once meta guard, campaign 10 terminal handoff — CLEAN.
4. layout/접근성 공격: 1280×720·1280×800·1920×1080 bounded rect, wrap/font 유지 — MACHINE CLEAN; Human 별도.
5. 장기 적합성/범위 공격: 새 overlay·scene·asset/schema 없이 기존 hook/model 확장, campaign resource/reward/history 통과 — CLEAN_REVIEW_EXIT.

Fix round 1은 terminal handoff-start와 confirmation guard를 분리하고 새 loadout lifecycle에서만 reset한다. 반복 finish/deferred 호출은 ready 1회·confirmed 1회와 동일 resources를 검증한다. clash callout은 resolver가 제공한 `raw_damage=15`, `clash_opponent_raw_damage=10`, `clash_difference=5`, `damage=5`를 그대로 표시하며 산술을 수행하지 않는다. 비용은 실제 존재하는 key만 표시한다. Fix round 2에서는 잘못된 사후 상태 주입 flag를 제거하고 실제 이전 production 전환으로 민감도를 재검증했다. inline layout/event regression과 bridge terminal/resource regression을 함께 계약으로 명시했고 두 테스트 모두 실제 CI 호출 목록 및 binding guard에 포함됨을 확인했다. Final layout wave에서는 stale minimum-height와 nowrap width 침범을 width-first/deferred container 배치로 교정하고, inline 결과를 legacy `timing_row_y - 58` 좌표 대신 timing/progress 오른쪽의 bounded causal lane에 배치했다. Fix 후 focused/full regression은 구현자 GREEN이며 최종 상태는 controller 독립 재검토 전 `READY_FOR_RE_REVIEW`다.

## 미검증·남은 위험

### Controller exact-source readback

- Independent task review and final scoped code review: approved through `5eb580e6063abf3881b93e7d0da2d19521e33387`. Final review caught an introduced 720/800p card overflow; the corrective commit restores the original vertical budget and places the cause beside the progress control. This required an explicitly recorded extension of the default final fix-wave cap under the user's continuous correction instruction; no failing layout was merged.
- Independent Python suite at `5a188391`: 477 passed in 17.08s. Final source changes after that are layout and its native acceptance only; exact-head CI remains required.
- Actual Windows Godot editor 6628, game 18856, source `5eb580e6`, 1280×800: setup → briefing → three guard actions → one execute click → reveal → automatic bundle 2 readiness. No review-confirmation input, no terminal-state injection. Game stopped after capture; diagnostics 0 errors / 0 warnings during this run, not an audio-exit or Human acceptance claim.
- `docs/runtime-captures/inline-reveal-fixed-20260908.png`: SHA-256 `0FCFAADCDF08904AB37728C4A9AE4685E357A60E3AC81C40D86F3860AFDB315A`.
- `docs/runtime-captures/inline-next-ready-fixed-20260908.png`: SHA-256 `5C9BD018CAC6C4C75D8680312CF889E64657F3012F8756904B39A326191C58E9`.
- Controller and independent reviewer inspected both images: compact callouts, separated result text, cause beside the CTA, all ten basic cards visible. Bounded visual evidence applies only to these two 1280×800 states. Long clash, 720p and 1080p have machine geometry coverage, not equivalent visible captures.

Windows visible Human usability, 물리 키보드/마우스/게임패드, accessibility user, Android actual device, release performance와 사람 가독성/재미는 `NOT_RUN`. 현재 저장/이어하기는 durable consumer가 없는 것으로 read-only 검색에서 확인됐으며 별도 설계·구현이 남는다. 위 두 상태 capture와 독립 review는 완료했고, exact-head CI·보호 병합·postmerge closeout은 후속 단계다.

## Postmerge closeout

PR 331 exact implementation head `0371f886daf83683130c81437a2e2e6132d27628`은 `32 SUCCESS / 0 FAIL / 0 PENDING`, CLEAN, unresolved threads `[]` 뒤 2026-09-08T12:23:10Z에 normal merge되어 main `bf161025b63edd7eb441b2c4f2ae9da5155f68da`가 됐다. Controller detached-main readback은 Python 478 PASS(15.52s), protected lifecycle PASS, Base operating validator PASS다.

Closeout branch는 archive/current-owner regression 추가 뒤 Python 480 PASS(15.05s), adopted Base `19355b7ef065a21d0f2b685c7d9be64a4a3970f8` generator check 및 operating validator PASS다.

Closeout review는 최초 archive regression이 향후의 모든 active approval manifest까지 금지하는 과도한 조건과 current routing owner 네 필드의 stale 값을 발견했다. 교정 전 linked-current regression은 `1 failed, 2 passed`(exit 1)로 `ACTIVE_CONTEXT.next_package`의 기존 native-campaign route를 포착했다. 교정 후 archive guard는 이후 별도 scope의 active approval을 허용하되 PR 331의 exact retired bytes 재활성화만 금지하며, `ACTIVE_CONTEXT`의 `next_package`·`user_directed_planning_next_package`·`user_directed_planning_status`와 `current_operating_state.json`의 `next_package`·`active_decision_state`를 merged inline-results 상태 및 `BLUEPRINT_SAVE_CONTINUE_AND_EVENT_STATUS_REWARD_CANON_GAPS`로 연결한다.

첫 전체 재검사는 `19 failed, 462 passed`로 current discovery의 과거 literal 기대와 `ACTIVE_CONTEXT.active_decision_state` 한 필드가 아직 연결되지 않은 사실을 추가 포착했다. 해당 current consumer만 같은 merged 상태로 이관한 뒤 관련 87 PASS, 전체 Python 481 PASS(14.75s), committed focused 22 PASS, protected lifecycle PASS, adopted Base operating validator PASS를 확인했다. 이 교정은 current routing/test authority에 한정되며 역사 snapshot이나 제품 코드는 바꾸지 않는다.

초기 exact head `51fd10c6`의 A3 standalone checker 실패와 native action-selection assertion 후 hang은 숨기지 않는다. test-only `0371f886`가 retired standalone review 기대를 inline/no-overlay/automatic-next 계약과 bounded failure exit로 이관했다. 최종 제품 commit `5eb580e6` 및 controller capture bytes는 그 교정에서 변하지 않았다. Active approval은 merged Git blob 그대로 `docs/operations/2026-09-08_PR331_PROTECTED_CHANGE_APPROVAL_RECORD.md`에 보존하고 종료했다. 다음 safe work는 durable save/continue와 event/status/reward canon gap이며 전체 Blueprint, Human/device/accessibility/release 완료가 아니다.
