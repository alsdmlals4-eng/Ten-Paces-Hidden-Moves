# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ 현재 질문의 책임 원본
→ 실제 코드·데이터·자산·테스트
```

Gates·Roadmap·Registry·Audit·Handoff는 `DOCUMENTATION_MAP.md`가 지시할 때만 읽는다. 전체 `skills/`, 백업·보류·과거 산출물을 기본 컨텍스트로 로드하지 않는다.

## 현재 기준

- 프로젝트: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`
- Base: `alsdmlals4-eng/Base@ee265576da7f67d3278f8099dd97d4e714ef0651`
- Base 버전·차이: `docs/BASE_RULES_VERSION.md`
- 70개 변경 파일 감사: `[기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md`
- 운영 PR: #5
- 전투 POC PR: #7

## Work Mode

- `PLAN`: 요구·정본·근거·실행 순서
- `BUILD`: 승인 범위 구현
- `REVIEW`: 적대적 검토·반례·검증

Skill·Skill Mode는 Registry trigger로 자동 선택한다. L1 이상은 선택 이유·수행 내용·결과·증거·미검증을 `execution-report`로 남긴다.

## 제품 기준

- `[강호낭인]`, 전장 10칸, 플레이어 3번·상대 8번
- 라운드 `3수 → 3수 → 4수`, 총 10수
- 판정 `대응 → 속공 → 이동 → 일반 공격`
- 기초 행동 8종, 절초 기세 최대 5칸
- 비용은 행동 슬롯·기력·내력, 덱·손패·행동력 없음

## 현재 구현

- STEP 0~10
- TARGETING 10.5
- RESPONSE 10.6
- RESOURCE PREVIEW 10.6
- 사용자 Windows: STEP 0~10·대상 지정 확인
- 사용자 확인 대기: 최신 대응 판정·자원 미리보기

## 상태 경계

정적 Actions 성공은 Godot 런타임, PDF 발행, 접근성, 성능, 사용자 시각 검수, Branch protection 강제를 증명하지 않는다. 원격 변경과 사용자 로컬 미커밋 파일도 자동으로 동일하지 않다.
