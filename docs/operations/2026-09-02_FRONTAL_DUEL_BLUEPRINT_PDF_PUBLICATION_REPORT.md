# 2026-09-02 정면 결투 블루프린트 PDF 발행 · Execution Report

```yaml
work_id: TEN-PUB-20260902-FRONTAL-DUEL-BLUEPRINT-PDF-01
work_mode: PLAN + PUBLISH + REVIEW
skill:
  - managing-design-documents/publish+validate
  - ten-paces-verification/evidence-report
  - synchronizing-local-and-github-state/preflight+publish+verify
initial_publication_parent_sha: d0a641ce6a9d3920d33f27446e47d06efd1d550a
image_correction_parent_sha: 255d1152a5be0db7e36a0a6068a532b653ae4fa5
image_correction_branch: codex/frontal-duel-visual-blueprint-pdf-20260902
image_correction_output_sha256: ED9A36F9800BFA23C455CFEF1981E85789E7A39103BC949634EC9D95AA579B58
hybrid_restoration_parent_sha: fba401848ff9d2a704e8f1e8e330e8f5ef67f3f3
hybrid_restoration_rebased_write_parent_sha: 5e57f4de88ca92648cf2e6155b99db3ee77d9670
hybrid_restoration_branch: codex/frontal-duel-blueprint-hybrid-restoration-20260902
hybrid_restoration_output_sha256: 07E87BAEC46D068928DE2AA3B9D8B11EC8D9AC5E179C8E6BF71FBF782CE87576
current_base_main_observed_2026_09_02: aaa94caf5772c262f023dd9e80fd4b8bbffd85db
authority_domain: HUMAN_GDD_PDF_DERIVED_VIEW
core_rule_change: false
runtime_or_save_change: false
new_runtime_raster: false
implementation_feasibility: FEASIBLE
```

`initial_publication_parent_sha`는 최초 PDF 발행의 역사 기준이고, 이번 이미지 중심 보정의 write parent는 `image_correction_parent_sha`다. 두 값을 섞어 현재 기준 SHA로 읽지 않는다.

## 사용자 약속과 책임 범위

사용자는 권장안에 따라 현재 전투 블루프린트를 PDF로 보고, 앞으로 실제 소비처가 확인된 이미지는 생성 전 별도 승인을 기다리지 말고 제작하라고 지시했다.

현재 PDF는 기존 정본을 읽기 쉬운 **10쪽 하이브리드 파생본**으로 발행하는 작업이다. 실제 Godot/승인 이미지를 먼저 보여 주되, 이전본의 흐름 맵과 두 와이어프레임도 구조 설계 레이어로 보존한다. 전투 규칙, 저장, Godot scene/code, 승인 자산, 이미지 정본 상태를 바꾸지 않으며, 독립 정본이 아니다.

## 최초 발행 당시 정본·동시성 readback (역사 기록)

- local `main`과 `origin/main`은 시작 시 `d0a641ce6a9d3920d33f27446e47d06efd1d550a`에서 일치했다.
- 관련 열린 PR은 없었다. PR #199와 PR #200은 서로 다른 기존 draft 문서 작업으로 read-only 보존했다.
- `docs/design/2026-09-01_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT.md`가 화면 흐름·와이어프레임·카드 계약의 책임 원본이다.
- `docs/decisions/2026-09-01_ACTION_PLAN_LOCK_AND_EXECUTE_CTA_DECISION.md`가 `행동계획 잠금 → N수 실행` 입력 semantics의 책임 원본이다.
- `docs/reviews/2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md`의 10개 공식 사례 packet은 같은 decision dimension과 같은 current product state이므로 `REUSED_EVIDENCE`로 사용했다. 새 규칙·UX·자산 선택을 추가하지 않아 별도 10개 패킷을 중복 생성하지 않았다.

## PDF 발행 결과

