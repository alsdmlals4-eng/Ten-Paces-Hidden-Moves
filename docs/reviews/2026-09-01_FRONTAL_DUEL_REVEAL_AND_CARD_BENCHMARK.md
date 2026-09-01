# 십보강호 정면 결투·순차 공개·통합 카드 벤치마크 보강 · 2026-09-01

```yaml
report_id: TEN-RES-20260901-FRONTAL-DUEL-REVEAL-CARD-BENCHMARK-01
extends: docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md
decision_dimension: FRONTAL_DUEL_PRESENTATION_ACTION_BY_ACTION_REVEAL_UNIFIED_ACTION_CARD_SURFACE
research_date: 2026-09-01
research_question: "정면 공유 바닥의 1:1 결투, 3/3/4 잠금 뒤 한 수씩 공개되는 해결, 기초·무공·절초의 단일 카드 표면을 어떻게 결합해야 숨은 계획과 거리 판단을 지키면서 결과 원인을 읽을 수 있는가?"
current_source_relevance_check: CURRENT_OFFICIAL_PRODUCT_AND_PLATFORM_SOURCES_RECHECKED
sample_requirement: "direct comparison 3+, adjacent system 3+, negative or mixed transfer 1+"
benchmarked_game_count: 10
evidence_ceiling: DESK_RESEARCH_ONLY_NO_TEN_PACES_HUMAN_PLAYTEST_NO_RUNTIME_OR_RULE_MUTATION
```

## 범위와 보호선

이 보강은 기존 12종 보고서를 대체하지 않는다. 최신 사용자 방향과 같은 판단 축만 다시 확인한다.

- 보호: 10칸 논리 거리, 시작 거리 2, `3 → 해결 → 3 → 해결 → 4 → 해결`, 숨은 계획, 공개 이력만 읽는 AI, 관찰의 행동 **유형만** 공개, 덱/손패/드로우 부재.
- 새 규칙 금지: 전면 적 계획·목표·피해 공개, 공격 방향 선택, 실시간 반응 시험, 새 카드 경제, 새 저장 데이터.
- 화면 목표: 바닥 격자 없이 두 인물이 같은 기준선에 서고, `거리 N`과 현재 행동 묶음이 먼저 읽힌다. 해결에서는 오직 현재 수만 양측에 드러나며, 다음 수는 숨긴다.
- 사용자 반응 신호는 Steam aggregate·공개 업데이트 등 제한된 신호다. 만족/불만의 인과나 십보강호 플레이어 경험을 증명하지 않는다.

## 10개 사례의 역공학

