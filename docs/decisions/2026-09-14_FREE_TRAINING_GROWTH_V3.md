# TEN-DEC-20260914-FREE-TRAINING-GROWTH-V3-01

Status: APPROVED_CONTRACT_CONTINUATION / IMPLEMENTATION_IN_PROGRESS

근거: 사용자가 P00~P14 권장 명세를 승인한 뒤 최신 지시에서 해당 순서대로 게임 전체 구현·개선을 별도 반복 승인 없이 계속하도록 명시했다. 이 결정은 승인 명세6절의 자유 수련 관리와 신규 저장 버전의 기술 계약을 구체화한다. Human/이미지 final lock/출시 승인이나 핵심 전투 코어 변경을 뜻하지 않는다.

새 여정은 `schema_version=3`, `ruleset_id=ten-duel-growth-v3`로 명시하고 기존 가변 상대10건을 그대로 사용한다. v1/v2의 내용 identity·실전 저장 bytes·당시 성장 의미를 보존하며 기존 여정을 강제 변환하지 않는다. 자유 수련 배분은v3의 안전한 비전투 경계에서만 제공한다. 수련 수치는 기존 progression owner를 그대로 사용한다.

명세에서 제안한 시간순 `progression_events`는 보상/행로 receipt를 index로 참조하고 수련 배분을 기록한다. 전체 재생은 당시 보유와 pool을 확인해 미래 보상으로 과거 지출을 허용하지 않는다. 중복 효과 원장을 추가하지 않는다. 이벤트 순서·preview/commit·화면·검증·롤백 상세는 `docs/operations/2026-09-14_TRAINING_ALLOCATION_IMPLEMENTATION.md`가 구현 계획으로 소유한다.

진행 저장과 사용자 설정은 계속 분리한다. P03 능력 보너스와 P04 중복 전수 정책은 이 결정의 구현 완료로 간주하지 않는다. 기술 구현이 저장/실제 입력/해금 소비처까지 검증되기 전 상태는 부분 구현이다.
