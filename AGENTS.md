# 십보강호 협업 규칙

이 파일은 `Ten-Paces-Hidden-Moves`의 최상위 작업 규칙이다. Base의 공용 운영 계약을 십보강호의 Godot 구조, 전투 규칙, 기획 책임 원본과 검증 방식에 맞게 분화한다.

## 1. 연속성 계약

새 채팅, 새 AI, 새 작업자가 과거 대화 없이 저장소만으로 다음을 찾을 수 있어야 한다.

- 무엇을 만드는가
- 현재 제품·구현·운영 단계는 무엇인가
- 무엇을 변경하면 안 되는가
- 현재 책임 원본과 실제 파일은 어디인가
- 어떤 Work Mode·Skill·Skill Mode가 왜 선택되는가
- 어떤 검증을 실행했고 무엇이 미검증인가
- 다음 작업·의존성·진입 조건·롤백은 무엇인가

Active Context는 현재 상태의 기본 원본이다. Handoff는 세션·브랜치·마일스톤 경계의 스냅샷이며 두 번째 활성 상태 원본으로 유지하지 않는다.

## 2. 규칙 우선순위

1. 사용자의 최신 확정 지시
2. 보안·안전·플랫폼 제약과 이 `AGENTS.md`
3. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`와 승인된 작업 계약
4. `[기획서]/DESIGN_DOCUMENT_REGISTRY.json`에 등록된 책임 원본
5. 실제 코드·데이터·자산·테스트·캡처·프로파일 증거
6. `docs/BASE_RULES_VERSION.md`에 고정된 Base 기준과 프로젝트별 차이
7. Base 원격 최신 `main`
8. 외부 사례·리뷰·과거 대화·초안·추정

정상 동작 중인 사용자 변경을 임의로 되돌리지 않는다. 외부 벤치마크·커뮤니티·모델 해석은 요구사항 권한이나 구현 사실의 정본이 아니다.

## 3. 적용 Base

- Base 저장소: `alsdmlals4-eng/Base`
- 적용 기록: `docs/BASE_RULES_VERSION.md`
- 현재 동기화 기준: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 상세 감사: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`

일상 작업은 프로젝트에 동기화된 규칙을 우선한다. Base 원격은 업데이트 감사, Base 제안, 공용 Skill 변경 때만 다시 비교한다.

## 4. 최초 읽기

```text
최신 사용자 지시
→ START_HERE.md
→ AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ [기획서]/00_프로젝트_허브/START_HERE.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ DEVELOPMENT_GATES.md
→ ROADMAP.md
→ [기획서]/DESIGN_DOCUMENT_REGISTRY.json
→ 현재 책임 원본
→ SKILL_REGISTRY.json
→ 필요한 Base 통합 Skill·Skill Mode와 프로젝트 Skill
→ Issue·Goal·Plan·실행 순서
→ 실제 코드·데이터·자산·테스트
```

`모두 확인`은 모든 파일·모든 Skill을 무작정 읽는다는 뜻이 아니다. Documentation Map과 Registry로 적용 책임 원본과 영향 파일을 전수 추적한다.

기본 제외:

- `docs/[백업]/`
- `docs/[보류]/`
- `[제거 후보]`
- 과거 생성물·구형 파생본
- trigger가 없는 전체 skills 폴더

감사·재개·reconcile-legacy 요청일 때만 위 영역을 읽는다.

## 5. 필요한 환경·권한

작업과 검증 전에 필요한 실행 파일, 라이브러리, 폰트, 입력 파일, 인증, 저장소·브랜치 권한을 확인한다.

누락 항목은 다음 형식으로 기록한다.

```text
필요 항목 / 이유 / 설치·설정 방법 / 재시작·적용 / 확인 명령 / 최소 권한
```

- 사용자 승인 없이 시스템 전역 설치·계정 설정·권한 확대·Branch protection 변경을 수행하지 않는다.
- 사용자가 설치·권한 부여를 완료했다고 알려도 실제 경로·버전·인증·쓰기 가능 여부를 확인한다.
- 실행하지 않은 조사·검사·렌더·권한을 통과로 보고하지 않는다.
- 현재 알려진 Windows 작업 경로는 `C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves`다. 작업 환경에서 읽을 수 없으면 원격 상태만 수정하고 로컬 미커밋 상태는 `[미검증]`으로 둔다.

