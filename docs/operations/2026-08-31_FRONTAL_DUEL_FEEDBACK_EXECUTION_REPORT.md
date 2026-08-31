# 정면 결투·행동 피드백·카드 정보·메인 화면 실행 보고

## 실행 기준

| 항목 | 값 |
| --- | --- |
| 기준 작업트리 | `C:\Users\user\Documents\GitHub\Ninza\tph-r-831` |
| Branch / 시작 HEAD | `codex/user-approved-reconciliation-20260831` / `969ad3e48d530196e86a2741d74e2737f527a9f3` |
| 비교 기준 | `origin/main` `1509317d59d270087c5ff08b696e8ae9d8e7dfce` |
| 현재 PR | #298, `OPEN`, `CLEAN` (2026-08-31 fresh read) |
| Work Mode | `BUILD → REVIEW` |
| 적용 Skill / Mode | project workflow router; test-driven-development; live-editor; systematic-debugging; running-adversarial-review-and-refinement (`attack → validate-critique → refine → regression-recheck → decision-report`) |
| 사용자 권한 | 정면 구도·통일 카드·연출·메인 화면·화면 검증의 계속 진행. 새 raster는 scoped one-result 생성 뒤 별도 final lock을 유지. |

## 작업 전 문제 → 채택 구조와 이유

| 현재 상태 | 요청 이유 | 채택한 최소 변경 | 기대 효과 |
| --- | --- | --- | --- |
| 전투 인물이 idle 때 수직으로 흔들리고 발밑 디버그 십자가가 남음 | 바닥 위에 자연스럽게 서야 함 | `CombatCharacterPlaceholder`의 idle vertical bob과 foot cross를 제거하고 고정 평면 그림자만 유지 | 두 인물이 같은 돌바닥에 서 보이며, 이동·공격 때의 실제 변화도 분명해짐 |
| 평타·합·절초의 해결 피드백이 레이어 뒤로 갈 수 있음 | 한 수씩 공개한 대결의 결과가 분명해야 함 | `CombatBoardPreview`가 공개된 한 이벤트만 차례로 받아 overlay 위 z-index에서 label/motion/ultimate VFX를 표시 | 미래 수를 읽지 않으면서 행동 종류·합·절초 결과를 구별 |
| 무공/절초 카드가 기초 행동 카드보다 압축되어 사거리·소모·효과가 불명확 | 모든 행동을 같은 카드 언어로 읽어야 함 | `ActionViewModelAdapter → ActionChoiceCard` 공통 facts에 사거리·기력·내력·기세·효과를 명시하고 모든 source panel의 세로 공간을 맞춤 | 기초·무공·절초를 동일한 비용/사거리/결과 기준으로 비교 |
| MAIN이 기술적 세로슬라이스 문구 중심 | 게임의 첫 인상을 세계관·대결 약속으로 바꿔야 함 | 기존 시작 route만 호출하는 `MainTitleScreen`을 추가, courtyard/인물/제목/한 개의 시작 버튼만 노출 | 규칙·저장 state를 바꾸지 않고 플레이어용 진입 화면을 확보 |

## 실제 구현 결과

- `CombatCharacterPlaceholder`는 idle에서 `set_process(false)`로 고정되고, 실제 이동/공격에서만 처리된다. 두 캐릭터의 foot anchor는 동일 평면을 사용한다.
- `CombatBoardPreview`는 `presentation_future_action_exposed=false`를 계속 보존한다. 평타·합·절초를 public resolved event에 한정해 각각 `attack`, `clash`, `ultimate` feedback metadata로 내보낸다. 절초의 기존 RGBA ink-gold VFX는 overlay 위에서 표시한다.
- `ActionChoiceCard`는 최소 높이 `138`px로 확장되고 illustration/name/facts/effect가 서로 clip되지 않는다. 0 비용도 숨기지 않으며 `0`으로 표시한다. 빈 `damage_formula`가 `floor(0 + …)`로 보이던 adapter bug도 기본 damage fallback으로 고쳤다.
- `MainTitleScreen`은 `VerticalSliceShell`의 기존 `_on_primary_button_pressed()`만 연결한다. MAIN에서는 기존 technical content panel을 숨기며 setup·briefing·combat에는 영향을 주지 않는다.
- 전투 규칙, 10칸 논리, 거리 판정, 3/3/4, AI privacy boundary, save key, deck/hand/draw 금지는 변경하지 않았다.

