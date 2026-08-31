# 십보강호 플랫폼 출시·에셋 권리 Profile

> Base 정본: `alsdmlals4-eng/Base/docs/knowledge/game-development/PLATFORM_REVIEW_ASSET_RIGHTS_AND_REFERENCE_PRODUCTION_GUIDE.md`  
> 프로젝트: `십보강호: 숨은 수의 비무 (Ten Paces: Hidden Moves)`  
> 기준 main: `bbed0fd4d278ca0e0d52f4e6d9083aafa1997318`  
> 상태: `STATIC_PROFILE_CREATED / PROJECT_ASSET_AUDIT_NOT_RUN / PLATFORM_SUBMISSION_NOT_RUN`

이 문서는 프로젝트별 출시·권리 Profile이다. 최종 이용등급, 법률 검토, Steam·STOVE 승인 또는 실제 자산 권리 확보를 보증하지 않는다.

## 1. 플랫폼·등급 전략

```yaml
rating_strategy: LOWEST_VIABLE_RATING
adult_only_avoidance: AVOID_ADULTS_ONLY
content_rating_target: UNASSIGNED_PENDING_REPRESENTATIVE_BUILD
rating_candidate_range: AGE_12_CANDIDATE_NOT_ASSIGNED
target_audience: TEEN_AND_ADULT_STRATEGY_PLAYERS_PENDING_VALIDATION
children_in_target_audience: false
families_policy_applicable: false
```

전체이용가는 강제 목표가 아니다. 무협 비무의 핵심 재미·합·피격·중단 표현을 숨기지 않으면서 청소년이용불가·18+를 피할 수 있는 가장 낮은 정직한 등급을 프로젝트별로 선택한다.

## 2. 목표 플랫폼

```yaml
platforms:
  PC: PRIMARY
  Steam: RELEASE_CANDIDATE
  STOVE: RELEASE_CANDIDATE
  Google_Play: MOBILE_CONSIDERATION_ONLY
  Android: MOBILE_CONSIDERATION_ONLY
```

현재 프로젝트 정본은 PC 우선이다. 모바일은 검토 가능성만 기록하며 Android·Google Play 출시 준비 완료를 주장하지 않는다.

## 3. 콘텐츠 위험 초안

| Risk | 현재 관찰 | 증거 상태 | 출시 전 확인 |
|---|---|---|---|
| violence | 무협 1대1 비무, 공격·방어·회피·중단 | 기획 정본만 확인 | 대표 빌드의 시각·음향 강도, 유혈·상처 표현 |
| sexual content | 현행 핵심 정본에서 확인되지 않음 | 불완전 | 전체 콘텐츠·상점 이미지 전수 확인 |
| horror | 핵심 요소 아님 | 불완전 | 연출·이벤트 전수 확인 |
| language | 확정 증거 없음 | 불완전 | 대사·기술명·상점 문구 확인 |
| drugs/alcohol/tobacco | 확정 증거 없음 | 불완전 | 배경·아이템·대사 확인 |
| crime | 비무 맥락 외 확정 증거 없음 | 불완전 | 서사·의뢰 확인 |
| gambling/simulated gambling | 확정 시스템 없음 | 불완전 | 확률형 보상·유료 재화 여부 확인 |
| ads/IAP | 현재 출시 모델 미확정 | UNDECIDED | 상점·결제·확률 공개 정책 |
| UGC/online interaction | 비동기 기능 보류 | NOT_IMPLEMENTED | 실제 출시 기능과 설문 일치 |
| AI-generated/live-generated content | 제작 과정·최종 shipping 자산별 기록 필요 | UNVERIFIED | Steam disclosure와 권리 Record 연결 |

위 표는 등급 판정이 아니다. 실제 build·store·trailer·questionnaire가 준비되면 다시 작성한다.

## 4. 자산 Coverage

최소 다음 범주를 `docs/ASSET_RIGHTS_AND_PROVENANCE_RECORD.md` 인스턴스로 관리한다.

1. 음악·효과음
2. 폰트
3. 캐릭터·일러스트·UI
4. 3D 모델·애니메이션
5. 플러그인·에셋
6. 오픈소스 라이브러리
7. AI 출력·모델·서비스·약관
8. 외주 제작 계약
9. 성우·작곡가·번역가 계약

shipping build뿐 아니라 capsule, trailer, screenshot, press kit와 광고도 원천 자산 Record에 연결한다.

## 5. 참조 기반 독립 제작

```text
합법적인 reference source 기록
→ 기능·구조·정보 위계·일반 제작 원리 분석
→ 식별 가능한 고유 표현을 forbidden_expression에 기록
→ 십보강호 정본에 맞는 reference_brief 작성
→ 원본과 분리된 작업 파일·최종 자산 제작
→ similarity and rights review
→ final_asset_record 승인
```

원본 이미지·사운드·메시·텍스처·리그·폰트 글리프·코드를 조금 바꾸거나 AI로 다시 생성했다는 이유만으로 독립 자산으로 보지 않는다. 특정 작가·작품·캐릭터·성우의 식별 가능한 표현이나 음성을 모사하지 않는다.

## 6. Release Gate

다음 중 하나라도 남으면 `RELEASE_BLOCKED_UNVERIFIED`다.

- shipping·marketing 자산의 출처·라이선스·계약·약관 버전 누락
- `commercial_use` 또는 `distribution_in_game_build`가 `UNKNOWN`·`PROHIBITED`
- 조건부 권리의 조건 이행 증거 없음
- 참조 원본이 build·store·trailer에 포함됨
- `reference_brief`, `forbidden_expression`, `final_asset_record`, 유사성 검토 누락
- OSS NOTICE·attribution·source 의무 누락
- AI 입력 권리·모델/서비스/버전·약관 날짜·Steam disclosure 누락
- build·store·trailer·questionnaire 불일치
- 민감한 계약 원본·개인정보가 공개 저장소에 노출됨

## 7. 증거 상태

```text
STATIC_EVIDENCE_PROFILE_CREATED
RUNTIME_ASSET_USE_CHECKED: NOT_RUN
BUILD_STORE_CONSISTENCY_CHECKED: NOT_RUN
STEAM_SUBMISSION: PLATFORM_SUBMISSION_NOT_RUN
STOVE_SUBMISSION: PLATFORM_SUBMISSION_NOT_RUN
FINAL_RATING: NOT_ASSIGNED
LEGAL_REVIEW: LEGAL_REVIEW_NOT_PERFORMED
```
