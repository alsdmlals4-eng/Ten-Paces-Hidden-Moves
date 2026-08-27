# TEN-DEC-20260828-WARM-DUSK-V2-PLANNING-ANCHOR-01

- Status: `USER_APPROVED_PLANNING_ANCHOR_ONLY`
- Issue: `#249`
- Parent direction: `TEN-DEC-20260827-WARM-DUSK-TEN-STEP-VISUAL-DIRECTION-01`
- Selected source: `docs/visual-assets/candidates/WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID.png`
- Source SHA-256: `11281c8f6eb874b3ddd516b38c11cbba269eb6a2d547ce8c36f701c65fd84802`

## 결정

사용자는 v2 no-floor-grid 후보를 **`PROJECT_CORE_SCENE_VISUAL_BOARD`의 planning visual anchor**로 승인했다. 이 선택은 시각 방향·기획 검토용 anchor를 고정하지만, **not a runtime asset**, `PROJECT_ASSET_APPROVED`, Godot scene/resource integration, Windows/Android/Human visual PASS는 아니다.

## Adopted

- warm dusk의 amber·sepia 대기와 charcoal ink/paper 재질
- 양측 인물의 가로 대치와 전장이 가장 큰 시각 질량인 구도
- 논리 10칸을 바닥 격자·번호가 아닌 Godot UI/data가 소유하는 원칙
- 어두운 전술 UI, 밝은 종이 정보면, 제한된 antique gold의 역할 분리
- 편집 화면의 `행동계획 실행` 뒤 전투·해결 애니메이션으로 이어지는 Flow

## Rejected / Avoid

- gold floor grid, 바닥 번호, 이미지에 굽힌 규칙·버튼·수치·텍스트
- 과도한 주황·금색·광택 3D·현대 물체·마법식 glow
- 숨은 상대 계획·정답·확률을 포즈·색·연출로 누설하는 표현
- v2의 영화적 대칭과 작은 인물 크기를 실제 gameplay UI 가독성 PASS로 오인하는 일

## Visual Direction Lock Packet

| Layer | Locked anchor |
| --- | --- |
| Global | warm dusk, charcoal ink, paper wear, restrained antique gold |
| Character | 7\~7.5등신 반실사 무협, 명확한 무기·자세·의상 덩어리 silhouette |
| Environment | 낮은 시점의 비격자 stone court, 먼 배경은 전투원보다 저대비 |
| UI | dark ink tactical surface + paper reading plane; text/numbers remain Godot UI/data |
| VFX | 먹의 운동감과 짧은 금색 핵심선; gameplay 판독을 가리지 않음 |
| Camera / density | horizontal duel, 거리와 양측 silhouette 우선, UI overlay 안전 영역 보존 |

### Keep / Do Not Drift / Allowed variation

- **Keep:** 전장 우선, 공개 정보의 불확실성, 해결 뒤 인과 명확성, 좌우 대치 silhouette.
- **Do Not Drift:** 논리 격자 시각화, 카드 손패/드로우 문법, 다른 게임의 pixel/3D family, 새 규칙 발명.
- **Allowed variation:** 지역·시간대·진영·상태에 따라 palette 온도·원근·장식 밀도는 달라질 수 있으나, 공통 UI hierarchy와 카메라 의미를 바꾸지 않는다.

## Provenance, destination, and evidence boundary

- v1의 gold floor-grid 후보는 `REVISION_REQUIRED` historical reference다.
- 2026-08-25 reference set은 superseded되지 않으며, 이 선택은 그중 current warm-dusk direction을 구체화한다.
- rights/provenance는 source candidate 기록까지만 확인됐으며 release asset 권리는 `UNKNOWN / RELEASE_BLOCKED_UNVERIFIED`다.
- Repository destination: this Decision and `docs/planning-data/current_visual_production_handoff_20260826.json`.
- Notion destination: `02 · 비주얼 바이블`; planning-anchor source attachment and page readback are `PASS_20260828`.
- 다음 시각 결과는 `PROJECT_CORE_SCENE_VISUAL_BOARD` 1장뿐이며, text brief와 별도 명시 사용자 승인 전에는 생성하지 않는다.
