# 초기 무공서 10권 런타임 기반 설계

> Gate: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`  
> 사용자 승인: `2026-08-06 권장안대로 진행`  
> 부모 Decision: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`  
> 상태: `IMPLEMENTED_RUNTIME_FOUNDATION`

## 목표

승인된 초기 무공서 10권의 3·5·7·9·10성 구조를 Godot 런타임이 읽고 합성하고 결정적으로 실행할 수 있게 한다. 현행 기본 행동과 공용 절초는 호환 회귀 기준으로 유지하며, UI 전면 교체·AI 자동 채택·최종 밸런스는 별도 Gate로 분리한다.

## 채택 구조

### 1. 분할 런타임 카탈로그

```text
data/cards/martial_manual_cards.json
└─ Decision·runtime 상태·호환 정책·정확한 10개 파일 map

data/cards/martial_manuals/*.json
└─ 무공서별 3·7·10성 카드와 5·9성 overlay
```

단일 대형 JSON은 검토·충돌 해결·책임 분리가 불리해 기각했다.

### 2. MartialManualRegistry

- manifest와 10개 무공서 파일을 로드한다.
- 숙련도 3·5·7·9·10에 맞춰 해금 카드를 구성한다.
- 5성은 star3만, 9성은 star7만 수정한다.
- 9성은 정확히 한 단계의 무분기 effect를 추가한다.
- 매 호출마다 deep copy를 반환해 정본 JSON 변조를 막는다.
- 명시적인 loadout과 mastery map이 있을 때만 카드를 병합한다.

### 3. MartialEffectPipeline

카드명별 하드코딩이 아니라 순서가 있는 `effect_steps`를 실행한다.

허용 구조:

- 상태·자원 생성과 소비.
- 전투당 사용권 소비.
- 접근·후퇴·밀치기.
- 사거리 재검사.
- 일반·독립 공격.
- 특수 합.
- 방어 파괴.
- 실제 체력 적중·방어0·합 승리·회피 성공 요구.
- 완료 시 기세.
- 방어 손실 기록.

금지 구조:

- 독·출혈 등 미승인 신규 상태.
- 무작위 타수.
- 숨은 계획 열람.
- 자동 정답·자동 합 승리.
- 사용자 추가 입력.
- 능력치 권수 쿼터.

### 4. 전투 호환 어댑터

`TenManualCombatResolutionEngine`은 현행 전투 엔진을 상속한다.

- 기본 동작에서는 기존 기본 카드와 공용 절초만 유지한다.
- `configure_martial_loadout` 호출 시에만 해금 무공 카드를 병합한다.
- 재구성 시 이전 무공 카드만 제거한다.
- 기본 카드·공용 절초 ID는 제거·변경하지 않는다.
- 무공 effect program은 `resolve_martial_card`를 통해 pipeline에 위임한다.

기존 엔진을 직접 대규모 수정하는 안은 회귀 원인 분리가 어려워 기각했다.

## 데이터 계약

- 정확한 10권 roster를 사용한다.
- 각 무공서의 문파·이름·주/보조능력치는 승인 계약과 일치한다.
- 능력치별 권수·균등 분포·최소/최대 쿼터는 존재하지 않는다.
- 각 무공서에는 star3·star7·star10 카드와 star5·star9 overlay가 존재한다.
- 실행 카드에는 ID, 이름, manual ID, 해금 성급, 범주, 해결 단계, 대상 방식, 슬롯, 비용, 사거리, effect steps, 예산 참조, 임시 밸런스 표시가 필요하다.
- 사람 밸런스 미검증 수치는 `PROVISIONAL_WITHIN_APPROVED_BUDGET`으로 표시한다.

## 특수 불변조건

### 자하신공

- 프로그램 첫 단계에서 전투당 사용권을 소모한다.
- 이후 중단·전투불능에도 환불하지 않는다.
- 전체 프로그램 완료 시에만 절초기세 +1을 지급한다.

### 나한금강공

- 방어·강건이 공격보다 먼저 실행된다.
- 강건은 현행 중단 1회 방지 범위만 사용한다.
- 무적·피해 무시·절대 중단 면역을 만들지 않는다.

### 회마창

```text
첫 공격 → 후퇴 → 사거리 재검사 → 두 번째 공격
```

두 번째 공격은 사거리 실패를 무시하지 않는다.

### 능파미보

```text
회피 성공 → 이동 전 반격 → 후퇴 → 준비 상태
```

### 만천화우

독립 공격 4회를 결정적으로 처리하며 무작위 타수를 사용하지 않는다.

## TDD 증거

RED:

- workflow `31049328495`: manifest·레지스트리·pipeline 부재.
- workflow `31050666862`: 전투 호환 어댑터 부재.

GREEN:

- 10권 roster·stat-fit·성급 구조 정적 계약.
- 적대적 변조 테스트.
- Godot 4.7.1 registry·pipeline·adapter headless 검증.
- PR Validation·Full Validation과 기존 전투 회귀.

## 완료 경계

`RUNTIME_FOUNDATION` 완료:

- 데이터 로드.
- 숙련 해금·overlay 합성.
- 구조적 effect 실행.
- 명시적 전투 loadout 통합.
- 기존 카드 호환성.

아직 완료 아님:

- 전체 행동 선택 UI.
- AI 자동 채택.
- 최종 밸런스·아트·연출·음향.
- Windows·접근성·성능·사람 플레이.
- PR 병합·Draft 해제.

다음 Gate는 `TEN_MANUAL_UI_AI_ADOPTION_GATE`다.
