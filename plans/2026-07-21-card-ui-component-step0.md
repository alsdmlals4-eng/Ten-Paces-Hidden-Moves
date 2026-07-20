# STEP 0 — 카드 템플릿 UI 컴포넌트 분리

## 승인 근거

사용자가 확정한 카드 템플릿을 실제 Godot UI 컴포넌트와 데이터로 분리한다. 고정되는 것은 레이아웃과 정보 책임이며, 카드마다 소속·사거리·기능·카드명·원화·비용·상세 효과가 바뀔 수 있다.

## 고정 계약

```text
좌측 상단: 소속 배지
중앙 상단: 사거리
우측 상단: 이동 / 공격 / 대응 / 회복 / 강화 배지
중앙: 카드명 + 원화
하단: 행동 슬롯 / 기력 / 내력
클릭 상세: 대상 / 사거리 / 피해 / 조건 / 효과 / 태그 / 세 비용 / 플레이버
```

- 기초 행동의 소속은 `[기초]`다.
- `[강호낭인]` 소속 배지는 사용하지 않는다.
- 행동력은 카드 데이터와 UI에서 제거한다.
- `막기 경감`은 공통 상세 항목과 데이터 필드에서 제거한다.
- UI는 데이터를 표시하며 전투 결과를 계산하지 않는다.
- 향후 사용자 편집 기능은 같은 데이터 필드를 수정하는 별도 단계다.

## 생성 파일

- `project.godot`
- `data/cards/basic_cards.json`
- `assets/ui/cards/card_asset_manifest.json`
- `assets/ui/cards/card_badge_atlas.svg`
- `assets/ui/cards/cost_icon_atlas.svg`
- `assets/ui/cards/basic_illustrations_atlas.svg`
- `src/ui/card_catalog.gd`
- `src/ui/card_view.gd`
- `src/ui/card_detail_panel.gd`
- `src/ui/card_component_preview.gd`
- `scenes/ui/card_view.tscn`
- `scenes/ui/card_detail_panel.tscn`
- `scenes/ui/card_component_preview.tscn`
- `tests/check_card_component_contract.py`

## 기초 카드 7종

| 카드 | 기능 | 사거리 | 슬롯 | 기력 | 내력 |
|---|---|---:|---:|---:|---:|
| 이동 | 이동 | `-` | 1 | 0 | 0 |
| 막기 | 대응 | `-` | 1 | 0 | 0 |
| 회피 | 대응 | `-` | 1 | 1 | 0 |
| 속공 | 공격 | `1` | 1 | 1 | 0 |
| 강공 | 공격 | `1` | 2 | 1 | 0 |
| 명상 | 회복 | `-` | 1 | 0 | 0 |
| 태세 | 강화 | `-` | 1 | 0 | 1 |

수치는 데이터 예시이며 전투 밸런스 책임 원본과 플레이테스트 결과에 따라 교체할 수 있다.

## PR 체크리스트

- [x] 카드 프레임과 데이터가 분리됐다.
- [x] 소속·사거리·기능 배지가 독립 필드다.
- [x] 승인된 기능 배지 5종만 사용한다.
- [x] 행동 슬롯·기력·내력만 하단에 표시한다.
- [x] 행동력 필드가 없다.
- [x] `막기 경감` 필드가 없다.
- [x] 기초 카드 7종이 동일 `CardView`를 사용한다.
- [x] 클릭 상세 패널이 같은 JSON 데이터를 사용한다.
- [x] 원화·배지·비용 아이콘이 독립 Atlas다.
- [x] Python 정적 계약 검사를 통과했다.
- [ ] Godot 4.7.1에서 실제 렌더를 확인했다.
- [ ] Windows에서 클릭·스크롤·최소 해상도를 수동 확인했다.

## 검증 상태

현재 실행 환경에는 Godot 4.7.1과 사용자 Windows 작업본이 연결되지 않았다. GDScript 파싱, 씬 로드, 실제 렌더와 Windows 입력 검증은 `NOT_RUN`이다.
