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

### 최종 main readback · PR361

검토 HEAD `2bdf345f5110baccaab335994ec6475391be8602`, 원격 35SUCCESS/0FAIL/0PENDING, 미해결 검토0을 확인하고 2026-09-24T15:56:35Z에 main `53b007e3ad1b1dd7eb3b1ef574a2391bb7abf8cb`로 정상 병합했다. 전체 tracked tree가 검수 후보와 동일하다. 일회 승인 종료와 보호 기준선/파생본 동기화는 같은 날짜 PR361 승인 종료 기록에 연결한다. 제품 코드/원화/영상은 이 closeout에서 바꾸지 않는다. 원래 checkout45dirty와 사용자 리뷰 SHA256 `afd73518d7bf507728e500045733ef5b9c7a466dc3feeba3c62331455cdd2dac`은 보호했다.

원격 native 입력 검사는 일반 연출 속도 `ordinary_defaults`에서 453094ms 동안 295번의 실제 버튼 입력으로 비무10승·보상10회·행로36회를 완료했다. 실패0이며 공개 정책으로 선택한12종 행동을 사용했다. 근거는 [PR361 제품 검사](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/actions/runs/36022075768/job/107709315719)의 `NATIVE_CAMPAIGN_SUMMARY`다. import 종료 때 자원22개 경고는 남아 있으며 실행 실패나 누수 없음으로 바꾸어 보고하지 않는다.


## 화면별 수묵 이미지·하단 확대 · 2026-09-25 추가 승인

- 기준 SHA `7f549217ea4b2496613b9b4cf3176bccfede2c58`; Work Mode BUILD/REVIEW; Skill/Mode: 프로젝트 router·imagegen·HTML blueprint·Hera live/UI·전투 UX·reference-freshness/verification, 같은 승인 continuation. 최신 제작·게임 연결·HTML·직접 폐기 지시를 BUILD 승인/기존 Decision에 연결했다.
- 생성9회: 배경6장·복면9자세·복면 접점1장·도겸 맨손9자세. 신규 runtime25파일+기존 stable ID 초상2파일 교체, 플레이어 승인 원화 재사용. 구13파일/import 실제 삭제, PDF 역사·해시 ledger만 유지. 변경 전후 사용자 코멘트 해시는 별도 확인한다.
- RED: 새 하단 검사가 폰트/결과 영역/배경13항목에서 실패했다. 최소 구현 뒤 네 화면 크기에서 GREEN. 1차 전체 pytest는584통과/16실패였으며 실패 대부분은 삭제된 초상 원본을 여전히 부르는 HTML/역사 기대값이다. 구 파일을 복구하지 않고 현재 manifest consumer와 해시 있는 명시 폐기 계약으로 교정했다.
- 전체 검토1: 정본/승인·제품 전체 diff·규칙/AI/저장 미변경·untouched 적14명·준비 조작·원본/파생/삭제·HTML·실행 증거·비용·재사용을 대조했다. 실제 여정이 무작위여서 미리보기 배외검객만 교체하면 도겸이 옛 그림으로 나오는 결함, 밝은 브리핑 위 저대비 글자, 자동 tooltip의 결과 가림, HTML의 옛 시작/준비 이미지 override를 확인해 교정했다. 촬영 실패의 빈 save_id/seed 재현은 fixture에서만 고쳤다. 새 게임 규칙·전역 도구 설치는 없다.
- Windows native 캡처: 실제 Godot4.7.1,1440×900. 메인/시작/브리핑/준비는 격리 정상 이동, 결과/행로/휴식은 명시 UI fixture다. 전투 녹화는 실제 resolver 고정3/3/4계획,706프레임/24fps/29.417초·서로 다른 전체 프레임491개·오류0. 일반 AI 대전 녹화나 승리 증명으로 과장하지 않는다.
- 현재 적/투명 alpha/배경/인물 비율/준비 구획/휴식/도감 소비자·브리지가 native8종 PASS. 사용자 시각 품질·반복 관람 체감·Android·출시 성능/권리는 NOT_RUN/기존 미확정이다. 전체 검토2와 전달 결과는 아래에 누적한다.

- 전체 검토2: 수정된 전체 후보의 정본/실제 diff/기존 preparation·resolver·AI·save·14명 미변경/생성 source/동작/HTML/비용과 유지보수를 대조했다. 옛 flow·briefing·preparation 예시가 일부 남는 연결, 4수 링크가 회피 구 영상으로 가는 연결, 이전 영상 해시/710프레임 metadata, byte-identical 구 이미지3중복을 추가 발견했다. 현재 native 예시/정확한3/3/4영상/706프레임 해시로 고치고 중복3개도 명시 ledger 뒤 삭제했다. 상태창/행로 와이어프레임과 역사 회피 설명은 현재 영상인 것처럼 바꾸지 않는다. 전체 검토는 정확히2회; 이후 확인은 이 결함들의 영향 검사다.
- 최종 로컬: pytest **602 passed / 583.45초**; 확대·상대 binding 포함 focused native8종 PASS; Windows export와 내보낸 실행 파일 제품 시나리오 **50/50·실패0**. export 종료의 기존 resource22 경고는 남아 있으며 무경고로 주장하지 않는다. 공개 게임의 첫 상대는 계속 무작위다.
- 인앱 브라우저: 새 화면 목록3열·종류/안정 번호/용도/inline 코멘트 확인, 로딩 완료 이미지 깨짐0. native MP41440×900/29.416667초가 실제로 끝까지 재생되어 ended=true/readyState4/error없음; 브라우저 오류로그0. 기존 자동 저장 코드는 미수정이고 사용자 코멘트 원본 SHA256 `afd73518d7bf507728e500045733ef5b9c7a466dc3feeba3c62331455cdd2dac` 동일함을 확인했다.
- 실제 사용자 시각 검수·키보드/마우스 체감·반복 관람의 멋·Android·실기기·출시 권리/성능은 별도다. 이번 정상 PR/원격 exact-head/merge 및 일회 승인 종료는 아래 전달 readback에 기록한다.

- 검토2 영향 교정: 상대 export 정본 재생성 검사에서 배외검객 portrait의 상위 ADDITIONAL_OPPONENTS owner가 구 삭제 파일을 가리키는 실제 drift를 발견했다. owner를 현재 등록 초상으로 연결하고 export --check 회귀를 추가했다. 기존 제품 data의 동일 경로를 재생성해 일치시켰으며 능력치·명칭·로스터·저장 ID는 바꾸지 않았다.

