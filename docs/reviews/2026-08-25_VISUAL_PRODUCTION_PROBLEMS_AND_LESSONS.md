# 십보강호 · Visual Production 문제·교훈 기록 · 2026-08-25

> 범위: 2026-08-25 전투 화면·캐릭터·행동 삽화·수묵 clean plate 탐색/승인 과정에서 실제로 드러난 문제와 재사용 가능한 교훈을 기록한다.  
> 이 문서는 프로젝트 회고/증거이며 Base 공용 규칙 자체가 아니다. 공용 후보는 별도 BCP로 제출한다.

## 1. 결과 요약

사용자 승인 결과:

- 대표 전투 화면 `TEN-IMG-001` 승인.
- Character Master 기준 승인.
- 기초 행동 10종 삽화 스타일 승인.
- 공통 수묵 clean plate 1종 승인.
- 후속 제작 cadence는 사용자 최신 지시에 따라 **한 번에 최대 3장 묶음**으로 변경.
- Notion Home/Visual Bible/Asset Library에 승인 상태와 preview 전달 완료.

미완료:

- 승인 Reference의 Godot runtime 적용.
- 상대 15명 전체 식별성 검증.
- Windows visible/Android/Human 검증.
- `진행` CTA와 `행동계획 잠금` 의미 계약의 정본 통합.
- `TEN-VIS-A07` 정식 repository asset-inventory ID 승격.

---

## 2. 문제 1 · 모든 레이어를 같은 그림체로 묶으면 가독성이 떨어짐

### 관찰

초기 시안은 손그림/수묵 질감을 UI까지 강하게 공유했다. 세계관 통일감은 있었지만 전술 게임에서 읽어야 하는 `거리`, 현재 3수 계획, 비용, 행동 종류가 장식과 같은 질감에 묻힐 위험이 컸다.

### 수정

역할별로 treatment를 분리했다.

- 배경: 저대비 수묵화.
- 캐릭터: 수묵 선화 + 제한적 도트/디더링.
- UI: 별도 정제 정보 UI.

### 교훈

**Visual cohesion은 동일 렌더러가 아니라 공통 의미 체계·비율·색 역할·레이어 관계로 만들 수 있다.**

공용 후보: `LAYERED_VISUAL_STYLE_RESPONSIBILITY`.

### 비사용 조건

순수 일러스트 게임처럼 UI 정보량이 매우 낮고 화면 전체가 하나의 화폭으로 읽혀야 하는 경우에는 treatment 분리가 오히려 부자연스러울 수 있다.

---

## 3. 문제 2 · 캐릭터가 짤막하게 보이면 전투의 위압감과 무협 인상이 약해짐

### 관찰

초기 전투 시안에서 인물이 화면에 충분히 존재하지만 체형이 짧고 UI에 눌려 “무협 검객의 대치”보다 “UI 사이의 작은 말판”처럼 보였다.

### 수정

- 캐릭터 세로 비율을 늘렸다.
- 전장 영역을 먼저 확보하고 행동 선택 영역을 아래로 내렸다.
- 카드 세로 크기를 줄여 캐릭터 점유를 회복했다.

### 교훈

**전투 화면의 캐릭터 매력/위압감 문제를 UI 디테일로 해결하려 하지 말고, 먼저 체형·점유율·negative space를 교정한다.**

검증 질문:

- UI를 모두 회색 박스로 바꿔도 캐릭터 대치가 주인공으로 보이는가?
- 실루엣만 남겨도 두 인물의 체급/태도/무기가 구별되는가?

---

## 4. 문제 3 · 카드가 세로로 길어지면 전장을 잠식함

### 관찰

초기 카드 시안은 한 장에 이름·비용·사거리·효과·삽화를 모두 넣어 카드가 길어졌다. 결과적으로 화면 하단이 커지고 캐릭터/전장이 줄었다.

### 수정

- 최대 5×2 = 10개 배열.
- 카드에는 이름/삽화/수/비용/필요한 사거리만 우선.
- 긴 효과/조건/공식은 Detail Panel로 분리.

### 교훈

**정보량이 많은 전술 행동 UI는 카드 자체를 문서로 만들지 않는다. 선택 surface와 상세 설명 surface를 분리한다.**

관련 runtime 증거:

