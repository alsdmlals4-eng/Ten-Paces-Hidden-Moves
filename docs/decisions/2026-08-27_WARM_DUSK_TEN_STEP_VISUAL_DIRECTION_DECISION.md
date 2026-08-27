# TEN-DEC-20260827-WARM-DUSK-TEN-STEP-VISUAL-DIRECTION-01

## 결정

사용자가 2026-08-27에 제공한 세 개의 전투 화면 reference를 다음 프로젝트 시각 방향으로 선택했다.

- 석양의 온기와 짙은 흑갈색 기반의 무협 전장
- 종이 질감 위의 선명한 먹선과 절제된 붓 터치
- 거리·전장·인물 실루엣을 먼저 읽히는 가로형 결투 구도; 논리 10칸은 바닥선 없이 UI/data가 표현
- 검정 전술 UI와 오래된 금색의 선택/거리 강조

## 실제 소비처와 경계

- 관련 실제 surface: `src/combat/combat_board_preview.gd`의 전투판과 `scenes/combat/battle_background.tscn`의 배경 표현.
- 기존 runtime background `res://assets/backgrounds/twilight_ink_duel_v1.png`와 모든 초상/Battler route는 이 결정만으로 교체하지 않는다.
- v1은 바닥의 금색 칸 표시에 대해 `REVISION_REQUIRED`가 됐다. 사용자가 명시적으로 요청한 단일 교정 결과 `WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID`는 현재 `GENERATED_EXPLORATION · IN_REVIEW`다. 어느 결과도 `PROJECT_ASSET_APPROVED`, Notion attachment, runtime route, Windows/Android/human verification이 아니다.

## Keep / Avoid / Do Not Drift

### Keep

- 1대1 가로 거리 전장과 전장이 가장 큰 시각 질량이라는 게임 의미; 논리 10칸은 바닥 격자·번호 없이 유지
- 두 인물의 명확한 대치 실루엣, 비어 있는 UI overlay 안전영역, 낮은 시점의 stone-court 원근
- 먹선, 종이·마모 재질, 어두운 charcoal, 흙빛 amber, 제한된 gold 강조

### Avoid

- 옅은 회백 단색 수묵으로만 처리되어 선택/거리 가독성을 잃는 결과
- 노출 과다한 주황, 과도한 금색, 광택 3D, 현대 물체, 마법 효과
- 바닥에 표시되는 칸선·번호·gold lane grid
- 이미지에 굽힌 텍스트·수치·버튼·체력바·아이콘

### Do Not Drift

- `거리 N`, 10칸, 3/3/4 계획의 게임 의미는 이미지가 아닌 Godot UI/data가 소유한다.
- 새 캐릭터 정체성, 숨은 상대 계획, 새 combat rule 또는 UI 동작을 이미지가 발명하지 않는다.
- 기존 승인 자산을 새 direction이 선택됐다는 이유만으로 retroactive approval 취소·runtime 교체하지 않는다.

## Reference receipt

| ID | 역할 | 상태 |
| --- | --- | --- |
| user-image-20260827-01 | 가로 결투의 석양·lane·거리 가독성 | 사용자 제공 direction reference |
| user-image-20260827-02 | 짙은 ink/paper 인물·검정/금색 UI 재질 | 사용자 제공 direction reference |
| user-image-20260827-03 | 흑갈색 palette와 인물의 표정/실루엣 밀도 | 사용자 제공 direction reference |
| `twilight_ink_duel_v1.png` | 현재 game battlefield backdrop의 연속성 | repository runtime reference |

## 검증·후속

- `WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID`을 위 네 reference와 비교한다.
- 다음 asset 생성, Notion attachment, runtime replacement는 이 후보 검토와 별도 consumer/implementation task가 필요하다.
- 신규 visual family를 project-wide runtime style PASS로 주장하지 않는다.
