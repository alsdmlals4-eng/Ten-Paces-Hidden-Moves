---
name: ten-paces-verification
description: Use when Ten Paces design, implementation, UI, data, save, build, publication, accessibility, performance, or player-understanding claims require project-specific observable evidence.
---

# 십보강호 검증

## 책임

십보강호 고유 규칙·데이터·Godot·UI·빌드·플레이어 이해 주장을 재현 가능한 증거로 판정한다. 일반 변경 검증·정본 최신성 방법은 Base Skill을 사용하고, 이 Skill은 프로젝트 고유 반례와 증거 기준을 제공한다.

## Skill Modes

- `contract-check`: 승인 계약·정본·실제 diff 대조.
- `static-validation`: 형식·경로·Registry·전투 계약.
- `runtime-validation`: Godot 파싱·headless·에디터·Windows 실행.
- `accessibility-review`: 실제 정보·입력·탐색·모션·음향 장벽.
- `performance-profile`: 목표 플랫폼 예산·baseline 비교.
- `regression`: 정상·실패·경계·반례·기존 동작.
- `evidence-report`: 통과·실패·미실행 증거 보고.

## 사용 조건

사용한다.

- 전투·AI·UI·데이터·저장·빌드의 완료 주장을 검증한다.
- 정본 변경 뒤 프로젝트 고유 소비자 누락을 확인한다.
- 사람 플레이·접근성·성능의 증거 상태를 판정한다.

사용하지 않는다.

- 변경이 없는 아이디어 비교다.
- 일반 저장소 구조 감사만 필요하다.
- 같은 입력의 검사 결과를 실행 없이 다시 주장한다.

## 책임 원본

- 제품 체크리스트: `docs/08_TEST_CHECKLIST.md`.
- 전투 규칙: `docs/02_COMBAT_RULES.md`.
- POC 범위: `docs/05_COMBAT_POC_SPEC.md`.
- UI·접근성: `docs/07_COMBAT_UI_SPEC.md`.
- 아키텍처: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`.
- 작업 게이트: `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`.
- 실제 증거: `data/`, `scenes/`, `src/`, `assets/`, `tests/`, Actions, Godot, Windows, 사람 관찰.

## 검증 순서

```text
claim and failure condition
→ baseline and approved scope
→ canonical/reference freshness
→ format·syntax·static
→ focused automated tests
→ Godot runtime·render·build
→ accessibility when affected
→ performance when affected
→ normal·failure·edge·counterexample
→ adjacent regression
→ baseline diff preservation
→ evidence report
```

## 절차

1. 검증할 주장과 실패 조건을 적는다.
2. 기준 SHA·환경·도구·권한·버전·입력을 기록한다.
3. 파일 존재·정적·자동·Godot·Windows·사람 검수를 분리한다.
4. 변경 정본에서 데이터·fallback·코드·씬·자산·테스트·문서·Skill·Context 영향 지도를 만든다.
5. changed 파일뿐 아니라 갱신됐어야 할 untouched 소비자를 확인한다.
6. 정상 경로와 함께 원래 실패해야 하는 반례를 실행한다.
7. 수정 전 반례 실패·수정 후 통과를 가능한 범위에서 확인한다.
8. 기준 SHA 대비 보호 경로 변경을 검사한다.
9. 통과·실패·미실행·환경 차이를 분리 보고한다.

## 프로젝트 고유 계약군

- 전장 10칸·4/7·거리 3·밀착·점유·교환/통과.
- `[3,3,4]`·준비/실행·대상·자원 미리보기.
- 기초 행동 8종·절초 3종.
- 합·방어·회피·필중.
- 중단·강건·전투 불능.
- 공개 상태 기반 최소 AI와 금지 입력.
- 종료·재시작 완전 초기화.
- 수별 state/event 연출과 UI 계산 금지.
- 키보드·접근성 정보 채널·최소 해상도.
- T0/T1/T2/전체판 상태 구분.

정확한 현재 값은 제품 정본과 JSON에서 읽고 Skill 본문에 별도 진행 상태를 복제하지 않는다.

## 병합 차단 결함

- 활성 문서·Skill·Entry Point가 데이터와 반대되는 전장·자원·판정·AI 상태를 현행으로 설명한다.
- JSON과 fallback·runtime state·fixture·자산의 값이 다르다.
- 백업·보류·과거 PR을 활성 구현 기본 입력으로 사용한다.
- T1 이후 가설을 T0 완료로 표시한다.
- AI가 플레이어 미확정 계획을 읽는다.
- UI·VFX·오디오가 피해·기세·승패를 재계산한다.
- 재시작 뒤 상태·신호·로그·연출·오디오가 누적된다.
- 기준 SHA 대비 사용자/Codex 제품 파일이 의도 없이 삭제·변경됐다.

과거 Git 이력·닫힌 PR·Change Log의 당시 사실은 활성 참조와 분리해 허용한다.

## 접근성·성능

- 접근성은 텍스트·대비·정보 채널·입력·탐색·시간·난이도·모션·음향 장벽과 대체 경로를 실제 플레이로 확인한다.
- UI Automation·메타데이터 존재만으로 실제 보조기기 사용성을 통과 처리하지 않는다.
- 성능은 목표 플랫폼·동일 빌드·대표/최악 장면에서 frame time·CPU·GPU·메모리·로딩을 baseline과 비교한다.
- DEBUG 표본과 Release 목표 사양을 구분한다.

## 금지

- 체크리스트 존재를 테스트 통과로 간주.
- 파일 존재를 실행 성공으로 간주.
- 정적 패턴만으로 UI 결함 또는 성공 확정.
- Actions 성공을 Windows·접근성·성능·Required Check 강제로 간주.
- 실행하지 않은 검증을 암묵적으로 통과 처리.
- 테스트 편의를 위해 사용자 승인값을 구형 fixture로 되돌림.
- 최신 Codex 변경을 확인 없이 reset·rebase·force push.

## 출력

```yaml
claim:
baseline_sha:
environment:
static:
automated:
godot_runtime:
windows:
human_playtest:
accessibility_user:
release_performance:
baseline_diff:
counterexamples:
result: PASS | PARTIAL | FAIL | NOT_RUN | BLOCKED
remaining_risks:
```

## 완료 기준

- 각 완료 주장에 재현 가능한 증거가 있다.
- 변경 정본과 모든 활성 소비자가 일치한다.
- 실패와 미검증이 다음 작업으로 연결된다.
- 기준 전후 결과와 파일을 비교할 수 있다.
- 사람 이해와 자동 테스트를 분리한다.
