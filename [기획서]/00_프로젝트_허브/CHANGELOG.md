# 십보강호 운영 변경 기록

## 2026-07-21 — Base latest main 전면 동기화

### 기준

- 이전 Base: `eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- 현재 Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 변경 집합: 155개 커밋·70개 파일

### 추가

- `BASE_MAIN_SYNC_AUDIT.md` 70파일 처리표
- Work Mode `PLAN / BUILD / REVIEW`
- Skill·Skill Mode 자동 라우팅과 실행 보고
- `skills/LEGACY_SKILL_ALIASES.md`
- 실행 보고·실행 순서·구형 파일 처리·컨셉·벤치마크·정본 최신성·변경 검증 템플릿
- `.github/reference-freshness.json`
- canonical reference freshness 검사·테스트
- Skill package integrity 검사·테스트
- 확장된 Documentation Governance Workflow

### 변경

- Base 기준 SHA와 루트·허브 시작 문서 갱신
- Skill Registry를 `automatic-trigger-match`로 전환
- 6개 프로젝트 활성 Skill에 Skill Mode와 현재 전투 상태 반영
- Governance 검사기를 정책 기반 발행·자동 라우팅 계약에 맞게 갱신
- README·Active Context·Roadmap·Gates를 현재 STEP 10.6 상태로 갱신
- 현행 제품 소개를 `3수 → 3수 → 4수`, 8개 기초 행동으로 정렬

### 보존

- 기존 `docs/01~11`, 백업·보류·Plan·PR·Git 이력
- 프로젝트 고유 세계관·수치·용어·Godot 경로
- 승인 UI·배경·카드·전투 구현
- 실행하지 않은 검증의 미검증 상태

### 검증

- Base 핵심 운영 원본과 13개 활성 Skill Registry 확인
- 이전 기준 이후 70개 변경 파일 전수 판정
- 정본 최신성·Skill 무결성·Governance 정적 검사 연결
- 최신 Actions 최종 확인 대기

### 미검증

- 사용자 로컬 미커밋 파일
- RESPONSE 10.6 최신 Godot 런타임
- PDF·DOCX·다이어그램·Manifest 실제 발행
- 접근성 사용자 검수
- 목표 플랫폼 성능 프로파일
- Branch protection Required Check 강제

## 2026-07-21 — 전투 POC STEP 0~10.6

- 카드 UI·10칸 전장·배경·상단 HUD·10수 행동 슬롯
- 기초 행동 8종·상세·로그·진행·배치
- 이동 목적지·공격 방향·판정 엔진
- 강공·보법·시작 자원 규칙
- 막기·회피·태세 연계와 배치 즉시 자원 미리보기
- 사용자 Windows에서 STEP 0~10·대상 지정 확인
- 최신 대응·자원 보완 사용자 확인 대기

## 2026-07-20 — Base schema v3 Governance foundation

- 루트 START_HERE와 프로젝트 허브
- Design·Skill·Interview Registry
- Development Gates·Update Matrix·Handoff·Decision·Health Report
- 표준 라이브러리 Governance 검사와 GitHub Workflow
- 기존 본책·백업·보류·Plan 비파괴 보존