| 항목 | 결과 |
| --- | --- |
| 파생 PDF | `output/pdf/TEN_PACES_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT_2026-09-02.pdf` |
| 페이지 | A4 landscape 10쪽 |
| 입력 | current blueprint, action-plan-lock Decision, benchmark, actual consumer/asset state, approved visual board, current runtime captures, existing runtime-evidence ceiling |
| 출력 SHA-256 | `07E87BAEC46D068928DE2AA3B9D8B11EC8D9AC5E179C8E6BF71FBF782CE87576` |
| 포함 | 실제 Godot 화면·승인 시각 보드·카드 계약, 3/3/4 흐름 맵, 계획/공개 구조 와이어프레임, 잠금→공개→합 구현 contract, asset/evidence boundary |
| 제외 | 새 rules, numerical balance, future action preview, deck/hand/draw, new image candidate, Human/device PASS claim |

## 2026-09-02 사람용 Master GDD 무손실 복원

### 작업 전 문제

사용자가 기존 36쪽 사람용 GDD를 10쪽 focused action-flow PDF로 잘못 축소해 “최종 블루프린트”처럼 읽히는 퇴행을 지적했다. 10쪽 파일은 전투 흐름의 유용한 보조 자료였지만, 36쪽 source의 비전, player journey, 시스템 지도, AI 경계, 콘텐츠, 플랫폼, QA, 위험, register를 대체하지 못한다.

### 채택한 구조와 이유

`HUMAN_BLUEPRINT_ADDITIVE_20260902`를 채택했다. 새 `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf`는 다음만 수행한다.

1. 사람이 읽을 current cover 1쪽을 제공한다.
2. `exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260829.pdf`의 36쪽을 rasterize·요약·순서변경 없이 그대로 포함한다.
3. 기존 focused generator의 visual direction, actual planning capture, 3/3/4 flow, planning/reveal wireframe, card/evidence/handoff 9쪽을 관련 baseline section 곁에 interleave한다.

그러므로 현재 PDF는 총 46쪽이며, 36쪽 source와 10쪽 focused output 중 어느 것도 “10쪽으로 대체된 인간용 정본”이라고 주장하지 않는다. 기존 10쪽 output은 current master 역할에서 제거된 `ABSORBED_DERIVED_OUTPUT`이다.

### 실제 산출물 및 증거 경계

| 항목 | 결과 |
| --- | --- |
| current human master | `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf` |
| page structure | 1 current cover + 36 exact baseline pages + 9 visual/wireframe addendum pages = 46 |
| output SHA-256 | `B92CB4D40881E405E71D69659E0EF981D5C9E9FC5FEAB96E55F66069490115C7` |
| preserved source | `exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260829.pdf` (`PRESERVED_BASELINE_SOURCE_36_PAGES`) |
| focused output | `output/pdf/TEN_PACES_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT_2026-09-02.pdf` (`ABSORBED_DERIVED_OUTPUT`; no current-master role) |
| image state | newly generated modular courtyard/banner/character candidates are deliberately excluded until a separate user final lock; no candidate is represented as runtime or human proof |

The assembler is `tools/build_human_game_blueprint_pdf.py`. It writes atomically, checks the baseline page count before assembly, and fails if the expected 46-page result cannot be produced. The profile test proves that every 36-page source text page reappears in the same order in the 46-page output.

## 2026-09-02 이미지 중심 발행 보정

### 발견과 판정

사용자 검토에서 기존 PDF는 표지에만 정면 석정 background를 사용하고, 본문의 계획·카드·공개 설명을 일반적인 텍스트 도식으로 축소한 것이 확인됐다. 이는 이미 승인된 `PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2`와 실제 Godot runtime capture가 제공하는 시각적 기준보다 약한 사람용 표현이다.

판정은 `MUST_FIX / OMISSION`이다. 전투 규칙·저장·Godot 제품 경로는 바꾸지 않지만, 같은 source를 읽는 `HUMAN_GDD_PDF_DERIVED_VIEW`는 이미지 우선으로 재발행해야 한다.

`CURRENT_SOURCE_RELEVANCE_CHECK`: `NOT_APPLICABLE_WITH_REASON`. 이번 결함의 사실은 시장·엔진·외부 자산의 최신 정보가 아니라 repository 안의 current PDF, final-locked visual board, runtime captures, asset consumer와 render 결과로 완결된다. 새 외부 이미지·plugin·gameplay mechanism을 채택하지 않아 외부 조사 결과가 이 보정 방향을 바꾸지 않는다.

