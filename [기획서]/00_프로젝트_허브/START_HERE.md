# 십보강호 프로젝트 허브

이 허브는 현재 상태, 책임 원본, Work Mode·Skill 라우팅, 개발 게이트, 검증과 인수인계를 연결한다.

## 작업 시작 순서

```text
최신 사용자 지시
→ ../../../START_HERE.md
→ ../../../AGENTS.md
→ ../../../docs/BASE_RULES_VERSION.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ DEVELOPMENT_GATES.md
→ ROADMAP.md
→ ../DESIGN_DOCUMENT_REGISTRY.json
→ 현재 책임 원본
→ SKILL_REGISTRY.json
→ 필요한 Skill·Skill Mode
→ Issue·Plan·실제 파일·테스트
```

## 현재 상태

- Base 기준: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- Base 변경 155개 커밋·70개 파일 감사: `BASE_MAIN_SYNC_AUDIT.md`
- 운영 PR: #5
- 전투 POC PR: #7
- 전투 POC: STEP 0~10, TARGETING 10.5 구현
- 대응·자원 보완: RESPONSE 10.6, RESOURCE PREVIEW 10.6 구현
- 사용자 Windows 확인: STEP 0~10·행동 배치·대상 지정
- 사용자 확인 대기: 최신 대응 연계·자원 미리보기
- PDF·Skill Map·Manifest: `MIGRATION_PENDING`
- Required Check 강제: 미확인

## Work Mode

- `PLAN`: 요구·정본·순서·승인
- `BUILD`: 승인 범위 구현
- `REVIEW`: 검토·검증·판정

Registry trigger로 필요한 최소 Skill·Skill Mode를 자동 선택한다. L1 이상 작업은 사용 이유·수행 내용·결과·증거·미검증을 기록한다.

## 허브 문서

- `ACTIVE_CONTEXT.md`: 현재 상태 기본 원본
- `HANDOFF.md`: 경계 스냅샷
- `ROADMAP.md`: 운영·제품 게이트
- `DOCUMENTATION_MAP.md`: 질문별 책임 원본과 Skill
- `DEVELOPMENT_GATES.md`: 완료 증거
- `DOCUMENT_UPDATE_MATRIX.md`: 변경 소비자
- `BASE_MAIN_SYNC_AUDIT.md`: Base 전수 처리표
- `DECISION_LOG.md`: 결정과 재검토 조건
- `CHANGELOG.md`: 변경·검증·미검증
- `AI_WORKFLOW.md`: AI·GitHub 흐름
- `SOURCE_AUDIT.md`: 보존·구형본 감사
- `OPERATING_SYSTEM_HEALTH_REPORT.md`: verify 결과

`../DESIGN_DOCUMENT_REGISTRY.json`이 제품 책임 원본을 연결한다. 실제 구현은 `data/`, `scenes/`, `src/`, `tests/`, `project.godot`에서 확인한다.

문서 존재, 정적 검사, Actions 성공, PDF 생성, Godot 런타임, 접근성·성능 검증, 사용자 시각 검수, Required Check 강제는 각각 독립 상태다.
