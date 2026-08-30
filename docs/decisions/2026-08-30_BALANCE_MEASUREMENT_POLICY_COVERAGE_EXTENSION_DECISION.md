# Balance Measurement-Policy Coverage Extension Decision

~~~yaml
decision_id: TEN-DEC-20260830-BALANCE-MEASUREMENT-POLICY-COVERAGE-EXTENSION-01
status: USER_CONTINUATION_APPROVED_IMPLEMENTED_MERGED_MAIN_PR289_REMOTE_CI_PASS_PROTECTED_APPROVAL_ARCHIVED_PR290_POSTMERGE_READBACK
baseline_origin_main: 65fc68a299e0b62a187baadb798d0ca82388b580
work_mode: BUILD
approval_source: "user explicit: 좋아 진행해; existing long-horizon direction: 권장안대로 진행해 / godot에 기획안들 전부 다 구현될 때까지 멈추지마"
predecessor: TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
scope: OPENING_NO_ROUTE_ENGINE_DIRECT_VALIDATION_ONLY_POLICY_COVERAGE_EXTENSION
current_source_relevance_check: REUSE_ALLOWED_SAME_DAY_INITIAL_12_GAME_PACKET_SAME_SINGLE_DUEL_BALANCE_DECISION_DIMENSION_SAME_RUNTIME_STATE_FOUR_OFFICIAL_SOURCES_LIVE_RECHECKED
implementation_feasibility: FEASIBLE_CURRENT_GODOT_4_7_1_ENGINE_AND_PUBLIC_POLICY_BOUNDARY_EXIST
runtime_evidence: TWO_4500_SCENARIO_HEADLESS_GODOT_4_7_1_REPORTS_BYTE_IDENTICAL
windows_visible: NOT_RUN
human_player: NOT_RUN
android_device: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
~~~

## 작업 전 문제

기존 v1 계측은 15명 후보 × 15개 합법 시작 무공 조합 × 3개 공개 정책 × 5개 AI 시드, 총 3,375개 단일 결투를 실제 resolver로 실행했다. 그러나 `public_guarded_exchange`는 항상 막기를 우선해 회피 성공이 0회였고, 세 정책 모두 절초를 선택하지 않아 절초 실행도 0회였다. `public_recovery_range`는 회복을 선택해도 기존 행 스키마가 선택 범주를 기록하지 않아 회복 행동 coverage를 판정할 수 없었다.

이는 전투 수치, 캐릭터, 카드, UI 결함이 아니라 계측 입력과 공개 결과 행의 관측 공백이다. 전임 Decision은 이 공백을 같은 v1 수치 변경으로 처리하지 말고 별도 measurement-policy Decision으로 다루도록 명시했다.

## 조사·비교 및 출처 관련성

이번 작업은 같은 날의 12개 사전 벤치마크 packet을 재사용할 수 있는 동일 decision dimension이다. 프로젝트의 실제 결투 resolver·후보·시작 무공·opening_no_route 범위는 packet 병합 뒤 바뀌지 않았고, 이번 변경은 게임 규칙·화면·콘텐츠가 아니라 검증용 행동 표본만 넓힌다.

