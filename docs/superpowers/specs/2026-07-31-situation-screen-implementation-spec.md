# 십보강호 상황별 인게임 화면 구현 명세서 — 중간점검 초안

> Spec ID: `TEN-SIT-SPEC-20260731-01`  
> 상태: `DESIGN_DRAFT_USER_REVIEW_PENDING`  
> Work Mode: `PLAN`  
> 런타임 권한: `NONE`  
> 대상 플랫폼: `PC`  
> 대상 엔진: `Godot 4.x / GDScript`  
> 기준 브랜치: `agent/2026-07-31-combat-route-champion-sync`  
> 기준 PR: `#65`  
> 제품 코드·Scene·runtime data·asset 변경: `없음`

---

# 1. 작업 목적과 증거 경계

이 문서는 프로젝트 문서와 실제 Godot 파일을 먼저 확인한 뒤, 플레이어가 실제 게임에서 경험할 상황을 상태 단위로 분해하고 화면·시스템·데이터·Scene·Node·Signal·저장·전환·완료·테스트 계약을 작성한다.

이 문서에서 사용하는 판정 등급은 다음과 같다.

| 등급 | 의미 |
|---|---|
| `확정` | 최신 사용자 승인 결정 또는 현재 책임 원본에서 확인됨 |
| `실제 구현` | 현재 `project.godot`, Scene, Script, JSON에서 직접 확인됨 |
| `해석` | 확정 내용과 실제 구현을 연결하기 위해 도출함 |
| `제안` | Vertical Slice 구현을 위해 권장하는 신규 구조 |
| `확인 필요` | 사용자 결정·실제 실행·시각 검수 없이는 확정할 수 없음 |

레퍼런스 이미지는 현재 대화에 첨부되지 않았다. 따라서 이미지에서만 판별 가능한 배치·캐릭터 외형·애니메이션은 확정하지 않는다. 시각 방향은 현재 자산 Manifest, 전투 배경 계약, UI Script의 색·레이아웃, UI 책임 문서를 근거로 정리한다.

## 1.1 확인한 책임 원본과 실제 파일

- `AGENTS.md`
- `docs/BASE_RULES_VERSION.md`
- `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- `README.md`, `START_HERE.md`
- `docs/01_GAME_DESIGN.md`
- `docs/02_COMBAT_RULES.md`
- `docs/03_CONTENT_CATALOG.md`
- `docs/05_COMBAT_POC_SPEC.md`
- `docs/07_COMBAT_UI_SPEC.md`
- `docs/08_TEST_CHECKLIST.md`
- `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- `docs/UX_UI_SYSTEM.md`
- `docs/decisions/2026-07-31_COMBAT_ROUTE_AND_CHAMPION_DECISION.md`
- `docs/decisions/2026-07-31_PROCEDURAL_DUEL_POOL_AND_ROUTE_DECISION.md`
- Issue `#13`
- `project.godot`
- `scenes/combat/combat_board_preview.tscn`
- `src/combat/combat_board_preview.gd`
- `src/combat/combat_board_preview_auto.gd`
- `src/combat/combat_resolution_engine*.gd`
- `src/combat/combat_ai_planner.gd`
- `scenes/ui/*.tscn`, `src/ui/*.gd`
- `data/combat/*.json`, `data/cards/*.json`
- `assets/ASSET_MANIFEST.json`

---

# 2. 프로젝트 핵심 경험

## 프로젝트 핵심 정의

| 항목 | 현재 정의 |
|---|---|
| 장르 | 1대1 무협 심리 전술 로그라이트 |
| 플랫폼 | PC |
| 예상 플레이 세션 | 데모 15~22분, 전체 회차 30~40분 |
| 플레이어 역할 | 여러 문파의 무공을 익히며 강호의 강자와 비무하는 강호낭인 |
| 핵심 판타지 | 상대의 숨은 수를 읽고 미리 준비한 계획으로 행동을 끊는 무인 |
| 핵심 감정 | 긴장, 추론, 계획 확정의 결단, 합을 이긴 납득감, 실패 원인을 깨닫는 학습감 |
| 주요 선택 | 3/3/4 행동 배치, 거리·방향·대상, 무공 구성, 경로·노드·다음 상대 |
| 주요 고민 | 상대의 후보 행동을 얼마나 견딜 계획인가, 현재 자원을 어디에 걸 것인가, 회복과 성장·정보 중 무엇을 택할 것인가 |
| 주요 보상 | 새로운 파훼 선택지, 무공 성장, 다음 상대 정보, 합·중단 성공의 인과 이해 |
| 기억에 남아야 할 장면 | 공개 순간 서로의 수가 겹치고 순차 합·중단으로 후속타가 무너지는 장면 |
| 대표 세일즈포인트 | `보이지 않는 상대의 수를 읽고, 준비한 계획으로 꺾는다.` |
| 상징 요소 | 10칸 전장, 3/3/4 슬롯, 수묵과 금빛, 합·중단 표식 |
| 차별점 | 덱·손패가 아니라 항상 접근 가능한 행동과 성장한 무공을 비공개 동시 계획에 배치함 |

## 핵심 플레이 루프

```text
회차 시작
→ 시작 무공 선택
→ 주요 비무 후보·경로 확인
→ 노드 2개 선택·해결
→ 다음 상대 정보와 현재 상태 확인
→ 상대 의도 가설 기록
→ 3수/3수/4수 계획
→ 비공개 계획 확정
→ 거리·합·방어·회피·중단 해결
→ 결정적 원인 복기
→ 승리·패배 처리
→ 보상·성장 또는 재도전
→ 다음 경로
```

## 화면 설계 원칙

1. 한 화면은 현재 상황·중요 선택·결과·다음 동기 중 하나 이상을 분명히 담당한다.
2. 플레이어에게 상대의 정답 계획을 보여 주지 않되, 공개 상태·전조·거리·자원·규칙은 숨기지 않는다.
3. UI는 판정을 재계산하지 않고 도메인 상태와 결과 View Data를 표현한다.
4. 색·모션·음향을 줄이거나 꺼도 핵심 원인이 텍스트·아이콘·형태로 남아야 한다.
5. 실행 전 선택은 되돌릴 수 있고, 실행 후 결과는 되돌리지 않고 복기한다.
6. 경로의 무작위성은 `run_seed`로 재현 가능하며, 학습 역할과 안전장치는 유지한다.

---

# 3. 현재 시각 방향

## 3.1 확정·실제 구현

- 수묵 기반 무협 분위기.
- 석양·세피아·먹색·무채색을 기본으로 제한적인 적색과 금빛 강조 사용.
- 배경은 10칸 전장과 캐릭터 판독을 방해하지 않도록 저대비로 유지.
- UI 패널은 짙은 갈색·흑색 반투명 바탕, 금빛 테두리, 종이색 텍스트를 사용.
- 전투 캐릭터는 필드 SD가 아니라 전장용 전신 원화 기반 현재 자산을 사용.
- 플레이어·상대 상태 패널에는 반신 초상 자산이 존재.
- 절초는 먹 번짐과 금빛 VFX 계열을 사용.
- 핵심 정보는 텍스트·도형 폴백을 반드시 유지.

## 3.2 개선 제안

| 영역 | 제안 |
|---|---|
| 화면 비율 | 16:10 현재 viewport를 유지하되 16:9와 4:3 안전영역에서도 핵심 UI가 성립하도록 Container 기반 재배치 |
| 컬러 | 배경 먹색/세피아, 중립 정보 종이색, 확정·승리 금빛, 위험 탁한 적색, 선택 청회색을 역할 토큰으로 고정 |
| 폰트 | 제목·이명은 장식 서체 후보, 본문·수치·로그는 고가독성 한국어 UI 서체로 분리 |
| 아이콘 | 합·방어도·회피·필중·중단·강건은 색이 없어도 구별되는 실루엣 |
| 패널 | 얇은 금선과 종이 질감은 유지하되 장식이 텍스트 영역을 침범하지 않음 |
| 전환 | 먹 번짐·붓 획 wipe를 사용하되 입력 잠금과 Scene 준비 완료를 기준으로 종료 |
| 모션 | 정상·빠른 재생·모션 감소 세 모드가 동일한 판정 로그를 공유 |

## 3.3 확인 필요

- 메인 화면의 최종 키아트.
- 각 비무 후보 15명의 전장 원화·초상 제작 범위.
- 무공서·문파별 배지의 최종 스타일.
- 폰트 라이선스와 실제 렌더 품질.
- 16:9를 최종 기준 해상도로 전환할지, 현재 1440×900을 기준으로 유지할지.

---

# 4. 현재 화면 및 UI 구현 현황

## 4.1 실제 시작 구조

현재 `project.godot`은 `combat_board_preview.tscn`을 직접 시작한다. Main Menu, App Root, Run Map, Reward Screen을 거치는 제품 흐름은 확인되지 않았다.

`combat_board_preview.tscn`은 루트 `Control`과 `combat_board_preview_auto.gd`만 선언하고, 실제 전투 배경·HUD·카드·슬롯·로그·가설·복기·버튼은 `combat_board_preview.gd`가 런타임에 생성한다.

## 4.2 실제 구성요소 매핑

