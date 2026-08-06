# 통합 작업지시문 v4.3 프로젝트 바인딩 결정

- Decision ID: `TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01`
- 승인일시: 2026-08-06 23:47:51 KST
- 상태: `CURRENT_APPROVED_PROJECT_OPERATING_CONTRACT`
- 계약: `docs/planning-data/approved_20260806_integrated_work_contract_v4_3_binding.json`

## 1. 기준 계약

`PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION v4.3`을 십보강호의 현행 통합 작업 기준으로 사용한다.

```yaml
contract_version: 4.3
review_model: GPT_ROLE_SEPARATED_PLUS_USER_DECISION_AUTHORITY
external_independent_reviewer: NOT_PLANNED_SOLO_DEVELOPMENT
merge_authority: CURRENT_CONVERSATION_RECOMMENDED_MERGES_AUTO_APPROVED
```

별도의 인간 독립 리뷰어가 존재한다고 가장하지 않는다. 검토는 구현자 설명과 분리된 입력 패킷으로 수행하는 GPT 검토자 역할, 사용자 최종 결정권, GUT·CI·exact-HEAD 객관 증거의 세 축으로 구성한다.

## 2. 실제 프로젝트 바인딩

업로드된 지시문의 예시 경로는 템플릿 기본값이며 이 프로젝트에는 다음 실제 입력을 적용한다.

```yaml
project_repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
project_default_branch: main
project_local_path: C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves
canonical_local_checkout: C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves
godot_project_path: C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves
project_google_sheet_id: 1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0
```

로컬 경로는 현재 에이전트가 접근할 수 없으므로 `LOCAL_SYNC_BLOCKED_NO_LOCAL_ACCESS`와 `GODOT_RUN_BLOCKED_NO_LOCAL_ACCESS`를 유지한다.

## 3. 작업 진입 Gate

작업 시작 시 Base·프로젝트 GitHub·Google Sheet를 새로 읽고 다음을 재판정한다.

- Decision 원장.
- 미확정·차단·보류 목록.
- 이미지 검수 상태.
- 현재 Goal·Issue·PR·merged main.
- GUT 채택 명세 병합 여부.
- HiGodot 권위·연결·버전 증거.

근거 없는 READY/AWAITING은 `BLOCKED`, `MISSING_EVIDENCE`, `STALE_STATUS`로 되돌린다.

## 4. 역할과 병합 권위

현재 대화에서 제안·검토·승인된 비충돌 권장안은 exact HEAD 전체 검토, Required Check 성공, unresolved thread 0, P0/P1 없음, 저장소 정책 통과 후 자동 병합 승인 범위에 들어간다.

branch protection 또는 Ruleset이 다른 계정의 승인 리뷰를 실제로 강제하면 우회하지 않고 `BLOCKED_REQUIRED_EXTERNAL_REVIEW`로 보고한다.

## 5. GUT·HiGodot 선행 조건

- HiGodot: `SINGLE_GODOT_SCENE_NODE_RESOURCE_PROJECT_SETTINGS_AUTHOR`.
- GUT 9.7.1: `FORMAL_TEST_EXECUTION_AND_ASSERTION`.
- GUT는 production Scene·Resource·project.godot을 수정하지 않는다.
- GUT 정식 설치 전에 별도 adoption-spec Draft PR을 검토·병합한다.
- 명세 미병합 상태의 정식 설치는 `BLOCKED_BY_GUT_ADOPTION_SPEC`다.

## 6. 오디오 및 플랫폼

공유 사운드 Vault `C:/Users/user/Documents/GitHub/shered audio vault`는 read-only 원본 라이브러리로 취급한다. 로컬 접근·권리·hash가 검증된 파일만 프로젝트 `res://` 하위로 복사할 수 있으며 절대 경로 runtime 참조는 금지한다.

Windows·Android는 단일 게임 로직·데이터 코어를 공유하고 입력·UI·플랫폼 통합만 분리한다.
