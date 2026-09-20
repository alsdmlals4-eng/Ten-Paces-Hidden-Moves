# 보상 선택 가능성 및 행로 효과 표시

Decision: TEN-DEC-20260920-REWARD-CHOICE-AVAILABILITY-01
Status: APPROVED_CONTINUATION

사용자는 남은 명세 권장안과 반복 구현을 승인했고 “좋아 작업 계속 진행해”로 이어갔다. 실행 계획은 REMAINING_GAME_IMPLEMENTATION_SPEC.md §8 후속 절이다.

- 새 보상 선택에서 이미 보유한 문파 전수는 선택 불가. 이유는 이미 보유한 무공이며 자유 수련6 / 집중5+자유3은 그대로다. 새 환율/소급 지급 없음.
- result view는 available/unavailable_reason_key, UI는 표시/초점, run 명령은 실제 소유/정상 receipt 검증을 책임진다. UI 우회로 효력 없는 보상을 저장할 수 없다.
- v1~v4의 과거 pending/result/history는 기존 규칙으로 읽고 확정한다. 보존된 이력 재생은 현재 선택 가능성 검사와 분리한다. schema/content identity/원본 저장 bytes를 바꾸지 않는다.
- 행로의 기존5효과를 유지하며 domain 미리보기/실제 receipt로 예상/적용량과 상한을 설명한다. 10전·36선택·매회3갈래/정보 공개 범위를 보존한다. 영구 능력 공급량은 미정 상태를 유지한다.
- Human 재미/Android/최종 이미지/출시 승인은 이 결정에 포함되지 않는다.
