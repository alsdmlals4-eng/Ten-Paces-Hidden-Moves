# 십보강호 · 첫 Vertical Slice Visual/UX 요구사항 명세

> Decision: `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`  
> 상태: `APPROVED_VISUAL_UX_REQUIREMENT`  
> 상위 기획 완료 Decision: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`  
> 제품 구현 권한: `false`  
> 새 이미지 생성 권한: `USER_EXPLICIT_REQUEST_REQUIRED`

이 문서는 첫 5전 Vertical Slice의 텍스트 기획을 다시 열지 않고, 기존 수묵 전투 자산·Combat UI·비전투 Flow를 하나의 시각/UX 언어로 묶는 **Visual/UX 구현 입력 계약**이다.

핵심 방향은 **통합 수묵 전술 화폭**이다. 화면마다 별도 미술 체계를 만들지 않고 현재 전투의 수묵·세피아·먹+금 계보를 `Main → Setup → Intro → Briefing → Combat → Review → Result → Route → Completion` 전체로 확장한다.

---

## 1. 보호할 제품 정체성

다음은 시각 검토 때문에 바꾸지 않는다.

- 논리 10칸 전장.
- `3수 → 3수 → 4수` 계획.
- 플레이어/적 현재 계획 비공개.
- AI가 플레이어 미확정 계획을 읽지 않는 anti-cheat.
- 거리·합·대응·중단·복기.
- 시작 무공 6중4.
- 5개 주요 비무 슬롯 × 후보 3명.
- 비무 사이 정확히 `회복/성장 1노드 + 정보/대비 1노드`.
- 다음 상대는 Result 뒤 Route 전에 선확정.
- Combat Review는 Combat Overlay, Duel Result는 별도 Scene.
- `[관찰]`은 공개 가능한 행동 종류만 보여 주고 정답을 누설하지 않는다.
- 기존 10권 무공과 현행 카드/행동 UI를 재사용한다.

Visual/UX는 이 규칙을 더 잘 읽게 해야지 새 판정·새 자원·새 덱 시스템을 추가하면 안 된다.

---

## 2. Visual North Star

### 2.1 통합 수묵 전술 화폭

- 전장이 가장 큰 시각 질량이다.
- 장식은 전술 판단보다 앞에 오지 않는다.
- 세계 표현은 저채도 수묵·세피아·종이 질감을 기본으로 한다.
- 중요한 선택·잠금·결정적 결과에는 제한된 따뜻한 금색을 사용한다.
- 위험·피해·중단에는 제한된 탁한 적색을 사용한다.
- 청회색은 거리·보조 상태·중립 또는 비활성 정보에 우선한다.
- 밝은 종이색은 반드시 읽어야 하는 핵심 텍스트에 사용한다.
- 색상만으로 상태를 구분하지 않고 아이콘·형태·텍스트를 함께 사용한다.

### 2.2 핵심 문장

> **불확실성은 커밋 전에 유지하고, 명확성은 해결 후 극대화한다.**

- Briefing/Route는 가능성을 좁힌다.
- Combat의 현재 숨은 계획은 숨긴다.
- Review는 이미 발생한 결과의 원인과 순서를 명확하게 보여 준다.
- Review는 다음 행동을 자동 추천하지 않는다.

---

## 3. 화면별 Visual/UX 계약

| 화면 | 플레이어의 한 질문 | 제1 시선 | 시각/UX 역할 | 금지 |
|---|---|---|---|---|
| Main | 이번 비무행을 시작/이어갈까? | 제목 + 진입 | 넓은 여백, 진입 선택 1개 강조 | 메뉴 과밀 |
| Setup | 어떤 4권으로 나를 정의할까? | 선택한 4권 | 무공을 플레이어 정체성으로 보이게 | 덱/손패/드로우 문법 |
| Intro | 왜 이 비무행을 걷는가? | 플레이어 + 목적 | 짧은 무협 화폭으로 첫 비무에 연결 | 장문 세계관 설명 |
| Briefing | 이 상대의 무엇을 믿고 무엇을 의심할까? | 상대 → 공개 무공 → 습관/반례 | 정답이 아니라 가설 형성 | 잠금 계획·AI 가중치·정답 대응 공개 |
| Combat | 어떤 3/3/4 계획을 잠글까? | 전장 + 거리 + 현재 묶음 | 기존 Combat UI가 주인공 | 초상/연출이 전장 가림 |
| Review | 왜 방금 결과가 났나? | 사건 1~3개 | 원인 → 결과 순서 명료화 | 다음 수 자동 코칭 |
| Result | 무엇을 얻었고 다음 상대는 누구인가? | 승패/등급 → 보상 → 다음 상대 | 긴장 해소 + 다음 긴장 생성 | Route 선택까지 압축 |
| Route 1 | 지금 회복/성장 중 무엇이 필요한가? | 2개 선택 | 현재 상태와 선택 결과 직접 비교 | 거대 월드맵 |
| Route 2 | 다음 상대를 위해 무엇을 더 알까? | 다음 상대 맥락 + 2개 선택 | 공개 정보의 폭만 조절 | 상대 reroll·정답 노출 |
| Completion | 이번 비무행에서 무엇이 달라졌나? | 읽기/계획/적응 변화 | 플레이어 변화와 기억점 회고 | 통계 덤프 |

---

## 4. 공통 정보 위계

모든 화면은 다음 3층을 사용한다.

1. **지금 판단에 반드시 필요한 정보**
2. **선택을 비교할 때 필요한 정보**
3. **상세 확인용 정보**

공통 규칙:

- 한 화면의 Primary CTA는 1개만 가장 강하게 보이게 한다.
- `뒤로`, `상세`, `도움말`은 Primary CTA와 시각 경쟁하지 않는다.
- 상태 변화는 색 외에 텍스트·아이콘·형태를 사용한다.
- 숫자/이름/사거리/효과는 원화에 굽지 않는다.
- 설명이 길어지면 상세 패널 또는 단계적 펼침으로 내린다.

---

## 5. Combat → Review 전환 계약

Review는 별도 전투판을 새로 만들지 않는다.

1. 현재 Combat 전장의 위치·거리·전투원 위치를 유지한다.
2. 전장을 어둡게 눌러 현재 분석 대상 외 요소의 대비를 낮춘다.
3. 이번 해결에서 가장 중요한 사건 1~3개만 순차 강조한다.
4. 각 사건은 `원인 → 적용 → 결과`를 짧은 Chip/Log로 표시한다.
5. 원인 후보 예:
   - 합 승리/패배
   - 사거리 실패
   - 방향 실패
   - 방어도 적용
   - 회피 성공/실패
   - 중단
   - 후속타 취소
   - 잔여타
6. Review가 종료되면 Result Scene으로 이동한다.

Review는 게임 해설이 아니라 **판정 복기**다.

---

## 6. 캐릭터 Visual 계약

후보 15명은 15개의 UI 시스템이 아니다.

### 6.1 공통 프레임

모든 후보가 공유한다.

- 동일 Portrait Frame.
- 동일한 기본 조명·명암 범위.
- Combat 전신의 동일 기준 크기와 발 위치.
- 플레이어를 바라보는 facing 방향 규칙.
- Briefing/Result에서 동일 정보 슬롯.

### 6.2 최소 차별화 축

각 후보는 최소 다음에서 차이가 나야 한다.

- 얼굴/머리 큰 실루엣.
- 무기.
- 자세.
- 의상 큰 덩어리.
- 소량의 포인트 색.

같은 무공서가 재등장할 때 문파 색만 바꾸는 대신 **그 무공을 운용하는 태도와 실루엣**으로 구분한다.

### 6.3 재사용

- 초상은 Briefing/Result/Route의 opponent lockup에 재사용한다.
- Combat 전신은 동일 원화 계보에서 자세/무기 layer를 구조화해 재사용 가능하게 한다.
- 화면별로 15명 전용 풀 일러스트를 만들지 않는다.

---

## 7. 재사용 컴포넌트 계약

| Component | 사용 화면 | 핵심 상태 |
|---|---|---|
| `InkFrame` | Main/Setup/Briefing/Result/Route/Completion | default/focus/disabled |
| `CharacterPortraitSlot` | Briefing/Result/Route | player/opponent/locked-next |
| `MartialIdentityBadge` | Setup/Briefing/Result | manual/faction/technique-role |
| `PrimaryDecisionPanel` | Setup/Result/Route | selectable/selected/confirmed |
| `CauseEventChip` | Review | clash/range/defense/evade/interrupt/residual |
| `NextOpponentLockup` | Result/Route | locked/public-known/hidden-detail |
| `CompletionMemoryCard` | Completion | read/plan/adaptation highlight |

기존 카드 Atlas, Badge, 비용 Icon, 전투 배경, 초상, battler, 먹+금 VFX 계보는 `REUSE_FIRST`다.

---

## 8. 최소 신규 Visual Asset Inventory

아래는 **요구사항**이다. 이 Decision은 이미지 생성 권한이 아니다.

### `TEN-VIS-A01` · 공통 비전투 수묵 clean plate 1~2종

- Main/Intro/Briefing/Result/Route에서 crop/overlay로 재사용.
- 전투판을 흉내 내지 않고 여백과 인물 가독성을 우선.

### `TEN-VIS-A02` · 상대 15명 Portrait Set

- 동일 프레임/조명/시선 규칙.
- 인물별 실루엣 차별화.
- 텍스트/문파 이름을 이미지에 굽지 않음.

### `TEN-VIS-A03` · 상대 15명 Combat Battler Set

- 동일 크기/발 위치/facing 계약.
- 작은 표시 크기에서도 무기와 자세가 구별되어야 함.

### `TEN-VIS-A04` · Route 8노드 Icon Set

- 회복/성장/정보/대비 의미가 색 없이도 구별.
- 단색 SVG/shape 우선.

### `TEN-VIS-A05` · Result/Completion 인장·등급·기록 표식

- 텍스트와 분리된 SVG/shape 계열 우선.
- 등급 장식이 승패/보상 정보보다 강해지지 않음.

### `TEN-VIS-A06` · 추가 전투 배경 변주 2~3종

- 저대비 clean plate.
- 전투원·거리·HUD 가독성을 침범하지 않음.
- 배경마다 별도 룰을 암시하지 않음.

현재 상태: `REQUIREMENT_APPROVED / NOT_GENERATED`.

---

## 9. Layer / Provenance 계약

시각자료는 다음 레이어를 분리해 관리한다.

1. `background clean plate`
2. `character / portrait`
3. `weapon or silhouette accent`
4. `UI frame / badge / icon`
5. `text / numeric data`
6. `VFX overlay`

원화 안에 텍스트·수치·UI를 굽지 않는다. 생성/가공 자산은 source, prompt/provenance, 활성/비활성 상태, 투명도 요구를 manifest에서 추적한다.

---

## 10. Responsive / Accessibility

- Windows와 Android는 동일한 핵심 정보 필드를 유지한다.
- 플랫폼 차이는 정보 삭제가 아니라 배치 재구성으로 해결한다.
- 모바일 축소에서 장식/풍경/보조 설명을 먼저 접거나 줄인다.
- Combat 우선순위는 `거리 → 자원 → 현재 3/3/4 → 잠금 상태`다.
- Briefing 우선순위는 `상대 → 공개 무공 → 습관 → 반례`다.
- Route 우선순위는 `선택 결과 → 현재 상태 → 다음 상대 맥락`이다.
- 포커스·키보드·게임패드·터치에서 Primary CTA와 선택 상태가 명확해야 한다.
- 모션 감소/빠른 재생/즉시 완료에서도 판정 순서와 원인이 텍스트로 남아야 한다.

실제 Windows visible/Android 기기/Human 가독성은 아직 `NOT_RUN`이다.

---

## 11. 금지 시각 문법

- 상대 잠금 계획을 색·포즈·연출로 정답 누설.
- 카드게임의 손패·드로우·덱 셔플처럼 보이는 UI.
- 과도한 금장·glassmorphism·강한 glow.
- 수묵 자산 위에 사진적/렌더링 스타일을 혼합해 그림체 일관성 붕괴.
- 15명 × 화면별 독립 풀 일러스트를 P0로 요구.
- Route를 별도 대형 월드맵/메타게임으로 확장.
- Review에서 다음 행동을 직접 추천.
- Combat보다 캐릭터 초상이나 VFX가 더 큰 시각 질량을 차지.

---

## 12. 외부 벤치마크 적용 경계

기존 조사에서 다음 원칙만 가져온다.

- *Into the Breach*: 해결 인과와 전술 정보의 높은 가독성은 `ADAPT`하되, 적의 정확한 미래 행동 전체 공개는 십보강호 정체성과 충돌하므로 채택하지 않는다.
- *Phantom Brigade*: 계획과 실행을 시각적으로 분리하는 긴장 구조는 `ADAPT`하되, 타임라인 전체 예측 공개는 채택하지 않는다.
- *Yomi*: 동시 선택과 상대 성향 읽기는 핵심 정체성 강화에 `ADAPT`한다.
- *Fights in Tight Spaces*: 위치와 기다림/행동 타이밍의 의미는 `ADAPT`하되 덱빌딩 구조는 가져오지 않는다.

벤치마크는 제품 정체성을 설명하는 참고이지 시스템 복제 권한이 아니다.

---

## 13. 적대적 검토 5회 요약

### Loop 1 · 미술이 전술을 덮는가?

위험: 캐릭터/배경/VFX가 10칸 수읽기보다 앞에 보임.  
대응: 전장을 최대 시각 질량으로 유지하고 배경·초상은 대비를 낮춘다.

### Loop 2 · Route가 별도 게임으로 비대해지는가?

위험: 강호행로가 월드맵/탐험 게임으로 변함.  
대응: 정확히 2노드, 현재 선택과 다음 상대 맥락만 표시한다.

### Loop 3 · 15명 제작량이 폭증하는가?

위험: 인물 × 화면별 독립 일러스트.  
대응: 공통 프레임 + Portrait/Battler 재사용 + 모듈형 clean plate.

### Loop 4 · 시각 정보가 숨은 계획을 누설하는가?

위험: 포즈·색·애니메이션이 정답표가 됨.  
대응: 공개 이력/습관/행동 종류 경계만 표현하고 hidden plan은 시각적으로도 보호한다.

### Loop 5 · 모바일 축소에서 정보가 붕괴하는가?

위험: PC UI 단순 축소.  
대응: 핵심 정보 필드를 유지하면서 상세/장식만 접는 반응형 계층을 사용한다.

현재 검토 결과: **코어 기획 Reopen 필요 없음**.

---

## 14. 재검토 조건

다음 중 하나가 실제 evidence로 확인되면 Visual/UX Decision을 다시 연다.

- 플레이어 시선이 전술 정보보다 장식에 지속적으로 끌림.
- 1280×720 또는 모바일 레이아웃에서 핵심 정보가 1차 시야에 남지 않음.
- 같은 무공서를 쓰는 반복 상대가 초상/실루엣만으로 구별되지 않음.
- Briefing 정보가 숨은 계획의 사실상 정답표가 됨.
- Review가 원인 설명 대신 자동 코칭처럼 읽힘.
- Route가 전투보다 큰 별도 메타게임으로 체감됨.

---

## 15. 다음 Gate

Visual/UX 요구사항 검토는 완료했다.

현재 상태:

```yaml
visual_ux_requirement: COMPLETE
visual_asset_generation: NOT_REQUESTED
product_implementation_authorized: false
human_visual_approval: NOT_RUN
windows_visible_layout_validation: NOT_RUN
android_physical_layout_validation: NOT_RUN
```

다음은 사용자 명시 요청에 따라 둘 중 하나다.

1. **이미지 제작 요청** → `TEN-VIS-A01`부터 정확히 1장씩 생성·승인·구조화 루프.
2. **제품 구현 요청** → `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`와 이 문서를 함께 fresh-read하고 current Entry Gate를 확인한 뒤 구현 작업 계약을 작성.

두 요청이 모두 없으면 `AWAITING_EXPLICIT_ASSET_OR_IMPLEMENTATION_REQUEST`로 유지한다.

---

## 16. 현재 목표 Build 화면 인벤토리·시각 커버리지 감사 · 2026-08-27

> Issue: [#238](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/issues/238)
> 범위: 기본 진입 `res://scenes/run/vertical_slice_shell.tscn`의 첫 5전 Vertical Slice. 이 절은 이 문서의 화면별 Visual/UX 계약을 **actual runtime consumer와 coverage 상태로 읽기 위한 current projection**이다. Asset Manifest·승인 lifecycle·runtime PASS의 독립 정본이 아니다.

