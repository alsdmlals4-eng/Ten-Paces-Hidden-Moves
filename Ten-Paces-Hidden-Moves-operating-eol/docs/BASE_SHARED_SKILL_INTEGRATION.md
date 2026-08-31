# Base 공용 Skill 연결 기준

`Ten-Paces-Hidden-Moves`는 Base 공용 Skill 본문을 복제하지 않고 route Registry와 프로젝트 어댑터로 사용하며, 십보강호 고유 Skill만 프로젝트 내부에서 관리한다.

## 기준과 경로

- 공용 Skill 기준: `alsdmlals4-eng/Base@6a224e450f9420223c00921f3c56e051612f92ad`
- 현재 공용·로컬 route 계약: `skills/PROJECT_BASE_ADAPTER.json`
- 생성 효과 route view: `skills/PROJECT_SKILL_SNAPSHOT.json`
- 아카이브 어댑터: `[기획서]/00_프로젝트_허브/ARCHIVE_RETENTION_ADAPTER.json`
- 프로젝트 고유 Skill Registry: `skills/SKILL_REGISTRY.json`

`docs/BASE_RULES_VERSION.md`의 전체 운영체계 기준과 이 공용 Skill 기준은 별도 책임이다. 공용 Skill pin 갱신으로 다른 Base 정책을 자동 강제하지 않는다.

## 라우팅

```text
작업 요청
→ skills/PROJECT_BASE_ADAPTER.json의 pin·보호 경로 검증
→ skills/PROJECT_SKILL_SNAPSHOT.json의 effective_routes 선택
→ 필요할 때만 십보강호 고유 전투·UX·구현·QA Skill 선택
```

- 레거시·아카이브: `governing-legacy-retention-and-archives`.
- Godot 직접 생성 전 자산 탐색: `evaluating-godot-assets-and-plugins-before-creation`.

## 직접 생성 전 조사

```text
Godot 기본 기능 → 공식 Asset Store → 기존 Asset Library
→ 제작자 GitHub 안정 Release·tag → itch.io → 공식 판매처·상용 마켓
→ ADOPT / ADAPT / TRIAL / REJECT / BUILD_CUSTOM
```

카드 UI, 툴팁, 행동 순서, 그리드, 전투 로그와 테스트 보조를 우선 조사한다. 무공 조합, 행동 슬롯 판정과 전투 규칙은 외부 플러그인에 맡기지 않는다.

## 기록·검증

- 채택 자산: `docs/technical/ADOPTED_ASSETS.md`
- 라이선스: `docs/technical/THIRD_PARTY_LICENSES.md`
- 아카이브: `docs/archive/README.md`, `docs/archive/MANIFEST.json`
- 정적 검사: `python tests/test_base_shared_skill_adapter.py`
- Godot·Windows·사람 플레이는 실행 전까지 `NOT_RUN`이다.
