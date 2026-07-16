# 플레이테스트 시작

- 엔진: Godot 4.7.1 stable
- 메인 씬: `scenes/combat_playtest.tscn`
- 자동 테스트: `godot --headless --path . --script res://tests/run_all.gd`
- 기획 누락 검사: `python scripts/check_planning_sync.py`
- 정적 검사: `python tests/static_check.py`
- 통합 기획서: `[기획서]/README.md`

현재 빌드는 10칸 전장, AI 선잠금, 2수 동시 공개, 1수→2수 해상, 이동, 공격, 막기, 회피, 명상, 합, 절초 기세와 절초 발동을 검증하는 T0 프로토타입이다. 5전 대회·수련·상대 정보·제약은 다음 T1 범위다.

## 권장 세션

1. 첫 전투는 설명 없이 진행한다.
2. 둘째 전투는 툴팁과 로그를 읽도록 한다.
3. 셋째 전투는 절초를 한 번 이상 예약한다.
4. `[기획서]/05_플레이테스트/플레이테스트_기록_템플릿.md`에 결과를 기록한다.