### 16.1 목표 Build와 화면 family 판정

```yaml
target_build: FIRST_FIVE_DUEL_PC_FIRST_VERTICAL_SLICE
must_play_flow: MAIN → SETUP → INTRO → BRIEFING → COMBAT → REVIEW → RESULT → ROUTE_GROWTH → ROUTE_INFO → BRIEFING → ... → COMPLETION
runtime_entry: res://scenes/run/vertical_slice_shell.tscn
runtime_state_owner: src/run/vertical_slice_run_state.gd
screen_design_reference_owner: this document + exact Project Notion `03 · UI · 전투 Flow Map` / `02 · 비주얼 바이블`
runtime_asset_owner: assets/ASSET_MANIFEST.json + actual preload/data consumer
image_generation_policy: NO_AUTOMATIC_IMAGE_GENERATION_FROM_GAPS
```

| Family | 판정 | 이유 |
|---|---|---|
| A 시작·시스템 진입 | 적용 | `MAIN`은 현재 기본 실행 경로의 단일 진입 화면이다. Boot/splash/loading, save slot, profile, continue/load는 현재 Slice에 없다. |
| B 시작 구성·선택 | 적용 | `SETUP`에서 6개 시작 무공 중 정확히 4개를 고른다. 별도 캐릭터/직업/장비 화면은 없다. |
| C 허브·지도·행로 | 부분 적용 | 허브·월드맵은 없고, `ROUTE_GROWTH`와 `ROUTE_INFO` 두 순차 선택 surface만 있다. |
| D 핵심 gameplay | 적용 | 10칸 논리 전장과 3/3/4 계획의 `COMBAT` 및 그 Overlay `REVIEW`가 핵심 gameplay다. 대화/탐색/건설은 없다. |
| E 준비·전투 | 적용 | `BRIEFING`, `COMBAT`, `REVIEW`가 실제 Scene/Overlay 경계를 이룬다. 별도 조준/QTE/보스 phase surface는 없다. |
| F 결과·반복 성장 | 적용 | `RESULT`, 두 Route surface, `COMPLETION`이 보상·성장·완주 흐름을 담당한다. Game-over/retry는 아직 없다. |
| G 기록·도움 | 미적용 | 도감, 튜토리얼, 검색, 기록 보관소는 현재 Slice runtime에 구현/소비처가 없다. |
| H 일시정지·설정 | 미적용 | pause, settings, language, save/load, input remap은 현재 Slice runtime에 구현/소비처가 없다. |
| I 실패·종료·예외 | 부분 적용 | `COMPLETION`은 정상 완주만 제공한다. failure/game-over, credits, loading/error/reconnect는 현재 Slice에 구현/소비처가 없다. |

