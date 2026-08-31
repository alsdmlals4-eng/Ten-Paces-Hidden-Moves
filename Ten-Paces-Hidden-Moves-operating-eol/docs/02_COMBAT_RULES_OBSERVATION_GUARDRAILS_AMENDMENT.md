# 전투 규칙 관찰 가드레일 개정

- Decision ID: `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`
- 상태: `CURRENT_APPROVED_PLANNING_GOVERNANCE`
- 적용 대상: `docs/02_COMBAT_RULES.md`의 `[관찰]`·적 계획 잠금·공개 순서
- 제품 구현: `NOT_STARTED`

## 1. 기존 규칙 유지

본 개정은 관찰 효과를 변경하지 않는다.

```text
[관찰] 1수
→ 관찰량 1 획득
→ 적 현재 묶음 잠금
→ 관찰량 1당 앞 슬롯의 실제 행동 종류 1개 공개
```

- 행동 종류 직접 공개를 유지한다.
- 복합 기술은 실제 구성 종류를 모두 표시한다.
- 저장·획득 상한 없음과 묶음·라운드 이월을 유지한다.
- 기술명·무공서명·정확한 비용·방향·거리·피해·사거리·대상·AI 가중치는 공개하지 않는다.
- 기력·내력 비용은 새로 추가하지 않는다.

## 2. 해결 순서 명시

```text
직전 묶음 종료 상태·회복 정산
→ 적이 현재 공개 상태로 현재 묶음 계획 생성
→ 적 계획 잠금
→ 저장 관찰량을 앞 수부터 소비
→ 잠긴 실제 행동 종류 공개
→ 플레이어 계획·확정
→ 묶음 해결
```

- 공개 뒤 적 계획 교체를 금지한다.
- 플레이어 미확정 계획 참조를 금지한다.
- 미래 묶음을 관찰 때문에 미리 생성하지 않는다.

## 3. 정답 유출 판정 경계

다음은 허용한다.

- 관찰과 비무 전 조사 결과를 플레이어가 직접 결합해 정확한 기술을 추론.
- 관찰량이 묶음 길이 이상이면 현재 잠금 묶음의 모든 행동 종류 공개.

다음은 금지한다.

- UI가 정확한 기술명을 자동 확정해 표시.
- UI가 권장 정답 대응을 생성.
- AI 가중치·선호 행동을 공개.
- 공개 결과를 본 적 AI가 계획을 재작성.

## 4. 측정

제품 구현 뒤 다음을 기록한다.

- `observation_use_rate`
- `observation_points_spent_per_bundle`
- `full_bundle_reveal_rate`
- `exact_technique_inference_rate`
- `observation_assisted_correct_counter_rate`
- `non_observation_correct_counter_rate`
- `observation_assisted_grade_uplift`
- `non_observation_win_rate`

유효 관찰 묶음 30개 전에는 밸런스 결론을 확정하지 않는다. 경고값은 수동 재검토만 열며 자동 공개량 감소·비용 증가·가격 변경으로 이어지지 않는다.
