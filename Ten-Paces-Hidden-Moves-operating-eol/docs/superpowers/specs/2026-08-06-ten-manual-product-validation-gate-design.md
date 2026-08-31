# 초기 10권 제품 검증 Gate 설계

> Decision: `TEN_MANUAL_PRODUCT_VALIDATION_GATE`  
> 상태: `USER_APPROVED_RECOMMENDED_APPROACH_AWAITING_WRITTEN_SPEC_REVIEW`  
> 승인 근거: 사용자의 직접 지시 — `권장안대로 진행`  
> 기준 PR: Draft PR #92  
> 기준 제품 SHA: `8832d0f54062ce999a5a9c5238f704854f96a0b1`  
> 부모 PR #91 SHA: `ffdbd385abb75b0f314400601c7a3120acc616e9`

## 1. 목적

`TEN_MANUAL_UI_AI_ADOPTION_GATE`에서 초기 무공서 10권은 레지스트리·행동 선택 UI·공개 상태 적 AI·묶음 전투 해결기에 연결되었다. 다음 단계는 기능이 존재한다는 주장과 실제 제품 검증 증거를 분리하고, 자동화 가능한 PC 제품 검증을 재현 가능한 형태로 닫는 것이다.

이 Gate는 다음 질문에 답한다.

1. 정확한 Git SHA에서 Windows용 PC 빌드를 재현할 수 있는가?
2. 무공서 10권의 3·5·7·9·10성 성취도가 제품 UI에서 보이고 실제 전투 해결까지 이어지는가?
3. 1280×800·1440×900·1920×1080에서 핵심 UI가 잘리거나 포커스를 잃지 않는가?
4. 키보드·마우스 합성 입력으로 핵심 선택 흐름을 완료할 수 있는가?
5. 성능·접근성·사람 이해도에서 무엇을 실제로 검증했고 무엇이 아직 미실행인가?

## 2. 접근안 비교와 채택

### A. 증거 우선형 — 채택

현재 기능과 수치를 고정하고 Windows 빌드·런타임 smoke·해상도·합성 입력·성능 기초 계측·접근성 자동검사·STEP 14 기록 구조를 먼저 만든다. 실제 증거가 존재하는 축만 승격하며 사람·실기기·Release 성능은 실행 전까지 `NOT_RUN`으로 유지한다.

장점:

- 자동검증 성공을 사람 검증 성공으로 오인하지 않는다.
- 같은 exact SHA에서 빌드·실행·증거를 재현할 수 있다.
- 밸런스 변경 전에 제품 연결 결함을 먼저 제거한다.
- 실패가 빌드·런타임·UI·입력·성능·사람 중 어느 축인지 분리된다.

### B. 자동 밸런스 시뮬레이션 우선 — 보류

다수 AI 전투로 승률·선택률·자원 포화를 빠르게 수집할 수 있으나, 실제 UI 이해·입력·Windows 실행 결함을 가릴 수 있다. 제품 검증 Gate 이후 별도 `TEN_MANUAL_BALANCE_MEASUREMENT_GATE` 후보로 유지한다.

### C. 사람 테스트 우선 — 현재 단독 채택 불가

사람 이해도를 가장 직접적으로 확인하지만, 고정 Windows 배포본·환경 기록·참가자 증거 없이 시작하면 결과를 재현할 수 없다. STEP 14는 이번 Gate에서 재활성화하되 실행 결과는 실제 참가자가 생기기 전까지 `NOT_RUN`이다.

## 3. 제품 검증 상태 모델

검증 축을 하나의 PASS 문자열로 합치지 않는다.

```yaml
canonical_contract: PASS | FAIL
static_validation: PASS | FAIL
ubuntu_godot_headless: PASS | FAIL
windows_export: PASS | FAIL | BLOCKED
windows_ci_runtime: PASS | FAIL | BLOCKED
windows_local_render: NOT_RUN | PASS | FAIL
keyboard_synthetic: PASS | FAIL
mouse_synthetic: PASS | FAIL
gamepad_physical: NOT_RUN | PASS | FAIL
resolution_matrix: PASS | FAIL
accessibility_automated: PASS | FAIL
accessibility_user: NOT_RUN | PASS | FAIL
performance_baseline: CAPTURED | FAIL | NOT_RUN
release_performance: NOT_RUN | PASS | FAIL
human_step14: NOT_RUN | PASS | FAIL
product_gate: PARTIAL_AUTOMATED_COMPLETE | PASS | FAIL | BLOCKED
```

이번 구현에서 허용되는 최고 상태는 사람·로컬 Windows·Release 성능을 실행하지 않은 경우 `PARTIAL_AUTOMATED_COMPLETE`다. `PASS`, `T1_GREENLIGHT`, `MVP_COMPLETE`, Draft 해제 또는 병합 권한을 자동으로 만들지 않는다.

