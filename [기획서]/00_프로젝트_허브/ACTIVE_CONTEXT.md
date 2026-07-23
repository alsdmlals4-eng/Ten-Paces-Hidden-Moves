# 십보강호 활성 컨텍스트

## 현재 상태

- Work Mode: `REVIEW` — Issue #11 마감 증거와 활성 정본 최신성 확인을 마쳤고, 다음 POC 범위를 준비한다.
- Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 운영 PR: #5 `agent/base-full-11-migration`
- 전투 POC PR: #7 `agent/t0-combat-poc-board`
- 제품 단계: Prototype
- 구현: STEP 0~10, TARGETING 10.5, RESPONSE 10.6, RESOURCE PREVIEW 10.6
- 사용자 Windows 확인: 기존 STEP 0~10·행동 배치·이동 목적지·공격 방향
- 기술 Windows 확인: 플레이어 4번·상대 7번, 최신 대응 판정·자원 미리보기까지 완료. 실제 사용자 이해도·선호 검수는 STEP 14에서 별도로 수행.
- P0-1 핵심 책임 원본 정렬: 완료
- P0-2 연쇄 소비자 정렬: 완료
- P0-3 시작 위치·활성 원본 정리: 활성 소비자 감사 완료. 새 커밋 뒤 GitHub Actions 재실행은 별도 운영 Gate.

## 제품 계약

- `[강호낭인]`, 전장 10칸, 플레이어 4번·상대 7번 시작
- 시작 거리 3칸
- 라운드 `3수 → 3수 → 4수`, 총 10수
- 판정 `대응 → 속공 → 이동 → 일반 공격`
- 같은 단계 공격은 동시 피해
- 기초 행동 8종, 절초 기세 최대 5칸
- 비용은 행동 슬롯·기력·내력
- 덱·손패·행동력·공통 `막기 경감` 없음
- 현재 상대는 정식 AI가 아니라 고정 검증 계획
- Issue #11 피격 중단·강건·밀착·절초 3종·단계별 연출은 자동·Windows·UI Automation·DEBUG 성능 증거 `PASS`, 집중 제거

세부 규칙은 `docs/02_COMBAT_RULES.md`, 현재 POC 범위는 `docs/05_COMBAT_POC_SPEC.md`, 구현 사실은 `data/`, `scenes/`, `src/`, `tests/`가 책임진다.

## P0-1 — 핵심 책임 원본 정렬

완료:

- `docs/01_GAME_DESIGN.md`.
- `docs/02_COMBAT_RULES.md`.
- `docs/05_COMBAT_POC_SPEC.md`.
- 과거 전투 구조를 `HOLD`로 격리.
- 문서와 카드·전장·HUD·판정 데이터 계약 추가.

## P0-2 — 연쇄 소비자 정렬

완료:

- `docs/07_COMBAT_UI_SPEC.md`: 실제 Control 상태·문구·미구현 경계.
- `docs/08_TEST_CHECKLIST.md`: 자동·Godot·Windows·사용자 증거 분리.
- `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`: 실제 Dictionary POC와 목표 typed model 분리.
- `docs/10_COMBAT_PRESENTATION_PLAN.md`: 즉시 판정과 향후 단계별 연출 분리.
- canonical combat consumer 정적 계약 확대.

## P0-3 — 시작 위치 4/7·활성 원본 정리

### 구현 전파

- `data/combat/combat_board_poc.json`: 플레이어 4번·상대 7번.
- `CombatBoardPreview`: 현재값과 계약 누락 fallback 4번·7번.
- `tests/check_combat_board_contract.py`: 데이터·코드·Godot fixture·SVG 일치.
- `tests/verify_combat_board.gd`: 4→5·7→6 통합 판정.
- `tests/verify_response_rules.gd`: 4/7 독립 대응·자원 fixture.
- 배치 기준 SVG: 플레이어 4번·상대 7번.

### 책임 원본·소비자 전파

- `README.md`.
- `docs/01~11` 중 현재 전투·콘텐츠·성장·UI·QA·아키텍처·연출·학습 문서.
- 로컬 프로젝트 Skill 4개.
- Product Roadmap·QA 시나리오.

### 구형 활성 원본 처리

- `docs/03_CONTENT_CATALOG.md`: T0 현재·T1 계획·전체판 가설·HOLD로 재구성.
- `docs/06_STARTING_FACTION_MASTERY_DATA.md`: T1 이후 성장 가설로 재구성.
- 구형 Context 파일: 독립 제품 사실이 없는 `DEPRECATED_ENTRYPOINT`로 전환.
- 백업·보류·Plan·Git 이력은 역사 기록으로 보존.

