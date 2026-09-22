# HTML 블루프린트·원본 연결 구조도 검수

저장소 원본 → `python tools/build_html_blueprint.py` → `output/blueprint/index.html` 순서다.
전체 승인 설명·자산·모션·PM·작업 재개가 범위이며 게임 규칙은 JS로 재구현하지 않는다.
설계와 완료 조건은 `docs/blueprint/HTML_MIGRATION_SPEC.md`가 소유한다.

## 구조도에 흡수한 Archify 방법

- 질문에 따라 workflow / dataflow / sequence를 선택한다. 현재 원본에 있는 책임·관계만 안정적인 ID로 표현한다.
- 노드·관계·설명을 하나의 모델에서 렌더하고 검증한다. 화면의 근접 배치로 실제 호출·원인·영향을 추정하지 않는다.
- 연결에는 의미와 방향을 붙이고, 흐름을 끊어 가독성을 가장하지 않는다. 관련 없는 노드를 통과하거나 설명이 가려지는 배치를 교정한다.
- 기본은 정적이다. 선택한 노드의 실제 직접 연결·원본을 강조하고 깊은 링크로 재개한다. 게임 연출과 설명용 탐색을 구별한다.
- 실패한 새 발행을 마지막 정상본으로 가장하지 않는다. 입력/출력 해시, 자동 구조 검사, 실제 브라우저 동작, 사람 시각 검수를 독립적으로 기록한다.

원출처: https://github.com/tt-a1i/archify — 2026-09-22 관측 `5289f6867f048a7450ec5718f58459613a84cf41`.
읽은 범위: `archify/SKILL.md`, workflow/sequence/common schema와 각 예제,
authoring/delivery/viewer-runtime 계약, workflow readable-v2 배치 계약, preview/open-artifact 경로, MIT LICENSE.
이 revision은 조사 증거이지 영구 최신 기준이 아니다. 구현은 프로젝트 전용 경량 SVG이며 Archify 전체 엔진·Showcase 검사·PNG/WebM export를 도입했다고 주장하지 않는다.
원본 패키지의 업데이트 실행·전역 설치·브랜드 수집·호스팅 절차는 이 프로젝트의 명령으로 흡수하지 않는다.

## AI가 직접 열고 검사하는 경로

1. `python tools/serve_html_blueprint.py`는 생성 후 127.0.0.1에만 읽기 전용 미리보기를 시작한다. 기존 출력만 확인할 때는 `--no-build`.
2. 현재 주소·PID·출력 해시는 무시된 `output/blueprint/preview-session.json`에서 읽는다. 같은 PC/네트워크 공간에 연결된 브라우저 도구로 해당 HTTP 주소를 연다.
3. 실제 브라우저에서 목차/검색/상태 필터/인물 상세/이미지 확대·Esc/모션 재생·정지/구조도 선택·원본/PM/재개 요청을 확인한다. 작은 화면과 키보드 이동을 포함한다.
4. 자동 테스트: `python -m unittest tests.test_html_blueprint tests.test_html_blueprint_preview tests.test_html_blueprint_diagrams tests.test_html_blueprint_publication`; 소스 렌더·링크: `node tools/check_html_blueprint_ui.cjs`. 이 검사는 실제 브라우저 증거를 대체하지 않는다.
5. 브라우저 정책이 요청을 거절하면 같은 요청을 다른 도구로 우회하지 않는다. 안전하게 범위를 줄인 별도 열람 방식도 차단되면 해당 검사만 BLOCKED_UNVERIFIED로 남긴다.

서버는 발행 manifest의 파일만 해시 대조 후 제공하며 디렉터리 목록·임의 파일·쓰기·명령 실행·외부 바인딩을 허용하지 않는다.
클라우드 GPT/Claude 등의 localhost는 사용자 PC가 아니다. 그 환경에서 접속하지 않았다면 호환 완료를 주장하지 않는다. 공개 터널·업로드·인증·전역 설정 변경은 별도 범위다.
검수 중 원본을 바꾸면 재생성하고 본 작업이 시작한 서버만 종료/재시작한다. 기본 120분 뒤 종료되며 주소·PID를 다음 세션의 상시 준비 상태로 재사용하지 않는다.


## 재현 환경

Python3.12+와 Pillow/reportlab, Poppler의 pdftoppm이 필요하다. Node는 소스 렌더/링크 검사에 사용한다.
정확한 CI 패키지는 `.github/workflows/html-blueprint.yml`을 따른다. 기존 환경을 먼저 확인하고 전역 설치를 임의 실행하지 않는다.
관측한 PR342 commit이 로컬 Git에 없으면 명시된 SHA를 origin에서 fetch한 뒤 생성한다. 다른 작업 폴더를 읽어 대체하지 않는다.
PDF 페이지 렌더는 승인 PDF의 SHA별로 캐시하고112쪽 coverage와 캐시 hash를 대조한다. 문서 수정은 공유 원본에 반영한다.
HTML 원본 항목의 기존 페이지 비교 이미지는 역사 승인 배치이며 최신 runtime과 혼동하지 않는다.
