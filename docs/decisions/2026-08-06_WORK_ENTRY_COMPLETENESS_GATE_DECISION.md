# 작업 진입 누락 방지 필수 Gate Decision

```yaml
decision_id: TEN-DEC-20260806-WORK-ENTRY-COMPLETENESS-GATE-01
date: 2026-08-06
status: APPROVED_FOR_IMPLEMENTATION
gate_type: MANDATORY_BLOCKING_GATE
checklist_policy: CHECKLIST_ONLY_FORBIDDEN
approval_source: USER_REQUIRED_FAIL_CLOSED_ENTRY_GATE
baseline_main: 6e471b62a6236749312f31264428a46b97c8387a
sheet_baseline_main: 5f4add5d98721413681cf92c01bb810f16677703
product_behavior_change: false
```

## 결정

누락 방지 규칙은 사람이 읽고 지나가는 체크리스트가 아니다. 작업 유형별 필수 증거를 기계적으로 읽고, 하나라도 없거나 충돌하면 작업 시작·READY·AWAITING_IMPLEMENTATION·병합 가능 판정을 차단하는 fail-closed Gate로 운영한다.

```yaml
entry_policy: FAIL_CLOSED
missing_readback: WORK_ENTRY_BLOCKED_UNVERIFIED
canon_conflict: WORK_ENTRY_BLOCKED_CANON_CONFLICT
open_p0_p1: WORK_ENTRY_BLOCKED_FINDINGS_OPEN
visual_not_closed: WORK_ENTRY_BLOCKED_VISUAL_GATE_OPEN
sheet_not_synced: WORK_ENTRY_BLOCKED_SHEET_SYNC
false_ready_action: FALSE_READY_REVERSAL
```

## 필수 readback

모든 작업 시작 시 아래 여섯 Surface를 새로 읽는다.

1. GitHub 현행 Decision 원장과 관련 책임 정본.
2. Sheet `02_현재_확정결정`.
3. Sheet `04_누락_충돌_감사`의 미해결 P0/P1·CANON_CONFLICT·BLOCKED 항목.
4. Sheet `71_이미지기획_생성목록`.
5. Sheet `72_이미지검수_승인로그`.
6. `docs/planning-data/current_operating_state.json`.

읽지 못한 Surface는 통과로 간주하지 않는다. GitHub와 Sheet가 다르면 최신 승인 Decision과 실제 구현을 근거로 충돌을 해소하기 전까지 차단한다. 이 원칙은 `GITHUB_SHEET_READBACK_REQUIRED`다.

## 작업 유형별 진입 조건

### 제품 기획·구현

다음이 모두 참이어야만 제품 코드·Scene·Resource·데이터·플랫폼 Adapter 구현에 진입한다.

```text
관련 Decision 승인·동일 ID GitHub/Sheet 반영
AND P0/P1·CANON_CONFLICT 0건 또는 승인된 scope exemption
AND [기획 완료]
AND [검토 완료]
AND [이미지 완료] 또는 NO_NEW_VISUAL_ASSET_REQUIRED 승인
AND exact baseline main 확인
AND 실패 테스트·수용 기준 존재
```

현재 Sheet readback에서는 P0 `RUNTIME_AUTHORITY_GAP`, 계획 단계, 이미지 `PLANNED / IN_REVIEW / NOT_RUN`이 남아 있다. 따라서 `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION`은 `PRODUCT_IMPLEMENTATION_BLOCKED`다. 기존 `NEXT_APPROVED_PACKAGE_NOT_IMPLEMENTED`, `READY`, `AWAITING_IMPLEMENTATION` 표현은 진입 허가가 아니며 `FALSE_READY_REVERSAL` 대상이다.

### 거버넌스·개발 도구

제품 화면·아트·플레이 경험을 바꾸지 않는 CI·validator·테스트 프레임워크·저작 도구 채택은 별도 경로를 사용한다.

```text
scope_class: GOVERNANCE_TOOLING
visual_disposition: NO_NEW_VISUAL_ASSET_REQUIRED
product_behavior_change: false
protected_product_files: unchanged unless separately approved
```

GUT 9.7.1·HiGodot 3.1.2 채택은 이 경로에 해당한다. HiGodot은 유일한 Godot 저작 권위, GUT는 테스트 실행·JUnit 권위로만 사용한다. 이 예외는 제품 구현 Gate를 해제하지 않는다.

## 잘못된 READY/AWAITING 되돌림

다음 표식은 필수 증거가 닫히기 전 사용할 수 없다.

```text
READY
READY_NOT_RUN
AWAITING_IMPLEMENTATION
IMPLEMENTATION_READY
CODEX_READY
```

대신 정확한 차단 상태와 해제 조건을 기록한다. 자동 validator는 위 표식이 제품 진입 상태와 함께 나타나면 실패한다.

## Sheet 동기화

이 Decision ID는 다음 위치에 동일하게 기록한다.

- `02_현재_확정결정`
- `04_누락_충돌_감사`
- `71_이미지기획_생성목록`의 tooling 무자산 판정
- `72_이미지검수_승인로그`의 tooling 무자산 승인
- `99_변경이력`

제품 이미지 `TEN-IMG-001~003`의 기존 `PLANNED / BLOCKED_BY_DEMO / IN_REVIEW / NOT_RUN` 상태는 변경하지 않는다.

## 검증

- `tests/test_work_entry_completeness_gate.py`
- `tools/check_work_entry_completeness_gate.py`
- `.github/workflows/documentation-governance.yml`의 `gut-adoption-exact-head` job

Gate 자체가 누락되면 CI가 실패해야 한다. Gate가 제품 구현을 차단하는 현재 상태는 validator PASS이며, 제품 구현이 성공했다는 의미가 아니다.
