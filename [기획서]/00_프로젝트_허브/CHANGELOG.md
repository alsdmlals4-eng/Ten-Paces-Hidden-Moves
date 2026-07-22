# 십보강호 운영 변경 기록

## 2026-07-22 — P0-1 활성 전투 책임 원본 정렬

### 문제

Design Registry가 `ACTIVE`로 지정한 다음 문서에 실제 STEP 10.6과 충돌하는 과거 전투 규칙이 남아 있었다.

- `docs/01_GAME_DESIGN.md`
- `docs/02_COMBAT_RULES.md`
- `docs/05_COMBAT_POC_SPEC.md`

주요 충돌:

- 과거 2행동·2타이밍 묶음 구조
- A=4/B=6 시작 위치
- 행동력·내공 비용
- 합 수치 비교·차이 피해
- 한 칸 중첩·통과·자리 교환
- 현재 적을 정식 AI처럼 설명

### 정렬

- 전장 10칸, 플레이어 3번·상대 8번
- 라운드 `3수 → 3수 → 4수`, 총 10수
- 판정 `대응 → 속공 → 이동 → 일반 공격`
- 같은 공격 단계 동시 피해
- 기초 행동 8종과 정확한 비용·사거리·피해·회복
- 2슬롯 행동 마지막 점유 수 실행
- 이동 목적지·공격 방향 직접 지정
- 배치 즉시 자원 예상값과 진행 잠금
- 막기·회피·태세 결합 규칙
- 시작 체력·기력·내력 최대치와 `start_penalties`
- 현재 적은 고정 검증 계획
- STEP 11~14의 미구현 경계

과거 2행동·행동력·합 비교·중첩 이동 규칙은 삭제하지 않고 `HOLD`로 격리했다.

### 범위 재정의

- T0: 단일 전투 POC
- T1: 플레이 스타일 2개·상대 3명 내외·전투 3회 내외의 최소 세로 슬라이스
- T2: 5전 데모
- 전체판: 10전·12세력·무공·심법·절초·성장

대규모 콘텐츠는 T0 플레이 경험 검증 전 본격 확대하지 않는 게이트를 추가했다.

### 회귀 방지

- 세 책임 원본을 canonical reference freshness strict 대상에 포함
- 과거 시작 위치·2타이밍 묶음·행동 두 개 잠금·행동력 문장의 활성 재등장 차단
- `tests/check_canonical_combat_docs.py` 추가
- 문서와 카드·전장·HUD·판정 데이터의 양방향 계약 검사
- Card Component Contract Workflow에 문서 변경 경로·새 검사 추가

### 검증

- Documentation Governance run #380: `PASS`
- Card Component Contract run #407: `PASS`
- canonical combat docs vs runtime contract: `PASS`
- 이번 단계의 전투 코드·데이터·씬·자산 변경: 없음
- Godot 런타임 재실행: 불필요한 문서·정적 계약 변경이므로 `NOT_RUN`

### 다음

P0-2에서 UI·QA·아키텍처·연출 소비자 문서를 현재 규칙으로 정렬한다.

## 2026-07-22 — Base 통합·가지치기·적대적 개선

### 간소화

- Base 공유 Skill 13개는 유지하고 로컬 Skill을 프로젝트 고유 6개에서 4개로 축소.
- 공용 운영·인수·Health Review 로컬 복제를 Base 통합 Skill로 승계.
- 사용 불가능한 Project Skill Map·Publication Manifest 제거.
- 컨셉·벤치마크 템플릿 통합.
- 정본 최신성 감사 양식을 변경 검증 템플릿에 통합.
- 분리된 Governance 테스트 2개를 표준 라이브러리 회귀 테스트 1개로 통합.
- 중복 Governance checker 제거.
- 루트·허브·AGENTS·Workflow의 기본 읽기 경로 축소.

### 발행 계약 수정

- 실제 발행 생성기가 없음을 확인.
- 11개 기획 문서와 Skill Registry를 실행 가능한 `source_only`로 정렬.
- PDF가 필요한 마일스톤에서 생성기·폰트·Manifest·렌더·사용자 검수를 함께 설치하도록 변경.
- 가짜 `always_sync`·`milestone_sync` 현재 상태 제거.

### 적대적 검토

- 변경 전 `de9ad6e…`와 최적화 head를 비교해 운영 파일만 변경됐음을 확인.
- 전투 코드·데이터·씬·자산·제품 본책 변경 없음.
- Design Registry와 로컬 Schema의 정책 충돌 발견.
- Schema를 정책 기반 조건부 계약으로 수정하고 자동 검사 추가.
- 발행 정책 승격 시 생성기 파일 존재 검사 추가.

### 실패·개선 루프

1. README Base 버전 링크 누락 발견·복구.
2. 허브 Base 버전 경로 누락 발견·복구.
3. 루트 START_HERE Skill Registry 경로 누락 발견·복구.
4. AGENTS Skill Registry 경로 누락 발견·복구.
5. 수동 검토에서 Registry·Schema 충돌 발견·수정.
6. 운영 구조·정본 최신성·Skill 무결성·회귀 테스트 재통과.

### 삭제·승계

삭제된 항목은 Git 이력·Legacy Alias·통합 템플릿·Base 공유 Skill·자동 검사로 기능을 승계했다. 제품 기능·규칙·자산은 삭제하지 않았다.

### 미검증

- 사용자 로컬 미커밋 파일
- RESPONSE 10.6 최신 Godot 런타임
- PDF 발행 파이프라인
- 접근성 사용자 검수
- 목표 플랫폼 성능 프로파일
- 외부 POC 플레이테스트
- Branch protection Required Check 강제

## 2026-07-21 — Base latest main 전면 동기화

- Base를 `ee265576da7f67d3278f8099dd97d4e714ef0651`로 갱신.
- 이전 기준 이후 155개 커밋·70개 변경 파일 전수 판정.
- Work Mode `PLAN / BUILD / REVIEW`와 자동 Skill·Skill Mode 라우팅.
- L1 이상 실행 보고, reconciliation, 정본 최신성, Skill 무결성.
- 접근성·성능을 독립 검증 게이트로 분리.
- 현재 제품 Entry Point를 10칸·3/3/4·8개 기초 행동·STEP 10.6으로 정렬.
- 기존 본책·백업·보류·Plan·Godot 자산 비파괴 보존.

## 2026-07-21 — 전투 POC STEP 0~10.6

- 카드 UI·10칸 전장·배경·상단 HUD·10수 행동 슬롯.
- 기초 행동 8종·상세·로그·진행·배치.
- 이동 목적지·공격 방향·판정 엔진.
- 강공·보법·시작 자원 규칙.
- 막기·회피·태세 연계와 배치 즉시 자원 미리보기.
- 사용자 Windows에서 STEP 0~10·대상 지정 확인.
- 최신 대응·자원 보완 사용자 확인 대기.

## 2026-07-20 — Base schema v3 Governance foundation

- 루트 START_HERE와 프로젝트 허브.
- Design·Skill·Interview Registry.
- Development Gates·Update Matrix·Handoff·Decision·Health Report.
- 표준 라이브러리 Governance 검사와 GitHub Workflow.
- 기존 본책·백업·보류·Plan 비파괴 보존.
