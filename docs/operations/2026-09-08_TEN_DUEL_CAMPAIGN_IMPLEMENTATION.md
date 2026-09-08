# 10전 비무행 구현 · 진행 기록

기준: `751f4ee07e84f810015cedaa9c9d77a93016c041`. Work Mode BUILD.
Skill: combat-implementation-handoff/build, ten-paces-verification/runtime-validation,
combat-ux-and-accessibility/runtime-review, test-driven-development.

## 승인과 구현 계약

최신 사용자 지시는 강호행로를 거쳐 비무 10전까지 플레이 가능하게 구현하고 실제
인게임 캡처를 남기는 것이다. 이전 첫 5전 범위는 역사 기준선이다.
기존 15명 후보와 검증된 무공/AI binding을 보존하고 그중 서로 다른 10명을
순서대로 만나는 회차를 연결한다. 새 전투 판정 엔진을 만들지 않는다.
비무 사이에는 세 후보 중 다음 목적지 하나를 고르는 선택을 네 번 반복한다.
9구간 총 36회이며 10전 보상 뒤에는 추가 행로를 만들지 않는다.
정탐은 상대의 보유 능력에 관한 정보이며 미확정/확정 미래 계획을 노출하지 않는다.
저장 포맷 변경, 새 외부 의존성, 유료 에셋 도입은 이 작업에 없다.

## 조사 · 적용 가능성

2026-09-04 THREE_BRANCH_FOUR_CHOICE_ROUTE_BENCHMARK의 10개 사례를
같은 경로 선택 차원에 재사용한다. 2026-09-08 공식 Monster Train 상품 설명에서
장소별 이득과 경로 선택을 다시 확인했다. ADAPT: 결과 범주를 선택 전에 표시.
Darkest Dungeon II 공식 소개는 여정의 준비 구간 비교에 한정한다.
AVOID: 덱/손패/드로우, 파티/마차, 신규 메타 경제.
출처: https://store.steampowered.com/app/1102190/Monster_Train/
https://store.steampowered.com/app/1940340/Darkest_Dungeon_II/
제품 소개는 사람 UX/밸런스 증거가 아니다.

FEASIBLE: 기존 RunState → progression → route shell → combat bridge 소비 경로를
확인했다. catalog는 기존 후보 보존, campaign 순서만 별도 검증한다.
Base remote 68792fc3의 리뷰 상한 변경은 드리프트로 기록하며 프로젝트 채택 pin과
최소 5회 규칙을 조용히 교체하지 않는다. 관련 PR 199/200은 기존 작업 보존.

## 순서와 완료 증거

1. 10전/36행로/중복 입력/패배 재도전 실패 회귀 RED.
2. 회차 순서와 행로 상태를 기존 도메인에 연결.
3. 실제 셸 입력에 세 후보/선택 결과/다음 단계 연결.
4. 기존 회귀 영향 확인, Godot 파싱 및 상태 테스트.
5. 실제 렌더와 입력 캡처, 별도 전체 전투 자동 진행 검증.
6. 정본 상태·로드맵·review·CI·병합 readback.

현재 완료 여부: 작업 중, 미커밋/미병합.
- RED: 기존 구현은 첫 결과 뒤 JIANGHU로 진입하지 못해 테스트 실패.
- GREEN: verify_ten_duel_campaign.gd 통과. 실제 catalog/run state를 사용하지만
  종료 결과를 주입한 상태 테스트이며 열 번 실제 전투를 끝낸 증거는 아니다.
- verify_integration_information_boundaries.gd 통과.
- 기존 verify_vertical_slice_route_state.gd는 옛 2노드 가정을 유지하여 113행에서
  빈 배열 참조로 실패. 교체/회귀 정리가 필요하며 전체 회귀 PASS가 아니다.
- Godot 4.7.1 editor PID 6628 / runtime PID 6348의 exact worktree 확인.
  실제 1280×800 타이틀/전투/행로 캡처 확보. 행로는 종료 결과 주입으로 진입했고
  실제 수련 버튼 클릭 → 다음 갈림길 전환 확인. 최종 시각 품질 승인 아님.
- Hera 설치 CLI는 최신 skill 문서의 --pid 옵션을 지원하지 않음. 한 editor와
  한 runtime만 있는 것을 instances에서 확인하고 exact editor로 제한했다.
  올바른 현행 문법은 game node call ... --arg 값 / game click --text 문구.