## 4. 범위

### 4.1 Windows 재현 빌드

- Godot `4.7.1`과 Windows Desktop export template 버전을 고정한다.
- GitHub Actions `windows-latest`에서 Release Windows x86_64 빌드를 생성한다.
- 빌드 파일·PCK·검증 JSON·로그를 하나의 workflow artifact로 업로드한다.
- artifact metadata에 `repository`, `pr`, `head_sha`, `godot_version`, `workflow_run_id`, `build_utc`, `preset`을 기록한다.
- export template 설치 실패·artifact 누락·실행 timeout은 `BLOCKED` 또는 `FAIL`이며 PASS로 대체하지 않는다.

### 4.2 Windows CI 런타임

Windows runner에서 생성한 실행 파일을 실제 Windows 프로세스로 실행한다. 화면이 없는 CI 실행은 `windows_ci_runtime` 증거이며 로컬 GPU·모니터·실물 입력 검증을 대체하지 않는다.

런타임은 다음을 수행한다.

1. Main scene 기동.
2. Combat preview 진입.
3. player/enemy loadout 분리 확인.
4. 무공 탭과 절초 탭 공급 원본 확인.
5. 대표 기술 배치·묶음 진행·전투 로그 생성.
6. 정상 종료와 종료 코드 `0` 확인.
7. JSON 증거 파일 저장.

### 4.3 초기 10권 제품 시나리오 행렬

10권 각각에 대해 3·5·7·9·10성 제품 경로를 검증한다. 총 50개 성취도 시나리오는 데이터 기반으로 생성하며 테스트 코드에 현재 표시명을 중복 하드코딩하지 않는다.

각 성취도에서 확인할 계약:

- 3성: 기술1이 UI에 해금되고 배치·실행된다.
- 5성: 기술1 카드 ID는 유지되고 승인 overlay 하나가 합성된다.
- 7성: 기술2가 새 카드로 해금되고 기술1을 제거하지 않는다.
- 9성: 기술2 카드 ID는 유지되고 단일 완성 overlay 하나만 합성된다.
- 10성: 고유 절초가 기존 공용 절초와 함께 표시되고 실행된다.

대표 의미 검증:

- 매화검결: 실제 체력 피해 조건 연격과 결착검.
- 나한금강공: 방어·강건 선행과 장격.
- 태극검결: 합·흘리기·반격.
- 양가창결: 후퇴 뒤 사거리 재확인과 회마창.
- 자하심법: 전투당 사용권 선소모·미환불·완료 기세.
- 소요보결: 이동 전 반격 후 후퇴.
- 강룡장결: 합 승리 후 방어 파괴·피해·밀치기 순서.
- 천기암기록: 독립 다단과 사거리 1~4 절초.
- 팽가도결: 방어 0 조건부 결착도.
- 창궁무애검법: 준비 소비와 직선 검압 합.

### 4.4 해상도·안전영역

다음 viewport를 자동 생성해 핵심 Control의 전역 rect·최소 크기·포커스 진입 가능성을 검사한다.

- `1280×800`
- `1440×900`
- `1920×1080`

검사 대상:

- ActionSelectionDock 전체.
- `[기초] [무공] [절초]` 탭.
- 무공서 목록·기술 목록·세부 패널.
- 10수 타임라인과 `[진행]` 버튼.
- 절초 예약·잠금 표시.
- 결과·복기 진입 버튼.

자동검사는 Control이 viewport 밖으로 완전히 이탈하거나 주요 버튼의 클릭 영역이 0이거나 포커스 경로가 끊기면 실패한다. 자동 rect 검사는 실제 가독성·텍스트 품질·보조기기 사용성을 통과 처리하지 않는다.

### 4.5 입력 검증

Windows CI에서 Godot Input Action을 통해 합성 입력을 실행한다.

- 키보드: 탭 이동, 방향키 또는 승인된 탐색 키, 확인, 취소, 묶음 진행.
- 마우스: 탭 선택, 무공서 선택, 기술 배치, 슬롯 제거, 진행.
- 게임패드: InputMap·포커스 계약은 자동 검사하되 실물 패드 입력은 `NOT_RUN`.

원시 키 코드에 전투 규칙을 결합하지 않는다. 합성 입력 성공은 실물 장치·지연·포커스 체감을 대체하지 않는다.

### 4.6 성능 증거

이번 Gate는 최종 최소 사양이나 Release 성능 PASS 기준을 확정하지 않는다. 동일 exact SHA·동일 Windows CI 환경에서 다음 기초값을 수집한다.

