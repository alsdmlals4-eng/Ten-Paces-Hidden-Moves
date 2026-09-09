# 내부 전체 검토를 2회로 변경

```yaml
decision_id: TEN-DEC-20260909-TWO-ROUND-INTERNAL-REVIEW-01
status: USER_APPROVED
approved_at: 2026-09-09
scope: PROJECT_INTERNAL_REVIEW_CADENCE
```

사용자 최신 지시: “내부검토 이제 5회가 아니라 2회로 줄일거야”.

- material 작업은 동일 승인 작업의 최종 후보 계보에서 정확히 2회 전체 검토한다. 단순 작업의 기존 최소 1회 확인은 유지한다.
- 1회차와 2회차 모두 전체 승인 범위·정본·실제 변경·untouched consumer·검증·비용·장기 적합성을 본다. 관점 하나를 한 회로 세지 않는다.
- 단계·세션·커밋·병합 전후로 횟수를 초기화하지 않는다. 이미 같은 범위에서 수행한 유효 회차를 다시 채우지 않는다.
- 2회 후 발견한 문제는 결함별 교정·영향 회귀검증·readback으로 처리한다. 자동 세 번째 전체 검토를 하지 않는다.
- 2회 수행 자체는 PASS가 아니다. 미해결 MUST_FIX·안전·승인·acceptance blocker가 남으면 완료·병합하지 않는다. CI·exact-head·독립 승인·postmerge readback은 유지한다.

책임 원본은 AGENTS.md와 프로젝트 통합 작업 계약이다. 2026-08-28 연구/적대 검토 Decision의 **회차 수만** 대체하며 조사·구현 가능성·가짜 finding 금지·evidence ceiling은 유지한다. 과거 수행 기록, 승인 원문, receipt/hash와 historical planning snapshot은 소급 편집하지 않는다.

최신 Base main `580a362db07b4b1a91a87300402969793784acff`에서 `docs/operations/FULL_ADVERSARIAL_REVIEW_LOOP_POLICY.md`의 정확히 2회와 자동 세 번째 금지를 직접 확인했다. 이번 사용자 지시로 프로젝트의 횟수 드리프트를 교정한다. Base adoption/version lock을 교체하지 않으며 Base 파일의 추가 변경은 필요하지 않다.

`CURRENT_SOURCE_RELEVANCE_CHECK: NOT_APPLICABLE` — 횟수는 사용자 운영 선택이며 외부 연구로 최적 횟수를 주장하지 않는다. 게임 기능·시각·시스템 기획이 아닌 회차 지시 교정이므로 10게임 비교를 억지로 생성하지 않는다.
