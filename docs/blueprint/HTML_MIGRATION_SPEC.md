# 십보강호 HTML 블루프린트 전환 설계

상태: HTML_MIGRATION_VERIFIED — 2026-09-22 승인 범위 구현·검수 후 PR344 main 병합 및 tree 일치 확인. 신규 게임 전체 완성/사람 재미/출시 승인을 뜻하지 않는다.
관측일: 2026-09-22. 방향 승인: “HTML에서 PM과 구현 확인”, “완전 이동 후 PDF 별도 생성 안 함”, “십보강호로 가자”.
이번 산출물은 위 방향의 프로젝트별 구체 설계다. 게임 규칙·자산의 새 승인이나 공개 배포 승인을 만들지 않는다.

## 1. 목표와 사용 경험

사용자는 한 진입점에서 “어떤 게임인가 → 무엇을 만들기로 했는가 → 어디까지 실제 구현됐는가
→ 무엇을 직접 확인할 수 있는가 → 다음 무엇을 할 것인가”를 이해한다.
기존 블루프린트의 설명·시각 자료·학습 가치를 보존하고 PM만 있는 요약 보드로 축소하지 않는다.

HTML은 저장소 책임 원본에서 생성하는 사람용 파생 뷰다. 저장소 Markdown/JSON, 코드·씬·자산,
승인 기록과 검증 증거의 역할은 유지한다. HTML 수정이나 브라우저 체크만으로 정본을 바꾸지 않는다.

2026-09-22 추가 사용자 요구: 확정·승인 이미지와 모션을 포함해 중간보스·적·배경·무공,
구현 작업·PM을 Godot 밖에서도 확인한다. 사용 목적은 사용자 검수와 다른 채팅/AI의 작업 재개다.
다음 작업자가 로컬 원본과 HTML을 함께 확인해 누락·중복 작업을 피하도록, 승인·사용처·잔여 작업을
같은 항목으로 연결한다. HTML만 읽고 원본 fresh-read를 생략하거나 과거 화면을 현재 구현으로 삼지 않는다.

전환 완료 뒤 사람용 기본 산출물은 HTML 하나다. 정기 블루프린트 PDF와 월간 작업일지 PDF의
중복 생성을 중단하고 작업일지는 기존 작업 기록을 HTML에서 날짜별로 보여준다.
기존 PDF·승인 해시·원화는 보존한다. 별도 제출 요청이 있을 때만 PDF를 만든다.

## 2. 실제 확인한 현재 상태

| 대상 | 확인된 사실 | 설계에 미치는 영향 |
|---|---|---|
| 최신 main | e5ec55e622d7c050e885e5bbdb698df9fd9bb8d3 | 이번 설계의 관측 기준이며 영구 current pin 아님 |
| 기본 작업 폴더 | main 751f4ee0, 코드·import 미커밋 변경 있음 | 기존 폴더는 변경하지 않고 격리 branch 사용 |
| 승인 블루프린트 | current_user_planning_status.json에 112쪽 PDF와 47개 visual input의 승인 해시 기록 | 원본 내용·승인 계보 보존, 생성 성공과 제품 승인 구분 |
| 기존 HTML | docs/PROJECT_OPERATING_DASHBOARD.html은 운영 성숙도·Base route 파생 화면 | 전체 블루프린트 또는 제품 PM이라고 주장하지 않음; 생성 라우터 직접 덮어쓰기 금지 |
| PDF 생성 | tools/build_human_blueprint_complete.py의 PAGE_ORDER가 112페이지를 연결 | 기존 서술·데이터·그림 연결을 재사용하되 좌표 기반 PDF 레이아웃을 반응형 HTML로 복제하지 않음 |
| PM 충돌 | current_operating_state.json의 active_planning_pr=337, GitHub에서 #337은 2026-09-09 병합됨 | 상태 정합성 교정이 필요; 낡은 JSON을 그대로 최신 카드에 표시하지 않음 |
| 제품 후보 | #342 OPEN/Draft, head d2e1edae7930c11e6c04cfbe269a06c4d3075f14 (관측 시점) | main 완료와 분리; 다른 작업의 모션·원화·저장 변경은 자동 흡수하지 않음 |
| 실행 구성 | 실제 main scene은 scenes/run/vertical_slice_shell.tscn, gl_compatibility, Windows export preset | 웹 가능성은 있으나 Web preset·export·브라우저 실행 증거 없음 |

112쪽과 47개는 이번에 읽은 승인 기록/생성 receipt의 수치다. PDF 전체 재렌더와 원화 전체 해시 대조는
이 설계 단계에서 새로 수행하지 않았다. 구현 전 coverage baseline에서 다시 검사한다.

## 3. 선택한 방법과 제외한 방법

| 방법 | 판정 | 이유 |
|---|---|---|
| PDF를 HTML 안에 삽입하고 PM 링크만 추가 | 제외 | 본문 검색·상태별 탐색·자산별 요청이 약하고 PDF 정기 생성이 계속 필요 |
| 새 웹 PM 앱·DB·게임 JS 시뮬레이터 구축 | 제외 | 상태와 게임 규칙이 중복되고 인증·운영·동기화 비용 증가 |
| 기존 저장소 원본에서 정적 HTML 생성 + 실제 Godot 실행 증거 연결 | 채택 | 기존 승인·데이터·테스트 재사용, 추가 서비스/결제 없이 시작 가능 |

기존 Python 문서/데이터 도구를 우선 재사용한다. 새 UI 프레임워크·DB·MCP·상시 서비스·플러그인 설치는
기본 범위가 아니다. 프로젝트별 경로와 표시 항목만 얇은 설정으로 두며 범용 플랫폼을 만들지 않는다.

## 4. 화면 구성

첫 화면은 승인된 화면 아틀라스와 현재 상태 요약이다. 기본 탐색은 다음 역할로 구분한다.

- 게임 이해: 기존 6부의 설명, SWOT·독창성, 행로·전투·상대·무공·구현 학습.
- PM: 승인 목표와 작업 목록, 의존성·차단·검토 대기·다음 작업, 목표 일정/예상 일정.
- 구현 확인: 기능·화면·상대·무공별 실제 코드/씬/자산/테스트 근거와 실행 진입점.
- 자산·모션 도감: 확정·승인된 원화·초상·전신·배경·UI·효과·모션을 실제 파일로 열람하고 사용 대상/작업과 연결.
- 검수·기록: 캡처·영상·검사 결과·사용자 검수 상태·변경 이력.

