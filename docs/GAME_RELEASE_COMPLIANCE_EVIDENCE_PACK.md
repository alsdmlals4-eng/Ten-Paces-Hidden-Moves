# 십보강호 Game Release Compliance Evidence Pack

> Steam·STOVE 제출 전 프로젝트 단위로 채운다. 현재 상태는 Template 도입이며 실제 제출·등급·법률 검토가 아니다.  
> Base 기준: `alsdmlals4-eng/Base/templates/project-operations/GAME_RELEASE_COMPLIANCE_EVIDENCE_PACK.md`

## 0. Metadata

```yaml
release_pack_id:
project: TEN_PACES_HIDDEN_MOVES
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
baseline_commit:
target_build:
created_at:
updated_at:
owner:
status: DRAFT | IN_PROGRESS | READY_FOR_SUBMISSION | SUBMITTED | APPROVED | RETURNED | RELEASE_BLOCKED_UNVERIFIED | SUPERSEDED
```

## 1. Rating and audience

```yaml
rating_strategy: LOWEST_VIABLE_RATING
adult_only_avoidance: AVOID_ADULTS_ONLY
content_rating_target: UNASSIGNED_PENDING_REPRESENTATIVE_BUILD
target_audience: TEEN_AND_ADULT_STRATEGY_PLAYERS_PENDING_VALIDATION
children_in_target_audience: false
rating_decision_id:
rating_rationale:
```

전체이용가는 후보일 뿐 공통 강제 목표가 아니다. 청소년이용불가·18+를 기본적으로 피하되 비무의 핵심 경험을 숨기거나 설문을 축소하지 않는다.

## 2. Platform matrix

```yaml
platform_ratings:
  Steam:
    target_or_assigned_rating:
    regional_ratings:
    questionnaire_version_or_checked_at:
    build_evidence:
    store_evidence:
    trailer_screenshot_evidence:
    mature_content_disclosure:
    ai_disclosure:
    ads_ugc_online_interaction:
    status: NOT_STARTED | IN_PROGRESS | READY_FOR_SUBMISSION | SUBMITTED | APPROVED | RETURNED | RELEASE_BLOCKED_UNVERIFIED
  STOVE:
    target_or_assigned_rating:
    self_rating_scope: ALL_AGES | AGE_12 | AGE_15 | ADULT_ONLY_GRAC_REQUIRED | UNDECIDED
    questionnaire_version_or_checked_at:
    game_manual_evidence:
    gameplay_video_evidence:
    risk_scene_evidence:
    illustration_evidence:
    language_file_evidence:
    build_evidence:
    store_evidence:
    status: NOT_STARTED | IN_PROGRESS | READY_FOR_SUBMISSION | SUBMITTED | APPROVED | RETURNED | RELEASE_BLOCKED_UNVERIFIED
  Google_Play:
    status: NOT_APPLICABLE_MOBILE_CONSIDERATION_ONLY
```

## 3. Content risk matrix

| Risk | Present | Severity/frequency/context | Build evidence | Store/trailer evidence | Platform answer | Mitigation without core damage | Status |
|---|---|---|---|---|---|---|---|
| violence |  |  |  |  |  |  |  |
| sexual content |  |  |  |  |  |  |  |
| horror |  |  |  |  |  |  |  |
| language |  |  |  |  |  |  |  |
| drugs/alcohol/tobacco |  |  |  |  |  |  |  |
| crime |  |  |  |  |  |  |  |
| gambling/simulated gambling |  |  |  |  |  |  |  |
| ads/IAP |  |  |  |  |  |  |  |
| UGC/online interaction |  |  |  |  |  |  |  |
| AI-generated/live-generated content |  |  |  |  |  |  |  |

## 4. Consistency review

```yaml
build_store_questionnaire_consistency:
  target_build_matches_review_build:
  store_description_matches_features:
  capsule_and_screenshots_match_build:
  trailer_matches_representative_play:
  inaccessible_uploaded_content_disclosed:
  ads_and_offers_match_content_rating:
  online_ugc_features_disclosed:
  ai_content_disclosed:
  result: PASS | REVISION_REQUIRED | RELEASE_BLOCKED_UNVERIFIED
```

## 5. Asset rights coverage

```yaml
asset_rights_coverage:
  MUSIC_SFX:
  FONT:
  CHARACTER_ILLUSTRATION:
  MODEL_3D_ANIMATION:
  PLUGIN_ASSET:
  OPEN_SOURCE_LIBRARY:
  AI_OUTPUT_MODEL_TERMS:
  OUTSOURCING_CONTRACT:
  VOICE_COMPOSER_TRANSLATOR_CONTRACT:
open_source_notice_status:
ai_disclosure_status:
contract_coverage:
reference_to_original_coverage:
```

각 항목은 자산별 `docs/ASSET_RIGHTS_AND_PROVENANCE_RECORD.md` 인스턴스와 실제 shipping·marketing 사용처를 연결한다.

## 6. Secure evidence

```yaml
secure_evidence_policy:
  public_repository_contains_unredacted_contracts: false
  public_repository_contains_ids_or_signatures: false
  secure_original_location_scheme:
  proof_hash_policy:
  redaction_review:
  access_control_owner:
```

## 7. Automatic blockers

다음은 자동으로 `RELEASE_BLOCKED_UNVERIFIED`다.

- 필요한 권리가 `UNKNOWN` 또는 `PROHIBITED`
- 조건부 권리의 조건 이행 증거 없음
- reference-only 원본이 build·store·trailer에 포함됨
- AI model·terms version·input rights·Steam disclosure 누락
- OSS attribution·NOTICE·source 의무 누락
- 외주·성우·작곡·번역 계약 범위 누락
- build·store·trailer·questionnaire 불일치
- 청소년이용불가·18+ 위험에 대한 사용자 결정·플랫폼 경로 없음
- 민감한 계약 원본·개인정보가 공개 저장소에 노출됨

## 8. Release decision

```yaml
release_decision: READY_FOR_SUBMISSION | RELEASE_BLOCKED_UNVERIFIED | RETURN_TO_PRODUCTION | NOT_APPLICABLE
reviewed_by:
reviewed_at:
exact_build_commit:
static_evidence_status:
runtime_asset_use_status:
build_store_consistency_status:
platform_submission_status: PLATFORM_SUBMISSION_NOT_RUN
legal_review_status: LEGAL_REVIEW_NOT_PERFORMED
notes:
```

Template 작성이나 자동 테스트 통과만으로 Steam·STOVE 승인, 최종 등급 또는 법률 clearance를 주장하지 않는다.