- `ActionSelectionDock`는 이미 source tab과 detail panel을 가진다.
- 따라서 이미지 시안도 existing runtime architecture를 따라가는 것이 재사용·구현 비용 측면에서 유리했다.

---

## 5. 문제 4 · “픽셀/도트 느낌” 요청을 전체 픽셀아트 전환으로 해석하면 drift가 큼

### 관찰

사용자는 기존 수묵화/도트 계보에 더 가깝게 하길 원했지만, 전체 화면을 픽셀아트로 전환하는 것은 기존 승인 Visual Bible과 충돌하고 배경/UI 노이즈를 키울 가능성이 있었다.

### 수정

도트/디더링의 책임을 좁혔다.

- 캐릭터 먹 가장자리와 작은 카드 판독 보조.
- 전장 배경은 계속 수묵화.
- UI는 정제된 별도 스타일.

### 교훈

**부분 stylistic cue를 받았을 때 전체 renderer migration과 국소 texture/treatment 변경을 구분한다.**

공용 적용 시 먼저 비교할 대안:

1. 전체 스타일 전환.
2. 주 피사체에만 국소 treatment.
3. 현행 유지 + VFX/edge accent만 추가.

---

## 6. 문제 5 · 대량 자산을 먼저 만들면 style drift와 폐기 비용이 커짐

### 관찰

프로젝트에는 상대 15명, 전신 15명, Route 아이콘, 배경 변주 등 큰 자산 목록이 존재한다. 이를 바로 대량 생성하면 캐릭터 비율·카드 삽화 밀도·배경 대비가 확정되기 전에 수십 장이 생길 위험이 있다.

### 수정

먼저 네 종류의 기준 Reference를 승인했다.

1. 대표 전투 화면.
2. Character Master.
3. small-card illustration sheet.
4. common clean plate.

그 뒤 15명/무공/Route로 확장한다.

### 교훈

**`REFERENCE_SET_BEFORE_SCALE`: 반복 생산 전에 서로 다른 소비처를 대표하는 최소 reference set을 먼저 잠근다.**

이 네 종류가 모든 프로젝트의 정답은 아니다. 프로젝트마다 반복 생산 병목을 대표하는 3~5개 기준 reference를 선택한다.

---

## 7. 문제 6 · 승인과 runtime asset을 섞으면 상태가 과장됨

### 관찰

사용자가 시안을 “승인”했더라도 다음은 자동으로 성립하지 않는다.

- repository shipping asset 등록.
- Godot scene 적용.
- device/Human PASS.
- 라이선스/provenance manifest 완료.

### 수정

상태를 분리했다.

`USER_APPROVED_REFERENCE` → `REPOSITORY_REFERENCE_SOURCE` → `PROJECT_ASSET_APPROVED` → `RUNTIME_INTEGRATED` → `HUMAN/DEVICE_VALIDATED`

현재는 첫 두 단계 사이를 정리하는 중이다.

### 교훈

**이미지 생성 성공, 사용자 승인, 제품 자산 승인, runtime 통합은 각각 다른 증거다.**

---

## 8. 문제 7 · Notion에 image block만 보인다고 전달 완료로 볼 수 없음

### 관찰

Notion connector는 로컬 PNG를 바로 붙이는 경로가 제한적이었다. 검토용 SVG wrapper를 업로드하고 페이지에 image block을 넣었지만, 단순히 block 존재만 확인하면 빈 wrapper/깨진 이미지 가능성을 배제할 수 없다.

### 수정

두 단계 readback을 수행했다.

1. destination page readback: Home/Visual Bible/Asset Library에 승인 상태와 이미지 block 존재 확인.
2. attachment content readback: 4개 업로드 파일을 다시 다운로드해 SVG 내부에 실제 JPEG base64 data가 존재함을 확인.

### 교훈

**`NOTION_ATTACHMENT_CONTENT_READBACK`: 전달 완료는 destination block + non-empty attachment content를 함께 확인한다.**

주의:

- preview가 source master와 동일 품질이라는 뜻은 아니다.
- source master는 repository/asset vault 등 별도 durable source에 보존해야 한다.

---

## 9. 문제 8 · 1장 승인 Gate가 style lock 뒤에는 작업 리듬을 지나치게 잘게 쪼갤 수 있음

### 관찰

