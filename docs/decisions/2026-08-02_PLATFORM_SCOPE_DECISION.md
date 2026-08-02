# 플랫폼 범위 결정

- Decision ID: `TEN-DEC-20260802-PLATFORM-SCOPE-01`
- 승인일: `2026-08-02`
- 상태: `APPROVED_PLANNING`
- 승인 근거: 사용자의 직접 지시 — `PC, 이후 모바일(고려 중)`
- 현재 주 플랫폼: `PC`
- 미래 검토 플랫폼: `MOBILE_CONSIDERATION_ONLY`
- 구조화 계약: `docs/planning-data/approved_20260802_platform_scope_contract.json`
- 모바일 런타임 구현 권한: `NONE`
- 모바일 기기·성능·스토어 검증: `NOT_RUN`

## 1. 승인 결정

십보강호의 현재 기획·구현·검증·배포 기준은 **PC**다.

모바일은 PC 버티컬 슬라이스와 전투 코어가 검증된 뒤 재평가할 미래 플랫폼 후보이며, 현재 제품 범위·일정·수용 기준에 포함하지 않는다. `모바일 고려`를 모바일 포팅 승인, 동시 출시 약속, 터치 UI 구현 계약 또는 크로스 플랫폼 저장·온라인 서비스 약속으로 해석하지 않는다.

## 2. 현재 PC 범위

현재 Vertical Slice와 다음 패키지는 다음 기준을 사용한다.

- Godot 4.7 기반 PC 실행.
- 키보드·마우스·게임패드 입력.
- `1280×800`, `1440×900`, `16:9` 안전영역 검증.
- `VERTICAL_SLICE_APP_FLOW_SHELL`의 Main→Setup→Route→Node→Briefing→Combat→Result 흐름.
- Windows 실제 Godot 실행, 저장·재진입·중복 입력·성능·접근성·사람 검증.

## 3. 현재 제외 범위

다음은 별도 Decision과 Build Gate 전까지 구현하지 않는다.

- 터치 전용 조작·제스처·가상 패드.
- 모바일 화면비·노치·안전영역 최적화.
- Android·iOS 빌드·서명·스토어 배포.
- 모바일 성능·발열·메모리·배터리 예산.
- PC↔모바일 크로스 세이브·계정·동기화.
- 모바일 과금·광고·푸시 알림·네트워크 서비스.
- 모바일을 이유로 한 전투 코어·3/3/4·정보 구조·콘텐츠 범위 변경.

## 4. 미래 호환 경계

현재 PC 구현에서 합리적인 비용으로 지킬 수 있는 경계만 유지한다.

- 입력 의도는 가능하면 Godot Input Action을 통해 표현하고 장치 원시 이벤트에 도메인 규칙을 결합하지 않는다.
- 전투 판정·저장 Schema·콘텐츠 ID는 화면·입력 장치와 분리한다.
- 핵심 정보는 색·모션·음향 하나에만 의존하지 않는다.
- PC 해상도 대응을 위한 반응형 레이아웃은 유지하되, 모바일 전용 추상화나 UI를 선행 구현하지 않는다.
- 미래 모바일 요구가 PC 코어를 변경해야 한다면 호환성 개선이 아니라 새 기획 Decision으로 승격한다.

## 5. 모바일 재검토 Gate

다음 조건이 실제 증거로 닫힌 뒤 모바일 타당성을 별도 검토한다.

1. `VERTICAL_SLICE_APP_FLOW_SHELL` 구현·자동 검증 완료.
2. Windows 실제 실행·해상도·키보드·마우스·게임패드 검증.
3. 저장·불러오기·same-seed 재진입·보상 단일 commit 안정화.
4. STEP 14 사람 검증과 핵심 전투 이해도 확인.
5. 대표 콘텐츠의 반복 제작성과 PC 성능 예산 확인.
6. 터치 조작·화면 밀도·성능·스토어 비용을 포함한 모바일 타당성 조사.
7. 사용자 승인과 별도 모바일 범위 Decision.

## 6. 정본·소비자 영향

이 Decision은 다음 Surface에 같은 ID로 연결한다.

- `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- `README.md`
- `START_HERE.md`
- `docs/04_ROADMAP.md`
- `docs/planning-data/approved_20260802_platform_scope_contract.json`
- Google Sheets `00_프로젝트_허브`
- Google Sheets `02_현재_확정결정`
- Google Sheets `20_코어경험_데모목표`
- Google Sheets `30_데모범위_품질기준_제작기반`
- Google Sheets `90_본제작_출시_사업`
- Google Sheets `99_변경이력`

## 7. 검증 상태

```yaml
canonical_documentation: PLANNED_SYNC
planning_data: PLANNED_SYNC
google_sheet: PLANNED_SYNC
pc_runtime_change: NONE
mobile_runtime: NOT_STARTED
mobile_device_validation: NOT_RUN
mobile_performance_validation: NOT_RUN
store_validation: NOT_RUN
human_mobile_validation: NOT_RUN
```
