# 무공 기술서 무삽화 표현 실행 보고 · 2026-08-30

```yaml
report_id: TEN-OPS-20260830-MARTIAL-MANUAL-TEXT-FIRST-PRESENTATION-01
baseline_main: 03b8b8887a6a5c8961fd4902cf1e0b37bd8d2954
work_mode: BUILD
skill: combat-ux-and-accessibility, ten-paces-verification
skill_mode: UI_PRESENTATION_AND_REGRESSION
decision: TEN-DEC-20260830-MARTIAL-MANUAL-TEXT-FIRST-PRESENTATION-01
current_source_relevance_check: NOT_APPLICABLE_USER_PRODUCT_PRESENTATION_DECISION
feasibility: FEASIBLE_EXISTING_MARTIAL_ACTION_PANEL_HAS_NO_ILLUSTRATION_CONSUMER
status: LOCAL_FULL_VERIFICATION_PASS_AWAITING_PR_CI_AND_POSTMERGE_READBACK
```

## 작업 전 문제

실제 `MartialActionPanel`과 무공 데이터는 이미 text/tag/numeric 표현이지만, 현행 Visual Gate와 handoff는 “개별 무공/절초 카드 삽화”를 미래 후보로 남겨 사용자 최신 방향과 충돌했다. 이 충돌은 다음 세션에서 무공 기술서에 불필요한 이미지 consumer를 도입할 위험이 있었다.

## 채택 구조와 이유

무공서와 그 기술 목록만 `TEXT_TAG_NUMERIC_ONLY_NO_ILLUSTRATION`로 고정한다. 행동명, 행동 수, 자원, 잠금/해금, 태그, 조건부 사거리와 효과는 Godot data binding이 소유하므로 전술 판단에 필요한 정보를 유지한다. 기초 카드의 승인 atlas, 전장 배경, 대치 캐릭터와 필살기 연출은 별도 consumer이므로 변경하지 않는다.

## TDD 관찰

새 Decision/current-handoff/Gate 계약을 요구하는 focused Python test를 먼저 추가해 RED를 확인했다. 실패 원인은 새 Decision 파일이 아직 존재하지 않았기 때문이다. 실제 무공 UI behavior는 기존부터 방향을 만족하므로, Godot regression은 가짜 product RED를 만들지 않고 무공 기술 정의의 `illustration` 부재와 `MartialActionPanel`의 `TextureRect` 부재를 명시적으로 검증한다.

## 다섯 차례 적대 검토

1. **권위:** latest user direction, current Visual Gate, structured handoff, current UI consumer와 data를 대조해 user decision이 더 좁은 current override임을 확인한다.
2. **범위:** `MartialActionPanel`만 고정하고 basic `CardView`, background, battler, portrait, ultimate/VFX를 diff와 tests로 보호한다.
3. **정보 위계:** 기술 선택에서 필요한 이름·행동 수·비용·잠금·태그·사거리/효과가 이미지 없이 보이는지 UI code/readback으로 확인한다.
4. **runtime:** actual Godot headless scene test로 data field와 node tree를 확인하고 viewport product verification을 재실행한다.
5. **delivery:** JSON validity, focused/full tests, reference freshness, operating checks, diff review, remote CI, merge와 exact-main readback을 마친 뒤에만 clean exit를 기록한다.

Human readability, accessibility-user, Android device와 release performance는 자동 검증으로 대체하지 않으며 이 변경의 evidence ceiling에서 `NOT_RUN`이다.

## 현재 local 검증 결과

| 검증 | 결과 | 증거와 한계 |
|---|---|---|
| TDD contract | PASS | 새 Decision 요구 focused Python test는 문서 생성 전 `EXPECTED_RED`, 정본·structured state 반영 뒤 GREEN이 됐다. |
| visual/current-discovery focused suite | PASS | visual policy, discovery, GPT Work handoff, r5.4 contract 33 tests가 통과했다. |
| Godot 무공 UI/AI 채택 | PASS | Godot 4.7.1 headless `verify_ten_manual_ui_ai_adoption.gd`가 `TEN_MANUAL_UI_AI_ADOPTION_VERIFY_OK`를 출력했다. 무공 data field와 `MartialActionPanel` node tree 회귀를 포함한다. |
| Godot product viewport | PASS | Godot 4.7.1 headless `verify_ten_manual_product_viewports.gd`가 `TEN_MANUAL_PRODUCT_VIEWPORTS_OK`를 출력했다. 1280×800, 1440×900, 1920×1080 자동 product viewport 범위다. |
| Human/visible usability | NOT_RUN | headless scene/viewport verification은 사람의 실제 읽기 경험을 대체하지 않는다. |

새 worktree의 Godot class cache가 아직 없을 때 첫 direct headless script가 global class를 해석하지 못했다. `--editor --headless --quit`로 worktree-local class/import cache를 한 번 준비한 뒤 같은 script가 PASS했다. 이 cache와 재import 산출물은 추적하지 않았고 generated artifact도 작업 tree에서 제거했다.

## Full-scope review 결과

1. **권위 — PASS:** latest user decision을 새 current Decision으로 보존하고, consumer-first Decision은 무공 기술서 범위에서만 부분 supersede했다.
2. **범위 — PASS:** diff에는 `src/`, `data/`, `scenes/`, `assets/`, `addons/`, `project.godot` product path가 없으며 기본 CardView·전장·인물·UltimateActionPanel/VFX 계약은 문서와 test에서 명시적으로 제외했다.
3. **정보 위계 — PASS:** `MartialActionPanel`의 Button text/tooltip/accessibility path가 이름·수·비용·잠금·태그·조건부 정보만 소유함을 source readback했고, `TextureRect`는 없다.
4. **machine/runtime — PASS:** Godot 4.7.1 headless UI/AI adoption 및 3개 viewport product verification이 모두 통과했다.
5. **delivery — PASS (remote 대기):** full Python suite `422 tests / 16.790s / OK`, approved operating contract, generated artifact check, reference freshness, operating system, archive governance와 whitespace check가 통과했다. PR CI와 safe merge 및 exact-main readback만 남았다.

`CLEAN_REVIEW_EXIT`는 remote CI, safe merge, exact main readback까지 완료된 뒤에만 기록한다.
