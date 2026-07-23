# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `BUILD → REVIEW` — PR #7 기준 정본·Skill·Governance 최신화와 보존 검증.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 구현 PR: #7 `agent/t0-combat-poc-board`.
- 기준 SHA: `147a031c75e96bff170d7f99016beb9e85b12066`.
- 최신 승인: Issue #13 STEP 12~14.
- 정합화 브랜치: `agent/pr7-canonical-skill-refresh`.
- 제품 단계: T0 Prototype.
- 프로젝트 코어: `CORE_REVIEW_PENDING`.

## 현재 구현

- STEP 0~13 구현.
- TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6.
- 10칸·4/7·거리 3·거리 0 `[밀착]`.
- `3수 → 3수 → 4수`.
- 기초 행동 8종·절초 3종.
- `[합]`·순차 방어·회피·필중·중단·강건.
- 공개 상태 기반 결정적 최소 AI.
- 승패·무승부·4/7 완전 재시작.
- 수별 `timing_results`·`presentation_events` 연출.
- 키보드 포커스·모션 감소·음향 제어·UI Automation 기술 증거.

세부 판정은 `docs/02_COMBAT_RULES.md`, 범위는 `docs/05_COMBAT_POC_SPEC.md`, 증거는 `docs/08_TEST_CHECKLIST.md`, 실제 상태는 `data/`, `src/`, `scenes/`, `assets/`, `tests/`가 책임진다.

## 증거 경계

```yaml
step_0_to_13_implementation: IMPLEMENTED
mechanical_step14_scenarios: RECORDED
windows_and_godot_technical_evidence: PARTIAL_TO_PASS
human_rule_comprehension: NOT_RUN
assistive_technology_user_validation: NOT_RUN
subjective_audio_motion_readability: NOT_RUN
external_playtest: NOT_RUN
release_performance_budget: NOT_RUN
branch_protection_required_checks: NOT_RUN
local_uncommitted_state: UNVERIFIED
```

기계 시나리오와 개발자 반환값 확인은 실제 플레이어 이해·선호를 대체하지 않는다.

## 현재 작업

1. 활성 `docs/01~11`을 Issue #13 현행 계약으로 재작성한다.
2. Base 25개 Skill route와 프로젝트 고유 Skill 4개를 정렬한다.
3. board schema 16·Base SHA·Skill 집합을 단일 freshness 계약으로 검사한다.
4. stale 문장·구형 Base·구형 Skill·Python 캐시 재등장을 차단한다.
5. 기준 SHA 대비 Codex 제품 파일 보존을 비교한다.
6. Documentation Governance·Card Component Contract를 새 HEAD에서 실행한다.
7. 정합화 PR을 #7에 병합한 뒤 #7의 `main` 통합 가능성을 재검토한다.

## 보호 범위

정합화 작업에서 다음을 수정하지 않는다.

- `data/`.
- `src/`.
- `scenes/`.
- `assets/`.
- `addons/`.
- `project.godot`.
- 제품 Godot 런타임 테스트.
- 사용자 로컬 미커밋 변경.

force push·reset·rebase로 PR #7 HEAD를 덮어쓰지 않는다.

## 다음 제품 작업

정합화가 검증된 뒤 PLAN 모드로 전환한다.

```text
핵심 컨셉 후보
→ 제약·조건
→ 뾰족한 재미
→ 모든 요소의 WHY/HOW/WHAT 정렬
→ 현재 POC 증거 대조
→ 기획 재조정
→ SWOT / VRIO
→ 사용자 승인으로 프로젝트 코어 확정
→ STEP 14 실제 사용자 플레이
```

코어 승인 전 T1 콘텐츠 제작을 시작하지 않는다.

## 기본 읽기

1. `AGENTS.md`.
2. 이 `ACTIVE_CONTEXT.md`.
3. `DOCUMENTATION_MAP.md`.
4. 질문별 책임 원본.
5. 실제 파일·테스트·PR·Issue.

백업·보류·과거 Plan·닫힌 PR은 기본 읽기에서 제외한다.

## 중단 조건

- PR #7 기준 SHA가 예상과 다르게 이동했다.
- 보호 경로에 의도하지 않은 변경이 나타났다.
- Actions 실패 원인을 확인하지 않고 통합하려 한다.
- 실제 사용자 증거 없이 STEP 14 또는 T1을 통과 처리한다.
- 구형 PR의 고유 정보 보존을 확인하지 않고 닫거나 병합한다.
