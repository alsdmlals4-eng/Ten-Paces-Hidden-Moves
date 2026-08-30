# 사전 벤치마크·역공학 게이트 실행 보고 · 2026-08-30

```yaml
report_id: TEN-EXEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01
decision: TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01
baseline_origin_main: a28462b54677c725693b139f68cf50f2b2d5ea53
branch: codex/benchmark-gate-recovery-20260830
merged_pr: 287
postmerge_origin_main: ba4fed201f4c2e37f9ed5fbc32027344ccb9a56d
work_mode: PLAN
skill: ten-paces-hidden-moves-workflow-router, governing-game-user-research-coverage, analyzing-and-refining-game-concepts, ten-paces-game-design, combat-ux-and-accessibility
skill_mode: CURRENT_SOURCE_RELEVANCE_CHECK_AND_BENCHMARK_REVERSE_ENGINEERING
user_direction: "비슷한 장르,류의 게임 10개 이상 벤치마킹해서 역공학 먼저 진행"
feasibility: FEASIBLE_REPOSITORY_ONLY_POLICY_AND_CANON_CHANGE
product_paths_changed: []
evidence_ceiling: DESK_RESEARCH_AND_CONTRACT_VALIDATION_ONLY
status: IMPLEMENTED_MERGED_MAIN_PR287_REMOTE_CI_PASS_EXACT_MAIN_POSTMERGE_READBACK
```

## 작업 전 문제

현행 `approved_20260805_work_governance_contract.json`은 모든 작업 전 research packet과 비교를 요구했지만, 새 L1+ package에서 몇 개 게임을 어떤 형태로 비교할지는 최소 2개로만 고정했다. 사용자가 요청한 “10개 이상 벤치마킹 후 역공학”을 단순 대화 약속으로 남기면, 다음 package에서 표면적 사례 복제 또는 임의 생략이 가능한 상태였다.

또한 project core는 10칸/거리2/`3-해결-3-해결-4-해결`과 public/hidden fairness를 이미 소유한다. 따라서 이 작업은 게임 규칙·수치·Godot asset/scene을 바꾸는 일이 아니라, 외부 제품 사실을 current core와 대조하는 policy/canon 작업으로 한정했다.

## 조사·비교 결과

- 12개 제품을 직접 예측형 결투 3, 인접 전술 정보/공간 3, 무기 결투의 거리/가드/commitment 5, 혼합/부정 반례 1로 분류했다.
- 각 항목은 공식 제품 source와 `DO_NOT_COPY` 경계를 함께 기록했다. public review aggregate는 Steamworks가 설명하는 feedback channel의 제한된 signal로만 사용했으며, 개별 반응의 원인이나 시장 결론으로 사용하지 않았다.
- `YOMI 2`, `Fights in Tight Spaces`, `Shogun Showdown`, `Absolver`는 모두 card/deck/hand/draw 혹은 Combat Deck을 사용한다. 이는 십보강호에 복제할 선례가 아니라 현재 금지를 더 명확히 하는 반례다.
- `Into the Breach`의 full telegraph와 `Die by the Blade`의 one-hit 방향은 각각 관찰 범주 정보량과 복구 가능성의 상한을 점검하는 데 쓰되, 현재 core로 채택하지 않는다.

## 채택한 구조와 이유

기존 work-governance owner를 확장한다. 새 L1+ package는 10개 이상 unique game, 직접 비교 3, 인접 시스템 3, 부정/혼합 사례 1, 공식 product fact/반응 신호/기제/이전 원칙/`DO_NOT_COPY`/판정이라는 동일 항목을 갖는 packet 뒤에만 시작한다. 초기 12개 report는 2026-08-30 기준 baseline이다.

동일 decision dimension·current project state·source freshness를 다시 만족하는 bounded continuation만 packet을 재사용할 수 있다. 이것은 research volume만 늘리는 의식이 아니라, 수치 조정/UX/콘텐츠/구현 구조마다 다른 반례를 다시 확인하게 하는 장치다. `no silent bypass`.

## TDD 관찰

