# 십보강호 v6 전체 결정 권한 원장 — Part 1B

> 정본 인덱스: `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`

# 6. 다중 슬롯·전조·중단·효과 원자성

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| SLOT-01 | CONFIRMED | 1슬롯 행동은 해당 슬롯에서 실행한다. | `SLOT-C` |
| SLOT-02 | CONFIRMED | 2슬롯 행동은 1슬롯 `[전조]`, 2슬롯 `[실행]`이다. | `SLOT-C` |
| SLOT-03 | CONFIRMED | 3슬롯 행동은 1·2슬롯 `[전조]`, 3슬롯 `[실행]`이다. | `SLOT-C` |
| SLOT-04 | CONFIRMED | 전조 슬롯에서는 피해·이동·상태 부여 등 실제 전투 효과를 실행하지 않는다. | `SLOT-C` |
| SLOT-05 | CONFIRMED | 복합 행동의 여러 효과는 마지막 실행 슬롯에서 명시된 내부 순서로 해결한다. | `SLOT-C` |
| SLOT-06 | CONFIRMED | 행동 중단 시 이미 완료된 효과는 보존한다. | `SLOT-C` |
| SLOT-07 | CONFIRMED | 중단 시 현재 미해결 효과와 같은 행동의 이후 효과는 취소한다. | `SLOT-C` |
| SLOT-08 | CONFIRMED | 중단되어도 이후 별도 행동 슬롯의 계획은 유지한다. | `SLOT-C` |
| SLOT-09 | CONFIRMED | 예외는 좁은 `[강건]` 보호 또는 명시적 행동 단위 면역만 허용한다. | `SLOT-C` |
| SLOT-10 | CONFIRMED | 효과의 기본 원자 단위는 주효과와 직접 종속 결과다. | `SLOT-C` |
| SLOT-11 | CONFIRMED | 원자 효과 사이에는 중단·자동 발동·사망 검사를 허용한다. | `SLOT-C` |
| SLOT-12 | CONFIRMED | 치명타가 발생하면 비용·사용 기록·로그·정산 플래그를 보존하고 비필수 후속 결과는 생략한다. | `SLOT-C` |
| SLOT-13 | CONFIRMED | 다중 슬롯 행동은 첫 점유 슬롯에서 `STARTED/IN_PROGRESS`가 되며 마지막 실행 슬롯까지 같은 행동 인스턴스로 유지된다. | `SLOT-C` |
| SLOT-14 | CONFIRMED | 전조 구간의 유효 중단은 현재 다중 슬롯 행동의 남은 전조와 실행을 취소하고 점유 슬롯과 이미 지불한 비용은 반환하지 않는다. | `SLOT-C` |
| SLOT-15 | CONFIRMED | 1슬롯 행동은 같은 슬롯에서 자기 판정 단계보다 앞선 유효 중단 원인이 있을 때만 실행 전에 중단될 수 있다. | `SLOT-C` |
| SLOT-16 | CONFIRMED | `[강건]`은 속공 단계 피격이 1슬롯 행동에 만들 중단만 1회 방지하며, 진행 중인 2·3슬롯 행동은 보호하지 않는다. | `SLOT-C` |
| SLOT-17 | CONFIRMED | 하나의 공격 효과가 만든 `[연격]` 피해 묶음은 중단 시도를 기본적으로 공격 효과당 최대 한 번만 발생시킨다. | `SLOT-C` |

---

