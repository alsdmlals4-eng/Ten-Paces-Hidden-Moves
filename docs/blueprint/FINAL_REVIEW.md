# 통합 편집판 전달 검수

대상: `output/pdf/TEN_PACES_HUMAN_BLUEPRINT_20260910_COMPLETE.pdf`

- PDF SHA-256: `3571f98886cfe2114732bbfa95c15522daf6b28229212591969d92a3c5d24560`
- 81쪽 / 50,735,293 bytes. 원본 PNG 그대로 보존, PDF 삽입 사본만 JPEG93/4:4:4.
- 첫 전체 81쪽 렌더를 14개 contact sheet로 직접 확인했다. 이후 교정본 전체를 다시 렌더했다.
- 교정 후 확대 확인: 전체 플로우, 준비 구조, 실행 배치, 상대 능력치 정렬, 매화·양가창·소요·팽가도·창궁, 단계 체크.
- 내용 검사 PASS: 81쪽과 receipt 일치, 중복 제목 없음, 무공 기술·강화 명칭, 30개 삽화, 15명 초상, 150단계 표, 내부 코드 토큰 노출 검사.
- 단계 회귀 PASS: 단조 성장·성수·해금·별호·자원 상한·초상 존재.
- 반격 설명 회귀: RED 관측 후 GREEN. 복구 owner 회귀 PASS.
- 프로젝트 운영 검사 PASS / adopted Base exact validator PASS (문서 격리 공간 한정).
- 독립 표적 검토 4건 교정: 재도전 제한, 단계 가중치 source hash, 캡처 개인 경로 의존, 반격 의미 누락.
- 새 full-scope 검토 회차를 추가한 것이 아니다. 기존 2회 이후 결함별 교정·영향 검증이다.

실제 게임 전체·사람 체감·Android·음향 청감·출시 권리 PASS가 아니다.
신규 그림은 reader-facing 후보이며 승인된 전투 모션을 변경하지 않았다.
기존 도감보다 세부 내용이 줄지 않도록 종류별 책임 페이지를 분리했다. 같은 무공의 5/9성은 3/7성 아래에만 설명한다.

## 보존·재현

원본 36쪽 PDF와 복원 비교판은 미수정. 선택 PNG와 실제 촬영2장, capture manifest를 repository에 보존한다.
manifest는 원래 촬영 전체 기록이며 이 편집판에 채택한 프레임은 preparation-plan / execution-024뿐이다.
PDF builder는 필요한 두 촬영과 manifest가 없으면 실패한다. 출처 해시는 빌드 시 로컬 원본 bytes 기준이다.
새 체크아웃에서 재생성하면 메타데이터·로컬 경로·줄끝 차이에 따라 byte hash는 달라질 수 있다. 동일 byte PDF 재현을 주장하지 않는다.

## 별도 미완료

제품 변경·신규 자산 final lock·원 제품 보호 metadata 복구·Base 공용 반영·GitHub CI와 병합은 별도다.
이 전달 검수표는 그 상태를 대신 승인하지 않는다.
