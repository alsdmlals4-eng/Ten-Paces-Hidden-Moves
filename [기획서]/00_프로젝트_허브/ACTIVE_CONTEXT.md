# 십보강호 활성 컨텍스트

## 현재 상태

- Work Mode: `REVIEW` 완료
- Base: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- 운영 PR: #5 `agent/base-full-11-migration`
- 전투 POC PR: #7 `agent/t0-combat-poc-board`
- 최적화 동기화 PR: #9 merged
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

세부 규칙은 `docs/02_COMBAT_RULES.md`, 구현 사실은 `data/`, `scenes/`, `src/`, `tests/`가 책임진다.

## Base 통합·최적화 결과

- Base 155개 커밋·70개 변경 파일 전수 감사
- Base 공유 Skill 13개 유지
- 로컬 Skill은 십보강호 고유 디자인·UX·Godot 구현·QA 4개만 유지
- 제거한 공용 로컬 Skill은 Base Skill·Legacy Alias로 승계
- 문서·Skill Registry는 실제 생성기가 없어 `source_only`
- Skill Map·가짜 Manifest·중복 checker·중복 테스트 제거
- 컨셉·근거·정본 최신성 템플릿 통합
- Design Registry와 Schema의 정책 충돌 수정
- 삭제 경로·stale 전투 표현·가짜 발행 상태 재등장 차단

상세 근거: `BASE_MAIN_SYNC_AUDIT.md`, `BASE_MAIN_SYNC_VERIFICATION.md`.

## 검증 상태

- PR #5 Documentation Governance run #371: `PASS`
- operating-system structure·Registry Schema: `PASS`
- canonical reference freshness·forbidden paths: `PASS`
- Base 13 route·로컬 4 Skill integrity: `PASS`
- 통합 Governance 회귀·실패 반례: `PASS`
- PR #7 최적화 Governance run #370: `PASS`
- PR #7 Card Component Contract run #399: `PASS`
- 전투 코드·데이터·씬·자산 비침범: `PASS`
- 최신 Godot 대응·자원 기능: `UNVERIFIED`
- PDF 발행·접근성·성능·외부 플레이테스트·Branch protection: `NOT_RUN`

## 다음 작업

1. 사용자 작업본에서 `agent/t0-combat-poc-board` Fetch/Pull
2. Godot F5로 RESPONSE·RESOURCE PREVIEW 10.6 확인
3. 결과를 PR #7과 이 문서에 반영
4. STEP 11 피격 중단·집중·강건

## 보호 범위

- 승인된 전투 규칙·UI·자산과 Godot 구현
- 기존 `docs/01~11`, 백업·보류·Plan·PR·Git 이력
- 사용자 로컬 미커밋 변경
- 실행하지 않은 검증의 미검증 상태
