from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
PROFILE = ROOT / "docs" / "PLATFORM_RELEASE_AND_ASSET_RIGHTS_PROFILE.md"
ASSET_RECORD = ROOT / "docs" / "ASSET_RIGHTS_AND_PROVENANCE_RECORD.md"
RELEASE_PACK = ROOT / "docs" / "GAME_RELEASE_COMPLIANCE_EVIDENCE_PACK.md"
AGENTS = ROOT / "AGENTS.md"


class PlatformReleaseAssetRightsContractTests(unittest.TestCase):
    def test_required_project_documents_exist(self) -> None:
        for path in (PROFILE, ASSET_RECORD, RELEASE_PACK):
            self.assertTrue(path.is_file(), f"missing required release evidence document: {path}")

    def test_project_profile_declares_rating_platform_and_evidence_boundaries(self) -> None:
        text = PROFILE.read_text(encoding="utf-8")
        required = (
            "LOWEST_VIABLE_RATING",
            "AVOID_ADULTS_ONLY",
            "PC",
            "Steam",
            "STOVE",
            "MOBILE_CONSIDERATION_ONLY",
            "RELEASE_BLOCKED_UNVERIFIED",
            "content_rating_target",
            "target_audience",
            "violence",
            "AI-generated/live-generated content",
            "PLATFORM_SUBMISSION_NOT_RUN",
            "LEGAL_REVIEW_NOT_PERFORMED",
        )
        for token in required:
            self.assertIn(token, text)

    def test_asset_record_separates_rights_and_reference_to_original_evidence(self) -> None:
        text = ASSET_RECORD.read_text(encoding="utf-8")
        required = (
            "commercial_use",
            "distribution_in_game_build",
            "raw_source_redistribution",
            "license_version_or_terms_date",
            "reference_brief",
            "forbidden_expression",
            "final_asset_record",
            "reference_similarity_status",
            "secure_original_location",
            "MUSIC_SFX",
            "FONT",
            "CHARACTER_ILLUSTRATION",
            "MODEL_3D_ANIMATION",
            "PLUGIN_ASSET",
            "OPEN_SOURCE_LIBRARY",
            "AI_OUTPUT_MODEL_TERMS",
            "OUTSOURCING_CONTRACT",
            "VOICE_COMPOSER_TRANSLATOR_CONTRACT",
        )
        for token in required:
            self.assertIn(token, text)

    def test_release_pack_fails_closed_and_routes_from_agents(self) -> None:
        release_text = RELEASE_PACK.read_text(encoding="utf-8")
        agents_text = AGENTS.read_text(encoding="utf-8")
        for token in (
            "build_store_questionnaire_consistency",
            "asset_rights_coverage",
            "RELEASE_BLOCKED_UNVERIFIED",
            "Steam",
            "STOVE",
        ):
            self.assertIn(token, release_text)
        for path in (
            "docs/PLATFORM_RELEASE_AND_ASSET_RIGHTS_PROFILE.md",
            "docs/ASSET_RIGHTS_AND_PROVENANCE_RECORD.md",
            "docs/GAME_RELEASE_COMPLIANCE_EVIDENCE_PACK.md",
        ):
            self.assertIn(path, agents_text)


if __name__ == "__main__":
    unittest.main()
