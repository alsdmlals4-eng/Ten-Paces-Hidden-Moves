# 무공서 → 해금 기술 → 수 자동 배치 UX 결정

- Decision ID: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`
- 승인일: `2026-08-01`
- 상태: `IMPLEMENTED_AUTOMATED_VALIDATION_PASS_HUMAN_PENDING`
- 런타임 권한: `IMPLEMENTED_IN_PR65`
- 작업 모드: `REVIEW`
- 설계: `docs/superpowers/specs/2026-08-01-action-selection-dock-design.md`
- 구현 종료: `docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md`
- 구조화 계약: `docs/planning-data/approved_20260801_martial_technique_timeline_ux_contract.json`

## 1. 제품 UX 정본

```text
행동 출처 선택
├─ 기초 행동
├─ 무공서
│  └─ 해당 무공서에서 현재 해금된 기술
└─ 절초
   ├─ 기본 절초
   └─ 10성 해금 절초

기술 선택
→ 현재 행동묶음에서 가장 앞의 유효 연속 빈 수에 자동 배치
→ 필요한 경우 이동 목적지 또는 공격 방향 지정
→ 진행 전까지 연결 블록 단위로 이동·제거
→ 진행 뒤 잠금·해결
```

## 2. 전투 타임라인

- 한 라운드는 총 10수다.
- 묶음은 `1~3 / 4~6 / 7~10`이다.
- 전체 10수와 현재 편집 묶음을 동시에 표시한다.
- 현재 행동묶음만 편집한다.
- `[진행]` 후 현재 묶음을 잠그고 해결한다.

## 3. 무공서와 기술

- 무공서는 성장·계보·기술 분류 단위다.
- 무공서를 직접 수 슬롯에 배치하지 않는다.
- 실제 배치 대상은 현재 해금된 기술이다.
- 덱·손패·드로우·장착 기술 제한을 사용하지 않는다.
- 시작 후보 무공서 6권 중 4권을 선택하고 3성으로 시작한다.
- 1/3/5/7/9/10성 해금 구조를 유지한다.

## 4. 기초 행동

기초 행동은 무공서와 독립된 공용 행동군이다.

- 이동
- 보법
- 막기
- 회피
- 속공
- 강공
- 명상
- 준비

기초 행동과 무공 기술을 하나의 평면 손패처럼 섞지 않는다.

## 5. 다중 수 기술

- 1수 기술: 해당 수에 실행.
- 2수 기술: 첫 수 `[전조]`, 둘째 수 `[실행]`.
- 3수 기술: 앞 2수 `[전조]`, 마지막 수 `[실행]`.
- 하나의 연결 프레임으로 표시한다.
- 묶음 경계를 넘지 않는다.
- 비용은 첫 전조에서 전액 선지불한다.
- 중단돼도 비용과 점유 수를 환불하지 않는다.

## 6. 자동 배치·재배치

- 기술 선택 시 현재 묶음의 가장 앞 유효 연속 빈 수를 찾는다.
- 공간이 있으면 즉시 배치한다.
- 공간이 없으면 실패 이유를 표시하고 계획·자원을 변경하지 않는다.
- 진행 전 연결 블록 전체를 이동·제거할 수 있다.
- 마우스 Drag와 키보드·게임패드 좌우 이동·제거를 모두 제공한다.
- 무효 Drop·중첩·묶음 경계 통과는 원래 배치를 보존한다.

## 7. 절초와 절초기세

- 절초는 별도 진입점이다.
- 공유 절초기세는 `0/5`로 기력·내력과 분리한다.
- 배치 성공 시 기세 5를 예약한다.
- 진행 전 제거 시 예약 기세를 복원한다.
- 진행 전 이동 시 기존 예약을 환불하고 새 수에 재예약한다.
- 묶음 확정 뒤에는 환불하지 않는다.
- 기본 절초와 10성 절초는 동일 자원을 사용한다.

## 8. 금지

- 무공서를 직접 수 슬롯에 놓는 표현
- 무공 기술을 무작위 손패처럼 표현
- 다중 수 기술을 독립 카드 여러 장처럼 표현
- 전체 10수 없이 현재 묶음만 보여 주는 화면
- 절초기세를 기력·내력과 합치는 표현
- 상대 실제 계획이나 정답 기술 추천
- 제품 P0의 가상 `준비+막기/회피` 카드

## 9. 구현·검증 증거

- PR #66을 PR #65 통합 브랜치에 병합했다.
- 실제 제품 입력 경로는 `ActionSelectionDock → ActionPlacementController → ActionTimingPanelAuto → CombatResolutionEngine`이다.
- 연결 블록 포인터 Drop 누락을 RED 회귀로 재현하고 수정했다.
- 검증 HEAD: `673c209017ffe3e1c7ef2a89849ca4ea0846d1c5`.
- PR Validation #993: `PASS`.
- Validate Base v9 adoption #106: `PASS`.
- Full Validation #73: `PASS`.
- Ubuntu/Windows Python 3.11·3.12: `PASS`.
- Ubuntu Godot headless·Action-selection smoke: `PASS`.

## 10. 남은 검증·후속

- Windows 실제 Godot 실행
- 실제 마우스 Drag·게임패드 체감
- 최소 해상도 실제 렌더
- 화면 읽기 도구
- 신규 플레이어의 무공서→기술 이해도
- 절초기세 예약·환불 이해도
- P1 빠른 무공·검색·정렬·필터
- 패시브·진의 상시 표시 범위

```yaml
planning_complete: true
review_complete: true
runtime_changes_implemented: true
automated_validation: PASS
human_validation: NOT_RUN
integration_pr: 65
main_merge: PENDING
```
