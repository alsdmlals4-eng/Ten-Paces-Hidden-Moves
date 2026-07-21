# 십보강호 운영 변경 기록

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