본문은 한글 설명을 먼저 표시한다. 코드 경로·ID·기술 상세는 접을 수 있지만,
미구현·미검증·자료 충돌 경고는 접힌 기술 상세에 숨기지 않는다.
목차·검색·필터·이미지 확대·키보드 조작·좁은 화면 읽기를 지원한다.
시각 기준은 기존 종이/먹색/금색 계열을 재사용하며 신규 원화를 만들지 않는다.

모든 항목은 안정적인 ID와 깊은 링크를 갖는다. 날짜별 새 HTML을 사용자가 찾아다니지 않게 한다.
출력 진입점 제안은 output/blueprint/index.html이다. 구현 뒤 최초 경로를 고정하고 원본 위치와
발행 위치를 구분한다. 공개 인터넷 주소·유료 호스팅·원격 접근권한은 이번 범위가 아니다.
로컬 파일이 다른 기기나 다른 AI에서 자동 접근되는 것으로 설명하지 않는다.

### 4.1. 자산·모션 도감과 항목별 확인

| 대상 | HTML에서 확인하는 내용 | 함께 보여줄 상태/근거 |
|---|---|---|
| 적·중간보스·인물 | 기존 데이터의 분류·이름·역할, 승인 초상/전신, 연결 무공·등장 구간 | 원본 ID, 선정/승인 범위, main/PR 후보, 실제 소비 씬·데이터 |
| 배경·UI·이펙트 | 실제 이미지 확대, 투명 배경 확인, 원본/런타임 변환본 비교 | 승인 해시·출처, 사용 화면, 미연결/대체 이미지 사용 여부 |
| 모션 | 원본 시트·개별 포즈, 존재하는 프레임/타이밍 데이터에 따른 재생·정지·프레임 이동·속도 조절 | 포즈·영역·pivot·타이밍 출처, 모션 승인 범위, 실제 엔진 영상/캡처 |
| 무공 카드 연출 | 카드→프리셋→포즈/이펙트/효과음→실제 소비 코드 추적, 존재하는 합/카드 연출 실행 영상 | 준비/접근/타격/복귀 및 합 결과의 실제 연결 여부, 테스트·미검증·잔여 PM |

모든 승인 자산을 inventory하며 대표 예시만으로 도감 완료를 판정하지 않는다. 후보·미승인·역사 자산은
승인 목록과 구분하되 필터로 찾아볼 수 있게 하고, 같은 파일의 여러 사용처는 재사용 관계로 연결한다.
승인됐지만 아직 미연결인 자산도 보이며, 원본 파일 누락을 임의의 다른 그림으로 메우지 않는다.
중간보스 분류가 원본에 없으면 HTML 편집자가 새 역할을 발명하지 않는다.

정적 포즈만 있는 경우 포즈 모음으로 표시한다. 실제 애니메이션 데이터가 없는 자산에 임의 타이밍을
넣어 승인 모션처럼 보여주지 않는다. 검증된 atlas 영역이 없으면 시트 전체를 먼저 보이며 자동 균등
분할로 무기·인물을 잘라내지 않는다. 웹 프레임 재생은 ASSET_PREVIEW이며 게임의 이동·충돌·피해·합
규칙을 JS로 재구현하지 않는다. 실제 카드 연출은 원래 Godot 실행에서 얻은 영상 또는 검증된 export로 확인한다.
모든 애니메이션은 정지 상태에서 시작하고 반복·배속은 열람 조작임을 표시한다.

### 4.2. 다음 채팅/AI의 재개 경로

같은 항목 ID로 기획→승인 자산→실제 사용처→검증→PM→다음 작업을 연결한다. 첫 화면의 재개 안내에는
저장소/작업 폴더·branch·관측 revision·미커밋 입력 유무/해시·관련 PR·보호할 변경·현재 작업·다음 안전 작업,
필수 읽기 순서와 검증 명령의 원본 위치를 제공한다. 과거 검증은 대상 revision과 함께 남긴다.
다른 AI가 읽을 수 있는 표시용 인덱스에도 동일 ID·상태·원본 경로를 내보내되 편집 정본은 만들지 않는다.

재개용 요청 복사는 현재 위치와 원본 읽기 순서를 묶어 제공한다. 로컬 파일 접근 권한이 있는 AI는
원본을 재확인하며, 권한이 없는 외부 AI에는 사용자가 자료를 전달해야 함을 표시한다. 자동 업로드는 하지 않는다.
다른 PC용 묶음이 필요하면 상대 경로 자산과 표시 인덱스를 함께 전달하고, 원본에 접근할 수 없는 항목은
현재 원본을 확인한 것처럼 표시하지 않는다. HTML 자체가 저장소 변경을 실시간 감지한다고 가정하지 않는다.
작업 단위 종료 시 생성/검사 경로를 기존 마무리 절차에 연결하고 생성 시각·원본 revision·최근 GitHub 관측을 표시한다.
오프라인 HTML은 마지막 발행 시점의 화면이며, 변경 후 재생성 전에는 최신이라고 보증하지 않는다.

## 5. 원본과 모듈의 책임

| 책임 | 재사용 원본/consumer | 신규 변경 방향 |
|---|---|---|
| 설명·읽기 순서 | docs/blueprint/READING_STRUCTURE.md, docs/01_GAME_DESIGN.md, docs/02_COMBAT_RULES.md, 기존 PDF builder | 독립 설명 원본이 없는 builder 내부 문구만 기존 blueprint owner 아래 구조화; HTML/PDF용 복제 서술 금지 |
| 무공·상대·성장 | docs/blueprint의 JSON·단계표, 실제 data와 catalog | 같은 원본을 읽고 승인 설계 값·실제 코드 값·실측 값을 따로 표시 |
| 자산 | ART_SELECTION.json, ASSET_READINESS.json, assets/ASSET_MANIFEST.json, blueprint_final_approval | 파일·해시·승인·consumer 연결; 도감 원화를 전투 모션 완료로 오인하지 않음 |
| PM | docs/04_ROADMAP.md, current JSON, Active Context, 관련 receipt와 GitHub 관측 | 작업 원본은 기존 owner 유지; 생성한 표시 모델은 편집 정본이 아님 |
| 발행 | 기존 Python 도구와 검증 | 입력 수집/검사 → 표시 모델 → HTML 렌더를 작은 책임으로 분리 |
| 실행 근거 | 실제 Godot scene/build/test/capture와 검증 기록 | 웹 데모·자산 미리보기·실제 엔진 증거를 분리 |