### 16.2 Target Screen Inventory

`P0`는 현 목표 Build의 첫 완주 흐름을 막는 surface, `P1`은 반복·명료성·후속 polish, `P2`는 현재 Slice 밖의 production/release surface다. `coverage_status`는 승인 자산 lifecycle이나 Human/runtime PASS를 뜻하지 않는다.

| screen_id | priority | entry → exit | 플레이어 질문 / 첫 시선 | runtime consumer | composition evidence | coverage_status |
|---|---|---|---|---|---|---|
| `SCREEN_MAIN` | P0 | app entry → 새 비무행 | 이번 비무행을 시작할까? / 제목·단일 CTA | `VerticalSliceShell._render_current_screen` | functional `ContentPanel`, 전면 `TechnicalBackground` | `COVERED_EXISTING` |
| `SCREEN_SETUP` | P0 | Main → Intro | 어떤 4권으로 나를 정의할까? / 선택 수·무공 목록 | `VerticalSliceShell._build_setup_options` | Godot toggle buttons·text | `COVERED_EXISTING` |
| `SCREEN_INTRO` | P0 | Setup → Briefing | 왜 첫 비무행을 걷는가? / 짧은 목적·선택 무공 | `VerticalSliceShell._render_current_screen` | Godot text/panel | `COVERED_EXISTING` |
| `SCREEN_BRIEFING` | P0 | Intro/Route Info → Combat | 무엇을 믿고 의심할까? / 상대·공개 무공·습관 | `VerticalSliceShell._render_briefing` | Godot text/panel; hidden-plan exclusion in code text | `COVERED_EXISTING` |
| `SCREEN_COMBAT` | P0 | Briefing → Review | 어떤 3/3/4 계획을 잠글까? / 전장·거리·현재 묶음 | `VerticalSliceCombatBridge` → `CombatBoardPreview` | existing combat runtime; focused Godot evidence | `COVERED_EXISTING` |
| `OVERLAY_REVIEW` | P0 | terminal Combat → Result | 왜 방금 결과가 났나? / 실제 사건 1~3개 | `CombatReviewPanel` via `VerticalSliceCombatBridge` | combat-on-screen overlay | `COVERED_EXISTING` |
| `SCREEN_RESULT` | P0 | Review → Route/Completion | 무엇을 얻고 다음에 무엇을 준비할까? / 결과·보상 선택 | `VerticalSliceResultShell` (`src/run/vertical_slice_shell_result_auto.gd`) | Godot result options/text | `COVERED_EXISTING` |
| `SCREEN_ROUTE_GROWTH` | P0 | Result → Route Info | 지금 무엇을 회복/성장시킬까? / locked opponent 맥락·3개 선택 | `VerticalSliceRouteShell` (`src/run/vertical_slice_shell_route_auto.gd`) | Godot option controls/text | `COVERED_EXISTING` |
| `SCREEN_ROUTE_INFO` | P0 | Route Growth → Briefing | 다음 상대에 대해 무엇을 더 알까? / 공개 정보 선택 | `VerticalSliceRouteShell` (`src/run/vertical_slice_shell_route_auto.gd`) | Godot option controls/text | `COVERED_EXISTING` |
| `SCREEN_COMPLETION` | P0 | Duel 5 Result → terminal | 첫 비무행에서 무엇이 달라졌나? / run history | `VerticalSliceCompletionShell` (`src/run/vertical_slice_shell_completion_auto.gd`) | Godot summary cards/text | `COVERED_EXISTING` |
| `SCREEN_PAUSE_SETTINGS` | P1 | N/A | 설정/중단/복귀 | 없음 | `NOT_APPLICABLE` for current Slice; future support flow | `NOT_APPLICABLE` |
| `SCREEN_FAILURE_RETRY` | P1 | N/A | 패배 이유·재시도 | 없음 | `NOT_APPLICABLE` for current Slice; no game-over model | `NOT_APPLICABLE` |
| `SCREEN_CODEX_HELP` | P2 | N/A | 도감·튜토리얼·검색 | 없음 | `NOT_APPLICABLE` for current Slice | `NOT_APPLICABLE` |
| `SCREEN_RELEASE_LOADING_ERROR` | P2 | N/A | boot/loading/error/credits/store | 없음 | `NOT_APPLICABLE` for current Slice | `NOT_APPLICABLE` |

