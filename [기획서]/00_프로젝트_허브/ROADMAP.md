# 십보강호 운영 로드맵

> 제품 구현의 상세 순서는 `docs/04_ROADMAP.md`, 현재 사용자 결정 권한은 `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`가 소유한다.

```yaml
product_stage: CONCEPT_APPROVAL
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL
```

## R0 — 현행 구현·역사 보존

- [x] T0 구현 계보 PR #7·Issue #13 확인.
- [x] 기술 기준 SHA `659c57e7ffa588ad6a6471ed9b5394985b159eaf` 보존.
- [x] Base 기준과 프로젝트 고유 Skill 경계 보존.
- [x] 기존 코드·데이터·테스트는 현재 구현 사실로 유지.

상태: `IMPLEMENTED_LEGACY / REFERENCE_ONLY_FOR_V6_DESIGN`.

## R1 — v6 결정 권한 통합

- [x] 제품 단계 `CONCEPT_APPROVAL`과 Work Mode `PLAN` 확정.
- [x] 프로젝트 코어를 상대의 숨은 수를 읽고 파훼하는 경험으로 재정렬.
- [x] 핵심 결투 5개 버티컬 슬라이스 앵커 확정.
- [x] 무공서 16권·1~10성·수련·랭크 계약 연결.
- [x] 연격·방어도·전조·비용·태그 계약 연결.
- [x] PR #45의 BUILD 승인·구형 기획을 `SUPERSEDED_REFERENCE`로 재분류.
- [x] 모든 결정에 주장 유형·근거·책임 원본·적용 빌드·재검토 조건 연결.

상태: `V6_PLANNING_AUTHORITY_INTEGRATED`.

## R2 — 현재 GitHub 통합

- [x] v6 전체 결정 권한 원장 작성.
- [x] Active Context·Documentation Map·Handoff·진입점 갱신.
- [x] PR #45 제목·본문을 계획 전용 통합으로 교정.
- [x] 과거 기획 기준선과 BUILD 진입 문서를 역사 포인터로 축약.
- [ ] 최신 PR Validation PASS.
- [ ] PR #45 병합 후 main SHA와 파일 상태 재확인.

상태: `INTEGRATION_REVIEW`.

## R3 — `[보류]`

다음은 사용자가 재개하기 전 진행하지 않는다.

- Round 4 이후 전체 적대적 검토.
- 16권 절초의 개별 이름·효과·슬롯·태그·대응점.
- 2026-07-26 구현 계획 실행.
- 런타임 구현 계획 재작성.
- Godot 런타임·데이터·씬·자산 변경.

상태: `HOLD`.

## R4 — 설계 재개 후

사용자가 절초 설계를 재개하면:

1. 절초 공통 계약을 기준으로 16개 절초를 하나씩 확정한다.
2. 일반 기술과 성급 효과를 내부 권장안으로 완성한다.
3. 성장 경제·경로·적·UI의 통합 명세를 작성한다.
4. 보류된 적대적 검토를 재개한다.
5. 남은 `MUST_FIX`가 0일 때만 새 구현 계획과 BUILD 승인을 요청한다.

상태: `NOT_STARTED / USER_RESTART_REQUIRED`.

## R5 — 향후 BUILD 게이트

새 BUILD는 다음을 모두 요구한다.

- 사용자의 명시적 구현 승인.
- 최신 통합 명세와 구현 계획.
- 보호 경로·기준 SHA·롤백 계약.
- 격리 브랜치·worktree.
- TDD와 구간별 REVIEW 복귀.
- Godot·Windows·접근성·성능·사람 검증의 독립 기록.

현재 판정: `NOT_GRANTED`.

## 독립 증거 원칙

파일 존재·정적 검사·Actions·Godot·Windows·접근성·성능·사람 플레이·시장 검증은 서로 다른 증거다. 실행하지 않은 항목은 `UNVERIFIED`다.
