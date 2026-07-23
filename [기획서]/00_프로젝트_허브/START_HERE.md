# 십보강호 프로젝트 허브

## 기본 경로

```text
../../../AGENTS.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ 질문별 책임 원본
→ 실제 파일·테스트·PR·Issue
```

현재 요청에 필요할 때만 Gates·Roadmap·Registry·Audit·Handoff를 추가로 읽는다.

## 현재 상태

- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- Base 버전·차이: `../../../docs/BASE_RULES_VERSION.md`.
- 감사: `BASE_MAIN_SYNC_AUDIT.md`.
- 검증: `BASE_MAIN_SYNC_VERIFICATION.md`.
- 구현 PR: #7 `agent/t0-combat-poc-board`.
- 기준 SHA: `147a031c75e96bff170d7f99016beb9e85b12066`.
- 최신 승인: Issue #13 STEP 12~14.
- 구현: STEP 0~13.
- STEP 14 기계 시나리오: 기록됨.
- STEP 14 실제 사용자 관찰: `NOT_RUN`.
- 프로젝트 코어: `CORE_REVIEW_PENDING`.
- 문서·Skill Registry: `source_only`.
- Skill: Base 활성 25개 route + 프로젝트 고유 4개.
- Branch protection Required Check: `NOT_RUN`.

## Work Mode

- `PLAN`: 요구·코어·근거·대안·승인.
- `BUILD`: 승인 범위 구현.
- `REVIEW`: 적대적 검토·반례·검증.

Registry trigger로 필요한 최소 Skill·Skill Mode를 자동 선택하고 L1 이상은 기준 SHA와 실행 결과를 보고한다.

## 허브 책임

- `ACTIVE_CONTEXT.md`: 현재 상태·다음 작업·위험.
- `DOCUMENTATION_MAP.md`: 책임 원본·Skill·검증 경로.
- `DEVELOPMENT_GATES.md`: 준비·완료·진입 게이트.
- `ROADMAP.md`: 운영·제품 순서.
- `HANDOFF.md`: 세션·브랜치·마일스톤 경계 스냅샷.
- `DOCUMENT_UPDATE_MATRIX.md`: 정본 변경 소비자.
- `SKILL_REGISTRY.json`: Base·로컬 Skill 자동 라우팅.
- `BASE_MAIN_SYNC_AUDIT.md`: Base 변경 영향 처리.
- `BASE_MAIN_SYNC_VERIFICATION.md`: 반례·Actions·보존 검증.
- `DECISION_LOG.md`, `CHANGELOG.md`, `SOURCE_AUDIT.md`: 결정·이력·구형 자료 처리.

제품 책임 원본은 `../DESIGN_DOCUMENT_REGISTRY.json`, 구현 사실은 `../../../data/`, `../../../scenes/`, `../../../src/`, `../../../assets/`, `../../../tests/`, `../../../project.godot`가 책임진다.

## 다음 순서

```text
정본·Skill·Governance 검증
→ PR #7 제품 파일 보존 확인
→ 프로젝트 코어 PLAN·사용자 승인
→ STEP 14 실제 사용자 플레이
→ T1 진입 또는 기획 재조정
```

정적 Actions 성공은 Godot 런타임·Windows 사용자 경험·접근성 사용자 검수·Release 성능·PDF·Branch protection을 증명하지 않는다.
