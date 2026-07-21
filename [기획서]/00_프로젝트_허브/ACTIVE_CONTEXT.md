# 십보강호 활성 컨텍스트

> 현재 상태·다음 작업·위험을 압축해 연결한다. 제품 본책의 전문을 복제하지 않는다.

## 현재 단계

- 운영: Base schema v3 Governance foundation 설치·정적 검증 완료, Draft PR #5 검토 중.
- 제품: 전투 POC 제작 순서 STEP 0~14 승인.
- 구현 브랜치: `agent/t0-combat-poc-board`, 스택형 Draft PR #7.
- STEP 0: 카드 템플릿을 Godot UI 컴포넌트·JSON·분리 SVG 자산으로 구현.
- STEP 1: 실제 Godot 10칸 전투판 씬 구현.
- STEP 2: 플레이어 3번 / 상대 8번 / 동일 스케일 / 높이 1.5칸 폭 / 발 앵커 일치 구현.
- 자동화: 로컬 Python 없이 Godot headless 검사 → 성공 보고서 commit → push까지 수행.
- 다음 구현: 로컬 통합 검증 PASS 후 STEP 3 전투 배경.
- 강제 상태: Branch protection Required Check는 변경·확인하지 않음.

## 제품 고정 방향

- 전장은 10칸이다.
- 라운드는 `3수 → 3수 → 4수`, 총 10타이밍이다.
- 동타이밍 기본 해상은 `대응 → 속공 → 이동 → 일반 공격`이다.
- 피격 시 아직 실행되지 않은 이동·공격 등 후속 행동이 중단된다.
- `[집중]`과 `[강건]`은 중단 방지 계약이다.
- 기초 행동은 이동·막기·회피·속공·강공·명상·태세 7종이다.
- 카드 상단은 `소속 배지 / 사거리 / 기능 배지`다.
- 기능 배지는 이동·공격·대응·회복·강화 5종이다.
- 기초 행동의 소속은 `[기초]`다.
- 카드 하단은 행동 슬롯·기력·내력만 사용한다.
- 덱·손패·남은 카드·행동력·공통 `막기 경감`은 사용하지 않는다.
- UI·VFX·오디오는 전투 결과를 표현하며 직접 계산하지 않는다.

## STEP 0 구현 결과

- `project.godot`과 카드 컴포넌트 미리보기 씬 추가.
- 카드 삽화·기초 배지·기능 배지·비용 아이콘을 독립 SVG Atlas로 분리.
- `CardView`, `CardDetailPanel`, `CardCatalog` 책임 분리.
- 카드 7종을 `data/cards/basic_cards.json`으로 주입.
- 행동력과 `막기 경감` 필드를 금지하는 정적 검사 추가.
- 사용자 편집 도구는 향후 별도 단계이며 현재 범위에 포함하지 않음.

## STEP 1·2 구현 결과

- 책임 데이터: `data/combat/combat_board_poc.json`.
- 실제 씬: `scenes/combat/combat_board_preview.tscn`.
- `CombatBoardTile` 10개를 `Tile01..Tile10`으로 생성.
- 플레이어를 3번 칸, 상대를 8번 칸에 배치.
- 캐릭터 높이를 타일 폭의 `1.5배`로 계산.
- 양측 캐릭터의 크기·비율을 동일하게 유지.
- 발 중심을 타일의 공통 앵커에 계산 배치.
- 타일·캐릭터를 독립 재사용 컴포넌트로 분리.
- 색 외에도 테두리·P/E 기호·실루엣으로 점유를 구분.
- `tests/verify_combat_board.gd`가 10칸·3번/8번·동일 스케일·발 앵커를 headless 검증.
- `assets/reference/step_02_character_scale_and_tile_placement.svg`를 승인 기준으로 사용.

## 자동 검증

- 실행 파일: `tools/verify_and_commit_step0.cmd`.
- 실제 본체: `tools/verify_and_commit_combat_foundation.ps1`.
- 로컬 Python을 요구하지 않는다.
- 프로젝트 import·GDScript 파싱, STEP 0, STEP 1·2를 순서대로 검사한다.
- 하나라도 실패하면 commit·push하지 않는다.
- 모두 성공하면 `artifacts/verification/combat-ui-foundation-godot-verification.md`만 커밋하고 현재 브랜치에 push한다.

## 즉시 다음 작업

1. 사용자 Windows에서 최신 브랜치를 pull한다.
2. `tools/verify_and_commit_step0.cmd`를 다시 실행한다.
3. 생성된 PASS 보고서와 PR Actions를 확인한다.
4. STEP 3: 전투판·캐릭터보다 낮은 대비의 전투 배경을 제작한다.
5. 이후 승인된 순서대로 상단 HUD와 행동 슬롯을 진행한다.

## 보호 범위

- 승인 카드 템플릿과 원화 방향.
- 10칸 전장과 3수·3수·4수 구조.
- 기초 카드 7종과 기능 배지 5종.
- 행동 슬롯·기력·내력 비용 체계.
- `docs/[백업]/`, `docs/[보류]/`, 기존 Plan·PR 이력.
- 실행되지 않은 검증의 미검증 상태.

## 주요 위험

- Windows 작업본에 원격보다 최신 파일 또는 미커밋 변경이 있을 수 있다.
- 현재 ChatGPT 실행 환경에는 Godot 4.7.1이 없어 로컬 렌더를 직접 확인할 수 없다.
- Actions 성공은 Godot·Windows 시각 품질 또는 Required Check 강제를 의미하지 않는다.
- 캐릭터 실루엣은 STEP 2 배치 검증용이며 최종 캐릭터 원화가 아니다.

## 완료 판정

STEP 0과 STEP 1·2의 저장소 구현·정적 계약·headless 검증 코드는 완료했다. 사용자 Windows의 Godot 4.7에서 통합 자동 검증을 통과해 PASS 보고서가 push되면 런타임 구조 검증을 완료로 전환한다.
