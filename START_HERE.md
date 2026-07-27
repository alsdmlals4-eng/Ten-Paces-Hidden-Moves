# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 질문별 책임 원본
→ 실제 코드·데이터·씬·자산·테스트·PR·Issue
```

백업·보류·과거 계획·닫힌 PR·전체 Skill 폴더를 기본 컨텍스트로 로드하지 않는다.

## 현재 기준

- 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`.
- Base 적용 기준: `docs/BASE_RULES_VERSION.md`.
- Skill Registry: `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`.
- 제품 단계: `CONCEPT_APPROVAL`.
- 현재 Work Mode: `PLAN`.
- Work Mode 어휘: `PLAN / BUILD / REVIEW`.
- 실행 프로필: `PLANNING_ONLY_PROFILE`.
- 최신 기획 통합 PR: #45 `agent/poc-planning-baseline-and-legacy-audit`.
- 현재 결정 권한: `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.
- PR #45 통합 검수: `docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md`.
- 현행 T0 구현 계보: PR #7과 Issue #13. 최신 v6 설계 권한과는 분리한다.
- 런타임 구현: `PROHIBITED_UNTIL_NEW_APPROVAL`.
- 사람 검증: `UNVERIFIED`.

2026-07-26의 BUILD 승인과 구현 인계 기록은 `SUPERSEDED_REFERENCE`다. PR #45 통합은 최신 계획 문서와 역사 자료를 정합화하며 제품 런타임을 변경하지 않는다.

## 현재 코어

> 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트.

- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 핵심 결투 5개를 버티컬 슬라이스 앵커로 사용한다.
- `[연격 N]`은 총피해를 N회로 분할한다.
- 방어와 보호막은 통합 `[방어도]`다.
- 수련 중앙 목표는 전체 전투 5회 40~50, 10회 90~100이다.
- 절초는 기세 5를 소비하고 동일 슬롯 일반 기술보다 약 50% 높은 예산을 가진다.

## `[보류]`

- Round 4 이후 전체 적대적 검토.
- 16권 절초의 개별 설계.
- 2026-07-26 구현 계획 실행.
- Godot 런타임·데이터·씬·자산 변경.

## 상태 경계

정적 검사와 문서 정합성은 Godot 런타임·Windows·성능·접근성·사람 플레이를 증명하지 않는다. 실행하지 않은 검증은 `UNVERIFIED`로 기록한다.
