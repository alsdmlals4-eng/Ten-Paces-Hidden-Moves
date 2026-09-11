# 통합 블루프린트 편집 · 복구 기록

기준 Project main: 885c91ee934a6f096c79c7d0cfb5f31db4de7f5c.
Base completed main 관측: 2f93e872d9ed4fa18018ac759b01acd7d34e9b58.
Work Mode: BUILD / REVIEW. Skill Mode: 승인 복구, rule-update(기획 권장안), PDF 렌더 검수.
사용자 승인: 복구 허용·라우터 지속 교정, 중복 제거·종류별 편집·10전 기준 하위 단계 상세표,
3/7/10성 삽화와 5/9성 종속 설명. 고정 원본 캐릭터/모션은 변경하지 않는다.

## 원인과 복구

라우터 직접 편집은 Base 생성물 byte 일치 검사와 충돌한다. 수정 책임을 프로젝트 AGENTS에
두고 생성 라우터는 그대로 유지했다. 기존 제품 변경과 문서 작업을 다른 작업 공간에 보존했다.
동일 protected baseline, 동일 adopted Base, 동일 검사로 문서 공간 진입 PASS.
이 경로는 외부 승인 true를 조작하거나 제품 실패를 PASS로 바꾸지 않는다.
원 제품 공간에도 같은 상위 규칙을 적용하고 직접 편집했던 생성 라우터를 원복했다.

## 조사·재사용과 범위

기존 12종 benchmark의 행동 구분·거리·정보 경계 원칙을 재사용한다. 이번 직접 재확인은
Sirlin Yomi 2 소개, Subset Into the Breach 소개, Shogun Showdown 공식 상품 페이지다.
카드 그림과 의미의 구분 ADAPT, 완전 적 의도 공개/덱 시스템 REJECT.
외부 게임의 능력치나 성장 수치를 복사하지 않았다. 신규 권장 수치는 자체 튜닝 초안이며
10게임의 스테이지 성장 정량 비교나 사람 검증을 완료했다고 주장하지 않는다.

- https://www.sirlin.net/posts/introducing-yomi-2
- https://www.subsetgames.com/itb.html
- https://store.steampowered.com/app/2084000/Shogun_Showdown/

## 이번 검증

- 기존 복구 차단은 직전 실제 수행 실패로 관측했다. 생성물 drift 원인을 후속 발견하여 owner 교정.
- 단계표 검사 RED(구현 없음) → GREEN. 15명×10단계, 합계 일치, 능력치·성수 단조성, 절초 해금 검사.
- 프로젝트 운영 검사 PASS, pinned Base approved operating 검사 PASS(문서 격리 공간 한정).
- 17쪽 부분 PDF 제작. 매화검결과 상대 첫 페이지를 직접 렌더 확인했다. 표와 주석 겹침을
  발견하여 수정하고 재렌더 확인했다. 수정본 17쪽 전체를 5개 contact sheet로 직접
  확인했고 상대 첫 페이지와 매화검결은 확대 확인했다. 이는 사람 UX 승인과 다르다.
- 그림 3장은 built-in 생성 후보. 첫 그림의 검끝 여백 수정 필요, 사용자 미확정, 런타임 미연결.
- 기존 검토 회차를 초기화하지 않고 발견 결함별 수정으로 기록한다.

## 당시 남은 작업 (초기 17쪽 시점의 역사 기록)

전체 중복 없는 통합 PDF, 단계별 자원 최대치·별호, 수치/무기 설명 불일치 교정,
27장 삽화와 전체 최종 확정, 원 제품 공간 승인 metadata 복구·전체 런타임 검증,
GitHub safe merge·Base 공용 교훈 환류. 현재 기록은 이 항목들의 완료 증거가 아니다.

## 최종 통합 편집 후속 교정

- 전체 81쪽을 생성·렌더 확인했고 삽화 확대, 능력치 열 정렬, 흐름 연결과 거리0 중첩을 교정했다.
- 무공30장(3/7/10성), 상대15장(여성7·남성8), 합 핵심 장면1장을 제작·직접 확인했다.
- 상대150행의 단계별 별호, 성수·기술·강화와 자원 상한30/5/4를 명시했다.
- 5/9성은 종속 설명만 사용한다. 기존 PDF·원화·제품 미커밋 작업은 보존했다.
- 공식 사례11개 제한 비교는 `docs/blueprint/RESEARCH_20260910.md`에 기록했다.
- 표적 독립 검토: 재도전1회 제한, 반격 설명 누락, 능력 원본 해시 누락, 개인 경로 캡처 의존을 발견·교정했다. 기존 전체 검토2회를 재시작한 것이 아니다.
- 반격 설명은 실패 회귀 RED → 구현 GREEN으로 확인했다. 문서 작업의 운영 검사와 adopted Base 검사는 PASS.
- PDF 내부 그림만 원해상도 JPEG quality93/4:4:4로 인코딩하여 약242MB에서 약51MB로 감소시켰다. 원본 PNG는 변경하지 않았다.
- 캡처는 repository 증거 폴더에 보존하고 누락 시 builder가 실패한다. 생성 장면은 실제 실행 캡처로 표시하지 않는다.
- 문서 완성은 신규 원화 최종 lock, 제품 연결, 사람 체감, Android, 출시 또는 GitHub 병합 완료를 뜻하지 않는다.

### 남은 제품·전달 경계

기존 제품 공간의 보호 승인 metadata 복구, 새 회차 상대추첨·저장, 새 단계수치 연결,
전 무기 모션·VFX·청감·완주 검증은 미완료다. Base 공용 owner 반영과 GitHub exact-head
CI·병합·main readback은 별도 검증 전까지 완료로 주장하지 않는다.
열린 #199/#200의 실제 diff를 확인했다. 오래된 front-door/채택 pin을 current main에
덮어쓰지 않았고, 기존 branch를 보존했다.