| 화면·상황 | 기존 Scene | 기존 Script | 기존 데이터 | 분류 | 주요 위험 |
|---|---|---|---|---|---|
| 전투 전체 | `combat_board_preview.tscn` | `combat_board_preview.gd`, `_auto.gd` | `combat_board_poc.json` | 기존 구조 확장 | 단일 Script가 조립·입력·레이아웃·연출·오디오·재시작을 과도하게 소유 |
| 10칸 전장 | `combat_board_tile.tscn`, `battle_background.tscn` | 대응 Script | 전장 JSON·Asset Manifest | 재사용 가능 | 신규 거리·노드 상태와 표시 계약 정합화 필요 |
| 전투 캐릭터 | `combat_character_placeholder.tscn` | placeholder Script | Asset Manifest | 교체·확장 필요 | 후보 15명 제작량, 애니메이션과 판정 동기화 |
| 상단 HUD | `top_combat_hud.tscn` | `top_combat_hud.gd` | `combat_hud_preview.json` | 재사용 가능 | 최신 방어도 비소모 계약과 구형 표시 차이 |
| 3/3/4 슬롯 | `action_timing_panel.tscn` | `action_timing_panel.gd` | action timing JSON | 재사용 핵심 | 전체 10칸을 유지하면서 현재 묶음만 편집 가능해야 함 |
| 행동 선택 | `basic_card_tray.tscn` | `basic_card_tray.gd`, `card_catalog.gd` | `basic_cards.json` | 재사용·확장 | 시작 무공·해금 기술까지 합칠 별도 View Data 필요 |
| 카드 상세 | `card_detail_panel.tscn` | 대응 Script | 카드 JSON | 재사용 가능 | 긴 효과·비교 표시·게임패드 복귀 검증 필요 |
| 상대 가설 | `opponent_hypothesis_panel.tscn` | 대응 Script | `combat_hypothesis_poc.json` | 재사용·확장 | 후보별 전조와 행로 정보 연결 필요 |
| 전투 로그 | `combat_log_panel.tscn` | 대응 Script | log preview JSON | 재사용 가능 | 최신 순차 연격·방어도 사건 어휘 정합화 필요 |
| 묶음 복기 | `combat_review_panel.tscn` | 대응 Script | runtime summary | 재사용 핵심 | 결투 종료·보상·재도전까지는 담당하지 않음 |
| 메인 화면 | 확인된 제품 Scene 없음 | 확인된 제품 Script 없음 | 없음 | 신규 필요 | 저장 없음·이어하기 가능 상태 분기 필요 |
| 시작 무공 선택 | 독립 Scene 확인 안 됨 | 없음 | planning 자료만 존재 | 신규 필요 | 6개 중 4개 선택과 중복·성급 초기화 |
| 강호행로 | 독립 Scene 확인 안 됨 | 없음 | 승인 planning JSON | 신규 필요 | 절차 생성·경로 가독성·seed 재현성 |
| 노드 사건 | 독립 Scene 확인 안 됨 | 없음 | 일부 기획 초안 | 신규 필요 | 결과 중복 적용·상대 전용 정보 오생성 |
| 무공 구성·자원 관리 | 독립 Scene 확인 안 됨 | 카드 UI 일부만 존재 | 카드 JSON·planning 성장 자료 | 기존 부품 활용 신규 화면 | 전통적 인벤토리로 오해하지 않도록 역할 명확화 |
| 결투 결과·보상 | 복기 Panel만 존재 | review Script | summary Dictionary | 기존 부품 활용 신규 화면 | 보상 1회 commit·재도전 snapshot·RunState 연결 |
| 저장·불러오기 | 제품용 관리자 확인 안 됨 | 없음 | 없음 | 신규 필요 | 전투 도중 저장 범위·버전 호환 |

## 4.3 현재 구조의 핵심 진단

### 그대로 재사용 가능

- `CombatResolutionEngine`의 도메인 판정 책임.
- `CombatAiPlanner`의 공개 상태 기반 AI 경계.
- 10칸 Tile, 상단 HUD, 3/3/4 슬롯, 카드 상세, 전투 로그, 상대 가설, 결정적 복기 UI 부품.
- JSON ID 기반 카드 카탈로그 로딩과 필수 필드 검증.
- 모션 감소·빠른 재생·즉시 완료의 결과 비개입 원칙.

### 확장해야 함

- `CombatBoardPreview`를 제품용 `CombatScreen`으로 감싸거나 분리.
- 최신 연격·방어도 계약에 맞는 View Data와 로그 사건.
- 무공·성급·해금 기술을 포함한 행동 팔레트.
- 전투 진입 전 `BattleDefinition`과 `RunState` 연결.
- 복기 뒤 `DuelResult`와 `RewardChoice` 연결.

### 신규 필요

- App Root와 화면 흐름 관리자.
- Run Session·Save Service.
- Main Menu, Run Setup, Route Map, Node Resolution, Duel Briefing, Martial Build, Duel Result/Reward, Run End Scene.
- planning JSON을 runtime JSON으로 변환하는 명시적 adapter.

---

# 5. 필수 기준 화면 4종

# SCREEN-01 메인 화면

## 현재 정의 상태

- 문서상 제품용 타이틀·이어하기 화면의 세부 정의는 확인되지 않음.
- 실제 main scene은 전투 PoC.
- 따라서 메인 화면은 `신규 제안`이며 구현된 것으로 간주하지 않음.

## 현재 확인안

```text
앱 실행
└─ combat_board_preview.tscn 직접 진입
```

## 개선 제안안

```text
┌────────────────────────────────────────────────────────────┐
│                 십보강호: 숨은 수의 비무                   │
│          수묵 키아트 / 10칸과 두 검객의 실루엣             │
│                                                            │
│                    [새 회차 시작]                           │
│                    [이어하기]  잠김/활성                    │
│                    [연습 비무]                              │
│                    [설정]                                   │
│                    [종료]                                   │
│                                                            │
│  좌하단: 버전·저장 상태          우하단: 입력 안내          │
└────────────────────────────────────────────────────────────┘
```

## 상태 변형

- 최초 실행: 이어하기 비활성, 새 회차 강조.
- 저장 없음: 비활성 이유 표시.
- 저장 있음: 현재 슬롯·상대·체력 요약.
- 저장 버전 불일치: 안전 복구·새 회차 선택.
- 전환 중: 버튼 잠금과 먹 번짐 전환.
- 튜토리얼 완료: 연습 비무 활성.

## Godot 제안

```text
MainMenuScreen (Control)
├─ BackgroundLayer
├─ TitleArt
├─ MenuButtons (VBoxContainer)
├─ ContinueSummaryPanel
├─ VersionAndSaveStatus
└─ InputHintBar
```

화면 자체는 별도 Scene, 저장 조회는 `SaveService`, 전환 요청은 `AppFlowController` Signal로 전달한다.

---

# SCREEN-02 비무 핵심 플레이 화면

## 현재 정의 상태

실제 구현이 존재하며 현재 프로젝트의 유일한 직접 시작 화면이다. 현재 레이아웃은 상단 양측 HUD, 중앙 10칸, 하단 3/3/4 슬롯과 기초 행동, 좌우 상세·로그 Overlay, 상대 가설, 복기 Panel로 구성된다.

## 현재 확인안

```text
┌─ 플레이어 상태 ─ 기세 ─ 라운드/묶음 ─ 기세 ─ 상대 상태 ┐
│  상대 의도 가설                 전조/결과                 로그 │
│                                                            │
│ 플레이어       1 2 3 4 5 6 7 8 9 10        상대            │
│                                                            │
│ [3수][3수][4수 행동 타임라인]             [진행]            │
│ [이동][보법][막기][회피][속공][강공][명상][태세]            │
└────────────────────────────────────────────────────────────┘
```

## 개선 제안안

```text
┌─ 상대 공개 전조/대표 위협 ─ 거리 ─ 라운드·현재 묶음 ──┐
│ 플레이어 상태·예상값                         상대 상태·전조 │
├───────────────────────────────────────────────────────────┤
│ 가설/행로정보   플레이어 ─ 10칸 전장 ─ 상대       접이식 로그 │
│                 방향·사거리·위협 범위 강조                  │
├───────────────────────────────────────────────────────────┤
│ 1 2 3 | 4 5 6 | 7 8 9 10  전체 타임라인                     │
│ 현재 묶음 편집 / 이전 결과 / 이후 잠김                       │
├───────────────────────────────────────────────────────────┤
│ 기초 행동 + 해금 무공 + 절초    상세 비교    [계획 확정]       │
└───────────────────────────────────────────────────────────┘
```

## 상태 변형

- 전투 진입·브리핑.
- 계획 가능.
- 카드 선택.
- 대상 지정.
- 자원 부족.
- 슬롯 충돌.
- 계획 확정.
- 판정·연출 중 입력 잠금.
- 결정적 복기.
- 전투 종료.
- 빠른 재생·모션 감소·무음.

---

# SCREEN-03 무공 구성·보유 자원 관리 화면

## 현재 정의 상태

전통적 인벤토리·덱·손패는 프로젝트 코어에 없다. 이 프로젝트에서 대응하는 화면은 **현재 무공 성장·해금 기술·전투 자원·일회성 대비 효과를 확인하고 다음 비무의 행동 선택지를 이해하는 화면**이다.

기초 행동 Tray와 카드 상세은 실제 존재하지만 독립 관리 화면은 확인되지 않았다.

## 현재 확인안

```text
전투 하단 BasicCardTray
→ 카드 선택 또는 hover
→ CardDetailPanel
```

## 개선 제안안

```text
┌─ 현재 무학 구성 ─────────────────── 다음 상대 요약 ───────┐
│ [문파/무공 목록]     [선택 무공 상세]       [현재 자원]     │
│ 3성/5성/해금 기술     슬롯·비용·거리·타격    체력/금전/수련 │
│ 집중/분산 상태        다음 성급 변화          의료/대비효과  │
│                                                            │
│ [사용 가능 행동 미리보기] [다음 전투 영향] [경로로 복귀]    │
└────────────────────────────────────────────────────────────┘
```

## 상태 변형

- 시작 무공 6개 중 4개 선택.
- 일반 조회.
- 수련 포인트 배분.
- 기술 신규 해금.
- 수련 부족.
- 최대 10성.
- 다음 상대 정보와 비교.
- 일회성 대비 효과 존재.

## 구현 기준

- 독립 `MartialBuildScreen` 또는 Route 화면의 재사용 Overlay.
- 수치 변경은 `RunSession` 요청을 통해서만 수행.
- `CardViewData`는 표시 전용이며 피해·합 계산을 하지 않음.

---

# SCREEN-04 비무 결과·복기·보상 화면

## 현재 정의 상태

`CombatReviewPanel`은 실제 존재하며 내 가설, 상대 실제 행동, 결정적 원인, 전후 거리, 다음 검토를 표시한다. 다만 현재 terminal 상태에서는 개발용 `결전 다시 시작`으로 연결되며, 제품용 승리 보상·RunState commit·유료 재도전·경로 복귀 화면은 확인되지 않았다.

## 현재 확인안

```text
[결정적 복기]
내 가설
상대 실제 행동
결정적 원인
전후 거리
다음 검토
[상세 기록] [다음 묶음/결전 다시 시작]
```

## 개선 제안안

```text
┌─ 비무 결과: 승리 / 패배 / 무승부 ───────────────────────┐
│ 결정적 장면 요약        성과 등급·공개 과제                │
│ [내 가설→실제 행동→합/중단 원인]                          │
├───────────────────────────────────────────────────────────┤
│ 승리: 보상 3개 비교 → 하나 선택 → 성장 반영                │
│ 패배: 원인 요약 → 재도전 비용 1/2/3 → 재도전/회차 포기      │
├───────────────────────────────────────────────────────────┤
│ [상세 전투 기록] [무공 구성 확인] [다음 경로/재도전]         │
└───────────────────────────────────────────────────────────┘
```

## 상태 변형

- 묶음 복기.
- 승리.
- 패배.
- 무승부.
- 공개 과제 달성/미달성.
- 신규 기술 해금.
- 재도전 가능/재화 부족.
- 보상 선택 완료.
- commit 중 입력 잠금.

---

# 6. 대표 플레이 상황 전체 목록과 우선순위