`IMPLEMENTATION_FEASIBILITY`: `FEASIBLE`. Markdown 정본, final-locked/implemented visual inputs, Python PDF generator, Poppler render, pypdf readback과 관련 regression test가 모두 current repository에 존재한다. 제품 protected path를 변경하지 않고 파생 PDF만 원자적으로 교체할 수 있다.

### 보정 범위

- 계획 편집 본문에는 `TEN-RVC-20260901-001`과 `TEN-RVC-20260901-005`의 실제 Godot 화면을 사용한다.
- 시각 방향 페이지에는 user-final-locked `PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2`를 전체 크기로 사용한다.
- 통합 카드 페이지에는 current semantic atlas와 실제 runtime card rack을, 합 연출 페이지에는 final-locked visual board의 합 방향과 현재 VFX consumer 계약을 사용한다.
- attack/clash atlas는 opaque source에 neutral-light runtime matte가 필요한 bytes이므로, PDF에는 raw checker source를 직접 노출하지 않는다. runtime capture가 추가되기 전의 합 장면은 final-locked planning board의 visual-direction crop으로만 보여 준다.
- 아직 project-bound capture가 없는 `plan_locked → current-action reveal → impact`은 실제 runtime screenshot로 위장하지 않고, 승인 자산을 사용한 구현 계약과 `PENDING` 캡처 상태를 함께 표시한다.
- 새 runtime raster는 만들지 않는다. 현재 concrete consumer에 대한 asset gap이 아니라, 이미 승인된 이미지를 파생 PDF에서 사용하지 않은 발행 결함이기 때문이다.

### 교체 기준

파생 PDF의 파일명은 유지하되 이전 binary는 이 변경 branch 안에서 **시각 보정본으로 교체**한다. 새 PDF는 source Markdown의 이미지 우선 기준과 재생성 script를 함께 보유하며, 이전 PDF hash는 historical publication evidence로만 남긴다.

### 보정본 검증 readback

- Rebuild script: `tools/build_frontal_duel_visual_blueprint_pdf.py`.
- Runtime/approved visual inputs: `TEN-RVC-20260901-001`, `TEN-RVC-20260901-005`, `PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2`, martial/ultimate card atlas, frontal courtyard background.
- Output: 7-page A4 landscape PDF, SHA-256 `ED9A36F9800BFA23C455CFEF1981E85789E7A39103BC949634EC9D95AA579B58`.
- Visual render: every page rendered through Poppler at 144 DPI. The first image-centred render exposed two opaque overlay failures and one raw opaque VFX-atlas checker exposure; all three were corrected and the final seven-page render has no hidden hero image, clipped Korean text, overlap, or raw checker panel.
- Text readback: `실제 Godot`, `통합 카드`, `PENDING` present. This is PDF/readback evidence, not human UX or device evidence.

## 2026-09-02 블루프린트 퇴행 재감사 · 하이브리드 복원

### 작업 전 문제 → 조사·비교 결과

사용자는 이미지 중심 보정 이후에도 블루프린트가 이전판보다 퇴행했다고 지적했다. 이 판단은 단순 취향이 아니라 PDF 두 revision을 직접 대조해 확인했다.

