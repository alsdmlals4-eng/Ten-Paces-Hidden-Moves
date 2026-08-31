# TEN-IMG-001 Visual Requirement 승인 결정

- Decision ID: `TEN-DEC-20260808-TEN-IMG-001-VISUAL-REQUIREMENT-APPROVAL-01`
- Requirement ID: `TEN-VIS-REQ-001`
- Image ID: `TEN-IMG-001`
- 승인일: `2026-08-08`
- 승인 출처: 사용자 `권장안대로 승인`
- 상태: `CURRENT_APPROVED_PLANNING_VISUAL_REQUIREMENT`
- 권한: `PLANNING_VISUALIZATION_ONLY`
- 승인 시 project main: `58209a59e2fab7f77b73d3316303efb5cc710c2a`
- 승인 시 Base main: `a912cc001ff4d4e3415fb4b4931723c49eb08d9a`

## 1. 승인 결론

`TEN-VIS-REQ-001`을 `APPROVE`한다.

승인된 제작 disposition은 `GENERATE_EXPLORATION`이다. 따라서 `TEN-IMG-001`은 제품 UI 구현 전 정보 위계·가독성·반응형 재배치 가능성을 검토하기 위한 **PLANNING_VISUALIZATION 탐색 이미지**로 생성할 수 있다.

이 승인은 다음을 승인하지 않는다.

- 생성 결과의 `PROJECT_ASSET_APPROVED` 승격
- `ASSET_MANIFEST.yml` 제품 자산 등록
- Godot Scene/Resource/UI 구현
- 런타임 통합
- Windows/Android 실기기 검증 완료 주장
- 사람 UX 검증 완료 주장
- Product Entry Gate 해제

## 2. 승인 근거

Base 최신 `Visual Requirement Gate`의 Delete Test·역할·우선순위·disposition 기준을 다시 대조했다.

`TEN-VIS-REQ-001`은 다음을 갖춘다.

- 핵심 정보 위계를 검증하는 명시적 역할
- 제거 시 발생하는 관찰 가능한 손실을 설명하는 Delete Test
- `P0_BLOCKER` 우선순위
- 기존 `combat_board_preview.tscn`은 구조 참고만 하고 승인 자산으로 오인하지 않는 재사용 경계
- Windows 16:9와 Android responsive stress case
- 색 단독 의미 금지·편집 가능한 제품 텍스트 유지
- 권리·유사성 검수와 생성 provenance 기록 요구
- 생성 뒤 다시 검수해야 하는 명시적 validation/handoff

## 3. 최신 전투 UI 정본 연결

탐색 생성은 `TEN-DEC-20260808-COMBAT-PLANNING-UI-CARD-TIMELINE-01`을 최신 UI 표시 권위로 사용한다.

특히 다음 관계를 보존한다.

- 전체 논리 범위 `10수`
- 묶음 `3|3|4`
- compact 화면의 현재 수 주변 responsive timeline viewport
- 현재 수·현재 묶음·전체 10수 중 위치 인지
- 카드의 슬롯·사거리·기력·내력·절초기세 분리
- `기초 | 무공 | 절초` 계층
- 1~10 전장·위치·거리 정보 관계

미확정 값이나 새 전투 규칙을 이미지 생성 편의를 위해 창작하지 않는다.

## 4. 생성 로그와 검수

탐색 이미지를 생성할 때 최소 다음 provenance를 기록한다.

1. 사용 모델 또는 생성 도구
2. 사용 prompt 또는 generation brief
3. 생성 일시·버전
4. 권리·출처 메모

생성 결과는 최소 다음 항목을 검수한다.

- 기획 일치
- 실제 화면 가독성
- Godot editable UI로 재구성 가능한지
- 무협 전술 톤과 정보 명료성의 일관성
- 권리·유사성
- Windows 16:9 / Android responsive 재배치

검수 전 상태는 계속 `NOT_AN_ASSET`이다.

## 5. Entry Gate 영향

이번 승인으로 해소되는 것은 **`TEN-VIS-REQ-001`의 승인 전 이미지 생성 금지 상태**뿐이다.

다음 blocker는 그대로 남는다.

- local Hera CLI/addon exact pair·status·smoke/source-delta canary
- HiGodot L2 plugin/export-setting authoring
- HiGodot L1 export regression validation
- `TEN-IMG-001` 실제 생성 및 생성 후 검수
- local Windows/Android/device 검증
- 사람 UX 검증

따라서 `product_implementation_authorized = false`와 Product Entry Gate `BLOCK`은 유지한다.

## 6. 클레임 경계

```yaml
requirement_approval: APPROVED
generation_disposition: GENERATE_EXPLORATION
generation_authorized: true
product_asset_approved: false
runtime_integration_authorized: false
godot_implementation_authorized: false
windows_validation: NOT_RUN
android_validation: NOT_RUN
human_validation: NOT_RUN
product_entry_gate: BLOCK
```
