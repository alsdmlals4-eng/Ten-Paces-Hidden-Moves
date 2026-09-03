# 강호행로 3갈래·4회 선택과 사람용 Blueprint 설계

> 상태: 사용자 승인 범위의 문서·시각 후보·PDF 산출 설계. Godot product implementation은 포함하지 않는다.
>
> 근거: `TEN-DEC-20260904-THREE-BRANCH-FOUR-CHOICE-JIANGHU-AND-HUMAN-BLUEPRINT-01`.

## 목적

기존 사람용 PDF 안에 섞인 2노드 경로, 별도 Review Overlay, 두 단계 CTA를 새 정본으로 재생산하지 않는다. 대신 새로운 단일 현재 PDF가 프로젝트 소개, 9화면 atlas, 강호행로/비무 flow, text-native wireframe, asset split plan, PM과 evidence ceiling을 같은 용어로 설명한다.

## 범위와 경계

| 포함 | 제외 |
|---|---|
| route 3 candidates × 4 picks canonical docs | `src/`, `scenes/`, `data/`, `assets/` runtime mutation |
| whole-screen atlas candidate and provenance | existing locked asset replacement |
| new PDF builder and contract test | Godot runtime, Android, human UX, release claims |
| active registry/status/operation records | user-provided reference image pixels in the build |

## PDF architecture

`tools/build_human_game_blueprint_20260904_pdf.py` creates the one current human publication. It imports no old baseline pages because those pages preserve superseded screen rules. It uses ReportLab and the single generated atlas only as a documentation candidate, while Flow Maps/wireframes/PM tables remain text-native vector/text elements.

Page groups:

1. project introduction and evidence legend;
2. atlas and screen-number map;
3. 강호행로: 3 branches × 4 selections, candidate contract, flow and wireframe;
4. 비무: preparation, execution, compare rail, clash, ultimate, interruption, result;
5. whole-scene → split asset candidate → composition handoff;
6. PM/implementation/test matrix and risk register.

## Data flow

```text
Decision + GDD + actual legacy consumers + route benchmark
→ candidate provenance record + text-native blueprint source
→ deterministic PDF builder
→ PDF structural/readback checks + rendered-page inspection
→ registry, active context, operation report
```

## Error and provenance rules

- The builder fails if the candidate atlas is missing or if its dimensions are not the recorded `1672×941`.
- The output is a new dated path; the 20260902 publication is retained as historical derived evidence.
- Korean raster copy is illustrative. All binding requirements live in the text and tables beside it.
- No existing final-locked runtime PNG is overwritten, and no candidate is declared shipping-ready.

## Verification design

- A new Python contract test is written first and must fail before the builder/current-owner updates exist.
- The test checks the new PDF identity, 9 atlas screen labels, `3갈래`, `4회`, `행동 실행`, `VS`, source-candidate evidence, and the absence of active `route_two_nodes_per_gap_preserved` / standalone Review assertions.
- The builder is then run only after the PDF create marker; `pypdf` checks page count/text markers and Poppler renders every page for visual inspection.
- Documentation/reference freshness and the focused Python contract suite run after source update. Runtime, device, human, accessibility and release remain `NOT_RUN`.
