# 십보강호 · Art Style & Component System 명세

> Decision: `TEN-DEC-20260820-VISUAL-COMPONENT-STYLE-SYSTEM-02`  
> 상위 Visual/UX Decision: `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`  
> 상태: `APPROVED_ART_STYLE_COMPONENT_BASELINE`  
> 사용자 승인: `좋아 권장안대로 진행하자`  
> 기준 viewport: `1440×900` logical / `1280×800` current window override  
> 최종 Human Visual PASS: `NOT_RUN`

이 문서는 `통합 수묵 전술 화폭`을 실제 제작·구현 가능한 **그림체 규칙, 디자인 토큰, 컴포넌트 크기, 상태, 레이아웃, 반응형 규칙**으로 내린다. 기존 Combat/RunState/Route 규칙은 바꾸지 않는다.

---

## 1. 승인 그림체

### 1.1 이름

**비픽셀 2D · 수묵 선화 × 저채도 담채 × 제한된 금색 포인트 · 반실사 무협 일러스트**

구조화 키: `NON_PIXEL_SEMI_REALISTIC_INK_LINE_RESTRAINED_WASH`.

### 1.2 캐릭터 렌더링

- 성인 기본 비례 `7~7.5등신`.
- 실사와 애니메이션 사이의 반실사. chibi·과도한 미형화·photoreal을 사용하지 않는다.
- 얼굴·머리 큰 실루엣, 무기, 자세, 의상 큰 덩어리, 포인트색 순서로 인물을 구별한다.
- 캐릭터당 지배 포인트색은 `1개`를 원칙으로 하고, 보조색을 포함해 `최대 2개`를 넘기지 않는다.
- 선은 붓압과 약한 불균일성이 느껴져야 하며 완전히 균일한 vector outline처럼 보이지 않게 한다.
- 채색은 저채도 `2~4개 주요 색군` 중심. 그림자 단계는 적게 유지한다.
- 종이 질감·먹 번짐은 배경/외곽에 강하고 얼굴·무기·핵심 UI 영역에는 약하게 사용한다.
- Portrait와 Combat Battler는 같은 캐릭터 master에서 파생하고 별도 스타일로 다시 그리지 않는다.

### 1.3 배경 / VFX

- 배경은 전투원보다 `1~2단계` 낮은 대비를 유지한다.
- VFX는 `먹의 운동감 + 제한된 금색 핵심선`을 기본으로 한다.
- glow는 짧고 국소적으로만 사용한다.
- 배경이나 포즈가 상대의 숨은 현재 계획·정답 대응을 암시하면 안 된다.

### 1.4 금지 그림체

- glossy 3D / 유리질 UI / 과도한 금장.
- 고채도 모바일 중국풍 RPG 장식 과잉.
- 강한 anime glow, chibi, photoreal.
- 캐릭터마다 임의 장식·문양을 계속 추가해 AI 생성 티가 나는 방식.
- 원화 안에 이름·비용·거리·효과·수치를 굽는 방식.
- 초상은 비픽셀인데 Combat만 별도 pixel style로 고정하는 혼합. Pixel 전투는 `REOPEN_CONDITION`에서만 재검토한다.

---

## 2. Semantic Color / Material Token

색의 **역할은 고정**한다. 사용자가 제공할 최종 reference가 들어오면 exact chroma는 조정할 수 있으나 역할을 바꾸지 않는다.

| Token | 초기 implementation seed | 의미 |
|---|---:|---|
| `INK_900` | `#171411` | 화면 바탕·강한 구조 |
| `INK_800` | `#241F1A` | 패널 바탕 |
| `PAPER_100` | `#EADFC9` | 핵심 텍스트·밝은 정보면 |
| `PAPER_300` | `#C9BCA8` | 본문·보조 텍스트 |
| `SEPIA_500` | `#7F6847` | 기본 경계·오래된 종이 구조 |
| `GOLD_500` | `#B99254` | 선택·잠금·확정·절초·Primary 결정 |
| `DANGER_500` | `#965148` | 피해·중단·위험 |
| `BLUEGRAY_500` | `#687783` | 거리·중립·비활성·보조 상태 |

규칙:

- `GOLD_500`은 장식색이 아니라 **결정 의미**다.
- 모든 상태는 색만으로 표현하지 않고 `색 + 형태 + 아이콘 + 텍스트` 중 최소 3개를 함께 사용한다.
- 최종 reference review에서 색상값이 바뀌어도 token 이름과 의미는 유지한다.

---

## 3. Core Layout Token

### 3.1 기준 화면

