# 합 연출 작업 기준 교정 · 실행 기록

- 기준 main: `6ea28301029875fb9e606bab3b8bb5b61801822b`.
- Work Mode: BUILD/REVIEW, 범위는 운영·연출 명세이며 제품 코드/데이터/이미지 bytes 수정 없음.
- Skill: project workflow router(운영 검증), Base art technique-card/변경관리, 독립 requesting-code-review.
- 승인·조사·3대안·적용/비적용·consumer·남은 자산 제작은 `docs/decisions/2026-09-09_CLASH_STAGING_AND_OUTCOME_DIRECTION.md`가 소유한다.
- 기존 아트 owner, 로드맵, Active Context에서 해당 결정을 발견하도록 연결. Base adoption pin 무변경.
- 신규 2개 문서 연결 회귀 RED → GREEN. 독립 검토에서 사거리 밖/장풍 합을 검 접촉으로 오해할 가능성을 발견했고 회귀를 RED로 확장한 뒤 적용 범위를 검 대 검으로 교정했다.
- 운영 검사 PASS. 이 증거는 문서 연결 검사이며 모션 품질·Godot runtime·Human·Android·출시 검증이 아니다.
- 상단 접촉 핵심 자세 및 승패 반동 자산 제작/승인/연결은 NOT_RUN. 이전 오프라인 GIF의 수동 교차점은 게임 판정 정본이 아니다.
- Base 공용 원칙은 별도 Base current-task branch에서 수정하며 merge/CI/readback은 각 PR의 실제 결과를 따른다. 해당 Base 변경이 모든 프로젝트에 자동 도입됐다고 주장하지 않는다.
- 원래 checkout의 사용자 수정 8개는 보존했다. 되돌리기는 본 문서 변경의 bounded revert로 가능하며 승인 원본 삭제·게임 저장 이관 없음.

## 후속 사용자 요구 · 2회 검토 교정 (별도 변경 계보)

- 입력 main: `3a1a3e46939ed6977d1d8b07815c1f3482f5e242`; 분기 `codex/weapon-staging-coverage-20260909`.
- Work Mode: BUILD(회차 정책)/PLAN(적 요구 기록)/REVIEW. Skill/Mode: project workflow router; Base art/reuse 조사; adversarial `attack/validate-critique/regression-recheck`; verification-before-completion; systematic-debugging(테스트 환경 확인). 이 기록은 검토 계보와 상태를 소유하며 제품 기획을 복제하지 않는다.
- 사용자가 내부 검토를 5회→2회로 명시 변경했다. 최신 Base의 정확히 2회와 자동 세 번째 금지를 확인하고 프로젝트 AGENTS·통합 계약·현재 planning locator를 교정했다. 과거 수행/승인 기록과 Base adoption pin은 보존했다.
- 검 대표 제작, 다양한 적 타입, 새 게임 시작 시 10전 전체 상대 고정 추첨, 단계별 스탯/보유 무공/수련도/별호의 승인 요구를 책임 Decision과 Active Context/로드맵에 연결했다. 새 제품 기능과 이미지 생성은 수행하지 않았다. 새 적 생성 설계축의 비교·상세 수치·반복 정책·저장 호환은 미완료로 기록했다.
- 대안: 정책 문구만 일괄 치환(REJECT: 역사 왜곡), 새 공용 검토 프레임워크(REJECT: Base 기존 2회와 중복), 현재 owner/consumer만 교정 + 역사 보존(ADOPT).
- 열린 PR: #199 front-door Human/Device 안내는 AGENTS의 다른 섹션 변경이며 현재 검토 횟수/적 요구와 의미상 별개다. 실제 해당 diff를 확인하고 보존했다. #200은 별도 과거 Base adoption/파생본 변경이므로 흡수하지 않았다. 관련 신규 PR만 이 변경을 전달한다.
- 전체 검토 1: 최신 사용자 의도·현재 source·open diff·실제 적/저장/이미지 consumer·정본·비용·rollback을 대조했다. `OMISSION`: 통합 계약의 `slice_benchmark_and_adversarial_policy`에 FIVE_PLUS 잔존 → 현재 2회로 교정. `CONFLICT`: 현재 고정 상대/엄격 저장을 새 무작위 구현으로 오인할 위험 → NOT_IMPLEMENTED와 실제 소비자 목록 유지. 별호/인물과 개별 만남의 상태 구분을 요구 기록에 포함했다.
- 전체 검토 2: 교정된 AGENTS/계약/두 신규 Decision/기존 연출 결정/Active/현재 JSON/로드맵/테스트와 untouched 제품 경로를 재대조했다. 과거 5회 기록·정탐 비공개 경계·도겸의 맨손 계열·근접 비수 미지정·자산 final lock이 보존됐다. 검 대표 작업보다 새 적 타입 정의를 먼저 하도록 기존 연출 Decision에도 최신 우선순위 링크를 추가했다. 별도 세 번째 전체 검토 없이 이후 finding 영향 범위만 확인한다.
- 실제 검사: 회차 기대값 변경 뒤 기존 계약 회귀 `1 failed, 3 passed` RED → 교정 뒤 `7 passed`; 관련 통합/adapter 포함 `20 passed`; operating system/freshness/diff whitespace 검사 PASS. 문서 검사 결과이지 새 추첨·별호·모션 runtime PASS가 아니다.
- 전체 suite 첫 실행은 전역 스크립트 캐시가 없는 격리 worktree에서 Godot 타입 해석 실패. 중단 후 Godot 4.7.1 headless editor import, 해당 전투 피드백 `4 passed (21.60s)` 재검증. import 종료에서 ObjectDB 45개/리소스 22개 경고가 관측됐으며 무누수 PASS를 주장하지 않는다. 이후 전체 suite는 **502 passed / 328.51s**. 이는 기존 제품 회귀 포함 자동 검사이며 새 적 기능 구현 증거가 아니다.
- 현재 evidence ceiling: 정책/요구 문서 교정과 관련 검사 통과. 새 적 시스템·이미지·모션·GIF·Human/device/release는 미완료. 상세 기획/제품 작업 전체 완료나 CI/main 병합 완료를 이 로컬 기록만으로 선언하지 않는다.
- 재사용 교훈: 새 worktree는 엔진 import가 먼저이며, 생성 sidecar를 제품 diff에 섞지 않는다. 이미 알려진 로컬 실행 교훈을 재사용했으므로 새 Base 정책/프레임워크를 추가하지 않는다.