## 6. Work Mode·Skill·Skill Mode

### Work Mode

- `PLAN`: 의도·요구·근거·정본·실행 순서. 기본 읽기·제안이며 승인 전 제품 변경 금지.
- `BUILD`: 승인 범위의 코드·데이터·문서·자산 구현과 단계별 검증.
- `REVIEW`: 적대적 검토·반례·증거·판정. 기본 읽기 전용이며 수정 승인 시 `BUILD`로 전환 후 다시 `REVIEW`한다.

한 시점에는 주 Work Mode 하나만 둔다. 복합 작업은 `PLAN → BUILD → REVIEW`로 전환할 수 있다.

### 자동 라우팅

새 L1 이상 요청은 `managing-project-intake-and-work-contract`에서 한 번만 처리한다.

```text
Prompt 의도·현재 단계 파악
→ Work Mode 자동 선택
→ Skill Registry trigger·do_not_use_when 대조
→ 필요한 최소 Skill 자동 선택
→ 각 Skill의 필요한 Skill Mode 자동 선택
→ 저장소 사실 조사
→ 필요한 경우 clarify
→ 사용자 마지막 확인
→ contract
→ 필요한 경우 decompose-and-sequence
→ 실행·검증
→ execution-report
```

사용자는 Skill이나 Skill Mode를 직접 선택할 필요가 없다. `load_by_default=false`는 자동 선택 금지가 아니라 trigger가 없을 때 불필요하게 읽지 않는다는 뜻이다.

라우팅 결과:

- 작업 수준 L0~L4
- 주 Work Mode 하나
- 주 책임 분야 하나와 영향 분야
- 변경 유형
- 최소 Foundation·분야 Skill과 Skill Mode
- 범위·제외·보호 대상
- 완료 기준·검증·롤백
- 필요한 경우 결과·의존성·병렬 묶음·게이트

금지:

- 사용자에게 Skill 선택을 전가
- Work Mode와 Skill Mode 혼용
- 전체 Skill 자동 로드
- trigger와 무관한 Skill 호출
- 실제 사용하지 않은 Skill을 사용했다고 보고
- 같은 요청의 수준·범위·상태를 여러 Skill에서 중복 판정
- 주 책임 분야 Skill 여러 개 지정
- 사용자 확인 전 구조·범위·실행 순서 확정
- 근거 없는 일정 숫자 발명
- 같은 파일·Schema·자산 경계를 무시한 병렬 작업

## 7. L1 이상 작업 계약

```yaml
work_contract_type: github_issue | approved_direct_request
work_level: L0 | L1 | L2 | L3 | L4
work_mode: PLAN | BUILD | REVIEW
primary_discipline:
affected_disciplines:
change_types:
goal:
user_or_player_value:
scope:
out_of_scope:
protected_paths_decisions_assets:
required_tools_and_files:
required_permissions:
required_design_document_ids:
foundation_skills:
discipline_skills:
skill_modes:
execution_steps:
dependencies:
parallel_batches:
acceptance_criteria:
validation:
stop_conditions:
rollback:
```

`decompose-and-sequence`는 승인된 L2 이상 또는 다중 의존성 작업에만 사용한다. 단계는 활동명이 아니라 `outcome / inputs / files / dependencies / output / acceptance / validation / rollback`을 가진다.

관계는 `BLOCKS / INFORMS / USES_OUTPUT / SHARES_RESOURCE / VALIDATES / OPTIONAL_FOLLOWUP`으로 구분한다.

## 8. 십보강호 제품 고정 계약

- 프로젝트 시작 정체성은 `[강호낭인]`이다.
- 전장은 정확히 10칸이다.
- 기본 시작 위치는 플레이어 3번, 상대 8번이다.
- 캐릭터는 같은 스케일이며 발 중심을 타일 앵커에 맞춘다.
- 한 라운드는 `3수 → 3수 → 4수`, 총 10수다.
- 10수 종료는 전투 종료가 아니라 다음 라운드 진입이다.
- 판정 순서는 `대응 → 속공 → 이동 → 일반 공격`이다.
- 같은 판정 단계 공격은 동시 피해를 적용한다.
- 기초 행동은 이동·보법·막기·회피·속공·강공·명상·태세 8종이다.
- 절초 기세 최대치는 5칸이다.
- 카드 하단 비용은 행동 슬롯·기력·내력만 사용한다.
- 덱·손패·남은 카드·행동력·공통 `막기 경감`은 사용하지 않는다.
- UI·VFX·애니메이션·오디오는 전투 결과를 표현하며 피해·자원·성장·저장을 직접 계산하지 않는다.
- AI는 플레이어의 비공개 행동을 읽지 않는다.
- 이미지·시안의 임시 수치·문구를 공식 기획값으로 해석하지 않는다.
- `docs/[보류]/` 기능은 사용자가 재개하기 전 코드·씬·데이터·테스트에 반영하지 않는다.

