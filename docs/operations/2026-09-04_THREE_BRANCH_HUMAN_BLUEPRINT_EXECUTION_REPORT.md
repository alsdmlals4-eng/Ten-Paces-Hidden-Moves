# 강호행로 3갈래·4회 선택 및 사람용 Blueprint 실행 보고

> 기준 SHA: `09e3f923fc30514228d70f6f8f8465a41712fa2e`
> Work Mode: `PLAN_AND_REVIEW_DOCUMENTATION_CANDIDATE_PRODUCTION`
> Skill / Skill Mode: `ten-paces-hidden-moves-workflow-router` / `PLAN`; `design-art-prompts`, `design-documents`, `reference-freshness`, `running-adversarial-review-and-refinement` / scoped; `imagegen` / scoped generation; `pdf` / create-render-inspect; `test-driven-development`, `verification-before-completion` / regression and readback
> 결정: `TEN-DEC-20260904-THREE-BRANCH-FOUR-CHOICE-JIANGHU-AND-HUMAN-BLUEPRINT-01`

## 1. 작업 전 문제

- 기존 사람용 20260902 PDF와 일부 active 문서가 `구간당 성장/정보 2노드`, player-facing `행동계획 잠금 → N수 실행`, 별도 `Combat Review Overlay`를 현재처럼 보이게 했다.
- 실제 Godot 소비처도 같은 2노드 route와 두 단계 CTA를 구현하고 있어, 새 사용자의 `3갈래 × 4회`와 `행동 실행`을 구현 완료로 바꾸어 쓰면 안 되는 상태였다.
- 기존 고정 모듈은 final-locked/runtime-verified evidence를 보유하므로, 새 일괄 시안이 이를 조용히 덮어쓰면 provenance와 consumer 계약을 깨게 된다.

## 2. 조사·비교 결과

`docs/reviews/2026-09-04_THREE_BRANCH_FOUR_CHOICE_ROUTE_BENCHMARK.md`에서 10개 사례를 fresh-read했다. 공식 소개가 경로 선택의 다음 전투 준비 역할을 직접 설명하는 Monster Train, Wildfrost, Dead Cells를 route tempo와 공개 trade-off만 **ADAPT**했다. Darkest Dungeon II, Against the Storm, Roguebook, Griftlands, FTL, Loop Hero, Slay the Spire는 인접/부정·혼합 경계로 사용했다.

- 채택: 한 surface 안에서 단계별 세 후보를 비교하고, 선택 결과가 다음 비무 준비를 바꾸는 구조.
- 거절: deck/hand/draw, 방대한 분기 map, 보이지 않는 상대 계획의 보상 노출, 무의미한 동일 보상 세 개, 네 개의 전환 Scene.
- 한계: desk research는 이 프로젝트의 선택 읽기 시간, 난이도, 사람 가독성을 증명하지 않는다.

## 3. 채택한 구조와 이유

```text
비무 결과
  → stage 1: 후보 3개 중 1개 / 1·4
  → stage 2: 후보 3개 중 1개 / 2·4
  → stage 3: 후보 3개 중 1개 / 3·4
  → stage 4: 후보 3개 중 1개 / 4·4
  → 다음 비무 Briefing
```

- 4회는 경로 화면의 `0/4…4/4` counter로만 진척을 표현하며, 화면 수나 일반 전투를 늘리지 않는다.
- 비무는 20/50/30 준비 surface와 `기본 / 무공 / 절초` 5×2, 상세 효과와 관찰을 유지한다.
- `행동 실행`은 계획 유효성 확인 후 즉시 전투를 시작하는 유일한 player-facing CTA다.
- 실행 중에는 공개된 현재 카드만 `내 카드 → VS ← 상대 카드`로 보이며, 중단은 이미 공개된 현재 카드만 찢김/퇴색한다.

## 4. 실제 준비 결과

| 산출물 | 결과 | 상태 |
|---|---|---|
| successor Decision + active GDD/UX reconciliation | 사용자 최신 규칙과 legacy 경계를 명시 | `SPECIFIED` |
| 10-case benchmark | route adoption/rejection and no-copy boundary 기록 | `RESEARCHED` |
| 3×3 atlas | 통일된 청회색 한지·먹선·절제된 금색 후보, 1~9 화면 번호 | `GENERATED_CANDIDATE` |
| 사람용 PDF | 프로젝트 소개, atlas, 두 system flow/wireframe, PM, 분리 후보, handoff를 24쪽으로 연결 | `MACHINE_VERIFIED` |
| product code | 변경 없음; legacy truth 기록 | `IMPLEMENTED_LEGACY` |

## 5. 사용 예

플레이어는 비무 결과 뒤 `행로 선택 0/4`에서 `수련 / 관찰 / 사건`처럼 각기 다른 공개 범주의 세 후보를 비교하고 하나를 고른다. 네 번째 적용 뒤 Briefing에서는 수치가 보이는 내 HUD, 숫자가 숨겨진 상대 HUD, 현재 계획 3수, 5×2 카드, 상세 효과와 관찰을 확인한다. `행동 실행` 후 기본 전투·합·절초 모두 현재 공개 카드의 `VS` rail을 먼저 보여 주고, 결과 strip이 원인만 남긴다.

## 6. 기대효과

- 강호행로가 한 번의 선택이 아니라 다음 비무 전 네 번의 짧은 준비 판단이 된다.
- 카드의 강도보다 상대를 읽고 현재 선택을 조합하는 core를 보존한다.
- 사람용 문서는 화면, 구현순서, 이미지 생산, PM 및 검증 한계를 하나의 독해 경로로 제공한다.

## 7. 검증 증거

### RED → GREEN

