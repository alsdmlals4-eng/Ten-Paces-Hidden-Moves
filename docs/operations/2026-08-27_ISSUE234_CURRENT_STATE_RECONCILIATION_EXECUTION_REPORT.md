# Issue #234 · Current Vertical Slice 상태 교정 실행 기록

## 범위와 기준

- 기준 Project `main`: `327ea6e1a63211f5f47b55968fb0f429b74b0328`.
- 기준 Base current `main`: `986ac32113958c501f11cd1ec4e38e65eb29f746`.
- 범위: 첫 5전 Vertical Slice의 현재 구현/검증 상태가 남아 있는 요약 문서와 Notion Production 상태를 실제 구현 증거와 맞춘다.
- 제외: 제품 코드·자산·플랫폼 Adapter·신규 이미지 생성·Draft PR #199/#200 변경.

## 확인된 현재 상태

- `res://scenes/run/vertical_slice_shell.tscn`이 기본 진입점이며 첫 5전 Shell을 시작한다.
- `slot1_dogyeom`만 전용 상태 초상과 전신 Battler를 사용하고, 다른 상대와 ID 누락 상대는 generic fallback을 유지한다.
- Windows visible human usability, Android 실기기, 접근성 사용자, 사람 재미/가독성은 계속 `NOT_RUN`이다.

## Incident · 깨끗한 worktree Godot 회귀 실행 순서

### 관측

깨끗한 worktree에서 개별 Godot verifier를 바로 실행하면 전역 클래스 cache와 PNG import 산출물이 없어 `VerticalSliceRouteShell` 및 portrait preload 오류가 발생했다.

### 원인

Godot 4.7.1의 깨끗한 checkout은 개별 `--script` verifier 전에 `--headless --editor --path . --quit` 초기 import/전역 클래스 등록이 필요하다. 이는 제품 코드 결함이 아니라 이미 CI와 프로젝트 collector가 사용하는 실행 순서를 생략한 실행 오류다.

### 해결과 재발 방지

기존 CI/collector와 같은 import·parse 선행 단계를 적용한 뒤 default-entry, 도겸 상태 초상, 도겸 Battler, Vertical Slice combat bridge verifier를 실행했다. 네 verifier가 모두 PASS했고, Hera 런타임도 1280×800 기본 화면에서 오류·경고·clipping 없이 확인됐다.

### Base 승격 판정

`NO_BASE_PROMOTION`: 이 원칙은 현재 Base Work 계약과 기존 CI workflow에 이미 반영되어 있어 새 공용 규칙이나 Base 변경이 필요하지 않다.

## Evidence ceiling

자동 Godot·Hera evidence는 사람의 이해도·재미·기기 검증을 대체하지 않는다. 위 Human/device 항목은 `NOT_RUN`으로 유지한다.