| ID | 상황 | 유형 | 빈도 | 핵심 재미 | 감정 중요 | 구현 위험 | 차별성 | 우선순위 |
|---|---|---|---:|---:|---:|---:|---:|---|
| `SIT-001` | 타이틀에서 새 회차·이어하기 선택 | 진입 | 낮음 | 2 | 3 | 2 | 1 | P0 |
| `SIT-002` | 시작 무공 6개 중 4개 선택 | 준비·성장 | 회차당 1 | 4 | 3 | 3 | 4 | P0 |
| `SIT-003` | 다음 상대 2명과 노드 경로 비교 | 선택·장기 진행 | 비무 사이 | 5 | 4 | 5 | 5 | P0 |
| `SIT-004` | 휴식·수련·정보·사건 노드 해결 | 선택·보상·위험 | 구간당 2 | 4 | 3 | 4 | 4 | P0 |
| `SIT-005` | 다음 상대 공개 정보와 대비 확인 | 준비 | 비무 전 | 5 | 4 | 3 | 5 | P0 |
| `SIT-006` | 상대 가설을 세우고 3/3/4 계획 | 핵심 플레이 | 매우 높음 | 5 | 5 | 5 | 5 | P0 |
| `SIT-007` | 계획 공개 후 합·방어·중단 해결 | 전투·위험 | 매우 높음 | 5 | 5 | 5 | 5 | P0 |
| `SIT-008` | 결정적 원인 복기와 다음 묶음 수정 | 복기·학습 | 묶음마다 | 5 | 5 | 4 | 5 | P0 |
| `SIT-009` | 승리 보상 선택과 RunState 반영 | 보상·성장 | 비무 후 | 4 | 4 | 5 | 3 | P0 |
| `SIT-010` | 패배 후 유료 재도전 또는 회차 포기 | 실패·복구 | 조건부 | 5 | 5 | 5 | 4 | P0 |
| `SIT-011` | 현재 무공·성급·해금 기술 상세 조회 | 성장·정보 | 중간 | 3 | 2 | 3 | 3 | P1 |
| `SIT-012` | 설정·접근성·일시정지 | 편의 | 중간 | 1 | 2 | 3 | 1 | P1 |
| `SIT-013` | 회차 저장·이어하기 | 장기 진행 | 중간 | 2 | 3 | 5 | 1 | P1 |
| `SIT-014` | 5전 데모 완료·요약 | 승리·복귀 | 회차당 1 | 3 | 5 | 3 | 3 | P1 |
| `SIT-015` | 용어·상태·합 규칙 사전 | 학습 | 필요 시 | 2 | 2 | 2 | 2 | P2 |
| `SIT-016` | 천하제일인·등록 전투 구성 | 장기 확장 | 후반 | 5 | 5 | 5 | 5 | P3/HOLD |

---

# 7. P0 상황별 상세 인게임 화면 구현 명세

# [SIT-001] 타이틀에서 새 회차·이어하기 선택

## A. 상황 개요

- 발생 이유: 앱 실행 후 플레이 진입점을 제공.
- 목표: 새 회차, 이어하기, 연습 비무 중 가능한 진입 선택.
- 알고 있는 정보: 게임 제목과 저장 슬롯 요약.
- 모르는 정보: 실제 첫 상대와 절차 경로.
- 위험: 잘못된 저장 덮어쓰기, 전환 중 중복 입력.
- 기대 보상: 즉시 회차 시작.
- 감정: 정돈된 기대감.
- 핵심 선택: 새 회차 또는 이어하기.
- 다음 연결: `RUN_SETUP` 또는 `ROUTE_MAP`/`COMBAT_PRACTICE`.

## B. 근거와 가정

- 확정: PC, PLAN 단계, 데모 5전.
- 실제 구현: 앱 실행 시 전투 PoC 직행.
- 제안: 제품용 Main Menu 신규.
- 확인 필요: 세이브 슬롯 개수, 연습 비무 제공 시점.

## C. 진입 조건

- 이전 상태: `BOOT`.
- Trigger: App Root 초기화 완료.
- 필요 데이터: Profile summary, suspended run summary, settings.
- 진입 불가: 데이터 migration 또는 치명적 로드 오류 중.
- 중복 방지: 전환 요청 후 전체 버튼 잠금.

## D. 화면 목적

1. 새 회차 시작 가능 여부.
2. 이어하기 상태와 위치.
3. 연습·설정·종료.
4. 저장·버전 오류 설명.

## E. 예상 인게임 화면

앞의 SCREEN-01 제안안을 사용한다. 첫 3초에는 제목, 새 회차, 이어하기 상태만 보여야 한다.

## F. 화면 구성요소

| 요소 | 역할 | 표시 | 숨김 | 입력 | 우선순위 |
|---|---|---|---|---|---:|
| TitleArt | 첫인상 | 항상 | 없음 | 아니오 | 2 |
| NewRunButton | 신규 회차 | 항상 | 없음 | 예 | 1 |
| ContinueButton | suspended run 복귀 | 저장 유효 | 없음 | 예 | 1 |
| ContinueSummary | 슬롯·상대·체력 요약 | 저장 유효 | 저장 없음 | 아니오 | 2 |
| ErrorPanel | migration·손상 설명 | 오류 | 정상 | 선택 | 1 |
| Settings/Quit | 환경 설정·종료 | 항상 | 전환 중 | 예 | 3 |

## G. 플레이어 입력

| 입력 | 조건 | 반응 | 피드백 | 제한 |
|---|---|---|---|---|
| 방향/포인터 선택 | 전환 중 아님 | focus 이동 | 금빛 outline | 비활성 항목 건너뜀 |
| 확인 | 활성 버튼 | 전환 요청 | SFX·버튼 잠금 | 중복 처리 금지 |
| 취소 | 설정·오류 Modal | 이전 focus 복귀 | 닫힘 연출 | Main root에서는 앱 종료 확인 |

키보드·마우스·게임패드만 대상으로 한다.

## H. 상황 진행 흐름

```text
BOOT 자동
→ Profile/Save summary 로드
→ MAIN_MENU 입력 허용
→ 버튼 선택
→ 조건 재검증
→ 화면 입력 잠금
→ 전환 연출
→ 다음 Screen 준비 확인
→ MAIN_MENU 종료
```

저장은 새 회차 생성 직후 체크포인트에서 수행한다.

## I. 시스템 반응

| 행동 | 조건 | 즉시 반응 | 데이터 변화 | 장기 영향 | 다음 상태 |
|---|---|---|---|---|---|
| 새 회차 | 가능 | 확인 Modal 선택적 | RunState 신규 생성 | 새 seed | RUN_SETUP |
| 이어하기 | 유효 저장 | summary 재검증 | saved RunState 복원 | 같은 seed 유지 | 저장된 상태 |
| 이어하기 | 저장 손상 | 차단 | 없음 | 복구/폐기 선택 | MAIN_MENU |
| 연속 확인 | 전환 잠금 | 무시+선택적 알림 | 없음 | 없음 | TRANSITION |

## J. 필요한 시스템

| 시스템 | 역할 | 입력 | 출력 | 연결 |
|---|---|---|---|---|
| SaveService | profile/run summary | save file | LoadResult | Main, RunSession |
| RunSession | 신규·복원 | seed/save | RunState | Route, Combat |
| AppFlowController | 화면 전환 | ScreenRequest | transition result | 모든 Screen |
| SettingsService | 입력·오디오·접근성 | config | settings snapshot | UI/Audio |

## K. Godot 구현 구조

```text
MainMenuScreen (Control)
├─ BackgroundLayer (TextureRect)
├─ SafeArea (MarginContainer)
│  └─ MainColumn (VBoxContainer)
│     ├─ Logo
│     ├─ MenuButtons
│     └─ ContinueSummaryPanel
├─ StatusBar
└─ ConfirmationModalLayer
```

UI는 Save 파일을 직접 읽지 않고 `SaveService.summary_ready` 결과만 표시한다.

## L. Scene 분리 기준

완전 별도 Screen Scene을 권장한다. 설정·확인창은 재사용 Modal Scene.

## M. Signal 및 상태 전환

- `new_run_requested`
- `continue_requested`
- `settings_requested`
- `quit_requested`
- `screen_transition_requested`

```text
ENTER → LOADING_SUMMARY → READY → TRANSITIONING → EXIT
```

## N. 데이터 구조

| 데이터 | 필드 | 위치 | 변경 주체 | 저장 |
|---|---|---|---|---|
| ProfileSummary | currency, unlocks, tutorial flags | profile save | SaveService | 예 |
| SuspendedRunSummary | run_id, slot, opponent, hp, timestamp | run save | SaveService | 예 |
| MainMenuViewData | button states, error text | memory | presenter | 아니오 |

## O. 화면 전환 시 유지 데이터

- 설정·프로필: 반드시 유지, save.
- RunState: 신규 생성 또는 복원.
- Main focus: Scene 종료 시 초기화 가능.
- BGM 재생 위치: Main 내부 전환이면 유지, Run 시작 시 crossfade.

## P. 연출 명세

수묵 배경의 미세한 움직임, 금빛 focus, 먹 번짐 전환. 모션 감소 시 fade만 사용.

## Q. 필요한 애셋

| 애셋 | 용도 | 변형 | 우선순위 | 임시 대체 |
|---|---|---|---|---|
| Main key art | 첫인상 | 16:9/16:10 safe crop | P1 | 기존 전투 배경 가능 |
| Logo | 제목 | 고해상도/단색 | P1 | 텍스트 가능 |
| Button frame | 공통 UI | normal/focus/disabled | P0 | StyleBox 가능 |
| Main BGM | 분위기 | loop | P2 | 무음 가능 |

## R. 예외 상황

- 저장 손상: 원본 백업, 안전 폐기 선택.
- migration 실패: 오류 코드와 새 회차 제공.
- 전환 중 입력: InputBlocker.
- Window resize: Container 재배치, focus 유지.

## S. 완료 기준

- 저장 유무·오류에 따라 버튼 상태가 정확함.
- 새 회차/이어하기가 한 번만 실행됨.
- 입력 3종으로 핵심 메뉴 완주.
- 지원 해상도에서 버튼과 summary가 잘리지 않음.

## T. 테스트 체크리스트

- [ ] 저장 없음 최초 실행.
- [ ] 정상 suspended run 이어하기.
- [ ] 손상·구버전 저장.
- [ ] 확인 버튼 연타.
- [ ] 전환 중 창 크기 변경.
- [ ] 키보드·마우스·게임패드 focus.

---

# [SIT-002] 시작 무공 6개 중 4개 선택

## A. 상황 개요

플레이어는 회차의 초기 파훼 수단을 결정한다. 피해 수치보다 거리·슬롯·자원·대응 방식이 다른 6개 후보 중 4개를 선택한다.

