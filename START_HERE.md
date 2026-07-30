# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ skills/PROJECT_BASE_ADAPTER.json
→ skills/PROJECT_SKILL_SNAPSHOT.json
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 질문별 책임 원본
→ 실제 코드·데이터·씬·자산·테스트·PR·Issue
```

백업·보류·과거 계획·닫힌 PR·전체 Skill 폴더를 기본 컨텍스트로 로드하지 않는다.

## 현재 운영 기준

- 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`.
- Base 적용 기준: `docs/BASE_RULES_VERSION.md`.
- Base release: `v9.3.0`.
- Vertical Slice 실행 계약: `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v9.md`, contract `9.1`.
- 자동 라우팅 계약: `skills/PROJECT_BASE_ADAPTER.json`과 생성된 `skills/PROJECT_SKILL_SNAPSHOT.json`.
- 프로젝트 고유 Skill Registry: `skills/SKILL_REGISTRY.json`.
- `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`은 명시적 호환·이력 참조다.
- Adapter·Snapshot·Router pin이 다르면 작업을 중단한다.

## 현재 제품 기준

- 제품 단계: `CONCEPT_APPROVAL`.
- 현재 Work Mode: `PLAN`.
- Work Mode 어휘: `PLAN / BUILD / REVIEW`.
- 실행 프로필: `PLANNING_ONLY_PROFILE`.
- 최신 기획 통합 PR: #45.
- 현재 결정 권한: `docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.
- 현행 T0 구현 계보: PR #7과 Issue #13.
- 런타임 구현: `PROHIBITED_UNTIL_NEW_APPROVAL`.
- 사람 검증: `UNVERIFIED`.
- 플랫폼: PC 우선, 차후 모바일.

## 현재 코어

> 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트.

- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 핵심 결투 5개를 버티컬 슬라이스 앵커로 사용한다.
- 전체 필수 주요 비무 목표는 10전이다.
- `[연격 N]`은 총피해를 N회로 분할한다.
- 방어와 보호막은 통합 `[방어도]`다.
- AI는 플레이어의 미확정 계획을 읽지 않는다.

## 장기 확장 포인터

Issue #64는 본편 10전과 `[천하제일인]` 승리 후 등록 가능한 비동기 챔피언 배틀을 다룬다.

- 사용자 측: 자신의 캐릭터를 직접 조작·계획.
- 상대 측: 등록된 `Champion Build Snapshot`을 AI가 조종.
- 등록 후 자신의 현재·과거 구성과 자가 비무 가능.
- 현재 Demo·Vertical Slice에는 서버·모바일 런타임을 포함하지 않는다.

## `[보류]`

- Round 4 이후 전체 적대적 검토.
- 16권 절초의 개별 설계.
- 2026-07-26 구현 계획 실행.
- Godot 런타임·데이터·씬·자산 변경.
- 서버·계정·랭킹·시즌·모바일 포팅 구현.

## 상태 경계

정적 검사와 문서 정합성은 Godot 런타임·Windows·성능·접근성·사람 플레이를 증명하지 않는다. 실행하지 않은 검증은 `UNVERIFIED` 또는 `NOT_RUN`으로 기록한다.
