# 십보강호 협업 규칙

이 파일은 `alsdmlals4-eng/Ten-Paces-Hidden-Moves`의 최상위 작업 계약이다.

## 1. 우선순위

1. 사용자의 최신 확정 지시.
2. 보안·플랫폼 제약과 이 문서.
3. 현행 통합 작업계약 `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`과 Active Context.
4. 최신 날짜의 Decision과 등록된 분야 책임 원본.
5. 실제 코드·데이터·Scene·자산·테스트.
6. 프로젝트 Adapter에 고정된 Base 기준.
7. Base 원격 원본.
8. 과거 문서·PR·외부 사례·추정.

실제 구현과 승인 정본이 다르면 어느 한쪽을 자동으로 진실로 간주하지 않고 `CANON_CONFLICT`로 판정한다.

## 2. 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 파일·테스트·PR
```

- 현행 통합 작업계약: `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md` / `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`.
- Base Adapter: `skills/PROJECT_BASE_ADAPTER.json`.
- 프로젝트 Skill Registry: `skills/SKILL_REGISTRY.json`.
- Base 버전 정본: `docs/BASE_RULES_VERSION.md`.
- 백업·보류·과거 계획·전체 Skill 폴더를 기본 로드하지 않는다.

## 3. 현재 기준

변동이 잦은 활성 PR·exact head·승인 수·다음 Decision은 `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`만 책임진다. 이 진입 문서는 해당 값을 복제하지 않는다.

안정 기준:

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
runtime_work_mode: REVIEW
runtime_integration_pr: 65
planning_work_mode: PLAN
runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_MERGED
latest_combat_planning_runtime: PRODUCT_VALIDATION_AUTOMATED
design_platforms: WINDOWS_ANDROID
platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS
platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01
windows_runtime_evidence: CI_EXPORT_RUNTIME_PASS_LOCAL_NOT_RUN
android_runtime_evidence: NOT_RUN
base_release_pinned: 9.4.3
```

활성 기획 상태는 Active Context와 GitHub PR metadata를 함께 읽는다. Branch의 승인이나 PR 통과는 main 병합 완료가 아니며, 병합 후 main·Sheet 재조회 전에는 `SYNCED_TO_MAIN`으로 표시하지 않는다.

## 4. Work Mode·Skill Mode

- `PLAN`: 요구·근거·설계·순서·Decision 확정.
- `BUILD`: 승인된 패키지 구현.
- `REVIEW`: 적대적 검토·반례·검증·최소 수정.
- Registry trigger로 필요한 최소 Skill·Skill Mode만 사용한다.
- L1 이상 작업은 `기준 SHA / Work Mode / Skill / Skill Mode / 수행 / 결과 / 증거 / 미검증`을 `execution-report`에 기록한다.
- 정본·경로·ID·Schema 변경은 `reference-freshness`로 검사한다.

## 5. 프로젝트 코어

- 1대1 10칸 일자형 전장.
- 플레이어 4번·상대 7번 시작.
- 거리 0 `[밀착]`.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 추론.
- AI의 미확정 플레이어 계획 열람 금지.
- 덱·손패·드로우·장착 기술 제한 없음.
- 무공서가 아니라 현재 해금 기술을 수에 배치.
- 순차 `[합]`, 방어도, 회피, 중단, 강건, 복기.
- 성장은 판단을 대체하지 않고 파훼 선택지를 확장.

코어·Core Loop·주요 UX·콘텐츠 의미·저장 호환성을 바꾸는 변경은 새 Decision으로 승격한다.

## 6. 행동 선택 계약

Decision: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`.

- 출처는 `[기초] [무공] [절초]`.
- 무공서는 직접 배치하지 않는다.
- 현재 해금 기술을 가장 앞의 유효 연속 수에 자동 배치한다.
- 다중 수 행동은 `[전조] → [실행]` 연결 블록이다.
- 진행 전 이동·제거를 허용한다.
- 절초기세 5를 예약하고 진행 전 제거·이동에서 환불·재예약한다.
- 제품 P0에서 가상 `준비+막기/회피` 카드를 만들지 않는다.
- UI는 전투·보상·저장 규칙을 재계산하지 않는다.

## 7. 화면 구조 계약

Decision: `TEN-DEC-20260801-SITUATION-SCREEN-01`.

- 필수 화면: 메인 / 비무 / 무공 구성·자원 / 결과·복기·보상.
- P0 상황 10종을 별도 상태로 관리한다.
- Route와 Combat은 별도 Scene.
- Combat Review는 Combat Overlay.
- Duel Result는 별도 Scene.
- P0 Autoload 후보는 `RunSession`, `SaveService`.
- `CombatState`는 Combat Scene 소유.

## 8. 플랫폼 구조 계약

Decision: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`.

