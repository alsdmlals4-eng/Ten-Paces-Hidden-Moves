# 2026-08-31 무공·절초 카드 Atlas Final Lock 및 학습 흡수 실행 보고서

## 실행 기준과 증거 한계

- **Work Mode:** `BUILD → REVIEW`.
- **초기 기준 프로젝트 main:** `0b2ab3fe64a8325b52b743c8d9da03cb23646b3f`; 이 branch의 implementation parent는 이 기준에서 분기했다.
- **최종 fresh-fetch 프로젝트 main:** `1509317d59d270087c5ff08b696e8ae9d8e7dfce` (2026-08-31 15:00 KST, message `d`). 이 commit은 approved frontal background·`ActionChoiceCard`·card-illustration decision을 제거하고 diagonal/hypothesis/text-first surfaces를 다시 추가한다. 최신 사용자 final lock과 충돌하므로 `CANON_CONFLICT`로 기록하고 자동 rebase, direct-main mutation, remote-history 변경은 수행하지 않았다.
- **Base 관찰:** current remote `origin/main`의 `1f0ef9d8bdb1869c9ba25b33efdcb34cf2ccba83`; Base는 read-only로만 비교했고 변경·제안·Registry 갱신을 하지 않았다.
- **권위:** 최신 사용자 final lock `삽화 확정`; `AGENTS.md`; current visual/planning owners; `TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01`.
- **CURRENT_SOURCE_RELEVANCE_CHECK:** `REUSED_EVIDENCE`. 2026-08-30의 12개 게임 역공학 packet은 같은 카드 위계/읽기 가능한 행동 분류 dimension과 같은 project state를 다뤘다. 이번 작업은 새 규칙·경제·UX 방향을 채택하지 않고 final-locked art를 기존 renderer에 연결하는 bounded implementation이므로 새 외부 제품 사실을 주장하지 않았다.
- **증거 한계:** local automated checks와 exact Windows Godot/Hera visible runtime observation까지만 수행했다. Human 플레이 이해도·재미, 접근성 사용자, Android 실기기, release 성능, store, unconditional rights PASS는 아니다.

## 작업 전 문제

`MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1`은 사용자가 검토한 후보였지만 candidate 폴더에만 있었다. 따라서 무공·절초는 basic action과 다른 text-first 표면으로 보였고, 후보 상태가 current handoff/queue에도 남아 있었다. `ActionChoiceCard`는 공통 renderer였으나 martial/ultimate의 meaning별 atlas region을 줄 runtime data route가 없었다.

## 조사·비교와 채택 판단

| 대안 | 판단 | 이유 |
| --- | --- | --- |
| 하나의 `ActionChoiceCard` + `ActionViewModelAdapter` semantic region mapping | `ADOPT` | 기존 cards의 텍스트·비용·잠금·포커스·접근성 계약을 그대로 보존하면서 이미지 차이만 모델 경계에서 처리한다. |
| 무공/절초 별도의 삽화 panel 및 renderer | `REJECT` | card hierarchy, sizing, input, accessibility가 세 갈래로 drift할 위험이 있다. |
| final lock 뒤에도 text-only 상태를 유지 | `REJECT` | 사용자의 명시 final lock 및 “카드 삽화도 다 넣기” 방향과 충돌한다. |
| 새 Base 공용 Skill/규칙 생성 | `REJECT` | 이번 사실은 하나의 프로젝트·하나의 atlas consumer에 한정되며, Base에는 이미 asset lifecycle/reference-freshness/change-proposal owners가 있다. |

## 실제 구현·정본 반영

1. 사용자 final lock의 exact candidate (`SHA-256` `227a0492399d287fec073d7bccb36dc84eae1dd0c6d11247302e24ca87c3750e`)를 다음 두 위치로 byte-for-byte 승격했다.
   - `docs/visual-assets/approved/MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png`
   - `res://assets/ui/cards/martial_ultimate_card_illustration_atlas_01_v1.png`
2. `assets/ASSET_MANIFEST.json`에 generation output, hash, provenance, rights boundary, approved/runtime path와 actual consumer를 등록했다.
3. `ActionViewModelAdapter`가 martial manual별 sword/saber/palm/spear/meditation/guard/footwork region과 ultimate region을 제공한다. 전투 규칙, AI public-information boundary, save schema는 수정하지 않았다.
4. `ActionChoiceCard`의 shared illustration region은 `basic_atlas_only`와 `semantic_atlas` policy를 모두 rendering하며, `MartialActionPanel` 및 `UltimateActionPanel` snapshot/meta도 `semantic_atlas`로 일치시켰다.
5. historical no-illustration Decision은 삭제하지 않고 `SUPERSEDED_HISTORICAL_EVIDENCE`로 보존했다. candidate PNG/record도 provenance로 보존했고 current pending queue에서는 제거했다.

