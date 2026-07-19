---
name: project-operations-and-handoff
description: Use when starting, routing, migrating, documenting, or handing off Ten Paces project work while preserving current design sources and unverified implementation state.
---

# 십보강호 프로젝트 운영·인수인계

## 핵심 원칙

현재 질문에 필요한 책임 원본과 최소 스킬만 읽고, 작업 종료 시 새 작업자가 저장소만으로 상태·다음 행동·위험을 복원하게 한다.

## 사용 조건

- 새 L1 이상 요청.
- Base 마이그레이션·문서 구조·Registry 변경.
- 현재 단계·우선순위·위험 변경.
- 작업 종료·새 채팅·Codex 인수.

## 읽기 순서

```text
START_HERE.md
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ DEVELOPMENT_GATES.md
→ DESIGN_DOCUMENT_REGISTRY.json
→ SKILL_REGISTRY.json
→ 현재 책임 원본·Issue·Plan·실제 파일
```

## 절차

1. 요청 수준과 주 책임 분야를 정한다.
2. 최신 사용자 지시, 보호 범위와 미검증을 분리한다.
3. Documentation Map에서 책임 원본을 찾는다.
4. Registry에서 trigger가 일치하는 최소 분야 스킬을 선택한다.
5. Ready 전에는 구현·삭제·대규모 이동을 실행하지 않는다.
6. 변경 후 Update Matrix로 동기화 범위를 확인한다.
7. 실행한 검증과 미검증을 분리한다.
8. Active Context·Roadmap·Handoff·Changelog·Learning Log를 필요한 만큼 갱신한다.

## 기존 프로젝트 마이그레이션

```text
Audit only
→ Governance foundation
→ 승인된 책임 이관
→ 보존·링크·발행 검증
→ 승인된 Cleanup
```

기존 `docs` 본책·백업·보류는 Registry·PDF·보존 대조와 사용자 승인 전에 제거하지 않는다.

## 완료 기준

- 주 책임 분야가 하나다.
- 책임 원본·실제 경로·검증이 연결된다.
- 새 작업자가 다음 행동과 금지 범위를 설명한다.
- 구현하지 않은 상태를 완료로 기록하지 않는다.
- Base 승격 후보와 프로젝트 고유 내용을 분리한다.

## 학습

실패·중요 결정·검증 결과는 `skills/SKILL_LEARNING_LOG.md`에 기록한다. 한 번의 성공으로 스킬을 검증 상태로 올리지 않는다.
