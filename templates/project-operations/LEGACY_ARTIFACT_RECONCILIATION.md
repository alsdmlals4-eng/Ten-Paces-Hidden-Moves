# 구형 파일·파생본 처리표

| 현재 경로 | 책임 | 현행 정본 | 고유 정보 | 활성 참조 | 파생본 | 판정 | 승인 | 변경 | 검증 | 롤백 |
|---|---|---|---|---|---|---|---|---|---|---|

판정:

- `CURRENT`
- `UPDATE_IN_PLACE`
- `MERGE_TO_CANONICAL`
- `COMPATIBILITY_STUB`
- `ARCHIVE_HISTORY`
- `DELETE_APPROVED`
- `KEEP_UNRESOLVED`

삭제 조건:

- 고유 결정·예외·이미지·보류 승계
- 활성·외부 참조 갱신 또는 호환 stub
- 생성물·Manifest·해시 검증
- Git 이력·태그·백업 복구 경로
- 사용자 승인
- reference-freshness 차단 finding 없음
