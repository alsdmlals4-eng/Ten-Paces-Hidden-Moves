# [대체됨] 플랫폼 범위 결정

- Decision ID: `TEN-DEC-20260802-PLATFORM-SCOPE-01`
- 승인일: `2026-08-02`
- 상태: `SUPERSEDED`
- 대체 Decision: `TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`
- 대체일: `2026-08-06`
- 역사적 승인 근거: 사용자의 당시 직접 지시 — `PC, 이후 모바일(고려 중)`

## 역사적 결정

이 Decision은 당시 PC를 주 플랫폼으로 두고 모바일을 후속 검토 대상으로 제한했다. 이후 사용자가 모든 게임의 기본 설계 대상을 Windows와 Android로 명시하고, 게임 로직·데이터는 단일 코어로 유지하며 입력·UI·플랫폼 연동만 분리하도록 확정했으므로 현행 플랫폼 권위를 상실했다.

다음 항목은 역사적 배경으로만 보존한다.

- PC 우선 Vertical Slice 검증 계획.
- 입력 의도와 도메인 규칙 분리.
- 전투 판정·저장 Schema·콘텐츠 ID와 화면·입력 장치 분리.
- 핵심 정보의 다중 채널 전달.

다음 항목은 현행으로 사용하지 않는다.

- `primary_platform: PC`.
- `future_platform: MOBILE_CONSIDERATION_ONLY`.
- Android를 별도 미래 Decision 전까지 제품 범위에서 제외하는 규칙.

현행 책임 원본은 `docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md`다.