- main-before.png / combat-before-atlas-replacement.png는 교체 전 기준선.
  jianghu-functional-checkpoint.png는 새 상태에 연결된 기능용 화면이다.
- 전체 10전 실제 전투, 모든 행로 효과 경계, 재도전 회귀, 전체 CI,
  Human/Android/접근성/출시 검증은 아직 NOT_RUN 또는 미완료.

추가 사용자 지시: 아틀라스 기준으로 기존 이미지 대부분 교체, Blueprint도 개선 가능.
공통 비무장 후보와 제작 요청은 2026-09-08_ATLAS_VISUAL_SUCCESSOR_BRIEF.md에 연결.
남은 작업: 인물 상태군/한지 UI/행로 시각화, 실제 consumer 연결,
기존 5전 테스트 이관, 정탐 단계·제약·보상 UI 등 Blueprint 전체 대조, 10전 전투 검증.
복구: 이 격리 작업의 변경만 되돌릴 수 있으며 원본 승인 자산/다른 worktree는 보존한다.

## Atlas/audio continuation evidence

Latest explicit user instruction authorizes recreation AND runtime connection without
intermediate approval. Final human visual acceptance and asset shipping rights remain
unverified; no candidate is relabeled USER_APPROVED merely by implementation.

- New original blue-ink courtyard connected to battle, title and noncombat shell.
  Source original preserved; source hash and exact consumers in candidate manifest.
- Actual Hera capture `combat-atlas-successor-checkpoint.png`, 1280x800, game PID 24232
  bound to editor 6628. Battle setup reached through real shell methods; not full-play evidence.
- Authored HUD frame covered the parent-drawn resource fills. RED then corrected draw order.
  Unknown opponent resources now show ?/? and no variable-length fill; no covert ratio leak.
- Original nine-cue PCM sound bank caches deterministic resources. Warm at scene creation.
  Separate momentum voice prevents earned-momentum sound replacing the preceding clash.
  Mute/restart/exit and live volume cover both voices.
- `verify_atlas_presentation_successor.gd` RED cases individually observed, then GREEN.
  Final focused run: cold nine cues 36047 us; warm 900 lookups 462 us. This is one host's
  microbenchmark, not whole-game FPS, mobile performance or subjective audio quality evidence.
- Immediate headless shutdown initially reported five audio playback references. Allowing
  the audio server 100ms to drain in the test removes the warning; no production delay added.
- Python unittest discovery: 460 PASS. `verify_frontal_duel_assets.gd` PASS.
- Older ink-paper presentation test still reports three layout/style expectations conflicting
  with current compact cards/dark planning strip. Must reconcile against real geometry,
  not mark broad runtime PASS. The stale hardcoded background metadata was corrected to
  derive from the actual Background constant rather than a second independent path.

### Current external source relevance / decisions

Official Godot stable sources reread 2026-09-08:
- https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html
  ADOPT measured hot-path removal and remeasurement; AVOID unsupported global speed claims.
- https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html
  ADAPT distinct simultaneous cues as bounded voices; changing one stream must not erase
  feedback from another semantic event. No external recording/license introduced.
- https://docs.godotengine.org/en/stable/classes/class_control.html
  ADOPT native UI layout, actual node/capture checks; no rasterized gameplay text.
These engineering references complement, not replace, the existing ten-game benchmark packet.

### Real resolver probe (not synthetic terminal)

`tests/probe_ten_duel_real_resolver.gd` uses the actual metrics resolver, each campaign
candidate's runtime binding, starting four manuals at 3 stars, and actual enemy AI.
The bounded player policy reads public distance and own resources only; it uses basic
quick attack/palm/move/meditate. No health, damage, victory or opponent plan is injected.
Each opponent starts independently: this is NOT a sequential campaign completion test.
Observed: duels 1–8 win in 5–7 bundles; duels 9–10 loss in 5 bundles, enemies left at
9/30 HP. All ten terminate. A zero probe exit means no stall, NOT ten wins or balance PASS.
Follow-up: use actual earned growth/recovery and full shell progression for ten-duel
completion, then visible presentation/input QA. Do not nerf the final opponents just to
make this intentionally simple probe win.

