# 십보강호 협업 규칙

이 파일은 `alsdmlals4-eng/Ten-Paces-Hidden-Moves`의 repository-wide **항상 적용되는 프로젝트 불변식**만 소유한다. 변동 상태와 Base 상세 playbook을 여기에 복제하지 않는다.

## 1. 권위·시작 순서

```text
사용자의 최신 명시 지시
→ 보안·플랫폼 제약 + 이 AGENTS.md
→ docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
   / TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ current planning JSON + GitHub live metadata + exact Project Notion
→ 최신 관련 Decision + 질문별 책임 원본
→ 실제 code/data/scene/resource/asset/test/runtime
→ 프로젝트 compatibility/adoption pin
→ 최신 Base completed main의 필요한 owner
→ 검증된 외부 근거 → 추론 → 역사 자료
```

실제 구현과 승인 정본이 다르면 자동으로 한쪽을 진실로 만들지 않고 `CANON_CONFLICT`로 판정한다.

## 2. DOMAIN SPLIT

- `NOTION_DEFAULT_PROJECT_WORKSPACE` / `NOTION_HUMAN_FACING_CANON`: 사람이 읽고 비교·수정하는 Project Home, Flow/Storyboard, Visual, 세계관·캐릭터·핵심 시스템 설명, 핵심 표.
- `REPOSITORY_STRUCTURED_CANON` / `REPOSITORY_RUNTIME_TRUTH`: Markdown, JSON, game data, code, Scene, Resource, tracked asset, tests, CI, runtime evidence.
- Google Sheets: `MIGRATION_ONLY_UNTIL_REMOVAL`. 고유 미이관 자료를 찾는 compatibility source이며 신규 기획·승인·current state 작업면이 아니다.

## 3. Mutable state

활성 PR·exact HEAD·현재 Work Mode·제품 단계·구현 상태·승인 수·다음 package/Decision·device/Human evidence는 `ACTIVE_CONTEXT.md`, current structured JSON, GitHub metadata, exact Project Notion에서 fresh-read한다. 이 AGENTS에 mutable snapshot을 고정하지 않는다.

## 4. Work Mode·Skill

- `PLAN`: 요구·근거·대안·설계·Decision.
- `BUILD`: 승인된 범위의 구현.
- `REVIEW`: 정본·실제 변경·untouched consumer·test·readback을 적대적으로 검토.
- Registry trigger로 필요한 최소 Skill과 **Skill Mode**만 사용한다.
- L1 이상 작업은 `기준 SHA / Work Mode / Skill / Skill Mode / 수행 / 결과 / 증거 / 미검증`을 `execution-report`에 남긴다.
- 경로·ID·Schema·정본 변경은 `reference-freshness`로 활성 consumer와 파생본을 확인한다.
- `진행해`/`계속해`는 이미 승인된 같은 계약의 continuation이며 새 코어·범위·비용 권한을 만들지 않는다.

## 5. 프로젝트 코어

- 1대1 10칸 일자형 논리 전장.
- 시작 공개 거리 2, 거리 0 `[밀착]`.
- 플레이어 화면은 절대 번호보다 `거리 N` 중심.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 추론.
- AI는 플레이어의 미확정 계획·숨은 기술 배치·UI 의도 신호를 읽지 않는다.
- 덱·손패·드로우·장착 기술 제한 없음.
- 무공서가 아니라 현재 해금 기술을 수에 배치.
- 순차 `[합]`, 방어도, 회피, 중단, 강건, 복기.
- 성장은 판단을 대체하지 않고 파훼 선택지를 확장한다.

코어·Core Loop·주요 UX·콘텐츠 의미·저장 호환성을 바꾸는 변경은 새 Decision으로 승격한다.

## 6. 행동 선택·화면·플랫폼 보호

- 행동 선택 Decision: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`.
- 화면 구조 Decision: `TEN-DEC-20260801-SITUATION-SCREEN-01`.
- 플랫폼: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01` + 단일 공유 코어/플랫폼 Adapter.
- Android 실제 export·설치·실기기·터치·back·safe-area·lifecycle·저장·성능 evidence가 없으면 Android 런타임 지원 완료를 주장하지 않는다.
- UI는 전투·보상·저장 규칙을 재계산하지 않는다.

## 7. 구현·검증

제품 보호 경로:

```text
data/
src/
scenes/
assets/
addons/
project.godot
```

- 격리 Branch/PR에서 구현한다. direct main push, force push, ruleset/admin bypass는 금지한다.
- 코드·정책·계약 동작 변경은 실패 회귀를 먼저 작성하고 RED를 확인한 뒤 최소 GREEN과 관련 회귀를 수행한다.
- 자동 검증은 로컬 Windows visible, 실물 게임패드, 실제 Android 기기, 접근성 사용자, Release 성능, 사람 플레이를 대체하지 않는다.
- 실행하지 않은 검증은 `NOT_RUN` 또는 `BLOCKED_UNVERIFIED`다.

## 8. Open PR·동시성

- pre-existing open/draft/ready PR은 `READ_ONLY`가 기본이다.
- 다른 채팅/작업자의 PR·branch·path를 takeover하지 않는다.
- current-task PR만 latest-main reconciliation → exact HEAD → required checks → review/thread/ruleset → safe merge → postmerge main readback까지 현재 승인 범위에서 진행할 수 있다.

## 9. 시각 자산

새 이미지 생성·스타일 변경은 `canon review → text brief → 사용자 명시 승인 → 정확히 1개 결과 → 사용자 검토` 순서다. reference-only/chat exploration을 승인 자산으로 승격하지 않는다. 승인 Visual의 Notion 전달은 실제 attach + destination readback이 필요하다.

## 10. 역사·호환

- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 계보다.
- PR #45는 v6 계획 통합 이력이다.
- PR #65는 ActionSelectionDock/화면 구조 구현 이력이다.
- PR #92는 초기 10권 무공 런타임·UI/AI·자동 제품 검증 이력이다.
- `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`은 `SUPERSEDED_HISTORICAL_EVIDENCE`다.
- Base v9.4.3 payload/evidence/finalization pin은 과거 프로젝트 채택·회귀 증거이며 current Base remote truth가 아니다.

과거 Decision·review·snapshot의 당시 사실은 보존하되 current authority로 재사용하지 않는다.
