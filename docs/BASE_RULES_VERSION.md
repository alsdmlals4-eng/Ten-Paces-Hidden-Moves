# Base 규칙 적용 버전

- Base 저장소: `alsdmlals4-eng/Base`
- 기준 브랜치: `main`
- 기준 커밋: `9ea52ec2b0a7e8db4f23cf310dc266dff11245d1`
- Base 문서 버전: `v1.9.2`
- 프로젝트 동기화 날짜: `2026-07-16`
- 적용 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`

## 적용한 공용 구조

- 학습형 Base와 프로젝트 전용 데이터의 책임 분리.
- 기획서·로드맵·Active Context·Documentation Map의 지속성 계약.
- 요청을 목적·맥락·경험·범위·제약·산출물·완료·검증으로 변환하는 절차.
- Vertical Slice와 데모의 범위·품질·제작성 검증.
- UI·연출과 도메인 상태 소유 경계.
- 프로젝트 결과를 Base method·skill·template·case로 환류하는 절차.
- 한 번 채택한 설계를 실제 검증 전에는 검증된 공용 스킬로 표시하지 않는 지식 상태 규칙.
- Base 채택→프로젝트 구체화→검증→Base 환류의 양방향 학습 사례.
- 내부 난도·성장 데이터와 세계관 표현을 의미 키로 분리하는 사례.

## 프로젝트 구체화

십보강호의 실제 수치, 문파·무공·제약 이름, Godot 경로, 구현 상태와 테스트 결과는 프로젝트 저장소가 책임진다.

프로젝트 적용 기록:

- `docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md`
- `docs/skills/TEN_PACES_PLANNING_HANDOFF_EXTENSION.md`

Base에 반영한 사례:

- `docs/knowledge/cases/BASE_PROJECT_BIDIRECTIONAL_LEARNING_CASE.md`
- `docs/knowledge/cases/DIEGETIC_OPPONENT_INFORMATION_CASE.md`

## 갱신 조건

다음 경우 Base `main`의 최신 Documentation Map과 Changelog를 확인한 뒤 이 파일을 갱신한다.

- 프로젝트가 새로운 Base method·skill·template을 적용할 때.
- Base의 우선순위·문서 수명주기·인수인계·지식 승격 규칙이 바뀔 때.
- 프로젝트 작업에서 공용 지식을 Base로 승격한 뒤 양쪽 참조를 정리할 때.
- Base 사례의 지식 상태가 `가설`·`채택`에서 `부분 검증`·`검증`으로 바뀔 때.
- 새 작업자나 AI가 현재 Base 기준과 프로젝트 문서가 충돌한다고 보고할 때.

Base 원격과 프로젝트 파일은 자동 동기화되지 않는다. 기준 커밋이 바뀌면 프로젝트 로컬 사본·스킬 확장·적용 기록과의 차이를 확인한다.
