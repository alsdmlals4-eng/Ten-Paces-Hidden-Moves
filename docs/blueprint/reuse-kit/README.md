# HTML 블루프린트 재사용 꾸러미 · 1차

십보강호 HTML을 정리하면서 확인한 방법을 다른 프로젝트에서도 재현할 수 있게 묶었다. 실제 사용자 코멘트와 게임 원화는 포함하지 않는다.

- [스킬 지침](building-reviewable-html-blueprints/SKILL.md)
- [바로 열어볼 실행 예시](example/index.html)
- [전달용 ZIP](html-blueprint-skill-v1.zip)
- [문제와 해결 방법의 실제 프로젝트 연결](building-reviewable-html-blueprints/references/ten-paces-example.md)
- [저장·폐기·미디어 검수 계약](building-reviewable-html-blueprints/references/review-media-contract.md)

## 포함한 방법

종류·번호·쓰임새·제작 의도, 같은 종류의 그림 비교, 항목 바로 아래 코멘트, 작성 중 위치 유지, 임시/영구 저장 상태 구분, 폐기 요청과 실제 처리의 구분, 중복 규칙의 공용 표, 사건별 설명과 선택지 표, 원본/미리보기 분리, 실제 영상 재생 확인, 만료된 미리보기 복구를 담았다.

실행 예시는 범용 도식 3개로 분류·코멘트·검토 상태·폐기 요청·JSON 내보내기를 보여준다. 서버 없는 UI 시연이므로 코멘트는 같은 미리보기 주소의 브라우저에만 보관된다. 주소/포트나 PC가 바뀌기 전에 내보내야 한다. 실제 십보강호의 파일 저장 기능과 같은 범위라고 주장하지 않는다.

## 사용

개인 스킬 설치 위치는 C:/Users/user/.codex/skills/building-reviewable-html-blueprints 이다. 이 폴더는 해당 설치본의 검증된 전달 스냅샷이다. 수정 후 두 사본과 ZIP의 해시 일치를 다시 확인하며 서로 다른 정본으로 운영하지 않는다.

나중에 “building-reviewable-html-blueprints 스킬을 사용해서, 십보강호 HTML 예시를 참고하되 이 프로젝트 자료에 맞춰 만들어줘”라고 요청할 수 있다. 자동 발견 상태는 새 작업에서 확인한다.

다른 프로젝트용 작은 예시는 Python 표준 라이브러리만으로 만든다.

```text
python building-reviewable-html-blueprints/scripts/scaffold.py --output <빈 폴더> --project-id my-project --project-name "내 프로젝트"
```

기존 결과물이 있는 폴더는 덮어쓰지 않는다. 실제 적용에서는 프로젝트의 원본, 이미지 사용처, 번호/ID, 영구 리뷰 저장소, 발행기, 권한을 먼저 연결한다. 예시의 탐험/전투/인물 분류나 십보강호의 전투 규칙을 공통 규칙으로 강제하지 않는다.

## Base에 전달할 때

기존 Base building-project-visual-dashboards의 내용/권위 원칙을 재사용한다. 이 꾸러미는 HTML의 읽기·작성·재생·검수 방법을 보완한다. 1차 완성 후 위 실행 예시와 검증 결과를 보여주고 공통화할 부분만 채택한다. 이번 작업에서 Base 저장소·다른 프로젝트·설치 플러그인·전역 설정을 변경하지 않았다.

검증과 남은 한계는 기존 HTML 실행 기록의 reusable_html_skill_followup에 남긴다. 실제 사용자 프로젝트의 저장/동시 편집/삭제 통합까지 이 예시가 완료했다는 뜻은 아니다.
