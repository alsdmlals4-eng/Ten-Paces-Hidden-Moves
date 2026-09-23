# 강호행로·기연·DDD와 HTML 검수 통합

상태: USER_APPROVED_IMPLEMENTATION_IN_PROGRESS. 승인: 2026-09-23 사용자의 “좋아 권장안대로 진행해”. 기준 main: 2dfa2a6a9b846276869a8084f7be3a3ab3ef7f67. Base 최신 main 관측: 23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef. 특정 SHA를 영구 기준으로 사용하지 않는다.

## 승인 범위와 보호

- 첫 연결 구조도/아틀라스를 유지하고 게임 이해 첫 설명을 현재 기획서·대상·SWOT·DDD로 확장한다. 승인된 과거112항목과 원화/PDF는 보존한다.
- DDD는 사용자가 정의한 Dopamine Driven Development: 핵심 쾌감·보상 경험을 먼저 구현·관찰·교정하는 개발 관점이다. 생물학적 수치나 자동 FUN_PASS를 주장하지 않는다.
- 강호행로는 휴식/수련/정탐/무작위 이벤트. 3후보 중1선택×비무 사이4회, 전체10비무를 유지한다. 조사 활동은 신규 회차에서 정탐으로 통합한다.
- 기연은 무작위 사건에서 얻는 회차 한정 자동 효과. 장착 제한 없이 고유 효과를 축적한다. 발동 조건/상한/중복과 처리 순서를 데이터에 명시하고 재귀 발동을 금지한다. 새 여정에서 초기화한다.
- 사건 결과와 획득 이력은 회차에 고정해 이어하기/중복 입력으로 재추첨·중복 지급하지 않는다. 기존 저장은 기존 규칙으로 계속한다.
- 무공 성수·기술 효과를 원본에서 사람용 표로 파생하며 HTML에서 전투 규칙을 다시 계산하지 않는다.
- 외부 브라우저와 AI 검수는 동일한 loopback 읽기 전용 서버를 이용한다. 실행 진입점에서 현재 발행본 검증·서버 재사용/복구·브라우저 열기를 처리한다. 공개 노출·전역 설정·플러그인 변경 없음.
- 원래 작업 폴더의 dirty45개와 별도 PR342 후보를 보존한다. PR342 성장v3/v4·UI/모션과 신규 변경의 저장/consumer 경계를 대조한다. 미완료 후보를 main 구현으로 표시하지 않는다.

## 구현 순서 / 완료 기준

1. 접속/이미지: 유효 세션 재사용, 죽은 세션 재실행, 발행본 변경 감지, 외부 Chrome 실제 로딩. 지연 로딩 실패에 복구 안내. 경로·hash 검사와 실제 decode를 구분.
2. 기획서/SWOT/DDD/성수·기술 표: 기존 owner 갱신 → HTML 파생 → 구조도·개별 항목 링크 검증. 과거 승인 내용과 현재 상태 구분.
3. 사건·기연: 구조화 데이터 → 순수 규칙/저장 → 전투/행로 UI 소비자 → HTML 도감. 조건/경계/재시도/구형 저장 회귀 RED→GREEN.
4. 전체 검토2회(동일 승인 범위 공유), 영향 회귀, 실제 Godot 실행 및 브라우저 검수, 누적 일지/Active Context, 정상 PR 검사·병합·main 재확인.

## 근거·대안·가능성

CURRENT_SOURCE_RELEVANCE_CHECK: 기존 docs/blueprint/RESEARCH_20260910.md와2026-09-23 읽기 전용 진단 재사용. 새 기연 판단은 Slay the Spire 공식 소개 https://store.steampowered.com/app/646570/Slay_the_Spire/ 의 유물 상호작용·획득 대가·사건/경로 선택을 참조. ADAPT: 무작위 획득+계획 가능한 활용. DO_NOT_COPY: 덱·손패·드로우·전투 구조/외부 자산. 기존 조사 문서의 유물 제외는 당시 범위로 보존하며 이번 승인 범위에서는 대체된다.

대안: 임시 URL만 전달(재접속 실패 반복), 공개 호스팅(불필요한 공개·운영 범위), 로컬 실행 진입점(채택). 기연 영구 계정 성장/장착 슬롯은 미채택; 회차 한정 자동 적용을 채택한다.

FEASIBLE: Windows Python/Chrome와 기존 HTML 빌더·loopback 서버 사용 가능. Godot 신규 효과는 실제 engine/fixture 검증 후 완료 판정. 저장 호환은 관련 PR342와 exact source 대조 필요. 사람 재미/Android/최종 신규 자산 승인은 NOT_RUN이며 독립 구현을 막는 조건이 아니다.

## 실행 기록

- Work Mode BUILD; Skill ten-paces-game-design/rule-update, ten-paces-verification/html-blueprint-review·regression·runtime-validation. 승인안 실행은 기존 계약/기록을 재사용하며 별도 인터뷰·중복 계획을 만들지 않는다.
- 시작: router validator PASS, latest main/관련 PR/Base 확인, 격리 branch 생성. 신규 게임 실행 NOT_RUN. 아래 진행·증거를 누적한다.


