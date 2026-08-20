# TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01

## 상태

`APPROVED_SCOPED_IMPLEMENTATION_GATE`

## 사용자 지시

2026-08-20 사용자 명시: `이미지 생성 외 작업을 진행하자`.

이 지시는 현재 `AWAITING_EXPLICIT_ASSET_OR_IMPLEMENTATION_REQUEST` 상태에서 **이미지 생성을 제외한 첫 5전 Vertical Slice 구현 작업을 진행하라는 명시적 요청**으로 기록한다.

## 문제

기존 `docs/planning-data/current_entry_gate_20260808.json`은 Windows/Android 플랫폼 어댑터 구현과 Android 실기기·Human 검증을 한 Gate에 묶은 역사 스냅샷이다. 이 Gate를 삭제하거나 PASS로 덮어쓰면 미검증 플랫폼·Human evidence가 잘못 승격된다.

반면 2026-08-20에 승인된 첫 5전 Vertical Slice와 Visual/UX Handoff는 PC-first 제품 구현을 시작할 준비가 되어 있고, 현재 사용자가 이미지 생성 외 작업의 진행을 명시적으로 요청했다.

## 결정

### 1. PC-first 첫 5전 Vertical Slice 구현을 좁게 허용한다

허용 범위:

- Run/App Flow shell.
- RunState.
- 후보 15명 data binding.
- 시작 6중4 Setup과 Briefing.
- 기존 전투 코어 연결.
- Combat Review Overlay와 Duel Result Scene.
- Route 8노드.
- 5전 Completion Summary.
- 위 범위의 자동 테스트·회귀 검증.

### 2. 기존 플랫폼 Gate는 그대로 보존한다

이 Decision은 다음을 PASS로 만들지 않는다.

- Android 실제 기기: `BLOCKED_UNVERIFIED`.
- Human 재미·몰입·가독성: `NOT_RUN`.
- Windows visible local usability: `NOT_RUN`.
- Windows/Android Adapter implementation: 기존 플랫폼 Gate 기준 `BLOCKED` 유지.
- Release validation: 미승인.

따라서 **개발 착수 권한**과 **플랫폼/사람/릴리스 검증 완료**를 분리한다.

### 3. 이미지 생성은 계속 중단한다

- 새 이미지 생성 권한: `false`.
- 이번 대화에서 생성된 수묵 전투 화면은 `REFERENCE_ONLY_NOT_ASSET`.
- 사용자가 집의 시안을 나중에 제공하기로 했으므로 final visual reference는 `USER_REFERENCE_PENDING`.
- 구현은 기존 승인 자산·텍스트·구조화 placeholder/frame을 사용할 수 있으나, 그 상태를 Human Visual PASS로 주장하지 않는다.

### 4. 보호 대상

이 구현 Gate는 다음을 재설계하지 않는다.

- 논리 10칸 전장.
- 3수 → 3수 → 4수 계획.
- 양측 현재 계획 비공개.
- AI의 플레이어 미확정 입력 접근 금지.
- 거리·합·대응·중단·복기.
- `[관찰]` 플레이어 전용 권위.
- 기존 10권 무공 재사용.
- Combat Review = Overlay / Duel Result = 별도 Scene / Route = 별도 Scene.

보호 코어 변경이 필요해지면 해당 구현을 멈추고 별도 Planning Reopen Decision을 만든다.

## 구현 기준선

- `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`
- `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`
- `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`
- `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`
- `docs/14_VERTICAL_SLICE_LOADOUT_ROUTE_BUDGET_WIREFRAME.md`
- `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`
- `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`

## 다음 실행

`docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md` Phase I부터 TDD로 진행한다. 첫 구현은 기존 `CombatBoardPreview` 전투 코어를 재작성하지 않고 바깥의 Run/App Flow shell을 추가하는 방식으로 한다.
