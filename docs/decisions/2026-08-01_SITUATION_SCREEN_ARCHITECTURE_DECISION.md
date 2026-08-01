# 상황별 인게임 화면·제품 흐름 아키텍처 결정

- Decision ID: `TEN-DEC-20260801-SITUATION-SCREEN-01`
- 승인일: `2026-08-01`
- 상태: `APPROVED_PLANNING`
- 승인 근거: 사용자의 권장안 일괄 승인
- 상세 설계 입력: `docs/superpowers/specs/2026-07-31-situation-screen-implementation-spec.md`
- 구조화 계약: `docs/planning-data/approved_20260801_situation_screen_contract.json`
- 런타임 권한: `NONE_FOR_FULL_PRODUCT_FLOW`
- 사람·시각 검증: `NOT_RUN`

## 1. 승인 결정

십보강호의 제품 흐름은 전투 PoC 단일 화면을 확장하는 방식이 아니라, 플레이어 상황과 상태 소유권에 따라 다음 화면·상태로 분리한다.

```text
BOOT
→ MAIN
→ RUN_SETUP
→ ROUTE
→ NODE
→ DUEL_BRIEFING
→ COMBAT_PLAN
→ COMBAT_RESOLVE
→ COMBAT_REVIEW
→ DUEL_RESULT
→ REWARD_OR_RETRY
→ ROUTE 또는 RUN_COMPLETE
```

필수 기준 화면은 다음 네 종류다.

1. 메인 화면
2. 비무 핵심 플레이 화면
3. 무공 구성·성급·해금 기술·보유 자원 화면
4. 결과·복기·보상 화면

P0 플레이 상황은 `Main`, `Run Setup`, `Route`, `Node`, `Duel Briefing`, `Combat Plan`, `Resolve`, `Review`, `Victory Reward`, `Defeat Retry` 10종으로 고정한다.

## 2. Scene·상태 소유권

- `Route`와 `Combat`은 별도 Scene으로 구성한다.
- `Combat Review`는 전투 Scene 내부 Overlay로 유지한다.
- `Duel Result`는 전투 종료 뒤 진입하는 별도 Scene으로 둔다.
- P0 Autoload 후보는 `RunSession`, `SaveService`로 제한한다.
- `CombatState`는 Combat Scene이 소유한다.
- UI는 판정·보상·저장 규칙을 재계산하지 않고 도메인 결과를 표시한다.
- 화면 전환은 입력 잠금, 다음 Scene 준비 완료, 중복 요청 차단을 포함한다.

## 3. 기존 구현 재사용

다음 현행 전투 PoC 요소는 재사용한다.

- 10칸 일자형 전장
- 상단 HUD
- 3/3/4 전체 10수 타임라인
- `ActionSelectionDock`
- 상대 가설
- 판정 로그
- `CombatReviewPanel`
- 전투 판정 엔진과 안정적인 결과 이벤트

`CombatBoardPreview`의 화면 조립·입력·레이아웃·연출·오디오·재시작 책임은 한 번에 재작성하지 않고 패키지별로 점진 분리한다.

## 4. 콘텐츠 제작 단계

최종 데모 계약인 `주요 비무 5슬롯 × 슬롯별 후보 3명`은 유지한다. 다만 15명 전체 제작을 첫 통합 구현의 선행 조건으로 두지 않는다.

```text
1차 파이프라인 증명
- 슬롯별 대표 후보 1명
- Main→Setup→Route→Node→Briefing→Combat→Result 연결
- 저장·재진입·보상 1회 commit 검증

2차 반복 제작 증명
- 같은 구조로 두 번째 후보·노드 제작
- 데이터 재사용성과 제작 비용 검증

3차 후보 풀 확장
- 자동·사람 검증을 통과한 슬롯부터 후보 3명으로 확장
```

이는 후보 15명 계약을 축소하거나 폐기하는 결정이 아니라, 파이프라인 실패 위험을 먼저 줄이는 제작 순서다.

## 5. P0 다음 구현 패키지

다음 구현 패키지는 `VERTICAL_SLICE_APP_FLOW_SHELL`이다.

포함:

- App Root와 명시적 화면 상태 전환
- Main Menu 저충실도 화면
- RunSession·SaveService 최소 계약
- Run Setup 6중4 선택 Shell
- Route·Node·Briefing 저충실도 흐름
- 기존 Combat PoC 진입·복귀 연결
- Result/Reward/Retry 1회성 transaction Shell
- 정상·중복 입력·저장 실패·재진입 회귀 테스트

제외:

- 후보 15명 전체 콘텐츠
- 최종 아트·사운드 폴리싱
- 주요 비무 6~10
- 천하제일인·비동기 기능
- 사람 검증 완료 주장

## 6. 품질·접근성 게이트

- 키보드·마우스·게임패드로 핵심 흐름을 완주할 수 있어야 한다.
- 색·모션·음향 하나만으로 상태를 전달하지 않는다.
- 1280×800, 1440×900, 16:9 안전영역에서 핵심 입력이 잘리지 않아야 한다.
- 전환 중 중복 입력, 보상 이중 commit, 저장 실패, 동일 seed 복원이 검증돼야 한다.
- 자동 검증은 사람의 화면 이해·재미·피로 검증을 대체하지 않는다.

## 7. 남은 기획

- Main 최종 키아트와 로고
- 저장 슬롯·재도전 비용·복구 UX의 제품 값
- Route·Node 저충실도 와이어프레임
- Result/Reward 정보 우선순위
- 실제 화면 기준 해상도와 폰트 라이선스
- 후보 15명의 자산 제작 예산과 반복 제작 속도

위 항목 중 기술 기본값은 최소 안전안으로 진행하고, 프로젝트 코어·플레이어 경험을 바꾸는 변경만 Decision으로 승격한다.
