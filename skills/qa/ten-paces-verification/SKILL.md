---
name: ten-paces-verification
description: Use when Ten Paces design, implementation, UI, data, save, build, publication, accessibility, performance, player-understanding, or local Godot validation claims require project-specific observable evidence.
---

# 십보강호 검증

## 책임

십보강호 고유 규칙·데이터·Godot·UI·빌드·플레이어 이해 주장을 재현 가능한 증거로 판정한다. 일반 변경 검증·정본 최신성 방법은 Base Skill을 사용하고, 이 Skill은 프로젝트 고유 반례와 증거 기준을 제공한다.

UNIFIED_WORK_EXECUTION: 현재 실행자가 승인 범위의 구현·검증을 수행한다. HANDOFF_ONLY_FOR_CAPABILITY_GAP_OR_EXPLICIT_REQUEST에만 CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF로 연결한다. 과거 local Codex launcher는 사용하지 않는다.

## Skill Modes

- `contract-check`: 승인 계약·정본·실제 diff 대조.
- `static-validation`: 형식·경로·Registry·전투 계약.
- `runtime-validation`: Godot 파싱·headless·에디터·Windows 실행.
- `local-godot-validation-readiness`: 사용자 PC에서 Godot 실행/검증이 필요한 경우 exact project/editor/session과 채택 toolchain을 판정한다.
- `accessibility-review`: 실제 정보·입력·탐색·모션·음향 장벽.
- `performance-profile`: 목표 플랫폼 예산·baseline 비교.
- `regression`: 정상·실패·경계·반례·기존 동작.
- `evidence-report`: 통과·실패·미실행 증거 보고.

## 사용 조건

사용한다.

- 전투·AI·UI·데이터·저장·빌드의 완료 주장을 검증한다.
- 정본 변경 뒤 프로젝트 고유 소비자 누락을 확인한다.
- 사람 플레이·접근성·성능의 증거 상태를 판정한다.
- 사용자 PC에서 local Godot 실행/검증이 실제 필요하고 exact project/editor/session readiness를 확인해야 한다.
- 현재 실행자 또는 조건부 인계 결과의 프로젝트 고유 runtime evidence를 검수한다.

사용하지 않는다.

- 변경이 없는 아이디어 비교다.
- 일반 저장소 구조 감사만 필요하다.
- 같은 입력의 검사 결과를 실행 없이 다시 주장한다.
- 과거 launcher 실행·프로세스 존재·LISTEN 포트 존재만으로 current readiness를 통과시키려 한다.
- local Codex launcher/CODEX_HOME/dedicated port bootstrap을 current 제품 구현 전제조건으로 복원하려 한다.

## 책임 원본