- 이전 `794471bf` PDF는 7쪽 안에 `플레이어가 한 묶음을 읽는 순서`, 계획 편집 와이어프레임, 한 수 공개 와이어프레임을 독립 페이지로 두었다. 그 페이지들은 `계획 편집 → 행동계획 잠금 → N수 실행 → 이번 수 공개 → 충돌·정착 → 복기`와 입력/숨김 경계를 한 화면에서 추적할 수 있게 했다.
- 당시 최신 `fba40184` PDF는 실제 Godot capture와 승인 시각 보드를 크게 배치한 점은 개선했지만, 위 세 구조를 image caption과 PENDING stage로 치환했다. 따라서 시각 기준은 강해졌고 구현자가 읽을 상태·입력·결과 계약은 약해졌다.
- `CURRENT_SOURCE_RELEVANCE_CHECK`는 `NOT_APPLICABLE_WITH_REASON`이다. 판단 근거는 이 repository의 두 PDF, canonical Markdown, generator, capture/asset consumer이며, 최신 외부 정보가 문서 표현 복원의 결론을 바꾸지 않는다. 같은 decision dimension의 10개 사례 packet은 `REUSED_EVIDENCE`; 새 게임 규칙/UX/asset 선택은 없다.
- `IMPLEMENTATION_FEASIBILITY`는 `FEASIBLE`: source Markdown, actual/approved visual input, deterministic generator, Poppler, pypdf, regression test가 모두 현 저장소에서 확인됐다. protected product path는 변경하지 않는다.

### 채택 구조와 이유

권장안은 **이미지 앵커 + 구조 설계 레이어의 하이브리드**다.

| 대안 | 장점 | 한계 | 판정 |
| --- | --- | --- | --- |
| 이전 text-first PDF로 완전 복귀 | 흐름·상태·입력을 빠르게 읽는다. | 실제 Godot 화면과 승인 시각 방향을 다시 부차화한다. | `REJECT` |
| 기존 image-first PDF 유지 | 시각 기준과 카드/배경 질량을 바로 확인한다. | 사용자가 지적한 흐름·와이어프레임 정보 손실을 해결하지 못한다. | `REJECT` |
| 이미지와 구조 설계 레이어 병렬 유지 | 실제 화면을 기준으로 두면서 구현 상태·입력·공개 경계를 명시한다. | 3쪽이 늘어나지만 같은 source/asset만 재사용하며 현재의 모호성을 제거한다. | `ADOPT` |

복원한 10쪽 순서는 `실제 화면/승인 시각 → 실제 계획 화면 → 3/3/4 흐름 맵 → 계획 구조 → 카드 → 한 수 공개 구조 → 잠금/공개/합 표현 계약 → 증거 → handoff`다. 새 state와 새 asset을 만들어 낸 것이 아니며, p3의 runtime capture와 `PENDING` capture를 계속 구분한다.

### 실제 구현 또는 준비 결과

- canonical blueprint에 `### E. 이미지와 구조 설계의 이중 레이어`를 추가해, 이미지가 흐름 맵/와이어프레임을 대체하지 못하도록 발행 규칙을 명시했다.
- generator에 `page_flow_map`, `page_plan_wireframe`, `page_reveal_wireframe`을 추가하고, 기존 visual/capture/card pages를 유지한 10쪽 PDF로 재생성했다.
- regression test를 먼저 추가해 새 구조 페이지와 핵심 보호 문구가 없는 현재 generator에서 예상대로 `FAIL`을 확인한 뒤, 최소 구현 후 focused 5개 test `PASS`를 확인했다.
- 실제 레이아웃 검수에서 계획 와이어프레임의 우측 HUD copy가 panel 경계에 가까운 것을 발견해 글꼴/정렬을 한 번 최소 보정했다. 최종 144 DPI 재-render에서 해당 copy, page 4 flow, page 7 reveal, page 8 evidence-stage 모두 clip/overlap 없이 읽힌다.

### 기대 효과

- 기획/검수자는 실제 석정·캐릭터·카드 삽화의 인게임 방향을 이미지로 확인한다.
- 구현자는 첫 CTA와 resolver 호출 0회, 둘째 CTA의 1회 시작, 현재 수만 공개, 정착 후 다음 수라는 state contract를 도식으로 확인한다.
- 새 문서 작업에서 이미지 표현을 강화하더라도 구조적 flow/wireframe을 삭제하는 회귀를 test가 차단한다.

### 5회 전체 적대 검토

각 회차는 canonical source, 이전/현재 PDF, generator diff, visual input, unchanged product consumer, evidence ceiling, temp/output retention을 함께 다시 대조했다.

