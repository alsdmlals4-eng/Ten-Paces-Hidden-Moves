# 십보강호 프로젝트 허브

## 기본 경로

```text
../../../AGENTS.md
→ ../../../docs/BASE_RULES_VERSION.md
→ ACTIVE_CONTEXT.md
→ DOCUMENTATION_MAP.md
→ SKILL_REGISTRY.json
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 파일·테스트·PR·Issue
```

- Base 동기화 감사: `BASE_MAIN_SYNC_AUDIT.md`.
- 과거 v6 결정 인덱스: `../../../docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.
- 현재 요청에 필요할 때만 Gates·Roadmap·Audit·Handoff를 추가로 읽는다.

## 현재 상태

변동 상태는 `ACTIVE_CONTEXT.md`만 책임진다. 활성 PR·exact head·승인 수·다음 Decision은 GitHub PR metadata와 함께 그 문서에서 확인한다.

안정 기준:

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
runtime_work_mode: REVIEW
runtime_integration_pr: 65
planning_work_mode: PLAN
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
base_release_pinned: 9.4.3
t1_greenlight: NOT_GRANTED
human_validation: NOT_RUN
```

전체 제품 화면 흐름 런타임은 기획·검토·이미지 Gate 뒤 별도 Codex 패키지에서 시작한다.

## Work Mode

- `PLAN`: 요구·정본·설계·문서·순서.
- `BUILD`: 승인된 구현 패키지.
- `REVIEW`: 적대적 검토·반례·증거·최소 수정.

런타임 운영 기준은 `REVIEW`, 현재 GrillMe 승인 활동은 `PLAN`이다.

## 현재 다음 작업

```text
ACTIVE_CONTEXT의 다음 기획 Decision
→ 남은 기획 완료
→ 전체 정본·PR·Sheet 적대적 검토 완료
→ 필요한 이미지·애니메이션·HX 생성·검수·승인
→ VERTICAL_SLICE_APP_FLOW_SHELL Codex 구현
→ Windows 실제 실행·해상도·입력·접근성·성능·STEP 14 사람 검증
```

## 허브 책임

- `ACTIVE_CONTEXT.md`: 병합된 main 상태·다음 작업·위험.
- `DOCUMENTATION_MAP.md`: main 체크포인트와 활성 Draft PR을 포함한 질문별 권한 원본·역사 자료.
- `DEVELOPMENT_GATES.md`: 현재 단계 진입·차단 조건.
- `ROADMAP.md`: 운영 순서와 재개 조건.
- `HANDOFF.md`: 세션 인수 경계.
- `SKILL_REGISTRY.json`: Base·로컬 Skill 라우팅.

## 역사·보류

- PR #7·Issue #13: T0 `STEP 0~13` 구현 계보.
- PR #45·`2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`: 재설계·승인 이력.
- PR #65: 현재 런타임 통합 기준선.
- PR #72·#80: 이후 전투·성장 기획 체크포인트.
- 2026-07-26 BUILD 문서: `SUPERSEDED_REFERENCE`.
- 16권 절초 개별 설계, 주요 비무 6~10 런타임, 천하제일인·비동기 기능, 최종 폴리싱: `[보류]`.

자동 검증은 Windows 실제 Godot·접근성·성능·사람 플레이를 증명하지 않는다.
