# 십보강호 협업 규칙

이 파일은 `alsdmlals4-eng/Ten-Paces-Hidden-Moves`의 최상위 프로젝트 작업 계약이다.

## 1. 우선순위

1. 사용자의 최신 확정 지시.
2. 보안·플랫폼 제약과 이 `AGENTS.md`.
3. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`와 승인된 작업 계약.
4. 최신 날짜의 현재 Decision과 등록된 분야 책임 원본.
5. 실제 코드·데이터·Scene·Resource·자산·테스트.
6. 프로젝트에 고정된 Base route·Adapter.
7. Base 원격 원본.
8. 과거 문서·PR·Issue·외부 사례·추정.

정상 동작 중인 사용자·Codex 변경을 임의로 되돌리지 않는다. 실제 구현과 승인 정본이 다르면 어느 쪽도 자동으로 진실로 간주하지 않고 `CANON_CONFLICT`로 판정한다.

## 2. 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 파일·테스트·PR·Issue
```

- Base 공용 Skill route: `skills/PROJECT_BASE_ADAPTER.json`.
- 프로젝트 고유 Skill Registry: `skills/SKILL_REGISTRY.json`.
- `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`은 호환·이력 참조다.
- 백업·보류·과거 계획·닫힌 PR·전체 Skill 폴더를 기본 로드하지 않는다.

## 3. 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
current_integration_pr: 65
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
implemented_decision: TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
approved_planning_decision: TEN-DEC-20260801-SITUATION-SCREEN-01
automated_validation: PASS
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
base_release_pinned: 9.1.0
```

- ActionSelectionDock은 구현·자동 검증을 완료했지만 PR #65의 `main` 병합과 사람 검증은 아직 남아 있다.
- 전체 제품 화면 흐름은 승인된 PLAN이며 런타임 구현은 다음 패키지에서 시작한다.
- Base main v9.3은 조사했지만 현재 PR에서 v9.1 pin을 교체하지 않는다.

## 4. Work Mode·Skill Mode

- `PLAN`: 요구·근거·설계·순서·Decision 확정. 승인 전 제품 변경 금지.
- `BUILD`: 승인 범위의 코드·데이터·문서·자산 구현.
- `REVIEW`: 적대적 검토·반례·증거·판정. 승인된 최소 수정만 BUILD로 전환.
- Skill은 Registry trigger와 비사용 조건으로 자동 선택한다.
- Skill Mode는 현재 필요한 세부 절차만 사용한다.
- L1 이상 작업은 기준 SHA, Work Mode, Skill, Skill Mode, 수행 내용, 결과, 증거, 미검증을 `execution-report`에 기록한다.
- 정본·경로·ID·Schema·Base SHA 변경은 `reference-freshness`로 검사한다.

한 시점의 주 Work Mode는 하나다. 사용자에게 Skill 선택을 전가하지 않는다.

## 5. 프로젝트 코어

> 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트.

- 1대1 10칸 일자형 전장.
- 플레이어 4번·상대 7번 시작.
- 거리 0 `[밀착]`.
- 한 라운드 `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태와 해결 이력 기반 상대 추론.
- AI의 미확정 플레이어 계획 열람 금지.
- 덱·손패·드로우·장착 기술 제한 없음.
- 무공서는 성장·분류 단위이며 현재 해금 기술만 배치.
- 순차 `[합]`, 방어도, 회피, 중단, 강건, 복기.
- 성장은 판단을 대체하지 않고 파훼 선택지를 확장.

프로젝트 코어·Core Loop·주요 UX·콘텐츠 의미·저장 호환성을 바꾸는 변경은 `USER_DECISION_REQUIRED` 또는 새 Decision으로 승격한다.

## 6. 최신 행동 선택 계약