## B. 근거와 가정

- 확정: 시작 후보 6개 중 4개, 3성 시작.
- 실제 구현: 기초 행동과 절초 카드 UI는 존재하지만 시작 무공 선택 Screen은 확인되지 않음.
- 제안: `RunSetupScreen` 신규, 기존 Card 상세 패턴 재사용.

## C. 진입 조건

- 신규 RunState 생성 완료.
- 선택 가능한 시작 무공 후보 6개가 유효.
- 이미 선택 완료한 run은 중복 진입 금지.

## D. 화면 목적

1. 4개 선택 제한.
2. 무공마다 바뀌는 거리·슬롯·자원 선택지.
3. 선택 조합의 중복 역할 경고.
4. 회차 시작 확정.

## E. 텍스트 와이어프레임

```text
┌─ 시작 무공 선택 0/4 ─────────────── 선택 조합 요약 ─────┐
│ [무공1][무공2][무공3]       거리/대응/공격 역할 분포      │
│ [무공4][무공5][무공6]       기력·내력 예상 부담           │
│                                                            │
│ 선택 무공 상세: 해금 기술·성장 방향·대표 절초              │
│                                  [초기화] [회차 시작]       │
└────────────────────────────────────────────────────────────┘
```

## F. 구성요소

후보 Grid, 상세 Panel, 역할 분포, 0/4 Counter, 확정 Button, 조건 부족 Message.

## G. 입력

선택 토글, 상세 보기, 전체 초기화, 확정. 4개 초과는 입력을 무시하지 않고 교체 안내.

## H. 흐름

```text
후보 로드 → 첫 후보 focus → 선택/해제 반복 → 4개 충족
→ 조합 검증 → 확정 → RunState에 3성 4개 기록 → seed 기반 첫 상대 생성
```

## I. 시스템 반응

- 4개 미만: 확정 비활성, 남은 수 표시.
- 4개 초과 시도: 현재 선택 하나 해제 안내.
- 데이터 누락: 해당 후보 비활성, 전체 6개 미만이면 진입 차단.
- 확정 후: 같은 화면에서 재확정 금지.

## J. 필요한 시스템

ContentRepository, RunSetupService, RunSession, CardViewDataBuilder, SaveService.

## K. Godot 구조

```text
RunSetupScreen
├─ Header
├─ CandidateGrid
│  └─ MartialCandidateCard ×6
├─ MartialDetailPanel
├─ SelectionSummaryPanel
└─ FooterActions
```

`MartialCandidateCard`는 재사용 Scene. 도메인 변경은 `RunSetupService.request_selection()`으로 수행.

## L. Scene 분리

별도 Screen 권장. 상세은 재사용 Panel.

## M. 상태 전환

`ENTER → SELECTING → VALIDATING → COMMITTING → ROUTE_GENERATING → EXIT`.

Signals: `candidate_toggled`, `selection_changed`, `setup_confirmed`, `setup_failed`.

## N. 데이터

| 데이터 | 필드 | 관리 |
|---|---|---|
| MartialDefinition | id, faction, role tags, initial star, unlocks | runtime JSON |
| RunSetupSelection | selected_ids[4] | memory/RunState |
| CardViewData | cost, slots, range, effects | presenter |

Google Sheets는 authoring, runtime은 검증된 JSON adapter를 사용한다.

## O. 유지 데이터

run_id, run_seed, 선택 무공, 3성, profile unlock. 화면 hover 상태는 초기화.

## P. 연출

선택 시 붓 원형 표식, 역할 tag 변화. 확정 시 선택 4개가 중앙으로 모이는 연출은 P2.

## Q. 애셋

무공 아이콘 128×128 source 권장, 상세 카드 삽화 768×1024 source 권장, 문파 배지 128×128. P0는 기존 카드 frame과 텍스트로 대체 가능.

## R. 예외

중복 ID, locked 후보, save 중 종료, confirm 연타, 긴 한국어 설명, gamepad grid focus.

## S. 완료 기준

항상 정확히 4개가 RunState에 한 번만 저장되고 첫 비무 생성에 사용된다.

## T. 테스트

- [ ] 0~3개 확정 차단.
- [ ] 4개 정상.
- [ ] 5번째 선택 처리.
- [ ] 저장 후 재진입.
- [ ] 데이터 1개 누락.
- [ ] 모든 입력 방식·해상도.

---

# [SIT-003] 다음 상대 2명과 강호행로 비교

## A. 상황 개요

비무 승리 후 다음 슬롯 후보 3명 중 제시된 2명과 각 경로의 노드 유형·위험·보상을 비교해 경로와 상대를 함께 선택한다.

## B. 근거와 가정

- 확정: 첫 비무는 3명 중 1명 seed 선정, 이후 3명 중 2명 제시.
- 확정: 구간당 노드 2개, 각 층 후보 2~3개, seed 재현.
- 실제 구현: Route Scene 확인되지 않음.
- 제안: `RouteMapScreen`, `RunRouteGenerator`, `RouteGraphData` 신규.

## C. 진입 조건

- RunState 활성.
- 직전 비무 결과와 보상 commit 완료.
- 다음 슬롯이 존재.
- route graph가 현재 `run_seed/slot_id/gap_index`에서 생성·검증됨.

## D. 화면 목적

1. 다음 상대 후보 2명.
2. 각 후보 대표 위협·난이도·공개 정보.
3. 노드 2개 경로의 기회비용.
4. 현재 체력·무공 구성과 경로 적합성.

## E. 와이어프레임

```text
┌─ 강호행로 · 슬롯 2 ───── 현재 체력/금전/무공 요약 ──────┐
│        [1차 노드층]           [2차 노드층]                 │
│   ○휴식 ───── ○정보 ─────────── [묵진]                    │
│     ╲          ╱                                           │
│      ○수련 ─ ○대비 ──────────── [위청람]                  │
│   ○사건 ───── ○회복                                        │
│                                                            │
│ 선택 경로 요약: 위험 / 예상 보상 / 상대 대표 위협          │
│                                    [경로 확정]              │
└────────────────────────────────────────────────────────────┘
```

## F. 구성요소

OpponentDestinationCard, RouteNodeButton, EdgeLayer, CurrentRunSummary, RouteComparisonPanel, ConfirmButton, Legend.

## G. 입력

노드 focus/hover, 경로 미리보기, 상대 상세, 경로 확정, 무공 구성 Overlay 열기, 취소 불가 시 설명.

## H. 흐름

```text
GraphData 수신 → 노드·연결선 표시 → 후보 상대 공개
→ 노드 또는 상대 선택 → 도달 가능 경로 강조
→ 비교 Panel 갱신 → 경로 확정 → 첫 노드 진입
```

## I. 시스템 반응

- 낮은 체력: 접근 가능한 회복 경로 보장 여부 검증.
- 죽은 경로: 생성 단계 실패로 graph 재생성 또는 명시적 오류.
- 미제시 상대 정보 노드: graph validation 실패.
- 선택한 노드가 연결되지 않음: confirm 차단.
- 동일 seed 재로드: 동일 graph 복원.

## J. 시스템

RunRouteGenerator, RouteValidator, RunSession, ContentRepository, RoutePresenter, SaveService.

## K. Godot 구조

```text
RouteMapScreen
├─ Background
├─ HeaderHUD
├─ GraphViewport (Control)
│  ├─ EdgeLayer (Control custom draw)
│  ├─ NodeLayer
│  │  └─ RouteNodeView ×N
│  └─ OpponentLayer
│     └─ OpponentDestinationCard ×2
├─ RouteComparisonPanel
├─ MartialBuildOverlayHost
└─ FooterActions
```

SubViewport는 필요하지 않다. Control 좌표와 custom draw로 연결선을 그린다.

## L. Scene 분리

완전 별도 Screen. 상대 상세·무공 구성은 Overlay.

## M. 상태 전환

`ENTER → DISPLAYING → PREVIEWING_ROUTE → CONFIRMING → NODE_TRANSITION`.

Signals: `route_node_focused`, `route_preview_changed`, `route_committed`, `build_overlay_requested`.

## N. 데이터

| 데이터 | 주요 필드 | 저장 |
|---|---|---|
| RouteGraphData | graph_id, seed, layers, nodes, edges, opponent destinations | RunState/save |
| RouteNodeDefinition | id, type, risk, reward category, conditions | runtime JSON |
| OpponentOffer | candidate_id, public threat, difficulty, destination | RunState/save |

## O. 유지 데이터

선택 전 graph 전체, 현재 노드, 방문 history, offered opponents, HP·money·martial progression, BGM position. 화면 카메라 없음 또는 scroll offset는 session-only.

## P. 연출

노드 선택 시 먹선이 진해지고 선택 경로만 금빛. 전환은 선택 노드로 붓길이 이어진 뒤 fade.

## Q. 애셋

지도 배경 2560×1440 master 권장, 노드 아이콘 128×128, 상대 초상 1024×1024 또는 1024×1536, 연결선은 shader 없이 custom draw 가능.

## R. 예외

graph generation 실패, overlapping nodes, 해상도에서 선 교차, 저장 후 후보 변경, opponent content 누락, confirm 연타.

## S. 완료 기준

- 2명의 제시 상대 모두 도달 가능.
- 각 경로 정확히 노드 2개 방문.
- seed 저장·로드 후 동일.
- 위험·보상·상대가 선택 전 비교 가능.

## T. 테스트

- [ ] 100개 seed graph invariant.
- [ ] 낮은 체력 회복 보장.
- [ ] 같은 유형 3연속 방지.
- [ ] 미제시 상대 정보 배제.
- [ ] 저장·로드 동일 graph.
- [ ] 1280×720~2560×1440 배치.

---

# [SIT-004] 휴식·수련·정보·짧은 사건 노드 해결

## A. 상황 개요

플레이어는 선택한 노드에서 1~2개의 명확한 선택을 하고 현재 상태 또는 다음 비무 준비를 바꾼다.

## B. 근거와 가정

- 확정: 데모 노드 유형 4종, 평균 15~45초 목표.
- 실제 구현: Node Resolution Scene 확인되지 않음.
- 제안: 공통 `RouteNodeScreen`과 타입별 resolver 분리.

## C. 진입 조건

committed route의 현재 node, 아직 미해결, 조건·비용 snapshot 존재.

## D. 화면 목적

현재 상황, 선택 비용, 즉시 결과, 다음 상대와의 관계를 한 화면에서 전달.

## E. 와이어프레임

```text
┌─ 노드명 / 유형 / 위험도 ───────── 다음 상대: 위청람 ─────┐
│ 배경·짧은 상황 삽화                                         │
│ 상황 설명 2~4문장                                            │
│ [선택 A: 비용 → 보상]                                        │
│ [선택 B: 안전 → 정보]                                        │
│ 현재 체력·금전·수련 변화 미리보기                            │
└─────────────────────────────────────────────────────────────┘
```

