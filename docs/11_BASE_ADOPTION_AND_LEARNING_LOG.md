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
→ 프로젝트 Skill 자동 라우팅
→ 책임 원본·실제 구현 감사
→ 변경 정본과 모든 활성 소비자 영향 지도
→ 비파괴 갱신·구형 원본 재분류
→ 정적·Godot·Windows·사용자 증거 분리
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
| 정본 최신성 | 변경 정본→활성 소비자→테스트→Workflow→Context 전파 확인 |
| 문서 생명주기 | Registry 책임·`source_only` 정책·중복 원본 방지 |
| 변경 검증 | 계약→실제 diff→정적→런타임→회귀→증거 보고 |
| 접근성 | 정보·입력·탐색·시간·난이도·모션 장벽과 대체 경로 |
| 성능 | 목표 플랫폼·동일 빌드·대표/최악 장면 baseline 비교 |

## 프로젝트 구체화

- `[강호낭인]`.
- 전장 10칸, 플레이어 4번·상대 7번 시작, 시작 거리 3.
- 라운드 `3수 → 3수 → 4수`, 총 10수.
- 판정 `대응 → 속공 → 이동 → 일반 공격`.
- 기초 행동 8종, 절초 기세 최대 5칸.
- 비용은 행동 슬롯·기력·내력.
- T0 단일 전투 → T1 최소 세로 슬라이스 → T2 5전 데모 → 전체 10전.
- UI·연출은 판정·보상·수련·저장을 확정하지 않음.

현재 PR #7은 Prototype다. STEP 0~10과 TARGETING 10.5는 기존 Windows 흐름이 확인됐고, 최신 HiGodot 런타임에서 플레이어 4번·상대 7번 시작, 4→5·7→6, RESPONSE·RESOURCE PREVIEW 10.6을 확인했다.

## 이번 시작 위치 변경의 Skill 실행

### 주 Discipline Skill

`combat-implementation-handoff: build/runtime-handoff`

- 전장 JSON을 먼저 수정.
- BoardPreview 계약 소비와 fallback을 함께 수정.
- Godot fixture와 Python 정적 계약을 같은 값으로 수정.
- 참조 SVG까지 갱신.
- 런타임을 실행하지 않은 상태는 `UNVERIFIED`로 유지.

### 프로젝트 보조 Skill

`ten-paces-game-design: rule-update`

- 시작 위치를 플레이어 4번·상대 7번으로 확정.
- 시작 거리 3이 첫 묶음 접근·대응·자원 선택에 주는 영향을 기획서에 기록.
- T0 현재 규칙과 T1 이후 성장 가설을 분리.

`ten-paces-verification: contract-check/regression/evidence-report`

- 4→5·7→6 통합 fixture.
- 4→6 보법 2칸.
- 시작 거리 3의 속공·강공 사거리 실패.
- 코드 fallback·Godot fixture·SVG·문서 일치 검사.

### Base Foundation Skill

- `managing-design-documents: update/restructure/validate`.
- `auditing-canonical-reference-freshness: impact-map/reference-scan/propagation-gap/closure-report`.
- `reviewing-and-validating-project-changes: contract-check/static-validation/regression/evidence-report`.

## 정본 최신성 감사에서 발견한 문제

### FIX_NOW

- 시작 위치가 데이터·코드·책임 원본·테스트·참조도에 분산됨.
- `docs/03_CONTENT_CATALOG.md`가 전체판 후보와 구형 규칙을 현재 T0처럼 설명함.
- `docs/06_STARTING_FACTION_MASTERY_DATA.md`가 미구현 성장 가설을 구형 비용·판정 기준으로 설명함.
- 구형 Context 파일이 현행 프로젝트 허브와 충돌하는 중복 활성 상태를 보유함.
- QA Skill과 Base 학습 기록이 구형 시작 위치를 보유함.

### 처리

- `docs/03`은 CURRENT_T0·PLANNED_T1·HYPOTHESIS·HOLD 카탈로그로 재구성.
- `docs/06`은 T1 이후 성장 가설로 재구성하고 현행 공용 필드만 사용.
- 구형 Context 파일은 독립 사실이 없는 `DEPRECATED_ENTRYPOINT`로 전환.
- 시작 위치 계약을 코드 fallback·Godot test·Python test·SVG까지 전파.
- 활성 정본 최신성 검사 범위를 문서·Skill·Entry Point까지 확대.

### ALLOWED_LEGACY

- Git 이력·과거 PR·Change Log의 당시 사실.
- `docs/[백업]/`, Git 이력과 과거 PR·Change Log의 역사 기록.

이력 경로의 과거 표현을 현재 규칙으로 강제 덮어쓰지 않는다.

## 통합·간소화 결과

### Skill

- 로컬 6개 → 4개.
- 삭제한 공용 복제는 Base intake·context/handoff·operating-system·change-validation·freshness가 승계.
- Legacy Alias와 forbidden path 검사로 호환·재등장 방지.

### 문서·발행

- 존재하지 않는 Skill Map PDF·Manifest 계약 제거.
- 실제 Design Document generator 부재 확인.
- 등록 문서와 Skill Registry를 `source_only`로 정렬.
- 발행이 필요한 마일스톤에 생성기·폰트·Manifest·렌더·사용자 검수를 함께 설치.

### 템플릿·검사

- 컨셉·벤치마크 템플릿 통합.
- 정본 최신성 감사를 변경 검증에 통합.
- Governance 회귀 테스트 통합.
- 기본 읽기 경로를 AGENTS·Context·Map 중심으로 축소.

