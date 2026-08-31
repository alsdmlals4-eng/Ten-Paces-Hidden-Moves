# [대체됨] 최대 사거리 구간 가격 결정

- Decision ID: `TEN-DEC-20260802-RANGE-PRICE-BANDS-01`
- 승인일: 2026-08-02
- 상태: `SUPERSEDED`
- 생명주기 표시: `[대체됨]`
- 구현 권한: `HISTORICAL_LEDGER_EVIDENCE_ONLY`
- 대체 Decision: `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01`
- 현재 거리 권위: `docs/planning-data/approved_20260804_combat_pricing_interruption_recovery_contract.json`

> 이 파일은 신규·수정 기술의 가격 근거가 아니다. 현재 이동·공격 사거리 가격은 1칸당 15틱이며, 이 문서의 값은 과거 승인 ledger 재현과 migration 비교에만 사용한다.

## 과거 가격 스냅샷

| 최대 사거리 | 과거 총비용 |
|---:|---:|
| 1 | 0틱 |
| 2 | 10틱 |
| 3 | 25틱 |
| 4 | 40틱 |

과거 내부 스냅샷에는 `range_per_tile_beyond_one: 4`, `movement_per_tile: 6`이 남아 있을 수 있다. 이는 `LEGACY_APPROVED_TECHNIQUE_LEDGER_SNAPSHOT`이며 신규 작성 가격이 아니다.

## 현재 가격

```text
공격 최대사거리 가격 = max(0, 최대사거리 - 1) × 15틱
이동 가격 = 이동 칸 × 15틱
```

| 거리·이동 | 현재 가격 |
|---:|---:|
| 사거리1 | 0틱 |
| 사거리2 / 이동1 | 15틱 |
| 사거리3 / 이동2 | 30틱 |
| 사거리4 / 이동3 | 45틱 |

## 허용·금지

허용:

- 과거 기술 ledger 재현.
- before/after 가격 감사.
- migration 회귀 테스트.

금지:

- 신규·수정 기술 가격 계산.
- 제품 카드·런타임 데이터의 현재 비용 근거.
- `CURRENT_APPROVED_PLANNING`으로 표시.

```yaml
authority_status: SUPERSEDED
lifecycle_label_ko: "[대체됨]"
superseded_by: TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01
allowed_use: HISTORICAL_LEDGER_REPRODUCTION_ONLY
current_distance_ticks_per_tile: 15
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
```
