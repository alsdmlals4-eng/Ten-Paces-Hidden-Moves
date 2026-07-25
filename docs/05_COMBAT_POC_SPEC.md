# 십보강호 전투 POC·세로 슬라이스 명세

> 책임: 현재 구현 상태와 다음 플레이 가능한 PoC의 목적·범위·성공·실패 기준

## 1. 목적

다음 PoC는 전체 게임 제작이 아니라 다음 질문을 검증한다.

> 공개 성향이 다른 세 상대와 3번 싸우고 두 번 성장했을 때, 플레이어가 거리·합·대응·중단을 읽어 실제 계획을 바꾸는가?

## 2. 단계 구분

### CURRENT_T0

`STEP_0_TO_13_IMPLEMENTED`, `mechanical_step14` 기록 완료. 현재 런타임은 구형 수치를 구현하며 새 기획은 미구현이다.

### 다음 PoC

- 주요 비무 3개.
- 선택 성장 노드 2개.
- 시작 무공 후보 6개 중 4개 선택.
- 최신 승인 전투 규칙.
- 결정적 복기.

### T1

사람 PoC 통과 뒤 목표 품질과 제작 파이프라인을 검증하는 최소 세로 슬라이스.

## 3. 현행 T0 계약

10칸·4/7·3/3/4·기초 행동 8종·절초 3종·합·방어·회피·필중·중단·강건·공개 상태 AI·재시작을 기술적으로 실행한다. 숫자는 `IMPLEMENTED_LEGACY`이며 상세 차이는 02 문서가 소유한다.

## 4. 다음 PoC 계약

### 흐름

```text
시작 무공 4개 선택
→ 주요 비무 1
→ 성장 선택
→ 주요 비무 2
→ 성장 선택
→ 주요 비무 3
→ 복기·종료
```

### 포함

- 순차 연격 합과 첫 피해 중단.
- 방어도5 누적·소모.
- 횟수형 회피와 필중.
- 강화×1.5와 중단 1회 강건.
- 적중 효과 scope/trigger.
- 공개 성향과 최대 3 AI 후보.
- 성과 등급·수련포인트.

### 제외

- 주요 비무 4~10 구현.
- 전체 지도 생성.
- 저장·영구 성장·상점 완성.
- 최종 아트·사운드·Release 성능.

## 5. 구현 단계와 증거 상태

```yaml
current_runtime: TECHNICALLY_VERIFIED_LEGACY
new_planning_contract: AUTHORED
new_runtime_implementation: NOT_STARTED
new_automated_validation: NOT_RUN
new_godot_validation: NOT_RUN
new_windows_validation: NOT_RUN
human_step14: NOT_RUN
t1_greenlight: NOT_GRANTED
```

## 6. STEP 14 플레이테스트 계약

- 빌드·commit·Godot 버전·플랫폼·입력 방법을 기록한다.
- 행동 관찰과 인터뷰 반응을 분리한다.
- 합·중단·강건·연격·성장 선택의 이해를 확인한다.
- 결과를 본 뒤 성공 기준을 바꾸지 않는다.

## 7. T0 완료 기준

다음 새 계약의 데이터·코드·테스트·문서가 일치하고, 비공개 계획 누출·재시작 누적·설명 불가능한 결과가 없어야 한다. 기계 통과만으로 사람 이해를 통과 처리하지 않는다.

## 8. 현재 판정

```yaml
planning_phase: PLANNING_IN_PROGRESS
poc_scope: THREE_DUELS_TWO_GROWTH_CHOICES
implementation: NOT_STARTED
human_step14: NOT_RUN
t1_greenlight: NOT_GRANTED
decision: RETEST
```