- export 소요 시간.
- 프로세스 시작부터 Main ready까지 시간.
- Combat preview ready까지 시간.
- 50개 성취도 시나리오 총 실행 시간.
- 대표 전투 100묶음 해결 시간.
- 프로세스 peak working set.
- artifact 전체 크기.

첫 성공 실행은 `performance_baseline: CAPTURED`이며 `release_performance: NOT_RUN`이다. 후속 실행부터 같은 환경의 직전 승인 baseline 대비 `+20%` 이상 악화하면 경고, `+35%` 이상 악화하면 자동 제품 Gate를 실패시킨다. runner 이미지 변경이나 Godot 버전 변경 시 기존 baseline과 직접 비교하지 않고 새 baseline Decision을 요구한다.

### 4.7 접근성 증거

자동검사:

- 모든 핵심 버튼의 비어 있지 않은 텍스트 또는 접근 가능한 설명.
- 키보드 포커스 경로 단절 없음.
- 선택·잠금·실패가 색 하나에만 의존하지 않고 텍스트 또는 아이콘 상태를 함께 제공.
- 모션·음향 없이 전투 원인과 결과 텍스트 확인 가능.
- 1280×800에서 주요 텍스트 clipping 없음.

실제 스크린리더·저시력·운동 접근성 사용자 검증은 `accessibility_user: NOT_RUN`으로 유지한다.

### 4.8 STEP 14 재활성화

기존 `DEFERRED_BY_USER / DO_NOT_RUN` 프로토콜을 다음 상태로 승격한다.

```yaml
protocol_status: REACTIVATED_BY_USER
build_commit: LOCK_AFTER_PRODUCT_GATE_IMPLEMENTATION
participant_count: 0
human_step14: NOT_RUN
```

사용자의 이번 지시는 프로토콜 준비 재활성화 승인으로 해석한다. 참가자를 대신 생성하거나 자동화 결과를 참가자 결과로 기록하지 않는다.

5명 신규 플레이어의 기존 통과 신호를 유지한다.

- 4/5 이상 전투 완료.
- 4/5 이상 3/3/4와 결정적 원인 설명.
- 3/5 이상 상대 성향 발견.
- 3/5 이상 다음 묶음·재도전에서 계획 변경.
- 3/5 이상 자발적 재도전 또는 다음 수 선택.
- 핵심 결과를 막는 단일 정보 채널 장벽 0건.

## 5. 구성 요소와 책임

### 계약·정본

- `docs/decisions/2026-08-06_TEN_MANUAL_PRODUCT_VALIDATION_GATE.md`
  - 승인 범위·증거 축·완료 금지 주장을 기록한다.
- `docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json`
  - 기계 검증 가능한 상태·환경·필수 artifact·시나리오 행렬을 제공한다.
- `docs/08_TEST_CHECKLIST.md`
  - 구형 현재 SHA와 UI·AI 상태를 새 Gate 기준으로 갱신한다.
