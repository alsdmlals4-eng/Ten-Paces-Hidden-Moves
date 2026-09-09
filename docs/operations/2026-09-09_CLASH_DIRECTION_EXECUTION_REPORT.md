# 합 연출 작업 기준 교정 · 실행 기록

- 기준 main: `6ea28301029875fb9e606bab3b8bb5b61801822b`.
- Work Mode: BUILD/REVIEW, 범위는 운영·연출 명세이며 제품 코드/데이터/이미지 bytes 수정 없음.
- Skill: project workflow router(운영 검증), Base art technique-card/변경관리, 독립 requesting-code-review.
- 승인·조사·3대안·적용/비적용·consumer·남은 자산 제작은 `docs/decisions/2026-09-09_CLASH_STAGING_AND_OUTCOME_DIRECTION.md`가 소유한다.
- 기존 아트 owner, 로드맵, Active Context에서 해당 결정을 발견하도록 연결. Base adoption pin 무변경.
- 신규 2개 문서 연결 회귀 RED → GREEN. 독립 검토에서 사거리 밖/장풍 합을 검 접촉으로 오해할 가능성을 발견했고 회귀를 RED로 확장한 뒤 적용 범위를 검 대 검으로 교정했다.
- 운영 검사 PASS. 이 증거는 문서 연결 검사이며 모션 품질·Godot runtime·Human·Android·출시 검증이 아니다.
- 상단 접촉 핵심 자세 및 승패 반동 자산 제작/승인/연결은 NOT_RUN. 이전 오프라인 GIF의 수동 교차점은 게임 판정 정본이 아니다.
- Base 공용 원칙은 별도 Base current-task branch에서 수정하며 merge/CI/readback은 각 PR의 실제 결과를 따른다. 해당 Base 변경이 모든 프로젝트에 자동 도입됐다고 주장하지 않는다.
- 원래 checkout의 사용자 수정 8개는 보존했다. 되돌리기는 본 문서 변경의 bounded revert로 가능하며 승인 원본 삭제·게임 저장 이관 없음.

## 후속 사용자 요구 · 2회 검토 교정 (별도 변경 계보)

- 입력 main: `3a1a3e46939ed6977d1d8b07815c1f3482f5e242`; 분기 `codex/weapon-staging-coverage-20260909`.
- Work Mode: BUILD(회차 정책)/PLAN(적 요구 기록)/REVIEW. Skill/Mode: project workflow router; Base art/reuse 조사; adversarial `attack/validate-critique/regression-recheck`; verification-before-completion; systematic-debugging(테스트 환경 확인). 이 기록은 검토 계보와 상태를 소유하며 제품 기획을 복제하지 않는다.
- 사용자가 내부 검토를 5회→2회로 명시 변경했다. 최신 Base의 정확히 2회와 자동 세 번째 금지를 확인하고 프로젝트 AGENTS·통합 계약·현재 planning locator를 교정했다. 과거 수행/승인 기록과 Base adoption pin은 보존했다.
- 검 대표 제작, 다양한 적 타입, 새 게임 시작 시 10전 전체 상대 고정 추첨, 단계별 스탯/보유 무공/수련도/별호의 승인 요구를 책임 Decision과 Active Context/로드맵에 연결했다. 새 제품 기능과 이미지 생성은 수행하지 않았다. 새 적 생성 설계축의 비교·상세 수치·반복 정책·저장 호환은 미완료로 기록했다.
- 대안: 정책 문구만 일괄 치환(REJECT: 역사 왜곡), 새 공용 검토 프레임워크(REJECT: Base 기존 2회와 중복), 현재 owner/consumer만 교정 + 역사 보존(ADOPT).
- 열린 PR: #199 front-door Human/Device 안내는 AGENTS의 다른 섹션 변경이며 현재 검토 횟수/적 요구와 의미상 별개다. 실제 해당 diff를 확인하고 보존했다. #200은 별도 과거 Base adoption/파생본 변경이므로 흡수하지 않았다. 관련 신규 PR만 이 변경을 전달한다.
- 전체 검토 1: 최신 사용자 의도·현재 source·open diff·실제 적/저장/이미지 consumer·정본·비용·rollback을 대조했다. `OMISSION`: 통합 계약의 `slice_benchmark_and_adversarial_policy`에 FIVE_PLUS 잔존 → 현재 2회로 교정. `CONFLICT`: 현재 고정 상대/엄격 저장을 새 무작위 구현으로 오인할 위험 → NOT_IMPLEMENTED와 실제 소비자 목록 유지. 별호/인물과 개별 만남의 상태 구분을 요구 기록에 포함했다.
- 전체 검토 2: 교정된 AGENTS/계약/두 신규 Decision/기존 연출 결정/Active/현재 JSON/로드맵/테스트와 untouched 제품 경로를 재대조했다. 과거 5회 기록·정탐 비공개 경계·도겸의 맨손 계열·근접 비수 미지정·자산 final lock이 보존됐다. 검 대표 작업보다 새 적 타입 정의를 먼저 하도록 기존 연출 Decision에도 최신 우선순위 링크를 추가했다. 별도 세 번째 전체 검토 없이 이후 finding 영향 범위만 확인한다.
- 실제 검사: 회차 기대값 변경 뒤 기존 계약 회귀 `1 failed, 3 passed` RED → 교정 뒤 `7 passed`; 관련 통합/adapter 포함 `20 passed`; operating system/freshness/diff whitespace 검사 PASS. 문서 검사 결과이지 새 추첨·별호·모션 runtime PASS가 아니다.
- 전체 suite 첫 실행은 전역 스크립트 캐시가 없는 격리 worktree에서 Godot 타입 해석 실패. 중단 후 Godot 4.7.1 headless editor import, 해당 전투 피드백 `4 passed (21.60s)` 재검증. import 종료에서 ObjectDB 45개/리소스 22개 경고가 관측됐으며 무누수 PASS를 주장하지 않는다. 이후 전체 suite는 **502 passed / 328.51s**. 이는 기존 제품 회귀 포함 자동 검사이며 새 적 기능 구현 증거가 아니다.
- 현재 evidence ceiling: 정책/요구 문서 교정과 관련 검사 통과. 새 적 시스템·이미지·모션·GIF·Human/device/release는 미완료. 상세 기획/제품 작업 전체 완료나 CI/main 병합 완료를 이 로컬 기록만으로 선언하지 않는다.
- 재사용 교훈: 새 worktree는 엔진 import가 먼저이며, 생성 sidecar를 제품 diff에 섞지 않는다. 이미 알려진 로컬 실행 교훈을 재사용했으므로 새 Base 정책/프레임워크를 추가하지 않는다.