## 현재 상태 → 요청 이유 → 기대 효과 → 실제 조치

| 요소 | 현재 상태 | 요청 이유 | 기대 효과 | 실제 조치 / 상태 |
| --- | --- | --- | --- | --- |
| 공통 카드 renderer | basic만 atlas, martial/ultimate는 text-first | 행동 source마다 카드 경험이 달라 보임 | source와 무관하게 한 카드 문법 유지 | **수정 완료** — `ActionChoiceCard`에 `semantic_atlas` policy 추가 |
| semantic mapping 작업 구조 | atlas가 candidate라 consumer mapping 없음 | 패널별 별도 UI 구현을 피해야 함 | 한 renderer에서 내용 의미에 맞는 삽화 표시 | **추가 완료** — `ActionViewModelAdapter`가 source-kind/region을 소유 |
| final-lock asset lifecycle | 후보 해시만 존재, approved/runtime/manifest 없음 | 승인 asset의 출처와 runtime bytes를 연결해야 함 | 후보가 무단 승격되지 않고 rollback/audit 가능 | **추가 완료** — exact bytes, manifest, approved record, regression 검사 |
| 무공/절초 snapshot·회귀 | policy가 일부 meta에만 남을 수 있었음 | documentation/data/runtime drift를 막아야 함 | 변경 뒤에도 visible consumer와 snapshot이 함께 갱신 | **수정 완료** — focused Godot/Python coverage 확대 |
| no-art current policy | 현재 방향과 충돌 | final lock 이후 오래된 policy가 재적용되면 안 됨 | current truth가 user lock과 일치 | **폐기 완료** — current policy에서는 제거, Decision은 역사 evidence로 보존 |
| 새 전용 ‘card art’ Skill | 기존 asset/consumer/QA skills가 이미 있음 | 작은 구현 하나가 Skill 난립을 만들면 유지비 증가 | learnings는 남기되 skill surface를 최소화 | **추가하지 않음** — existing `SKILL_LEARNING_LOG`에 project pattern으로 흡수 |
| Base 공용 변경 제안 | generic evidence가 한 project pattern뿐 | project-local 사실을 Base 필수 규칙으로 과승격하면 안 됨 | Base 안정성·재사용성 보호 | **제안하지 않음** — 공용 learning PDF에 신규 후보 0건으로 기록 |

## 사용 예과 기대 효과

비무 화면에서 `무공` 탭을 열면 선택한 무공의 기술 카드가 sword/palm/spear 등 의미에 맞는 atlas crop을 상단에 보이면서, 아래의 무공명·행동 수·비용·range·잠금 텍스트를 유지한다. `절초` 탭은 같은 카드 frame과 gold ultimate crop을 사용한다. 플레이어는 source가 바뀌어도 카드의 읽는 위치와 입력 방식이 달라지지 않는다.

## 검증 증거

- **TDD:** final-lock test는 approved/runtime destination 부재 상태에서 먼저 RED였고, exact-byte promotion 이후 manifest/current-owner assertions까지 GREEN으로 확장했다.
- **Godot import/parse:** Godot `4.7.1` headless editor parse/import exit `0`.
- **Focused Godot:** `verify_action_card_source_unification`, `verify_martial_action_panel`, `verify_ultimate_action_panel` 모두 `PASS`.
- **Focused Python:** `tests/test_visual_consumer_asset_production_policy.py`는 candidate/approved/runtime bytes, manifest entry, current policy/paths를 함께 검사한다.
- **Full Python regression:** `python -m unittest discover -s tests -p 'test_*.py' -q`는 `431` tests `OK`였다. final-lock 상태를 과거의 "candidate awaiting lock"으로 기대하던 handoff regression 하나를 발견해 current structured owner와 같은 final-lock string을 기대하도록 갱신한 뒤 재실행했다.
- **Visible runtime:** unrelated GRIMOIRE editor는 건드리지 않았다. exact Ten Paces editor instance `23696`에서 default vertical-slice flow를 첫 전투까지 진행한 뒤 `무공`과 `절초` tab을 각각 열었다. 두 panel은 `metadata/illustration_policy = semantic_atlas`, `visible = true`였고 card child `TextureRect`가 runtime tree에 존재했다. screenshot analysis는 nonblank 및 clipping warning 없음, runtime diagnostics는 `error_count=0`, `warning_count=0`이었다.

## 자동화·학습 반영

