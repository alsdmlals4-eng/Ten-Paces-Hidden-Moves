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