- PR363 CI의 영향 교정: 표시용 초상 경로까지 과거 저장 fingerprint에 포함된 탓에 schema2/5/6 고정 저장 회귀가 RED였다. 명시된 배외검객 신·구 경로 한 쌍만 identity 계산에서 호환 처리해 과거 bytes를 유지하며 live 경로·나머지 필드 검사는 보존했다. 기존 pending/applied 저장 decode와 게임 내용 변경 거부가 GREEN이다. HTML 링크 검사는 fragment를 파일명으로 취급하던 오류 및 구319 정지화면 기대값을 현재 실제 캡처로 교정했고 **1266 views / 21590 local links PASS**, 자동 저장/충돌·리뷰 동기화·검색3종도 PASS. native terminal 검사는 긴 묶음의 완료를 최대20초의 실제 시간 제한 내 기다리도록 교정했다. 실제 연출 속도·종료 규칙은 변경하지 않았다.

- 저장 호환 교정 후 `9d555ffbfde6fafda7707ba9f641492eb777419a`에서 Windows 빌드를 다시 만들어50/50 PASS했다. terminal/event checks/event run/legacy giyun run/variable save compat도 PASS했다. 전체 소스 해시가 교정 전 상태로 남지 않도록 native9화면과3/3/4 영상을 재촬영했다. **현재 전달 영상은686프레임/24fps/28.583초**, distinct491·runtime오류0이다. 위706프레임 기록은 교정 전 촬영 이력이며 현재 clip/manifest는 새 촬영으로 갱신했다.

### 최종 전달 readback · PR363

추가 저장/상위 owner 회귀12개는517.69초에 모두 PASS했다. 메인 촬영 도구는 실행마다 별도 임시 저장을 써 오래된 테스트 저장 안내가 예시에 섞이지 않게 했다. 새 여정 화면 재촬영7장 중 실제 변화는 메인1장이며 전투 영상/제품 bytes는 동일하다.

검토 HEAD `0af72791199b41bbefdcbdf2bd43de4920eb8f26`, 최신 workflow별 34SUCCESS/실패0/진행0, 미해결 검토0을 확인하고 2026-09-24T19:49:31Z에 main `df3b7538f16e66208e29f4f4c04c85567c34ff5c`로 정상 병합했다. 전체 tracked tree가 동일하다. 최종 HTML1266화면/21595내부링크 PASS와 브라우저28.583333초 ended=true/error없음을 확인했다. Windows 검수 ZIP의 실행 파일/PCK bytes와 CRC를 검증했다. 기존 사용자 코멘트 SHA256 `afd73518d7bf507728e500045733ef5b9c7a466dc3feeba3c62331455cdd2dac`은 동일하다. 일회 승인 종료는 `docs/operations/2026-09-25_PR363_PROTECTED_CHANGE_APPROVAL_RECORD.md`로 연결한다.

원격 ordinary_defaults native 캠페인은447829ms 동안295회 실제 입력으로 비무10승·보상10회·행로36회를 완료했고 실패0이다. [원격 제품 검사](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/actions/runs/36049087231/job/107800173797)의 NATIVE_CAMPAIGN_SUMMARY를 근거로 한다. 사람 플레이의 재미나 최종 시각 승인을 대신하지 않는다.

## 실제 실행·메뉴·준비 구도 후속 · 2026-09-25

