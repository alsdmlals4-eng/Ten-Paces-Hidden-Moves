# TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01

```yaml
decision_id: TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01
status: APPROVED_CURRENT
approval_source: "user explicit: 새 작업계약에 따라 상태 확인 후 진행해"
decision_date: 2026-08-26
scope: PROJECT_OPERATING_AUTHORITY
canonical_document: docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
source_uploaded_sha256: fdf238c202cfac6d3a824aae49b8ac525fba023e31bba7df6ece64a2790365a0
base_observed_main: edb3b3376603c9f6b00d64af3126304f8c9946bf
supersedes_decision_id: TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01
runtime_mutation: NONE
product_core_mutation: NONE
```

## 결정

십보강호의 current project operating contract를 `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION v4.8 · revision 2026-08-26-r5.4-superset-final` thin adapter로 승격한다.

이번 승격은 공용 Base 본문을 프로젝트에 복제하는 작업이 아니다. 현재 프로젝트가 다음 새 채팅에서도 GitHub + Notion만으로 같은 작업 경계를 복원하도록 최신 사용자 계약과 프로젝트 owner surface를 정렬한다.

## 핵심 변경

1. 최신 Base completed main을 매 작업 fresh-read하고 Base 세부 절차는 owner progressive-load로 유지한다.
2. 새 채팅은 과거 대화가 아니라 exact Project Notion + project GitHub current truth에서 상태를 재구성한다.
3. Notion human-facing canon / repository structured-runtime canon / Google Sheets migration-only 경계를 유지한다.
4. GPT가 PowerShell로 local Codex를 실행하는 과거 orchestration과 project-specific `CODEX_HOME` 필수 경로를 current execution에서 폐기한다.
5. 실제 Godot 제품 구현이 필요한 경우 `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF` 뒤 Codex가 GitHub + Notion을 독립 fresh-read하여 자신의 구현환경에서 수행한다.
6. PowerShell은 Godot local 실행·검증이 실제 필요할 때만 사용한다.
7. 호환 가능한 host에서는 shared approved exact Godot pin + Godot AI 기본 포트 + exact project/editor/session isolation을 기본으로 한다.
8. 새 이미지 생성/생성형 편집은 `brief → explicit approval → exactly one result → review`를 current visual-production Gate로 사용한다.
9. UI 구조는 최소 `ko/en/ja/zh-*` localization-ready와 `pc_standard / pc_wide_or_ultrawide / mobile_landscape` semantic parity를 계획한다. 중국어 variant는 별도 프로젝트 Decision 전 `UNKNOWN_UNVERIFIED`다.
10. requirement traceability, playable slice, visual delete test/asset coverage/style lock, evidence ceiling, minimum-five adversarial review를 프로젝트 current contract에서 누락하지 않는다.

## r2 보존·대체 경계

`TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`은 `SUPERSEDED_HISTORICAL_EVIDENCE`로 전환한다. 해당 Decision과 structured record는 삭제하지 않는다.

r2에서 보존하는 것:

- Base thin-adapter/progressive-load 원칙.
- Notion / repository / Google Sheets domain split.
- open PR read-only, current-task PR의 좁은 merge 예외.
- Implementation Reality Gate와 evidence ceiling.
- 제품 보호 경로와 제품 의미 비변경.

의도적으로 대체하는 것:

- GPT→PowerShell→local Codex launcher.
- project-specific CODEX_HOME 및 dedicated port readiness.
- 과거 고정 tool/version/session snapshot의 current authority 사용.
- 프로젝트 visual-production의 3-image batch current 실행 권한.

## 비변경 범위

이 Decision은 다음을 바꾸지 않는다.

- 10칸·시작 공개 거리2·3/3/4·거리·합·대응·중단·복기 코어.
- AI public-information boundary.
- 이미 병합된 첫 5전 PC-first Vertical Slice Phase I–VI runtime 구현.
- 무공/성장/경제 수치.
- Windows/Android 제품 지원 evidence ceiling.
- 승인된 2026-08-25 Visual Reference Set 자체.
- `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`.

## 검증 조건

- r5.4 current-contract RED가 기존 r2 cold-start에서 실제 실패하고 migration 뒤 GREEN이어야 한다.
- r2/v4.5 역사 evidence가 삭제되지 않아야 한다.
- active verification Skill이 local Codex/CODEX_HOME/dedicated-port 경로를 current readiness로 요구하지 않아야 한다.
- current visual state가 exactly-one Gate와 일치해야 한다.
- Google Sheets가 current authority로 재승격되지 않아야 한다.
- protected product path 변경이 없어야 한다.
- exact-head PR CI, 최소 5회 adversarial review, merge 뒤 new-main + Notion destination readback이 필요하다.