## F. 구성요소

NodeTitle, Type/RiskBadge, Illustration, BodyText, ChoiceList, CostPreview, ResultFeedback, Continue.

## G. 입력

선택, 확인, 취소 가능한 경우 이전 focus. 경로 확정 뒤 노드 이탈은 일반적으로 불가.

## H. 흐름

```text
NodeDefinition 로드 → 조건 평가 → 선택지 표시
→ 선택 → 현재 상태 재검증 → resolve 요청
→ 결과 원자적 적용 → 결과 피드백 → node completed 기록
→ 다음 노드/비무 이동
```

## I. 시스템 반응

- 비용 부족: 선택 비활성+이유.
- 사건 피해가 HP 1 미만: clamp 또는 선택 차단 계약 적용.
- 선택 중 상태 변경: commit 직전 재검증.
- 중복 입력: resolution token으로 1회 적용.

## J. 시스템

RouteNodeResolver, ConditionEvaluator, RewardApplier, RunSession, SaveService, AudioDirector.

## K. Godot 구조

```text
RouteNodeScreen
├─ BackgroundLayer
├─ NodeContentPanel
│  ├─ Header
│  ├─ Illustration
│  ├─ Description
│  ├─ ChoiceList
│  └─ ResultPanel
└─ RunSummaryStrip
```

노드 타입별 Scene을 복제하지 않고 Definition과 선택 Template을 바꾼다. 특별 연출만 child Scene으로 확장.

## L. Scene 분리

공통 별도 Screen 권장. 단순 정보 확인은 RouteMap 위 Modal도 가능하지만 P0는 상태·저장 경계를 명확히 하기 위해 Screen 전환이 안전하다.

## M. 상태 전환

`ENTER → CHOOSING → VALIDATING → RESOLVING → SHOWING_RESULT → EXIT`.

## N. 데이터

NodeDefinition, ChoiceDefinition, Condition, Cost, Effect, NodeResolutionRecord. Authoring Sheet → planning JSON → runtime adapter.

## O. 유지 데이터

RunState 전체, selected route, next opponent, node completion, one-shot flags. Result animation 상태는 초기화.

## P. 연출

휴식은 호흡·따뜻한 색, 수련은 붓 획, 정보는 문서·소문 표식, 사건은 위험색. 판정 수치는 연출 전에 commit하고 결과 텍스트로 고정.

## Q. 애셋

노드 배경 1920×1080 source 또는 재사용 배경+vignette, 타입 아이콘, 선택 SFX. P0는 배경 4종과 공통 패널로 대체 가능.

## R. 예외

데이터 누락, 선택지 0개, 비용 부족 전부, 결과 중 앱 종료, one-shot 중복, audio 중복.

## S. 완료 기준

결과가 정확히 1회 적용되고 저장 후 재진입해도 반복되지 않으며 다음 상태가 정확하다.

## T. 테스트

정상·비용 부족·HP 1 경계·중복 입력·중간 종료·저장 복귀·모든 노드 유형.

---

# [SIT-005] 다음 상대 공개 정보와 비무 준비

## A. 상황 개요

경로 마지막 노드 뒤 플레이어는 상대 이름·이명·대표 위협·공개 전조·자신의 일회성 대비 효과를 확인하고 비무에 진입한다.

## B. 근거와 가정

- 확정: 상대의 정확한 계획은 숨기고 공개 상태·전조·대표 위협을 제공.
- 실제 구현: `OpponentHypothesisPanel`은 전투 내 가설 기록을 지원.
- 제안: `DuelBriefingScreen` 신규, 가설 Panel은 전투에서 유지.

## C. 진입 조건

두 노드 완료, opponent destination 확정, BattleDefinition 생성 가능.

## D. 화면 목적

1. 누구와 싸우는가.
2. 어떤 위협 범주를 조심하는가.
3. 행로에서 무엇을 준비했는가.
4. 현재 무공 구성으로 어떤 선택이 가능한가.

## E. 와이어프레임

```text
┌─ 주요 비무 슬롯 2 ──────────────────────────────────────┐
│ 상대 전신/초상  묵진 · 철벽승                            │
│ 대표 위협: 방어도·강건 뒤 강공                           │
│ 공개 전조 3종 / 공개 자원 / 선호 거리                    │
│ 행로 정보: 막기→태세→강공 후보 강화                      │
│ 내 준비: 체력+2, 첫 방어 초과 시 기세+1                  │
│ [무공 구성 확인]                         [비무 시작]      │
└──────────────────────────────────────────────────────────┘
```

## F. 구성요소

OpponentPortrait, Identity, ThreatSummary, TellList, RouteIntel, PrepEffects, PlayerSummary, StartButton.

## G. 입력

상세 용어, 무공 구성 Overlay, 비무 시작, 경로 확인 read-only.

## H. 흐름

BattleDefinition 로드 → 공개 정보 View Data → 준비 효과 검증 → 시작 확정 → pre-battle snapshot → Combat Scene.

## I. 반응

BattleDefinition 누락 시 시작 차단. 일회성 효과 대상 불일치 시 경고 후 제거하지 않고 감사 기록. 시작 연타는 snapshot 1개만 생성.

## J. 시스템

BattleFactory, RunSession, ContentRepository, CombatEntryService, SaveService.

## K. Godot 구조

`DuelBriefingScreen` 별도 Control; `OpponentProfilePanel`, `PrepEffectList`, `MartialBuildOverlay` 재사용.

## L. Scene 분리

별도 Screen 권장. 비무 화면 Overlay보다 로딩·snapshot·BGM 전환 경계가 명확하다.

## M. 상태

`ENTER → REVIEWING → PREPARING_SNAPSHOT → LOADING_COMBAT → EXIT`.

## N. 데이터

OpponentDefinition, BattleDefinition, PublicTellDefinition, PrepModifier, PreBattleSnapshot.

## O. 유지 데이터

RunState와 pre-battle snapshot, opponent seed, route intel. Briefing scroll/focus는 초기화 가능.

## P. 연출

상대 이명과 붓 서명, 전장 배경의 작은 preview. 과한 컷신은 P2.

## Q. 애셋

상대 초상·전신, 이명 서체, 대표 무기 아이콘. 후보마다 신규 시스템 VFX는 만들지 않음.

## R. 예외

상대 asset 없음은 실루엣 폴백, info 중복, 전투 load 실패, snapshot 실패.

## S. 완료 기준

비무 시작 전에 필요한 공개 정보와 준비 효과가 모두 설명되고 동일 BattleDefinition으로 전투가 생성됨.

## T. 테스트

각 슬롯 후보, 정보 노드 선택/미선택, asset missing, snapshot 복원, 연타.

---

# [SIT-006] 상대 가설을 세우고 3/3/4 계획

## A. 상황 개요

핵심 플레이 상황. 플레이어는 공개 상태와 전조를 보고 상대 의도 가설을 기록하고 현재 묶음의 모든 슬롯에 행동을 배치·대상 지정·자원 검증한 뒤 확정한다.

## B. 근거와 가정

- 확정: 3/3/4, 비공개 계획, 공개 상태 기반 AI.
- 실제 구현: `CombatBoardPreview`, `ActionTimingPanel`, `BasicCardTray`, `CardDetailPanel`, `OpponentHypothesisPanel`, `TopCombatHud`, targeting과 resource preview.
- 제안: 현재 부품 재사용, Controller/Presentation/Layout 책임 분리.

## C. 진입 조건

CombatState 생성, current bundle unresolved, presentation queue empty, combat not terminal.

## D. 화면 목적

1. 거리·자원·현재 묶음.
2. 상대 전조·대표 위협·가설.
3. 사용 가능한 행동 비교.
4. 슬롯·대상·비용 완성 여부.
5. 확정 전 불확실성과 위험.

## E. 화면

SCREEN-02 개선 제안 사용. 첫 3초에는 현재 묶음, 거리, 상대 전조, 양측 HP·자원, 행동 Tray가 보여야 한다.

## F. 구성요소

| 요소 | 역할 | 표시 조건 | 숨김 | 입력 |
|---|---|---|---|---|
| TopCombatHUD | 양측 상태 | 항상 | 없음 | 일부 tooltip |
| Board | 위치·거리·대상 | 항상 | 없음 | 대상 지정 |
| HypothesisPanel | 의도 기록 | planning | resolving | 선택 |
| TimingPanel | 3/3/4 계획 | 항상 | 없음 | 배치·삭제 |
| ActionPalette | 기초·무공·절초 | planning | resolving | 선택 |
| CardDetail | L1~L3 정보 | focus/selected | 해제 | pin/close |
| ProgressButton | 계획 확정 | bundle complete | terminal | 확인 |
| ErrorFeedback | 자원·대상·충돌 | 오류 | 정상 | 없음 |

## G. 입력

카드 선택 → 자동 또는 직접 슬롯 배치 → 이동 칸/공격 방향 지정 → 배치 취소·교체 → 가설 선택 → 계획 확정. 게임패드 focus는 카드→슬롯→대상→확정의 예측 가능한 순서.

## H. 흐름

```text
PLANNING 진입
→ 공개 상태·전조 갱신
→ 가설 선택 선택적
→ 행동 선택
→ 슬롯 배치
→ 대상 지정
→ 자원 projected state 갱신
→ current bundle complete 검증
→ 계획 확정
→ 가설·계획·state_before snapshot
→ AI bundle 생성
→ COMMITTED
```

## I. 시스템 반응

- 사거리·대상 없음: 확정 차단, 수정 위치 강조.
- 연속 슬롯 부족: 카드 배치 차단.
- 기세 5 아님: 절초 비활성 이유.
- target pending: 다른 카드 선택 전 대상 완료 안내.
- 확정 후: 입력 전부 lock.
- AI는 미확정 계획을 읽지 않음.

## J. 시스템

CombatScreenController, CombatResolutionEngine, CombatAiPlanner, PlanValidator, TargetingController, CardViewDataBuilder, CombatPresenter.

## K. Godot 구조

```text
CombatScreen (Control)
├─ BattleView
│  ├─ BattleBackground
│  ├─ BoardView
│  └─ CombatantLayer
├─ CombatHUDLayer
│  ├─ TopCombatHUD
│  ├─ OpponentTellPanel
│  ├─ OpponentHypothesisPanel
│  ├─ ActionTimingPanel
│  ├─ ActionPalette
│  ├─ CombatProgressButton
│  └─ OverlayHost
│     ├─ CardDetailPanel
│     └─ CombatLogPanel
├─ CombatScreenController (Node)
├─ TargetingController (Node)
└─ CombatPresentationController (Node)
```

