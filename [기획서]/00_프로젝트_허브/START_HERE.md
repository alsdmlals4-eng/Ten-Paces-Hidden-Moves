# 십보강호 프로젝트 허브

## 목적

이 허브는 프로젝트의 현재 상태, 기획 책임 원본, 선택적 스킬, 개발 게이트, 검증과 인수인계를 연결한다. 기존 `docs` 본책의 내용을 장문 복제하지 않고 정확한 경로와 상태만 라우팅한다.

## 작업 시작 순서

```text
최신 사용자 지시
→ ../../../AGENTS.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ DEVELOPMENT_GATES.md
→ ../DESIGN_DOCUMENT_REGISTRY.json
→ SKILL_REGISTRY.json
→ 현재 작업의 책임 원본
→ Roadmap·Issue·Plan
→ 실제 파일·테스트
```

## 현재 상태

- 단계: Base schema v3 비파괴 마이그레이션과 구현 인수 준비.
- 제품 기획: 승인된 Markdown 본책을 유지한다.
- 구현: 원격 저장소에서는 Godot 프로젝트·코드·테스트를 확인하지 못했다.
- PDF: 생성 도구·폰트·로컬 원본 검증 전이므로 `MIGRATION_PENDING`.
- 다음 제품 기획: 기존 Active Context 기준 절초 기세·상단 HUD UX.
- 다음 운영 작업: 사용자의 Windows 작업본을 실제로 열어 원격과 차이를 감사하고 발행 파이프라인을 실행한다.

## 허브 문서

| 문서 | 책임 |
|---|---|
| `ACTIVE_CONTEXT.md` | 현재 단계·우선순위·위험 라우터 |
| `HANDOFF.md` | 다음 작업자의 첫 행동과 중단 기준 |
| `ROADMAP.md` | 운영체계 마이그레이션과 제품 로드맵 연결 |
| `DOCUMENTATION_MAP.md` | 질문별 책임 원본·스킬·검증 경로 |
| `DEVELOPMENT_GATES.md` | 작업·제품 게이트와 완료 판정 |
| `DOCUMENT_UPDATE_MATRIX.md` | 변경 유형별 동기화 대상 |
| `DECISION_LOG.md` | 구조·책임 원본·보존 결정 |
| `CHANGELOG.md` | 마이그레이션 변경·검증·미검증 |
| `AI_WORKFLOW.md` | GPT·Codex·GitHub 역할과 승인 흐름 |
| `SOURCE_AUDIT.md` | 변경 전 구조·보존·위험 감사 |
| `LIFECYCLE_AREAS.md` | 현행·백업·보류·제거 후보 계약 |
| `OPERATING_SYSTEM_HEALTH_REPORT.md` | 구조·Registry·발행·자동화 검수 |

## 책임 원본

`../DESIGN_DOCUMENT_REGISTRY.json`이 기획 본책의 기계 판독 라우터다. 현재는 기존 `docs/01~11` Markdown 파일을 단일 책임 원본으로 등록한다. 내용 승계와 발행 검증 전에는 기존 본책을 이동하거나 제거하지 않는다.

## 선택적 스킬

`SKILL_REGISTRY.json`에서 요청과 trigger가 일치하는 최소 스킬만 선택한다.

- 모든 스킬 자동 로드 금지.
- 주 책임 분야 스킬 최대 1개.
- Foundation 스킬 최대 3개.
- 검증·발행·Handoff 스킬은 해당 게이트에서만 사용.
- `[보류]`, `[백업]`, `[제거 후보]`는 기본 호출 금지.

## 완료의 의미

문서 구조 설치, PDF 발행, GitHub Actions 존재, 실제 Actions 성공, Branch protection Required Check 강제, Godot 런타임 검증은 서로 다른 상태다. 확인하지 않은 상태를 완료로 기록하지 않는다.
