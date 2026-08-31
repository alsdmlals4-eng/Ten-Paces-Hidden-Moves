## 40. 실패 조건

다음 중 하나라도 있으면 완료를 선언하지 않는다.

### Base·권위

- instruction 작성 요청인데 실제 Base/프로젝트 작업까지 실행
- Base current main 재조회 없음
- recursive inventory 또는 미검증 범위 표시 없음
- Registry 없이 임의 Skill 선택
- v4.5의 snapshot을 영구 current authority로 사용
- v4.5의 Base 절차 복사본을 current Base보다 우선

### External Process

- 외부 process overlay가 project/Base canon을 덮어씀
- overlay가 안전 Gate를 약화
- 같은 승인 범위를 재승인 요구
- Skill을 읽기만 했는데 실행했다고 보고
- `OVERLAY_CONFLICT`를 숨김

### 프로젝트·기획

- PHASE A/B 완료 전에 PowerShell/Codex/Godot BUILD 시작
- 사용자 “기획 완료” 선언 없이 구현 단계 진입
- 핵심 요구 추적 누락
- 프로젝트 코어/핵심 재미 복원 없음
- benchmark 없이 중요한 권장안 확정
- 출처 사실과 추론 혼합
- Planning conflict를 사용자 승인 없이 결정
- 10개 Decision 최대 배치/early checkpoint 무시
- Grill Me에 벤치마킹·현업 비교가 필요한데 근거 없이 선택지 제시
- 승인 Decision을 GitHub 정본·계획 데이터·연결 Sheet에 가능한 즉시 동기화하지 않음
- 같은 Decision ID 연결 누락

### BCP-020 경험

- 자동 test/UI render로 HUMAN_USABILITY PASS 주장
- 사람 관찰 없이 PLAYER_EXPERIENCE PASS 주장
- 첫 세션에 대표 문제/행동/선택/결과/다음 질문 없음
- decision screen에서 비용·위험·결과가 읽히지 않음
- 코어 퍼즐/전투를 부당하게 minigame으로 강등

### PowerShell·Codex·Godot

- 사용자 지정 기본 Codex command 검증 없이 임의 변형
- PowerShell 사용자 승인 프롬프트를 불필요하게 2개 초과 생성
- `-a never` 운영인데 Codex 내부 approval 의존 workflow 설계
- 이전 PowerShell/Codex/Godot session/PID를 다음 블록의 current truth로 사용
- Godot 버전 추측
- HiGodot 채택 계약을 우회한 persistent authoring
- GUT 0 test discovery를 성공 처리
- Hera QA 후 tracked source delta 존재
- clean import 미검증
- actual main scene 실행 없음

### 자산

- Draft/placeholder 최종화
- provenance/license 미검증
- shared audio 원본 무단 변경
- 외부 절대 경로 production dependency
- local-only asset 후보가 tracked production 참조

### CI·PR

- 작업 시작/배치 종료/병합 후 모든 Open/Draft PR 감사 누락
- proposal-only/reference-only/DO_NOT_MERGE PR 자동 병합
- stale/duplicate PR 후속 정리 누락
- mutable Action tag/branch를 고위험 workflow에서 사용
- 과도한 `GITHUB_TOKEN` 권한
- Required Check 실패/미실행
- wrong SHA 검증
- strict up-to-date 우회
- unresolved thread
- Draft 상태인데 merge ready 주장
- `main` 이동 후 이전 GREEN으로 병합
- 승인 범위 밖 diff
- adversarial finding 미해결

### 병합 후

- 새 main readback 없음
- affected canon/consumer 재검토 없음
- 안전조건 없는 branch 삭제
- dirty/diverged local을 force/reset
- 사용자가 받을 수 없는 로컬 상태를 “전달 완료”로 주장

---

## 41. 최종 보고 형식

