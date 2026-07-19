# 십보강호 협업 규칙

## 1. 규칙 우선순위

문서와 실제 파일이 충돌하면 다음 순서를 따른다.

1. 사용자의 최신 확정 지시.
2. 보안·안전·플랫폼 제약과 이 `AGENTS.md`.
3. `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
4. 승인된 프로젝트 책임 원본과 GitHub Issue·직접 요청·Plan.
5. 실제 구현·데이터·자산·테스트 증거.
6. `docs/BASE_RULES_VERSION.md`에 고정된 Base 커밋과 프로젝트별 차이.
7. Base 원격 최신 `main`.
8. 과거 대화·초안·추정.

실제 구현 상태는 파일과 실행 결과로 확인한다. 문서·체크리스트·Workflow 파일 존재만 보고 구현·테스트·CI 완료를 추정하지 않는다.

## 2. 최초 읽기

```text
최신 사용자 지시
→ START_HERE.md
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/START_HERE.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ DEVELOPMENT_GATES.md
→ [기획서]/DESIGN_DOCUMENT_REGISTRY.json
→ SKILL_REGISTRY.json
→ 현재 작업의 책임 원본
→ Issue·Plan·실제 파일·검증
```

- 저장소 전체와 모든 스킬을 무조건 읽지 않는다.
- `docs/[백업]/`, `docs/[보류]/`, `[제거 후보]`는 감사·재개·삭제 검토 요청이 없는 한 기본 읽기와 구현에서 제외한다.
- Active Context와 실제 파일이 충돌하면 차이를 보고하고 확인된 증거를 기준으로 갱신한다.

## 3. 작업 계약·스킬 라우팅

L1 이상 작업은 다음을 판정한다.

```yaml
work_contract_type: github_issue/approved_direct_request
work_level:
primary_discipline:
affected_disciplines:
change_types:
goal:
user_or_player_value:
scope:
out_of_scope:
protected_paths:
required_tools_and_files:
required_permissions:
required_design_document_ids:
foundation_skills:
discipline_skills:
deferred_skills:
acceptance_criteria:
validation:
stop_conditions:
```

- 주 책임 분야는 하나다.
- `SKILL_REGISTRY.json`에서 trigger가 일치하는 최소 스킬만 선택한다.
- 주 책임 분야 스킬은 최대 하나, Foundation 스킬은 필요한 최소 개수만 사용한다.
- 검증·발행·Handoff 스킬은 해당 게이트에 도달했을 때만 사용한다.
- 전체 스킬 자동 로드와 같은 책임의 중복 스킬 호출을 금지한다.

## 4. 딥인터뷰·승인 게이트

기능·게임 경험·아트 방향·구조·워크플로·Base 변경처럼 선택이 필요한 L2 이상 요청은 다음 순서를 따른다.

```text
저장소 사실 조사
→ 사용자 결정이 필요한 질문
→ 결정·모호성 기록
→ 마지막 재진술 확인
→ 실행 계약·Plan
→ 구현
```

명확한 사용자 직접 요청이 목표·범위·보호·완료 기준을 충분히 제공하면 확인 근거를 Interview Registry에 기록하고 실행할 수 있다. 오탈자·명확한 단일 파일 기계 수정·동일 검사 재실행은 인터뷰 예외다.

## 5. 기획 책임 원본·발행

- 서술 중심 기획은 Markdown을 기본 책임 원본으로 사용할 수 있다.
- Registry·Manifest·상태·ID·경로·게임 데이터는 JSON으로 관리한다.
- 한 문서에는 Markdown 또는 JSON 단일 책임 원본 하나만 둔다.
- 현재 활성 본책은 `[기획서]/DESIGN_DOCUMENT_REGISTRY.json`에 등록된 `docs/01~11`이다.
- 활성 `*_v2`, `*_final`, `*_latest`, `copy`, `new` 복제본을 만들지 않는다.
- DOCX·PDF·다이어그램은 파생본이며 독립 원본으로 수동 유지하지 않는다.
- PDF는 항상 동기화 대상이다. 실제 생성·전 페이지 렌더·검수 전에는 CURRENT로 표시하지 않는다.
- 자동 렌더 검수와 사람 시각 검수를 별도 상태로 기록한다.
- 생성 실패 시 기존 정상 산출물을 보존한다.

## 6. 기존 프로젝트 마이그레이션·보존

```text
Audit only
→ Governance foundation
→ 사용자 승인된 책임 이관
→ 보존·참조·발행 검증
→ 승인된 Cleanup·Enforcement
```

조사와 사용자 승인 없이 다음을 삭제·축약·변경하지 않는다.

- 승인 기획·결정·고유 수치·용어·예외.
- 현재 구현 상태와 실제 경로.
- 승인 이미지·UI·다이어그램·프롬프트.
- 테스트 결과·실패·미검증 기록.
- Roadmap·Issue·Plan·PR 이력.
- `[백업]`, `[보류]`, `[확인 필요]`, `[미검증]`.
- 외부에서 참조되는 파일과 승인 근거.

기존 `docs` 본책은 Registry·PDF·링크·보존 대조와 별도 삭제 승인 전 제거하지 않는다. 확신할 수 없으면 `[제거 후보]`로 유지한다.

## 7. 제품 기획·구현 경계

- 전장 10칸·라운드 10타이밍·대회 10전과 5전 데모의 승인 구조를 임의로 변경하지 않는다.
- 전투·성장·AI·저장 결과는 도메인 계층이 소유한다.
- UI·VFX·애니메이션·오디오는 입력과 표현을 담당하며 피해·보상·수련·저장을 직접 계산하지 않는다.
- AI는 플레이어의 비공개 행동을 읽지 않는다.
- 시안의 임시 수치로 전투·성장 기준을 확정하지 않는다.
- 사용자가 재개하지 않은 `docs/[보류]/` 기능을 코드·씬·데이터·테스트에 반영하지 않는다.
- 실제 Godot 파일을 읽지 않고 구현 경로·완료를 추정하지 않는다.

## 8. 관련 문서 동기화

변경 후 `[기획서]/00_프로젝트_허브/DOCUMENT_UPDATE_MATRIX.md`를 확인한다.

- 제품 방향·범위가 바뀌면 README, 01, 04, 05, Active Context를 확인한다.
- 전투 규칙이 바뀌면 02, 05, 07, 08, 09, 10과 구현 Plan을 확인한다.
- 책임 원본·경로가 바뀌면 Design Registry와 Documentation Map을 갱신한다.
- 스킬이 바뀌면 Skill Registry·Skill Map·Learning Log를 갱신한다.
- 승인 이미지·원본·생성기가 바뀌면 관련 Manifest와 PDF 발행을 다시 수행한다.
- 구현 범위·완료 기준이 바뀌면 테스트와 Plan을 함께 확인한다.

## 9. 작업 종료 정비

1. 확정된 결정·수치·상태를 책임 원본에 반영한다.
2. Design Registry·Skill Registry·Manifest 영향 여부를 확인한다.
3. Active Context·Roadmap·Handoff·Documentation Map을 최신화한다.
4. Changelog·Decision Log·Learning Log에 필요한 기록을 남긴다.
5. 낡은 표현·수치·경로·중복을 검색한다.
6. 실행한 검증·실패·미검증을 분리한다.
7. 실제 구현·테스트·PDF·Actions·Required Check 상태를 증거와 일치시킨다.
8. 다음 작업자의 첫 행동·선행 조건·중단 기준을 기록한다.

## 10. Base 학습 환류

프로젝트 교훈을 Base에 자동 반영하지 않는다.

```text
프로젝트 관찰·검증
→ 프로젝트 고유 값 분리
→ 기존 Base 중복·충돌 확인
→ Base [수정제안서] 제안 전용 PR
→ 사용자 검토·구현 승인
→ 별도 Base 구현 PR
→ 프로젝트 학습 기록 갱신
```

사용자가 특정 Base 변경을 직접 승인한 경우에만 제안 단계를 생략할 수 있다. 프로젝트 고유 이름·밸런스·세계관·카드 사양·Godot 경로·일회성 구현 세부는 프로젝트에만 남긴다.

## 11. 로컬 작업본·도구·권한

현재 사용자가 제공한 로컬 경로는 다음이다.

`C:\Users\user\Documents\바이브코딩\ten-paces-hidden-moves-base-full-11-migration`

작업 환경에서 해당 경로를 실제로 읽지 못하면 원격 저장소만 기준으로 변경하고 로컬 전용 파일·미커밋 변경·Godot 상태를 `[미검증]`으로 보고한다.

필요한 실행 파일·라이브러리·폰트·입력·인증·권한이 없으면 우회 결과를 정상 완료로 처리하지 않는다. 필요 항목, 이유, 설치·적용 방법, 확인 명령과 최소 권한을 기록하고 설치 후 실제 환경을 다시 검증한다.

## 12. 결과 보고

- 수정한 책임 원본·운영 파일과 이유.
- 보존·이동·삭제한 파일과 승인 근거.
- Registry·Manifest·스킬·발행 영향.
- 실제 수행한 검증·실패·미검증.
- Base 제안 후보와 프로젝트 전용으로 남긴 값.
- 다음 작업자의 첫 확인 항목과 차단 요인.