현재 상세 전투 규칙·구현 상태는 `docs/02_COMBAT_RULES.md`, `data/combat/`, `data/cards/`, `src/combat/`, `tests/`와 PR #7을 함께 확인한다.

## 9. 책임 원본·발행

- 서술 중심 기획은 Markdown, Registry·Manifest·상태·ID·경로·게임 데이터는 JSON을 사용한다.
- 한 질문에는 `[기획서]/DESIGN_DOCUMENT_REGISTRY.json`에 등록된 책임 원본 하나만 둔다.
- 같은 서술을 Markdown과 JSON 양쪽에 독립 원본으로 복제하지 않는다.
- `v2`, `final`, `latest`, 날짜 접미사의 활성 복제본을 만들지 않는다.
- DOCX·PDF·다이어그램은 파생본이며 독립 원본으로 수동 수정하지 않는다.

발행 정책:

- `source_only`: 원본과 직접 검증만 유지
- `milestone_sync`: 주요 게이트·정기 검토·외부 공유 시 PDF·Manifest 동기화
- `always_sync`: 원본·승인 이미지·생성기 변경과 같은 작업에서 상시 동기화

`CURRENT`, 자동 렌더, AI 시각 검수, 사용자 시각 검수는 독립 상태다. 생성 실패 시 기존 정상 산출물을 보존한다.

## 10. 기존 프로젝트·구형 파일 안전 처리

`managing-game-project-operating-system`을 자동 선택한다.

```text
PLAN: audit
→ 현행 책임·참조·고유 정보·버전 복제본 조사
→ 필요 시 reconcile-legacy 처리표
→ 목표 구조·보존·롤백 제안
→ 사용자 승인
→ BUILD: 승인된 UPDATE·MERGE·STUB·ARCHIVE·DELETE·migrate
→ REVIEW: 보존·참조·발행·복구 대조
→ reference-freshness
→ verify
```

파일별 상태:

```text
CURRENT
UPDATE_IN_PLACE
MERGE_TO_CANONICAL
COMPATIBILITY_STUB
ARCHIVE_HISTORY
DELETE_APPROVED
KEEP_UNRESOLVED
```

사용자 승인 전 금지:

- 파일·폴더 대량 삭제·이동·통합
- 파일명에 `old`·`v2`·`final`이 있다는 이유만으로 삭제
- 기존 책임 문서 대규모 축약
- 승인 이미지·자산 제거 또는 임의 교체
- 프로젝트 용어·수치·결정 변경
- `[보류]` 폐기
- Base 구조에 맞춘 강제 개명

고유 정보·활성 참조·파생본·복구·사용자 승인이 확인되지 않은 항목은 `KEEP_UNRESOLVED` 또는 `[제거 후보]`로 유지한다.

## 11. 변경 영향·정본 최신성

변경 후 `[기획서]/00_프로젝트_허브/DOCUMENT_UPDATE_MATRIX.md`를 확인한다.

- 제품 방향·범위: README, 01, 04, 05, Active Context
- 전투 규칙: 02, 05, 07, 08, 09, 10, 데이터·테스트·Plan
- 책임 원본·경로·ID·Schema: Design Registry, Documentation Map, 소비자, 생성기, 테스트, 파생본
- Skill: Skill Registry, Skill Map, Learning Log, Legacy Alias, 패키지 무결성 테스트
- 승인 이미지·생성기: Asset Manifest, 발행 Manifest, PDF·시각 검수
- 구현 범위·완료 기준: 테스트, Roadmap, Active Context, Handoff, PR