초기 Base 공용 Gate는 승인당 정확히 1장을 요구한다. 탐색 초반에는 drift를 줄이는 데 효과적이지만, 사용자와 style lock이 이미 형성된 뒤 `상대 Master / 무공 삽화 / Route 아이콘`처럼 서로 독립적인 세 항목을 한 장씩 승인/생성/중단하면 대화 비용이 커진다.

사용자가 명시적으로 **“한번에 3장씩 만들자”**고 cadence를 변경했다.

### 수정

프로젝트에서는 다음 bounded batch로 운영한다.

- 최대 3장.
- 각 항목의 brief/보호선은 사전에 존재.
- 사용자 명시 생성 승인 필요.
- 묶음 결과 뒤 자동 다음 묶음 금지.
- 결과 각각을 승인/수정/기각 가능.

### 교훈 후보

`BOUNDED_EXPLICIT_IMAGE_BATCH`.

### 위험과 반례

- 아직 스타일이 안 잠긴 탐색 초반에는 3장이 동시에 drift할 수 있다.
- 서로 강하게 의존하는 이미지(대표 화면이 확정되어야 다음 캐릭터 크기가 결정되는 경우)는 순차 1장 방식이 더 안전하다.
- 사용자가 수량을 명시하지 않았으면 기본 1장 Gate가 더 안전하다.

따라서 Base 후보는 “항상 3장”이 아니라 **style lock + explicit user batch size + independent briefs** 조건부 예외여야 한다.

---

## 10. 문제 9 · 화면 시안의 CTA 텍스트가 규칙 의미를 암묵적으로 바꿀 수 있음

### 관찰

사용자는 `행동계획 잠금` 대신 `진행`을 원했다. 시각적으로는 더 자연스럽고 부담이 낮지만, repository 전투 규칙에서 `행동계획 잠금`은 현재 묶음이 확정되고 수정 불가가 된다는 의미 계약도 소유한다.

### 교훈

**UI label simplification과 gameplay semantic change를 분리한다.**

- `DISPLAY_LABEL_CHANGE`인지
- `SEMANTIC_STATE_TRANSITION_CHANGE`인지

구분한 뒤 runtime 변경 전 Decision을 만든다.

---

## 11. Base 승격 후보

### Candidate A · `LAYERED_VISUAL_STYLE_RESPONSIBILITY`

일반화:

- 배경/캐릭터/UI/VFX가 각자 다른 visual treatment를 가져도 색 의미·비율·재질·레이어 우선순위를 공유하면 하나의 제품 언어가 될 수 있다.

### Candidate B · `REFERENCE_SET_BEFORE_SCALE`

일반화:

- 대량 자산 전에 서로 다른 소비처를 대표하는 최소 reference set을 승인하고 반복 생산을 시작한다.

### Candidate C · `BOUNDED_EXPLICIT_IMAGE_BATCH`

일반화:

- style lock 이후, 사용자가 명시한 bounded batch 수량과 독립 brief가 있으면 1장 Gate를 조건부 완화할 수 있다.
- batch 결과 뒤 자동 chain은 계속 금지한다.

### Candidate D · `NOTION_ATTACHMENT_CONTENT_READBACK`

일반화:

- Notion Visual 전달 완료는 destination block 존재 + 실제 non-empty attachment content readback을 요구한다.

---

## 12. 프로젝트 전용으로 남기는 것

Base로 복사하지 않는다.

- `3/3/4` 계획 규칙.
- `거리 N`의 십보강호 구체 UI.
- 무공/절초 명칭·문파·15명 상대 수.
- 먹/세피아/금색의 exact 프로젝트 palette.
- `TEN-VIS-A01~A07` ID.
- 현재 승인 캐릭터의 외형과 실제 이미지.

---

## 13. 검증 ceiling

이번 회고가 증명하는 것:

- 사용자 reference 승인 사실.
- Notion 전달/readback 사실.
- 프로젝트 내부 시각 탐색에서 위 문제들이 실제로 발생/수정됐다는 사실.

증명하지 않는 것:

- 다른 프로젝트에서도 bounded batch가 항상 우월함.
- 실제 15명 반복 생산에서 style lock이 완벽히 유지됨.
- device/Human gameplay 품질 향상.
- runtime asset pipeline의 완전성.

따라서 Base에서는 특히 Candidate C를 **조건부 제안**으로 다뤄야 한다.
