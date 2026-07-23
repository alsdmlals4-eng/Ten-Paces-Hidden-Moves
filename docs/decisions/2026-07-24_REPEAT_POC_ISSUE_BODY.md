# Issue Body — REPEAT_POC 코어 검증

## Goal

현행 10칸·4/7·3/3/4 판정을 보존하면서 플레이어 가설 기록, 결정적 복기, 읽을 수 있는 라이벌 성향을 구현하고 동일 build SHA의 신규 플레이어 STEP 14를 실행한다.

## Player value

플레이어가 상대 의도를 하나 가정하고 수를 건 뒤 무엇을 맞히고 틀렸는지 이해해 다음 계획을 실제로 바꾸는 경험을 증명한다.

## Baseline

- Project core: `CORE_CONFIRMED`.
- Product gate: `REPEAT_POC`.
- Product baseline: `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- Planning branch: `agent/project-core-confirmation`.
- Plan: `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`.
- Codex entry: `plans/CODEX_GOAL_REPEAT_POC.md`.

## Required sequence

- [ ] PR-A0 정본 SHA·AI source·board schema 17 정렬.
- [ ] PR-A1 데이터 기반 라이벌 복수 후보·seed 재현·private input 차단.
- [ ] PR-A2 플레이어 가설 snapshot·결정적 summary builder.
- [ ] PR-A3 복기 UI·키보드·모션 감소 통합.
- [ ] PR-A4 고정 SHA 신규 플레이어 5명 STEP 14.

## Fixed rules

- 10칸·4/7·거리 3.
- 비공개 `3수 → 3수 → 4수`.
- 합·방어·회피·필중·중단·강건 공식 불변.
- AI는 공개 상태만 사용.
- 미기록 가설 추정 금지.
- 정답 행동·승률·예측률 제공 금지.

## Exclusions

새 행동·절초·세력·무공·성장·경제·저장·난이도·머신러닝·전체 미래 예고·콘텐츠 선확장.

## Gates

- Governance·reference freshness PASS.
- 신규 AI·hypothesis·summary·review UI Godot verifier PASS.
- 기존 판정·재시작·키보드·레이아웃 verifier PASS.
- Windows 1440×900·960×640 기술 확인.
- 동일 build SHA 참가자 5명.
- 실제 사람 증거 없이 T1·MVP 완료 선언 금지.

## Rollback

PR-A0~A4를 독립 스택형 PR로 유지한다. 각 단계 실패 시 해당 PR만 되돌리고 현행 최소 AI·기존 로그·next_bundle_ready 흐름으로 복귀한다.
