# REPEAT_POC 요구사항 추적·수용 매트릭스

| 요구사항 | 책임 원본 | 구현 경로 | 자동 검증 | 사람 검증 | 완료 상태 |
|---|---|---|---|---|---|
| 최신 기준 SHA | docs/02·05·08·09 | 문서 header | Governance | 해당 없음 | NOT_STARTED |
| 단일 public_state_ai source | docs/02·09 | board/resolution data | Governance | 공정성 신뢰 | NOT_STARTED |
| 복수 합리 후보·seed 재현 | Goal·AI architecture | rival data·AI planner | AI verifier | 성향 발견 | NOT_STARTED |
| private plan 차단 | docs/02·09 | public snapshot whitelist | AI verifier | 공정성 신뢰 | NOT_STARTED |
| 플레이어 가설 기록 | Goal·UI spec | hypothesis data·panel | hypothesis verifier | 가설이 계획에 영향 | NOT_STARTED |
| 미기록 가설 추정 금지 | Goal·review contract | summary builder | summary fixture | 문구 이해 | NOT_STARTED |
| 결정적 cause code | combat rules·QA | summary builder | 합·방어·회피·필중·중단 fixture | 원인 설명 | NOT_STARTED |
| 판정 재계산 금지 | architecture·UI spec | review panel | engine result 불변 | 결과 신뢰 | NOT_STARTED |
| 키보드·모션 감소 | UI spec | panel·focus | UI verifier | 실제 사용자 | NOT_STARTED |
| 동일 SHA STEP 14 | protocol | research records | SHA check | 참가자 5명 | NOT_RUN |
| T1 진입 판정 | Development Gates | 상태 문서 | Governance | 사전 고정 신호 | NOT_GRANTED |

## 상태 규칙

- 코드·파일 존재만으로 `PASS`를 사용하지 않는다.
- 자동 검증과 사람 검증을 서로 대체하지 않는다.
- `NOT_STARTED`, `IN_PROGRESS`, `IMPLEMENTED`, `PASS`, `PARTIAL`, `FAIL`, `BLOCKED`, `NOT_RUN`, `UNVERIFIED`를 구분한다.
- 사람 STEP 14 전에는 마지막 두 행을 완료로 바꾸지 않는다.
