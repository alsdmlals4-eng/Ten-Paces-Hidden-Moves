---
name: combat-implementation-handoff
description: Use when approved Ten Paces design must be audited against a real Godot worktree and converted into exact GDScript, scene, data, save, and test changes.
---

# 십보강호 구현 인수

## 사용 전제

실제 저장소 트리와 `project.godot`, GDScript, 씬, Resource, 데이터, 테스트를 읽을 수 있어야 한다. 현재 원격에는 해당 파일이 확인되지 않았으므로 Windows 작업본 연결 전 구현 완료를 주장하지 않는다.

## 책임 원본

- 판정: `docs/02_COMBAT_RULES.md`
- 범위: `docs/05_COMBAT_POC_SPEC.md`
- 성장 데이터: `docs/06_STARTING_FACTION_MASTERY_DATA.md`
- UI 계약: `docs/07_COMBAT_UI_SPEC.md`
- 테스트: `docs/08_TEST_CHECKLIST.md`
- 아키텍처: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- 연출 이벤트: `docs/10_COMBAT_PRESENTATION_PLAN.md`
- 구현 Plan: `plans/2026-07-16-combat-poc-plan.md`

## 감사 절차

1. Git status·branch·remote와 사용자 변경을 확인한다.
2. 문서와 실제 파일 차이를 기록한다.
3. 폐기된 6슬롯·1~5성·9전·구 보상 흔적을 검색한다.
4. 저장 포맷·Resource ID·공개 인터페이스·세이브 호환 보호 경로를 정한다.
5. 정확한 수정·신규 파일, 데이터 계약, 테스트 명령, 위험과 중단 기준을 Plan으로 작성한다.
6. 사용자 승인 뒤 구현한다.
7. 구조화 이벤트와 결정론적 테스트로 검증한다.

## 구현 경계

- 전투 규칙은 씬과 분리된 순수 시뮬레이션 책임을 가진다.
- UI는 입력과 이벤트 표시를 담당한다.
- AI는 공개 정보만 사용해 플레이어보다 먼저 두 행동을 잠근다.
- 문파 효과는 공용 수정자 계약으로 표현한다.
- 프레젠테이션 이벤트는 결과를 변경하지 않는다.

## 금지

- 실제 경로를 읽지 않고 파일명을 추정.
- 승인 전 코드·씬·Resource·저장 포맷 수정.
- 임시 수치로 본책 변경.
- 보류 기능 확장.
- UI 코드에서 피해·보상·수련·저장 계산.

## 완료 기준

- 문서 규칙과 실제 구현 경로가 연결된다.
- 같은 시드·입력에서 결과가 재현된다.
- 저장·불러오기와 재도전에서 고정 상태가 유지된다.
- Godot headless와 Windows 빌드 검증 결과가 기록된다.
- 미실행 검증은 명시적으로 남는다.
