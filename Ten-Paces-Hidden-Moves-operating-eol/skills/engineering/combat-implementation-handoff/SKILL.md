---
name: combat-implementation-handoff
description: Use when approved Ten Paces design must be audited against the real Godot worktree and converted into exact GDScript, scene, data, asset, compatibility, and test changes with runtime evidence.
---

# 십보강호 구현 인수

## 책임

승인된 십보강호 규칙·UI 계약을 실제 Godot 파일·데이터·씬·자산·테스트 변경으로 변환하고, 사용자 작업과 기존 동작을 보존한 상태로 런타임 증거를 인계한다.

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
- 현재 기준: 허브 `ACTIVE_CONTEXT.md`, PR #7, 활성 Issue.

## 절차

1. Git branch·HEAD·status·remote와 사용자 변경을 확인한다.
2. 기준 SHA에서 격리 브랜치 또는 worktree를 만든다.
3. 문서·Registry·실제 파일의 차이를 기록한다.
4. 변경 정본에서 데이터·fallback·state·AI·씬·UI·자산·테스트·Context 영향 지도를 만든다.
5. 공개 ID·Resource UID·세이브 포맷·노드·신호·입력 경로의 보호 범위를 정한다.
6. 결과·의존성·완료·검증·롤백 단위로 계획한다.
7. 승인 범위를 가장 작은 검증 가능한 변경으로 구현한다.
8. 좁은 정적·단위 검사부터 Godot 파싱·headless·Windows 렌더·입력으로 확장한다.
9. 정상·실패·경계·반례·회귀를 확인한다.
10. 실제 결과를 Context·Roadmap·Handoff·PR에 기록한다.
11. 기준 SHA 대비 변경 파일을 확인해 사용자/Codex 작업 유실이 없는지 검증한다.

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

## 출력

```yaml
baseline_branch:
baseline_sha:
work_branch:
approved_scope:
protected_paths:
changed_files:
untouched_consumers:
static_evidence:
runtime_evidence:
windows_evidence:
human_evidence:
rollback:
result: PASS | PARTIAL | FAIL | NOT_RUN | BLOCKED
```

## 완료 기준

- 문서 규칙과 실제 구현 경로가 연결된다.
- 데이터·fallback·runtime state·test·자산·문서가 일치한다.
- 같은 입력에서 판정과 AI가 재현된다.
- 정상·실패·경계·반례·회귀 증거가 있다.
- 기준 SHA 대비 보호 경로의 의도치 않은 변경이 없다.
- 실행하지 않은 런타임·접근성·성능·사람 플레이를 통과로 표시하지 않는다.