## 이미지·자산 상태

| 자산 | 상태 | 증거 / consumer |
| --- | --- | --- |
| `FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1` | `USER_FINAL_LOCKED → CANON_REGISTERED → IMPLEMENTED` | `BattleBackground` |
| `MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1` | `USER_FINAL_LOCKED → CANON_REGISTERED → IMPLEMENTED` | `ActionViewModelAdapter → ActionChoiceCard` |
| `ultimate_ink_gold_sprite_sheet_rgba.png` | `APPROVED_ACTIVE` | `CombatBoardPreview` ultimate feedback |
| normal-attack / clash two-band transparent VFX | `GENERATED_CANDIDATE` | external candidate `exec-a87618fa-38d4-40a5-abf7-7643951e419b`; no repository copy or consumer before final lock |
| title-logo candidate `십보강호 / 숨은 수의 비무` | `GENERATED_CANDIDATE` | external candidate `exec-22d2078f-8dc6-40e5-ac6b-0e91b7f5e232`; SHA-256 `5C75EDBBE02770DDB1D41868A1BEB4A55E802BC53295381D3B204238A3842E13`; 1672×941 PNG; four corners alpha `0` |

### 정확한 구형 파일 정리 판정

`ultimate_ink_gold_sprite_sheet.png` 및 `ultimate_ink_gold_sprite_sheet_transparency_candidate.png`는 runtime/scene/data/doc consumer가 없는 `REJECTED_NOT_ACTIVE` 원본임을 검색으로 확인했다. 각각의 SHA-256은 `F99D1F33A072F443FDF6BA7AAA025EF0A2C7909F0CBBFD52EA0054947CA030D2`, `B6F9BC5EEC8969728E08A3FEE7CAA607743F3B2E9C81913F584922D534FC3853`이다.

그러나 이 실행 환경은 두 binary와 `.import`의 삭제를 차단했다. 실제 파일이 남은 상태에서 manifest entry만 제거하면 orphan conflict가 되므로, 삭제 목록은 비활성 provenance record로 되돌렸다. 이는 `BLOCKED_UNVERIFIED` cleanup이며 활성 RGBA asset에는 영향이 없다. 삭제가 실행 가능한 환경에서 정확한 네 파일만 다시 삭제하고 manifest/readback을 함께 갱신한다.

## 재현된 문제와 복구

자동 생성된 active asset `.import`를 먼저 제거한 뒤 `verify_action_card_source_unification.gd`가 재현 가능하게 실패했다. Godot은 `frontal_courtyard_duel_background_01_v1.png`에 resource loader가 없다고 보고했고, 그 결과 background preload와 board setup이 연쇄적으로 실패했다.

- 원인: 활성 courtyard 및 martial/ultimate atlas의 필요한 Godot import metadata가 없음.
- 비교: 기존 active basic atlas/background에는 matching `.import`가 존재함.
- 단일 가설 검사: 한 번의 `Godot 4.7.1 --headless --editor --import --quit`로 active import를 재생성.
- 결과: 두 active import가 존재하게 되었고, 같은 action-card regression이 다시 PASS.

따라서 active runtime asset의 import metadata는 정리 대상이 아니다. Godot 종료의 ObjectDB/resource warning은 import 명령에서 관측됐으나 exit code는 `0`; 이를 runtime quality PASS로 확대 해석하지 않는다.

## 기계 검증 증거

다음은 Godot 4.7.1 headless에서 모두 exit `0`으로 통과했다.

- `verify_ink_paper_combat_presentation.gd`
- `verify_combat_action_reveal.gd`
- `verify_vertical_slice_shell.gd`
- `verify_action_view_model_adapter.gd`
- `verify_action_selection_dock.gd`
- `verify_basic_action_panel.gd`
- `verify_martial_action_panel.gd`
- `verify_ultimate_action_panel.gd`
- `verify_combat_character_art.gd`
- `verify_frontal_duel_assets.gd`
- `verify_combat_presentation_liveness.gd`
- `verify_combat_terminal_presentation.gd`
- `verify_combat_sfx_presentation.gd`
- `verify_combat_keyboard_accessibility.gd`
- `verify_default_vertical_slice_entry.gd`
- `verify_action_card_source_unification.gd`

