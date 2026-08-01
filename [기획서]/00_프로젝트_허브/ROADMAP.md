# 십보강호 운영 로드맵

> 상세 제품 로드맵: `../../../docs/04_ROADMAP.md`  
> 현재 상태: `ACTIVE_CONTEXT.md`  
> 과거 v6 결정 인덱스: `../../../docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
integration_pr: 65
implemented_decision: TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
approved_planning_decision: TEN-DEC-20260801-SITUATION-SCREEN-01
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
human_validation: NOT_RUN
```

## R0 — 구현·역사 기준선

- [x] T0 구현 계보 PR #7·Issue #13 보존.
- [x] 기술 기준 SHA `659c57e7ffa588ad6a6471ed9b5394985b159eaf` 보존.
- [x] v6 원장을 역사 인덱스로 유지.
- [x] 최신 날짜별 Decision과 실제 구현을 현재 권한으로 사용.

상태: `APPROVED`.

## R1 — 전투·회차 기획

- [x] 1대1 10칸·3/3/4·거리·합·방어도·중단·복기.
- [x] 데모 5슬롯·후보 3명·중간 노드 8개.
- [x] 전체 10슬롯·중간 노드 18개.
- [x] 절차형 상대·경로와 슬롯 1~3 학습 역할.
- [x] 3수 계획 편집·해결·복기 UX.

상태: `APPROVED_PLANNING`.

## R2 — ActionSelectionDock

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

## R3 — 정본·Sheet·PR #65

- [x] 최신 Decision·planning data·Closeout·감사 문서.
- [x] Active Context·Documentation Map·Roadmap·진입점 갱신.
- [x] Google Sheets 7개 책임 탭 동기화·재조회.
- [ ] 동일 HEAD의 PR Validation·Base v9·Full Validation PASS.
- [ ] PR #65 main 병합.
- [ ] main SHA와 Sheet 상태 `SYNCED` 재기록.

상태: `INTEGRATION_REVIEW`.

## R4 — `VERTICAL_SLICE_APP_FLOW_SHELL`

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

상태: `APPROVED_NEXT_PACKAGE / NOT_STARTED`.

## R5 — 콘텐츠 반복 제작

```text
슬롯별 대표 후보 1명으로 제품 흐름 증명
→ 두 번째 후보·노드 반복 제작
→ 제작 시간·데이터 재사용·사람 검증
→ 검증된 슬롯부터 후보 3명으로 확장
```

최종 `5슬롯 × 후보 3명` 계약을 축소하지 않는다.

## R6 — 사람·Vertical Slice 게이트

- Windows 실제 Godot.
- 키보드·마우스·게임패드.
- 해상도·safe area.
- 접근성·성능.
- `STEP 14` 신규 플레이어 5명.
- 두 번째 콘텐츠 반복 제작 증거.

상태: `T1_NOT_GRANTED`.

## R7 — Base v9.3

PR #65가 main에 안정화된 뒤 별도 migration PR에서 Adapter·pin·generated view·Registry hash·protected baseline·freshness·회귀를 함께 갱신한다.

상태: `SEPARATE_FOLLOWUP`.

## `[보류]`

- 16권 절초 개별 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 최종 아트·오디오 폴리싱.

실행하지 않은 검증은 `NOT_RUN / UNVERIFIED`다.