- Design baseline: `1440×900` logical viewport.
- Current desktop window check: `1280×800`.
- Compact regression: `1280×720`.
- Android orientation은 현재 정본에 확정 근거가 없으므로 portrait/landscape를 임의 고정하지 않는다. 폭/높이 기반 profile로 대응한다.

### 3.2 Spacing

`4 / 8 / 12 / 16 / 24 / 32 / 48 / 64` logical px.

- 기본 component inner padding: `16`.
- 큰 정보판: `24`.
- compact: 한 단계 감소.
- narrow: `12~16` 유지. 텍스트를 지나치게 압축하지 않는다.

### 3.3 Grid

#### `WIDE`
- 조건: width `>=1200` and height `>=720`.
- 12 columns.
- outer margin `32`.
- gutter `16`.

#### `COMPACT_WIDE`
- 조건: width `800~1199` 또는 height `600~719`.
- 8 columns.
- outer margin `24`.
- gutter `12`.

#### `NARROW`
- 조건: width `<800` 또는 usable safe width `<720`.
- 4 columns.
- outer margin `16`.
- gutter `12`.
- 정보 삭제가 아니라 stack/collapse/drawer로 재배치한다.

### 3.4 Shape

- 기본 패널 radius: `4`.
- 큰 frame 최대 radius: `8`.
- pill shape는 상태 chip에만 제한.
- border: default `1`, focus/selected `2`, decisive emphasis 최대 `3`.
- 비대칭 붓터치 accent는 구조를 흐리지 않는 1곳에만 사용한다.

---

## 4. Typography Token

폰트 파일/정확한 family는 최종 reference 및 실제 한글 렌더링 검증 후 고른다. 계층과 크기는 이 문서에서 고정한다.

| Token | WIDE | COMPACT | 역할 |
|---|---:|---:|---|
| `H1` | 32 | 28 | 화면 제목 |
| `H2` | 24 | 22 | 주요 섹션 |
| `H3` | 18 | 18 | 카드/패널 제목 |
| `BODY` | 16 | 16 | 핵심 본문 |
| `CAPTION` | 13 | 13 | 보조 설명 |
| `MICRO` | 11 | 11 | 배지·짧은 상태 |

- 본문 최소는 `16`을 우선한다.
- 한글 캘리그래피는 제목/인장 등 국소 장식에만 사용한다.
- 수치·거리·비용은 좁아지지 않는 UI 글꼴을 사용한다.
- 터치 대상 최소 `48×48`; desktop pointer 최소 `40×40`.

---

## 5. Component Family 12종

기존 7종을 폐기하지 않고 상위 family로 확장한다.

### 5.1 `InkSurface`

역할: 전체 배경/clean surface.

- 상태: `default / dimmed / focus-background`.
- layer: clean plate → paper noise → edge ink → optional vignette.
- 중앙 정보 영역에는 강한 얼룩을 두지 않는다.

### 5.2 `InkFrame`

역할: 모든 정보판의 구조.

- WIDE padding `24`, compact/narrow `16`.
- 상태:
  - `default`: sepia 1px.
  - `focus`: gold 2px + focus marker.
  - `disabled`: bluegray/low contrast + disabled text.
  - `warning`: danger edge marker + warning icon.

### 5.3 `CharacterSlot`

기존 `CharacterPortraitSlot`을 포함하는 상위 family.

- Portrait aspect: `4:5`.
- WIDE preferred `288×360`.
- COMPACT `224×280`.
- NARROW summary `120×150`, 상세에서는 width `>=180` 확보.
- 상태: `player / opponent / locked-next / unknown / defeated`.
- 같은 master에서 Portrait crop / Combat full body / Result crop / thumbnail을 파생한다.

### 5.4 `IdentityHeader`

기존 `MartialIdentityBadge`를 포함한다.

- min height `72` WIDE / `64` compact.
- 이름 → 문파/소속 → 시그니처 무공 → 보조 한 줄의 순서.
- 배지는 한 줄 `3개`를 넘기지 않는다.

### 5.5 `MartialActionCard`

행동 카탈로그이며 hand/deck card가 아니다.

- WIDE preferred `168×224`.
- COMPACT `148×196`.
- NARROW는 `full-width × min 92` horizontal row variant 허용.
- illustration 영역 약 `60%`, structured data 약 `40%`.
- 상태: `default / hover / focus / selected / confirmed / locked / disabled`.
- 항상 표시: 행동명, 출처+종류, 슬롯, 실제 비용/비용 없음, 핵심 효과.
- 공격만 사거리 표시. 적용되지 않는 행은 만들지 않는다.

### 5.6 `ResourceStrip`

