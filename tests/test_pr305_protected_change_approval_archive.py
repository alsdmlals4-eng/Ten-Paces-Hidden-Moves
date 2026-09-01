from __future__ import annotations

import hashlib
import re
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RECORD = ROOT / "docs" / "operations" / "2026-09-01_PR305_PROTECTED_CHANGE_APPROVAL_RECORD.md"
PR305_MERGE = "ab180360da27c163b7da4dc3c17789fa29bc1a14"
MANIFEST_PATH = "docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json"
EXPECTED_PATHS = (
    "data/cards/martial_manuals/beggars_dragon_subduing_palm.json",
    "data/cards/martial_manuals/hebei_peng_five_tigers_saber.json",
    "data/cards/martial_manuals/mount_hua_plum_blossom_sword.json",
    "data/cards/martial_manuals/nangong_boundless_sky_sword.json",
    "data/cards/martial_manuals/shaolin_arhat_vajra_art.json",
    "data/cards/martial_manuals/sichuan_tang_hidden_weapons.json",
    "data/cards/martial_manuals/wudang_taiji_sword.json",
    "data/cards/martial_manuals/yang_family_spear.json",
    "data/cards/ultimate_cards.json",
    "data/combat/combat_board_poc.json",
    "data/combat/combat_progress_preview.json",
    "data/combat/combat_resolution_preview.json",
    "data/combat/mastery_ultimate_poc.json",
    "scenes/ui/action_selection/linked_action_block.tscn",
    "scenes/ui/combat_progress_button.tscn",
    "src/combat/battle_background.gd",
    "src/combat/combat_ai_planner.gd",
    "src/combat/combat_board_preview.gd",
    "src/combat/combat_board_preview_auto.gd",
    "src/combat/combat_character_placeholder.gd",
    "src/combat/combat_resolution_engine_ten_manuals.gd",
    "src/ui/action_selection/action_placement_controller.gd",
    "src/ui/action_selection/action_selection_dock.gd",
    "src/ui/action_selection/action_view_model_adapter.gd",
    "src/ui/action_timing_panel.gd",
    "src/ui/action_timing_panel_auto.gd",
    "src/ui/combat_progress_button.gd",
    "src/validation/vertical_slice_balance_public_policy.gd",
)


class Pr305ProtectedChangeApprovalArchiveTests(unittest.TestCase):
    def test_record_preserves_the_exact_original_approval_paths_and_hash(self) -> None:
        record = RECORD.read_text(encoding="utf-8")
        manifest = subprocess.check_output(
            ["git", "show", f"{PR305_MERGE}:{MANIFEST_PATH}"],
            cwd=ROOT,
        )

        self.assertIn(f"implementation_merge_commit: {PR305_MERGE}", record)
        self.assertIn(
            f"approval_manifest_sha256: {hashlib.sha256(manifest).hexdigest().upper()}",
            record,
        )
        section = re.search(
            r"approved_protected_paths_exact:\n(?P<paths>(?:  - .+\n)+)",
            record,
        )
        self.assertIsNotNone(section)
        archived_paths = tuple(re.findall(r"^  - (.+)$", section.group("paths"), re.MULTILINE))
        self.assertEqual(EXPECTED_PATHS, archived_paths)


if __name__ == "__main__":
    unittest.main()
