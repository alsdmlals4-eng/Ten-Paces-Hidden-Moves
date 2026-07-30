# 십보강호 협업 규칙

이 파일은 `Ten-Paces-Hidden-Moves`의 최상위 프로젝트 작업 계약이다.

## 1. 우선순위

1. 사용자의 최신 확정 지시.
2. 보안·플랫폼 제약과 이 `AGENTS.md`.
3. 프로젝트 정본·실제 구현·열린 Issue·PR.
4. `skills/PROJECT_BASE_ADAPTER.json`과 생성된 `skills/PROJECT_SKILL_SNAPSHOT.json`.
5. `alsdmlals4-eng/Base`의 고정된 **Base v9.3** 릴리스와 `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v9.md`.
6. v6 결정 원장과 질문별 책임 원본.
7. 과거 문서·호환 입력·외부 사례.

정상 동작 중인 사용자·Codex 변경을 임의로 되돌리지 않는다. Adapter·Snapshot·Router pin이 서로 다르면 추론으로 보정하지 않고 중단한다.

## 2. 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ skills/PROJECT_BASE_ADAPTER.json
→ skills/PROJECT_SKILL_SNAPSHOT.json
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 질문별 책임 원본
→ 실제 파일·테스트·PR·Issue
```

- Base 기준: `docs/BASE_RULES_VERSION.md`.
- 프로젝트 고유 Skill Registry: `skills/SKILL_REGISTRY.json`.
- `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`은 호환·이력 참조이며 자동 라우팅 정본이 아니다.
- 백업·보류·과거 계획·닫힌 PR·전체 Skill 폴더를 기본 컨텍스트로 로드하지 않는다.

## 3. 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
project_en: Ten Paces: Hidden Moves
primary_platform: PC
future_platform: Mobile
product_stage: CONCEPT_APPROVAL
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL
planning_integration_pr: 45
canonical_decision_ledger: docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
human_validation: UNVERIFIED
base_release: v9.3.0
vertical_slice_contract: v9 / contract 9.1
```

- 현행 T0 구현 계보는 PR #7과 Issue #13이다. 최신 v6 설계 권한과 분리한다.
- PR #45는 v6 계획 정본과 역사·검증 자료를 정합화했으며 제품 런타임을 변경하지 않았다.
- Base v9.3 운영체계 이관은 Issue #63이 추적한다.
- 천하제일인 이후 비동기 챔피언 배틀 장기 설계는 Issue #64가 추적하며 현재 런타임 범위가 아니다.

## 4. Work Mode·Skill Mode

- `PLAN`: 요구·정본·근거·설계·문서·검수. 승인 전 제품 변경 금지.
- `BUILD`: 사용자가 명시적으로 승인한 범위의 구현.
- `REVIEW`: 적대적 검토·반례·검증·판정.
- Skill Mode는 Registry trigger와 작업 위험에 따라 최소 범위로 선택한다.
- L1 이상 작업은 기준 SHA, 선택 Skill, 실제 수행, 결과, 증거, 미검증을 `execution-report`에 기록한다.
- 정본·경로·ID·Schema·Base pin 변경은 `reference-freshness`로 검사한다.

한 시점의 주 Work Mode는 하나다. 제품의 현재 Work Mode는 `PLAN`이다. 운영체계 이관은 승인된 별도 `BUILD → REVIEW` 범위로만 수행한다.

## 5. 현재 제품 코어

> 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트.