구현 때 필요한 coverage manifest는 원본 식별자→HTML 항목ID→자산/근거 링크만 저장한다.
전체 설명·수치를 별도 JSON에 복제하는 두 번째 기획서나 PM DB를 만들지 않는다.
기존 builder 문구를 옮길 때는 승인본의 고유 설명을 먼저 대조하고, 역사 PDF bytes는 변경하지 않는다.

출력 metadata는 source revision, 생성 시각, 입력 해시, GitHub 조회 시각, evidence revision을 포함한다.
외부 상태 조회 실패는 마지막 관측 시각과 OFFLINE/STALE로 표시하고 최신으로 가장하지 않는다.
필수 원본 누락·ID 중복·해시 불일치·깨진 참조는 생성 실패로 처리하고 마지막 정상본을 유지한다.
부분 생성 결과를 현재 정본처럼 덮어쓰지 않는다. 서비스워커는 초기 범위에서 제외한다.

## 6. PM과 일정

- 완료 판정은 승인 작업의 수용 기준과 필수 근거에서 파생한다. 문서 페이지·체크 클릭·테스트 개수로 제품 완성률을 만들지 않는다.
- 완료/전체 작업 수는 분모와 제외 사유를 함께 보여준다. 문서·구현·실행·사용자 검수의 상태를 분리한다.
- IN_PROGRESS 1, VERIFY_REVIEW 1을 기본으로 기존 WIP 계약을 재사용한다.
- 계획 날짜·추정 범위·실제 시작/완료일·의존 차단을 구분한다. 기록이 없으면 미정이며 날짜를 발명하지 않는다.
- 기존 owner에 없는 필요한 일정 정보만 해당 owner에 보완한다. HTML에서 별도 수동 일정을 관리하지 않는다.
- main과 PR 후보를 별도 묶음으로 표시한다. PR 통과·병합과 Human/최종 자산/출시 승인을 섞지 않는다.
- 낡은 PR337 checkpoint는 후속 구현에서 실제 영향 consumer와 현재 승인 작업을 대조해 교정한다.
  PR342라는 숫자로 단순 치환하거나 그 후보를 main 상태로 승격하지 않는다.

## 7. 실제 구현 확인과 최소 테스트 경로

시각 목표/와이어프레임은 DESIGN_PREVIEW, 이미지·프레임·음원은 ASSET_PREVIEW,
실제 코드·씬으로 실행한 결과는 RUNTIME_EVIDENCE로 구분한다.

첫 실행 경로는 main의 실제 새 여정→시작 무공→브리핑→준비/해결 장면 중 연결 가능한 대표 흐름이다.
무공 또는 상대 1개에서 승인 그림, 실제 데이터, consumer, 실제 화면 근거까지 추적한다.
이는 최초 연결 시험의 최소 단위이며 전체 자산·모션 도감이나 최종 전환의 완료 범위가 아니다.
새 검증은 현재 revision·환경·입력·결과·캡처를 기록한다. 과거 캡처에는 관측 revision을 유지한다.

웹 실행:
- 기존 코드/씬을 그대로 쓰는 격리된 export 적합성 검사 후 허용한다.
- 같은 게임을 JS로 다시 구현하지 않는다. 브라우저 재생 실패·성능/저장 차이를 감추지 않는다.
- 개발자용 addon·비밀·문서·검수 원본의 불필요한 export 포함을 확인한다.
- 실제 사용자 저장과 테스트 저장은 분리하고 기존 여정을 덮어쓰지 않는다.
- 웹 적합성이 입증되지 않으면 HTML에 실제 PC build/실행 설명과 검증 영상을 연결한다.
  이를 “브라우저 안 게임 실행 성공”으로 표시하지 않는다.
- 테스트 빌드가 없으면 실행 버튼은 이유와 함께 사용할 수 없다고 표시한다.
  HTML 링크가 로컬 exe를 자동 실행한다고 가정하지 않으며 임의 명령 실행 브리지를 만들지 않는다.

HTML 내 브라우저 실행 성공을 Android 네이티브·실기기·사람 재미 검증으로 승격하지 않는다.

## 8. 검수 요청·보안

항목 선택 → 현재 revision·항목ID·바꿀 부분·보호할 부분을 포함한 요청 문구 생성 →
사용자가 대화에서 승인 → 저장소 기존 Decision/작업 기록 갱신 → readback → HTML 재생성 순서다.

브라우저 저장은 요청 초안 편의 기능일 뿐 승인·공유 상태 정본이 아니다.
HTML에 토큰·API 키·계약 원본·개인정보·불필요한 소스를 포함하지 않는다.
본문 접기는 접근 통제가 아니다. 원본 문자열·경로·외부 URL은 escape/허용 범위 검사하고
스크립트 주입·상위 경로 탈출·임의 파일 공개를 막는다.
새 공개 호스팅/기기 간 공유/인증 변경은 사용자 결정 전 수행하지 않는다.

## 9. 전환 완료 조건과 회귀

1. 승인 112쪽의 고유 설명·표·이미지 역할을 항목별로 inventory하고 HTML에서 도달 가능함을 대조한다.
   페이지 수 그대로 복제할 필요는 없지만 고유 내용 누락 0, 변경 의미의 owner와 근거가 있어야 한다.
2. 승인 visual input의 파일/해시를 확인하고 선정/승인/구현/검증 상태가 보존된다.
   기존 47개 입력에만 한정하지 않고 현행 승인 자산·모션 전체와 후보 목록을 대조한다.
   모든 대상은 실제 미리보기 또는 파일 누락/재생 불가의 명시적 상태를 갖고, 필수 승인 파일 누락은 전환을 막는다.
   포즈만 있는 자산을 모션 완료로 세지 않는다. 재생 가능한 모션의 조작과 원본 데이터 일치를 검사한다.
