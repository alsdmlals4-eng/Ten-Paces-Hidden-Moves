# 전투 규칙 개정 — 7성·9성 무공 숙련 보너스

- Decision: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`
- 부모 규칙: `docs/02_COMBAT_RULES.md`
- 예산 원본: `approved_20260804_existing_action_reprice_contract.json`
- 구현 권한: `PLANNING_ONLY`

## 적용 우선순위

이 개정은 7성·9성 숙련 예산과 9성 작성 복잡도에 한해 기존 성장 가설의 “9성 공개 정보 자동 분기” 표현을 대체한다. 기존 거리·슬롯·자원·조건·중단·고정 이동 규칙은 유지한다.

## 7성

```text
star7_final_budget_ticks
= effective_technique2_available_budget_ticks + 10
```

- `effective_technique2_available_budget_ticks`는 현행 repricing overlay에서 읽는다.
- +10틱은 높은 무공 이해도를 나타내는 숙련 예산이다.
- 실제 효과 배분은 별도 Decision 전까지 미승인이다.
- 기술2는 기술1과 동일 역할을 수행하거나 기술1을 전 상황에서 대체하면 안 된다.

## 9성

```text
star9_bonus_ticks
= 10 + floor(star7_final_budget_ticks × 0.20)
```

- 완성 보너스 효과는 기술2당 정확히 하나다.
- 상황별 분기·추가 선택·추가 비용·복수 보너스는 없다.
- 카드 설명은 한 문장으로 작성한다.
- 기술2의 기존 역할을 완성하되 역할 자체를 바꾸지 않는다.
- 기술1 역할을 복제하지 않는다.
- 개별 효과는 별도 GrillMe Decision 전까지 미승인이다.

## 금지

- 역사 기술2 계약의 구형 예산을 현행 repricing보다 우선 사용.
- 20% 항의 반올림 또는 올림.
- 하나의 9성 기술에 여러 상황별 효과를 병기.
- 공개 상태별 우선순위 분기.
- 해결 중 플레이어가 강화 방향을 선택.
- 숙련 보너스로 거리·순서·합·회피·중단의 실패를 무조건 삭제.
- 별도 승인 없이 기존 7성 효과를 +10틱만큼 자동 증액.

## 검증 경계

제품 코드·Scene·런타임 데이터는 변경하지 않는다. 자동 검증은 설계 계약의 무결성만 증명하며 사람 체감·밸런스를 증명하지 않는다.
