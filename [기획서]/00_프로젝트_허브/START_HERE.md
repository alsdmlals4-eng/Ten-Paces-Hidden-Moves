# 십보강호 프로젝트 허브

## 기본 경로

```text
../../../AGENTS.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ 현재 책임 원본
→ 실제 파일·테스트·PR
```

현재 요청에 필요할 때만 Gates, Roadmap, Registry, Audit, Handoff를 추가로 읽는다.

## 현재 상태

- Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 감사: `BASE_MAIN_SYNC_AUDIT.md`
- 검증: `BASE_MAIN_SYNC_VERIFICATION.md`
- 운영 PR: #5
- 전투 POC PR: #7
- 구현: STEP 0~10, TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6
- 사용자 확인: STEP 0~10·행동 배치·대상 지정
- 사용자 확인 대기: 최신 대응 연계·자원 미리보기
- 문서·Skill Registry: 발행 생성기가 없어 `source_only`
- Skill: Base 공유 13개 + 로컬 고유 4개
- Branch protection: 미확인

## Work Mode

- `PLAN`: 요구·정본·순서·승인
- `BUILD`: 승인 범위 구현
- `REVIEW`: 적대적 검토·검증·판정

Registry trigger로 필요한 최소 Skill·Skill Mode를 자동 선택하고 L1 이상은 실행 결과를 보고한다.

## 허브 책임

- `ACTIVE_CONTEXT.md`: 현재 상태·다음 작업·위험
- `DOCUMENTATION_MAP.md`: 책임 원본·Skill·검증
- `DEVELOPMENT_GATES.md`: 준비·완료 게이트
- `ROADMAP.md`: 운영·제품 단계
- `HANDOFF.md`: 경계 스냅샷
- `DOCUMENT_UPDATE_MATRIX.md`: 변경 소비자
- `BASE_MAIN_SYNC_AUDIT.md`: Base 파일별 처리
- `BASE_MAIN_SYNC_VERIFICATION.md`: 적대적 검토·Actions·보존
- `DECISION_LOG.md`, `CHANGELOG.md`, `SOURCE_AUDIT.md`: 이력

제품 책임 원본은 `../DESIGN_DOCUMENT_REGISTRY.json`, Skill 라우팅은 `SKILL_REGISTRY.json`, 구현 사실은 `data/`, `scenes/`, `src/`, `tests/`, `project.godot`가 책임진다.

정적 Actions 성공은 Godot 런타임, PDF, 접근성, 성능, 사용자 검수, Branch protection을 증명하지 않는다.