3. PM 원본 충돌을 교정하거나 미해결 충돌로 표시한다. source/head 차이를 숨기지 않는다.
4. 검색·목차·deep link·이미지 확대·키보드/좁은 화면·빈/차단 상태를 실제 브라우저에서 검사한다.
5. 정상 입력, 누락 원본, 중복 ID, 잘못된 상태, stale evidence, escaping, 잘못된 링크의 자동 회귀를 둔다.
6. 대표 기능의 실제 Godot 실행 근거와 사용자 실행 경로가 연결된다. browser-only 실행이 안 되면 PC 경로 한계를 명시한다.
7. 새 세션이 AGENTS→Active Context→HTML/spec→원본/테스트를 찾아 재개할 수 있다.
   대표 적·중간보스(원본에 존재하는 경우)·배경·무공에서 승인 파일/사용처/검증/잔여 PM의 왕복 탐색을 검사한다.
   기존 완료 작업과 미연결 자산을 구별하고 main/후보·오래된 화면·미커밋 입력을 식별할 수 있어야 한다.
8. 전체 구현 후보를 정확히 2회 적대 검토하고 필수 CI/정상 병합/main readback까지 확인한다.
9. 실제 전환 뒤 프로젝트 AGENTS·통합 계약·Reading Structure·문서 지도·관련 테스트의 PDF 정기 생성 요구를 함께 교정한다.
   월간 작업일지 PDF 의무도 이때 해제한다. HTML 전환이 아직 안 된 지금은 기존 owner를 먼저 제거하지 않는다.

설계 작성 당시 구현·브라우저·Godot·Human·전환·PR/병합은 NOT_RUN이었다. 현재 결과는 아래 누적 검증 기록을 따른다.
설계에 대한 self-review와 기준선 테스트를 이 항목들의 PASS로 세지 않는다.

## 10. 보호·롤백·공용화

보호: 사용자 원 작업 폴더, PR342와 다른 작업 branch, 승인 PDF/원화, 제품 규칙·저장 데이터,
채택 Base 생성 라우터·release lock. 이번 설계 커밋은 문서와 시작 receipt만 변경한다.

발행 실패는 마지막 정상 HTML로 복원하며 원본·승인 snapshot은 손대지 않는다.
전환 정책을 되돌릴 때는 해당 정책 커밋만 회복하고 게임/저장 변경을 섞지 않는다.
Base 전역 발행 계약의 일괄 변경과 다른 프로젝트 일괄 이관은 이 설계의 완료 범위가 아니다.
십보강호 pilot의 실제 consumer·회귀 결과 후 공용화 후보로 평가한다.

## 11. 근거·현재 실행 기록

현재 조사 근거: AGENTS/BASE_RULES_VERSION/통합 계약/Active Context/Registry,
Reading Structure, PDF builder와 receipt, approval JSON, PM owner,
project.godot/export_presets, GitHub main 및 #337/#342.

외부 원출처(2026-09-22 본문 확인):
- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
  Compatibility/WebGL2·별도 export·브라우저 저장/오디오 차이 확인. 현재 프로젝트 웹 성공 증거 아님.
- https://storybook.js.org/docs/essentials/controls
  상태별 인터랙티브 확인 패턴만 ADAPT. Storybook 설치/도입이나 생산성 실측 증거 아님.

Base main 관측: 23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef.
입력 연결: docs/operations/2026-09-22_HTML_BLUEPRINT_WORK_CONTRACT_RECEIPT.json.
Work Mode PLAN; intake route/contract, brainstorming architectural design, isolated worktree.
AgentMemory 도구 미제공으로 세션 복원은 미실행. 저장소/GitHub readback으로 대체했다.
게임 rule-update Skill은 trigger 비대상으로 미사용. PDF 전체 검수·Godot live Skill은 실행 단계까지 보류한다.

기준선: test_lean_work_execution_adoption 11개, test_opponent_stage_blueprint 1개 통과.
시작 receipt: phase=start PASS (기록 일관성 검사, 전체 구현 증거 아님).
설계 self-review: 중복 PM owner, 후보/main 혼합, PDF 조기 중단, 월간 PDF 잔존,
브라우저 실행 과장, 승인 snapshot 손실, 비밀 노출을 점검해 위 경계에 반영했다.
전체 구현 적대 검토 2회는 아직 수행하지 않았으며 완료로 기록하지 않는다.

2026-09-22 재개 설계 보완: Work Mode PLAN / managing-design-documents / update.
최신 사용자 요구의 자산·모션 전체 열람과 다른 채팅/AI 재개 경로를 기존 초안에 추가했다.
source relevance는 같은 날짜·같은 파생 HTML 결정의 유효한 조사와 현행 자산 owner를 재사용했다.
운영 계약 검사 PASS. 실제 HTML·미리보기·Godot 실행과 전체 파일 coverage는 여전히 NOT_RUN이다.
설계 한정 검토에서 대표 1개를 전체 완료로 오인할 위험, 포즈를 모션으로 오인할 위험,
오래된 정적 HTML을 자동 동기화로 오인할 위험을 위 수용 기준으로 교정했다.

다음: 승인된 아래 구현 순서대로 수행한다. 같은 범위는 재승인하지 않는다.
기술적인 파일 분할/테스트 세부를 사용자에게 결정시키지 않는다.

## 12. 승인된 구현 순서와 누적 실행 기록

2026-09-22 추가 명시 요청: AI(GPT·Codex·Claude)가 HTML을 직접 열고 조작·검수할 수 있는 경로를 마련하며,
Archify를 다이어그램 기술로 상세 확인·흡수한다. 구현 스코프는 loopback 읽기 전용 미리보기와 원본 연결 구조도다.
프로젝트 QA Skill의 `html-blueprint-review` 모드에 적용 방법을 연결했다. 전역 설치나 외부 공개는 포함하지 않는다.
외부 근거와 채택/비채택: `skills/qa/ten-paces-verification/references/html-blueprint.md`.
자동 배치 엔진 전체 이식보다 현재 3개 설명 구조도에 맞는 작은 SVG 모델/검사가 유지 비용에 맞는다.
실제 원본·관계 ID·직접 연결 강조·키보드 탐색·실행 증거 분리를 채택하고, 가상 runtime·게임 JS 재구현은 제외한다.
원 file:// 접근은 브라우저 정책으로 차단됐다. 사용자는 첫 화면·도감 정상 표시와 인물 화면을 직접 확인했다.
이후 manifest 파일만 허용하는 별도 loopback HTTP 미리보기에서 Codex IAB 실제 접속 성공을 확인했다.
이는 파일 URL 정책 해제나 다른 클라우드 AI의 접속 성공이 아니다.

