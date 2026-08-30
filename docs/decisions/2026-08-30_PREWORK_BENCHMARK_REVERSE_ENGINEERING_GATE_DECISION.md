# TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01

```yaml
decision_id: TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01
status: CURRENT_APPROVED_PROJECT_OPERATING_POLICY
effective_date: 2026-08-30
approval_source: "user explicit: 비슷한 장르,류의 게임 10개 이상 벤치마킹해서 역공학 먼저 진행"
scope: PREWORK_RESEARCH_GATE_FOR_NEW_L1_PLUS_PACKAGES
initial_packet: docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md
runtime_rule_asset_change: NONE
evidence_ceiling: DESK_RESEARCH_ONLY
```

## 결정

새 L1+ 기획·시스템·UX·콘텐츠·구현 패키지는 계획이나 mutation 전에 유사·인접 장르 게임 **10개 이상**을 벤치마킹하고 역공학한다. 이는 “유명 게임을 복제”하는 규칙이 아니라, 십보강호의 수읽기·거리·숨은 계획·순차 해결을 더 명확히 보호하거나 반례를 찾기 위한 사전 게이트다.

초기 packet은 12개 게임으로 이 기준을 충족한다. 다음 package는 그 packet을 무조건 재사용하지 않는다. decision dimension, 현재 프로젝트 상태, 외부 source freshness가 모두 같은 bounded continuation일 때만 재사용할 수 있으며, 그렇지 않으면 관련 10개 이상을 새로 또는 보강해 분석한다. `no silent bypass`.

## 필수 packet

| 항목 | 최소 기준 |
| --- | --- |
| unique game comparable | 10개 이상 |
| 직접 비교 | 3개 이상 — 동시/순차 예측, 턴 기반 대결, 읽기 기반 대전 등 |
| 인접 시스템 | 3개 이상 — 전술 공간, 공개 정보, 행동 타이밍, 거리/가드/판정 등 |
| 부정 또는 혼합 사례 | 1개 이상 — 실패/과도한 비용/기대 불일치의 반례 |
| 각 사례 | 공식 제품 사실, 플레이어 반응 신호 또는 명시된 공백, mechanism, transfer principle, `DO_NOT_COPY`, `ADOPT/ADAPT/AVOID/TEST` |
| 결론 | 현재 정본과의 충돌, 구현 가능성, 필요한 user Decision과 evidence ceiling |

Steam 등의 aggregate review는 플레이어 반응의 제한된 신호일 뿐 원인 증명, 시장 성공 판정, 십보강호의 재미 검증이 아니다. 플랫폼의 공식 문서도 review score를 고객 경험의 한 channel로 설명할 뿐, 개별 게임의 인과관계를 보장하지 않는다. 따라서 수치 또는 평가를 사용하면 관찰일·표본/플랫폼 한계·추론 금지를 함께 남긴다.

## 보호 경계

- 이 gate는 현재 project core를 바꾸지 않는다. 10칸 논리 전장, 공개 거리 2, `3 → 해결 → 3 → 해결 → 4 → 해결`, 공개 상태/해결 이력 기반 추론은 계속 분야 정본이 소유한다.
- 외부 사례가 card/deck/hand/draw, 장착 기술 제한, 실시간 반응 조작, 완전한 상대 계획 노출을 쓴다고 해도 그 기능을 채택하지 않는다. 현재의 `deck/hand/draw` 금지와 AI의 미확정 플레이어 계획·숨은 배치·UI 의도 열람 금지는 우선한다.
- 각 사례의 `DO_NOT_COPY`에는 타사 UI, 아트, 캐릭터, 고유 이름, 상표, 수치 및 lore를 포함한다. 옮길 수 있는 것은 추상적 설계 원칙뿐이다.
- L0 오탈자·순수 형식·이미 검증된 exact rerun은 10개 packet 대상이 아니지만 `CURRENT_SOURCE_RELEVANCE_CHECK`와 기존 적대 검토 원칙은 계속 적용한다.
- 이 gate는 user approval, Human/player test, Windows visible, Android device, accessibility-user, release evidence를 대체하지 않는다.

## 현재 적용

`docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md`는 아래 시점의 공식 제품 자료와 제한된 platform response signal을 분리해 기록한 초기 12개 packet이다. 이번 결정은 workflow governance만 갱신하며 code/data/scene/resource/asset/project setting을 변경하지 않는다. 현재 다음 제품 surface인 balance instrumentation 결과 검토도, 수치 변경 Decision을 새로 열기 전에 이 gate의 적용 대상이다.

## 상태

`CONFIRMED_BY_USER_EXPLICIT_DIRECTION`. 이 Decision은 사전 조사 품질을 강제하지만, 어떤 외부 게임의 기능 채택, 런타임 변경, 플레이어 재미, 시장성, 사람 검증, device/release PASS를 주장하지 않는다.