# 7. 비용·계획 미리보기·실행 실패

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| COST-01 | CONFIRMED | 행동 비용은 행동 시작 시 전액 원자적으로 지불한다. | `COST-C` |
| COST-02 | CONFIRMED | 다중 슬롯 행동은 첫 전조 슬롯에서 비용을 지불한다. | `COST-C` |
| COST-03 | CONFIRMED | 중단·사거리 실패·방향 실패·합 패배·회피·KO에도 비용을 환불하지 않는다. | `COST-C` |
| COST-04 | CONFIRMED | 계획 미리보기에는 보장된 자원 획득만 포함한다. | `COST-C` |
| COST-05 | CONFIRMED | 조건부 자원 획득은 계획 가능 자원으로 미리 계산하지 않는다. | `COST-C` |
| COST-06 | CONFIRMED | 각 행동은 첫 점유 슬롯의 행동 시작 시점에 실제 자원과 시작 조건을 다시 검증한다. | `COST-C` |
| COST-07 | CONFIRMED | 행동 시작 시 자원이 부족하면 그 첫 점유 슬롯에서 즉시 `fizzle`한다. | `COST-C` |
| COST-08 | CONFIRMED | fizzle은 비용을 지불하지 않고 모든 효과를 취소한다. | `COST-C` |
| COST-09 | CONFIRMED | fizzle한 행동의 점유 슬롯은 소비되고 이후 행동은 계속된다. | `COST-C` |
| COST-10 | CONFIRMED | fizzle 슬롯에 다른 행동을 대체 배치하지 않는다. | `COST-C` |
| COST-11 | CONFIRMED | fizzle은 `used/attempted`로 기록하되 `started/resolved/completed`로 기록하지 않는다. | `COST-C` |
| COST-12 | CONFIRMED | fizzle은 사용 제한·충전·재사용 대기·첫 사용·반복 시도 카운트를 소비한다. | `COST-C` |
| COST-13 | CONFIRMED | fizzle은 공격·적중·합·피해 트리거를 발생시키지 않는다. | `COST-C` |
| COST-14 | CONFIRMED | 사용·시도 예약형 버프는 fizzle에서 소비될 수 있다. | `COST-C` |
| COST-15 | CONFIRMED | 시작·공격·합·적중·피해·완료 시점 버프는 fizzle에서 소비하지 않는다. | `COST-C` |
| COST-16 | CONFIRMED | 다중 슬롯 행동이 첫 전조에서 fizzle하면 해당 행동의 나머지 점유 슬롯은 소비된 상태로 건너뛰며 전조·실행 효과를 발생시키지 않는다. | `COST-C` |
| COST-17 | CONFIRMED | 절초기세 5의 예약 소비는 일반 행동 비용 선지불 규칙과 분리된 계획 단계 예외다. | `COST-C` |
| COST-18 | CONFIRMED | 자동 효과의 비용 부족 실패는 계획 행동의 fizzle과 다르며 사용 횟수·재사용 대기·예약 효과를 소비하지 않는다. | `COST-C` |

---

# 8. 예약 효과·태그 중첩·지속시간

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| STACK-01 | CONFIRMED | 서로 다른 예약 효과는 동시에 존재할 수 있다. | `STACK-C` |
| STACK-02 | LATEST_OVERRIDE | 지속형 상태·예약 효과 인스턴스는 중첩 방식을 명시해야 하며 누락은 검증 오류다. 구조·분류·즉시 효과 표식에는 상태 중첩 방식을 요구하지 않는다. | `STACK-L` |
| STACK-03 | CONFIRMED | 중첩 방식: `STACK_VALUE / STACK_CHARGES / STACK_INSTANCES / REFRESH / REPLACE_HIGHER / NON_STACKING`. | `STACK-C` |
| STACK-04 | CONFIRMED | 대부분의 태그는 중첩 가능하며 비중첩은 예외로 취급한다. | `STACK-C` |
| STACK-05 | LATEST_OVERRIDE | 지속형 상태·예약 효과 인스턴스는 지속시간을 명시해야 하며 누락은 검증 오류다. `[전조]`, `[절초]`, `[연격 N]`, `[경공]`, 계통 태그와 즉시 위치 효과에는 지속시간을 요구하지 않는다. | `STACK-L` |
| STACK-06 | CONFIRMED | 지속시간: `UNTIL_CONSUMED / UNTIL_ACTION_END / UNTIL_BUNDLE_END / UNTIL_ROUND_END / UNTIL_COMBAT_END / FIXED_TRIGGER_COUNT / FIXED_ACTION_COUNT / FIXED_BUNDLE_COUNT`. | `STACK-C` |
| STACK-07 | CONFIRMED | 전투 상태 태그는 다음 전투로 이월하지 않는다. | `STACK-C` |
| STACK-08 | CONFIRMED | 무공서의 영구 기능은 전투 상태가 아니라 패시브로 취급한다. | `STACK-C` |
| STACK-09 | CONFIRMED | 상태 인스턴스는 출처·값·충전·획득 순서·지속시간·잔여량·만료를 추적한다. | `STACK-C` |
| STACK-10 | CONFIRMED | 소비 우선순위는 가장 빠른 만료 → 가장 오래된 획득 → 안정적 인스턴스 ID다. | `STACK-C` |
| STACK-11 | CONFIRMED | 여러 충전을 나눠 소비할 수 있지만 총량을 원자적으로 검증하고 부족하면 전혀 소비하지 않는다. | `STACK-C` |
| STACK-12 | CONFIRMED | 자동 효과의 동일 태그 경쟁 우선순위는 현재 행동 효과 순서 → 무공서 효과 순서 → 태그 획득 순서 → 안정적 효과 ID다. | `STACK-C` |
| STACK-13 | CONFIRMED | 자동 효과에는 플레이어 중간 선택·예약을 두지 않는다. 선택이 필요하면 능동 기술로 만든다. | `STACK-C` |
| STACK-14 | CONFIRMED | 자동 효과의 비용이 부족하면 부분 지불·부분 효과·사용 횟수 소비 없이 실패한다. | `STACK-C` |
| STACK-15 | CONFIRMED | 조건과 비용이 유효한 자동 효과는 의무 발동하며 임의 끄기 기능을 두지 않는다. | `STACK-C` |
| STACK-16 | CONFIRMED | `[연격 N]`, `[밀치기 N]`, `[추격 N]`, `[후퇴 N]`처럼 행동 데이터에 직접 적힌 즉시 효과 수치는 지속형 상태가 아니라 해당 공격·효과 인스턴스의 매개변수다. | `STACK-C` |
| STACK-17 | CONFIRMED | 한 공격 효과에 같은 즉시 위치 효과가 여러 번 결합되면 콘텐츠가 선언한 집계 방식에 따라 값을 합치거나 별도 효과 순서로 유지한다. 선언 누락은 검증 오류다. | `STACK-C` |
| STACK-18 | CONFIRMED | 고유 기술에 내장된 `[필중]`과 예약 상태가 부여하는 `[필중]` 충전을 구분한다. 내장 필중은 충전을 소비하지 않고, 예약 필중만 공격 효과 시작 시 1충전을 소비한다. | `STACK-C` |

