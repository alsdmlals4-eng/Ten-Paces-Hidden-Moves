# 기존 기연 저장 호환 fixture

실제 main `2e3bf285352556eeae16452403cef2368676035c` 코드가 사건 규칙을 변경하기 전에 생성한 schema5 체크포인트다. seed99, 첫 비무 종료의 synthetic win, 수련6 보상 뒤 사건 선택 전(`pending.json`)과 accept 확정 뒤(`applied.json`)이다. 사용자 저장 파일을 복사하지 않았다.

- v1 content identity: `5363363676e6c1e66ac36bb4725dea1b2918c6f35744c50e453999d61e442884`.
- 검증: `tests/verify_event_checks.gd`에서 새 코드로 원래 transport decode; `verify_giyun_run.gd`에서 v1 전체36단계·저장 readback.
- 자동 fixture는 사람 플레이나 새 확률 규칙의 재미 증거가 아니다. 새 카탈로그로 재생성하면 호환 검증 목적이 사라지므로 변경하지 않는다.
