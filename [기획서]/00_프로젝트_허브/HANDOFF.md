# 십보강호 인수인계

> 현재 상태 원본: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`

## 첫 행동

1. 루트 `AGENTS.md`를 읽는다.
2. `ACTIVE_CONTEXT.md`와 `DOCUMENTATION_MAP.md`를 읽는다.
3. PR #7 `agent/t0-combat-poc-board`의 현재 HEAD와 기준 SHA 관계를 확인한다.
4. Issue #13의 승인 규칙과 `docs/02_COMBAT_RULES.md`를 대조한다.
5. Registry trigger로 최소 Skill·Skill Mode를 선택한다.
6. 구현 작업이면 실제 `data/`, `src/`, `scenes/`, `assets/`, `tests/`를 확인한다.

## 현재 기준

- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 구현 PR: #7 `agent/t0-combat-poc-board`.
- 기준 SHA: `147a031c75e96bff170d7f99016beb9e85b12066`.
- 최신 승인: Issue #13 STEP 12~14.
- 정합화 브랜치: `agent/pr7-canonical-skill-refresh`.
- 프로젝트 코어: `CORE_REVIEW_PENDING`.

## 완료된 구현

- STEP 0~13.
- 10칸·4/7·거리 3·밀착.
- 3/3/4·기초 행동 8종·절초 3종.
- 합·방어·회피·필중·중단·강건.
- 공개 상태 기반 최소 AI.
- 승패·무승부·완전 재시작.
- 순차 연출·키보드·모션 감소·음향 제어.

## 현재 정합화 작업

- 활성 본책을 현행 계약으로 재작성.
- Base 활성 Skill 25개 route.
- 프로젝트 고유 Skill 4개 유지·간소화.
- board schema 16·Base SHA·Skill 집합 단일 freshness 계약.
- stale 반례·Python cache 재발 차단.
- 기준 SHA 대비 제품 파일 보존 검증.
- 정합화 Draft PR을 #7 대상으로 생성 예정.

## 미검증

- 실제 사용자 STEP 14 규칙 이해·재도전 행동.
- 실제 보조기기 사용자 사용성.
- 주관적 음향·모션 읽기성.
- 외부 POC 표본.
- 목표 장치 Release 성능.
- Branch protection Required Check 강제.
- 사용자 로컬 미커밋 파일과 원격 차이.

## 보호 범위

정합화에서는 다음을 변경하지 않는다.

- `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`.
- 제품 Godot 런타임 테스트.
- 사용자 로컬 변경.
- 백업·보류·과거 Plan·Git 이력.
- T1 이후 성장·세력 가설의 고유 정보.

force push·reset·rebase를 금지한다.

## 다음 작업

1. Design Registry·Entry Point·Audit·Health 문서를 최종 정렬한다.
2. Governance·Skill·freshness 반례를 실행한다.
3. 기준 SHA compare로 허용 변경만 존재하는지 확인한다.
4. 정합화 Draft PR을 #7 대상으로 생성한다.
5. 최신 Actions 성공 뒤 #7 통합 여부를 결정한다.
6. 정합화 뒤 PLAN 모드에서 프로젝트 코어를 확정한다.
7. 코어 승인 뒤 STEP 14 실제 사용자 플레이를 실행한다.

## 프로젝트 코어 PLAN 순서

```text
핵심 컨셉 후보
→ 제약·조건
→ 뾰족한 재미
→ WHY/HOW/WHAT 정렬
→ POC 증거 대조
→ 기획 재조정
→ SWOT / VRIO
→ 적대적 검토
→ 사용자 승인
```

## 중단 기준

- PR #7 HEAD 또는 기준 SHA가 예상과 다르다.
- 보호 경로에 예상 밖 변경이 있다.
- Actions 실패 원인을 확인하지 않았다.
- 사람 증거 없이 STEP 14·T1을 통과 처리하려 한다.
- 구형 PR의 고유 정보 보존을 확인하지 않고 닫거나 병합하려 한다.