- 제품 체크리스트: `docs/08_TEST_CHECKLIST.md`.
- 전투 규칙: `docs/02_COMBAT_RULES.md`.
- POC 범위: `docs/05_COMBAT_POC_SPEC.md`.
- UI·접근성: `docs/07_COMBAT_UI_SPEC.md`.
- 아키텍처: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`.
- 작업 게이트: `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`.
- current project contract: `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`.
- 실제 증거: `data/`, `scenes/`, `src/`, `assets/`, `tests/`, Actions, Godot, Windows, Android actual device, 사람 관찰.
- 과거 local executor: `TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01` 및 `tools/start_ten_paces_local_executor.ps1` — `SUPERSEDED_HISTORICAL_EVIDENCE_FOR_CURRENT_EXECUTION`, current launcher가 아님.

## 검증 순서

```text
claim and failure condition
→ baseline and approved scope
→ canonical/reference freshness
→ format·syntax·static
→ focused automated tests
→ Godot runtime·render·build when required
→ accessibility when affected
→ performance when affected
→ normal·failure·edge·counterexample
→ adjacent regression
→ baseline diff preservation
→ evidence report
```

## `local-godot-validation-readiness` 계약

현재 host 기본은 프로젝트별 동일 Godot binary와 dedicated port를 증식시키는 방식이 아니라 **현재 승인된 shared exact Godot pin + Godot AI 기본 포트 + exact project/editor/session identity**다. 정확한 pin/version은 프로젝트 current adoption record와 공식 upstream freshness Gate를 읽고 발견한다.

```yaml
PROJECT_IDENTITY: exact repository/worktree/project.godot
GODOT_COMPATIBILITY: project exact requirement vs current approved shared pin
EDITOR_IDENTITY: exact project path + current editor process/session
GODOT_AI_SESSION: exact project/editor session identity when adopted and required
GODOT_AI_PORTS: provider current default unless evidenced recovery exception
GUT: current project-adopted deterministic GDScript test authority when applicable
HERA: current project-adopted LIVE_QA_AND_OBSERVABILITY_ONLY when applicable
REPO_NO_UNINTENDED_MUTATION: pre/post repository delta classification
```

추가 원칙:

- historical executable/PID/port/session은 locator/history일 뿐 current authority가 아니다.
- current project contract가 폐기한 project-specific CODEX_HOME이나 local Codex bootstrap을 readiness 항목으로 요구하지 않는다.
- external process 존재만으로 editor/session/project identity PASS를 주장하지 않는다.
- read-only readiness 중 제품 파일 변경을 만들지 않는다.
- 어느 한 항목이라도 실제 호출/조회가 되지 않으면 `NOT_RUN` 또는 `BLOCKED`이며 `PASS`로 승격하지 않는다.
- 읽기 전용 readiness에서 제품을 수정하지 않는다. 구현 승인이 있으면 같은 세션에서 build로 전환할 수 있으며 실제 능력 부족일 때만 인계한다.

## 프로젝트 고유 계약군

정확한 current 값은 `docs/02_COMBAT_RULES.md`, 최신 Decision, structured data, actual runtime에서 읽는다. 아래는 stable discovery invariant다.

- 1대1 10칸 논리 전장.
- 시작 공개 거리 2, 거리 0 `[밀착]`, player-facing `거리 N` 중심.
- `[3,3,4]` 계획 묶음과 current-bundle commit/resolve 의미.
- 기초/무공/절초 행동 출처; 현재 기초 행동 정본은 10종이며 exact 수치/세부는 current combat canon에서 읽는다.
- 합·방어·회피·중단·강건·복기.
- 공개 상태 기반 상대 AI와 미확정 플레이어 계획 열람 금지.
- 종료·재시작 상태 초기화와 save/state 의미.
- UI/VFX/audio의 combat/economy/save 규칙 재계산 금지.
- Windows·Android shared core + platform adapters.
- localization-ready `ko/en/ja/zh-*`; Chinese variant는 project Decision 전 `UNKNOWN_UNVERIFIED`.
- responsive `pc_standard / pc_wide_or_ultrawide / mobile_landscape` semantic parity.

과거 `4/7`, `거리3`, 기초 행동8종 같은 역사 구현/Decision 값은 당시 evidence로 보존할 수 있지만 current Skill contract로 고정하지 않는다.

## 병합 차단 결함

- 활성 문서·Skill·Entry Point가 데이터와 반대되는 전장·자원·판정·AI 상태를 현행으로 설명한다.
- JSON과 fallback·runtime state·fixture·자산의 값이 다르다.
- 백업·보류·과거 PR을 활성 구현 기본 입력으로 사용한다.
- 낮은 evidence 층을 Human/player/runtime PASS로 승격한다.
- AI가 플레이어 미확정 계획을 읽는다.
- UI·VFX·오디오가 피해·기세·승패를 재계산한다.
- 재시작 뒤 상태·신호·로그·연출·오디오가 누적된다.
- 기준 SHA 대비 사용자/Codex 제품 파일이 의도 없이 삭제·변경됐다.
- 다른 프로젝트 editor/session을 십보강호 readiness로 오인한다.
- 실제 exact project/session 확인 없이 process/port만으로 readiness PASS를 주장한다.
- current r5.4가 폐기한 local Codex/CODEX_HOME/dedicated-port orchestration을 active 진입점이 다시 요구한다.

과거 Git 이력·닫힌 PR·Change Log·historical Decision의 당시 사실은 활성 참조와 분리해 허용한다.

## 접근성·성능

- 접근성은 텍스트·대비·정보 채널·입력·탐색·시간·난이도·모션·음향 장벽과 대체 경로를 실제 플레이로 확인한다.
- UI Automation·메타데이터 존재만으로 실제 보조기기 사용성을 통과 처리하지 않는다.
- 성능은 목표 플랫폼·동일 빌드·대표/최악 장면에서 frame time·CPU·GPU·메모리·로딩을 baseline과 비교한다.
- DEBUG 표본과 Release 목표 사양을 구분한다.

## 금지

- 체크리스트 존재를 테스트 통과로 간주.
- 파일 존재를 실행 성공으로 간주.
- 정적 패턴만으로 UI 결함 또는 성공 확정.
- Actions 성공을 Windows visible·Android actual device·접근성 사용자·Release 성능 PASS로 간주.
- 실행하지 않은 검증을 암묵적으로 통과 처리.
- 테스트 편의를 위해 사용자 승인값을 구형 fixture로 되돌림.
- 다른 open PR/branch를 확인 없이 reset·rebase·force push.
- local Codex launcher를 current 제품 구현 route로 사용.

공용 승인·격리·검토·보고 절차는 `AGENTS.md`와 `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`를 재사용한다. 기존 실행 기록에 주장·변경·검증·미검증·다음 작업을 누적하며 단계마다 새 보고서를 만들지 않는다.

## 완료 기준

- 각 완료 주장에 재현 가능한 증거가 있다.
- 변경 정본과 모든 활성 소비자가 일치한다.
- 실패와 미검증이 다음 작업으로 연결된다.
- 기준 전후 결과와 파일을 비교할 수 있다.
- 사람 이해와 자동 테스트를 분리한다.
- historical executor evidence와 current Godot validation route를 분리한다.

## 재미·표현 검증 연결

FUN_VERIFICATION_LIFECYCLE은 `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md` §6.1을 따른다. 변경 기능의 기존 owner에 가설·반례·입력/상태/정보·실제 consumer·검증·교정을 연결한다. 이해 실패·규칙/선택 실패·피드백 부족·반복 피로를 구분한다. HUMAN_NOT_RUN을 자동 테스트나 AI 검토로 FUN_PASS로 바꾸지 않으며 승인된 독립 구현은 계속한다. 작은 변경은 기존 기록에 짧게 적고 새 재미 보고서·보편 점수·가상 감독을 만들지 않는다.
