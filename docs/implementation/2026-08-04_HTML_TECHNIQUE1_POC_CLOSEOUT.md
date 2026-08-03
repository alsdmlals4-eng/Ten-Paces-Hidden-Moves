# HTML 기술1 전투 검증 PoC 구현 종료 기록

- 구현일: 2026-08-04
- 설계: `docs/superpowers/specs/2026-08-04-html-technique1-validation-poc-design.md`
- 구현 계획: `docs/superpowers/plans/2026-08-04-html-technique1-playable-poc.md`
- 실행 진입점: `web/technique1-poc/index.html`
- 단일 실행 파일: `web/technique1-poc/dist/ten-paces-technique1-poc.html`
- 상태: `IMPLEMENTED_LOCAL_AUTOMATED_VALIDATION_PASS_HUMAN_PENDING`

## 구현 범위

- 10칸 일자형 전장과 플레이어4·AI7 시작 위치
- 전체 10수와 현재 `3/3/4` 묶음 편집
- 빈 슬롯 대기, 다중 수 연결 점유, 비용 선예약과 진행 전 환불
- 플레이어 기초 행동10종과 AI 기초 행동9종
- 여섯 시작 무공 기술1 전부
- 공개 상태·seed 기반 deterministic AI 선잠금
- 관찰량 이월과 새로 잠긴 적 계획 종류 공개
- 순차 연격 합, 사거리 밖 합, 회피, 비소모 방어도, 중단, 강건
- 절초기세0~5, 묶음당 자동+1, 회피 성공+1, 합 승리 행동당 최대+1, 준비된 명상+1
- 준비 무비용·1수 강화, 대응→속공→이동→공격 해결 순서
- 같은 수 공격 선정산과 피격 시 명상·후속 비공격 행동 중단
- 모든 공격 카드의 거리·피해 계약 기반 표시
- 묶음마다 양측 내력·절초기세+1
- 기본 절초3종의 예약·진행 전 환불 fixture
- 사건 로그, 한 단계·자동·2배속·즉시 결과, JSON replay
- 기술별 모션 문법, 모션 감소, 음소거, 볼륨, 키보드 포커스
- 저장소 에셋 상대경로와 CSS fallback

## 자동 검증

실행 명령:

```bash
cd web/technique1-poc
npm run test:all
```

확인 결과:

- 브라우저 번들 생성: PASS
- `dist/app.js` JavaScript syntax: PASS
- Node engine/AI/UI-contract tests: 26 PASS, 0 FAIL
- Chromium UI smoke: PASS
- UI smoke가 확인한 경로:
  - 10칸 렌더
  - 무공 탭→유운삼첩 배치
  - 묶음 해결과 사건 로그
  - 다음 묶음 전환
  - 절초기세5 fixture→절초 예약→0/5 차감
  - 전투 초기화→체력30/30 복원
  - page error 0

## 적대적 검토에서 수정한 회귀

1. 다중 수 행동의 실행 슬롯까지 `[전조]`로 공개되던 위험을 수정했다. 전조 슬롯만 `[전조]`, 실행 슬롯은 실제 행동 종류를 표시한다.
2. 연격이 상대 전투불능 뒤에도 잔여 피해 단위를 처리할 수 있던 위험을 수정했다. 체력0 즉시 잔여타를 중단한다.
3. 관찰량이 이전 묶음 계획에 소비될 수 있던 전환 순서를 분리했다. 묶음 전환→새 AI 계획 잠금→관찰 공개 순서를 사용한다.
4. 모듈 테스트 래퍼와 브라우저 번들 전역 이름 충돌을 제거하고 `node --check`로 보호했다.
5. 준비 내력 비용, `general` 혼합 순차 실행, 묶음 회복 누락, 회피 성공 기세 누락을 사용자 재검수로 발견하고 회귀 테스트를 추가했다.
6. 공격 설명을 실제 행동 계약에서 생성해 유운삼첩의 거리·피해 누락과 향후 수기 불일치를 방지했다.

## 증거 경계

```yaml
implementation: PASS
bundle_generation: PASS
javascript_syntax: PASS
node_tests: 26_PASS_0_FAIL
chromium_ui_smoke: PASS
human_fun_validation: NOT_RUN
human_accessibility_validation: NOT_RUN
windows_physical_input: NOT_RUN
final_balance_validation: NOT_RUN
```

자동 검증은 규칙·배치·판정·브라우저 입력 경로를 증명하지만 장기 재미, 기술 역할 이해도, 실제 오디오 선호, 최소 해상도 전체 가독성을 증명하지 않는다.
