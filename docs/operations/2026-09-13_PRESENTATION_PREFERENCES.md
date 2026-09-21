# 사용자 설정 유지와 작업 기준 정리 — 승인된 구현 계획

- 승인: 2026-09-13 사용자 `좋아 권장안대로 작업진행해`. 구현/수정 계획을 먼저 기록한 뒤 실행한다.
- 기준 SHA: 3dffd457b0b26bd729cc868acf54d285abbadb2c; main ed2104d98872c63eac27999830aeae9c15a00bdc; Base remote d830c0f6967678eed3c208ac6b24f9cd1b262ec3. 채택 pin 9.4.4 유지.
- Work Mode PLAN → BUILD → REVIEW; Skill combat-implementation-handoff / implementation-contract, build, runtime-handoff; ten-paces-verification / regression-validation; reference-freshness.
- 실제 작업 위치: `.worktrees/motion-integration-20260912`, PR #342. 바깥 루트의 이전 HEAD와 사용자 미커밋 변경은 보존한다.

## 조사와 구현 가능성

CURRENT_SOURCE_RELEVANCE_CHECK: PASS. 기존 10개 게임 비교의 같은 소리/모션 표시·입력·정보 경계는 `2026-09-12_PRESENTATION_CONTROLS_WORK_CONTRACT_RECEIPT.json`에서 재사용한다. 이를 설정 저장 구현의 증거로 확대하지 않는다. 추가로 2026-09-13 [Hades 공식 지원](https://www.supergiantgames.com/faqs/hades/)의 Profile1.sjson 설정과 진행 저장 분리, [Godot ConfigFile 공식 문서](https://docs.godotengine.org/en/stable/classes/class_configfile.html)의 명시적 load/save 및 Error 반환을 본문 확인했다. 공개 문서는 내부 구현이나 플레이어 검증이 아니다.

- ADOPT: Godot ConfigFile 독립 사용자 설정 파일. 외부 의존성·진행 저장 migration 없음.
- ADAPT: shell이 먼저 읽고 새 전투 화면에 공유 인스턴스를 주입한다. 스크립트 검증은 기존 run-save의 격리 원칙처럼 명시적 테스트 경로만 사용한다. 독립 전투 preview는 임시 설정이다.
- REJECT: 여정 저장에 설정 포함 — 사용자 선호와 여정의 수명이 다르다.
- REJECT: 메모리만 유지 — 앱 재실행 요구를 충족하지 않는다.
- FEASIBLE: 기존 세 컨트롤과 shell의 전투 생성 경로를 연결한다. 저장 실패 시 이번 실행의 설정을 유지하고 다음 조작에서 재시도하며 진행 저장을 막지 않는다.

## 구현 순서와 완료 기준

1. 실패 회귀 먼저: 저장/재읽기, 기본값, 잘못된 값·손상 파일·쓰기 실패, 다음 전투 인스턴스, 별도 프로세스 재실행을 재현한다.
2. 설정 owner를 추가한다. mute=false, volume=0.65, reduced_motion=false. 잘못된 bool은 기본값, 유한한 숫자는 0..1 범위, 누락/손상 파일은 기본값. 실제 조작 시에만 파일을 쓴다.
3. shell 초기화 → 전투 ready 전 주입 → 초기 컨트롤과 첫 효과음 적용. 기존 조작 후 저장한다. 진행 저장·전투 규칙·AI·새 이미지에는 연결하지 않는다.
4. 역사 검수 기록 앞에 현재 구현 상태 안내를 추가한다. ACTIVE_CONTEXT, UX owner, 이 실행 기록을 갱신한다. 계획 선행 원칙을 협업 owner에 반영한다.
5. 승인된 작업 계보의 전체 검토 2회는 초기화하지 않는다. 기존 검토 이후 새 설정 범위의 정본·diff·consumer·실행·비용·장기 적합성을 표적 검토하고 관련 회귀, 실제 Godot 실행, 보호 계약, exact HEAD CI를 확인한다.
6. 임시 파일은 경로와 해시를 확인해 수동 삭제 폴더로 이동한다. 모션 4장의 최종 승인, Human/Android/실물 음향/출시 검증은 별개다.

## 실행 기록

구현 전 계획 기록 완료. RED/GREEN과 실제 결과를 아래에 추가한다.

### 구현·검증 결과

- `src/ui/presentation_preferences.gd`: 독립 ConfigFile owner, 엄격한 값 복원, pending 파일 완성 뒤 교체, 실패 시 메모리 유지와 재시도. 작은 세 값만 저장하며 별도 프레임워크·비용·진행 migration을 추가하지 않았다.
- `VerticalSliceShell`이 전투 생성 전에 공유 설정을 전달한다. `_ready`에서 버튼·슬라이더·두 효과음 플레이어의 초기값을 먼저 반영하고 기존 세 조작에서 저장한다. standalone preview와 기본 script entry는 실제 사용자 설정을 읽거나 쓰지 않는다.
- RED: `preferences-red.log`에서 persistent owner 부재로 exit1 관측. GREEN: `preferences-green.log`,16개 검사 PASS. 의도적으로 손상한 fixture의 ConfigFile parse 오류는 복구 경로의 예상 출력이며 게임 진입 차단이 아니다.
- 실제 입력·별도 프로세스: `test_presentation_preferences_restart.py` write26/read24 검사 PASS. Enter와 좌우 키의 실제 InputEvent로 조작, 전투/여정 Dictionary 불변, 전투 재생성·새 타이틀·다른 프로세스 복원을 검증했다.
- Windows 4.7.1 OpenGL/NVIDIA RTX3050: visible read24 검사 PASS, 1280×800 GPU 캡처 `C:/Users/user/.codex/visualizations/tenpaces-motion-integration-20260912/preferences-restored.png` 직접 확인. 소리 끔·슬라이더25%·모션 감소 켬 표시가 복원됐다. 이는 자동 실행/화면 확인이며 실제 음향 장치·Human 접근성 PASS가 아니다.
- 영향 회귀7개 PASS: variable_save_compat, variable_shell, save_entry_isolation, combat_sfx_presentation, combat_keyboard_accessibility, combat_focus_order, combat_review_ui. 로그는 같은 evidence root의 validation/*-preferences.log.
- 프로젝트/참조 검사 PASS, Python governance/retry-save22개 PASS. Godot editor import는 script parse 실패 없이 exit0이지만 종료 시45개 ObjectDB/22개 resource 진단이 남는다. 같은 수치가 기존 baseline-import.log에도 있으며 새 런타임 프로세스 검사에는 발생하지 않았다. editor 종료를 무진단 PASS로 표현하지 않는다.
- 보호 검사에서 검증용 복원 sidecar를 변경으로 탐지했다. 승인 범위를 늘리지 않고 원래 삭제 대기 위치로180개를 동일 SHA-256 확인 후 반환해 재검사 PASS. 실제 새 제품 경로3개만 기존 사용자 승인 근거로 추가했다.
- 새 검증 부산물10개를 기존 삭제 대기 폴더의 `preferences-20260913`에 원래 경로·SHA-256 목록과 함께 이동했다. 실제 삭제 없음. 작업 폴더 안내도 현재 통합본과 이전 원본 보존 폴더를 명확히 구분했다.

### 기존 두 차례 검토 이후 표적 검토와 학습

동일 승인 작업 계보의 전체 검토 횟수를 초기화하지 않았다. 새 설정에 대해 다음 영향 지도를 직접 검토했다.

- 정본/진입점: 과거 PDF 검수의 NOT_RUN을 현재 상태로 오독하는 경로를 상단 현재 상태 안내로 교정. 원래 PDF와 당시 판단 보존.
- 실제 diff/consumer: shell이 ready 전에 주입하고 두 오디오 채널도 생성 시 초기화하도록 교정. null instantiate 검사 이후에만 참조를 대입한다. 독립 preview의 테스트 격리를 유지한다.
- 실패/회귀: 손상 파일과 쓰기 실패를 성공으로 숨기지 않고 기본값/이번 실행 유지/다음 변경 재시도를 분리. 입력 후 전투와 여정이 그대로인지 실제 검사했다.
- 자동화/비용: 새 native 회귀를 기존 제품 CI에 추가했다. Godot 없는 일반 Python 환경은 NOT_RUN skip이며 해당 제품 CI는 GODOT_BIN을 명시해 실행한다. 세 설정에 새 modal, 종속 라이브러리, 저장 Schema 변경을 추가하지 않았다.
- 재사용 교훈: 사용자 설정은 장면보다 오래 살아야 하며 ready 이전에 적용해야 첫 프레임/첫 소리와 라벨이 일치한다. 테스트는 실제 사용자 저장과 독립된 경로를 써야 한다. 프로젝트 코드·회귀·UX owner에 반영했고 공용 Base 변경은 하지 않았다.

원격 CI는 이 변경의 실제 push HEAD를 조회하여 확인한다. 기존34PASS를 새 변경 PASS로 재사용하지 않는다. PR342 Draft와 캐릭터4장 최종 확정 경계는 유지한다.
