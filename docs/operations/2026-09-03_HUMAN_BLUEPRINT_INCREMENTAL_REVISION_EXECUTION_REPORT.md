# 2026-09-03 Human Blueprint Incremental Revision · Execution Report

```yaml
work_id: TEN-PUB-20260903-HUMAN-BLUEPRINT-INCREMENTAL-REVISION-01
work_mode: BUILD + REVIEW + PUBLISH
receipt: docs/operations/2026-09-03_HUMAN_BLUEPRINT_INCREMENTAL_REVISION_WORK_CONTRACT_RECEIPT.json
project_pr: 321
base_commit_observed: 0afdef427257ae5f8bcc2f37b7c46e13bc00b44b
branch_head_before_mutation: ae0e59f7d774d95465a8bc125d93c52b79fc386c
base_current_main_observed: 575b44cb3a68c361dcb7a677a98b86c76c0ca16d
work_level: L1
core_rule_change: false
runtime_change: false
save_schema_change: false
new_raster_generation: false
destructive_cleanup: false
implementation_feasibility: FEASIBLE
```

## 작업 전 문제

현재 human PDF는 36쪽 Master GDD를 보존한 46쪽 additive view였으나, 사용자가
필요하다고 한 프로젝트 목표·시스템·케이스별 현재 상태, 단계별 FM(Flow Map),
준비/전투 구분 wireframe, 이미지 제작/합성 provenance는 하나의 실무용 route로
검토하기 어려웠다. 새 PDF를 따로 만들면 두 개의 current Blueprint가 생기므로
기존 human master path를 **누적 개정**해야 했다.

## 조사·비교 결과

| 대상 | 판정 | 근거 |
|---|---|---|
| 36쪽 baseline | `PRESERVE` | `MASTER_PRODUCTION_GDD_20260829.pdf`의 모든 page text가 current output에서 동일 순서로 재현돼야 함 |
| 기존 46쪽 addendum | `EXPAND` | focused flow/card/wireframe layer는 유지하되 planning/production coverage가 더 필요 |
| whole-scene image | `RETAIN_AS_SUPERSEDED_PROVENANCE` | `FRONTAL_COURTYARD_DUEL_SEQUENCE_BOARD_20260902_v2`는 camera/질량 검토용이며 canon/runtime asset이 아님 |
| background/banner/two battlers | `REUSE_ONLY` | user-final-lock·canon registration·runtime consumer가 있으므로 새 이미지 생성/교체 불필요 |
| `TEN-RVC-20260903-003…006` | `USE_AS_MACHINE_EVIDENCE` | preparation, hover detail, plan lock, current-action reveal의 project-bound machine captures |

같은 decision dimension의 10-game benchmark는 project owner에 이미 존재하고 이번
범위는 product rule/UX semantic을 바꾸지 않는 derived publication revision이므로
`REUSED_EVIDENCE`. 외부 product/asset adoption은 하지 않았다.

## 채택한 구조와 이유

`1 cover + 36 exact baseline pages + 15 additive pages = 52 pages`로 확장했다.
새 15쪽은 baseline subject boundary 옆에 interleave되고, baseline은 rasterize,
요약, 순서 변경, 삭제하지 않았다.

| 추가 층 | 내용 | 이유 / 기대 효과 |
|---|---|---|
| Goal/System | core goal, system state, request reason, expected effect | 실행 목적과 다음 안전 작업을 화면 시안 밖에서도 판독 |
| Stage FM | `계획 → 잠금 → 현재 수 공개 → 합 → 정착` | 3/3/4와 hidden-info boundary를 단계별로 구현/검수 |
| Preparation / Combat wireframes | 20/50/30 준비 surface, lock 뒤 전투 확장 surface | 카드·행동잠금·전투 화면의 책임과 비율을 분리 |
| Asset production | whole scene → separated candidate → Godot composition | candidate/canon/runtime evidence를 혼동 없이 재사용 |
| Case matrix | P-01…P-06 state/reason/effect/evidence | `IMPLEMENTED`, `PARTIAL`, `NOT_RUN`의 우선순위를 가시화 |

## 실제 구현 또는 준비 결과

- `tools/build_frontal_duel_visual_blueprint_pdf.py`를 16쪽 reusable addendum
  generator로 확장했다. addendum cover는 non-current이고, 15쪽만 master에
  삽입된다.
- `tools/build_human_game_blueprint_pdf.py`는 52쪽 count와 새 insertion ordering을
  보호한다.
- tall transparent battler modules가 PDF production board에서 crop되지 않도록
  `contain_dimensions` / `draw_image_contain`을 적용했다. 첫 render에서 발견한
  portrait crop/label collision은 smallest surface correction 후 재-render했다.
