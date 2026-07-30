> # 십보강호: 숨은 수의 비무
## Ten Paces: Hidden Moves

상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 **무협 전술 로그라이트**입니다.

> 보이지 않는 상대의 수를 읽고, 준비한 계획으로 꺾는다.

## 시작

- [작업 시작](START_HERE.md)
- [현재 상태]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)
- [v6 전체 결정 권한 원장](docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md)
- [문서 지도]([기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md)
- [게임 기획](docs/01_GAME_DESIGN.md)
- [전투 규칙](docs/02_COMBAT_RULES.md)
- [콘텐츠 카탈로그](docs/03_CONTENT_CATALOG.md)
- [전투 시스템 아키텍처](docs/09_COMBAT_SYSTEM_ARCHITECTURE.md)
- [테스트 체크리스트](docs/08_TEST_CHECKLIST.md)
- [Base 적용 기준](docs/BASE_RULES_VERSION.md)
- [Base 동기화 감사]([기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md)

## 현재 작업 상태

```yaml
product_stage: CONCEPT_APPROVAL
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL
primary_platform: PC
future_platform: Mobile
human_validation: UNVERIFIED
base_release: v9.3.0
base_release_commit: 30ca6c7b5f93521f0eb0eed42d01437cd43c50ae
vertical_slice_execution_contract: v9 / contract 9.1
```

Base 공용 Skill은 프로젝트에 복제하지 않습니다. `skills/PROJECT_BASE_ADAPTER.json`과 생성된 `skills/PROJECT_SKILL_SNAPSHOT.json`이 Base shared 27개와 프로젝트 local 4개의 effective route를 제공합니다.

## 프로젝트 코어

```text
상대의 공개 상태·해결 이력 관찰
→ 다음 행동에 대한 가설 수립
→ 3수 → 3수 → 4수 행동 묶음 계획
→ 상대 의도 완화·거부·반전·응징
→ 결과 복기와 무공 성장
```

- 10칸 일자형 전장에서 플레이어 4번·상대 7번 시작을 사용합니다.
- `[합]`, 거리, 연격, 통합 방어도의 인과를 복기할 수 있어야 합니다.
- 성장은 더 다양하고 강력한 파훼 방법을 제공합니다.
- 원시 수치 상승은 파훼 판단을 대체하지 않습니다.
- AI는 플레이어의 미확정 계획을 읽지 않습니다.
- 덱·손패·드로우·장착 기술 제한을 사용하지 않습니다.

## 현재 주요 기획 계약

- 한 라운드는 `3수 → 3수 → 4수`, 각 묶음 뒤 해결하며 총 10수입니다.
- 10칸 일자형 전장과 거리 0 `[밀착]`을 사용합니다.
- 버티컬 슬라이스는 핵심 결투 5개를 앵커로 합니다.
- 필수 주요 비무 전체 목표는 10전입니다.
- `[연격 N]`은 최종 총피해를 N개의 피해 묶음으로 나눕니다.
- 방어와 보호막은 하나의 `[방어도]`로 통합됩니다.
- 무공서는 16권, 1~10성입니다.

## 천하제일인 이후 장기 콘텐츠

본편 10전과 `[천하제일인]` 대전 승리 후 다음 **비동기 챔피언 배틀**을 별도 Gate에서 검토합니다.

```text
완성 캐릭터·등록 전투 구성 저장
→ 사용자는 자신의 캐릭터를 직접 조작·계획
→ 상대의 등록 캐릭터는 AI가 조종
→ 결과 복기·재등록
```

- 공식 기획 용어: `등록 전투 구성`.
- 데이터 용어: `Champion Build Snapshot`.
- 등록 후 자신의 현재·과거 Snapshot과 싸우는 `자가 비무`를 지원하는 방향입니다.
- 현재 Demo·Vertical Slice에는 서버, 계정, 랭킹, 모바일 UI를 넣지 않습니다.
- 전투 판정 코어와 UI·씬·네트워크의 분리 가능성만 선행 설계 경계로 유지합니다.
- 상세 추적: GitHub Issue #64.

## 구현 사실과 설계 권한

현재 `main`에는 기존 T0 전투 PoC의 STEP 0~13이 존재합니다. 최신 v6 기획과 완전히 일치하지 않을 수 있습니다. 실제 코드·데이터는 현재 구현 사실의 근거이며, 최신 설계 권한은 v6 결정 원장이 소유합니다.

정적 검사·Actions 성공은 Godot 런타임, Windows 사용성, 접근성, 성능, 실제 플레이 재미를 증명하지 않습니다. 실행하지 않은 항목은 `UNVERIFIED` 또는 `NOT_RUN`으로 유지합니다.

## `[보류]`

- Round 4 이후 전체 적대적 검토
- 16개 개별 절초 설계
- Godot 런타임·데이터·씬·자산 변경
- 서버·온라인 대전 구현
- 모바일 포팅

## Legacy/Compatibility

과거 BCA v8 채택의 재현 문자열은 남기되 현행 권한으로 사용하지 않습니다.

- Legacy Base: `alsdmlals4-eng/Base@c987647d01ad2baa028a16e03d85ddfc1572a727`
- Legacy prompt: `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v8.md`
- 상태: `SUPERSEDED_COMPATIBILITY / HISTORY_ONLY`