### 16.3 Screen → Asset Coverage Matrix

| screen scope | composition / identity | world·character | UI·text·state | feedback / technical consumer | implementation mode | coverage / gap treatment |
|---|---|---|---|---|---|---|
| Main / Setup / Intro | existing `InkSurface` direction, not a baked screen bitmap | no mandatory character image | `ContentPanel`, `Button`, `Label`, toggle state | primary CTA; disabled until 4 selections | `GODOT_UI + TEXT_LAYER + NO_NEW_IMAGE_FILE_REQUIRED` | P0 covered by functional UI; whole-screen visual polish is P1 `SCREEN_DESIGN_REFERENCE` queue |
| Briefing | panel hierarchy protects uncertainty | opponent identity is structured text; portrait is optional | public manual/habit/counterexample; hidden plan excluded | start CTA | `GODOT_UI + TEXT_LAYER + REUSE_PROJECT` | P0 covered; portrait/result crop is not required until an exact opponent consumer is selected |
| Combat / Review | battle background remains largest mass | `twilight_ink_duel_v1`, player/enemy battlers, Dogyeom routing for `slot1_dogyeom` | HUD, timeline, cards, focus/selected/disabled state | range/target/resolve/review; `ultimate_ink_gold_sprite_sheet_rgba` | `EXISTING_APPROVED + REUSE_PROJECT + GODOT_UI + SVG_VECTOR + SPRITE_SHEET` | P0 covered by actual preloads and Godot regressions; warm-dusk candidate remains `GENERATED_EXPLORATION · IN_REVIEW`, never a runtime asset |
| Result / Route / Completion | functional panel composition, not a full-screen raster | no mandatory new background/portrait | result choices, locked opponent context, route options, run summary | reward receipt / selected route / completion summary | `GODOT_UI + TEXT_LAYER + PROCEDURAL_DRAW + NO_NEW_IMAGE_FILE_REQUIRED` | P0 covered; result mark/route icon/background variant remain P1 `GAP_NONBLOCKING` only when exact component consumer is specified |
| Pause / Failure / Codex / Release system | no current consumer | none | none | none | `DO_NOT_GENERATE` | `NOT_APPLICABLE` for this Slice; future scope must create a screen requirement before assets |