기존 `skills/SKILL_LEARNING_LOG.md`에 `Final-locked shared card atlas propagation` 패턴을 추가했다. 핵심 교훈은 final-lock asset 작업에서 **candidate hash → exact destinations → manifest → view-model mapping → shared renderer snapshot → focused regression → exact runtime panel**을 한 묶음으로 확인해야 한다는 것이다. 이는 project-specific pattern이며 새 Base skill을 만들 근거는 아니다.

사용자 제공 Base instruction의 공용 학습 산출물은 `output/pdf/TEN_PACES_BASE_COMMON_LEARNING_REPORT_2026-08-31.pdf` 하나로 만들었다. 이 PDF는 4페이지 render/layout을 확인했고, text extract의 ASCII structural marker도 검증했다. 이 환경의 Poppler text extraction은 Korean CID glyph을 정상적인 selectable Korean text로 복원하지 못하므로, Korean readability evidence는 render observation까지만 주장한다.

## 다섯 차례 적대 검토

1. **승인/bytes 공격:** candidate, approved, runtime 파일의 SHA-256과 manifest destination을 대조했다.
2. **consumer 공격:** atlas가 raw data에 중복 저장되지 않고 `ActionViewModelAdapter → ActionChoiceCard` 경계에서만 주입되는지 확인했다.
3. **surface drift 공격:** martial/ultimate panel metadata, snapshots, actual instantiated card child를 함께 확인했다. 최초 snapshot hardcode와 test context 누락을 찾아 수정했다.
4. **information/compatibility 공격:** AI hidden planning, combat resolution, save schema, basic atlas route가 수정되지 않았음을 diff와 focused tests로 확인했다.
5. **retention/cleanup 공격:** current no-art policy는 superseded historical evidence로 남기고, duplicate panel/art system과 Godot-generated untracked import/cache byproducts는 current tree에서 보관하지 않는다.

## 미검증·남은 위험

- Human 카드 가독성·미감, 접근성 사용자, Android device, release performance, store/release readiness는 `NOT_RUN`이다.
- asset rights는 prompt/provenance와 conditional release boundary까지 기록됐으며, 법적 독점성 또는 출시에 대한 무조건 보증이 아니다.
- current branch는 아직 local worktree이며 PR 생성·remote CI·merge/post-merge readback을 이 보고서가 주장하지 않는다. 특히 remote `main`의 `1509317d` conflict는 별도의 explicit reconciliation decision이 필요하다.

## 2026-08-31 Fresh-read 복구 정합화 부록

### 재개 기준

- **사용자 continuation:** 이후의 `최종확정` 및 `base와 프로젝트를 프레쉬리드하고 작업을 재개하자`는 앞서 확정된 frontal composition, 숨은 논리 전장, 상대 의도 가설/즉시 완료 제거, 그리고 basic·martial·ultimate 공통 카드 및 삽화 방향을 바꾸지 않는 `REUSED_APPROVAL`이다. 새 코어 규칙이나 Base 변경 권한으로 해석하지 않았다.
- **프로젝트 fresh-read 기준:** `origin/main` / `main` `1509317d59d270087c5ff08b696e8ae9d8e7dfce`.
- **Base fresh-read 기준:** `origin/main` `48dd501a10913251c4107d723bb677dae3ab9898`. 프로젝트의 채택 pin을 새 Base로 조용히 교체하지 않았고, Base 파일·Registry·proposal은 변경하지 않았다.
- **복구 branch:** `codex/user-approved-reconciliation-20260831`, 짧은 Windows worktree `C:\Users\user\Documents\GitHub\Ninza\tph-r-831`.

### 발견한 문제와 채택한 복구 구조

| 요소 | 현재 상태 | 요청 이유 | 기대 효과 | 실제 조치 |
| --- | --- | --- | --- | --- |
| 중첩 복제 트리 | `1509317d`가 `Ten-Paces-Hidden-Moves-operating-eol/` 아래에 1,505개 tracked blob(약 48,008,076 bytes)을 다시 넣어 Windows 기본 worktree 생성도 긴 경로로 실패 | 현재 실행·소비처가 없는 구형/중복 파일을 남기지 않음 | 저장소 용량·경로 한계·향후 fresh worktree 위험 감소 | 해당 commit만 branch에서 revert(`0bc43709`)했다. 외부 consumer 참조와 submodule이 없음을 먼저 확인했다. |
| 사용자 final lock과 최신 main의 충돌 | 최신 main은 diagonal/hypothesis/text-only 방향을 재도입하고 `ActionChoiceCard` 소비처를 제거 | 이미 확정한 화면·카드 경험을 유지 | 실제 실행 화면과 승인 정본의 일치 | unrelated open PR은 건드리지 않고, final-lock commit chain만 `REUSE_EXISTING_PROJECT_IMPLEMENTATION`으로 재적용했다. |
| 회귀 계약 | shared renderer가 `semantic_atlas`를 지원하는데 오래된 static contract는 `basic_atlas_only`만 허용 | 정본과 테스트가 서로 다른 현상을 PASS시키면 안 됨 | 다음 변경에서 card illustration regression을 즉시 검출 | 먼저 final-lock regression을 RED로 확인하고, shared renderer의 두 정책 및 martial/ultimate의 `semantic_atlas` publish를 검증하도록 contract를 최소 갱신했다(`63531e46`). |
| Godot 생성물 | 실런타임 확인 뒤 `.import`·`.uid` 13개가 untracked로 생성됨 | 필요한 파일만 남기는 사용자 정책 | branch/PR에 engine cache가 섞이지 않음 | 대상 목록을 dry-run/readback한 뒤 정확히 삭제했다. tracked `.import`/`project.godot`은 index bytes로 되돌려 source diff가 없음을 확인했다. |