- Windows와 Android를 기본 설계 대상으로 유지한다.
- 전투 규칙·AI·콘텐츠·ID·수치·저장 Schema는 하나의 공유 코어를 사용한다.
- 플랫폼 차이는 입력, 반응형 UI·안전영역, 앱 생명주기·뒤로가기, 플랫폼 서비스, 품질·성능·export adapter에 한정한다.
- 핵심 규칙·데이터·저장 의미의 동등성을 요구하며 픽셀 동일 UI나 동시 출시를 요구하지 않는다.
- Android export·설치·실기기·터치·뒤로가기·pause/resume·suspend/restore·저장·성능 증거가 없으면 Android 런타임 지원 완료를 주장하지 않는다.
- 플랫폼 편의를 이유로 10칸·3/3/4·비공개 계획·순차 해결·복기 코어를 분기하지 않는다.

## 9. 정본·Sheet

- 한 질문에는 현재 책임 원본 하나만 둔다.
- 현행 전체 작업 방식·검증·병합·전달 계약은 `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`가 책임진다.
- 승인 Decision은 같은 ID로 Decision 문서, 분야 정본, planning JSON, Google Sheets에 연결한다.
- Google Sheets는 `USER_FACING_GDD_WORKSPACE`이며 GitHub 정본·실제 구현을 대체하지 않는다.
- Sheet 전용 변경은 `PROPOSED_SHEET_CHANGE`로 보존한다.
- `docs/planning-data/*.json`은 직접 런타임 입력이 아니다.

## 10. 구현·검증

제품 보호 경로:

```text
data/
src/
scenes/
assets/
addons/
project.godot
```

- 격리 Branch/PR에서 구현한다.
- 실패 회귀를 먼저 작성하고 RED를 확인한다.
- 최소 수정 뒤 focused test와 전체 회귀를 실행한다.
- 동일 HEAD, 필수 검사, P0/P1 없음, 미해결 thread 0 뒤 병합한다.
- 실행하지 않은 검증은 PASS로 표시하지 않는다.
- 자동 검증은 로컬 Windows 실제 렌더·실물 게임패드·실제 Android 기기·접근성 사용자·Release 성능·사람 플레이를 대체하지 않는다.

## 11. 적대적 검토

```text
review-scope-map
→ attack
→ validate-critique
→ finding 분류
→ 승인된 최소 수정
→ regression-recheck
→ decision-report
```

변경 파일뿐 아니라 정본, 활성 소비자, 인접 시스템, untouched 파일, 테스트, Sheet, 파생본을 확인한다.

## 12. 다음 패키지

`VERTICAL_SLICE_APP_FLOW_SHELL`

```text
App Root
→ Main
→ 시작 무공 6중4
→ Route·Node·Briefing
→ 기존 Combat
→ Result·Reward·Retry
```

후보 15명 전체, 최종 아트·오디오, 주요 비무 6~10, 천하제일인은 제외한다.

## 13. 역사·호환

- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 계보다.
- PR #45는 v6 계획 통합 이력이다.
- PR #92는 초기 10권 런타임·UI/AI·자동 제품 검증의 main 병합 계보다.
- `TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01`은 GUT 채택 당시의 역사적 통합 작업계약 증거이며 현행 작업계약은 v4.5 r2다.
- 과거 Base SHA `c987647d01ad2baa028a16e03d85ddfc1572a727`은 역사 회귀 증거다.
- 현재 Base 권한은 `skills/PROJECT_BASE_ADAPTER.json`의 Base v9.4.3 payload/evidence/finalization pin이다.
- Base release Commit은 운영 감사 증거이며 프로젝트 코어·제품 구현 권한을 변경하지 않는다.

## 14. `[보류]`

- 16권 절초 개별 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 최종 아트·오디오 폴리싱.

## 15. 플랫폼 출시·에셋 권리

출시·외부 자산·참조 기반 제작 작업은 다음 프로젝트 증거를 추가로 읽는다.

- `docs/PLATFORM_RELEASE_AND_ASSET_RIGHTS_PROFILE.md`
- `docs/ASSET_RIGHTS_AND_PROVENANCE_RECORD.md`
- `docs/GAME_RELEASE_COMPLIANCE_EVIDENCE_PACK.md`

Steam·STOVE·Google Play 후보 출시에서는 실제 build·store·trailer·questionnaire 일치와 shipping·marketing 자산 권리를 함께 검토한다. 원본 에셋을 조금 수정하거나 AI로 변환했다는 이유만으로 독립 자산으로 보지 않는다. 기능·구조·정보 위계·일반 제작 원리만 참조하고 `reference_brief`, `forbidden_expression`, 별도 `final_asset_record`, 유사성 검토를 남긴다.

필수 권리·계약·약관 버전·플랫폼 답변이 미확인이거나 실제 사용과 증빙이 다르면 `RELEASE_BLOCKED_UNVERIFIED`다. 자동 테스트와 Template 존재는 실제 자산 감사, 법률 검토, 플랫폼 제출 또는 최종 등급을 대체하지 않는다.