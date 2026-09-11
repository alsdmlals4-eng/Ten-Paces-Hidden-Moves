# 십보강호 Asset Rights and Provenance Record

> 자산별 복사본을 만들어 작성한다. 이 빈 원장 자체는 실제 권리 증거가 아니다.  
> Base 기준: `alsdmlals4-eng/Base/templates/project-operations/ASSET_RIGHTS_AND_PROVENANCE_RECORD.md`

## Record

```yaml
asset_id:
category: MUSIC_SFX | FONT | CHARACTER_ILLUSTRATION | MODEL_3D_ANIMATION | PLUGIN_ASSET | OPEN_SOURCE_LIBRARY | AI_OUTPUT_MODEL_TERMS | OUTSOURCING_CONTRACT | VOICE_COMPOSER_TRANSLATOR_CONTRACT | OTHER
name:
project: TEN_PACES_HIDDEN_MOVES
creation_route: OWNED_ORIGINAL | COMMISSIONED_ORIGINAL | LICENSED_THIRD_PARTY | OPEN_SOURCE | AI_GENERATED | REFERENCE_TO_ORIGINAL | MIXED_ROUTE
creator_or_vendor:
source_url_or_path:
source_checked_at:
acquired_or_created_at:
license_or_contract:
license_version_or_terms_date:
commercial_use: ALLOWED | CONDITIONAL | PROHIBITED | NOT_REQUIRED | UNKNOWN
distribution_in_game_build: ALLOWED | CONDITIONAL | PROHIBITED | NOT_REQUIRED | UNKNOWN
raw_source_redistribution: ALLOWED | CONDITIONAL | PROHIBITED | NOT_REQUIRED | UNKNOWN
modification: ALLOWED | CONDITIONAL | PROHIBITED | NOT_REQUIRED | UNKNOWN
attribution:
platform_or_territory_restrictions:
term_or_expiration:
seat_account_or_project_restrictions:
open_source_notice_or_source_obligation:
ai_model_service_version:
ai_account_or_plan:
ai_terms_checked_at:
ai_input_rights:
ai_output_terms:
ai_human_contribution_and_postprocessing:
contract_scope:
voice_clone_or_ai_training_rights:
reference_sources:
reference_brief:
forbidden_expression:
final_asset_record:
reference_similarity_status: PASS | REVISION_REQUIRED | BLOCKED_UNVERIFIED | NOT_APPLICABLE
shipping_and_marketing_usage:
proof_reference:
proof_hash:
secure_original_location:
redacted_excerpt:
reviewed_by:
reviewed_at:
status: APPROVED | CONDITIONAL | REJECTED | RELEASE_BLOCKED_UNVERIFIED | SUPERSEDED
notes:
```

## Rights interpretation

- `commercial_use`, `distribution_in_game_build`, `raw_source_redistribution`, `modification`은 별개다.
- 게임에 포함해 배포할 권리가 확인되지 않았으면 상업 이용 가능 문구만으로 승인하지 않는다.
- 원본·소스 파일을 단독 재배포하지 않는다면 `raw_source_redistribution: NOT_REQUIRED`로 기록할 수 있다.
- 필요한 권리가 `UNKNOWN`이거나 조건 충족 증거가 없으면 `RELEASE_BLOCKED_UNVERIFIED`다.
- 오픈소스는 공개 저장소라는 이유만으로 허용하지 않고 license·copyright·NOTICE·source·수정 고지를 확인한다.
- AI는 모델·서비스·버전·계정/요금제·생성일·약관 날짜·입력 권리·출력 조건·사람 기여를 기록한다.
- 외주·성우·작곡·번역은 플랫폼·지역·기간·수정·2차적 이용·크레딧·재사용·AI 학습·음성 복제를 분리한다.

## Reference-to-original review

```yaml
reference_only_input_excluded_from_build:
functional_or_general_principles_extracted:
identifiable_expression_removed:
project_specific_canon_applied:
independent_working_files:
comparison_set:
reviewer:
reviewed_at:
reference_similarity_status:
```

허용하는 분석은 기능, 정보 위계, 상호작용 흐름, 일반적인 형태·리듬·재질·주파수·타이밍·성능 원리다.

