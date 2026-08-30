# 십보강호 사전 12종 벤치마크·역공학 · 2026-08-30

```yaml
report_id: TEN-RESEARCH-20260830-BENCHMARK-REVERSE-ENGINEERING-01
decision: TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01
benchmark_entry_count: 12
research_date: 2026-08-30
research_question: "새 수치·UX·콘텐츠·구현 package가 십보강호의 수읽기/거리/숨은 계획/순차 해결을 흐리지 않으면서 실제 player-facing 가치를 만들려면, 무엇을 채택·변형·회피·검증해야 하는가?"
decision_changed_by_answer: "새 L1+ package는 10개 이상 공식-사실 기반 역공학 packet 뒤에만 계획 또는 mutation을 시작한다. 이번 분석은 현행 core 변경을 제안하지 않는다."
current_source_relevance_check: CURRENT_OFFICIAL_PRODUCT_AND_PLATFORM_SOURCES_CHECKED
source_types: [OFFICIAL_PRODUCT_FACT, LIMITED_PLAYER_RESPONSE_SIGNAL]
evidence_ceiling: DESK_RESEARCH_ONLY_NO_TEN_PACES_HUMAN_PLAYTEST_NO_RUNTIME_OR_RULE_MUTATION
```

## 읽는 방법과 한계

`OFFICIAL_PRODUCT_FACT`는 개발사/퍼블리셔 또는 공식 Steam/Nintendo 상품 페이지의 설명만 말한다. `LIMITED_PLAYER_RESPONSE_SIGNAL`은 Steam의 공개 aggregate badge처럼 관찰 시점에 변하는 반응 신호다. Steamworks는 review를 feedback channel 중 하나로 설명하며 score가 경험의 인과를 증명하지 않음을 전제로 한다. 따라서 아래 `transfer principle`은 사실의 복사가 아니라 십보강호 정본과 대조한 설계 해석이다.

모든 항목의 `DO_NOT_COPY`는 해당 제품의 UI·아트·캐릭터·문구·수치·고유 시스템 표현을 재현하지 않는다는 뜻이다. 십보강호는 이미 10칸/공개 거리2/`3-해결-3-해결-4-해결`/공개 관찰 범주/숨은 기술 배치/AI public-state fairness를 소유하므로, 이 문서는 이를 변경하지 않는다.

## 범주 배치

| 범주 | entries | 이유 |
| --- | --- | --- |
| 직접 예측형 결투 | 3 | 동시 또는 순차 행동을 읽고 확정·해결하는 규칙을 비교 |
| 전술 공개정보·공간 | 3 | 정보 공개량, 공간, 행동 타이밍의 전달 방식을 비교 |
| 무기 결투·거리감 | 5 | 가드, 거리, 공격 commitment의 화면 언어를 분리 |
| 부정/혼합 반례 | 1 | 위험한 한 방 구조와 출시 품질 기대의 비용을 비교 |

## 사례별 역공학

### game_id: YOUR_ONLY_MOVE_IS_HUSTLE