## 승인 수묵 합·먹 VFX 제품 적용 · 2026-09-25

- 기준 SHA: `ca2ce2d7242913a775267343b54d87575b2c4375`, branch `codex/ink-combat-runtime-20260924`. Work Mode BUILD/REVIEW; Skill/Mode: project workflow router / verified routing; combat-implementation-handoff / scoped product implementation; combat-ux-and-accessibility / presentation readback; ten-paces-verification / native regression; Hera live-editor / exact project UI evidence; verification-before-completion. 원래 main checkout의45개 사용자 dirty와 코멘트 저장을 보호한다.
- 승인:2026-09-24 최신 “지금 느낌으로 전투쪽 이미지,연출등을 변경…먹 v.fx 연결”. 기존 준비/선택/배치/확정 보호와3/3/4전체 흐름을 재사용한다. 일회 보호 경로 manifest는 실제 변경 파일만 열거한다. 비용/AI/저장/계획 코어 변경 없음.
- CURRENT_SOURCE_RELEVANCE_CHECK/FEASIBLE: 최신 사용자 승인·원화/기하·도메인 사실·공식 CanvasItem textured polygon 자료를 대조했다. 상세 출처·경계는 기존 수묵 Decision. PR342 `d2e1edae7930c11e6c04cfbe269a06c4d3075f14`의 읽기 전용 `combat_motion_presets.gd`, `combat_motion_sequence.gd`, `data/presentation/combat_motion_presets.json` 및 사실/실패 검증만 재사용했다. 광범위한 성장/명단/저장 변경은 이번 수정에 합치지 않았다. #199/#200은 무관 범위로 보존한다.
- 실제 consumer: `CombatBoardPreview._present_ink_bundle` → `InkResolutionModel` → `InkCombatPresentation`/`InkCombatStage`. 승인 원화5개와 기존 crop/alpha 정리로18자세+3원본을 등록했다. 검끝을 따른 textured ink quads, 실제 검 대 검 합의 접점/근접 컷, 실제 회피/막기/실패, 이전 자세에서 다음 수로 연결을 사용한다. 다른 계열은 검 접촉을 꾸미지 않는다.
- 전체 검토1: 승인/정본·순수표시 PR342 diff·domain untouched·정보경계·장기자산/저장/비용을 대조했다. mirrored 합의 피해 중복·대응 비용 재지불·묶음 보상 혼합을 실제 state delta로 차단했다. 비검/identity 없는 합의 가짜 검 접촉을 압력 연출로 교정했고, 고정 capture의 JSON 실수 키 `1.0` 때문에 다른 상대 묶음이 선택되는 fixture 결함을 교정했다. 새 adapter 없는 RED를 먼저 확인했다.
- 전체 검토2: 교정된 제품/원화·data·UI·이벤트/실패·기존 사용자 조작·저장·export·승인 manifest·실행 근거와 문서를 다시 대조했다. Label 최소높이가 하단을 밀어내는 실제 화면 결함을 bounded text/tooltip으로 교정했다. 새 surface가 기존 소리/음량 조작을 가리는 것을 찾아 동일 adapter에 연결하고 키보드 포커스를 구성했다. 결정 접점보다 빠른 승패 공개를 늦췄고, 신규 자산 때문에 역사24개 보존 검사가 섞이는 것을 기존 해시 유지+신규21개 source/destination 해시 검증으로 교정했다. 이후는 이 finding의 집중 재검증이며 세 번째 전체 검토를 만들지 않는다.
- 실제 로컬: model44검사 및 기존 pure motion134검사, native3/3/4묶음·미래행동·준비 geometry복귀·모션감소·즉시skip·pause/restart 취소·기존소리/음량 PASS. 기존 checkpoint/terminal/actionselection/keyboard/1280×720·1280×800·1920×1080배치/판정·10절초/정보경계도 실행했다. 예전 partition 회귀가 구 renderer의 move/reveal 노드를 기대해2실패했고, 현재 실제 CTA consumer의 move/3수·resize·domain parity를 검사하도록 옮겨 PASS했다. 검증 요구를 삭제하지 않았다.
- Windows visible: exact Godot `4.7.1.stable.official.a13da4feb`, 새 worktree Hera editor29364 identity 확인, 실제 scene의 강공·명상·행동 실행 CTA로 새 overlay 진입과 준비 복귀 확인. `runtime-bundles.mp4`는 같은 실제 scene/판정기에 고정 계획을 넣은 무음 자동 촬영이며 일반 AI 플레이 영상이 아니다. 녹화의최종프레임·시간·해시는 runtime-capture/candidates.json을 따른다.
- 현재 한계: 기존2검객의 공통 무대 자세다. 모든 상대 인물/무기별 고유 중간 자세나 모든30기술 독자 안무, 사람의 멋·자연스러움·반복 피로, 실제 Android/접근성 사용자/출시 성능·권리는 완료가 아니다. 에디터 import/export 종료의 기존 ObjectDB45/resource22 경고는 별도로 관측했으며 무누수 PASS를 주장하지 않는다.
- 전달: 로컬 Windows 빌드/전체 회귀/원격 CI와 정상 병합은 아래 최종 readback에 갱신한다. 현재 원격 성공이나 main 반영을 추정하지 않는다.

