# Vertical Slice 기획 완료 승인 결정

- Decision ID: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`
- 승인일: 2026-08-20
- 승인 근거: 사용자 명시 `기획완료`
- 상태: `APPROVED_PLANNING_COMPLETE`
- 선행 Decision: `TEN-DEC-20260820-VERTICAL-SLICE-REVIEW-READY-01`
- 제품 구현 권한: `false`

## 결정

사용자는 첫 5전 Vertical Slice의 현재 기획 패키지를 명시적으로 `기획완료` 승인했다.

따라서 다음 기획 계보를 하나의 완료된 첫 Vertical Slice 기획 기준선으로 묶는다.

1. `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01`
2. `TEN-DEC-20260820-VERTICAL-SLICE-CONTENT-DETAIL-01`
3. `TEN-DEC-20260820-VERTICAL-SLICE-LOADOUT-ROUTE-WIRE-01`
4. `TEN-DEC-20260820-VERTICAL-SLICE-REVIEW-READY-01`
5. 이번 `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`

## 완료 범위

- 강호 비무행의 플레이어 역할과 첫 5전 감정·학습곡선.
- 5개 슬롯 × 후보 3명 = 상대 후보 15명의 최소 차별화 구조.
- 기존 10권 무공 재사용 기반 상대 loadout 방향.
- 주요 비무 사이 정확히 2개, 총 8개 Route 노드.
- 다음 상대 선확정 → 성장/회복 → 정보/대비 → Briefing 흐름.
- Main → Setup → Briefing → Combat → Review → Result/Reward → Route → 다음 Duel → 5전 완주 App Flow.
- Combat Review Overlay와 Duel Result 별도 Scene 경계.
- AI 공개정보/금지정보와 플레이어 비공개 계획 보호.
- 난이도 Seed `20/22/24/26/28`, 무공 성급 Seed `3/7/7/7/9` 및 비연 관찰 안전 예외.
- Route 성장 경로 `집중 +6`, `자유 +14`, 회복 Seed `최대 체력 25% + 기력1 + 내력1`.
- 첫 회차 aggregate 비전투 시간 예산과 `8분30초` 재검토 트리거.
- 정적/시뮬레이션/Human 검증의 증거 경계.

## 완료가 뜻하지 않는 것

`기획완료`는 다음을 자동 승인하거나 PASS로 만들지 않는다.

- Godot 제품 코드·Scene·runtime data 구현.
- 이미지·최종 아트·VFX·오디오 생성/채택.
- 대량 밸런스 시뮬레이션 PASS.
- Windows visible local render·실물 입력 PASS.
- Android 실기기 PASS.
- Human 재미·가독성·몰입 PASS.
- Route 회복 Seed 또는 난이도 Seed의 최종 밸런스 확정.

## 다음 Gate

다음 단계는 `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`의 구현 인수인계 계약이다.

제품 변경은 별도의 명시적 구현 요청이 들어온 뒤에만 시작한다. 구현 시작 시에는 과거 SHA/상태를 재사용하지 않고 다음을 다시 확인한다.

1. Project `main`과 열린 PR.
2. exact Project Notion.
3. `ACTIVE_CONTEXT.md`와 current entry/operating gate.
4. 현재 Godot 코드·Scene·data·tests.
5. 구현 시점 Base/project 규칙.

## 롤백/재개

사용자가 기획을 다시 열면 이 Decision 자체를 삭제하지 않는다. 후속 Decision으로 변경된 범위만 명시하고, 이미 완료된 기획 계보 중 무엇이 superseded 되었는지 기록한다.