다음은 독립 제작으로 인정하지 않는다.

- 이미지 tracing·overpaint·식별 가능한 캐릭터·구도·UI skin 복제
- 음악·효과음 sample, 멜로디·리프·보컬 재사용
- mesh·texture·rig·animation clip·font glyph 추출
- 특정 작가·성우·실존 인물의 식별 가능한 스타일·음성 모사
- 원본을 AI에 입력해 유사하게 만든 뒤 입력 권리·유사성 검토를 생략

## Public repository safety

공개 저장소에는 unredacted 계약서, 신분증, 서명, 주소, 전화번호, 계좌·결제·세금 정보와 비공개 단가를 넣지 않는다. 원본은 접근 통제된 Drive·계약 시스템·vault에 보관하고 `secure_original_location`, 최소 metadata, hash와 합법적으로 가린 발췌만 기록한다.

## 2026-09-11 승인 Blueprint 원화47개 정본 등록

사용자의 최종 시각 승인 원본은 `docs/planning-data/current_user_planning_status.json`의
`blueprint_final_approval`이며 승인 revision은 `c95ec7e671b14cfa1e8954f1f495ba2833bbd101`이다.
선정47개(무공30·인물16·합 설명1)의 원본 bytes를 보존하고 정확한 SHA-256을 대조한 복사본을 등록했다.
경로·ID·원본 해시·크기·용도는 `assets/blueprint/APPROVED_ART_MANIFEST.json`과
기존 `assets/ASSET_MANIFEST.json`의 신규 `blueprint_*` 항목에서 읽는다.
기존24개 manifest 항목의 정규화 해시를 보존 검사하며 기존 플레이어·모션 파일은 수정하지 않는다.

- 생성 경로: built-in image generation. 원문 요약 및 수정·선정 경과는 `docs/blueprint/ILLUSTRATION_CANDIDATES.md`.
- 백무진 참고 입력·해시는 `docs/blueprint/ASSET_READINESS.json`. 합 설명은 기존 검 동작 sequence를 인물 일관성 참고로 사용한 정적 원화다.
- 사용자 승인·정본 등록: `USER_APPROVED__CANON_REGISTERED`.
- 기계 검증: Python에서47개 승인 해시·ID·기존24개 항목 보존 PASS. exact Godot `4.7.1.stable.official.a13da4feb`에서47개 Texture2D 로드·성수 경계·알 수 없는 ID 거부 PASS.
- 제품 화면 통합·Windows visible·Android·Human·출시: 본 등록 검사만으로 PASS 아님. 화면 consumer 검증은 전체 구현 실행 기록을 따른다.
- 권리 상태: `RELEASE_BLOCKED_UNVERIFIED`. 서비스 exact model/version/account plan·당시 약관·참고 입력 권리의 완전한 증거는 이번 visual final lock으로 생성되지 않는다. 상업 이용·게임 배포·원본 재배포·수정 권한은 각각 `UNKNOWN`으로 유지한다.
- 조회 helper: `src/ui/approved_blueprint_art.gd`. 도감/브리핑은 `KEEP_ASPECT_CENTERED`와 동일 이미지의 UI 상태 표현을 사용한다. 신규 정적 원화는 전투 frame animation을 교체하지 않는다.

무공30개는 후속 연결에서 실제 `ActionChoiceCard/CardIllustration`과
`ActionDetailPanel/ApprovedManualIllustration`의 consumer를 확인했다.
현재 숙련도 대신 기술의 authored `unlock_star`(호환 `unlock_mastery`)로 선택해
10성 캐릭터의3성 기술에10성 그림이 잘못 표시되지 않도록 했다.
카드의 기존26px 밴드와 비용·효과·사거리 우선 정보를 보존하고, 큰 원화는 기존 상세 스크롤의
텍스트 뒤에만 표시한다. 원화 전체를 보이도록 비율을 유지하며 기본기와 기본 절초는 기존 atlas를 유지한다.
`verify_approved_manual_art_consumer.gd` RED→GREEN30개 실제 adapter 기술 인스턴스 검사와
기존 카드 통합·상세·무공·절초·UI/AI 채택5개 회귀가 PASS다. Windows visible/사람 검수는 별도다.
