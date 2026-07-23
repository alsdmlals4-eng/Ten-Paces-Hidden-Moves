# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 질문별 책임 원본
→ 실제 코드·데이터·씬·자산·테스트·PR·Issue
```

전체 Skill 폴더, 백업·보류·과거 Plan·닫힌 PR을 기본 컨텍스트로 로드하지 않는다.

## 현재 기준

- 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`.
- Base: `alsdmlals4-eng/Base@41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- Base 버전·차이: `docs/BASE_RULES_VERSION.md`.
- Skill Registry: `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`.
- 현재 구현: PR #7 `agent/t0-combat-poc-board`.
- 기준 SHA: `147a031c75e96bff170d7f99016beb9e85b12066`.
- 최신 승인: Issue #13 STEP 12~14.

## Work Mode

- `PLAN`: 요구·코어·근거·대안·실행 순서.
- `BUILD`: 승인 범위 구현.
- `REVIEW`: 적대적 검토·반례·검증.

Skill·Skill Mode는 Registry trigger로 자동 선택한다. L1 이상은 기준 SHA·선택 이유·수행·결과·증거·미검증을 `execution-report`로 남긴다.

## 현재 제품 상태

- 10칸, 플레이어 4번·상대 7번, 시작 거리 3.
- 같은 칸 최대 2인과 거리 0 `[밀착]`.
- 라운드 `3수 → 3수 → 4수`.
- 기초 행동 8종·절초 3종.
- `[합]`·방어·회피·필중·중단·강건.
- 공개 상태 기반 결정적 최소 AI.
- 승패·무승부·4/7 완전 재시작.
- STEP 0~13 구현·기술 증거.
- STEP 14 기계 시나리오 기록.
- 실제 사용자 STEP 14: `NOT_RUN`.
- 프로젝트 코어: `CORE_REVIEW_PENDING`.

## 다음 순서

```text
정본·Skill·Governance 최신화
→ PR #7 제품 파일 보존 검증
→ 프로젝트 코어 PLAN·사용자 승인
→ STEP 14 실제 사용자 플레이
→ T1 진입 판단
```

## 상태 경계

정적 Actions 성공은 Godot 런타임·Windows 사용자 경험·접근성 사용자 검수·Release 성능·PDF 발행·Branch protection 강제를 증명하지 않는다. 원격 변경과 사용자 로컬 미커밋 파일도 자동으로 동일하지 않다.
