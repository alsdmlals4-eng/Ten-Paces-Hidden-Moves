# 십보강호 구현 로드맵과 검증 기준

> 책임: 현재 구현 패키지·Vertical Slice 진입 순서·검증 게이트  
> 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`  
> 전투 규칙: `docs/02_COMBAT_RULES.md`

## 1. 현재 단계

```yaml
phase: VERTICAL_SLICE_APP_FLOW_PLANNING
project_core: CORE_CONFIRMED
integration_pr: 65
action_selection_dock: IMPLEMENTED_AUTOMATED_VALIDATION_PASS_HUMAN_PENDING
situation_screen_architecture: APPROVED_PLANNING
full_product_flow_runtime: NOT_STARTED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
human_step14: NOT_RUN
t1_greenlight: NOT_GRANTED
```

## 2. 현재 작업

### 완료

- [x] 프로젝트 코어와 1대1·10칸·3/3/4 전투 정본화.
- [x] 데모 5슬롯·후보 3명·중간 노드 8개 계약.
- [x] 절차형 상대·경로와 슬롯 1~3 학습 역할 기획.
- [x] 3수 계획 편집·해결·복기 UX 승인.
- [x] 무공서→해금 기술→수 배치 UX 승인.
- [x] ActionSelectionDock·자동 배치·연결 블록·절초기세 예약 구현.
- [x] 마우스 Drop 누락을 RED 회귀 뒤 수정.
- [x] PR Validation·Base v9·Full Validation·Ubuntu Godot·Windows/Python matrix 통과.
- [x] 필수 화면 4종·P0 상황 10종·Scene 소유권 승인.

### 진행

- [ ] PR #65 정본·Google Sheets 동기화.
- [ ] PR #65 `main` 병합과 post-merge 재조회.

### 다음

`VERTICAL_SLICE_APP_FLOW_SHELL`

- [ ] App Root와 화면 상태 전환.
- [ ] Main Menu 저충실도 Shell.
- [ ] `RunSession`·`SaveService` 최소 계약.
- [ ] 시작 무공 6개 중 4개 선택 Shell.
- [ ] Route·Node·Briefing 저충실도 흐름.
- [ ] 기존 Combat PoC 진입·복귀.
- [ ] Result·Reward·Retry 1회성 transaction.
- [ ] 중복 입력·저장 실패·same-seed 재진입 회귀.
- [ ] 키보드·마우스·게임패드 Focus.
- [ ] 1280×800·1440×900·16:9 safe area.

## 3. 프로젝트 코어 확정

1대1·10칸·비공개 3/3/4·공개 정보 기반 상대 읽기·거리·`[합]`·대응·중단·복기는 불변이다. 로그라이트 성장은 다음 결투 판단을 바꾸는 보조 구조다.

행동 선택은 `[기초] [무공서→현재 해금 기술] [절초]`이며, 가장 앞 유효 연속 수에 자동 배치한다. 다중 수 행동은 `[전조] → [실행]` 연결 블록이고 절초기세는 `0~5` 예약·진행 전 환불을 사용한다.

## 4. 제품 흐름 패키지

승인 Decision: `TEN-DEC-20260801-SITUATION-SCREEN-01`.

```text
BOOT
→ MAIN
→ RUN_SETUP
→ ROUTE
→ NODE
→ DUEL_BRIEFING
→ COMBAT
→ COMBAT_REVIEW
→ DUEL_RESULT
→ REWARD_OR_RETRY
```

포함:

- App Root·화면 전환·입력 잠금.
- Main·Setup·Route·Node·Briefing Shell.
- 최소 RunSession·SaveService.
- Combat 진입·복귀.
- 보상·재도전 transaction.

제외:

- 후보 15명 전체.
- 최종 아트·오디오.
- 주요 비무 6~10.
- 천하제일인·비동기 기능.
- 사람 검증 PASS 주장.

## 5. 콘텐츠 제작 순서

최종 데모 계약은 `주요 비무 5슬롯 × 후보 3명`이다.

```text
슬롯별 대표 후보 1명으로 제품 흐름 증명
→ 두 번째 후보·노드 반복 제작
→ 제작 시간·데이터 재사용·사람 검증
→ 검증된 슬롯부터 후보 3명으로 확장
```

후보 수를 줄이는 결정이 아니라 파이프라인 위험을 먼저 줄이는 제작 게이트다.

## 6. Demo·전체 회차

```yaml
demo:
  major_duels: 5
  candidates_per_slot: 3
  gaps: 4
  nodes_per_gap: 2
  intermediate_nodes: 8
  target_playtime: 15_to_22_minutes