| 사례 | 분류 | 공식 제품 사실·제한된 신호 | 기제 | 십보강호 전환 원칙 | DO NOT COPY | 판정 |
| --- | --- | --- | --- | --- | --- | --- |
| [Your Only Move Is HUSTLE](https://steamcommunity.com/app/2212330?l=english) | 직접 · 계획 결투 | 공식 Steam 페이지는 frame-by-frame의 turn-based combat simulator와 느린 시간으로 전투를 조율하는 구조를 설명한다. 공개 커뮤니티에는 정확한 move viewer가 진입 장벽을 낮춘다는 한 개의 긍정 신호가 있지만 인과 증거는 아니다. | 결정을 먼저 확정하고 연속 장면으로 결과를 본다. | 한 수의 **확정감**과 해결 후 복기는 유지한다. | 미래 전체 예측, frame 데이터, 완전한 상대 입력 시뮬레이션. | **ADAPT / MIXED** — 완전 예측은 수읽기를 없애므로 금지한다. |
| [Shogun Showdown](https://goblinzstudio.com/game/shogun-showdown/) | 직접 · 거리/타이밍 | 공식 소개는 "every action counts"인 turn-based combat와 positioning·attack timing을 설명한다. 별도 원인 분석 가능한 사용자 표본은 이번 조사에 없다. | 위치와 행동 순서를 함께 결정한다. | 3/3/4 슬롯은 공격만이 아니라 준비·방어·관찰의 commitment도 같은 밀도로 보여 준다. | 덱빌딩·업그레이드·타일 화면 문법. | **ADAPT** |
| [Fights in Tight Spaces](https://www.groundshatter.com/home) | 직접 인접 · 전술 카드 | 공식 개발사 소개는 카드 기반 turn tactics와 공간 통제를 소개하며, 공개 패치 기록은 가독성·카드 텍스트·위험 표시를 반복 개선한다. 이는 UI 문제가 실제 운영 항목이었다는 공개 신호이지 원인 증명은 아니다. | 카드 한 장의 사실과 공간 결과를 같은 결정을 위해 읽는다. | 카드 안에서 이름·수 점유·비용·효과를 빠르게 비교하고 상세는 보조 패널로 내린다. | 덱/손패/드로우, 다수 적 격자, UI skin. | **ADAPT** |
| [Hellish Quart](https://www.hellishquart.com/) | 직접 인접 · 검술 접지 | 공식 사이트는 1대1 검술에서 칼날이 물리적으로 충돌·방어하며 잘 맞춘 한 번의 공격이 결정적일 수 있음을 설명한다. 플레이 경험 인과를 말할 사용자 연구는 없다. | 가드·거리·무기 접촉이 타격의 이유가 된다. | 합/방어/사거리 실패는 피해 숫자보다 먼저, 같은 바닥에 선 두 인물의 관계로 보인다. | 물리 충돌, 절단·즉사, 역사 인물·모션. | **ADAPT** |
| [For Honor: Art of Battle](https://www.ubisoft.com/en-ca/game/for-honor/news-updates/3i9GE9e7XGWHqKQH2wUtZc/for-honor-the-art-of-battle) | 직접 인접 · 대치 상태 | Ubisoft는 weapon position을 직접 제어해 attack·block·feint를 만드는 Art of Battle을 설명한다. 제품 소개는 사용성 검증이 아니다. | 자세·무기 방향이 대치의 긴장을 전달한다. | 확정 전/해결 후의 시각 층위는 분리하되, 고정 정면 대치와 자동 공격 대상을 우선한다. | 3방향 stance, 공격 방향 입력, 실시간 리액션 부담. | **ADAPT / AVOID** |
| [Into the Breach](https://subsetgames.com/itb.html) | 인접 · 공개 정보 | Subset Games는 모든 적 공격이 telegraphed되는 minimalistic turn-based combat를 공식 설명한다. 사람 반응 원인 분석은 이번 범위 밖이다. | 적 의도를 전면 노출해 퍼즐 대응을 만든다. | 관찰의 `공격/방어/이동…` **유형**은 선명히, 기술명·대상·피해·뒤 수는 계속 숨긴다. | 완전 적 intent, target/damage 공개, 격자 퍼즐. | **ADAPT / AVOID** |
| [Phantom Brigade](https://braceyourselfgames.com/phantom-brigade/) | 인접 · 타임라인 해결 | 공식 사이트는 예측한 적 행동을 타임라인 위에 대응책으로 배치하고 실행 뒤 실시간으로 보는 구조를 설명한다. 공식 FAQ는 prediction 개선을 포함한 QOL 변경을 기록한다. | 계획 층과 결과 층을 분리한다. | 잠금된 3/3/4 계획은 작고 명확히, 해결은 한 수씩 크게 전환한다. | 미래 전체 시각화, 메카/파괴 표현, 다수 유닛 timeline. | **ADAPT** |
| [Marvel's Midnight Suns](https://blog.playstation.com/2022/10/26/marvels-midnight-suns-super-heroic-turn-based-combat-and-card-tactics-explained/) | 인접 · 카드 사실성 | Firaxis의 공식 설명은 영웅 능력을 card로 표현하고, 카드가 적중/효과를 명확히 전달하도록 만든 이유를 설명한다. 이번 조사에는 별도 인과 연구가 없다. | 카드가 행동 명세와 선택 표면을 겸한다. | 공통 카드 렌더러가 삽화와 텍스트 사실을 함께 보존한다. | 8장 덱, draw/redraw, 히어로 IP·UI. | **ADAPT** |
| [Inkulinati](https://store.steampowered.com/app/957960/Inkulinati/?l=english) | 인접 · 수묵 정보 위계 | 공식 Steam 페이지는 중세 필사본에서 나온 turn-based strategy와 매 수의 계획을 설명한다. 확인 시점의 공개 aggregate는 Very Positive 87%/714으로 표시됐지만 미적 방향의 인과 증거는 아니다. | 질감 있는 세계가 수치·선택 가독성과 공존한다. | 한지·먹·제한된 금색은 데이터 대비를 침범하지 않는 배경 문법으로만 쓴다. | 필사본 캐릭터/유머/army/bestiary, 덱빌딩. | **ADAPT** |
| [Slay the Spire](https://store.steampowered.com/app/646570/Slay_the_Spire?l=english) | 부정 경계 · 카드 시스템 | 공식 Steam 페이지는 매 run에 카드를 더하는 dynamic deck building을 설명하며, 확인 시점 영문 aggregate는 Overwhelmingly Positive 97%/76,743으로 표시된다. 이 수치는 행동 원인을 증명하지 않는다. | 카드 사실과 상승하는 선택 복잡도가 연결된다. | 카드의 작은 정보 계층·상세 진입성만 취한다. | 카드 획득·덱·손패·draw/discard, 장르 루프. | **AVOID (core boundary)** |

## 종합 적용

| 유지 또는 변경 | 현재 상태 → 요청 이유 | 기대 효과 | 채택 상태 |
| --- | --- | --- | --- |
| 정면 공유 바닥 | 논리 tile layer와 발 기준선이 현재 구현 내부에 남아 있다 → 사용자는 보드와 허공 느낌을 원하지 않는다. | 두 인물의 거리·대치가 첫 시선에 읽히고 논리 10칸은 표현을 지배하지 않는다. | `ADOPT` |
| 한 수씩 공개 | 구현은 이미 timing별 overlay를 가진다 → 카드 표면과 결과 정보의 밀도를 더 명확히 맞춘다. | 현재 수의 원인·결과를 이해하고 미래 수는 추론으로 남긴다. | `ADOPT` |
| 이동만 전/후 선택 | 현 `attack_direction` target path가 남아 있다 → 공격의 방향 고르기는 불필요한 입력이다. | 이동의 의도는 명확하면서 공격 선택은 빠르고 일관된다. | `ADAPT` |
| 공통 카드 표면 | `ActionChoiceCard`는 존재하지만 전투판은 `BasicCardTray`/별도 절초 목록과 함께 병존한다. | 기초·무공·절초 모두 삽화+이름+수+비용+효과를 같은 위치에서 비교한다. | `ADOPT` |
| 관찰의 경계 | 관찰은 잠긴 적 행동 유형만 공개하도록 구현됐다. | 공개 단서가 실제 판단을 돕되 숨은 계획·AI 공정성을 침해하지 않는다. | `ADOPT` |

## 이번 연구의 판정과 다음 증거

```yaml
feasibility: PARTIAL
why_partial:
  - "새 규칙·새 raster asset은 필요하지 않으며 현재 data, final-locked background/battlers/card atlas/VFX, sequential reveal consumer가 존재한다."
  - "그러나 CombatBoardPreview에는 visible TileLayer/FootAnchorGuide, attack_direction, BasicCardTray/UltimateList의 구형 presentation carrier가 남아 있다."
next_evidence:
  - "Blueprint implementation 전에 current Godot consumer와 state-output contract를 test-first로 고정한다."
  - "변경된 화면은 1440×900과 1280×800 runtime capture를 남긴다."
not_proven:
  - "사람이 관찰 유형만으로 다음 수를 올바르게 좁히는지"
  - "Windows/Android 실제 사용성, 접근성 사용자, 성능, 출시 적합성"
```

## 출처와 한계

- 위 링크는 2026-09-01에 다시 확인한 공식 개발사·퍼블리셔·Steam 상품/커뮤니티 페이지다.
- Steam aggregate와 공개 업데이트는 제한된 player/public signal이며, 개별 시스템의 품질이나 사용자 만족 원인을 확정하지 않는다.
- 본 문서는 desk research이다. 십보강호의 human player comparison, device, accessibility, release evidence는 모두 별도 gate에서 `NOT_RUN` 상태다.
