# 십보강호 Base 적용·학습 순환 기록

> Base 공용 운영 계약을 십보강호에 적용한 차이, 프로젝트 고유 값, 검증 결과와 환류 조건을 기록한다. Base 원본이나 제품 본책 전문을 복제하지 않는다.

## 기준 정보

- Base: `alsdmlals4-eng/Base@ee265576da7f67d3278f8099dd97d4e714ef0651`
- 이전 기준: `eb40b912e5f5a0e4d369105a4f0a770e0a6179a9`
- 비교: 155개 커밋·70개 변경 파일
- 전수 감사: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`
- 적대적 검증: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_VERIFICATION.md`
- 버전 원본: `docs/BASE_RULES_VERSION.md`

## 적용 흐름

```text
Base canonical 읽기
→ 70개 변경 파일 전수 판정
→ 프로젝트 책임 원본·실제 구현 감사
→ 공용 기능과 프로젝트 고유 기능 분리
→ 비파괴 적용
→ 가지치기·통합·Schema 대조
→ 정본 최신성·Skill 무결성·회귀
→ PR·Context·Roadmap·Learning Log
```

## 적용한 Base 공용 계약

| Base 계약 | 프로젝트 적용 |
|---|---|
| Work Mode | `PLAN / BUILD / REVIEW` |
| 자동 라우팅 | trigger·비사용 조건으로 최소 Skill·Skill Mode 선택 |
| 실행 보고 | L1 이상 이유·수행·결과·증거·미검증 기록 |
| 공유 Skill | Base 13개를 `shared_skill_routes`에 등록 |
| 프로젝트 Skill | 십보강호 고유 디자인·UX·Godot·QA 4개만 유지 |
| Legacy Alias | 제거된 Base·로컬 ID를 현재 Skill·mode에 연결 |
| 안전 정리 | `audit → reconcile-legacy → 승인된 변경 → verify` |
| 정본 최신성 | changed와 expected-but-untouched 소비자·Schema·Workflow 확인 |
| 문서 발행 | 현재 생성기 부재로 모두 `source_only` |
| Skill 무결성 | Registry·SKILL.md·mode·Learning Log·entrypoint 검사 |
| 접근성 | 정보·입력·탐색·시간·난이도·모션 장벽과 대체 경로 |
| 성능 | 목표 플랫폼·동일 빌드·대표/최악 장면 baseline 비교 |
| 실행 순서 | 결과·입력·파일·의존성·완료·검증·롤백 |
| 조사·PoC | 제품 사실·자기보고·행동 근거·해석 분리 |

## 프로젝트 구체화

- `[강호낭인]`
- 전장 10칸, 플레이어 3번·상대 8번
- 라운드 `3수 → 3수 → 4수`, 총 10수
- 판정 `대응 → 속공 → 이동 → 일반 공격`
- 기초 행동 8종, 절초 기세 최대 5칸
- 데모 1~5전, 전체 10전
- UI·연출은 판정·보상·수련·저장을 확정하지 않음

현재 PR #7은 Prototype다. STEP 0~10과 TARGETING 10.5는 사용자 Windows에서 확인됐고 RESPONSE·RESOURCE PREVIEW 10.6은 최신 사용자 런타임 확인 대기다.

## 통합·간소화 결과

### Skill

- 로컬 6개 → 4개.
- 삭제한 공용 복제:
  - `project-operations-and-handoff`
  - `project-health-review`
- Base intake·context/handoff·operating-system·change-validation·freshness가 기능을 승계.
- Legacy Alias와 forbidden path 검사로 호환·재등장 방지.

### 문서·발행

- 존재하지 않는 Skill Map PDF·Manifest 계약 제거.
- 존재하지 않는 Design Document generator를 발견.
- 11개 문서와 Skill Registry를 `source_only`로 정렬.
- 발행이 필요한 마일스톤에 생성기·폰트·Manifest·렌더·사용자 검수를 함께 설치.

### 템플릿·검사

- 컨셉·벤치마크 → `GAME_CONCEPT_AND_EVIDENCE_REVIEW.md`.
- 정본 최신성 감사 → `PROJECT_CHANGE_VALIDATION.md`.
- 회귀 테스트 2개 → `test_project_governance.py`.
- 중복 checker 제거.
- 기본 읽기 경로를 AGENTS·Context·Map 중심으로 축소.

### 적대적 검토 발견

- Registry는 `source_only`인데 로컬 Design Registry Schema가 `always_sync`를 강제하는 모순 발견.
- 세 발행 정책의 조건부 Schema로 수정.
- `source_only` 파생 필드 null·diagram none 강제.
- 발행 정책 승격 시 generator 파일 존재 검사 추가.

## 프로젝트에만 남기는 정보

- 세계관·세력·무공·제약 이름
- 전장·라운드·대회 구조와 전투 수치
- 수련·행운·절초 확률
- Godot 경로·GDScript·씬·데이터·테스트
- 이명·풍문·정탐 문구와 상대 의미 키

## Base 환류

```text
프로젝트 관찰·검증
→ 프로젝트 고유 값 분리
→ 기존 Base 중복·충돌 확인
→ Base 수정제안 PR
→ 사용자 승인
→ 별도 Base 구현 PR
→ 프로젝트 Learning Log 갱신
```

사용자가 특정 Base 변경을 직접 승인한 경우에만 제안 단계를 생략한다.

## 검증 상태

확인:

- Base SHA·155개 커밋·70개 파일 처리표
- Base 공유 Skill 13개·로컬 Skill 4개
- Design·Skill Registry와 로컬 Schema 조건 일치
- 운영 구조·정본 최신성·Skill 무결성·회귀 테스트 Actions 성공
- 제품 본책·백업·보류·Plan·Godot 구현 비삭제
- 전투 코드·데이터·씬·자산 비침범

미검증:

- 사용자 로컬 미커밋 파일
- RESPONSE 10.6 최신 Godot 런타임
- PDF 발행 파이프라인·전 페이지 시각 검수
- 접근성 사용자 검수
- 목표 플랫폼 성능 프로파일
- 외부 POC 플레이테스트
- Branch protection Required Check 강제

## 후속 리뷰 조건

- Base SHA·Skill Registry·Schema 변경
- 문서 정책을 `milestone_sync`로 승격
- 정본·경로·ID·generator 변경
- 전투 본책과 구현 불일치
- 동일 stale reference·Skill 중복·콜드 스타트 실패
- POC 플레이테스트 결과
