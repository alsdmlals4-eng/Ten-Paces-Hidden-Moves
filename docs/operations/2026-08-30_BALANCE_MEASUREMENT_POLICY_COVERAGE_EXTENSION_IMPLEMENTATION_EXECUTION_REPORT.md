# Balance Measurement-Policy Coverage Extension — Implementation Execution Report

~~~yaml
report_id: TEN-DEC-20260830-BALANCE-MEASUREMENT-POLICY-COVERAGE-EXTENSION-01-IMPLEMENTATION
status: IMPLEMENTED_MERGED_MAIN_PR289_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR290_POSTMERGE_READBACK
baseline_origin_main: 65fc68a299e0b62a187baadb798d0ca82388b580
implementation_commit: cc267852210b3bfde7d0dd5df784e501c64011d4
work_mode: BUILD
user_approval: "2026-08-30 user explicit: 좋아 진행해; prior long-horizon continuation approval retained"
skill_modes:
  - ten-paces-hidden-moves-workflow-router: build
  - ten-paces-game-design: balance-review
  - combat-implementation-handoff: build
  - ten-paces-verification: contract-check/reference-freshness/regression/evidence-report
  - test-driven-development: RED-GREEN
  - systematic-debugging: diagnose-before-fix
  - running-adversarial-review-and-refinement: five-full-scope-loops
protected_change_manifest: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
build_approval_record: docs/implementation/BUILD_APPROVAL_2026-08-30.md
protected_base_commit: 944cd8194152b3d2e31647b25dacd1bad90b7876
product_mutation: NONE
asset_mutation: NONE
ui_scene_save_ai_formula_mutation: NONE
~~~

## 작업 전 문제

v1 계측은 실제 resolver 3,375 결투를 실행했지만, 세 공개 정책만으로는 회피 성공과 절초 실행 표본이 0이었다. 회복 행동은 선택해도 row가 그 선택 범주를 기록하지 않아 coverage를 판정할 수 없었다. 이는 전투 수치나 플레이어 화면 문제가 아니라, 공개 정책 표본과 검증 보고서의 관측 공백이었다.

## 조사·비교 결과

