# 비무 제약 v0 런타임 채택

Decision ID: TEN-DEC-20260908-BIMU-CONSTRAINT-RUNTIME-01
Status: APPROVED_FOR_BUILD / IMPLEMENTATION_IN_PROGRESS

최신 사용자 지시: 기획한 내용을 Godot에 연속 구현하고 부족한 상세는 권장안으로
채우며, 제약은 기술 제한과 상대 강화 및 복수 선택을 포함한다. 이 지시를
기존 2026-09-04 규칙/UI 후보의 별도 런타임 구현 승인으로 한정 적용한다.

## 책임과 범위

역사 규칙/UI 명세:
`codex/human-blueprint-r4-closure-20260907:docs/decisions/2026-09-04_BIMU_CONSTRAINT_COMPOSITION_V0_CANDIDATE_DECISION.md`
및 같은 branch의 `docs/planning-data/bimu_constraint_v0_candidate_catalog.json`.
이 경로는 감사용 provenance이며 게임에서 읽지 않는다. 과거 후보 문서의
RUNTIME_NOT_IMPLEMENTED 표기는 당시 사실로 보존한다.

실행 규칙 owner: `data/run/bimu_constraints.json`.
구현 순서·기존 10사례 비교 재사용·공식 자료 refresh:
`docs/operations/2026-09-08_BIMU_CONSTRAINT_RUNTIME_PLAN.md`.

- 9종 제약, 0–2개, 3점 예산, 상대 강화 최대1개, 중복 불가.
- 브리핑에서 확정하고 이번 비무만 적용, 재도전은 같은 조건으로 복원.
- 기술 제한은 실제 보유 무공 기술만 대상. 기초 행동과 기본 절초는 유지.
- 상대 강화의 대상·delta·기간은 공개하되 기존 스테이터스/미래 행동을 새로 노출하지 않음.
- 시작 거리2, 3/3/4, AI 비공개 계획 접근 금지, 덱/손패/드로우 부재 유지.
- 제약 보상 연동 없음. 행운·등급·금전·저장 스키마·정탐 단계 수치 변경 없음.
- 현재 자원 +1은 최대치로 제한하여 이미 가득 찬 자원에는 추가 효과가 없을 수 있음.
  최대치 증가로 몰래 변경하지 않고 UI에도 제한을 표시한다.

## 구현·검증 경계

현재 런타임 연결은 미완료. 데이터/모델 → RunState/engine → 브리핑/준비
consumer 순으로 test-first 구현한다. UI 봉인만으로 완료 처리하지 않는다.
실제 보유 ID에 재결합한 규칙으로 forged placement를 차단하며 원본 데이터를 수정하지 않는다.
0선택과 이전 10전 흐름은 회귀 보호한다. 기계/runtime PASS와 Human 균형·사용성,
Android·접근성·출시 권리는 별도다. 해당 미실행 검증은 NOT_RUN으로 유지한다.