1. **구조 퇴행 공격:** 이전 flow/wireframe이 단순 장식인지 확인했다. 3/3/4, 입력 경계, hidden-info boundary, resolver timing을 소유하므로 `MUST_FIX / OMISSION`으로 판정했다.
2. **이미지 재퇴행 공격:** wireframe을 복구하면서 actual capture/approved board가 다시 빠지는지 확인했다. 새 page 4/5/7에 image anchor를 남기고 기존 image pages를 유지해 방지했다.
3. **증거 위장 공격:** structural page의 card/VFX sample이 새 runtime capture처럼 읽힐 위험을 확인했다. p3 runtime anchor와 planning-only art direction을 분리하고 exact plan-locked/reveal/impact는 계속 `PENDING`으로 유지했다.
4. **가독성 공격:** Poppler 144 DPI render에서 long HUD copy와 10-page footer count를 포함해 경계·한글·flow arrow·card fact text를 검토했다. HUD copy 정렬을 보정한 뒤 final render의 clipping, overlap, raw checker exposure는 0건이다.
5. **전파·용량 공격:** Markdown source, generator, PDF, regression test, report를 함께 갱신했다. 새 raster/제품 코드/scene은 0개이며, 비교/렌더 temporary files는 final validation 이후 path-limited cleanup 대상이다. 기존 open PR #199/#200은 read-only다.

### 검증 증거와 미검증

```yaml
baseline_project_main: fba401848ff9d2a704e8f1e8e330e8f5ef67f3f3
rebased_write_parent: 5e57f4de88ca92648cf2e6155b99db3ee77d9670
current_base_remote_observed: aaa94caf5772c262f023dd9e80fd4b8bbffd85db
base_adoption_action: "NO_SILENT_ADOPTION; project v9.4.4 pin remains compatibility evidence"
focused_red: "new structural-layer regression assertion failed before implementation as expected"
focused_green: "python -m unittest tests.test_frontal_duel_action_flow_blueprint_contract -v -> 5 passed"
full_regression: "python -m unittest discover -s tests -p 'test_*.py' -v -> 447 passed"
operating_contract: "python tools/check_project_operating_system.py -> PASS"
reference_freshness: "python tools/check_canonical_reference_freshness.py --root . --config .github/reference-freshness.json -> PASS"
pdf_readback: "10 pages; required flow/wireframe/current-timing/PENDING tokens present"
visual_render: "Poppler 144 DPI; page 4/5/7/8 inspected after final rebuild"
product_runtime_change: NONE
human_player: NOT_RUN
android_actual_device: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
```

## 이미지·자산 처리

사용자의 이번 지시는 current visual production owner의 `scoped brief → single generation → final user lock` 절차와 양립한다. **생성 전 별도 승인 대기는 하지 않되, 새 후보가 실제 runtime consumer에 필요하다는 확인은 유지**한다.

이번 PDF는 이미 final-locked·구현된 정면 석정 background를 표지의 파생 표현으로 재사용했다. 새 런타임 raster는 생성하지 않았다. current P0 전투 consumer에 background, battler, 기초/무공/절초 atlas, attack-clash/ultimate VFX가 모두 존재하므로 중복 생성은 용량·provenance·검수 비용만 늘린다.

## 최초·이미지 중심 보정 당시 검증 (역사 기록)

- PDF metadata: 7 pages, A4 landscape, title/author/subject readback PASS.
- 텍스트 readback: `정면 결투`, `행동계획 잠금`, `PENDING` 포함 여부 PASS.
- 시각 검수: Poppler 144 DPI로 7쪽 전부 render하고 header/footer, 한글 글꼴, wireframe 경계, 표, card fact rows를 검수했다.
- 교정: 첫 render에서 카드 계약의 `상태` row와 설명 panel이 겹치는 결함 1건을 발견했다. panel 위치를 최소 수정한 뒤 전 페이지 재-render에서 overlap/clip 0건을 확인했다.
- 이미지 중심 보정 회귀: `python -m unittest tests.test_frontal_duel_action_flow_blueprint_contract -v` → 4 passed. 새 test는 5개 current visual input의 존재·Markdown 우선 기준·raw checker 방지 문구를 확인한다.
- 전체 자동 회귀: `python -m unittest discover -s tests -p 'test_*.py' -v` → 446 passed.
- 운영/정본 최신성: `python tools/check_project_operating_system.py` 및 `python tools/check_canonical_reference_freshness.py --root . --config .github/reference-freshness.json` → PASS.
- 변경 무결성: text diff 대상 `git diff --check` → PASS. PDF metadata/readback 및 144 DPI render는 새 output hash `ED9A…B58`에 대해 실행했다.