현재 `CombatBoardPreview` Script에서 화면 조립·입력·연출을 단계적으로 이동한다. `CombatResolutionEngine`은 UI Node를 참조하지 않는다.

## L. Scene 분리

전투는 Route와 완전히 별도 Scene. 카드 상세·로그는 CanvasLayer/Overlay Scene.

## M. Signal 및 상태

Signals: `card_selected`, `placement_requested`, `target_requested`, `plan_changed`, `plan_commit_requested`, `plan_committed`, `combat_state_changed`.

`ENTER → PLANNING → TARGETING → PLANNING_READY → COMMITTING → COMMITTED`.

## N. 데이터

CombatState, BattleDefinition, ActionDefinition, PlacementData, TargetData, HypothesisSnapshot, PlanSnapshot, ProjectedResourceViewData.

현재 Dictionary 기반 구현은 유지 가능하지만 Vertical Slice adapter 경계에서 schema validator가 필요하다. 장기적으로 state는 typed Resource 또는 명시적 class로 승격 가능.

## O. 유지 데이터

전투 Scene 내 CombatState, current placements, selected hypothesis. Scene 이탈 시 승패 처리 전까지 pre-battle snapshot만 RunSession에 유지. 미확정 UI focus는 save하지 않음.

## P. 연출

선택·유효 범위·비용 변화는 즉시. 계획 확정 시 붓 획으로 슬롯 봉인. 아직 상대 계획은 공개하지 않음.

## Q. 애셋

기존 배경·전신·초상·VFX 재사용. 행동 아이콘 128×128 source, 카드 삽화 768×1024 권장. P0는 도형·텍스트 폴백 허용.

## R. 예외

대상 중 캐릭터 이동, 데이터 hot reload, focus loss, 빠른 클릭, resize, pause, card definition 누락, projected state와 actual state 불일치.

## S. 완료 기준

- 현재 묶음의 모든 행동·대상·비용이 유효해야만 확정.
- 실행 전 자유롭게 취소·교체.
- UI 예상값이 도메인 validator 결과와 일치.
- AI 입력에 미확정 plan 없음.

## T. 테스트

- [ ] 1/2/3슬롯 행동 배치.
- [ ] 이동·공격 방향 대상.
- [ ] 자원 부족·절초 기세 부족.
- [ ] 슬롯 충돌·배치 취소.
- [ ] keyboard/mouse/gamepad.
- [ ] 모션 감소·무음.
- [ ] AI input whitelist.

---

# [SIT-007] 계획 공개 후 합·방어·중단 해결

## A. 상황 개요

양측 확정 계획을 공개하고 도메인 엔진이 사건을 순서대로 해결한다. 플레이어는 개입하지 않고 무엇이 왜 발생했는지 읽는다.

## B. 근거와 가정

- 확정: 순차 연격 합, 비소모 방어도, HP 피해 중단, 강건.
- 실제 구현: resolution engine, presentation events, 빠른 재생·즉시 완료.
- 위험: 현재 runtime 구형 규칙과 최신 planning 정본 차이.

## C. 진입 조건

양측 plan committed, snapshot 고정, input locked.

## D. 화면 목적

1. 현재 실행 수와 행동.
2. 합 비교값.
3. 방어 감산→체력 피해.
4. 중단과 후속타 취소.
5. 상태·자원 변화.

## E. 화면 변화

계획 UI는 read-only. 중앙 전장과 current event를 강조. 결과 Label·로그·slot marker에 `타격 1/3`, `합 승리`, `체력 피해`, `중단`, `후속타 취소`를 같은 event ID로 표시.

## F. 구성요소

PresentationBanner, CurrentTimingMarker, ClashCompare, DamageBreakdown, StatusEventIcons, CombatLog, Skip/Fast controls.

## G. 입력

빠른 재생, 즉시 완료, 로그 펼치기만 허용. 판정 변경 입력은 금지.

## H. 흐름

```text
COMMITTED
→ engine.resolve_bundle()
→ timing_results + presentation_events 생성
→ 사건 큐 순차 표현
→ 매 사건 뒤 authoritative snapshot 적용
→ terminal 여부 확인
→ REVIEW_SUMMARY 생성
→ COMBAT_REVIEW
```

## I. 시스템 반응

- 연격 대 연격: 현재 packet끼리 합.
- 합 패배/동점: 현재 packet만 취소.
- 최종 HP 피해≥1: 현재 action interrupt, 미실행 후속타 취소.
- guard로 HP 피해0: 중단 없음.
- 강건: 피해 유지, 중단 1회 방지.
- skip: queue delay만 0, event 순서·state 동일.

## J. 시스템

CombatResolutionEngine, CombatPresentationController, CombatEventFormatter, CombatAudioRouter, AccessibilityAnnouncer.

## K. Godot 구조

전투 Scene 내부 `CombatPresentationController`가 event queue를 소비하고 View에 signal을 보낸다. Animation 완료는 도메인 판정의 trigger가 아니다.

## L. Scene 분리

기존 Combat Scene 내부 상태 전환. 별도 Scene 전환 금지.

## M. Signal·상태

`bundle_resolution_started`, `presentation_event_started`, `snapshot_applied`, `presentation_event_finished`, `bundle_resolution_finished`.

`COMMITTED → RESOLVING → PRESENTING → REVIEW_READY`.

## N. 데이터

ResolutionResult, TimingResult[], PresentationEvent[], CombatSnapshot, CombatLogEntry.

모든 event에는 stable event_id, timing, actor, target, action_id, hit_index, cause_code, before/after가 필요하다.

## O. 유지 데이터

CombatState, committed plans, hypothesis, event log. 애니메이션 프레임은 유지 불필요. 앱 종료 중간 저장은 P1에서 event 경계만 허용하거나 전투 직전 snapshot으로 복귀.

## P. 연출

합: 두 공격 궤적 교차와 숫자 비교. 방어: 흡수 숫자. 중단: 미실행 슬롯에 붓 취소선. 모션 감소 시 위치 변화·숫자·로그만 즉시 갱신.

## Q. 애셋

공격/방어/회피/합/중단 VFX, 타격 SFX, 절초 atlas. P0는 현재 procedural SFX와 텍스트·도형 VFX 사용 가능.

## R. 예외

animation과 state desync, event queue skip 중복, KO 뒤 후속 event, audio pile-up, resize 중 tween, pause 중 timer.

## S. 완료 기준

동일 input/seed에서 정상·빠른·skip 결과가 byte-equivalent state와 동일 event order를 만든다.

## T. 테스트

단타, 연격 대 연격, 연격 대 단타, 동점, guard 0 damage, HP damage interrupt, 강건, KO, unmatched hits, skip/reduced motion.

---

# [SIT-008] 결정적 복기와 다음 묶음 수정

## A. 상황 개요

묶음 종료 후 내 가설·상대 실제 행동·결정적 원인·거리 변화·다음 검토를 확인하고 다음 묶음 계획으로 복귀한다.

## B. 근거와 가정

- 실제 구현: `CombatReviewPanel`과 summary builder 존재.
- 확정: 복기는 전투를 재계산하지 않음.
- 제안: route intel과 예상/실제 차이를 summary에 확장.

## C. 진입 조건

presentation queue 종료, review summary 생성, combat terminal 여부 결정.

## D. 목적

1. 내 가설과 실제 행동 차이.
2. 합·거리·중단의 결정적 cause.
3. 무엇을 다음 묶음에서 바꿀지.
4. 상세 로그 접근.

## E. 화면

현재 Review Panel을 중심 Overlay로 사용. terminal이 아니면 `다음 묶음`, terminal이면 `결과 확인`으로 변경.

## F. 요소

ReviewTitle, HypothesisComparison, CauseSummary, BeforeAfterDistance, NextReviewHint, DetailLogButton, ContinueButton.

## G. 입력

상세 로그 열기, 계속. 복기 중 전투 계획 입력 금지.

## H. 흐름

summary 표시 → player 읽기 → 상세 선택 가능 → 계속 → non-terminal은 next bundle, terminal은 DuelResult.

## I. 반응

summary 누락 시 raw event fallback. 계속 연타는 1회. 상세 로그에서 닫으면 Continue focus 복귀.

## J. 시스템

CombatReviewSummaryBuilder, CombatLogPresenter, CombatScreenController.

## K. Godot

기존 `CombatReviewPanel` 재사용. `continue_requested`를 화면 Controller가 terminal 여부에 따라 분기.

## L. 분리

Combat Scene Canvas Overlay.

## M. 상태

`REVIEW_ENTER → REVIEWING → CONTINUE_REQUESTED → NEXT_BUNDLE_READY | COMBAT_ENDED`.

## N. 데이터

ReviewSummary: hypothesis, opponent_actual, cause_code/label, decisive_timing, distance_before/after, review_dimension, route_intel_used.

## O. 유지

summary와 full log는 combat 종료까지 유지. 다음 묶음 시작 시 Panel state 초기화.

## P. 연출

복기 Panel은 전투 위에 어둡게 올라오고 결정적 슬롯·타일을 선택적으로 highlight. 모션 없음도 동일.

## Q. 애셋

기존 StyleBox·텍스트로 P0 충족. cause icon P1.

## R. 예외

summary cause와 raw log 불일치, terminal 분기 오류, focus trap, Panel이 입력을 뒤로 전달.

## S. 완료 기준

플레이어가 원인과 다음 수정 차원을 화면만으로 설명할 수 있고 다음 묶음 또는 결과로 정확히 이동.

## T. 테스트

가설 기록/미기록, 거리 원인, 합 원인, 방어 원인, 중단 원인, terminal/non-terminal, 상세 로그 focus.

---

# [SIT-009/010] 승리 보상 또는 패배 재도전

## A. 상황 개요

전투 종료 뒤 승리는 보상 선택과 RunState 1회 commit, 패배는 원인 복기와 영구재화 1→2→3 비용 재도전 또는 회차 포기를 제공한다.

## B. 근거와 가정

- 확정: 전투 직전 RunState snapshot, 피해·임시 자원 롤백, 영구재화 지불 비롤백.
- 문서상 주요 비무 보상 3선택 후보 존재.
- 실제 구현: 개발용 restart만 존재, 제품용 결과 Service는 미구현.

## C. 진입 조건

CombatState terminal, presentation·review 완료, outcome 확정, pre-battle snapshot 존재.

## D. 화면 목적

승리: 결과·과제·보상 비교·다음 성장.  
패배: 실패 원인·재도전 비용·복원 범위·포기 결과.

## E. 화면

SCREEN-04 개선안 사용.

## F. 구성요소

OutcomeHeader, PerformanceSummary, ReviewShortcut, RewardChoiceGrid 또는 RetryPanel, RunStateDeltaPreview, Confirm.

## G. 입력

