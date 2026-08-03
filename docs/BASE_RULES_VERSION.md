# Base 규칙 적용 버전

## 1. 현재 권위

프로젝트의 Base 적용 권위는 다음 순서다.

```text
skills/PROJECT_BASE_ADAPTER.json
→ skills/PROJECT_SKILL_SNAPSHOT.json
→ skills/SKILL_REGISTRY.json
→ 프로젝트 AGENTS·START_HERE·Active Context
```

- Base 동기화 감사: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`.

현재 canonical Adapter:

```yaml
base_repository: alsdmlals4-eng/Base
base_release_version: 9.4.3
release_commit: 7dd1a4f80388bc5faca767ff74a3eb32dc9d0ac8
release_evidence_commit: da33a350d61b8adc52df97fccc7001708a933370
release_finalization_commit: 0b7c94f38d959efc0fc9442274c60b2e268a3c97
adapter: skills/PROJECT_BASE_ADAPTER.json
shared_skill_policy: adapter_only
project_local_skills: 4
publication_policy: source_only
```

Base 공용 Skill 본문을 프로젝트에 복제하지 않는다. 프로젝트 고유 규칙과 실제 경로만 로컬 Skill·Adapter가 소유한다.

## 2. Base v9.4.3 적용 감사

2026-08-02 적용 기준:

```yaml
base_payload_commit: 7dd1a4f80388bc5faca767ff74a3eb32dc9d0ac8
base_trusted_evidence_commit: da33a350d61b8adc52df97fccc7001708a933370
base_pin_finalization_commit: 0b7c94f38d959efc0fc9442274c60b2e268a3c97
base_registry_sha256: 693a0dff3f054ecdd653079909e044211473838e73dd9aff07734d1ce5694c59
base_release_state: BASE_RELEASED
project_adoption: V9_4_3_OPERATING_CONTRACT_APPLIED
product_paths_changed: false
```

Base v9.4 계열의 모델·추론 단계·Prompt caching·비용 측정, 지시 권위, Interface-first Prompt, Context 큐레이션, Artifact 주장 상한, Godot UI 모션 계약을 유지한다. v9.4.2의 기획 우선·Grill Me 최대 10건 승인 배치와 v9.4.3의 first-prompt 방향 고정·Grill Me alignment gate를 프로젝트 Adapter와 운영 문서에 적용한다. 십보강호의 전투 코어·무공 데이터·저장 Schema·승인 아트·실제 Godot 구현은 이 적용으로 변경하지 않는다.

## 3. 현재 적용 운영 계약

- Work Mode: `PLAN / BUILD / REVIEW`.
- Registry trigger 기반 최소 Skill·Skill Mode 자동 선택.
- 전체 Skill 기본 로드 금지.
- L1 이상은 `first-prompt → contract → clarify`와 Grill Me alignment gate를 거친다.
- L1 이상 `execution-report`.
- 기존 프로젝트 감사: `audit → reconcile-legacy → 승인 변경 → verify`.
- 적대적 검토: `attack → validate-critique → 승인된 최소 수정 → regression-recheck → decision-report`.
- 상세·가역 수치는 GPT 권장 기본값을 사용할 수 있지만, 성장 속도·경제·세션 길이·빌드 우열·핵심 경험을 바꾸면 `GRILL_ME_REQUIRED`다.
- 승인 Decision은 같은 ID로 활성 Branch의 GitHub 정본·planning data·Google Sheets에 즉시 연결한다.
- 승인 Decision 배치는 최대 10건이며, 고위험·정본 충돌·세션 종료·사용자 요청에서는 조기 체크포인트를 허용한다.
- 병합 전 Sheet 상태는 `APPROVED_PENDING_MERGE`, 병합 후 main·Sheet 재조회가 끝난 상태만 `SYNCED_TO_MAIN`이다.
- Google Sheets는 `USER_FACING_GDD_WORKSPACE`이며 실제 구현·GitHub 정본을 대체하지 않는다.
- 구현 PR은 동일 HEAD·필수 검사·P0/P1 없음·미해결 thread 0 뒤 담당 에이전트가 병합한다.

## 4. Skill 구조

현재 프로젝트 Adapter는 Base 활성 Skill 28개를 route하며 프로젝트 고유 Skill 4개를 유지한다.

프로젝트 고유 Skill:

- `ten-paces-game-design`
- `combat-ux-and-accessibility`
- `combat-implementation-handoff`
- `ten-paces-verification`

공용 Skill은 Base가 소유하고 로컬 Skill은 십보강호 고유 전투·UX·구현·검증 계약만 소유한다.

## 5. 정본·발행·아카이브

- 한 질문에 Markdown 또는 JSON 현재 책임 원본 하나.
- 승인 상태·구현 상태·검증 상태를 한 `status`에 혼합하지 않는다.
- DOCX·PDF·Dashboard는 정본이 아니다.
- 현재 제품 기획 문서는 생성기가 없는 `source_only`다.
- 아카이브·백업·보류는 현재 구현 권한을 갖지 않는다.
- 삭제는 고유 정보·활성 소비자·복구 경로·사용자 승인 확인 뒤 수행한다.

## 6. 프로젝트 고유 계약

Base가 아닌 프로젝트가 소유한다.

- 1대1 10칸 일자형 전장.
- 플레이어 4번·상대 7번 시작과 거리 0 `[밀착]`.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 합·연격·방어도·회피·중단·강건·복기.
- 무공서→현재 해금 기술→수 배치.
- 절초기세 `0~5` 예약·환불.
- 공개 상태 기반 상대 AI.
- 데모 5슬롯·후보 3명·중간 노드 8개.
- 전체 10슬롯·중간 노드 18개.
- Godot 코드·데이터·Scene·자산·테스트·런타임 상태.

## 7. 현재 프로젝트 상태와 검증

```yaml
main_state_sync_commit: 6d8237e00168e45a7d3c001a0f6b3587b57147b7
active_planning_pr: 82
active_planning_head: 289378c214702223dc0d1e149134438c3e761ba0
active_approval_count: 2/10
active_decision_state: APPROVED_PENDING_MERGE
project_adapter_validation: PASS
pr_validation: PASS_AT_ACTIVE_PR82_HEAD
base_v9_validation: PASS_AT_ACTIVE_PR82_HEAD
full_validation: PASS_AT_ACTIVE_PR82_HEAD
action_selection_godot_smoke: PASS
ubuntu_godot_headless: PASS
ubuntu_windows_python_matrix: PASS
windows_godot_runtime: NOT_RUN
human_validation: NOT_RUN
```

자동 검증은 실제 Windows Godot·실물 게임패드·화면 읽기 도구·사람 플레이를 대체하지 않는다. 활성 PR #82의 성공 검사는 현재 head의 두 승인 Decision 정합성 증거이며, 10/10 또는 조기 체크포인트의 최종 병합 허가를 뜻하지 않는다.

## 8. 역사·호환 기준

다음은 현재 권위가 아니라 재현·회귀를 위한 역사 입력이다.

- 과거 Base 코어 SHA `c987647d01ad2baa028a16e03d85ddfc1572a727`.
- 과거 archive extension SHA `6a224e450f9420223c00921f3c56e051612f92ad`.
- 당시 Base 비교 범위 `6개 커밋·43개 변경 파일`.
- v8 통합 실행문과 BCA 문서.
- PR #7·Issue #13 T0 계보.
- Base v9.4.0·v9.4.1·v9.4.2 채택 기록과 호환 Adapter view.

위 값은 `HISTORICAL_COMPATIBILITY_BASELINE`이며 canonical Adapter의 Base v9.4.3 pin을 덮어쓰지 않는다.

## 9. 재감사 조건

- Base release·Registry·route·Adapter Schema 변경.
- 프로젝트 Decision·정본·경로·ID·Schema 변경.
- Google Sheets tab·열·Decision sync 계약 변경.
- 제품 보호 경로 또는 저장 호환성 변경.
- first-prompt·기획 우선·Grill Me 배치 계약 변경.