- `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- `[기획서]/00_프로젝트_허브/ROADMAP.md`
- `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`
  - 자동 완료와 사람 미완료를 분리한다.

### 테스트·검증

- `tests/verify_ten_manual_product_gate.gd`
  - 10권×5성취도, UI 공급, 배치, 실행, 해상도, 합성 입력을 검증한다.
- `tools/validate_ten_manual_product_gate.py`
  - 계약·증거 JSON·SHA·상태 과장·시나리오 개수·artifact metadata를 검사한다.
- `scripts/windows/run_ten_manual_product_validation.ps1`
  - export된 Windows 실행 파일을 실행하고 로그·시간·메모리·종료 코드를 수집한다.
- `.github/workflows/validate-ten-manual-product-gate.yml`
  - Windows export·Windows runtime·Ubuntu headless·계약 검사를 실행하고 artifact를 업로드한다.

### 증거

- `docs/evidence/TEN_MANUAL_PRODUCT_VALIDATION_EVIDENCE.md`
  - exact SHA별 자동·Windows CI·로컬 Windows·접근성·성능·사람 상태를 분리 보고한다.
- `artifacts/ten-manual-product-validation/<head_sha>/product_validation_evidence.json`
  - CI 생성물이며 저장소 정본이 아니다. Actions artifact에서 보존한다.
- `docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md`
- `docs/research/STEP14_REPEAT_POC_RESULTS_TEMPLATE.md`
  - 프로토콜 재활성화와 고정 build SHA를 기록하되 참가자 결과는 미실행 상태로 유지한다.

## 6. 데이터 흐름

```text
exact PR head checkout
→ 계약·정본 정적 검사
→ Ubuntu Godot headless 50개 성취도 제품 시나리오
→ Windows Release export
→ export 실행 파일 Windows CI smoke
→ 해상도·합성 입력·무공 UI/AI/전투 검증
→ 시간·메모리·artifact 크기 수집
→ product_validation_evidence.json 생성
→ Python validator가 SHA·증거·상태 과장 검사
→ Actions artifact 업로드
→ evidence report·PR·Google Sheet 동기화
```

Google Sheet는 구현 최종 exact SHA의 자동검증이 통과한 뒤에만 갱신한다. 같은 Decision ID를 `00·01·02·03_무공서_무학·04·12·15·30·40·41·99`에 연결한다.

## 7. 실패 처리

- Godot export template 없음: `windows_export: BLOCKED`.
- Windows 실행 파일이 기동하지 않음: `windows_ci_runtime: FAIL`.
- 실행 timeout 또는 비정상 종료: `FAIL`, 로그·덤프 artifact 보존.
- 50개 시나리오 중 하나라도 누락: `automated product gate: FAIL`.
- evidence SHA와 PR head 불일치: `CANON_CONFLICT`.
- 사람 결과에 participant count 0인데 PASS 존재: validator 실패.
- 로컬 Windows·실물 게임패드·접근성 사용자·Release 성능을 Actions 결과로 PASS 처리: validator 실패.
- 성능 runner 또는 Godot 버전이 baseline과 다름: 비교 보류 후 새 baseline 필요.
- 제품 검증 중 밸런스 수치를 변경해야 하는 발견: 이 Gate에서 즉시 변경하지 않고 별도 `TEN_MANUAL_BALANCE_MEASUREMENT_GATE` Decision 후보로 분리한다.

## 8. TDD와 검증 순서

```text
RED: 계약·50시나리오·Windows artifact·상태 과장 검사가 현재 head에서 실패
→ 최소 계약·검증 harness 구현
→ Ubuntu headless GREEN
→ Windows export GREEN
→ Windows CI runtime GREEN
→ 기존 PR Validation·Full Validation·무공/예산/숙련 회귀 GREEN
→ evidence validator 변조 테스트 GREEN
→ exact-head readback
→ Google Sheet 같은 Decision/SHA 동기화
```

변조 테스트는 최소 다음을 포함한다.

- 시나리오 49개로 축소.
- 9성 overlay를 두 개로 증가.
- 플레이어 미확정 계획을 AI 입력에 추가.
- Windows artifact SHA를 다른 commit으로 변경.
- participant count 0에서 human PASS 설정.
- Windows CI를 local Windows PASS로 위장.
- performance baseline 환경이 다른데 회귀 비교 수행.

## 9. 완료 기준

자동 제품 검증 Gate의 완료 조건:

1. 10권×5성취도 50개 제품 시나리오 PASS.
2. Ubuntu Godot headless PASS.
3. Windows x86_64 Release export PASS.
4. export된 실행 파일의 Windows CI runtime PASS.
5. 3개 해상도와 키보드·마우스 합성 입력 PASS.
6. 접근성 자동검사 PASS.
7. 성능 baseline CAPTURED.
8. 증거 JSON과 exact SHA 일치.
9. PR Validation·Full Validation·기존 10권·예산·숙련·AI 비치팅 회귀 PASS.
10. 리뷰 스레드 P0/P1 0.
11. GitHub 정본과 Google Sheet가 같은 Decision·exact SHA로 readback됨.

완료 후 허용 상태:

```yaml
runtime_authority: PRODUCT_VALIDATION_AUTOMATED
product_gate: PARTIAL_AUTOMATED_COMPLETE
windows_ci_runtime: PASS
windows_local_render: NOT_RUN
human_step14: NOT_RUN
accessibility_user: NOT_RUN
release_performance: NOT_RUN
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

## 10. 비범위

- 무공별 최종 피해·비용·AI 가중치 조정.
- 최종 loadout 획득·교체 경제.
- 적별 최종 무공 loadout·난이도 곡선.
- 모바일 터치 UI·Android·iOS.
- 물리 Windows PC·모니터·GPU·실물 입력을 대신한 PASS 주장.
- 참가자를 대신한 가상 사람 테스트.
- Draft 해제·병합·부모 PR 우회.
- T1·MVP·출시 완료 선언.

## 11. 다음 Gate

자동 제품 검증이 완료되면 다음 작업을 분리한다.

1. `TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE`
   - 로컬 Windows 렌더·실물 키보드/마우스/게임패드·접근성 실사용·Release 성능.
2. `TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE`
   - 신규 플레이어 5명.
3. `TEN_MANUAL_BALANCE_MEASUREMENT_GATE`
   - 실제 로그 기반 선택률·성공률·자원·대체율 측정과 수치 조정.

이 세 Gate의 증거가 없으면 `TEN_MANUAL_PRODUCT_VALIDATION_GATE` 자동 완료를 전체 제품 완료로 확대 해석하지 않는다.