- current publication:
  `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf`
  - SHA-256: `B2A3CE38E3AEFDACEE91FF5CCDC6B45432A870ECE32A51C362DBB584B27692E4`
  - 52 A4-landscape pages
  - 36 preserved baseline pages + 15 additive pages
  - 3.09 MiB; the generator embeds opaque proof imagery at the 144-DPI
    review resolution and retains alpha only for separated modules, avoiding
    redundant full-resolution copies while preserving the final visual review.

## 사용 예

1. **기획/PM:** goal/system and P-01…P-06 matrix에서 `현재 상태 → 요청 이유 → 기대 효과`를 읽고, human/device gate와 machine evidence를 섞지 않는다.
2. **UI 구현:** preparation wireframe으로 20/50/30 surface와 plan lock의 position/size를 확인하고, combat wireframe으로 lock 뒤에 하단 카드가 사라져야 함을 확인한다.
3. **이미지 제작:** whole-scene candidate로 composition을 검토한 뒤, verified consumer가 있는 module만 분리 후보로 만들고 Godot에서 합성/캡처한다.
4. **연출 검수:** staged FM과 reveal contract를 따라 현재 행동만 공개하고 future action을 노출하지 않는지 확인한다.

## 기대 효과

- 36쪽 GDD의 비전·시스템·QA·risk context는 보존하면서도 최신 전투 화면과
  실제 asset pipeline을 같은 reader route에 둔다.
- 이미지가 문서의 구조를 지우지 않고, wireframe이 실제 visual/runtime evidence를
  대체하지 않는다.
- 이후 image update는 consumer-first, separated-module, explicit evidence ceiling
  절차로 재사용할 수 있다.

## 검증 증거

| 검증 | 결과 | 한계 |
|---|---|---|
| RED | new rendered-PDF regression failed at 46 pages | missing incremental planning layers was correctly detected |
| GREEN | 10 focused human-blueprint profile tests passed | source/PDF behavior only |
| full regression | 458 Python tests passed | no new Godot product path was modified |
| PDF readback | 52 pages; required heading tokens present; all 36 baseline page texts found in order | text readback is not UX validation |
| PDF render | Poppler 144 DPI rendered all 52 final compressed pages; contact-sheet overview plus added page 3/7/9/12/13/14 detailed inspection | rendered image inspection, not human-player study |
| visual correction | full-height contain geometry test RED then GREEN | protects portrait module crop regression |
| Git hygiene | exact `origin/main` is ancestor of task branch; `git diff --check` passed | push/CI readback pending current mutation |

## 자동화·학습 반영

- Added rendered-output contract: a human master that silently falls back to
  46 pages or loses the goal/system/FM/wireframe/image pipeline/case layer
  fails automatically.
- Added a portrait-bound contract for independent transparent modules. This
  prevents reuse evidence from becoming a cropped pseudo-sprite in a human
  production board.
- Added a bounded-publication-size contract. The same 52-page PDF rebuilds
  below 32 MiB by downsampling only to the 144-DPI proof target and JPEG
  compressing opaque evidence; transparent module pixels remain alpha-safe.
- No Base promotion is proposed yet: this is useful project practice, but its
  exact PDF lineage and asset IDs remain Ten Paces-specific.

## 5회 전체 적대 검토

1. **퇴행 공격:** 52쪽 output가 36쪽 source를 덮는지 검사했다. PDF reader가
   baseline 36쪽의 text page를 모두 순서대로 찾았으므로 `CLEAN`.
2. **정본 공격:** PDF가 별도 design canon, 게임 rule 변경, or latest commit claim으로
   읽히는지 검사했다. Markdown/source owner·current PR boundary·machine evidence
   label을 유지해 `CLEAN`.
3. **자산 공격:** superseded whole-scene candidate가 canon/runtime으로 보이거나 locked
   modules가 새로 생성된 것처럼 보이는지 검사했다. 각 상태와 consumer를 page 12/13에
   분리해 `CLEAN`.
4. **표현/가독성 공격:** 144 DPI render에서 all-page blank/crop/overlap을 overview로
   점검하고, new page 3/7/9/12/13/14를 full inspection했다. initial portrait crop와
   module label collision 1건을 확인해 contain helper 및 footer placement로 수정 후
   page 12 rerender에서 `CLEAN`.
5. **증거/확장성 공격:** UI capture가 human/device/release PASS로 과장되거나 P-05 motion
   gap이 삭제되는지 검사했다. P-05=`PARTIAL`, P-06=`NOT_RUN`을 matrix/evidence page에
   유지해 `CLEAN`.

## 미검증·남은 위험

- `P-05` 공격·막기·회피·피격·절초의 자연스러운 합/모션 연속성은 여전히
  `PARTIAL`; current PDF/캡처는 이를 완료로 주장하지 않는다.
- 사람 플레이 비교는 사용자 지시에 따라 보류 상태이며, Windows Human UX,
  Android actual device, accessibility user, release/performance evidence도 `NOT_RUN`.
- 이 문서 패키지는 Godot product paths를 바꾸지 않는다. 다음 product mutation은
  separate implementation package와 actual consumer/evidence를 요구한다.