승리 보상 1개 선택, 상세 비교, 확정. 패배 재도전/포기/타이틀. 확정 뒤 입력 lock.

## H. 흐름

### 승리

```text
outcome 수신 → reward offers 생성 → 선택
→ 조건 재검증 → reward+HP+progress 원자적 commit
→ save checkpoint → 다음 RouteMap
```

### 패배

```text
outcome 수신 → retry cost 계산 → 잔액 확인
→ 재도전 선택 → 영구재화 결제 commit
→ pre-battle RunState snapshot 복원
→ 동일 opponent/seed BattleDefinition 재생성 → briefing 또는 combat
```

## I. 시스템 반응

- 보상 중복 선택: 첫 transaction만 인정.
- 보상 데이터 누락: commit 차단, 안전 오류.
- 재화 부족: 재도전 비활성, 포기/타이틀만.
- 재도전 결제 뒤 load 실패: 결제 transaction 복구 정책 필요.
- 다른 전투 진입 시 retry count 초기화.

## J. 시스템

DuelResultService, RewardOfferGenerator, RunStateTransaction, PermanentProfileService, RetryService, SaveService.

## K. Godot 구조

```text
DuelResultScreen
├─ OutcomeHeader
├─ PerformanceAndReviewPanel
├─ VictoryRewardPanel
│  └─ RewardChoiceCard ×3
├─ DefeatRetryPanel
├─ RunStateDeltaPanel
└─ FooterActions
```

## L. Scene 분리

Combat Scene에서 완전히 분리. CombatState를 직접 보존하지 않고 immutable ResultPayload와 log reference만 전달.

## M. Signal·상태

`result_presented`, `reward_selected`, `reward_commit_requested`, `reward_committed`, `retry_requested`, `retry_paid`, `run_abandoned`.

`ENTER → REVIEWING_RESULT → CHOOSING → COMMITTING → ROUTE_EXIT | RETRY_EXIT | RUN_END`.

## N. 데이터

CombatResultPayload, PerformanceGrade, ObjectiveResult, RewardOffer[], RunStateDelta, RetryQuote, TransactionReceipt.

## O. 유지 데이터

승리 commit 후 updated RunState. 패배 재도전은 pre-battle snapshot+permanent receipt. Combat temporary state는 폐기. log는 session history에 요약 저장 가능.

## P. 연출

승리 금빛 먹 번짐, 패배 저채도. 보상 선택 시 수치 변화 preview. 과장된 장시간 연출은 30~40분 런 리듬상 제한.

## Q. 애셋

결과 인장, 등급 아이콘, 보상 카드 frame, 승패 SFX. P0는 텍스트·StyleBox 가능.

## R. 예외

double commit, 저장 중 종료, reward ID 중복, retry payment race, same seed 불일치, 타이틀 복귀 후 suspended run 처리.

## S. 완료 기준

보상·재도전 거래가 정확히 1회이며 저장·로드 뒤 상태가 일치하고 올바른 Route/Combat/Main으로 전환.

## T. 테스트

- [ ] 승리 보상 3개 중 1개.
- [ ] 공개 과제 달성/미달성.
- [ ] double click.
- [ ] retry 비용 1→2→3→3.
- [ ] 잔액 부족.
- [ ] 동일 seed 재도전.
- [ ] 저장 직후 강제 종료·복원.

---

# 8. P1~P3 요약 명세

| 상황 | 요약 구현 | 우선순위 | 임시 대체 |
|---|---|---|---|
| 무공 구성 상세 조회 | Route/Briefing에서 Overlay로 현재 4개 무공·성급·기술·다음 성장 비교 | P1 | 목록+CardDetail |
| 설정·접근성·일시정지 | 모션 감소·빠른 재생·음량을 전투 로컬 버튼에서 공용 Settings로 승격 | P1 | 현재 전투 버튼 유지 |
| suspended run 저장 | 노드 완료·비무 직전·결과 commit 뒤 checkpoint | P1 | 데모에서 세션 save만 |
| 5전 데모 완료 | 전체 선택·비무 기록·대표 빌드 요약 후 타이틀 | P1 | 정적 요약 Panel |
| 용어 사전 | 합·중단·강건·필중 등 context tooltip과 사전 | P2 | 카드 상세 텍스트 |
| 연출 강화 | 후보별 intro, camera, bespoke VFX | P2 | 공용 전장 연출 |
| 천하제일인·등록 전투 구성 | 본편 엔딩 후 해금, 별도 장기 상태 | P3/HOLD | 구현하지 않음 |

---

# 9. 전체 상황 연결 구조

```text
BOOT
→ MAIN_MENU
├─ NEW_RUN → RUN_SETUP
│            → FIRST_DUEL_BRIEFING
│            → COMBAT_PLANNING
│            → COMBAT_RESOLVING
│            → COMBAT_REVIEW
│            ├─ NEXT_BUNDLE → COMBAT_PLANNING
│            └─ COMBAT_ENDED
│                ├─ VICTORY → DUEL_RESULT_REWARD
│                │             → ROUTE_MAP
│                │                → ROUTE_NODE_1
│                │                → ROUTE_NODE_2
│                │                → DUEL_BRIEFING
│                └─ DEFEAT → RETRY_DECISION
│                              ├─ RETRY → DUEL_BRIEFING/COMBAT
│                              └─ ABANDON → RUN_END/MAIN_MENU
├─ CONTINUE → SAVED_STATE
├─ PRACTICE → DUEL_BRIEFING → COMBAT
└─ SETTINGS
```

## 전환 계약

| 이전 | 조건 | 다음 | 유지 데이터 | 방식 |
|---|---|---|---|---|
| Main | 새 회차 | Run Setup | profile/settings | 별도 Screen |
| Run Setup | 4개 확정 | First Briefing | RunState | 별도 Screen |
| Result | 승리 commit | Route Map | RunState, history | 별도 Screen |
| Route Map | 경로 확정 | Node | graph, opponent offers | 별도 Screen |
| Node 1 | 완료 | Node 2 | RunState, route | 별도 Screen |
| Node 2 | 완료 | Briefing | RunState, prep | 별도 Screen |
| Briefing | snapshot 성공 | Combat | BattleDefinition, snapshot | 별도 Screen |
| Combat planning | plan commit | Resolving | CombatState | 동일 Scene 상태 |
| Resolving | queue 종료 | Review | CombatState, logs | Overlay |
| Review | non-terminal | Planning | CombatState | Overlay 닫기 |
| Review | terminal | Result | ResultPayload, log ref | 별도 Screen |
| Result defeat | retry 결제 | Combat | snapshot, same seed | 별도 Scene 재생성 |

---

# 10. 권장 공통 아키텍처

## 10.1 App Root

```text
AppRoot (Node)
├─ ScreenHost (Control)
├─ ModalLayer (CanvasLayer)
├─ TransitionLayer (CanvasLayer)
│  ├─ InputBlocker
│  └─ InkTransition
└─ AppFlowController (Node)
```

`project.godot`의 main scene을 장기적으로 AppRoot로 전환하되, 이는 사용자 Build 승인 뒤에만 수행한다.

## 10.2 Autoload 최소화

### P0 권장

- `RunSession`: 현재 RunState와 pre-battle snapshot, graph, transaction boundary 소유.
- `SaveService`: profile/suspended run serialization, migration, atomic write.

### P1 권장

- `SettingsService`: 입력·접근성·오디오 설정.
- `AudioDirector`: BGM crossfade와 event SFX routing.

`GameFlow`는 Autoload보다 AppRoot child로 두어 테스트와 lifecycle을 명확히 한다. CombatState는 절대 Autoload로 올리지 않는다.

## 10.3 도메인·UI 분리

```text
runtime data / RunState / BattleDefinition
→ service·validator·engine
→ immutable result / view data
→ Screen Controller
→ Control Scene
→ player input request Signal
→ service·engine
```

- UI가 damage, clash, reward, route generation을 계산하지 않음.
- Animation 완료가 state commit 조건이 아님.
- Scene이 저장 파일을 직접 읽고 쓰지 않음.
- stable ID를 display name 대신 상태·저장 key로 사용.

---

# 11. 데이터 구조와 관리 방식

| 데이터 | 주요 필드 | 권장 저장 | 사용 화면 | 변경 영향 |
|---|---|---|---|---|
| ProfileState | permanent_currency, unlocks, settings refs, schema | save JSON/Resource | Main, Retry | 장기 진행 |
| RunState | run_id, seed, slot, hp, money, martial progression, route, retry | save JSON + typed adapter | 전 화면 | 회차 전체 |
| RouteGraphData | layers, node IDs, edges, offered opponents | RunState | Route | 경로 재현 |
| NodeDefinition | id, type, choices, conditions, costs, effects | runtime JSON | Node | 콘텐츠 |
| OpponentDefinition | id, slot role, tells, AI profile, art refs | runtime JSON | Route, Briefing, Combat | 후보 |
| BattleDefinition | opponent, start positions, seed, modifiers, rewards | runtime object | Briefing, Combat | 전투 생성 |
| MartialDefinition | id, faction, stars, techniques, role tags | runtime JSON | Setup, Build, Combat | 행동 선택 |
| ActionDefinition | id, category, slots, costs, target, hits, effects | runtime JSON | Build, Combat | 판정 |
| CombatState | round, bundle, positions, resources, statuses, progress | memory | Combat | 한 전투 |
| CombatResultPayload | outcome, grade, objective, log refs, delta | memory/save history | Result | 보상 |
| RewardDefinition | id, type, values, eligibility | runtime JSON | Result | 성장 |
| ViewData | formatted text, icon refs, enabled reason | memory | UI | 표시만 |

## 관리 판단

- Google Sheets: 기획자가 편집하는 GDD·콘텐츠 원천.
- `docs/planning-data`: 비런타임 권위·검증 입력.
- runtime JSON: adapter가 생성·검증한 실제 콘텐츠.
- Godot Resource: Theme, PackedScene reference, presentation configuration처럼 에디터 친화 데이터.
- Save: versioned JSON 또는 Resource serializer 중 하나로 통일; content definition 자체를 save에 복제하지 않고 stable ID와 mutable state만 저장.

---

# 12. 화면 전환과 상태 유지

## 12.1 별도 Scene 전환과 Overlay 비교

| 방식 | 장점 | 위험 | 적용 |
|---|---|---|---|
| 별도 Scene | 책임·메모리·입력·저장 경계 명확 | 상태 전달 필요 | Main, Setup, Route, Node, Briefing, Combat, Result |
| 동일 Scene 상태 | 객체 유지, 빠름 | Controller 복잡 | Combat planning/resolving |
| CanvasLayer Overlay | context 보존, Modal 적합 | 입력 누수 | Card Detail, Log, Review, Pause, Build inspect |
| SubViewport | 별도 렌더 가능 | 복잡·성능·입력 변환 | 현재 필요 없음 |

