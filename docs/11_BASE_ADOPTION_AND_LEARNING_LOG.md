# 십보강호 Base 적용·학습 순환 기록

> 상태: 활성 인수 문서  
> 목적: Base 공용 운영 계약을 십보강호에 적용한 차이, 프로젝트 고유 값, 검증 결과와 Base 제안 상태를 기록한다. Base 원본이나 제품 본책 전문을 복제하지 않는다.

## 기준 정보

- Base 저장소: `alsdmlals4-eng/Base`
- 이전 기준: `eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- 현재 기준: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 동기화 날짜: `2026-07-21`
- 비교: 155개 커밋·70개 변경 파일
- 상세 처리표: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`
- 버전 원본: `docs/BASE_RULES_VERSION.md`

## 적용 흐름

```text
Base START_HERE·AGENTS·OPERATING_MODEL
→ WORK_MODE_AND_SKILL_ROUTING
→ DOCUMENTATION_MAP·SKILL_REGISTRY
→ 기존 기준 이후 변경 파일 전수 비교
→ 프로젝트 책임 원본·실제 구현·PR 감사
→ 공용 계약과 프로젝트 고유 값 분리
→ 승인 범위 운영 파일 갱신
→ reference-freshness·Skill integrity·Governance
→ PR·Context·Roadmap·Learning Log
```

## 최신 Base에서 적용한 공용 계약

| Base 계약 | 프로젝트 적용 |
|---|---|
| Work Mode | `PLAN / BUILD / REVIEW` |
| 자동 Skill 라우팅 | Registry trigger와 비사용 조건으로 최소 Skill·Skill Mode 자동 선택 |
| 실행 보고 | L1 이상 이유·수행·결과·증거·미검증 기록 |
| 통합 Skill | 13개 Base Skill을 공용 경로로 참조하고 프로젝트 Skill 6개에 분화 |
| Legacy Alias | 제거된 구형 ID를 현재 Skill·mode에 연결 |
| 안전 마이그레이션 | `audit → reconcile-legacy → 승인된 migrate → verify` |
| 정본 최신성 | 변경 정본과 expected-but-untouched 소비자·테스트·파생본 확인 |
| 정책 기반 발행 | `source_only / milestone_sync / always_sync` |
| Skill 무결성 | Registry·SKILL.md·Learning Log·entrypoint 연결 검사 |
| 접근성 | 실제 정보·입력·탐색·시간·난이도·모션 장벽과 대체 경로 |
| 성능 | 목표 플랫폼·동일 빌드·대표·최악 장면의 baseline 비교 |
| 실행 순서 | 결과·입력·파일·의존성·완료·검증·롤백 |
| 조사·PoC | 제품 사실·자기보고·행동 근거·해석 분리, ADOPT/ADAPT/AVOID/TEST/IGNORE |

## 프로젝트에 맞게 구체화한 규칙

### 제품 구조

- `[강호낭인]` 플레이어 정체성
- 전장 10칸, 플레이어 3번·상대 8번
- 라운드 `3수 → 3수 → 4수`, 총 10수
- 판정 `대응 → 속공 → 이동 → 일반 공격`
- 기초 행동 8종
- 절초 기세 최대 5칸
- 데모 1~5전, 전체 10전

### 상태·표현 경계

```text
전투·성장·AI 내부 상태
→ 의미 기반 이벤트·표현 요청
→ UI·VFX·오디오·문구
```

UI·연출은 판정·보상·수련·저장을 확정하지 않는다. 상대 내부 프로필과 플레이어용 이명·풍문·전적·정탐은 의미 키로 연결한다.

### POC와 Vertical Slice

- 현재 PR #7은 전투 Prototype다.
- STEP 0~10과 TARGETING 10.5는 사용자 Windows에서 부분 검증됐다.
- RESPONSE 10.6과 RESOURCE PREVIEW 10.6은 구현됐으나 최신 사용자 런타임 확인 대기다.
- 5전 데모 완주·외부 플레이·목표 품질·제작 파이프라인·접근성·성능은 Vertical Slice 게이트다.

## 프로젝트에만 남기는 정보

- 프로젝트명·세계관·세력·무공·제약 이름
- 전장 10칸·3/3/4·대회 10전
- 전투 카드·비용·피해·방어·회피·태세 연계 수치
- 수련 포인트·행운 결과표·절초 목표 확률
- Godot 버전·경로·GDScript·씬·데이터·테스트
- 이명·풍문·정탐 원문과 상대 의미 키

## Base로 자동 승격하지 않는 계약

```text
프로젝트 관찰·검증
→ 프로젝트 고유 값 분리
→ 기존 Base 중복·충돌 확인
→ Base [수정제안서] 제안 전용 PR
→ 사용자 검토·구현 승인
→ 별도 Base 구현 PR
→ 프로젝트 Learning Log 갱신
```

사용자가 특정 Base 변경을 직접 승인한 경우에만 제안 단계를 생략할 수 있다.

## 이번 동기화에서 추가한 프로젝트 산출물

- `BASE_MAIN_SYNC_AUDIT.md`
- `skills/LEGACY_SKILL_ALIASES.md`
- Work Mode·Skill Mode가 적용된 `SKILL_REGISTRY.json`
- 실행 보고·실행 순서·reconciliation·컨셉·벤치마크·검증 템플릿
- `.github/reference-freshness.json`
- `tools/check_canonical_reference_freshness.py`
- `tools/check_skill_package_integrity.py`
- reference freshness·Skill integrity 테스트
- 확장된 Documentation Governance Workflow

## 검증 상태

확인됨:

- Base 최신 기준 SHA와 변경 집합
- Base 핵심 책임 원본과 13개 활성 Skill Registry
- 70개 변경 파일의 프로젝트 적용 판정
- 기존 제품 본책·백업·보류·Plan 비삭제
- 현재 제품 Entry Point의 10수·8개 기초 행동 상태 갱신

진행 중:

- 최신 Governance·reference-freshness·Skill integrity Actions
- PR #5·#7 체크리스트 갱신
- 스택 브랜치 운영 파일 동일화

미검증:

- 사용자 로컬 미커밋 파일
- RESPONSE 10.6 최신 Godot 런타임
- PDF·DOCX·다이어그램·Manifest 실제 발행
- 접근성 사용자 검수
- 목표 플랫폼 성능 프로파일
- Branch protection Required Check 강제

## 후속 리뷰 조건

- Base SHA 변경
- Work Mode·Skill Registry·Schema 변경
- 정본·경로·ID·발행 정책·생성기 변경
- 전투 본책과 구현의 불일치
- POC 플레이테스트 결과
- 동일 stale reference 또는 Skill 패키지 결함 반복
