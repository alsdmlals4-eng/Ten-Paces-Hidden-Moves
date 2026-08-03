# 십보강호 기술1 HTML 전투 검증 PoC

여섯 시작 무공의 3성 기술1, 기초 행동 10종, 관찰, 순차 합, 방어도, 회피, 중단, 강건, 절초기세 예약·환불을 브라우저에서 직접 시험하는 PC용 PoC입니다.

## 바로 실행

이 브랜치의 배포 패키지는 다음 파일들로 구성됩니다.

- `dist/ten-paces-technique1-poc.html`
- `dist/payload-1.js`
- `dist/payload-2.js`
- `dist/payload-3.js`
- `dist/payload-4.js`

브랜치 ZIP을 내려받아 폴더 구조를 유지한 뒤 `dist/ten-paces-technique1-poc.html`을 Chrome 또는 Edge에서 여십시오. 최상위 `index.html`도 같은 실행 파일로 연결됩니다.

대화에 첨부된 `Ten-Paces-Technique1-PoC.html`은 페이로드까지 내장한 단일 실행 파일이며, `Ten-Paces-Technique1-HTML-PoC.zip`에는 원본 모듈·테스트·실행 문서가 포함됩니다.

## 플레이 순서

1. 적 AI가 현재 공개 상태와 seed만 사용해 먼저 묶음 계획을 잠급니다.
2. `[기초]`, `[무공]`, `[절초]` 탭에서 행동을 선택합니다.
3. 행동은 현재 묶음의 가장 앞 유효 연속 수에 자동 배치됩니다.
4. 이동·보법은 전진 또는 후퇴를 선택해 배치합니다.
5. 배치된 플레이어 슬롯을 누르면 진행 전 제거되고 예약 자원이 환불됩니다.
6. 빈 슬롯은 `[대기]`로 처리되므로 모든 슬롯을 채우지 않아도 진행할 수 있습니다.
7. `[묶음 진행]` 뒤 한 단계·자동 재생·2배속·결과 즉시 보기로 판정을 확인합니다.
8. `[다음 묶음]`을 누르면 이전에 획득한 관찰량이 새로 잠긴 적 계획에 적용됩니다.

## 절초기세 검증

- 범위 `0~5`
- 합 승리 시 공격 행동당 최대 `+1`
- 준비가 적용된 명상 시 `+1`
- 절초 배치 성공 시 기세5 예약
- 진행 전 슬롯 제거 시 기세5 환불
- 묶음 확정 뒤에는 환불하지 않음

`[절초기세 5 설정]`은 기본 절초 3종의 예약·환불을 빠르게 검증하는 fixture 버튼입니다.

## 자동 검증 증거

원본·테스트 동봉 ZIP에서 다음 검증을 실행했습니다.

```bash
cd web/technique1-poc
npm run test:all
```

결과:

- 브라우저 번들 생성 PASS
- JavaScript syntax PASS
- 엔진·AI 테스트 `18 PASS / 0 FAIL`
- Chromium UI smoke PASS
- 브라우저 page error `0`

검증 범위에는 기술 공식, 비용 예약·환불, 고정 이동, 방어도 비소모, 중단·강건, 절초기세 상한, 관찰 이월, deterministic AI, 실제 브라우저 행동 배치·묶음 해결·절초 예약·초기화가 포함됩니다.

## 정직한 검증 경계

- 사람의 재미·역할 이해·가독성·접근성 평가는 `NOT_RUN`입니다.
- Windows 실제 물리 입력 검증은 `NOT_RUN`입니다.
- 기본 막기 방어도5는 `POC_REFERENCE_VALUE`입니다.
- 금강가세·철각유영의 대응 단계는 `POC_RESOLUTION_MAPPING`입니다.
- 밀착 거리0 근접 공격은 `POC_ENGAGEMENT_COMPATIBILITY`입니다.
- 기본 절초 3종은 `LEGACY_SYSTEM_FIXTURE`이며 여섯 무공의 10성 고유 절초가 아닙니다.
- S/A/B/C 등급 가중치와 경계는 미확정이므로 원자료만 표시합니다.
