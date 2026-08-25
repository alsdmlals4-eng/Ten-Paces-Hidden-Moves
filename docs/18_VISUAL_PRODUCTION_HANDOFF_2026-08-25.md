# 십보강호 · Visual Production Handoff · 2026-08-25

> 목적: 새 ChatGPT/Codex 세션이 과거 채팅 기억에 의존하지 않고 현재 승인 Visual 품질과 작업 순서를 그대로 재개하기 위한 인수인계 원본.  
> 상태: `USER_APPROVED_REFERENCE_SET / NEXT_BATCH_READY / RUNTIME_ART_INTEGRATION_NOT_RUN`  
> 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`  
> 작성 기준 관측 main: `11b72d236809515b4c68a4650fb99c106139e9f9` — 다음 세션은 반드시 live main을 다시 읽을 것.  
> 작성 기준 Base main: `af013a311dd2dadd991080e92bacb0572f0c2f69` — 프로젝트 Base pin과 current remote truth를 혼동하지 말 것.

이 문서는 기존 `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`를 대체하지 않는다. 17은 요구사항/Visual North Star, 본 문서는 **2026-08-25 실제 사용자 승인 Reference와 다음 제작 순서**를 소유한다.

시각 Reference의 human-facing 원본은 현재 DOMAIN_SPLIT에 따라 **Notion Asset Library / Home**가 소유한다. GitHub는 승인 상태·구조·brief·다음 작업·문제/교훈·runtime 경계를 소유하며, 채팅에서 생성된 원본 PNG를 runtime `assets/`에 자동 승격하지 않는다.

---

## 1. 새 세션 시작 순서

새 채팅에서는 다음 순서로 fresh-read한다.

1. `AGENTS.md`.
2. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
3. `docs/planning-data/current_user_planning_status.json`.
4. 이 문서와 `docs/planning-data/current_visual_production_handoff_20260825.json`.
5. GitHub live `main`, 열린 PR, 최근 commit.
6. exact Project Notion:
   - `십보강호 · Home`
   - `02 · 비주얼 바이블`
   - `04 · 에셋 라이브러리`
7. 이번 이미지가 실제 전투/행동 UI와 맞아야 할 경우 현재 `src/ui/action_selection/**`, `data/cards/**`, `docs/02_COMBAT_RULES.md`를 확인한다.
8. Google Sheet는 migration-only다. 현재 시각 작업의 정본으로 승격하지 않는다.

현재 관측된 pre-existing draft PR `#199`는 read-only다. 이 handoff 작업과 직접 소유 관계가 없으므로 takeover/수정하지 않는다.

---

## 2. 2026-08-25 사용자 승인 Reference Set

사용자가 다음 4개 이미지를 명시적으로 승인했다. 이들은 **후속 이미지 제작의 시각 기준**이며 아직 Godot runtime shipping asset PASS는 아니다.

Human-facing image source:

- Home: `https://app.notion.com/p/3c41b237eb1c8105a254d860f3c21638`
- Visual Bible: `https://app.notion.com/p/3c01b237eb1c814f80d4c6140fddebd4`
- Asset Library: `https://app.notion.com/p/3c01b237eb1c8172a16dc7713b75fcc5`

### 2.1 대표 전투 화면 · `TEN-IMG-001`

Notion owner: `십보강호 · Home` + `04 · 에셋 라이브러리`.

보호할 내용:

- 전장이 가장 큰 시각 질량.
- 캐릭터는 기존보다 세로로 길고 반실사 비율.
- 배경은 저대비 수묵 산수.
- 캐릭터는 수묵 선화에 **제한적인 도트/디더링 마감**을 사용한다. 전체 화면을 픽셀아트로 전환하지 않는다.
- UI는 캐릭터/배경과 별도 그림체로 정제해도 된다. 정보 가독성이 최우선이다.
- 중앙 `거리 N` 중심. 절대 칸 번호를 주인공으로 만들지 않는다.
- 현재 계획은 `3수` 묶음을 가늘게 표시하고 전체 `3 / 3 / 4` 진행을 보조적으로 보여 준다.
- 하단 Action Selection은 `기초 / 무공 / 절초` 세 목록을 전환한다.
- 행동/기술 카드는 **최대 5열 × 2행 = 10개**를 한 화면에 배치할 수 있어야 한다.
- 카드에는 작은 행동/무공 삽화가 있다. 효과 전문은 별도 Detail Panel로 내린다.
- 시안의 Primary CTA는 사용자 요청에 따라 `진행`으로 보인다.

주의:

- Repository 전투 규칙은 현재 `행동계획 잠금`이라는 의미 계약을 갖고 있다. `진행`이 단순 표시명 변경인지, 커밋/실행 의미 자체를 바꾸는지는 **별도 Decision 미확정**이다. 이미지 시안만 보고 전투 규칙을 바꾸지 않는다.

### 2.2 Character Master Reference

Notion owner: `04 · 에셋 라이브러리`의 `TEN-VIS-CHAR-MASTER-001`.

Style lock:

- 성인 무협 인물, 세로로 긴 7~7.5등신 계열.
- 반실사 얼굴/체형.
- 수묵 선화 + 저채도 담채 + 먹의 큰 덩어리.
- 작은 크기에서 실루엣이 먼저 읽히도록 무기·머리·자세·의상 큰 덩어리를 강조.
- 도트/디더링은 가장자리와 먹 번짐을 정리하는 **부분 마감 언어**다.
- 캐릭터마다 별도 UI를 만들지 않는다.

재사용 파이프라인:

`Character Master → Portrait Crop → Combat Full Body → Result Crop → Silhouette → Thumbnail`

### 2.3 기초 행동 10종 삽화 Reference

Notion owner: `04 · 에셋 라이브러리`의 `TEN-VIS-A07-CANDIDATE`.

보호할 내용:

- 5×2 10칸에서 작은 크기로 읽히는 수묵 동세 삽화.
- 기초 행동은 동작을 직관적으로 보여 주고, 무공/절초는 같은 프레임을 재사용하면서 문파·무기·운용 태도·먹+금 VFX로 차이를 만든다.
- 이름/비용/사거리/효과 숫자를 원화에 굽지 않는다.
- 실제 카드 정보는 Godot UI/data binding이 소유한다.

현재 `TEN-VIS-A07`은 아직 repository 정식 asset inventory Decision ID가 아니다. 다음 세션에서 필요하면 기존 A01~A06 체계와 충돌하지 않는 별도 Decision/Inventory sync로 승격한다.

### 2.4 공통 수묵 Clean Plate · `TEN-VIS-A01`

Notion owner: `04 · 에셋 라이브러리`의 `TEN-VIS-A01`.

보호할 내용:

- 저대비 수묵 산수.
- 중앙과 인물/패널 배치 영역에 충분한 negative space.
- Main/Intro/Briefing/Result/Route에서 crop·overlay 재사용 가능.
- 배경이 캐릭터·전장·UI보다 먼저 튀면 실패.

A01은 1차 plate 승인 완료다. 필요할 경우 같은 언어의 2번째 공통 plate를 추가할 수 있으나 신규 스타일을 발명하지 않는다.

---

## 3. 승인 Visual Language 요약

한 문장:

> **세계는 저대비 수묵화, 인물은 수묵 선화×제한 디더링, 정보는 독립적이고 정제된 전술 UI.**

레이어 책임:

1. `background clean plate` — 분위기와 여백.
2. `character portrait/full body` — 인물성·실루엣·무기·자세.
3. `weapon / silhouette accent` — 작은 크기 식별성.
4. `UI frame / panel` — 정보 위계와 상호작용.
5. `badge / icon` — 출처·종류·상태 판별.
6. `text / numeric data` — Godot/data binding.
7. `VFX overlay` — 짧은 먹의 운동감 + 제한 금색 결정선.

색 의미:

- 먹/세피아: 세계·기본 구조.
- 밝은 종이색: 읽어야 하는 정보.
- 제한 금색: 선택·확정·절초·결정적 결과.
- 탁한 적색: 피해·중단·위험.
- 청회색: 거리·중립·비활성/보조.

---

## 4. Action Selection UI 품질 기준

현재 runtime `ActionSelectionDock`는 이미 `basic / martial / ultimate` 소스를 `기초 / 무공 / 절초`로 전환한다. 새 이미지가 이를 다른 시스템으로 재발명하면 안 된다.

권장 카드 구성:

- 이름.
- 작은 삽화.
- 몇 수.
- 실제 비용.
- 공격 행동일 때만 필요한 사거리.
- 대표 태그/아이콘.
- 긴 효과/조건/공식은 Detail Panel.

5×2는 **최대 수용량**이다. 항상 빈 칸을 억지로 채우거나 10개를 동시에 노출해야 한다는 뜻이 아니다.

카드가 수집형 손패/덱처럼 보이면 실패다. 플레이어는 “현재 해금된 행동/무공을 수에 배치한다”고 느껴야 한다.

---

## 5. 현재 이미지 제작 cadence

사용자의 최신 명시 지시:

`한 번에 최대 3장씩 만들고 묶음 단위로 검토한다.`

현재 프로젝트 운영 해석:

- 작업 전 프로젝트/Notion/repository canon을 읽는다.
- 묶음의 1~3개 항목 각각에 목적·보호 요소·금지 drift가 있어야 한다.
- 사용자가 해당 묶음 제작을 명시 승인한 뒤 생성한다.
- 한 묶음 결과를 사용자에게 제시한 뒤 자동으로 다음 묶음을 생성하지 않는다.
- 승인/수정/기각 후 다음 묶음으로 이동한다.

이 cadence는 2026-08-25 사용자 지시의 current visual-production override다. Base의 기존 `GENERATE_EXACTLY_ONE` 공용 Gate와 차이가 있으므로 Base 변경 후보로 별도 제출한다. 프로젝트 고유 기준이므로 Base 변경이 승인되기 전에도 **이 프로젝트에서는 최신 사용자 지시가 우선**한다.

---

## 6. 다음 3장 제작 패키지 · READY

다음 세션의 첫 이미지 작업 후보는 아래 세 장이다. 사용자가 새 채팅에서 `진행해` 등으로 제작을 다시 명시하면 이 묶음의 brief를 보여 주고 진행한다.

### #1 Opponent Character Master #01

목적:

- 승인 Character Master 문법을 실제 상대 인물에 적용.
- 플레이어 낭인과 다른 얼굴/머리 실루엣·무기·자세·의상 큰 덩어리를 검증.
- 이후 상대 15명 Portrait/Combat Set의 생산 기준 확정.

금지:

- 플레이어 Master의 얼굴/의상 복제.
- 단순 색상 변경만으로 상대성을 표현.
- 상대의 숨은 계획/정답을 포즈나 색으로 누설.

### #2 Martial Technique Illustration Sheet #01

목적:

- 실제 무공 기술용 5×2 최대 10개 삽화 언어 검증.
- 기초 행동과 달리 문파/무기/운용 태도가 읽히게 한다.
- 카드 UI와 삽화를 분리 가능한 구조로 유지.

금지:

- 카드 텍스트/수치를 원화에 굽기.
- 10장이 각각 다른 렌더러/화풍처럼 보이기.
- 절초와 일반 무공의 강도 위계를 뒤집기.

### #3 Route Icon Sheet #01 · `TEN-VIS-A04`

목적:

- 8개 Route 노드 아이콘을 한 장에서 검증.
- 회복/성장/정보/대비 계열이 색을 빼도 형태로 구분되게 한다.
- SVG/shape로 재구축하기 쉬운 단색 수묵 silhouette를 우선한다.

금지:

- 거대 월드맵이나 별도 메타게임 분위기.
- 의미를 텍스트에만 의존.
- 장식이 선택 의미보다 강해짐.

---

## 7. Notion 승인 전달 · 검증 완료

Human-facing canon:

- Home: `https://app.notion.com/p/3c41b237eb1c8105a254d860f3c21638`
- Visual Bible: `https://app.notion.com/p/3c01b237eb1c814f80d4c6140fddebd4`
- Asset Library: `https://app.notion.com/p/3c01b237eb1c8172a16dc7713b75fcc5`

2026-08-25 destination readback 결과:

- Home에 `APPROVED COMBAT REFERENCE · 2026-08-25`가 표시됨.
- Home 대표 Visual 이미지 block이 존재함.
- Visual Bible의 생성 상태가 `USER_APPROVED_REFERENCE_SET_20260825 / NOT_RUNTIME_INTEGRATED`로 갱신됨.
- Asset Library에 전투 화면, Character Master, 행동 삽화 시트, Clean Plate 4종이 승인 Reference Set으로 표시됨.
- 네 첨부 파일을 다시 다운로드해 확인한 결과 모두 빈 파일이 아니라 **SVG 내부에 실제 JPEG image data가 내장된 non-empty preview**임.

주의:

- Notion 첨부는 human review/비교용 압축 preview다. 현재 전달 검증은 “승인 시각 방향을 다음 세션에서 판독 가능한가”를 증명한다.
- 원본 생성 PNG를 자동으로 repository runtime `assets/`에 넣지 않았다. shipping source master/promotion은 별도 asset-provenance/runtime 작업이다.
- Notion preview 존재를 Godot runtime integration 또는 release asset PASS로 해석하지 않는다.

---

## 8. 현재 충돌·미해결 사항

### `진행` vs `행동계획 잠금`

- Visual Reference: `진행` CTA 승인.
- 전투 규칙 정본: `행동계획 잠금` 의미 계약 유지.
- 상태: `SEMANTIC_RENAME_DECISION_PENDING`.
- 새 채팅에서 시각 작업을 계속하는 데는 blocker가 아니지만 runtime UI 문구 변경 전에는 Decision 필요.

### Google Sheet historical drift

`71_이미지기획_생성목록`의 `TEN-IMG-001`은 과거 `USER_RESUMED_IMAGE_WORK_REVIEW_COMPLETE_GATE_NOT_AN_ASSET` 상태를 유지한다.

- 현재 Notion/GitHub visual work truth보다 오래됨.
- v4.8 Domain Split에 따라 Sheet는 migration-only이므로 신규 상태를 Sheet에 다시 동기화하지 않는다.
- 새 세션은 Sheet의 이 행을 current authority로 사용하지 않는다.

### Human/device/runtime evidence

아직 다음을 주장하지 않는다.

- Windows visible local usability PASS.
- Android actual device PASS.
- 15명 전체 식별성 PASS.
- 최종 VFX/audio PASS.
- 승인 Reference의 Godot runtime integration PASS.
- Human fun/readability/immersion PASS.

---

## 9. 품질 유지 체크리스트

새 이미지가 현재 승인 품질을 유지하려면 매 묶음마다 확인한다.

- [ ] 배경이 인물/UI보다 낮은 대비인가.
- [ ] 인물이 세로로 길고 반실사 무협 비율인가.
- [ ] 도트/디더링이 전체 스타일이 아니라 제한적 마감인가.
- [ ] 캐릭터 식별이 얼굴색보다 머리/무기/자세/의상 덩어리로 되는가.
- [ ] UI가 그림체를 억지로 따라 하지 않고 판독성을 우선하는가.
- [ ] 금색이 핵심 선택/결정에 제한되는가.
- [ ] 텍스트·수치가 원화에 굽혀 있지 않은가.
- [ ] 숨은 계획/AI 정답이 시각적으로 누출되지 않는가.
- [ ] 카드/행동 UI가 덱·손패처럼 보이지 않는가.
- [ ] 새 결과가 승인 reference 4종과 한 가족으로 보이는가.

---

## 10. Problem → Lesson 요약

상세 기록: `docs/reviews/2026-08-25_VISUAL_PRODUCTION_PROBLEMS_AND_LESSONS.md`.

핵심 교훈:

1. **스타일 통일은 모든 레이어를 같은 렌더러로 만드는 것이 아니다.** 배경/캐릭터/UI가 서로 다른 책임을 가지되 같은 의미 체계로 연결될 수 있다.
2. **캐릭터 체형과 화면 점유가 먼저다.** 카드/UI 디테일을 조정하기 전에 전투 화면에서 인물이 너무 작거나 짤막하게 보이는 문제를 먼저 해결해야 한다.
3. **정보량이 많은 전술 게임의 카드는 짧고 시각적으로, 상세는 별도 패널로 분리한다.**
4. **대량 자산 전에 대표 화면 → Character Master → 삽화 시트 → clean plate 순으로 style lock을 잡으면 재작업을 줄인다.**
5. **Notion image block 존재만 확인하지 말고 attachment 내용 + destination readback을 확인한다.**
6. **승인 Reference와 runtime asset은 다른 상태다.** 승인 화면을 곧바로 `assets/`에 shipping asset으로 넣지 않는다.
7. **사용자가 명시한 bounded batch는 검토 cadence를 줄이면서도 자동 chain을 막을 수 있다.** 이 항목은 Base 공용 규칙 변경 후보이며 아직 Base 구현 완료가 아니다.

---

## 11. Base 승격 상태

이번 프로젝트에서 나온 공용 후보는 Base BCP로 제출한다.

공용 후보:

- `LAYERED_VISUAL_STYLE_RESPONSIBILITY`: 배경/캐릭터/UI를 동일 렌더러로 강제하지 않고 역할별 visual treatment를 분리한다.
- `REFERENCE_SET_BEFORE_SCALE`: 대표 화면 + Character Master + small-card illustration sheet + clean plate를 먼저 승인한 뒤 대량 자산 생산으로 확장한다.
- `BOUNDED_EXPLICIT_IMAGE_BATCH`: 사용자 명시 승인 하에 1~N개의 bounded batch를 허용하되 묶음 후 자동 다음 생성은 금지한다.
- `NOTION_ATTACHMENT_CONTENT_READBACK`: Notion 전달 완료는 block 존재뿐 아니라 실제 non-empty attachment와 destination readback을 요구한다.

프로젝트 고유 값(십보강호 3/3/4, 무공, 15명, 수묵/금색 palette 등)은 Base 공용 규칙에 복사하지 않는다.

---

## 12. Resume 한 줄

> **새 채팅에서는 GitHub/Notion을 fresh-read한 뒤 Notion의 4종 승인 Reference와 이 handoff를 기준으로 `Opponent Character Master #01 + Martial Technique Illustration Sheet #01 + Route Icon Sheet #01` 세 장 묶음부터 재개한다. 자동으로 다음 묶음까지 생성하지 않는다.**