추가로 `python tests/test_base_v91_operating_contract.py`는 `2` tests `OK`, `git diff --check`는 exit `0`, `ASSET_MANIFEST.json` parse는 `VALID`다.

## 적대적 전체 개선 loop

각 회차는 scope, user intent, project core, current canon, source/destination/consumer, diff, tests, input/accessibility, asset rights/provenance, rollback/cleanup, PR concurrency, cost, long-term fit, evidence ceiling을 모두 재공격했다. 대표 finding은 아래와 같으며 한 lens를 한 loop로 세지 않았다.

| loop | attack → validate → refine → regression | evidence delta | 판정 |
| --- | --- | --- | --- |
| 1 | cleanup이 manifest만 먼저 제거하면 physical stale binaries가 orphan이 된다는 finding | physical paths, `rg` consumer 0, manifest diff | `MUST_FIX` — manifest entries 복원; JSON parse 재검사 |
| 2 | grounded character와 sequential feedback이 10칸/AI privacy를 건드리는지 재공격 | presentation tests + `future_action_visible=false` scan | no valid core regression; `NO_MATERIAL_FOLLOWUP` |
| 3 | common card facts가 basic-only, clipping, empty formula, accessibility label 회귀를 만드는지 재공격 | card adapter/panel/keyboard tests | empty-formula issue는 이미 minimal fix 후 green; remaining finding 없음 |
| 4 | MAIN start route, technical copy, imported asset loading 및 recoverability를 재공격 | main-entry test, one Godot import, failing→passing card regression | active import is retained; no new implementation defect |
| 5 | open PR overlap, stale user-facing controls, static contract, exact working diff, candidate-state overclaim을 재공격 | PR #298 fresh read `OPEN/CLEAN`, retired hypothesis/skip scan, contract test, diff check, HERA sessions list | no duplicate takeover; title/VFX final lock and correct-editor visible screen remain unresolved gates |

`FULL_LOOP_COUNT=5`는 충족했다. 그러나 현재 범위의 candidate final lock과 visible-screen evidence가 남아 있으므로 `CLEAN_REVIEW_EXIT=NOT_REACHED`; 이를 machine/UX complete로 바꾸지 않는다.

### 대안·장기 적합성 비교

1. **채택 — 공통 `ActionChoiceCard` + semantic atlas + public-event feedback:** 현재 core/저장/AI 경계를 유지하면서 모든 행동을 같은 정보 문법으로 정렬한다.
2. **기각 — 무공/절초별 독립 패널과 별도 연출 상태기계:** 단기적으로 꾸밀 수 있으나 정보 우선순위와 regression surface가 분열된다.
3. **기각 — action reveal이 미래 행동까지 미리 읽어 합 연출을 계산:** 연출은 화려해질 수 있으나 private-plan/순차 공개 계약을 위반한다.

장기적으로 1안만이 새 기술·상태를 추가해도 data→adapter→shared card route를 유지하며, Android adapter와 accessibility labels를 분기시키지 않는다.

## 미검증·남은 위험·다음 안전 작업

- `USER_FINAL_LOCK_REQUIRED`: normal-attack/clash VFX candidate와 title-logo candidate는 별도 image final lock이 필요하다. 확정 전에는 canonical folder, asset manifest, runtime path, production consumer에 넣지 않는다.
- `BLOCKED_UNVERIFIED`: 현재 HERA/Godot session list가 비어 있어, 정확한 `tph-r-831` worktree의 visible MAIN/attack/clash/ultimate screenshot 검증은 수행하지 못했다. 다른 Godot project를 열거나 조작하지 않았다.
- `BLOCKED_UNVERIFIED`: 구형 binary VFX 2개 및 `.import` 2개의 실제 삭제는 실행 환경 차단으로 보류다. 복구 가능한 Git history와 manifest provenance는 유지된다.
- `NOT_RUN`: Windows human UX, Android device/touch/back/safe-area, accessibility-user, performance release, human play comparison, release/rights final clearance.

현재 패키지는 `IMPLEMENTED_AND_MACHINE_VERIFIED_PARTIAL`; 화면 관찰과 두 candidate final lock 전에는 전체 완료나 Human/Device PASS를 주장하지 않는다.