## 프로젝트에만 남기는 정보

- 세계관·세력·무공·제약 이름.
- 전장·라운드·대회 구조와 전투 수치.
- 수련·행운·절초 확률.
- Godot 경로·GDScript·씬·데이터·테스트.
- 이명·풍문·정탐 문구와 상대 의미 키.

## Base 환류

```text
프로젝트 관찰·검증
→ 프로젝트 고유 값 분리
→ 기존 Base 중복·충돌 확인
→ Base 수정 제안
→ 사용자 승인
→ 별도 Base 구현
→ 프로젝트 Learning Log 갱신
```

사용자가 특정 Base 변경을 직접 승인한 경우에만 제안 단계를 생략한다.

## UI/UX 표현 갱신 기록 (2026-07-23)

- 사용자 승인에 따라 전장 배경과 양측 초상을 프로젝트 전용 ImageGen 자산으로 교체했다. 프롬프트·경로·라이선스는 `assets/ASSET_MANIFEST.json`에 기록했다.
- 사용자 제공 이미지는 수묵·석양·저대비·결투 구도라는 방향 참조이며, 원본을 복제하거나 런타임 자산으로 사용하지 않는다.
- 절초 목록은 플레이어 절초 기세 바로 아래로 이동했고, 키보드 카드→수 슬롯→대상 타일→진행 흐름과 간단한 이동·대기·공격 모션을 추가했다.
- Headless 정적·런타임 검증은 통과했고, 파공검기 처치의 `combat_ended`·전투 불능·입력 잠금·패배음 요청과 확정 기세/막기 SFX 요청도 검증했다. HiGodot Windows에서는 4/7 시작, 절초 목록 활성·예약·방향 입력, 대시 후 5·6번 위치, 수묵·금빛 VFX와 `사거리 실패` 결과, `소리:끔` → `소리:켬` 토글 텍스트, 진행 직후 `resolving`·`locked=true`와 카드 선택 핸들러 차단까지 확인했다. Windows AudioStreamWAV 재생·음소거 즉시 정지·PCM 음량 차이, Always Active UI Automation 노출과 DEBUG 대표/최악 성능 표본도 마감했다. 실제 보조기기 사용성·주관적 청취/모션과 Release 목표 사양은 계속 `NOT_RUN`이다.
- 활성 자산 매니페스트에서 한글 메타데이터가 깨지는 경우에도 제작 프롬프트·경로·라이선스·RGBA 투명도 감사가 추적 가능해야 한다. 따라서 매니페스트를 UTF-8 한글 역할명과 폴백 설명으로 정정하고, JSON 파싱·활성 RGBA 감사 상태를 다시 확인했다.
- 전장 인물은 단순 실루엣보다 10칸 거리 읽기를 해치지 않는 전신 수묵 원화가 적합했다. 크로마키 생성본과 RGBA 결과를 함께 매니페스트에 남기고, 실제 전장 발 앵커와 충돌하지 않는지를 자동·런타임 캡처로 모두 확인했다.
- 표준 Godot 컨트롤의 기본 포커스 표현은 수묵 UI 위에서 약할 수 있다. 전투 입력은 `focus` StyleBox를 명시적으로 덮어써야 Tab 경로가 흰 테두리와 면 변화로 보장된다.

## 전투 수 단위 중단·기세 경제 갱신 (2026-07-23)

- 피격 중단을 미래 행동 전체 취소로 두면 3/3/4 계획의 읽기 보상이 사라진다. 따라서 실제 피해는 같은 수의 아직 실행 전 행동만 취소하고, 같은 수의 공격은 합 또는 동시 피해로 끝까지 계산하며 이후 수 계획은 유지한다.
- 절초 기세는 단순 적중 보상보다 묶음 완료·막기·회피·합 승리처럼 수 읽기의 성공을 보상해야 한다. 시작값은 양측 0/5로 고정한다.
- 기세 5는 절초 선택 자격이다. 절초 3종은 기세 게이지 아래에 상시 유지해 선택지를 미리 읽게 하고, 기세 5·연속 빈 수 조건에서만 활성화해 결단의 문맥을 유지한다. 강공 선택은 절초 목록의 표시·선택 조건이 아니다.

## 검증 상태

확인:

- Base SHA·155개 커밋·70개 파일 처리표.
- Base 공유 Skill 13개·로컬 Skill 4개.
- Design·Skill Registry와 로컬 Schema 조건 일치.
- 과거 운영 구조·정본 최신성·Skill 무결성 Actions 성공.
- 시작 위치 4/7 데이터·코드·테스트·SVG·문서 변경.

확인 대기:

- 이번 변경의 최신 Actions.
- 회피·태세 결합과 자원 해제/부족 잠금의 최신 결과 UI.
- 현재 Issue #11 기술 범위에는 추가 대기 항목 없음. 주관적 품질 검수는 STEP 14로 이관.

미검증:

- 사용자 로컬 미커밋 파일.
- PDF 발행 파이프라인·전 페이지 시각 검수.
- 접근성 사용자 검수.
- 목표 플랫폼 성능 프로파일.
- 외부 POC 플레이테스트.
- Branch protection Required Check 강제.

## 후속 리뷰 조건

- Base SHA·Skill Registry·Schema 변경.
- 문서 정책을 `milestone_sync`로 승격.
- 정본·경로·ID·generator 변경.
- 전투 본책과 구현 불일치.
- 시작 위치·전장 크기·타이밍 구조 변경.
- 동일 stale reference·Skill 중복·콜드 스타트 실패.
- POC 플레이테스트 결과.
