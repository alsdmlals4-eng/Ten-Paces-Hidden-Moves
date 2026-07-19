# 십보강호 시작 지점

이 문서는 새 채팅, 새 GPT, 새 Codex와 새 작업자가 `Ten-Paces-Hidden-Moves`를 시작할 때 사용하는 최상위 라우터다.

## 현재 기준선

- 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`
- 원격 기준: `main@0ac66389ad6b1d10019680ebf1417d423fa1466e`
- 적용 Base: `alsdmlals4-eng/Base@eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- 운영 계약: Base schema v3 비파괴 마이그레이션
- 추적 Issue: `#4 Base schema v3 운영체계 전면 마이그레이션`
- 사용자 로컬 작업본: `C:\Users\user\Documents\바이브코딩\ten-paces-hidden-moves-base-full-11-migration`

현재 실행 환경에서는 위 Windows 경로를 직접 읽지 못했다. 원격 저장소에 없는 코드·자산·미커밋 변경과 Godot 실행 상태는 `[미검증]`이다.

## 가장 먼저 읽기

```text
START_HERE.md
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/START_HERE.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ [기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md
→ [기획서]/DESIGN_DOCUMENT_REGISTRY.json
→ [기획서]/00_프로젝트_허브/SKILL_REGISTRY.json
→ 현재 작업의 Markdown 책임 원본
→ 실제 코드·데이터·자산·테스트
```

## 현재 책임 원본 정책

- 서술 중심 기획은 기존 `docs/*.md`를 schema v3 Markdown 책임 원본으로 보존한다.
- Registry·상태·ID·경로·Manifest는 JSON으로 관리한다.
- 같은 질문에 책임 원본을 두 개 만들지 않는다.
- 기존 `docs/[백업]/`, `docs/[보류]/`, Plan과 Git 이력은 삭제하지 않는다.
- PDF는 항상 동기화하는 것이 목표지만 현재 생성 환경과 로컬 원본을 확인하지 못해 `MIGRATION_PENDING`이다.
- DOCX와 다이어그램은 필요한 경우의 선택 파생본이다.

## 현재 제품 방향

십보강호는 10칸 전장에서 양측이 두 행동을 비공개로 잠근 뒤 동시에 공개하는 1대1 무협 로그라이트다. 전장 10칸, 라운드 10타이밍, 전체 대회 10전의 `10-10-10` 구조와 5전 예선 결승 데모를 유지한다.

세부 기획은 기존 책임 원본을 따른다.

- 전체 경험: `docs/01_GAME_DESIGN.md`
- 전투 규칙: `docs/02_COMBAT_RULES.md`
- UI: `docs/07_COMBAT_UI_SPEC.md`
- 시스템 경계: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- 연출: `docs/10_COMBAT_PRESENTATION_PLAN.md`
- 검증: `docs/08_TEST_CHECKLIST.md`
- 로드맵: `docs/04_ROADMAP.md`

## 현재 마이그레이션 상태

```text
Audit only               완료
Governance foundation    진행 중
책임 원본 Registry       진행 중
PDF·Manifest 발행         MIGRATION_PENDING
Godot·코드·자산 감사      미검증
Cleanup·강제 검사         후속 게이트
```

구조 정리만으로 구현·런타임·플레이테스트 완료를 주장하지 않는다.
