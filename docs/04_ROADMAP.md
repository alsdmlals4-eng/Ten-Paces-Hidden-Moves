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

## 2. 완료된 작업

- [x] 프로젝트 코어 확정.
- [x] 1대1·10칸·3/3/4·거리·합·방어도·중단·복기 정본화.
- [x] 데모 5슬롯·후보 3명·중간 노드 8개 계약.
- [x] 전체 회차 10슬롯·중간 노드 18개 계약.
- [x] 절차형 상대 후보·경로 생성 계약.
- [x] 슬롯 1~3 학습 역할·후보 풀 기획.
- [x] 3수 계획 편집·해결·복기 UX 승인.
- [x] `기초 / 무공서→해금 기술 / 절초` 행동 선택 UX 승인.
- [x] ActionSelectionDock·공통 자동 배치·연결 블록·절초기세 예약 구현.
- [x] 연결 블록 포인터 Drop 누락을 RED 회귀 뒤 수정.
- [x] PR Validation·Base v9·Full Validation·Ubuntu Godot·Windows/Python matrix 통과.
- [x] 필수 화면 4종·P0 상황 10종·Scene 소유권 승인.
- [ ] PR #65 `main` 병합·post-merge Sheet 재동기화.
- [ ] Windows 실제 Godot·사람 UX 검증.

## 3. 프로젝트 코어 확정

1대1·10칸·비공개 3/3/4·공개 정보 기반 상대 읽기·거리·`[합]`·대응·중단·복기는 불변이다. 로그라이트 성장은 다음 결투 판단을 바꾸는 보조 구조다.

## 4. 현재 구현 패키지 종료

### ActionSelectionDock

Decision: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`

- 행동 출처 `기초 / 무공 / 절초`.
- 무공서가 아니라 현재 해금 기술을 배치.
- 가장 앞의 유효 연속 수 자동 배치.
- 2수·3수 연결 블록 `[전조] → [실행]`.
- 진행 전 마우스·키보드·게임패드 재배치·제거.
- 절초기세 예약·진행 전 환불·이동 시 재예약.
- 제품 P0 가상 `준비+막기/회피` 제외.

검증 HEAD `673c209017ffe3e1c7ef2a89849ca4ea0846d1c5`:

```yaml
pr_validation_993: PASS
base_v9_106: PASS
full_validation_73: PASS
ubuntu_godot_headless: PASS
action_selection_smoke: PASS
ubuntu_windows_python_matrix: PASS
windows_godot_runtime: NOT_RUN
human_validation: NOT_RUN
```

## 5. 다음 구현 패키지 — `VERTICAL_SLICE_APP_FLOW_SHELL`

Decision: `TEN-DEC-20260801-SITUATION-SCREEN-01`

### 목표

전투 PoC 직행 구조를 다음 저충실도 제품 흐름으로 연결한다.

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
→ ROUTE 또는 RUN_COMPLETE
```

### 포함

- [ ] App Root와 명시적 화면 상태 전환.
- [ ] Main Menu Shell.
- [ ] `RunSession`·`SaveService` 최소 계약.
- [ ] 시작 무공 6개 중 4개 선택 Shell.
- [ ] Route·Node·Briefing 저충실도 화면.
- [ ] 기존 Combat PoC 진입·복귀.
- [ ] Result·Reward·Retry 1회성 transaction.
- [ ] 전환 중 중복 입력 차단.
- [ ] 저장 실패·손상·same-seed 복원.
- [ ] 키보드·마우스·게임패드 Focus 계약.
- [ ] 1280×800·1440×900·16:9 safe area 검증.

### 제외

- 후보 15명 전체 구현.
- 최종 아트·오디오 폴리싱.
- 주요 비무 6~10.
- 천하제일인·비동기 기능.
- 사람 검증 PASS 주장.

## 6. 콘텐츠 제작 단계

최종 데모 계약은 `주요 비무 5슬롯 × 후보 3명`이다. 제작 순서는 다음과 같다.

```text
1. 슬롯별 대표 후보 1명으로 제품 흐름 파이프라인 증명
2. 두 번째 후보·노드를 같은 구조로 반복 제작
3. 제작 시간·데이터 재사용·사람 검증 확인
4. 검증된 슬롯부터 후보 3명으로 확장
```

후보 수를 줄이는 결정이 아니라 선행 위험을 줄이는 단계적 제작 게이트다.

## 7. 후속 패키지

### `APP_FLOW_HUMAN_VALIDATION`

- 신규 플레이어의 첫 3초 화면 목표 이해.
- 무공서→해금 기술 관계 이해.
- 3/3/4 계획과 전체 10수 이해.
- 절초기세 예약·환불 이해.
- Result 복기 뒤 다음 계획 변경.
- 저장·재진입·패배 재도전 이해.

### `SECOND_CONTENT_PIPELINE_PROOF`

- 같은 데이터 구조로 두 번째 상대·노드 제작.
- 후보별 공통/고유 데이터 분리.
- AI·전조·정보 노드 반복 제작 비용 측정.

### `DEMO_SLOT_POOL_EXPANSION`

- 슬롯 1~5 후보 각 3명.
- 최종 노드 풀·보상·경로 안전장치.
- 15~22분 플레이타임 재검증.

### `BASE_V9_3_MIGRATION`

- PR #65 main 안정화 뒤 별도 진행.
- Base release pin·evidence·Adapter·generated compatibility view·freshness·test를 함께 갱신.
- 제품 코드·기획 Decision 변경과 분리.

## 8. Demo·전체 회차 범위

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

## 9. BUILD/REVIEW 루프

```text
BUILD: failing test → RED 확인 → 최소 구현 → focused test
→ REVIEW: diff·정본·정적·Godot·접근성·회귀
→ 동일 HEAD 검증
→ 병합 또는 REVISE
```

- 구현 패키지는 독립 Branch/PR로 진행한다.
- 실패 기준을 무시하고 다음 기능을 진행하지 않는다.
- 실행하지 않은 검증은 `NOT_RUN`이다.
- 사람 증거 없이 이해도·재미·피로를 PASS로 기록하지 않는다.

## 10. STEP 14

- 신규 플레이어 5명.
- 4명 이상 치명적 차단 없이 데모 흐름 완료 또는 이탈 이유 기록.
- 4명 이상 3/3/4와 결정적 원인을 설명.
- 3명 이상 상대 성향을 발견.
- 3명 이상 노드 선택 뒤 다음 계획 변경.
- 3명 이상 재도전에서 계획 변경.
- 색·모션·음향 단일 채널 의존 없음.

현재 `human_step14: NOT_RUN`이다.

## 11. T1 — 최소 세로 슬라이스

다음 증거가 모두 있어야 진입한다.

- App Flow Shell 자동·Godot 검증.
- Windows 실제 실행.
- 접근성·해상도·성능 검증.
- 사람 STEP 14.
- 두 번째 상대·노드 반복 제작 증거.

현재 `t1_greenlight: NOT_GRANTED`다.

## 12. 공통 검증 게이트

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

## 13. 중단·축소 조건

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

## 14. 역사

2026-07-26의 P0-A/B/C 계획은 현재 구조의 역사 입력이다. 기존 `2~3노드`, `13~17개 방문`, `new_poc_runtime: NOT_STARTED` 표현은 최신 2026-07-31·2026-08-01 Decision으로 대체됐다.