`tests/test_prework_benchmark_reverse_engineering_gate.py`를 먼저 추가하고 실행했다. 정본 구현 전 결과는 예상 RED였다: 10개 비교 gate 필드와 current planning locator가 없었고, 새 Decision/report/execution-report 경로도 존재하지 않았다. 이 failure는 이번 요구의 정확한 부재를 가리키며, existing product runtime을 고장낸 사실이 아니다.

## 다섯 차례 적대 검토

| Loop | 공격 범위 | finding / 교정 | 상태 |
| --- | --- | --- | --- |
| 1 | authority와 사용자 의도 | 기존 `minimum_reliable_comparables_when_available: 2`가 최신 10개 지시보다 약했다. 같은 structured owner와 validator를 10개 gate로 보강한다. | RESOLVED |
| 2 | core/정보 경계 | card/deck/hand/draw, full enemy plan reveal, real-time reaction, one-hit rule이 현 core를 침식할 수 있었다. 모든 entry에 `DO_NOT_COPY`와 AVOID boundary를 넣는다. | RESOLVED |
| 3 | evidence 품질 | store page/review aggregate를 causal proof로 다루는 위험이 있었다. 공식 product fact와 limited player signal을 분리하고 Steamworks limitation source를 추가한다. | RESOLVED |
| 4 | scope/consumer | policy 작업에 Godot scene, asset, data 또는 runtime evidence를 섞으면 false implementation claim이 된다. product path diff를 금지하고 current planning/Active Context/contract만 연결한다. | RESOLVED |
| 5 | long-term reuse | 같은 12개를 모든 미래 작업에 그대로 붙이면 stale/irrelevant research가 된다. decision dimension·project state·freshness 일치 시에만 reuse하고 아니면 refresh하도록 고정한다. | RESOLVED |

`CLEAN_REVIEW_EXIT`: PASS. local document-policy 검토 후 PR #287의 원격 required checks가 모두 성공했고, 2026-08-30에 squash merge됐다. `origin/main`의 `ba4fed201f4c2e37f9ed5fbc32027344ccb9a56d`을 fresh fetch/readback했고, 검증 worktree의 content가 exact `origin/main`과 동일함을 확인한 뒤 generated-artifact freshness, project operating-system check, full Python regression을 다시 실행했다. Human/player, Windows visible, Android device, accessibility-user, release performance는 독립적으로 `NOT_RUN`이다.

## 검증 예정과 한계

| 검증 | 현재 상태 | 증명 범위 |
| --- | --- | --- |
| focused prework gate + governing contract tests | PASS, 21 tests | 10-game policy, validator, current owner and map contract |
| work governance validator | PASS | structured policy fields and required per-comparable records |
| operating contract / generated-artifact freshness | PASS | project owner consistency; Base operating view is current |
| full Python regression | PASS, 428 tests | existing repository contracts remain valid with the new gate |
| PR #287 remote CI | PASS | required checks에 failure/cancelled/timed-out 결과 없음; Godot/Windows jobs도 성공 |
| postmerge exact-main readback | PASS | squash commit `ba4fed201f4c2e37f9ed5fbc32027344ccb9a56d` = fresh `origin/main`; local validation content와 diff 없음 |
| Godot runtime | NOT_RUN_NOT_REQUIRED_FOR_NO_PRODUCT_PATH_DIFF | `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot` diff가 없어 gameplay runtime change를 주장하지 않는다 |
| Human/player and device validation | NOT_RUN | external desk research와 자동 test가 대체할 수 없음 |

## 자동화·학습 반영

10개 기준과 entry fields를 Python validator와 regression으로 고정한다. 앞으로 source 하나가 사라지거나 10개 미만으로 축소되거나 `DO_NOT_COPY`/negative-case 없이 사례 목록만 쌓으면 regression이 실패해야 한다. 같은 issue가 반복되면 current report를 복사하지 않고 해당 decision dimension에서 새 packet을 refresh한다.

## 미검증·남은 위험

1. 이 report는 실제 십보강호 플레이 경험이나 재미를 증명하지 않는다.
2. 12개 source의 제품 버전·store text·review aggregate는 변할 수 있으므로 future package에서 live source를 refresh한다.
3. 새 balance/UX/core mutation은 이 gate를 통과해도 별도 user Decision, feasibility, TDD, Godot runtime/human evidence가 필요하다.