### 16.4 Screen Design Reference Queue

| screen_id | reference_needed | existing anchor | required fidelity / validation | priority |
|---|---|---|---|---|
| `SCREEN_COMBAT` / `OVERLAY_REVIEW` | no new reference before current candidate review | `TEN-IMG-001`; `WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID` is candidate-only | existing focused Godot regression; Windows visible/human comparison remains `NOT_RUN` | P1 |
| `SCREEN_MAIN` / `SCREEN_SETUP` / `SCREEN_INTRO` | composition only, no raster requirement | Visual Bible Component System + `TEN-VIS-A01` approved clean-plate reference | target-resolution wireframe or runtime capture after a separately approved implementation package | P1 |
| `SCREEN_BRIEFING` / `SCREEN_RESULT` / `SCREEN_ROUTE_*` / `SCREEN_COMPLETION` | composition only, no raster requirement | existing Visual/UX Flow + reusable panel/character-slot rules | runtime capture after a separately approved implementation package | P1 |

### 16.5 Runtime Asset Family Queue

| asset_family_id | screen_ids | actual runtime consumer | states / variants | production mode | status |
|---|---|---|---|---|---|
| `COMBAT_BACKGROUND_01` | Combat, Review | `src/combat/battle_background.gd` | normal backdrop | `EXISTING_APPROVED` | `COVERED_EXISTING`; candidate replacement is not approved |
| `COMBAT_CHARACTER_BATTLERS` | Combat, Review | `src/combat/combat_character_placeholder.gd` | player, generic enemy, `slot1_dogyeom` | `REUSE_PROJECT` | `COVERED_EXISTING`; remaining opponents require exact consumer + identity source |
| `STATUS_PORTRAITS` | Combat | `src/ui/combatant_status_panel.gd` | player, generic enemy, `slot1_dogyeom` | `EXISTING_APPROVED` | `COVERED_EXISTING`; 14 portraits are not an automatic queue |
| `CARD_ICON_ILLUSTRATION` | Combat | `src/ui/basic_card_tray.gd → src/ui/basic_card_tray_item.gd`, `data/cards/basic_cards.json` | source/category/cost/selected/disabled | `SVG_VECTOR + TEXT_LAYER + REUSE_PROJECT` | `COVERED_EXISTING`; a new raster is allowed only for an exact card ID |
| `ULTIMATE_VFX` | Combat | `src/combat/combat_board_preview.gd` | staged effect | `SPRITE_SHEET` | `COVERED_EXISTING` for current VFX; Human readability `NOT_RUN` |
| `NONCOMBAT_UI_COMPONENTS` | Main/Setup/Intro/Briefing/Result/Route/Completion | `src/run/vertical_slice_shell*.gd` | normal/focus/selected/disabled | `GODOT_UI + TEXT_LAYER` | `COVERED_EXISTING`; no image file required |

