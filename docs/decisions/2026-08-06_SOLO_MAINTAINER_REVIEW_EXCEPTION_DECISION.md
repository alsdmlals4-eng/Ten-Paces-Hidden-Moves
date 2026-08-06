# Solo-maintainer 리뷰 예외 결정

- Decision ID: `TEN-DEC-20260806-SOLO-MAINTAINER-REVIEW-EXCEPTION-01`
- 승인일시: 2026-08-06 23:37 KST
- 상태: `CURRENT_APPROVED_PROJECT_OPERATING_EXCEPTION`
- 적용 범위: `PROJECT_WIDE_WHILE_SOLO_MAINTAINED`
- 계약: `docs/planning-data/approved_20260806_solo_maintainer_review_exception.json`

## 1. 승인 결정

이 저장소가 실제로 단독 유지되는 동안 다른 GitHub 사용자의 독립 `APPROVE`를 병합 필수조건에서 제외한다. 이 예외는 PR #104뿐 아니라 향후 이 프로젝트 PR에도 적용한다.

```yaml
independent_review: WAIVED_WHILE_ACTIVATION_CONDITION_TRUE
review_record: SOLO_MAINTAINER_REVIEW_ATTESTATION
fake_independent_approval: NO_FAKE_INDEPENDENT_APPROVE
```

작성자 자신의 검토를 독립 승인이라고 표시하지 않는다. 독립 검토가 없는 사실과 solo-maintainer 예외 사용 사실을 PR에 명시한다.

## 2. Base 충돌과 해석

현재 Base는 병합 전 독립 검토를 요구한다. 최신 사용자 지시는 이 프로젝트의 단독 유지 현실에 대한 명시적 예외로 우선 적용한다.

- Base 저장소와 Base 공용 규칙은 변경하지 않는다.
- Base 독립 검토 규칙이 모든 프로젝트에서 폐기됐다고 주장하지 않는다.
- 이 저장소의 프로젝트 전용 운영 예외로만 기록한다.
- 추가 maintainer 또는 유효 reviewer가 생기면 예외를 자동 중지하고 일반 독립 검토 경로로 복귀한다.

## 3. 대체할 수 없는 필수 통제

독립 리뷰만 면제하며 다음은 면제하지 않는다.

```text
FRESH_BASE_GITHUB_SHEET_READBACK
AND EXACT_HEAD_VERIFICATION
AND ALL_REQUIRED_CHECKS_PASS
AND TDD_EVIDENCE
AND ADVERSARIAL_DIFF_REVIEW
AND UNRESOLVED_THREADS_ZERO
AND OPEN_P0_P1_ZERO
AND GITHUB_SHEET_SAME_DECISION_ID
AND EXPLICIT_USER_MERGE_AUTHORIZATION_PER_PR
```

- HEAD가 바뀌면 이전 검토·검사·attestation은 무효다.
- 자동 병합은 금지한다.
- 각 PR의 정확한 HEAD에 대해 사용자의 명시적 병합 승인을 다시 받아야 한다: `EXPLICIT_USER_MERGE_AUTHORIZATION_PER_PR`.
- 검증하지 않은 runtime·사람·실기기·접근성·성능 결과를 통과로 바꾸지 않는다.
- branch protection·권한·보안 설정 변경은 별도 사용자 승인 없이 수행하지 않는다.

## 4. 고위험 변경

다음 범위는 이 상시 예외만으로 병합할 수 없다. PR별 위험 설명과 사용자의 추가 명시적 위험 승인이 필요하다.

- 보안·인증·자격증명.
- 저장소 권한·branch protection.
- 파괴적 데이터 또는 save migration.
- release signing·store 배포.
- 법무·개인정보·사용자 데이터.
- 되돌리기 어려운 production 작업.

## 5. 제품 구현 Gate

이 결정은 리뷰 인력 조건만 조정한다. 제품 구현 준비도를 바꾸지 않는다.

```yaml
product_implementation_effect: NONE
product_entry_gate: PRODUCT_ENTRY_GATE_NOT_WAIVED
current_product_entry: BLOCKED_BY_WORK_ENTRY_COMPLETENESS_GATE
```

`TEN-IMG-001`, Android, 로컬 Windows, 접근성 사용자, Release 성능, 사람 검증 등의 기존 미완료 상태는 그대로 유지한다.

## 6. 정지·취소 조건

다음 중 하나면 예외를 fail-closed로 중지한다.

- 추가 maintainer 또는 유효 reviewer가 등록됨.
- 사용자가 예외를 철회함.
- GitHub·Sheet·Base·Decision 사이에 미해결 충돌이 생김.
- 필수 readback 또는 exact-head 증거가 없음.

중지 결과는 `MERGE_BLOCKED_UNTIL_REVALIDATED`다.
