# 십보강호 활성 컨텍스트

## 현재 상태

- Work Mode: `PLAN → BUILD → REVIEW`
- Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 운영 PR: #5 `agent/base-full-11-migration`
- 전투 POC PR: #7 `agent/t0-combat-poc-board`
- 제품 단계: Prototype
- 구현: STEP 0~10, TARGETING 10.5, RESPONSE 10.6, RESOURCE PREVIEW 10.6
- 사용자 Windows 확인: STEP 0~10·행동 배치·이동 목적지·공격 방향
- 사용자 확인 대기: 최신 막기·회피·태세 판정과 자원 미리보기
- P0-1 책임 원본 정렬: 완료
- P0-2 연쇄 소비자 정렬: 다음 작업

## 제품 계약

- `[강호낭인]`, 전장 10칸, 플레이어 3번·상대 8번
- 라운드 `3수 → 3수 → 4수`, 총 10수
- 판정 `대응 → 속공 → 이동 → 일반 공격`
- 같은 단계 공격은 동시 피해
- 기초 행동 8종, 절초 기세 최대 5칸
- 비용은 행동 슬롯·기력·내력
- 덱·손패·행동력·공통 `막기 경감` 없음
- 현재 상대는 정식 AI가 아니라 고정 검증 계획
- 피격 중단·집중·강건은 STEP 11 예정

세부 규칙은 `docs/02_COMBAT_RULES.md`, 현재 POC 범위는 `docs/05_COMBAT_POC_SPEC.md`, 구현 사실은 `data/`, `scenes/`, `src/`, `tests/`가 책임진다.

## P0-1 책임 원본 정렬 결과

다음 활성 책임 원본을 실제 STEP 10.6 구현과 대조해 전면 갱신했다.

- `docs/01_GAME_DESIGN.md`
- `docs/02_COMBAT_RULES.md`
- `docs/05_COMBAT_POC_SPEC.md`

정렬한 핵심:

- 과거 2행동 구조를 현행 `3수 → 3수 → 4수`로 교체
- 시작 위치를 플레이어 3번·상대 8번으로 통일
- 행동력·내공을 현행 비용에서 제거하고 행동 슬롯·기력·내력으로 통일
- 기초 행동 8종의 비용·사거리·피해·회복을 카드 데이터와 일치
- 막기·회피·태세 결합과 자원 미리보기를 구현값으로 기록
- 2슬롯 행동의 마지막 점유 수 실행을 명시
- 현재 적을 고정 fixture로 구분하고 정식 AI 완료 주장을 제거
- 피격 중단·AI·종료·플레이테스트를 STEP 11~14로 분리
- 과거 2행동·행동력·합 비교·중첩 이동은 `HOLD`로 격리
- T0·T1·5전 데모·전체판의 범위와 진입 조건 분리

## 정본 drift 방지

- `docs/01`, `docs/02`, `docs/05`를 canonical reference freshness의 strict 대상에 추가
- 과거 시작 위치·2타이밍 묶음·행동 두 개 잠금·행동력 설명의 재등장 차단
- `tests/check_canonical_combat_docs.py` 추가
- 문서와 전장·타이밍·HUD·카드·대응 데이터의 양방향 계약 검사
- Card Component Contract Workflow에 문서 변경 경로와 새 검사 연결

## Base 통합·최적화 결과

- Base 155개 커밋·70개 변경 파일 전수 감사
- Base 공유 Skill 13개 유지
- 로컬 Skill은 십보강호 고유 디자인·UX·Godot 구현·QA 4개만 유지
- 제거한 공용 로컬 Skill은 Base Skill·Legacy Alias로 승계
- 문서·Skill Registry는 실제 생성기가 없어 `source_only`
- Skill Map·가짜 Manifest·중복 checker·중복 테스트 제거
- 컨셉·근거·정본 최신성 템플릿 통합
- Design Registry와 Schema의 정책 충돌 수정
- 삭제 경로·stale 전투 표현·가짜 발행 상태 재등장 차단

상세 근거: `BASE_MAIN_SYNC_AUDIT.md`, `BASE_MAIN_SYNC_VERIFICATION.md`.

## 최신 검증 상태

- Documentation Governance run #380: `PASS`
- Card Component Contract run #407: `PASS`
- canonical combat docs vs runtime contract: `PASS`
- operating-system structure·Registry Schema: `PASS`
- canonical reference freshness·forbidden paths: `PASS`
- Base 13 route·로컬 4 Skill integrity: `PASS`
- 전투 코드·데이터·씬·자산 변경: 없음
- 최신 Godot 대응·자원 기능: `UNVERIFIED`
- PDF 발행·접근성·성능·외부 플레이테스트·Branch protection: `NOT_RUN`

## 다음 작업

### P0-2 — 연쇄 소비자 정렬

1. `docs/07_COMBAT_UI_SPEC.md`
2. `docs/08_TEST_CHECKLIST.md`
3. `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
4. `docs/10_COMBAT_PRESENTATION_PLAN.md`
5. 필요 시 `docs/03`, `docs/04`, `docs/06`의 현재 규칙 참조
6. 연쇄 소비자 stale 검사와 Actions

현재 확인된 주요 drift:

- UI 문서의 기초 행동 7종 표기
- UI 문서의 현재 합 예상·피격 중단 완료 표현
- QA 문서의 A=4/B=6·2타이밍 묶음·합·행동력 테스트
- 아키텍처·연출 문서의 과거 판정·이벤트 계약 가능성

P0-2가 끝난 뒤 RESPONSE·RESOURCE PREVIEW 10.6 Windows 확인과 STEP 11로 진행한다.

## 보호 범위

- 승인된 전투 규칙·UI·자산과 Godot 구현
- 기존 `docs/01~11`, 백업·보류·Plan·PR·Git 이력
- 성장·행운·12세력 구상은 삭제하지 않고 T1 이후 가설로 보존
- 사용자 로컬 미커밋 변경
- 실행하지 않은 검증의 미검증 상태