Independent campaign review found earlier recon overwritten by a subsequent investigate
in the same four-step interval. Corrected in 6c76df52, independently reviewed as resolved:
all public clues survive in the existing briefing text API; no hidden plan exposed.

Presentation review cycle evidence (bounded implementation, not full product acceptance):
1. Source/consumer review: replaced hardcoded stale background metadata with the actual
   loaded source constant; preserved old approved binaries and final-review boundary.
2. Runtime rendering review: authored wells hid live fill, then duplicated it when exposed.
   Retired baked HUD wells/portrait visibility and kept native live status UI instead.
3. Information/audio boundaries: hidden enemy ratios masked; momentum cannot overwrite
   clash voice; volume/mute/reset/exit tested for the actual players.
4. Independent consumer/viewport review: 720p chips overlapped momentum. RED two failures,
   shared draw/test geometry + compact resource rows, GREEN at 340x128 with two states.
5. Test/long-term review: historical charcoal-on-dark and 88px/50px compact-card assumptions
   reconciled to current native dark strip and complete 80px card stack with non-overlap.
   No claim that compact cards yet satisfy all requested always-visible effect summaries.
   Full card/briefing/route editorial integration remains a distinct unfinished task.

Current focused PASS: atlas successor, frontal assets, ink-paper presentation,
combat board, screen partition, combat SFX. Native-status rendered capture:
`combat-atlas-native-status.png` at 1280x800 (before the final 720p geometry refinement).

### Rest consumer continuation

Reused existing Blueprint inn illustration unchanged (SHA-256 recorded in rest-runtime-manifest).
The same ten-game route benchmark applies: this connects the approved rest outcome, not
a new economy, choice count, or event effect. Existing run-state remains the sole recovery owner.
Rest changes only backdrop and composition; resolved options hide, continuation restores
the next three-choice screen. Regression RED: missing art, wrong panel position, disabled
choices retained. GREEN after binding; duplicate selection cannot heal twice. Existing
shell regression also PASS. Actual 1280x800 capture reviewed: traveller unobscured, native
Korean text and continuation visible. Synthetic terminal used to reach scene is NOT duel evidence.
Final human visual approval, rights release review and Android runtime remain NOT_RUN.

### Sequential probe independent review correction

c11ad041/2904c9e9 initially reported ten wins with retained run history. Independent
review found make_initial_state resets resource currents after the probe set its HUD
values. Actual shell applies resources AFTER initialization. Thus that probe run proves
resolver termination under reset resources, NOT accumulated-resource campaign completion.
The initial completion claim is withdrawn. Required fix: post-initialization application
and exact resource equality assertion before the first resolver in every duel/retry,
then honest rerun. Prior independent and synthetic tests remain their bounded evidence.

Correction f011c704: exact handoff equality initially RED at duel 2; post-init resources
now match before all ten attempted entries. Corrected simple policy wins duels 1–8 then
loses duel 9 and its legal retry (enemy 2 HP). Duel 10 NOT_REACHED; bounded public-policy
improvement continues. This is not proof that the product is unwinnable.

Route backdrop now uses one original mountain/river illustration, generated with the
built-in image model and source/hash/brief retained. Native three choices remain separate.
Rest→next route→briefing background transitions PASS, actual 1280×800 route capture reviewed.
Window title no longer claims five-duel slice; reward copy no longer falsely defers existing
progression to a future phase. Both copy regressions observed RED then GREEN; result test PASS.

Capture tooling lesson: changing project.godot name while the editor is open left its
in-memory name and userdata discovery stale. Game process existed but Hera could not find
it. Exact-session stop and synchronization of the already-authorized project setting
restored capture; no other editor or project was changed. Shared headless test logs are
not reliable proof of the visible game's cleanliness; use exact runtime capture/identity.

### Corrected sequential completion and preparation readback

The final public policy at 79408303 completed ten actual resolver wins with no retry,
ten rewards and 36 offered route choices. Controller and independent reviewer reran it:
exit 0, final resources health 9/30, stamina 1/5, internal 2/4, ten base ultimate uses.
Seven-star Shaolin and Yang techniques actually resolved. Exact accumulated resource
equality is asserted before every first resolver. Earlier invalid and failed policies
remain historical counterexamples in the task report, not current completion evidence.

