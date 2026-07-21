# 십보강호 활성 컨텍스트

> 현재 상태·다음 작업·위험을 압축한다. 제품 본책 전문은 복제하지 않는다.

## 현재 단계

- 운영 Work Mode: `PLAN → BUILD → REVIEW`
- 주 Skill: `managing-game-project-operating-system`
- Skill Mode: `audit → reconcile-legacy → migrate → verify`
- Base 기준: `ee265576da7f67d3278f8099dd97d4e714ef0651`
- Base 비교: 이전 기준보다 155개 커밋·70개 파일 변경
- 운영 브랜치·PR: `agent/base-full-11-migration`, Draft PR #5
- 구현 브랜치·PR: `agent/t0-combat-poc-board`, 스택형 Draft PR #7
- 동기화 PR: #8 merged, merge `c8d940586af1e619d3adf76f1c8ad6b36d657de4`
- 제품 단계: 전투 POC Prototype
- 구현 범위: STEP 0~10, TARGETING 10.5, RESPONSE 10.6, RESOURCE PREVIEW 10.6
- 사용자 Windows 확인: STEP 0~10·1수부터 배치·범위 초과 차단·이동 목적지·공격 방향
- 사용자 확인 대기: 최신 막기·회피·태세 연계와 배치 즉시 자원 표시

## 운영 검증

- PR #5 Documentation Governance run #298: `PASS`
- Project operating-system structure: `PASS`
- Canonical reference freshness: `PASS`
- Project Skill package integrity: `PASS`
- PR #7 Documentation Governance run #299: `PASS`
- PR #7 Card Component Contract run #395: `PASS`
- PR #7 mergeable: `true`
- 상세 증거: `BASE_MAIN_SYNC_VERIFICATION.md`

## 제품 고정 방향

- 플레이어 정체성: `[강호낭인]`
- 전장 10칸, 플레이어 3번·상대 8번
- 라운드 `3수 → 3수 → 4수`, 총 10수
- 10수 완료는 다음 라운드 진입
- 판정 `대응 → 속공 → 이동 → 일반 공격`
- 같은 판정 단계 공격은 동시 피해
- 기초 행동 8종: 이동·보법·막기·회피·속공·강공·명상·태세
- 절초 기세 최대 5칸
- 카드 비용: 행동 슬롯·기력·내력
- 덱·손패·행동력·공통 `막기 경감` 없음
- 전투 시작 체력·기력·내력은 최대치, 시작 패널티가 있을 때만 감소

## 전투 규칙 보완

- 강공: 슬롯 2, 사거리 2, 기력 1·내력 1, 지정 방향 거리 1·2 공격
- 보법: 슬롯 1, 내력 1, 좌우 1칸 또는 2칸 선택
- 막기: 같은 수 50% 감소, 같은 묶음 방어도 감소, 높은 감소량 적용
- 회피: 같은 수 공격 완전 회피
- 태세+막기: 같은 슬롯 결합, 묶음 전체 방어, 방어도 50% 증가
- 태세+회피: 같은 슬롯 결합, 묶음 전체 완전 회피
- 행동 배치: 실행 순서 기준 자원 소모·명상 회복 예상치를 HUD에 즉시 반영
- 자원 부족 계획: 슬롯 표시와 진행 버튼 잠금

## 구현 책임 경로

- 카드 데이터: `data/cards/basic_cards.json`
- 전투 데이터: `data/combat/`
- 씬: `scenes/`
- 판정·전장 코드: `src/combat/`
- UI 코드: `src/ui/`
- 검증: `tests/`
- Windows 자동화: `tools/verify_and_commit_combat_foundation.ps1`

## Base 동기화 판정

`PASS_WITH_UNVERIFIED_GATES`

완료:

- 최신 Base canonical 원본·13개 Skill Registry 확인
- 70개 변경 파일 전수 처리표
- Work Mode·자동 라우팅·실행 보고·Legacy Alias
- 정책 기반 발행·reconciliation·접근성·성능 계약
- 정본 최신성·Skill 무결성 검사와 Actions
- PR #5 운영 파일 44개를 PR #7에 비파괴 동기화

미검증:

- 사용자 로컬 미커밋 파일
- RESPONSE 10.6 최신 Godot 런타임
- PDF·Manifest 발행과 전 페이지 시각 검수
- 접근성 사용자 검수
- 목표 플랫폼 성능 프로파일
- Branch protection Required Check 강제

## 즉시 다음 작업

1. 사용자 작업본에서 `agent/t0-combat-poc-board` Fetch/Pull
2. Godot F5로 RESPONSE 10.6과 RESOURCE PREVIEW 10.6 확인
3. 결과를 PR #7·Active Context에 기록
4. STEP 11 피격 중단·집중·강건 작업 계약

## 보호 범위

- 사용자 승인 제품 규칙·UI 방향·자산
- 10칸·3/3/4·8개 기초 행동·절초 기세 5칸
- 기존 `docs/01~11`, 백업·보류·Plan·PR·Git 이력
- 정상 동작 중인 사용자 변경
- 실행하지 않은 검증의 미검증 상태