정본·경로·ID·Schema·정책·생성기 변경이 여러 소비자에 전파될 수 있으면 `auditing-canonical-reference-freshness`를 실행한다. 변경한 파일뿐 아니라 변경됐어야 하지만 untouched인 소비자도 확인한다.

## 12. 이미지·UI·접근성·성능

- 기존 승인 이미지가 있으면 별도 지시 없이 새 시안을 만들지 않는다.
- Asset ID·캐노니컬 경로·출처·승인 상태·채택·비채택 요소·실제 캡처를 기록한다.
- 생성 전 프롬프트와 구현 후 UI 감사는 독립 Skill이다.
- UI 감사 정적 패턴은 후보일 뿐 결함·자동 삭제 권한이 아니다.
- 사용자 승인된 finding만 수정하고 실제 Godot/Web 전후 렌더로 재검수한다.

접근성은 텍스트·대비·정보 채널·입력·탐색·시간·난이도·모션의 실제 플레이 장벽과 대체 경로를 확인한다. 법적 준수 인증으로 표현하지 않는다.

성능은 목표 플랫폼·동일 빌드·대표·최악 장면에서 frame time, CPU·GPU·메모리·네트워크·로딩을 baseline과 비교한다. 평균 FPS 하나나 빈 에디터 장면만으로 통과시키지 않는다.

## 13. 검증

일반 변경은 `reviewing-and-validating-project-changes`를 사용한다.

```text
작업 계약·실행 단계·diff 대조
→ 정본·경로·ID·Schema 변경 시 reference-freshness
→ 포맷·문법·정적 검사
→ 관련 자동 테스트
→ 실제 런타임·렌더·빌드
→ 적용 시 accessibility-review
→ 적용 시 performance-profile
→ 정상·실패·경계·원래 실패 반례
→ 저장·불러오기·호환성
→ 인접 기능 회귀
→ evidence-report
```

실행 환경이 없으면 `UNVERIFIED`로 기록한다. 체크리스트·Workflow·테스트 파일이 존재한다는 사실과 실제 실행 성공을 구분한다.

## 14. 작업 종료 정비

1. 확정 결정·수치·상태를 책임 원본에 반영한다.
2. Design Registry·Skill Registry·Manifest 영향을 확인한다.
3. Active Context·Roadmap·Documentation Map을 갱신한다.
4. Handoff는 경계 스냅샷이 필요할 때만 갱신한다.
5. Changelog·Decision Log·Learning Log에 필요한 기록을 남긴다.
6. Legacy Alias·정본 경로·낡은 용어·수치·중복을 검사한다.
7. 실행한 검증·실패·미검증을 분리한다.
8. 실제 구현·테스트·PDF·Actions·Required Check 상태를 증거와 일치시킨다.
9. 다음 작업자의 첫 행동·선행 조건·중단 기준·롤백을 기록한다.

## 15. Base 학습 환류

```text
프로젝트 관찰·검증
→ 프로젝트 고유 값 분리
→ 기존 Base 중복·충돌 확인
→ Base [수정제안서] 제안 전용 PR
→ 사용자 검토·구현 승인
→ 별도 Base 구현 PR
→ 프로젝트 Learning Log 갱신
```

프로젝트 고유 이름·밸런스·세계관·카드 사양·Godot 경로·일회성 구현 세부는 프로젝트에만 남긴다.

## 16. L1 이상 실행 보고

```yaml
work_mode:
skill_id:
skill_mode:
selection: automatic | user-directed
reason:
work_performed:
result:
evidence:
status: PASS | PARTIAL | FAIL | UNVERIFIED
```

최종 보고에는 다음을 분리한다.

- 사용한 Work Mode·Skill·Skill Mode와 이유
- 주 책임·영향 분야
- 실제 변경한 문서·코드·데이터·자산·Skill
- 유지한 기존 결정·동작·자산
- 정본·참조 최신성·변경 전파 결과
- 실행한 검증과 결과
- 미검증·사용자 확인 대기
- 접근성·성능 결과 또는 미실행 이유
- 남은 위험·롤백
- 보존·통합·보류·제거 후보
- 콜드 스타트 결과
- 다음 작업과 선행 조건

실행하지 않은 Skill, 조사, 테스트, 렌더링, 구현, 접근성·성능 검증, 브랜치 보호를 완료로 보고하지 않는다.
