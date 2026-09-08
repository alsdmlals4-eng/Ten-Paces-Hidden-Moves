# 비무 제약 런타임 로컬 구현·검증 기록

## 작업 전 문제와 현재 결과

기준 SHA: `65fb51e3` (task 1–3 제품 구현과 UI 교정 완료 시점).
보호 기준: `81ef0f0b2ede9cd63d6a2aba521a645efc1d4e5f`.
Work Mode: BUILD → REVIEW. Skill: `ten-paces-verification`.
Skill Mode: contract-check, regression, runtime-validation, evidence-report.
현재 상태: `IMPLEMENTED_LOCAL_VERIFIED_AWAITING_CI_MERGE`.
전체 Blueprint 기능 완료·사용자 최종 승인·출시 완료가 아니다.

기존 브리핑에는 복수 제약 선택과 실제 engine 강제가 없었다. 9종 catalog/model,
RunState 확정 receipt, engine 강제, native 브리핑/준비 consumer를 연결했다.
현재 운영 owner는 10전 병합 설명과 첫 5전/과거 플랫폼 후속 YAML이 충돌했다.
현재 실행 JSON·Active Context·두 로드맵 router·관련 회귀를 동기화하고
PR65/92 및 플랫폼 설계 기록은 명시적인 역사 계보로 보존했다.

## 조사·구조·사용 예와 효과

CURRENT_SOURCE_RELEVANCE_CHECK: `REUSED_EVIDENCE`.
같은 패키지의 `2026-09-08_BIMU_CONSTRAINT_RUNTIME_PLAN.md`에 기록된 기존 10사례
선택/조합/공개/기간 비교와 공식 Hades, God of War, Godot 최적화 refresh를 재사용했다.
추가 설계 차원이나 보상/핵심 수치 변경은 없다. task 4의 상태 동기화와 CI 배선에는
새 외부 자료가 현재 repository 사실을 바꾸지 않으므로 별도 검색은 NOT_APPLICABLE.
FEASIBLE: actual catalog → model → RunState → bridge/engine → native UI → tests.

브리핑에서 문파 단절의 보유 무공과 내공 수련의 스테이터스를 선택하면 총 2개/2점이며
대상과 변화량이 공개된다. 세 번째 선택은 기존 선택을 보존하며 거절한다.
확정 뒤 봉인 무공은 이유를 표시하고 실제 계획 제출·engine도 같은 ID를 차단한다.
재도전은 같은 receipt이고 다음 비무는 초기화한다. 기초 행동/기본 절초는 유지한다.
같은 manual context 10회 갱신의 실제 node 교체는 10회에서 0회로 줄었다.
이는 rebuild 측정이며 FPS·Release 성능 개선 판정은 아니다.

## 검증 증거

환경: Windows, Godot `4.7.1.stable.official.a13da4feb`.
명령의 Godot 실행 파일:
`C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe`.

- RED: `python -m pytest tests/test_current_discovery_contract.py -q --tb=short`:
  현재 stage 기대를 먼저 수정하자 `1 failed, 18 passed`; 실패는 과거 FIRST_FIVE YAML이었다.
- GREEN: 같은 명령 `19 passed`; `python tools/check_postmerge_canon_lifecycle.py`:
  `CANON_LIFECYCLE_OK`.
- 첫 전체 pytest: `5 failed, 468 passed`. 후속 상태 고정 회귀 2곳, JSON pretty format,
  두 roadmap에 current Decision 연결 누락을 교정했다. 검사 삭제/skip 없음.
- 최종 `python -m pytest -q --tb=line`: `473 passed in 15.50s`, exit 0.
  최종 report/manifest 작성 뒤 재실행도 `473 passed in 15.15s`였다.
- `python tools/check_project_operating_system.py --root .`: PASS.
  `python tools/check_one_time_protected_change_lifecycle.py --project-root . --base-sha 61ccbdf568968e98b3c1665cc66e53c343f418ef`:
  `Protected approval lifecycle validation passed`. 승인 경로와 committed protected diff의
  집합 대조: `PROTECTED_APPROVAL_EXACT_PATHS_OK count=12`. staged diff whitespace 검사 PASS.
- Godot 공통 명령: `--headless --path . --script tests/<case>.gd`.
  아래 15개를 순차 실행하여 모두 exit 0, script error 없이 통과했다:
  `verify_bimu_constraint_model` (45 cases), `verify_bimu_constraint_runtime`,
  `verify_bimu_constraint_ui`, `probe_sequential_ten_duel_campaign`,
  `verify_ten_duel_campaign`, `verify_vertical_slice_failure_retry`,
  `verify_vertical_slice_combat_bridge`, `verify_ten_manual_product_gate` (50 scenarios),
  `verify_ten_manual_product_viewports`, `verify_combat_keyboard_accessibility`,
  `verify_combat_focus_order`, `verify_combat_layout_accessibility`,
  `verify_combat_action_selection_integration`, `verify_action_card_summary`,
  `verify_atlas_presentation_successor`.
- 실제 public-policy resolver 캠페인은 10승, 보상 10회, 행로 36회와 누적 자원 handoff를
  검사한다. `verify_ten_duel_campaign`의 synthetic terminal state 검사와 구분한다.
