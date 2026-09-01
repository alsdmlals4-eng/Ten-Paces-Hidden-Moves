# 2026-09-02 정면 결투 블루프린트 PDF 발행 · Execution Report

```yaml
work_id: TEN-PUB-20260902-FRONTAL-DUEL-BLUEPRINT-PDF-01
work_mode: PLAN + PUBLISH + REVIEW
skill:
  - managing-design-documents/publish+validate
  - ten-paces-verification/evidence-report
  - synchronizing-local-and-github-state/preflight+publish+verify
base_project_source_sha: d0a641ce6a9d3920d33f27446e47d06efd1d550a
write_parent_sha: d0a641ce6a9d3920d33f27446e47d06efd1d550a
authority_domain: HUMAN_GDD_PDF_DERIVED_VIEW
core_rule_change: false
runtime_or_save_change: false
new_runtime_raster: false
implementation_feasibility: FEASIBLE
```

## 사용자 약속과 책임 범위

사용자는 권장안에 따라 현재 전투 블루프린트를 PDF로 보고, 앞으로 실제 소비처가 확인된 이미지는 생성 전 별도 승인을 기다리지 말고 제작하라고 지시했다.

이번 PDF는 기존 정본을 읽기 쉬운 7쪽 파생본으로 발행하는 작업이다. 전투 규칙, 저장, Godot scene/code, 승인 자산, 이미지 정본 상태를 바꾸지 않으며, 독립 정본이 아니다.

## 현재 정본·동시성 readback

- local `main`과 `origin/main`은 시작 시 `d0a641ce6a9d3920d33f27446e47d06efd1d550a`에서 일치했다.
- 관련 열린 PR은 없었다. PR #199와 PR #200은 서로 다른 기존 draft 문서 작업으로 read-only 보존했다.
- `docs/design/2026-09-01_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT.md`가 화면 흐름·와이어프레임·카드 계약의 책임 원본이다.
- `docs/decisions/2026-09-01_ACTION_PLAN_LOCK_AND_EXECUTE_CTA_DECISION.md`가 `행동계획 잠금 → N수 실행` 입력 semantics의 책임 원본이다.
- `docs/reviews/2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md`의 10개 공식 사례 packet은 같은 decision dimension과 같은 current product state이므로 `REUSED_EVIDENCE`로 사용했다. 새 규칙·UX·자산 선택을 추가하지 않아 별도 10개 패킷을 중복 생성하지 않았다.

## PDF 발행 결과

| 항목 | 결과 |
| --- | --- |
| 파생 PDF | `output/pdf/TEN_PACES_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT_2026-09-02.pdf` |
| 페이지 | A4 landscape 7쪽 |
| 입력 | current blueprint, action-plan-lock Decision, benchmark, actual consumer/asset state, existing runtime-evidence ceiling |
| 출력 SHA-256 | `25A8A3D2151103B3278D51A0F6738D2E3E2CCE48A051D23603238AD1DD414C86` |
| 포함 | 표지, 3/3/4 flow map, 계획 편집 wireframe, timing reveal wireframe, unified card contract, benchmark transfer boundary, asset/evidence boundary |
| 제외 | 새 rules, numerical balance, future action preview, deck/hand/draw, new image candidate, Human/device PASS claim |

## 이미지·자산 처리

사용자의 이번 지시는 current visual production owner의 `scoped brief → single generation → final user lock` 절차와 양립한다. **생성 전 별도 승인 대기는 하지 않되, 새 후보가 실제 runtime consumer에 필요하다는 확인은 유지**한다.

이번 PDF는 이미 final-locked·구현된 정면 석정 background를 표지의 파생 표현으로 재사용했다. 새 런타임 raster는 생성하지 않았다. current P0 전투 consumer에 background, battler, 기초/무공/절초 atlas, attack-clash/ultimate VFX가 모두 존재하므로 중복 생성은 용량·provenance·검수 비용만 늘린다.

## 검증

- PDF metadata: 7 pages, A4 landscape, title/author/subject readback PASS.
- 텍스트 readback: `정면 결투`, `행동계획 잠금`, `PENDING` 포함 여부 PASS.
- 시각 검수: Poppler 144 DPI로 7쪽 전부 render하고 header/footer, 한글 글꼴, wireframe 경계, 표, card fact rows를 검수했다.
- 교정: 첫 render에서 카드 계약의 `상태` row와 설명 panel이 겹치는 결함 1건을 발견했다. panel 위치를 최소 수정한 뒤 전 페이지 재-render에서 overlap/clip 0건을 확인했다.

`CURRENT` PDF와 사람의 최종 시각 승인, actual project-bound Godot capture, Android device, accessibility-user, player understanding, release performance는 서로 다른 증거 상태다. exact `plan_locked` runtime PNG는 기존대로 `PENDING`이다.

## 5회 적대 검토와 clean exit

1. **정본 공격:** PDF가 새 전투 규칙·Decision·독립 정본처럼 읽히는지 확인했다. 표지와 발행 범위를 `HUMAN_GDD_PDF_DERIVED_VIEW`로 고정했고, 기존 책임 원본 경로를 보고서에 연결했다.
2. **정보 경계 공격:** 카드·reveal 예시가 미래 행동, 관찰 전 기술명·대상·피해, AI의 비공개 계획 열람을 암시하지 않는지 확인했다. 미래 미리보기와 deck/hand/draw를 명시적으로 제외했다.
3. **시각 결함 공격:** 첫 PDF render에서 카드 계약의 마지막 row와 하단 panel overlap 1건을 발견했다. panel 위치를 조정해 7쪽 전부 재-render했고 clip/overlap을 발견하지 못했다.
4. **자산·용량 공격:** 같은 목적의 새 raster를 생성하거나 PDF를 새 runtime asset로 오인하는 경로를 확인했다. 기존 final-locked asset만 파생 표현으로 재사용하고, runtime raster 변경은 0으로 유지했다.
5. **파생물·정리 공격:** source PDF와 report만 보관 대상으로 남기고, builder 및 두 차수의 rendered PNG는 Git path-limited cleanup으로 제거했다. 다른 open PR, protected code path, legacy/migration surface는 변경하지 않았다.

판정: `CLEAN_REVIEW_EXIT`. 발견된 유효 결함은 1건이며 최소 수정·재-render로 닫았다. 추가 repository mutation이 필요한 누락·충돌·중복은 발견되지 않았다.

## post-merge main readback

- PR #310은 normal merge commit `a28fb584a8ab72d223def4cfac4dd7b0ae9f8267`로 `main`에 병합됐다.
- local `main`과 `origin/main`은 이 SHA에서 일치하며, publication PDF와 report 모두 tracked readback됐다.
- PDF SHA-256은 발행 기록의 `25A8A3D2151103B3278D51A0F6738D2E3E2CCE48A051D23603238AD1DD414C86`와 일치한다.
- publication branch `codex/frontal-duel-blueprint-pdf-20260902`는 local·origin에서 삭제됐다. 다른 open PR과 product protected paths는 변경하지 않았다.

## 다음 안전 작업

1. 정확한 십보강호 project-bound Godot session이 준비되면 plan-locked·reveal·impact 최소 캡처를 repository manifest에 추가한다.
2. 그 과정에서 실제 새 visual consumer가 발견되면 별도 pre-generation approval 없이 brief와 단일 후보를 만들고, consumer 연결·runtime evidence를 남긴 뒤 final lock 상태를 사용자에게 제시한다.