### 적용 Skill

주 Skill:

- `combat-implementation-handoff: implementation-contract/build/runtime-handoff`.

프로젝트 보조 Skill:

- `ten-paces-game-design: rule-update/poc-contract`.
- `ten-paces-verification: contract-check/regression/evidence-report`.
- `combat-ux-and-accessibility: ui-contract/runtime-review`.

Base Foundation:

- `managing-design-documents: update/restructure/validate`.
- `auditing-canonical-reference-freshness: impact-map/reference-scan/propagation-gap/closure-report`.
- `reviewing-and-validating-project-changes: contract-check/static-validation/regression/evidence-report`.

## 최신 검증 상태

### 이전 통과 증거

- Documentation Governance run #387: `PASS`.
- Card Component Contract run #414: `PASS`.
- Base 13 route·로컬 4 Skill integrity: `PASS`.

### 이번 변경

- 시작 위치 4/7 데이터·코드·테스트·SVG 변경: 완료.
- 활성 문서·Skill·중복 Context 정리: 완료.
- 최신 canonical reference freshness·combat contract의 로컬 정적 검사는 통과했다. GitHub Actions 재실행은 현재 검증된 로컬 변경을 커밋·push한 뒤의 별도 운영 단계다.
- HiGodot Windows 런타임 4/7 렌더·판정: `PASSED` — 10칸 화면에서 플레이어 4번·상대 7번, 엔진 fixture의 4→5·7→6을 확인했다.
- 최신 RESPONSE·RESOURCE PREVIEW Godot headless와 HiGodot 런타임: `PASSED` — 같은 수 막기 피해 12→체력 24, 자원 미리보기 기력 5/5·내력 4/4를 확인했다.
- PDF 발행·외부 플레이테스트·Branch protection: `NOT_RUN`. Windows UI Automation 접근성 경로, 절차적 SFX 재생/음소거/음량, 대표·최악 장면 DEBUG 성능 표본은 확보했다. 실제 보조기기 사용성·주관적 음향/모션 평가와 Release 목표 사양은 STEP 14/배포 Gate에서 검수한다.

## 다음 작업

1. 검증된 로컬 변경을 하나의 의도적 커밋으로 정리하고 Draft PR #7을 갱신한 뒤, 해당 커밋의 GitHub Actions를 다시 실행한다.
2. PR #7의 base 브랜치(`agent/base-full-11-migration`) 통합 순서를 정리하고, main 대상 전환 뒤 Required Check/브랜치 보호 상태를 확인한다.
3. STEP 12 비치팅 최소 AI를 별도 Issue·Plan으로 구체화한다. AI는 플레이어의 비공개 예약을 읽지 않고 같은 카드·기세·슬롯·대상 규칙을 사용한다.
4. STEP 13 종료·재시작을 별도 Issue·Plan으로 구체화한다. 현재 `combat_ended` 잠금과 완전한 재시작 흐름을 혼동하지 않는다.
5. STEP 14에서 실제 플레이어의 전체 키보드/보조기기 사용성, 주관적 음향·모션 읽기성, Release 목표 사양 성능과 외부 POC 플레이테스트를 검수한다.

## 보호 범위

- 승인된 전투 규칙·UI·자산과 Godot 구현.
- 기존 `docs/01~11`, 백업·보류·Plan·PR·Git 이력.
- 성장·행운·12세력 구상은 삭제하지 않고 T1 이후 가설로 보존.
- 사용자 로컬 미커밋 변경.
- 실행하지 않은 검증의 미검증 상태.
# UI/UX와 단순 모션 갱신 (2026-07-23)

