---
name: combat-implementation-handoff
description: Use when approved Ten Paces design must be audited against the real Godot worktree and converted into exact GDScript, scene, data, asset, compatibility, and test changes with runtime evidence.
---

# 십보강호 구현 인수

## 책임

승인된 십보강호 규칙·UI 계약을 실제 Godot 파일·데이터·씬·자산·테스트 변경으로 변환하고, 사용자 작업과 기존 동작을 보존한 상태로 런타임 증거를 인계한다.

UNIFIED_WORK_EXECUTION: 승인 구현은 현재 세션에서 수행한다. HANDOFF_ONLY_FOR_CAPABILITY_GAP_OR_EXPLICIT_REQUEST일 때만 별도 인계한다.

## Skill Modes

- `implementation-contract`: 실제 경로·데이터 소유·호환성·테스트 Plan.
- `build`: 승인 범위의 Godot 구현.
- `runtime-handoff`: 실행 증거·미검증·다음 작업 인계.

## 사용 조건

사용한다.

- 전투·AI·UI·데이터 계약을 실제 Godot 구현으로 옮긴다.
- 규칙 변경이 fallback·fixture·씬·자산·테스트에 전파돼야 한다.
- 런타임 오류·상태 누적·저장 호환성 영향을 다룬다.

사용하지 않는다.

- 실제 저장소 파일을 읽지 않은 순수 기획 대화다.
- 프로젝트 코어·벤치마킹·제품 방향만 비교한다.
- 일반 Git 동기화만 필요하다.

## 책임 원본

- 판정: `docs/02_COMBAT_RULES.md`.
- 범위: `docs/05_COMBAT_POC_SPEC.md`.
- UI: `docs/07_COMBAT_UI_SPEC.md`.
- 테스트: `docs/08_TEST_CHECKLIST.md`.
- 아키텍처: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`.
- 구현: `data/`, `scenes/`, `src/`, `assets/`, `tests/`, `project.godot`.
- 현재 기준: 허브 `ACTIVE_CONTEXT.md`, 현재 관련 PR, 활성 Issue.

## 영향 지도 최소 범위

전투 계약 하나가 바뀌면 다음 소비자를 확인한다.

```text
canonical rule or JSON
→ loader and fallback
→ runtime state
→ resolution/AI
→ target and resource preview
→ scene and UI
→ assets and manifest
→ automated/Godot/Windows tests
→ docs, Skills, Context, PR
```

## 구현 경계

- 전투 규칙은 씬과 분리된 판정 엔진이 소유한다.
- AI는 공개 정보만 사용하고 플레이어와 같은 계획 검증을 거친다.
- UI는 입력·예상값·결과를 표현한다.
- VFX·애니메이션·오디오는 결과를 변경하지 않는다.
- 현재 없는 저장·불러오기·회차 상태를 완료로 가정하지 않는다.
- 보류 기능을 fixture 편의를 위해 구현하지 않는다.

## 파일 안전

- force push·reset·사용자 변경 덮어쓰기 금지.
- 데이터만 수정하고 fallback·fixture·자산·문서를 방치하지 않는다.
- 테스트를 통과시키기 위해 승인값을 구형 fixture로 되돌리지 않는다.
- 삭제·이동은 참조·고유 정보·복구·사용자 승인을 확인한다.
- 생성 자산은 manifest·라이선스·원본/파생 관계를 유지한다.

## 검증 순서

```text
contract-check
→ reference-freshness
→ JSON/GDScript syntax
→ focused automated tests
→ Godot parse/headless/editor runtime
→ Windows input/render
→ accessibility when affected
→ performance when affected
→ normal/failure/edge/counterexample/regression
→ baseline diff and evidence report
```

공용 승인·격리·검토·보고 절차는 `AGENTS.md`와 `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`를 재사용한다. 기존 실행 기록에 주장·변경·검증·미검증·다음 작업을 누적하며 단계마다 새 보고서를 만들지 않는다.

## 완료 기준

- 문서 규칙과 실제 구현 경로가 연결된다.
- 데이터·fallback·runtime state·test·자산·문서가 일치한다.
- 같은 입력에서 판정과 AI가 재현된다.
- 정상·실패·경계·반례·회귀 증거가 있다.
- 기준 SHA 대비 보호 경로의 의도치 않은 변경이 없다.
- 실행하지 않은 런타임·접근성·성능·사람 플레이를 통과로 표시하지 않는다.