Independent review: no hidden enemy plan read or arbitrary victory/resource injection.
The probe DOES directly apply production-equivalent resource handoff and ultimate
reservation, so its evidence ceiling is deterministic headless resolver/RunState
integration, NOT UI placement input, global balance or Human gameplay acceptance.

Preparation summaries now show action slots, stamina/internal cost, range, movement
and main effect magnitude. Numerical previews use the combat engine's existing formula;
missing actor data has an explicit formula fallback. A shared lazy engine removes
per-card JSON/AI initialization. No FPS improvement claim is made without profiling.
Actual first capture revealed summary overflow despite parent bounds passing. RED tests
now inspect each rendered label and row overlap at 720p/800p. Cards are 98px, font remains
11px and artwork is retained; corrected 1280x800 capture reviewed with no label overflow:
`docs/runtime-captures/TEN-ATLAS-SUCCESSOR-20260908/combat-card-summaries-fixed-1280x800.png`.
This capture enters combat via normal shell methods, not synthetic terminal injection.

Briefing copy removes internal AI/seed terminology and the removed recent-rating line.
Owned manuals display current mastery as a number plus one star. Regression observed
four RED assertions, then GREEN. This copy repair does not implement the still-missing
constraint selection or detailed scout-level status panels. Full Python suite: 470 PASS.

Current remaining product gaps: visible-input full campaign, rich node/event scenes,
briefing constraints and scout-level status, target currency/training/grade rewards,
actor/VFX polish, Blueprint reconciliation. Human, Android, rights and release remain
NOT_RUN. This integration package is a verified increment, not the entire Blueprint.

### Final real-consumer review corrections

Independent delivery review caught two missed consumers: martial `effect_steps` attacks
were falsely labeled raw power 0, and detail-hover created a fresh engine. Real ten-manual
attack coverage reproduced 43 RED assertions; 1b4b68f6 now reports single unconditional
raw attack power, otherwise a truthful conditional/multihit label, and shares one read-only
preview engine across cards and detail. Reviewer reran the sequential probe: still 10 wins.

Controller's actual martial-tab capture then found left-offscreen clipping caused by the
four-manual selector's minimum width. de71c6cd adds native horizontal scrolling without
shrinking fonts or deleting manual information. Six RED containment assertions now pass
at 720p/800p, including first/last selectable manual and technique card bounds. Corrected
actual capture reviewed: `docs/runtime-captures/TEN-ATLAS-SUCCESSOR-20260908/martial-summary-fixed-1280x800.png`.
The earlier offscreen capture is not final evidence. The six new campaign/presentation
checks now execute in the product CI job after import; a Python contract guards that wiring.

### Cross-platform final-gate corrections

313ffc9c replaces the fixed 98px height with a minimum 104px and measured native
summary height plus 4px padding; the 112px viewport ceiling remains tested. The native
manual scroll follows keyboard focus. At a00f2030 Windows and Linux product CI both
passed, including the new card bounds test. This does not imply the separate Full
Validation workflow was finished: it exposed a legacy <=84px / art>=30px assertion.
581dd6ef updates that test to actual content bounds and explicit quit(1) on failure,
preventing a failed assertion from leaving the Godot process alive. 9ae2dc4c removes
the corresponding obsolete exact 98px Python source contract. Full pytest: 472 PASS.

Fresh native 1280x800 capture after the dynamic-height fix:
`docs/runtime-captures/TEN-ATLAS-SUCCESSOR-20260908/martial-dynamic-layout-1280x800.png`.
Hera editor 6628, game 23852; normal start/manual selection/briefing/preparation
methods then actual martial-tab click. No synthetic terminal or resource injection.
Capture shows the native horizontal selector and retained cards; actor art, density
and final Human readability remain follow-up work, not final art acceptance.

PR 323 archived PR 321's exact approval JSON/hash, added inactive-authority markers,
and promoted only the protected baseline. Exact-head checks and independent review
passed; merged main a0d4d967b81ab4a6ce8dc4623546fecceceb4307 read back. PR 322 now
has its own 27-path approval matching its product diff. Generated local imports/UIDs
and raw exploratory captures were preserved, never bulk-staged. Its old stalled Full
Validation run was cancelled after the concrete obsolete assertion was identified;
new exact-head CI must pass before merge. No protected-rule bypass was used.
