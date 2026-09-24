# 십보강호에서 추출한 사례

참고 저장소: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves
확인 기준: ec7240633e21aec448f9426781a7acbf294aa748 (2026-09-24 main).
이 문서는 재사용 예시다. 다음 프로젝트의 최신 상태는 해당 저장소를 다시 읽는다.

| 배운 점 | 실제 책임 파일 | 적용할 때 바꿀 것 |
|---|---|---|
| 원본을 읽어 파생 HTML 생성 | tools/build_html_blueprint.py, tools/html_blueprint.py | 프로젝트 원본 어댑터 |
| 제목·번호·쓰임새와 안정적 번호 | tools/html_blueprint_numbers.py, docs/blueprint/IMAGE_NUMBERS.json | 분류/ID 규칙 |
| 인라인 의견과 부분 갱신 | tools/html_blueprint_ui/inline.js, review.js, review_state.js | 영구 저장 어댑터와 프로젝트 ID |
| 사건 설명 1회 + 선택 결과 표 | tools/html_blueprint_ui/event_catalog.js / event_catalog.css | 실제 사건·선택 원본 |
| 목록 미리보기와 원본 보존 | tools/html_blueprint_previews.py | 용도별 크기/인코더 프로필 |
| 실제 움직임과 포스터 구분 | tools/encode_blueprint_motion.py, docs/blueprint/evidence/motion/manifest.json | 캡처 도구·결과 사건 |
| 제한된 로컬 발행과 복구 | tools/serve_html_blueprint.py, tools/open_html_blueprint.py | 발행 경로·만료 정책 |
| 수정 이유와 누적 증거 | docs/blueprint/HTML_MIGRATION_SPEC.md | 현재 프로젝트의 기존 기록 |

주요 실제 문제: 댓글 저장 때 전체 목록을 다시 그려 스크롤이 이동함; 만료된 포트 때문에 정상 이미지/영상도 깨짐; 이름 추측으로 전투 이미지가 휴식·정탐에 연결됨; 전체 atlas를 한 셀처럼 표시함; 반복 성장 표와 큰 그림이 공간을 소모함.

채택한 방법: 저장 후 변경 항목만 갱신, 즉시 임시 초안+직렬 저장, 안정 ID/번호, 실제 사용처 분류, 중간 크기 비교 칸, 공용 규칙 표, 원본과 작은 미리보기 분리, 선택한 영상만 재생, 브라우저 직접 확인.

십보강호의 강호행로/전투/플레이어/상대 분류, 3/3/4 규칙, 능력치나 기연 확률은 이 스킬의 공통 규칙이 아니다. 다른 프로젝트에 그대로 복사하지 않는다. 아틀라스와 일반 이미지 목록도 구별한다.

검증 연결: tests/test_html_blueprint*.py, tools/check_html_blueprint_ui.cjs. 전체 프로젝트가 있는 경우에만 현재 CLI/테스트를 확인해서 실행한다. 2026-09-24의 “원본 참조 bytes 감소”는 실제 브라우저 FPS 측정이 아니었다.

Base에 보여줄 때는 이 사례·실행 예시·검수 결과를 함께 전달하고 재발생 가능한 공통 원리만 채택한다. 원본 게임 자산이나 사용자 코멘트를 동의 없이 다른 프로젝트로 복사하지 않는다.