Decision: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`

- 출처는 `[기초] [무공] [절초]`다.
- 무공서는 직접 수에 배치하지 않는다.
- 실제 배치 단위는 현재 해금 기술이다.
- 세 출처는 가장 앞의 유효 연속 수에 자동 배치한다.
- 다중 수 행동은 `[전조] → [실행]` 연결 블록이다.
- 진행 전 연결 블록 전체 이동·제거를 허용한다.
- 절초기세 5는 배치 성공 시 예약하고 진행 전 제거·이동에서 환불·재예약한다.
- 제품 P0에서 가상 `준비+막기/회피` 카드를 만들지 않는다.
- UI는 피해·합·중단·AI·해금·자원 판정을 직접 계산하지 않는다.

## 7. 승인된 화면 구조

Decision: `TEN-DEC-20260801-SITUATION-SCREEN-01`

- 필수 화면: 메인 / 비무 / 무공 구성·자원 / 결과·복기·보상.
- P0 상황: Main, Run Setup, Route, Node, Briefing, Combat Plan, Resolve, Review, Victory Reward, Defeat Retry.
- Route와 Combat은 별도 Scene.
- Combat Review는 Combat Scene Overlay.
- Duel Result는 별도 Scene.
- P0 Autoload 후보는 `RunSession`, `SaveService`.
- `CombatState`는 Combat Scene 소유.
- 첫 제품 흐름은 슬롯별 대표 후보로 파이프라인을 증명하고, 후보 3명 계약은 검증 뒤 확장한다.

## 8. 책임 원본·Decision·Sheet

- 한 질문에는 현재 책임 원본 하나만 둔다.
- 최신 승인 Decision은 같은 ID로 Decision 문서, 분야 정본, planning JSON, Google Sheets에 연결한다.
- `ACTIVE_CONTEXT.md`는 현재 상태·다음 작업·위험만 압축한다.
- `DOCUMENTATION_MAP.md`는 책임 원본 경로를 연결한다.
- Google Sheets는 `USER_FACING_GDD_WORKSPACE`이며 GitHub 정본·실제 구현을 대체하지 않는다.
- Sheet에만 있는 변경은 `PROPOSED_SHEET_CHANGE`로 보존한다.
- `docs/planning-data/*.json`은 직접 런타임 입력이 아니다.
- 승인되지 않은 수치·규칙·콘텐츠 의미를 자동으로 런타임에 승격하지 않는다.

## 9. 구현 보호

승인된 BUILD 패키지 밖에서는 다음 제품 경로를 변경하지 않는다.

```text
data/
src/
scenes/
assets/
addons/
project.godot
```

- 구현은 격리 Branch/PR에서 수행한다.
- 변경 전 실패 회귀를 작성하고 RED를 확인한다.
- 최소 수정 뒤 GREEN과 전체 회귀를 확인한다.
- 저장·Schema·Scene 구조·대규모 이동·삭제는 별도 구현 PR을 사용한다.
- 삭제는 권한·고유 정보·활성 소비자·복구 경로 확인 없이 수행하지 않는다.

## 10. 검증 원칙

```text
contract-check
→ reference-freshness
→ syntax·static
→ automated tests
→ Godot headless
→ 적용 시 Windows·runtime·render
→ accessibility·performance
→ human playtest
→ regression
→ evidence-report
```

- 실행하지 않은 검증은 PASS로 표시하지 않는다.
- 파일 존재, 정적 검사, Actions, Godot headless, Windows 실제 실행, 접근성, 성능, 사람 플레이는 서로 다른 증거다.
- `MUST_FIX` 또는 필수 `BLOCKED_UNVERIFIED`가 남으면 완료를 과장하지 않는다.
- 병합 전 동일 HEAD, 필수 검사, unresolved thread 0, P0/P1 없음, 기획 충돌 없음이 필요하다.
- 위 조건을 만족한 non-Draft PR은 현재 Base 정책에 따라 담당 에이전트가 허용된 방식으로 병합한다.

## 11. 적대적 검토

```text
review-scope-map
→ attack
→ validate-critique
→ MUST_FIX / SHOULD_FIX / USER_DECISION_REQUIRED / DEFER
→ 승인된 최소 수정
→ regression-recheck
→ decision-report
```

변경 파일만 보지 않고 정본, 활성 소비자, 인접 시스템, 변경됐어야 할 untouched 파일, 테스트, Template, Sheet, 파생본을 연결한다.

## 12. 현재 다음 패키지

`VERTICAL_SLICE_APP_FLOW_SHELL`

- App Root·화면 상태 전환.
- Main Menu 저충실도 Shell.
- `RunSession`·`SaveService` 최소 계약.
- 시작 무공 6중4 선택 Shell.
- Route·Node·Briefing 저충실도 흐름.
- 기존 Combat PoC 진입·복귀.
- Result/Reward/Retry transaction Shell.
- 중복 입력·저장 실패·same-seed 재진입 회귀.

후보 15명 전체, 최종 아트·오디오, 주요 비무 6~10, 천하제일인은 포함하지 않는다.

## 13. 역사·호환

- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 계보다.
- PR #45는 v6 재설계 통합 이력이다.
- 과거 Base `c987647d01ad2baa028a16e03d85ddfc1572a727`와 v8 Prompt는 `HISTORICAL_COMPATIBILITY_BASELINE`이다.
- 현재 공용 Skill 권한은 `skills/PROJECT_BASE_ADAPTER.json`의 Base v9.1 release pin이다.
- Base v9.3 adoption은 별도 migration·검증 PR에서 수행한다.

## 14. `[보류]`

- 16권 절초의 개별 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 최종 아트·오디오 폴리싱.

`[보류]`는 구현 입력에서 제외한다.
