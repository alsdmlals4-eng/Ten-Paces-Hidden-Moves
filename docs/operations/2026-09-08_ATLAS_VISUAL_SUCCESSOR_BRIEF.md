# 아틀라스 기반 시각 교체 · 공통 배경 후보

최신 사용자 지시: 기존 인게임 이미지 대부분을 Blueprint/Atlas에 맞게 교체 가능.
개선된 이미지에 맞춰 Blueprint 이미지도 변경 가능. 이전 승인본은 보존한다.

초기 brief: NEEDED → BRIEF_READY. 현재 생성/연결 상태는 같은 자산의 manifest가 소유한다.
생성 도구: built-in image_gen. 상업 배포 권리 검증은 별도.
참조: 사용자 승인 core screen 60018f76, 승인 문서의 3×3 Atlas v2.
입력은 사용자가 제공한 프로젝트 이미지이며 외부 게임 아트는 입력하지 않는다.
후보 사용처: combat backdrop, briefing backdrop, result backdrop, Human Blueprint.
현행 consumer: src/ui/main_title_screen.gd 및 combat scene의 배경 TextureRect 계열.
기존 원본을 덮어쓰지 않고 후보를 별도 보존; 최종 채택/런타임 등록은 별도 상태다.

## 생성 요청

고해상도 16:9 반실사 수묵 무협 비무장. 청회색과 먹색, 자연스러운 종이·붓 질감.
중앙 먼 문루, 양옆 대나무, 달빛과 희미한 등불. 화면 중앙/하단은 인물과 UI를
겹칠 수 있는 빈 석재 마당. 인물·무기·HUD·문구·테두리·숫자 없음.
전투 판정/현재 계획을 암시하는 이펙트 없음. 광택 3D/픽셀/황갈색 일색 금지.
전체 구도는 승인 전투 장면의 앞쪽 마당과 중앙 문루를 유지하고 형태·가독성 개선.
