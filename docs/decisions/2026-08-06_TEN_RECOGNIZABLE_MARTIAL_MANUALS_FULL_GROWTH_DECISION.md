# TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01

## 상태

```yaml
decision_status: APPROVED_DRAFT_PLANNING
approval_batch: 9/10
implementation_authority: PLANNING_ONLY
product_runtime_changed: false
human_balance_validation: NOT_RUN
```

## 결정

초기 무공서 범위를 기존 6권에서 10권으로 확장하고, 모든 무공서에 문파·주능력치·보조능력치·3성 기술1·5성 추가 효과·7성 기술2·9성 단일 완성 효과·10성 절초를 부여한다.

능력치별 무공서 권수, 균등 분포, 최소·최대 쿼터는 설계 규칙으로 사용하지 않는다. 각 능력치는 해당 문파, 무학 철학, 실제 동작, 피해 방식과의 적합성으로 결정한다.

## 초기 10권

| 문파·유파 | 무공서 | 주 / 보조 | 10성 절초 |
|---|---|---|---|
| 화산파 | 매화검결 | 신법 / 외공 | 이십사수매화검법 |
| 소림사 | 나한금강공 | 외공 / 내공 | 여래신장 |
| 무당파 | 태극검결 | 심안 / 내공 | 태극혜검 |
| 양가 | 양가창결 | 외공 / 신법 | 회마창 |
| 화산파 | 자하심법 | 내공 / 근골 | 자하신공 |
| 소요파 | 소요보결 | 신법 / 심안 | 능파미보 |
| 개방 | 강룡장결 | 내공 / 근골 | 항룡십팔장 |
| 사천당문 | 천기암기록 | 심안 / 신법 | 만천화우 |
| 하북팽가 | 팽가도결 | 근골 / 외공 | 오호단문도 |
| 남궁세가 | 창궁무애검법 | 내공 / 심안 | 제왕검형 |

## 능력치 결정

- 소림 나한금강공은 단련된 육체와 근접 장격이 핵심이므로 외공이 주능력치다. 내공은 호체강기와 충격 전환을 보조한다.
- 개방 강룡장결은 중후한 양강 내력을 장력으로 방출하므로 내공이 주능력치다. 근골은 장세 유지·밀치기·잔여 여력을 보조한다.
- 방출형 장력·장풍·검강은 기본적으로 내공을 우선한다.
- 근접 장격·권격·도격·창격은 기본적으로 외공을 우선한다.
- 예외는 무공서별 무학과 해결 순서로 설명한다.

## 특수 규칙

### 자하신공

- 전투당 1회.
- 첫 전조가 실행되는 순간 사용권 소모.
- 중단·전투불능 시 사용권 환불 없음.
- 실행 완료 시에만 절초기세 1 회복.
- 전투 중 사용권 재충전·초기화 금지.

### 나한금강공

- 금강공 계열 공격과 전조는 핵심 동작보다 먼저 `[강건]`을 얻는다.
- 현행 `[강건]` 중단 방지 규칙만 사용한다.
- 무적·피해 무시·전투불능 방지·절대 중단 면역으로 확장하지 않는다.

## 성장 규칙

```text
3성: 기술1 기본 운용
5성: 기술1 역할을 강화하는 추가 효과
7성: 같은 무학의 다른 전술 응용
9성: 기술2의 단일 무분기 완성 효과
10성: 문파와 무공서를 대표하는 절초
```

7성의 `+10틱`은 별도 숙련 패시브가 아니라 기술2 최종 예산에 통합한다.

## 예산 권위

- 기존 6권 기술2: 현행 승인 예산을 별칭으로 보존하고 `+10틱` 통합.
- 신규 4권 기술2: 새 계획 프로필로 가격 산정.
- 10개 절초: 3슬롯 중심 계획 프로필과 명시적 수치 필드 사용.
- 최종 편차 허용 범위: `±5틱`.

```text
available_budget_ticks
= slot_budget
+ stamina_cost × 4
+ internal_cost × 7
+ condition_allowance_ticks
+ other_resource_allowance_ticks
```

## 권위 파일

- `docs/planning-data/approved_20260806_ten_recognizable_martial_manuals_contract.json`
- `docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json`
- `docs/superpowers/specs/2026-08-06-ten-recognizable-martial-manuals-full-growth-design.md`
- `docs/superpowers/specs/2026-08-06-shaolin-beggars-primary-stat-authority-amendment.md`

## 대체 경계

이 Decision은 초기 무공서의 현재 이름·문파·능력치·3/5/7/9/10성 성장 방향을 우선한다. 이전 6권의 이름과 효과 계약은 예산·계보 추적을 위한 역사 증거로 유지하며 현재 표시명으로 사용하지 않는다.

## 구현 경계

- 제품 코드·Godot Scene·HTML PoC·런타임 데이터 변경 없음.
- 사람·밸런스·Windows·접근성·성능 검증 `NOT_RUN`.
- PR #92는 Draft·stacked 상태를 유지하며 PR #91보다 먼저 독립 병합하지 않는다.
- 런타임 구현은 별도 `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE` 승인 뒤 진행한다.
