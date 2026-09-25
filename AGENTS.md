# 십보강호 협업 규칙

이 파일은 항상 필요한 프로젝트 경계와 읽기 경로만 소유한다. 설명은 한국어로 결과·작동 방식·직접 확인 방법을 먼저 제시한다.

## 시작과 정본

```text
최신 사용자 지시 → 보안·플랫폼 제약 + AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md + 최신 main·관련 PR
→ 현재 결정·질문별 owner·실제 코드/데이터/consumer
→ skills/SKILL_REGISTRY.json의 필요한 Skill Mode
→ 채택 Base 계약과 최신 Base main의 필요한 owner
```

GitHub의 REPOSITORY_HUMAN_FACING_CANON / REPOSITORY_STRUCTURED_CANON / REPOSITORY_RUNTIME_TRUTH가 정본이다. `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`을 따른다. Notion은 역사·이관 입력, Google Sheets는 MIGRATION_ONLY_UNTIL_REMOVAL이다. 과거 채팅·PDF·pin·닫힌 PR은 현재 상태를 대신하지 않는다. 충돌은 CANON_CONFLICT로 확인하고 임의의 정본을 만들지 않는다.

## 승인된 작업 실행

- PLAN / BUILD / REVIEW와 Skill Mode를 구분한다. 새 변경은 의도·현재 상태·변경/보호·구현 방향·완료/검증 기준을 설명하고 승인받는다. 같은 범위는 REUSED_APPROVAL로 이어가며 단계·세션마다 재계획·재승인하지 않는다.
- UNIFIED_WORK_EXECUTION: 현재 세션의 실제 능력과 승인으로 설계·구현·자산 연결·검증·교정·정본 갱신·허용된 정상 PR 병합과 main readback까지 수행한다. 인계는 실제 capability gap 또는 사용자 지정일 때만 한다. 도구 가용성은 새 권한이 아니다.
- 새 방향·범위·비용·보안·파괴적 변경·게임 핵심 의미는 별도 결정이다. `진행해`는 같은 승인 계약의 continuation이다.
- 작업 전 CURRENT_SOURCE_RELEVANCE_CHECK로 기존 구현·승인 자산·Base 사례부터 확인한다. 유효한 동일 근거는 REUSED_EVIDENCE로 재사용하고 중요한 새 판단에 필요한 공식 자료만 추가한다. 비교 수 채우기·허수 대안·매 수정의 새 보고서를 만들지 않는다.
- SOURCE_DEPENDENCY_SCOPED_BLOCKER: 필수 근거 실패는 의존 작업만 BLOCKED_UNVERIFIED로 둔다. 별도 승인·근거가 있는 독립 작업은 계속한다. 사용자가 전체 중단을 지시하면 중단한다.
- RECOVERY_ONLY: 생성 라우터의 무결성 검사 실패를 무시하지 않는다. 읽기 전용 진단과 승인된 제한적 복구만 진행하고 원 실패·범위를 보존한다. 같은 승인에서는 반복 승인을 요청하지 않는다. 생성 라우터는 채택한 Base 출력으로 유지하며 승인 조작·검사 약화를 금지한다. 복구 뒤 같은 검사와 영향 회귀를 통과하기 전 차단된 일반 실행은 재개하지 않는다.
- 전체 적대 검토는 동일 승인 후보 전체에서 정확히 2회이며 단계마다 초기화하지 않는다. 이후는 결함별 교정과 영향 검증이다. `docs/decisions/2026-09-09_TWO_ROUND_INTERNAL_REVIEW.md` 참조. 개수만 채워 PASS로 하지 않는다.
- Base와 설치 스킬의 접수·계획·검토를 중복 실행하지 않는다. 현재 주 책임 owner와 승인 참조를 한 번 연결한다. 설치 플러그인·전역 설정은 변경하지 않는다.
- L1+ 실행은 기존 execution-report에 기준 SHA / Work Mode / Skill / Skill Mode / 수행 / 결과 / 증거 / 미검증을 짧게 남긴다. 경로·ID·schema 변경은 reference-freshness로 실제 참조와 생성물을 확인한다.

## 제품 불변식