`CURRENT` PDF와 사람의 최종 시각 승인, actual project-bound Godot capture, Android device, accessibility-user, player understanding, release performance는 서로 다른 증거 상태다. exact `plan_locked` runtime PNG는 기존대로 `PENDING`이다.

## 최초 발행의 5회 적대 검토와 clean exit (역사 기록)

1. **정본 공격:** PDF가 새 전투 규칙·Decision·독립 정본처럼 읽히는지 확인했다. 표지와 발행 범위를 `HUMAN_GDD_PDF_DERIVED_VIEW`로 고정했고, 기존 책임 원본 경로를 보고서에 연결했다.
2. **정보 경계 공격:** 카드·reveal 예시가 미래 행동, 관찰 전 기술명·대상·피해, AI의 비공개 계획 열람을 암시하지 않는지 확인했다. 미래 미리보기와 deck/hand/draw를 명시적으로 제외했다.
3. **시각 결함 공격:** 첫 PDF render에서 카드 계약의 마지막 row와 하단 panel overlap 1건을 발견했다. panel 위치를 조정해 7쪽 전부 재-render했고 clip/overlap을 발견하지 못했다.
4. **자산·용량 공격:** 같은 목적의 새 raster를 생성하거나 PDF를 새 runtime asset로 오인하는 경로를 확인했다. 기존 final-locked asset만 파생 표현으로 재사용하고, runtime raster 변경은 0으로 유지했다.
5. **파생물·정리 공격:** source PDF와 report만 보관 대상으로 남기고, builder 및 두 차수의 rendered PNG는 Git path-limited cleanup으로 제거했다. 다른 open PR, protected code path, legacy/migration surface는 변경하지 않았다.

당시 판정은 `CLEAN_REVIEW_EXIT`였다. 그러나 이후 사용자 검토에서 “본문이 승인 이미지·실제 runtime capture보다 추상 도식에 의존한다”는 새 `OMISSION`이 확인되어, 이 clean exit는 이미지 중심 보정 작업의 current 완료 판정으로 재사용하지 않는다.

## 최초 발행 post-merge main readback (역사 기록)

- PR #310은 normal merge commit `a28fb584a8ab72d223def4cfac4dd7b0ae9f8267`로 `main`에 병합됐다.
- local `main`과 `origin/main`은 이 SHA에서 일치하며, publication PDF와 report 모두 tracked readback됐다.
- PDF SHA-256은 발행 기록의 `25A8A3D2151103B3278D51A0F6738D2E3E2CCE48A051D23603238AD1DD414C86`와 일치한다.
- publication branch `codex/frontal-duel-blueprint-pdf-20260902`는 local·origin에서 삭제됐다. 다른 open PR과 product protected paths는 변경하지 않았다.

## 이미지 중심 보정의 5회 적대 검토

모든 회차는 source Markdown, 실제 Godot capture/asset, 변경 diff, PDF 파생본, 미변경 소비자, 증거 상한, 열린 PR과 장기 유지 비용을 함께 공격했다. 회차마다 관점만 달리 채우지 않고 전체 범위를 다시 검토했다.

