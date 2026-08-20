# 십보강호 · 첫 Vertical Slice 기획 완료 결정

- Decision ID: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`
- 승인일: 2026-08-20
- 승인 근거: 사용자 명시 `기획완료`
- 선행 Review Ready: `TEN-DEC-20260820-VERTICAL-SLICE-REVIEW-READY-01`
- 상태: `PLANNING_COMPLETE`

## 승인 범위

사용자는 첫 5전 Vertical Slice의 현행 텍스트 기획을 완료로 승인했다.

승인되는 기획 권위:

1. `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`
   - 강호 비무행, 플레이어 역할, 5전 감정·학습곡선, App Flow.
2. `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`
   - 5 슬롯 × 후보 3명, Route 8노드, Briefing/Review/Result 텍스트 UX.
3. `docs/14_VERTICAL_SLICE_LOADOUT_ROUTE_BUDGET_WIREFRAME.md`
   - 기존 10권 재사용, 후보 무공 배정, Route 성장·회복 Seed, 비전투 Wire.
4. `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`
   - 상대 난이도 Seed, AI 공정성, 정적/시뮬레이션 검증 계약, aggregate 시간 예산.

## 보호 범위

- 10칸 전장.
- `3수 → 3수 → 4수`.
- 플레이어/AI 현재 계획 비공개와 AI anti-cheat.
- 거리·합·대응·중단·복기.
- 시작 무공 6중4.
- 주요 비무 5 슬롯 × 후보 3명.
- 비무 사이 정확히 2 Route 노드.
- Combat Review Overlay와 Duel Result 별도 Scene 경계.
- 적 AI의 플레이어 전용 `[관찰]` 사용 금지.
- 정보 Route는 다음 상대가 먼저 확정된 뒤 작동.
- 첫 회차 aggregate 비전투 시간 예산이 개별 화면 최대값보다 우선.

## 완료의 의미

`PLANNING_COMPLETE`는 **첫 Vertical Slice의 현행 기획을 더 이상 미완성 P0/P1 때문에 막지 않는다**는 뜻이다.

다음을 뜻하지 않는다.

- 제품 코드/Scene/runtime data 구현 완료.
- 밸런스 시뮬레이션 PASS.
- 회복 Seed `최대 체력 25% + 기력1 + 내력1`의 최종 확정.
- 상대 스탯/성급 Seed의 Human 재미 검증.
- Windows visible/local usability PASS.
- Android 실제 기기 PASS.
- 접근성 사용자 PASS.
- Human 재미·몰입·가독성 PASS.
- 최종 아트/VFX/오디오 승인.

따라서 위 항목은 기존 evidence ceiling을 그대로 유지한다.

## 다음 단계

현행 작업 순서는 다음으로 전환한다.

```text
PLANNING_COMPLETE
→ VISUAL_UX_REQUIREMENT_AND_REFERENCE_REVIEW
→ 사용자 명시 이미지 생성 요청/시안 승인(필요한 경우)
→ 승인 Visual Reference를 사용한 Vertical Slice implementation contract
→ Build/Scene/runtime implementation
→ automated QA
→ release-near Human play validation
```

사용자가 이미지 생성을 명시적으로 요청하지 않은 상태에서는 새 이미지를 자동 생성하지 않는다.

## 구현 권한 경계

이번 `기획완료`는 기획 Gate를 닫지만 **제품 구현을 현재 채팅에서 자동 착수하라는 명령으로 해석하지 않는다**.

- `product_implementation_authorized`: 현재 Entry Gate와 후속 구현 계약이 별도로 허용할 때까지 `false`.
- 플랫폼 Adapter/Android Gate도 기존 검증 상태를 유지한다.
- 다음 구현 전 GitHub `main`, exact Project Notion, current entry/operating gate를 다시 읽는다.

## 재개 조건

다음 중 하나면 기획을 다시 열 수 있다.

- 사용자 명시 수정 지시.
- Visual/UX 검토에서 핵심 코어와 충돌 발견.
- 대량 시뮬레이션에서 지배 전략/막힌 빌드 발견.
- Human play에서 3/3/4 수읽기보다 UI/서사/노드가 더 강하게 기억됨.
- 첫 회차 비전투 시간이 8분30초를 반복 초과.
- 정보 Route가 정답 누출로 판명됨.

그 외에는 현재 기획을 구현 기준선으로 사용한다.