full_run:
  major_duels: 10
  candidates_per_slot: 3
  gaps: 9
  nodes_per_gap: 2
  intermediate_nodes: 18
  target_playtime: 30_to_40_minutes
```

## 7. BUILD/REVIEW 루프

```text
failing test
→ RED 확인
→ 최소 구현
→ focused test
→ diff·정본·Godot·회귀 REVIEW
→ 동일 HEAD 필수 검사
→ 병합 또는 REVISE
```

실행하지 않은 검증은 `NOT_RUN`이다. 사람 증거 없이 이해도·재미·피로를 PASS로 기록하지 않는다.

## 8. STEP 14

- 신규 플레이어 5명.
- 4명 이상 치명적 차단 없이 데모 흐름 완료 또는 이탈 이유 기록.
- 4명 이상 3/3/4와 결정적 원인을 설명.
- 3명 이상 상대 성향 발견.
- 3명 이상 노드 선택 뒤 다음 계획 변경.
- 3명 이상 재도전에서 계획 변경.
- 색·모션·음향 단일 채널 의존 없음.

현재 `human_step14: NOT_RUN`이다.

## 9. T1 — 최소 세로 슬라이스

다음 증거가 모두 있어야 진입한다.

- App Flow Shell 자동·Godot 검증.
- Windows 실제 실행.
- 접근성·해상도·성능 검증.
- 사람 STEP 14.
- 두 번째 상대·노드 반복 제작 증거.

현재 `t1_greenlight: NOT_GRANTED`다.

## 10. 공통 검증 게이트

```text
계약·Schema
→ JSON·정적 검사
→ 자동 테스트
→ Godot headless
→ Windows runtime·render
→ 접근성·성능
→ 사람 플레이
→ 정본·Sheet 동기화
→ evidence-report
```

## 11. 후속 운영

### Base v9.3 migration

PR #65가 main에 안정화된 뒤 별도 PR에서 release·evidence pin, Adapter, generated view, Registry hash, protected baseline, freshness, 회귀를 함께 갱신한다.

### 사람 검증

ActionSelectionDock은 자동 검증을 통과했지만 Windows 실제 Godot·실물 마우스 Drag·게임패드·화면 읽기 도구·신규 플레이어 이해도는 `NOT_RUN`이다.

## 12. 중단·축소 조건

- 연격이 다른 공격을 지배한다.
- 성장·노드 선택이 피해 증가만 만든다.
- 노드가 반복 피로만 늘린다.
- 공개 성향 없이 정답 추측에 의존한다.
- 3/3/4 또는 무공서→기술 관계가 이해되지 않는다.
- 두 번째 무공·적·노드를 같은 데이터 구조로 만들 수 없다.
- 플레이어 미확정 계획을 AI가 읽는다.
- 보상·저장이 이중 commit된다.
- 외부 에셋 때문에 정보 구조나 전투 계약을 왜곡한다.

판정 어휘: `KEEP / AMPLIFY / CHANGE / REMOVE / DEFER / RETEST`.

## 13. 역사

2026-07-26의 P0-A/B/C 계획은 역사 입력이다. 기존 `2~3노드`, `13~17개 방문`, `new_poc_runtime: NOT_STARTED` 표현은 최신 Decision으로 대체됐다.
