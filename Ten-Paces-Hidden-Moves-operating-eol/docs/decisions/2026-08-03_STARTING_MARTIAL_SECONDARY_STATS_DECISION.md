# 시작 무공 6종 주·보조 능력치 매핑 결정

- Decision ID: `TEN-DEC-20260803-STARTING-MARTIAL-SECONDARY-STATS-01`
- 승인일: 2026-08-03
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `2/10`
- 선행 결정:
  - `TEN-DEC-20260802-STARTING-STAT-TOTAL20-MANUAL-BONUS-01`
  - `TEN-DEC-20260802-EVEN-STAR-STAT-ESCALATION-01`
  - `TEN-DEC-20260803-UNCAPPED-CORE-STATS-01`
  - `TEN-DEC-20260803-STAR7-TECHNIQUE-PRIMARY-STAT8-01`
  - `TEN-DEC-20260803-STAR10-ULTIMATE-PRIMARY-STAT12-01`

## 1. 승인 결론

시작 후보 무공 6종의 고정 주·보조 영구 능력치 벡터를 다음과 같이 확정한다.

| 무공 ID | 무공 | 주 능력치 | 보조 능력치 | 정체성 연결 |
|---|---|---|---|---|
| `flowing_cloud_sword` | 유운검결 | 신법 | 외공 | 이동·연격 속도와 실제 타격력 |
| `diamond_body_art` | 금강호체공 | 근골 | 내공 | 육체 방어와 내력 기반 호신 |
| `taiji_flowing_sword` | 태극유전검 | 심안 | 내공 | 간파·반격과 힘을 흘리는 내가 운용 |
| `chasing_wind_spear` | 추풍창법 | 외공 | 신법 | 창의 위력·사거리와 위치 조정 |
| `clear_heart_nourishing_art` | 청심양생공 | 내공 | 근골 | 내력·회복과 생존 기반 |
| `shadowless_ten_steps` | 무영십보 | 신법 | 심안 | 이동·회피와 상대 수 읽기 |

영문 enum은 다음을 사용한다.

```yaml
외공: EXTERNAL
근골: CONSTITUTION
신법: MOVEMENT
내공: INTERNAL
심안: INSIGHT
```

## 2. 짝수 성 지급과의 연결

`TEN-DEC-20260802-EVEN-STAR-STAT-ESCALATION-01`의 지급량은 위 벡터에 적용한다.

| 성취 | 해당 성에서 새로 지급 |
|---:|---|
| 2성 | 주 +1 |
| 4성 | 주 +1, 보조 +1 |
| 6성 | 주 +2, 보조 +1 |
| 8성 | 주 +3, 보조 +2 |

따라서 무공 하나를 8성까지 성장시키면 해당 무공의 총 기여는 `주 +7·보조 +4`다.

- 시작 무공은 3성으로 선택되므로 시작 시에는 2성의 주 +1만 적용한다.
- 보조 능력치는 4성 최초 도달 전에는 지급되지 않는다.
- 보너스는 무공·성취·회차별 최초 1회만 지급한다.
- 중복 습득·저장 재로드·지정 수련 변환으로 다시 지급하지 않는다.

## 3. 전체 분포

주·보조 역할 연결 횟수는 다음과 같다.

| 능력치 | 주 연결 수 | 보조 연결 수 | 총 연결 수 |
|---|---:|---:|---:|
| 외공 | 1 | 1 | 2 |
| 근골 | 1 | 1 | 2 |
| 신법 | 2 | 1 | 3 |
| 내공 | 1 | 2 | 3 |
| 심안 | 1 | 1 | 2 |

여섯 무공을 모두 8성까지 성장시켰을 때 무공 보너스만의 합은 다음과 같다.

| 능력치 | 총 보너스 |
|---|---:|
| 외공 | +11 |
| 근골 | +11 |
| 신법 | +18 |
| 내공 | +15 |
| 심안 | +11 |

총합은 `66`이며, 무공 6종 × 무공당 11점과 일치한다.

신법은 두 무공의 주 능력치이므로 가장 높은 집중 경로를 유지한다. 대신 태극유전검의 보조를 신법이 아닌 내공으로 두어 신법이 연격·창술·반격·경공을 모두 연결하는 범용 최적 능력치가 되는 위험을 줄인다.

## 4. 기술 작성 경계

이번 매핑은 다음을 확정한다.

- 무공별 짝수 성 고정 영구 능력치 지급 방향
- 무공 카드와 성장 화면에 표시할 주·보조 능력치 정체성
- 향후 5·9성 임계 효과와 기술 작성에서 우선 검토할 능력치 범위

다음을 자동으로 뜻하지 않는다.

- 모든 기술이 주·보조 능력치를 동시에 피해 배수로 사용함
- 보조 능력치가 3·7·10성 기술 해금 요구치가 됨
- 보조 능력치가 기술의 구조적 값에 점당 연속 적용됨
- 별도 ledger 없이 보조 능력치 효과를 무료로 추가함

개별 기술은 기존 기술 작성 계약에 따라 주 능력치 1종을 필수로 사용하고, 보조 능력치 사용 여부·배수·임계 효과는 기술별 예산과 별도 승인으로 결정한다.

## 5. 적대적 검토·벤치마킹 판정

검토한 세 방향:

1. **정체성 우선·분포 보정형**: 기능적으로 자연스러운 벡터를 사용하면서 신법 과집중을 태극유전검의 `심안+내공`으로 완화한다.
2. **행동 역할 직결형**: 태극유전검을 `심안+신법`으로 두지만 신법이 4개 무공과 연결되어 범용 최적 능력치가 될 위험이 크다.
3. **수치 균형 우선형**: 능력치 출현 수부터 맞추지만 무공 정체성과 플레이어 설명 가능성이 약해진다.

프로젝트에는 첫 번째 원칙을 채택한다.

- 무공의 이름·기능·전투 역할과 능력치 연결이 설명 가능해야 한다.
- 모든 능력치는 최소 두 무공과 연결되어 버림 능력치 위험을 낮춘다.
- 동일 연결 횟수 자체를 목표로 삼아 정체성을 왜곡하지 않는다.
- 주·보조 벡터와 실제 기술 배수는 분리해 밸런스 조정 가능성을 유지한다.

## 6. 후속 범위

이번 Decision으로 `manual_secondary_stat_mapping` 미결정을 해소한다.

남은 후속:

1. 중간 노드 영구 능력치 보상 여부·지급량
2. 무공별 3·7성 기술과 5·9성 패치의 실제 주·보조 배수·임계값
3. 무공별 10성 절초 효과·예산
4. 신법·내공 중첩 경로와 분산 빌드의 사람 검증
5. 현재 합법 최대 능력치 재계산

## 7. 구현·검증 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
implementation_status: NOT_STARTED
manual_mapping:
  flowing_cloud_sword: {primary: MOVEMENT, secondary: EXTERNAL}
  diamond_body_art: {primary: CONSTITUTION, secondary: INTERNAL}
  taiji_flowing_sword: {primary: INSIGHT, secondary: INTERNAL}
  chasing_wind_spear: {primary: EXTERNAL, secondary: MOVEMENT}
  clear_heart_nourishing_art: {primary: INTERNAL, secondary: CONSTITUTION}
  shadowless_ten_steps: {primary: MOVEMENT, secondary: INSIGHT}
secondary_is_unlock_requirement: false
secondary_auto_scales_every_technique: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 2/10
```
