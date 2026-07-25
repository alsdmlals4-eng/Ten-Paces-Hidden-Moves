# 십보강호 아카이브

이 경로는 과거 결정·증거·파생본을 복구 가능하게 보존하는 비활성 영역이다.

- 아카이브 자료는 현재 정본이 아니며 구현 권한이 없다.
- 현재 정본은 `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`와 `MANIFEST.json`의 `superseded_by`에서 확인한다.
- 원문을 비우지 않는다. 경로만 남기고 본문을 삭제하는 방식은 금지한다.
- 실제 아카이브 항목은 classification, 원래·현재 경로, SHA-256, 대체 정본, 사유, rollback ref와 검증 상태를 기록한다.
- 비밀키·API token·자격증명·private key는 아카이브하지 않는다.
- Base 공용 Skill 본문은 프로젝트에 복제하지 않고 `skills/BASE_SHARED_SKILL_ROUTES.json`과 프로젝트 어댑터로 선택한다.
- Git branch는 폴더로 이동할 수 없으며 unique commit 감사와 rollback tag 검증 뒤 별도 처리한다.

이번 채택 작업은 기존 구형 자료를 이동·삭제·재작성하지 않는다.
