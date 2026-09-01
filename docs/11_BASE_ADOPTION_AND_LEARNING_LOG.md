# 십보강호 Base 적용·학습 순환 기록

> 책임: Base 공용 운영 계약을 십보강호에 적용한 차이·검증·프로젝트 고유 교훈·환류 조건  
> Base 버전 원본: `docs/BASE_RULES_VERSION.md`

## 1. 기준 정보

- current compatibility/adoption pin: `alsdmlals4-eng/Base@5adc196c0185951f50e49ab5e51586eff8d60886` (`v9.4.4`).
- current Base `main` observation for this audit: `19355b7ef065a21d0f2b685c7d9be64a4a3970f8`; this is audit evidence, not a permanent project pin.
- exact project audit baseline: `main@4032cf550295da6d55646a8fb64fb27acaf1ddc3`.
- current adaptation owner: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`.
- per-work proof: `docs/operations/2026-09-01_BASE_CURRENT_ADAPTER_WORK_CONTRACT_RECEIPT.json`.

이번 적용은 전투·Godot·asset 변경이 아니라 thin operating adapter 갱신이다. Base의 current project-start receipt, reuse-first, bounded hygiene, feature-level contract, conditional Blueprint, bounded runtime capture, active-surface correction을 십보강호의 repository-first 정본과 10개 game benchmark gate에 맞춰 연결한다.

## 2. 이번 Base 변화와 historical initial v9 adoption context

다음은 이전 Base refresh의 재현·학습 evidence다. current Base 또는 current project stage로 읽지 않는다.

- 당시 비교 기준: `alsdmlals4-eng/Base@41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 당시 범위: 6개 커밋·43개 변경 파일.
- 당시 전투 baseline: PR #7 `agent/t0-combat-poc-board@147a031c75e96bff170d7f99016beb9e85b12066`.
- 당시 정합화 branch: `agent/pr7-canonical-skill-refresh`.

역사 사례의 교훈은 current project owner와 actual implementation을 먼저 읽고 Base route를 선택한다는 점이다. Base Skill 전체를 기본 로드하거나 프로젝트에 복사하지 않는다.

## 3. 프로젝트 적용 구조

### Base 공유 Skill 25개

공용 운영·기획·검증 방법은 Base 원본을 라우팅한다. 프로젝트에 패키지를 복제하지 않는다.

### 프로젝트 고유 Skill 4개

- `ten-paces-game-design`.
- `combat-ux-and-accessibility`.
- `combat-implementation-handoff`.
- `ten-paces-verification`.

로컬 Skill은 십보강호 고유 규칙·UX·Godot 인수·반례만 소유한다. 현재 STEP 진행 상태는 Skill 본문에 복제하지 않고 Active Context와 제품 정본에서 읽는다.

## 4. 정본 최신화에서 발견한 문제

### 4.1 날짜별 보정 절

여러 활성 문서의 앞부분에는 구형 계약이 남고 하단의 날짜별 갱신 절만 최신이었다.

예:

- 한 칸 한 전투원 대 거리 0 `[밀착]`.
- 공동 목적지 양측 정지 대 공동 점유 허용.
- 높은 감소량 선택 대 방어도 차감 후 같은 수 반감.
- 고정 상대 plan 대 공개 상태 최소 AI.
- STEP 11~13 미구현 대 실제 구현·기술 검증.

처리:

- 현재 사실을 책임 절에 통합했다.
- 날짜별 보정 절을 제거했다.
- 과거 전문은 Git 이력·Change Log에서 찾도록 했다.
- stale 문장이 위에 남아 있으면 하단 보정 절이 있어도 freshness가 실패하는 반례를 추가했다.

### 4.2 구조화 계약 drift

- 실제 board JSON은 schema 16인데 freshness 설정은 15를 요구했다.
- 프로젝트 Registry는 이전 Base와 13개 공유 Skill을 고정했다.
- 검사기 두 곳도 같은 숫자를 하드코딩했다.

처리:

- `.github/reference-freshness.json`을 board schema·Base SHA·활성 Skill 집합의 단일 검사 계약으로 사용한다.
- 운영·Skill 검사기는 그 설정을 읽는다.
- schema·Base commit·route 누락/중복 반례를 자동 테스트에 추가했다.

### 4.3 Skill의 상태 복제

로컬 Skill에 특정 STEP·Issue·구현 상태를 직접 적어 빠르게 낡았다.

처리:

- Skill에는 책임·mode·사용 조건·절차·출력·금지만 남겼다.
- 현재 상태는 Active Context·본책·실제 파일을 읽는다.
- 프로젝트 코어·벤치마킹·구조 최적화는 최신 Base Skill로 라우팅한다.

### 4.4 생성 캐시 추적

`tools/__pycache__/*.pyc`가 PR에 포함돼 있었다.

처리:

- 추적된 캐시 3개를 제거했다.
- `.gitignore`에 `__pycache__/`, `*.py[cod]`를 추가했다.

## 5. 프로젝트 고유 계약

Base로 승격하지 않는다.

- `[강호낭인]`과 무협 세계관.
- 10칸·4/7·3/3/4.
- 합·밀착·중단·강건·필중·절초 3종 수치.
- 기초 행동·자원·기세 경제.
- 세력·무공·심법·제약 후보.
- Godot 경로·씬·자산·테스트·PR 상태.
- T0/T1/T2/10전 범위.

## 6. 공용화 가능한 관찰

다음은 Base BCP 후보이나 이번 프로젝트 작업에서 Base를 직접 수정하지 않는다.

1. 활성 문서에 날짜별 최신화 절을 계속 붙이면 상충 문장이 동시에 존재하므로, freshness는 최신 토큰 존재뿐 아니라 stale 토큰 부재를 검사해야 한다.
2. 외부 기준의 SHA·활성 ID 집합은 여러 검사기에 하드코딩하지 않고 하나의 구조화 설정에서 읽어야 한다.
3. 프로젝트 Skill은 현재 진행 상태를 복제하기보다 현재 상태 정본을 읽는 절차 router로 유지해야 한다.
4. 기준 브랜치 보존 작업은 exact SHA 분기와 보호 prefix diff 검사를 명시해야 한다.

환류 절차:

```text
프로젝트 관찰·반례·검증
→ 프로젝트 고유 값 제거
→ 기존 Base 중복·충돌 확인
→ BCP 작성
→ 사용자 승인
→ 별도 Base PR
→ 프로젝트 Learning Log 갱신
```

## 7. 검증 상태

```yaml
base_v944_compatibility_pin: PENDING_CURRENT_ADAPTER_PR
base_current_main_adaptation: PENDING_CURRENT_ADAPTER_PR
project_work_receipt: PENDING_VALIDATOR
local_skills_4: PRESERVED
product_code_data_scene_assets: OUT_OF_SCOPE_UNCHANGED
human_device_accessibility_release: NOT_RUN
```

Actions 성공 전에는 최신화 완료로 표시하지 않는다.

## 8. 후속 리뷰 조건

- Base SHA·Skill Registry·Skill coverage 변경.
- 전장·라운드·합·대응·절초·AI 계약 변경.
- 책임 원본·경로·ID·Schema 변경.
- 프로젝트 코어 승인 또는 재개방.
- STEP 14 실제 플레이 결과.
- T1 진입·발행 파이프라인·저장 Schema 도입.