```markdown
# 최종 작업 보고

## 1. 작업 대상
- Base main:
- Project:
- Approved scope:
- Approval reference:
- Work Mode:

## 2. Base 라우팅
- Registry:
- Selected Skills:
- Executed modes:
- External process overlay:
- Read-only vs actually executed:

## 3. 프로젝트 복원
- Current decisions:
- Actual implementation:
- Sheet:
- Entry reconciliation:

## 4. 기획
- Planning phase:
- User planning-complete declaration:
- Requirement traceability:
- Goal:
- Pointed fun:
- Core loop:
- Core/support systems:
- Benchmark:
- Existing Solution First:
- Grill Me decisions:
- Grill Me batch checkpoint:
- Canon/Sheet Decision sync:
- Final planning review:

## 5. 플레이어 경험
- TECH_EVIDENCE:
- UI_EVIDENCE:
- HUMAN_USABILITY_EVIDENCE:
- PLAYER_EXPERIENCE_EVIDENCE:
- First session:
- Decision screen:
- Minigame narrative function:

## 6. Visual / Asset / Audio
- Visual Requirement:
- Asset Vault:
- Reference Library:
- Shared Audio:
- Provenance:

## 7. Godot
- Version:
- HiGodot:
- GUT:
- Hera:
- Clean import:
- Main scene:
- Project Play:

## 8. Windows / Android
- Shared core:
- Platform adapters:
- Size:
- Performance:

## 9. 변경
- PowerShell/Codex execution command:
- Manual approval prompts used:
- Fresh execution identity:
- Files:
- Protected items preserved:

## 10. TDD / 검증
- RED:
- GREEN:
- Static:
- Runtime:
- Accessibility:
- Performance:
- Regression:
- NOT_RUN:

## 11. 적대적 검토
- Attack findings:
- Validated:
- Rejected critiques:
- Fixed:
- Remaining:

## 12. GitHub
- All Open/Draft PR audit:
- PR:
- Review head:
- Base:
- CI target:
- ci-gate:
- Threads:
- Merge:
- New main:
- Branch cleanup:

## 13. Sheet / 정본
- Decision sync:
- Canon readback:
- Sheet readback:

## 14. 로컬 전달
- Fetch:
- Pull:
- Local main:
- Godot Run:

## 15. Base 승격·Skill 변화
- Project-source BCP:
- Proposal registry/index:
- Active Registry mutation:
- Feature-level classification:
- Partial Skill absorptions:
- Skill consolidation/new Skill:
- Follow-up:

## 16. User Action Required
- 사용자만 가능한 작업:
- 왜 필요한가:
- 정확한 단계/명령:
- 기대 결과:
- 완료 후 제공할 증거:

## 17. 최종 판정
PASS | PASS_WITH_FOLLOWUP | BLOCKED_UNVERIFIED | REVISE
```

---

## 42. Base 정본 링크

이 파일은 아래 내용을 복제하지 않고 current Base를 직접 읽는다.

```text
https://github.com/alsdmlals4-eng/Base/blob/main/START_HERE.md
https://github.com/alsdmlals4-eng/Base/blob/main/AGENTS.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/OPERATING_MODEL.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/WORK_MODE_AND_SKILL_ROUTING.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/DOCUMENTATION_MAP.md
https://github.com/alsdmlals4-eng/Base/blob/main/skills/SKILL_REGISTRY.json
https://github.com/alsdmlals4-eng/Base/blob/main/docs/generated/BASE_ACTIVE_SKILLS.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/CAPABILITY_COMPOSITION_MAP.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/knowledge/game-development/GAME_DESIGN_AND_PLAYER_EXPERIENCE_GUIDE.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/CONFIRMED_DECISION_SYNC_POLICY.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/GITHUB_PRO_OPERATING_POLICY.md
```

필요 Skill은 Registry로 찾는다.

주요 역할 예:

```text
managing-project-intake-and-work-contract
running-adversarial-review-and-refinement
auditing-canonical-reference-freshness
reviewing-and-validating-project-changes
evaluating-godot-assets-and-plugins-before-creation
diagnosing-game-engine-runtime-failures
maintaining-project-context-and-handoff
managing-base-change-proposals
```

목록은 예시일 뿐 current Registry를 대체하지 않는다.

---

## 43. v4.4 → v4.5 Migration

v4.5가 의도적으로 제거한 것:

```text
Base Skill별 세부 절차의 대량 복제
Base current Action SHA 복제
Base 현재 Skill 수를 설계 계약으로 고정
Base 정책 문서의 장문 재서술
과거 Base snapshot을 current truth로 사용
```

v4.5가 보존한 것:

```text
프로젝트 입력/경로
Windows/Android 공용 코어
HiGodot/GUT/Hera 역할
Asset/Reference/Audio Vault
Planning First
Existing Solution First
Grill Me conflict approval
10 Decision batch
TDD
on-demand Codex
exact validation target
merge authority inheritance
main readback
Fetch/Pull local handoff
Project Play
adversarial review
Base BCP promotion
```

v4.5가 추가한 것:

