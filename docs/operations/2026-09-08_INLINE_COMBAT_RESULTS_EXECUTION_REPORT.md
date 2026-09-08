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
- `python -m pytest -q`: 476 PASS.
- native ordinary-default ten-duel campaign: 10 wins, 10 rewards, 36 routes, 299 activations, failures 0, native exit 0. 실제 UI path이며 terminal state injection 없음.
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

Fix round 1은 terminal handoff-start와 confirmation guard를 분리하고 새 loadout lifecycle에서만 reset한다. 반복 finish/deferred 호출은 ready 1회·confirmed 1회와 동일 resources를 검증한다. clash callout은 resolver가 제공한 `raw_damage=15`, `clash_opponent_raw_damage=10`, `clash_difference=5`, `damage=5`를 그대로 표시하며 산술을 수행하지 않는다. 비용은 실제 존재하는 key만 표시한다. Fix round 2에서는 잘못된 사후 상태 주입 flag를 제거하고 실제 이전 production 전환으로 민감도를 재검증했다. inline layout/event regression과 bridge terminal/resource regression을 함께 계약으로 명시했고 두 테스트 모두 실제 CI 호출 목록 및 binding guard에 포함됨을 확인했다. Fix 후 focused/full regression은 구현자 GREEN이며 최종 상태는 controller 독립 재검토 전 `READY_FOR_RE_REVIEW`다.

## 미검증·남은 위험

Windows visible Human usability, 물리 키보드/마우스/게임패드, accessibility user, Android actual device, release performance와 사람 가독성/재미는 `NOT_RUN`. 현재 저장/이어하기는 durable consumer가 없는 것으로 read-only 검색에서 확인됐으며 별도 승인 설계 대상이다. controller의 실제 화면 capture·독립 review·exact-head CI·보호 병합·postmerge closeout은 후속 단계다.