1. CONTENT: 기존 builder의 본문 구성 함수를 공유해 112개 설명 단위를 추출한다. PDF bytes를 건드리지 않고 승인 입력 해시를 확인한다.
2. ASSETS: 승인 원본·자산 manifest·소비처를 도감에 연결한다. PR342 자료는 정확한 후보 revision으로 별도 읽는다.
3. PM: 기존 작업·날짜별 기록·GitHub 관측을 투영하고 PR337 상태를 교정한다.
4. VIEW: 로컬 HTML 검색·필터·자산 확대·모션 탐색·재개 요청 복사와 원본 연결을 구현한다.
5. VERIFY: 실패 회귀→통과, 브라우저 검증, 원본 coverage, 실제 엔진 증거/실행 경로를 확인한다.
6. DELIVER: 전체 검토 2회, 정책·읽기 경로 교정, 정상 PR/검사/병합/main 재확인. 전환 gate 미충족 시 PDF 정책을 유지한다.

- 2026-09-22 BUILD / executing-plans + building-project-visual-dashboards / 구현: 테스트 모듈 부재의 RED 확인. 공유 인터페이스는 본문 블록→표시 모델→HTML, 자산 ID→승인/사용처/PM 링크다.
- Ruling: 기존 본문을 다른 JSON에 복제하지 않고 builder의 compose()를 공유 원본으로 유지한다. PDF 좌표를 웹 레이아웃에 강제하지 않으며 기존 승인 PDF는 역사 비교 경로로 보존한다.


## 13. 누적 검증 기록

2026-09-22 / 기준 main e5ec55e622d7c050e885e5bbdb698df9fd9bb8d3 / BUILD.
- 112개 설명 단위·47개 승인 입력 해시·기존 승인 PDF bytes를 대조했다. PDF 스킬의 읽기 전용 렌더로112개 원래 페이지의 공간 배치/도식도 각 HTML 항목에 보존했다. 새 PDF를 생성하지 않았다.
- 자산151개(원본·적용본·후보), PM23개, workflow/dataflow/sequence 구조도3개를 연결했다. PR342는 d2e1edae7930c11e6c04cfbe269a06c4d3075f14의 실제 Git blob에서 읽으며 제품 변경을 흡수하지 않는다.
- RED→GREEN: missing display module, approval misclassification, missing approved folder/CSS delimiters, preview boundary, diagrams, rollback publication, approved derivative source relation. 출력 오류 시 last-good 복원, 중단으로 혼합된 발행은 manifest output hash로 거부한다.
- 자동: HTML/preview/diagram/publication + 관련 discovery/vertical-slice/opponent/lean 회귀54개 통과(후속 source-approval 회귀 추가). 원본 렌더311뷰/1470로컬 링크 통과. 실제 브라우저와 별도 증거다.
- 브라우저: Codex IAB HTTP 접속, 포즈 다음/재생(프레임 변화)/정지/배속, 이미지 확대·Esc, 검색과 빈 상태, 구조도 노드 선택/직접 연결/원본 링크, 키보드 Enter, 재개 요청 복사 성공. 844×390/390×844에서 전체 페이지 가로 넘침 없음; 구조도는 자체 가로 스크롤을 사용한다.
- 사용자: 첫 화면·도감 정상 표시와 인물 갤러리 연결을 직접 확인했다. 모든 세부 페이지/게임 재미까지 승인한 것으로 확대하지 않는다.
- Godot: 기존 capture.json·09-11 실제 입력10전/36행로 근거·project.godot 실행 경로를 재사용한다. 현재 새 visible Godot 실행은 NOT_RUN이며 HTML 모션을 runtime 증거로 대체하지 않는다.
- 전체 검토1/2: 정본·실제 변경·untouched 소비처·실행 근거·유지 비용을 함께 검토. 발행 일관성, 공간 학습자료 누락, 파생 자산 승인 연결 누락, 오래된 현재 상태 문구를 교정했다. 독립 검토2와 원격 검사/병합은 진행 중이다.
- 일지: PR342의 기존 `AI_USAGE_EVIDENCE_2026_09.json`을 같은 경로로 선택 보존하고09-22 요약을 누적했다. 과거 제품 작업을 main 완료로 승격하지 않는다.

- 전체 검토2/2: 독립 reviewer가 P0/P1 없음, P2 4건을 확인했다. 승인 PDF의 HTTP 허용 누락, 후보 consumer 설명의 잘못된 파일 링크, 비무 종료/다음 묶음 흐름 구분 누락, 설명 생성 의존 코드의 입력 해시 누락이다. 각 항목을 교정하고 허용 목록 링크 검사/경로 추출 회귀/전투 흐름 회귀/의존 코드 manifest 검사를 추가했다. 추가 전체 검토를 시작하지 않고 이 지적의 집중 재검증만 수행한다.
- 독립 검토의 좁은 화면 승인 페이지 표시 우려에는 너비 제한을 명시했다. 펼친 상태의 실제 브라우저 재검증을 전달 gate로 유지한다.

- 최종 집중 확인: Python 관련58개, Node334개 표시/1603개 허용 목록 내 로컬 링크 통과. 펼친 승인 페이지가390×844/844×390에서 정상 로드되고 전체 가로 넘침 없음. 원래 승인 페이지의 도식도 보존된다.
- PR344 첫 원격 검사에서 Active Context YAML의 PR337이 남아 PM JSON과 불일치하는 문제를 발견했다. 두 현재 owner를 PR344로 교정했고 해당3개 계약과 discovery56개 회귀가 통과했다. 과거337 병합 이력은 별도 보존한다.

