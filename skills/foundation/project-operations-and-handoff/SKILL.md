---
name: project-operations-and-handoff
description: Use for Ten Paces request routing, Work Mode selection, Base migration, Active Context updates, boundary handoffs, and L1+ execution reports while preserving project sources and unverified states.
---

# 십보강호 프로젝트 운영·인수인계

## Skill Modes

- `route`: 요청 수준·Work Mode·주 책임·최소 Skill을 판정
- `context-update`: 현재 상태·다음 작업·위험 갱신
- `handoff`: 세션·브랜치·마일스톤 경계 스냅샷
- `execution-report`: 사용 이유·수행 내용·결과·증거·미검증 보고

## 중심 원칙

현재 질문에 필요한 책임 원본과 최소 Skill만 읽고, 새 작업자가 저장소만으로 상태·다음 행동·위험을 복원하게 한다. Active Context는 현재 상태의 기본 원본이며 Handoff는 경계 스냅샷이다.

## 사용 조건

- 새 L1 이상 요청
- Work Mode·Skill 라우팅
- Base 마이그레이션·Registry·문서 구조 변경
- 현재 단계·우선순위·위험 변경
- 작업 종료·새 채팅·Codex 인수

## 읽기 순서

```text
START_HERE.md
→ AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ DEVELOPMENT_GATES.md
→ DESIGN_DOCUMENT_REGISTRY.json
→ 현재 책임 원본
→ SKILL_REGISTRY.json
→ 실제 파일·테스트·PR
```

## 절차

1. `PLAN / BUILD / REVIEW` 중 주 Work Mode를 정한다.
2. 요청 수준과 주 책임 분야 하나, 영향 분야를 정한다.
3. 최신 사용자 지시·보호 범위·미검증을 분리한다.
4. Documentation Map에서 책임 원본을 찾는다.
5. Registry trigger로 필요한 최소 Skill·Skill Mode를 자동 선택한다.
6. 구조 변경은 `audit → reconcile-legacy → 승인 → migrate → verify`를 따른다.
7. 변경 후 Update Matrix와 정본 최신성을 확인한다.
8. 실행한 검증과 미검증을 분리한다.
9. Active Context·Roadmap·Learning Log를 갱신하고 필요한 경우만 Handoff를 만든다.
10. L1 이상은 실행 보고를 남긴다.

## 구형 파일 처리

```text
CURRENT / UPDATE_IN_PLACE / MERGE_TO_CANONICAL / COMPATIBILITY_STUB
ARCHIVE_HISTORY / DELETE_APPROVED / KEEP_UNRESOLVED
```

고유 정보·활성 참조·파생본·복구·사용자 승인 전 삭제하지 않는다.

## 완료 기준

- Work Mode·Skill Mode·선택 이유가 명확하다.
- 주 책임 분야가 하나다.
- 책임 원본·실제 경로·검증이 연결된다.
- 구현하지 않은 상태를 완료로 기록하지 않는다.
- 새 작업자가 다음 행동과 금지 범위를 설명한다.
- 프로젝트 고유 값과 Base 공용 교훈을 분리한다.

## 실행 보고

`templates/project-operations/SKILL_EXECUTION_REPORT.md`를 사용한다.

## 학습

실패·중요 결정·검증 결과는 `skills/SKILL_LEARNING_LOG.md`에 기록한다. 한 번의 성공으로 지식 상태를 `VERIFIED`로 올리지 않는다.