- 한 라운드: `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 10칸 일자형 전장과 거리 0 `[밀착]`.
- AI는 플레이어의 미확정 계획을 읽지 않는다.
- 덱·손패·드로우·장착 기술 제한을 사용하지 않는다.
- 버티컬 슬라이스는 핵심 결투 5개를 앵커로 한다.
- 필수 주요 비무 전체 목표는 10전이다.
- `[연격 N]`은 한 공격의 총피해를 N개 피해 묶음으로 나눈다.
- 방어와 보호막은 통합 `[방어도]`다.
- 무공서 16권, 1~10성, 10성 절초.

세부 설계 권한은 v6 결정 원장이 소유한다. 실제 코드·데이터는 구현 사실을 증명하지만 최신 설계 권한을 자동으로 대체하지 않는다.

## 6. 미래 확장 경계

PC 본편과 전투 코어 검증 후 별도 Gate에서 다음을 검토한다.

```text
필수 주요 비무 10전 완료
→ [천하제일인] 승리
→ Champion Build Snapshot 등록
→ 사용자 캐릭터 직접 조작·계획
→ 등록 상대는 AI 조종
→ 자신의 현재·과거 등록 구성과 자가 비무
```

- 현재 단계에서는 서버·계정·랭킹·시즌·모바일 UI를 구현하지 않는다.
- 전투 판정 코어는 UI·씬·네트워크와 분리 가능한 방향을 유지한다.
- 공식 용어는 `등록 전투 구성`, 데이터 용어는 `Champion Build Snapshot`이다. 새 드로우 덱 시스템을 의미하지 않는다.

## 7. `[보류]`

- Round 4 이후 전체 적대적 검토.
- 16권 절초의 개별 설계.
- 2026-07-26 구현 계획 실행.
- Godot 런타임·데이터·씬·자산 변경.
- 서버·온라인 대전·모바일 포팅 구현.

`[보류]`는 결정 행에서 `DEFERRED`, 게이트에서 `HOLD`이며 런타임 구현 입력에서 제외한다.

## 8. 변경 보호

현재 `PLAN`과 Issue #63 이관 범위에서 다음 제품 경로는 수정하지 않는다.

```text
data/
src/
scenes/
assets/
addons/
project.godot
```

문서·검증 자산을 수정한 뒤에는 changed files를 확인한다. 제품 경로 변경이 발견되면 즉시 중단하고 원인·복구를 보고한다.

## 9. 검증 원칙

```text
contract-check
→ reference-freshness
→ syntax·static
→ automated tests
→ 적용 시 runtime·render·build
→ normal·failure·edge·counterexample·regression
→ baseline diff
→ evidence-report
```

- 실제로 실행하지 않은 검증은 PASS로 기록하지 않는다.
- 파일 존재, 정적 테스트, Actions 성공, Godot 실행, Windows 확인, 접근성, 성능, 사람 플레이는 서로 다른 증거다.
- 문서 정합성 통과는 런타임 구현이나 게임 재미를 증명하지 않는다.
- `MUST_FIX` 또는 필수 `UNVERIFIED`가 남으면 완료를 과장하지 않는다.

## 10. Sheet 정책

- 프로젝트 Sheet ID: `1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0`.
- GitHub 정본 PR 병합 전에는 Sheet를 쓰지 않는다.
- 현재 충돌 상태는 `SHEET_GITHUB_CONFLICT / BLOCKED / NO_AUTOMATIC_OVERWRITE`다.
- 병합된 `main` SHA를 재조회한 뒤 계약된 탭·범위만 동기화한다.
- Sheet 단독 변경은 `PROPOSED_SHEET_CHANGE`로 처리한다.

## 11. 작업 종료

1. 최신 사용자 결정과 책임 원본을 맞춘다.
2. 활성 소비자에서 구형 권한 참조를 제거하거나 명시적 호환 기록으로 격리한다.
3. 제품 경로가 변경되지 않았는지 확인한다.
4. 정적·자동 검증과 PR 상태를 새 HEAD에서 다시 확인한다.
5. 미검증·보류·롤백 경계를 명시한다.
6. 병합은 사용자의 명시적 승인과 최신 검증 증거가 있을 때만 수행한다.

## 12. Legacy/Compatibility 기록

다음은 현행 실행 권한이 아니라 과거 BCA v8 채택을 재현하기 위한 문자열이다.

- Legacy Base: `alsdmlals4-eng/Base@c987647d01ad2baa028a16e03d85ddfc1572a727`.
- Legacy prompt: `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v8.md`.
- 상태: `SUPERSEDED_COMPATIBILITY / HISTORY_ONLY`.
