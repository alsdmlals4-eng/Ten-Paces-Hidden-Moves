# Martial Manual Text-First Presentation Decision · 2026-08-30

> **Historical/superseded for current card-art direction:** `TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01` replaces this decision's no-illustration policy. The pre-existing no-runtime-illustration implementation remains in force only until the new candidate receives an explicit final lock and passes its own implementation and runtime gates.

> Decision ID: `TEN-DEC-20260830-MARTIAL-MANUAL-TEXT-FIRST-PRESENTATION-01`
> Status: `SUPERSEDED_HISTORICAL_EVIDENCE`
> Work mode: `BUILD`
> Product/runtime mutation authority: `true — existing presentation contract and regression coverage only`
> Scope: `MartialActionPanel`의 보유 무공서와 선택 무공 기술 목록

## 사용자 결정

`USER_EXPLICIT_20260830`: **무공 기술서에 삽화는 넣지 않는다.**

이 결정은 수묵 전투의 시각 질량을 전장과 대치 인물에 남기고, 무공서는 수를 고르는 전술 정보면으로 유지한다. 따라서 무공서의 기술 선택 줄은 삽화 카드가 아니라 읽기 쉬운 텍스트·태그·수치 UI다.

## 채택한 계약

```yaml
policy: TEXT_TAG_NUMERIC_ONLY_NO_ILLUSTRATION
applies_to:
  - scenes/ui/action_selection/martial_action_panel.tscn
  - src/ui/action_selection/martial_action_panel.gd
  - source: martial_manual
    source_kind: martial
    surface: MartialActionPanel
always_visible:
  - 무공서명과 성수
  - 기술명
  - 행동_수
  - 기력_내력_비용
  - 잠금_해금_성수
  - 행동_종류와_효과_태그
conditionally_visible:
  - 공격_행동의_사거리
  - 실제_조건과_상세_효과
forbidden:
  - 무공_기술_행의_중앙_삽화
  - 무공_데이터의_illustration_필드_의존
  - 무공_목록_안의_TextureRect_삽화_노드
asset_generation: NOT_NEEDED_BY_USER_DECISION_NO_GENERATION
```

선택, hover, keyboard focus와 잠금은 종이 면·테두리·아이콘 없는 텍스트 및 접근성 이름으로 구분한다. 색만으로 상태를 전달하지 않는다.

## 범위 밖 — 유지

- 기초 행동 `CardView.illustration`과 `data/cards/basic_cards.json`의 승인 atlas 소비는 유지한다.
- 전장 배경, 대각 대치 Battler/Portrait, 거리·3/3/4 계획 UI는 유지한다.
- `UltimateActionPanel`, 무공 유래 절초, 필살기 연출과 전투 중 `VS` 공개 overlay는 이 결정을 이유로 변경하지 않는다.
- 전투 규칙, AI 정보 경계, 저장 schema, 무공 수치와 해금 규칙은 변경하지 않는다.

## 기존 정본과의 관계

`TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01`의 **actual-game-consumer-first** 원칙은 유지한다. 다만 그 문서의 미래 무공 카드 삽화 후보는 이 결정의 범위에서 더 이상 유효하지 않다. `CardView.illustration`은 기초 카드의 실제 소비 계약이지, 무공 기술서에 삽화를 의무화하는 계약이 아니다.

## 실행 가능성과 증거 경계

Fresh read 결과 `MartialActionPanel`은 이미 `Button`과 `Label`만으로 무공서/기술을 재구성하며, `data/cards/martial_manuals/*.json`의 기술에는 `illustration` 필드가 없다. 따라서 새 이미지 생성이나 product-path 코드 변환 없이 문서 충돌을 해소하고 Godot 회귀로 고정할 수 있다: `FEASIBLE`.

이번 사용성 방향은 외부 기술·법규·시장 사실로 결정되지 않는 명시적 사용자 제품 선택이므로 `CURRENT_SOURCE_RELEVANCE_CHECK: NOT_APPLICABLE_USER_PRODUCT_PRESENTATION_DECISION`이다. 자동 Godot 검증은 구현 계약만 검증하며, 실제 사용자 가독성·Android·접근성 사용자·release evidence는 별도 `NOT_RUN`이다.