- 기존 current_operating_state의 엄격한10필드 schema를 유지하도록 과거337 checkpoint와 관련 후보342 기록을 작업 receipt/관측 원본에 보존했다. schema 검사를 완화하거나 게임 계약을 변경하지 않았다.


## 14. 전환 완료와 이후 운영

PR344는2026-09-22T13:52:49Z에 main `b6c63cd4ed7333d51168f077d199b1b69ec84daf`로 정상 병합됐다.
검토 head c24719ac와 병합 main의 전체 tree 내용이 일치하며 exact-head 원격29검사 PASS/3조건부 SKIP/실패0, 미해결 review thread0을 확인했다.
브라우저에서 승인 페이지 펼침·모션 조작·구조도/원본·검색·복사와 작은 화면을 확인했다. PDF와 코드의 HTTP 실제 응답200도 확인했다.
이후 블루프린트·월간 일지 PDF는 정기 생성하지 않는다. 기존 승인 PDF/원화는 유지하고 날짜별 요약을 기존 월간 JSON에 누적해 HTML로 읽는다.

작업 후 기존 owner/Active Context/일지를 갱신 → `python tools/build_html_blueprint.py` → 관련 검사 → `python tools/serve_html_blueprint.py --no-build`로 실제 브라우저를 확인한다.
서버 주소는 매번 preview-session.json에서 읽으며, 저장된 옛 주소를 준비 완료 증거로 사용하지 않는다.
다음 게임 작업은 PR342의 실제 head와 원래 dirty 작업 폴더·승인 자산/모션 gate를 독립적으로 fresh-read한다. HTML 전환을 그 제품 후보의 main 병합으로 오인하지 않는다.

추가 로컬 전체 회귀는 초기 import cache가 없는 상태에서 시작되어 중단했다. 이 폴더에 exact Godot4.7.1 초기 import를 실행한 뒤 전체523개 검사를473.650초에 통과했다. 근거: `output/blueprint/python-regression-prepared.log`.
초기 import는 종료 code0이지만 기존 editor/addon resource cleanup 경고가 있었다. 신규 visible 게임 실행/Human/Android/출시 검수로 세지 않는다.

병합 main의 Full Validation·platform rights·HTML Blueprint·GodotLiveEditorPilot 워크플로도 통과했다.
초기 import가 만든 metadata186개는 SHA256/원래 경로/복구 안내와 함께 `output/blueprint/manual-delete-candidates/godot-import-20260922`로 보관했다. tracked metadata는 HEAD로 복원했고 원래 프로젝트 폴더와 게임 자산은 건드리지 않았다.

Closeout PR345 첫 최종 head의 원격 product job은 전체10분 한도로 마지막 행로 검사 중 취소됐다(run35738191421). 10전 native 입력은10승/36행로/failures[]로 완료했지만 전체 job PASS로 세지 않았다. 모든 검사/판정/명령을 유지한 채 Linux job 한도를 기존 Windows와 같은15분으로 교정했다. 이 설정만 바꾼 집중 diff 검토 후 새 head 전체 원격 검사를 수행한다.

## 15. 사용자 검수 후 화면 아틀라스·영상 교정 · 2026-09-23

승인: 사용자가 구현 전 이해·계획 재확인을 요청했고, “맞아. 구조도 상자와 아틀라스가 합쳐졌다고 생각하면 될거같아”라고 확정했다. 최초 실패 회귀·설계 초안 이후 이 확정을 받고 UI/영상 구현을 진행했다. 기준 main `28b689cc5889afbe761bdbfd2e7537f9ebfadcaa`.

- 첫 진입은 화면 이미지가 들어간 구조도 8개 상자다. 클릭하면 메인 아틀라스, 시작 무공 10권/30기술의 한국어 효과·영상, 상대 16명/비무 제약, 기초 행동 10개/수 배치, 합·해결, 결과·행로·종료의 본문과 실제 구현 원본을 연다. 다음 화면/브라우저 뒤로가기로 연결한다.
- 전체보기는 112개 설명 본문, 16인 전술·성장, 30기술, 자산151개, PM, 실행 기록, 누적 일지, 재개 정보를 스크롤로 전부 읽는다. 원본 표시 함수를 재사용하며 이미지 지연 로딩·화면 밖 설명 렌더 지연으로 부담을 줄인다. 다른 메뉴의 검색어는 전체보기·상대 브리핑을 제한하지 않는다.
- 실제 Godot4.7.1 기존 장면의 viewport를 렌더 후 기록하고 실제 프레임 시각 간격으로 MP4 36개를 만들었다. 기본6개는 격돌/합 승패/피격/방어/회피/절초의 고정 결과 상황이며, 나머지30개는 기존 판정 코어가 생성한 무공별 이벤트를 사용한다. 기존 포즈 도감과 영상은 구분한다. 재생·정지·배속·구간 탐색을 제공한다.
- 영상은 현재 main의 촬영용 상황이며 실제 캠페인 진행·사람 재미·PR342 추가 연출의 검증이 아니다. 무음이다. 실패/조건 미충족과 정적 표시 위주인 연출도 그대로 드러낸다. 영상36개가36종 고유 캐릭터 애니메이션 완성을 뜻하지 않는다. 미병합 PR342의 접근/타격/복귀 프리셋은 해당 제품 작업에서 별도 확인한다.
- 원본: `tools/html_blueprint_experience.py`의 화면 연결, `tools/html_blueprint_ui/experience.js`, `docs/blueprint/evidence/motion/manifest.json`. 미디어 SHA·제품 입력 해시·촬영 완료 시각과 인코딩 시각을 분리한다. 텍스트 입력 해시는 UTF-8/universal-newline 기준으로 Windows/Linux 차이를 제거한다. 제품 입력이 바뀌면 촬영 근거 재확인 전 발행을 거절한다.
- 보호: 게임 코드/규칙/저장/승인 원화/PDF/PR342/원래 dirty checkout/플러그인·전역 설정. HTML에 게임 판정을 다시 구현하지 않는다.
- CURRENT_SOURCE_RELEVANCE_CHECK: 기존 Archify 조사와 승인 구조도 설계를 재사용. 공식 Godot 촬영 문서 https://docs.godotengine.org/en/stable/tutorials/animation/creating_movies.html 를 확인했다. 기존 연출이 wall-clock 지연을 사용하므로 고정시간 MovieMaker 대신 실제 viewport 프레임/실제 시각 간격을 사용했다. 신규 장르 기획이 아닌 승인 HTML 피드백 교정이다.
- FEASIBLE: 승인 Godot binary/실제 scene/함수로 렌더·촬영 성공. live editor 연결은 없으며 독립 촬영 프로세스다. 첫 import 누락 시도와 잘못된 engine 클래스를 사용한 시도는 stderr 오류로 배제했고 성공으로 세지 않았다. main의 일부 정적 연출은 HTML에서 새 게임 동작으로 꾸미지 않았다.
- 기존 계약의 전체 검토2회는 재사용한다. 이번 집중 독립 검토에서 검색 상태 누출과 합 패배 주체 오류를 발견했다. 검색 독립 렌더, 패배 actor=player→후속 actor=enemy로 교정하고 재촬영·의미 회귀를 추가했다.