### 복구 변경 범위와 rollback

복구 chain은 `0bc43709`, `03e68a3b`, `845cc188`, `0699ad88`, `9bff68a7`, `a8eb38f9`, `ad93d0fe`, `63531e46`이다. 전투 규칙, 공개 정보 경계, AI, save schema, core 10-step logical model은 변경하지 않았다. remote `main` push, force-push, merge, Base mutation은 수행하지 않았다. 이 package의 rollback은 이 branch의 복구 commits를 revert하거나 branch를 폐기하는 방식이며, 기존 source branch와 기존 open PR은 보존된다.

### 복구 후 적대 검토 5회와 clean exit

1. **권위/범위 공격:** 프로젝트·Base AGENTS, active owners, project adapter와 최신 main을 교차 read했다. 새 Base adoption이나 신규 game rule로 범위가 넓어지는 시도를 배제했다.
2. **삭제 안전성 공격:** 중첩 tree가 `1509317d`에서만 추가되었는지, tree 밖의 파일이 참조하지 않는지, `.gitmodules`가 없는지를 검사한 뒤에만 revert했다.
3. **정본/회귀 공격:** final-lock policy test를 RED로 확인한 뒤 GREEN으로 만들었다. 이어 stale static action-selection contract가 발견되어 semantic atlas policy를 정확히 수용하도록 고쳤다.
4. **자동/구조 공격:** project operating-system, Base v9.1 operating contract, canonical reference freshness, action-selection contract, full Python test suite, Godot headless parse와 focused Godot scripts를 다시 실행했다.
5. **실화면/잔존물 공격:** exact recovery worktree의 Godot scene에서 frontal courtyard, equal grounded battlers, hidden `TileLayer`, `거리 2`, martial 2개·ultimate 8개의 visible `CardIllustration` 노드를 확인했다. 진단은 error/warning 0이었고, import/UID 생성물도 정리 후 Git readback 했다.

### 복구 검증 결과와 증거 한계

- **Python full regression:** `python -m unittest discover -s tests -p 'test_*.py' -q` → `432` tests `OK`.
- **운영 계약:** `python -m unittest tests.test_base_v91_operating_contract -v` → `2` tests `OK`; `python tools/check_project_operating_system.py --root . --config .github/documentation-governance.json` → `PASS`.
- **현재 reference/카드 contract:** `python tools/check_canonical_reference_freshness.py --root . --config .github/reference-freshness.json` 및 `python tests/check_action_selection_contract.py` → `PASS`.
- **Godot:** exact Godot `4.7.1` headless editor parse exit `0`; `verify_action_card_source_unification.gd`, `verify_martial_action_panel.gd`, `verify_ultimate_action_panel.gd`, `verify_frontal_duel_assets.gd` → 각각 `PASS`.
- **증거 한계:** 위 결과는 automated + exact local runtime verification이다. 인간 플레이 비교, UX/human acceptance, 접근성 사용자, Android 실기기, release performance, remote CI/PR/merge/post-merge main readback은 여전히 `NOT_RUN`이다.

### 재사용·학습 결론

`ActionChoiceCard`, `ActionViewModelAdapter`, approved frontal background와 semantic atlas는 기존 프로젝트 구현을 재사용했다. 새 Base proposal은 `NO_NEW_BASE_PROPOSAL`: 이번 문제의 핵심은 project-specific historical-main recovery와 Godot generated-file hygiene이며, 현재 Base에 중복되는 공용 정책을 새로 만들 근거가 없다. 다만 후속 작업에서도 **runtime import 뒤 exact generated-file readback → target-limited cleanup** 순서를 유지한다.