```text
GPT_CHAT_PLANNING_COMPLETE_BEFORE_POWERSHELL_CODEX_GODOT_BUILD
GRILL_ME_10_MAX_BATCH_CLOSE_AND_PLANNING_PR
CURRENT_CONVERSATION_AUTO_MERGE_APPROVAL
OPEN_DRAFT_PR_FULL_INVENTORY
POWERSHELL_CODEX_FULL_AUTO_WITH_MAX_2_MANUAL_APPROVAL_GATES
PROJECT_SOURCE_BCP_PROPOSAL
PARTIAL_SKILL_ABSORPTION
FUNCTION_LEVEL_VALIDITY_CLASSIFICATION
USER_ACTION_REQUIRED_AT_END
EXTERNAL_PROCESS_OVERLAY
BCP-020 evidence separation
FIRST SESSION representative experience
DECISION SCREEN comprehension
MINIGAME narrative function gate
Base repository-setting drift Issue #277 visibility
thin-adapter authority rule
```

### 43.1 v4.4 대비 명시 복원 확인

v4.4에서 독립 섹션이었으나 초기 v4.5 Thin Adapter에서 축약됐던 다음 프로젝트 고유 계약을 다시 명시했다.

```text
핵심 요구 추적표
구현 원칙·작업 유형별 TDD
완성형 Vertical Slice 기준
GPT/Codex/객관 증거 역할 분리
로컬 접근 불가 시 행동
```

이 복원은 Base current canon을 복제하기 위한 것이 아니라 프로젝트의 실행·증거·전달 경계를 보존하기 위한 것이다.

### 43.2 이번 v4.5 revision 반영 검증표

| 요청/보호 항목 | 반영 위치 | 상태 |
|---|---|---|
| 기획 우선 | 0.2, 8.1 | `PASS` |
| 상세 수치 GPT 권장안 | 8.2 | `PASS` |
| 기획 충돌 Grill Me 승인 | 8.2, 11 | `PASS` |
| Grill Me 최대 10건 + 조기 체크포인트 | 11.3 | `PASS` |
| 10건 배치마다 정본/Sheet/PR/적대적 검토 | 11.2~11.3 | `PASS` |
| Grill Me·작업 시 벤치마킹/현업 비교 | 9, 11.1 | `PASS` |
| 작업마다 TDD | 25 | `PASS` |
| 현재 대화 승인 범위 자동 병합 | 12.0 | `PASS` |
| GitHub 정본·계획 데이터·Google Sheet 같은 Decision ID | 11.2 | `PASS` |
| 브레인스토밍·Superpowers·적대적 검토 | 3, 28.1 | `PASS` |
| 사용자 행동 전용 blocker를 마지막에 요청 | 37.4, 최종 보고 | `PASS` |
| GPT가 직접 해결 가능하면 직접 해결 | 26.3, 37.4 | `PASS` |
| PowerShell Codex 기본 command | 26.1 | `PASS` |
| 사용자 수동 승인 최대 2회 | 26.2 | `PASS` |
| PowerShell/Codex/Godot fresh-session 재시작 | 26.4 | `PASS` |
| 프로젝트 출처형 BCP | 36.1 | `PASS` |
| proposal 단계 Base 활성 규칙 미변경 | 36.1~36.2 | `PASS` |
| Open/Draft PR 전체 감사 | 32 | `PASS` |
| proposal/reference/DO_NOT_MERGE 보호 | 12.0, 32.3 | `PASS` |
| Skill 부분 흡수 | 37.1 | `PASS` |
| 기능 단위 상태 분류 | 37.2 | `PASS` |
| 최적 작업 요소 누락 시 blocker | 37.4 | `PASS` |
| GPT 기획 완료 선언 후에만 local BUILD | 0.2, 26 | `PASS` |
| v4.4 핵심 요구 추적표 | 7.1 | `PASS` |
| v4.4 작업 유형별 TDD/구현 원칙 | 25 | `PASS` |
| v4.4 Vertical Slice 완료 기준 | 35.1 | `PASS` |
| v4.4 GPT 역할 분리·객관 증거 | 28.2 | `PASS` |
| v4.4 로컬 접근 불가 행동 | 35.2 | `PASS` |

의도적으로 복원하지 않은 것은 Base current canon의 장문 복제·과거 Action SHA·고정 Skill 수처럼 Thin Adapter 원칙과 충돌하는 내용뿐이다.
그 항목들은 **누락이 아니라 current Base 재조회로 대체**한다.

---

## 44. 최종 원칙

