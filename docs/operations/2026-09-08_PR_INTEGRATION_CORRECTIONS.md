# 관련 PR 통합 및 전투 UI 회귀 교정

- 기준: main `c740253eaa76f52a71928fd5f17be7653a337f29`, 검토 PR head `cf8dde6b0c4a270f0273dcaebbe750e4aa0a5195`.
- Work Mode: BUILD / REVIEW. Skill Mode: scoped regression repair.
- Skills: workflow-router, systematic-debugging, test-driven-development, requesting-code-review, verification-before-completion.
- 권한: TEN-DEC-20260908-STANDING-PR-INTEGRATION-01. 다른 작업의 dirty checkout은 보존하고 별도 branch에서 교정한다.

## 문제와 채택 구조

기존 CI 성공과 달리 전체 Python 459개 중 진행 상태를 과거 값으로 고정한 검사 하나가 실패했다. 독립 코드 검토는 새 묶음 슬롯 미배치, 표현 중 미래 해결 로그 재노출, 막기/회피 전체 효과 소실을 발견했다. 제품 데이터·resolver는 변경하지 않고 실제 UI consumer를 최소 수정했다.

묶음 갱신 때 배치를 갱신하고, 관찰 정보 갱신은 잠긴 표현 화면의 로그 가시성을 덮어쓰지 않는다. 복기 상세는 review_ready에서만 명시적으로 열린다. 작은 상세창도 축약 요약 아래 원본 효과 전문을 유지한다. 너비 판단은 실제 크기를 사용한다.

## 근거와 적용 한계

CURRENT_SOURCE_RELEVANCE_CHECK: 기존 승인된 정보 경계와 3/3/4 UI의 회귀 복구다. 새 게임 의미·밸런스·외부 자산·의존성은 도입하지 않는다. 따라서 이 교정에는 신규 장르 비교를 발명하지 않고 기존 공개 정보/현재 수 표현 계약과 실제 재현을 적용한다. 다음 강호행로 구현은 기존 `2026-09-04_THREE_BRANCH_FOUR_CHOICE_ROUTE_BENCHMARK.md`의 별도 범위다. Base 최신 검토 횟수 드리프트는 프로젝트의 명시적 검토 계약을 자동 교체하지 않는다.

## 검증

- 새 Godot 반례: 수정 전 10 실패(exit 1), 수정 후 INTEGRATION_INFORMATION_BOUNDARIES_OK(exit 0).
- Python 전체: 459 tests OK. 과거 phase 기대값만 현재 승인된 다음 구현 상태로 교정; 구현완료로 승격하지 않음.
- Godot 4.7.1: action_detail_panel, frontal_duel_screen_partition, frontal_duel_plan_lock, vertical_slice_route_state, linked_action_blocks 통과.
- 독립 재검토: 세 Important 해소, 추가 Critical/Important 없음. 검토자는 코드 읽기만 수행했으며 실행 증거는 주 작업의 결과다.
- 새 검사를 Full Validation에 연결하여 로컬에서만 발견되고 사라지는 회귀를 방지한다.
- Headless editor import exit 0이지만 종료 때 ObjectDB 45 / resources 22 경고가 있었다. 런타임 focused test에서는 재현되지 않았다. 에디터 종료 누수 원인 확정은 미검증이다.
- 실제 사람 플레이, Android, 접근성, 출시: NOT_RUN. 전체 전투 모든 프레임 관찰은 focused 상태 테스트와 구별한다.

## 남은 작업

## 교정 lineage 재검토 기록

각 회차는 동일 교정 범위의 사용자 승인·owner·전체 diff·인접 consumer·복구·정보 경계·검증 한계와 대안을 재검토했다. 아래 항목은 회차의 대표 증거이며 서로 다른 렌즈를 회차로 센 것이 아니다.

1. 원 PR 전체 입력: CI 성공만 믿는 대안 기각. Python 실패와 독립 검토 세 결함을 검증 대상으로 채택; 승인 이미지·resolver·다른 checkout 보존. 재현 반례 10 실패.
2. 최소 교정 후보: 슬롯 갱신의 재귀 여부, 표현/복기 상태 경계, compact 전문 보존, 인접 소비자 재공격. 새 반례 GREEN 및 detail/partition/plan-lock/route/linked 회귀 통과. UI 전면 재작성보다 기존 owner 수정이 안전하다.
3. 정책/CI 포함 후보: 기존 read-only와 최신 사용자 승인 충돌을 AGENTS·통합계약·Active Context·current JSON으로 교정. 역사 binding은 보존. 새 테스트를 두 CI 경로에 연결. 전체 Python 459와 운영 검사 재통과. 독립 재검토 추가 중요 결함 없음.
4. 확장 회귀 후보: 전투 선택 통합·키보드·포커스 순서·레이아웃 자동 검사 모두 통과. resolver/data/save/asset bytes에는 교정 delta 없음. 보호 manifest의 기존 세 제품 경로 허용을 확인. 실제 사람 접근성 PASS로 확대하지 않음.
5. 통합 전 후보: main 재조회 동일, PR head 외부 변경 없음, 미해결 review thread 0, branch rules API 결과 빈 목록 확인. 기존 #199/#200은 문서/이전 Base 채택 범위로 식별하고 게임 UI 패치에 무차별 혼합하지 않음. import 부산물과 dirty 원 작업은 stage하지 않는다. 중복 구현보다 이 교정 PR을 먼저 통합하고 새 행로 구현을 잇는 것이 장기적으로 적합하다. 원격 exact-head 검증과 postmerge readback은 아직 남아 있다.

Exact-head 원격 CI와 보호 규칙 확인 및 main readback은 통합 시 별도 실행한다. 승인된 블루프린트와 4회 강호행로·이벤트·휴식·정탐 구현은 후속 작업이며 이 교정으로 완료를 주장하지 않는다. 승인 원본 이미지·다른 worktree·미커밋 파일은 변경/삭제하지 않는다.

## 원격 검증에서 재개방된 교정

원격 run 34154758662는 기존 PDF를 text diff로 인식하여 PDF 내부의 정상 공백을 오류로 처리했다. 로컬 속성 반례도 `unspecified/astextplain/unspecified`로 RED였다. `.gitattributes`의 `*.pdf binary`로 저장 바이트/병합/비교 정책을 명시한다. PDF bytes는 수정하지 않으며 test_pdf_binary_contract를 추가한다. 이 실패는 이전 CI 성공이나 새 UI 회귀와 무관한 통합 누락으로, 검사 제외나 실패 무시로 처리하지 않는다.
