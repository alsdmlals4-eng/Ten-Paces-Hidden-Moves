# STEP 0 — 카드 UI 컴포넌트 구현·검증 Plan

## 목적

승인된 카드 템플릿을 통이미지가 아니라 데이터와 자산을 교체할 수 있는 재사용 Godot UI 컴포넌트로 구현하고, 로컬 Windows Godot 검증을 안전하게 자동화한다.

## 승인된 카드 계약

- 좌측 상단: 소속 배지.
- 중앙 상단: 사거리.
- 우측 상단: 이동·공격·대응·회복·강화 기능 배지.
- 기초 행동 7종의 소속은 `기초`.
- 하단 비용은 `행동 슬롯 / 기력 / 내력`만 사용한다.
- 행동력과 공통 `막기 경감` 필드는 사용하지 않는다.
- 카드 클릭 시 동일 데이터가 상세 패널에 표시된다.
- 카드별 소속·사거리·기능·원화·수치·효과는 데이터에서 교체할 수 있다.
- 사용자 편집기는 이후 별도 단계에서 구현한다.

## 구현 파일

- `project.godot`
- `data/cards/basic_cards.json`
- `assets/ui/cards/card_asset_manifest.json`
- `assets/ui/cards/card_badge_atlas.svg`
- `assets/ui/cards/cost_icon_atlas.svg`
- `assets/ui/cards/basic_illustrations_atlas.svg`
- `scenes/ui/card_view.tscn`
- `scenes/ui/card_detail_panel.tscn`
- `scenes/ui/card_component_preview.tscn`
- `src/ui/card_catalog.gd`
- `src/ui/card_view.gd`
- `src/ui/card_detail_panel.gd`
- `src/ui/card_component_preview.gd`

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

## 로컬 자동 검증

### 실행 파일

- 원클릭 실행: `tools/verify_and_commit_step0.cmd`
- PowerShell 본체: `tools/verify_and_commit_step0.ps1`
- Godot headless 검사: `tests/verify_step0.gd`
- 정적 계약 검사: `tests/check_card_component_contract.py`

### 자동 실행 순서

1. Git 저장소 루트와 현재 브랜치를 확인한다.
2. 브랜치가 `agent/t0-combat-poc-board`가 아니면 중단한다.
3. 실행 전 작업 폴더가 clean이 아니면 중단한다.
4. 원격을 fetch하고 `--ff-only`로만 pull한다.
5. Godot 실행 파일과 Python 3을 탐색한다.
6. 카드 정적 계약 검사를 실행한다.
7. Godot headless editor로 프로젝트 import·GDScript 파싱을 확인한다.
8. 카드 7종, 필수·금지 필드, Atlas 경로와 미리보기 씬을 검사한다.
9. 성공 보고서를 `artifacts/verification/step0-godot-verification.md`에 생성한다.
10. 보고서 외 다른 파일이 바뀌면 중단한다.
11. 보고서만 stage하고 `test: verify STEP 0 card components in Godot`으로 커밋한다.
12. 기본값으로 현재 브랜치를 origin에 push한다.

### 안전 조건

- 하나라도 실패하면 검증 커밋과 push를 수행하지 않는다.
- 기존 사용자 변경을 자동 stage하지 않는다.
- 병합·rebase·강제 push를 수행하지 않는다.
- `-NoPush` 옵션을 주면 검증·커밋 후 push만 건너뛴다.
- 자동화는 headless 구조 검증이며 실제 마우스 클릭·스크롤·최소 해상도·시각 품질을 대신하지 않는다.

## 실행 방법

GitHub Desktop에서 현재 브랜치를 pull한 뒤 다음 파일을 더블클릭한다.

```text
tools\verify_and_commit_step0.cmd
```

Godot 자동 탐색에 실패하면 PowerShell에서 다음처럼 실행한다.

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\verify_and_commit_step0.ps1 `
  -GodotPath "C:\Godot\Godot_v4.7.1-stable_win64_console.exe"
```

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
- [x] Python 정적 계약 검사 연결.
- [x] Godot headless 씬 검사 연결.
- [x] 실패 시 commit·push 금지.
- [x] clean worktree와 지정 브랜치 강제.
- [x] fast-forward pull만 허용.
- [x] 보고서 외 변경 파일 자동 stage 금지.
- [x] PowerShell 구문 CI 검사 연결.
- [ ] 사용자 Windows에서 실제 자동화 실행.
- [ ] 생성된 검증 보고서와 push 결과 확인.
- [ ] 실제 화면 클릭·스크롤·최소 해상도 수동 검수.

## 검증 상태

GitHub Actions는 정적 계약과 PowerShell 구문을 검사한다. 실제 Godot 실행과 보고서 커밋·push는 사용자의 Windows 작업본에서 원클릭 자동화가 실행된 뒤 증거로 확정한다.