검증 명령: `python -m unittest tests.test_html_blueprint tests.test_html_blueprint_preview tests.test_html_blueprint_diagrams tests.test_html_blueprint_publication tests.test_html_blueprint_experience`, `node tools/check_html_blueprint_ui.cjs`. HTTP 영상 Range206/416, 미디어 CSP, source-hash 변경 거절도 포함한다. CI는 같은 검사를 실행하며 ffmpeg/Godot 재촬영을 매 HTML 발행마다 요구하지 않는다.

촬영 재현은 `tools/capture_blueprint_motion.gd`를 승인 Godot로 일반 렌더 실행 → stderr 오류없음/36개 완료 확인 → `tools/encode_blueprint_motion.py --ffmpeg <로컬 ffmpeg> --log <해당 stderr 로그>` → HTML 생성 순서다. 프레임·로그는 `output/blueprint/motion-capture`에 기록하며 실패 시 발행하지 않는다. ffmpeg는 이번 작업의 무시된 도구 폴더에만 준비했고 전역 설치/설정은 바꾸지 않았다.

검증 결과(2026-09-23): Python 집중 회귀29개 PASS, Node378개 화면/4,968개 로컬 링크 PASS. 독립 검토의2개 지적은 수정 후 해당3개 회귀와 Node 검사를 다시 통과해 잔여0건이다. 새 브라우저 주소에서 교정 영상36개, 합 패배 MP4 실제 재생(paused=false/time 증가), 390px 문서 가로 넘침 없음과 readyState4 완료를 확인했다. 기존 데스크톱 검수는1440×1000에서 상자8개/메인·무공·브리핑·수 배치, 영상재생/0.5배속, 전체112본문·16인·30카드·36영상/중복ID0/하단 이어가기 도달을 확인했다. 브라우저 직접 검수는 같은 PC Codex IAB이며 클라우드GPT/Claude 접속은 미실시다.

Godot import가 생성한 untracked metadata187개는 `C:/Users/user/Documents/삭제대기/Ten-Paces-Hidden-Moves/html-atlas-motion-20260923`에 원래 경로·SHA256·복구 안내와 함께 이동했다. 직접 삭제는 하지 않았다. 원본 main/다른 작업 폴더와 승인 자산은 보존했다. 재촬영 시 `output/blueprint/motion-capture` 폴더를 먼저 만들고 Godot import 준비를 확인한다.

마지막 좁은 화면 점검에서 전체보기 Active Context의 긴 경로/자산명이 문서를 가로로 밀어내는 문제를 발견해 일반 본문·제목의 긴 단어 줄바꿈을 적용했다. 교정 후390px에서 문서375px, 전체112본문, 하단 이어가기 위치170px을 실제 브라우저로 확인했다. 깊은 링크를 처음 열 때도 해당 상세/전체보기 구역으로 이동한다. 추가 중간 프레임/실패 AVI1670개(504,841,193bytes)는 같은 삭제대기 폴더 raw-capture 아래 원래 경로·SHA256과 함께 이동했고 최종36MP4/포스터/로그/촬영 기록은 보존했다.


## 16. 항목별 검수·재개 개선 · 2026-09-23

승인: 사용자가 여섯 가지 권장안에 “좋아 다 적용해줘”라고 승인했다. 기준 main6398f2687d9995b81c446e36b00e6a6f8a6a5c0c, Base 최신 main23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef를 다시 확인했다. PR342 head d2e1edae7930c11e6c04cfbe269a06c4d3075f14는 별도 Draft다. 외부 dirty45개는 보호한다.

실행 계획/인터페이스: 1) 기존 owner에서 항목 ID·상태·사용처·PM·fingerprint를 파생 → 2) 화면 패널/검색/검수/요청이 같은 인덱스를 소비 → 3) 엔진 촬영 프레임의 phase/event를 영상 타임라인에 연결 → 4) 브라우저/자동/독립 검토 → 정상 PR 및 main 재확인. 새 PM 정본이나 승인 owner를 만들지 않는다.

| 승인 항목 | 실제 변경·검증 기준 |
| --- | --- |
| 화면별 검수 패널 | 넓은 화면 구조도/상세 병렬, 좁은 화면 아래, 이전/다음·화면 선택 링크·뒤로가기 위치 유지 |
| 연출 단계 | 실제 프레임의 엔진 phase/event/time을 기록, 구간 이동·반복, 미기록 접근/복귀 시점을 발명하지 않음 |
| 상태 분리 | 기획/자산/연결/실행/사용자 검수와 미연결·미촬영/갱신·정적 연출 필터; 상태별 질문은 검수 완료가 아님 |
| 항목별 재개 | 화면·무공·인물·자산·연출의 원본/PM/시간/상태를 복사하고 resume-index에 동일 ID 제공 |
| 변경·근거 신선도 | 같은 브라우저·주소에서 명시 저장한 항목 fingerprint 비교. 촬영 입력 drift는 해당 영상을 역사로 표시. 파일 무결성 오류는 계속 거절 |
| 전체보기 탐색 | 기존112본문 전체 유지, 고정 목차/읽는 구역/위치 복원/분류 통합 검색/게임 내 이름 |