- 1대1 10칸 일자형 논리 전장, 시작 공개 거리 2, 거리 0 `[밀착]`, 화면은 `거리 N` 중심.
- 새 게임: `10초 행동 설계 → 전투 진행`. 0.1초 논리 눈금에 선딜·발동·후딜을 배치한다. `TEN-DEC-20260925-FRAME-TIMELINE-PROLOGUE-01`이 기존 3·3·4 코어를 대체하며 구형 저장은 호환 경로로만 유지한다. 공개 상태·해결 이력 기반 상대 추론. AI는 미확정 계획·숨은 기술 배치·UI 의도를 읽지 않는다.
- 덱·손패·드로우·장착 기술 제한 없음. 현재 해금 기술을 수에 배치한다. 합·방어도·회피·중단·강건·복기를 보존한다. 성장은 파훼 선택지를 확장한다.
- platform_decision: TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01; design_platforms: WINDOWS_ANDROID; platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS; android_runtime_evidence: NOT_RUN.
- 전투 규칙·AI·콘텐츠·ID·수치·저장 Schema는 하나의 공유 코어이며 UI/VFX/audio가 재계산하지 않는다. localization `ko/en/ja/zh-*`, Chinese variant 미확정. responsive `pc_standard / pc_wide_or_ultrawide / mobile_landscape` 의미 동등성을 보호한다.
- 제품 보호 경로: `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`. 핵심 의미·저장 호환성 변경은 Decision이 필요하다.

## 검증·Git·정리

- 사용자 dirty 변경과 다른 작업을 보존하고 격리 branch/PR에서 수정한다. direct main push, force push, admin/ruleset bypass 금지.
- 관련 열린 PR은 `docs/decisions/2026-09-08_STANDING_PR_INTEGRATION_AUTHORIZATION.md` 범위에서 실제 diff·중복·동시성을 확인한 뒤 통합한다. 무관한 PR을 흡수하지 않는다. Draft 미완료 사유와 필수 CI·review/thread/ruleset을 해소한 뒤 정상 병합하고 main을 다시 읽는다.
- 동작·계약 변경은 실패 회귀 RED → 최소 GREEN → 영향 회귀. 문서·정적·자동·Godot runtime·Human·최종 자산 승인·병합·출시를 구분한다. 실행하지 않은 것은 NOT_RUN이다.
- Godot authoring/runtime이 필요한 작업만 정확한 project.godot·채택 엔진·현재 editor/session을 확인한다. 문서 작업에 엔진 실행을 강제하지 않는다. 과거 PID/port/CODEX_HOME/local Codex launcher를 준비 완료 증거로 사용하지 않는다.
- 삭제 가능한 자료는 참조·원본·사용처를 확인한 후 `C:/Users/user/Documents/삭제대기`로 복구 가능하게 이동하고 링크·원래 경로·hash를 남긴다. 사용자가 직접 삭제한다.
- 진행/다음 작업은 기존 Active Context에 누적한다. 월간 작업일지는 기존 `docs/operations/AI_USAGE_EVIDENCE_2026_09.json`에 날짜별로 요약하고 같은 날짜는 합친다. 검증된 HTML 전환 이후 블루프린트·월간 작업일지 PDF를 정기 재발행하지 않으며 기존 승인 PDF·원화를 보존한다. 전환 상태는 `docs/blueprint/HTML_MIGRATION_SPEC.md`를 따른다. 전체 대화·중복 추적표를 만들지 않는다.

## 조건부 owner

- 재미·효과·비주얼·UI 검증: 통합 계약 §6.1의 경험 가설·반례·실제 consumer·교정 기준을 사용한다. 자동 검사와 HUMAN_NOT_RUN을 구분하며 같은 작업의 기존 기록에 연결한다.
- 새 게임 설계·조사: `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md` §4. 과거 PREWORK_BENCHMARK_REVERSE_ENGINEERING_GATE / TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01의 자료는 역사이며 고정10개 quota는 2026-09-20 승인으로 대체했다.
- 이미지: `docs/GPT_IMAGE_GENERATION_AND_REVIEW_WORKFLOW.md`. 정본·consumer·규격을 확인하고 실제 이미지 도구로 크로마키 생성→배경 제거→alpha/edge 검수. 후보·사용자 final lock·정본 등록·runtime 적용·실행 검증을 구분한다. 승인 자산을 임의 교체하지 않는다.
- 출시·외부 자산 권리: `docs/PLATFORM_RELEASE_AND_ASSET_RIGHTS_PROFILE.md`, `docs/ASSET_RIGHTS_AND_PROVENANCE_RECORD.md`, `docs/GAME_RELEASE_COMPLIANCE_EVIDENCE_PACK.md`.
- Human/기기/접근성 검수: `docs/planning-data/current_issue54_human_device_validation_packet.json`. 준비 상태는 Human/Device PASS가 아니며 현재 artifact를 먼저 대조한다.
- 최신 Base 읽기·채택·드리프트: `docs/BASE_RULES_VERSION.md`와 `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`. release pin은 재현 근거이고 permanent current 기준이 아니다.