---

# 9. 자동 발동 체인

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| AUTO-01 | CONFIRMED | 자동 발동은 깊이 우선으로 즉시 처리한다. | `AUTO-C` |
| AUTO-02 | CONFIRMED | 각 효과 뒤 상태를 갱신한 다음 후속 자동 발동을 검사한다. | `AUTO-C` |
| AUTO-03 | CONFIRMED | 동일 효과 인스턴스는 하나의 루트 체인에서 한 번만 발동한다. | `AUTO-C` |
| AUTO-04 | CONFIRMED | 다른 효과 인스턴스의 연쇄 발동은 허용한다. | `AUTO-C` |
| AUTO-05 | CONFIRMED | 반복 인스턴스는 건너뛰고 로그에 기록한다. | `AUTO-C` |
| AUTO-06 | CONFIRMED | 루프 가드는 조건·비용·사용 횟수 검사 전에 적용하며 가드로 건너뛴 효과는 아무것도 소비하지 않는다. | `AUTO-C` |
| AUTO-07 | CONFIRMED | 플레이어에게 보이는 게임플레이 체인 제한은 두지 않는다. | `AUTO-C` |
| AUTO-08 | CONFIRMED | 기술 안전 한도는 중첩 깊이 32, 루트 체인 활성화 128이다. | `AUTO-C` |
| AUTO-09 | CONFIRMED | 안전 한도 초과 시 남은 체인을 중단하고 완료 결과를 보존하며 런타임 오류와 콘텐츠 검증 실패를 기록한다. | `AUTO-C` |
| AUTO-10 | CONFIRMED | 통상 1~6회 연쇄를 목표로 하고 8회 초과는 리뷰 경고 대상으로 삼는다. | `AUTO-C` |
| AUTO-11 | CONFIRMED | 원자 효과 해결 뒤 상태와 로그를 갱신하고 체력 0의 즉시 종료를 먼저 판정한 다음, 전투가 계속될 때만 일반 자동 발동 체인을 처리한다. | `AUTO-C` |
| AUTO-12 | CONFIRMED | 완료된 효과가 만든 자동 발동은 원효과가 이후 중단을 일으켰더라도 보존되며 깊이 우선으로 처리한다. 다만 원행동의 미해결 후속 효과는 이미 취소된 상태다. | `AUTO-C` |
| AUTO-13 | CONFIRMED | `[연격]` 피해 묶음은 기본 자동 발동 범위를 늘리지 않는다. 일반 트리거는 공격 효과당 한 번이며, 피해 묶음마다 발동하려면 `PER_DAMAGE_PACKET`을 명시하고 별도 예산을 사용한다. | `AUTO-C` |

---