CURRENT_SOURCE_RELEVANCE_CHECK: 동일 승인 방향의 Archify 조사와 직전 권장안의 Storybook 상태별 사례(https://storybook.js.org/docs/get-started/whats-a-story), W3C 시각 설명(https://www.w3.org/WAI/media/av/description/)을 재사용한다. 새 장르/게임 규칙 기획이 아니다.
FEASIBLE: 기존 데이터·HTML·Godot 촬영 경로로 구현 가능. UI는 게임 규칙을 다시 계산하지 않는다. 실제 state별 촬영·소리·사람 검수는 없는 경우 미기록으로 표시한다.

BUILD / executing-plans + ten-paces-verification(html-blueprint-review, reference freshness). 단계 시점/의존 입력 검사 부재 RED 후 GREEN. 독립 코드 검토 전 자체 전체 검토1: 자료 명칭과 카드 ID가 달라 선택 원화 연결이 빠지는 문제를 발견해 ART_SELECTION의 성수 이름 매칭 회귀 RED→GREEN으로 교정했다. 초기 촬영 import에서 생성 metadata8개가 보호 경로 검사에 걸려 복구 manifest와 함께 삭제대기 폴더로 이동했고 동일 운영 계약 검사 PASS를 확인했다. 인코딩 도중 검사를 시작한 첫 시도는 매체 해시 불일치로 실패했으며, 인코딩 완료 후31개 집중 검사가 통과했다. 이 첫 실패를 통과로 세지 않는다.

설계 판단: 브라우저 저장은 포트/브라우저 경계를 넘지 않는다. 다른 AI에는 source-bound resume-index와 항목 요청을 사용한다. 촬영 의존성은 리터럴 resource closure와 동적 조회 보호를 위한 전체 data/combat modules를 유지하며, 검증하지 않은 최소 의존성을 단정하지 않는다. 영상 단계는 프레임 단위 관측이며 캐릭터 고유 동작·사람 재미 PASS가 아니다.

구현·대표 자동 검사·브라우저 검수와 전체 검토2회를 완료했다. 전달 PR347의 병합/원격 검사/최신 main은 GitHub live metadata로 확인한다. 아래에는 실제 확인한 증거만 누적한다.


독립 전체 검토2/2: P1 이상0, P2 네 항목(전역 클래스 상속 입력 누락, 변경 목록의 추가/삭제 누락, 후보 자산 PM 누락, 짧은 구간 반복 overshoot)을 확인했다. 각 재현을 먼저 실패시킨 뒤 교정했다. 상속/class 참조 closure 및 동적 data/combat 신규 파일 감지, 추가/수정/삭제 표시, 후보 scope+exact revision PM 매칭, 프레임 경계·영상끝 반복을 적용했다. 후보 요청문에는 경로와 exact SHA도 추가했다. 새로운 전체 검토는 시작하지 않는다.
브라우저 중간 확인: 1440px 구조도와 상세 병렬, 화면 속 새 여정→10권/30기술, 매화삼첩 승인 삽화와 단계/후보 설정 비교, 짧은 타격구간 반복 유지(time1.157s/ready4/재생중), 실제 재생시점1.123s를 담은 요청 복사, 검색어 복귀, 미연결 필터122개, 비교 기준 저장을 확인했다. 전체112본문/30기술/36영상/중복DOM ID0과 이어가기 하단 도달을 확인했다.390px에서 문서375px이며 목차가 구역 제목을 일부 가려 scroll margin225px로 교정했다. 최종 재확인은 아래 누적한다.

추가 전체 회귀 첫 실행은 임시 import8개를 검사 전에 옮긴 영향으로 배경 텍스처/부모 script를 로드하지 못하고 durable continuation timeout이 발생해 중단했다. 해당 보관본의 hash를 대조해 복원 후 같은 durable 실행의 DURABLE_CONTINUE PASS를 확인했다. 전체 회귀는 복원 상태에서 다시 시작했다. 임시 metadata 정리는 모든 Godot 검사가 끝난 뒤로 미룬다. 제품 코드 결함 교정이나 첫 실행 PASS로 기록하지 않는다.

복원 후 전체533개 회귀(465.008초)는 게임 실행을 포함한532개 PASS, 다음 작업 owner 불일치1개 FAIL이었다. HTML 병합 확인이라는 단기 단계를 current next_package에 넣으면서 기존 사용자 상태의 다음 제품 작업과 달라졌다. 두 owner가 기존 PR342 fresh-read continuation을 유지하도록 교정하고 실패 검사를 포함한 관련 검사를 다시 실행한다. 전체 첫 실패를 숨기거나 전체 재실행 PASS로 바꾸지 않는다. 좁은 화면 최종 확인은 목차 bottom208px/구역 heading225px, 문서375px로 가림과 수평 넘침이 없었다. 후보 자산의 원본 경로·정확한 SHA·PM 연결, 기술 삽화의 사람이 읽을 이름, 메뉴 현재 위치 표기도 교정했다.

최종 집중 확인: 실패한 owner 일치 검사를 포함한37개 Python 검사 PASS, project operating system PASS, 재생성 HTML의661개 표시/6725개 로컬 링크 PASS. 실제 브라우저 후보 자산 요청에서 d2e1edae7930c11e6c04cfbe269a06c4d3075f14 원본3개와 PRESENTATION-PREFERENCES PM을 확인했고, 한국어 효과 이름·현재 메뉴 aria-current 단일 지정·수평 넘침 없음을 확인했다. 같은 기반 전체533개 중532개 통과 및 owner 교정 후 관련 재검증이 최종 로컬 증거다. 전체533개를 교정 후 다시 수행했다고 주장하지 않는다. 원격 exact-head 검사와 병합 여부는 PR347에서 조회한다.

검사 종료 후 임시 메타데이터223개와 인코딩 완료 원시 프레임3353개를 `C:/Users/user/Documents/삭제대기/Ten-Paces-Hidden-Moves/html-inspection-20260923/final-cleanup`으로 옮겼다. 파일마다 original/stored/SHA256 복구 명세를 남겼다. MP4/포스터·승인 원본은 보존했고 프로젝트 운영 계약 검사 PASS다. 이후 Godot 검사는 먼저 import를 복원/재생성해야 한다.