## 최신 추가 요구: 복수 무공·설명 자료 복원

- 기준 HEAD d6cbc2c5 / Work Mode PLAN·BUILD(문서) / Skill game-design balance-review, pdf 편집·검수.
- 81쪽 최종 전달과 병합을 보류하고 PR340을 Draft로 전환했다.
- 기존15명+백무진을16명으로 명세화하고, 주력1+보조2권의10단계160행을 생성했다.
- 실제 NEXT_STAR_COSTS와 대조하는 회귀를 포함해 비용·무공 유일성·단조성·해금 검사4건 PASS.
  최초 두 회귀는 구현 전 AttributeError/KeyError RED를 관측했다. 반격 설명 기존 회귀1건도 PASS.
- 10/5/3은43점, 기준10/7/5는57점. 플레이어 승리·행로 수련 비교를 추가하되 사람 밸런스 PASS는 아님.
- 기존 PDF의 내장 화면8개를 비손실 추출하고 원본/개별 해시를 보존했다.
- 장식 그림을 제거하고 이미지 노드 흐름·아틀라스·행로 상태/사건·브리핑·연격·회피를 복원했다.
- 87쪽 재편집판의 첫 전체 렌더를15개 접촉 시트로 직접 검토했다. 후속 숫자/출처/체크 표 교정은 재생성·재검수 대상이다.
- 독립 검토는 실제 제품 소비자와 저장 경계를 읽기 전용으로 확인했다. 새 full-scope 회차를 만들지 않았다.
- 제품 변경은 수행하지 않았다. shell/bridge/codec 한 권 제한, 전체 catalog의 저장 identity,
  적 금지 관찰 강화, 제약·정탐·측정 소비자가 남아 있다. 기존 제품 미커밋 상태와 저장을 보존했다.
- 현재 PR340에는 외부 approved-protected-change metadata가 없다(실제 GitHub labels=[] 확인).
  문서 수정의 승인·검사는 제품 보호 경로 승인이나 저장 호환 검증을 대신하지 않는다.

## 2026-09-11 상세 기획 승인 검토본 재개

- 기준 SHA6d84832d / Work Mode PLAN·BUILD(문서) / Skill game-design·combat-implementation-handoff·pdf·TDD / Skill Mode balance-review·implementation-spec·artifact-review.
- 최신 사용자 지시로 타 프로젝트 참고 대기 해제. main885c91ee, Base remote2f93e872를 읽었으며 채택 계약을 임의 갱신하지 않았다.
- 원래 dirty6개 문서/도구를 tmp/resume-preservation-20260911에 해시와 함께 보존한 후 같은 Draft PR340의 문서 분기에서 계속했다.
- 고정3권·공통 접두어를 인물별2~5권·고유4단계 별호로 교체. 비용곡선 회귀 RED2건 관측 후 GREEN. 현재 관련 회귀6건+복구 owner1건 PASS.
- 상세 SWOT4면·인물별 전술8면·구현 인수8면 추가. 저장 schema/content identity/한 권 제한 실제 소비자를 읽고 v1 보존·v2 새 여정 계약을 작성했다.
- 백무진 전용1024×1536 후보1장 생성·시각 검토. 출처·해시·소비처·상태군은 ASSET_READINESS.json에 기록, 정본/제품 승격 안 함.
- CURRENT_SOURCE_RELEVANCE_CHECK: 저장·RNG는 공식 Godot 본문 조회; 무공 수/성장 의사결정의 기존11개 비교를 현재 차원에 재대조. 별도 프로젝트 작업 자료는 사용하지 않았다. 제한은 RESEARCH_20260910.md에 기록했다.
- 표적 검토 발견: 옛 초상15+기존1, 고정3권, 천기비성술5성 오기, 검증하지 않은 적 필터 위치 단정. 각 표현을 교정하고 내용 검사·렌더로 재검증했다.
- 원본 JSON→기획 계산기→160행/112쪽→승인 후 catalog/shell/bridge/codec 흐름을 기존 Blueprint에 설명했다. 별도 대시보드를 만들지 않았다.
- 자동화: 인물별 편성·비용·별호 회귀와 PDF 내용·source hash 검사 갱신. 공용 정책/메모리 mutation 없음.
- 상세 수치·별호·후보 원화 최종 검토 후 실제 구현. Godot·Human·실기기·출시 NOT_RUN. 문서 검증 해시는 FINAL_REVIEW.md 참조.

## 2026-09-11 사용자 최종 lock 기록

기준c95ec7e6 / Work Mode PLAN / Skill project workflow-router·reference-freshness / Skill Mode approval-readback.
사용자의 명확한 확정 부분을 기존 Decision·current planning JSON·Active Context에 반영했다.
112쪽 PDF와 선정47개 원화의 SHA-256을 재검증하여 승인 snapshot을 남겼다. 기존 PDF/receipt와
미선정 후보는 보존했다. 신규 외부 사실·설계 변경 없는 승인 기록이므로 CURRENT_SOURCE_RELEVANCE_CHECK=NOT_APPLICABLE.
프로젝트 진입 계약 PASS, 승인 대상 exact remote head의27SUCCESS/3SKIPPED 확인.
기존 두 차례 검토를 초기화하지 않고 승인 범위·원본 해시·현재 상태 참조를 표적 대조했다.
제품 적용·Human·Android·출시 상태를 승격하지 않았다. 후속 실행 뜻은 사용자 확인 중.
