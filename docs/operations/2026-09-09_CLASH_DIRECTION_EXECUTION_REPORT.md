# 합 연출 작업 기준 교정 · 실행 기록

- 기준 main: `6ea28301029875fb9e606bab3b8bb5b61801822b`.
- Work Mode: BUILD/REVIEW, 범위는 운영·연출 명세이며 제품 코드/데이터/이미지 bytes 수정 없음.
- Skill: project workflow router(운영 검증), Base art technique-card/변경관리, 독립 requesting-code-review.
- 승인·조사·3대안·적용/비적용·consumer·남은 자산 제작은 `docs/decisions/2026-09-09_CLASH_STAGING_AND_OUTCOME_DIRECTION.md`가 소유한다.
- 기존 아트 owner, 로드맵, Active Context에서 해당 결정을 발견하도록 연결. Base adoption pin 무변경.
- 신규 2개 문서 연결 회귀 RED → GREEN. 독립 검토에서 사거리 밖/장풍 합을 검 접촉으로 오해할 가능성을 발견했고 회귀를 RED로 확장한 뒤 적용 범위를 검 대 검으로 교정했다.
- 운영 검사 PASS. 이 증거는 문서 연결 검사이며 모션 품질·Godot runtime·Human·Android·출시 검증이 아니다.
- 상단 접촉 핵심 자세 및 승패 반동 자산 제작/승인/연결은 NOT_RUN. 이전 오프라인 GIF의 수동 교차점은 게임 판정 정본이 아니다.
- Base 공용 원칙은 별도 Base current-task branch에서 수정하며 merge/CI/readback은 각 PR의 실제 결과를 따른다. 해당 Base 변경이 모든 프로젝트에 자동 도입됐다고 주장하지 않는다.
- 원래 checkout의 사용자 수정 8개는 보존했다. 되돌리기는 본 문서 변경의 bounded revert로 가능하며 승인 원본 삭제·게임 저장 이관 없음.