1. **이미지 소비 누락 공격:** 실제 capture와 final-locked visual board가 있는데도 본문을 일반 도식으로 축소한 경로를 확인했다. `MUST_FIX / OMISSION`으로 검증했으며, 표지뿐 아니라 계획·카드·공개/합 설명에 실제 이미지를 배치하는 재생성기로 보정했다.
2. **증거 위장 공격:** planning board와 card atlas를 실제 Godot의 잠금·공개·impact capture처럼 읽히게 할 위험을 확인했다. 각 미래 단계는 `PENDING` project-bound capture로 표시하고, 현재 capture가 보여 주는 계획 편집·자동 배치만 `MACHINE_RUNTIME_CAPTURE`로 유지했다.
3. **자산 합성/투명도 공격:** `attack_clash_ink_gold_atlas_rgba_v1.png`이 source bytes에서는 opaque이며 runtime shader matte가 필요함을 확인했다. raw checker source를 PDF에 싣는 안은 기각하고, 동일 의미를 보장하는 final-locked planning board의 합 direction crop으로 대체했다. runtime VFX 소비 계약은 문서에 남겼다.
4. **렌더·가독성 공격:** 첫 image-centred render에서 두 곳의 불투명 overlay와 raw VFX checker 노출을 찾았다. full-screen black overlay는 제거하고, 하단 caption은 얇은 opaque panel로 한정했다. Poppler 144 DPI 전 페이지 재-render에서 hero image 숨김·한글 clip·요소 overlap·checker panel 0건을 확인했다.
5. **전파·재현성·용량 공격:** 사람이 읽는 source, PDF, report, regression test, generator가 함께 바뀌는지와 불필요한 파생 PNG/temp path가 남는지 확인했다. canonical markdown에 이미지 우선 규칙을 추가하고 source-path existence를 검사하는 회귀 test와 재생성 script를 추가했다. protected product paths, 기존 open PR #199/#200, 새 runtime raster는 건드리지 않았다.

### 보정 clean-exit 및 post-merge readback

`REMAINING_WORK_RECALCULATION_REQUIRED` 결과는 이 보정 범위의 구현·문서·PDF·회귀 test·render 검증 후 `0`이다. pre-merge focused 4 passed, full 446 passed, operating-system/reference-freshness PASS, final 7-page render/readback PASS를 확인했다.

PR #312는 exact head `0d220da0d87b5ce27d9189897f33b5591f0281cf`에서 모든 완료 check가 `SUCCESS` 또는 적용 범위의 `SKIPPED`로 끝나고, review/comment 0건인 상태에서 normal merge commit `4338fe063bb4c0d4075c5ede90ca96bc23c63b08`로 병합됐다. 새 `main`에서 PDF SHA-256 `ED9A36F9800BFA23C455CFEF1981E85789E7A39103BC949634EC9D95AA579B58`, 7쪽 A4 landscape, `실제 Godot`·`통합 카드`·`PENDING`·`이미지 중심 블루프린트` text readback, focused blueprint regression 4 passed, reference freshness PASS를 다시 확인했다. 이 변경의 `CLEAN_REVIEW_EXIT_POSTMERGE`는 위 readback 범위에서 성립한다.

## 이미지 중심 보정 동기화 상태

- source main before correction: `255d1152a5be0db7e36a0a6068a532b653ae4fa5`.
- correction branch / exact head: `codex/frontal-duel-visual-blueprint-pdf-20260902` / `0d220da0d87b5ce27d9189897f33b5591f0281cf`.
- correction PR / normal merge: #312 / `4338fe063bb4c0d4075c5ede90ca96bc23c63b08`.
- current exact PDF output hash: `ED9A36F9800BFA23C455CFEF1981E85789E7A39103BC949634EC9D95AA579B58`.
- pre-existing open PR #199/#200은 read-only이며 이 보정과 path/semantic overlap이 없다.
- PR publish, exact-head checks, normal merge, post-merge `main`/PDF/readback는 모두 위 commit에서 완료됐다. first correction branch는 local·origin에서 제거됐고, 다른 open PR과 product protected paths는 변경하지 않았다.

## 다음 안전 작업

1. 정확한 십보강호 project-bound Godot session이 준비되면 plan-locked·reveal·impact 최소 캡처를 repository manifest에 추가한다.
2. 그 과정에서 실제 새 visual consumer가 발견되면 별도 pre-generation approval 없이 brief와 단일 후보를 만들고, consumer 연결·runtime evidence를 남긴 뒤 final lock 상태를 사용자에게 제시한다.