- class: DIRECT_PREDICTION_DUEL
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Steam 공식 상품 페이지](https://store.steampowered.com/app/2212330/Your_Only_Move_Is_HUSTLE/)는 frame-by-frame 계획을 쓰는 turn-based combat simulator와 online PvP/sandbox를 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL` — 같은 상품 페이지에 최근/영문 review aggregate가 매우 긍정적으로 표시됐으나, 이것만으로 만족 원인을 추정하지 않는다.
- mechanism: 행동을 결정 전에 세밀하게 검토하고 대전 상대의 선택을 읽는다.
- transfer_principle: 확정 전 계획의 결과감은 강하되, 상대의 완전한 정답을 먼저 보여 주지 않아야 수읽기가 남는다.
- DO_NOT_COPY: frame-level 입력, TAS형 조작, 애니메이션/표현 및 sandbox 재현.
- disposition: [ADAPT] `3/3/4` bundle의 확정감과 해결 후 복기 가시성만 강화 후보로 보존한다.

### game_id: TORIBASH

- class: DIRECT_PREDICTION_DUEL
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Toribash 공식 소개](https://www.toribash.com/about.html)와 [Steam 공식 상품 페이지](https://store.steampowered.com/app/248570/Toribash/)는 turn-based fighting에서 관절 조작으로 수를 설계하는 구조를 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL` — 공개 Steam aggregate는 참고 신호일 뿐 관절 조작 복잡도가 만족/불만의 원인이라는 증거가 아니다.
- mechanism: 한 턴의 물리적 결과가 다음 턴의 자세와 선택지를 만든다.
- transfer_principle: 한 수의 결과는 다음 판단의 public state를 바꿔야 한다.
- DO_NOT_COPY: 관절 단위 편집, ragdoll physics, UI와 자세 simulation.
- disposition: [ADOPT] 해결 이력이 다음 수의 판단 근거가 되는 원칙을 현재 public-history 계약과 대조해 유지한다.

### game_id: YOMI_2

- class: DIRECT_PREDICTION_DUEL
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Sirlin Games의 Yomi 2 소개](https://www.sirlin.net/posts/introducing-yomi-2)와 [Nintendo 공식 상품 페이지](https://www.nintendo.com/us/store/products/yomi-2-switch/)는 attack/block/throw/dodge/ability를 카드 형태의 fighting-game decision으로 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL_OR_GAP` — 이번 desk study는 원문 review를 인과 분석하지 않았고, game-specific player interview도 없다.
- mechanism: 행동 분류 사이의 상성으로 상대 경향을 읽는다.
- transfer_principle: 공격·방어·회피·준비·관찰의 읽기 가능한 유형은 유용하지만, 유형을 정답표로 노출하면 안 된다.
- DO_NOT_COPY: card/deck/hand/draw, 교환/콤보 경제, 캐릭터/카드 표현.
- disposition: [ADAPT] action taxonomy의 대결 언어만; deck/hand/draw는 [AVOID].

### game_id: FIGHTS_IN_TIGHT_SPACES

- class: ADJACENT_TACTICAL_SPACE
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Steam 공식 상품 페이지](https://store.steampowered.com/app/1265820/Fights_in_Tight_Spaces/)는 deck-building turn tactics, space control, martial-arts sequence를 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL_OR_GAP` — 이번 packet은 review 원문 분석을 수행하지 않았다.
- mechanism: 위치와 행동 순서가 공격 기회와 위험을 함께 만든다.
- transfer_principle: 거리 변화는 단순 수치가 아니라 다음 유효 행동과 위험을 읽을 수 있게 보여야 한다.
- DO_NOT_COPY: deck-building, hand, grid board art, 카드 흐름과 액션 연출.
- disposition: [ADAPT] 거리/도착지/판정 이유의 명확성; core의 deck/hand/draw 금지는 유지한다.

### game_id: INTO_THE_BREACH

- class: ADJACENT_TACTICAL_INFORMATION
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Subset Games 공식 소개](https://www.subsetgames.com/itb.html)는 turn-based strategy에서 적의 공격이 telegraphed되는 전투를 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL_OR_GAP` — 이번 보고서는 공식 설명과 구조 비교만 사용한다.
- mechanism: 공개된 적 intent를 바탕으로 피해를 재배치·상쇄한다.
- transfer_principle: 플레이어가 어떤 공개 단서로 판단해야 하는지는 선명해야 하지만, 단서의 정보량은 게임의 수읽기를 제거하지 않는 선에서 제한한다.
- DO_NOT_COPY: 적의 정확한 행동/타깃/피해 전면 노출, grid puzzle, mecha/세계관/UI.
- disposition: [ADAPT] 관찰 범주의 의미와 해결 원인 가시화; 완전 계획 공개는 [AVOID].

### game_id: SHOGUN_SHOWDOWN

- class: ADJACENT_TACTICAL_TIMING
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Steam 공식 상품 페이지](https://store.steampowered.com/app/2084000/Shogun_Showdown/)는 turn-based combat에서 positioning, attack timing, upgrade/deck-building 요소를 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL_OR_GAP` — 개별 평가의 이유를 이번 단계에서 인과로 채택하지 않았다.
- mechanism: 공격을 즉시 난사하지 않고 위치·timing을 축적해 강한 수를 만든다.
- transfer_principle: 준비/중단/방어가 공격과 동등한 선택임을 timeline에서 명확히 드러내야 한다.
- DO_NOT_COPY: deck-building/upgrades, tile UI, 타이틀 고유 표현.
- disposition: [ADAPT] 행동 타이밍의 readable commitment; deck loop는 [AVOID].

### game_id: FOR_HONOR

- class: MARTIAL_SPACING_AND_GUARD
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Ubisoft의 Art of Battle 설명](https://www.ubisoft.com/en-us/game/for-honor/news-updates/3i9GE9e7XGWHqKQH2wUtZc/for-honor-the-art-of-battle)은 stance/weapon position으로 상대 의도를 표시하고 block, attack, feint를 선택하는 구조를 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL_OR_GAP` — 공식 tutorial/marketing은 사용성 검증이 아니며 별도 player study가 필요하다.
- mechanism: 공격 방향, 가드, feint가 서로의 읽기·대응 여지를 만든다.
- transfer_principle: 공개 telegraph와 확정된 행동을 시각적으로 다른 상태로 구분한다.
- DO_NOT_COPY: 실시간 stick control, 3방향 stance 입력, 캐릭터/애니메이션/UI.
- disposition: [ADAPT] 대각 대치 화면에서 가드/관찰/확정 단계의 시각적 층위; 실시간 reaction test는 [AVOID].

### game_id: SAMURAI_SHODOWN

- class: MARTIAL_SPACING_AND_COMMITMENT
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Steam 공식 상품 페이지](https://store.steampowered.com/app/1342260/SAMURAI_SHODOWN/)는 blade-wielding fighting series의 대전 제품이라는 사실을 제공한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL_OR_GAP` — 이 desk packet은 player review 인과를 조사하지 않았다.
- mechanism: 무기 대결의 거리와 한 번의 commitment가 긴장감을 만든다.
- transfer_principle: 큰 수는 충돌 전후에 명확한 거리·위험·회복 맥락이 있어야 읽힌다.
- DO_NOT_COPY: 대전 input/command, 캐릭터/무기/연출, damage values.
- disposition: [ADAPT] 고위험 선택의 visual commitment; 실시간 격투 규칙은 [AVOID].

### game_id: HELLISH_QUART

- class: MARTIAL_SPACING_AND_GUARD
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Hellish Quart 공식 사이트](https://www.hellishquart.com/)는 역사적 1대1 sword duel, physics clash/block, guard를 지난 잘 맞춘 공격의 결정성을 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL_OR_GAP` — 이번 단계에서 장기 만족도나 난이도 원인을 검증하지 않았다.
- mechanism: 가드와 거리에서 단 한 번의 정확한 공격이 의미를 갖는다.
- transfer_principle: 타격 성공은 임의 피해 숫자만이 아니라 가드/거리/중단 여부와 연결해 설명한다.
- DO_NOT_COPY: physics collision, 절단/one-hit 표현, 역사 인물/모션/아트.
- disposition: [ADAPT] decisive-resolution의 설명성; one-hit lethality는 [AVOID].

### game_id: NIDHOGG_2

- class: MARTIAL_SPACING_AND_FACING
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Steam 공식 상품 페이지](https://store.steampowered.com/app/535520/Nidhogg_2/)는 2D swordplay, parry, opposing side로 전진하는 대전 목표를 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL_OR_GAP` — product page의 public feedback은 별도 원인 검증을 대체하지 않는다.
- mechanism: facing과 거리의 즉시 읽힘이 맞대결의 판단 속도를 낮춘다.
- transfer_principle: logical 10칸을 바닥 grid로 강제하지 않고도, 서로 마주하는 방향과 거리 변화는 즉시 알아볼 수 있어야 한다.
- DO_NOT_COPY: race-to-goal objective, 2D art, weapon control, 화면 구성.
- disposition: [ADAPT] 대각 대치 캐릭터의 facing/spacing legibility; 레이스 목적은 [AVOID].

### game_id: ABSOLVER

- class: MARTIAL_STYLE_IDENTITY
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Steam 공식 상품 페이지](https://store.steampowered.com/app/473690/Absolver)와 [공식 사이트](https://www.absolvergame.com/)는 stance, dodge/parry, player-arranged Combat Deck을 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL_OR_GAP` — 이번 단계에서 build complexity가 반응에 미친 영향을 추론하지 않는다.
- mechanism: 스타일과 배운 기술 조합이 장기적인 대전 정체성을 만든다.
- transfer_principle: 해금 기술은 플레이어의 파훼 선택지를 확장해야 하며, 성장만으로 판단을 대체하면 안 된다.
- DO_NOT_COPY: Combat Deck, stance combo memory, real-time combat/control, world/art.
- disposition: [ADAPT] martial identity/growth principle; Combat Deck과 sequence memorization은 [AVOID].

### game_id: DIE_BY_THE_BLADE

- class: NEGATIVE_OR_MIXED_CASE
- source_kind: OFFICIAL_PRODUCT_FACT
- official_fact: [Steam 공식 상품 페이지](https://store.steampowered.com/app/1154670/Die_by_the_Blade/)는 1대1 weapon-focused duel과 one-hit kill/no-health-bar 방향을 설명한다. 2026-08-30 확인.
- player_signal: `LIMITED_PLAYER_RESPONSE_SIGNAL` — 같은 상품 페이지의 영문 aggregate는 Mixed로 관찰됐고, 개발팀의 [공식 사과/향후 계획 공지](https://steamcommunity.com/games/1154670/announcements/detail/4652868978433987468)는 출시 상태가 기대에 미치지 못했다고 설명한다. 두 사실만으로 mixed 평가의 단일 원인은 결론 내리지 않는다.
- mechanism: 실수 한 번의 비용이 큰 즉사형 무기 대결을 약속한다.
- transfer_principle: 강한 긴장감은 필요하지만, 정보 부족/운 나쁜 한 수/설명 부재가 복구 불가능한 손실로 바로 이어져서는 안 된다.
- DO_NOT_COPY: one-hit/no-health rule, 타이틀/무기/아트, store presentation 및 출시 결론.
- disposition: [AVOID] 십보강호의 armor/evade/interrupt/resilience/review를 제거하는 전면 즉사 구조; [TEST] 위기에서 왜 졌는지 사람에게 설명되는지.

## 종합 판정

| disposition | 십보강호에 남길 원칙 | 금지 또는 다음 증거 |
| --- | --- | --- |
| [ADOPT] | 해결 이력은 다음 판단의 public state가 된다. | 이미 정본인 public-history를 새 규칙처럼 중복 구현하지 않는다. |
| [ADAPT] | 거리·가드·관찰·확정·해결을 서로 다른 가시 상태로 보여 준다. | 대각 대치 visual, action reveal, 복기에서 실제 사람이 읽는지 검증한다. |
| [AVOID] | deck/hand/draw, full intent reveal, real-time reaction burden, one-hit all-or-nothing을 도입하지 않는다. | 현 project core와 공정 AI 경계를 그대로 보호한다. |
| [TEST] | 관찰 범주만으로 다음 3수의 위험을 좁히고, 해결 이유를 설명할 수 있는가. | Windows visible/Human player test와 future balance telemetry가 필요하며 현재 `NOT_RUN`이다. |

## 다음 package에 적용할 체크

1. 이 report의 12개 중 decision dimension에 직접 맞는 10개 이상을 source freshness와 함께 다시 확인한다. 예: balance면 `YOMI 2`, `Fights in Tight Spaces`, `Shogun Showdown`, negative case를 반드시 포함하되, visual-only면 외부 UI 복제가 아닌 state-legibility 축으로 다시 분류한다.
2. 전부를 채워도 `FEASIBLE`을 자동으로 얻지 않는다. 실제 Godot consumer/data/scene/test route와 platform constraints를 별도로 확인한다.
3. product rule, visual asset, or significant UX change는 별도 Decision과 user approval boundary를 따른다.
4. Human/player, accessibility, Android device, release performance는 아직 증거가 없으므로 `NOT_RUN`이다.

## Sources and evidence limits

- [Steamworks User Reviews documentation](https://partner.steamgames.com/doc/store/reviews), accessed 2026-08-30 — aggregate review와 개별 review를 원인 증명이 아닌 feedback channel로 다루는 한계.
- [Steam Playtest documentation](https://partner.steamgames.com/doc/features/playtest?language=english), accessed 2026-08-30 — 이후 외부 playtest가 필요해질 때의 공식 선택지일 뿐, 이 report는 Playtest 실행 증거가 아니다.
- 위 12개 entry의 공식 product links, accessed 2026-08-30 — 제품 사실의 1차 source. 각 게임의 현행 build, 가격, review score는 계속 변할 수 있다.