### 구현 및 검토 1/2 교정

Decision ID: TEN-DEC-20260923-GIYUN-DDD-BLUEPRINT-01.
새 회차는 schema5를 사용한다. PR342의 별도 성장 schema3/4와 충돌하지 않으며 기존 schema1/2의 내용 식별값과 규칙을 보존한다. 6기연/6사건을 추가했고 고유 획득·중복 수련 전환·체력 대가·시드 고정과 실제 해결 후 조건부 혜택을 연결했다. 반진 옥패는 기존 준비 효과와 분리된 giyun_attack_bonus(0~4)를 저장하며 사거리 안의 다음 기초 공격에서 한 번 소비한다. 절초/무공/이동/준비 후처리에서 임의 소비하지 않는다.

독립 전체 검토1/2 CHANGES_REQUIRED: 합 양쪽 복제 기록으로 인한 허위 명중/피격, 준비 후처리의 보너스 소멸, 무공 방어 누락, 사건 체력 대가 대조 누락, route_start_resources 미검증을 발견했다. 실제 합 승패/대기 후 공격·실제 무공 방어·잘못된 저장 경계 회귀로 교정했다. 최초 RED 로그는 output/blueprint/giyun-review1-red.log 및 giyun-save-review1-red.log. 첫 전체538검사 중2실패(고정 rest를 가정한 기존 fixture와 교정 중 실행한 저장 반례)를 통과로 세지 않는다. 새 선택지 fixture를 고정 사건 선택으로 교정했다.

Godot4.7.1 실제 렌더: 보유6개 사건 선택 fixture. docs/blueprint/evidence/giyun-route-20260923.png(960×600 렌더; 창 요청960×640). 사용자 저장은 비활성화했다. 이 캡처는 실제10전 플레이·사람 재미·Android 증거가 아니다. UI 테스트 초기 좌표 단위를 창 크기와 혼동한 실패를 논리 viewport 기준으로 교정했다.

외부 Chrome에서 현재 기획서/DDD/SWOT, 10권의 성수·기술 표와 16인 이미지 표시를 확인했다. 기연 도감·전체 항목·원본·PM을 같은 파생 화면에 연결한다. 기존 영상은 원래 캡처 시점의 근거이며 새 기연 전투 촬영으로 표시하지 않는다.


### 전체 검토 2/2 및 집중 검증

독립 전체 검토2/2: P0/P1 없음, P2 세 항목(반복 이미지 실패에서 복구 안내 소실, schema5 route id 필수 타입 누락, combat state_before actor 타입 검사 순서)을 교정했다. 추가 전체 검토는 하지 않고 해당 손상 입력과 반복 실패 UI의 집중 회귀를 수행했다. GIYUN_RUN PASS / VARIABLE_COMBAT_CODEC PASS(160기존 편성+신규 기연 bonus checkpoint)에서 SCRIPT ERROR 없음. 초기 RED는 출력 마지막 PASS 문구가 있어도 SCRIPT ERROR 때문에 실패로 유지한다.

HTML39검사 PASS, 676표시/6876내부 링크 PASS(실제 브라우저 증거와 별도), 승인 운영 계약 validator PASS, 일회 승인·adapter 관련9검사 PASS. 외부 Chrome의 무공3삽화 및 기초10기술 atlas(1536×1024) 실제 decode·표시를 확인했다. 실행 진입점의 동시2회 호출은 초기 PermissionError를 재현하고 byte lock 획득 전에 쓰지 않도록 교정한 뒤 동일 주소 반환 PASS. 종료된 preview 서버는 진입점 재실행으로 복구 확인했다.

최종 전체 회귀 이전의538개 묶음은537PASS/실제 프로세스 pending reward 실패1을 남겼다. 이후 같은 전체 프로세스 종료/복원 검사를 고정된 소스로 재실행해324.736초 PASS를 확인했다. 전체 회귀와 원격 검사는 아래에 완료 결과를 추가한다. 준비 중 import metadata를 이동해 실행 준비가 깨진 시도는 제품 PASS로 세지 않았고, 동일 SHA256 복원 후 필요한 runtime 회귀를 다시 수행했다. 최종 정리는 런타임 검증 종료 후 수행한다.


### PR348 원격 검사 교정

첫 원격 검사(35802372158)는 기존 combat bridge fixture가 휴식1회를 가정하면서 새 경로의 첫 선택지인 휴식을 반복해 자원 기대값3건이 실패했다. 제품 자원 전달을 바꾸지 않고 새 시드 경로에서 수련/정탐과 휴식1회를 명시적으로 선택하도록 교정했다. 같은 실제 bridge 검사와 이후9개 native 검사를 로컬 재실행해 PASS, SCRIPT ERROR 없음. 이 실패는 초기 원격 결과로 보존한다.

Windows 더블클릭 실행 진입점은 검증한 Python 환경을 사용하도록 `python`으로 맞췄다. 실제 cmd 실행에서 HTML 재생성·서버 복구·외부 Chrome 열기와 종료코드0을 확인했다. `py -3`가 선택한 별도 Python의 PIL 누락은 제품 실패와 구분하며 전역 패키지/설정을 바꾸지 않았다.
