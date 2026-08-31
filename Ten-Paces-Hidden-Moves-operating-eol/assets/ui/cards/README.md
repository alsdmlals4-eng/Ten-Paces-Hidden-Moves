# 카드 UI 자산

승인 카드 시안을 런타임에서 수정 가능한 요소로 분리한 파생 자산이다.

- `basic_illustrations_atlas.svg`: 기초 카드 7종 중앙 원화
- `card_badge_atlas.svg`: `[기초]` 소속 배지와 기능 배지 5종
- `cost_icon_atlas.svg`: 행동 슬롯·기력·내력 아이콘
- `card_asset_manifest.json`: Atlas 좌표·승인 상태·경로 계약

카드명·사거리·비용·효과 문구는 이미지에 굽지 않는다. JSON과 Godot UI가 표시하며, 실제 전투 결과는 전투 도메인이 계산한다.