### 16.6 교정 로그와 Codex handoff

| 현행 | 문제 | 교정 | 실제 사용 예 | 기대효과 | evidence |
|---|---|---|---|---|---|
| historical A01~A06 asset-family list | asset category만으로 화면 completeness를 판단할 위험 | 이 절에서 actual screen-first rows, consumer, mode, `NOT_APPLICABLE` reasons를 추가 | Route는 별도 월드맵 asset이 아니라 두 Godot choice surface | 불필요한 image backlog 방지 | `VerticalSliceRunState` screen constants + shell routes |
| `STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL` metadata | 기능적 P0 flow와 final visual polish를 혼동할 위험 | P0 functional coverage와 P1 screen-reference polish를 분리 | Main/Result/Route/Completion are functional panels, not missing image screens | coverage gap이 자동 생성으로 번지지 않음 | actual run shell metadata |
| `VisualReferenceStatus` 표시 문구 | `final_visual_reference_pending=false`와 달리 승인 Reference가 아직 반영 전처럼 읽힘 | Issue #240에서 문구를 `승인 전투 레퍼런스 확인됨`으로 교정하고 기존 shell regression을 갱신 | `src/run/vertical_slice_shell.gd` pending label | 사용자-facing 상태 표기의 정합성 회복 | focused Godot shell regression `PASS`; Windows/Android/Human `NOT_RUN` |