- 상태: `IMPLEMENTED_FOR_REVIEW`.
- 수묵 석양 전장·양측 초상은 프로젝트 전용 생성 자산이며, 추적 정보는 `assets/ASSET_MANIFEST.json`에 있다.
- 전장 위 전투원도 단순 도형 대신 강호낭인/무명 검객 전신 RGBA 원화를 사용한다. Godot 4.7 실제 창 캡처에서 4번·7번 타일의 발 앵커, 수묵 석양 배경, HUD·절초 목록·카드 계층과 함께 렌더됨을 확인했다.
- 표준 키보드 컨트롤은 흰색 2px 포커스 링을 사용한다. Windows 실제 창에 Tab 입력을 전달했고, headless에서는 절초·재생·모션·소리·음량·진행 컨트롤의 포커스 링 구성을 자동 확인했다.
- 절초 목록은 플레이어 절초 기세 아래에 표시한다. 기세 5, 빈 연속 수, 입력 잠금 상태가 선택 가능 여부를 결정한다.
- 행동은 `timing_results`를 따라 한 수씩 재생하며, 대기 호흡·이동·공격/절초의 단순 모션은 표현 전용이다.
- Headless: 구형 배경 활성 참조 제거, 키보드 카드→수 슬롯→대상→진행 흐름, 보드/절초 회귀는 통과했다.
- 2026-07-23 Godot 4.7 재검증: 프로젝트 파싱 및 STEP 0, 4/7·RESPONSE, 중단/강건/밀착/절초, 절초 UI, 전투 불능/SFX, `InputEventMouseButton` 기반 resolving 입력 잠금, 키보드, 960×640·1440×900 레이아웃, 밀착·절초 VFX·52개 로그 성능 테스트가 모두 통과했다. 전신 원화·표준 포커스 링 뒤 마지막 Headless 혼잡 표본은 평균 7.56ms/frame, static memory 90,063,941 bytes였다.
- 활성 자산 매니페스트의 한글 역할명·폴백 설명을 UTF-8로 바로잡았고, 수묵·금빛 RGBA VFX의 프롬프트·경로·투명도 검수·라이선스 정보를 유지했다.
- HiGodot Windows 런타임: 4/7 시작, 4→5·7→6, RESPONSE·RESOURCE PREVIEW, 절초 목록 활성·클릭 예약·방향 지정과 수묵·금빛 VFX/사거리 실패 결과/대시 후 5·6번 위치를 확인했다. 진행 직후 `resolving`·`locked=true`와 카드 선택 핸들러 차단, `Tab` 한 번의 1수 슬롯 포커스 테두리, `소리:끔` → `소리:켬` 토글 텍스트 상태와 대표 시작 장면 5개 표본 145 FPS·267 draw call·약 54.1MB video memory도 기록했다. 별도 Godot 4.7.1 DEBUG 프로세스의 대표 시작 장면은 창 준비 875ms, 5초 유휴 CPU 단일 코어 환산 122.62%, 작업 집합 약 243MB, 전용 메모리 약 310MB였다. 같은 RTX 3050 렌더러에서 밀착·파공검기 VFX·52개 로그 최악 장면은 120프레임 평균 17.11ms, 378 draw call, video memory 약 69.6MB를 기록했다. Windows `AudioStreamWAV` 재생·음소거 즉시 정지·PCM 음량 차이와 Always Active UI Automation 노출도 확인했다. 실제 보조기기 사용자의 전체 조작성·주관적 음향/모션 평가는 STEP 14까지 `NOT_RUN`이다.

# Issue #11 정본 갱신 (2026-07-23)

절초 3종·피격 중단·강건·밀착·전투 불능 결과 상태는 구현 및 자동 검증 완료다. `[집중]`은 제거했다. 절초 예약은 기세 5를 즉시 소비하되 `[진행]` 전 점유 수 슬롯 클릭 또는 Enter로 전체 예약을 취소해 기세 5를 돌려받으며, 진행 뒤 중단·실패는 환불하지 않는다. 대표 시작과 최악 절초/밀착 Windows 성능 표본은 확보했다. `즉시 완료`는 진행 중 절초 타이머도 다음 프레임에 취소하고, Tab은 카드→수 슬롯→대상 타일→진행→재생/음향 제어 순서로 회귀 검증했다. 같은 조작 요소에 한국어 Godot 접근성 이름·설명도 부여했고, Windows UI Automation 노출과 실제 AudioStreamWAV 재생도 확인했다. Issue #11의 기술 Gate는 마감됐고, 실제 보조기기 사용성·주관적 음향 평가는 STEP 14 품질 검수다. 상세 규칙은 `docs/02_COMBAT_RULES.md`를 따른다.

2026-07-23 마감 증거: 절차적 SFX는 Windows Godot 4.7.1에서 `AudioStreamWAV` 재생, 음소거 즉시 정지, PCM 기반 음량 조절까지 통과했다. `accessibility/general/accessibility_support=1`로 항상 활성화한 동일 Windows 창은 운영체제 UI Automation 트리에 행동 진행·수 슬롯·카드·절초 목록·재생/음향 제어를 한국어 이름과 역할로 노출했다. Issue #11은 구현·자동·Windows·UI Automation 증거 기준 `PASS`이며, 주관적 믹스 평가는 후속 플레이테스트다.