- 기준 SHA `549dc3aaed9781c02d9c9915ea5f294689c3038c`; Work Mode BUILD/REVIEW, Skill Mode implementation/runtime-validation/reference-freshness. 프로젝트 router·combat UX/구현·검증, HTML blueprint, Godot live-editor의 기존 접수와 승인을 재사용한다.
- 범위: 저장 오류로 잠긴 전투 실행 복구, 삽화 6종 중 4권 시작 선택, 이어하기/도감/감상 설정/종료의 실제 동작, 대각선 준비 구도, 연속 합·반격·회피와 확대 컷의 연결. 3/3/4·행동 선택/취소/확정·공유 판정·숨은 상대 정보·AI·저장 schema는 유지한다. 새 라이브러리·설치·원화 생성 비용은 없다.
- CURRENT_SOURCE_RELEVANCE_CHECK / FEASIBLE: 기존 승인 수묵 원화·Project Moon 조사·실제 consumer를 REUSED_EVIDENCE로 사용했다. 공식 [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html)·[Control](https://docs.godotengine.org/en/stable/classes/class_control.html) 문서를 대조했으며 실제 채택 Godot4.7.1에서 입력·좌표·캡처·회귀를 확인했다. 외부 문서를 현재 작품의 재미/아트 승인으로 쓰지 않는다.
- 실제 사용자 저장의 읽기 전용 복사본에서 이동→회피→준비 해결 후 `[강건]`의 정상 문자열 `description`을 codec이 거부하는 RED를 재현했다. 선택 문자열만 허용하고 숫자/객체 description·알 수 없는 필드는 계속 거부하는 GREEN을 확인했다. 기존 schema6 bytes나 게임 규칙 변경 없음.
- 업데이트 Godot AI4.2.3을 정확한 `ink-screen-refresh-20260925` editor/session에 연결했다. 사용자가 수정한 addon은 보존하고 hash-guard로 승인 src만 복사해 검증했다. 원본 저장에는 쓰지 않았다. 실제 Continue→2번째 묶음 복구, 마우스 막기3개 배치→실행→3번째 묶음/SAVED/blocked=false, 공개된 3수 결과, 도감 삽화·탭·Esc, 설정·Esc, 종료 버튼으로 game stopped를 확인했다. 읽기용 eval에서 잘못된 속성 접근으로 발생한 도구 검수 오류2건은 제품 오류와 분리하고 재실행했다.
- 전체 검토1: 다섯 요청과 정본·전체 diff·미변경 resolver/AI/save/다른 화면·비용/유지보수를 대조했다. 기초 도감의 누락 삽화, 작은 창의 잘린 카드, Esc에서 제거된 viewport 접근을 발견해 실제 atlas/두 줄 높이/닫기 순서로 교정했다. 실제 native 화면과 RED→GREEN 및 기존 입력 회귀를 함께 확인했다.
- 전체 검토2: 교정된 전체 후보와 열린 PR342의 겹치는 표시 모듈, 브리핑/보상/행로/기존 저장·HTML 번호/코멘트·검증·장기 책임을 다시 대조했다. 종이 테마를 상속한 계획 글자가 검은 바탕에서 사라지는 문제와 확대 원화의 양옆 직사각형 경계를 발견했다. 계획 글자 색상을 고정하고 확대 화면을 영역 전체에 맞추며 회귀 RED→GREEN을 확인했다. 미생성 상대는 공통 수묵 자세를 사용하고 고유 외형 완성으로 주장하지 않는다. 전체 검토는 정확히2회이며 이후는 이 결함들의 영향 검사다.
- 교체 완료된 구 일반 적 원화의 runtime/approved/candidate 동일 PNG3개를 SHA256 확인 후 실제 삭제했다. 번호와 승인 이력은 기존 폐기 ledger에 남겼다. 승인47삽화와 기존21개 자산 기록의 hash, 상대별 고유 기존 초상은 별도 보호한다.
- 로컬 증거: unittest579 PASS, 저장 준비 회귀/새 UI/모션 연속성/기존 카드·배치·키보드·초점·전투 정보·저장 검증 PASS. 최종 native11화면과 실제 resolver 고정계획3/3/4 녹화723프레임/24fps/30.125초/서로 다른511프레임을 HTML source manifest에 연결했다. 도감·설정은 실제 title consumer이며 결과/행로/휴식 촬영은 명시 UI fixture다.
- 검증의 한계: 새 연출의 멋·자연스러움에 대한 사용자 최종 검수, 모든 적의 고유 수묵 자세, Android·실기기·출시 성능/권리는 별도다. editor import 종료에 기존 resource22 정리 경고가 남아 있으므로 무경고라 주장하지 않는다. 최종 pytest/Windows 빌드/HTML 브라우저/PR 체크와 main readback은 아래에 누적한다.

- 집중 영향 확인: 전체 pytest603개 중601통과/2실패를 먼저 기록했다. 하나는 촬영/발행 중 manifest의 resolution이 아직 결합되지 않은 시점, 하나는 화면 목록을9개로 고정한 옛 기대값이었다. 최종11화면 발행 후 도감/설정 menu분류·중복없는 경로까지 확인하도록 교정하고 해당2파일11검사가 모두 PASS했다. 전체603개를 마지막 상태에서 한 번에 재실행했다고 주장하지 않는다.
- HTML1268 view/21499 local link PASS. 인앱 브라우저에서30.125초 MP4가 readyState4, ended=true, media error없음으로 끝까지 재생됐다. 브라우저 error log0. 구조도 하단에 남던 옛 준비 참고안/합 삽화 표기도 현재 촬영 근거를 읽도록 교정했다.

- PR365 원격 영향 교정: full-validation의 기존 카드 상단 band/양 검객 동일 높이·같은 바닥선 검사가 승인된 좌측 삽화/대각선3:2구도와 충돌했다. 실제 source-alpha 독립 측정 및80% 축소 negative control은 유지하고 새3:2비율·깊이·모션 envelope90%상한·카드 내부 영역/글자 비중첩으로 검사했다. 해당 workflow native31종 전부 로컬 PASS; 제품 bytes는 추가 변경하지 않았다. Windows50/50·ZIP해시/CRC PASS, 최종 HTML1270view/21563local link PASS.

- 같은 원격 제품 job의 일반속도 캠페인은452225ms/실제 입력295회/비무10승/보상10회/행로36회/실패0으로 완료됐다. 근거는 [PR365 native 캠페인](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/actions/runs/36077007132/job/107890430945)의 NATIVE_CAMPAIGN_SUMMARY다. 이후 Linux에서 네 무공이 모두 들어가는데도 스크롤을 필수로 기대한 구 검사가 실패했다. 전부 보이는 상태를 검사하고 시험용 넓은 버튼으로 실제 overflow/마지막 항목 접근/키보드 자동 스크롤을 강제 검증하도록 고쳤다. 강제 overflow의 경계 좌표 오차0.00005px는 다른 기하 검사와 같은0.5px 허용으로 다뤘다. 세 viewport를 포함한 해당 검사와 휴식/atlas 후속 검사는 PASS이며 제품 bytes는 그대로다. 원격 job 전체 성공은 새 exact-head 결과에서 확인한다.

### 최종 전달 readback · PR365

검토 HEAD `92be01fb1385ab8373f06ad27117268acc538fd7`의 최신 workflow별 33SUCCESS/실패0/진행0, 미해결 검토0, 최신 main을 확인하고 2026-09-25T00:54:47Z에 main `9f0ce7ddf3a7aad95e82b725d99bbd5248bdd60d`로 정상 병합했다. 전체 tracked tree가 동일하다. 원본 사용자 저장8개와 사용자 코멘트 SHA256 `afd73518d7bf507728e500045733ef5b9c7a466dc3feeba3c62331455cdd2dac` 동일함을 확인했다. Windows 실행 파일/PCK/설명서 ZIP의 해시와 CRC 검증 PASS. 로컬 실제 실행·자동 CI·사용자 시각 승인·출시를 구분한다. 일회 승인 종료는 `docs/operations/2026-09-25_PR365_PROTECTED_CHANGE_APPROVAL_RECORD.md`.

최종 exact-head의 [일반 속도 native 입력 캠페인](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/actions/runs/36078610083/job/107895307586)은451114ms/입력295회/비무10승/보상10회/행로36회/실패0이며 이후 저장·카드·휴식 검사까지 전부 통과했다. 승인 종료 파생본은 adapter를 commit한 뒤 Git의 정규 bytes 기준으로 재생성해 Windows 줄바꿈 해시 차이를 예방했다.

승인 종료의 로컬 검사에서는 작업 사본 adapter만 CRLF로 남아 raw-byte 기대값1개가 먼저 실패했다. 해당 파일을 저장소에서 지정한 LF로 정규화한 뒤 lifecycle/기준선/adapter9검사가 모두 PASS했다. 승인 operating contract와 postmerge canon 검사도 PASS이며 제품 diff는 없다.


## 2026-09-25 참조 준비 화면의 UI 배치·구도 교정

기준 main89cee855 / BUILD / combat-ux-and-accessibility: design-review, ten-paces-verification: runtime-validation, Hera live-editor: 실제 입력·기하. 최신 사용자960093f1참조와 UI배치·구도라는 정정으로 승인 범위를 한정했다. 기존 수묵 원화 재사용, 양끝 소형 HUD/초상·중앙 거리·오른쪽 관찰·종이 계획 한 줄·오른쪽 실행·5×2 카드/고정 상세를 연결했다. 규칙·AI·저장·연출 코드는 변경하지 않는다. 같은 결정의 공식 Control 근거 REUSED_EVIDENCE, FEASIBLE.

검토1: 정본/실제13표현파일/공유 카드·상세·HUD 소비자/기존31native검사와 신규4크기 반례를 대조했다. 초기 RED93개, 이후 작은 viewport 카드·탭/안내 겹침과 관찰/실행 버튼 중첩, 원어 폰트 요약 높이, 확장 전장 HUD영역 경계, 빈 상세 초기 상태, 카드효과 tooltip 대응을 교정했다. 예전 가로카드/거대한HUD/왼쪽 실행 그룹을 고정한 테스트는 최신 승인 구도로 갱신하고 실제 입력·대응결과·정보비공개 검사는 유지했다. 신규 원화·도구 설치·코어 복제 없음.

검토2: 수정 후보 전체 diff와 미변경 판정/카메라/저장·별도도감 소비자를 다시 대조했다.4실제 viewport의 카드/헤더/상세/관찰/실행 비중첩, 공개 자원과 숨은 적자원, 고정미리보기와 실제배치 분리를 검사했다. 실제 폰트 상속으로 작은 글자를 보강했고 관찰 갱신의 낡은 안내2반례, 기존64px 최소 슬롯과84px 부모의 넘침, 이전 결과의 옛 오른쪽 빈칸 의존을 발견했다. 각각 갱신 레이아웃,96px 계획 줄,계획 위 결과 한 줄로 교정해 기존 입력/정보 경계/inline 회귀를 통과했다. 전체 검토는 정확히2회이며 이후는 발견 결함의 영향 검사다.

Godot AI4.2.3 exact session `ten-paces-hidden-moves@e3c0b4f76e16bdac`에서 사용자 addon313파일을 해시로 보존했다. 별도 저장 fixture에서 실제 마우스 막기3개→키보드 실행→`next_bundle_ready/bundle2/placements0/detail_visible=true`와 결과 문구를 확인했다. run9 LIVE/current_run_errors=[] 및 fresh game framebuffer를 확인했다. 앞선 두 읽기 eval의 잘못된 속성 접근은 제품 오류와 분리하고 종료/재실행했다. 원본 플레이 저장과 코멘트에는 쓰지 않았다.

전체 Python603검사의 최초 실행은601PASS/2FAIL이었다. 하나는 옛 상단 고정 card anchor 검사로 새 하단 anchor와 native 비중첩 검사에 맞춰 교정했고, 다른 하나는 화면 재촬영 중 미완성 capture manifest를 동시에 읽은 경우였다. publish 완료 후 해당11검사 전부 PASS했다. 실제732프레임/30.5초 영상과11화면을 현 소스 해시로 다시 연결했다. 자동/Windows/HTML/PR 최종 결과는 아래에 누적하며 사용자 시각 검수·Android·출시는 NOT_RUN이다.

교정 영향 검사: full-validation workflow의32native 시나리오 전부 exit0/ERROR0, Windows export의실제50시나리오50PASS, HTML1270view/21572내부연결 PASS. export 작업 자체는 성공했으나 에디터 종료 시22resource/45ObjectDB 정리 경고가 남았고, 제품 실행 검사에서는 오류가 없었다. 새 코드·실제 촬영·Windows PCK를 함께 검증했으며 task-local capture4크기는960×640/1280×720/1280×800/1920×1080이다.

원격 영향 검사에서는 준비용 글꼴이 결과창까지 상속돼 Linux960×640의 긴 행동명과 결과가 겹치는 반례를 발견했다. 새 테마를 준비 조작부에만 적용해 기존 해결 화면의 폰트와 줄바꿈을 유지했다. 기존 card-context 검사는 제거된 세 번째 자식 대신 실제 tooltip 효과를, bridge 검사는 새 승인 원화의 유효한 AtlasTexture 영역과 상대 ID 경로를 확인하도록 갱신했다. 두 검사 및 전체32native 재실행 PASS. 제품 코드50a60ab6에서 Windows50/50 재검증, 실제11화면과726프레임/24fps/30.25초/서로 다른511프레임을 다시 촬영해 source manifest와 HTML에 반영했다. 초기 원격 승인 검사는 PR label 미부착이 원인이며 기존 사용자 승인에 맞춰 정상 label을 적용한 이후 PASS했다.

## 2026-09-25 참조 그대로 구현 · 캐릭터만 교체

앞 절의 가로 재해석 후보는 사용자에게 거절됐다. 최신 지시 “이미지 그대로 구현시키고 캐릭만 맞춰서 바꿔”와5676141a참조, 같은 고해상도18211d8c참조로 범위를 다시 고정했다. 기준 main89cee855 / 작업 시작9c5aed6e / BUILD·REVIEW / 기존 project router·combat UX·Hera live-editor·imagegen·HTML blueprint·runtime validation의 승인을 재사용한다. CURRENT_SOURCE_RELEVANCE_CHECK=REUSED_EVIDENCE: 기존 공식 Control/AtlasTexture 및 같은 준비 화면 소비자 근거를 재사용하며 새 게임 규칙 판단은 없다. 실제 네이티브 Controls·실행 환경·기존 입력 검사를 대조한 결과 FEASIBLE이다.

참조의1086×1448세로 비율, 초상/상태·중앙 거리·관찰·계획/진행·5×2카드·고정 상세·하단 안내 위치를 재현했다. text-free 배경과 세 캐릭터 영역을 실제 이미지 도구로 제작하고, 사용자 제공 참조에서 기초10삽화 영역만 런타임 AtlasTexture로 사용한다. 수치·버튼·선택·판정은 실제 Controls와 기존 데이터가 소유한다. 첫 만남 도겸은 이름·초상·대치 외형을 같은 인물로 연결했다. 새로운 배경/캐릭터/참조사용3자산은 중앙 manifest에 출처·해시·consumer·최종 시각 검수 대기 상태로 등록했다. 기존47삽화와21기존 기록의 불변 해시는 변경하지 않는다. 외부 참고 이미지의 독립 원저작권·출시 권리 완료를 주장하지 않는다.

전체 검토1: 새 후보 전체의 참조 구도·모든 변경 모듈·공유 카드/상세/HUD·미변경 판정/AI/저장/해결 연출·작업 비용/책임을 대조했다. 초기 비율/배경8반례를 RED로 확인했다. 이웃 검객의 칼 조각, 초상 사각 경계, 카드 삽화 영역, 부모 scale을 무시하는 이전 기하 진단, 상세 문구 밀도를 교정했다. 유효 alpha·실제 노드 경계·30기술/도감 소비자·기존32native 결과와 다섯 크기의 실제 화면을 확인했다. 상단 숨은 상대 수치를 임의 생성하지 않는다.

전체 검토2: 전체 수정 후보와 정본·미변경 전투/저장·개인 리뷰·addon·영상/HTML·권리 상태를 다시 대조했다. Godot AI 실제 막기3개 입력→진행→bundle2/next_bundle_ready/placements0/detail_visible=true를 확인하고 무공 탭까지 눌렀다. 이후 결과 안내가 옛 가로 좌표로 덮이는 반례를 발견했다.4viewport RED를 먼저 추가하고 결과 안내의 단일 참조 좌표 consumer로 교정해 GREEN 및 inline 기존 검사 PASS를 확인했다. 옛 원격 검사의 “기초 상세에는 삽화 없음” 기대는 현재 기초 삽화의 정확한 atlas/영역으로 대체해30무공 전환 뒤 남는 삽화가 없음을 검사했다. 전체 검토는 정확히2회이며 이후는 발견 결함의 영향 확인이다.

Python unittest 전체579검사의 첫 실행은577PASS/1FAIL/1ERROR였다. 신규3자산을 이전21불변 기록에 섞은 기대값은 신규 ID3개를 명시적으로 분리하고 기존 hash/count를 그대로 유지한다. ERROR는 실제 화면 촬영 중 아직 resolution이 추가되지 않은 manifest를 읽은 동시 발행 시점이다. 발행 완료 후 영향 검사를 별도로 재실행한다. 전체579재실행이나 사용자 최종 시각 승인으로 확대하지 않는다.

업데이트 Godot AI4.2.3 exact session ten-paces-hidden-moves@e3c0b4f76e16bdac의 실제 게임 창에서 입력·상태·fresh framebuffer를 확인했다. 진단용 eval의 들여쓰기 오류1건으로 중단된run11은 제품 오류와 구분하고run12로 다시 시작했다. 사용자 addon313파일, 원본 사용자 작업/저장/52리뷰는 보호한다. 새 시각 결과는 사용자 final lock 전이므로 PR367은 Draft이며 이 후보의 main 병합·Human/Android/출시는 NOT_RUN이다. 최종 실행본·HTML·원격 체크 결과는 아래에 누적한다.

집중 영향 교정: 원격56d1fb06의 실패는 신규자산3개를 옛21개에 포함한 별도 combat-contract 기대, 승인경로 목록의 중앙 manifest 누락, 옛 가로 상태창/계획면에 고정된17기하 기대였다. 기존21해시와47승인 삽화 불변 검사는 유지하며 신규3ID/원본 해시/검수대기 상태를 정확히 검사한다. 보호경로 승인은 기존 사용자 지시에 포함된 중앙 등록 경로1개를 보완했다. 실제 그려지는 준비 자원바와 진단 snapshot을 같은 좌표로 연결했다. 참조 내부의실제Control 경계·정보/초상·다음묶음 복귀를 검사하고 해결 중 원화 alpha·이동궤적·negative control은 그대로 보존했다. 해당 contract·partition·product viewports·기초/무공 아트·inline·정보경계 관련 검사가 PASS다.

실제 촬영은 최종734프레임/24fps/30.583초/서로 다른511프레임,11화면이다. 발행 후 Python 실패 관련7검사가 PASS했다. 앞선Windows 제품56d1fb06의50/50과ZIP CRC/실행파일/PCK byte일치 PASS, HTML1276view/21682내부연결 PASS를 확인했다. 인앱브라우저 준비 그림1086×1448과 확대, 앞선723프레임 영상30.125초의 끝까지 재생/미디어 오류없음/콘솔오류0을 확인했다. 자원바 진단 교정 뒤 갱신된734프레임과 최종 실행본은 전달 전 다시 확인한다. 이전 촬영과 현재 촬영의 수치를 섞어 완료 주장하지 않는다.

### 참조 재현 실행본 전달 · 최종 제품 코드 0f4d446a

7b6b776f의 원격33검사 중32개는 통과했고 automated-product-evidence는 Linux 대체 글꼴의 실제 최소높이27px가 상태 이름의23px 칸을 넘는2반례로 실패했다. 0f4d446a에서 해당 이름만 실제 글꼴 최소높이에 맞춰 축소했다. Windows 준비 화면의 PNG bytes는 교정 전후 동일하며 참조의 위치·여백은 유지했다. 기존 실제 기하·해결 원화·이동 negative control을 포함한 partition 집중 재검사가 PASS했다. 원격 최종 HEAD 결과는 PR367의 live metadata를 따르며 이전 실패를 성공으로 취급하지 않는다.

0f4d446a로 Windows release export와 실행 파일의50시나리오를 재실행해50PASS/0FAIL을 확인했다. `build/windows/TenPaces-Reference-Preparation-20260925-Windows.zip`은 EXE·PCK·한국어 실행 안내를 포함하며188682153bytes, SHA256 `584d127e7a00f7a81a9e6da2d6009634389fed3dcb23e6113f6d314501fe48b0`이다. ZIP CRC와 압축 전후 각 파일 SHA256 일치 PASS. 로컬 근거는 `output/prep-layout/reference-delivery.json`과 `reference-windows-final/`이다. export 종료의 기존45 ObjectDB/22 resource 정리 경고는 남아 있으며 실제 제품 시나리오는 오류0이다.

동일 제품 코드에서 native9화면+해결2화면, 실제 판정기의 고정3/3/4 묶음735프레임/24fps/30.625초/서로 다른511프레임을 다시 촬영·발행했다. 촬영 자체의 `INK_SCREEN_CAPTURE count=9`와 `INK_COMBAT_RUNTIME failures=0 frames=735`를 확인했고 manifest에 소스와 미디어 해시를 갱신했다. 최종 HTML과 브라우저 재생 readback은 이 발행본을 사용한다. 원본 사용자52리뷰·기존 작업·Godot AI addon313파일을 보호한다. 새 시각 결과의 사용자 최종 확정 전이므로 PR367은 Draft이며 main 병합·Human/Android·출시는 완료로 보고하지 않는다.

최종 브라우저에서735프레임 영상이30.625초 끝까지 재생된 ended=true/readyState4/media error=null/console errors0과 준비 원본1086×1448의 정상 확대를 확인했다. Godot AI run15 LIVE/fresh framebuffer/현재 실행 오류없음, addon313해시와 사용자 리뷰 해시 보존을 다시 확인했다. HTML1276view/21682연결 PASS. 로컬 readback은 `output/prep-layout/reference-browser-final.json`이다.

f0901652 원격 검사32개는 PASS했다. 제품 job은 원래15분 제한으로 취소됐지만, 그 직전 실제 normal-speed 캠페인은295입력·비무10승·보상10회·행로36회·545748ms·실패0으로 완료됐다. 후속 단계와 근거 업로드는 취소되어 PASS로 간주하지 않는다. 원인인 job 전체 한도만25분으로 늘려, 캠페인 자체의15분 유한 한도와 사전 import/나머지 검사를 모두 수용한다. 실제 판정·일반 연출 속도·반례·검사 항목은 줄이지 않는다. 새 HEAD 원격 결과는 동일 PR367의 live metadata가 소유한다.

취소된 이후23검사를 로컬에서 실행해 제약 안내 영역의 탭 경계4px 교차, 옛 초상 숨김 기대, 정수 스크롤의 변환 후0.552px 반올림을0.5px로 제한한 기대를 확인했다. ce56315d에서 안내의 오른쪽 기준을 유지하고 영역만12px 좁혔다. 초상 검사는 실제 참조 AtlasTexture 표시와 자원바 비중첩을 확인하도록 옮겼으며, 키보드 자동 스크롤은 최대1 native pixel을 부모 transform으로 변환한 유한 오차만 허용한다. 제약 UI·카드 요약·atlas consumer·참조 배치 집중 재검사 PASS, 나머지21개도 실행 PASS다. 새 round/전투/저장 규칙은 없다. 준비 PNG bytes는 이전 후보와 동일하다.

전달 최종 제품 ce56315d에서 Windows50/50·실패0, 새11화면,708프레임/24fps/29.5초/고유511프레임을 다시 생성·발행했다. ZIP188681969bytes, SHA256 `304f02793f706abaf924e8d6fffc8c1bf1269239324b73d52f59ab9f7135a85a`, 압축 CRC/구성 파일 해시 일치 PASS다. `output/prep-layout/reference-delivery.json`과 `reference-windows-current/`가 최신 로컬 실행본을 식별한다. 첫 Windows helper 실행은 구 PowerShell의 빈 ExitCode 때문에 보고 단계가 실패했지만 실제50시나리오는 성공했으며, 현재 PowerShell7로 재검증해 실제 종료0과 근거 생성을 확인했다. 원격 최종 통과 전에는 CI 전체 PASS를 주장하지 않는다.


### HTML 폐기 요청 실행 · 2026-09-25

기준0906af9b72889181c0ef4120f020614202eaae51 / BUILD·REVIEW / building-reviewable-html-blueprints + project workflow router / asset cleanup·reference freshness. 최신 사용자의 실제 폐기 지시와 GUT13파일 유지 답변을 재사용한 승인 범위다. CURRENT_SOURCE_RELEVANCE_CHECK: 파일 폐기 판단은 공용 검토 기록·실제 참조·원본 해시가 직접 근거이므로 외부 조사는 NOT_APPLICABLE. FEASIBLE. 별도 화면 개편과 프레임 전투는 계획만 수행한다.

공용 reviews.json revision108·SHA256 cc4201ad3c187520ba128b9b5a48fa09b3f993fdec8f18511cdea3f6a133cd88의102요청: 저장소85원본+삭제대기2캡처 삭제, 기존1삭제 확인, GUT13원본 유지/목록 제외, PR342후보1발행 사본 삭제. 총342개 원본·파생 미리보기·sidecar 파일의 부재를 확인했다. 다른 PR의 원본과 요청하지 않은 승인/런타임 복사본은 이번 변경에 포함하지 않는다. 파일별 번호·요청ID/시간·원래 경로·해시·복구 기준은 IMPLEMENTATION_READINESS.json의 기존 retired_images에 누적했다.316/317은 삭제대기 사본과 이전 Git 촬영본의 해시를 별도로 명시했다. IMAGE_NUMBERS.json 및105개 사용자 코멘트 원본의 해시는 그대로다.

기초 CardView의 구 배지·비용 SVG 사용을 제거하고 기존 종류·수·기력·내력 값을 Label로 표시했다. basic_cards.json은20개 badge 참조만 비우고 모든 행동ID·삽화·효과·비용·거리 필드는 기준과 동일하다. HTML generator가 알려진 폐기 자료만 처리 이력으로 바꾸며, 미등록 누락과 변조 영상은 여전히 실패한다. 폐기 영상 poster만 생략하고37개 실제 영상은 유지한다. 최초10화풍/초기혼합 시안 전용 gallery는 제거하며 승인된 합 미리보기는 유지한다.

전체 검토1:102요청·Git원본·제품 consumer·파생본을 대조해 실제 카드 atlas2개와 GUT13이미지 의존, 별도 PR342원본 경계를 확인했다. 카드 소비처를 교체하고 GUT는 사용자 답변대로 제외만 처리했다. 전체 검토2:실제 diff·미변경 준비/전투/저장·builder·사용자 기록·복구정보·목록을 대조해 후보29 재번호, 삭제된 사건 촬영의 본문/검수 증거, 기본 이미지 목록에 남는 폐기 항목,316/317의 복구 해시 혼동을 교정했다. 이후는 해당 반례의 집중 검증만 수행했다.

검증: 폐기 회귀4개 RED→GREEN(누락파일/영상poster/후보번호), HTML37검사, 자산/기획 관련12검사 PASS; 카드·전투보드 계약 PASS. Godot4.7.1 STEP0_GODOT_VERIFY_OK, PREPARATION_REFERENCE PASS/0failures. HTML112설명·기존412번호,1280뷰/18737로컬연결 검사 PASS. 일반 이미지 목록은 폐기 항목 제외, 별도 폐기 필터/개별번호로 코멘트 이력 확인 가능. 로컬 산출/검증은 output/blueprint-disposal-*.json·output/disposal-*.log. 일괄 삭제 자동 검토가 blocked by policy로 거부한 최초 시도는 아무 파일도 변경하지 않았고, 추적 파일/정확한 해시의 삭제대기 파일/작업 폴더 안 파생본으로 나눠 정상 처리했다. 사용자 원본 작업 폴더, addon 원본13파일, shared review 파일은 변경하지 않았다.

기존 준비 화면 최종 이미지의 사용자 검수와 PR367 Draft 이유는 미해소다. 새 Windows 배포본·Android·Human·병합은 이번 폐기 작업의 검증으로 주장하지 않는다. 다음 화면 개편 및 프레임 판정/AI/저장 전환은 구체 계획 제시 후 사용자 구현 승인 대기다.

738ef4bc 원격 검사에서 발견한 후속 결함2건: freshness 설정이 폐기130번 SVG를 필수 파일로 요구했고, 저장 내용 해시에 포함된 배지20필드 변경으로 schema5 기존 저장이 거절됐다. 삭제 SVG의 현행 consumer를 폐기 원장/파일 부재 검사로 옮기고, 저장 해시 계산에만 알려진10기초 행동의 배지 필드를 정확한 과거 값으로 대응시켰다. 런타임 카드와 삭제 파일은 복원하지 않는다. 새 회귀 RED 뒤 기존 schema5 고정 해시와 pending/applied 저장 읽기, 비용 변경·필드 누락·미등록 배지 변경의 거절을 GREEN으로 확인했다. Godot EVENT_CHECKS 및 RUN_SAVE_STORE PASS/0failures, canonical freshness와 영향 계약9종 PASS. 게임 규칙과 저장 schema는 그대로이며 프레임 전환 구현은 포함하지 않는다.

### 예시 화면·10초 계획·출사표 도입 · 2026-09-25

기준9d2f543029a9b8f44ae4d8c5450725b374d88df9 / PLAN / imagegen + brainstorming / planning-visualization·bounded in-chat design. 최신 사용자 요청은 우선 예시 이미지 제작이며, 도중에10초 설계 구간·관찰 단계×약3초·출사표 튜토리얼 후 강호행로1회→비무 방향을 추가했다. 현행 시작 무공 consumer `src/run/vertical_slice_starter_manual_catalog.gd`와 시작 흐름 `src/run/vertical_slice_shell.gd`를 읽었다. 선택6종 중4종/3성은 재사용하고 새로운 시작 순서는 설계로만 기록했다. GitHub main 관측89cee855b1beb6a8a73a08a579aeb964ec398cbf, 관련PR367은Draft이며 이 시안은 제품 구현·병합 근거가 아니다.

CURRENT_SOURCE_RELEVANCE_CHECK: 사용자 지정 순서·직전 승인 화풍·동일 작업의 원화와 실제 시작 consumer를 재사용했다. 새로운 외부 게임/UX 효과를 사실로 주장하지 않는 대화용 시안이므로 추가 인터넷 비교는 NOT_APPLICABLE. FEASIBLE: 내장 이미지 도구로 정지 시안 생성/표시. 프레임 제품 구현 가능성과 사용자 학습 효과의 검증은 이번 정지 시안으로 판정하지 않는다.

제작: 메인 메뉴(인물 없음), 노드형 강호행로, 비무 결과,10초 시간축 복기, 비무 브리핑,10초 준비 화면,출사표 총7개 현행 검토 시안. 최초3초 준비 시안은10초 시안으로 검토 기준을 대체했다. 생성 파일은 대화용이므로 `C:/Users/user/.codex/generated_images/01a08da6-5204-7991-b5ac-41990ea2f7fa/`에 유지했다. 파일 식별: 메인 `exec-0016f1cf-967c-4d92-b0c7-4e3fa983a65b.png`, 행로 `exec-3c365675-cd8c-4bab-bc75-958b255d24da.png`, 결과 `exec-0882535d-1e93-4897-8cb2-ade02925a3a1.png`, 복기 `exec-fe6e0682-da90-43ae-98a6-c52d615042f1.png`, 브리핑 `exec-2c8fa2c8-4b5e-46d4-bafd-c0be65484653.png`,10초 준비 `exec-51956564-f252-4ca0-9cdf-5ef187e602b2.png`, 출사표 `exec-520ba541-9ecf-4ce7-af57-d9ef1c5ff853.png`. 참조는 앞선 시안·사용자 UI 참조이며, 모든 신규 bitmap은 내장 이미지 도구로 제작했다.

검토: 사용자 순서와 시안/현행 제품의 경계, 무공 선택 consumer, 첫 전투 전 행로1회,3/3/4의 재도입 여부를 대조했다. 이어 생성 이미지를 시각 확인하여 출사표의 단독 낭인·짧은 상황문·다음 무공 선택 버튼·하단 여정 순서, 준비의0~10초 시간축·6초 공개 경계·3/6/9초 관찰 표기를 확인했다. 복기 시안의 일부 판정 문구/시간축은 설명용 그림 예시이며 실제 전투 계산과 일치한다고 주장하지 않는다. 시안은 화면 구조 검토용이고, 최종 문구·수치·콘텐츠는 실제 제품 연결 때 별도 대조해야 한다.

미검증: 새 도입·10초 판정·관찰·저장/이어하기·실제 영상·게임/HTML 반영·사용자 학습 효과·기기 실행은 NOT_RUN. 이번 범위에서 제품 코드·게임 자산·HTML·기존 파일 삭제는 변경하지 않았고, 최신 사용자 방향만 ACTIVE_CONTEXT에 갱신했다. 다음은 사용자 시안 피드백과 앞서 요청된 구체 구현/폐기안 검토다.


### 10초 전투·출사표 실제 구현 · 2026-09-25

기준9d2f543029a9b8f44ae4d8c5450725b374d88df9 / BUILD·REVIEW / project workflow router, executing-plans, TDD, dispatching-parallel-agents, imagegen, HTML blueprint, Hera live-editor / 승인 구현·독립 도메인 작업·통합 검증. 최신 명시 승인은 “좋아 잘 이해했어 지금걸로 맞춰서 만들자. 실제 게임데이터 구현,html 연결까지 진행해줘”이며 Decision `TEN-DEC-20260925-FRAME-TIMELINE-PROLOGUE-01`로 현재 코어를 승격했다. 원본 사용자 checkout과 다른 PR의 작업은 변경하지 않는다.

CURRENT_SOURCE_RELEVANCE_CHECK=REUSED_EVIDENCE: 동일 승인 시안7개와 현행 runtime/저장/HTML consumers, Godot 공식 [Control](https://docs.godotengine.org/en/stable/classes/class_control.html) 및 [processing](https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html)의 입력·렌더링/논리 주기 구분을 재사용한다. 새로운 게임 비교나 효과 수치를 외부 근거로 발명하지 않는다. FEASIBLE: 실제4.7.1 실행 환경·기술 정의·기존 효과 프로그램·버전 저장·이미지 도구를 확인했다. 갱신 Godot AI가 공개한 세션은 다른 ink-screen-refresh 작업 폴더라 그 세션에 쓰지 않았고, 정확한 현 작업 폴더의 native Godot 실행으로 검증했다.

제품: 새 게임은 출사표→삽화6중4→규칙·시간축 실습→첫 비전투 사건1회→브리핑→비무. 기술은100틱/10초에 선딜·발동·후딜로 배치하고 실제 유효 구간·거리에서 합/방어/회피/중단을 판정한다. 잔여 동작과 일회 비용/효과를 다음 구간에 이월한다. 관찰은 완료 후30/60/90틱만 먼저 확정된 적 계획을 공개한다. 실제 이벤트/상태 변화로 먹 동작·2줄 시간축·하단 결과와 읽기 전용 복기를 연결했다. 기존 무공 정의를 재사용하며 무공별 새 모션은 만들지 않았다. 새 schema7은 확정 전후 경계와 시작 자원·상대/소유 무공·전체 해결을 재검증하고, 구형1/2/5/6 저장은 원래 실행 규칙으로 읽는다.

시각: 메인 인물을 제거하고 오른쪽 여백에 실제5버튼을 놓았다. 메인·출사표·준비용 text-free 배경3개는 실제 이미지 도구로 제작했고 해시/프롬프트/참조/consumer를 `assets/ui/ink_frame/provenance.json` 및 중앙 manifest에 등록했다. 준비의 대각선 대치·초상/상태·거리·오른쪽 관찰·5×2삽화/상세 구도를 사용한다. 실제 촬영에서 상태 문구가 배경에 묻힌 부분과 시간축 끝 표시를 교정했다. 승인 시안과 실제 촬영, 기존 구형 영상을 HTML에서 구별한다. 신규 파생 원화의 사용자 final lock 및 독립 출시 권리는 이 검증으로 주장하지 않는다.

전체 검토1: 정본과 각 실제 변경·미변경 효과/AI/저장/성장/HTML consumer를 대조했다. 초기 코어·도입·schema 회귀 RED 뒤 기본 GREEN을 확인했다. 다섯 번째 획득 무공이 고정4권 제한에 걸리던 연결, 시작 전 상태를 변조해도 replay가 일치하던 검증 구멍, 이동2칸 설정이 막기를 막던 문제, 빈 이월 계획의 확정·저장·재생 누락, 실제 패배 뒤 복기 진입을 교정했다. 획득 시점 이전의 보상/제약을 현재 소유 무공으로 소급 정당화하지 않도록 역사별 소유 목록으로 검증한다.

전체 검토2: 독립 검토가 전투·bridge·공개 뷰·save/runtime·보상·도입·기존 consumer를 다시 공격했다. 발동 첫 틱의 사거리 실패 뒤 유효 구간의 접촉을 놓치는 반례, 관찰 끝135틱 뒤142/155틱 실제 발동/완료 시각이 노출되던 반례를 RED7개로 재현하고 고쳤다. 공개 구간은 view-only로 잘리며 실제 연출이 도달하면 같은 uid의 진짜 기록으로 바뀐다. 비용·선행 방어 효과·타격은 반복되지 않는다. 실제 pointer rename 실패로 확정/정산/재시도 중 효과가 중복되지 않는32검사, 획득 후 다음 비무·수련·저장64검사, 실제 패배/복기/재도전14검사를 확인했다. 리뷰 담당자가 작성한 비전투/소유 목록 코드는 주 작업이 별도로 비교했으며 독립 검토라고 부풀리지 않는다. 후속 재생2반례(초기 공개 정보 소실, 완료 이벤트가 공격 연출을 다시 시작)는3개 표시 회귀 RED→GREEN으로 교정했다.

검증: 코어152, 도입158, 무공 획득64, 확정 저장·재시도32, bridge26, frame save8, 도입UI26, playback UI3개 검사와 기존 효과/무공/기연/가변상대·저장 호환 회귀가 PASS다. Windows native 촬영에서 실제 두 구간14.1초 후 승리(플레이어25/30·상대0)→보상→행로→사건과 별도 실제 패배→복기를 확인했다. 승리를 주입하지 않고 현재 공개 거리와 자기 자원만 사용한 장풍/명상 입력이다. 다른 시드의 전체 흐름은473프레임/24fps/19.708초로 기록했고, 첫10초는일반속도·이후구간만8배속이다. strict PASS receipt·PNG/MP4 SHA256을 통한 HTML 연결만 허용한다.

Python 전체588검사 최초 실행은586PASS/2FAIL이었다. 첫 실패는 신규 배경3개가 기존 자산 기록의 불변 해시 검사에 포함된 것으로, 새3ID/실제 PNG·참조 해시를 별도 검증하고 옛 해시는 유지했다. 둘째는 legacy lifecycle 검사가 새 여정에서 SETUP으로 바로 가는 옛 전제를 쓴 것으로, 실제 새 출사표 저장 실패·재시도를 먼저 검증한 뒤 legacy bundle lifecycle은 명시적인 구형 fixture로 분리했다. 나머지 독립 프로세스 저장/변조/회복 검사는 첫 전체 실행에서도 통과했다. 발견 실패의 집중 재검증·최종 HTML/browser/export 결과는 아래에 누적한다.

남은 기존 정본 불일치: 대력금강장7성의 기록 방어 추가 피해, 금강호체3성의 다음 자기 행동 전까지 완전 흡수 보상과 미정 수치, 일부 SPECIAL_CLASH 전용 무공의 공격 설명과 HP 피해 연결, 합 위력 증가의 미지정 만료 시점은 이전 데이터/효과 프로그램과 승인 설명의 차이다. 여래신장의 선딜 전 방어·강건 및 실제 방어 손실 보너스(최대6)는 명시된 수치로 새 frame 프로그램에서 교정했다. 나머지 미정 효과를 임의 발명하거나 모든 무공 의미가 완결됐다고 주장하지 않는다. 기능 검토본·PR367 Draft로 제공하고 사람 재미/세부 밸런스·Android·접근성 사용자·신규 원화 최종 확정·출시는 NOT_RUN이다.


최종 로컬 readback: 위 Python2실패를 교정한 집중4검사 모두 PASS(36.846초). 최종 native 원본11장+실제 승리/보상 뒤4장, H.264/yuv420p/faststart 영상473프레임·24fps·19.708333초를 strict receipt로 발행했다. Blueprint107검사,1357뷰/20667로컬연결 PASS. Chrome에서 currentTime7.46181→duration19.708333/ended=true/readyState4/error=null,콘솔오류·경고없음 확인. 브라우저 screenshot API의 CDP timeout2회는 native 원본 이미지 직접 검수와 실제 재생/readback 결과로 구분하며 캡처 성공으로 세지 않는다.

Windows4.7.1 release EXE/PCK를 생성하고 격리 저장 경로로 실행하여 NVIDIA OpenGL main 초기화/exit0/실행오류없음을 확인했다. ZIP194891820bytes, SHA256 b0ce5b6ac568d48e6daa6fd9f58b052fe63c29a7c110a27476d27113a0053029. ZIP CRC와 EXE/PCK/실행하기.cmd/설명서의 압축 전후 해시 일치 PASS. `output/frame-final/delivery.json`이 실행본을 식별한다. exporter 종료의 기존 ObjectDB45/resource22 정리 경고는 남아 있고 제품 실행 stderr는 비어 있다. 운영 계약·canonical reference freshness·combat docs 검사 PASS. 원격 exact HEAD와 PR 상태는 전달 전 별도 확인하며 자동 검증을 Human/Android/최종 원화/출시 승인으로 올리지 않는다.

698ab0bf 원격 검사에서 신규 frame 전용 검사는 PASS했으나 공통 combat-board 검사와 OS/Python4조합은 같은 원인으로 실패했다. 별도 standalone 검사에도 새 배경3개가 옛21불변 기록에 포함돼 있었다. 로컬에서 동일 RED를 재현하고 정확한3ID만 분리했으며, 원본21의 count/digest를 유지하고 새 자산의 PNG·참조·제작 기록을 검사한다. 알 수 없는 신규 ID, 기존 기록 변경, 새 원화의 잘못된 해시를 주입한3반례는 모두 거부했다. standalone combat-board·승인 원화3검사·후속 영향7검사 PASS. 제품 코드와 실행본은 이 교정에서 바뀌지 않는다. 최종 재발행은1357뷰/20694링크와 영상19.708333초 끝까지재생/미디어·콘솔오류0을 확인했다. 이후 원격 검사 결과는 PR367의 실제 최신 HEAD 상태로 구분한다.