**Codex implementation record — `CODEX_UI_COPY_CORRECTION_REQUIRED`**

```yaml
scope: one non-core copy correction only
issue: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/issues/240
implementation_status: FOCUSED_GODOT_PASS_PENDING_PR_MERGE
read_first:
  - docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md#16
  - src/run/vertical_slice_shell.gd
  - tests/verify_vertical_slice_shell.gd
  - tests/verify_default_vertical_slice_entry.gd
exact_consumer: VerticalSliceShell/VisualReferenceStatus
change: replace the stale “승인 전투 레퍼런스 반영 전” wording with a statement that the approved reference exists while this shell remains functional/visual-hierarchy evidence only
non_goals:
  - no visual asset promotion
  - no layout, combat rule, or flow change
  - no generated image
acceptance:
  - `final_visual_reference_pending` remains false
  - the label does not say approval is pending
  - update the exact `VisualReferenceStatus` expectation in `tests/verify_vertical_slice_shell.gd`
  - shell and default-entry regressions pass
  - Windows/Android/human evidence remains unchanged
godot_validation: run the focused default-entry/shell verification; close any Godot process started for it
```

### 16.7 Audit exit and remaining gaps

```yaml
p0_blocking_gap: 0
p1_nonblocking:
  - screen-level composition comparison for noncombat functional UI
  - warm-dusk candidate review; no Notion attach, runtime integration, or extra generation
p2_deferred:
  - pause/settings, failure/retry, codex/help, boot/loading/error/release surfaces
image_brief_approval_required: none_from_this_audit
runtime_player_validation:
  - windows visible human usability: NOT_RUN
  - android device: NOT_RUN
  - human readability/fun: NOT_RUN
```

Five adversarial checks completed for this audit: screen completeness (all current state constants/overlays listed), player decision clarity (one question/entry/exit per P0 row), state-family coverage (selected/disabled/focus and combat feedback assigned to actual consumer), overproduction (noncombat uses Godot UI/text; no automatic raster queue), and canon/runtime alignment (Notion/manifest/runtime consumers compared; stale copy isolated to a bounded handoff).
