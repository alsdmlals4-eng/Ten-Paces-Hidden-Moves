# 십보강호 활성 컨텍스트

## 현재 상태

- Work Mode: `PLAN → BUILD → REVIEW`
- Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 운영 PR: #5 `agent/base-full-11-migration`
- 전투 POC PR: #7 `agent/t0-combat-poc-board`
- 제품 단계: Prototype
- 구현: STEP 0~10, TARGETING 10.5, RESPONSE 10.6, RESOURCE PREVIEW 10.6
- 사용자 Windows 확인: 기존 STEP 0~10·행동 배치·이동 목적지·공격 방향
- 사용자 확인 대기: 플레이어 4번·상대 7번, 최신 대응 판정, 자원 미리보기
- P0-1 핵심 책임 원본 정렬: 완료
- P0-2 연쇄 소비자 정렬: 완료
- P0-3 시작 위치·활성 원본 정리: 정적 검증 진행

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
- 피격 중단·집중·강건은 STEP 11 예정

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
- `docs/ACTIVE_CONTEXT.md`: 독립 제품 사실이 없는 `DEPRECATED_ENTRYPOINT`로 전환.
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
- 최신 canonical reference freshness·combat contract Actions: 실행 대기.
- 사용자 Windows 4/7 렌더·판정: `NOT_RUN`.
- 최신 RESPONSE·RESOURCE PREVIEW Godot: `UNVERIFIED`.
- PDF 발행·접근성·성능·외부 플레이테스트·Branch protection: `NOT_RUN`.

## 다음 작업

1. 최신 정본·전투 계약 Actions 실행·실패 개선 루프.
2. PR #7과 Change Log에 정적 증거 기록.
3. 사용자 GitHub Desktop Fetch/Pull.
4. Godot F5로 플레이어 4번·상대 7번과 4→5·7→6 판정 확인.
5. RESPONSE·RESOURCE PREVIEW 10.6 확인.
6. STEP 11 피격 중단·집중·강건.

## 보호 범위

- 승인된 전투 규칙·UI·자산과 Godot 구현.
- 기존 `docs/01~11`, 백업·보류·Plan·PR·Git 이력.
- 성장·행운·12세력 구상은 삭제하지 않고 T1 이후 가설로 보존.
- 사용자 로컬 미커밋 변경.
- 실행하지 않은 검증의 미검증 상태.