같은 날 병합된 12개 게임 벤치마크 packet을 동일한 단일 결투 계측 차원으로 재사용했다. 최신 공식 제품 사실도 다시 확인했다. [Yomi 2](https://www.sirlin.net/posts/introducing-yomi-2)의 super meter는 기존 공개 기세 5를 실제로 관찰할 근거로만 `ADAPT`했고, [Fights in Tight Spaces](https://store.steampowered.com/app/1265820/Fights_in_Tight_Spaces/)와 [Shogun Showdown](https://store.steampowered.com/app/2084000/Shogun_Showdown/)의 deck-building은 `REJECT`, [Die by the Blade](https://store.steampowered.com/app/1154670/Die_by_the_Blade/)의 one-hit 구조는 `AVOID`로 유지했다.

`CURRENT_SOURCE_RELEVANCE_CHECK` 결과는 `REUSE_ALLOWED_SAME_DAY_INITIAL_12_GAME_PACKET_SAME_SINGLE_DUEL_BALANCE_DECISION_DIMENSION_SAME_RUNTIME_STATE_FOUR_OFFICIAL_SOURCES_LIVE_RECHECKED`다. 이 재사용은 재미·공정성 또는 수치 밸런스를 증명하지 않는다.

## 채택한 구조와 이유

- 기존 세 공개 정책을 보존하고, 검증 전용 `public_evade_then_ultimate` 하나만 추가했다.
- 이 정책은 공개 거리, 플레이어 공개 자원/기세, 공개 카드 정의와 공개 해결 이력만 사용한다. 기세가 최대면 현재 거리와 묶음 슬롯에 맞는 기본 절초를, 그 외에는 합법 회피를 고르고 기존 공개 fallback으로만 내려간다.
- matrix를 `15 후보 × 15 합법 시작 조합 × 4 정책 × 5 AI seed = 4,500` 실제 resolver 결투로 확장했다. 10칸, 공개 시작 거리 2, 3/3/4, opening_no_route와 최대 12라운드는 그대로다.
- schema 2 row에는 card ID·목표·상대 계획을 쓰지 않는 고정 aggregate 네 키 `guard`, `evade`, `recovery`, `ultimate`만 더했다. 선택 횟수와 resolver가 실제로 기록한 `successful_dodges`/`ultimate_uses`를 분리했다.

## 실제 구현 또는 준비 결과

- protected runtime-adjacent 경로 네 곳만 변경했다: matrix 1개와 검증 전용 GDScript 3개.
- report runner contract를 schema 2와 새 Decision ID로 올렸다.
- 새 공개 policy, 4,500 scenario matrix, safe row schema와 current-owner 소비처를 RED 후 GREEN 회귀로 묶었다.
- Godot 첫 스캔이 만든 추적되지 않는 배경 import 캐시 1개는 원본 asset/data를 건드리지 않고 제거했다. 이후 protected manifest는 정확한 네 코드/데이터 경로만 소유한다.
- 전체 Python 회귀 첫 실행은 코드 결함이 아니라 Windows TEMP 디스크 공간 부족으로 planning-data copy test 14개가 중단됐다. 열린 PR과 무관하고 Git clean인 과거 완료 worktree 14개만 제거해 약 1.13GB를 회복한 뒤 동일 전체 suite를 다시 실행했다.

## 사용 예

새 검증 입력 `public_evade_then_ultimate`은 플레이어의 숨은 배치나 상대 AI intent를 보지 않는다. 공개 기세가 최대이고 거리 2인 3수 묶음이면 `ultimate_cleave_peak`만큼의 합법 절초 배치를 만든다. 기세가 최대가 아니면 `basic_evade`를 먼저 배치한다. 이 동작은 검증 보고서의 coverage를 넓힐 뿐, 실제 플레이어 행동 선택이나 AI 판단을 바꾸지 않는다.

## 기대효과

회피, 회복, 절초라는 기존 결투 규칙의 서로 다른 공개 표본이 실제 resolver에서 관측된다. 이후 숫자를 손댈 필요가 생겨도 “어떤 공개 표본에서 무엇이 일어났는가”를 분리한 상태에서 별도 numerical Decision을 만들 수 있다. 자동 튜닝이나 덱/손패/드로우, 전면 의도 공개는 도입하지 않는다.

## 검증 증거

- TDD RED: 새 policy·4,500 scenario·schema 2 기대값을 먼저 추가했을 때 세 정책만 등록된 기존 구현이 policy 회귀에서 실패했다.
- TDD GREEN: Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`)에서 `verify_vertical_slice_balance_public_policy`, `verify_vertical_slice_balance_instrumentation`, `verify_vertical_slice_balance_report_runner`, `verify_ai_rival_tendency`, `verify_phase2_combat_resolution`이 모두 PASS했다.
- 실제 full report 두 번: 각 4,500 resolver 결투가 byte-identical SHA-256 `B311E75470063A96A382356C55C03E107CDF23316EB8035C360298B0DF7B4D5D`를 만들었고 Python report checker가 PASS했다.
- full Python suite: `428 tests` PASS.
- current operating system, canonical reference freshness, approved protected contract(정확한 manifest + pinned Base)과 focused governance/current-owner 회귀가 PASS했다.
- `git diff --check` PASS. 생성 `.import` 캐시는 staging하지 않았고 implementation commit에는 포함되지 않았다.
- PR #289 첫 원격 CI readback은 active `BUILD_APPROVAL_2026-08-30.md`에 이전 package addendum만 있고 이번 runtime-adjacent validation scope가 같은 PR diff에 없다는 delivery-gate 누락을 fail-closed로 찾았다. 사용자 승인과 이번 Decision에 맞는 PR #289 addendum을 추가해 재실행한다.

## 다섯 번의 전체 적대 검토

| loop | 공격한 위험 | 결과 / 최소 조치 |
|---|---|---|
| 1 | scope가 실제 결투 수치·UI·저장을 바꾸는지 | `REJECTED`: diff는 validation matrix/report/policy와 정본 상태만 바꾼다. 카드/profile 수치와 소비 UI는 untouched다. |
| 2 | 새 policy가 숨은 상대 행동·미확정 계획·UI signal을 읽는지 | `REJECTED`: `_public_snapshot`은 공개 위치·자원·기세·공개 이력만 노출한다. private sentinel 회귀가 placement 불변을 확인한다. |
| 3 | schema 2가 카드 ID·목표·AI trace를 row에 누출하는지 | `REJECTED`: 고정 네 aggregate 키 외 row key를 거부하고 forbidden-token checker 및 Godot row regression을 통과했다. |
| 4 | 정적 표기만 바꾸고 resolver 실행/결정성을 주장하는지 | `REJECTED`: 실제 4,500 resolver 결투 두 번과 byte-identical hash, 실행 metric coverage를 확인했다. |
| 5 | 현재 상태 소비처·보호 전달 계약·환경 실패를 숨기는지 | `REFINED`: 오래된 v1 `next_phase` assertions를 새 Decision으로 동기화했고, 정확한 4-path manifest를 만들었다. TEMP 포화는 clean historical worktree만 정리한 후 전체 suite 재실행으로 닫았다. |

`CLEAN_REVIEW_EXIT`: 위 다섯 관점에서 새 범위 이탈, private-information leak, report schema leak, unresolved deterministic failure, current-consumer drift는 남지 않았다.

## 자동화·학습 반영

새 report checker는 guard/evade/recovery/ultimate 선택 표본과 실제 회피 성공·절초 실행을 각각 0 초과로 요구한다. 따라서 다음 계측 변경이 policy 등록만 하고 실행 coverage를 만들지 못하면 fail-closed한다. 임시 저장 공간 포화도 코드 실패와 구별했고, 현재 작업의 깨끗한 완료 worktree만 정리하는 recovery 절차로 닫았다.

## 미검증·남은 위험

- PR #289은 `7072c3b49130434d1bf213d2275004c4f91a789e`로 병합됐고 remote CI 전체 PASS를 확인했다. PR #290은 active manifest를 immutable archive로 전환하고 adapter baseline을 승격한 뒤 `97961e87d93720d94a6a7862753d0af2c9592cd7`로 병합됐다. exact `origin/main` readback은 manifest 부재, archive 존재, adapter baseline `7072c3b4…`를 확인했다.
- Windows-visible UX, 사람 플레이, Android 기기, 접근성 사용자, release 성능은 이번 validation-only 변경에 대해 `NOT_RUN`이다.
- 보고서 표본은 수치 밸런스, 공정성, 재미 또는 출시 준비 완료를 뜻하지 않는다. card/profile/recovery/stat 값을 바꾸려면 결과 검토와 별도 numerical balance Decision이 필요하다.