- WIDE preferred `240×44`.
- compact `208×40`.
- touch/narrow min height `48`.
- 상태: `stable / low / critical / recovering`.
- 현재/최대 값, icon, text를 함께 사용한다.

### 5.7 `TacticalStateChip`

- min height `28` desktop / `32` touch.
- horizontal padding `8~12`.
- 상태 family: `distance / clash / range-fail / guard / evade / interrupt / residual-hit / observation / locked`.
- 아이콘 하나 + 짧은 한국어 label을 기본으로 한다.

### 5.8 `DecisionTile`

기존 `PrimaryDecisionPanel`을 포함한다.

- WIDE min height `88`.
- compact `80`.
- narrow `72`, 내부 CTA/tap target는 `48` 이상.
- 상태: `selectable / hover / focus / selected / confirmed / locked / disabled`.
- selected 전에는 gold를 최소화하고 confirmed 때 가장 강하게 사용한다.

### 5.9 `TimelineBundle`

3/3/4 계획판.

- WIDE preferred height `112`.
- compact `96`.
- narrow/low-height `84`까지 축소 가능.
- 상태: `planning / ready / locked / resolving / resolved / interrupted`.
- 현재 묶음이 가장 높은 대비, 이전/다음 묶음은 한 단계 낮다.
- 연결 행동은 하나의 연결 block으로 유지한다.

### 5.10 `CauseEventChip`

- WIDE min `180×56`, max preferred width `280`.
- compact/narrow full-width row 허용.
- 내용 순서: `원인 → 적용 → 결과`.
- 타입: `clash / range-fail / defense / evade / interrupt / residual-hit / direction-fail / followup-cancel`.
- 다음 행동 추천 문구를 넣지 않는다.

### 5.11 `NextOpponentLockup`

- WIDE preferred `360×128`.
- compact width fluid / min height `112`.
- 상태: `locked / public-known / hidden-detail`.
- `locked`는 금색 잠금 표식 + 텍스트로 표시하되 숨은 계획·AI 가중치·seed는 노출하지 않는다.

### 5.12 `CompletionMemoryCard`

- WIDE preferred `248×152`.
- compact `220×144`.
- narrow full width, min height `120`.
- 상태: `read-highlight / plan-highlight / adaptation-highlight`.
- 플레이어 유형 진단이나 정답 build 추천을 하지 않는다.

---

## 6. Screen Grid Contract

### Main

- 핵심 콘텐츠: 중앙 `6/12 columns` 이하.
- 제목 → 한 줄 목적 → Primary CTA 하나.
- 배경 여백이 UI보다 넓게 느껴져야 한다.

### Setup

WIDE:
- Player identity/status `4/12`.
- 6 manual choices `8/12`.
- 선택 영역은 `3×2` 또는 너비에 따라 `2×3`.

NARROW:
- Player summary → manual list → confirm 순으로 stack.
- 2-column tile은 각 tile이 충분히 읽히는 경우만 사용; 아니면 1-column.

### Intro

- max content width `760`.
- 장문 설명 대신 character/clean plate + 2~4줄 + Primary CTA.

### Briefing

WIDE:
- CharacterSlot `4/12`.
- identity/public manual/habit/counterexample `8/12`.
- `공개 정보`와 `알 수 없음`을 별도 frame으로 구분한다.

NARROW:
- portrait summary → identity → known/unknown blocks.

### Combat

기존 Combat UI 구조를 보존한다. 이 문서는 재설계가 아니라 component sizing guide다.

1440×900 권장 vertical budget:
- top HUD: 약 `72`.
- battlefield: preferred `400~440`, min `360`.
- TimelineBundle: `112`.
- action selection/detail region: `220~250`.
- 남은 공간은 gutter/edge padding.

1280×720 compact 목표:
- HUD `64`.
- battlefield min `300~320`.
- Timeline `96`.
- action region 약 `190~210`.
- 상세창은 side overlay/drawer로 전환 가능.

전장·거리·자원·현재 3/3/4·잠금 상태를 장식보다 먼저 보존한다.

### Review

- Combat 전장을 유지하고 `dimmed`.
- CauseEventChip `1~3개`만 rail/overlay로 표시.
- WIDE는 우측 rail 또는 하단 overlay.
- NARROW는 하단 sheet로 stack.

### Result

WIDE:
- 결과/원지표/보상 `7/12`.
- NextOpponentLockup `5/12`.
- 보상 DecisionTile은 현재 runtime 계약의 **3개 logical option**을 같은 행 또는 2+1 wrap으로 표시한다.

### Route Growth/Recovery

