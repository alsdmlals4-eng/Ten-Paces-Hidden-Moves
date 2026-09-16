
# 십보강호 GPT 이미지 생성·검수 워크플로

## 현재 추가 제작 지시 · 2026-09-14

사용자 지시에 따라 이후 새 이미지 후보는 피사체와 겹치지 않는 단색 크로마키 배경으로 생성한 뒤 배경을 제거한다. 이미지 생성·편집은 이미지 모델을 사용한다. 원본 크로마키 후보와 배경 제거 결과를 함께 보존하고, 실제 alpha 채널·가장자리 색 번짐·반투명 효과·손/무기/실루엣 손실·상태군 크기와 pivot을 검수한다. 불투명 체크무늬를 투명도 증거로 인정하지 않는다. 제거 과정에서 필수 픽셀이 훼손되면 재교정한다.

이 지시는 새 생성 방법을 소유하며 기존 승인 원화를 일괄 재생성하거나 최종 승인 상태를 바꾸지 않는다. 실제 consumer와 brief를 먼저 확인하고, 후보 생성→배경 제거→검수→사용자 final lock→catalog/provenance/hash 등록→runtime 연결의 경계를 유지한다. 현재 작업에서는 새 이미지 consumer가 없어 이미지 생성은 수행하지 않았다.

- Base: `alsdmlals4-eng/Base@c987647d01ad2baa028a16e03d85ddfc1572a727`
- 공용 Mode: `planning-visualization`, `final-visual-candidate`, `visual-qa-and-approval`
- Sheet 상태: `PROJECT_SHEET_CONFIGURED`

## 기획 중 우선 이미지

1. 10칸 일자형 전장과 거리·밀착 정보 목업.
2. `3수 → 3수 → 4수` 계획 슬롯과 실행 전/후 HUD.
3. 카드의 문파·무공 종류·사거리·비용·행동 슬롯·기력·내력 정보 위계.
4. 주요 문파·무공·심법의 실루엣과 색·상징 언어.
5. 숨은 수 단서·가설·파훼가 읽히는 결투 상황 비교.

## 기획 종료 우선 후보

1. 5개 앵커 결투 Demo 키아트와 Steam 캡슐 후보.
2. 실제 16:9 전투 HUD·카드·로그 고도화 목업.
3. 주요 인물·상대 무인 캐릭터 시트와 표정·포즈.
4. 무공서·절초·세력 카드의 반복 제작 가능한 시각 체계.

## 검수

`PLANNED → GENERATED_EXPLORATION → IN_REVIEW → REVISION_REQUIRED/REJECTED/APPROVED_CANDIDATE → PROJECT_ASSET_APPROVED → APPLIED_AND_RUNTIME_VERIFIED`를 사용한다.

전장·카드·HUD는 실제 화면 크기에서 거리, 선택, 대응, 합 결과가 읽혀야 한다. 손·무기·한글·배지·카드 정렬·원근 오류, 구현 비용, 특정 IP·작가 스타일 유사성, 원출처·라이선스를 검수한다. 생성 결과는 자동 최종 자산이 아니다.
