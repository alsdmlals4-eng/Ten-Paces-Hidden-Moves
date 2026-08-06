# 십보강호 운영 로드맵

> 상세 제품 로드맵: `../../../docs/04_ROADMAP.md`  
> 현재 상태: `ACTIVE_CONTEXT.md`  
> 과거 v6 결정 인덱스: `../../../docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
integration_pr: 65
active_planning_work_mode: PLAN
main_state_sync_commit: 6d8237e00168e45a7d3c001a0f6b3587b57147b7
last_planning_checkpoint_merge: d9f38e6f3cacaf170d4b290e95b3645114639aff
active_planning_pr: 82
active_planning_head: 289378c214702223dc0d1e149134438c3e761ba0
active_approval_count: 2/10
implemented_decision: TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
approved_planning_decision: TEN-DEC-20260801-SITUATION-SCREEN-01
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: INTERMEDIATE_NODE_PERMANENT_STAT_REWARDS
human_validation: NOT_RUN
base_release_pinned: 9.4.3
```

`work_mode: REVIEW`·`integration_pr: 65`는 런타임 기준선이며 PR #82는 별도의 활성 `PLAN` 승인 배치다.

## R0 — 구현·역사·Base 기준선

- [x] T0 구현 계보 PR #7·Issue #13 보존.
- [x] 기술 기준 SHA `659c57e7ffa588ad6a6471ed9b5394985b159eaf` 보존.
- [x] v6 원장을 역사 인덱스로 유지.
- [x] 최신 날짜별 Decision과 실제 구현을 현재 권한으로 사용.
- [x] Base v9.4.3 Adapter payload·evidence·finalization pin 확인.
- [x] main 체크포인트와 활성 Draft PR을 분리.

상태: `APPROVED`.

## R1 — 전투·회차·성장 기획

- [x] 1대1 10칸·3/3/4·거리·합·방어도·중단·복기.
- [x] 데모 5슬롯·후보 3명·중간 노드 8개.
- [x] 전체 10슬롯·중간 노드 18개.
- [x] 절차형 상대·경로와 슬롯 1~3 학습 역할.
- [x] 3수 계획 편집·해결·복기 UX.
- [x] PR #80 성장 기획 10/10 체크포인트 병합.
- [x] PR #82 10성 절초 주 능력치12·시작 무공 보조 능력치 매핑 승인 2/10.
- [ ] 중간 노드 영구 스테이터스 보상.
- [ ] 개별 기술 배수·5/9성 임계 효과.
- [ ] 전투 종료 등급 산식·파밍 방지·절초 평가.
- [ ] 경쟁·관찰·고능력치 사람 검증 계약.

상태: `APPROVED_PENDING_MERGE_2_OF_10`.

## R2 — ActionSelectionDock 런타임 기준선

- [x] `[기초] [무공] [절초]` 구조.
- [x] 무공서→현재 해금 기술.
- [x] 가장 앞 유효 연속 수 자동 배치.
- [x] `[전조] → [실행]` 연결 블록.
- [x] 진행 전 이동·제거.
- [x] 절초기세 예약·환불.
- [x] 포인터 Drop 회귀 수정.
- [x] 구현 HEAD 자동 검증 PASS.
- [ ] Windows 실제 Godot·사람 검증.

상태: `IMPLEMENTED_AUTOMATED_PASS_HUMAN_PENDING`.

## R3 — 정본·Sheet·PR 운영

- [x] PR #80 10/10 exact-head 검증·병합.
- [x] PR #81 main 상태 동기화와 Sheet readback.
- [x] PR #82 두 승인 Decision을 Branch·planning data·Sheet에 같은 ID로 기록.
- [x] PR #82 exact-head 세 필수 Workflow PASS·review thread 0.
- [ ] PR #82 최대 10건 또는 허용된 조기 체크포인트 완료.
- [ ] 전체 적대적 검토·P0/P1 0·exact-head 재검증.
- [ ] 병합 후 main SHA와 Sheet `SYNCED_TO_MAIN` 재기록.

상태: `ACTIVE_PLANNING_BATCH`.

## R4 — 기획 완료

```text
중간 노드 영구 스탯
→ 기술 배수·임계
→ 등급·파밍·절초 평가
→ 경쟁·관찰·사람 검증 계약
→ 10/10 또는 조기 체크포인트
→ exact-head PR·Sheet·정본 감사
```

상태: `NOT_COMPLETE`.

## R5 — 전체 검토

- 핵심 시스템·보조 시스템·핵심 재미·제품 목표 정렬.
- 성장·관찰·보상·등급이 수읽기를 대체하는 반례 검증.
- main·PR·Sheet·활성 소비자·untouched 문서·테스트 대조.
- 구현과 승인 기획 차이 목록·Codex 범위 확정.

상태: `BLOCKED_BY_R4`.

## R6 — 이미지·애니메이션·HX

```text
필요 목록 확정
→ 브리프·금지요소·화면 위치
→ 생성
→ 시각 QA·접근성·일관성 검수
→ 승인 ID·버전·파일 경로 기록
```

상태: `BLOCKED_BY_R5`.

## R7 — `VERTICAL_SLICE_APP_FLOW_SHELL`

```text
App Root
→ Main
→ 시작 무공 6중4
→ Route·Node·Briefing
→ 기존 Combat
→ Result·Reward·Retry
```

- [ ] 명시적 화면 상태 전환과 입력 잠금.
- [ ] `RunSession`·`SaveService` 최소 계약.
- [ ] Route·Node·Briefing 저충실도 Shell.
- [ ] Combat 진입·복귀.
- [ ] Result·Reward·Retry transaction.
- [ ] 저장 실패·same-seed 복원·이중 commit 회귀.

상태: `NOT_GRANTED_UNTIL_PLANNING_REVIEW_IMAGES_COMPLETE`.

## R8 — 콘텐츠 반복 제작

```text
슬롯별 대표 후보 1명으로 제품 흐름 증명
→ 두 번째 후보·노드 반복 제작
→ 제작 시간·데이터 재사용·사람 검증
→ 검증된 슬롯부터 후보 3명으로 확장
```

최종 `5슬롯 × 후보 3명` 계약을 축소하지 않는다.

## R9 — 사람·Vertical Slice 게이트

- Windows 실제 Godot.
- 키보드·마우스·게임패드.
- 해상도·safe area.
- 접근성·성능.
- `STEP 14` 신규 플레이어 5명.
- 고능력치가 잘못된 계획을 덮는 비율.
- 두 번째 콘텐츠 반복 제작 증거.

상태: `T1_NOT_GRANTED`.

## `[보류]`

- 16권 절초 개별 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 모바일 포팅·스토어·크로스 세이브.
- 최종 아트·오디오 폴리싱.

실행하지 않은 검증은 `NOT_RUN / UNVERIFIED`다.