### 추천

Combat은 Route 위 Overlay가 아니라 별도 Scene. Route state는 `RunSession`에 유지한다. Combat Review는 같은 Scene Overlay, Duel Result는 별도 Scene.

## 12.2 저장 체크포인트

- 새 회차 시작 무공 확정 후.
- 경로 선택 확정 후.
- 각 노드 결과 commit 후.
- 비무 직전 snapshot 생성 후.
- 승리 보상 commit 후.
- 재도전 영구재화 결제와 snapshot 복원 transaction 후.

전투 사건 중간 저장은 P0에서 제외하고, 앱 종료 시 전투 직전 snapshot으로 복귀하는 정책을 권장한다.

---

# 13. 필요한 애셋 총괄

| 애셋 | 권장 source | 상태 | 재사용 |
|---|---:|---|---|
| 전투 배경 | 2560×1440 이상 | 기존 활성 자산 | 재사용 |
| 전장 캐릭터 전신 | 1024×1536 RGBA 이상 | 플레이어·무명 상대 존재 | 후보별 확장 |
| 상태 초상 | 1024×1024 또는 1024×1536 | 2종 존재 | 후보별 확장 |
| 카드 삽화 | 768×1024 | 일부 기존 atlas 계보 | 무공별 확장 |
| 노드 배경 | 1920×1080 | 신규 | 타입별 재사용 |
| 노드 아이콘 | 128×128 | 신규 | 타입 공통 |
| 상태 아이콘 | 128×128 | 일부 폴백 | 공통 |
| 합·중단 VFX | 1024~2048 atlas | 절초 VFX 존재 | 공통+후보 시그니처 |
| UI frame | 9-slice source | StyleBox 폴백 존재 | 공통 |
| BGM | loop 가능한 원본 | 확인 필요 | 화면군별 |
| SFX | 사건 ID 단위 | procedural 일부 | 공통 |

표시 크기는 화면 scale에 따라 줄이고 source를 직접 layout 기준으로 삼지 않는다.

---

# 14. 공통 예외·위험

1. `CombatBoardPreview` 단일 Script의 과도한 책임.
2. 최신 기획 규칙과 legacy runtime 판정 불일치.
3. planning JSON을 runtime에서 직접 읽어 authority 경계가 무너지는 문제.
4. Route·Reward transaction 중복 적용.
5. Scene 전환 중 input 누수와 confirm 연타.
6. pre-battle snapshot과 permanent profile의 rollback 범위 혼합.
7. 후보 15명 제작량으로 Vertical Slice가 지연되는 위험.
8. 960×640 최소 크기에서 Overlay 충돌.
9. 긴 한국어 효과와 게임패드 focus가 카드 정보 계층을 깨는 문제.
10. skip/fast/reduced motion이 판정 결과를 바꾸는 문제.
11. 후보 asset 누락을 fatal error로 처리해 진행이 막히는 문제.
12. audio player 중복 생성·Scene 이탈 뒤 재생 지속.

---

# 15. Vertical Slice 구현 우선순위

## P0 — 플레이 가능 구조

1. `AppRoot`와 Screen transition/input lock.
2. `RunSession`·versioned `SaveService` 최소 계약.
3. 시작 무공 6→4 선택.
4. seed 기반 첫 상대 3→1, 다음 슬롯 3→2 제시.
5. 2층 Route Map과 공통 Node Resolution.
6. Duel Briefing과 pre-battle snapshot.
7. 기존 Combat PoC를 제품 Screen 경계로 감싸고 최신 runtime adapter 연결.
8. Combat Review → Duel Result 분기.
9. 승리 보상 1회 commit, 패배 재도전·포기.
10. 2개 슬롯 후보를 사용한 최소 한 구간 end-to-end.

## P1 — 경험 완성

- 무공 구성 독립 Overlay.
- suspended run 저장·이어하기.
- 공용 설정·접근성.
- 5전 데모 완료 Summary.
- 슬롯 1~5 후보 3명 콘텐츠.

## P2 — 연출·편의

- 후보별 intro·camera·시그니처 VFX.
- 용어 사전·상세 통계.
- 노드 배경 변주와 오디오 확장.

## P3/HOLD

- 천하제일인.
- Champion Build Snapshot 등록·비동기 대전.
- 서버.

## 임시 UI 허용

- Main key art, 노드 삽화, 후보 전신 일부는 정적 placeholder 가능.
- Route 연결선은 custom draw.
- 보상은 텍스트 카드 가능.
- 신규 규칙 판독에 필요한 아이콘이 없으면 텍스트·형태 폴백 필수.

임시 대체 불가:

- 10칸 위치·거리.
- 3/3/4 묶음.
- 공개 전조와 가설.
- 자원·대상 오류.
- 합·방어·중단 원인.
- 결과 transaction과 저장 경계.

---

# 16. 테스트 전략

## 정적·데이터

- 모든 runtime JSON schema validation.
- stable ID uniqueness와 reference integrity.
- Route generator invariant와 seed determinism.
- Reward/retry transaction idempotency.
- Save schema migration·atomic write.

## Godot Scene

- 모든 Screen 독립 instantiate/free.
- AppRoot 전환 100회 반복 후 orphan·signal duplication 없음.
- 960×640, 1280×720, 1440×900, 1920×1080, 2560×1440.
- keyboard/mouse/gamepad focus path.
- pause, resize, focus loss, app close.

## 정상 흐름

- 새 회차→무공 선택→첫 비무→승리→보상→경로→노드2개→두 번째 비무.

## 실패 흐름

- 데이터 누락, 비용 부족, 사거리 실패, 패배, 재화 부족, save failure, load failure.

## 반복·저장

- 동일 seed 동일 상대·graph.
- 노드·보상 중복 미적용.
- 재도전 1→2→3, permanent payment 비롤백.
- 저장 후 정확한 Screen과 focus 가능한 상태로 복귀.

## 사람 검증

- 플레이어가 첫 3초에 현재 목표를 말할 수 있는가.
- 경로 선택 이유가 다음 상대·회복·성장 중 하나와 연결되는가.
- 합 패배와 중단을 구분하는가.
- 복기 뒤 다음 plan이 실제로 달라지는가.
- 색·모션·음향 없이도 원인을 이해하는가.

---

# 17. 상황별 인게임 화면 보드

| 번호 | 화면·상황 | 핵심 행동 | 가장 중요한 정보 | 주요 시스템 | 이전→다음 | 우선순위 | 현재 구현 |
|---:|---|---|---|---|---|---|---|
| 1 | Main / 새 회차·이어하기 | 진입 선택 | 저장·가능 행동 | Save, Flow | Boot→Setup | P0 | 신규 필요 |
| 2 | Run Setup / 시작 무공 | 6중4 선택 | 역할·거리·자원 | Content, RunSession | Main→Briefing | P0 | 신규 필요 |
| 3 | Route Map / 다음 상대 | 경로·상대 선택 | 상대2명·노드 위험보상 | Generator, RunState | Result→Node | P0 | 신규 필요 |
| 4 | Route Node / 상태 조정 | 1개 선택 | 비용·즉시 결과 | Resolver, Transaction | Route→Node/Briefing | P0 | 신규 필요 |
| 5 | Duel Briefing | 공개 정보 확인 | 대표 위협·전조·준비 | BattleFactory | Node→Combat | P0 | 신규 필요 |
| 6 | Combat Planning | 가설·3/3/4 배치 | 거리·자원·대상 | 기존 전투 UI/Engine | Briefing→Resolve | P0 | 기존 확장 |
| 7 | Combat Resolve/Review | 결과 관찰·원인 이해 | 합·방어·중단 | Engine, Presenter, Review | Plan→Next/Result | P0 | 기존 확장 |
| 8 | Duel Result | 보상/재도전 | 결과·transaction | Result, Save | Combat→Route/Retry | P0 | 일부 부품만 존재 |
| 9 | Martial Build | 성장 확인 | 성급·해금·다음 영향 | Content, RunState | Route/Briefing Overlay | P1 | 기존 카드 부품 활용 신규 |

---

# 18. 확인이 필요한 결정

1. 최종 기준 화면 비율: 16:10 유지 또는 16:9 전환.
2. Main Menu에서 연습 비무를 처음부터 제공할지.
3. 전투 중 앱 종료 시 전투 직전 snapshot 복귀를 공식 정책으로 할지.
4. 승리 보상 3선택의 최종 종류·수치.
5. 무공 구성 화면에서 수련 배분을 언제 허용할지: 노드에서만 또는 Route에서도.
6. 첫 데모 후보 15명의 시각 자산을 모두 개별 제작할지, 공용 전신·효과 공유 범위.
7. 후보 이름·이명·대표 무공의 최종 승인.
8. 패배 시 회차 포기 뒤 suspended run 삭제 시점.
9. settings와 save를 P0에 포함할 최소 범위.
10. 인게임 튜토리얼의 강제 정도와 tooltip/coach mark 비율.

---

# 19. Base 승격 후보

다음은 프로젝트 전용 내용이 아니라 다른 Godot 게임에도 재사용 가능한 공용 후보이다.

- 상황→입력→시스템 반응→결과→다음 상태 기반 화면 명세 템플릿.
- AppRoot ScreenHost + ModalLayer + Transition InputBlocker 패턴.
- Scene 전환 transaction과 중복 입력 방지 계약.
- RunState·CombatState·PermanentProfile rollback 경계 체크리스트.
- deterministic route graph 화면·저장 검증 패턴.
- 결과 UI의 idempotent reward/retry transaction 기준.
- current/proposed wireframe와 실제 파일 매핑 표.

승격 전 Base의 기존 `designing-vertical-slices`, `auditing-and-refining-ui-art`, `reviewing-and-validating-project-changes`와 중복 여부를 확인해야 한다.

# 20. 프로젝트 전용 유지 항목

- 10칸 전장과 거리 0 밀착.
- 3/3/4 계획.
- 상대 가설과 공개 전조.
- 순차 연격 합·비소모 방어도·체력 피해 중단·강건.
- 무공 6중4 시작 선택과 성급 성장.
- 슬롯별 후보 3명과 3→1/3→2 상대 선정.
- 천하제일인·등록 전투 구성.
- 수묵·금빛의 십보강호 시각 언어.

---

# 21. 완료·검토 게이트

```yaml
spec_status: DESIGN_DRAFT_USER_REVIEW_PENDING
planning_complete: false
review_complete: false
runtime_implementation: prohibited
product_paths_changed: false
human_validation: not_run
codex_handoff: false
```

이 문서는 구현 계획이나 Build 승인이 아니다. 사용자 검토에서 화면·상태·P0 범위가 승인된 뒤에만 구현 계획을 별도로 작성한다.