```text
이 지시문을 업데이트하는 요청에서는 지시 범위를 넘어 실제 프로젝트 작업을 실행하지 않는다.
Base는 매번 current main에서 다시 읽는다.
이 파일은 Base의 복제 정본이 아니라 프로젝트 Thin Adapter다.
GPT 채팅에서 기획을 모두 닫고 사용자가 “기획 완료”를 선언한 뒤 최종 검수를 끝내기 전에는 PowerShell/Codex/Godot BUILD를 시작하지 않는다.
상세 데이터 수치는 GPT 권장안+범위+벤치마킹으로 진행하되 기획 충돌은 Grill Me 승인 없이는 확정하지 않는다.
Grill Me는 10건을 최대 배치로 하고 고위험·세션 종료·정본 영향이 크면 조기 체크포인트를 허용한다.
각 승인 배치의 Decision은 같은 ID로 GitHub 정본·계획 데이터·연결 Sheet에 즉시 동기화하고 planning PR 검수·적대적 검토까지 닫는다.
모든 작업은 TDD/test-first로 진행한다.
현재 대화에서 이미 승인된 동일 범위 PR은 모든 Gate 통과 후 별도 병합 승인 없이 자동 병합한다.
모든 Open/Draft PR을 작업 시작·배치 종료·병합 후 재감사한다.
PowerShell/Codex 기본은 `codex.cmd -a never -s workspace-write`이며 사용자 수동 승인 프롬프트는 최대 2개로 억제한다.
PowerShell/Codex/Godot 실행 블록이 끝나면 세션을 닫고 다음 블록은 fresh-read부터 다시 시작한다.
수정제안서는 Base 활성 규칙을 proposal 단계에서 건드리지 않고 `[수정제안서]/BCP - [프로젝트명]` 출처형 evidence proposal로 시작한다.
Skill은 전체 채택만 보지 않고 기능·mode·checklist·reference 단위의 부분 흡수를 적극 검토한다.
모든 기능은 이미 반영됨 / 현재에도 유효 / 충돌·구형 / 부분 재사용 / 누락 필요로 분해해 판정한다.
최적 작업에 필요한 요소가 없으면 GPT가 직접 해결 가능한지 먼저 판단하고, 사용자만 가능한 blocker는 마지막 User Action Required에 정확한 조치로 모은다.
Registry로 필요한 Skill만 선택하고, 읽은 Skill과 실행한 Skill을 구분한다.
외부 process framework는 EXECUTION_PROCESS_ONLY이며 project/Base canon을 소유하지 않는다.
같은 승인 범위는 REUSED_APPROVAL로 진행하고 기술 재검증 때문에 재승인받지 않는다.
Planning은 구현보다 먼저 닫고 중요한 충돌만 Grill Me로 올린다.
벤치마킹은 공식·현업 근거를 사용하되 프로젝트 정본을 대체하지 않는다.
기존 해법을 먼저 조사하고 BUILD_NEW를 기본값으로 두지 않는다.
TECH, UI, HUMAN_USABILITY, PLAYER_EXPERIENCE 증거는 서로 대체하지 않는다.
사람을 관찰하지 않았으면 HUMAN/PLAYER evidence는 NOT_RUN이다.
첫 세션은 대표 문제→행동→선택→결과→다음 질문의 압축판이다.
핵심 결정 화면은 상황·선택·필요정보·비용/위험/결과를 읽을 수 있어야 한다.
코어 인터랙션을 미니게임으로 강등하지 않는다.
Visual Requirement와 Asset Vault 승인은 분리한다.
HiGodot은 채택된 프로젝트에서 persistent Godot authoring의 단일 권위다.
GUT은 deterministic GDScript test 권위이며 production을 저작하지 않는다.
Hera는 live QA/observability만 수행하고 tracked source delta를 남기지 않는다.
Windows와 Android는 하나의 게임 로직·데이터 코어를 공유한다.
public repo의 standard GitHub-hosted Actions는 예산 0이어도 REMOTE_CI 기본이다.
Actions는 reviewed full-length SHA와 least privilege를 사용한다.
검증 중 main이 움직이면 이전 GREEN을 재사용하지 않고 current base에서 재검증한다.
Required ci-gate와 unresolved thread, strict up-to-date를 우회하지 않는다.
병합 성공은 new main readback으로 확인한다.
사용자 로컬 전달은 Fetch origin→Pull origin 중심으로 유지한다.
실행하지 않은 조사·Skill·test·Godot·기기·사람 검증을 실행했다고 말하지 않는다.
```
