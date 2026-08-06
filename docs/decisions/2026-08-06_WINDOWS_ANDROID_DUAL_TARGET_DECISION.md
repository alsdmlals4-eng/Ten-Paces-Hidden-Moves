# Windows·Android 이중 기본 대상 플랫폼 Decision

```yaml
decision_id: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01
status: APPROVED_PLANNING
approval_source: USER_CURRENT_SESSION_EXPLICIT_INSTRUCTION
decision_date: 2026-08-06
design_targets: [WINDOWS, ANDROID]
logic_and_data_core: SINGLE_SHARED_CORE
separated_adapters: [INPUT, RESPONSIVE_UI, APP_LIFECYCLE, PLATFORM_SERVICES, QUALITY_EXPORT]
same_day_release_required: false
windows_runtime_evidence: CI_EXPORT_RUNTIME_PASS_LOCAL_NOT_RUN
android_runtime_evidence: NOT_RUN
android_device_evidence: NOT_RUN
android_performance_evidence: NOT_RUN
android_store_evidence: NOT_RUN
```

## 1. 승인 결정

십보강호는 Windows와 Android를 기본 설계 대상으로 유지한다. 두 플랫폼은 동일한 게임 규칙·콘텐츠·데이터·저장 의미를 공유하며, 플랫폼 차이는 어댑터 경계에서만 처리한다.

이 Decision은 Android 구현 완료나 동시 출시 약속이 아니다. 설계·인터페이스·수용 기준을 두 플랫폼에 맞춰 선행 고정하는 기획 권위이며, 실제 Android 지원 표시는 별도 실행 증거가 닫힌 뒤에만 허용한다.

## 2. 공유 단일 코어

다음은 플랫폼별로 복제하거나 분기하지 않는다.

- 10칸 전장, `3수 → 3수 → 4수`, 거리·순서·합·대응·중단 해결.
- AI의 공개 정보·잠긴 계획·비치팅 금지 규칙.
- 무공서·기술·성취도·자원·피해·상태·등급 계산.
- 콘텐츠 ID·Schema·seed·결정적 실행 순서.
- 저장 데이터의 의미·버전·마이그레이션 계약.
- 결과·복기·보상·진행 상태의 도메인 규칙.

공유 코어는 화면 크기, 포인터·터치 종류, 앱 일시정지, 스토어 SDK 또는 장치 성능 등 플랫폼 환경을 직접 참조하지 않는다.

## 3. 분리 어댑터

### INPUT

- 도메인 명령은 `select / place / move / remove / confirm / cancel / inspect / back`처럼 장치 중립 의도로 정의한다.
- 키보드·마우스·게임패드·터치는 같은 명령으로 변환한다.
- hover 전용 정보와 정밀 드래그만으로 핵심 조작을 구성하지 않는다.

### RESPONSIVE_UI

- 화면 구조와 정보 우선순위는 공유하되 밀도·배치·팝업 방식은 플랫폼 프로필로 조정할 수 있다.
- 안전영역, 화면비, 글자 크기, 터치 표적, 포커스 이동, 가상 키보드 영향을 검증한다.
- 픽셀 동일 UI는 목표가 아니며 플레이 의미·상태 전달·행동 가능성의 동등성을 목표로 한다.

### APP_LIFECYCLE

- Android 뒤로가기, pause/resume, background/foreground, suspend/restore, 강제 종료 복구를 별도 어댑터와 저장 Gate로 처리한다.
- 앱 생명주기 이벤트가 전투 해결 중복 실행이나 보상 중복 commit을 만들면 안 된다.

### PLATFORM_SERVICES

- 스토어·업적·클라우드·결제·권한·파일 위치는 선택적 플랫폼 서비스 인터페이스 뒤에 둔다.
- 서비스가 없어도 핵심 전투·로컬 저장·데모가 실행 가능해야 한다.

### QUALITY_EXPORT

- export preset, 패키징, 그래픽 품질, 메모리·발열·배터리·프레임 예산을 플랫폼별로 관리한다.
- 성능 차이를 이유로 규칙이나 콘텐츠 의미를 바꾸지 않고 표현 품질과 리소스 예산을 조절한다.

## 4. 동등성 계약

반드시 동등해야 하는 것:

- 같은 입력 의도에 대한 합법성·판정·AI·보상 결과.
- 같은 seed·상태·콘텐츠 버전에서의 도메인 결과.
- 저장·불러오기·마이그레이션 의미.
- 핵심 정보와 실패 원인의 이해 가능성.
- 접근성 대체 경로와 취소·복구 가능성.

동일할 필요가 없는 것:

- 화면 배치·밀도·패널 전환 방식.
- 포인터 hover와 터치 long-press 같은 보조 상호작용.
- 그래픽 품질 프로필·해상도·효과 밀도.
- 스토어별 기능과 출시 날짜.

## 5. 구현·검증 Gate

### Windows

현행 자동 증거는 CI export·runtime과 합성 입력·자동 접근성·성능 baseline까지다. 로컬 실제 렌더·실물 게임패드·접근성 사용자·Release 성능 판정은 `NOT_RUN`이다.

### Android

다음이 실제 증거로 닫히기 전 `ANDROID_RUNTIME_SUPPORTED`를 주장하지 않는다.

1. Godot Android export와 서명 가능한 패키지 생성.
2. 최소 한 대 이상의 실제 Android 기기 설치·첫 실행·종료.
3. 터치 선택·배치·이동·제거·확인·취소·상세보기.
4. 뒤로가기·pause/resume·background/foreground·suspend/restore.
5. 전투 중단·재진입·저장·보상 단일 commit·마이그레이션.
6. 대표 저사양·기준 기기의 메모리·프레임·발열·배터리 관찰.
7. 화면비·안전영역·글자·터치 표적·접근성 검증.
8. Windows와 동일한 핵심 시나리오 결과 parity.

## 6. 범위 경계

- Windows·Android 기본 설계는 iOS 지원을 자동 승인하지 않는다.
- 크로스 세이브·계정·온라인 동기화·결제·광고·푸시는 별도 Decision이다.
- 같은 날 두 플랫폼 출시를 요구하지 않는다.
- Android를 이유로 핵심 전투를 단순화하거나 별도 밸런스 규칙을 만들지 않는다.
- 실제 기기 증거 전에는 Android 완료·성능 통과·스토어 준비를 보고하지 않는다.

## 7. 다음 Gate

```text
POSTMERGE_CANON_SYNC
→ WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_CONTRACT
→ LOCAL_WINDOWS_ANDROID_DEVICE_ACCESSIBILITY_PERFORMANCE_GATE
→ STEP14_HUMAN_VALIDATION_GATE
→ BALANCE_MEASUREMENT_GATE
```

## 8. 정본·소비자

같은 Decision ID를 다음에 반영한다.

- `AGENTS.md`
- `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- `docs/04_ROADMAP.md`
- `docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md`의 `[대체됨]` 표식
- Google Sheets `00_프로젝트_허브`
- Google Sheets `02_현재_확정결정`
- Google Sheets `10_제품방향`
- Google Sheets `30_데모범위_품질기준_제작기반`
- Google Sheets `99_변경이력`
