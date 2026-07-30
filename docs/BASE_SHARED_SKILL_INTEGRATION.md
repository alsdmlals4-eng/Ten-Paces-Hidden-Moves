# Base 공용 Skill 연결 기준

`Ten-Paces-Hidden-Moves`는 Base 공용 Skill 본문을 복제하지 않고 검증된 route Adapter로 사용하며, 십보강호 고유 Skill만 프로젝트 내부에서 관리한다.

## 현행 기준과 경로

- Base release: `alsdmlals4-eng/Base` `v9.3.0`.
- Release commit: `30ca6c7b5f93521f0eb0eed42d01437cd43c50ae`.
- Evidence commit: `462a86db192d23d0f386281a1eb54b0a8cbad62e`.
- Base Registry SHA-256: `9847bb2b225c776ad7916930f0f48c490bc2a898bea8e02ea1fdd0e6caac60c1`.
- Active execution contract: `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v9.md`.
- 공용·로컬 route 정본: `skills/PROJECT_BASE_ADAPTER.json`.
- 생성 effective route view: `skills/PROJECT_SKILL_SNAPSHOT.json`.
- 프로젝트 고유 Skill Registry: `skills/SKILL_REGISTRY.json`.
- 아카이브 어댑터: `[기획서]/00_프로젝트_허브/ARCHIVE_RETENTION_ADAPTER.json`.

## 라우팅

```text
작업 요청
→ AGENTS.md와 현재 Work Mode 확인
→ PROJECT_BASE_ADAPTER.json의 release pin·보호 경로·Sheet 상태 검증
→ PROJECT_SKILL_SNAPSHOT.json의 effective_routes 선택
→ 프로젝트 local route 우선
→ 필요한 Base shared Skill만 고정된 Base v9.3에서 읽기
```

- Base shared: 27 routes.
- Project local: 4 routes.
- Precedence: `PROJECT_LOCAL_THEN_BASE_SHARED`.
- Adapter·Snapshot·Router pin 불일치 시 fail closed.
- v8·v9.1 어댑터는 compatibility/history이며 활성 route를 만들지 않는다.

## 프로젝트 고유 경계

- `ten-paces-game-design`: 전투·성장·무공 제품 판단.
- `combat-ux-and-accessibility`: 전투 UI 정보 계층·접근성.
- `combat-implementation-handoff`: 승인된 Godot 구현 인계.
- `ten-paces-verification`: 프로젝트 전용 증거·반례·판정.

## 직접 생성 전 조사

```text
Godot 기본 기능 → 공식 Asset Library → 기존 프로젝트 자산
→ 제작자 GitHub 안정 Release·tag → itch.io → 공식 판매처·상용 마켓
→ ADOPT / ADAPT / TRIAL / REJECT / BUILD_CUSTOM
```

카드 UI, 툴팁, 행동 순서, 그리드, 전투 로그와 테스트 보조를 우선 조사한다. 무공 조합, 행동 슬롯 판정과 전투 규칙은 외부 플러그인에 맡기지 않는다.

## Sheet·서버 경계

- Sheet는 병합된 GitHub `main`을 확인한 뒤에만 동기화한다.
- 서버·모바일 확장은 Issue #64의 planning-only 경계이며 현재 shared route 이관에 포함하지 않는다.
- 전투 코어의 데이터 ID·규칙 버전·UI/네트워크 분리 가능성만 장기 호환 조건으로 기록한다.

## 기록·검증

- 채택 자산: `docs/technical/ADOPTED_ASSETS.md`.
- 라이선스: `docs/technical/THIRD_PARTY_LICENSES.md`.
- 아카이브: `docs/archive/README.md`, `docs/archive/MANIFEST.json`.
- 정적 검사: `python tests/test_base_shared_skill_adapter.py`.
- 운영 계약 검사: `python tests/test_base_v9_adoption.py`와 `python tests/test_base_v91_operating_contract.py`.
- Godot·Windows·접근성 사용자·사람 플레이는 실행 전까지 `NOT_RUN`이다.

## Legacy extension

`alsdmlals4-eng/Base@6a224e450f9420223c00921f3c56e051612f92ad`의 archive extension은 보존 정책의 역사적 exact pin으로 남는다. Base v9.3 전체 운영 권한과 혼합하지 않는다.
