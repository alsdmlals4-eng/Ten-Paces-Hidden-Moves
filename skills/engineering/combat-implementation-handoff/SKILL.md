---
name: combat-implementation-handoff
description: Use when approved Ten Paces design must be audited against a real Godot worktree and converted into exact GDScript, scene, data, save, and test changes with runtime evidence.
---

# 십보강호 구현 인수

## Skill Modes

- `implementation-contract`: 실제 경로·데이터 소유·테스트·호환성 Plan
- `build`: 승인 범위의 Godot 구현
- `runtime-handoff`: 실행 증거·미검증·다음 작업 인계

## 사용 전제

실제 저장소의 `project.godot`, GDScript, 씬, 데이터, 자산, 테스트와 Git 상태를 확인한다. 현재 원격에는 Godot 구현이 존재하며 사용자는 STEP 0~10·대상 지정의 이전 Windows 흐름을 확인했다.

현재 최신 확인 대기:

- 플레이어 4번·상대 7번 시작 위치.
- RESPONSE 10.6.
- RESOURCE PREVIEW 10.6.

사용자 재확인 전 위 항목은 `IMPLEMENTED_FOR_REVIEW` 또는 `UNVERIFIED`다.

## 책임 원본

- 판정: `docs/02_COMBAT_RULES.md`
- 범위: `docs/05_COMBAT_POC_SPEC.md`
- UI: `docs/07_COMBAT_UI_SPEC.md`
- 테스트: `docs/08_TEST_CHECKLIST.md`
- 아키텍처: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- 구현 데이터·코드: `data/`, `scenes/`, `src/`, `tests/`
- 시작 위치 데이터 원본: `data/combat/combat_board_poc.json`
- 구현 PR: #7

## 절차

1. Git branch·status·remote와 사용자 변경을 확인한다.
2. 문서·Registry·실제 파일의 차이를 기록한다.
3. 낡은 전투 구조·ID·경로·Schema·fixture 소비자를 검색한다.
4. 변경 정본에서 코드 fallback·씬 메타·테스트·자산·문서·Skill·Context 영향 지도를 만든다.
5. 저장·Resource ID·공개 인터페이스·세이브 호환 보호 경로를 정한다.
6. 변경을 결과·의존성·완료·검증·롤백 단위로 계획한다.
7. 승인 범위를 가장 작은 검증 가능한 변경으로 구현한다.
8. 정적 검사→Godot 파싱→headless→Windows 포인터·렌더 순으로 검증한다.
9. 실제 결과를 Context·Roadmap·Handoff·PR에 기록한다.

## 시작 위치 변경 계약

플레이어 4번·상대 7번 변경은 다음 소비자를 함께 수정한다.

```text
combat_board_poc.json
→ CombatBoardPreview loaded value and fallback
→ CombatState initial tile
→ character placement and occupancy
→ targeting origin and movement candidates
→ enemy fixture expectations
→ Python contract test
→ Godot board and response tests
→ reference SVG
→ active docs, project Skills, Active Context, PR
```

- 계약 파일 로드 실패 시에도 fallback은 4번·7번이다.
- 기본 이동·보법·공격 fixture의 기대 칸을 새 시작 위치에서 다시 계산한다.
- 테스트를 통과시키기 위해 사용자 확정값을 fixture에 맞춰 되돌리지 않는다.

## 구현 경계

- 전투 규칙은 씬과 분리된 판정 엔진이 소유한다.
- UI는 입력·계획 예상치·결과 표시를 담당한다.
- UI의 자원 미리보기는 실제 상태를 확정하지 않는다.
- AI는 공개 정보만 사용한다.
- 공용 효과는 데이터·수정자 계약으로 표현한다.
- VFX·애니메이션·오디오는 결과를 변경하지 않는다.
- 현재 T0에는 저장·재도전·정식 AI가 없다.

## 금지

- 실제 경로를 읽지 않고 파일명 추정.
- 승인 전 코드·씬·데이터·저장 포맷 수정.
- 데이터만 수정하고 fallback·fixture·자산·문서를 방치.
- 임시 수치로 본책 변경.
- 보류 기능 확장.
- UI 코드에서 피해·보상·수련·저장 확정.
- 정적 Actions만으로 Windows 런타임 완료 주장.

## 완료 기준

- 문서 규칙과 실제 구현 경로가 연결된다.
- 시작 위치가 데이터·fallback·runtime state·test·SVG에서 일치한다.
- 같은 입력에서 판정이 재현된다.
- 정상·실패·경계·회귀 테스트가 있다.
- Godot headless와 사용자 Windows 결과를 분리 기록한다.
- 현재 없는 저장·불러오기·재도전을 완료로 표시하지 않는다.
- 실행하지 않은 접근성·성능·플레이테스트는 `NOT_RUN`이다.