- [Yomi 2 공식 소개](https://www.sirlin.net/posts/introducing-yomi-2)는 super meter를 쌓아 super move를 쓰는 구조를 설명한다. `ADAPT`: 십보강호의 이미 존재하는 공개 기세 5 조건이 실제로 계측되는지만 본다. `DO_NOT_COPY`: hand, discard, 교환 시스템이나 gem 능력은 도입하지 않는다.
- [Fights in Tight Spaces 공식 Steam 페이지](https://store.steampowered.com/app/1265820/Fights_in_Tight_Spaces/)와 [Shogun Showdown 공식 Steam 페이지](https://store.steampowered.com/app/2084000/Shogun_Showdown/)는 위치·기세·공격 타이밍을 강조하지만 deck-building을 전제한다. `ADAPT`: 위치/행동 결과를 분리 관찰한다. `REJECT`: deck, hand, draw, build 선택지를 십보강호에 추가하지 않는다.
- [Die by the Blade 공식 Steam 페이지](https://store.steampowered.com/app/1154670/Die_by_the_Blade/)의 one-hit kill은 혼합/부정 반례다. `AVOID`: 새 policy가 존재한다고 결투를 일격 필살 또는 전면 의도 공개형으로 바꾸지 않는다.

따라서 source freshness와 project-state relevance가 일치해 초기 12개 packet을 재사용한다. 이 재사용은 플레이어 재미·공정성 증명이 아니며, 사람 플레이와 별도 수치 Decision을 대체하지 않는다.

## 결정

1. 기존 `public_approach_pressure`, `public_guarded_exchange`, `public_recovery_range`를 삭제·의미 변경하지 않는다.
2. 네 번째 validation-only 정책 `public_evade_then_ultimate`를 추가한다. 이 정책은 공개 거리, 자신의 공개 자원/기세, 공개 카드 정의, 공개 해결 이력만 읽는다.
   - 기세가 최대가 아니면 합법·지불 가능한 `basic_evade`를 우선한다.
   - 기세가 최대면 현재 공개 거리와 묶음 슬롯에 맞는 기본 절초만 선택한다: 거리 1은 `ultimate_ten_paces_wave`, 거리 2는 `ultimate_cleave_peak`, 거리 3은 `ultimate_void_sword_qi`.
   - 회피가 불가하면 기존 공개 회복/거리 fallback을 사용한다. 숨겨진 적 행동, AI trace, 미확정 플레이어 배치, UI 포인터/preview/관찰 답변은 읽지 않는다.
3. matrix는 15 × 15 × 4 × 5 = **4,500** scenario로 확장한다. route는 계속 `opening_no_route`, 공개 시작 거리 2, 3/3/4, 최대 12라운드다.
4. report schema는 2로 올리고, 행마다 카드 ID·목표·상대 계획을 쓰지 않는 고정 `policy_selection_counts` 네 키(`guard`, `evade`, `recovery`, `ultimate`)만 추가한다. 이는 합법 placement 선택 횟수이지 승률·공정성 threshold가 아니다. 실제 절초 실행과 회피 성공은 기존 resolver 기반 `battle_metrics`로 따로 남긴다.

## 보호·제외

- 10칸, 공개 시작 거리 2, 3/3/4, 합·방어·회피·중단·강건, 전투 수식, AI 공개정보 경계, retry, save/load를 바꾸지 않는다.
- candidate profile, 무공/기초/절초 카드 수치·비용·효과, Scene/UI/asset/audio/localization/Android/telemetry/auto-tuning을 바꾸지 않는다.
- 이 정책은 플레이어 전략, 상대 공략, 난이도 판정, Human UX PASS가 아니다.

## 수용 기준

1. 4개 정책·5개 seed·현재 15 후보·15 시작 조합에서 정확히 4,500 scenario가 fail-closed로 생성된다.
2. 새 policy의 공개 상태 행동은 실제 engine legality boundary를 통과하고, private sentinel을 주입해도 placement가 변하지 않는다.
3. full report는 fixed public row schema만 포함하고, guard/evade/recovery/ultimate 선택 표본과 새 policy의 successful dodge/ultimate execution이 모두 0보다 커야 한다.
4. 같은 exact source와 입력에서 두 independent Godot 4.7.1 headless run이 byte-identical report를 만든다.
5. 자동/headless 통과는 `MACHINE_VERIFIED`일 뿐 Windows-visible, Human, Android, accessibility, release, numerical balance PASS가 아니다.

## 다음 경계

이 Decision이 만든 4,500개 결과는 수치 변경의 근거 후보일 뿐 자동 변경 권한이 아니다. 실제 card/profile/recovery/stat 값을 바꾸려면 결과 검토, 새 numerical balance Decision, data 회귀, Godot runtime 및 별도 Human/player evidence가 필요하다.
