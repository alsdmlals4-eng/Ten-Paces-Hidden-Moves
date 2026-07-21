# 십보강호 활성 컨텍스트

## 현재 상태

- Work Mode: `PLAN → BUILD → REVIEW`
- Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 운영 PR: #5 `agent/base-full-11-migration`
- 전투 POC PR: #7 `agent/t0-combat-poc-board`
- 제품 단계: Prototype
- 구현: STEP 0~10, TARGETING 10.5, RESPONSE 10.6, RESOURCE PREVIEW 10.6
- 사용자 Windows 확인: STEP 0~10·행동 배치·이동 목적지·공격 방향
- 사용자 확인 대기: 최신 막기·회피·태세 판정과 자원 미리보기

## 제품 계약

- `[강호낭인]`, 전장 10칸, 플레이어 3번·상대 8번
- 라운드 `3수 → 3수 → 4수`, 총 10수
- 판정 `대응 → 속공 → 이동 → 일반 공격`
- 같은 단계 공격은 동시 피해
- 기초 행동 8종, 절초 기세 최대 5칸
- 비용은 행동 슬롯·기력·내력
- 덱·손패·행동력·공통 `막기 경감` 없음

세부 전투 규칙은 `docs/02_COMBAT_RULES.md`, 실제 상태는 `data/`, `scenes/`, `src/`, `tests/`가 책임진다.

## Base 통합·간소화

- Base 155개 커밋·70개 변경 파일 감사
- Base 공유 Skill 13개 유지
- 로컬 Skill은 전투 디자인·UX·Godot 구현·QA 4개만 유지
- 요청 접수·상태 인수·운영 검수의 로컬 복제는 Base Skill로 통합
- 문서·Skill Registry는 실제 생성기가 없어 `source_only`
- PDF가 필요한 마일스톤에 발행 파이프라인을 별도 설치
- 템플릿·검사·회귀 테스트 중복 통합
- 삭제한 ID·경로는 Legacy Alias와 정본 최신성 검사로 보호

상세 근거: `BASE_MAIN_SYNC_AUDIT.md`, `BASE_MAIN_SYNC_VERIFICATION.md`.

## 검증 상태

- 운영 구조·발행 정책 형태: 검사 대상
- Canonical reference freshness: 검사 대상
- Project Skill package integrity: 검사 대상
- Governance 회귀 테스트: 검사 대상
- PR #7 Card Component Contract: 기존 PASS, 운영 동기화 뒤 재확인 필요
- 최신 Godot 대응·자원 기능: `UNVERIFIED`
- PDF·접근성·성능·외부 플레이테스트·Branch protection: `NOT_RUN`

## 다음 작업

1. 간소화 후 PR #5 Governance 전체 통과
2. 동일 운영 변경을 PR #7에 동기화하고 두 Actions 통과
3. 사용자 Fetch/Pull 후 Godot F5
4. RESPONSE·RESOURCE PREVIEW 10.6 확인
5. STEP 11 피격 중단·집중·강건

## 보호 범위

- 승인된 전투 규칙·UI·자산과 Godot 구현
- 기존 `docs/01~11`, 백업·보류·Plan·PR·Git 이력
- 사용자 로컬 미커밋 변경
- 실행하지 않은 검증의 미검증 상태