WIDE:
- next opponent/context `5/12`.
- 현재 상태 + **3개 logical choice** `7/12`.
- `recovery / focused training / free training`을 동등 비교 후 confirm.

### Route Information/Preparation

- 같은 locked opponent를 유지한다.
- `무공 / 습관 / 최근 사례` 3개 category를 DecisionTile로 표시한다.
- 선택이 상대 reroll처럼 보이는 연출을 금지한다.

### Completion

- 상단: 5전 summary line.
- 중단: CompletionMemoryCard `3개`까지 한 행, 추가는 wrap.
- 하단: reward/Route history 요약 + 짧은 recurring-peer beat.
- raw stat dump나 personality diagnosis는 금지한다.

---

## 7. Responsive Priority

### WIDE → COMPACT

1. decorative whitespace 축소.
2. panel padding 한 단계 축소.
3. side detail을 drawer/overlay로 전환.
4. card grid column 수 감소.
5. 핵심 text size는 BODY 16 아래로 내리지 않는다.

### COMPACT → NARROW

1. 2-column 화면을 stack.
2. portrait는 summary crop으로 축소하고 상세는 별도 영역.
3. secondary detail을 collapse.
4. Primary CTA는 sticky bottom 또는 마지막 flow 위치에 유지.
5. Combat 핵심 정보는 `거리 → 자원 → 현재 3/3/4 → 잠금` 순으로 남긴다.
6. 정보 자체를 삭제하지 않는다.

### Low-height

height `<600`이면:
- noncombat는 scroll 허용.
- decorative header/clean-plate crop을 먼저 줄인다.
- Combat에서는 detail panel을 overlay/drawer로 보내고 battlefield 최소 높이를 우선한다.

---

## 8. Layer / Reuse Contract

모든 신규 Visual은 다음을 분리한다.

1. `background clean plate`
2. `character portrait/full body`
3. `weapon / silhouette accent`
4. `UI frame / panel`
5. `badge / icon`
6. `text / numeric data`
7. `VFX overlay`

캐릭터는 `Character Master → Portrait Crop → Combat Full Body → Result Crop → Silhouette → Thumbnail` 순으로 파생한다.

---

## 9. 현재 승인/보류

### APPROVED

- `TEN-VISUAL-002` 그림체 방향.
- 비픽셀 2D 수묵 선화·담채.
- 12 Component Family.
- semantic color role.
- spacing/grid/typography/component size baseline.
- 1440×900 design baseline / 1280×800 current window / 1280×720 compact regression.
- width-based responsive profiles.
- layer/reuse contract.

### STILL PENDING / HUMAN NOT RUN

- 실제 font family/file.
- 최종 reference를 반영한 exact chroma 미세 조정.
- Android orientation/device-specific safe area.
- 15명 실제 portrait/battler Human 식별성.
- Windows visible local Human readability.
- final VFX/audio polish.

---

## 10. Reopen Conditions

다음 경우에만 `TEN-VISUAL-002` 세부를 다시 연다.

1. `1280×720`에서 거리·자원·현재 3/3/4·잠금이 1차 시야에 남지 않음.
2. 비픽셀 수묵 battler가 실제 10칸 전장 판단을 방해함.
3. 동일 character master에서 Portrait/Combat/Result 일관성을 유지하기 어려움.
4. 15명이 얼굴/무기/자세/큰 의상 덩어리만으로 구별되지 않음.
5. Review가 인과 복기가 아니라 정답 코칭으로 읽힘.
6. Route UI가 전투보다 큰 별도 메타게임처럼 보임.
7. 사용자가 이후 제공하는 원본 시안이 현재 art direction보다 명백히 우수해 `ART_DIRECTION_REVIEW_TRIGGER`를 충족함.

원본 시안 review는 그림체 세부·색조·재질을 바꿀 수 있으나, 별도 후속 Decision 없이 10칸/3·3·4/hidden plan/정보 위계 같은 제품 계약을 바꾸지 않는다.

---

## 11. 현재 작업 순서

사용자 승인에 따라 다음 순서를 정본으로 사용한다.

1. `TEN-VISUAL-002` Art Style + Component baseline 기록.
2. GitHub/Notion 동기화.
3. 최종 사용자 원본 시안 수령 시 art-direction 비교 검토.
4. 필요한 경우 token/chroma/render detail만 후속 Decision으로 수정.
5. 승인 reference 기준으로 `TEN-VIS-A01~A06` 제작/구조화.
6. 실제 Windows visible/Human 검증 뒤 spacing/size micro-tuning.
7. Android 실기기 단계에서 orientation/safe-area 최종화.

새 이미지 생성은 별도 명시 요청 전 진행하지 않는다.
