# Hera v1 설치·권위 정합화 감사

- Audit ID: `TEN-AUD-20260808-HERA-V1-RECONCILIATION`
- Decision ID: `TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01`
- 기준 main: `8e06c3ed4b572d211aeb9447d5d0b1491b1b8467`
- Base main: `fa69a77a14f923a756064f6ae151d34cadb374f7`

## 판정

`PASS_ADDON_PROVENANCE / BLOCK_ACTIVE_ADOPTION_AND_PRODUCT_ENTRY`

## 확인 결과

- 프로젝트 Hera addon tree: `6cb87ac8ba768de1d924447f385fba6d80bcde68`.
- 공식 `NotNull92/hera-agent-godot@v1.0.0` addon tree: `6cb87ac8ba768de1d924447f385fba6d80bcde68`.
- addon tree는 exact match.
- `plugin.cfg` version은 `1.0.0`.
- `project.godot` enabled plugin은 `res://addons/godot_ai/plugin.cfg`만 확인되어 Hera는 비활성.
- companion CLI exact version과 실제 로컬 연결은 현재 환경에서 확인 불가.
- Draft PR #109는 current main보다 2 commit 뒤이며 최신 main과 diverged.
- Google Sheet Hub는 project main `956dc9b…`, Base `0b7c94f…`를 기록해 stale 상태.

## 조치

1. Hera를 `PRESENT_DISABLED_PAIR_UNVERIFIED`로 분류한다.
2. persistent authoring 권위는 HiGodot에만 유지한다.
3. Hera는 향후 활성화되더라도 `LIVE_QA_AND_OBSERVABILITY_ONLY`로 제한한다.
4. CLI/addon exact pair·editor restart·status/smoke·source-delta canary 전에는 `ADOPTED_ACTIVE`를 주장하지 않는다.
5. PR #109는 최신 main 반영과 새 exact-head GUT/JUnit 검증 전 병합 금지.
6. Sheet Hub·결정 원장·감사·변경 이력을 현재 SHA와 같은 Decision ID로 동기화한다.
7. `TEN-IMG-001` 검수와 로컬 플랫폼 검증이 남아 있어 Windows·Android Adapter 제품 구현은 계속 차단한다.

## 미검증

- Windows 로컬 checkout 상태.
- `hera --version` 및 실제 CLI 설치 경로.
- Godot Editor에서 Hera enable/restart.
- `hera status` / `hera smoke --skip-game`.
- shared token 실제 설정.
- acceptance QA 전후 tracked source delta NONE.
- Android 실기기·로컬 Windows·사람 검증.
