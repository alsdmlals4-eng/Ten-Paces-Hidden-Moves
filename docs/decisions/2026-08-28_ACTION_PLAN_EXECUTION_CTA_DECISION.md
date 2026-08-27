# TEN-DEC-20260828-ACTION-PLAN-EXECUTION-CTA-01

- Status: `USER_APPROVED_CANONICALIZATION`
- Issue: `#247`
- Baseline: `ffa2778e0fd41c0487adf44db93c532c8d1b45f9`

## 결정

플레이어가 현재 묶음의 배치를 마친 뒤 누르는 Primary CTA의 표기는 **`행동계획 실행`**이다.

이 CTA는 단순한 화면 진행이나 별도 확인 단계가 아니다. 유효한 현재 묶음을 한 번에 commit하고, 편집 계획 화면에서 전투·해결 애니메이션 화면으로 전환하는 경계다. 실행을 누른 뒤 해당 묶음은 편집 화면으로 되돌아가지 않으며, 결과는 이후 Review에서 인과로 설명한다.

## 보호하는 슬롯 규칙

- `3수`는 **3슬롯**이다. 첫 두 묶음은 각각 3슬롯, 마지막 묶음은 4슬롯이다.
- 2슬롯 행동은 첫 슬롯 `[전조]`, 둘째 슬롯 `[실행]`으로 **전조 → 행동**의 두 슬롯을 모두 소비한다.
- 3슬롯 행동은 앞 두 슬롯 `[전조]`, 마지막 슬롯 `[실행]`이다.
- 전조는 별도 강화 행동이 아니라 연결된 행동 인스턴스의 점유·표시 단계다. 중단·비용·취소 규칙은 `docs/02_COMBAT_RULES.md`가 소유한다.

## Player experience

플레이어는 계획 화면에서 카드와 대상을 충분히 검토·배치한 뒤, `행동계획 실행`을 눌러 자기 판단을 결과에 걸어야 한다. 이어지는 전투·해결 애니메이션은 “무슨 일이 일어났는가”를 보여주고, Review는 “왜 그렇게 되었는가”를 설명한다.

따라서 UI는 실행 전에는 편집 가능 상태와 부족한 슬롯·대상·자원을 명확히 보이고, 실행 직후에는 같은 버튼을 반복해서 누르게 하지 않으며 전투·해결 상태를 명확히 보여야 한다.

## 범위와 제외

- 범위: 현재 묶음 Primary CTA의 문구와 전환 의미, 3/3/4 슬롯 표현, 다중 슬롯 행동의 시각적 설명.
- 제외: 전투 수치, AI 규칙, 시작 거리, 카드 수, asset 교체, Android UI, 새 production asset 생성.
- 현재 POC의 `진행` 표기와 현재 화면 전환 구현은 이 Decision만으로 변경되지 않는다. 별도 `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF`에서 copy와 계획→전투·해결 전환을 함께 구현·검증한다.

## 검증 경계

- repository 정본과 structured visual handoff의 semantic CTA 일치: automated contract test.
- Windows visible·Human readability·전투 애니메이션 전환 만족도: `NOT_RUN`.
- Android 실기기·접근성 사용자·게임패드: `NOT_RUN`.
