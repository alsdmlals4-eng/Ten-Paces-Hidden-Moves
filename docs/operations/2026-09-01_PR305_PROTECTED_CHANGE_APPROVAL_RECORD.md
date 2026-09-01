# PR 305 보호 변경 승인 Archive Record

```yaml
artifact_role: PROTECTED_CHANGE_APPROVAL_ARCHIVE_RECORD
implementation_pr: 305
implementation_pr_url: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/pull/305
implementation_merge_commit: ab180360da27c163b7da4dc3c17789fa29bc1a14
implementation_base_commit: 8d0f401f42431e78f78f26067f3dfc0309ddda9e
decision_ids:
  - TEN-DEC-20260901-GROUNDED-DUEL-AUTO-TARGET-OBSERVE-01
approved_protected_path_groups_for_reading_only:
  - data/cards/martial_manuals/*
  - data/cards/ultimate_cards.json
  - data/combat/*
  - scenes/ui/action_selection/linked_action_block.tscn
  - scenes/ui/combat_progress_button.tscn
  - src/combat/*
  - src/ui/action_selection/*
  - src/ui/action_timing_panel*.gd
  - src/ui/combat_progress_button.gd
  - src/validation/vertical_slice_balance_public_policy.gd
approved_protected_paths_exact:
  - data/cards/martial_manuals/beggars_dragon_subduing_palm.json
  - data/cards/martial_manuals/hebei_peng_five_tigers_saber.json
  - data/cards/martial_manuals/mount_hua_plum_blossom_sword.json
  - data/cards/martial_manuals/nangong_boundless_sky_sword.json
  - data/cards/martial_manuals/shaolin_arhat_vajra_art.json
  - data/cards/martial_manuals/sichuan_tang_hidden_weapons.json
  - data/cards/martial_manuals/wudang_taiji_sword.json
  - data/cards/martial_manuals/yang_family_spear.json
  - data/cards/ultimate_cards.json
  - data/combat/combat_board_poc.json
  - data/combat/combat_progress_preview.json
  - data/combat/combat_resolution_preview.json
  - data/combat/mastery_ultimate_poc.json
  - scenes/ui/action_selection/linked_action_block.tscn
  - scenes/ui/combat_progress_button.tscn
  - src/combat/battle_background.gd
  - src/combat/combat_ai_planner.gd
  - src/combat/combat_board_preview.gd
  - src/combat/combat_board_preview_auto.gd
  - src/combat/combat_character_placeholder.gd
  - src/combat/combat_resolution_engine_ten_manuals.gd
  - src/ui/action_selection/action_placement_controller.gd
  - src/ui/action_selection/action_selection_dock.gd
  - src/ui/action_selection/action_view_model_adapter.gd
  - src/ui/action_timing_panel.gd
  - src/ui/action_timing_panel_auto.gd
  - src/ui/combat_progress_button.gd
  - src/validation/vertical_slice_balance_public_policy.gd
approval_manifest_path: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
approval_manifest_sha256: 3E6A8D75883F39FCB81817D3893D6F88500776DB8BFA244C35579CA3FA72C045
approval_lifecycle: ARCHIVE_RECORD_RETAINED_ACTIVE_MANIFEST_REMOVED_BY_THIS_CLEANUP_PR
remote_ci: PR305_APPROVED_PROTECTED_CHANGE_LABEL_AND_NORMAL_MERGE_CONFIRMED
evidence_ceiling: PR305_MACHINE_AND_REMOTE_CI_EVIDENCE_ONLY_HUMAN_DEVICE_ACCESSIBILITY_RELEASE_NOT_RUN
```

PR #305's manifest was a single-PR authorization for grounded frontal presentation, movement-only intent, non-movement public-opponent auto target, bounded timing blocks, compact execution control, type-only observation, and atomic ultimate reservation. The PR was normally merged at the exact commit above with the required `approved-protected-change` label.

This immutable record preserves the original authorization after removing the active manifest. It prevents a later protected change from silently inheriting PR #305's larger path set or approval source. The next protected baseline is PR #305's merge commit; this new plan-lock refinement must use its own Decision, BUILD approval, review, and exact-PR label.
