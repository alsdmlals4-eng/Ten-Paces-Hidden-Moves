# T0 전투 POC — M1 카드 UI·10칸 전투판 마일스톤

## 목적

현재 승인된 전투 UX·규칙을 실제 Godot POC로 옮기기 전에, 모든 전투 표현의 기준이 되는 **카드 UI 컴포넌트·10칸 전투판·카메라·캐릭터 배치 규격**을 먼저 확정한다.

## 진행 상태

- STEP 0 카드 템플릿 실제 UI 컴포넌트 분리: **구현 완료 / 로컬 Godot 통합 검증 대기**
- STEP 1 10칸 전투판: **Godot 실제 씬 구현 완료 / 로컬 렌더 검증 대기**
- STEP 2 캐릭터 크기·칸 배치: **3번·8번 실제 배치 구현 완료 / 로컬 렌더 검증 대기**
- STEP 3 전투 배경: 대기

## 브랜치·PR 계약

- 작업 브랜치: `agent/t0-combat-poc-board`
- 기준 브랜치: `agent/base-full-11-migration` (Draft PR #5)
- 작업 수준: L3 — UI 자산 분리·Godot 컴포넌트·전투판 위치 표현
- 주 책임: 개발·엔지니어링
- 영향 분야: UX·UI·접근성, 아트, QA, 프로덕션·PM
- 보호: 기존 승인 원화·카드 규칙·10칸 구조·PR 이력

## 기존 PR 판정

- PR #5: Governance 성공. 본 PR의 기준 브랜치다.
- PR #6: PR #5와 Registry·Skill Map이 겹쳐 PR #5 이후 리베이스 검수가 필요하다.
- PR #3: 2수 묶음 가정이 현재 `3수 → 3수 → 4수`와 충돌해 현 상태로 병합하지 않는다.
- PR #2: Godot 설정·이벤트·테스트 골격만 참고하고 2수·행동력·구 카드 체계는 이식하지 않는다.

## STEP 0 승인 카드 UI 계약

- 좌측 상단: 소속 배지.
- 중앙 상단: 사거리.
- 우측 상단: `이동 / 공격 / 대응 / 회복 / 강화` 기능 배지.
- 기초 행동의 소속은 `[기초]`.
- 하단은 `행동 슬롯 / 기력 / 내력`만 표시.
- 행동력과 공통 `막기 경감` 항목 제거.
- 카드명·원화·배지·사거리·수치·효과는 데이터로 교체 가능.
- UI는 표현만 담당하고 전투 결과를 계산하지 않음.

세부 구현은 `plans/2026-07-21-card-ui-component-step0.md`가 책임진다.

## STEP 1·2 Godot 구현 계약

책임 데이터는 `data/combat/combat_board_poc.json`이다.

- 정확히 10개의 타일을 `Tile01`부터 `Tile10`까지 생성한다.
- 플레이어 시작 위치는 3번, 상대 시작 위치는 8번이다.
- 시작 거리 표현은 `8 - 3 = 5`다.
- 캐릭터 높이는 타일 폭의 `1.5배`다.
- 양측 캐릭터의 크기와 비율은 동일하다.
- 캐릭터 발 중심은 타일의 `foot_anchor_y_ratio` 위치와 일치한다.
- 전투 위치의 책임은 정수 `1..10`이며 화면 좌표는 UI가 계산한다.
- 플레이어·상대 구분은 색뿐 아니라 테두리 두께, `P/E` 기호, 캐릭터 실루엣으로 보조한다.
- 10칸 전체와 양측 전신을 동시에 표시하는 고정 와이드 구성을 사용한다.
- 승인 기준 자산은 `assets/reference/step_02_character_scale_and_tile_placement.svg`다.

### 구현 파일

- `data/combat/combat_board_poc.json`
- `src/combat/combat_board_tile.gd`
- `src/combat/combat_character_placeholder.gd`
- `src/combat/combat_board_preview.gd`
- `scenes/combat/combat_board_tile.tscn`
- `scenes/combat/combat_character_placeholder.tscn`
- `scenes/combat/combat_board_preview.tscn`
- `tests/check_combat_board_contract.py`
- `tests/verify_combat_board.gd`

초기 위치와 크기는 POC 판독 기준이며 밸런스 값이 아니다. 캐릭터는 최종 원화가 아니라 크기·발 앵커 검증용 실루엣이다.

## 제작 순서

0. 카드 템플릿 실제 UI 컴포넌트 분리
1. 10칸 전투판
2. 캐릭터 크기·칸 배치
3. 전투 배경
4. 상단 HUD
5. 3수·3수·4수 행동 슬롯
6. 기초 카드 7개 UI 삽입
7. 카드 상세·전투 로그
8. 진행 버튼
9. 행동 배치 상호작용
10. 판정 엔진
11. 피격 중단·집중·강건
12. 간단 AI
13. 전투 종료·재시작
14. POC 플레이테스트

## 자동 검증

`tools/verify_and_commit_step0.cmd`는 기존 파일명을 유지하지만 내부적으로 `tools/verify_and_commit_combat_foundation.ps1`을 실행한다.

실행 순서:

1. 브랜치·clean worktree 확인.
2. 원격 브랜치 fast-forward.
3. Godot 4.x 버전 확인.
4. 프로젝트 import·GDScript 파싱.
5. STEP 0 카드 7종·상세 패널 검증.
6. STEP 1·2 타일 10개·3번/8번·동일 스케일·발 앵커 검증.
7. 성공 보고서만 커밋하고 현재 브랜치에 push.

로컬 Python은 필요하지 않는다. 하나라도 실패하면 commit·push를 수행하지 않는다.

## PR 체크리스트

### STEP 0

- [x] 카드 원화와 UI 프레임이 분리됐다.
- [x] `[기초]`와 기능 배지 5종이 Atlas의 독립 영역이다.
- [x] 행동 슬롯·기력·내력 아이콘이 독립 영역이다.
- [x] 기초 카드 7종이 JSON 데이터로 정의됐다.
- [x] `CardView`와 `CardDetailPanel`이 분리됐다.
- [x] 행동력과 `막기 경감` 필드가 제거됐다.
- [x] 정적 계약 검사를 통과했다.
- [x] 로컬 Python 의존성이 제거됐다.
- [ ] Godot 실제 씬 로드·렌더를 로컬 자동화로 확인했다.

### STEP 1·2

- [x] 정확히 10칸과 번호 1~10을 실제 Godot 씬으로 구현했다.
- [x] 플레이어 3번·상대 8번 실제 배치를 구현했다.
- [x] 양측 동일 스케일과 `1.5배` 높이를 데이터로 고정했다.
- [x] 발 중심과 칸 앵커를 계산으로 일치시켰다.
- [x] 타일·캐릭터를 독립 재사용 컴포넌트로 분리했다.
- [x] 승인 기준 SVG 자산을 저장소에 반영했다.
- [x] 정적 STEP 1·2 계약 검사를 추가했다.
- [x] Godot headless STEP 1·2 검증 스크립트를 추가했다.
- [ ] 사용자 Windows의 Godot 4.7에서 통합 자동 검증을 통과했다.
- [ ] 16:9·최소 해상도·색각 폴백을 수동 검증했다.

현재 저장소 정적 구조와 자동 검증 코드는 완료했으며, 사용자 Windows에서 원클릭 통합 검증을 실행해 런타임 PASS 보고서를 생성해야 한다.