1. `python -m unittest tests.test_human_blueprint_20260904_contract -v`를 builder/owner/PDF가 없을 때 실행했다. `new dated human-blueprint builder must exist`로 **RED**를 확인했다.
2. candidate record와 deterministic 24-page builder를 추가하고 PDF를 생성했다.
3. focused final `python -m unittest tests.test_human_blueprint_20260904_contract tests.test_human_game_blueprint_profile tests.test_base_v91_operating_contract tests.test_project_governance -v`는 **26 tests OK**였다.
4. Poppler로 24쪽 전부를 raster render하고 각 쪽을 점검했다. 11쪽의 HUD 누락, 14~16쪽의 작은 HUD 겹침, 16쪽 공지 card crop, 21쪽 handoff card crop을 찾아 builder layout을 보정한 뒤 재생성했다.
5. generated PDF의 textconv은 whitespace 검사의 대상이 아니므로 `git diff --check -- . ':!exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260904.pdf'`, JSON parse, current/historical wording search, `python tools/check_canonical_reference_freshness.py --root . --config .github/reference-freshness.json`, `python tools/check_project_operating_system.py`를 final readback에서 실행했다. 전자는 각각 source whitespace error 없음, parse PASS, historical-only matches, `canonical reference freshness: PASS`, `project operating system: PASS`를 냈다. PDF byte/구조는 아래 전용 검증으로 검사했다.

### Final PDF readback

- PDF: `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260904.pdf`
- SHA-256: `496b38fd30fa35b1a48014504a47b9f6c04eb5217894a7dbbb37d435ff42522b`
- `pdfinfo`: 24 pages, A4 landscape, PDF 1.4.
- `pypdf`: 24 pages and required `강호행로 / 3갈래 / 4회 선택 / 행동 실행 / VS / GENERATED_CANDIDATE / RUNTIME_IMPLEMENTATION_NOT_STARTED` markers present.
- Poppler: 24 rendered pages. All-page inspection completed; last publish readback rechecked page 22 status matrix. Earlier visual fixes retained the 11쪽 full three-resource HUD, 14~16쪽 compact HUD/card readability, and 21쪽 handoff card bounds.

### PR scope-aware CI reconciliation

- 기존 PR #321의 `scope-aware-validation`은 새 atlas/PDF와 무관하게, `tests/test_current_discovery_contract.py`가 당시 `FRONTAL_DUEL_V2...` 문자열을 current state로 고정해서 실패했다.
- current `ACTIVE_CONTEXT`, planning JSON, `test_current_discovery_contract.py`, `test_integrated_work_contract_v48r54.py`를 함께 갱신했다. final local equivalent는 project-governance discovery 13 tests + scope-aware module group 58 tests + current human Blueprint group 13 tests, 총 **84 tests OK**였다.
- 이 보정은 legacy runtime evidence를 지우지 않는다. 새 atlas는 `GENERATED_CANDIDATE`, route/CTA/Review surface는 `IMPLEMENTED_LEGACY`, 새 runtime package는 `NOT_RUN`으로 유지한다.

### 5회 full-scope 적대 검토

| loop | 공격 대상 | 실제 finding | 보정 / clean exit |
|---|---|---|---|
| 1 | core drift | 4회 선택이 deck/hand/draw 또는 추가 전투로 읽힐 위험 | Decision/flow에 후보 3개·하나 선택·4회·다음 Briefing만 명시 |
| 2 | information boundary | 관찰/정보 후보가 숨은 행동을 알려 줄 위험 | 공개 범주/한 줄 효과만 허용, 미래 계획·정확 기술/확률 금지 |
| 3 | current vs legacy | 2노드/두 단계 CTA/Review가 current 문장으로 남음 | successor wording과 `IMPLEMENTED_LEGACY` 표식을 동시 기록 |
| 4 | visual/consumer/rights | whole atlas가 runtime asset 또는 final lock으로 오인될 위험 | candidate record에 documentation-only consumer, runtime NONE, rights blocked 기록 |
| 5 | PDF visual/evidence | HUD 정보 누락/겹침·공지 crop, 문서 PASS를 runtime PASS로 과장할 위험 | 4개 layout 수정, PDF는 MACHINE_VERIFIED; Godot/Human/Android/rights는 NOT_RUN 또는 blocked 유지 |

## 8. 자동화·학습 반영

- `tests/test_human_blueprint_20260904_contract.py`가 PDF 경로, candidate, counter, CTA, VS, 상태 경계를 회귀 검사한다.
- 기존 human Blueprint profile test를 current 20260904 publication과 retained historical derived publication 관계로 갱신했다.
- builder는 atlas 파일 부재/크기 불일치 시 실패하며, 전체 scene candidate → consumer-bound separated brief → user lock → composition 순서를 문서화한다.

## 9. 미검증·남은 위험

| 항목 | 상태 | 다음 안전 작업 |
|---|---|---|
| Godot route model/shell | `IMPLEMENTED_LEGACY` | 3 candidate, 4 pick, 0/4 counter regression을 RED부터 작성하는 BUILD package |
| player-facing CTA / Review boundary | `IMPLEMENTED_LEGACY` | `행동 실행`, no separate Review, current-card-only interruption UI state 구현 |
| Windows capture | `NOT_RUN` | 새 Route/Briefing/VS runtime capture |
| Human, Android, accessibility | `NOT_RUN` | 실제 플레이어 판독성, touch/safe area, motion/accessibility 검수 |
| candidate atlas lock and shipping rights | `RELEASE_BLOCKED_UNVERIFIED` | actual runtime consumer별 분리 후보와 user final lock, provenance/rights review |

현재 문서/후보 패키지는 완료 범위를 넘어 실제 game runtime 완료라고 주장하지 않는다.