# 10. 기초 행동 10종

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| BASIC-01 | CONFIRMED | `이동`은 기초 행동이다. | `BASIC-C` |
| BASIC-02 | CONFIRMED | `보법`은 기초 행동이다. | `BASIC-C` |
| BASIC-03 | CONFIRMED | `막기`는 기초 행동이다. | `BASIC-C` |
| BASIC-04 | CONFIRMED | `회피`는 기초 행동이다. | `BASIC-C` |
| BASIC-05 | CONFIRMED | `속공`은 기초 행동이다. | `BASIC-C` |
| BASIC-06 | CONFIRMED | `강공`은 기초 행동이다. | `BASIC-C` |
| BASIC-07 | CONFIRMED | `격공`은 기초 행동이다. | `BASIC-C` |
| BASIC-08 | CONFIRMED | `명상`은 기초 행동이다. | `BASIC-C` |
| BASIC-09 | CONFIRMED | `준비`는 기초 행동이다. | `BASIC-C` |
| BASIC-10 | CONFIRMED | `관찰`은 기초 행동이다. | `BASIC-C` |
| BASIC-11 | REJECTED | `밀치기`를 독립 기초 행동으로 두지 않는다. | `BASIC-R` |
| BASIC-12 | REJECTED | `추격`을 독립 기초 행동으로 두지 않는다. | `BASIC-R` |
| BASIC-13 | CONFIRMED | `[격공]`: 1슬롯, 내력 1, 사거리 1~3, 낮은 위력, 일반 공격 단계, 속공보다 낮은 합 위력이며 적중해도 기본 행동 중단을 유발하지 않는다. | `BASIC-C` |
| BASIC-14 | DEFERRED | 기초 행동의 최종 피해·방어·회복 수치는 전체 기술 예산표 이후 확정한다. | `BASIC-D` |
| BASIC-15 | CONFIRMED | 기초 행동 이름은 `준비`다. `강화`는 무공서 핵심 유형이며 범용 전투 상태명이 아니다. | `BASIC-C` |
| BASIC-16 | LATEST_OVERRIDE | 범용 `[준비]` 또는 `[강화]` 상태 태그를 사용하지 않고, 준비 행동의 실제 결과를 콘텐츠가 선언한 `다음 공격`, `다음 공격 행동`, `[강건]` 충전 등 구체적인 예약 효과 인스턴스로 기록한다. | `BASIC-L` |

---

# 11. 관찰·정보 공개

| ID | 상태 | 결정 | 연결 프로필 |
|---|---|---|---|
| OBS-01 | CONFIRMED | 거짓 정보는 제공하지 않는다. | `OBS-C` |
| OBS-02 | CONFIRMED | 관찰과 정보 결과는 결정론적이며 저장 불러오기로 재굴림하지 않는다. | `OBS-C` |
| OBS-03 | CONFIRMED | 적 행동 묶음 전체의 정확한 기술을 공개하지 않는다. | `OBS-C` |
| OBS-04 | CONFIRMED | 기본 `[관찰 1]`은 1슬롯을 사용해 다음 적 묶음의 첫 슬롯 주 행동 범주를 공개한다. | `OBS-C` |
| OBS-05 | CONFIRMED | 무공 기술은 `[관찰 2]` 또는 `[관찰 3]`을 자체 보유할 수 있다. | `OBS-C` |
| OBS-06 | CONFIRMED | `[관찰 N]`은 다음 묶음 앞 N개 슬롯의 주 행동 범주만 공개한다. | `OBS-C` |
| OBS-07 | CONFIRMED | 네 번째 슬롯은 관찰로 공개하지 않는다. | `OBS-C` |
| OBS-08 | CONFIRMED | 정확한 기술명·피해·비용·사거리·방향·태그·효과를 공개하지 않는다. | `OBS-C` |
| OBS-09 | CONFIRMED | 같은 대상 묶음에 여러 관찰이 적용되면 최고 등급 하나만 사용한다. | `OBS-C` |
| OBS-10 | CONFIRMED | 관찰 등급은 전역 능력치로 합산하지 않는다. | `OBS-C` |
| OBS-11 | CONFIRMED | 관찰 기술은 다른 효과와 결합할 수 있고 등급별 고정 최소 비용은 두지 않는다. | `OBS-C` |
| OBS-12 | CONFIRMED | 모든 행동은 여러 효과를 명시된 순서로 조합할 수 있다. | `OBS-C` |
| OBS-13 | CONFIRMED | 각 행동에는 디자이너가 주 행동 범주 하나를 명시한다. | `OBS-C` |
| OBS-14 | CONFIRMED | 관찰은 주 행동 범주만 공개하며 검증기는 효과 내용과 범주 불일치를 경고한다. | `OBS-C` |

---
