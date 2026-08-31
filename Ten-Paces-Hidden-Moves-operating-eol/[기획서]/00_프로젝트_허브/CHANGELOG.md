# 십보강호 운영 변경 기록

## 2026-07-22 — Base 통합·가지치기·적대적 개선

### 간소화

- Base 공유 Skill 13개는 유지하고 로컬 Skill을 프로젝트 고유 6개에서 4개로 축소.
- 공용 운영·인수·Health Review 로컬 복제를 Base 통합 Skill로 승계.
- 사용 불가능한 Project Skill Map·Publication Manifest 제거.
- 컨셉·벤치마크 템플릿 통합.
- 정본 최신성 감사 양식을 변경 검증 템플릿에 통합.
- 분리된 Governance 테스트 2개를 표준 라이브러리 회귀 테스트 1개로 통합.
- 중복 Governance checker 제거.
- 루트·허브·AGENTS·Workflow의 기본 읽기 경로 축소.

### 발행 계약 수정

- 실제 발행 생성기가 없음을 확인.
- 11개 기획 문서와 Skill Registry를 실행 가능한 `source_only`로 정렬.
- PDF가 필요한 마일스톤에서 생성기·폰트·Manifest·렌더·사용자 검수를 함께 설치하도록 변경.
- 가짜 `always_sync`·`milestone_sync` 현재 상태 제거.

### 적대적 검토

- 변경 전 `de9ad6e…`와 최적화 head를 비교해 운영 파일만 변경됐음을 확인.
- 전투 코드·데이터·씬·자산·제품 본책 변경 없음.
- Design Registry와 로컬 Schema의 정책 충돌 발견.
- Schema를 정책 기반 조건부 계약으로 수정하고 자동 검사 추가.
- 발행 정책 승격 시 생성기 파일 존재 검사 추가.

### 실패·개선 루프

1. README Base 버전 링크 누락 발견·복구.
2. 허브 Base 버전 경로 누락 발견·복구.
3. 루트 START_HERE Skill Registry 경로 누락 발견·복구.
4. AGENTS Skill Registry 경로 누락 발견·복구.
5. 수동 검토에서 Registry·Schema 충돌 발견·수정.
6. 운영 구조·정본 최신성·Skill 무결성·회귀 테스트 재통과.

### 삭제·승계

삭제된 항목은 Git 이력·Legacy Alias·통합 템플릿·Base 공유 Skill·자동 검사로 기능을 승계했다. 제품 기능·규칙·자산은 삭제하지 않았다.

### 미검증

- 사용자 로컬 미커밋 파일
- RESPONSE 10.6 최신 Godot 런타임
- PDF 발행 파이프라인
- 접근성 사용자 검수
- 목표 플랫폼 성능 프로파일
- 외부 POC 플레이테스트
- Branch protection Required Check 강제

## 2026-07-21 — Base latest main 전면 동기화

- Base를 `ee265576da7f67d3278f8099dd97d4e714ef0651`로 갱신.
- 이전 기준 이후 155개 커밋·70개 변경 파일 전수 판정.
- Work Mode `PLAN / BUILD / REVIEW`와 자동 Skill·Skill Mode 라우팅.
- L1 이상 실행 보고, reconciliation, 정본 최신성, Skill 무결성.
- 접근성·성능을 독립 검증 게이트로 분리.
- 현재 제품 Entry Point를 10칸·3/3/4·8개 기초 행동·STEP 10.6으로 정렬.
- 기존 본책·백업·보류·Plan·Godot 자산 비파괴 보존.

## 2026-07-21 — 전투 POC STEP 0~10.6

- 카드 UI·10칸 전장·배경·상단 HUD·10수 행동 슬롯.
- 기초 행동 8종·상세·로그·진행·배치.
- 이동 목적지·공격 방향·판정 엔진.
- 강공·보법·시작 자원 규칙.
- 막기·회피·태세 연계와 배치 즉시 자원 미리보기.
- 사용자 Windows에서 STEP 0~10·대상 지정 확인.
- 최신 대응·자원 보완 사용자 확인 대기.

## 2026-07-20 — Base schema v3 Governance foundation

- 루트 START_HERE와 프로젝트 허브.
- Design·Skill·Interview Registry.
- Development Gates·Update Matrix·Handoff·Decision·Health Report.
- 표준 라이브러리 Governance 검사와 GitHub Workflow.
- 기존 본책·백업·보류·Plan 비파괴 보존.
# 2026-07-23 — Issue #11 절초·전투 연출

