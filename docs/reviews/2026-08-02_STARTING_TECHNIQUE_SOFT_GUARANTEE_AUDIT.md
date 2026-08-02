# 시작 기술 소프트 보장 후속 감사

- Audit ID: `TEN-AUD-031`
- 감사일: 2026-08-02
- 기준 PR: `#80`
- 관련 Decision: `TEN-DEC-20260802-STARTING-TECHNIQUE-SOFT-GUARANTEE-01`
- 상태: `RESOLVED_IN_PLANNING_RUNTIME_NOT_STARTED`

## 1. 감사 대상

`TEN-AUD-030`의 P1-2 시작 선택 숨은 잠금 위험을 후속 검토한다.

위험:

- 시작 무공 4개를 선택해도 주 능력치4 미달 기술이 잠길 수 있음
- 선택 전에 잠금 원인과 결과를 알 수 없으면 기만적인 선택이 됨
- 모든 기술 활성화를 강제하면 전문화 자유도가 사라짐

## 2. 승인된 해결

소프트 보장 정책을 적용한다.

- 모든 시작 무공 4개 조합에서 네 첫 기술을 동시에 활성화할 수 있는 배분이 존재함
- `[추천 배분]`은 최소 해금 기준선만 제공함
- 네 기술 동시 활성은 확정 조건이 아님
- 일부 기술 잠금 전문화는 경고 후 허용함
- 최종 예상 능력치·활성/잠금 상태·부족 수치·남은 점수를 확정 전에 표시함
- 자유 분배와 무공 선택을 확정 전 재조정할 수 있음

## 3. 적대적 검증

### 수학적 가능성

- 신법 무공 2개 + 다른 무공 2개: 최소 자유점 2
- 신법 무공 1개 + 다른 무공 3개: 최소 자유점 4
- 신법 무공 없이 다른 무공 4개: 최소 자유점 4
- 사용 가능한 자유점: 6

모든 조합에서 네 기술 활성 배분이 가능하며 남는 전문화점은 2~4다.

### 자유도 보존

- 자동 최적 빌드를 제공하지 않음
- 추가 무료 능력치를 지급하지 않음
- 잠긴 기술을 허용해 극단 전문화를 보존함
- 추천 배분을 `최소 기술 활성 기준`으로 표시함

### 남은 위험

- 유운검결·무영십보 동시 선택의 신법 투자 효율
- 추천 배분이 사실상 정답으로 받아들여질 가능성
- 정확한 화면 배치와 조작 순서

위 항목은 사람 검증과 후속 UX 설계에서 확인하며 현재 기획 승인을 차단하지 않는다.

## 4. 판정

```yaml
audit_id: TEN-AUD-031
source_finding: TEN-AUD-030_P1-2
planning_risk_status: RESOLVED_BY_SOFT_GUARANTEE
runtime_status: NOT_STARTED
all_combinations_activatable: true
activation_required: false
preconfirm_disclosure_required: true
locked_specialization_allowed: true
remaining_p1_merge_blockers_from_ten_aud_030: 5
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
```