- 강화 후 registry 검사는 개수 비교에서 정렬한 정확한 card ID 집합 비교로 강화했다.
- 제품 CI의 기존 public-policy probe를 유지하고 model/runtime/UI 3개 실행을 추가했다.

## Windows visible 증거

Controller가 source `65fb51e3`에서 exact worktree/editor 6628/runtime 29048을 확인하고
Hera로 관찰했다. root start method 이후 starter/intro/briefing/constraints/confirm/
martial tab은 실제 native 클릭이었다. 마지막 항목 focus-scroll은 node grab_focus를
사용했다. 자원·결과 주입은 없었다. 진단 errors 0 / warnings 0 후 해당 실행을 종료했다.
다음 3개 fixed 캡처만 이 변경에 포함한다. pre-fix 및 resize-attempt 원본은 보존한다.

| 캡처 (docs/runtime-captures/TEN-BIMU-CONSTRAINTS-20260908/) | SHA-256 |
| --- | --- |
| briefing-zero-fixed-1280x800.png | 5493C8060FA017BEE8B0686397DAFB2910B767882E2CE29133FEDB5BDD3F1062 |
| briefing-selected-fixed-1280x800.png | F2DFB8E74F2B0B62C6D17732EEA0EF01F5BEFF73678670D1F78E78FB67A710E2 |
| preparation-sealed-fixed-1280x800.png | 6E1828CA24666BACDB4AC27E5C679A24D06DBE077E9F97B132F835A8E984EBAA |

실제 캡처는 1280×800. 720 resize 요청은 무시되어 계속 800이었다.
720 레이아웃·focus·마지막 row/selector 경계는 headless 통과이며 visible720은 NOT_RUN.
unchecked text cue/대비, 정수 count, footer 확대 후 마지막 선택 row 경계의 실제 결함은
task 3 RED/GREEN 및 fixed 캡처로 교정했다. 사람 가독성·접근성 승인을 의미하지 않는다.

## 전체 범위 적대 검토 5회와 학습 반영

각 회차는 승인 정본·제품 diff·untouched consumer·실행 증거·비용·장기 적합성을 함께
검토했다. 아래는 각 회차의 주된 발견과 조치이며 독립 외부 검토를 대체하지 않는다.

1. catalog/model/engine/UI와 current owner를 대조했다. 첫 5전/플랫폼 current 상태 모순을
   발견하여 실패 회귀 후 현재 실행 상태로 교정했다. 새 core/보상/save/유료 의존성 없음.
2. route/result/retry와 bridge/registry 경계를 재검토했다. 정확 unlock ID 집합 검사를
   강화했다. 독립 bridge는 run_seed/duel_index를 별도 expected identity와 비교하지 않는다.
   실제 shell은 현재 RunState receipt를 직접 공급하고 retry는 snapshot 동일성을 검사한다.
   현재 외부 receipt 입력 consumer는 없어 비차단 잔여 방어 개선으로 남긴다.
3. 전체 제품/문서 소비자 검사에서 next_phase 고정과 roadmap provenance 누락을 발견했다.
   untouched 회귀를 current 상태에 맞추고 역사 approval/플랫폼 Gate를 유지했다.
   전체 pytest GREEN과 15개 Godot 회귀로 core·AI·UI·route 영향과 추가 비용을 재확인했다.
4. 실제 fixed 캡처 provenance와 headless UI·focus·대비·node identity 증거를 대조했다.
   visible720을 주장하지 않도록 범위를 교정하고 raw/pre-fix/import/uid를 제외했다.
   텍스트·native layout 수정이며 새 이미지 생성/자산 최종 lock/유료 도구 없음.
5. 승인 Decision·BUILD 승인·제품 12경로와 fresh manifest, CI 실행 경로·기존 public probe,
   상태 JSON/Active Context/roadmap/report를 다시 대조했다. 최종 상태는 local verified,
   exact CI·merge pending. 기존 사용자 dirt는 보존하고 whole Blueprint 승격을 차단했다.

재사용 개선: 현재 실행 상태를 과거 고정 token으로 검증하지 않고 단일 current JSON과
동기화한다. 역사 PR은 historical prefix로 유지한다. 성능 주장은 실측 node identity와
일치시키고 cap/선택/focus 반례를 지속 CI에 둔다. Base 공용 후보는 current/history
validator 구분과 viewport 실제 치수 확인이며 이 작업에서 Base를 변경하지 않는다.

## 남은 작업·증거 한계

로컬 문서/자동 테스트는 PASS. controller의 Windows visible 관찰은 위 3개 상태에 한정.
원격 exact-head CI, protected approval label, safe merge 및 postmerge main readback은
controller가 수행한다. `PROJECT_PROTECTED_CHANGE_APPROVAL.json`은 이번 12경로의 새 승인
기록이며 PR322 archive를 재활성화하지 않는다. 병합 후 일회성 manifest 수명 종료 필요.
전체 UI 입력 캠페인, 모든 선택 조합의 Human 균형, Android 실기기, 실제 게임패드,
접근성 사용자, release 성능·권리·출시 및 전체 Blueprint 완료는 NOT_RUN/미완료다.