- 양측 체력 30/30·공격력 8, 절초 3종과 기세 5 예약을 추가했다. 예약은 `[진행]` 전 점유 수 슬롯 클릭 또는 Enter로 취소해 기세 5를 되돌릴 수 있고, 진행 뒤에는 환불되지 않는다.
- 실제 피해 중단, 태세 강건의 1슬롯 속공 보호, 거리 0 밀착과 공동 타일 점유를 추가했다.
- 엔진 `presentation_events`, 결과 상태, 소리 제어와 절차적 SFX를 추가했다.
- `[집중]`을 활성 규칙·HUD fixture에서 제거했다.
- 활성 자산 매니페스트의 한글 메타데이터를 UTF-8로 정정하고, 마지막 Godot 4.7 Headless 혼잡 장면 재검증(평균 7.61ms/frame)을 기록했다.
- `resolving` 중 실제 마우스 버튼 이벤트가 카드 선택·수 예약·절초 기세 소비를 바꾸지 않는 회귀 테스트를 추가했다.
- 수묵 석양 전장과 결합하는 강호낭인/무명 검객 전신 RGBA 원화를 추가하고, 발 앵커·실제 Godot 4.7 렌더를 검증했다.
- 절초·재생·모션·소리·음량·진행의 표준 Tab 컨트롤에 흰색 2px 포커스 링을 추가했다.
- `즉시 완료`가 진행 중 절초의 최대 0.70초 대기를 끝까지 기다리던 결함을 고쳤다. 프레임 단위 취소 대기와 `verify_combat_presentation_controls.gd` 회귀 검증을 추가해 텍스트·VFX가 즉시 사라지고 판정 결과는 바뀌지 않음을 보장한다.
- Tab 순서를 카드 8종 → 수 슬롯 1~10 → 대상 타일 1~10 → 진행 → 재생/음향 제어 → 카드로 명시해 장면 트리 생성 순서 변화가 키보드 조작 경로를 바꾸지 않도록 했다.
- Godot 4.7 Control 접근성 API를 사용해 카드·수 슬롯·전장 타일·진행·재생/음향 제어에 한국어 이름과 조작 설명을 추가하고 회귀 검증했다. 실제 Windows 화면 읽기 출력은 별도 수동 Gate로 남긴다.
- `accessibility/general/accessibility_support=1`을 설정하고, Windows UI Automation 트리에서 전투 조작 요소의 한국어 이름·역할 노출을 확인했다. 절차적 SFX는 Windows `AudioStreamWAV` 재생·음소거 즉시 정지·PCM 음량 차이까지 회귀 검증했다.

## 2026-07-23 — Issue #11 마감 정본 감사

- 활성 허브·로드맵·UI·QA·아키텍처·연출·학습 문서에서 Issue #11의 오래된 `NOT_RUN` 문구를 기술 검증과 실제 사용자 품질 검수로 분리했다.
- Windows UI Automation, 절차적 SFX, DEBUG 대표/최악 장면 성능 표본은 기술 증거 `PASS`로 기록하고, 실제 보조기기 사용성·주관적 음향/모션·Release 목표 사양은 STEP 14/배포 Gate의 `NOT_RUN`으로 유지했다.
- 다음 제품 작업은 STEP 12 비치팅 AI, STEP 13 종료·재시작, STEP 14 플레이테스트로 정렬했다. Draft PR/Issue 통합은 별도 운영 작업으로 남긴다.
- 활성화되지 않은 과거 Plan·보류 가설·구형 인수인계 확장 파일은 사용자 승인에 따라 삭제했다. 복구가 필요하면 Git 이력을 사용한다.

## 2026-07-23 — Issue #13 합·방어·필중 및 STEP 12~14

- 같은 수의 유효 공격은 합으로 정산하고, 속공은 이동보다 먼저 위치를 처리하되 공격군에서는 일반 공격과 동시 판정하도록 갱신했다.
- 막기는 방어도 차감 뒤 같은 수 반감, 태세 강화 방어도 6, 파공검기 필중의 회피 무시를 현재 규칙·데이터·표현 이벤트에 반영했다.
- 공개 상태 최소 AI와 전투 종료·재시작을 구현했다. MCP Godot 런타임에서 합 6 대 8, 동점 합, 파공검기 필중 대 회피, 4/7·30 체력 재시작과 포커스 순서를 확인했다.
- STEP 14의 사람 관찰·보조기기·주관적 음향/모션·Release 성능은 기계적 증거로 대체하지 않고 `NOT_RUN`으로 남긴다.