집중 교정 기록: 전체 검사 도중 불필요한 생성 sidecar를 정리하면서 기존 배경의 미등록 import3개가 로딩 의존성임을 확인했다. 해당 최초 실행은 parse 실패/검사 중단으로 보존하고, 원본 해시가 같은 import/UID8개를 복원해 승인 범위에 명시·등록했다. 원화 bytes나 기존 소스는 바꾸지 않았다. 이후 native710프레임/29.58초 촬영과 신규6개 검사·canonical consumer 검사·승인 계약을 다시 PASS했다. 최초 전체 검사나 실패 촬영을 성공으로 취급하지 않는다. 현재 consumer로 바뀐 타이밍 snapshot 계약 검사는 새 consumer의 실제 state 복사를 확인하도록 갱신했다.

### 로컬 전달 검증 · PR361

- 제품 구현 기준 `3aab20f0665fc97a7b8704edd26836efca35c119`: 전체 pytest **600 passed / 595.73초**, Windows release export 성공, 해당 실행 파일의 제품 시나리오 **50/50·실패0**. 실행 파일과 PCK는 작업 폴더 `build/windows/`에 함께 둔다. 로컬 로그는 `output/ink-validation/full-pytest-final.log`, `export-final.log`, `exported-product/`에 보존한다.
- 최초 PR361 CI에서 BUILD 승인 링크 파일 누락과 교체 전 `CombatActionRevealOverlay`만 찾는 회귀를 확인했다. 기존 사용자 승인 근거를 `docs/implementation/BUILD_APPROVAL_2026-09-25.md`에 연결하고, 같은 실제 CTA의 새 화면에서 미래 수 비공개·현재 사실·판정 전 상태·준비 숨김·서로 겹치지 않는 영역·skip/domain parity를 확인하도록 옮겼다. 6 viewport 실행과 구 직접 feedback consumer 회귀 모두 `COMBAT_ACTION_REVEAL_VERIFY_OK`. 검사 요구 삭제나 승인 범위 확대는 없다.
- 인앱 브라우저에서 실제 녹화29.583초가 끝까지 재생되고 오류 없이 종료됨을 확인했다. 첫 탭은 브라우저 renderer가 종료되어 새 검수 탭으로 복구했다. 녹화 후 제품 포커스 버튼의 글자색을 명확히 하는 미세 교정이 있으며 영상의 동작·수치는 동일하다.
- PR: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/pull/361. exact-head 원격 검사 및 정상 병합 여부는 GitHub live metadata를 따르며 아래 최종 main readback에서 확정한다.

추가 원격 full-validation의 실제 게임 회귀도 대조했다. 기존 5초 reveal 제한은 승인된 긴 안무의 전체 묶음을 기다리지 못해 RED였고 24초의 유한 한도로 교정했다. 구 절초 atlas 전용 playback 검사는 새 먹 consumer의 실제 card/actor/execution timing·계열·승인 붓·양의 표시 기하·결과 영역 분리를 검증하도록 옮겼다. 기존 예약·취소·기세·잠금 검사는 유지했다. full-validation의 native31종 중30종이 먼저 통과했고 남은 절초 회귀는 집중 교정 후 `ULTIMATE_UI_RESERVATION_VERIFY_OK`; 게임 제품 bytes 추가 변경 없이 모두 검증됐다. 정상 속도 실제 CTA와 별도 전용 소비자 회귀를 함께 유지하며 미래 행동/일반 자원 판정 요구를 낮추지 않는다.
